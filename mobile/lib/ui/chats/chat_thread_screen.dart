import 'dart:async';



import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';

import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';



import '../../core/auth/auth_repository.dart';

import '../../core/calls/call_repository.dart';

import '../../core/chat/chat_models.dart';

import '../../core/chat/chat_repository.dart';

import '../../core/chat/conversation_id.dart';

import '../../core/chat/outbox_service.dart';

import '../../core/db/message_store.dart';

import '../../core/auth/session_provider.dart';

import '../../core/realtime/chat_realtime_service.dart';

import '../../core/safety/safety_repository.dart';

import '../calls/call_room_screen.dart';



class ChatThreadScreen extends ConsumerStatefulWidget {

  const ChatThreadScreen({

    super.key,

    required this.conversationId,

    required this.title,

    this.peerUserId,

    this.groupId,

    this.username,

    this.isGroup = false,
  });

  final String conversationId;
  final String title;
  final String? peerUserId;
  final String? groupId;
  final String? username;
  final bool isGroup;



  @override

  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();

}



class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> with WidgetsBindingObserver {

  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];

  bool _loading = true;

  String? _error;

  String? _conversationId;

  String? _peerUserId;

  String? _groupId;

  bool _isGroup = false;

  Timer? _typingDebounce;

  Timer? _typingClearTimer;
  Timer? _typingKeepAlive;

  StreamSubscription<Map<String, dynamic>>? _realtimeSub;

  StreamSubscription<List<ChatMessage>>? _messagesSub;

  Future<void>? _inFlight;

  int _lastCount = 0;

  final Set<String> _acknowledgedDelivery = {};

  bool _peerTyping = false;

  bool _readReceiptsEnabled = true;

  bool _typingEnabled = true;



  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final myId = ref.read(sessionProvider).userId!;



    _isGroup = widget.isGroup || isGroupConversation(widget.conversationId);

    _groupId = widget.groupId ?? groupIdFromConversation(widget.conversationId);

    _peerUserId = widget.peerUserId ?? peerUserIdFromConversation(widget.conversationId, myId);

    _conversationId = widget.conversationId;



    if (!_isGroup && _peerUserId == myId) {

      _error = 'Cannot chat with yourself. Use the other emulator account.';

      _loading = false;

      return;

    }



    if (!_isGroup && _peerUserId != null) {

      ref.read(chatRepositoryProvider).warmPeer(_peerUserId!);

    }

    _loadPrivacy();

    // UI is a projection of the local DB → cached messages render instantly
    // (offline-capable). The network sync below just writes into that DB.
    _subscribeToStore();
    _syncMessages();
    _flushOutbox();

    _startRealtime();

    _input.addListener(_onInputChanged);

  }



  Future<void> _loadPrivacy() async {

    try {

      final p = await ref.read(authRepositoryProvider).getPrivacy();

      if (!mounted) return;

      setState(() {

        _readReceiptsEnabled = p['readReceipts'] as bool? ?? true;

        _typingEnabled = p['typingIndicators'] as bool? ?? true;

      });

    } catch (_) {}

  }



  void _onInputChanged() {
    if (!_typingEnabled || _conversationId == null) return;
    final typing = _input.text.trim().isNotEmpty;
    _typingDebounce?.cancel();
    if (typing) {
      _typingDebounce = Timer(const Duration(milliseconds: 350), () {
        if (_input.text.trim().isEmpty || _conversationId == null) return;
        ref.read(chatRepositoryProvider).sendTyping(conversationId: _conversationId!, isTyping: true).catchError((_) {});
      });
      _typingKeepAlive?.cancel();
      _typingKeepAlive = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_input.text.trim().isEmpty) {
          _typingKeepAlive?.cancel();
          return;
        }
        ref.read(chatRepositoryProvider).sendTyping(conversationId: _conversationId!, isTyping: true).catchError((_) {});
      });
    } else {
      _typingKeepAlive?.cancel();
      ref.read(chatRepositoryProvider).sendTyping(conversationId: _conversationId!, isTyping: false).catchError((_) {});
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(max);
      }
    });
  }



  Future<void> _handleRealtimePush(Map<String, dynamic> data) async {

    final type = data['type'] as String? ?? 'message';

    final convId = data['conversationId'] as String?;



    if (type == '__synced') {
      // WebSocket (re)subscribed — reconcile with backend once to fill any gap
      // recovery couldn't cover, and retry any queued outgoing messages.
      // This is event-driven, not periodic polling.
      _flushOutbox();
      _syncMessages();
      return;
    }

    if (type == 'typing') {

      if (convId != _conversationId) return;

      final uid = data['userId'] as String?;

      final myId = ref.read(sessionProvider).userId;

      if (uid == null || uid == myId) return;

      if (!mounted) return;

      setState(() => _peerTyping = data['isTyping'] as bool? ?? false);

      _typingClearTimer?.cancel();

      if (_peerTyping) {

        _typingClearTimer = Timer(const Duration(seconds: 4), () {

          if (mounted) setState(() => _peerTyping = false);

        });

      }

      return;

    }



    if (type == 'delivery') {
      if (convId != _conversationId) return;
      final eid = data['envelopeId'] as String?;
      if (eid != null) {
        ref.read(messageStoreProvider).markStatusByServerId(convId!, eid, delivered: true);
      }
      return;
    }

    if (type == 'receipt') {
      if (convId != _conversationId) return;
      final eid = data['envelopeId'] as String?;
      if (eid != null) {
        ref.read(messageStoreProvider).markStatusByServerId(convId!, eid, delivered: true, read: true);
      }
      return;
    }



    if (type == 'call') {

      final callId = data['callId'] as String?;

      if (callId == null || !mounted) return;

      _showIncomingCall(callId);

      return;

    }



    if (convId != _conversationId) return;



    final myId = ref.read(sessionProvider).userId!;

    final senderId = data['senderUserId'] as String?;

    final senderDeviceId = data['senderDeviceId'] as String?;

    final ciphertext = data['ciphertext'] as String?;

    final envelopeId = data['envelopeId'] as String? ?? data['clientMessageId'] as String?;



    if (senderId == null || ciphertext == null) {

      _syncMessages();

      return;

    }



    if (envelopeId != null && _messages.any((m) => m.id == envelopeId)) return;

    if (senderId == myId) return;

    // WS push received — decrypt and write into the local store; the watch
    // stream renders it. The store is the single source of truth.
    final text = await ref.read(chatRepositoryProvider).decryptEnvelope(

          ciphertext: ciphertext,

          conversationId: convId!,

          senderUserId: senderId,

          senderDeviceId: senderDeviceId ?? '',

          peerUserId: _peerUserId ?? senderId,

        );



    if (!mounted) return;

    await ref.read(messageStoreProvider).upsertServerMessage(
      ChatMessage(
        id: envelopeId ?? 'rt-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: convId,
        senderUserId: senderId,
        text: text,
        createdAt: DateTime.now(),
        isMine: false,
        clientMessageId: data['clientMessageId'] as String?,
      ),
    );

    _maybeSendDeliveryReceipt(envelopeId);
    _maybeSendReadReceipt(envelopeId);
  }

  void _maybeSendDeliveryReceipt(String? envelopeId) {
    if (envelopeId == null || _conversationId == null) return;
    if (_acknowledgedDelivery.contains(envelopeId)) return;
    _acknowledgedDelivery.add(envelopeId);
    ref.read(chatRepositoryProvider).sendDeliveryReceipt(
          conversationId: _conversationId!,
          envelopeId: envelopeId,
        ).catchError((_) => _acknowledgedDelivery.remove(envelopeId));
  }



  Future<void> _showIncomingCall(String callId) async {

    final join = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Incoming call'),

        content: Text('${widget.title} is calling'),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Decline')),

          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Answer')),

        ],

      ),

    );

    if (join != true || !mounted) return;

    try {

      final session = await ref.read(callRepositoryProvider).joinCall(callId);

      if (!mounted) return;

      await Navigator.of(context).push(

        MaterialPageRoute<void>(

          builder: (_) => CallRoomScreen(session: session, title: widget.title),

        ),

      );

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));

      }

    }

  }



  void _maybeSendReadReceipt(String? envelopeId) {

    if (!_readReceiptsEnabled || envelopeId == null || _conversationId == null) return;

    ref.read(chatRepositoryProvider).sendReadReceipt(

          conversationId: _conversationId!,

          envelopeId: envelopeId,

        ).catchError((_) {});

  }



  void _sendReadReceiptsForLoaded() {
    if (_conversationId == null) return;
    ChatMessage? latestPeer;
    for (final m in _messages.reversed) {
      if (!m.isMine && !m.id.startsWith('local-')) {
        latestPeer = m;
        break;
      }
    }
    if (latestPeer == null) return;
    _maybeSendDeliveryReceipt(latestPeer.id);
    if (_readReceiptsEnabled) _maybeSendReadReceipt(latestPeer.id);
  }



  void _startRealtime() {
    final session = ref.read(sessionProvider);
    final userId = session.userId;
    final deviceId = session.deviceId;
    final token = session.accessToken;
    if (userId == null || deviceId == null || token == null) return;

    final realtime = ref.read(chatRealtimeProvider);
    realtime.ensureConnected(userId: userId, deviceId: deviceId, accessToken: token).catchError((_) {
      realtime.scheduleReconnect(userId: userId, deviceId: deviceId, accessToken: token);
    });
    _realtimeSub?.cancel();
    _realtimeSub = realtime.events.listen(_handleRealtimePush);
  }



  @override

  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed && _conversationId != null) {
      // Re-establish the live socket and reconcile once on resume.
      _startRealtime();
      _syncMessages();
      _flushOutbox();

    }

  }



  @override

  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    _typingDebounce?.cancel();
    _typingClearTimer?.cancel();
    _typingKeepAlive?.cancel();
    _realtimeSub?.cancel();
    _messagesSub?.cancel();

    _input.removeListener(_onInputChanged);

    _input.dispose();

    _scrollController.dispose();

    super.dispose();

  }



  String _friendlyError(Object e) {

    final msg = e.toString();

    if (msg.contains('receive timeout') || msg.contains('connection timeout')) {

      return 'Network slow — pull to refresh or tap ↻';

    }

    if (msg.contains('Accept message request')) {

      return 'Accept the message request first (Profile → Message requests)';

    }

    if (msg.contains('message_request_required') || msg.contains('403')) {

      return 'Not connected yet — accept message request first';

    }

    if (msg.contains('Recipient has no registered device')) {

      return 'Other user must open the app once to register encryption keys';

    }

    return msg.replaceFirst('DioException [unknown]: ', '');

  }



  void _subscribeToStore() {
    final convId = _conversationId;
    if (convId == null) return;
    _messagesSub?.cancel();
    _messagesSub = ref.read(messageStoreProvider).watchMessages(convId).listen((msgs) {
      if (!mounted) return;
      final grew = msgs.length > _lastCount;
      _lastCount = msgs.length;
      setState(() {
        _messages = msgs;
        _loading = false;
        if (_error != null && !_error!.contains('yourself')) _error = null;
      });
      if (grew) _scrollToBottom();
      _sendReadReceiptsForLoaded();
    });
  }

  /// Pull the recent window from the server into the local store. The UI
  /// updates through the watch stream; this never blocks rendering.
  Future<void> _syncMessages() {
    final convId = _conversationId;
    if (convId == null) return Future.value();
    if (_error != null && _error!.contains('yourself')) return Future.value();
    if (_inFlight != null) return _inFlight!;

    _inFlight = ref.read(chatRepositoryProvider).syncConversation(convId).then((_) {
      if (mounted) setState(() => _error = null);
    }).catchError((Object e) {
      // Only surface an error when we have nothing cached to show.
      if (mounted && _messages.isEmpty) {
        setState(() {
          _loading = false;
          _error = _friendlyError(e);
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    }).whenComplete(() {
      _inFlight = null;
    });
    return _inFlight!;
  }



  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _conversationId == null) return;
    final myId = ref.read(sessionProvider).userId!;
    final cmid = _uuid.v4();
    final now = DateTime.now();
    final store = ref.read(messageStoreProvider);

    _input.clear();
    if (_typingEnabled) {
      ref.read(chatRepositoryProvider).sendTyping(conversationId: _conversationId!, isTyping: false).catchError((_) {});
    }

    // Write the optimistic message + the outbox entry to local storage *before*
    // the network call. The watch stream renders it instantly, and a crash/kill
    // or dead connection can never lose it — it will be retried.
    await store.insertOptimistic(
      clientMessageId: cmid,
      conversationId: _conversationId!,
      senderUserId: myId,
      text: text,
      createdAt: now,
    );
    await ref.read(chatRepositoryProvider).outbox.add(OutboxEntry(
          clientMessageId: cmid,
          conversationId: _conversationId!,
          plaintext: text,
          isGroup: _isGroup,
          createdAt: now,
          recipientUserId: _isGroup ? null : _peerUserId,
          groupId: _isGroup ? _groupId : null,
        ));

    await _trySend(cmid, text);
  }

  Future<void> _trySend(String cmid, String text) async {
    final repo = ref.read(chatRepositoryProvider);
    final store = ref.read(messageStoreProvider);
    try {
      String envelopeId;
      if (_isGroup && _groupId != null) {
        envelopeId = await repo.sendGroupMessage(groupId: _groupId!, plaintext: text, clientMessageId: cmid);
      } else if (_peerUserId != null) {
        envelopeId = await repo.sendMessage(recipientUserId: _peerUserId!, plaintext: text, clientMessageId: cmid);
      } else {
        return;
      }
      await repo.outbox.remove(cmid);
      await store.confirmSent(cmid, envelopeId);
    } catch (_) {
      // Keep it in the outbox; mark failed so the user sees ⚠ and can tap to
      // retry. It will also auto-retry on the next reconnect/app launch.
      await store.markFailed(cmid, true);
    }
  }

  /// Manual retry from the failed-message UI.
  Future<void> _retry(ChatMessage m) async {
    if (m.clientMessageId == null) return;
    await ref.read(messageStoreProvider).markFailed(m.clientMessageId!, false);
    await _trySend(m.clientMessageId!, m.text);
  }

  /// Retry all queued sends (called on reconnect + app launch). The repository
  /// confirms each one into the local store, so the watch stream updates ticks.
  Future<void> _flushOutbox() async {
    await ref.read(chatRepositoryProvider).flushOutbox();
  }



  Future<void> _startVoiceCall() async {

    if (_peerUserId == null || _conversationId == null) return;

    try {

      final session = await ref.read(callRepositoryProvider).startCall(

            calleeUserId: _peerUserId!,

            conversationId: _conversationId!,

          );

      if (!mounted) return;

      await Navigator.of(context).push(

        MaterialPageRoute<void>(

          builder: (_) => CallRoomScreen(session: session, title: widget.title),

        ),

      );

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));

      }

    }

  }



  Future<void> _blockPeer() async {

    if (_peerUserId == null) return;

    final ok = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Block user?'),

        content: Text('${widget.title} will no longer be able to message you.'),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),

          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Block')),

        ],

      ),

    );

    if (ok != true || !mounted) return;

    await ref.read(safetyRepositoryProvider).blockUser(_peerUserId!);

    if (mounted) Navigator.of(context).pop();

  }



  Future<void> _reportPeer() async {

    if (_peerUserId == null) return;

    final reasonCtrl = TextEditingController();

    final ok = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Report user'),

        content: TextField(

          controller: reasonCtrl,

          decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),

          maxLines: 3,

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),

          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),

        ],

      ),

    );

    if (ok != true || !mounted) return;

    await ref.read(safetyRepositoryProvider).reportUser(

          reportedUserId: _peerUserId!,

          contextType: _isGroup ? 'group' : 'chat',

          contextId: _conversationId,

          reason: reasonCtrl.text.trim().isEmpty ? 'Inappropriate behaviour' : reasonCtrl.text.trim(),

        );

    reasonCtrl.dispose();

    if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));

    }

  }



  @override

  Widget build(BuildContext context) {

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(

      appBar: AppBar(

        title: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),

            // Whether we SEE the peer typing depends only on whether they chose
            // to broadcast it — never on our own typing-privacy toggle.
            if (_peerTyping)

              Text('typing…', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary, fontStyle: FontStyle.italic))

            else if (widget.username != null)

              Text('@${widget.username}', style: Theme.of(context).textTheme.labelSmall)

            else if (_isGroup)

              Text('Group · E2EE', style: Theme.of(context).textTheme.labelSmall),

          ],

        ),

        actions: [

          if (!_isGroup && _peerUserId != null)

            IconButton(onPressed: _startVoiceCall, icon: const Icon(Icons.call_outlined)),

          PopupMenuButton<String>(

            onSelected: (v) {

              if (v == 'block') _blockPeer();

              if (v == 'report') _reportPeer();

            },

            itemBuilder: (_) => [

              if (!_isGroup) const PopupMenuItem(value: 'block', child: Text('Block')),

              const PopupMenuItem(value: 'report', child: Text('Report')),

            ],

          ),

          IconButton(

            onPressed: () {

              setState(() {

                _error = null;

              });

              _syncMessages();

            },

            icon: const Icon(Icons.refresh),

          ),

        ],

      ),

      body: Column(

        children: [

          Expanded(

            child: _loading

                ? const Center(child: CircularProgressIndicator())

                : _error != null

                    ? Center(

                        child: Padding(

                          padding: const EdgeInsets.all(24),

                          child: Column(

                            mainAxisSize: MainAxisSize.min,

                            children: [

                              Text(_error!, textAlign: TextAlign.center),

                              const Gap(12),

                              FilledButton(

                                onPressed: () {

                                  setState(() {

                                    _loading = true;

                                    _error = null;

                                  });

                                  _syncMessages();

                                },

                                child: const Text('Retry'),

                              ),

                            ],

                          ),

                        ),

                      )

                    : _messages.isEmpty

                        ? const Center(child: Text('Say hello — messages are end-to-end encrypted'))

                        : Column(

                        children: [

                          Expanded(

                            child: ListView.builder(

                              controller: _scrollController,

                              padding: const EdgeInsets.all(16),

                              itemCount: _messages.length,

                              itemBuilder: (context, i) {

                                final m = _messages[i];

                                return _Bubble(
                                  message: m,
                                  primary: primary,
                                  showSender: _isGroup && !m.isMine,
                                  onRetry: m.sendFailed ? () => _retry(m) : null,
                                );

                              },

                            ),

                          ),

                          if (_peerTyping)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _TypingIndicator(),
                              ),
                            ),

                        ],

                      ),

          ),

          SafeArea(

            child: Padding(

              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),

              child: Row(

                children: [

                  Expanded(

                    child: TextField(

                      controller: _input,

                      minLines: 1,

                      maxLines: 4,

                      decoration: InputDecoration(

                        hintText: 'Message',

                        filled: true,

                        fillColor: Colors.white,

                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),

                      ),

                      onSubmitted: (_) => _send(),

                    ),

                  ),

                  const Gap(8),

                  IconButton.filled(

                    onPressed: _send,

                    icon: const Icon(Icons.send_rounded),

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}



class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> {
  int _tick = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _tick = (_tick + 1) % 4);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * (_tick == 0 ? 3 : _tick);
    return Text(
      'typing$dots',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF6B7280),
            fontStyle: FontStyle.italic,
          ),
    );
  }
}

class _Bubble extends StatelessWidget {

  const _Bubble({required this.message, required this.primary, this.showSender = false, this.onRetry});



  final ChatMessage message;

  final Color primary;

  final bool showSender;

  final VoidCallback? onRetry;



  @override

  Widget build(BuildContext context) {

    final time = DateFormat.jm().format(message.createdAt.toLocal());
    final (receipt, receiptColor) = _receiptStyle(message);

    final bubble = Container(

        margin: const EdgeInsets.only(bottom: 8),

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),

        decoration: BoxDecoration(

          color: message.isMine ? primary : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: message.isMine ? null : Border.all(color: Theme.of(context).dividerColor),

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.end,

          children: [

            Text(

              message.text,

              style: TextStyle(

                color: message.isMine ? Colors.white : const Color(0xFF111827),

                height: 1.35,

              ),

            ),

            const Gap(4),

            Text(
              '$time$receipt',
              style: TextStyle(
                fontSize: 11,
                color: receiptColor ?? (message.isMine ? Colors.white70 : const Color(0xFF9AA3B2)),
              ),
            ),

            if (message.sendFailed)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Not sent · tap to retry',
                  style: TextStyle(fontSize: 10, color: message.isMine ? const Color(0xFFFFE1E1) : const Color(0xFFEF4444)),
                ),
              ),

          ],

        ),

      );

    return Align(

      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,

      child: message.sendFailed && onRetry != null
          ? GestureDetector(onTap: onRetry, child: bubble)
          : bubble,

    );

  }

  (String, Color?) _receiptStyle(ChatMessage message) {
    if (!message.isMine) return ('', null);
    if (message.sendFailed) return (' ⚠', const Color(0xFFFFD0D0));
    if (message.readByPeer) return (' ✓✓', const Color(0xFF93C5FD));
    if (message.deliveredToPeer) return (' ✓✓', Colors.white70);
    if (message.confirmedOnServer) return (' ✓', Colors.white70);
    return (' …', Colors.white54);
  }
}


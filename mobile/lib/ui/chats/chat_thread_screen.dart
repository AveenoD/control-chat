import 'dart:async';
import 'dart:io';



import 'package:dio/dio.dart';

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart' show ImageSource;

import 'package:open_filex/open_filex.dart';

import 'package:just_audio/just_audio.dart';

import 'package:gap/gap.dart';

import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';



import '../../core/auth/auth_repository.dart';

import '../../core/calls/call_repository.dart';

import '../../core/security/screen_security.dart';

import 'group_avatar.dart';

import 'group_invite.dart';

import '../../core/chat/active_conversation.dart';
import '../../core/chat/chat_models.dart';
import '../../core/chat/typing_service.dart';

import '../../core/chat/chat_repository.dart';

import '../../core/chat/conversation_id.dart';

import '../../core/chat/group_repository.dart';

import '../../core/chat/media_service.dart';

import '../../core/chat/recording_service.dart';

import '../../core/chat/message_wire.dart';

import '../../core/chat/outbox_service.dart';

import '../../core/db/message_store.dart';

import '../../core/auth/session_provider.dart';

import 'group_info_screen.dart';

import 'media_preview_screen.dart';

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

  /// True when the local user has left / been removed from this group → the
  /// thread becomes read-only but stays visible.
  bool _leftGroup = false;

  StreamSubscription<bool>? _leftSub;

  /// Group avatar (encrypted blob id + key), shown in the app bar for groups.
  String? _groupAvatarBlobId;
  String? _groupAvatarKey;

  /// Group members (for @mention suggestions + bubble highlighting).
  List<GroupMember> _groupMembers = const [];
  Set<String> _memberUsernames = const {};
  String? _myUsername;

  /// Live @mention autocomplete state while composing.
  List<GroupMember> _mentionSuggestions = const [];
  int _mentionTokenStart = -1;

  Timer? _typingDebounce;

  Timer? _typingKeepAlive;

  StreamSubscription<Map<String, dynamic>>? _realtimeSub;

  StreamSubscription<List<ChatMessage>>? _messagesSub;

  StreamSubscription<Map<String, List<ReactionView>>>? _reactionsSub;

  /// targetMessageId -> reactions, for rendering reaction chips.
  Map<String, List<ReactionView>> _reactions = {};

  /// The message currently being replied to (composer banner active).
  ChatMessage? _replyingTo;

  /// Briefly highlighted message after tapping a quote (scroll-to-original).
  String? _highlightedId;

  Future<void>? _inFlight;

  int _lastCount = 0;

  final Set<String> _acknowledgedDelivery = {};

  bool _readReceiptsEnabled = true;

  bool _typingEnabled = true;

  /// Disappearing-message timer for this chat (seconds; 0 = off).
  int _disappearingSeconds = 0;

  /// When true the next (text) message is sent as one-time-view.
  bool _viewOnceNext = false;

  /// True when the composer has text — drives the in-field view-once button.
  bool _hasText = false;

  /// Voice-note recording state.
  bool _recording = false;
  Duration _recElapsed = Duration.zero;
  Timer? _recTimer;
  StreamSubscription<double>? _recAmpSub;
  final List<double> _recLiveBars = [];

  /// Per-message upload progress (0..1) keyed by clientMessageId, while a media
  /// blob is being encrypted + uploaded. Transient/in-memory only.
  final Map<String, double> _uploadProgress = {};

  StreamSubscription<int>? _disappearingSub;
  Timer? _expirySweeper;



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
    _myUsername = ref.read(sessionProvider).profile?.username;

    // UI is a projection of the local DB → cached messages render instantly
    // (offline-capable). The network sync below just writes into that DB.
    _subscribeToStore();
    _watchDisappearing();
    _startExpirySweeper();
    _purgeUndecryptableThenSync();
    _flushOutbox();

    if (_isGroup && _groupId != null) {
      _leftSub = ref
          .read(messageStoreProvider)
          .watchGroupLeft(_conversationId!)
          .listen((left) {
        if (mounted && left != _leftGroup) setState(() => _leftGroup = left);
      });
      _initGroup();
    }

    _startRealtime();

    _input.addListener(_onInputChanged);

    final convId = _conversationId;
    if (convId != null) {
      // Riverpod forbids modifying providers inside initState — defer until
      // after the first frame so the widget tree has finished building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(activeConversationIdProvider.notifier).setActive(convId);
        ref.read(messageStoreProvider).clearUnread(convId);
      });
    }

  }

  /// Group bootstrap: handle any pending key rotation (designated admin only)
  /// and back-fill membership system lines so they render on a cold open.
  Future<void> _initGroup() async {
    final gid = _groupId;
    final convId = _conversationId;
    if (gid == null || convId == null) return;
    final store = ref.read(messageStoreProvider);

    // Already known to be left → stay read-only, skip member-only calls (403).
    if (await store.isGroupLeft(convId)) return;

    final groups = ref.read(groupRepositoryProvider);
    try {
      // getMeta 403s if we were silently removed by an admin (we never receive
      // our own removal event) → flip the thread to read-only.
      final meta = await groups.getMeta(gid);
      if (mounted) {
        setState(() {
          _groupAvatarBlobId = meta.avatarBlobId;
          _groupAvatarKey = meta.avatarKey;
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        await store.markGroupLeft(convId);
        await store.upsertServerMessage(ChatMessage(
          // Stable id → re-opens dedupe instead of stacking the notice.
          id: 'sys-removed-$convId',
          conversationId: convId,
          senderUserId: kSystemSenderId,
          text: "You're no longer a member of this group",
          createdAt: DateTime.now(),
          isMine: false,
        ));
        return;
      }
    } catch (_) {}

    // Load members for @mention autocomplete + bubble highlighting.
    try {
      final members = await groups.listMembers(gid);
      if (mounted) {
        setState(() {
          _groupMembers = members;
          _memberUsernames = members
              .map((m) => m.username)
              .whereType<String>()
              .where((u) => u.isNotEmpty)
              .toSet();
        });
      }
    } catch (_) {}

    await groups.rotateIfNeeded(gid).catchError((_) {});
    // Heal key distribution: if I hold the key, (re)seal it to any member device
    // that never received it (new/reinstalled device). Lets peers recover.
    await groups.ensureKeyDistributed(gid).catchError((_) {});
    try {
      final myId = ref.read(sessionProvider).userId;
      final msgs = await groups.fetchSystemMessages(gid, myUserId: myId);
      for (final m in msgs) {
        await store.upsertServerMessage(m);
      }
    } catch (_) {}
  }

  void _openGroupInfo() {
    final gid = _groupId;
    if (gid == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupInfoScreen(groupId: gid, title: widget.title, isLeft: _leftGroup),
      ),
    );
  }

  /// Tapping a link in a bubble: our own group invite links join in-app; any
  /// other URL opens in the browser (falling back to copy if it can't launch).
  Future<void> _handleLinkTap(String url) async {
    if (url.startsWith(kGroupInviteLinkBase)) {
      final token = parseInviteToken(url);
      if (token != null) {
        await _joinViaInviteToken(token);
        return;
      }
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Link copied')));
    }
  }

  Future<void> _joinViaInviteToken(String token) async {
    final repo = ref.read(groupRepositoryProvider);
    GroupInvitePreview preview;
    try {
      preview = await repo.previewInvite(token);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite link is invalid or expired')),
        );
      }
      return;
    }
    if (!mounted) return;

    if (!preview.alreadyMember) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(preview.title),
          content: Text('${preview.memberCount} members · Join this group?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Join')),
          ],
        ),
      );
      if (confirm != true) return;
      try {
        await repo.joinByInvite(token);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not join the group')),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatThreadScreen(
          conversationId: preview.conversationId,
          title: preview.title,
          groupId: preview.groupId,
          isGroup: true,
        ),
      ),
    );
  }

  /// Clear stale "unable to decrypt" rows, then reconcile. With the multi-device
  /// fix, any message still addressed to this device returns decrypted; orphaned
  /// old-model ciphertext just stops showing.
  Future<void> _purgeUndecryptableThenSync() async {
    final convId = _conversationId;
    if (convId != null) {
      await ref.read(messageStoreProvider).deleteUndecryptable(convId);
    }
    await _syncMessages();
  }

  void _watchDisappearing() {
    final convId = _conversationId;
    if (convId == null) return;
    final store = ref.read(messageStoreProvider);
    _disappearingSub?.cancel();
    _disappearingSub = store.watchDisappearing(convId).listen((seconds) {
      if (mounted) setState(() => _disappearingSeconds = seconds);
    });
  }

  /// Periodically purge expired disappearing messages. The watch stream then
  /// re-emits the trimmed list. Event-driven, not network polling.
  void _startExpirySweeper() {
    final store = ref.read(messageStoreProvider);
    store.deleteExpired();
    _expirySweeper?.cancel();
    _expirySweeper = Timer.periodic(const Duration(seconds: 5), (_) {
      store.deleteExpired();
    });
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
    final has = _input.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() {
        _hasText = has;
        // Dropping back to an empty box disarms the per-message view-once toggle.
        if (!has) _viewOnceNext = false;
      });
    }
    _updateMentionSuggestions();
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

  void _clearMentionSuggestions() {
    if (_mentionSuggestions.isEmpty && _mentionTokenStart < 0) return;
    setState(() {
      _mentionSuggestions = const [];
      _mentionTokenStart = -1;
    });
  }

  /// Detects the `@token` being typed at the caret (groups only) and surfaces
  /// matching members. The token must start at a word boundary so mid-word `@`
  /// (e.g. an email) doesn't trigger the picker.
  void _updateMentionSuggestions() {
    if (!_isGroup || _groupMembers.isEmpty) {
      _clearMentionSuggestions();
      return;
    }
    final sel = _input.selection;
    final text = _input.text;
    if (!sel.isValid || sel.start != sel.end) {
      _clearMentionSuggestions();
      return;
    }
    final caret = sel.start;
    var i = caret - 1;
    while (i >= 0 && text[i] != ' ' && text[i] != '\n') {
      i--;
    }
    final tokenStart = i + 1;
    if (tokenStart >= caret || text[tokenStart] != '@') {
      _clearMentionSuggestions();
      return;
    }
    final query = text.substring(tokenStart + 1, caret).toLowerCase();
    // A space inside the token means the mention is already finished.
    if (query.contains(' ')) {
      _clearMentionSuggestions();
      return;
    }
    final myId = ref.read(sessionProvider).userId;
    final matches = _groupMembers.where((m) {
      if (m.userId == myId) return false;
      final uname = m.username;
      if (uname == null || uname.isEmpty) return false;
      if (query.isEmpty) return true;
      return uname.toLowerCase().contains(query) ||
          (m.displayName?.toLowerCase().contains(query) ?? false);
    }).take(6).toList();
    setState(() {
      _mentionSuggestions = matches;
      _mentionTokenStart = matches.isEmpty ? -1 : tokenStart;
    });
  }

  void _applyMention(GroupMember m) {
    final uname = m.username;
    if (uname == null || _mentionTokenStart < 0) {
      _clearMentionSuggestions();
      return;
    }
    final text = _input.text;
    final caret = _input.selection.end;
    final start = _mentionTokenStart;
    if (start > text.length || caret > text.length || start > caret) {
      _clearMentionSuggestions();
      return;
    }
    final replacement = '@$uname ';
    final newText = text.replaceRange(start, caret, replacement);
    _input.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    _clearMentionSuggestions();
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

    // Decode feature metadata carried inside the E2EE plaintext.
    final wire = text.startsWith('🔒') ? WireMessage(text: text) : ChatWire.decode(text);
    if (wire.isTimerControl) {
      await ref.read(messageStoreProvider).setDisappearing(convId, wire.timerSeconds);
      return;
    }
    if (wire.isReaction) {
      final tid = wire.reactionTargetId;
      if (tid != null) {
        final store = ref.read(messageStoreProvider);
        if (wire.reactionAdd && wire.reactionEmoji != null) {
          await store.setReaction(
            conversationId: convId,
            targetId: tid,
            reactorUserId: senderId,
            emoji: wire.reactionEmoji!,
          );
        } else {
          await store.removeReaction(targetId: tid, reactorUserId: senderId);
        }
      }
      return;
    }

    final now = DateTime.now();
    await ref.read(messageStoreProvider).upsertServerMessage(
      ChatMessage(
        id: envelopeId ?? 'rt-${now.millisecondsSinceEpoch}',
        conversationId: convId,
        senderUserId: senderId,
        text: wire.text,
        createdAt: now,
        isMine: false,
        clientMessageId: data['clientMessageId'] as String?,
        viewOnce: wire.viewOnce,
        expiresAt: wire.ttlSeconds > 0 ? now.add(Duration(seconds: wire.ttlSeconds)) : null,
        mediaType: wire.mediaType,
        mediaBlobId: wire.mediaBlobId,
        mediaKey: wire.mediaKey,
        mediaMime: wire.mediaMime,
        mediaWidth: wire.mediaWidth,
        mediaHeight: wire.mediaHeight,
        mediaFilename: wire.mediaFilename,
        mediaSize: wire.mediaSize,
        mediaDurationMs: wire.mediaDurationMs,
        mediaWaveform: wire.mediaWaveform,
        replyToId: wire.replyToId,
        replySender: wire.replySender,
        replyPreview: wire.replyPreview,
        replyMediaType: wire.replyMediaType,
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
      ref.read(messageStoreProvider).deleteExpired();

    }

  }



  @override

  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    _typingDebounce?.cancel();
    _typingKeepAlive?.cancel();
    _realtimeSub?.cancel();
    _messagesSub?.cancel();
    _reactionsSub?.cancel();
    _leftSub?.cancel();
    _disappearingSub?.cancel();
    _expirySweeper?.cancel();

    _input.removeListener(_onInputChanged);

    _input.dispose();

    _recTimer?.cancel();

    _recAmpSub?.cancel();

    _scrollController.dispose();

    // Defer until after dispose completes — Riverpod disallows sync writes in dispose.
    final active = ref.read(activeConversationIdProvider.notifier);
    Future.microtask(() => active.setActive(null));

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

    final myId = ref.read(sessionProvider).userId;
    if (myId != null) {
      _reactionsSub?.cancel();
      _reactionsSub =
          ref.read(messageStoreProvider).watchReactions(convId, myId).listen((map) {
        if (mounted) setState(() => _reactions = map);
      });
    }
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

    final viewOnce = _viewOnceNext;
    final ttl = _disappearingSeconds;
    final expiresAt = ttl > 0 ? now.add(Duration(seconds: ttl)) : null;

    final reply = _replyingTo;
    final replyId = reply?.id;
    final replySender = reply == null ? null : _replySenderLabel(reply);
    final replyPreview = reply == null ? null : _previewFor(reply);
    final replyMediaType = reply?.mediaType;

    _input.clear();
    if (_viewOnceNext) setState(() => _viewOnceNext = false);
    _clearReply();
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
      viewOnce: viewOnce,
      expiresAt: expiresAt,
      replyToId: replyId,
      replySender: replySender,
      replyPreview: replyPreview,
      replyMediaType: replyMediaType,
    );
    await ref.read(chatRepositoryProvider).outbox.add(OutboxEntry(
          clientMessageId: cmid,
          conversationId: _conversationId!,
          plaintext: text,
          isGroup: _isGroup,
          createdAt: now,
          recipientUserId: _isGroup ? null : _peerUserId,
          groupId: _isGroup ? _groupId : null,
          viewOnce: viewOnce,
          ttlSeconds: ttl,
          replyToId: replyId,
          replySender: replySender,
          replyPreview: replyPreview,
          replyMediaType: replyMediaType,
        ));

    await _trySend(cmid, text,
        viewOnce: viewOnce,
        ttlSeconds: ttl,
        reply: replyId == null
            ? null
            : WireReply(
                id: replyId, sender: replySender, preview: replyPreview, mediaType: replyMediaType));
  }

  Future<void> _trySend(String cmid, String text,
      {bool viewOnce = false, int ttlSeconds = 0, WireReply? reply}) async {
    final repo = ref.read(chatRepositoryProvider);
    final store = ref.read(messageStoreProvider);
    try {
      String envelopeId;
      if (_isGroup && _groupId != null) {
        envelopeId = await repo.sendGroupMessage(
            groupId: _groupId!, plaintext: text, clientMessageId: cmid, viewOnce: viewOnce, ttlSeconds: ttlSeconds, reply: reply);
      } else if (_peerUserId != null) {
        envelopeId = await repo.sendMessage(
            recipientUserId: _peerUserId!, plaintext: text, clientMessageId: cmid, viewOnce: viewOnce, ttlSeconds: ttlSeconds, reply: reply);
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

  /// Builds a WireReply from a persisted message's reply fields (for retries).
  WireReply? _replyFromMessage(ChatMessage m) => m.replyToId == null
      ? null
      : WireReply(
          id: m.replyToId!,
          sender: m.replySender,
          preview: m.replyPreview,
          mediaType: m.replyMediaType,
        );

  /// Short preview text for a quoted message (used in the reply banner/bubble).
  String _previewFor(ChatMessage m) {
    if (m.isImage) return '📷 Photo';
    if (m.isVoice) return '🎤 Voice note';
    if (m.isFile) return '📄 ${m.mediaFilename ?? 'File'}';
    if (m.viewOnce) return 'View once';
    return m.text;
  }

  String _replySenderLabel(ChatMessage m) {
    if (m.isMine) return 'You';
    return m.senderLabel ?? widget.title;
  }

  void _startReply(ChatMessage m) {
    setState(() => _replyingTo = m);
  }

  void _clearReply() {
    if (_replyingTo != null) setState(() => _replyingTo = null);
  }

  static const List<String> _quickEmojis = ['❤️', '😂', '👍', '😮', '😢', '🙏'];

  static const List<String> _emojiPickerSet = [
    '❤️', '😂', '👍', '👎', '😮', '😢', '🙏', '🔥',
    '😍', '😅', '😊', '😉', '😎', '🤔', '😴', '😭',
    '😡', '🥳', '🤯', '😱', '🤗', '🙄', '😬', '😇',
    '👏', '🙌', '💪', '✌️', '🤞', '👌', '🤝', '🫶',
    '💯', '✨', '🎉', '🎈', '💔', '💖', '⭐', '🌟',
    '😘', '😋', '🤤', '🤐', '🤫', '😜', '🤪', '😏',
    '🥺', '😤', '😩', '😢', '🤧', '🤒', '👀', '💀',
  ];

  Future<void> _toggleReaction(ChatMessage m, String emoji) async {
    if (!m.confirmedOnServer || _conversationId == null) return;
    final myId = ref.read(sessionProvider).userId!;
    final store = ref.read(messageStoreProvider);
    final repo = ref.read(chatRepositoryProvider);

    ReactionView? mine;
    for (final r in _reactions[m.id] ?? const <ReactionView>[]) {
      if (r.isMine) {
        mine = r;
        break;
      }
    }
    final removing = mine != null && mine.emoji == emoji;

    if (removing) {
      await store.removeReaction(targetId: m.id, reactorUserId: myId);
    } else {
      await store.setReaction(
          conversationId: _conversationId!, targetId: m.id, reactorUserId: myId, emoji: emoji);
    }

    try {
      if (_isGroup && _groupId != null) {
        await repo.sendGroupReaction(groupId: _groupId!, targetId: m.id, emoji: emoji, add: !removing);
      } else if (_peerUserId != null) {
        await repo.sendDmReaction(recipientUserId: _peerUserId!, targetId: m.id, emoji: emoji, add: !removing);
      }
    } catch (_) {
      // Local reaction already applied; the control will re-send on reconnect
      // is out of scope, but the UX stays responsive.
    }
  }

  Future<void> _showMessageMenu(ChatMessage m) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (m.confirmedOnServer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final e in _quickEmojis)
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.pop(ctx);
                          _toggleReaction(m, e);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(e, style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showEmojiPicker(m);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.add_circle_outline, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(ctx);
                _startReply(m);
              },
            ),
            if (!m.isMedia && m.text.isNotEmpty && !m.viewOnce)
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: m.text));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Copied')));
                },
              ),
            if (_isGroup && m.isMine && m.confirmedOnServer)
              ListTile(
                leading: const Icon(Icons.done_all),
                title: const Text('Message info'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMessageInfo(m);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Group "Seen by N": who has read this (own) message. Fetched on demand;
  /// only the sender can see it, and readers who disabled read receipts won't
  /// appear (the backend has no cursor for them).
  Future<void> _showMessageInfo(ChatMessage m) async {
    final gid = _groupId;
    if (gid == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (ctx, scrollController) => FutureBuilder<List<SeenReader>>(
          future: ref.read(groupRepositoryProvider).messageSeenBy(gid, m.id),
          builder: (ctx, snap) {
            final readers = snap.data ?? const <SeenReader>[];
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    const Icon(Icons.done_all, size: 20),
                    const Gap(8),
                    Text(
                      snap.connectionState == ConnectionState.waiting
                          ? 'Read by…'
                          : 'Read by ${readers.length}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const Gap(12),
                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (readers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No one has read this yet.',
                      style: Theme.of(ctx).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...readers.map(
                    (r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(r.label.isNotEmpty
                            ? r.label.replaceFirst('@', '')[0].toUpperCase()
                            : '?'),
                      ),
                      title: Text(r.label),
                      subtitle: r.username != null ? Text('@${r.username}') : null,
                      trailing: r.readAt != null
                          ? Text(
                              DateFormat.jm().format(r.readAt!.toLocal()),
                              style: Theme.of(ctx).textTheme.bodySmall,
                            )
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showEmojiPicker(ChatMessage m) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: 320,
          child: GridView.count(
            crossAxisCount: 8,
            padding: const EdgeInsets.all(12),
            children: [
              for (final e in _emojiPickerSet)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleReaction(m, e);
                  },
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Scrolls to and briefly highlights the quoted original message.
  void _scrollToMessage(String? targetId) {
    if (targetId == null) return;
    final idx = _messages.indexWhere((m) => m.id == targetId);
    if (idx < 0) return;
    setState(() => _highlightedId = targetId);
    // Approximate scroll: jump near the index by fraction of the list.
    final pos = _scrollController.position;
    final target = (idx / _messages.length) * pos.maxScrollExtent;
    _scrollController.animateTo(
      target.clamp(0.0, pos.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _highlightedId = null);
    });
  }

  /// Snapshots the active reply (for media sends), then clears the composer.
  ({String? id, String? sender, String? preview, String? mtype, WireReply? wire}) _consumeReply() {
    final r = _replyingTo;
    if (r == null) return (id: null, sender: null, preview: null, mtype: null, wire: null);
    final sender = _replySenderLabel(r);
    final preview = _previewFor(r);
    _clearReply();
    return (
      id: r.id,
      sender: sender,
      preview: preview,
      mtype: r.mediaType,
      wire: WireReply(id: r.id, sender: sender, preview: preview, mediaType: r.mediaType),
    );
  }

  /// Manual retry from the failed-message UI.
  Future<void> _retry(ChatMessage m) async {
    if (m.clientMessageId == null) return;
    await ref.read(messageStoreProvider).markFailed(m.clientMessageId!, false);
    final ttl = m.expiresAt != null ? m.expiresAt!.difference(m.createdAt).inSeconds : 0;
    if (m.isImage) {
      final path = m.mediaLocalPath;
      if (path == null || !File(path).existsSync()) {
        await ref.read(messageStoreProvider).markFailed(m.clientMessageId!, true);
        return;
      }
      final bytes = await File(path).readAsBytes();
      final picked = PickedImage(
        bytes: bytes,
        mime: m.mediaMime ?? 'image/jpeg',
        width: m.mediaWidth ?? 0,
        height: m.mediaHeight ?? 0,
      );
      await _trySendImage(m.clientMessageId!, picked,
          caption: m.text, viewOnce: m.viewOnce, ttlSeconds: ttl > 0 ? ttl : 0, reply: _replyFromMessage(m));
      return;
    }
    if (m.isFile) {
      final path = m.mediaLocalPath;
      if (path == null || !File(path).existsSync()) {
        await ref.read(messageStoreProvider).markFailed(m.clientMessageId!, true);
        return;
      }
      final bytes = await File(path).readAsBytes();
      final picked = PickedFile(
        bytes: bytes,
        filename: m.mediaFilename ?? 'file',
        mime: m.mediaMime ?? 'application/octet-stream',
        size: bytes.length,
      );
      await _trySendFile(m.clientMessageId!, picked,
          caption: m.text, viewOnce: m.viewOnce, ttlSeconds: ttl > 0 ? ttl : 0, reply: _replyFromMessage(m));
      return;
    }
    if (m.isVoice) {
      final path = m.mediaLocalPath;
      if (path == null || !File(path).existsSync()) {
        await ref.read(messageStoreProvider).markFailed(m.clientMessageId!, true);
        return;
      }
      final bytes = await File(path).readAsBytes();
      final voice = RecordedVoice(
        bytes: bytes,
        durationMs: m.mediaDurationMs ?? 0,
        waveform: m.mediaWaveform ?? const [],
        mime: m.mediaMime ?? 'audio/mp4',
      );
      await _trySendVoice(m.clientMessageId!, voice, ttlSeconds: ttl > 0 ? ttl : 0, reply: _replyFromMessage(m));
      return;
    }
    await _trySend(m.clientMessageId!, m.text,
        viewOnce: m.viewOnce, ttlSeconds: ttl > 0 ? ttl : 0, reply: _replyFromMessage(m));
  }

  /// Reveal a one-time-view image once, then consume it (wipe + delete blob).
  Future<void> _openViewOnceImage(ChatMessage m) async {
    final blobId = m.mediaBlobId;
    final key = m.mediaKey;
    if (blobId == null || key == null) return;
    final media = ref.read(mediaServiceProvider);
    final path = m.mediaLocalPath ??
        await media.ensureLocalFile(blobId: blobId, keyBase64: key, mime: m.mediaMime ?? 'image/jpeg');
    if (path == null || !mounted) return;
    await _showFullscreen(path);
    await ref.read(messageStoreProvider).markViewed(m);
    if (m.confirmedOnServer) ref.read(chatRepositoryProvider).consumeViewOnce(m.id);
    await media.deleteLocal(blobId);
  }

  Future<void> _showFullscreen(String path) async {
    final security = ref.read(screenSecurityProvider);
    await security.pushSecure();
    if (!mounted) {
      await security.restoreSaved();
      return;
    }
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _FullscreenImage(path: path),
          fullscreenDialog: true,
        ),
      );
    } finally {
      await security.restoreSaved();
    }
  }

  /// Reveal a one-time-view file once (open it), then consume it.
  Future<void> _openViewOnceFile(ChatMessage m) async {
    final blobId = m.mediaBlobId;
    final key = m.mediaKey;
    if (blobId == null || key == null) return;
    final media = ref.read(mediaServiceProvider);
    final path = m.mediaLocalPath ??
        await media.ensureLocalFile(
          blobId: blobId,
          keyBase64: key,
          mime: m.mediaMime ?? 'application/octet-stream',
          filename: m.mediaFilename,
        );
    if (path == null || !mounted) return;
    await OpenFilex.open(path, type: m.mediaMime);
    await ref.read(messageStoreProvider).markViewed(m);
    if (m.confirmedOnServer) ref.read(chatRepositoryProvider).consumeViewOnce(m.id);
    await media.deleteLocal(blobId);
  }

  /// Reveal a one-time-view voice note once (play to completion), then consume.
  Future<void> _openViewOnceVoice(ChatMessage m) async {
    final blobId = m.mediaBlobId;
    final key = m.mediaKey;
    if (blobId == null || key == null) return;
    final media = ref.read(mediaServiceProvider);
    final path = m.mediaLocalPath ??
        await media.ensureLocalFile(
          blobId: blobId,
          keyBase64: key,
          mime: m.mediaMime ?? 'audio/mp4',
          filename: 'voice.m4a',
        );
    if (path == null || !mounted) return;
    final player = AudioPlayer();
    try {
      await player.setFilePath(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playing voice note once…')),
        );
      }
      await player.play(); // completes when playback finishes
    } catch (_) {
    } finally {
      await player.dispose();
    }
    await ref.read(messageStoreProvider).markViewed(m);
    if (m.confirmedOnServer) ref.read(chatRepositoryProvider).consumeViewOnce(m.id);
    await media.deleteLocal(blobId);
  }

  /// Attach menu: photo (gallery/camera) or any document/file.
  Future<void> _showAttachSheet() async {
    if (_conversationId == null) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo library'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('Document'),
              onTap: () => Navigator.pop(ctx, 'file'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice == 'file') {
      await _pickAndSendFile();
    } else {
      await _pickAndSendImage(choice == 'camera' ? ImageSource.camera : ImageSource.gallery);
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    PickedImage? picked;
    try {
      picked = await ref.read(mediaServiceProvider).pickImage(source: source);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
      }
      return;
    }
    if (picked == null || !mounted) return;
    final result = await Navigator.of(context).push<MediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => MediaPreviewScreen.image(bytes: picked!.bytes, mime: picked.mime),
        fullscreenDialog: true,
      ),
    );
    if (result == null || !mounted) return;
    await _sendImage(picked, caption: result.caption, viewOnce: result.viewOnce);
  }

  Future<void> _pickAndSendFile() async {
    PickedFile? picked;
    try {
      picked = await ref.read(mediaServiceProvider).pickFile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
      }
      return;
    }
    if (picked == null || !mounted) return;
    const maxBytes = 50 * 1024 * 1024;
    if (picked.size > maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File too large (max 50 MB)')),
        );
      }
      return;
    }
    final result = await Navigator.of(context).push<MediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => MediaPreviewScreen.file(
          name: picked!.filename,
          size: picked.size,
          mime: picked.mime,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result == null || !mounted) return;
    await _sendFile(picked, caption: result.caption, viewOnce: result.viewOnce);
  }

  Future<void> _sendFile(PickedFile picked,
      {String caption = '', bool viewOnce = false}) async {
    final myId = ref.read(sessionProvider).userId!;
    final cmid = _uuid.v4();
    final now = DateTime.now();
    final store = ref.read(messageStoreProvider);
    final media = ref.read(mediaServiceProvider);

    final ttl = _disappearingSeconds;
    final expiresAt = ttl > 0 ? now.add(Duration(seconds: ttl)) : null;
    final rep = _consumeReply();

    String? localPath;
    try {
      localPath = await media.cacheLocalCopy(
        blobId: cmid,
        bytes: picked.bytes,
        mime: picked.mime,
        filename: picked.filename,
      );
    } catch (_) {}

    await store.insertOptimistic(
      clientMessageId: cmid,
      conversationId: _conversationId!,
      senderUserId: myId,
      text: caption,
      createdAt: now,
      viewOnce: viewOnce,
      expiresAt: expiresAt,
      mediaType: 'file',
      mediaMime: picked.mime,
      mediaLocalPath: localPath,
      mediaFilename: picked.filename,
      mediaSize: picked.size,
      replyToId: rep.id,
      replySender: rep.sender,
      replyPreview: rep.preview,
      replyMediaType: rep.mtype,
    );

    await _trySendFile(cmid, picked,
        caption: caption, viewOnce: viewOnce, ttlSeconds: ttl, reply: rep.wire);
  }

  Future<void> _trySendFile(String cmid, PickedFile picked,
      {String caption = '', bool viewOnce = false, int ttlSeconds = 0, WireReply? reply}) async {
    final repo = ref.read(chatRepositoryProvider);
    final store = ref.read(messageStoreProvider);
    final media = ref.read(mediaServiceProvider);
    _setProgress(cmid, 0);
    try {
      final uploaded = await media.encryptAndUpload(
        bytes: picked.bytes,
        conversationId: _conversationId!,
        mime: picked.mime,
        onProgress: (sent, total) => _setProgress(cmid, total > 0 ? sent / total : null),
      );
      await store.setMediaBlob(cmid, uploaded.blobId, uploaded.keyBase64);

      String envelopeId;
      if (_isGroup && _groupId != null) {
        envelopeId = await repo.sendGroupFile(
          groupId: _groupId!,
          blobId: uploaded.blobId,
          blobKey: uploaded.keyBase64,
          filename: picked.filename,
          mime: picked.mime,
          size: uploaded.size,
          caption: caption,
          clientMessageId: cmid,
          viewOnce: viewOnce,
          ttlSeconds: ttlSeconds,
          reply: reply,
        );
      } else if (_peerUserId != null) {
        envelopeId = await repo.sendDmFile(
          recipientUserId: _peerUserId!,
          blobId: uploaded.blobId,
          blobKey: uploaded.keyBase64,
          filename: picked.filename,
          mime: picked.mime,
          size: uploaded.size,
          caption: caption,
          clientMessageId: cmid,
          viewOnce: viewOnce,
          ttlSeconds: ttlSeconds,
          reply: reply,
        );
      } else {
        return;
      }
      await store.confirmSent(cmid, envelopeId);
    } catch (_) {
      await store.markFailed(cmid, true);
    } finally {
      _clearProgress(cmid);
    }
  }

  Future<void> _sendImage(PickedImage picked,
      {String caption = '', bool viewOnce = false}) async {
    final myId = ref.read(sessionProvider).userId!;
    final cmid = _uuid.v4();
    final now = DateTime.now();
    final store = ref.read(messageStoreProvider);
    final media = ref.read(mediaServiceProvider);

    final ttl = _disappearingSeconds;
    final expiresAt = ttl > 0 ? now.add(Duration(seconds: ttl)) : null;
    final rep = _consumeReply();

    // Show the image instantly on the sender side by caching a local copy keyed
    // by the client message id (before we know the server blob id).
    String? localPath;
    try {
      localPath = await media.cacheLocalCopy(blobId: cmid, bytes: picked.bytes, mime: picked.mime);
    } catch (_) {}

    await store.insertOptimistic(
      clientMessageId: cmid,
      conversationId: _conversationId!,
      senderUserId: myId,
      text: caption,
      createdAt: now,
      viewOnce: viewOnce,
      expiresAt: expiresAt,
      mediaType: 'image',
      mediaMime: picked.mime,
      mediaWidth: picked.width,
      mediaHeight: picked.height,
      mediaLocalPath: localPath,
      replyToId: rep.id,
      replySender: rep.sender,
      replyPreview: rep.preview,
      replyMediaType: rep.mtype,
    );

    await _trySendImage(cmid, picked,
        caption: caption, viewOnce: viewOnce, ttlSeconds: ttl, reply: rep.wire);
  }

  Future<void> _trySendImage(String cmid, PickedImage picked,
      {String caption = '', bool viewOnce = false, int ttlSeconds = 0, WireReply? reply}) async {
    final repo = ref.read(chatRepositoryProvider);
    final store = ref.read(messageStoreProvider);
    final media = ref.read(mediaServiceProvider);
    _setProgress(cmid, 0);
    try {
      final uploaded = await media.encryptAndUpload(
        bytes: picked.bytes,
        conversationId: _conversationId!,
        mime: picked.mime,
        onProgress: (sent, total) => _setProgress(cmid, total > 0 ? sent / total : null),
      );
      await store.setMediaBlob(cmid, uploaded.blobId, uploaded.keyBase64);

      String envelopeId;
      if (_isGroup && _groupId != null) {
        envelopeId = await repo.sendGroupImage(
          groupId: _groupId!,
          blobId: uploaded.blobId,
          blobKey: uploaded.keyBase64,
          mime: picked.mime,
          width: picked.width,
          height: picked.height,
          size: uploaded.size,
          caption: caption,
          clientMessageId: cmid,
          viewOnce: viewOnce,
          ttlSeconds: ttlSeconds,
          reply: reply,
        );
      } else if (_peerUserId != null) {
        envelopeId = await repo.sendDmImage(
          recipientUserId: _peerUserId!,
          blobId: uploaded.blobId,
          blobKey: uploaded.keyBase64,
          mime: picked.mime,
          width: picked.width,
          height: picked.height,
          size: uploaded.size,
          caption: caption,
          clientMessageId: cmid,
          viewOnce: viewOnce,
          ttlSeconds: ttlSeconds,
          reply: reply,
        );
      } else {
        return;
      }
      await store.confirmSent(cmid, envelopeId);
    } catch (_) {
      await store.markFailed(cmid, true);
    } finally {
      _clearProgress(cmid);
    }
  }

  void _setProgress(String cmid, double? value) {
    if (!mounted) return;
    setState(() => _uploadProgress[cmid] = (value ?? 0).clamp(0.0, 1.0));
  }

  void _clearProgress(String cmid) {
    if (!mounted) {
      _uploadProgress.remove(cmid);
      return;
    }
    setState(() => _uploadProgress.remove(cmid));
  }

  // ---- Voice notes ----

  Future<void> _startRecording() async {
    if (_conversationId == null || _recording) return;
    final rec = ref.read(recordingServiceProvider);
    if (!await rec.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission needed for voice notes')),
        );
      }
      return;
    }
    final ok = await rec.start();
    if (!ok || !mounted) return;
    _recLiveBars.clear();
    _recAmpSub = rec.amplitude.listen((a) {
      if (!mounted) return;
      setState(() {
        _recLiveBars.add(a);
        if (_recLiveBars.length > 48) _recLiveBars.removeAt(0);
      });
    });
    setState(() {
      _recording = true;
      _recElapsed = Duration.zero;
    });
    _recTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() => _recElapsed += const Duration(milliseconds: 200));
    });
  }

  Future<void> _cancelRecording() async {
    _recTimer?.cancel();
    await _recAmpSub?.cancel();
    _recAmpSub = null;
    await ref.read(recordingServiceProvider).cancel();
    if (mounted) {
      setState(() {
        _recording = false;
        _recLiveBars.clear();
      });
    }
  }

  Future<void> _stopAndSendRecording() async {
    _recTimer?.cancel();
    await _recAmpSub?.cancel();
    _recAmpSub = null;
    final rec = ref.read(recordingServiceProvider);
    final result = await rec.stop();
    if (mounted) {
      setState(() {
        _recording = false;
        _recLiveBars.clear();
      });
    }
    // Ignore accidental sub-second taps.
    if (result == null || result.durationMs < 700) return;
    await _sendVoice(result);
  }

  Future<void> _sendVoice(RecordedVoice voice) async {
    final myId = ref.read(sessionProvider).userId!;
    final cmid = _uuid.v4();
    final now = DateTime.now();
    final store = ref.read(messageStoreProvider);
    final media = ref.read(mediaServiceProvider);

    final ttl = _disappearingSeconds;
    final expiresAt = ttl > 0 ? now.add(Duration(seconds: ttl)) : null;
    final rep = _consumeReply();

    String? localPath;
    try {
      localPath = await media.cacheLocalCopy(
        blobId: cmid,
        bytes: voice.bytes,
        mime: voice.mime,
        filename: 'voice.m4a',
      );
    } catch (_) {}

    await store.insertOptimistic(
      clientMessageId: cmid,
      conversationId: _conversationId!,
      senderUserId: myId,
      text: '',
      createdAt: now,
      expiresAt: expiresAt,
      mediaType: 'voice',
      mediaMime: voice.mime,
      mediaLocalPath: localPath,
      mediaSize: voice.bytes.length,
      mediaDurationMs: voice.durationMs,
      mediaWaveform: voice.waveform,
      replyToId: rep.id,
      replySender: rep.sender,
      replyPreview: rep.preview,
      replyMediaType: rep.mtype,
    );

    await _trySendVoice(cmid, voice, ttlSeconds: ttl, reply: rep.wire);
  }

  Future<void> _trySendVoice(String cmid, RecordedVoice voice,
      {int ttlSeconds = 0, WireReply? reply}) async {
    final repo = ref.read(chatRepositoryProvider);
    final store = ref.read(messageStoreProvider);
    final media = ref.read(mediaServiceProvider);
    _setProgress(cmid, 0);
    try {
      final uploaded = await media.encryptAndUpload(
        bytes: voice.bytes,
        conversationId: _conversationId!,
        mime: voice.mime,
        onProgress: (sent, total) => _setProgress(cmid, total > 0 ? sent / total : null),
      );
      await store.setMediaBlob(cmid, uploaded.blobId, uploaded.keyBase64);

      String envelopeId;
      if (_isGroup && _groupId != null) {
        envelopeId = await repo.sendGroupVoice(
          groupId: _groupId!,
          blobId: uploaded.blobId,
          blobKey: uploaded.keyBase64,
          mime: voice.mime,
          durationMs: voice.durationMs,
          waveform: voice.waveform,
          size: uploaded.size,
          clientMessageId: cmid,
          ttlSeconds: ttlSeconds,
          reply: reply,
        );
      } else if (_peerUserId != null) {
        envelopeId = await repo.sendDmVoice(
          recipientUserId: _peerUserId!,
          blobId: uploaded.blobId,
          blobKey: uploaded.keyBase64,
          mime: voice.mime,
          durationMs: voice.durationMs,
          waveform: voice.waveform,
          size: uploaded.size,
          clientMessageId: cmid,
          ttlSeconds: ttlSeconds,
          reply: reply,
        );
      } else {
        return;
      }
      await store.confirmSent(cmid, envelopeId);
    } catch (_) {
      await store.markFailed(cmid, true);
    } finally {
      _clearProgress(cmid);
    }
  }

  String _fmtClock(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _mentionPicker(Color primary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      constraints: const BoxConstraints(maxHeight: 216),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _mentionSuggestions.length,
        itemBuilder: (context, i) {
          final m = _mentionSuggestions[i];
          final name = (m.displayName?.isNotEmpty ?? false)
              ? m.displayName!
              : (m.username ?? 'User');
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: primary, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: m.username != null
                ? Text('@${m.username}',
                    maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            onTap: () => _applyMention(m),
          );
        },
      ),
    );
  }

  Widget _recordingBar(Color primary) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Cancel',
          onPressed: _cancelRecording,
          icon: const Icon(Icons.delete_outline, color: Color(0xFFE11D48)),
        ),
        const _RecDot(),
        const Gap(8),
        Text(_fmtClock(_recElapsed),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const Gap(10),
        Expanded(
          child: SizedBox(
            height: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final b in _recLiveBars)
                  Container(
                    width: 3,
                    height: (4 + b * 24).clamp(4.0, 28.0),
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Gap(8),
        IconButton.filled(
          tooltip: 'Send',
          onPressed: _stopAndSendRecording,
          icon: const Icon(Icons.send_rounded),
        ),
      ],
    );
  }

  /// Open a one-time-view message: reveal its text once, then consume it.
  Future<void> _openViewOnce(ChatMessage m) async {
    if (m.viewed) return;
    if (m.isImage) {
      await _openViewOnceImage(m);
      return;
    }
    if (m.isFile) {
      await _openViewOnceFile(m);
      return;
    }
    if (m.isVoice) {
      await _openViewOnceVoice(m);
      return;
    }
    final body = m.text;
    final security = ref.read(screenSecurityProvider);
    await security.pushSecure();
    if (!mounted) {
      await security.restoreSaved();
      return;
    }
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [Icon(Icons.visibility_off_outlined, size: 18), Gap(8), Text('View once')],
          ),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } finally {
      await security.restoreSaved();
    }
    await ref.read(messageStoreProvider).markViewed(m);
    if (m.confirmedOnServer) ref.read(chatRepositoryProvider).consumeViewOnce(m.id);
  }

  Future<void> _pickDisappearingTimer() async {
    const options = <(String, int)>[
      ('Off', 0),
      ('30 seconds', 30),
      ('1 hour', 3600),
      ('1 day', 86400),
      ('7 days', 604800),
    ];
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Disappearing messages', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            for (final o in options)
              ListTile(
                title: Text(o.$1),
                trailing: _disappearingSeconds == o.$2
                    ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, o.$2),
              ),
          ],
        ),
      ),
    );
    if (selected == null || _conversationId == null) return;
    final store = ref.read(messageStoreProvider);
    await store.setDisappearing(_conversationId!, selected);
    try {
      await ref.read(chatRepositoryProvider).sendDisappearingTimer(
            isGroup: _isGroup,
            recipientUserId: _isGroup ? null : _peerUserId,
            groupId: _isGroup ? _groupId : null,
            seconds: selected,
          );
    } catch (_) {
      // Local timer still applies; peer will sync the change on next send/open.
    }
  }

  String _humanTimer(int seconds) {
    if (seconds <= 0) return 'off';
    if (seconds < 60) return '$seconds seconds';
    if (seconds < 3600) return '${seconds ~/ 60} minutes';
    if (seconds < 86400) return '${seconds ~/ 3600} hour${seconds ~/ 3600 == 1 ? '' : 's'}';
    return '${seconds ~/ 86400} day${seconds ~/ 86400 == 1 ? '' : 's'}';
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
    final peerTyping = ref.watch(peerTypingProvider)[widget.conversationId] ?? false;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(activeConversationIdProvider.notifier).setActive(null);
        }
      },
      child: Scaffold(

      appBar: AppBar(

        title: InkWell(

          onTap: (_isGroup && _groupId != null) ? _openGroupInfo : null,

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isGroup) ...[
                GroupAvatar(
                  title: widget.title,
                  blobId: _groupAvatarBlobId,
                  avatarKey: _groupAvatarKey,
                  radius: 18,
                ),
                const Gap(10),
              ],
              Flexible(
                child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [

            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),

            // Whether we SEE the peer typing depends only on whether they chose
            // to broadcast it — never on our own typing-privacy toggle.
            if (peerTyping)

              Text('typing…', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary, fontStyle: FontStyle.italic))

            else if (widget.username != null)

              Text('@${widget.username}', style: Theme.of(context).textTheme.labelSmall)

            else if (_isGroup)

              Text('tap for info', style: Theme.of(context).textTheme.labelSmall),

          ],

                ),
              ),
            ],
          ),

        ),

        actions: [

          if (!_isGroup && _peerUserId != null)

            IconButton(onPressed: _startVoiceCall, icon: const Icon(Icons.call_outlined)),

          IconButton(
            tooltip: 'Disappearing messages',
            onPressed: _pickDisappearingTimer,
            icon: Icon(
              _disappearingSeconds > 0 ? Icons.timer : Icons.timer_outlined,
              color: _disappearingSeconds > 0 ? primary : null,
            ),
          ),

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

                                if (m.senderUserId == kSystemSenderId) {
                                  return _SystemNotice(text: m.text);
                                }

                                final cmid = m.clientMessageId;
                                final progress = cmid != null ? _uploadProgress[cmid] : null;
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onLongPress: _leftGroup ? null : () => _showMessageMenu(m),
                                  onHorizontalDragEnd: _leftGroup
                                      ? null
                                      : (d) {
                                          if ((d.primaryVelocity ?? 0) > 220) _startReply(m);
                                        },
                                  child: _Bubble(
                                    message: m,
                                    primary: primary,
                                    showSender: _isGroup && !m.isMine,
                                    mentionUsernames: _memberUsernames,
                                    myUsername: _myUsername,
                                    onOpenLink: _handleLinkTap,
                                    uploadProgress: progress,
                                    highlighted: _highlightedId != null && m.id == _highlightedId,
                                    reactions: _reactions[m.id] ?? const [],
                                    onReact: _leftGroup ? null : (e) => _toggleReaction(m, e),
                                    onQuoteTap: m.isReply ? () => _scrollToMessage(m.replyToId) : null,
                                    onRetry: m.sendFailed ? () => _retry(m) : null,
                                    onViewOnce: (m.viewOnce && !m.isMine && !m.viewed)
                                        ? () => _openViewOnce(m)
                                        : null,
                                  ),
                                );

                              },

                            ),

                          ),

                          if (peerTyping)
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

          if (_disappearingSeconds > 0)
            Container(
              width: double.infinity,
              color: primary.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.timer, size: 14, color: primary),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      'Disappearing messages on · new messages vanish after ${_humanTimer(_disappearingSeconds)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary),
                    ),
                  ),
                ],
              ),
            ),

          if (_viewOnceNext)
            Container(
              width: double.infinity,
              color: primary.withValues(alpha: 0.12),
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              child: Row(
                children: [
                  Icon(Icons.visibility_off, size: 14, color: primary),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      'View once · this message opens a single time, then disappears',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _viewOnceNext = false),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 16, color: primary),
                    ),
                  ),
                ],
              ),
            ),

          if (_leftGroup)
            SafeArea(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF0F2F5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: const Text(
                  "You can't send messages to this group because you're no longer a member.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ),
            )
          else ...[
            if (_replyingTo != null)
            Container(
              width: double.infinity,
              color: primary.withValues(alpha: 0.08),
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
              child: Row(
                children: [
                  Container(width: 3, height: 34, color: primary),
                  const Gap(8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Replying to ${_replySenderLabel(_replyingTo!)}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: primary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _previewFor(_replyingTo!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _clearReply,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),

          if (_mentionSuggestions.isNotEmpty) _mentionPicker(primary),

          SafeArea(

            child: Padding(

              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),

              child: _recording
                  ? _recordingBar(primary)
                  : Row(

                children: [

                  IconButton(
                    tooltip: 'Attach',
                    onPressed: _showAttachSheet,
                    icon: const Icon(Icons.attach_file),
                  ),

                  Expanded(

                    child: TextField(

                      controller: _input,

                      minLines: 1,

                      maxLines: 4,

                      decoration: InputDecoration(

                        hintText: _viewOnceNext ? 'View-once message' : 'Message',

                        filled: true,

                        fillColor: Colors.white,

                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),

                        suffixIcon: _hasText
                            ? IconButton(
                                tooltip: _viewOnceNext ? 'View once: on' : 'View once: off',
                                onPressed: () => setState(() => _viewOnceNext = !_viewOnceNext),
                                icon: Icon(
                                  _viewOnceNext
                                      ? Icons.visibility_off
                                      : Icons.visibility_off_outlined,
                                  color: _viewOnceNext ? primary : const Color(0xFF9AA3B2),
                                ),
                              )
                            : null,

                      ),

                      onSubmitted: (_) => _send(),

                    ),

                  ),

                  const Gap(8),

                  _hasText
                      ? IconButton.filled(
                          onPressed: _send,
                          icon: const Icon(Icons.send_rounded),
                        )
                      : IconButton.filled(
                          tooltip: 'Record voice note',
                          onPressed: _startRecording,
                          icon: const Icon(Icons.mic),
                        ),

                ],

              ),

            ),

          ),

          ],

        ],

      ),

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

/// Renders message text with tappable URLs and highlighted `@mentions`.
/// Manages the lifecycle of its tap recognizers so they don't leak.
class _LinkableText extends StatefulWidget {
  const _LinkableText({
    required this.text,
    required this.style,
    required this.isMine,
    required this.primary,
    this.mentionUsernames = const {},
    this.myUsername,
    this.onOpenLink,
  });

  final String text;
  final TextStyle style;
  final bool isMine;
  final Color primary;
  final Set<String> mentionUsernames;
  final String? myUsername;
  final void Function(String url)? onOpenLink;

  @override
  State<_LinkableText> createState() => _LinkableTextState();
}

class _LinkableTextState extends State<_LinkableText> {
  final List<TapGestureRecognizer> _recognizers = [];

  // URL or @mention token.
  static final RegExp _re =
      RegExp(r'(https?:\/\/[^\s]+)|(@[A-Za-z0-9_]+)');

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final text = widget.text;
    final linkColor = widget.isMine ? Colors.white : widget.primary;
    final spans = <InlineSpan>[];
    var last = 0;

    for (final m in _re.allMatches(text)) {
      final url = m.group(1);
      final mention = m.group(2);

      // Only treat as a mention if it resolves to a real group member.
      if (mention != null &&
          !widget.mentionUsernames.contains(mention.substring(1))) {
        continue;
      }

      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }

      if (url != null) {
        // Trim trailing punctuation that commonly abuts a pasted URL.
        var clean = url;
        var trailing = '';
        while (clean.isNotEmpty && '.,!?)]}'.contains(clean[clean.length - 1])) {
          trailing = clean[clean.length - 1] + trailing;
          clean = clean.substring(0, clean.length - 1);
        }
        final recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onOpenLink?.call(clean);
        _recognizers.add(recognizer);
        spans.add(TextSpan(
          text: clean,
          style: TextStyle(
            color: linkColor,
            decoration: TextDecoration.underline,
            decorationColor: linkColor,
          ),
          recognizer: recognizer,
        ));
        if (trailing.isNotEmpty) spans.add(TextSpan(text: trailing));
      } else {
        final uname = mention!.substring(1);
        final isMe = widget.myUsername != null &&
            uname.toLowerCase() == widget.myUsername!.toLowerCase();
        spans.add(TextSpan(
          text: mention,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: linkColor,
            backgroundColor: isMe
                ? (widget.isMine
                    ? Colors.white.withValues(alpha: 0.22)
                    : widget.primary.withValues(alpha: 0.14))
                : null,
          ),
        ));
      }
      last = m.end;
    }

    if (last == 0) return Text(text, style: widget.style);
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: widget.style, children: spans));
  }
}

class _Bubble extends StatelessWidget {

  const _Bubble({
    required this.message,
    required this.primary,
    this.showSender = false,
    this.mentionUsernames = const {},
    this.myUsername,
    this.onOpenLink,
    this.uploadProgress,
    this.highlighted = false,
    this.reactions = const [],
    this.onReact,
    this.onQuoteTap,
    this.onRetry,
    this.onViewOnce,
  });



  final ChatMessage message;

  final Color primary;

  final bool showSender;

  /// Group member usernames used to highlight `@mentions` in the body.
  final Set<String> mentionUsernames;

  /// My own username, so a mention of me can be emphasised.
  final String? myUsername;

  /// Tapping a URL in the body invokes this (in-app join / open in browser).
  final void Function(String url)? onOpenLink;

  /// Active upload progress (0..1) for an outgoing media message, or null.
  final double? uploadProgress;

  /// Briefly highlighted (after a quote tap scrolled here).
  final bool highlighted;

  /// Reactions on this message (for the chips below the bubble).
  final List<ReactionView> reactions;

  /// Tapping a reaction chip toggles that emoji.
  final void Function(String emoji)? onReact;

  /// Tapping the quoted block scrolls to the original message.
  final VoidCallback? onQuoteTap;

  final VoidCallback? onRetry;

  /// Tap handler for an unopened incoming one-time-view message.
  final VoidCallback? onViewOnce;



  @override

  Widget build(BuildContext context) {

    final time = DateFormat.jm().format(message.createdAt.toLocal());
    final (receipt, receiptColor) = _receiptStyle(message);
    final onMine = message.isMine ? Colors.white : const Color(0xFF111827);

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

            _content(context, onMine),

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

    final tap = (message.sendFailed && onRetry != null) ? onRetry : onViewOnce;
    Widget bubbleChild = tap != null ? GestureDetector(onTap: tap, child: bubble) : bubble;
    if (highlighted) {
      bubbleChild = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: bubbleChild,
      );
    }

    final chips = _reactionChips(context);
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubbleChild,
          if (chips != null) chips,
        ],
      ),
    );
  }

  Widget? _reactionChips(BuildContext context) {
    if (reactions.isEmpty) return null;
    final counts = <String, int>{};
    final mineSet = <String>{};
    for (final r in reactions) {
      counts[r.emoji] = (counts[r.emoji] ?? 0) + 1;
      if (r.isMine) mineSet.add(r.emoji);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 4,
        children: [
          for (final e in counts.entries)
            GestureDetector(
              onTap: onReact == null ? null : () => onReact!(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: mineSet.contains(e.key)
                      ? primary.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: mineSet.contains(e.key) ? primary : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 13)),
                    if (e.value > 1) ...[
                      const Gap(3),
                      Text('${e.value}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Renders the bubble body. A one-time-view message is hidden on BOTH ends —
  /// the sender never sees the original content either, exactly like the
  /// recipient. Only the recipient (before opening) can tap to reveal it once.
  Widget _content(BuildContext context, Color onColor) {
    if (message.viewOnce) {
      if (message.viewed) {
        return _viewOncePill(onColor, Icons.visibility_off, 'Opened');
      }
      if (message.isMine) {
        // Sender: content stays hidden, not re-openable.
        return _viewOncePill(onColor, Icons.visibility_off_outlined, 'View once');
      }
      // Recipient: tap (handled by the bubble) reveals it exactly once.
      return _viewOncePill(onColor, Icons.visibility_off_outlined, 'View once · tap to view');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isReply) _quoteBlock(context, onColor),
        if (message.isImage) _ChatImage(message: message, uploadProgress: uploadProgress),
        if (message.isFile)
          _ChatFile(message: message, onColor: onColor, uploadProgress: uploadProgress),
        if (message.isVoice)
          _ChatVoice(message: message, onColor: onColor, uploadProgress: uploadProgress),
        if (message.isMedia && message.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _bodyText(message.text, onColor),
          ),
        if (!message.isMedia) _bodyText(message.text, onColor),
      ],
    );
  }

  /// Plain text, but with tappable URLs and `@username` mentions (matching a
  /// real group member) rendered bold/coloured.
  Widget _bodyText(String text, Color onColor) {
    return _LinkableText(
      text: text,
      style: TextStyle(color: onColor, height: 1.35),
      isMine: message.isMine,
      primary: primary,
      mentionUsernames: mentionUsernames,
      myUsername: myUsername,
      onOpenLink: onOpenLink,
    );
  }

  Widget _quoteBlock(BuildContext context, Color onColor) {
    final accent = message.isMine ? Colors.white : primary;
    final bg = message.isMine
        ? Colors.white.withValues(alpha: 0.18)
        : primary.withValues(alpha: 0.08);
    return GestureDetector(
      onTap: onQuoteTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.replySender ?? 'Reply',
              style: TextStyle(
                  color: onColor, fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const Gap(2),
            Text(
              message.replyPreview ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: onColor.withValues(alpha: 0.85), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewOncePill(Color onColor, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: onColor),
        const Gap(6),
        Text(label, style: TextStyle(color: onColor, fontStyle: FontStyle.italic)),
      ],
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

/// Thumbnail for an image message. Resolves the decrypted local file (download
/// on first view), shows a sized placeholder while loading, and opens a
/// fullscreen viewer on tap.
class _ChatImage extends ConsumerStatefulWidget {
  const _ChatImage({required this.message, this.uploadProgress});

  final ChatMessage message;
  final double? uploadProgress;

  @override
  ConsumerState<_ChatImage> createState() => _ChatImageState();
}

class _ChatImageState extends ConsumerState<_ChatImage> {
  String? _path;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(_ChatImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final o = oldWidget.message;
    final n = widget.message;
    if (o.mediaLocalPath != n.mediaLocalPath || o.mediaBlobId != n.mediaBlobId) {
      _path = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final m = widget.message;
    final local = m.mediaLocalPath;
    if (local != null && File(local).existsSync()) {
      setState(() => _path = local);
      return;
    }
    final blobId = m.mediaBlobId;
    final key = m.mediaKey;
    if (blobId == null || key == null) return; // still uploading on our side
    setState(() => _loading = true);
    final path = await ref.read(mediaServiceProvider).ensureLocalFile(
          blobId: blobId,
          keyBase64: key,
          mime: m.mediaMime ?? 'image/jpeg',
        );
    if (!mounted) return;
    setState(() {
      _path = path;
      _loading = false;
    });
    if (path != null && m.confirmedOnServer) {
      ref.read(messageStoreProvider).setMediaLocalPath(m.id, path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    const maxW = 230.0;
    const maxH = 320.0;
    double dispW = maxW;
    double dispH = maxW;
    final w = m.mediaWidth ?? 0;
    final h = m.mediaHeight ?? 0;
    if (w > 0 && h > 0) {
      final ar = w / h;
      dispW = maxW;
      dispH = maxW / ar;
      if (dispH > maxH) {
        dispH = maxH;
        dispW = maxH * ar;
      }
    }

    final radius = BorderRadius.circular(12);
    final uploading = m.isMine && !m.confirmedOnServer && !m.sendFailed;
    if (_path != null) {
      final image = ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(_path!),
          width: dispW,
          height: dispH,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
      if (uploading) {
        return ClipRRect(
          borderRadius: radius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              image,
              Container(width: dispW, height: dispH, color: Colors.black38),
              _UploadRing(progress: widget.uploadProgress),
            ],
          ),
        );
      }
      return GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _FullscreenImage(path: _path!),
            fullscreenDialog: true,
          ),
        ),
        child: image,
      );
    }

    return Container(
      width: dispW,
      height: dispH,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: _loading
          ? const SizedBox(
              width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.image_outlined, color: Color(0xFF9AA3B2), size: 36),
    );
  }
}

/// Circular upload indicator with an optional percentage in the centre. A null
/// [progress] renders an indeterminate spinner (e.g. queued / no byte counts).
class _UploadRing extends StatelessWidget {
  const _UploadRing({this.progress, this.size = 46, this.color = Colors.white});

  final double? progress;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = progress == null ? null : (progress! * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: color.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (pct != null)
            Text('$pct%',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Blinking red dot shown while recording a voice note.
class _RecDot extends StatefulWidget {
  const _RecDot();

  @override
  State<_RecDot> createState() => _RecDotState();
}

class _RecDotState extends State<_RecDot> {
  Timer? _t;
  bool _on = true;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) setState(() => _on = !_on);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _on ? 1 : 0.2,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
      ),
    );
  }
}

/// Voice-note bubble: play/pause, a real waveform that fills with playback
/// progress, and the duration. Resolves the decrypted local file on first play.
class _ChatVoice extends ConsumerStatefulWidget {
  const _ChatVoice({required this.message, required this.onColor, this.uploadProgress});

  final ChatMessage message;
  final Color onColor;
  final double? uploadProgress;

  @override
  ConsumerState<_ChatVoice> createState() => _ChatVoiceState();
}

class _ChatVoiceState extends ConsumerState<_ChatVoice> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;
  String? _path;
  bool _loading = false;
  bool _ready = false;
  Duration _pos = Duration.zero;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    final local = widget.message.mediaLocalPath;
    if (local != null && File(local).existsSync()) _path = local;
    _posSub = _player.positionStream.listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    _stateSub = _player.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _playing = s.playing && s.processingState != ProcessingState.completed);
      if (s.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
        setState(() => _pos = Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final m = widget.message;
    if (_playing) {
      await _player.pause();
      return;
    }
    if (!_ready) {
      _path ??= await _resolve();
      if (_path == null) return;
      try {
        await _player.setFilePath(_path!);
        _ready = true;
      } catch (_) {
        return;
      }
    }
    if (m.mediaDurationMs == null && _player.duration == null) return;
    await _player.play();
  }

  Future<String?> _resolve() async {
    final m = widget.message;
    final blobId = m.mediaBlobId;
    final key = m.mediaKey;
    if (blobId == null || key == null) return null;
    setState(() => _loading = true);
    final path = await ref.read(mediaServiceProvider).ensureLocalFile(
          blobId: blobId,
          keyBase64: key,
          mime: m.mediaMime ?? 'audio/mp4',
          filename: 'voice.m4a',
        );
    if (!mounted) return path;
    setState(() => _loading = false);
    if (path != null && m.confirmedOnServer) {
      ref.read(messageStoreProvider).setMediaLocalPath(m.id, path);
    }
    return path;
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final onColor = widget.onColor;
    final uploading = m.isMine && !m.confirmedOnServer && !m.sendFailed;

    final totalMs = m.mediaDurationMs ?? _player.duration?.inMilliseconds ?? 0;
    final total = Duration(milliseconds: totalMs);
    final frac = totalMs > 0 ? (_pos.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0;
    final bars = (m.mediaWaveform != null && m.mediaWaveform!.isNotEmpty)
        ? m.mediaWaveform!
        : List<int>.filled(40, 12);
    final label = _playing || _pos > Duration.zero ? _fmt(_pos) : _fmt(total);

    Widget leading;
    if (uploading) {
      leading = _UploadRing(progress: widget.uploadProgress, size: 34, color: onColor);
    } else if (_loading) {
      leading = SizedBox(
        width: 34,
        height: 34,
        child: CircularProgressIndicator(strokeWidth: 2, color: onColor),
      );
    } else {
      leading = InkWell(
        onTap: _toggle,
        customBorder: const CircleBorder(),
        child: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 38, color: onColor),
      );
    }

    return SizedBox(
      width: 232,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final n = bars.length;
                      final filled = (frac * n).round();
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (var i = 0; i < n; i++)
                            Expanded(
                              child: Container(
                                height: (3 + bars[i] / 100 * 26).clamp(3.0, 30.0),
                                margin: const EdgeInsets.symmetric(horizontal: 0.6),
                                decoration: BoxDecoration(
                                  color: onColor.withValues(alpha: i < filled ? 0.95 : 0.35),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(Icons.mic, size: 12, color: onColor.withValues(alpha: 0.7)),
                      const Gap(4),
                      Text(label,
                          style: TextStyle(color: onColor.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}

/// File/document attachment card. Tap → download (if needed) → open with the
/// system app. Shows filename, size, and a download/open affordance.
class _ChatFile extends ConsumerStatefulWidget {
  const _ChatFile({required this.message, required this.onColor, this.uploadProgress});

  final ChatMessage message;
  final Color onColor;
  final double? uploadProgress;

  @override
  ConsumerState<_ChatFile> createState() => _ChatFileState();
}

class _ChatFileState extends ConsumerState<_ChatFile> {
  String? _path;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final local = widget.message.mediaLocalPath;
    if (local != null && File(local).existsSync()) _path = local;
  }

  @override
  void didUpdateWidget(_ChatFile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final local = widget.message.mediaLocalPath;
    if (local != null && local != _path && File(local).existsSync()) {
      _path = local;
    }
  }

  Future<void> _openOrDownload() async {
    if (_busy) return;
    final m = widget.message;
    if (_path != null && File(_path!).existsSync()) {
      await OpenFilex.open(_path!, type: m.mediaMime);
      return;
    }
    final blobId = m.mediaBlobId;
    final key = m.mediaKey;
    if (blobId == null || key == null) return; // still uploading
    setState(() => _busy = true);
    final path = await ref.read(mediaServiceProvider).ensureLocalFile(
          blobId: blobId,
          keyBase64: key,
          mime: m.mediaMime ?? 'application/octet-stream',
          filename: m.mediaFilename,
        );
    if (!mounted) return;
    setState(() {
      _path = path;
      _busy = false;
    });
    if (path != null) {
      if (m.confirmedOnServer) {
        ref.read(messageStoreProvider).setMediaLocalPath(m.id, path);
      }
      await OpenFilex.open(path, type: m.mediaMime);
    }
  }

  IconData _fileIcon(String? mime, String? name) {
    final m = (mime ?? '').toLowerCase();
    final n = (name ?? '').toLowerCase();
    if (m.contains('pdf') || n.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (m.startsWith('image/')) return Icons.image_outlined;
    if (m.startsWith('audio/')) return Icons.audiotrack;
    if (m.startsWith('video/')) return Icons.movie_outlined;
    if (m.contains('zip') || n.endsWith('.zip') || n.endsWith('.rar')) return Icons.folder_zip_outlined;
    if (m.contains('word') || n.endsWith('.doc') || n.endsWith('.docx')) return Icons.description_outlined;
    if (m.contains('sheet') || m.contains('excel') || n.endsWith('.xls') || n.endsWith('.xlsx')) {
      return Icons.table_chart_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _fmtSize(int? b) {
    if (b == null || b <= 0) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final onColor = widget.onColor;
    final size = _fmtSize(m.mediaSize);
    final hasLocal = _path != null && File(_path!).existsSync();
    final uploading = m.isMine && !m.confirmedOnServer && !m.sendFailed;

    return GestureDetector(
      onTap: uploading ? null : _openOrDownload,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (m.isMine ? Colors.white : const Color(0xFF111827)).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_fileIcon(m.mediaMime, m.mediaFilename), size: 34, color: onColor),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    m.mediaFilename ?? 'File',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: onColor, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (size.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(size,
                          style: TextStyle(color: onColor.withValues(alpha: 0.7), fontSize: 11)),
                    ),
                ],
              ),
            ),
            const Gap(6),
            if (uploading)
              _UploadRing(progress: widget.uploadProgress, size: 26, color: onColor)
            else if (_busy)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: onColor),
              )
            else
              Icon(hasLocal ? Icons.open_in_new : Icons.download_rounded, color: onColor),
          ],
        ),
      ),
    );
  }
}

/// Centered grey notice for group lifecycle lines ("X added Y", "Y left").
class _SystemNotice extends StatelessWidget {
  const _SystemNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDF2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF52606D)),
          ),
        ),
      ),
    );
  }
}


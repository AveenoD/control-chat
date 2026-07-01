import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/chat/chat_models.dart';
import '../../../core/chat/chat_repository.dart';
import '../../../core/chat/group_repository.dart';
import '../../../core/chat/typing_service.dart';
import '../../../core/db/message_store.dart';
import '../../../core/realtime/chat_realtime_service.dart';
import '../../chats/chat_thread_screen.dart';
import '../../chats/create_group_screen.dart';
import '../../chats/group_avatar.dart';
import '../../chats/group_invite.dart';
import '../../chats/new_chat_screen.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  List<ConversationSummary> _conversations = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  Future<void>? _inFlight;
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;
  StreamSubscription<List<ConversationSummary>>? _convSub;
  Timer? _realtimeDebounce;

  @override
  void initState() {
    super.initState();
    _subscribeToStore();
    _listenRealtime();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfReady());
  }

  void _subscribeToStore() {
    // Render cached conversations instantly (offline-capable); the network
    // refresh below just writes into the same store, which re-emits here.
    _convSub = ref.read(messageStoreProvider).watchConversations().listen((list) {
      if (!mounted) return;
      setState(() {
        _conversations = list;
        if (list.isNotEmpty) _loading = false;
      });
    });
  }

  void _loadIfReady() {
    final session = ref.read(sessionProvider);
    if (session.isAuthenticated && !session.isLoading && _inFlight == null) {
      _load(silent: _conversations.isNotEmpty);
    }
  }

  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeProvider);
    _realtimeSub = realtime.events.listen((_) {
      _realtimeDebounce?.cancel();
      _realtimeDebounce = Timer(const Duration(milliseconds: 400), () {
        if (mounted) _load(silent: true);
      });
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _convSub?.cancel();
    _realtimeDebounce?.cancel();
    super.dispose();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('receive timeout') || msg.contains('connection timeout')) {
      return 'Network slow — tap ↻ to retry';
    }
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Session expired — pull to refresh or re-login';
    }
    return msg.replaceFirst('DioException [unknown]: ', '');
  }

  Future<void> _load({bool silent = false}) async {
    if (_inFlight != null) return _inFlight!;
    _inFlight = _doLoad(silent: silent).whenComplete(() => _inFlight = null);
    return _inFlight!;
  }

  Future<void> _joinViaLink() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join via link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste a group invite link to join.'),
            const Gap(12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Invite link',
                hintText: 'https://auratalk.app/join/...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (raw == null) return;
    final token = parseInviteToken(raw);
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That doesn\'t look like a valid invite link')),
        );
      }
      return;
    }

    final repo = ref.read(groupRepositoryProvider);
    GroupInvitePreview preview;
    try {
      preview = await repo.previewInvite(token);
    } catch (e) {
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not join the group')),
          );
        }
        return;
      }
    }

    await _load(silent: true);
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
    await _load(silent: true);
  }

  Future<void> _doLoad({bool silent = false}) async {
    if (!silent) {
      setState(() {
        if (_conversations.isEmpty) {
          _loading = true;
        } else {
          _refreshing = true;
        }
        _error = null;
      });
    }
    try {
      // Writes into the local store; the watch stream updates _conversations.
      await ref.read(chatRepositoryProvider).fetchConversations();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        // Keep showing cached chats if we have them; only error when empty.
        if (_conversations.isEmpty) _error = _friendlyError(e);
      });
    }
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return DateFormat.jm().format(local);
    }
    if (now.difference(local).inDays < 7) {
      return DateFormat.E().format(local);
    }
    return DateFormat.MMMd().format(local);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    ref.listen(sessionProvider, (prev, next) {
      if (next.isAuthenticated && !next.isLoading) {
        if (prev?.isLoading == true || prev == null || !prev.isAuthenticated) {
          _load(silent: _conversations.isNotEmpty);
        }
      }
    });

    if (session.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final primary = Theme.of(context).colorScheme.primary;
    final typingMap = ref.watch(peerTypingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuraTalk'),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(onPressed: () => _load(silent: _conversations.isNotEmpty), icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'join') _joinViaLink();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'join',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.link),
                  title: Text('Join via link'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'group',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CreateGroupScreen()),
              );
              await _load();
            },
            backgroundColor: Colors.white,
            foregroundColor: primary,
            child: const Icon(Icons.group_add_outlined),
          ),
          const Gap(12),
          FloatingActionButton(
            heroTag: 'chat',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NewChatScreen()),
              );
              await _load();
            },
            backgroundColor: primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(children: const [SizedBox(height: 200), Center(child: CircularProgressIndicator())])
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(_error!, textAlign: TextAlign.center)),
                      const Gap(12),
                      Center(child: FilledButton(onPressed: _load, child: const Text('Retry'))),
                    ],
                  )
                : _conversations.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No chats yet')),
                          SizedBox(height: 8),
                          Center(child: Text('Tap + to message a contact')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: _conversations.length + 1,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: _SearchBar(),
                            );
                          }
                          final c = _conversations[i - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ChatTile(
                              name: c.peer.label,
                              username: c.isGroup ? null : c.peer.username,
                              message: c.leftGroup ? 'You left the group' : c.lastPreview,
                              time: _formatTime(c.lastAt),
                              isGroup: c.isGroup,
                              unreadCount: c.unreadCount,
                              peerTyping: typingMap[c.conversationId] ?? false,
                              avatarBlobId: c.avatarBlobId,
                              avatarKey: c.avatarKey,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ChatThreadScreen(
                                      conversationId: c.conversationId,
                                      title: c.peer.label,
                                      peerUserId: c.isGroup ? null : c.peer.userId,
                                      groupId: c.groupId,
                                      username: c.isGroup ? null : c.peer.username,
                                      isGroup: c.isGroup,
                                    ),
                                  ),
                                );
                                await _load(silent: true);
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF9AA3B2)),
          Gap(10),
          Expanded(
            child: Text(
              'Search',
              style: TextStyle(color: Color(0xFF9AA3B2), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.name,
    required this.message,
    required this.time,
    required this.onTap,
    this.username,
    this.isGroup = false,
    this.unreadCount = 0,
    this.peerTyping = false,
    this.avatarBlobId,
    this.avatarKey,
  });

  final String name;
  final String? username;
  final String message;
  final String time;
  final VoidCallback onTap;
  final bool isGroup;
  final int unreadCount;
  final bool peerTyping;
  final String? avatarBlobId;
  final String? avatarKey;

  bool get _hasUnread => unreadCount > 0;

  bool get _hasGroupAvatar =>
      isGroup && (avatarBlobId?.isNotEmpty ?? false) && (avatarKey?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final previewText = peerTyping
        ? 'typing…'
        : (message.isEmpty ? 'Start chatting' : message);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (_hasGroupAvatar)
                GroupAvatar(title: name, blobId: avatarBlobId, avatarKey: avatarKey, radius: 22)
              else
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: Icon(isGroup ? Icons.groups_outlined : Icons.person_outline, color: primary),
                ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: _hasUnread ? FontWeight.w900 : FontWeight.w800,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _hasUnread ? primary : const Color(0xFF9AA3B2),
                                fontWeight: _hasUnread ? FontWeight.w700 : FontWeight.normal,
                              ),
                        ),
                      ],
                    ),
                    if (username != null) ...[
                      const Gap(2),
                      Text('@$username', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary)),
                    ],
                    const Gap(4),
                    Text(
                      previewText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: peerTyping
                                ? primary
                                : (_hasUnread ? const Color(0xFF111827) : const Color(0xFF6B7280)),
                            fontWeight: peerTyping || _hasUnread ? FontWeight.w600 : FontWeight.normal,
                            fontStyle: peerTyping ? FontStyle.italic : FontStyle.normal,
                          ),
                    ),
                  ],
                ),
              ),
              if (_hasUnread) ...[
                const Gap(8),
                Container(
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

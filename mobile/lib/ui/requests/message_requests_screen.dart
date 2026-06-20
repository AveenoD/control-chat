import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/session_provider.dart';
import '../../core/chat/chat_models.dart';
import '../../core/chat/conversation_id.dart';
import '../chats/chat_thread_screen.dart';

class MessageRequestsScreen extends ConsumerStatefulWidget {
  const MessageRequestsScreen({super.key});

  @override
  ConsumerState<MessageRequestsScreen> createState() => _MessageRequestsScreenState();
}

class _MessageRequestsScreenState extends ConsumerState<MessageRequestsScreen> {
  List<dynamic> _requests = [];
  bool _loading = true;
  String? _actingOnId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(authRepositoryProvider).fetchIncomingRequests();
      if (!mounted) return;
      setState(() {
        _requests = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load requests: $e')),
      );
    }
  }

  Future<void> _accept(Map<String, dynamic> request) async {
    final id = request['id'] as String;
    final fromUserId = request['from_user_id'] as String;
    final username = request['username'] as String?;
    final displayName = request['display_name'] as String?;

    setState(() => _actingOnId = id);
    try {
      await ref.read(authRepositoryProvider).acceptRequest(id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accepted @${username ?? 'user'} — you can chat now')),
      );

      await _load();

      final peer = ChatPeer(
        userId: fromUserId,
        username: username,
        displayName: displayName,
      );
      final myId = ref.read(sessionProvider).userId!;
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatThreadScreen(
            conversationId: directConversationId(myId, peer.userId),
            title: peer.label,
            peerUserId: peer.userId,
            username: peer.username,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Accept failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  Future<void> _decline(String id) async {
    setState(() => _actingOnId = id);
    try {
      await ref.read(authRepositoryProvider).declineRequest(id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Decline failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message requests')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  separatorBuilder: (context, index) => const Gap(10),
                  itemBuilder: (context, i) {
                    final r = _requests[i] as Map<String, dynamic>;
                    final id = r['id'] as String;
                    final username = r['username'] as String? ?? 'user';
                    final intro = r['intro_message'] as String?;
                    final busy = _actingOnId == id;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@$username wants to reach you',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            if (intro != null && intro.isNotEmpty) ...[
                              const Gap(6),
                              Text(intro, style: const TextStyle(color: Color(0xFF6B7280))),
                            ],
                            const Gap(12),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: busy ? null : () => _decline(id),
                                  child: const Text('Decline'),
                                ),
                                const Gap(8),
                                FilledButton(
                                  onPressed: busy ? null : () => _accept(r),
                                  child: busy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Accept'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

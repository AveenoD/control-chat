import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/session_provider.dart';
import '../../core/chat/chat_models.dart';
import '../../core/chat/chat_repository.dart';
import '../../core/chat/conversation_id.dart';
import 'chat_thread_screen.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  List<ChatPeer> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await ref.read(chatRepositoryProvider).fetchContacts();
      if (mounted) setState(() => _contacts = contacts);
    } catch (_) {}
  }

  Future<void> _openByUsername() async {
    final username = _usernameCtrl.text.trim().replaceFirst('@', '');
    if (username.length < 3) return;
    setState(() => _loading = true);
    try {
      final peer = await ref.read(chatRepositoryProvider).lookupByUsername(username);
      if (peer == null) throw Exception('User not found');
      if (!mounted) return;
      await _openPeer(peer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPeer(ChatPeer peer) async {
    final myId = ref.read(sessionProvider).userId;
    if (myId != null && peer.userId == myId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself — use the other account\'s @username')),
      );
      return;
    }

    final repo = ref.read(chatRepositoryProvider);
    final allowed = await repo.canMessage(peer.userId);
    if (!mounted) return;
    if (allowed) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatThreadScreen(
            conversationId: directConversationId(myId!, peer.userId),
            title: peer.label,
            peerUserId: peer.userId,
            username: peer.username,
          ),
        ),
      );
      return;
    }

    final send = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Message @${peer.username ?? peer.userId}'),
        content: const Text(
          'This user is not in your contacts. Send a message request to start chatting.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send request')),
        ],
      ),
    );
    if (send == true) {
      await repo.sendMessageRequest(toUserId: peer.userId, introMessage: 'Hi!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message request sent')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New chat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              labelText: 'Search by @username',
              border: OutlineInputBorder(),
              prefixText: '@',
            ),
            onSubmitted: (_) => _openByUsername(),
          ),
          const Gap(12),
          FilledButton(
            onPressed: _loading ? null : _openByUsername,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Find user'),
          ),
          const Gap(24),
          Text('Contacts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const Gap(8),
          if (_contacts.isEmpty)
            const Text('No contacts yet — accept message requests from Profile')
          else
            ..._contacts.map(
              (c) => ListTile(
                leading: CircleAvatar(
                  child: Text(c.label.isNotEmpty ? c.label[0].toUpperCase() : '?'),
                ),
                title: Text(c.label),
                subtitle: c.username != null ? Text('@${c.username}') : null,
                onTap: () => _openPeer(c),
              ),
            ),
        ],
      ),
    );
  }
}

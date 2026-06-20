import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/chat/group_repository.dart';
import 'chat_thread_screen.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _title = TextEditingController();
  final _members = TextEditingController();
  bool _creating = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _members.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _title.text.trim();
    final usernames = _members.text
        .split(RegExp(r'[,\s]+'))
        .map((s) => s.trim().replaceFirst('@', ''))
        .where((s) => s.isNotEmpty)
        .toList();

    if (title.isEmpty || usernames.isEmpty) {
      setState(() => _error = 'Enter a group name and at least one @username');
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final group = await ref.read(groupRepositoryProvider).createGroup(
            title: title,
            memberUsernames: usernames,
          );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ChatThreadScreen(
            conversationId: group.conversationId,
            title: group.title,
            groupId: group.groupId,
            isGroup: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = e.toString().replaceFirst('DioException [unknown]: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New group')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Group name',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _members,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Members (@username)',
                hintText: 'shaikh_06, anees_02',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const Gap(12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const Gap(24),
            FilledButton(
              onPressed: _creating ? null : _create,
              child: _creating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create group'),
            ),
            const Gap(12),
            Text(
              'Messages are end-to-end encrypted with a shared group key.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

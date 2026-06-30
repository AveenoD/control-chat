import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/chat/group_repository.dart';
import 'chat_thread_screen.dart';
import 'member_picker_screen.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _title = TextEditingController();
  final List<String> _usernames = [];
  bool _creating = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickMembers() async {
    final picked = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(builder: (_) => const MemberPickerScreen(title: 'Select members')),
    );
    if (picked != null) {
      setState(() {
        _usernames
          ..clear()
          ..addAll(picked);
      });
    }
  }

  Future<void> _create() async {
    final title = _title.text.trim();
    if (title.isEmpty || _usernames.isEmpty) {
      setState(() => _error = 'Enter a group name and add at least one member');
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final group = await ref.read(groupRepositoryProvider).createGroup(
            title: title,
            memberUsernames: _usernames,
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
            OutlinedButton.icon(
              onPressed: _creating ? null : _pickMembers,
              icon: const Icon(Icons.group_add),
              label: Text(_usernames.isEmpty
                  ? 'Add members'
                  : '${_usernames.length} member(s) selected'),
            ),
            if (_usernames.isNotEmpty) ...[
              const Gap(10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _usernames
                    .map((u) => Chip(
                          label: Text('@$u'),
                          onDeleted: () => setState(() => _usernames.remove(u)),
                        ))
                    .toList(),
              ),
            ],
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

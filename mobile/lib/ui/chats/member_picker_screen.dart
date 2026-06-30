import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/chat/chat_models.dart';
import '../../core/chat/chat_repository.dart';

/// Reusable picker that returns a list of selected @usernames. Used both when
/// creating a group and when adding members to an existing one. Backed by the
/// user's contacts, with a manual "@username" lookup fallback.
class MemberPickerScreen extends ConsumerStatefulWidget {
  const MemberPickerScreen({
    super.key,
    this.title = 'Add members',
    this.excludeUserIds = const {},
  });

  final String title;
  final Set<String> excludeUserIds;

  @override
  ConsumerState<MemberPickerScreen> createState() => _MemberPickerScreenState();
}

class _MemberPickerScreenState extends ConsumerState<MemberPickerScreen> {
  final _search = TextEditingController();
  final List<ChatPeer> _contacts = [];
  final Map<String, ChatPeer> _selected = {}; // username -> peer
  bool _loading = true;
  bool _lookingUp = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final contacts = await ref.read(chatRepositoryProvider).fetchContacts();
      setState(() {
        _contacts
          ..clear()
          ..addAll(contacts.where((c) =>
              c.username != null && !widget.excludeUserIds.contains(c.userId)));
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addByUsername() async {
    final raw = _search.text.trim().replaceFirst('@', '').toLowerCase();
    if (raw.isEmpty) return;
    setState(() {
      _lookingUp = true;
      _error = null;
    });
    try {
      final peer = await ref.read(chatRepositoryProvider).lookupByUsername(raw);
      if (peer == null || peer.username == null) {
        setState(() => _error = 'User not found');
      } else if (widget.excludeUserIds.contains(peer.userId)) {
        setState(() => _error = 'Already in the group');
      } else {
        setState(() {
          _selected[peer.username!] = peer;
          _search.clear();
        });
      }
    } catch (_) {
      setState(() => _error = 'User not found');
    } finally {
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  void _toggle(ChatPeer peer) {
    final uname = peer.username;
    if (uname == null) return;
    setState(() {
      if (_selected.containsKey(uname)) {
        _selected.remove(uname);
      } else {
        _selected[uname] = peer;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = _search.text.trim().replaceFirst('@', '').toLowerCase();
    final visible = filter.isEmpty
        ? _contacts
        : _contacts
            .where((c) =>
                (c.username ?? '').toLowerCase().contains(filter) ||
                (c.displayName ?? '').toLowerCase().contains(filter))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(_selected.keys.toList()),
            child: Text('Add (${_selected.length})'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _addByUsername(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search contacts or @username',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                if (filter.isNotEmpty)
                  IconButton(
                    onPressed: _lookingUp ? null : _addByUsername,
                    icon: _lookingUp
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt_1),
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ),
          if (_selected.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _selected.values
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text('@${p.username}'),
                            onDeleted: () => _toggle(p),
                          ),
                        ))
                    .toList(),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                    ? const Center(child: Text('No contacts — add by @username above'))
                    : ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final c = visible[i];
                          final selected = _selected.containsKey(c.username);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (_) => _toggle(c),
                            title: Text(c.displayName ?? '@${c.username}'),
                            subtitle: c.username != null ? Text('@${c.username}') : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

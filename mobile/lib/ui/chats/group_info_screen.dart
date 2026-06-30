import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../core/auth/session_provider.dart';
import '../../core/chat/chat_models.dart';
import '../../core/chat/conversation_id.dart';
import '../../core/chat/group_repository.dart';
import '../../core/chat/media_service.dart';
import '../../core/db/message_store.dart';
import 'group_avatar.dart';
import 'member_picker_screen.dart';

enum _AvatarAction { camera, gallery, remove }

class GroupInfoScreen extends ConsumerStatefulWidget {
  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.title,
    this.isLeft = false,
  });

  final String groupId;
  final String title;
  final bool isLeft;

  @override
  ConsumerState<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends ConsumerState<GroupInfoScreen> {
  GroupMeta? _meta;
  List<GroupMember> _members = const [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!widget.isLeft) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(groupRepositoryProvider);
      final meta = await repo.getMeta(widget.groupId);
      final members = await repo.listMembers(widget.groupId);
      if (!mounted) return;
      setState(() {
        _meta = meta;
        _members = members;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load group';
      });
    }
  }

  Future<void> _addMembers() async {
    final existing = _members.map((m) => m.userId).toSet();
    final usernames = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => MemberPickerScreen(title: 'Add members', excludeUserIds: existing),
      ),
    );
    if (usernames == null || usernames.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).addMembers(widget.groupId, usernames);
      await _load();
    } catch (e) {
      _snack('Could not add members');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeMember(GroupMember m) async {
    final ok = await _confirm('Remove ${m.label}?',
        'They will lose access to future messages.');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).removeMember(widget.groupId, m.userId);
      await _load();
    } catch (e) {
      _snack('Could not remove member');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setRole(GroupMember m, String role) async {
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).setRole(widget.groupId, m.userId, role);
      await _load();
    } catch (e) {
      _snack('Could not update role');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _meta?.title ?? widget.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename group'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Group name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == _meta?.title) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).renameGroup(widget.groupId, newTitle);
      await _load();
    } catch (e) {
      _snack('Could not rename group');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeAvatar() async {
    final hasAvatar = _meta?.hasAvatar ?? false;
    final source = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop(_AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(_AvatarAction.gallery),
            ),
            if (hasAvatar)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text('Remove photo',
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => Navigator.of(context).pop(_AvatarAction.remove),
              ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final convId = groupConversationId(widget.groupId);
    final store = ref.read(messageStoreProvider);
    final repo = ref.read(groupRepositoryProvider);

    setState(() => _busy = true);
    try {
      if (source == _AvatarAction.remove) {
        await repo.setAvatar(widget.groupId, null, null);
        await store.setGroupAvatarLocal(convId, null, null);
      } else {
        final media = ref.read(mediaServiceProvider);
        final picked = await media.pickImage(
          source: source == _AvatarAction.camera ? ImageSource.camera : ImageSource.gallery,
        );
        if (picked == null) {
          if (mounted) setState(() => _busy = false);
          return;
        }
        final uploaded = await media.encryptAndUpload(
          bytes: picked.bytes,
          conversationId: convId,
          mime: picked.mime,
        );
        // Sender sees it instantly without a re-download.
        await media.cacheLocalCopy(blobId: uploaded.blobId, bytes: picked.bytes, mime: picked.mime);
        await repo.setAvatar(widget.groupId, uploaded.blobId, uploaded.keyBase64);
        await store.setGroupAvatarLocal(convId, uploaded.blobId, uploaded.keyBase64);
      }
      await _load();
    } catch (e) {
      _snack('Could not update photo');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteGroup() async {
    final ok = await _confirm('Delete group?',
        'This permanently deletes the group for everyone.');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).deleteGroup(widget.groupId);
      if (!mounted) return;
      Navigator.of(context)
        ..pop()
        ..pop();
    } catch (e) {
      _snack('Could not delete group');
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMemberActions(GroupMember m) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(m.label, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: m.username != null ? Text('@${m.username}') : null,
            ),
            const Divider(height: 1),
            if (m.isAdmin)
              ListTile(
                leading: const Icon(Icons.remove_moderator_outlined),
                title: const Text('Dismiss as admin'),
                onTap: () {
                  Navigator.of(context).pop();
                  _setRole(m, 'member');
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.add_moderator_outlined),
                title: const Text('Make admin'),
                onTap: () {
                  Navigator.of(context).pop();
                  _setRole(m, 'admin');
                },
              ),
            ListTile(
              leading: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Remove from group',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.of(context).pop();
                _removeMember(m);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _leave() async {
    final ok = await _confirm('Leave group?', 'You will stop receiving messages from this group.');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).leaveGroup(widget.groupId);
      final convId = groupConversationId(widget.groupId);
      final store = ref.read(messageStoreProvider);
      // Keep the chat as a read-only "you left" thread instead of deleting it.
      await store.markGroupLeft(convId);
      await store.upsertServerMessage(ChatMessage(
        id: 'sys-left-$convId',
        conversationId: convId,
        senderUserId: kSystemSenderId,
        text: 'You left',
        createdAt: DateTime.now(),
        isMine: false,
      ));
      if (!mounted) return;
      // Back to the (now read-only) thread, not the chats list.
      Navigator.of(context).pop();
    } catch (e) {
      _snack('Could not leave group');
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteChat() async {
    final ok = await _confirm('Delete chat?', 'This removes the group chat from this device.');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(messageStoreProvider).deleteConversation(groupConversationId(widget.groupId));
      if (!mounted) return;
      // Pop info + thread → back to chats list.
      Navigator.of(context)
        ..pop()
        ..pop();
    } catch (e) {
      _snack('Could not delete chat');
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirm(String title, String body) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.read(sessionProvider).userId;
    final amAdmin = _meta?.amAdmin ?? false;
    final title = _meta?.title ?? widget.title;

    if (widget.isLeft) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group info')),
        body: ListView(
          children: [
            const Gap(16),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  title.isNotEmpty ? title[0].toUpperCase() : '#',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const Gap(10),
            Center(
              child: Text(title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            const Gap(2),
            Center(
              child: Text("You're no longer a member of this group",
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            const Gap(20),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Delete chat',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: _busy ? null : _deleteChat,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group info'),
        actions: [
          if (amAdmin)
            IconButton(
              tooltip: 'Rename group',
              onPressed: _busy ? null : _rename,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Stack(
                  children: [
                    ListView(
                      children: [
                        const Gap(16),
                        Center(
                          child: GestureDetector(
                            onTap: (amAdmin && !_busy) ? _changeAvatar : null,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GroupAvatar(
                                  title: title,
                                  blobId: _meta?.avatarBlobId,
                                  avatarKey: _meta?.avatarKey,
                                  radius: 40,
                                ),
                                if (amAdmin)
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                    ),
                                    child: const Icon(Icons.photo_camera,
                                        size: 16, color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(10),
                        Center(
                          child: Text(title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                        const Gap(2),
                        Center(
                          child: Text('${_members.length} members · E2EE',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const Gap(16),
                        const Divider(height: 1),
                        if (amAdmin)
                          ListTile(
                            leading: const Icon(Icons.person_add_alt_1),
                            title: const Text('Add members'),
                            onTap: _busy ? null : _addMembers,
                          ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text('Members',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                        ),
                        ..._members.map((m) {
                          final isMe = m.userId == myId;
                          return ListTile(
                            onTap: (amAdmin && !isMe && !_busy)
                                ? () => _showMemberActions(m)
                                : null,
                            leading: CircleAvatar(
                              child: Text(m.label.isNotEmpty
                                  ? m.label.replaceFirst('@', '')[0].toUpperCase()
                                  : '?'),
                            ),
                            title: Text(isMe ? 'You' : m.label),
                            subtitle: m.username != null ? Text('@${m.username}') : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (m.isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('admin',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context).colorScheme.primary)),
                                  ),
                                if (amAdmin && !isMe) const Icon(Icons.chevron_right, size: 18),
                              ],
                            ),
                          );
                        }),
                        const Gap(16),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                          title: Text('Leave group',
                              style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          onTap: _busy ? null : _leave,
                        ),
                        if (amAdmin)
                          ListTile(
                            leading: Icon(Icons.delete_forever,
                                color: Theme.of(context).colorScheme.error),
                            title: Text('Delete group',
                                style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            onTap: _busy ? null : _deleteGroup,
                          ),
                        const Gap(24),
                      ],
                    ),
                    if (_busy)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x33000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
    );
  }
}

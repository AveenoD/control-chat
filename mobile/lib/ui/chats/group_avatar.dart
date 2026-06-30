import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/chat/media_service.dart';

/// Renders a group's avatar from its encrypted blob, downloading + decrypting
/// on first use (cached thereafter). Falls back to the title initial while
/// loading or when no photo is set.
class GroupAvatar extends ConsumerWidget {
  const GroupAvatar({
    super.key,
    required this.title,
    this.blobId,
    this.avatarKey,
    this.radius = 20,
  });

  final String title;
  final String? blobId;
  final String? avatarKey;
  final double radius;

  bool get _hasAvatar =>
      (blobId?.isNotEmpty ?? false) && (avatarKey?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = _Initial(title: title, radius: radius);
    if (!_hasAvatar) return fallback;

    final media = ref.read(mediaServiceProvider);
    return FutureBuilder<String?>(
      future: media.ensureLocalFile(
        blobId: blobId!,
        keyBase64: avatarKey!,
        mime: 'image/jpeg',
      ),
      builder: (context, snap) {
        final path = snap.data;
        if (path == null || !File(path).existsSync()) return fallback;
        return CircleAvatar(radius: radius, backgroundImage: FileImage(File(path)));
      },
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.title, required this.radius});

  final String title;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : '#',
        style: TextStyle(fontSize: radius * 0.8, fontWeight: FontWeight.w700),
      ),
    );
  }
}

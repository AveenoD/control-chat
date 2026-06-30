import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';

/// Read-only viewer for a single legal document ('tos' or 'privacy').
class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({super.key, required this.type, this.fallbackTitle});

  final String type;
  final String? fallbackTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(fallbackTitle ?? 'Document')),
      body: FutureBuilder<LegalDocument>(
        future: ref.read(authRepositoryProvider).fetchLegalDocument(type),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Could not load this document. Check your connection.'),
              ),
            );
          }
          final doc = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(doc.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Version ${doc.version}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              Text(doc.content, style: const TextStyle(height: 1.5, fontSize: 14.5)),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/calls/call_repository.dart';

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  List<CallHistoryEntry> _calls = [];
  bool _loading = true;
  bool _offline = false;
  StreamSubscription<List<CallHistoryEntry>>? _sub;

  @override
  void initState() {
    super.initState();
    // Render cached call log instantly (offline-capable); refresh in background.
    _sub = ref.read(callRepositoryProvider).watchHistory().listen((list) {
      if (!mounted) return;
      setState(() {
        _calls = list;
        _loading = false;
      });
    });
    _load();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      // Writes into the local store; the watch stream updates the list.
      await ref.read(callRepositoryProvider).fetchHistory();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _offline = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _offline = true;
      });
    }
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return 'Today, ${DateFormat.jm().format(local)}';
    }
    if (now.difference(local).inDays < 2) {
      return 'Yesterday, ${DateFormat.jm().format(local)}';
    }
    return DateFormat.MMMd().add_jm().format(local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading && _calls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _calls.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_offline ? Icons.cloud_off_outlined : Icons.call_outlined,
                            size: 40, color: const Color(0xFF9AA3B2)),
                        const Gap(12),
                        Text(
                          _offline
                              ? "You're offline — call history will sync when you reconnect"
                              : 'No calls yet — start one from a chat',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: _calls.length,
                    itemBuilder: (context, i) {
                      final c = _calls[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CallTile(
                          name: c.peerLabel ?? 'Unknown',
                          time: _formatTime(c.startedAt),
                          isVideo: c.callType == 'video',
                          status: c.status,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _CallTile extends StatelessWidget {
  const _CallTile({
    required this.name,
    required this.time,
    required this.isVideo,
    required this.status,
  });

  final String name;
  final String time;
  final bool isVideo;
  final String status;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Icon(Icons.person_outline, color: primary),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const Gap(2),
                  Text('$time · $status', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
                ],
              ),
            ),
            Icon(isVideo ? Icons.videocam_outlined : Icons.call_outlined, color: primary),
          ],
        ),
      ),
    );
  }
}

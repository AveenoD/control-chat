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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(callRepositoryProvider).fetchHistory();
      if (!mounted) return;
      setState(() {
        _calls = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : _calls.isEmpty
                  ? const Center(child: Text('No calls yet — start one from a chat'))
                  : ListView.builder(
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

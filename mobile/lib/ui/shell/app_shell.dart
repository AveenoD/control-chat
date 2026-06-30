import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session_provider.dart';
import '../../core/calls/call_repository.dart';
import '../../core/chat/incoming_message_service.dart';
import '../../core/realtime/chat_realtime_service.dart';
import '../calls/call_room_screen.dart';
import '../tabs/calls/calls_screen.dart';
import '../tabs/chats/chats_screen.dart';
import '../tabs/home/home_screen.dart';
import '../tabs/profile/profile_screen.dart';
import '../tabs/zones/zones_screen.dart';

final shellTabIndexProvider = NotifierProvider<_ShellTabIndexNotifier, int>(_ShellTabIndexNotifier.new);

class _ShellTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _realtimeSub = ref.read(chatRealtimeProvider).events.listen(_onRealtime);
    // App-global message ingestion: decrypts + stores + delivery-acks every
    // incoming message regardless of which screen is open, so "delivered" (✓✓)
    // works even when the chat isn't on screen. Read receipts stay per-chat.
    ref.read(incomingMessageServiceProvider).start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectRealtimeIfNeeded());
  }

  void _connectRealtimeIfNeeded() {
    final s = ref.read(sessionProvider);
    if (!s.isAuthenticated || s.userId == null || s.deviceId == null || s.accessToken == null) {
      return;
    }
    ref.read(chatRealtimeProvider).ensureConnected(
          userId: s.userId!,
          deviceId: s.deviceId!,
          accessToken: s.accessToken!,
        ).catchError((_) {
          ref.read(chatRealtimeProvider).scheduleReconnect(
                userId: s.userId!,
                deviceId: s.deviceId!,
                accessToken: s.accessToken!,
              );
        });
  }

  Future<void> _onRealtime(Map<String, dynamic> data) async {
    if (data['type'] != 'call' || !mounted) return;
    final callId = data['callId'] as String?;
    if (callId == null) return;

    final join = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Incoming call'),
        content: const Text('Someone is calling you'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Decline')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Answer')),
        ],
      ),
    );
    if (join != true || !mounted) return;
    try {
      final session = await ref.read(callRepositoryProvider).joinCall(callId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CallRoomScreen(session: session, title: 'Call'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    ref.read(incomingMessageServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (prev, next) {
      if (!next.isAuthenticated ||
          next.isLoading ||
          next.userId == null ||
          next.deviceId == null ||
          next.accessToken == null) {
        return;
      }
      // Always connect when session becomes ready (loading finished).
      if (prev?.isLoading == true || prev == null || !prev.isAuthenticated) {
        _connectRealtimeIfNeeded();
        return;
      }
      final prevKey = '${prev.userId}:${prev.deviceId}:${prev.accessToken}';
      final nextKey = '${next.userId}:${next.deviceId}:${next.accessToken}';
      if (prevKey != nextKey) {
        _connectRealtimeIfNeeded();
      }
    });

    final idx = ref.watch(shellTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: idx,
        children: const [
          HomeScreen(),
          ZonesScreen(),
          ChatsScreen(),
          CallsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _AuraBottomNav(
        index: idx,
        onChanged: (i) => ref.read(shellTabIndexProvider.notifier).setIndex(i),
      ),
    );
  }
}

class _AuraBottomNav extends StatelessWidget {
  const _AuraBottomNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
            _NavItem(
              label: 'Zone',
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view,
              selected: index == 1,
              onTap: () => onChanged(1),
            ),
            _CenterAction(
              selected: index == 2,
              onTap: () => onChanged(2),
              color: color.primary,
            ),
            _NavItem(
              label: 'Calls',
              icon: Icons.call_outlined,
              selectedIcon: Icons.call,
              selected: index == 3,
              onTap: () => onChanged(3),
            ),
            _NavItem(
              label: 'Profile',
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              selected: index == 4,
              onTap: () => onChanged(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : color.withValues(alpha: 0.92);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkResponse(
          onTap: onTap,
          radius: 32,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Chats',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? color : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = selected ? primary : const Color(0xFF9AA3B2);
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

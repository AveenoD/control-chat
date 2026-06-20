import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../core/calls/call_repository.dart';

class CallRoomScreen extends ConsumerStatefulWidget {
  const CallRoomScreen({super.key, required this.session, this.title = 'Call'});

  final CallSession session;
  final String title;

  @override
  ConsumerState<CallRoomScreen> createState() => _CallRoomScreenState();
}

class _CallRoomScreenState extends ConsumerState<CallRoomScreen> {
  Room? _room;
  bool _connecting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      await room.connect(widget.session.livekitUrl, widget.session.token);
      await room.localParticipant?.setMicrophoneEnabled(true);
      if (widget.session.callType == 'video') {
        await room.localParticipant?.setCameraEnabled(true);
      }
      if (!mounted) return;
      setState(() {
        _room = room;
        _connecting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _hangUp() async {
    await _room?.disconnect();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _room?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: _connecting
            ? const CircularProgressIndicator(color: Colors.white)
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _hangUp, child: const Text('Close')),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.session.callType == 'video' ? Icons.videocam : Icons.call,
                        size: 72,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _room?.remoteParticipants.isNotEmpty == true ? 'Connected' : 'Waiting for peer…',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 32),
                      FloatingActionButton.large(
                        backgroundColor: Colors.red.shade600,
                        onPressed: _hangUp,
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text('Tap to end', style: TextStyle(color: primary.withValues(alpha: 0.9))),
                    ],
                  ),
      ),
    );
  }
}

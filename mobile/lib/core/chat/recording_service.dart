import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final recordingServiceProvider = Provider<RecordingService>((ref) {
  final s = RecordingService();
  ref.onDispose(s.dispose);
  return s;
});

/// A finished voice-note recording, held in memory ready to be encrypted +
/// uploaded through the same media pipeline as images/files.
class RecordedVoice {
  RecordedVoice({
    required this.bytes,
    required this.durationMs,
    required this.waveform,
    required this.mime,
  });

  final Uint8List bytes;
  final int durationMs;
  final List<int> waveform; // 0..100 bars
  final String mime;
}

/// Records AAC (.m4a) voice notes and samples microphone amplitude so we can
/// render a real waveform (live during recording and persisted with the note).
class RecordingService {
  final AudioRecorder _rec = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;
  final List<double> _samples = [];
  final StreamController<double> _amp = StreamController<double>.broadcast();
  DateTime? _startedAt;
  String? _path;

  /// Normalised live amplitude (0..1) for the recording UI.
  Stream<double> get amplitude => _amp.stream;

  Future<bool> hasPermission() => _rec.hasPermission();

  Future<bool> start() async {
    if (!await _rec.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    _path = p.join(dir.path, 'vn_${DateTime.now().millisecondsSinceEpoch}.m4a');
    _samples.clear();
    await _rec.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        numChannels: 1,
        bitRate: 32000,
        sampleRate: 44100,
      ),
      path: _path!,
    );
    _startedAt = DateTime.now();
    _ampSub = _rec.onAmplitudeChanged(const Duration(milliseconds: 120)).listen((a) {
      final n = _normalize(a.current);
      _samples.add(n);
      if (!_amp.isClosed) _amp.add(n);
    });
    return true;
  }

  /// Stops and returns the recording, or null if nothing usable was captured.
  Future<RecordedVoice?> stop() async {
    final stoppedPath = await _rec.stop();
    await _ampSub?.cancel();
    _ampSub = null;
    final durationMs =
        _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inMilliseconds;
    _startedAt = null;
    final path = stoppedPath ?? _path;
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    final wf = _downsample(_samples, 40);
    try {
      await file.delete();
    } catch (_) {}
    if (bytes.isEmpty) return null;
    return RecordedVoice(bytes: bytes, durationMs: durationMs, waveform: wf, mime: 'audio/mp4');
  }

  Future<void> cancel() async {
    try {
      await _rec.stop();
    } catch (_) {}
    await _ampSub?.cancel();
    _ampSub = null;
    _startedAt = null;
    _samples.clear();
    if (_path != null) {
      try {
        final f = File(_path!);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
  }

  double _normalize(double db) {
    if (db.isNaN || db.isInfinite) return 0;
    const floor = -45.0; // quieter than this reads as silence
    return ((db - floor) / (0 - floor)).clamp(0.0, 1.0);
  }

  List<int> _downsample(List<double> samples, int target) {
    if (samples.isEmpty) return List<int>.filled(target, 8);
    if (samples.length <= target) {
      return samples.map((e) => (e * 100).round().clamp(0, 100)).toList();
    }
    final out = <int>[];
    final bucket = samples.length / target;
    for (var i = 0; i < target; i++) {
      final start = (i * bucket).floor();
      final end = ((i + 1) * bucket).floor().clamp(start + 1, samples.length);
      var mx = 0.0;
      for (var j = start; j < end; j++) {
        if (samples[j] > mx) mx = samples[j];
      }
      out.add((mx * 100).round().clamp(0, 100));
    }
    return out;
  }

  void dispose() {
    _ampSub?.cancel();
    _amp.close();
    _rec.dispose();
  }
}

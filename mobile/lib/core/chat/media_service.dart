import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../api/dio_provider.dart';
import '../crypto/media_crypto_service.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService(ref.watch(dioProvider));
});

/// A compressed, ready-to-send image picked by the user.
class PickedImage {
  PickedImage({
    required this.bytes,
    required this.mime,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String mime;
  final int width;
  final int height;
}

/// A generic file (document/any) picked by the user, loaded into memory.
class PickedFile {
  PickedFile({
    required this.bytes,
    required this.filename,
    required this.mime,
    required this.size,
  });

  final Uint8List bytes;
  final String filename;
  final String mime;
  final int size;
}

/// Result of encrypting + uploading a blob to object storage.
class UploadedBlob {
  UploadedBlob({required this.blobId, required this.keyBase64, required this.size});
  final String blobId;
  final String keyBase64;
  final int size;
}

/// Handles the full media lifecycle: pick → compress → encrypt → upload, and
/// download → decrypt → cache. The server only ever sees ciphertext; the AES
/// key travels end-to-end inside the chat message.
class MediaService {
  MediaService(this._dio);

  final Dio _dio;
  final ImagePicker _picker = ImagePicker();

  // blobId -> resolved local file path; avoids re-downloading within a session.
  final Map<String, String> _pathCache = {};
  final Map<String, Future<String?>> _inflight = {};

  Future<PickedImage?> pickImage({required ImageSource source}) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 95,
    );
    if (x == null) return null;
    final raw = await x.readAsBytes();

    // Re-compress to a sane size/quality for chat. Falls back to the original
    // bytes if the platform compressor is unavailable.
    Uint8List bytes;
    try {
      bytes = await FlutterImageCompress.compressWithList(
        raw,
        minWidth: 1600,
        minHeight: 1600,
        quality: 78,
        format: CompressFormat.jpeg,
      );
    } catch (_) {
      bytes = raw;
    }

    int width = 0;
    int height = 0;
    try {
      final img = await decodeImageFromList(bytes);
      width = img.width;
      height = img.height;
    } catch (_) {}

    return PickedImage(bytes: bytes, mime: 'image/jpeg', width: width, height: height);
  }

  /// Picks any document/file and loads its bytes into memory for encryption.
  Future<PickedFile?> pickFile() async {
    final res = await FilePicker.platform.pickFiles(withData: true);
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    final bytes = f.bytes;
    if (bytes == null) return null;
    return PickedFile(
      bytes: bytes,
      filename: f.name,
      mime: _mimeFromExtension(f.extension),
      size: bytes.length,
    );
  }

  /// Encrypts [bytes] with a fresh key and uploads the ciphertext. Returns the
  /// blob id + key to embed in the (E2EE) message.
  Future<UploadedBlob> encryptAndUpload({
    required Uint8List bytes,
    required String conversationId,
    required String mime,
    void Function(int sent, int total)? onProgress,
  }) async {
    final enc = await MediaCryptoService.encryptBytes(bytes);
    final res = await _dio.post<Map<String, dynamic>>(
      '/media',
      data: enc.blob,
      queryParameters: {'conversationId': conversationId, 'contentType': mime},
      options: Options(contentType: 'application/octet-stream'),
      onSendProgress: onProgress,
    );
    final data = res.data!;
    if (data['ok'] != true || data['blobId'] == null) {
      throw Exception('Upload failed');
    }
    return UploadedBlob(
      blobId: data['blobId'] as String,
      keyBase64: enc.keyBase64,
      size: (data['size'] as num?)?.toInt() ?? bytes.length,
    );
  }

  /// Writes already-encrypted-source [bytes] (the sender's own picked image) to
  /// the local cache under [blobId] so the sender sees it instantly without a
  /// round-trip download.
  Future<String> cacheLocalCopy({
    required String blobId,
    required Uint8List bytes,
    String mime = 'image/jpeg',
    String? filename,
  }) async {
    final file = await _fileFor(blobId, mime, filename);
    await file.writeAsBytes(bytes, flush: true);
    _pathCache[blobId] = file.path;
    return file.path;
  }

  /// Returns a decrypted local file path for [blobId], downloading + decrypting
  /// on first access and caching thereafter. Returns null on failure.
  Future<String?> ensureLocalFile({
    required String blobId,
    required String keyBase64,
    String mime = 'image/jpeg',
    String? filename,
  }) {
    final cached = _pathCache[blobId];
    if (cached != null && File(cached).existsSync()) return Future.value(cached);

    final existing = _inflight[blobId];
    if (existing != null) return existing;

    final future = _download(blobId, keyBase64, mime, filename).whenComplete(() {
      _inflight.remove(blobId);
    });
    _inflight[blobId] = future;
    return future;
  }

  Future<String?> _download(String blobId, String keyBase64, String mime, [String? filename]) async {
    try {
      final file = await _fileFor(blobId, mime, filename);
      if (file.existsSync() && await file.length() > 0) {
        _pathCache[blobId] = file.path;
        return file.path;
      }
      final res = await _dio.get<List<int>>(
        '/media/$blobId',
        options: Options(responseType: ResponseType.bytes),
      );
      final blob = Uint8List.fromList(res.data!);
      final clear = await MediaCryptoService.decryptBytes(blob, keyBase64);
      await file.writeAsBytes(clear, flush: true);
      _pathCache[blobId] = file.path;
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<File> _fileFor(String blobId, String mime, [String? filename]) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'media_cache'));
    if (!mediaDir.existsSync()) {
      await mediaDir.create(recursive: true);
    }
    // Prefer the original filename so the OS opens it with the right app
    // (e.g. report.pdf → PDF viewer). Prefix with the blob id for uniqueness.
    if (filename != null && filename.trim().isNotEmpty) {
      final safe = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      return File(p.join(mediaDir.path, '${blobId}__$safe'));
    }
    final ext = mime.contains('png') ? 'png' : 'jpg';
    return File(p.join(mediaDir.path, '$blobId.$ext'));
  }

  String _mimeFromExtension(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  /// Best-effort delete of a cached local file (used when a view-once image is
  /// consumed). The remote blob is access-controlled and short-lived anyway.
  Future<void> deleteLocal(String? blobId) async {
    if (blobId == null) return;
    final path = _pathCache.remove(blobId);
    try {
      if (path != null) {
        final f = File(path);
        if (f.existsSync()) await f.delete();
      }
    } catch (_) {}
  }
}

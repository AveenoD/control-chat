import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// What the preview screen hands back to the chat thread when the user hits
/// send. `null` (route popped without a result) means the user cancelled.
class MediaPreviewResult {
  const MediaPreviewResult({required this.caption, required this.viewOnce});

  final String caption;
  final bool viewOnce;
}

/// Full-screen confirmation step shown after picking an image or a file, before
/// anything is uploaded. Lets the user add a caption and arm a per-attachment
/// "view once" toggle. Images render a real preview; files show a card.
class MediaPreviewScreen extends StatefulWidget {
  const MediaPreviewScreen._({
    this.imageBytes,
    this.fileName,
    this.fileSize,
    required this.mime,
    required this.isImage,
  });

  factory MediaPreviewScreen.image({
    required Uint8List bytes,
    required String mime,
  }) =>
      MediaPreviewScreen._(imageBytes: bytes, mime: mime, isImage: true);

  factory MediaPreviewScreen.file({
    required String name,
    required int size,
    required String mime,
  }) =>
      MediaPreviewScreen._(
        fileName: name,
        fileSize: size,
        mime: mime,
        isImage: false,
      );

  final Uint8List? imageBytes;
  final String? fileName;
  final int? fileSize;
  final String mime;
  final bool isImage;

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  final _caption = TextEditingController();
  bool _viewOnce = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  void _send() {
    Navigator.of(context).pop(
      MediaPreviewResult(caption: _caption.text.trim(), viewOnce: _viewOnce),
    );
  }

  IconData _fileIcon() {
    final m = widget.mime.toLowerCase();
    final n = (widget.fileName ?? '').toLowerCase();
    if (m.contains('pdf') || n.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (m.startsWith('audio/')) return Icons.audiotrack;
    if (m.startsWith('video/')) return Icons.movie_outlined;
    if (m.contains('zip') || n.endsWith('.zip') || n.endsWith('.rar')) {
      return Icons.folder_zip_outlined;
    }
    if (m.contains('word') || n.endsWith('.doc') || n.endsWith('.docx')) {
      return Icons.description_outlined;
    }
    if (m.contains('sheet') || m.contains('excel') || n.endsWith('.xls') || n.endsWith('.xlsx')) {
      return Icons.table_chart_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _fmtSize(int? b) {
    if (b == null || b <= 0) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          widget.isImage ? 'Send photo' : 'Send file',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: _viewOnce ? 'View once: on' : 'View once: off',
            onPressed: () => setState(() => _viewOnce = !_viewOnce),
            icon: Icon(
              _viewOnce ? Icons.visibility_off : Icons.visibility_off_outlined,
              color: _viewOnce ? theme.colorScheme.primary : Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: widget.isImage
                  ? InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Image.memory(widget.imageBytes!, fit: BoxFit.contain),
                    )
                  : _fileCard(),
            ),
          ),
          if (_viewOnce)
            Container(
              width: double.infinity,
              color: theme.colorScheme.primary.withValues(alpha: 0.18),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.visibility_off, size: 16, color: Colors.white),
                  const Gap(8),
                  const Expanded(
                    child: Text(
                      'View once — opens a single time, then disappears',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _caption,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add a caption…',
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.12),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  FloatingActionButton(
                    onPressed: _send,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileCard() {
    final size = _fmtSize(widget.fileSize);
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_fileIcon(), size: 72, color: Colors.white),
          const Gap(16),
          Text(
            widget.fileName ?? 'File',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          if (size.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(size, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

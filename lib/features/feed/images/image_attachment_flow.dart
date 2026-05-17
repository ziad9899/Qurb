import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'image_pipeline.dart';

/// End-to-end "attach a photo" flow used by the composer.
///
/// 1. shows a bottom sheet: take photo / choose from gallery / cancel
/// 2. routes to image_picker for raw bytes
/// 3. pushes the pro_image_editor screen for annotation
/// 4. compresses + strips EXIF
///
/// Returns null at any step if the user cancels. The composer is
/// responsible for showing errors via ScaffoldMessenger and for
/// keeping the returned bytes in its own state until "Post" is tapped.
Future<ProcessedImage?> runImageAttachmentFlow({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final source = await _showSourceSheet(context);
  if (source == null || !context.mounted) return null;

  final pipeline = ref.read(imagePipelineProvider);
  Uint8List? raw;
  try {
    raw = switch (source) {
      _Source.camera => await pipeline.pickFromCamera(),
      _Source.gallery => await pipeline.pickFromGallery(),
    };
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picker failed: $e')),
      );
    }
    return null;
  }
  if (raw == null || !context.mounted) return null;

  // Send the raw bytes (still EXIF-bearing) into the editor. We
  // strip EXIF AFTER editing so any rotation/crop done in the
  // editor uses the original full-resolution pixels for sharpness.
  final edited = await _openEditor(context, raw);
  if (edited == null || !context.mounted) return null;

  try {
    return await pipeline.processForUpload(edited);
  } on ImageProcessingException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
    return null;
  }
}

enum _Source { camera, gallery }

Future<_Source?> _showSourceSheet(BuildContext context) {
  return showModalBottomSheet<_Source>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, _Source.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, _Source.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<Uint8List?> _openEditor(BuildContext context, Uint8List bytes) {
  return Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => ProImageEditor.memory(
        bytes,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (edited) async {
            Navigator.of(ctx).pop(edited);
          },
          onCloseEditor: (_) => Navigator.of(ctx).pop(),
        ),
      ),
    ),
  );
}

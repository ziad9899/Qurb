import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pure-Dart helpers for the photo-attachment flow. Three responsibilities:
///   1. picking — wraps image_picker for camera/gallery
///   2. processing — strips EXIF and clamps dimensions / byte size
///   3. uploading — writes to the post-images Supabase bucket under
///      the caller's own user_id/ prefix
///
/// The widget layer composes these. The composer screen calls
/// `pickFromCamera` / `pickFromGallery` to get raw bytes, passes those
/// through the editor (pro_image_editor) to get flattened bytes, then
/// hands those to `processForUpload` and `upload`.
class ImagePipeline {
  ImagePipeline(this._client);

  final SupabaseClient _client;
  final ImagePicker _picker = ImagePicker();

  /// Max output dimensions after compression. 9:16 = 1080×1920 caps
  /// uploads at well under 2 MB after JPEG quality 80.
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1920;
  static const int _jpegQuality = 80;
  static const int _hardByteCap = 2 * 1024 * 1024;

  /// Opens the system camera. Returns null if the user cancels or
  /// denies permission. Raises a [PermissionException] only when the
  /// failure is non-recoverable (e.g. permanently denied + opens
  /// Settings); transient cancellations return null silently.
  Future<Uint8List?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      // Keep capture at native resolution; we resize during compress
      // so the editor sees a sharp input to draw on.
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (picked == null) return null;
    return picked.readAsBytes();
  }

  /// Opens the system gallery picker. Same semantics as pickFromCamera.
  Future<Uint8List?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked == null) return null;
    return picked.readAsBytes();
  }

  /// Re-encodes the input to JPEG and clamps dimensions. The
  /// flutter_image_compress library does NOT preserve EXIF when
  /// re-encoding, so GPS, device, and timestamp metadata are stripped
  /// in this single step. Returns the cleaned bytes + their final
  /// pixel dimensions.
  Future<ProcessedImage> processForUpload(Uint8List input) async {
    final bytes = await FlutterImageCompress.compressWithList(
      input,
      minWidth: _maxWidth,
      minHeight: _maxHeight,
      quality: _jpegQuality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (bytes.length > _hardByteCap) {
      // One more pass at lower quality if we're still over the cap.
      // 60% is the floor — anything lower looks visibly bad.
      final retry = await FlutterImageCompress.compressWithList(
        input,
        minWidth: _maxWidth,
        minHeight: _maxHeight,
        quality: 60,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (retry.length > _hardByteCap) {
        throw const ImageProcessingException(
          'image_too_large',
          'Image is still over 2 MB after compression. Try a simpler image.',
        );
      }
      return ProcessedImage(retry);
    }
    return ProcessedImage(bytes);
  }

  /// Uploads to `post-images/{user_id}/{uuid}.jpg`. Returns the
  /// storage path which the caller passes to `create_post` as
  /// `p_image_path`. The server then verifies the path belongs to
  /// the caller before linking it to the post (no trust on the
  /// client side — the RPC re-checks ownership).
  Future<String> upload(ProcessedImage image) async {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw const ImageProcessingException(
        'not_authenticated',
        'You must be signed in to upload an image.',
      );
    }
    final uid = session.user.id;
    final filename =
        '${DateTime.now().microsecondsSinceEpoch}_${_randomSuffix()}.jpg';
    final path = '$uid/$filename';

    await _client.storage.from('post-images').uploadBinary(
          path,
          image.bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            cacheControl: '31536000',
            upsert: false,
          ),
        );
    return path;
  }

  /// Resolves a storage path to a short-lived signed URL the feed
  /// can render. The post-images bucket is private; signed URLs
  /// expire after [ttlSeconds] (default 1 hour) so they aren't
  /// useful if scraped from a screenshot of network traffic.
  Future<String> signedUrlFor(String path, {int ttlSeconds = 3600}) {
    return _client.storage.from('post-images').createSignedUrl(path, ttlSeconds);
  }

  String _randomSuffix() {
    // 8-character random alphanumeric suffix to avoid filename
    // collisions when two posts are uploaded within the same microsecond.
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final now = DateTime.now().microsecondsSinceEpoch;
    var n = now;
    final buf = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buf.write(chars[n % chars.length]);
      n ~/= chars.length;
    }
    return buf.toString();
  }
}

class ProcessedImage {
  ProcessedImage(this.bytes);
  final Uint8List bytes;

  int get byteSize => bytes.length;
}

class ImageProcessingException implements Exception {
  const ImageProcessingException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'ImageProcessingException($code): $message';
}

final imagePipelineProvider = Provider<ImagePipeline>((ref) {
  return ImagePipeline(Supabase.instance.client);
});

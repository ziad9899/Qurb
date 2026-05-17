import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/data/mock_data.dart' show Proximity;
import '../../core/location/location_providers.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../l10n/generated/app_localizations.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import 'data/feed_providers.dart';
import 'images/image_attachment_flow.dart';
import 'images/image_pipeline.dart';

// Tag ordering. Labels come from AppLocalizations.compose_tag_* at render
// time so they switch language with the rest of the UI; this list pins the
// canonical wire keys persisted on the server.
const _kTagKeys = ['stories', 'feelings', 'discussion', 'help', 'moment', 'question'];

String _tagLabel(AppLocalizations t, String key) => switch (key) {
      'stories' => t.compose_tag_stories,
      'feelings' => t.compose_tag_feelings,
      'discussion' => t.compose_tag_discussion,
      'help' => t.compose_tag_help,
      'moment' => t.compose_tag_moment,
      'question' => t.compose_tag_question,
      _ => key,
    };

class ComposerScreen extends ConsumerStatefulWidget {
  const ComposerScreen({super.key});
  @override
  ConsumerState<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends ConsumerState<ComposerScreen> {
  final _controller = TextEditingController();
  Proximity _scope = Proximity.near;
  String _tag = _kTagKeys.first;
  bool _busy = false;
  String? _error;
  static const _max = 500;

  /// Optional photo attachment. Null until the user runs the image
  /// attachment flow at least once. Cleared when they tap the X
  /// on the preview thumbnail or after a successful publish.
  ProcessedImage? _draftImage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_busy) return;
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Best-effort: acquire location if not yet granted. The OS prompt
      // appears the first time the user publishes — a context they expect
      // ("ينشر قريبًا منك" already implies geography).
      var coords = latLngFrom(ref.read(myLocationProvider));
      if (coords == null) {
        await ref.read(myLocationProvider.notifier).acquire();
        coords = latLngFrom(ref.read(myLocationProvider));
      }

      // If the user attached an image, upload it FIRST. We do this
      // before create_post so the storage object exists by the time
      // the RPC verifies ownership. If upload fails the post is
      // never created — no orphan rows.
      String? imagePath;
      int? imageBytes;
      if (_draftImage != null) {
        final pipeline = ref.read(imagePipelineProvider);
        imagePath = await pipeline.upload(_draftImage!);
        imageBytes = _draftImage!.byteSize;
      }

      await ref.read(postRepositoryProvider).createPost(
            body: body,
            tag: _tag,
            proximity: _scope,
            lat: coords?.lat,
            lng: coords?.lng,
            imagePath: imagePath,
            imageBytes: imageBytes,
          );
      ref.invalidate(feedPostsProvider);
      HapticFeedback.mediumImpact();
      if (mounted) context.pop();
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() => _error = _humanizeError(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _attachImage() async {
    if (_busy) return;
    // PDPL consent: shown once before the first image attachment.
    // The flag lives in SharedPreferences in a follow-up; for MVP we
    // surface the disclosure every time inside a non-blocking sheet
    // before opening the picker. Tapping "Continue" proceeds; "Cancel"
    // backs out without any picker permission prompt firing.
    final consented = await _showConsentSheet();
    if (consented != true || !mounted) return;

    final result = await runImageAttachmentFlow(context: context, ref: ref);
    if (!mounted || result == null) return;
    setState(() => _draftImage = result);
  }

  Future<bool?> _showConsentSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مشاركة صورة',
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'بالاستمرار، أنت تؤكد أنك تملك حقوق هذه الصورة ولديك إذن '
                'بمشاركتها. نحذف بيانات الموقع (GPS) تلقائياً قبل الرفع.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('متابعة'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _humanizeError(String s) {
    final t = AppLocalizations.of(context);
    if (s.contains('rate_limit_posts_per_day')) return t.compose_err_rateLimit;
    if (s.contains('moderation_violation')) return t.compose_err_moderation;
    if (s.contains('body length out of range')) return t.compose_err_length;
    return t.compose_err_generic;
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final profileAsync = ref.watch(myProfileProvider);
    final shape = ref.watch(idShapeProvider);
    final text = _controller.text;
    final left = _max - text.length;
    final canPublish = text.trim().isNotEmpty && !_busy;

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(18, media.padding.top + 4, 18, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: QurbIconWidget(
                      QIcon.close, size: 22, color: qurb.textDim,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  t.compose_title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
                const Spacer(),
                _PublishButton(
                  enabled: canPublish,
                  busy: _busy,
                  onPressed: _publish,
                ),
              ],
            ),
          ),
          // Author row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Row(
              children: [
                profileAsync.maybeWhen(
                  data: (p) => p == null
                      ? const SizedBox.shrink()
                      : IdBadge(id: p.numericId.toString(), shape: shape),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Text(
                  t.compose_id_hint,
                  style: TextStyle(fontSize: 12, color: qurb.textDim),
                ),
              ],
            ),
          ),
          // Textarea
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                maxLength: _max,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  fontSize: 18,
                  color: qurb.text,
                  height: 1.65,
                ),
                decoration: InputDecoration(
                  hintText: t.compose_hint,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: qurb.textFaint,
                    height: 1.65,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          // Footer
          Container(
            decoration: BoxDecoration(
              color: qurb.bgElev,
              border: Border(
                top: BorderSide(color: qurb.border, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scope
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.compose_scope_label,
                        style: TextStyle(
                          fontSize: 11,
                          color: qurb.textFaint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final s in [
                            (Proximity.near, t.compose_scope_near_label, t.compose_scope_near_desc),
                            (Proximity.block, t.compose_scope_block_label, t.compose_scope_block_desc),
                            (Proximity.city, t.compose_scope_city_label, t.compose_scope_city_desc),
                          ])
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(end: 6),
                                child: _ScopeTile(
                                  active: _scope == s.$1,
                                  label: s.$2,
                                  desc: s.$3,
                                  onTap: () =>
                                      setState(() => _scope = s.$1),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tags
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.compose_tag_label,
                        style: TextStyle(
                          fontSize: 11,
                          color: qurb.textFaint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final key in _kTagKeys)
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 6),
                                child: GestureDetector(
                                  onTap: () => setState(() => _tag = key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11, vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: key == _tag
                                          ? qurb.gold
                                          : qurb.surface,
                                      borderRadius: BorderRadius.circular(999),
                                      border: key == _tag
                                          ? null
                                          : Border.all(
                                              color: qurb.border, width: 0.5),
                                    ),
                                    child: Text(
                                      '#${_tagLabel(t, key)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: key == _tag
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: key == _tag
                                            ? const Color(0xFF0A0A0B)
                                            : qurb.textDim,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Image/camera + char counter + error
                Container(
                  padding: EdgeInsets.fromLTRB(
                    18, 8, 18, 16 + media.padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: qurb.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      _ActionIconSquare(
                        icon: QIcon.image,
                        enabled: _draftImage == null && !_busy,
                        onTap: _attachImage,
                      ),
                      const SizedBox(width: 12),
                      _ActionIconSquare(
                        icon: QIcon.camera,
                        enabled: _draftImage == null && !_busy,
                        onTap: _attachImage,
                      ),
                      if (_draftImage != null) ...[
                        const SizedBox(width: 12),
                        _DraftImageChip(
                          image: _draftImage!,
                          onRemove: () =>
                              setState(() => _draftImage = null),
                        ),
                      ],
                      const Spacer(),
                      if (_error != null) ...[
                        Expanded(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 11, color: qurb.danger),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        '$left',
                        style: TextStyle(
                          fontSize: 12,
                          color: left < 50 ? qurb.accent : qurb.textFaint,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeTile extends StatelessWidget {
  const _ScopeTile({
    required this.active,
    required this.label,
    required this.desc,
    required this.onTap,
  });
  final bool active;
  final String label;
  final String desc;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: active ? qurb.accentSoft : qurb.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? qurb.accent : qurb.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? qurb.accent : qurb.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 10,
                color: active ? qurb.accent : qurb.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small chip in the composer footer that previews the attached
/// photo (40×40 rounded thumbnail) with an X to remove it.
class _DraftImageChip extends StatelessWidget {
  const _DraftImageChip({required this.image, required this.onRemove});
  final ProcessedImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            image.bytes,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tappable variant of [_IconButtonSquare]. When [enabled] is false the
/// icon is dimmed and taps are absorbed. Used by the composer to wire
/// the image / camera buttons to the attachment flow.
class _ActionIconSquare extends StatelessWidget {
  const _ActionIconSquare({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });
  final QIcon icon;
  final VoidCallback onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: qurb.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: qurb.border, width: 0.5),
          ),
          child: Center(
            child: QurbIconWidget(icon, size: 18, color: qurb.text),
          ),
        ),
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  const _PublishButton({
    required this.enabled, required this.busy, required this.onPressed,
  });
  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: enabled ? qurb.accent : qurb.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: busy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                ),
              )
            : Text(
                t.compose_publish,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? const Color(0xFFFFFFFF)
                      : qurb.textFaint,
                ),
              ),
      ),
    );
  }
}

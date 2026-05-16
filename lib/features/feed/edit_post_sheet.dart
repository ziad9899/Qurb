import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../l10n/generated/app_localizations.dart';
import 'data/feed_providers.dart';

/// Bottom sheet that lets a post's author rewrite the body. Runs the same
/// 500-char + moderation checks as compose, surfaces the same error keys.
/// On success: pops + invalidates the feed so the edit appears immediately.
class EditPostSheet extends ConsumerStatefulWidget {
  const EditPostSheet({
    super.key,
    required this.postId,
    required this.initialBody,
  });
  final int postId;
  final String initialBody;

  static Future<bool?> show(
    BuildContext context, {
    required int postId,
    required String initialBody,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditPostSheet(postId: postId, initialBody: initialBody),
      ),
    );
  }

  @override
  ConsumerState<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends ConsumerState<EditPostSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialBody);
  bool _busy = false;
  String? _error;
  static const _max = 500;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final body = _controller.text.trim();
    if (body.isEmpty || body == widget.initialBody) {
      Navigator.of(context).pop(false);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(postRepositoryProvider).updateMyPost(
            postId: widget.postId,
            body: body,
          );
      ref.invalidate(feedPostsProvider);
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        final t = AppLocalizations.of(context);
        final msg = e.toString();
        setState(() {
          _error = msg.contains('moderation_violation')
              ? t.compose_err_moderation
              : msg.contains('body length out of range')
                  ? t.compose_err_length
                  : t.compose_err_generic;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final left = _max - _controller.text.length;
    return Container(
      decoration: BoxDecoration(
        color: qurb.bgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: qurb.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  QurbIconWidget(QIcon.more, size: 18, color: qurb.text),
                  const SizedBox(width: 8),
                  Text(
                    t.post_edit_title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: qurb.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: qurb.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 8,
                  maxLength: _max,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 14, color: qurb.text, height: 1.7,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    isCollapsed: true,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 12, color: qurb.danger),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '$left',
                  style: TextStyle(
                    fontSize: 11,
                    color: left < 50 ? qurb.accent : qurb.textFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: qurb.border),
                        foregroundColor: qurb.textDim,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(t.common_cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: qurb.accent,
                        foregroundColor: const Color(0xFFFFFFFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFFFFF),
                                ),
                              ),
                            )
                          : Text(t.post_edit_save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

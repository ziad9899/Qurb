import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_icon.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import 'data/whispers_providers.dart';

/// Modal that lets the user attach a short note and dispatch a whisper
/// request for a specific post. Triggered from the post's "همس للناشر".
class WhisperRequestSheet extends ConsumerStatefulWidget {
  const WhisperRequestSheet({
    super.key,
    required this.postId,
    required this.recipientNumericId,
    this.postPreview,
  });
  final int postId;
  final int recipientNumericId;
  final String? postPreview;

  static Future<void> show(
    BuildContext context, {
    required int postId,
    required int recipientNumericId,
    String? postPreview,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: WhisperRequestSheet(
          postId: postId,
          recipientNumericId: recipientNumericId,
          postPreview: postPreview,
        ),
      ),
    );
  }

  @override
  ConsumerState<WhisperRequestSheet> createState() =>
      _WhisperRequestSheetState();
}

class _WhisperRequestSheetState extends ConsumerState<WhisperRequestSheet> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(whispersRepositoryProvider).requestWhisper(
            postId: widget.postId,
            message: _controller.text.trim().isEmpty
                ? null
                : _controller.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      final msg = e.toString();
      // Server sends "chat_exists:<id>" — jump straight to it.
      final match = RegExp(r'chat_exists:(\d+)').firstMatch(msg);
      if (match != null) {
        if (mounted) {
          Navigator.of(context).pop();
          context.push('/whispers/${match.group(1)}');
        }
        return;
      }
      setState(() => _error = _humanizeError(msg));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _humanizeError(String s) {
    if (s.contains('declined_cooldown')) {
      return 'الناشر رفض طلباً سابقاً — حاول بعد 30 يومًا.';
    }
    if (s.contains('rate_limit_whisper_requests_per_hour')) {
      return 'وصلت لحدّ طلبات الهمس (3/ساعة).';
    }
    if (s.contains('cannot_whisper_self')) {
      return 'لا يمكنك إرسال همس لنفسك.';
    }
    return 'تعذّر إرسال الطلب.';
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    return Container(
      decoration: BoxDecoration(
        color: qurb.bgElev,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: qurb.borderStrong, width: 0.5),
          left: BorderSide(color: qurb.border, width: 0.5),
          right: BorderSide(color: qurb.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // grabber
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: qurb.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  QurbIconWidget(QIcon.whisper, size: 18, color: qurb.accent),
                  const SizedBox(width: 8),
                  Text(
                    'همس للناشر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: qurb.text,
                    ),
                  ),
                  const Spacer(),
                  IdBadge(
                    id: widget.recipientNumericId.toString(),
                    shape: shape,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'سيستلم الناشر طلب همس. لن تستطيع إرسال رسائل قبل أن يقبل.',
                style: TextStyle(
                  fontSize: 12, color: qurb.textDim, height: 1.6,
                ),
              ),
              if (widget.postPreview != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: qurb.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: qurb.border, width: 0.5),
                  ),
                  child: Text(
                    widget.postPreview!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5, color: qurb.textDim, height: 1.6,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: qurb.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  maxLength: 500,
                  style: TextStyle(
                    fontSize: 14, color: qurb.text, height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'رسالة قصيرة (اختياري)',
                    hintStyle: TextStyle(
                      fontSize: 14, color: qurb.textFaint,
                    ),
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: qurb.border),
                        foregroundColor: qurb.textDim,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: qurb.accent,
                        foregroundColor: const Color(0xFFFFFFFF),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
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
                          : const Text('إرسال طلب'),
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

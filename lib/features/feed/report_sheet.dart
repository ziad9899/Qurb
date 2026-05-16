import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../l10n/generated/app_localizations.dart';
import '../profile/data/profile_providers.dart';

class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({
    super.key,
    required this.targetType,
    required this.targetId,
  });
  final String targetType; // 'post' | 'comment'
  final int targetId;

  static Future<bool?> show(
    BuildContext context, {
    required String targetType,
    required int targetId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x59000000),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportSheet(
          targetType: targetType,
          targetId: targetId,
        ),
      ),
    );
  }

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  String? _reason;
  bool _busy = false;
  String? _error;

  List<(String, String, String)> _reasonsFor(AppLocalizations t) => [
    ('spam', t.report_reason_spam_title, t.report_reason_spam_desc),
    ('harass', t.report_reason_harass_title, t.report_reason_harass_desc),
    ('fake', t.report_reason_fake_title, t.report_reason_fake_desc),
    ('nsfw', t.report_reason_nsfw_title, t.report_reason_nsfw_desc),
    ('private', t.report_reason_private_title, t.report_reason_private_desc),
    ('other', t.report_reason_other_title, t.report_reason_other_desc),
  ];

  Future<void> _submit() async {
    if (_reason == null || _busy) return;
    HapticFeedback.lightImpact();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(profileRepositoryProvider).fileReport(
            targetType: widget.targetType,
            targetId: widget.targetId,
            reason: _reason!,
          );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      final t = AppLocalizations.of(context);
      setState(() {
        _error = e.toString().contains('rate_limit')
            ? t.report_err_rateLimit
            : t.report_err_generic;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final reasons = _reasonsFor(t);
    return Container(
      decoration: BoxDecoration(
        color: qurb.bgElev,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
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
              Text(
                widget.targetType == 'comment'
                    ? t.report_comment_title
                    : t.report_post_title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: qurb.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.report_subtitle,
                style: TextStyle(
                  fontSize: 12, color: qurb.textDim, height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              ...reasons.map((r) {
                final active = _reason == r.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _reason = r.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            active ? qurb.accentSoft : qurb.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active ? qurb.accent : qurb.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.$2,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? qurb.accent
                                        : qurb.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  r.$3,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: active
                                        ? qurb.accent
                                        : qurb.textFaint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? qurb.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: active
                                    ? qurb.accent
                                    : qurb.borderStrong,
                                width: 1.5,
                              ),
                            ),
                            child: active
                                ? const Center(
                                    child: QurbIconWidget(
                                      QIcon.check,
                                      size: 12,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: qurb.danger),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (_reason == null || _busy) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qurb.danger,
                    foregroundColor: const Color(0xFFFFFFFF),
                    disabledBackgroundColor: qurb.surface2,
                    disabledForegroundColor: qurb.textFaint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
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
                      : Text(t.report_submit),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: qurb.textDim,
                ),
                child: Text(t.common_cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

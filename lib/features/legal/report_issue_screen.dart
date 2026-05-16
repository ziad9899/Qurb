import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_back_button.dart';
import '../../l10n/generated/app_localizations.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final body = _body.text.trim();
    if (body.length < 3) {
      setState(() => _error = t.report_issue_err_empty);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final locale = Localizations.localeOf(context).languageCode;
      await ref.read(supabaseClientProvider).rpc(
        'submit_feedback',
        params: {
          'p_subject': _subject.text.trim(),
          'p_body': body,
          'p_locale': locale,
          'p_app_version': '0.1.0',
        },
      );
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.report_issue_success)),
        );
        Navigator.maybePop(context);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() => _error = t.report_issue_err_generic);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          _Header(title: t.report_issue_title),
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                20, 16, 20, 16 + media.padding.bottom,
              ),
              children: [
                Text(
                  t.report_issue_subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: qurb.textDim,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                _Label(text: t.report_issue_subject_label),
                _Field(
                  controller: _subject,
                  hint: t.report_issue_subject_hint,
                ),
                const SizedBox(height: 14),
                _Label(text: t.report_issue_body_label),
                _Field(
                  controller: _body,
                  hint: t.report_issue_body_hint,
                  minLines: 5,
                  maxLines: 10,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 12, color: qurb.danger),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: qurb.accent,
                      foregroundColor: const Color(0xFFFFFFFF),
                      disabledBackgroundColor: qurb.surface2,
                      disabledForegroundColor: qurb.textFaint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
                        : Text(t.report_issue_submit),
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

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: qurb.textFaint,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.minLines,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String hint;
  final int? minLines;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14, color: qurb.text, height: 1.6),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: qurb.textFaint),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    return Container(
      padding:
          EdgeInsetsDirectional.fromSTEB(8, media.padding.top + 6, 8, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: qurb.border, width: 0.5)),
      ),
      child: Row(
        children: [
          const QurbBackButton(),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: qurb.text,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

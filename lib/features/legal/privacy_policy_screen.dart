import 'package:flutter/material.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_back_button.dart';
import '../../l10n/generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final sections = <(String, String)>[
      (t.privacy_section_identity_h, t.privacy_section_identity_b),
      (t.privacy_section_location_h, t.privacy_section_location_b),
      (t.privacy_section_content_h, t.privacy_section_content_b),
      (t.privacy_section_moderation_h, t.privacy_section_moderation_b),
      (t.privacy_section_contact_h, t.privacy_section_contact_b),
    ];
    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          _Header(title: t.privacy_title),
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                20, 14, 20, 20 + media.padding.bottom,
              ),
              children: [
                Text(
                  t.privacy_intro,
                  style: TextStyle(
                    fontSize: 14,
                    color: qurb.textDim,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                for (final s in sections) ...[
                  Text(
                    s.$1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: qurb.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.$2,
                    style: TextStyle(
                      fontSize: 13,
                      color: qurb.textDim,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ],
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

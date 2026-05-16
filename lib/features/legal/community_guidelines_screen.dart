import 'package:flutter/material.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../l10n/generated/app_localizations.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          _Header(title: t.community_title),
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                20, 14, 20, 20 + media.padding.bottom,
              ),
              children: [
                Text(
                  t.community_intro,
                  style: TextStyle(
                    fontSize: 14,
                    color: qurb.textDim,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                _Section(
                  title: t.community_do_h,
                  bullets: [t.community_do_1, t.community_do_2, t.community_do_3],
                  positive: true,
                ),
                const SizedBox(height: 14),
                _Section(
                  title: t.community_dont_h,
                  bullets: [
                    t.community_dont_1,
                    t.community_dont_2,
                    t.community_dont_3,
                    t.community_dont_4,
                    t.community_dont_5,
                  ],
                  positive: false,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: qurb.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: qurb.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.community_consequences_h,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: qurb.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.community_consequences_b,
                        style: TextStyle(
                          fontSize: 13,
                          color: qurb.textDim,
                          height: 1.7,
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.bullets,
    required this.positive,
  });
  final String title;
  final List<String> bullets;
  final bool positive;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final color = positive ? qurb.up : qurb.danger;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              QurbIconWidget(
                positive ? QIcon.check : QIcon.close,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: qurb.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final b in bullets)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 24, top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4, height: 4,
                    margin: const EdgeInsetsDirectional.only(top: 7),
                    decoration: BoxDecoration(
                      color: qurb.textFaint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 13,
                        color: qurb.textDim,
                        height: 1.7,
                      ),
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
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: QurbIconWidget(
                QIcon.chevron, size: 22, color: qurb.text,
              ),
            ),
          ),
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

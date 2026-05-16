import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import 'qurb_icon.dart';

/// Back chevron used in every screen header. Wraps the gesture in
/// `Semantics(button: true, label: …)` so VoiceOver / TalkBack announce
/// it as a real button and Apple's accessibility audit passes.
///
/// Tap target is 44×44pt (Apple HIG minimum) — the visible chevron is 22pt
/// and we hand-pad to reach 44 so screen readers don't fight with us.
class QurbBackButton extends StatelessWidget {
  const QurbBackButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: t.common_back,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () => Navigator.maybePop(context),
        child: Container(
          width: 44, height: 44,
          alignment: Alignment.center,
          child: QurbIconWidget(
            QIcon.chevron, size: 22, color: qurb.text,
          ),
        ),
      ),
    );
  }
}

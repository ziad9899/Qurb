import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../l10n/generated/app_localizations.dart';

/// Welcome — first run, no session yet. Tap "أنشئ معرفي" to call
/// signInAnonymously(), then route to /welcome/generated for the reveal.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});
  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _generating = false;
  bool _ageConfirmed = false;
  String? _error;
  late final AnimationController _pingC = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  // Tap recognizers on the "Terms" / "Privacy" links shown above the CTA.
  // Stored on State so they're disposed once — Text.rich rebuilds every
  // frame, and recreating a recognizer per frame would leak.
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () {
      if (!mounted) return;
      context.push('/settings/terms');
    };
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () {
      if (!mounted) return;
      context.push('/settings/privacy');
    };

  @override
  void dispose() {
    _pingC.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_generating || !_ageConfirmed) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
      // Force the profile provider to refetch with the freshly-signed-in user.
      ref.invalidate(myProfileProvider);
      await ref.read(myProfileProvider.future);
      if (!mounted) return;
      context.goNamed('welcome-generated');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).compose_err_generic);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          // accent glow top-right
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    qurb.accent.withValues(alpha: 0.20),
                    qurb.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.appName,
                    style: TextStyle(
                      fontSize: 11,
                      color: qurb.accent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.welcome_title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: qurb.text,
                      height: 1.25,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.welcome_subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: qurb.textDim,
                      height: 1.7,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _placeholderDial(qurb, t),
                    ),
                  ),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: qurb.danger, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _ageGate(qurb, t),
                  const SizedBox(height: 14),
                  _primaryButton(qurb, t),
                  const SizedBox(height: 14),
                  _termsLine(qurb, t),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderDial(QurbColors qurb, AppLocalizations t) {
    return AnimatedBuilder(
      animation: _pingC,
      builder: (_, __) {
        final v = _pingC.value;
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ping ring
              Transform.scale(
                scale: 1 + 0.4 * v,
                child: Container(
                  width: 152,
                  height: 152,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: qurb.accent.withValues(alpha: 0.25 * (1 - v)),
                    ),
                  ),
                ),
              ),
              // dashed-style border (using a circle with dotted decoration sim)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: qurb.borderStrong,
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '?????',
                  style: TextStyle(
                    fontSize: 30,
                    color: qurb.textFaint,
                    letterSpacing: 4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  t.welcome_generated_subtitle,
                  style: TextStyle(fontSize: 13, color: qurb.textDim),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ageGate(QurbColors qurb, AppLocalizations t) {
    return Semantics(
      label: t.welcome_age_confirm,
      checked: _ageConfirmed,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _ageConfirmed = !_ageConfirmed),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20, height: 20,
                margin: const EdgeInsetsDirectional.only(top: 1, end: 10),
                decoration: BoxDecoration(
                  color: _ageConfirmed ? qurb.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _ageConfirmed ? qurb.accent : qurb.borderStrong,
                    width: 1.5,
                  ),
                ),
                child: _ageConfirmed
                    ? const Center(
                        child: QurbIconWidget(
                          QIcon.check,
                          size: 13,
                          color: Color(0xFF1A1300),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  t.welcome_age_confirm,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: qurb.textDim,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(QurbColors qurb, AppLocalizations t) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: (_generating || !_ageConfirmed) ? null : _generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: qurb.accent,
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: qurb.accent.withValues(alpha: 0.5),
          disabledForegroundColor: const Color(0xCCFFFFFF),
          shadowColor: qurb.accent.withValues(alpha: 0.35),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _generating
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                ),
              )
            : Text(t.welcome_cta_generate),
      ),
    );
  }

  Widget _termsLine(QurbColors qurb, AppLocalizations t) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 11,
          color: qurb.textFaint,
          height: 1.6,
        ),
        children: [
          TextSpan(text: t.welcome_terms_prefix),
          TextSpan(
            text: t.welcome_terms_link,
            recognizer: _termsTap,
            style: TextStyle(
              color: qurb.accent,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: t.welcome_terms_and),
          TextSpan(
            text: t.welcome_privacy_link,
            recognizer: _privacyTap,
            style: TextStyle(
              color: qurb.accent,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: t.welcome_terms_suffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}


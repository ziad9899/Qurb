import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/qurb_theme.dart';

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
  String? _error;
  late final AnimationController _pingC = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _pingC.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_generating) return;
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
      setState(() => _error = 'تعذّر التوليد، حاول مجدداً.');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;

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
                    'أهلاً بك في قُرب',
                    style: TextStyle(
                      fontSize: 11,
                      color: qurb.accent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'مجتمع حولك\nبدون اسم، بدون صورة.',
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
                    'نولّد لك معرفاً رقمياً واحداً يلازمك. لا بريد، لا رقم هاتف، '
                    'لا متابعون. فقط ما تشاركه مع من حولك.',
                    style: TextStyle(
                      fontSize: 14,
                      color: qurb.textDim,
                      height: 1.7,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _placeholderDial(qurb),
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
                  _primaryButton(qurb),
                  const SizedBox(height: 14),
                  _termsLine(qurb),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderDial(QurbColors qurb) {
    return AnimatedBuilder(
      animation: _pingC,
      builder: (_, __) {
        final t = _pingC.value;
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ping ring
              Transform.scale(
                scale: 1 + 0.4 * t,
                child: Container(
                  width: 152,
                  height: 152,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: qurb.accent.withValues(alpha: 0.25 * (1 - t)),
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
                  'معرفك سيظهر مرة واحدة فقط',
                  style: TextStyle(fontSize: 13, color: qurb.textDim),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _primaryButton(QurbColors qurb) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _generating ? null : _generate,
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
            : const Text('أنشئ معرفي'),
      ),
    );
  }

  Widget _termsLine(QurbColors qurb) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 11,
          color: qurb.textFaint,
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'بمتابعتك توافق على '),
          TextSpan(
            text: 'شروط الاستخدام',
            style: TextStyle(
              color: qurb.textDim,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' و'),
          TextSpan(
            text: 'الخصوصية',
            style: TextStyle(
              color: qurb.textDim,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}


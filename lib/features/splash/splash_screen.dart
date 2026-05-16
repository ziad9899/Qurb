import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/qurb_theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// Splash — matches the web ScreenSplash artboard.
///   • Aurora: accent radial top + gold radial bottom-right
///   • Wordmark "قُرب" + accent dot + tagline
///   • Three dot loader animation
///   • Version chip
/// On mount, the screen waits for the auth-state stream's first emit, then
/// routes to /home (session present) or /welcome (no session).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _minTimer;
  bool _minElapsed = false;
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    // Keep splash on screen for a minimum, regardless of how fast Supabase
    // returns — gives the animation room to breathe.
    _minTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _minElapsed = true);
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    super.dispose();
  }

  void _maybeRoute(BuildContext context) {
    if (_routed || !_minElapsed) return;
    final user = ref.read(currentUserProvider);
    _routed = true;
    if (user != null) {
      context.goNamed('home');
    } else {
      context.goNamed('welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);

    // Re-check after min time elapses + on each auth state event.
    ref.listen(authStateStreamProvider, (_, __) => _maybeRoute(context));
    if (_minElapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRoute(context));
    }

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          // accent aurora (top)
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      qurb.accent.withValues(alpha: 0.25),
                      qurb.accent.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
          ),
          // gold aurora (bottom-right)
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    qurb.gold.withValues(alpha: 0.18),
                    qurb.gold.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),
          // wordmark
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 6, bottom: 18),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: qurb.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      t.appName,
                      style: TextStyle(
                        fontSize: 76,
                        fontWeight: FontWeight.w700,
                        color: qurb.text,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  t.splash_tagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: qurb.textDim,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          // loader + version
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _DotsLoader(color: qurb.accent),
                const SizedBox(height: 18),
                Text(
                  'QURB · v0.1',
                  style: TextStyle(
                    fontSize: 11,
                    color: qurb.textFaint,
                    letterSpacing: 2,
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

/// Three pulsing dots — mirrors the qurbDot CSS keyframe.
class _DotsLoader extends StatefulWidget {
  const _DotsLoader({required this.color});
  final Color color;
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _opacityAt(double t, double phase) {
    final v = ((t + phase) % 1.0);
    // peak at v=0.5 → opacity 1, edges → 0.3
    final wave = 1 - (2 * v - 1).abs();
    return 0.3 + 0.7 * wave;
  }

  double _scaleAt(double t, double phase) {
    final v = ((t + phase) % 1.0);
    final wave = 1 - (2 * v - 1).abs();
    return 1.0 + 0.3 * wave;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++) ...[
              Transform.scale(
                scale: _scaleAt(t, i * 0.15),
                child: Opacity(
                  opacity: _opacityAt(t, i * 0.15),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 6),
            ],
          ],
        );
      },
    );
  }
}

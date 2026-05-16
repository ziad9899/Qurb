import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/id_hues.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_icon.dart';

/// Welcome — second state. Reveals the freshly-generated numeric ID inside
/// a hue-tinted gradient sphere. Matches the "WelcomeGenerated" artboard.
class WelcomeGeneratedScreen extends ConsumerWidget {
  const WelcomeGeneratedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
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
                    'تم!',
                    style: TextStyle(
                      fontSize: 11,
                      color: qurb.accent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'هذا أنت الآن.\nاحفظ معرفك.',
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
                    'سيظهر هذا الرقم بجانب كل منشور وتعليق وهمس ترسله. '
                    'هو هويتك الكاملة في قُرب.',
                    style: TextStyle(
                      fontSize: 14,
                      color: qurb.textDim,
                      height: 1.7,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: profileAsync.when(
                        loading: () => const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                        error: (_, __) => Text(
                          'تعذّر جلب معرفك.',
                          style: TextStyle(color: qurb.danger),
                        ),
                        data: (p) => p == null
                            ? Text(
                                'لا يوجد معرف بعد.',
                                style: TextStyle(color: qurb.textDim),
                              )
                            : _IdReveal(numericId: p.numericId),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: profileAsync.value == null
                          ? null
                          : () => context.goNamed('home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: qurb.accent,
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: qurb.accent.withValues(alpha: 0.35),
                        elevation: 8,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('دخول إلى المجتمع'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      // "Re-generate" means: drop session → back to welcome.
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.goNamed('welcome');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: qurb.textDim,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('أعد التوليد'),
                  ),
                  const SizedBox(height: 42),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdReveal extends StatelessWidget {
  const _IdReveal({required this.numericId});
  final int numericId;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final hue = idHueFor(numericId.toString());
    final accent = oklchToColor(0.72, 0.16, hue.h);
    final accentDeep = oklchToColor(0.45, 0.18, hue.h);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // outer ring
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
            ),
            // gradient sphere
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [accent, accentDeep],
                  stops: const [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.32),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '#$numericId',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                  letterSpacing: 1.2,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: qurb.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: qurb.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              QurbIconWidget(QIcon.shield, size: 13, color: qurb.up),
              const SizedBox(width: 6),
              Text(
                'مجهول · مشفّر · دائم',
                style: TextStyle(fontSize: 11.5, color: qurb.textDim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

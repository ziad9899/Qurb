import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_card.dart';
import '../showcase/design_showcase_screen.dart';

/// Placeholder Home for after the welcome flow. The real feed is built
/// in Phase 3. For now we show: the user's badge, a "coming soon" card,
/// and a link to the design showcase.
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final profileAsync = ref.watch(myProfileProvider);
    final idShape = ref.watch(idShapeProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'قُرب',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: qurb.text,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: qurb.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Spacer(),
                      profileAsync.maybeWhen(
                        data: (p) => p == null
                            ? const SizedBox.shrink()
                            : IdBadge(
                                id: p.numericId.toString(),
                                shape: idShape,
                              ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  QurbCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'تم تسجيل دخولك بمجهولية ✓',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: qurb.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'الـ Feed الفعلي قادم في Phase 3. هذه شاشة مؤقتة '
                          'لتأكيد أن المعرف صار حيّ ومحفوظ على جهازك.',
                          style: TextStyle(
                            fontSize: 13,
                            color: qurb.textDim,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  QurbCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DesignShowcaseScreen(),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'نظام التصميم · معاينة المكوّنات',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: qurb.text,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: qurb.textDim,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.goNamed('welcome');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: qurb.danger,
                    ),
                    child: const Text('تسجيل خروج (للاختبار)'),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.feed,
              onChange: (_) {},
              hasUnread: false,
            ),
          ),
        ],
      ),
    );
  }
}

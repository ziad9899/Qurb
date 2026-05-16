import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_icon.dart';
import '../profile/data/profile_providers.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    final shape = ref.watch(idShapeProvider);
    final blocksAsync = ref.watch(myBlocksProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, media.padding.top + 6, 8, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: qurb.border, width: 0.5),
              ),
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
                  'قائمة الحظر',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Expanded(
            child: blocksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => Center(
                child: Text(
                  'تعذّر التحميل',
                  style: TextStyle(color: qurb.danger),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: qurb.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: qurb.border, width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: QurbIconWidget(
                                QIcon.block, size: 28, color: qurb.textFaint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'لا أحد محظور',
                            style: TextStyle(
                              fontSize: 14, color: qurb.textDim,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'يمكنك حظر أي مستخدم من قائمة منشوره.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: qurb.textFaint,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    for (final b in list)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: qurb.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: qurb.border, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            IdBadge(
                              id: b.blockedNumericId.toString(),
                              shape: shape,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                await ref
                                    .read(profileRepositoryProvider)
                                    .unblockByNumericId(b.blockedNumericId);
                                ref.invalidate(myBlocksProvider);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: qurb.accent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6,
                                ),
                              ),
                              child: const Text(
                                'إلغاء الحظر',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_back_button.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import '../profile/data/profile_providers.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
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
                const QurbBackButton(),
                const Spacer(),
                Text(
                  t.blocks_header,
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
              loading: () => const SkelList(count: 3),
              error: (_, __) => QurbError(
                onRetry: () => ref.invalidate(myBlocksProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return QurbEmpty(
                    icon: QIcon.block,
                    title: t.blocks_empty_title,
                    subtitle: t.blocks_empty_subtitle,
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
                              child: Text(
                                t.blocks_unblock,
                                style: const TextStyle(
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

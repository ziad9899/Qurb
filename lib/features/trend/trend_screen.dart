import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import 'data/trend_models.dart';
import 'data/trend_providers.dart';
import 'widgets/pulse_map.dart';

class TrendScreen extends ConsumerWidget {
  const TrendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final tagsAsync = ref.watch(trendingTagsProvider);
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  18, media.padding.top + 8, 18, 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.trend_title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: qurb.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.trend_subtitle,
                          style: TextStyle(
                            fontSize: 12, color: qurb.textDim,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: qurb.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: qurb.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.trend_live,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: qurb.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: qurb.accent,
                  backgroundColor: qurb.surface,
                  onRefresh: () async {
                    ref.invalidate(trendingTagsProvider);
                    await ref.read(trendingTagsProvider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
                    children: [
                      PulseMap(colors: qurb),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          QurbIconWidget(
                            QIcon.flame, size: 17, color: qurb.gold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.trend_hottest,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: qurb.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      tagsAsync.when(
                        loading: () => const Column(
                          children: [
                            SkelRow(padding: EdgeInsets.only(bottom: 8)),
                            SkelRow(padding: EdgeInsets.only(bottom: 8)),
                            SkelRow(padding: EdgeInsets.only(bottom: 8)),
                            SkelRow(padding: EdgeInsets.only(bottom: 8)),
                          ],
                        ),
                        error: (_, __) => QurbError(
                          compact: true,
                          title: t.trend_error_title,
                          onRetry: () =>
                              ref.invalidate(trendingTagsProvider),
                        ),
                        data: (tags) {
                          if (tags.isEmpty) {
                            return QurbEmpty(
                              compact: true,
                              icon: QIcon.flame,
                              title: t.trend_empty_title,
                              subtitle: t.trend_empty_subtitle,
                            );
                          }
                          return Column(
                            children: [
                              for (var i = 0; i < tags.length; i++)
                                _TrendRow(rank: i + 1, tag: tags[i]),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.search,
              onChange: (tab) {
                switch (tab) {
                  case NavTab.feed:
                    context.go('/home');
                    break;
                  case NavTab.post:
                    context.push('/compose');
                    break;
                  case NavTab.inbox:
                    context.push('/whispers');
                    break;
                  case NavTab.search:
                    context.go('/explore');
                    break;
                  case NavTab.me:
                    context.push('/profile');
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.rank, required this.tag});
  final int rank;
  final TrendingTag tag;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final dirIcon = switch (tag.direction) {
      TrendDirection.up => QIcon.arrowUp,
      TrendDirection.down => QIcon.arrowDown,
      TrendDirection.flat => QIcon.trend,
    };
    final dirColor = switch (tag.direction) {
      TrendDirection.up => qurb.up,
      TrendDirection.down => qurb.danger,
      TrendDirection.flat => qurb.textFaint,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: qurb.textFaint,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${tag.tag}',
                  style: TextStyle(
                    fontSize: 14,
                    color: qurb.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppLocalizations.of(context)
                      .trend_row_subtitle(tag.recentCount),
                  style: TextStyle(
                    fontSize: 11,
                    color: qurb.textFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          QurbIconWidget(dirIcon, size: 15, color: dirColor),
        ],
      ),
    );
  }
}

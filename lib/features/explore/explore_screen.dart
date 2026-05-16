import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/id_hues.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/proximity_chip.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import '../feed/data/post.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import 'data/explore_models.dart';
import 'data/explore_providers.dart';

List<String> _recentSearches(AppLocalizations t) => [
      t.explore_recent_q1,
      t.explore_recent_q2,
      t.explore_recent_q3,
      t.explore_recent_q4,
      t.explore_recent_q5,
    ];

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _liveQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).state = value.trim();
      setState(() => _liveQuery = value.trim());
    });
  }

  void _runFromChip(String s) {
    _controller.text = s;
    ref.read(searchQueryProvider.notifier).state = s;
    setState(() => _liveQuery = s);
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final isSearching = _liveQuery.isNotEmpty;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.explore_title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: qurb.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: qurb.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: qurb.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          QurbIconWidget(
                            QIcon.search, size: 17, color: qurb.textDim,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: _onChanged,
                              style: TextStyle(
                                fontSize: 13.5, color: qurb.text,
                              ),
                              decoration: InputDecoration(
                                hintText: t.explore_hint,
                                hintStyle: TextStyle(
                                  fontSize: 13.5, color: qurb.textFaint,
                                ),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                _onChanged('');
                              },
                              child: QurbIconWidget(
                                QIcon.close, size: 16, color: qurb.textFaint,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isSearching
                    ? _SearchResults(query: _liveQuery)
                    : _BrowseBody(onChipTap: _runFromChip),
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
                  case NavTab.me:
                    context.push('/profile');
                    break;
                  default:
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

class _BrowseBody extends ConsumerWidget {
  const _BrowseBody({required this.onChipTap});
  final ValueChanged<String> onChipTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final communitiesAsync = ref.watch(communitiesProvider);
    final suggestedAsync = ref.watch(suggestedPostsProvider);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Text(
            t.explore_recent,
            style: TextStyle(
              fontSize: 11,
              color: qurb.textFaint,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in _recentSearches(t))
                GestureDetector(
                  onTap: () => onChipTap(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: qurb.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: qurb.border, width: 0.5),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: qurb.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Row(
            children: [
              Text(
                t.explore_communities,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: qurb.text,
                ),
              ),
              const Spacer(),
              Text(
                t.explore_view_all,
                style: TextStyle(
                  fontSize: 11,
                  color: qurb.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        communitiesAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.25,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: qurb.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                padding: const EdgeInsets.all(14),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Skel(width: 36, height: 36, radius: 10),
                    SizedBox(height: 10),
                    Skel(width: 90, height: 12),
                    SizedBox(height: 6),
                    Skel(width: 60, height: 10),
                  ],
                ),
              ),
            ),
          ),
          error: (_, __) => QurbError(
            compact: true,
            title: t.explore_communities_error_title,
            onRetry: () => ref.invalidate(communitiesProvider),
          ),
          data: (list) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.25,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => _CommunityCard(c: list[i]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Text(
            t.explore_suggested,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: qurb.text,
            ),
          ),
        ),
        suggestedAsync.maybeWhen(
          data: (posts) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (final p in posts.take(2))
                  _SuggestedCard(post: p),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.c});
  final Community c;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final hueColor = oklchToColor(0.72, 0.16, c.hue.toDouble());
    final hueSoft = oklchToColor(0.72, 0.16, c.hue.toDouble(), 0.18);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: hueSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: hueColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            c.name,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: qurb.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: qurb.textFaint),
          ),
          const Spacer(),
          Text(
            AppLocalizations.of(context)
                .explore_members_count(_arabicNumber(c.members)),
            style: TextStyle(
              fontSize: 10.5,
              color: qurb.textDim,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _arabicNumber(int n) {
    if (n >= 1000) {
      final k = (n / 1000).toStringAsFixed(1);
      return '${k}k';
    }
    return n.toString();
  }
}

class _SuggestedCard extends ConsumerWidget {
  const _SuggestedCard({required this.post});
  final Post post;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: qurb.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: qurb.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IdBadge(
                  id: post.authorNumericId.toString(),
                  shape: shape,
                  size: IdBadgeSize.sm,
                ),
                const SizedBox(width: 7),
                ProximityChip(
                  kind: post.proximity,
                  size: ProximityChipSize.xs,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5, color: qurb.text, height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final t = AppLocalizations.of(context);
    return resultsAsync.when(
      loading: () => const SkelList(
        count: 4,
        padding: EdgeInsets.fromLTRB(18, 6, 18, 110),
      ),
      error: (_, __) => QurbError(
        title: t.explore_search_error_title,
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return QurbEmpty(
            icon: QIcon.search,
            title: t.explore_search_empty_title(query),
            subtitle: t.explore_search_empty_subtitle,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
          itemCount: posts.length,
          itemBuilder: (_, i) => _SuggestedCard(post: posts[i]),
        );
      },
    );
  }
}

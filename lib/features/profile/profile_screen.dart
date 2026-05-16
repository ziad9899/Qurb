import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/profile.dart';
import '../../core/theme/id_hues.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/proximity_chip.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import '../feed/data/post.dart';
import 'data/profile_models.dart';
import 'data/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final profileAsync = ref.watch(myProfileProvider);
    final statsAsync = ref.watch(myStatsProvider);
    final tab = ref.watch(profileTabProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: qurb.accent,
                    backgroundColor: qurb.surface,
                    onRefresh: () async {
                      ref.invalidate(myStatsProvider);
                      ref.invalidate(myPostsProvider);
                      ref.invalidate(myCommentsProvider);
                      ref.invalidate(myBookmarksProvider);
                      await ref.read(myStatsProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      children: [
                        profileAsync.maybeWhen(
                          data: (p) => p == null
                              ? const SizedBox.shrink()
                              : _Hero(profile: p),
                          orElse: () => const _HeroSkeleton(),
                        ),
                        const SizedBox(height: 4),
                        statsAsync.maybeWhen(
                          data: (s) => _StatsRow(stats: s),
                          orElse: () => const SizedBox(height: 80),
                        ),
                        _TabsBar(
                          active: tab,
                          onChange: (t) =>
                              ref.read(profileTabProvider.notifier).state = t,
                        ),
                        const SizedBox(height: 6),
                        _TabBody(tab: tab),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.me,
              onChange: (tab) {
                switch (tab) {
                  case NavTab.feed:
                    context.go('/home');
                    break;
                  case NavTab.search:
                    context.push('/explore');
                    break;
                  case NavTab.post:
                    context.push('/compose');
                    break;
                  case NavTab.inbox:
                    context.push('/whispers');
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

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: Row(
        children: [
          const SizedBox(width: 36),
          const Spacer(),
          Text(
            t.profile_header,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: qurb.text,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => GoRouter.of(context).push('/settings'),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: qurb.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: qurb.border, width: 0.5),
              ),
              child: Center(
                child: QurbIconWidget(
                  QIcon.more, size: 18, color: qurb.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.profile});
  final Profile profile;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final hue = idHueFor(profile.numericId.toString());
    final accentBright = oklchToColor(0.78, 0.18, hue.h);
    final accentDeep = oklchToColor(0.48, 0.16, hue.h);
    final accentSoft = oklchToColor(0.72, 0.16, hue.h, 0.18);

    return Stack(
      children: [
        // radial halo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1.4),
                radius: 1.2,
                colors: [accentSoft, qurb.bg.withValues(alpha: 0)],
                stops: const [0.0, 0.65],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Column(
            children: [
              Container(
                width: 92, height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [accentBright, accentDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentBright.withValues(alpha: 0.4),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${profile.numericId}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                    letterSpacing: 0.8,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                t.profile_id_caption,
                style: TextStyle(
                  fontSize: 11,
                  color: qurb.textFaint,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: qurb.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: qurb.up, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.profile_member_since(_monthLabel(context, profile.createdAt)),
                      style: TextStyle(
                        fontSize: 12, color: qurb.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Uses the current Localizations locale so months render in the user's
  // chosen language (intl.DateFormat handles both ar/en formatting).
  static String _monthLabel(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMM(locale).format(dt);
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      child: Column(
        children: [
          Container(
            width: 92, height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: qurb.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final ProfileStats stats;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final items = <(String, String, Color)>[
      (stats.postsCount.toString(), t.profile_stat_posts, qurb.text),
      (stats.karmaShort, t.profile_stat_karma, qurb.accent),
      (stats.bookmarksCount.toString(), t.profile_stat_bookmarks, qurb.text),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: qurb.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: items[i].$3,
                        fontFeatures:
                            const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 11, color: qurb.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.active, required this.onChange});
  final ProfileTab active;
  final ValueChanged<ProfileTab> onChange;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final labels = {
      ProfileTab.posts: t.profile_tab_posts,
      ProfileTab.comments: t.profile_tab_comments,
      ProfileTab.bookmarks: t.profile_tab_bookmarks,
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: qurb.border, width: 0.5)),
      ),
      child: Row(
        children: [
          for (final entry in labels.entries) ...[
            GestureDetector(
              onTap: () => onChange(entry.key),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                margin: const EdgeInsets.only(left: 18),
                decoration: BoxDecoration(
                  border: entry.key == active
                      ? Border(
                          bottom: BorderSide(color: qurb.accent, width: 2),
                        )
                      : null,
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: entry.key == active
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: entry.key == active ? qurb.text : qurb.textFaint,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabBody extends ConsumerWidget {
  const _TabBody({required this.tab});
  final ProfileTab tab;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    switch (tab) {
      case ProfileTab.posts:
        return _PostsList(
          provider: myPostsProvider,
          emptyIcon: QIcon.compass,
          emptyTitle: t.profile_empty_posts_title,
          emptySubtitle: t.profile_empty_posts_subtitle,
        );
      case ProfileTab.bookmarks:
        return _PostsList(
          provider: myBookmarksProvider,
          emptyIcon: QIcon.pin,
          emptyTitle: t.profile_empty_bookmarks_title,
          emptySubtitle: t.profile_empty_bookmarks_subtitle,
        );
      case ProfileTab.comments:
        final async = ref.watch(myCommentsProvider);
        return _CommentsList(async: async);
    }
  }
}

class _PostsList extends ConsumerWidget {
  const _PostsList({
    required this.provider,
    this.emptyIcon = QIcon.compass,
    required this.emptyTitle,
    this.emptySubtitle,
  });
  final AutoDisposeFutureProvider<List<Post>> provider;
  final QIcon emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(14, 6, 14, 0),
        child: Column(
          children: [SkelCard(), SkelCard(), SkelCard()],
        ),
      ),
      error: (_, __) => QurbError(
        compact: true,
        onRetry: () => ref.invalidate(provider),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return QurbEmpty(
            compact: true,
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              const SizedBox(height: 6),
              for (final p in posts) _CompactPostRow(post: p),
            ],
          ),
        );
      },
    );
  }
}

class _CompactPostRow extends StatelessWidget {
  const _CompactPostRow({required this.post});
  final Post post;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/post/${post.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                ProximityChip(
                  kind: post.proximity, size: ProximityChipSize.xs,
                ),
                const SizedBox(width: 7),
                Text(
                  relMinutes(post.minutesAgo),
                  style: TextStyle(
                    fontSize: 10, color: qurb.textFaint,
                  ),
                ),
                const Spacer(),
                Text(
                  t.profile_post_meta(post.score, post.commentsCount),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: qurb.textFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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

class _CommentsList extends ConsumerWidget {
  const _CommentsList({required this.async});
  final AsyncValue<List<MyComment>> async;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(14, 6, 14, 0),
        child: Column(
          children: [SkelCard(), SkelCard(), SkelCard()],
        ),
      ),
      error: (_, __) => QurbError(
        compact: true,
        onRetry: () => ref.invalidate(myCommentsProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          final t = AppLocalizations.of(context);
          return QurbEmpty(
            compact: true,
            icon: QIcon.reply,
            title: t.profile_empty_comments_title,
            subtitle: t.profile_empty_comments_subtitle,
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
          child: Column(
            children: [
              for (final c in list)
                GestureDetector(
                  onTap: () =>
                      GoRouter.of(context).push('/post/${c.postId}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: qurb.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: qurb.border, width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          c.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: qurb.text,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (c.postPreview != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: qurb.surface2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                QurbIconWidget(
                                  QIcon.reply,
                                  size: 11,
                                  color: qurb.textFaint,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    c.postPreview!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: qurb.textDim,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              relMinutes(
                                DateTime.now()
                                    .difference(c.createdAt)
                                    .inMinutes,
                              ),
                              style: TextStyle(
                                fontSize: 10, color: qurb.textFaint,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${c.score}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: c.score >= 0
                                    ? qurb.up
                                    : qurb.danger,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

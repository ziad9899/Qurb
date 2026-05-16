import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/location/location_providers.dart';
import '../../core/location/location_repository.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import '../notifications/data/notifications_providers.dart';
import '../whispers/data/whispers_providers.dart';
import 'data/feed_providers.dart';
import 'data/post_repository.dart';
import 'widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off location acquisition the moment we land on the feed, but
    // only if we haven't already resolved it this session — repeated
    // prompts are annoying. The provider returns null until acquire()
    // completes, at which point feedPostsProvider rebuilds with the
    // coordinates and re-issues posts_near.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(myLocationProvider) == null) {
        ref.read(myLocationProvider.notifier).acquire();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final filter = ref.watch(feedFilterProvider);
    final postsAsync = ref.watch(feedPostsProvider);
    final votesAsync = ref.watch(feedVotesProvider);
    final pendingRequests = ref.watch(incomingWhispersProvider);
    final hasUnread = pendingRequests.maybeWhen(
      data: (r) => r.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _Header(filter: filter),
              Expanded(
                child: RefreshIndicator(
                  color: qurb.accent,
                  backgroundColor: qurb.surface,
                  onRefresh: () async {
                    ref.invalidate(feedPostsProvider);
                    await ref.read(feedPostsProvider.future);
                  },
                  child: postsAsync.when(
                    loading: () => const _FeedSkeleton(),
                    error: (e, _) => _FeedError(error: e.toString()),
                    data: (result) {
                      if (result is FeedLocationNeeded) {
                        return _FeedLocationNeeded(
                          status: ref.watch(myLocationProvider),
                          onEnable: () async {
                            await ref
                                .read(myLocationProvider.notifier)
                                .acquire();
                            ref.invalidate(feedPostsProvider);
                          },
                        );
                      }
                      final posts = (result as FeedReady).posts;
                      if (posts.isEmpty) {
                        return _FeedEmpty();
                      }
                      final votes = votesAsync.maybeWhen(
                        data: (m) => m,
                        orElse: () => const <String, int>{},
                      );
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(12, 12, 12, 100),
                        itemCount: posts.length + 1,
                        itemBuilder: (_, i) {
                          if (i == posts.length) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  t.feed_end_marker,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: qurb.textFaint,
                                  ),
                                ),
                              ),
                            );
                          }
                          final p = posts[i];
                          final v = votes['post:${p.id}'];
                          return PostCard(
                            post: p,
                            myVote: v,
                            onOpen: () => context.push('/post/${p.id}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.feed,
              onChange: (tab) {
                switch (tab) {
                  case NavTab.post:
                    context.push('/compose');
                    break;
                  case NavTab.inbox:
                    context.push('/whispers');
                    break;
                  case NavTab.search:
                    context.push('/explore');
                    break;
                  case NavTab.me:
                    context.push('/profile');
                    break;
                  default:
                    break;
                }
              },
              hasUnread: hasUnread,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.filter});
  final FeedFilter filter;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final unreadNotifs = ref.watch(notificationsUnreadCountProvider);
    final hasUnreadNotifs = unreadNotifs.maybeWhen(
      data: (n) => n > 0,
      orElse: () => false,
    );
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(top: media.padding.top),
          decoration: BoxDecoration(
            color: qurb.glass,
            border: Border(
              bottom: BorderSide(color: qurb.border, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(18, 6, 18, 10),
                child: Row(
                  children: [
                    Text(
                      t.feed_appName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: qurb.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: qurb.accent, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.feed_location_riyadh,
                      style: TextStyle(
                        fontSize: 11, color: qurb.textDim,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/trend'),
                      child: Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: qurb.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: qurb.border, width: 0.5),
                        ),
                        child: Center(
                          child: QurbIconWidget(
                            QIcon.flame, size: 17, color: qurb.gold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: qurb.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: qurb.border, width: 0.5),
                            ),
                            child: Center(
                              child: QurbIconWidget(
                                QIcon.bell, size: 18, color: qurb.text,
                              ),
                            ),
                          ),
                          if (hasUnreadNotifs)
                            Positioned(
                              top: -2, left: -2,
                              child: Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color: qurb.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: qurb.bg, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in [
                        (FeedFilter.near, t.feed_filter_near),
                        (FeedFilter.block, t.feed_filter_block),
                        (FeedFilter.city, t.feed_filter_city),
                        (FeedFilter.all, t.feed_filter_all),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GestureDetector(
                            onTap: () => ref
                                .read(feedFilterProvider.notifier)
                                .state = f.$1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: filter == f.$1
                                    ? qurb.text
                                    : qurb.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: filter == f.$1
                                    ? null
                                    : Border.all(
                                        color: qurb.border, width: 0.5,
                                      ),
                              ),
                              child: Text(
                                f.$2,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: filter == f.$1
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: filter == f.$1
                                      ? qurb.bg
                                      : qurb.textDim,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: qurb.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: qurb.border, width: 0.5),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Skel(width: 70, height: 18, radius: 999),
                    SizedBox(width: 8),
                    Skel(width: 80, height: 18, radius: 999),
                  ],
                ),
                SizedBox(height: 12),
                Skel(width: double.infinity, height: 14),
                SizedBox(height: 8),
                Skel(width: 240, height: 14),
                SizedBox(height: 14),
                Skel(width: 110, height: 26, radius: 14),
              ],
            ),
          ),
      ],
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.error});
  final String error;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.feed_error_title,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: qurb.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: qurb.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedLocationNeeded extends ConsumerWidget {
  const _FeedLocationNeeded({required this.status, required this.onEnable});
  final LocationResult? status;
  final Future<void> Function() onEnable;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acquiring = ref.watch(locationAcquiringProvider);
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final subtitle = switch (status) {
      LocationDenied(permanent: true) => t.feed_location_denied_subtitle,
      LocationServiceOff() => t.feed_location_serviceOff_subtitle,
      _ => t.feed_location_needed_subtitle,
    };
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: qurb.accentSoft, shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: QurbIconWidget(
                      QIcon.pin, size: 28, color: qurb.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t.feed_location_needed_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12, color: qurb.textDim, height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  // Disabling onPressed while acquiring closes the
                  // double-tap race (two concurrent OS prompts) at
                  // the UI layer; the controller already guards
                  // against it at the model layer.
                  onPressed: acquiring ? null : onEnable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qurb.accent,
                    foregroundColor: const Color(0xFFFFFFFF),
                    disabledBackgroundColor:
                        qurb.accent.withValues(alpha: 0.5),
                    disabledForegroundColor:
                        const Color(0xCCFFFFFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: acquiring
                      ? const SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFFFFF),
                            ),
                          ),
                        )
                      : Text(t.feed_location_needed_cta),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: qurb.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: QurbIconWidget(
                      QIcon.compass, size: 28, color: qurb.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t.feed_empty_title,
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.feed_empty_subtitle,
                  style: TextStyle(fontSize: 12, color: qurb.textDim),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

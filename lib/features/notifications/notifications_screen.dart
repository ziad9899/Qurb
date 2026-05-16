import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import 'data/notifications_models.dart';
import 'data/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final notifsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _Header(
                onMarkAll: () async {
                  await ref
                      .read(notificationsRepositoryProvider)
                      .markAllRead();
                  ref.invalidate(notificationsListProvider);
                  ref.invalidate(notificationsUnreadCountProvider);
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  color: qurb.accent,
                  backgroundColor: qurb.surface,
                  onRefresh: () async {
                    ref.invalidate(notificationsListProvider);
                    await ref.read(notificationsListProvider.future);
                  },
                  child: notifsAsync.when(
                    loading: () => const SkelList(
                      count: 6,
                      padding: EdgeInsets.fromLTRB(14, 12, 14, 100),
                    ),
                    error: (e, _) => QurbError(
                      title: t.notifs_error_title,
                      onRetry: () =>
                          ref.invalidate(notificationsListProvider),
                    ),
                    data: (notifs) {
                      if (notifs.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            QurbEmpty(
                              icon: QIcon.bell,
                              title: t.notifs_empty_title,
                              subtitle: t.notifs_empty_subtitle,
                            ),
                          ],
                        );
                      }
                      return _GroupedList(notifs: notifs);
                    },
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.inbox,
              onChange: (tab) {
                switch (tab) {
                  case NavTab.feed:
                    context.go('/home');
                    break;
                  case NavTab.post:
                    context.push('/compose');
                    break;
                  case NavTab.inbox:
                    context.go('/whispers');
                    break;
                  case NavTab.search:
                    context.push('/explore');
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

class _Header extends StatelessWidget {
  const _Header({required this.onMarkAll});
  final VoidCallback onMarkAll;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            18, media.padding.top + 8, 18, 14,
          ),
          decoration: BoxDecoration(
            color: qurb.glass,
            border: Border(
              bottom: BorderSide(color: qurb.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Text(
                t.notifs_title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: qurb.text,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onMarkAll,
                child: Text(
                  t.notifs_mark_all_read,
                  style: TextStyle(
                    fontSize: 12,
                    color: qurb.accent,
                    fontWeight: FontWeight.w500,
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

class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.notifs});
  final List<NotificationItem> notifs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    // Group preserving the (already-descending) chronological order.
    final groups = <NotificationBucket, List<NotificationItem>>{};
    for (final n in notifs) {
      groups.putIfAbsent(bucketOf(n.createdAt), () => []).add(n);
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      children: [
        for (final entry in groups.entries) ...[
          _GroupHeader(label: bucketLabel(entry.key, t)),
          for (final n in entry.value)
            _NotifRow(notif: n, onTap: () => _onTapNotif(context, ref, n)),
        ],
      ],
    );
  }

  void _onTapNotif(BuildContext context, WidgetRef ref, NotificationItem n) {
    ref.read(notificationsRepositoryProvider).markRead(n.id);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(notificationsUnreadCountProvider);
    switch (n.kind) {
      case NotificationKind.reply:
      case NotificationKind.replyToComment:
        if (n.targetType == 'comment' && n.targetId != null) {
          // We don't know the post id without an extra fetch; jumping to
          // /home is fine for MVP.
          context.push('/home');
        }
        break;
      case NotificationKind.whisperRequest:
        context.push('/whispers');
        break;
      default:
        break;
    }
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: qurb.textFaint,
        ),
      ),
    );
  }
}

class _NotifRow extends ConsumerWidget {
  const _NotifRow({required this.notif, required this.onTap});
  final NotificationItem notif;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    final (icon, iconColor) = _iconFor(notif.kind, qurb);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        color: notif.isUnread
            ? qurb.accentSoft.withValues(alpha: 0.35)
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: qurb.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: qurb.border, width: 0.5),
              ),
              child: Center(
                child: QurbIconWidget(icon, size: 17, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (notif.actorNumericId != null)
                        IdBadge(
                          id: notif.actorNumericId.toString(),
                          shape: shape,
                          size: IdBadgeSize.sm,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        relMinutes(notif.minutesAgo),
                        style: TextStyle(
                          fontSize: 10.5, color: qurb.textFaint,
                        ),
                      ),
                      const Spacer(),
                      if (notif.isUnread)
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: qurb.accent, shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _humanize(context, notif),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: qurb.text,
                      height: 1.55,
                      fontWeight: notif.isUnread
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (QIcon, Color) _iconFor(NotificationKind k, dynamic qurb) {
    final q = qurb;
    switch (k) {
      case NotificationKind.reply:
      case NotificationKind.replyToComment:
        return (QIcon.reply, q.text as Color);
      case NotificationKind.voteMilestone:
        return (QIcon.arrowUp, q.up as Color);
      case NotificationKind.whisperRequest:
        return (QIcon.whisper, q.accent as Color);
      case NotificationKind.pulse:
        return (QIcon.pulse, q.gold as Color);
      case NotificationKind.tagTrending:
        return (QIcon.flame, q.gold as Color);
    }
  }

  String _humanize(BuildContext context, NotificationItem n) {
    final t = AppLocalizations.of(context);
    switch (n.kind) {
      case NotificationKind.reply:
        return t.notifs_human_reply_to_post(n.body);
      case NotificationKind.replyToComment:
        return t.notifs_human_reply_to_comment(n.body);
      case NotificationKind.voteMilestone:
        return t.notifs_human_vote_milestone(n.body.isEmpty ? '+1' : n.body);
      case NotificationKind.whisperRequest:
        return n.body.isEmpty
            ? t.notifs_human_whisper_request_default
            : n.body;
      case NotificationKind.pulse:
        return n.body;
      case NotificationKind.tagTrending:
        return t.notifs_human_tag_trending(n.body);
    }
  }
}


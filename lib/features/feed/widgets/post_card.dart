import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/qurb_theme.dart';
import '../../../core/util/relative_time.dart';
import '../../../core/widgets/id_badge.dart';
import '../../../core/widgets/proximity_chip.dart';
import '../../../core/widgets/qurb_card.dart';
import '../../../core/widgets/qurb_icon.dart';
import '../../../core/widgets/vote_pill.dart';
import '../../profile/data/profile_providers.dart';
import '../../showcase/design_showcase_screen.dart' show idShapeProvider;
import '../data/feed_providers.dart';
import '../data/post.dart';
import '../report_sheet.dart';

class PostCard extends ConsumerStatefulWidget {
  const PostCard({super.key, required this.post, this.onOpen, this.myVote});
  final Post post;
  final VoidCallback? onOpen;

  /// initial vote value from `feedVotesProvider` (1, -1, or null).
  final int? myVote;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.last = false,
  });
  final QIcon icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: qurb.border, width: 0.5)),
        ),
        child: Row(
          children: [
            QurbIconWidget(icon, size: 18, color: color ?? qurb.text),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color ?? qurb.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCardState extends ConsumerState<PostCard> {
  VoteValue? _localVote;
  late int _baselineScore;
  bool _voteBusy = false;

  @override
  void initState() {
    super.initState();
    _baselineScore = widget.post.score;
    _localVote = switch (widget.myVote) {
      1 => VoteValue.up,
      -1 => VoteValue.down,
      _ => null,
    };
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: qurb.bgElev,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: qurb.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                _MenuItem(
                  icon: QIcon.pin,
                  label: 'حفظ المنشور',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ref
                        .read(profileRepositoryProvider)
                        .toggleBookmark(widget.post.id);
                    ref.invalidate(myBookmarksProvider);
                  },
                ),
                _MenuItem(
                  icon: QIcon.flag,
                  label: 'الإبلاغ عن المنشور',
                  color: qurb.text,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ReportSheet.show(
                      context,
                      targetType: 'post',
                      targetId: widget.post.id,
                    );
                  },
                ),
                _MenuItem(
                  icon: QIcon.block,
                  label: 'حظر الناشر',
                  color: qurb.danger,
                  last: true,
                  onTap: () async {
                    Navigator.of(context).pop();
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: qurb.surface,
                        title: Text(
                          'حظر #${widget.post.authorNumericId}؟',
                          style: TextStyle(color: qurb.text),
                        ),
                        content: Text(
                          'لن ترى منشوراته أو تعليقاته بعد الآن.',
                          style: TextStyle(
                            color: qurb.textDim, height: 1.6,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(color: qurb.textDim),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            child: Text(
                              'حظر',
                              style: TextStyle(color: qurb.danger),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref
                          .read(profileRepositoryProvider)
                          .blockUserByPost(widget.post.id);
                      ref.invalidate(feedPostsProvider);
                      ref.invalidate(myBlocksProvider);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _vote(VoteValue? v) async {
    if (_voteBusy) return;
    // optimistic update
    setState(() {
      _localVote = v;
      _voteBusy = true;
    });
    final wire = switch (v) {
      VoteValue.up => 1,
      VoteValue.down => -1,
      _ => 0,
    };
    try {
      final newScore = await ref.read(voteRepositoryProvider).castVote(
            targetType: 'post',
            targetId: widget.post.id,
            value: wire,
          );
      if (mounted) setState(() => _baselineScore = newScore - wire);
    } catch (_) {
      // rollback on failure
      if (mounted) {
        setState(() => _localVote = switch (widget.myVote) {
              1 => VoteValue.up,
              -1 => VoteValue.down,
              _ => null,
            });
      }
    } finally {
      if (mounted) setState(() => _voteBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    final p = widget.post;

    return QurbCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      onTap: widget.onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IdBadge(id: p.authorNumericId.toString(), shape: shape),
              const SizedBox(width: 8),
              ProximityChip(kind: p.proximity),
              const SizedBox(width: 6),
              Text('·', style: TextStyle(fontSize: 11, color: qurb.textFaint)),
              const SizedBox(width: 6),
              Text(
                relMinutes(p.minutesAgo),
                style: TextStyle(fontSize: 11, color: qurb.textFaint),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showMoreMenu(context, ref),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: QurbIconWidget(
                    QIcon.more, size: 18, color: qurb.textFaint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            p.body,
            style: TextStyle(
              fontSize: 14.5,
              color: qurb.text,
              height: 1.75,
            ),
          ),
          if (p.hasImage) ...[
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    qurb.gold.withValues(alpha: 0.45),
                    qurb.accent.withValues(alpha: 0.40),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              VotePill(
                score: _baselineScore,
                vote: _localVote,
                onVote: _vote,
              ),
              const SizedBox(width: 10),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: qurb.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    QurbIconWidget(QIcon.reply, size: 13, color: qurb.textDim),
                    const SizedBox(width: 5),
                    Text(
                      '${p.commentsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: qurb.textDim,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (p.tag != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: qurb.goldSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#${p.tag}',
                    style: TextStyle(
                      fontSize: 10,
                      color: qurb.gold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

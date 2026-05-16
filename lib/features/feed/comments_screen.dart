import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/proximity_chip.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/vote_pill.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import '../whispers/whisper_request_sheet.dart';
import 'data/feed_providers.dart';
import 'data/post.dart';
import 'data/post_comment.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.postId});
  final int postId;
  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(postRepositoryProvider).createComment(
            postId: widget.postId,
            body: body,
          );
      _composer.clear();
      ref.invalidate(commentsProvider(widget.postId));
    } catch (_) {
      // swallow — UI doesn't surface errors here in MVP
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    final shape = ref.watch(idShapeProvider);
    final repo = ref.watch(postRepositoryProvider);
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final commentVotes = ref.watch(commentVotesProvider(widget.postId));

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _CommentsHeader(),
              Expanded(
                child: FutureBuilder<Post?>(
                  future: repo.fetchPost(widget.postId),
                  builder: (context, snap) {
                    final post = snap.data;
                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        18, 14, 18, 130 + media.padding.bottom,
                      ),
                      children: [
                        if (post != null) _PostHero(post: post, shape: shape),
                        const SizedBox(height: 6),
                        ...commentsAsync.when(
                          loading: () => [
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ],
                          error: (e, _) => [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'تعذّر تحميل التعليقات',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: qurb.danger),
                              ),
                            ),
                          ],
                          data: (comments) => [
                            for (final c in comments)
                              _CommentRow(
                                comment: c,
                                votes: commentVotes.value ?? const {},
                                shape: shape,
                                onVote: (cid, v) async {
                                  final wire = switch (v) {
                                    VoteValue.up => 1,
                                    VoteValue.down => -1,
                                    _ => 0,
                                  };
                                  await ref
                                      .read(voteRepositoryProvider)
                                      .castVote(
                                        targetType: 'comment',
                                        targetId: cid,
                                        value: wire,
                                      );
                                  ref.invalidate(
                                      commentVotesProvider(widget.postId));
                                },
                              ),
                            if (comments.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: Text(
                                    'لا تعليقات بعد · كن الأول',
                                    style: TextStyle(
                                      color: qurb.textFaint, fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          // Compose bar
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    14, 12, 14, 16 + media.padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: qurb.glass,
                    border: Border(
                      top: BorderSide(color: qurb.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: qurb.surface,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: qurb.border, width: 0.5),
                          ),
                          child: TextField(
                            controller: _composer,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'اكتب ردك...',
                              hintStyle: TextStyle(
                                fontSize: 13, color: qurb.textFaint,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13, color: qurb.text,
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: qurb.accent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: qurb.accent.withValues(alpha: 0.33),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _sending
                              ? const Padding(
                                  padding: EdgeInsets.all(11),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFFFFFF)),
                                  ),
                                )
                              : Transform.flip(
                                  flipX: true,
                                  child: const Center(
                                    child: QurbIconWidget(
                                      QIcon.send,
                                      size: 17,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(8, media.padding.top + 6, 8, 12),
      decoration: BoxDecoration(
        color: qurb.glass,
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
            'منشور',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: qurb.text,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: QurbIconWidget(
              QIcon.more, size: 20, color: qurb.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostHero extends ConsumerStatefulWidget {
  const _PostHero({required this.post, required this.shape});
  final Post post;
  final IdBadgeShape shape;
  @override
  ConsumerState<_PostHero> createState() => _PostHeroState();
}

class _PostHeroState extends ConsumerState<_PostHero> {
  VoteValue? _vote;
  late int _baselineScore = widget.post.score;

  Future<void> _onVote(VoteValue? v) async {
    setState(() => _vote = v);
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
    } catch (_) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final p = widget.post;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IdBadge(
              id: p.authorNumericId.toString(),
              shape: widget.shape,
              size: IdBadgeSize.md,
            ),
            const SizedBox(width: 8),
            ProximityChip(kind: p.proximity),
            const SizedBox(width: 6),
            Text('·',
                style: TextStyle(fontSize: 11, color: qurb.textFaint)),
            const SizedBox(width: 6),
            Text(
              relMinutes(p.minutesAgo),
              style: TextStyle(fontSize: 11, color: qurb.textFaint),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          p.body,
          style: TextStyle(
            fontSize: 17, color: qurb.text, height: 1.75,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            VotePill(
              score: _baselineScore,
              vote: _vote,
              onVote: _onVote,
              size: VotePillSize.lg,
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => WhisperRequestSheet.show(
                context,
                postId: p.id,
                recipientNumericId: p.authorNumericId,
                postPreview: p.body,
              ),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: qurb.surface2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    QurbIconWidget(
                      QIcon.whisper, size: 15, color: qurb.text,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'همس للناشر',
                      style: TextStyle(
                        fontSize: 13, color: qurb.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${p.commentsCount} رد',
              style: TextStyle(fontSize: 11, color: qurb.textFaint),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 0.5, color: qurb.border),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _CommentRow extends ConsumerStatefulWidget {
  const _CommentRow({
    required this.comment,
    required this.votes,
    required this.shape,
    required this.onVote,
    this.depth = 0,
  });
  final PostComment comment;
  final Map<String, int> votes;
  final IdBadgeShape shape;
  final Future<void> Function(int commentId, VoteValue? value) onVote;
  final int depth;
  @override
  ConsumerState<_CommentRow> createState() => _CommentRowState();
}

class _CommentRowState extends ConsumerState<_CommentRow> {
  late VoteValue? _vote = switch (widget.votes['comment:${widget.comment.id}']) {
    1 => VoteValue.up,
    -1 => VoteValue.down,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final c = widget.comment;
    return Padding(
      padding: EdgeInsets.only(
        right: widget.depth * 14.0,
        top: 12, bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IdBadge(
                id: c.authorNumericId.toString(),
                shape: widget.shape,
                size: IdBadgeSize.sm,
              ),
              const SizedBox(width: 7),
              Text(
                relMinutes(c.minutesAgo),
                style: TextStyle(fontSize: 10.5, color: qurb.textFaint),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            c.body,
            style: TextStyle(
              fontSize: 13.5, color: qurb.text, height: 1.7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              VotePill(
                score: c.score,
                vote: _vote,
                onVote: (v) async {
                  setState(() => _vote = v);
                  await widget.onVote(c.id, v);
                },
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    QurbIconWidget(
                      QIcon.reply, size: 12, color: qurb.textFaint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ردّ',
                      style: TextStyle(
                        fontSize: 11, color: qurb.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (final r in c.replies)
            _CommentRow(
              comment: r,
              votes: widget.votes,
              shape: widget.shape,
              onVote: widget.onVote,
              depth: widget.depth + 1,
            ),
          if (widget.depth == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(height: 0.5, color: qurb.border),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/proximity_chip.dart';
import '../../core/widgets/qurb_back_button.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/vote_pill.dart';
import '../../l10n/generated/app_localizations.dart';
import '../profile/data/profile_providers.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import '../whispers/whisper_request_sheet.dart';
import 'data/feed_providers.dart';
import 'data/post.dart';
import 'data/post_comment.dart';
import 'edit_post_sheet.dart';
import 'report_sheet.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.postId});
  final int postId;
  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  bool _sending = false;
  RealtimeChannel? _commentsChannel;
  Timer? _liveDebounce;

  // WhatsApp-style reply target: when the user taps "Reply" on a
  // comment, the composer focuses, the keyboard opens, and a chip
  // above the input shows who/what we're replying to.
  int? _replyToId;
  int? _replyToNumericId;
  String? _replyToPreview;

  @override
  void initState() {
    super.initState();
    // Live-update on incoming comments. The realtime callback only
    // signals "something changed" — we invalidate the provider so
    // threading + vote merging stay consistent with the fetch path.
    // A 250 ms debounce coalesces bursts (multiple comments arriving
    // in quick succession trigger a single refetch instead of N).
    _commentsChannel = ref.read(postRepositoryProvider).subscribeToPostComments(
          postId: widget.postId,
          onChange: () {
            if (!mounted) return;
            _liveDebounce?.cancel();
            _liveDebounce = Timer(
              const Duration(milliseconds: 250),
              () {
                if (!mounted) return;
                ref.invalidate(commentsProvider(widget.postId));
              },
            );
          },
        );
  }

  @override
  void dispose() {
    _liveDebounce?.cancel();
    _commentsChannel?.unsubscribe();
    _composer.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _startReply(PostComment c) {
    setState(() {
      _replyToId = c.id;
      _replyToNumericId = c.authorNumericId;
      _replyToPreview = c.body;
    });
    _composerFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToNumericId = null;
      _replyToPreview = null;
    });
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    HapticFeedback.lightImpact();
    final parentId = _replyToId;
    setState(() => _sending = true);
    try {
      await ref.read(postRepositoryProvider).createComment(
            postId: widget.postId,
            parentId: parentId,
            body: body,
          );
      _composer.clear();
      _cancelReply();
      ref.invalidate(commentsProvider(widget.postId));
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        final t = AppLocalizations.of(context);
        final msg = e.toString();
        String reason = t.comments_err_generic;
        if (msg.contains('moderation_violation')) {
          reason = t.comments_err_moderation;
        } else if (msg.contains('rate_limit_comments_per_hour')) {
          reason = t.comments_err_rateLimit;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reason), duration: const Duration(seconds: 3)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final shape = ref.watch(idShapeProvider);
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final commentVotes = ref.watch(commentVotesProvider(widget.postId));
    // Hoisted out of FutureBuilder so composer keystrokes (which
    // trigger setState for character-count UI) do not re-issue a
    // `posts_feed?id=eq.X` REST call on every key. The provider
    // caches the resolved post for the screen's lifetime; pull-to-
    // refresh / edit / delete invalidate it explicitly when needed.
    final postAsync = ref.watch(postByIdProvider(widget.postId));

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _CommentsHeader(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final post = postAsync.valueOrNull;
                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        18, 14, 18, 130 + media.padding.bottom,
                      ),
                      children: [
                        if (post != null) _PostHero(post: post, shape: shape),
                        const SizedBox(height: 6),
                        ...commentsAsync.when(
                          loading: () => const [
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                children: [
                                  SkelRow(padding: EdgeInsets.zero),
                                  SizedBox(height: 8),
                                  SkelRow(padding: EdgeInsets.zero),
                                  SizedBox(height: 8),
                                  SkelRow(padding: EdgeInsets.zero),
                                ],
                              ),
                            ),
                          ],
                          error: (e, _) => [
                            QurbError(
                              compact: true,
                              title: t.comments_error_title,
                              onRetry: () => ref.invalidate(
                                commentsProvider(widget.postId),
                              ),
                            ),
                          ],
                          data: (comments) => [
                            for (final c in comments)
                              _CommentRow(
                                comment: c,
                                votes: commentVotes.value ?? const {},
                                shape: shape,
                                onReply: _startReply,
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
                              QurbEmpty(
                                compact: true,
                                icon: QIcon.reply,
                                title: t.comments_empty_title,
                                subtitle: t.comments_empty_subtitle,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyToId != null)
                        _ReplyChip(
                          toNumericId: _replyToNumericId!,
                          preview: _replyToPreview ?? '',
                          onCancel: _cancelReply,
                        ),
                      Row(
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
                            focusNode: _composerFocus,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: t.comments_hint,
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
                      Semantics(
                      button: true,
                      label: t.comments_send_a11y,
                      child: GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 44, height: 44,
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
                      ),
                    ],
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
    final t = AppLocalizations.of(context);
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
          const QurbBackButton(),
          const Spacer(),
          Text(
            t.comments_header,
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: qurb.text,
            ),
          ),
          const Spacer(),
          // Spacer to mirror the leading back button so the title stays
          // centred. The post's "more" menu lives inside the post card.
          const SizedBox(width: 36),
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

  void _showPostMenu(
    BuildContext context,
    WidgetRef ref,
    Post p,
    QurbColors qurb,
    AppLocalizations t,
  ) {
    final myNumericId = ref.read(myProfileProvider).valueOrNull?.numericId;
    final isOwner =
        myNumericId != null && myNumericId == p.authorNumericId;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: qurb.bgElev,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
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
                _HeroMenuItem(
                  icon: QIcon.pin,
                  label: t.post_menu_save,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ref
                        .read(profileRepositoryProvider)
                        .toggleBookmark(p.id);
                    ref.invalidate(myBookmarksProvider);
                  },
                ),
                if (isOwner) ...[
                  _HeroMenuItem(
                    icon: QIcon.more,
                    label: t.post_menu_edit,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await EditPostSheet.show(
                        context,
                        postId: p.id,
                        initialBody: p.body,
                      );
                    },
                  ),
                  _HeroMenuItem(
                    icon: QIcon.close,
                    label: t.post_menu_delete,
                    color: qurb.danger,
                    last: true,
                    onTap: () async {
                      Navigator.of(context).pop();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: qurb.surface,
                          title: Text(t.post_delete_title,
                              style: TextStyle(color: qurb.text)),
                          content: Text(
                            t.post_delete_body,
                            style: TextStyle(
                                color: qurb.textDim, height: 1.6),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: Text(t.common_cancel,
                                  style: TextStyle(color: qurb.textDim)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: Text(t.post_delete_action,
                                  style: TextStyle(color: qurb.danger)),
                            ),
                          ],
                        ),
                      );
                      if (ok != true || !context.mounted) return;
                      try {
                        await ref
                            .read(postRepositoryProvider)
                            .deleteMyPost(p.id);
                        ref.invalidate(feedPostsProvider);
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (_) {/* ignore */}
                    },
                  ),
                ] else ...[
                  _HeroMenuItem(
                    icon: QIcon.flag,
                    label: t.post_menu_report,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ReportSheet.show(
                        context,
                        targetType: 'post',
                        targetId: p.id,
                      );
                    },
                  ),
                  _HeroMenuItem(
                    icon: QIcon.block,
                    label: t.post_menu_block,
                    color: qurb.danger,
                    last: true,
                    onTap: () async {
                      Navigator.of(context).pop();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: qurb.surface,
                          title: Text(
                            t.post_block_title(
                                p.authorNumericId.toString()),
                            style: TextStyle(color: qurb.text),
                          ),
                          content: Text(
                            t.post_block_body,
                            style: TextStyle(
                                color: qurb.textDim, height: 1.6),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: Text(t.common_cancel,
                                  style: TextStyle(color: qurb.textDim)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: Text(t.post_block_action,
                                  style: TextStyle(color: qurb.danger)),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(profileRepositoryProvider)
                            .blockUserByPost(p.id);
                        ref.invalidate(feedPostsProvider);
                        ref.invalidate(myBlocksProvider);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
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
            const Spacer(),
            GestureDetector(
              onTap: () => _showPostMenu(context, ref, p, qurb, t),
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
                      t.post_whisper_author,
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
              t.post_replies_count(p.commentsCount),
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
    required this.onReply,
    this.depth = 0,
  });
  final PostComment comment;
  final Map<String, int> votes;
  final IdBadgeShape shape;
  final Future<void> Function(int commentId, VoteValue? value) onVote;
  final void Function(PostComment) onReply;
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
    final t = AppLocalizations.of(context);
    final c = widget.comment;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: widget.depth * 14.0,
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onReply(c);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      QurbIconWidget(
                        QIcon.reply, size: 12, color: qurb.textFaint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t.comments_reply,
                        style: TextStyle(
                          fontSize: 11, color: qurb.textFaint,
                        ),
                      ),
                    ],
                  ),
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
              onReply: widget.onReply,
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

class _HeroMenuItem extends StatelessWidget {
  const _HeroMenuItem({
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

/// WhatsApp-style reply target indicator that lives directly above
/// the composer when the user taps "Reply" on a comment. Shows the
/// target's anonymous numeric id + a one-line preview, with an X to
/// dismiss.
class _ReplyChip extends StatelessWidget {
  const _ReplyChip({
    required this.toNumericId,
    required this.preview,
    required this.onCancel,
  });
  final int toNumericId;
  final String preview;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 3, height: 28,
            margin: const EdgeInsetsDirectional.only(end: 10),
            decoration: BoxDecoration(
              color: qurb.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.comments_replying_to(toNumericId.toString()),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: qurb.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12, color: qurb.textDim, height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: t.comments_cancel_reply,
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCancel,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: QurbIconWidget(
                  QIcon.close, size: 14, color: qurb.textFaint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

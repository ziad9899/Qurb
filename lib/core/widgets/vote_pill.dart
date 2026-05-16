import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';
import 'qurb_icon.dart';

enum VoteValue { up, down }

enum VotePillSize { sm, lg }

class VotePill extends StatelessWidget {
  const VotePill({
    super.key,
    required this.score,
    required this.vote,
    required this.onVote,
    this.size = VotePillSize.sm,
  });

  /// Server-provided baseline. The visible score includes the local vote.
  final int score;
  final VoteValue? vote;
  final ValueChanged<VoteValue?> onVote;
  final VotePillSize size;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final isLg = size == VotePillSize.lg;
    final h = isLg ? 36.0 : 28.0;
    final ic = isLg ? 18.0 : 14.0;
    final fs = isLg ? 14.0 : 12.0;
    final padX = isLg ? 10.0 : 8.0;
    final gap = isLg ? 6.0 : 4.0;

    final displayScore = switch (vote) {
      VoteValue.up => score + 1,
      VoteValue.down => score - 1,
      _ => score,
    };
    final scoreColor = switch (vote) {
      VoteValue.up => qurb.up,
      VoteValue.down => qurb.down,
      _ => qurb.textDim,
    };

    return Container(
      height: h,
      padding: EdgeInsets.symmetric(horizontal: padX),
      decoration: BoxDecoration(
        color: qurb.surface2,
        borderRadius: BorderRadius.circular(h / 2),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VoteButton(
            icon: QIcon.arrowUp,
            iconSize: ic,
            color: vote == VoteValue.up ? qurb.up : qurb.textDim,
            onTap: () =>
                onVote(vote == VoteValue.up ? null : VoteValue.up),
          ),
          SizedBox(width: gap),
          SizedBox(
            width: isLg ? 26 : 18,
            child: Text(
              '$displayScore',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fs,
                fontWeight: FontWeight.w600,
                color: scoreColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(width: gap),
          _VoteButton(
            icon: QIcon.arrowDown,
            iconSize: ic,
            color: vote == VoteValue.down ? qurb.down : qurb.textDim,
            onTap: () =>
                onVote(vote == VoteValue.down ? null : VoteValue.down),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.onTap,
  });
  final QIcon icon;
  final double iconSize;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: QurbIconWidget(icon, size: iconSize, color: color),
    );
  }
}

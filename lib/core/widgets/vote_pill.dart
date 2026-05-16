import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/qurb_theme.dart';
import 'qurb_icon.dart';

enum VoteValue { up, down }

enum VotePillSize { sm, lg }

class VotePill extends StatefulWidget {
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
  State<VotePill> createState() => _VotePillState();
}

class _VotePillState extends State<VotePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseC;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _pulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _pulseC, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseC.dispose();
    super.dispose();
  }

  void _onTapVote(VoteValue? next) {
    HapticFeedback.lightImpact();
    if (next != null) {
      _pulseC.forward(from: 0);
    }
    widget.onVote(next);
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final isLg = widget.size == VotePillSize.lg;
    final h = isLg ? 36.0 : 28.0;
    final ic = isLg ? 18.0 : 14.0;
    final fs = isLg ? 14.0 : 12.0;
    final padX = isLg ? 10.0 : 8.0;
    final gap = isLg ? 6.0 : 4.0;

    final displayScore = switch (widget.vote) {
      VoteValue.up => widget.score + 1,
      VoteValue.down => widget.score - 1,
      _ => widget.score,
    };
    final scoreColor = switch (widget.vote) {
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
            color: widget.vote == VoteValue.up ? qurb.up : qurb.textDim,
            scale: widget.vote == VoteValue.up ? _pulse : null,
            onTap: () => _onTapVote(
              widget.vote == VoteValue.up ? null : VoteValue.up,
            ),
          ),
          SizedBox(width: gap),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.35),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: SizedBox(
              key: ValueKey<int>(displayScore),
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
          ),
          SizedBox(width: gap),
          _VoteButton(
            icon: QIcon.arrowDown,
            iconSize: ic,
            color: widget.vote == VoteValue.down ? qurb.down : qurb.textDim,
            scale: widget.vote == VoteValue.down ? _pulse : null,
            onTap: () => _onTapVote(
              widget.vote == VoteValue.down ? null : VoteValue.down,
            ),
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
    this.scale,
  });
  final QIcon icon;
  final double iconSize;
  final Color color;
  final VoidCallback onTap;
  final Animation<double>? scale;
  @override
  Widget build(BuildContext context) {
    Widget child = QurbIconWidget(icon, size: iconSize, color: color);
    if (scale != null) {
      child = ScaleTransition(scale: scale!, child: child);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

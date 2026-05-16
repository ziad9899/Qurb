import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';

/// Shimmer block. Animates a linear gradient horizontally to mirror the
/// `qurbShimmer` keyframe from the web design.
class Skel extends StatefulWidget {
  const Skel({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });
  final double width;
  final double height;
  final double radius;

  @override
  State<Skel> createState() => _SkelState();
}

class _SkelState extends State<Skel> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        // Slide gradient from +200% to -200% (matches CSS keyframes).
        final t = _c.value;
        final shift = 2.0 - 4.0 * t;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + shift, 0),
              end: Alignment(1 + shift, 0),
              colors: [qurb.skel, qurb.skel2, qurb.skel],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

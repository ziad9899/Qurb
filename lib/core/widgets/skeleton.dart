import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';

/// Skeleton row built from `Skel` blocks shared across whisper / notification
/// / comment / profile lists.
class SkelRow extends StatelessWidget {
  const SkelRow({
    super.key,
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });
  final double height;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: padding,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: qurb.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: qurb.border, width: 0.5),
        ),
        child: const Row(
          children: [
            Skel(width: 38, height: 38, radius: 999),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Skel(width: 140, height: 12),
                  SizedBox(height: 6),
                  Skel(width: 200, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical stack of `SkelRow`s for whisper / notification / profile lists.
class SkelList extends StatelessWidget {
  const SkelList({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 100),
  });
  final int count;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        for (var i = 0; i < count; i++) const SkelRow(),
      ],
    );
  }
}

/// Skeleton block matching the compact post cards used in profile tabs &
/// comments-empty placeholders.
class SkelCard extends StatelessWidget {
  const SkelCard({super.key});
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Skel(width: 60, height: 16, radius: 999),
              SizedBox(width: 8),
              Skel(width: 50, height: 16, radius: 999),
            ],
          ),
          SizedBox(height: 10),
          Skel(width: double.infinity, height: 12),
          SizedBox(height: 6),
          Skel(width: 180, height: 12),
        ],
      ),
    );
  }
}

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

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Abstract activity heatmap. Mirrors the web design's PulseMap:
/// a dotted grid + 9 weighted heat blobs + an animated ping marking "you".
/// This is deliberately NOT a real map — it's a stylised pulse visualisation.
class PulseMap extends StatefulWidget {
  const PulseMap({super.key, required this.colors});
  final QurbColors colors;

  @override
  State<PulseMap> createState() => _PulseMapState();
}

class _PulseMapState extends State<PulseMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.colors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              size: Size.infinite,
              painter: _PulsePainter(
                colors: widget.colors,
                pingT: _c.value,
              ),
            ),
          ),
          // "أنت" label
          const _YouLabel(),
          // legend (bottom-end)
          Positioned(
            bottom: 12, left: 12,
            child: _Legend(colors: widget.colors),
          ),
          // header chip (top-start)
          Positioned(
            top: 12, right: 12,
            child: _HeaderChip(colors: widget.colors),
          ),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.colors, required this.pingT});
  final QurbColors colors;
  final double pingT;

  static const _zones = <_Zone>[
    _Zone(0.20, 0.21, 0.30),
    _Zone(0.47, 0.24, 0.60),
    _Zone(0.73, 0.17, 0.20),
    _Zone(0.17, 0.48, 0.80),
    _Zone(0.48, 0.50, 1.00), // 'you' — center
    _Zone(0.80, 0.45, 0.40),
    _Zone(0.23, 0.79, 0.30),
    _Zone(0.53, 0.74, 0.70),
    _Zone(0.83, 0.83, 0.50),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1) dotted grid
    final gridPaint = Paint()
      ..color = colors.textFaint.withValues(alpha: 0.18)
      ..strokeWidth = 0.5;
    const steps = 14;
    for (var i = 1; i <= steps; i++) {
      _drawDashedLine(
        canvas,
        Offset(i * size.width / steps, 0),
        Offset(i * size.width / steps, size.height),
        gridPaint,
        dashWidth: 2, gap: 4,
      );
      _drawDashedLine(
        canvas,
        Offset(0, i * size.height / steps),
        Offset(size.width, i * size.height / steps),
        gridPaint,
        dashWidth: 2, gap: 4,
      );
    }

    // 2) radial heat blobs
    for (final z in _zones) {
      final isHot = z.weight > 0.6;
      final base = isHot ? colors.accent : colors.gold;
      final cx = z.x * size.width;
      final cy = z.y * size.height;
      final r = 40 + z.weight * 35;
      final gradient = RadialGradient(
        colors: [
          base.withValues(alpha: isHot ? 0.55 : 0.35),
          base.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      );
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // 3) zone dots
    for (final z in _zones) {
      final isHot = z.weight > 0.6;
      final color = isHot ? colors.accent : colors.gold;
      final cx = z.x * size.width;
      final cy = z.y * size.height;
      canvas.drawCircle(
        Offset(cx, cy),
        4 + z.weight * 4,
        Paint()..color = color,
      );
    }

    // 4) animated ping on the centre ("you") zone
    final you = _zones.firstWhere((z) => z.weight == 1.0);
    final pcx = you.x * size.width;
    final pcy = you.y * size.height;
    final ringR = 8 + 16 * pingT;
    final ringOpacity = (1 - pingT).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(pcx, pcy),
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = colors.accent.withValues(alpha: 0.8 * ringOpacity),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    required double dashWidth,
    required double gap,
  }) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final dirX = dx / dist;
    final dirY = dy / dist;
    var travelled = 0.0;
    while (travelled < dist) {
      final endT = math.min(travelled + dashWidth, dist);
      canvas.drawLine(
        Offset(a.dx + dirX * travelled, a.dy + dirY * travelled),
        Offset(a.dx + dirX * endT, a.dy + dirY * endT),
        paint,
      );
      travelled = endT + gap;
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.pingT != pingT;
}

class _Zone {
  const _Zone(this.x, this.y, this.weight);
  final double x;
  final double y;
  final double weight;
}

class _YouLabel extends StatelessWidget {
  const _YouLabel();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      const youZ = (x: 0.48, y: 0.50);
      return Positioned(
        left: c.maxWidth * youZ.x - 16,
        top: c.maxHeight * youZ.y + 16,
        child: Builder(builder: (ctx) {
          final qurb = Theme.of(ctx);
          // We don't have access to QurbColors directly here; use Theme bg/text
          // for the "أنت" pill (it's intentionally inverted from the bg).
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: qurb.colorScheme.onSurface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              AppLocalizations.of(context).trend_pulse_you,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: qurb.colorScheme.surface,
              ),
            ),
          );
        }),
      );
    });
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.colors});
  final QurbColors colors;
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.glass,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendDot(color: colors.accent, label: 'نشاط مرتفع'),
              const SizedBox(width: 8),
              Container(width: 1, height: 10, color: colors.border),
              const SizedBox(width: 8),
              _LegendDot(color: colors.gold, label: 'متوسط'),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
      final qurb = Theme.of(ctx);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: qurb.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
        ],
      );
    });
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.colors});
  final QurbColors colors;
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.glass,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Text(
            'نبض الرياض الآن',
            style: TextStyle(fontSize: 10, color: colors.textDim),
          ),
        ),
      ),
    );
  }
}

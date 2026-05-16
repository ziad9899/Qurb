import 'package:flutter/material.dart';

import '../theme/id_hues.dart';
import '../theme/qurb_theme.dart';

/// The brand atom — the user's numeric ID, rendered as a coloured badge.
/// Five shapes are supported, all selectable from the Tweaks panel in the
/// web design. The tint is derived deterministically from the id digits.
enum IdBadgeShape { pill, chip, dot, ring, square }

enum IdBadgeSize { sm, md, lg }

class IdBadge extends StatelessWidget {
  const IdBadge({
    super.key,
    required this.id,
    this.shape = IdBadgeShape.pill,
    this.size = IdBadgeSize.md,
    this.prefix = '#',
  });

  final String id;
  final IdBadgeShape shape;
  final IdBadgeSize size;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final isDark = context.isDarkQurb;
    final hue = idHueColors(id, isDark: isDark);
    final dims = _dimensionsFor(size);
    final txt = '$prefix$id';

    final textStyle = TextStyle(
      fontFamily: 'IBMPlexMono',
      fontFamilyFallback: const ['monospace'],
      fontSize: dims.fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    switch (shape) {
      case IdBadgeShape.dot:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dims.dotSize,
              height: dims.dotSize,
              decoration:
                  BoxDecoration(color: hue.accent, shape: BoxShape.circle),
            ),
            SizedBox(width: dims.gap),
            Text(txt, style: textStyle.copyWith(color: qurb.text)),
          ],
        );

      case IdBadgeShape.ring:
        return Container(
          padding:
              EdgeInsets.symmetric(horizontal: dims.padX, vertical: dims.padY),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: hue.accent, width: 1.5),
          ),
          child: Text(txt, style: textStyle.copyWith(color: hue.accent)),
        );

      case IdBadgeShape.square:
        return Container(
          padding:
              EdgeInsets.symmetric(horizontal: dims.padX, vertical: dims.padY),
          decoration: BoxDecoration(
            color: hue.accent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(txt,
              style: textStyle.copyWith(color: const Color(0xFFFFFFFF))),
        );

      case IdBadgeShape.chip:
        return Container(
          padding:
              EdgeInsets.symmetric(horizontal: dims.padX, vertical: dims.padY),
          decoration: BoxDecoration(
            color: hue.accentSoft,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: hue.accentBorder, width: 0.5),
          ),
          child: Text(txt, style: textStyle.copyWith(color: hue.accent)),
        );

      case IdBadgeShape.pill:
        return Container(
          padding:
              EdgeInsets.symmetric(horizontal: dims.padX, vertical: dims.padY),
          decoration: BoxDecoration(
            color: hue.accentSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: hue.accentBorder, width: 0.5),
          ),
          child: Text(txt, style: textStyle.copyWith(color: hue.accent)),
        );
    }
  }

  _Dims _dimensionsFor(IdBadgeSize s) {
    switch (s) {
      case IdBadgeSize.sm:
        return const _Dims(11, 2, 7, 6, 5);
      case IdBadgeSize.lg:
        return const _Dims(16, 5, 12, 10, 8);
      case IdBadgeSize.md:
        return const _Dims(12.5, 3, 9, 7, 6);
    }
  }
}

class _Dims {
  const _Dims(this.fontSize, this.padY, this.padX, this.dotSize, this.gap);
  final double fontSize;
  final double padY;
  final double padX;
  final double dotSize;
  final double gap;
}

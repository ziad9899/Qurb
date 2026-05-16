import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The 8 hues used for ID badge tints. Mirrors the web design's ID_HUES array.
/// Hash the id digits → pick one. Same id always yields same hue.
class IdHue {
  const IdHue(this.h, this.name);
  final double h; // hue angle in degrees
  final String name;
}

const List<IdHue> kIdHues = [
  IdHue(354, 'rose'),
  IdHue(38, 'amber'),
  IdHue(156, 'mint'),
  IdHue(198, 'sky'),
  IdHue(262, 'violet'),
  IdHue(320, 'magenta'),
  IdHue(18, 'coral'),
  IdHue(92, 'lime'),
];

/// Pick a hue for an id by hashing its char codes (sum). Deterministic.
IdHue idHueFor(String id) {
  var sum = 0;
  for (final code in id.codeUnits) {
    sum += code;
  }
  return kIdHues[sum % kIdHues.length];
}

/// OKLCH → sRGB conversion. The web design uses oklch(0.72 0.16 hue) for
/// the badge accent and oklch(0.45 0.18 354) for the radial center on the
/// welcome screen. This converter matches Björn Ottosson's reference formula.
Color oklchToColor(double l, double c, double hDeg, [double alpha = 1.0]) {
  final hRad = hDeg * math.pi / 180.0;
  final a = c * math.cos(hRad);
  final b = c * math.sin(hRad);

  // OKLab → linear sRGB
  final lp = l + 0.3963377774 * a + 0.2158037573 * b;
  final mp = l - 0.1055613458 * a - 0.0638541728 * b;
  final sp = l - 0.0894841775 * a - 1.2914855480 * b;
  final l3 = lp * lp * lp;
  final m3 = mp * mp * mp;
  final s3 = sp * sp * sp;

  final r = 4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3;
  final g = -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3;
  final bl = -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3;

  int toSrgb(double v) {
    if (v <= 0) return 0;
    if (v >= 1) return 255;
    final s =
        v >= 0.0031308 ? 1.055 * math.pow(v, 1 / 2.4) - 0.055 : 12.92 * v;
    return (s * 255).round().clamp(0, 255);
  }

  return Color.fromARGB(
    (alpha.clamp(0.0, 1.0) * 255).round(),
    toSrgb(r),
    toSrgb(g),
    toSrgb(bl),
  );
}

/// Returns the standard accent + soft fill + border tint for a given id.
class IdHueColors {
  const IdHueColors({
    required this.accent,
    required this.accentSoft,
    required this.accentBorder,
  });
  final Color accent;
  final Color accentSoft;
  final Color accentBorder;
}

IdHueColors idHueColors(String id, {bool isDark = true}) {
  final hue = idHueFor(id);
  return IdHueColors(
    accent: oklchToColor(0.72, 0.16, hue.h),
    accentSoft: oklchToColor(0.72, 0.16, hue.h, isDark ? 0.18 : 0.13),
    accentBorder: oklchToColor(0.72, 0.16, hue.h, 0.35),
  );
}

import 'package:flutter/material.dart';

/// Qurb color tokens — mirrors the web design's THEMES.dark / THEMES.light.
/// Alpha channel encoded as the high byte of 0xAARRGGBB.
class QurbColors {
  const QurbColors({
    required this.bg,
    required this.bgElev,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.accentSoft,
    required this.gold,
    required this.goldSoft,
    required this.up,
    required this.down,
    required this.danger,
    required this.glass,
    required this.skel,
    required this.skel2,
  });

  final Color bg;
  final Color bgElev;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textDim;
  final Color textFaint;
  final Color accent;
  final Color accentSoft;
  final Color gold;
  final Color goldSoft;
  final Color up;
  final Color down;
  final Color danger;
  final Color glass;
  final Color skel;
  final Color skel2;

  static const QurbColors dark = QurbColors(
    bg: Color(0xFF0A0A0B),
    bgElev: Color(0xFF121214),
    surface: Color(0xFF171719),
    surface2: Color(0xFF1F1F22),
    border: Color(0x14FFFFFF),
    borderStrong: Color(0x24FFFFFF),
    text: Color(0xFFFAFAFA),
    textDim: Color(0x9EFAFAFA),
    textFaint: Color(0x61FAFAFA),
    accent: Color(0xFFFF4D6D),
    accentSoft: Color(0x29FF4D6D),
    gold: Color(0xFFFFC857),
    goldSoft: Color(0x24FFC857),
    up: Color(0xFF4ADE80),
    down: Color(0xFF94A3B8),
    danger: Color(0xFFFF5757),
    glass: Color(0xB8141416),
    skel: Color(0x0FFFFFFF),
    skel2: Color(0x1AFFFFFF),
  );

  static const QurbColors light = QurbColors(
    bg: Color(0xFFFAFAF9),
    bgElev: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4F4F2),
    border: Color(0x140A0A0B),
    borderStrong: Color(0x240A0A0B),
    text: Color(0xFF0A0A0B),
    textDim: Color(0x9E0A0A0B),
    textFaint: Color(0x610A0A0B),
    accent: Color(0xFFE5345C),
    accentSoft: Color(0x1AE5345C),
    gold: Color(0xFFB8821C),
    goldSoft: Color(0x1FB8821C),
    up: Color(0xFF16A34A),
    down: Color(0xFF64748B),
    danger: Color(0xFFDC2626),
    glass: Color(0xC7FFFFFF),
    skel: Color(0x0D000000),
    skel2: Color(0x17000000),
  );
}

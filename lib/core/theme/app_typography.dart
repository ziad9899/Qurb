import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Qurb typography scale — IBM Plex Sans Arabic.
/// Mirrors the type ramp from the DesignTokens artboard in the web design.
class QurbTypography {
  QurbTypography._();

  static TextStyle _base(double size, FontWeight weight, {double? letter}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letter,
      height: 1.4,
    );
  }

  /// Tabular-style numerals for IDs and scores.
  static TextStyle mono(double size, FontWeight weight) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: 0.2,
      height: 1.3,
    );
  }

  static TextStyle display(Color color) =>
      _base(32, FontWeight.w700, letter: -0.6).copyWith(color: color, height: 1.25);
  static TextStyle title(Color color) =>
      _base(24, FontWeight.w700, letter: -0.5).copyWith(color: color, height: 1.3);
  static TextStyle heading(Color color) =>
      _base(18, FontWeight.w600).copyWith(color: color, height: 1.35);
  static TextStyle body(Color color) =>
      _base(15, FontWeight.w500).copyWith(color: color, height: 1.7);
  static TextStyle bodySmall(Color color) =>
      _base(13, FontWeight.w500).copyWith(color: color, height: 1.6);
  static TextStyle caption(Color color) =>
      _base(11, FontWeight.w600, letter: 1.5).copyWith(color: color);

  static TextStyle label(Color color) =>
      _base(12, FontWeight.w500).copyWith(color: color);

  static TextTheme materialTextTheme(Color text, Color textDim) {
    return TextTheme(
      displayLarge: display(text),
      displayMedium: display(text),
      displaySmall: display(text),
      headlineLarge: title(text),
      headlineMedium: title(text),
      headlineSmall: heading(text),
      titleLarge: heading(text),
      titleMedium: heading(text),
      titleSmall: bodySmall(text),
      bodyLarge: body(text),
      bodyMedium: body(text),
      bodySmall: bodySmall(textDim),
      labelLarge: bodySmall(text),
      labelMedium: caption(textDim),
      labelSmall: caption(textDim),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'qurb_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _build(QurbColors c, bool isDark) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
        surface: c.surface,
        primary: c.accent,
        onPrimary: const Color(0xFFFFFFFF),
        secondary: c.gold,
        error: c.danger,
        outline: c.borderStrong,
      ),
      textTheme: QurbTypography.materialTextTheme(c.text, c.textDim),
      dividerColor: c.border,
      splashColor: c.accentSoft,
      highlightColor: c.accentSoft,
      extensions: [QurbThemeExt(colors: c, isDark: isDark)],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() => _build(QurbColors.dark, true);
  static ThemeData light() => _build(QurbColors.light, false);
}

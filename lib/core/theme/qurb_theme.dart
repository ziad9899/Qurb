import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ThemeExtension that carries Qurb's full color palette into the widget tree.
/// Access via `Theme.of(context).extension<QurbThemeExt>()!` or the helper
/// `context.qurb`.
@immutable
class QurbThemeExt extends ThemeExtension<QurbThemeExt> {
  const QurbThemeExt({required this.colors, required this.isDark});

  final QurbColors colors;
  final bool isDark;

  @override
  QurbThemeExt copyWith({QurbColors? colors, bool? isDark}) =>
      QurbThemeExt(colors: colors ?? this.colors, isDark: isDark ?? this.isDark);

  @override
  QurbThemeExt lerp(ThemeExtension<QurbThemeExt>? other, double t) {
    if (other is! QurbThemeExt) return this;
    // Themes are discrete (dark/light); no need to lerp every color individually.
    return t < 0.5 ? this : other;
  }
}

extension QurbThemeContext on BuildContext {
  QurbColors get qurb =>
      Theme.of(this).extension<QurbThemeExt>()!.colors;
  bool get isDarkQurb =>
      Theme.of(this).extension<QurbThemeExt>()!.isDark;
}

import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';

/// Card frame — used for posts, comments, list rows.
/// 18px radius, hairline border, no shadow (the design is flat-on-flat).
class QurbCard extends StatelessWidget {
  const QurbCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: child,
    );
    final wrapped = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: qurb.accentSoft,
              highlightColor: qurb.accentSoft,
              child: content,
            ),
          );
    return margin == null ? wrapped : Padding(padding: margin!, child: wrapped);
  }
}

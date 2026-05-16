import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';
import 'qurb_icon.dart';

/// Unified empty-state placeholder. Use across all "no data yet" surfaces so
/// the visual language stays consistent (icon bubble + title + subtitle).
class QurbEmpty extends StatelessWidget {
  const QurbEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(30, 80, 30, 30),
    this.compact = false,
  });

  final QIcon icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  /// Smaller variant for inline placement (e.g. inside profile tabs).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final bubbleSize = compact ? 52.0 : 64.0;
    final iconSize = compact ? 22.0 : 28.0;
    final titleSize = compact ? 14.0 : 16.0;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: bubbleSize,
            height: bubbleSize,
            decoration: BoxDecoration(
              color: qurb.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: QurbIconWidget(icon, size: iconSize, color: qurb.accent),
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: qurb.text,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: qurb.textDim,
                height: 1.6,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 14),
            action!,
          ],
        ],
      ),
    );
  }
}

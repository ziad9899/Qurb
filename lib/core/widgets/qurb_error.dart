import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/qurb_theme.dart';
import 'qurb_icon.dart';

/// Unified error placeholder with optional retry button. Use whenever an
/// async surface fails to load so the call-to-action is consistent.
class QurbError extends StatelessWidget {
  const QurbError({
    super.key,
    this.title,
    this.subtitle,
    this.onRetry,
    this.padding = const EdgeInsets.fromLTRB(30, 60, 30, 30),
    this.compact = false,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
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
              color: qurb.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: QurbIconWidget(
                QIcon.close,
                size: iconSize,
                color: qurb.danger,
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          Text(
            title ?? t.common_loadFailed,
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
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: qurb.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: Text(
                  t.common_retry,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

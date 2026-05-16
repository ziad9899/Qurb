import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/qurb_theme.dart';
import 'qurb_icon.dart';

/// 5-tab bottom navigation matching the web design. The centre tab is a
/// primary action FAB that sits raised above the bar.
enum NavTab { feed, search, post, inbox, me }

class QurbBottomNav extends StatelessWidget {
  const QurbBottomNav({
    super.key,
    required this.active,
    required this.onChange,
    this.hasUnread = false,
  });

  final NavTab active;
  final ValueChanged<NavTab> onChange;
  final bool hasUnread;

  static const _items = <_NavItem>[
    _NavItem(NavTab.feed, QIcon.home, 'الرئيسية'),
    _NavItem(NavTab.search, QIcon.compass, 'استكشف'),
    _NavItem(NavTab.post, QIcon.plus, 'انشر', primary: true),
    _NavItem(NavTab.inbox, QIcon.whisper, 'همس'),
    _NavItem(NavTab.me, QIcon.user, 'أنا'),
  ];

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 28),
          decoration: BoxDecoration(
            color: qurb.glass,
            border: Border(
              top: BorderSide(color: qurb.border, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final it in _items)
                _buildItem(context, it, qurb),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _NavItem it, dynamic qurb) {
    if (it.primary) {
      return Transform.translate(
        offset: const Offset(0, -14),
        child: GestureDetector(
          onTap: () => onChange(it.tab),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: qurb.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (qurb.accent as Color).withValues(alpha: 0.33),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: QurbIconWidget(QIcon.plus,
                  size: 22, color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      );
    }

    final isActive = it.tab == active;
    final color = isActive ? qurb.text : qurb.textFaint;
    return GestureDetector(
      onTap: () => onChange(it.tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QurbIconWidget(it.icon, size: 22, color: color as Color),
                const SizedBox(height: 3),
                Text(
                  it.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (it.tab == NavTab.inbox && hasUnread)
              Positioned(
                top: 0,
                right: 4,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: qurb.accent as Color,
                    shape: BoxShape.circle,
                    border: Border.all(color: qurb.bg as Color, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.tab, this.icon, this.label, {this.primary = false});
  final NavTab tab;
  final QIcon icon;
  final String label;
  final bool primary;
}

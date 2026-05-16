import 'package:flutter/material.dart';

/// Qurb's icon namespace. We map each design-named icon to the closest
/// Material outlined equivalent. The visual language is stroke-style icons
/// at ~1.6–2.0 stroke weight, ~22px default size.
enum QIcon {
  home,
  flame,
  pulse,
  whisper,
  bell,
  user,
  search,
  plus,
  arrowUp,
  arrowDown,
  pin,
  send,
  image,
  more,
  reply,
  flag,
  block,
  shield,
  moon,
  sun,
  chevron, // points "next" — in RTL that's left
  chevronL, // points "back" — in RTL that's right
  check,
  close,
  globe,
  hash,
  trend,
  eye,
  lock,
  camera,
  filter,
  compass,
}

IconData _iconDataFor(QIcon q) {
  switch (q) {
    case QIcon.home:
      return Icons.home_outlined;
    case QIcon.flame:
      return Icons.local_fire_department_outlined;
    case QIcon.pulse:
      return Icons.show_chart;
    case QIcon.whisper:
      return Icons.chat_bubble_outline;
    case QIcon.bell:
      return Icons.notifications_outlined;
    case QIcon.user:
      return Icons.person_outline;
    case QIcon.search:
      return Icons.search;
    case QIcon.plus:
      return Icons.add;
    case QIcon.arrowUp:
      return Icons.keyboard_arrow_up_rounded;
    case QIcon.arrowDown:
      return Icons.keyboard_arrow_down_rounded;
    case QIcon.pin:
      return Icons.place_outlined;
    case QIcon.send:
      return Icons.send_rounded;
    case QIcon.image:
      return Icons.image_outlined;
    case QIcon.more:
      return Icons.more_horiz;
    case QIcon.reply:
      return Icons.reply_rounded;
    case QIcon.flag:
      return Icons.flag_outlined;
    case QIcon.block:
      return Icons.block_outlined;
    case QIcon.shield:
      return Icons.shield_outlined;
    case QIcon.moon:
      return Icons.dark_mode_outlined;
    case QIcon.sun:
      return Icons.light_mode_outlined;
    case QIcon.chevron:
      return Icons.chevron_left_rounded;
    case QIcon.chevronL:
      return Icons.chevron_right_rounded;
    case QIcon.check:
      return Icons.check_rounded;
    case QIcon.close:
      return Icons.close_rounded;
    case QIcon.globe:
      return Icons.public_outlined;
    case QIcon.hash:
      return Icons.tag_rounded;
    case QIcon.trend:
      return Icons.trending_up_rounded;
    case QIcon.eye:
      return Icons.visibility_outlined;
    case QIcon.lock:
      return Icons.lock_outline_rounded;
    case QIcon.camera:
      return Icons.photo_camera_outlined;
    case QIcon.filter:
      return Icons.filter_list_rounded;
    case QIcon.compass:
      return Icons.explore_outlined;
  }
}

class QurbIconWidget extends StatelessWidget {
  const QurbIconWidget(
    this.name, {
    super.key,
    this.size = 22,
    this.color,
  });

  final QIcon name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(_iconDataFor(name), size: size, color: color);
  }
}

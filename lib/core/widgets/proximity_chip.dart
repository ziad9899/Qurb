import 'package:flutter/material.dart';

import '../data/mock_data.dart' show Proximity;
import '../theme/qurb_theme.dart';
import 'qurb_icon.dart';

enum ProximityChipSize { xs, sm }

class ProximityChip extends StatelessWidget {
  const ProximityChip({
    super.key,
    required this.kind,
    this.size = ProximityChipSize.sm,
  });

  final Proximity kind;
  final ProximityChipSize size;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    late final String label;
    late final QIcon icon;
    late final Color color;
    switch (kind) {
      case Proximity.near:
        label = 'قريب منك';
        icon = QIcon.pin;
        color = qurb.accent;
        break;
      case Proximity.block:
        label = 'داخل الحي';
        icon = QIcon.pin;
        color = qurb.gold;
        break;
      case Proximity.city:
        label = 'داخل المدينة';
        icon = QIcon.globe;
        color = qurb.textDim;
        break;
    }
    final isXs = size == ProximityChipSize.xs;
    final fs = isXs ? 10.0 : 11.0;
    final padY = isXs ? 2.0 : 3.0;
    final padX = isXs ? 6.0 : 7.0;
    final iconSize = isXs ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
      decoration: BoxDecoration(
        color: qurb.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QurbIconWidget(icon, size: iconSize, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: fs,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

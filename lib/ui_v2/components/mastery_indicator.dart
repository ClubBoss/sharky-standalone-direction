import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class MasteryIndicator extends StatelessWidget {
  final String level;

  const MasteryIndicator({required this.level, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DesignContainers.card,
      padding: const EdgeInsets.all(DesignLayout.itemSpacing),
      child: Text(
        'Mastery: $level',
        style: TextStyle(
          fontSize: DesignTypography.body,
          fontWeight: FontWeight.bold,
          color: Color(DesignColors.accent),
        ),
      ),
    );
  }
}

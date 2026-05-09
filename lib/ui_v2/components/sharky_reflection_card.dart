import 'package:flutter/material.dart';

import '../components/design_card.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class SharkyReflectionCard extends StatelessWidget {
  final String reflection;

  const SharkyReflectionCard({required this.reflection, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DesignLayout.vspaceSmall,
          horizontal: DesignLayout.itemSpacing,
        ),
        child: DesignCard(
          child: Text(
            'Session: $reflection',
            style: TextStyle(
              fontSize: DesignTypography.body,
              fontWeight: FontWeight.w500,
              color: Color(DesignColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../theme/v4_token_registry.dart';

class TraitsList extends StatelessWidget {
  final List<String> traits;

  const TraitsList({required this.traits, super.key});

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: traits.map((t) {
        return Padding(
          padding: EdgeInsets.only(bottom: tokens.v4SpacingS),
          child: Text(
            '- $t',
            style: TextStyle(
              fontSize: DesignTypography.body,
              fontWeight: FontWeight.w400,
              color: Color(DesignColors.accent),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_interactions.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../theme/v4_token_registry.dart';

class DesignButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  const DesignButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    final decoration = enabled
        ? DesignContainers.card
        : DesignInteractions.disabled;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        decoration: decoration,
        padding: EdgeInsets.all(tokens.v4SpacingM),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTypography.body,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? Color(DesignColors.accentStrong)
                  : Color(DesignColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

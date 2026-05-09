import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../theme/v4_token_registry.dart';

class DesignListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const DesignListTile({
    required this.title,
    this.subtitle,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: DesignContainers.card,
        padding: EdgeInsets.symmetric(
          vertical: tokens.v4SpacingM,
          horizontal: tokens.v4SpacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: DesignTypography.h3,
                fontWeight: FontWeight.bold,
                color: Color(DesignColors.accent),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: EdgeInsets.only(top: tokens.v4SpacingS),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: DesignTypography.body,
                    fontWeight: FontWeight.w400,
                    color: Color(DesignColors.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

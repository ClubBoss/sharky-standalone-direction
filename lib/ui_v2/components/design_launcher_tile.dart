import 'package:flutter/material.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../theme/v4_token_registry.dart';
import '../design/design_layout.dart';

class DesignLauncherTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const DesignLauncherTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: DesignContainers.card,
        padding: EdgeInsets.all(tokens.v4SpacingM),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.v4IconPaddingS),
              child: Opacity(
                opacity: tokens.v4IconOpacity,
                child: Icon(
                  icon,
                  color: Color(DesignColors.accent),
                  size: tokens.v4IconSizeM,
                ),
              ),
            ),
            SizedBox(width: tokens.v4SpacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: DesignTypography.h2,
                      fontWeight: FontWeight.bold,
                      color: Color(DesignColors.accent),
                    ),
                  ),
                  const SizedBox(height: DesignLayout.itemSpacing),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: DesignTypography.body,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../components_v3/panel_v3.dart';
import '../../theme/v4_token_registry.dart';

class PersonaProfileOverlayV1 extends StatelessWidget {
  const PersonaProfileOverlayV1({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
  });

  final String title;
  final String body;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = const V4TokenRegistry();
    final spacingM = tokens.v4SpacingMedium;
    final spacingL = tokens.v4SpacingLarge;
    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle(fontWeight: FontWeight.bold);
    final bodyStyle = theme.textTheme.bodyMedium;
    final subtitleStyle = theme.textTheme.bodySmall;
    return PanelV3(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: spacingM * 0.5),
              Text(subtitle!, style: subtitleStyle),
            ],
            SizedBox(height: spacingM),
            Text(body, style: bodyStyle),
          ],
        ),
      ),
    );
  }
}

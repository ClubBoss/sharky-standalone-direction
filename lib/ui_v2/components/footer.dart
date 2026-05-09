import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import '../theme/v4_token_registry.dart';

class TrainingPackResultFooter extends StatelessWidget {
  final VoidCallback onBackToList;

  const TrainingPackResultFooter({super.key, required this.onBackToList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    const tokens = V4TokenRegistry();
    final spacing = tokens.v4SpacingM;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      brand?.primaryBrand ?? theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.v4RadiusM),
                  ),
                  elevation: brand?.elevationMed ?? 2,
                ),
                onPressed: onBackToList,
                child: const Text('Back to List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/v4_token_registry.dart';

class TrainingPackResultHeader extends StatelessWidget {
  final String templateName;
  final int totalSpots;
  final int answered;

  const TrainingPackResultHeader({
    super.key,
    required this.templateName,
    required this.totalSpots,
    required this.answered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const tokens = V4TokenRegistry();
    final radius = BorderRadius.circular(tokens.v4RadiusS);
    final spacing = tokens.v4SpacingS;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: spacing * 2, horizontal: spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'pack-title-$templateName',
            child: Text(templateName, style: theme.textTheme.titleLarge),
          ),
          SizedBox(height: spacing),
          Text(
            'Spots: $totalSpots • Answered: $answered',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

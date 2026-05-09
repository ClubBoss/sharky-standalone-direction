import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import '../theme/v4_token_registry.dart';

class TrainingPackResultBody extends StatelessWidget {
  final Map<String, String> results;
  final List<String> spotIds;

  const TrainingPackResultBody({
    super.key,
    required this.results,
    required this.spotIds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    const tokens = V4TokenRegistry();
    final radius = BorderRadius.circular(tokens.v4RadiusM);
    if (spotIds.isEmpty) {
      return const Center(child: Text('No spots'));
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        vertical: tokens.v4SpacingM,
        horizontal: tokens.v4SpacingM,
      ),
      itemCount: spotIds.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.v4SpacingS),
      itemBuilder: (context, index) {
        final id = spotIds[index];
        final answer = results[id];
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
          child: ListTile(
            title: Text(
              'Spot #${index + 1}',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              'Answer: ${answer ?? '-'}',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }
}

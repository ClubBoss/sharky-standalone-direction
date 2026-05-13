import 'package:flutter/material.dart';
import '../theme/visual_theme_v3.dart';
import 'term_definition_resolver.dart';

class TermDefinitionOverlay extends StatelessWidget {
  const TermDefinitionOverlay({
    super.key,
    required this.term,
    required this.definition,
  });

  final String term;
  final String definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VisualThemeV3.card,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        boxShadow: const [VisualThemeV3.shadowMedium],
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      constraints: const BoxConstraints(minWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(term, style: theme.textTheme.labelLarge),
          const SizedBox(height: VisualThemeV3.spacingS),
          Text(definition, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  static void show(BuildContext context, String term) {
    final definition = TermDefinitionResolver.getDefinition(term);
    if (definition == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => Center(
        child: TermDefinitionOverlay(term: term, definition: definition),
      ),
    );
  }
}

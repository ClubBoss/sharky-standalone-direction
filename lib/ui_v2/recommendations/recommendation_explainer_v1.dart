import 'package:flutter/material.dart';

import '../persona/components_v3/panel_v3.dart';
import '../theme/v4_token_registry.dart';

class RecommendationExplainerV1 extends StatelessWidget {
  const RecommendationExplainerV1({
    super.key,
    required this.topItem,
    required this.personaTraits,
    required this.personaInsights,
  });

  final Map<String, Object?>? topItem;
  final Map<String, String>? personaTraits;
  final Map<String, String>? personaInsights;

  @override
  Widget build(BuildContext context) {
    if (topItem == null) return const SizedBox.shrink();
    final tokens = const V4TokenRegistry();
    final spacing = tokens.v4SpacingMedium;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final bodyStyle = theme.textTheme.bodySmall;
    final question = _asString(topItem?['question']);
    final tags = _asTags(topItem?['tags']);
    final reason = StringBuffer();
    if (personaTraits?.isNotEmpty == true) {
      reason.writeln('Traits: ${personaTraits!.keys.join(', ')}');
    }
    if (personaInsights?.isNotEmpty == true) {
      reason.writeln('Insights: ${personaInsights!.keys.join(', ')}');
    }
    if (tags.isNotEmpty) {
      reason.writeln('Score tags: ${tags.join(', ')}');
    }
    return PanelV3(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why this recommendation?', style: titleStyle),
            if (question.isNotEmpty) ...[
              SizedBox(height: spacing * 0.5),
              Text('Question: $question', style: bodyStyle),
            ],
            if (reason.isNotEmpty) ...[
              SizedBox(height: spacing * 0.5),
              Text(reason.toString().trim(), style: bodyStyle),
            ],
          ],
        ),
      ),
    );
  }

  String _asString(Object? value) =>
      value is String ? value : (value?.toString() ?? '');

  List<String> _asTags(Object? value) {
    if (value is Iterable) {
      return value
          .whereType<String>()
          .map((tag) => tag.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), ''))
          .where((tag) => tag.isNotEmpty)
          .toList()
        ..sort();
    }
    return const <String>[];
  }
}

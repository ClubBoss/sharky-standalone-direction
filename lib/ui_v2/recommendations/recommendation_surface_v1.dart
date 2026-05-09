import 'package:flutter/material.dart';

import '../persona/components_v3/panel_v3.dart';
import '../theme/v4_token_registry.dart';

class RecommendationSurfaceV1 extends StatelessWidget {
  const RecommendationSurfaceV1({
    super.key,
    required this.title,
    required this.topItem,
  });

  final String? title;
  final Map<String, Object?>? topItem;

  @override
  Widget build(BuildContext context) {
    if (topItem == null) return const SizedBox.shrink();
    final tokens = const V4TokenRegistry();
    final spacing = tokens.v4SpacingMedium;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final bodyStyle = theme.textTheme.bodyMedium;
    final question = _asString(topItem?['question']);
    final answer = _asString(topItem?['answer']);
    return PanelV3(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title ?? 'Recommendation', style: titleStyle),
            if (question.isNotEmpty) ...[
              SizedBox(height: spacing * 0.5),
              Text(question, style: bodyStyle),
            ],
            if (answer.isNotEmpty) ...[
              SizedBox(height: spacing * 0.5),
              Text(
                answer,
                style: bodyStyle?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _asString(Object? value) =>
      value is String ? value : (value?.toString() ?? '');
}

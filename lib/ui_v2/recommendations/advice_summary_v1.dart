import 'package:flutter/material.dart';

import '../persona/components_v3/panel_v3.dart';
import '../theme/v4_token_registry.dart';

class AdviceSummaryV1 extends StatelessWidget {
  const AdviceSummaryV1({
    super.key,
    required this.topItem,
    required this.shortSummaryText,
  });

  final Map<String, Object?>? topItem;
  final String? shortSummaryText;

  @override
  Widget build(BuildContext context) {
    if ((topItem == null || topItem!.isEmpty) &&
        (shortSummaryText == null || shortSummaryText!.isEmpty)) {
      return const SizedBox.shrink();
    }
    final tokens = const V4TokenRegistry();
    final spacing = tokens.v4SpacingSmall;
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final bodyStyle = theme.textTheme.bodySmall;
    final question = _asString(topItem?['question']);
    final summary = shortSummaryText?.trim();
    return PanelV3(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null && summary.isNotEmpty)
              Text(summary, style: titleStyle),
            if (question.isNotEmpty) ...[
              SizedBox(height: spacing),
              Text('Question: $question', style: bodyStyle),
            ],
          ],
        ),
      ),
    );
  }

  String _asString(Object? value) =>
      value is String ? value : (value?.toString() ?? '');
}

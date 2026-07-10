import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

class Act0ActionRecommendationSurfaceV1 extends StatelessWidget {
  const Act0ActionRecommendationSurfaceV1({
    super.key,
    required this.recommendation,
    this.compact = false,
  });

  final Act0ActionRecommendationV1 recommendation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_action_recommendation_surface'),
      margin: EdgeInsets.only(
        top: compact ? Act0ShellTokensV1.gapXs : Act0ShellTokensV1.gapSm,
      ),
      padding: EdgeInsets.all(
        compact ? Act0ShellTokensV1.gapXs : Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Semantics(
        label: 'Next recommendation: ${recommendation.explanation}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact) Text('Next step', style: Act0ShellTokensV1.label),
            if (!compact) const SizedBox(height: 4),
            Text(
              recommendation.explanation,
              key: const Key('act0_action_recommendation_explanation'),
              maxLines: compact ? 2 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: Act0ShellTokensV1.body,
            ),
          ],
        ),
      ),
    );
  }
}

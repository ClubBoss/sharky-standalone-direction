import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

enum Act0LearningScenePhaseV3 {
  theory,
  tableTask,
  feedbackCorrect,
  feedbackWrong,
}

/// The single compact teaching/task layer attached to the learning table.
///
/// This is intentionally not another card. The left rule and open background
/// make the copy read as table context while the table remains the scene's
/// dominant object.
class Act0LearningSceneGuideV3 extends StatelessWidget {
  const Act0LearningSceneGuideV3({
    super.key,
    required this.phase,
    required this.eyebrow,
    required this.headline,
    required this.support,
    this.focusLabel,
    this.progressLabel,
  });

  final Act0LearningScenePhaseV3 phase;
  final String eyebrow;
  final String headline;
  final String support;
  final String? focusLabel;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final tone = switch (phase) {
      Act0LearningScenePhaseV3.feedbackWrong => const Color(0xFFFFC46B),
      Act0LearningScenePhaseV3.feedbackCorrect => Act0ShellTokensV1.primary,
      Act0LearningScenePhaseV3.theory => Act0ShellTokensV1.info,
      Act0LearningScenePhaseV3.tableTask => Act0ShellTokensV1.primary,
    };
    final icon = switch (phase) {
      Act0LearningScenePhaseV3.theory => Icons.visibility_rounded,
      Act0LearningScenePhaseV3.tableTask => Icons.touch_app_rounded,
      Act0LearningScenePhaseV3.feedbackCorrect => Icons.check_rounded,
      Act0LearningScenePhaseV3.feedbackWrong => Icons.search_rounded,
    };
    final scaler = MediaQuery.textScalerOf(context);
    final enlarged = scaler.scale(1) > 1.1;

    return Semantics(
      container: true,
      label: '$eyebrow. $headline. $support',
      child: Container(
        key: const Key('act0_wave_a_learning_context'),
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 2, 14, 1),
        padding: EdgeInsets.fromLTRB(12, enlarged ? 8 : 6, 8, enlarged ? 9 : 7),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: tone, width: 3)),
          gradient: LinearGradient(
            colors: <Color>[tone.withValues(alpha: 0.11), Colors.transparent],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: tone),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          eyebrow,
                          key: const Key('act0_integrated_scene_purpose'),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: tone,
                            fontSize: 10.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.65,
                          ),
                        ),
                      ),
                      if ((progressLabel ?? '').trim().isNotEmpty)
                        Text(
                          progressLabel!,
                          key: const Key('act0_learning_scene_v3_progress'),
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.textMuted,
                            fontSize: 9.4,
                            letterSpacing: 0,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    headline,
                    key: const Key('act0_integrated_scene_prompt'),
                    maxLines: enlarged ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: enlarged ? 15.2 : 16.0,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  if (support.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      support,
                      key: const Key('act0_learning_scene_v3_support'),
                      maxLines: enlarged ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Act0ShellTokensV1.muted.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        fontSize: enlarged ? 12.2 : 11.4,
                        height: 1.16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if ((focusLabel ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.south_rounded, size: 12, color: tone),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            focusLabel!,
                            key: const Key('act0_learning_scene_v3_focus'),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: tone,
                              fontSize: 9.8,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

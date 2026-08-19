import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

enum Act0LearningScenePhaseV3 {
  theory,
  tableTask,
  feedbackCorrect,
  feedbackWrong,
}

/// Deterministic Sharky Coach Surface treatment for a given B5 attention
/// phase. Reuses the existing attention-phase truth the scene already
/// resolves for table salience, so coach ownership can never disagree with
/// scene state: no new state machine, no inference from rendered copy.
///
/// `avatarSize` of `0` means Sharky renders no header avatar at all — the
/// restrained treatment for every DECIDE-family moment (`theory`,
/// `decision`, the in-task `repair` retry, and the reduced-scaffold
/// `recheck` retry): the learner must still read the table, so the scene
/// stays exactly as quiet as before this surface existed. Only the two
/// feedback phases — `correctFeedback` (UNDERSTAND) and `wrongFeedback`
/// (REPAIR, the strongest state) — earn a visible speaking-owner avatar,
/// which is exactly where the mission asks Sharky to "become clearly
/// present as the owner of the explanation".
({Act0SharkyCompanionStateV1 state, double avatarSize})
act0SharkySceneCoachTreatmentForAttentionPhaseV1(
  Act0SceneAttentionPhaseV1 phase,
) {
  return switch (phase) {
    Act0SceneAttentionPhaseV1.theory => (
      state: Act0SharkyCompanionStateV1.neutral,
      avatarSize: 0.0,
    ),
    Act0SceneAttentionPhaseV1.decision => (
      state: Act0SharkyCompanionStateV1.neutral,
      avatarSize: 0.0,
    ),
    Act0SceneAttentionPhaseV1.repair => (
      state: Act0SharkyCompanionStateV1.coach,
      avatarSize: 0.0,
    ),
    Act0SceneAttentionPhaseV1.recheck => (
      state: Act0SharkyCompanionStateV1.coach,
      avatarSize: 0.0,
    ),
    Act0SceneAttentionPhaseV1.correctFeedback => (
      state: Act0SharkyCompanionStateV1.confirm,
      avatarSize: 40.0,
    ),
    Act0SceneAttentionPhaseV1.wrongFeedback => (
      state: Act0SharkyCompanionStateV1.repair,
      avatarSize: 52.0,
    ),
  };
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
    required this.attentionPhase,
    required this.eyebrow,
    required this.headline,
    required this.support,
    this.focusLabel,
    this.progressLabel,
  });

  final Act0LearningScenePhaseV3 phase;

  /// The existing B5 attention-phase truth. Drives Sharky's Coach Surface
  /// scaffold level (avatar presence/size) so the coach ownership reads as
  /// the scene's own state rather than a second, independent inference.
  final Act0SceneAttentionPhaseV1 attentionPhase;
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
    final scaler = MediaQuery.textScalerOf(context);
    final enlarged = scaler.scale(1) > 1.1;
    final coachTreatment = act0SharkySceneCoachTreatmentForAttentionPhaseV1(
      attentionPhase,
    );

    return Semantics(
      container: true,
      label: '$eyebrow. $headline. $support',
      child: Container(
        key: const Key('act0_wave_a_learning_context'),
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 1, 14, 1),
        padding: EdgeInsets.fromLTRB(
          12,
          enlarged ? 6 : 5,
          10,
          enlarged ? 7 : 6,
        ),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: tone, width: 3)),
          gradient: LinearGradient(
            colors: <Color>[tone.withValues(alpha: 0.11), Colors.transparent],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (coachTreatment.avatarSize > 0) ...[
              ExcludeSemantics(
                child: Act0SharkyCompanionAvatarV1(
                  key: const Key('act0_shell_learning_scene_sharky_avatar'),
                  state: coachTreatment.state,
                  size: coachTreatment.avatarSize,
                  simpleFrame: true,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
            ],
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

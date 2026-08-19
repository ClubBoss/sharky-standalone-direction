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

/// Presentation-only scaffold tier for a given B5 attention phase.
///
/// This governs *how much room Sharky's presence takes* — visibility,
/// relative size, and whether the guide earns the stronger "spoken" card
/// treatment — never *what Sharky is claiming*. Semantic truth (confirm /
/// repair / coach / neutral) is owned exclusively by the existing
/// evidence-gated [act0ResolveSharkyCompanionStateV1] resolver via
/// [act0SharkySceneCoachStateV1]; this function must never be used to
/// infer or manufacture that truth.
enum Act0SharkyCoachScaffoldTierV1 {
  /// DECIDE-family moments where the learner must still read the table
  /// unaided: no avatar at all, byte-identical to the pre-Coach-Surface
  /// guide.
  off,

  /// RECHECK/PROVE: Sharky stays present for continuity but visibly
  /// smaller and plainer than any coached state — the reduced-scaffold
  /// floor.
  quiet,

  /// UNDERSTAND / REPAIR: Sharky reads as the scene's speaking coach —
  /// larger avatar, and (when the resolved state carries real evidence)
  /// the notch-and-tint "spoken" card around the existing copy.
  spoken,
}

({Act0SharkyCoachScaffoldTierV1 tier, double avatarSize})
act0SharkySceneCoachScaffoldForAttentionPhaseV1(
  Act0SceneAttentionPhaseV1 phase,
) {
  return switch (phase) {
    Act0SceneAttentionPhaseV1.theory => (
      tier: Act0SharkyCoachScaffoldTierV1.off,
      avatarSize: 0.0,
    ),
    Act0SceneAttentionPhaseV1.decision => (
      tier: Act0SharkyCoachScaffoldTierV1.off,
      avatarSize: 0.0,
    ),
    Act0SceneAttentionPhaseV1.recheck => (
      tier: Act0SharkyCoachScaffoldTierV1.quiet,
      avatarSize: 22.0,
    ),
    Act0SceneAttentionPhaseV1.repair => (
      tier: Act0SharkyCoachScaffoldTierV1.spoken,
      avatarSize: 46.0,
    ),
    Act0SceneAttentionPhaseV1.correctFeedback => (
      tier: Act0SharkyCoachScaffoldTierV1.spoken,
      avatarSize: 40.0,
    ),
    Act0SceneAttentionPhaseV1.wrongFeedback => (
      tier: Act0SharkyCoachScaffoldTierV1.spoken,
      avatarSize: 52.0,
    ),
  };
}

/// The single semantic-truth owner for the Coach Surface: routes the
/// caller's already-resolved structured evidence through the existing,
/// canonical [act0ResolveSharkyCompanionStateV1] contract instead of
/// inferring a companion state from the attention phase or from any
/// rendered copy. Missing or mismatched evidence resolves `neutral`
/// exactly as the resolver already guarantees ("fail closed").
///
/// - `hasDirectObservationEvidence`: true only when a real source-backed
///   signal proof (a clue actually marked on the table) backs this
///   correct/wrong feedback moment.
/// - `hasOpenRepairTargetEvidence`: true only when a real, source-backed
///   repair-target reason backs the in-task targeted-repair retry.
///
/// `theory`, `decision`, and `recheck` have no matching moment in the
/// existing coach-phrase vocabulary — they resolve through the same
/// resolver with a `welcome` context, which is already proven (by
/// [act0ResolveSharkyCompanionStateV1]'s own contract) to resolve
/// `neutral`, so "no claim here" is the resolver's guarantee rather than
/// an assertion made in this function.
Act0SharkyCompanionStateV1 act0SharkySceneCoachStateV1({
  required Act0SceneAttentionPhaseV1 attentionPhase,
  required bool hasDirectObservationEvidence,
  required bool hasOpenRepairTargetEvidence,
}) {
  final context = switch (attentionPhase) {
    Act0SceneAttentionPhaseV1.correctFeedback => Act0SharkyCoachPhraseContextV1(
      surface: Act0SharkyCoachSurfaceV1.feedback,
      momentType: Act0SharkyCoachMomentTypeV1.decisionCorrect,
      evidenceKind: hasDirectObservationEvidence
          ? Act0SharkyCoachEvidenceKindV1.directObservation
          : Act0SharkyCoachEvidenceKindV1.none,
    ),
    Act0SceneAttentionPhaseV1.wrongFeedback => Act0SharkyCoachPhraseContextV1(
      surface: Act0SharkyCoachSurfaceV1.feedback,
      momentType: Act0SharkyCoachMomentTypeV1.decisionIncorrect,
      evidenceKind: hasDirectObservationEvidence
          ? Act0SharkyCoachEvidenceKindV1.directObservation
          : Act0SharkyCoachEvidenceKindV1.none,
    ),
    Act0SceneAttentionPhaseV1.repair => Act0SharkyCoachPhraseContextV1(
      surface: Act0SharkyCoachSurfaceV1.review,
      momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
      evidenceKind: hasOpenRepairTargetEvidence
          ? Act0SharkyCoachEvidenceKindV1.repairTarget
          : Act0SharkyCoachEvidenceKindV1.none,
      repairState: hasOpenRepairTargetEvidence
          ? Act0SharkyCoachRepairStateV1.open
          : Act0SharkyCoachRepairStateV1.none,
    ),
    Act0SceneAttentionPhaseV1.theory ||
    Act0SceneAttentionPhaseV1.decision ||
    Act0SceneAttentionPhaseV1.recheck => const Act0SharkyCoachPhraseContextV1(
      surface: Act0SharkyCoachSurfaceV1.play,
      momentType: Act0SharkyCoachMomentTypeV1.welcome,
    ),
  };
  return act0ResolveSharkyCompanionStateV1(context);
}

/// The notch-and-tint "spoken" treatment: reuses the exact speech-notch
/// geometry [Act0SharkyPresenceBubbleV1] already established elsewhere in
/// the app, so the guide reads as the same Sharky-is-speaking grammar
/// rather than a new card style. Applied only when the resolved companion
/// state carries real evidence, so it can never assert a claim the
/// resolver did not back.
class _Act0SharkySpokenSurfaceV1 extends StatelessWidget {
  const _Act0SharkySpokenSurfaceV1({required this.tone, required this.child});

  final Color tone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -7,
          top: 16,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.10),
                border: Border(
                  left: BorderSide(color: tone.withValues(alpha: 0.32)),
                  bottom: BorderSide(color: tone.withValues(alpha: 0.32)),
                ),
              ),
            ),
          ),
        ),
        Container(
          key: const Key('act0_shell_learning_scene_sharky_spoken_surface'),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            border: Border.all(color: tone.withValues(alpha: 0.32)),
          ),
          child: child,
        ),
      ],
    );
  }
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
    required this.sharkyState,
    this.growthStage = Act0SharkyGrowthStageV1.foundation,
    required this.eyebrow,
    required this.headline,
    required this.support,
    this.focusLabel,
    this.progressLabel,
  });

  final Act0LearningScenePhaseV3 phase;

  /// The existing B5 attention-phase truth. Presentation only: it selects
  /// Sharky's scaffold tier (visibility/size), never the semantic claim —
  /// see [Act0SharkyCoachScaffoldTierV1].
  final Act0SceneAttentionPhaseV1 attentionPhase;

  /// The semantic truth, already resolved by the caller from real
  /// structured evidence via [act0SharkySceneCoachStateV1] (which itself
  /// only wraps the canonical [act0ResolveSharkyCompanionStateV1]
  /// contract). This widget never re-derives or overrides it.
  final Act0SharkyCompanionStateV1 sharkyState;

  /// Sharky's persistent growth stage — a separate axis from [sharkyState].
  /// Callers pass the canonical resolved stage (see
  /// [act0SharkyGrowthStageForWorldNumberV1]), never a style token. Defaults
  /// to [Act0SharkyGrowthStageV1.foundation] only for callers that have not
  /// wired the canonical resolver.
  final Act0SharkyGrowthStageV1 growthStage;
  final String eyebrow;
  final String headline;
  final String support;
  final String? focusLabel;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final phaseTone = switch (phase) {
      Act0LearningScenePhaseV3.feedbackWrong => const Color(0xFFFFC46B),
      Act0LearningScenePhaseV3.feedbackCorrect => Act0ShellTokensV1.primary,
      Act0LearningScenePhaseV3.theory => Act0ShellTokensV1.info,
      Act0LearningScenePhaseV3.tableTask => Act0ShellTokensV1.primary,
    };
    final scaler = MediaQuery.textScalerOf(context);
    final enlarged = scaler.scale(1) > 1.1;
    final scaffold = act0SharkySceneCoachScaffoldForAttentionPhaseV1(
      attentionPhase,
    );
    final isEvidenceBacked = sharkyState != Act0SharkyCompanionStateV1.neutral;
    // Evidence-backed tone reads as Sharky's own claim; unclaimed moments
    // keep the scene's own phase tone exactly as before this surface
    // existed, so a missing/mismatched evidence context can never borrow a
    // coaching color it did not earn.
    final tone = isEvidenceBacked
        ? act0SharkyToneForMoodV1(
            act0SharkyMoodForCompanionStateV1(sharkyState),
          )
        : phaseTone;
    final showAvatar = scaffold.tier != Act0SharkyCoachScaffoldTierV1.off;
    final showSpokenSurface =
        scaffold.tier == Act0SharkyCoachScaffoldTierV1.spoken &&
        isEvidenceBacked;

    final content = Column(
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
          border: Border(left: BorderSide(color: phaseTone, width: 3)),
          gradient: LinearGradient(
            colors: <Color>[
              phaseTone.withValues(alpha: 0.11),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showAvatar) ...[
              ExcludeSemantics(
                child: Act0SharkyCompanionAvatarV1(
                  key: const Key('act0_shell_learning_scene_sharky_avatar'),
                  state: sharkyState,
                  size: scaffold.avatarSize,
                  simpleFrame: true,
                  growthStage: growthStage,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
            ],
            Expanded(
              child: showSpokenSurface
                  ? _Act0SharkySpokenSurfaceV1(tone: tone, child: content)
                  : content,
            ),
          ],
        ),
      ),
    );
  }
}

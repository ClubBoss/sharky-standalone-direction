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
  feedbackSuboptimal,
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
          top: 24,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.surface.withValues(alpha: 0.98),
                border: Border(
                  left: BorderSide(color: tone.withValues(alpha: 0.34)),
                  bottom: BorderSide(color: tone.withValues(alpha: 0.34)),
                ),
              ),
            ),
          ),
        ),
        Container(
          key: const Key('act0_shell_learning_scene_sharky_spoken_surface'),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            border: Border.all(color: tone.withValues(alpha: 0.34)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: tone.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

/// The single compact teaching/task layer attached to the learning table.
///
/// The prompt sits on the scene's upper chrome. In the registered feedback
/// shelf, the reason leads and the table remains in view.
class Act0LearningSceneGuideV3 extends StatelessWidget {
  const Act0LearningSceneGuideV3({
    super.key,
    required this.phase,
    required this.sharkyState,
    this.isAssistedFeedback = false,
    required this.eyebrow,
    required this.headline,
    required this.support,
    this.scrollSupport = false,
    this.focusPointsUp = false,
    this.focusLabel,
    this.progressLabel,
  });

  final Act0LearningScenePhaseV3 phase;

  /// The semantic truth, already resolved by the caller from real
  /// structured evidence via [act0SharkySceneCoachStateV1] (which itself
  /// only wraps the canonical [act0ResolveSharkyCompanionStateV1]
  /// contract). This widget never re-derives or overrides it.
  final Act0SharkyCompanionStateV1 sharkyState;

  final bool isAssistedFeedback;
  final String eyebrow;
  final String headline;
  final String support;
  // Opt in only for complete source-owned model premises, never answer hints.
  final bool scrollSupport;
  final bool focusPointsUp;
  final String? focusLabel;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final phaseTone = switch (phase) {
      Act0LearningScenePhaseV3.feedbackWrong => const Color(0xFFFFC46B),
      Act0LearningScenePhaseV3.feedbackCorrect => Act0ShellTokensV1.primary,
      Act0LearningScenePhaseV3.feedbackSuboptimal => Act0ShellTokensV1.info,
      Act0LearningScenePhaseV3.theory => Act0ShellTokensV1.info,
      Act0LearningScenePhaseV3.tableTask => Act0ShellTokensV1.primary,
    };
    final scaler = MediaQuery.textScalerOf(context);
    final enlarged = scaler.scale(1) > 1.1;
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
    final feedbackRingTone = switch (phase) {
      Act0LearningScenePhaseV3.feedbackWrong =>
        Act0ShellTokensV1.repairAttention,
      Act0LearningScenePhaseV3.feedbackCorrect =>
        isAssistedFeedback
            ? Act0ShellTokensV1.info
            : Act0ShellTokensV1.successProof,
      Act0LearningScenePhaseV3.feedbackSuboptimal => Act0ShellTokensV1.info,
      Act0LearningScenePhaseV3.theory ||
      Act0LearningScenePhaseV3.tableTask => null,
    };
    final showSpokenSurface = feedbackRingTone != null && isEvidenceBacked;
    final compactFeedback = focusPointsUp && feedbackRingTone != null;
    final hasReason = compactFeedback && support.trim().isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow.isNotEmpty || (progressLabel ?? '').trim().isNotEmpty) ...[
          Row(
            children: [
              if (showSpokenSurface) ...[
                Text(
                  'Sharky',
                  key: const Key('act0_learning_scene_v3_coach_owner'),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: tone,
                    fontSize: 11.4,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Expanded(
                child: eyebrow.isEmpty
                    ? const SizedBox.shrink()
                    : Text(
                        eyebrow,
                        key: const Key('act0_integrated_scene_purpose'),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Act0ShellTokensV1.label.copyWith(
                          color:
                              showSpokenSurface ||
                                  phase == Act0LearningScenePhaseV3.tableTask
                              ? Act0ShellTokensV1.textMuted
                              : tone,
                          fontSize: showSpokenSurface ? 8.8 : 10.2,
                          fontWeight: FontWeight.w900,
                          letterSpacing: showSpokenSurface ? 0.35 : 0.65,
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
          SizedBox(height: showSpokenSurface ? 3 : 2),
        ],
        if (hasReason) ...[
          Text(
            support,
            key: const Key('act0_learning_scene_v3_support'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: enlarged ? 14 : 13,
              fontWeight: FontWeight.w700,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Text(
          headline,
          key: const Key('act0_integrated_scene_prompt'),
          maxLines: focusPointsUp
              ? null
              : showSpokenSurface
              ? 3
              : (enlarged ? 3 : 2),
          overflow: focusPointsUp
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: Act0ShellTokensV1.body.copyWith(
            color: hasReason
                ? Act0ShellTokensV1.textMuted
                : Act0ShellTokensV1.text,
            fontSize: hasReason
                ? 12
                : showSpokenSurface
                ? (enlarged ? 15.4 : 16.4)
                : (enlarged ? 15.2 : 16.0),
            fontWeight: hasReason ? FontWeight.w700 : FontWeight.w900,
            height: showSpokenSurface ? 1.10 : 1.08,
          ),
        ),
        if (!hasReason && support.trim().isNotEmpty) ...[
          SizedBox(height: showSpokenSurface ? 4 : 3),
          // Preserve the existing compact overlay footprint while letting
          // learners read the complete authored theory rather than ellipsizing
          // source teaching facts. The physical table remains unchanged.
          if (phase == Act0LearningScenePhaseV3.theory || scrollSupport)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    (phase == Act0LearningScenePhaseV3.theory ? 4 : 2) *
                    scaler.scale(enlarged ? 12.2 : 11.4) *
                    1.16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: Key(
                        scrollSupport
                            ? 'act0_learning_scene_v3_model_support_scroll'
                            : 'act0_learning_scene_v3_theory_support_scroll',
                      ),
                      physics: const ClampingScrollPhysics(),
                      child: Text(
                        support,
                        key: const Key('act0_learning_scene_v3_support'),
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          fontSize: enlarged ? 12.2 : 11.4,
                          height: 1.16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.unfold_more_rounded, size: 14, color: phaseTone),
                ],
              ),
            )
          else
            Text(
              support,
              key: const Key('act0_learning_scene_v3_support'),
              maxLines: focusPointsUp
                  ? null
                  : showSpokenSurface
                  ? 3
                  : (enlarged ? 3 : 2),
              overflow: focusPointsUp
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: showSpokenSurface
                    ? (enlarged ? 12.0 : 11.8)
                    : (enlarged ? 12.2 : 11.4),
                height: showSpokenSurface ? 1.18 : 1.16,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
        if ((focusLabel ?? '').trim().isNotEmpty) ...[
          SizedBox(height: showSpokenSurface ? 6 : 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: showSpokenSurface ? 1 : 0),
                child: Icon(
                  focusPointsUp ? Icons.north_rounded : Icons.south_rounded,
                  size: showSpokenSurface ? 13 : 12,
                  color: tone,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  focusLabel!,
                  key: const Key('act0_learning_scene_v3_focus'),
                  maxLines: showSpokenSurface ? 2 : 1,
                  overflow: TextOverflow.fade,
                  softWrap: showSpokenSurface,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: tone,
                    fontSize: showSpokenSurface ? 10.2 : 9.8,
                    height: showSpokenSurface ? 1.14 : null,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );

    final guideBody = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (feedbackRingTone != null) ...[
          ExcludeSemantics(
            child: Container(
              key: const Key('act0_shell_learning_scene_sharky_avatar'),
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: feedbackRingTone, width: 2),
              ),
              child: Act0SharkyPresenceMascotV1(
                mood: act0SharkyMoodForCompanionStateV1(
                  Act0SharkyCompanionStateV1.neutral,
                ),
                tone: feedbackRingTone,
                size: 44,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: showSpokenSurface && !compactFeedback
              ? _Act0SharkySpokenSurfaceV1(tone: tone, child: content)
              : content,
        ),
      ],
    );

    final detachedSpeechBubble = showSpokenSurface && !compactFeedback;
    final darkPromptSurface =
        compactFeedback ||
        phase == Act0LearningScenePhaseV3.theory ||
        (phase == Act0LearningScenePhaseV3.tableTask && !focusPointsUp);
    return Semantics(
      container: true,
      explicitChildNodes: focusPointsUp,
      label: focusPointsUp
          ? null
          : [
              eyebrow,
              headline,
              support,
            ].where((line) => line.trim().isNotEmpty).join('. '),
      child: Container(
        key: const Key('act0_wave_a_learning_context'),
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(
          detachedSpeechBubble ? 10 : 14,
          detachedSpeechBubble ? 3 : 1,
          detachedSpeechBubble ? 10 : 14,
          detachedSpeechBubble ? 3 : 1,
        ),
        padding: detachedSpeechBubble
            ? const EdgeInsets.fromLTRB(2, 2, 2, 2)
            : EdgeInsets.fromLTRB(12, enlarged ? 6 : 5, 10, enlarged ? 7 : 6),
        decoration: detachedSpeechBubble
            ? null
            : BoxDecoration(
                border: Border(left: BorderSide(color: phaseTone, width: 3)),
                gradient: LinearGradient(
                  colors: darkPromptSurface
                      ? <Color>[
                          Act0ShellTokensV1.surface.withValues(alpha: 0.95),
                          Act0ShellTokensV1.surface.withValues(alpha: 0.88),
                        ]
                      : <Color>[
                          phaseTone.withValues(alpha: 0.11),
                          Colors.transparent,
                        ],
                ),
              ),
        child: guideBody,
      ),
    );
  }
}

import 'package:flutter/semantics.dart';
import 'act0_accessibility_semantics_v1.dart';
import 'act0_glossary_sheet_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_reading_style_v1.dart';
import 'dart:async';
import 'act0_predecision_card_focus_v1.dart';
import 'act0_prechoice_answer_cue_policy_v1.dart';
import 'act0_scene_profile_v1.dart';
import 'act0_f7_scene_source_v1.dart';
import 'act0_f7_scene_gate_v1.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hud_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_room_plate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_recommendation_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_causal_feedback_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_ids_v1.dart';

part 'act0_lesson_runner_surfaces_v1.dart';
part 'act0_lesson_runner_scene_v1.dart';
part 'act0_lesson_runner_feedback_v1.dart';
part 'act0_lesson_runner_completion_v1.dart';
part 'act0_lesson_runner_table_v1.dart';
part 'act0_lesson_runner_seats_v1.dart';
part 'act0_lesson_runner_actions_v1.dart';

enum Act0ShellTableVisualVariantV1 { classic, refinedDev2 }

enum Act0ProgressMilestoneTierV1 { lesson, world }

enum Act0TheoryPresentationRoleV1 {
  tableReading,
  conceptIntro,
  actionPrep,
  recapCheck,
  denseSynthesis,
}

/// A small, source-owned late-route cue shown only on the shared table stage.
/// It gives W11/W12 a distinct learning posture without changing a task,
/// answer, progression state, or completion route.
class Act0LateRouteTableSignalV1 {
  const Act0LateRouteTableSignalV1({
    required this.label,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String detail;
  final IconData icon;
}

Act0LateRouteTableSignalV1? act0LateRouteTableSignalForWorldNumberV1(
  int worldNumber,
) {
  return switch (worldNumber) {
    11 => const Act0LateRouteTableSignalV1(
      label: 'W11 \u00B7 Transfer',
      detail: 'Name the cue. Choose one action.',
      icon: Icons.alt_route_rounded,
    ),
    12 => const Act0LateRouteTableSignalV1(
      label: 'W12 \u00B7 Reset',
      detail: 'Drop last hand. Read spot.',
      icon: Icons.restart_alt_rounded,
    ),
    _ => null,
  };
}

enum Act0MilestoneCtaKindV1 {
  continueForward,
  replayForPerfect,
  reviewFirst,
  reviewForPerfect,
  backToMap,
}

const String _wave1bFeedbackBridgeLegacyLabelV1 = 'Table evidence';

Act0TheoryPresentationRoleV1 resolveAct0TheoryPresentationRoleV1({
  String? taskId,
  required Act0RunnerStateV1 runner,
  required int teachingStepIndex,
}) {
  final normalizedTaskId =
      (taskId?.trim().isNotEmpty == true ? taskId!.trim() : runner.lessonId)
          .toLowerCase();
  if (normalizedTaskId.endsWith('what_poker_is_theory')) {
    return teachingStepIndex <= 0
        ? Act0TheoryPresentationRoleV1.conceptIntro
        : Act0TheoryPresentationRoleV1.tableReading;
  }
  if (normalizedTaskId.endsWith('your_first_hand_preflop') ||
      normalizedTaskId.endsWith('blinds_theory')) {
    return Act0TheoryPresentationRoleV1.tableReading;
  }
  if (normalizedTaskId.endsWith('seat_order_decision')) {
    return Act0TheoryPresentationRoleV1.denseSynthesis;
  }
  if (normalizedTaskId.endsWith('actions_theory') ||
      normalizedTaskId.endsWith('hand_discipline_buckets_intro') ||
      normalizedTaskId.endsWith('continue_intro') ||
      normalizedTaskId.endsWith('discipline_intro') ||
      normalizedTaskId.endsWith('position_apply_intro')) {
    return Act0TheoryPresentationRoleV1.actionPrep;
  }
  if (normalizedTaskId.endsWith('apply_intro') ||
      normalizedTaskId.endsWith('checkpoint_intro') ||
      normalizedTaskId.endsWith('showdown_theory')) {
    return Act0TheoryPresentationRoleV1.recapCheck;
  }
  if (normalizedTaskId.endsWith('cards_ranks_suits_theory') ||
      normalizedTaskId.endsWith('positions_theory') ||
      normalizedTaskId.endsWith('button_intro') ||
      normalizedTaskId.endsWith('position_checkpoint_intro') ||
      normalizedTaskId.endsWith('hand_rankings_theory')) {
    return Act0TheoryPresentationRoleV1.conceptIntro;
  }
  return Act0TheoryPresentationRoleV1.tableReading;
}

class Act0RunnerCompletionSummaryV1 {
  const Act0RunnerCompletionSummaryV1({
    required this.xpGain,
    required this.startLevel,
    required this.endLevel,
    required this.startXp,
    required this.endXp,
    required this.xpTarget,
    this.skillGains = const <Act0SkillGainV1>[],
  });

  final int xpGain;
  final int startLevel;
  final int endLevel;
  final int startXp;
  final int endXp;
  final int xpTarget;
  final List<Act0SkillGainV1> skillGains;

  bool get leveledUp => endLevel > startLevel;

  String get toastRewardLabel => leveledUp ? 'Level up' : 'Clean rep';

  String get growthLabel => _formatSkillGrowthLabelV1(skillGains);
}

class Act0FeedbackSignalProofV1 {
  const Act0FeedbackSignalProofV1({
    required this.signalId,
    required this.label,
    required this.proofLine,
    this.seatIds = const <String>[],
    this.cardIds = const <String>[],
    this.statKeys = const <String>[],
  });

  final String signalId;
  final String label;
  final String proofLine;
  final List<String> seatIds;
  final List<String> cardIds;
  final List<String> statKeys;
}

enum Act0SkillReceiptOutcomeV1 { learned, repairStarted, needsRep }

class Act0SkillReceiptV1 {
  const Act0SkillReceiptV1({
    required this.skillAtomId,
    required this.skillLabel,
    required this.sourceSignalId,
    required this.sourceSignalLabel,
    required this.outcome,
    required this.nextRepId,
    required this.nextRepLabel,
  });

  final String skillAtomId;
  final String skillLabel;
  final String sourceSignalId;
  final String sourceSignalLabel;
  final Act0SkillReceiptOutcomeV1 outcome;
  final String nextRepId;
  final String nextRepLabel;

  String get receiptId =>
      '${skillAtomId}_${outcome.telemetryValue}_$sourceSignalId';

  String get outcomeId => outcome.telemetryValue;

  String get title {
    return switch (outcome) {
      Act0SkillReceiptOutcomeV1.learned => 'Correct answer recorded',
      Act0SkillReceiptOutcomeV1.repairStarted => 'Good spot to repair',
      Act0SkillReceiptOutcomeV1.needsRep => 'One more read will help',
    };
  }

  String get detail => switch (outcome) {
    Act0SkillReceiptOutcomeV1.learned =>
      'Your answer matched the check for $sourceSignalLabel.',
    Act0SkillReceiptOutcomeV1.repairStarted =>
      'The missed table clue was $sourceSignalLabel.',
    Act0SkillReceiptOutcomeV1.needsRep =>
      'Notice $sourceSignalLabel once more before adding speed.',
  };
}

extension on Act0SkillReceiptOutcomeV1 {
  String get telemetryValue => switch (this) {
    Act0SkillReceiptOutcomeV1.learned => 'learned',
    Act0SkillReceiptOutcomeV1.repairStarted => 'repair_started',
    Act0SkillReceiptOutcomeV1.needsRep => 'needs_rep',
  };
}

class Act0BlockCompletionSummaryV1 {
  const Act0BlockCompletionSummaryV1({
    required this.lessonTitle,
    required this.xpEarned,
    required this.errorCount,
    this.assistedCount = 0,
    this.independentProvenanceKnown = true,
    this.curriculumCompleted = false,
    required this.taskCount,
    required this.correctCount,
    required this.startLevel,
    required this.endLevel,
    required this.startXp,
    required this.endXp,
    required this.xpTarget,
    this.sharkyLine = '',
    this.nextLessonTitle,
    this.quickFixCount = 0,
    this.deepLeakCount = 0,
    this.skillGains = const <Act0SkillGainV1>[],
    this.milestoneTier = Act0ProgressMilestoneTierV1.lesson,
    this.worldNumber = 0,
    this.worldTitle = '',
    this.nextWorldNumber,
    this.nextWorldTitle,
    this.perfectClearCount = 0,
    this.completedClearCount = 0,
    this.hasSafeReviewTarget = false,
    this.hasReplayForPerfectTarget = false,
    this.futureRecheckCount = 0,
    this.futureProveCount = 0,
  });

  static const int unlockAccuracyPercent = 80;

  final bool curriculumCompleted;

  final String lessonTitle;
  final int xpEarned;
  final int errorCount;

  /// Count of tasks where the learner used Quick Hint or Theory Recall.
  /// Accuracy remains answer correctness; independent proof is distinct.
  final int assistedCount;
  final bool independentProvenanceKnown;
  final int taskCount;
  final int correctCount;
  final int startLevel;
  final int endLevel;
  final int startXp;
  final int endXp;
  final int xpTarget;
  final String sharkyLine;
  final String? nextLessonTitle;
  final int quickFixCount;
  final int deepLeakCount;
  final List<Act0SkillGainV1> skillGains;
  final Act0ProgressMilestoneTierV1 milestoneTier;
  final int worldNumber;
  final String worldTitle;
  final int? nextWorldNumber;
  final String? nextWorldTitle;
  final int perfectClearCount;
  final int completedClearCount;
  final bool hasSafeReviewTarget;
  final bool hasReplayForPerfectTarget;
  final int futureRecheckCount;
  final int futureProveCount;

  bool get hasNextLesson =>
      nextLessonTitle != null && nextLessonTitle!.isNotEmpty;

  bool get isWorldComplete =>
      milestoneTier == Act0ProgressMilestoneTierV1.world &&
      worldNumber > 0 &&
      worldTitle.trim().isNotEmpty;

  bool get hasPerfectGap =>
      completedClearCount > 0 && perfectClearCount < completedClearCount;

  bool get hasForwardPath =>
      hasNextLesson ||
      (isWorldComplete &&
          nextWorldTitle != null &&
          nextWorldTitle!.trim().isNotEmpty);

  bool get leveledUp => endLevel > startLevel;

  bool get hasVerifiedAssessment => independentProvenanceKnown && taskCount > 0;

  int get accuracyPercent =>
      taskCount <= 0 ? 0 : ((correctCount * 100) / taskCount).round();

  bool get qualifiesForNextLesson =>
      curriculumCompleted ||
      !hasNextLesson ||
      (hasVerifiedAssessment && accuracyPercent >= unlockAccuracyPercent);

  Act0MasteryStatusV1 get masteryStatus {
    if (deepLeakCount > 0) {
      return Act0MasteryStatusV1.needsReview;
    }
    if (!hasVerifiedAssessment) {
      return Act0MasteryStatusV1.learning;
    }
    if (errorCount == 0 && correctCount == taskCount && assistedCount == 0) {
      return Act0MasteryStatusV1.cleanPass;
    }
    if (accuracyPercent < unlockAccuracyPercent) {
      return Act0MasteryStatusV1.needsReview;
    }
    if (assistedCount > 0) {
      return Act0MasteryStatusV1.learning;
    }
    return Act0MasteryStatusV1.solid;
  }

  String get masteryLabel => switch (masteryStatus) {
    Act0MasteryStatusV1.cleanPass => 'All correct',
    Act0MasteryStatusV1.solid => 'Solid',
    Act0MasteryStatusV1.needsReview => 'Needs review',
    Act0MasteryStatusV1.learning => 'Learning',
  };

  String get milestoneTitle {
    if (!qualifiesForNextLesson) {
      return 'Almost there - replay to unlock';
    }
    return isWorldComplete ? 'World $worldNumber complete' : 'Lesson complete';
  }

  String get milestoneDetailTitle => isWorldComplete ? worldTitle : lessonTitle;

  String? get unlockedLabel {
    if (isWorldComplete) {
      if (nextWorldTitle == null ||
          nextWorldTitle!.trim().isEmpty ||
          nextWorldNumber == null ||
          nextWorldNumber! <= 0) {
        return null;
      }
      return 'Unlocked now: World $nextWorldNumber - $nextWorldTitle';
    }
    if (!hasNextLesson) {
      return null;
    }
    return 'Unlocked now: $nextLessonTitle';
  }

  String get progressStatusLabel {
    if (deepLeakCount > 0) {
      return 'Review open';
    }
    if (completedClearCount > 0 && perfectClearCount == completedClearCount) {
      return 'No misses';
    }
    if (perfectClearCount > 0 && completedClearCount > 0) {
      return '$perfectClearCount/$completedClearCount clean tasks';
    }
    if (quickFixCount > 0) {
      return 'Repairs recovered';
    }
    return masteryLabel;
  }

  List<String> get ownershipHighlights {
    if (!isWorldComplete) {
      return const <String>[];
    }
    final lines = <String>[];
    final seen = <String>{};
    for (final gain in skillGains) {
      final line = _ownershipLineForSkillLabelV1(gain.label);
      if (line == null || !seen.add(line)) {
        continue;
      }
      lines.add(line);
      if (lines.length >= 3) {
        break;
      }
    }
    return lines;
  }

  String? get primarySkillFocusLabel {
    if (!isWorldComplete || skillGains.isEmpty) {
      return null;
    }
    final ranked = skillGains.where((gain) => gain.gain > 0).toList();
    if (ranked.isEmpty) {
      return null;
    }
    ranked.sort((a, b) {
      final gainCompare = b.gain.compareTo(a.gain);
      if (gainCompare != 0) {
        return gainCompare;
      }
      return a.label.compareTo(b.label);
    });
    return ranked.first.label.trim().isEmpty ? null : ranked.first.label.trim();
  }

  List<String> get masteryPackLines {
    if (!isWorldComplete) {
      return const <String>[];
    }
    final lines = <String>[];
    final focus = primarySkillFocusLabel;
    if (focus != null) {
      lines.add('Practice focus: $focus');
    }
    if (futureRecheckCount > 0) {
      final noun = futureRecheckCount == 1 ? 'spot' : 'spots';
      lines.add('Keep ready: $futureRecheckCount quick $noun.');
    }
    if (futureProveCount > 0) {
      final noun = futureProveCount == 1 ? 'skill' : 'skills';
      lines.add('Prove again: $futureProveCount $noun without hints.');
    }
    return lines;
  }

  bool get hasMasteryPack => masteryPackLines.isNotEmpty;

  bool get hasReturnPlan => futureRecheckCount > 0 || futureProveCount > 0;

  String get returnPlanLabel {
    final focus = primarySkillFocusLabel;
    final opener = focus == null
        ? 'Plan another short practice in this world.'
        : 'Plan another short practice: $focus.';
    if (futureRecheckCount > 0 && futureProveCount > 0) {
      final spotNoun = futureRecheckCount == 1 ? 'spot' : 'spots';
      final skillNoun = futureProveCount == 1 ? 'skill' : 'skills';
      return '$opener Recheck $futureRecheckCount quick $spotNoun and prove $futureProveCount $skillNoun once.';
    }
    if (futureRecheckCount > 0) {
      final noun = futureRecheckCount == 1 ? 'spot' : 'spots';
      return '$opener Recheck $futureRecheckCount quick $noun.';
    }
    if (futureProveCount > 0) {
      final noun = futureProveCount == 1 ? 'skill' : 'skills';
      return '$opener Prove $futureProveCount $noun once.';
    }
    return opener;
  }

  String? get nextUnlockReasonLabel {
    if (!isWorldComplete ||
        nextWorldTitle == null ||
        nextWorldTitle!.trim().isEmpty) {
      return null;
    }
    return '$nextWorldTitle is the next curriculum step.';
  }

  bool get hasWorldOneCompletionPayoff =>
      isWorldComplete &&
      worldNumber == 1 &&
      nextWorldNumber == 2 &&
      nextWorldTitle != null &&
      nextWorldTitle!.trim().isNotEmpty;

  String get worldOneCompletionPayoffLabel => act0SharkyCoachLineForMomentV1(
    Act0SharkyCoachMomentV1.worldOneCompletionPayoff,
  );

  String get worldOneCompletionLearningLabel =>
      'You practiced reading the table before acting.';

  String get worldOneCompletionNextLabel =>
      'Next: ${nextWorldTitle?.trim() ?? 'Hand Discipline'}';

  String get worldOneCompletionPreviewLine =>
      'World 2 starts with a simple question: which hands deserve action?';

  String get worldOneCompletionProofFallbackLabel =>
      'Repair result saves the next time you fix one.';

  /// True only for an ordinary World 2-12 completion with valid route truth.
  /// World 1 keeps its own dedicated gate/copy above. World 12 is terminal and
  /// previews Volume I review instead of opening a future world; the special
  /// W4->W5 band transition remains separate.
  bool get hasWorldCompletionPayoff =>
      isWorldComplete &&
      worldNumber >= 2 &&
      worldNumber <= 12 &&
      (nextWorldNumber == worldNumber + 1 || worldNumber == 12) &&
      nextWorldTitle != null &&
      nextWorldTitle!.trim().isNotEmpty;

  _WorldCompletionMetaV1? get _worldCompletionMeta =>
      _worldCompletionMetaByNumberV1[worldNumber];

  String get worldCompletionPayoffLabel => act0SharkyCoachLineForMomentV1(
    Act0SharkyCoachMomentV1.worldCompletionPayoff,
    tier: act0SharkyCoachTierForWorldNumberV1(worldNumber),
  );

  String get worldCompletionLearningLabel =>
      _worldCompletionMeta?.learningLabel ?? '';

  String get worldCompletionNextLabel =>
      'Next: ${nextWorldTitle?.trim() ?? ''}';

  String get worldCompletionPreviewLine =>
      _worldCompletionMeta?.previewLine ?? '';

  String get worldCompletionProofFallbackLabel =>
      worldOneCompletionProofFallbackLabel;

  /// True only for the exact W4->W5 Foundation -> Developing Player band
  /// transition. Checked with higher priority than
  /// [hasWorldCompletionPayoff] at the render site so World 4 renders this
  /// stronger, bounded variant instead of falling through to the ordinary
  /// World 2-6 card. This gate is intentionally worldNumber == 4 only; it is
  /// not a general multi-band framework and must not be widened to cover any
  /// other world boundary.
  bool get hasBandTransitionPayoff =>
      isWorldComplete &&
      worldNumber == 4 &&
      nextWorldNumber == 5 &&
      nextWorldTitle != null &&
      nextWorldTitle!.trim().isNotEmpty;

  String get bandTransitionIdentityLabel => act0SharkyCoachLineForMomentV1(
    Act0SharkyCoachMomentV1.bandTransitionPayoff,
  ).replaceFirst(RegExp(r'\.$'), '');

  String get bandTransitionLearningLabel =>
      'You practiced reading the table, hand, action, and position before '
      'deciding.';

  String get bandTransitionNextLabel => 'Next: Developing Player';

  String get bandTransitionPreviewLine =>
      'World 5 starts connecting board texture and street changes into '
      'one plan.';

  String get bandTransitionProofFallbackLabel =>
      worldOneCompletionProofFallbackLabel;

  /// True only for the World 12 Volume I terminal completion. Checked with
  /// higher priority than [hasWorldCompletionPayoff] at the render site so
  /// World 12 renders this distinct closure card instead of the ordinary
  /// World 2-11 card. Reuses the same honest, already-accepted next-step and
  /// preview copy from [_worldCompletionMetaByNumberV1] (`Volume I review`,
  /// no fake W13 activation); only the identity headline differs so the
  /// moment reads as a closure rather than another ordinary world
  /// completion. Intentionally worldNumber == 12 only; not a general
  /// terminal framework.
  bool get hasTerminalCompletionPayoff =>
      isWorldComplete &&
      worldNumber == 12 &&
      nextWorldTitle != null &&
      nextWorldTitle!.trim().isNotEmpty;

  String get terminalCompletionIdentityLabel => 'Volume I complete.';

  String get terminalCompletionLearningLabel => worldCompletionLearningLabel;

  String get terminalCompletionNextLabel => worldCompletionNextLabel;

  String get terminalCompletionPreviewLine => worldCompletionPreviewLine;

  String get terminalCompletionProofFallbackLabel =>
      worldCompletionProofFallbackLabel;

  bool get shouldReviewFirst =>
      deepLeakCount > 0 && qualifiesForNextLesson && hasSafeReviewTarget;

  bool get shouldOfferReplayForPerfect =>
      hasPerfectGap &&
      hasReplayForPerfectTarget &&
      !hasSafeReviewTarget &&
      !shouldReviewFirst;

  bool get shouldOfferReviewForPerfect =>
      hasPerfectGap &&
      hasSafeReviewTarget &&
      !shouldReviewFirst &&
      deepLeakCount == 0;

  Act0MilestoneCtaKindV1 get primaryCtaKind {
    if (!qualifiesForNextLesson) {
      return Act0MilestoneCtaKindV1.replayForPerfect;
    }
    if (shouldReviewFirst) {
      return Act0MilestoneCtaKindV1.reviewFirst;
    }
    if (hasForwardPath) {
      return Act0MilestoneCtaKindV1.continueForward;
    }
    return Act0MilestoneCtaKindV1.backToMap;
  }

  Act0MilestoneCtaKindV1? get secondaryCtaKind {
    if (!qualifiesForNextLesson) {
      return null;
    }
    if (shouldReviewFirst) {
      return hasForwardPath ? Act0MilestoneCtaKindV1.continueForward : null;
    }
    if (shouldOfferReplayForPerfect) {
      return Act0MilestoneCtaKindV1.replayForPerfect;
    }
    if (shouldOfferReviewForPerfect) {
      return Act0MilestoneCtaKindV1.reviewForPerfect;
    }
    return null;
  }

  String get progressionCtaLabel {
    if (isWorldComplete &&
        nextWorldTitle != null &&
        nextWorldTitle!.trim().isNotEmpty) {
      return 'Open next world';
    }
    if (hasNextLesson) {
      return 'Open next lesson';
    }
    return 'Back to map';
  }

  String get suggestedNextAction {
    if (deepLeakCount > 0) {
      return 'Go to Review and fix the deep leak.';
    }
    if (masteryStatus == Act0MasteryStatusV1.needsReview) {
      return curriculumCompleted && hasForwardPath
          ? 'A focused replay is optional. You can continue learning.'
          : 'Replay this block before moving on.';
    }
    if (quickFixCount > 0) {
      return hasNextLesson
          ? 'Continue now, then check quick fixes in Review.'
          : isWorldComplete &&
                nextWorldTitle != null &&
                nextWorldTitle!.isNotEmpty
          ? 'Continue into $nextWorldTitle, then check quick fixes in Review.'
          : 'Check your quick fixes in Review.';
    }
    if (hasNextLesson) {
      return 'Continue to ${nextLessonTitle!}.';
    }
    if (isWorldComplete &&
        nextWorldTitle != null &&
        nextWorldTitle!.isNotEmpty) {
      return 'Continue to $nextWorldTitle.';
    }
    return 'All lessons done. Head to Review to track your progress.';
  }

  String get primaryCtaLabel {
    return switch (primaryCtaKind) {
      Act0MilestoneCtaKindV1.continueForward => progressionCtaLabel,
      Act0MilestoneCtaKindV1.replayForPerfect =>
        hasForwardPath ? 'Replay before next lesson' : 'Replay this block',
      Act0MilestoneCtaKindV1.reviewFirst => 'Review first',
      Act0MilestoneCtaKindV1.reviewForPerfect => 'Review for perfect',
      Act0MilestoneCtaKindV1.backToMap => 'Back to map',
    };
  }

  String? get secondaryCtaLabel => switch (secondaryCtaKind) {
    Act0MilestoneCtaKindV1.continueForward => progressionCtaLabel,
    Act0MilestoneCtaKindV1.replayForPerfect => 'Replay for perfect',
    Act0MilestoneCtaKindV1.reviewFirst => 'Review first',
    Act0MilestoneCtaKindV1.reviewForPerfect => 'Review for perfect',
    Act0MilestoneCtaKindV1.backToMap => 'Back to map',
    null => null,
  };

  String get habitRewardLabel {
    if (deepLeakCount > 0) {
      return 'Repair flagged';
    }
    if (quickFixCount > 0) {
      return 'Miss recovered';
    }
    if (!isWorldComplete && growthLabel.isNotEmpty) {
      return 'Practice recorded';
    }
    if (errorCount == 0 &&
        hasVerifiedAssessment &&
        assistedCount == 0 &&
        correctCount == taskCount) {
      return 'Clean read';
    }
    if (qualifiesForNextLesson) {
      return 'Route held';
    }
    return 'Replay ready';
  }

  String get habitRewardDetail {
    if (deepLeakCount > 0) {
      return 'You found the miss. Review it once before adding speed.';
    }
    if (quickFixCount > 0) {
      return 'You fixed the miss inside the lesson.';
    }
    if (!isWorldComplete && growthLabel.isNotEmpty) {
      return 'Practiced: $growthLabel. Try this clue in another spot.';
    }
    if (errorCount == 0 &&
        hasVerifiedAssessment &&
        assistedCount == 0 &&
        correctCount == taskCount) {
      return 'Clean run. This read will help in the next spot.';
    }
    if (qualifiesForNextLesson) {
      return "The lesson counts. We'll keep the next step beginner-safe.";
    }
    return 'Replay is the right move before adding new material. Clean it once and the next step will feel lighter again.';
  }

  String get gateMessage {
    if (deepLeakCount > 0 && qualifiesForNextLesson) {
      if (isWorldComplete &&
          nextWorldTitle != null &&
          nextWorldTitle!.isNotEmpty) {
        return 'Deep leak saved for Review. $nextWorldTitle is unlocked, but repair should be next.';
      }
      return hasNextLesson
          ? 'Deep leak saved for Review. Next lesson unlocked: ${nextLessonTitle!}. Repair should be next.'
          : 'Deep leak saved for Review. Clean it up before moving on.';
    }
    if (isWorldComplete) {
      if (nextWorldTitle != null && nextWorldTitle!.isNotEmpty) {
        return 'Strong finish. $nextWorldTitle is unlocked.';
      }
      return 'Strong finish. You completed this world.';
    }
    return qualifiesForNextLesson
        ? hasNextLesson
              ? 'Next lesson unlocked: ${nextLessonTitle!}.'
              : 'Clean finish. You completed all lessons.'
        : 'Keep replaying this clue to deepen the read before moving on.';
  }

  String get growthLabel => _formatSkillGrowthLabelV1(skillGains);
}

/// Deterministic, curriculum-true completion copy for Worlds 2-6, sourced
/// from each world's own accepted title/subtitle theme
/// (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart`). World 1 keeps its own
/// dedicated copy above; World 7+ is deferred and intentionally absent here.
class _WorldCompletionMetaV1 {
  const _WorldCompletionMetaV1({
    required this.learningLabel,
    required this.previewLine,
  });

  final String learningLabel;
  final String previewLine;
}

const Map<int, _WorldCompletionMetaV1>
_worldCompletionMetaByNumberV1 = <int, _WorldCompletionMetaV1>{
  2: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced separating playable hands from tempting ones.',
    previewLine:
        'World 3 starts with a simple question: does your seat change '
        'what you should play?',
  ),
  3: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced reading how position changes what a hand can do.',
    previewLine:
        'World 4 starts with a simple question: why did that bet '
        'happen, and what price did it create?',
  ),
  4: _WorldCompletionMetaV1(
    learningLabel:
        "You practiced reading why a bet happens and what price it's asking you "
        'to risk.',
    previewLine:
        'World 5 starts with a simple question: what does the board '
        'let you keep doing?',
  ),
  5: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced reading board texture and letting streets change '
        'your plan.',
    previewLine:
        'World 6 starts with a simple question: what could they still '
        'be holding?',
  ),
  6: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced grouping hands into ranges and comparing who '
        'is ahead.',
    previewLine:
        'World 7 starts with a simple question: what do the visible '
        'cards rule out?',
  ),
  7: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced using visible cards to remove combinations and narrow '
        'ranges.',
    previewLine:
        'World 8 starts with a simple question: how much risk can the '
        'stack still create?',
  ),
  8: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced reading how effective stack depth changes commitment and '
        'risk.',
    previewLine:
        'World 9 starts with a simple question: when does tournament '
        'pressure change the risk bar?',
  ),
  9: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced reading how survival pressure and risk premium change '
        'decisions.',
    previewLine:
        'World 10 starts with a simple question: which player tendency '
        'changes the plan?',
  ),
  10: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced tagging player tendencies, adjusting one lever, and '
        'keeping adjustment guardrails.',
    previewLine:
        'World 11 starts with a simple question: how does one clear plan '
        'transfer to real play?',
  ),
  11: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced planning a session, using table triggers, and closing '
        'the review loop.',
    previewLine:
        'World 12 starts with a simple question: how do you keep process '
        'steady when outcomes get noisy?',
  ),
  12: _WorldCompletionMetaV1(
    learningLabel:
        'You practiced judging process, resetting tilt, and keeping discipline '
        'before deeper strategy.',
    previewLine:
        'Volume I review brings the route together while later worlds '
        'stay locked.',
  ),
};

String _formatSkillGrowthLabelV1(List<Act0SkillGainV1> gains) {
  if (gains.isEmpty) {
    return '';
  }
  final sorted = gains.toList()
    ..sort((a, b) {
      final gainCompare = b.gain.compareTo(a.gain);
      if (gainCompare != 0) {
        return gainCompare;
      }
      return a.label.compareTo(b.label);
    });
  return sorted.take(2).map((gain) => gain.label).join('  \u2022  ');
}

String? _ownershipLineForSkillLabelV1(String label) {
  return switch (label) {
    'Table sense' => 'read the table and find your seat',
    'Board reading' => 'separate your cards from the board',
    'Hand reading' => 'compare the best hand at showdown',
    'Betting decisions' => 'make a first clean action',
    'Position play' => 'tell early seats from late seats',
    'Blind play' => 'track the blinds and first action',
    _ => null,
  };
}

// \u2500\u2500 Pure pot-calculation helpers (top-level so they are unit-testable) \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

/// Parses a BB amount string like "2.5 BB", "0.5 BB", "3BB" \u2192 double.
/// Returns 0.0 if unrecognised.
double act0ParseBbAmountV1(String s) {
  final m = RegExp(r'(\d+(?:\.\d+)?)\s*BB', caseSensitive: false).firstMatch(s);
  if (m == null) return 0.0;
  return double.tryParse(m.group(1)!) ?? 0.0;
}

/// Extracts the actor token (e.g. "BTN", "SB") from a stripped trail label.
/// Returns null when the label has no identifiable actor or no bet amount.
String? _act0TrailActor(String stripped) {
  final m = RegExp(
    r'^(\w+)\s+(?:blind|raises?|opens?|opened|calls?|called|bets?|all[- ]?in|goes\s+all)',
    caseSensitive: false,
  ).firstMatch(stripped);
  return m?.group(1)?.toUpperCase();
}

/// Calculates the running pot (in BB) by replaying [labels][0..upToIndex].
///
/// Returns `(potBb: -1.0, street: '')` when the trail does not start from
/// preflop blinds, so the caller can fall back to a static pot label.
///
/// Algorithm (per street):
///   \u2013 Each player's contribution is the **maximum** amount they put in
///     during that street (raise or call to X BB).
///   \u2013 An explicit "calls X BB more" adds X to the prior street commitment.
///   \u2013 On street transition the per-street map is flushed into [runningPot].
({double potBb, String street}) act0CalcTrailPotV1(
  List<String> labels,
  int upToIndex, {
  Set<int> noteIndexes = const {},
}) {
  if (labels.isEmpty) return (potBb: -1.0, street: '');

  // Preserve the source-index cutoff while ignoring only explicitly typed
  // notes. Any untyped blank in the requested prefix is malformed history.
  String? firstAction;
  for (var i = 0; i <= upToIndex && i < labels.length; i++) {
    if (noteIndexes.contains(i)) continue;
    final label = labels[i];
    if (label.trim().isEmpty) return (potBb: -1.0, street: '');
    firstAction ??= label;
  }
  if (firstAction == null) return (potBb: -1.0, street: '');
  final firstLower = firstAction.toLowerCase();
  // In a valid cash-game trail the *first* entry must be the small blind post.
  // A trail starting with BB only (or any other action) is incomplete \u2014 fall
  // back to the static potLabel so we never display a wrong pot.
  if (!firstLower.contains('sb blind')) {
    return (potBb: -1.0, street: '');
  }

  double runningPot = 0.0;
  final streetContribs = <String, double>{};
  String currentStreet = 'Preflop';

  for (int i = 0; i <= upToIndex && i < labels.length; i++) {
    if (noteIndexes.contains(i)) continue;
    final raw = labels[i];

    // Detect street transition: both "Flop: action" and bare "Flop dealt" forms.
    String? newStreet;
    if (RegExp(r'^flop[:\s]', caseSensitive: false).hasMatch(raw)) {
      newStreet = 'Flop';
    } else if (RegExp(r'^turn[:\s]', caseSensitive: false).hasMatch(raw)) {
      newStreet = 'Turn';
    } else if (RegExp(r'^river[:\s]', caseSensitive: false).hasMatch(raw)) {
      newStreet = 'River';
    }
    if (newStreet != null && newStreet != currentStreet) {
      runningPot += streetContribs.values.fold(0.0, (acc, v) => acc + v);
      streetContribs.clear();
      currentStreet = newStreet;
    }

    final stripped = raw.replaceFirst(
      RegExp(r'^(Flop|Turn|River):\s*', caseSensitive: false),
      '',
    );
    final actor = _act0TrailActor(stripped);
    if (actor == null) continue;
    final amount = act0ParseBbAmountV1(stripped);
    if (amount <= 0) continue;
    final existing = streetContribs[actor] ?? 0.0;
    final isAdditionalCall = RegExp(
      r'^\w+\s+(?:calls?|called)\s+\d+(?:\.\d+)?\s*BB\s+more$',
      caseSensitive: false,
    ).hasMatch(stripped.trim());
    final contribution = isAdditionalCall ? existing + amount : amount;
    if (contribution > existing) streetContribs[actor] = contribution;
  }

  final totalPot =
      runningPot + streetContribs.values.fold(0.0, (acc, v) => acc + v);
  return (potBb: totalPot, street: currentStreet);
}

/// Calculates the pot from typed source trail items while preserving source
/// indexes. Notes occupy an empty label slot and are never parsed as actions.
({double potBb, String street}) act0CalcTableTrailPotV1(
  Act0TableStateV1 table,
  int upToIndex,
) {
  final notes = <int>{};
  final labels = <String>[];
  for (var i = 0; i < table.actionTrail.length; i++) {
    final item = table.actionTrail[i];
    labels.add(item.label);
    if (item.isNote) notes.add(i);
  }
  return act0CalcTrailPotV1(labels, upToIndex, noteIndexes: notes);
}

/// Formats a pot double as a readable label: 6.5 \u2192 "Pot 6.5 BB", 7.0 \u2192 "Pot 7 BB".
String act0FormatPotLabelV1(double bb) {
  final rounded = (bb * 2).round() / 2; // nearest 0.5 BB
  final isWhole = rounded == rounded.truncateToDouble();
  return 'Pot ${isWhole ? rounded.toInt() : rounded} BB';
}

// \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

enum Act0RunnerFramingProfileV1 {
  neutral,
  boardHeroPot,
  boardOnly,
  heroAction,
  seatFocus,
}

/// Test-only, opt-in lower-surface states used to prove the bounded Phase 1
/// learning contract. The canonical learner route never supplies this value.
enum Act0LowerSurfacePrototypeStateV1 {
  coreRepairBeat1,
  coreRepairBeat2,
  coreRepairFinalBeat,
  expandedReference,
}

/// Test-only route-free accessibility presentation for compact large-text
/// layouts. The host keeps the direct table-decision contract active through
/// the decision; review phase remains the normal feedback owner.
enum Act0AccessibilityPrototypeStepV1 { evidence, decision }

enum Act0RunnerViewportProfileV1 { compact, canonical, large }

class Act0RunnerCompositionAllocationV1 {
  const Act0RunnerCompositionAllocationV1({
    required this.profile,
    required this.family,
    required this.textScale,
    required this.tableHeight,
    required this.lowerHeight,
  });

  final Act0RunnerViewportProfileV1 profile;
  final Act0RunnerCompositionFamilyV1 family;
  final double textScale;
  final double tableHeight;
  final double lowerHeight;
}

Act0RunnerCompositionAllocationV1 resolveAct0RunnerCompositionAllocationV1({
  required Size viewport,
  required EdgeInsets safeArea,
  required double textScale,
  required Act0RunnerCompositionFamilyV1 family,
}) {
  final profile = viewport.width <= 375 && viewport.height <= 812
      ? Act0RunnerViewportProfileV1.compact
      : viewport.width <= 402 && viewport.height <= 874
      ? Act0RunnerViewportProfileV1.canonical
      : Act0RunnerViewportProfileV1.large;
  final boundedScale = textScale.clamp(1.0, 1.4);
  final scaleProgress = (boundedScale - 1.0) / 0.4;
  final lowerAtOne = switch ((family, profile)) {
    (
      Act0RunnerCompositionFamilyV1.f1TableNative,
      Act0RunnerViewportProfileV1.compact,
    ) =>
      210.0,
    (
      Act0RunnerCompositionFamilyV1.f1TableNative,
      Act0RunnerViewportProfileV1.canonical,
    ) =>
      223.0,
    (
      Act0RunnerCompositionFamilyV1.f1TableNative,
      Act0RunnerViewportProfileV1.large,
    ) =>
      241.0,
    (
      Act0RunnerCompositionFamilyV1.f2AnswerList,
      Act0RunnerViewportProfileV1.compact,
    ) =>
      300.0,
    (
      Act0RunnerCompositionFamilyV1.f2AnswerList,
      Act0RunnerViewportProfileV1.canonical,
    ) =>
      320.0,
    (
      Act0RunnerCompositionFamilyV1.f2AnswerList,
      Act0RunnerViewportProfileV1.large,
    ) =>
      336.0,
  };
  final lowerAtOneFour = switch ((family, profile)) {
    (
      Act0RunnerCompositionFamilyV1.f1TableNative,
      Act0RunnerViewportProfileV1.compact,
    ) =>
      264.0,
    (
      Act0RunnerCompositionFamilyV1.f1TableNative,
      Act0RunnerViewportProfileV1.canonical,
    ) =>
      254.0,
    (
      Act0RunnerCompositionFamilyV1.f1TableNative,
      Act0RunnerViewportProfileV1.large,
    ) =>
      264.0,
    (
      Act0RunnerCompositionFamilyV1.f2AnswerList,
      Act0RunnerViewportProfileV1.compact ||
          Act0RunnerViewportProfileV1.canonical ||
          Act0RunnerViewportProfileV1.large,
    ) =>
      380.0,
  };
  final lowerHeight =
      lowerAtOne + ((lowerAtOneFour - lowerAtOne) * scaleProgress);
  final usableHeight = viewport.height - safeArea.vertical;
  return Act0RunnerCompositionAllocationV1(
    profile: profile,
    family: family,
    textScale: boundedScale,
    tableHeight: math.max(
      0.0,
      usableHeight -
          _runnerCompositionHeaderAndGapV1 -
          _sharedRunnerSeamV1 -
          lowerHeight,
    ),
    lowerHeight: lowerHeight,
  );
}

enum _RunnerInteractionModeV1 { answerListDecision, tableTapDecision, feedback }

/// The lower stage receives every pixel left after the locked table stage.
/// Profiles may change only child composition; they must never influence the
/// table allocation above them.
enum _RunnerLowerStageProfileV1 {
  instruction,
  tableTapDecision,
  decision,
  compactFeedback,
  expandedFeedback,
  accessibility,
}

enum _RunnerViewportFamilyV1 {
  neutral,
  answerListBoardHeroPot,
  answerListHeroAction,
  tableTapSeatFocus,
}

/// Exposure is monotonic until that source decision is actually recorded.
Act0DecisionAssistanceV1 act0MergeDecisionAssistanceV1(
  Act0DecisionAssistanceV1 retained,
  Act0DecisionAssistanceV1 next,
) {
  int rank(Act0DecisionAssistanceV1 value) => switch (value) {
    Act0DecisionAssistanceV1.none => 0,
    Act0DecisionAssistanceV1.legacyUnknown => 1,
    Act0DecisionAssistanceV1.quickHint => 2,
    Act0DecisionAssistanceV1.theoryRecall => 3,
  };
  return rank(next) > rank(retained) ? next : retained;
}

class Act0LessonRunnerShellV1 extends StatefulWidget {
  const Act0LessonRunnerShellV1({
    super.key,
    required this.runner,
    this.worldNumber = 0,
    this.selectedWorldId,
    this.selectedLessonId,
    this.selectedTaskId,
    this.selectedTaskTitle,
    this.selectedTaskFamily,
    this.tablePresentation = Act0TaskTablePresentationV1.legacy,
    this.theoryRecallStep,
    required this.onBack,
    required this.onContinueTheory,
    this.onPreviousTheory,
    this.onUndoInteraction,
    required this.onChooseOption,
    this.onSelectSizingPreset,
    this.onConfirmSizingPreset,
    this.onChooseSeat,
    this.onCompletedDecision,
    this.onChoiceAssistance,
    this.onAssistanceExposureRequested,
    this.initialChoiceAssistance = Act0DecisionAssistanceV1.none,
    required this.onContinueReview,
    this.completionSummary,
    this.isAssistedDecision = false,
    this.localizeW1Ctas = false,
    this.preserveSourceOwnedQuestion = false,
    this.firstValueReceiptLine,
    this.repairReasonLine,
    this.repairResultReceiptLine,
    this.repairOutcomeProofLine,
    this.forceShowRepairOutcomeProof = false,
    this.extraPracticeProgress,
    this.repairContinuesToSourceRecheck = false,
    this.isSourceRecheckAttempt = false,
    this.learningLoopStage,
    this.repairSessionSummaryLines = const <String>[],
    this.feedbackForwardCtaLabel,
    this.suppressFeedbackRepairFocus = false,
    this.framingProfile = Act0RunnerFramingProfileV1.neutral,
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
    this.relaxTheoryAdvanceLock = false,
    this.showLearningRailFocusLabels = false,
    this.rapidReviewMode = false,
    this.actionRecommendation,
    this.actionPayoff,
    this.telemetrySink,
    this.evidenceRunId = '',
    this.evidenceNextOrder = 0,
    this.reviewKindId = 'initialAssessment',
    this.tableChoreographyMode = Act0TableChoreographyModeV1.runtime,
    this.lowerSurfacePrototypeState,
    this.accessibilityPrototypeStep,
    this.onAccessibilityPrototypeStepChanged,
    this.compositionFamily = Act0RunnerCompositionFamilyV1.f2AnswerList,
  });

  final Act0RunnerStateV1 runner;
  final int worldNumber;
  final String? selectedWorldId;
  final String? selectedLessonId;
  final String? selectedTaskId;
  final String? selectedTaskTitle;
  final Act0TaskFamilyV1? selectedTaskFamily;
  final Act0TaskTablePresentationV1 tablePresentation;
  final Act0TeachingStepV1? theoryRecallStep;
  final VoidCallback onBack;
  final VoidCallback onContinueTheory;
  final VoidCallback? onPreviousTheory;
  final VoidCallback? onUndoInteraction;
  final ValueChanged<Act0RunnerOptionV1> onChooseOption;
  final ValueChanged<Act0SizingPresetV1>? onSelectSizingPreset;
  final VoidCallback? onConfirmSizingPreset;
  final ValueChanged<String>? onChooseSeat;
  final ValueChanged<Act0CompletedDecisionV1>? onCompletedDecision;
  final ValueChanged<Act0DecisionAssistanceV1>? onChoiceAssistance;
  final Future<bool> Function(Act0DecisionAssistanceV1)?
  onAssistanceExposureRequested;
  final Act0DecisionAssistanceV1 initialChoiceAssistance;
  final VoidCallback onContinueReview;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final bool isAssistedDecision;
  final bool localizeW1Ctas;
  // Placement quick-check reuses one task ID for three authored questions.
  final bool preserveSourceOwnedQuestion;
  final String? firstValueReceiptLine;
  final String? repairReasonLine;
  final String? repairResultReceiptLine;
  final String? repairOutcomeProofLine;
  final bool forceShowRepairOutcomeProof;
  final ({int step, int total})? extraPracticeProgress;
  final bool repairContinuesToSourceRecheck;
  final bool isSourceRecheckAttempt;

  /// B5 view metadata: which stage of the canonical learning loop is being
  /// rendered. Owned by the route that performs the transition; read-only here
  /// and never used to advance anything.
  final Act0ActionSequenceStageV1? learningLoopStage;
  final List<String> repairSessionSummaryLines;
  final String? feedbackForwardCtaLabel;
  final bool suppressFeedbackRepairFocus;
  final Act0RunnerFramingProfileV1 framingProfile;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;
  final bool relaxTheoryAdvanceLock;
  final bool showLearningRailFocusLabels;
  final bool rapidReviewMode;
  final Act0ActionRecommendationV1? actionRecommendation;
  final Act0ActionSessionPayoffV1? actionPayoff;
  final Act0TelemetrySinkV1? telemetrySink;
  final String evidenceRunId;

  /// Next durable order from the existing learning evidence owner.
  final int evidenceNextOrder;
  final String reviewKindId;
  final Act0TableChoreographyModeV1 tableChoreographyMode;
  final Act0LowerSurfacePrototypeStateV1? lowerSurfacePrototypeState;
  final Act0AccessibilityPrototypeStepV1? accessibilityPrototypeStep;
  final ValueChanged<Act0AccessibilityPrototypeStepV1>?
  onAccessibilityPrototypeStepChanged;
  final Act0RunnerCompositionFamilyV1 compositionFamily;

  @override
  State<Act0LessonRunnerShellV1> createState() =>
      _Act0LessonRunnerShellV1State();
}

class _Act0LessonRunnerShellV1State extends State<Act0LessonRunnerShellV1>
    with SingleTickerProviderStateMixin {
  static const Duration _theoryAdvanceLockDuration = Duration(
    milliseconds: 820,
  );
  static const Duration _replayAdvanceLockDuration = Duration(
    milliseconds: 280,
  );

  Timer? _theoryUnlockTimer;
  Timer? _rapidReviewTimer;
  bool _canAdvanceTheory = true;
  String _advanceLockKey = '';
  String _rapidReviewKey = '';
  String _taskShownTelemetryKey = '';
  String _userChoiceTelemetryKey = '';
  String _feedbackViewedTelemetryKey = '';
  String _completedDecisionTaskKey = '';
  int _completedDecisionOrdinal = 0;
  bool _decisionSubmittedForTaskV1 = false;
  String _showdownInteractionKey = '';
  final Stopwatch _decisionTelemetryStopwatch = Stopwatch();
  Timer? _tableChoreographyTimer;
  String _tableChoreographyRunKey = '';
  int _tableChoreographyGeneration = 0;
  Act0TableChoreographyPlanV1? _tableChoreographyPlan;
  int _tableChoreographyBeatIndex = -1;
  Act0TableChoreographyFrameV1? _tableChoreographyFrame;
  bool _heroDecisionReady = true;
  List<String> _interactiveHighlightedCardIds = const <String>[];
  String _interactiveShowdownLine = '';
  int? _actionTrailFocusedIndex;
  int _learningRailSupportSegmentIndex = 0;
  String _learningRailSupportStepKey = '';
  bool _showTheoryPeek = false;
  bool _assistanceExposurePendingV1 = false;
  int _assistanceExposureEpochV1 = 0;
  Act0DecisionAssistanceV1 _decisionAssistanceKindV1 =
      Act0DecisionAssistanceV1.none;
  bool _showFullIdeaInTheoryPeek = false;
  bool _coachAssetWarmupRequested = false;
  late Act0RunnerCompositionFamilyV1 _compositionFamily;
  late String _compositionTaskKey;

  // B6 semantic motion. One interpolation between two already-accepted B5
  // states, owned here because this `State` is the only owner that survives
  // every learning-loop hop \u2014 the scene's own elements are replaced at each
  // one, so an implicit animation placed down there would remount with no
  // "from" value at exactly the moments B6 exists to smooth.
  late final AnimationController _sceneAttentionController;
  late final Animation<double> _sceneAttentionProgress;
  Act0SceneAttentionPhaseV1? _sceneAttentionPhase;
  Act0SceneAttentionValuesV1? _sceneAttentionFrom;
  Act0SceneAttentionValuesV1? _sceneAttentionTo;
  var _sceneAttentionStartPending = false;
  var _f7AttemptGenerationV1 = 0;

  @override
  void initState() {
    super.initState();
    _sceneAttentionController = AnimationController(
      vsync: this,
      duration: Act0MotionTokensV1.standard,
      // Settled on first mount: a freshly entered scene has nothing to
      // transition *from*, so it must not animate itself in.
      value: 1,
    );
    // `enter`, not `settle`. Measured, `settle` (easeInOutCubic) moves only
    // 4.7% of the way in its first 64ms, so a transition the learner just
    // caused reads as lag before it reads as motion. `enter` (easeOutCubic)
    // responds on the first frame and decelerates into the endpoint, which is
    // what makes this feel like the scene answering the tap rather than
    // animating on its own schedule. Both are sanctioned tokens.
    _sceneAttentionProgress = _sceneAttentionController.drive(
      CurveTween(curve: Act0MotionTokensV1.enter),
    );
    _decisionAssistanceKindV1 = widget.initialChoiceAssistance;
    _syncTheoryAdvanceLock(initial: true);
    _syncRapidReviewAdvance();
    _maybeEmitTaskShownTelemetry();
    _compositionFamily = widget.compositionFamily;
    _compositionTaskKey = _compositionTaskIdentity(widget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTableChoreographyV1();
    if (_coachAssetWarmupRequested) {
      return;
    }
    _coachAssetWarmupRequested = true;

    // The Coach Surface is hidden during DECIDE, which gives the current
    // production asset time to decode before the first feedback frame. This
    // keeps the shared renderer and its error handling authoritative while
    // avoiding an empty mascot frame when feedback appears for the first time.
    unawaited(
      precacheImage(
        AssetImage(act0SharkyCompanionAssetForMoodV1(Act0SharkyMoodV1.neutral)),
        context,
      ).catchError((Object _) {
        // The normal Image.asset errorBuilder remains the visible fallback.
      }),
    );
  }

  /// Resolves what the scene should render this frame for [phase].
  ///
  /// Motion never owns the phase: the returned motion always publishes the
  /// incoming [phase], so the scene's deterministic phase marker flips on the
  /// same frame the state does. Only the three bounded B5 numbers interpolate,
  /// and they always end exactly on B5's settled values.
  Act0SceneAttentionMotionV1 _resolveSceneAttentionMotionV1(
    Act0SceneAttentionPhaseV1 phase, {
    required bool disableMotion,
  }) {
    final settled = Act0SceneAttentionV1(phase).settledValues;
    if (disableMotion) {
      // Reduced-motion contract: immediate transition, zero animated frames.
      if (_sceneAttentionController.isAnimating) {
        _sceneAttentionController.stop();
      }
      _sceneAttentionPhase = phase;
      _sceneAttentionFrom = settled;
      _sceneAttentionTo = settled;
      _sceneAttentionStartPending = false;
      return Act0SceneAttentionMotionV1.settled(phase);
    }
    if (_sceneAttentionPhase != phase) {
      final previousPhase = _sceneAttentionPhase;
      final previousFrom = _sceneAttentionFrom;
      final previousTo = _sceneAttentionTo;
      // Interruptible: a new state change wins immediately, and departs from
      // whatever is actually on screen rather than from a stale endpoint.
      var origin = previousFrom == null || previousTo == null
          ? settled
          : Act0SceneAttentionValuesV1.lerp(
              previousFrom,
              previousTo,
              _sceneAttentionProgress.value,
            );
      if (phase == Act0SceneAttentionPhaseV1.recheck) {
        // Answer fairness beats transition symmetry. A fading bracket is still
        // a clue animating into a recognition attempt, which the B6 acceptance
        // bar forbids, so the clue is released instantly on entering recheck
        // and never interpolates out. The field restoring around it is what
        // carries "the assistance is gone".
        origin = origin.withClueEmphasis(settled.clueEmphasis);
      }
      _sceneAttentionPhase = phase;
      _sceneAttentionFrom = origin;
      _sceneAttentionTo = settled;
      if (previousPhase != null && !_sceneAttentionStartPending) {
        // Start after this frame. The frame that discovers the change renders
        // the outgoing values, so the transition begins from what the learner
        // was actually looking at instead of flashing the new state first.
        _sceneAttentionStartPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _sceneAttentionStartPending = false;
          _sceneAttentionController.forward(from: 0);
          setState(() {});
        });
      }
    }
    return Act0SceneAttentionMotionV1(
      phase: phase,
      from: _sceneAttentionFrom ?? settled,
      to: _sceneAttentionTo ?? settled,
      progress: _sceneAttentionStartPending
          ? const AlwaysStoppedAnimation<double>(0)
          : _sceneAttentionProgress,
    );
  }

  @override
  void didUpdateWidget(covariant Act0LessonRunnerShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_compositionTaskIdentity(oldWidget) !=
            _compositionTaskIdentity(widget) ||
        oldWidget.evidenceRunId != widget.evidenceRunId ||
        oldWidget.runner.question != widget.runner.question ||
        (oldWidget.runner.phase == Act0LessonPhaseV1.review &&
            widget.runner.phase != Act0LessonPhaseV1.review)) {
      ++_f7AttemptGenerationV1;
    }
    // A new task or an explicit return from review opens a new attempt.
    // A feedback re-render must not reopen the already committed choice.
    if (oldWidget.selectedTaskId != widget.selectedTaskId ||
        oldWidget.selectedLessonId != widget.selectedLessonId ||
        (oldWidget.runner.phase == Act0LessonPhaseV1.review &&
            widget.runner.phase == Act0LessonPhaseV1.drill) ||
        (oldWidget.runner.phase == Act0LessonPhaseV1.drill &&
            widget.runner.phase == Act0LessonPhaseV1.drill &&
            widget.runner.selectedOptionId == null)) {
      _decisionSubmittedForTaskV1 = false;
    }
    _syncTheoryAdvanceLock();
    _syncLearningRailSupportSegment();
    _syncRapidReviewAdvance();
    _maybeEmitTaskShownTelemetry();
    _syncTableChoreographyV1();
    _maybeEmitFeedbackViewedTelemetry();
    final nextCompositionTaskKey = _compositionTaskIdentity(widget);
    final sourceTaskChanged = nextCompositionTaskKey != _compositionTaskKey;
    if (sourceTaskChanged) {
      _compositionTaskKey = nextCompositionTaskKey;
      _compositionFamily = widget.compositionFamily;
    }
    final nextKey = _interactionKey(widget.runner);
    if (sourceTaskChanged || _showdownInteractionKey != nextKey) {
      _assistanceExposureEpochV1 += 1;
      _assistanceExposurePendingV1 = false;
      _actionTrailFocusedIndex = null;
      _showdownInteractionKey = nextKey;
      _interactiveHighlightedCardIds = const <String>[];
      _interactiveShowdownLine = '';
      _showTheoryPeek = false;
      _showFullIdeaInTheoryPeek = false;
      _decisionAssistanceKindV1 = widget.initialChoiceAssistance;
    } else {
      _decisionAssistanceKindV1 = act0MergeDecisionAssistanceV1(
        _decisionAssistanceKindV1,
        widget.initialChoiceAssistance,
      );
    }
  }

  @override
  void dispose() {
    _theoryUnlockTimer?.cancel();
    _rapidReviewTimer?.cancel();
    _cancelTableChoreographyV1();
    _sceneAttentionController.dispose();
    super.dispose();
  }

  void _syncRapidReviewAdvance() {
    final shouldAutoAdvance =
        widget.rapidReviewMode &&
        _isReview &&
        widget.runner.selectedOptionId != null;
    if (!shouldAutoAdvance) {
      _rapidReviewTimer?.cancel();
      _rapidReviewKey = '';
      return;
    }
    final nextKey = _interactionKey(widget.runner);
    if (_rapidReviewKey == nextKey) {
      return;
    }
    _rapidReviewTimer?.cancel();
    _rapidReviewKey = nextKey;
    _rapidReviewTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) {
        return;
      }
      widget.onContinueReview();
    });
  }

  void _syncLearningRailSupportSegment() {
    final nextKey =
        '${widget.runner.lessonId}|${widget.runner.beatIndex}|'
        '${widget.runner.phase.name}|${widget.runner.teachingStepIndex}';
    if (_learningRailSupportStepKey == nextKey) {
      return;
    }
    _learningRailSupportStepKey = nextKey;
    _learningRailSupportSegmentIndex = 0;
  }

  bool get _isRefinedDev2 =>
      widget.tableVisualVariant == Act0ShellTableVisualVariantV1.refinedDev2;

  bool get _usesCanonicalIntegratedLearningSceneV1 => true;

  String _compositionTaskIdentity(Act0LessonRunnerShellV1 value) =>
      '${value.selectedWorldId ?? ''}|${value.selectedLessonId ?? ''}|'
      '${value.selectedTaskId ?? value.runner.lessonId}|${value.runner.beatIndex}';

  bool get _isTheory => widget.runner.phase == Act0LessonPhaseV1.theory;

  bool get _isReview => widget.runner.phase == Act0LessonPhaseV1.review;

  Act0TeachingStepV1? get _teachingStep => widget.runner.activeTeachingStep;

  bool get _isTeaching =>
      _teachingStep != null &&
      widget.runner.selectedOptionId == null &&
      widget.runner.phase != Act0LessonPhaseV1.review;

  bool get _showBottomLearningRail =>
      _isRefinedDev2 && (_isTheory || _isTeaching);

  String _interactionKey(Act0RunnerStateV1 runner) {
    return '${runner.lessonId}|${runner.beatIndex}|${runner.phase.name}|${runner.teachingStepIndex}|${runner.selectedOptionId ?? ''}';
  }

  void _recordTelemetry(Act0TelemetryEventV1 event) {
    try {
      widget.telemetrySink?.record(event);
    } catch (_) {}
  }

  bool get _taskTelemetryVisible {
    return widget.runner.phase == Act0LessonPhaseV1.drill &&
        widget.runner.teachingStepIndex >= widget.runner.teachingSteps.length;
  }

  String get _stableTaskTelemetryId {
    final taskId = widget.selectedTaskId?.trim();
    if (taskId != null && taskId.isNotEmpty) {
      return taskId;
    }
    return '${widget.runner.lessonId}_${widget.runner.beatIndex}';
  }

  String get _stableLessonTelemetryId {
    final lessonId = widget.selectedLessonId?.trim();
    if (lessonId != null && lessonId.isNotEmpty) {
      return lessonId;
    }
    return widget.runner.lessonId;
  }

  String? get _actionSequenceTelemetryId => widget.selectedTaskId == null
      ? null
      : act0ActionLearningSequenceForTaskV1(widget.selectedTaskId!)?.sequenceId;

  String _tableChoreographyTaskIdentityForWidgetV1(
    Act0LessonRunnerShellV1 value,
  ) {
    final lessonId = (value.selectedLessonId ?? '').trim().isNotEmpty
        ? value.selectedLessonId!.trim()
        : value.runner.lessonId;
    final taskId = (value.selectedTaskId ?? '').trim().isNotEmpty
        ? value.selectedTaskId!.trim()
        : '${value.runner.lessonId}_${value.runner.beatIndex}';
    return '${value.selectedWorldId ?? ''}|$lessonId|$taskId';
  }

  bool _tableChoreographyActorFocusSafeV1() {
    if (widget.runner.options.any((option) => option.seatId != null)) {
      return false;
    }
    final learnerPrompt = '${widget.runner.caption} ${widget.runner.question}'
        .toLowerCase();
    return !learnerPrompt.contains('which seat') &&
        !learnerPrompt.contains('who acts') &&
        !learnerPrompt.contains('who is acting') &&
        !learnerPrompt.contains('what position');
  }

  void _syncTableChoreographyV1() {
    if (!_taskTelemetryVisible) {
      _cancelTableChoreographyV1();
      _tableChoreographyRunKey = '';
      _tableChoreographyPlan = null;
      _tableChoreographyFrame = null;
      _tableChoreographyBeatIndex = -1;
      _heroDecisionReady = true;
      return;
    }

    final taskIdentity = _tableChoreographyTaskIdentityForWidgetV1(widget);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final settleImmediately =
        reduceMotion ||
        widget.tableChoreographyMode == Act0TableChoreographyModeV1.settled;

    if (_tableChoreographyRunKey == taskIdentity) {
      if (settleImmediately && !_heroDecisionReady) {
        _settleTableChoreographyV1(taskIdentity);
      }
      return;
    }

    _cancelTableChoreographyV1();
    _tableChoreographyRunKey = taskIdentity;
    _tableChoreographyBeatIndex = -1;
    final table = widget.runner.table;
    _tableChoreographyPlan = table.autoPlayHistory
        ? act0TableChoreographyPlanForTableV1(
            table,
            actorFocusSafe: _tableChoreographyActorFocusSafeV1(),
          )
        : null;

    final plan = _tableChoreographyPlan;
    if (plan == null || settleImmediately) {
      _tableChoreographyFrame = plan == null
          ? null
          : act0TableChoreographyFrameAfterBeatV1(plan, plan.beats.length - 1);
      _markHeroDecisionReadyV1(taskIdentity, notify: false);
      return;
    }

    _heroDecisionReady = false;
    _tableChoreographyFrame = act0TableChoreographyFrameAfterBeatV1(plan, -1);
    final generation = _tableChoreographyGeneration;
    _tableChoreographyTimer = Timer(
      const Duration(milliseconds: 160),
      () => _advanceTableChoreographyV1(taskIdentity, generation),
    );
  }

  void _settleTableChoreographyV1(String taskIdentity) {
    final plan = _tableChoreographyPlan;
    if (plan != null) {
      _tableChoreographyBeatIndex = plan.beats.length - 1;
      _tableChoreographyFrame = act0TableChoreographyFrameAfterBeatV1(
        plan,
        _tableChoreographyBeatIndex,
      );
    }
    _markHeroDecisionReadyV1(taskIdentity);
  }

  void _advanceTableChoreographyV1(String taskIdentity, int generation) {
    if (!mounted ||
        generation != _tableChoreographyGeneration ||
        taskIdentity != _tableChoreographyRunKey) {
      return;
    }
    final plan = _tableChoreographyPlan;
    if (plan == null) {
      _markHeroDecisionReadyV1(taskIdentity);
      return;
    }

    final nextIndex = _tableChoreographyBeatIndex + 1;
    if (nextIndex >= plan.beats.length) {
      _markHeroDecisionReadyV1(taskIdentity);
      return;
    }

    final beat = plan.beats[nextIndex];
    _tableChoreographyBeatIndex = nextIndex;
    _tableChoreographyFrame = act0TableChoreographyFrameAfterBeatV1(
      plan,
      nextIndex,
    );

    if (beat.kind == Act0TableChoreographyBeatKindV1.heroDecisionReady) {
      _markHeroDecisionReadyV1(taskIdentity);
      return;
    }

    setState(() {});
    _tableChoreographyTimer = Timer(
      _durationForTableChoreographyBeatV1(beat.kind),
      () => _advanceTableChoreographyV1(taskIdentity, generation),
    );
  }

  Duration _durationForTableChoreographyBeatV1(
    Act0TableChoreographyBeatKindV1 kind,
  ) {
    return switch (kind) {
      Act0TableChoreographyBeatKindV1.actionFocus => const Duration(
        milliseconds: 340,
      ),
      Act0TableChoreographyBeatKindV1.commitmentMove => const Duration(
        milliseconds: 500,
      ),
      Act0TableChoreographyBeatKindV1.foldRecess => const Duration(
        milliseconds: 340,
      ),
      Act0TableChoreographyBeatKindV1.commitmentsCollect => const Duration(
        milliseconds: 300,
      ),
      Act0TableChoreographyBeatKindV1.flopReveal ||
      Act0TableChoreographyBeatKindV1.turnReveal ||
      Act0TableChoreographyBeatKindV1.riverReveal => const Duration(
        milliseconds: 460,
      ),
      Act0TableChoreographyBeatKindV1.heroDecisionReady => Duration.zero,
    };
  }

  void _markHeroDecisionReadyV1(String taskIdentity, {bool notify = true}) {
    if (taskIdentity != _tableChoreographyRunKey) {
      return;
    }
    _tableChoreographyTimer?.cancel();
    _tableChoreographyTimer = null;
    final wasReady = _heroDecisionReady;
    _heroDecisionReady = true;

    final plan = _tableChoreographyPlan;
    if (plan != null) {
      _tableChoreographyBeatIndex = plan.beats.length - 1;
      _tableChoreographyFrame = act0TableChoreographyFrameAfterBeatV1(
        plan,
        _tableChoreographyBeatIndex,
      );
    }

    if (_taskTelemetryVisible && !_decisionTelemetryStopwatch.isRunning) {
      _decisionTelemetryStopwatch
        ..reset()
        ..start();
    }
    if (notify && !wasReady && mounted) {
      setState(() {});
    }
  }

  void _cancelTableChoreographyV1() {
    _tableChoreographyGeneration += 1;
    _tableChoreographyTimer?.cancel();
    _tableChoreographyTimer = null;
  }

  void _handleRunnerBackV1() {
    _cancelTableChoreographyV1();
    widget.onBack();
  }

  void _maybeEmitTaskShownTelemetry() {
    if (!_taskTelemetryVisible) {
      return;
    }
    final key =
        '${widget.selectedWorldId ?? ''}|$_stableLessonTelemetryId|$_stableTaskTelemetryId|${widget.runner.phase.name}';
    if (_taskShownTelemetryKey == key) {
      return;
    }
    _taskShownTelemetryKey = key;
    _userChoiceTelemetryKey = '';
    _decisionTelemetryStopwatch
      ..stop()
      ..reset();
    _recordTelemetry(
      Act0TelemetryEventV1(
        name: 'task_shown',
        fields: <String, Object?>{
          'schemaVersion': 1,
          if ((widget.selectedWorldId ?? '').trim().isNotEmpty)
            'worldId': widget.selectedWorldId!.trim(),
          'lessonId': _stableLessonTelemetryId,
          'taskId': _stableTaskTelemetryId,
          if (_actionSequenceTelemetryId != null)
            'sequenceId': _actionSequenceTelemetryId,
          if (widget.selectedTaskFamily != null)
            'taskFamily': widget.selectedTaskFamily!.name,
          'phase': widget.runner.phase.name,
          'attemptOrdinal': 1,
        },
      ),
    );
  }

  void _maybeEmitUserChoiceTelemetry(
    Act0RunnerOptionV1 option, {
    required String decisionTimeBucket,
    Act0CompletedDecisionKindV1 kind = Act0CompletedDecisionKindV1.actionList,
  }) {
    final projection = _decisionTelemetryProjectionV1(option, kind: kind);
    // Same-attempt callbacks are idempotent; a replay is a new attempt.
    final key = projection.attemptId;
    if (_userChoiceTelemetryKey == key) return;
    _userChoiceTelemetryKey = key;
    _decisionTelemetryStopwatch.stop();
    _recordTelemetry(
      Act0TelemetryEventV1(
        name: 'user_choice',
        fields: <String, Object?>{
          'schemaVersion': 1,
          if ((widget.selectedWorldId ?? '').trim().isNotEmpty)
            'worldId': widget.selectedWorldId!.trim(),
          'lessonId': _stableLessonTelemetryId,
          'taskId': _stableTaskTelemetryId,
          if (_actionSequenceTelemetryId != null)
            'sequenceId': _actionSequenceTelemetryId,
          'choiceId': option.id,
          'assistance_kind': _decisionAssistanceKindV1.name,
          'chosen_action': option.id,
          if (projection.expectedAction != null)
            'expected_action': projection.expectedAction,
          'correct': option.isCorrect,
          'result_classification': projection.resultClassification,
          'error_type': projection.errorType,
          if (projection.repairFamilyId != null)
            'repair_family_id': projection.repairFamilyId,
          'route_source_owner': 'act0_runner',
          'drill_kind': projection.drillKind,
          'attempt_id': projection.attemptId,
          'review_kind': widget.reviewKindId,
          if (projection.streetLabel.isNotEmpty)
            'street_v1': projection.streetLabel,
          'acceptable_action_ids': projection.acceptableActionIds,
          'option_quality': option.quality.name,
          'decisionTimeBucket': decisionTimeBucket,
          'attemptOrdinal': 1,
        },
      ),
    );
  }

  void _emitCanonicalDecisionMadeTelemetryV1(
    Act0RunnerOptionV1 option, {
    required String decisionTimeBucket,
    Act0CompletedDecisionKindV1 kind = Act0CompletedDecisionKindV1.actionList,
  }) {
    final projection = _decisionTelemetryProjectionV1(option, kind: kind);
    _recordTelemetry(
      Act0TelemetryEventV1(
        name: 'decision_made',
        fields: <String, Object?>{
          'schemaVersion': 1,
          if ((widget.selectedWorldId ?? '').trim().isNotEmpty) ...{
            'worldId': widget.selectedWorldId!.trim(),
            'world_id': widget.selectedWorldId!.trim(),
          },
          'lessonId': _stableLessonTelemetryId,
          'lesson_id': _stableLessonTelemetryId,
          'taskId': _stableTaskTelemetryId,
          'task_id': _stableTaskTelemetryId,
          if (_actionSequenceTelemetryId != null)
            'sequenceId': _actionSequenceTelemetryId,
          if (widget.selectedTaskFamily != null) ...{
            'taskFamily': widget.selectedTaskFamily!.name,
            'concept_family_id': widget.selectedTaskFamily!.name,
          },
          'choiceId': option.id,
          'assistance_kind': _decisionAssistanceKindV1.name,
          'chosen_action': option.id,
          'selected_action': option.id,
          if (projection.expectedAction != null) ...{
            'expected_action': projection.expectedAction,
            'correct_action': projection.expectedAction,
          },
          'acceptable_action_ids': projection.acceptableActionIds,
          'drill_kind': projection.drillKind,
          'correct': option.isCorrect,
          'is_correct': option.isCorrect,
          'result': projection.resultClassification,
          'result_classification': projection.resultClassification,
          'errorType': projection.errorType,
          'error_type': projection.errorType,
          if (projection.repairFamilyId != null)
            'repairFamilyId': projection.repairFamilyId,
          if (projection.repairFamilyId != null)
            'repair_family_id': projection.repairFamilyId,
          if (projection.repairTargetTaskId != null)
            'repairTargetTaskId': projection.repairTargetTaskId,
          if (projection.repairTargetTaskId != null)
            'repair_target_task_id': projection.repairTargetTaskId,
          if (projection.streetLabel.isNotEmpty)
            'street_v1': projection.streetLabel,
          'route_source_owner': 'act0_runner',
          'attempt_id': projection.attemptId,
          'review_kind': widget.reviewKindId,
          'decisionTimeBucket': decisionTimeBucket,
          'source_surface': 'act0_runner',
          'attemptOrdinal': 1,
          'attempt_ordinal': 1,
        },
      ),
    );
  }

  String _decisionTimeBucketV1(Duration elapsed) {
    if (elapsed <= Duration.zero) {
      return 'unknown';
    }
    if (elapsed < const Duration(seconds: 3)) {
      return 'under_3s';
    }
    if (elapsed < const Duration(seconds: 10)) {
      return '3_to_10s';
    }
    return 'over_10s';
  }

  void _maybeEmitFeedbackViewedTelemetry() {
    final selectedOptionId = widget.runner.selectedOptionId?.trim() ?? '';
    if (!_isReview || selectedOptionId.isEmpty) {
      return;
    }
    final key =
        '${widget.selectedWorldId ?? ''}|$_stableLessonTelemetryId|$_stableTaskTelemetryId|${widget.runner.phase.name}|$selectedOptionId';
    if (_feedbackViewedTelemetryKey == key) {
      return;
    }
    _feedbackViewedTelemetryKey = key;
    final selectedOption = widget.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => option?.id == selectedOptionId,
          orElse: () => null,
        );
    final feedbackSignalProof = _feedbackSignalProofForRunnerV1(
      runner: widget.runner,
      option: selectedOption,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: widget.runner.options.any(
        (option) => option.seatId != null,
      ),
    );
    final skillReceipt = widget.firstValueReceiptLine == null
        ? null
        : _skillReceiptForSignalProofV1(
            proof: feedbackSignalProof,
            quality: selectedOption?.quality ?? widget.runner.reviewQuality,
          );
    final causalFeedback = Act0CausalFeedbackV1.fromStructured(
      quality: selectedOption?.quality ?? widget.runner.reviewQuality,
      authoredReason: widget.runner.reviewReason,
      chosenAction: widget.runner.reviewSelectedLabel,
      preferredAction: widget.runner.reviewPreferredLabel,
      betterAction: widget.runner.reviewBetterLabel,
      structuredClue: feedbackSignalProof?.label ?? '',
    );
    _recordTelemetry(
      Act0TelemetryEventV1(
        name: 'feedback_viewed',
        fields: <String, Object?>{
          'schemaVersion': 1,
          if ((widget.selectedWorldId ?? '').trim().isNotEmpty)
            'worldId': widget.selectedWorldId!.trim(),
          'lessonId': _stableLessonTelemetryId,
          'taskId': _stableTaskTelemetryId,
          if (_actionSequenceTelemetryId != null)
            'sequenceId': _actionSequenceTelemetryId,
          if (selectedOption != null)
            'result': selectedOption.isCorrect ? 'correct' : 'incorrect',
          if (feedbackSignalProof != null)
            'feedbackSignal': feedbackSignalProof.signalId,
          if (skillReceipt != null) 'skillReceiptId': skillReceipt.receiptId,
          if (skillReceipt != null) 'skillAtomId': skillReceipt.skillAtomId,
          if (skillReceipt != null) 'nextRepId': skillReceipt.nextRepId,
          if (skillReceipt != null)
            'skillReceiptOutcome': skillReceipt.outcome.telemetryValue,
          'causal_feedback_shown': true,
          ...causalFeedback.toTelemetryPayload(),
          'attemptOrdinal': 1,
        },
      ),
    );
  }

  void _emitTaskResultTelemetryV1(
    Act0RunnerOptionV1 option, {
    required Act0CompletedDecisionKindV1 kind,
  }) {
    final feedbackSignalProof = _feedbackSignalProofForRunnerV1(
      runner: widget.runner.copyWith(selectedOptionId: option.id),
      option: option,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: widget.runner.options.any(
        (option) => option.seatId != null,
      ),
    );
    final skillReceipt = widget.firstValueReceiptLine == null
        ? null
        : _skillReceiptForSignalProofV1(
            proof: feedbackSignalProof,
            quality: option.quality,
          );
    final projection = _decisionTelemetryProjectionV1(option, kind: kind);
    _recordTelemetry(
      Act0TelemetryEventV1(
        name: 'task_result',
        fields: <String, Object?>{
          'schemaVersion': 1,
          if ((widget.selectedWorldId ?? '').trim().isNotEmpty)
            'worldId': widget.selectedWorldId!.trim(),
          'lessonId': _stableLessonTelemetryId,
          'taskId': _stableTaskTelemetryId,
          if (_actionSequenceTelemetryId != null)
            'sequenceId': _actionSequenceTelemetryId,
          'choiceId': option.id,
          'chosen_action': option.id,
          if (projection.expectedAction != null)
            'expected_action': projection.expectedAction,
          'correct': option.isCorrect,
          'result': projection.resultClassification,
          'result_classification': projection.resultClassification,
          'errorType': projection.errorType,
          'error_type': projection.errorType,
          if (projection.repairFamilyId != null)
            'repairFamilyId': projection.repairFamilyId,
          if (projection.repairFamilyId != null)
            'repair_family_id': projection.repairFamilyId,
          if (projection.repairTargetTaskId != null)
            'repairTargetTaskId': projection.repairTargetTaskId,
          if (projection.repairTargetTaskId != null)
            'repair_target_task_id': projection.repairTargetTaskId,
          if (projection.streetLabel.isNotEmpty)
            'street_v1': projection.streetLabel,
          'drill_kind': projection.drillKind,
          'attempt_id': projection.attemptId,
          if (feedbackSignalProof != null)
            'feedbackSignal': feedbackSignalProof.signalId,
          if (skillReceipt != null) 'skillReceiptId': skillReceipt.receiptId,
          if (skillReceipt != null) 'skillAtomId': skillReceipt.skillAtomId,
          if (skillReceipt != null) 'nextRepId': skillReceipt.nextRepId,
          if (skillReceipt != null)
            'skillReceiptOutcome': skillReceipt.outcome.telemetryValue,
          'attemptOrdinal': 1,
          'repairStatus': 'none',
        },
      ),
    );
  }

  bool _rejectInvalidAuthoredBettingPriceV1(Act0RunnerOptionV1 option) {
    if (!act0BettingPriceBlocksAuthoredSuccessV1(widget.runner.table, option)) {
      return false;
    }
    // This is a source error, not a learner mistake. Do not consume the
    // attempt, emit a grade, or forward a progress/repair/XP callback.
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        key: Key('act0_betting_price_unavailable'),
        content: Text(
          'This decision is temporarily unavailable. '
          'Return to Learn and choose another task.',
        ),
      ),
    );
    return true;
  }

  void _handleChooseOptionTelemetry(Act0RunnerOptionV1 option) {
    if (_assistanceExposurePendingV1 ||
        !_heroDecisionReady ||
        _decisionSubmittedForTaskV1) {
      return;
    }
    if (_rejectInvalidAuthoredBettingPriceV1(option)) return;
    _decisionSubmittedForTaskV1 = true;
    final telemetryDecisionTimeBucket = _decisionTimeBucketV1(
      _decisionTelemetryStopwatch.isRunning
          ? _decisionTelemetryStopwatch.elapsed
          : Duration.zero,
    );
    final decisionTimeBucket = _completedDecisionTimeBucket();
    _maybeEmitUserChoiceTelemetry(
      option,
      decisionTimeBucket: telemetryDecisionTimeBucket,
    );
    _emitCanonicalDecisionMadeTelemetryV1(
      option,
      decisionTimeBucket: telemetryDecisionTimeBucket,
    );
    _emitTaskResultTelemetryV1(
      option,
      kind: Act0CompletedDecisionKindV1.actionList,
    );
    widget.onChoiceAssistance?.call(_decisionAssistanceKindV1);
    widget.onChooseOption(option);
    _emitCompletedDecision(
      option,
      Act0CompletedDecisionKindV1.actionList,
      decisionTimeBucket: decisionTimeBucket,
    );
  }

  ({
    String? expectedAction,
    List<String> acceptableActionIds,
    String resultClassification,
    String errorType,
    String? repairFamilyId,
    String? repairTargetTaskId,
    String drillKind,
    String attemptId,
    List<String> boardCardIds,
    String streetLabel,
  })
  _decisionTelemetryProjectionV1(
    Act0RunnerOptionV1 option, {
    Act0CompletedDecisionKindV1 kind = Act0CompletedDecisionKindV1.actionList,
  }) {
    final expectedOption = widget.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (candidate) => candidate?.isCorrect ?? false,
          orElse: () => null,
        );
    final acceptableActionIds = widget.runner.options
        .where(
          (candidate) =>
              candidate.isCorrect ||
              candidate.quality == Act0FeedbackQualityV1.suboptimal,
        )
        .map((candidate) => candidate.id)
        .toList(growable: false);
    final receipt = act0FirstValueSkillReceiptForRunnerV1(
      runner: widget.runner,
      option: option,
      taskFamily: widget.selectedTaskFamily,
    );
    final resultClassification = switch (option.quality) {
      Act0FeedbackQualityV1.correct => 'correct',
      Act0FeedbackQualityV1.wrong => 'incorrect',
      Act0FeedbackQualityV1.suboptimal => 'suboptimal',
    };
    final concept = act0ConceptErrorDefinitionForTaskV1(
      worldId: widget.selectedWorldId?.trim() ?? '',
      lessonId: _stableLessonTelemetryId,
      taskId: _stableTaskTelemetryId,
    );
    final errorType = option.isCorrect
        ? 'none'
        : act0CanonicalErrorTypeForDecisionV1(
            result: option.quality == Act0FeedbackQualityV1.suboptimal
                ? 'suboptimal'
                : 'incorrect',
            skillAtomId:
                receipt?.skillAtomId ??
                concept?.eligibleRepairFamily ??
                'unknown',
            sourceTaskId: _stableTaskTelemetryId,
            sourceWorldId: widget.selectedWorldId?.trim() ?? '',
            sourceLessonId: _stableLessonTelemetryId,
          );
    final repairFamilyId = option.isCorrect
        ? null
        : concept?.eligibleRepairFamily ??
              (receipt == null
                  ? null
                  : '${receipt.skillAtomId}:${receipt.sourceSignalId}');
    return (
      expectedAction: expectedOption?.id,
      acceptableActionIds: acceptableActionIds,
      resultClassification: resultClassification,
      errorType: errorType,
      repairFamilyId: repairFamilyId,
      repairTargetTaskId: option.isCorrect ? null : receipt?.nextRepId,
      drillKind: widget.selectedTaskFamily?.name ?? 'unknown',
      attemptId: _canonicalCompletedAttemptIdV1(
        option,
        kind,
        _nextCompletedDecisionOrdinalV1(kind),
      ),
      boardCardIds: widget.runner.table.boardCards
          .map((card) => card.label)
          .where((label) => label.trim().isNotEmpty)
          .toList(growable: false),
      streetLabel: widget.runner.table.streetLabel.trim(),
    );
  }

  int _nextCompletedDecisionOrdinalV1(Act0CompletedDecisionKindV1 kind) {
    final taskKey =
        '${widget.evidenceRunId.trim()}|${widget.evidenceNextOrder}|'
        '${widget.selectedWorldId ?? ''}|'
        '$_stableLessonTelemetryId|$_stableTaskTelemetryId|${kind.name}';
    return _completedDecisionTaskKey == taskKey
        ? _completedDecisionOrdinal + 1
        : 1;
  }

  String _canonicalCompletedAttemptIdV1(
    Act0RunnerOptionV1 option,
    Act0CompletedDecisionKindV1 kind,
    int ordinal,
  ) {
    final runId = widget.evidenceRunId.trim();
    final worldId = widget.selectedWorldId?.trim() ?? '';
    final suffix =
        '$worldId|$_stableLessonTelemetryId|$_stableTaskTelemetryId|'
        '${kind.name}|${option.id}|$ordinal';
    if (widget.evidenceNextOrder <= 0) {
      // Backwards-compatible standalone/legacy runner consumers: product
      // owner always supplies next durable evidence order.
      return runId.isEmpty ? 'v1|$suffix' : 'v2|$runId|$suffix';
    }
    // Existing monotonic durable evidence order is stable across process
    // restore, and advances for each newly completed attempt.
    return 'v3|$runId|${widget.evidenceNextOrder}|$suffix';
  }

  void _handleChooseSeat(String seatId) {
    if (_assistanceExposurePendingV1 ||
        _isTheory ||
        widget.selectedTaskFamily == Act0TaskFamilyV1.learn ||
        !_heroDecisionReady ||
        _decisionSubmittedForTaskV1) {
      return;
    }
    final option = widget.runner.options.cast<Act0RunnerOptionV1?>().firstWhere(
      (candidate) => candidate?.seatId == seatId,
      orElse: () => null,
    );
    final elapsed = option != null && _decisionTelemetryStopwatch.isRunning
        ? _decisionTelemetryStopwatch.elapsed
        : null;
    final decisionTimeBucket = elapsed == null
        ? null
        : _decisionTimeBucketV1(elapsed);
    if (option != null) {
      _decisionSubmittedForTaskV1 = true;
      final telemetryDecisionTimeBucket = decisionTimeBucket ?? 'unknown';
      _maybeEmitUserChoiceTelemetry(
        option,
        decisionTimeBucket: telemetryDecisionTimeBucket,
        kind: Act0CompletedDecisionKindV1.seat,
      );
      _emitCanonicalDecisionMadeTelemetryV1(
        option,
        decisionTimeBucket: telemetryDecisionTimeBucket,
        kind: Act0CompletedDecisionKindV1.seat,
      );
      _emitTaskResultTelemetryV1(
        option,
        kind: Act0CompletedDecisionKindV1.seat,
      );
    }
    widget.onChoiceAssistance?.call(_decisionAssistanceKindV1);
    widget.onChooseSeat?.call(seatId);
    if (option != null) {
      _emitCompletedDecision(
        option,
        Act0CompletedDecisionKindV1.seat,
        decisionTimeBucket: decisionTimeBucket,
      );
    }
  }

  void _handleSelectSizingPresetV1(Act0SizingPresetV1 preset) {
    if (!_heroDecisionReady) {
      return;
    }
    widget.onSelectSizingPreset?.call(preset);
  }

  void _handleConfirmSizingPreset() {
    if (_assistanceExposurePendingV1 ||
        !_heroDecisionReady ||
        _decisionSubmittedForTaskV1) {
      return;
    }
    final presetId = widget.runner.selectedPresetId;
    final option = presetId == null
        ? null
        : widget.runner.options.cast<Act0RunnerOptionV1?>().firstWhere(
            (candidate) => candidate?.id == presetId,
            orElse: () => null,
          );
    if (option != null && _rejectInvalidAuthoredBettingPriceV1(option)) return;
    final decisionTimeBucket = _completedDecisionTimeBucket();
    if (option != null) {
      _decisionSubmittedForTaskV1 = true;
      final telemetryDecisionTimeBucket = _decisionTimeBucketV1(
        _decisionTelemetryStopwatch.isRunning
            ? _decisionTelemetryStopwatch.elapsed
            : Duration.zero,
      );
      _maybeEmitUserChoiceTelemetry(
        option,
        decisionTimeBucket: telemetryDecisionTimeBucket,
        kind: Act0CompletedDecisionKindV1.sizing,
      );
      _emitCanonicalDecisionMadeTelemetryV1(
        option,
        decisionTimeBucket: telemetryDecisionTimeBucket,
        kind: Act0CompletedDecisionKindV1.sizing,
      );
      _emitTaskResultTelemetryV1(
        option,
        kind: Act0CompletedDecisionKindV1.sizing,
      );
    }
    widget.onChoiceAssistance?.call(_decisionAssistanceKindV1);
    widget.onConfirmSizingPreset?.call();
    if (option != null) {
      _emitCompletedDecision(
        option,
        Act0CompletedDecisionKindV1.sizing,
        decisionTimeBucket: decisionTimeBucket,
      );
    }
  }

  void _emitCompletedDecision(
    Act0RunnerOptionV1 option,
    Act0CompletedDecisionKindV1 kind, {
    String? decisionTimeBucket,
  }) {
    final evidenceRunId = widget.evidenceRunId.trim();
    final taskKey =
        '$evidenceRunId|${widget.evidenceNextOrder}|${widget.selectedWorldId ?? ''}|'
        '$_stableLessonTelemetryId|$_stableTaskTelemetryId|${kind.name}';
    if (_completedDecisionTaskKey != taskKey) {
      _completedDecisionTaskKey = taskKey;
      _completedDecisionOrdinal = 0;
    }
    _completedDecisionOrdinal += 1;
    final expectedOption = widget.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (candidate) => candidate?.isCorrect ?? false,
          orElse: () => null,
        );
    final worldId = widget.selectedWorldId?.trim();
    final normalizedWorldId = worldId == null || worldId.isEmpty
        ? null
        : worldId;
    final receipt = act0FirstValueSkillReceiptForRunnerV1(
      runner: widget.runner,
      option: option,
      taskFamily: widget.selectedTaskFamily,
    );
    final resultKind = switch (option.quality) {
      Act0FeedbackQualityV1.correct => 'correct',
      Act0FeedbackQualityV1.wrong => 'incorrect',
      Act0FeedbackQualityV1.suboptimal => 'suboptimal',
    };
    final concept = act0ConceptErrorDefinitionForTaskV1(
      worldId: normalizedWorldId ?? '',
      lessonId: _stableLessonTelemetryId,
      taskId: _stableTaskTelemetryId,
    );
    final errorType = option.isCorrect
        ? 'none'
        : act0CanonicalErrorTypeForDecisionV1(
            result: option.quality == Act0FeedbackQualityV1.suboptimal
                ? 'suboptimal'
                : 'incorrect',
            skillAtomId:
                receipt?.skillAtomId ??
                concept?.eligibleRepairFamily ??
                'unknown',
            sourceTaskId: _stableTaskTelemetryId,
            sourceWorldId: normalizedWorldId ?? '',
            sourceLessonId: _stableLessonTelemetryId,
          );
    widget.onCompletedDecision?.call(
      Act0CompletedDecisionV1(
        attemptKey: _canonicalCompletedAttemptIdV1(
          option,
          kind,
          _completedDecisionOrdinal,
        ),
        worldId: normalizedWorldId,
        lessonId: _stableLessonTelemetryId,
        taskId: _stableTaskTelemetryId,
        sourceTaskId: _stableTaskTelemetryId,
        decisionKind: kind,
        selectedId: option.id,
        expectedId: expectedOption?.id,
        isCorrect: option.isCorrect,
        decisionTimeBucket:
            decisionTimeBucket ?? _completedDecisionTimeBucket(),
        taskFamily: widget.selectedTaskFamily,
        assistanceKind: _decisionAssistanceKindV1,
        resultKind: resultKind,
        errorType: errorType,
        skillAtomId: receipt?.skillAtomId ?? concept?.eligibleRepairFamily,
        repairFocusId: receipt?.sourceSignalId ?? concept?.id,
        missedSignalId: receipt?.sourceSignalId ?? concept?.id,
      ),
    );
  }

  String _completedDecisionTimeBucket() {
    if (!_decisionTelemetryStopwatch.isRunning) {
      return 'unknown';
    }
    final elapsed = _decisionTelemetryStopwatch.elapsed;
    if (elapsed < const Duration(seconds: 3)) {
      return 'under_3s';
    }
    if (elapsed < const Duration(seconds: 10)) {
      return '3_to_10s';
    }
    return 'over_10s';
  }

  bool _allowsInteractiveShowdown(Act0RunnerStateV1 runner) {
    final id = runner.lessonId.toLowerCase();
    return id.contains('showdown') ||
        id.contains('flush') ||
        id.contains('straight') ||
        id.contains('rank') ||
        id.contains('kicker') ||
        id.contains('best_five');
  }

  void _onBoardTappedForShowdown(Act0TableStateV1 table) {
    // Solver-derived best-five cues are help, not unassisted assessment input.
    // Keep explanation/review and explicitly assisted decisions available.
    if (_decisionAssistanceKindV1 == Act0DecisionAssistanceV1.none &&
        _isActiveAssessmentStateV1(
          isTeaching: _isTeaching,
          isReview: _isReview,
          runner: widget.runner,
        )) {
      return;
    }
    if (!_allowsInteractiveShowdown(widget.runner)) {
      return;
    }
    final insight = _computeShowdownInsight(table);
    if (insight == null) {
      setState(() {
        _interactiveHighlightedCardIds = const <String>[];
        _interactiveShowdownLine = '';
      });
      return;
    }
    setState(() {
      _interactiveHighlightedCardIds = insight.highlightedCardIds;
      _interactiveShowdownLine = insight.summaryLine;
    });
  }

  String? _activeSeatIdFromActionTrail(
    Act0TableStateV1 table,
    int? focusedIndex,
  ) {
    if (focusedIndex == null || table.actionTrail.isEmpty) {
      return null;
    }
    final index = focusedIndex.clamp(0, table.actionTrail.length - 1);
    final label = table.actionTrail[index].label;
    final match = RegExp(
      r'\b(UTG|HJ|CO|BTN|SB|BB|HERO)\b',
      caseSensitive: false,
    ).firstMatch(label);
    if (match == null) {
      return null;
    }
    final token = (match.group(1) ?? '').trim().toUpperCase();
    if (token == 'HERO') {
      return table.heroSeatId ?? table.heroSeat.seatId;
    }
    for (final seat in table.seats) {
      if (seat.seatLabel.trim().toUpperCase() == token) {
        return seat.seatId;
      }
    }
    return null;
  }

  Act0SeatBetStateV1? _deriveBetFromTrailStep(
    Act0TableStateV1 table,
    int? focusedIndex,
  ) {
    if (focusedIndex == null || table.actionTrail.isEmpty) {
      return null;
    }
    final index = focusedIndex.clamp(0, table.actionTrail.length - 1);
    final raw = table.actionTrail[index].label.trim();
    // Strip street prefix: "Flop: BB checks" \u2192 "BB checks"
    final stripped = raw.replaceFirst(
      RegExp(r'^(Flop|Turn|River):\s*', caseSensitive: false),
      '',
    );

    // Blind post: "SB blind 0.5 BB" / "BB blind 1 BB"
    final blindMatch = RegExp(
      r'^(SB|BB)\s+blind\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (blindMatch != null) {
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: blindMatch.group(1)!.toUpperCase(),
        amountLabel: blindMatch.group(2)!.trim(),
      );
    }

    // Raise: "BTN raises" / "BTN raises 2.5 BB" / "BTN opens 2.5 BB" / "BTN opened" / "CO opens"
    final raiseMatch = RegExp(
      r'^(\w+)\s+(raises?|opens?|opened)\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (raiseMatch != null) {
      final seat = raiseMatch.group(1)!.toUpperCase();
      final amt = (raiseMatch.group(3) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: seat,
        amountLabel: amt.isNotEmpty ? amt : 'raise',
      );
    }

    // Call: "BB calls" / "BB calls 2.5 BB" / "BB called"
    final callMatch = RegExp(
      r'^(\w+)\s+(calls?|called)\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (callMatch != null) {
      final seat = callMatch.group(1)!.toUpperCase();
      final amt = (callMatch.group(3) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.call,
        label: seat,
        amountLabel: amt.isNotEmpty ? amt : 'call',
      );
    }

    // Bet: "BTN bets 2 BB" / "BTN bet 2 BB"
    final betMatch = RegExp(
      r'^(\w+)\s+bets?\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (betMatch != null) {
      final seat = betMatch.group(1)!.toUpperCase();
      final amt = (betMatch.group(2) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.bet,
        label: seat,
        amountLabel: amt.isNotEmpty ? amt : 'bet',
      );
    }

    // All-in: "BTN all-in" / "UTG goes all in 50 BB" / "Hero shoves 20 BB"
    final allInMatch = RegExp(
      r'^(\w+)\s+(all[- ]?in|goes all(?:\s+in)?|shoves?|shoved)\s*(.*)?$',
      caseSensitive: false,
    ).firstMatch(stripped);
    if (allInMatch != null) {
      final amt = (allInMatch.group(3) ?? '').trim();
      return Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.allIn,
        label: allInMatch.group(1)!.toUpperCase(),
        amountLabel: amt.isNotEmpty ? amt : 'all-in',
      );
    }

    // Folds / checks \u2192 no chip
    return null;
  }

  // \u2500\u2500 Pot calculation \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  /// Calculates the running pot by replaying the trail up to [upToIndex].
  /// Delegates to top-level [act0CalcTrailPotV1].
  ({double potBb, String street}) _calculatePotAtTrailIndex(
    Act0TableStateV1 table,
    int upToIndex,
  ) {
    return act0CalcTableTrailPotV1(table, upToIndex);
  }

  /// Delegates to top-level [act0FormatPotLabelV1].
  String _formatPotLabel(double bb) => act0FormatPotLabelV1(bb);

  // \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  _Act0ShowdownInsightV1? _computeShowdownInsight(Act0TableStateV1 table) {
    if (table.scope != Act0TableScopeV1.playedHand ||
        table.boardCards.length != 5 ||
        table.heroCards.length != 2) {
      return null;
    }
    // A best-hand comparison needs every source-live opponent. Silently
    // skipping a hidden/malformed hand would manufacture a winner. This is
    // disclosure validation only; no history, stack or payout is inferred.
    final liveSeats = table.seats
        .where((seat) => seat.isInHand && !seat.isFolded)
        .toList(growable: false);
    if (liveSeats.length < 2 ||
        liveSeats.where((seat) => seat.isHero).length != 1 ||
        liveSeats.any((seat) => !seat.isOccupied) ||
        table.seats.map((seat) => seat.seatId).toSet().length !=
            table.seats.length) {
      return null;
    }
    final heroSeat = liveSeats.singleWhere((seat) => seat.isHero);
    final explicitHeroSeatId = table.heroSeatId?.trim() ?? '';
    if (explicitHeroSeatId.isNotEmpty &&
        explicitHeroSeatId != heroSeat.seatId) {
      return null;
    }
    final heroKeys = table.heroCards.map(_toSolverCard).toList();
    final heroSeatKeys = heroSeat.holeCards.map(_toSolverCard).toList();
    if (heroKeys.any((key) => key == null) ||
        heroSeatKeys.length != 2 ||
        heroKeys.toSet().length != 2 ||
        heroSeatKeys.toSet().length != 2 ||
        !heroKeys.toSet().containsAll(heroSeatKeys)) {
      return null;
    }
    for (final seat in liveSeats.where((seat) => !seat.isHero)) {
      if (seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp ||
          seat.holeCards.length != 2)
        return null;
    }
    final physicalCards = <String>{};
    for (final card in [
      ...table.boardCards,
      ...table.heroCards,
      for (final seat in table.seats)
        if (!seat.isHero &&
            seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
          ...seat.holeCards,
    ]) {
      final key = _toSolverCard(card);
      if (key == null || !physicalCards.add(key)) return null;
    }
    final board = <String>[];
    final boardByCard = <String, List<String>>{};
    for (var i = 0; i < table.boardCards.length && i < 5; i++) {
      final solver = _toSolverCard(table.boardCards[i]);
      if (solver == null) {
        return null;
      }
      board.add(solver);
      boardByCard.putIfAbsent(solver, () => <String>[]).add('board_$i');
    }

    final participants = <_Act0ShowdownParticipantV1>[];
    final heroCards = <String>[];
    final heroByCard = <String, List<String>>{};
    for (var i = 0; i < table.heroCards.length && i < 2; i++) {
      final solver = _toSolverCard(table.heroCards[i]);
      if (solver == null) {
        continue;
      }
      heroCards.add(solver);
      heroByCard.putIfAbsent(solver, () => <String>[]).add('hero_$i');
    }
    if (heroCards.length >= 2) {
      participants.add(
        _Act0ShowdownParticipantV1(
          seatId: table.heroSeatId ?? table.heroSeat.seatId,
          displayLabel: 'You',
          cards: heroCards,
          cardIdsBySolver: heroByCard,
        ),
      );
    }

    for (final seat in table.seats) {
      if (seat.isHero ||
          seat.holeCards.length < 2 ||
          seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp ||
          seat.isFolded ||
          !seat.isInHand) {
        continue;
      }
      final seatCards = <String>[];
      final seatByCard = <String, List<String>>{};
      for (var i = 0; i < seat.holeCards.length && i < 2; i++) {
        final solver = _toSolverCard(seat.holeCards[i]);
        if (solver == null) {
          continue;
        }
        seatCards.add(solver);
        seatByCard
            .putIfAbsent(solver, () => <String>[])
            .add('${seat.seatId}_$i');
      }
      if (seatCards.length >= 2) {
        participants.add(
          _Act0ShowdownParticipantV1(
            seatId: seat.seatId,
            displayLabel: seat.seatLabel,
            cards: seatCards,
            cardIdsBySolver: seatByCard,
          ),
        );
      }
    }

    if (participants.isEmpty) {
      return null;
    }

    final hands = <int, Hand>{};
    for (var i = 0; i < participants.length; i++) {
      hands[i] = Hand.solveHand(<String>[...board, ...participants[i].cards]);
    }
    if (hands.isEmpty) {
      return null;
    }
    final winningHands = Hand.winners(hands.values.toList());
    final winnerIndexes = <int>[
      for (final entry in hands.entries)
        if (winningHands.contains(entry.value)) entry.key,
    ];
    if (winnerIndexes.isEmpty) {
      return null;
    }

    final highlighted = <String>{};
    for (final winnerIndex in winnerIndexes) {
      final winner = participants[winnerIndex];
      final hand = hands[winnerIndex]!;
      for (final card in hand.cards) {
        final cardKey = card.toString();
        highlighted.addAll(boardByCard[cardKey] ?? const <String>[]);
        highlighted.addAll(winner.cardIdsBySolver[cardKey] ?? const <String>[]);
      }
    }

    final leadWinner = winnerIndexes.first;
    final leadHand = hands[leadWinner]!;
    final winnerLabels = winnerIndexes
        .map((index) => participants[index].displayLabel)
        .toList(growable: false);
    final winnerPhrase = winnerLabels.join(' & ');
    String summary;
    if (winnerIndexes.length > 1) {
      summary =
          'Tied best hands: $winnerPhrase with ${_humanHandName(leadHand)}.';
    } else {
      final loserCandidates = <int>[
        for (final idx in hands.keys)
          if (idx != leadWinner) idx,
      ];
      if (loserCandidates.isNotEmpty) {
        var bestLoser = loserCandidates.first;
        for (final idx in loserCandidates.skip(1)) {
          if (hands[idx]!.compare(hands[bestLoser]!) < 0) {
            bestLoser = idx;
          }
        }
        summary =
            'Best shown hand: $winnerPhrase with ${_humanHandName(leadHand)} over ${_humanHandName(hands[bestLoser]!)}.';
      } else {
        summary =
            'Best shown hand: $winnerPhrase with ${_humanHandName(leadHand)}.';
      }
    }

    if (highlighted.isEmpty) {
      highlighted.addAll(
        List<String>.generate(board.length, (index) => 'board_$index'),
      );
    }
    return _Act0ShowdownInsightV1(
      highlightedCardIds: highlighted.toList(growable: false),
      summaryLine: summary,
    );
  }

  String _humanHandName(Hand hand) {
    final raw = (hand.descr ?? hand.name).trim();
    if (raw.isEmpty) {
      return 'best hand';
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String? _toSolverCard(Act0CardStateV1 card) {
    final rank = _toSolverRank(card.rank);
    final suit = _toSolverSuit(card.suit);
    if (rank == null || suit == null) {
      return null;
    }
    return '$rank$suit';
  }

  String? _toSolverRank(String rank) {
    final normalized = rank.trim().toUpperCase();
    if (normalized == '10') {
      return 'T';
    }
    const allowed = <String>{
      'A',
      'K',
      'Q',
      'J',
      'T',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2',
    };
    return allowed.contains(normalized) ? normalized : null;
  }

  String? _toSolverSuit(String suit) {
    switch (suit.trim().toLowerCase()) {
      case 's':
      case '\u2660':
        return 's';
      case 'h':
      case '\u2665':
        return 'h';
      case 'd':
      case '\u2666':
        return 'd';
      case 'c':
      case '\u2663':
        return 'c';
      default:
        return null;
    }
  }

  bool _shouldShowPotSweep(Act0RunnerStateV1 runner) {
    if (runner.phase != Act0LessonPhaseV1.review) {
      return false;
    }
    if (runner.reviewQuality == Act0FeedbackQualityV1.wrong) {
      return false;
    }
    if (runner.table.potLabel.trim().isEmpty) {
      return false;
    }
    final text =
        '${runner.lessonId} ${runner.lessonTitle} ${runner.reviewTitle} ${runner.reviewReason}'
            .toLowerCase();
    return text.contains('showdown') ||
        text.contains('win at showdown') ||
        text.contains('wins the pot') ||
        text.contains('split pot') ||
        text.contains('tie the pot') ||
        text.contains('board plays') ||
        text.contains('which hand wins');
  }

  Duration get _currentTheoryAdvanceLockDuration =>
      widget.relaxTheoryAdvanceLock
      ? _replayAdvanceLockDuration
      : _theoryAdvanceLockDuration;

  String get _currentAdvanceLockKey {
    if (!_showBottomLearningRail) {
      return '';
    }
    return '${widget.runner.lessonId}|${widget.runner.beatIndex}|${widget.runner.phase.name}|${widget.runner.teachingStepIndex}|${widget.runner.selectedOptionId ?? ''}';
  }

  Future<void> _openTheoryRecallSheet() async {
    final step = widget.theoryRecallStep;
    if (step == null) {
      return;
    }
    if (!await _exposeDecisionAssistanceV1(
      Act0DecisionAssistanceV1.theoryRecall,
    ))
      return;
    // Seat-choice drills use a modal rather than the ordinary inline peek.
    // Apply the same pre-choice answer guard to both assistance routes.
    final safeIdea = _preChoiceTheoryIdeaV1(
      taskFamily: widget.selectedTaskFamily,
      runner: widget.runner,
      question: widget.runner.question,
      fullIdeaStep: step,
    );
    final bodyBlocks = act0BuildInstructionBlocksV1(
      text: safeIdea.body,
      compact: true,
    );
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => _TheoryRecallSheetV1(
        label: act0RuntimeTheoryRecallLabelV1(context),
        title: safeIdea.title,
        bodyBlocks: bodyBlocks,
      ),
    );
  }

  Future<bool> _exposeDecisionAssistanceV1(
    Act0DecisionAssistanceV1 kind,
  ) async {
    if (_assistanceExposurePendingV1 || _decisionSubmittedForTaskV1)
      return false;
    final epoch = ++_assistanceExposureEpochV1;
    final source = _compositionTaskIdentity(widget);
    final interaction = _interactionKey(widget.runner);
    final request = widget.onAssistanceExposureRequested;
    if (request != null) {
      // Before showing any assistance, commit an uncertainty marker. If the
      // process dies before the known-kind upgrade, it cannot resume as unaided.
      _decisionAssistanceKindV1 = act0MergeDecisionAssistanceV1(
        _decisionAssistanceKindV1,
        Act0DecisionAssistanceV1.legacyUnknown,
      );
      setState(() => _assistanceExposurePendingV1 = true);
      var acknowledged = false;
      try {
        acknowledged = await request(kind).timeout(const Duration(seconds: 10));
      } catch (_) {
        // An indeterminate save never licenses exposing unrecorded assistance.
      }
      if (!mounted || epoch != _assistanceExposureEpochV1) return false;
      setState(() => _assistanceExposurePendingV1 = false);
      if (!acknowledged) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              act0AcademyLanguageV1(context) == 'ru'
                  ? '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u0441\u043e\u0445\u0440\u0430\u043d\u0438\u0442\u044c \u0438\u0441\u043f\u043e\u043b\u044c\u0437\u043e\u0432\u0430\u043d\u0438\u0435 \u043f\u043e\u043c\u043e\u0449\u0438. \u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u0435 \u043f\u043e\u043f\u044b\u0442\u043a\u0443.'
                  : 'Help could not be saved. Please try again.',
            ),
          ),
        );
        return false;
      }
    }
    if (!mounted ||
        epoch != _assistanceExposureEpochV1 ||
        source != _compositionTaskIdentity(widget) ||
        interaction != _interactionKey(widget.runner))
      return false;
    _decisionAssistanceKindV1 = act0MergeDecisionAssistanceV1(
      _decisionAssistanceKindV1,
      kind,
    );
    widget.onChoiceAssistance?.call(_decisionAssistanceKindV1);
    return true;
  }

  Future<void> _openTheoryRecallPeek() async {
    if (widget.theoryRecallStep == null || _showTheoryPeek) return;
    if (!await _exposeDecisionAssistanceV1(Act0DecisionAssistanceV1.quickHint))
      return;
    if (mounted) setState(() => _showTheoryPeek = true);
  }

  void _closeTheoryRecallPeek() {
    if (!_showTheoryPeek) {
      return;
    }
    setState(() {
      _assistanceExposureEpochV1 += 1;
      _assistanceExposurePendingV1 = false;
      _showTheoryPeek = false;
      _showFullIdeaInTheoryPeek = false;
    });
  }

  void _syncTheoryAdvanceLock({bool initial = false}) {
    final nextKey = _currentAdvanceLockKey;
    if (nextKey.isEmpty) {
      _theoryUnlockTimer?.cancel();
      _advanceLockKey = '';
      if (initial) {
        _canAdvanceTheory = true;
      } else if (!_canAdvanceTheory) {
        setState(() => _canAdvanceTheory = true);
      }
      return;
    }
    if (_advanceLockKey == nextKey) {
      // Rebuilding the same step must not cancel the pending dwell unlock.
      return;
    }
    _theoryUnlockTimer?.cancel();
    _advanceLockKey = nextKey;
    if (initial) {
      _canAdvanceTheory = false;
    } else {
      setState(() => _canAdvanceTheory = false);
    }
    _theoryUnlockTimer = Timer(_currentTheoryAdvanceLockDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _canAdvanceTheory = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final runner = widget.runner;
    final isTheory = _isTheory;
    final isDrill = runner.phase == Act0LessonPhaseV1.drill;
    final isReview = _isReview;
    final accessibilityStep = widget.accessibilityPrototypeStep;
    final isAccessibilityFlow = accessibilityStep != null;
    final isAccessibilityDirectDecision = isAccessibilityFlow && !isReview;
    final isRefinedDev2 = _isRefinedDev2;
    final teachingStep = _teachingStep;
    final isTeaching = _isTeaching;
    final prompt = isTeaching
        ? act0AcademyTeachingCopyV1(
            context,
            runnerLessonId: runner.lessonId,
            source: teachingStep!.title,
            fallback: act0LocalizedTeachingStepTitleAtomByTaskIdV1(
              widget.selectedTaskId,
              runner.teachingStepIndex,
              fallback: teachingStep.title,
              languageCode: act0AcademyLanguageV1(context),
            ),
          )
        : act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
        ? act0AcademyW1InstructionV1(
            context,
            widget.selectedTaskId,
            runner.caption,
          )
        : act0LocalizedRunnerPromptAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: runner.caption,
            languageCode: act0AcademyLanguageV1(context),
          );
    final shouldShowRunnerHint = switch (runner.hintPolicy) {
      Act0HintPolicyV1.always => true,
      Act0HintPolicyV1.theoryOnly => isTheory,
      Act0HintPolicyV1.hidden => false,
    };
    final hint = isTeaching
        ? act0AcademyTeachingCopyV1(
            context,
            runnerLessonId: runner.lessonId,
            source: teachingStep!.body,
            fallback: act0LocalizedTeachingStepBodyAtomByTaskIdV1(
              widget.selectedTaskId,
              runner.teachingStepIndex,
              fallback: teachingStep.body,
              languageCode: act0AcademyLanguageV1(context),
            ),
          )
        : act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
        ? act0AcademyW1InstructionV1(
            context,
            widget.selectedTaskId,
            shouldShowRunnerHint ? runner.hint : '',
          )
        : act0LocalizedRunnerSupportAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: shouldShowRunnerHint ? runner.hint : '',
            languageCode: act0AcademyLanguageV1(context),
          );
    final question = widget.preserveSourceOwnedQuestion
        ? runner.question
        : act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
        ? act0AcademyW1InstructionV1(
            context,
            widget.selectedTaskId,
            runner.question,
          )
        : act0LocalizedRunnerQuestionAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: runner.question,
            languageCode: act0AcademyLanguageV1(context),
          );
    final learningRailSupportSegments = act0BuildLearningRailSupportSegmentsV1(
      hint: hint,
      focusLabels: widget.showLearningRailFocusLabels
          ? teachingStep?.focusLabels ?? const <String>[]
          : const <String>[],
      compact: isRefinedDev2,
    );
    // The lower-surface prototype treats authored theory as deterministic
    // pages. This reuses the content policy's bounded segments but includes
    // the prompt in the same page stream, so no content is hidden behind a
    // rail scroll view.
    final learningRailText = <String>[
      prompt,
      hint,
    ].where((line) => line.trim().isNotEmpty).join(' ');
    final learningRailPages = runner.phase == Act0LessonPhaseV1.theory
        ? act0BuildInstructionBlocksV1(
            text: learningRailText,
            compact: isRefinedDev2,
          )
        : act0BuildSupportingCopyBlocksV1(
            text: learningRailText,
            compact: isRefinedDev2,
          );
    final effectiveLearningRailPages =
        _usesCanonicalIntegratedLearningSceneV1 && isTheory
        ? <String>[hint.trim().isNotEmpty ? hint : prompt]
        : learningRailPages.isNotEmpty
        ? learningRailPages
        : learningRailSupportSegments;
    final cappedSupportSegmentIndex = effectiveLearningRailPages.isEmpty
        ? 0
        : _learningRailSupportSegmentIndex.clamp(
            0,
            effectiveLearningRailPages.length - 1,
          );
    final hasNextSupportSegment =
        cappedSupportSegmentIndex < effectiveLearningRailPages.length - 1;
    final hasPreviousSupportSegment = cappedSupportSegmentIndex > 0;
    final learningRailProgress = isRefinedDev2
        ? null
        : _learningRailProgressLabel(runner);
    final theoryPresentationRole = _showBottomLearningRail
        ? resolveAct0TheoryPresentationRoleV1(
            taskId: widget.selectedTaskId,
            runner: runner,
            teachingStepIndex: runner.teachingStepIndex,
          )
        : null;
    final hasSeatTargets = runner.options.any(
      (option) => option.seatId != null,
    );
    final baseTable = isReview
        ? act0RepairTableForRunnerV1(runner.table, runner.selectedOption)
        : act0TeachingTableForRunnerV1(runner.table, teachingStep);
    final feedbackSignalProof = isReview
        ? _feedbackSignalProofForRunnerV1(
            runner: runner,
            option: runner.selectedOption,
            taskFamily: widget.selectedTaskFamily,
            hasSeatTargets: hasSeatTargets,
          )
        : null;
    final table = isReview
        ? act0FeedbackTableForRunnerV1(
            runner: runner,
            taskFamily: widget.selectedTaskFamily,
          )
        : baseTable;
    final choreographyFrame = _tableChoreographyFrame;
    final activeChoreographyFrame =
        isDrill && !isTeaching && !_heroDecisionReady
        ? choreographyFrame
        : null;
    final choreographyActive = activeChoreographyFrame != null;
    final choreographedTable = activeChoreographyFrame == null
        ? table
        : act0TableForChoreographyFrameV1(table, activeChoreographyFrame);
    // Both board overlays and seat-card renderers consume this projection.
    // Keep the source table intact for teaching, requested help and feedback.
    final isActiveAssessment = _isActiveAssessmentStateV1(
      isTeaching: isTeaching,
      isReview: isReview,
      runner: runner,
    );
    final presentationTable = act0PredecisionCardFocusV1(
      isActiveAssessment && widget.worldNumber >= 1 && widget.worldNumber <= 4
          ? choreographedTable.copyWith(highlightedSeatIds: const [])
          : choreographedTable,
      isActiveAssessment: isActiveAssessment,
    );
    final sourceIdentityPolicy = act0TableIdentityPolicyForTeachingSemanticsV1(
      teachingStep?.identityTeachingSemantics ??
          Act0TableIdentityTeachingSemanticsV1.legacy,
    );
    final streetReplay = act0StreetReplayFromTableV1(table);
    final interactionMode = _resolveRunnerInteractionModeV1(
      isDrill: isDrill,
      isReview: isReview,
      hasSeatTargets: hasSeatTargets,
    );
    final framingProfile = _resolveRunnerFramingProfileV1(
      requestedProfile: widget.framingProfile,
      interactionMode: interactionMode,
      runner: runner,
      table: table,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final viewportFamily = _resolveRunnerViewportFamilyV1(
      framingProfile: framingProfile,
      hasSeatTargets: hasSeatTargets,
    );
    final bottomContext = _resolveRunnerBottomContextV1(
      context,
      runner: runner,
      table: table,
      isTeaching: isTeaching,
      isTheory: isTheory,
      isDrill: isDrill,
      isReview: isReview,
      showBottomLearningRail: _showBottomLearningRail,
      hasSeatTargets: hasSeatTargets,
      taskFamily: widget.selectedTaskFamily,
    );
    final compactBottomDockClearance =
        isRefinedDev2 && table.density == Act0TableDensityV1.compactLesson;
    final centerLabelOverride = _resolveTableCueDisplayV1(
      context: context,
      selectedTaskId: widget.selectedTaskId,
      runner: runner,
      table: table,
      isTeaching: isTeaching,
      isReview: isReview,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final centerStatDisplay = _resolveCenterStatDisplayV1(
      context,
      runner: runner,
      table: table,
      bottomContext: bottomContext,
      centerCueLabel: centerLabelOverride,
      isTeaching: isTeaching,
      isReview: isReview,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final lateRouteTableSignal = act0LateRouteTableSignalForWorldNumberV1(
      widget.worldNumber,
    );
    // The original source task is intentionally replayed after a mapped
    // repair. Keep that identity visible so it cannot read as another
    // authored hand before its result finalizes.
    final authoredTaskTitle = widget.selectedTaskTitle?.trim() ?? '';
    // ASM-04: a pending assessment must not name its answer in the task rail;
    // the authored title returns once the current decision is submitted.
    final selectedTaskTitle = authoredTaskTitle.isEmpty
        ? authoredTaskTitle
        : act0PrechoiceDisplayTitleV1(
            taskId: widget.selectedTaskId ?? '',
            authoredTitle: authoredTaskTitle,
            isAssessment: runner.options.isNotEmpty,
            hasSubmittedCurrentDecision: !_isActiveAssessmentStateV1(
              isTeaching: isTeaching,
              isReview: isReview,
              runner: runner,
            ),
          );
    final taskRailLabel = widget.isSourceRecheckAttempt
        ? 'Original read recheck'
        : selectedTaskTitle.isNotEmpty
        ? selectedTaskTitle
        : bottomContext.taskLabel;
    final theoryCoachLine = act0RuntimeTheoryCoachLineV1(
      context,
      authoredLine: runner.sharky.preSessionLine,
      lessonId: runner.lessonId,
      beatIndex: runner.beatIndex,
      teachingStepIndex: runner.teachingStepIndex,
      taskFamily: widget.selectedTaskFamily,
      prompt: prompt,
      supportLine: effectiveLearningRailPages.isEmpty
          ? hint
          : effectiveLearningRailPages[cappedSupportSegmentIndex],
    );
    final promptCoachLine = act0RuntimePromptCoachLineV1(
      context,
      lessonId: runner.lessonId,
      beatIndex: runner.beatIndex,
      question: question,
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
      isTrailHistory: bottomContext.isTrailHistory,
    );
    final promptContextLine =
        bottomContext.promptSupportLine?.trim().isNotEmpty == true
        ? bottomContext.promptSupportLine
        : (bottomContext.isTrailHistory ? null : promptCoachLine);
    final showStreetReplayInline =
        (table.decisionSeatId == null ||
            // A new priced source snapshot certifies its current pot, not
            // per-action pots in the legacy compact street annotations.
            (_tableChoreographyActorFocusSafeV1() &&
                table.toCallLabel.trim().isEmpty)) &&
        _heroDecisionReady &&
        streetReplay?.isConsumerSafe == true &&
        isDrill &&
        !isTeaching;
    final decisionHintFromSource = _resolveDecisionHintV1(
      taskFamily: widget.selectedTaskFamily,
      runner: runner,
      prompt: prompt,
      question: question,
      supportLine: promptContextLine ?? hint,
      fullIdeaStep: widget.theoryRecallStep,
    );
    final decisionHint = decisionHintFromSource == null
        ? null
        : act0AcademyLanguageV1(context) == 'ru' &&
              act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
        ? _DecisionHintV1(
            quickHint: act0AcademyW1InstructionV1(
              context,
              widget.selectedTaskId,
              runner.hint,
            ),
            fullIdeaTitle: decisionHintFromSource.fullIdeaTitle,
            fullIdeaBlocks: decisionHintFromSource.fullIdeaBlocks,
          )
        : decisionHintFromSource;
    final theoryRecallPeek = decisionHint == null
        ? null
        : _DecisionHintPeekV1(
            quickHint: decisionHint.quickHint,
            localizeW1Ctas: act0AcademyW1InstructionTaskV1(
              widget.selectedTaskId,
            ),
            fullIdeaTitle: decisionHint.fullIdeaTitle,
            fullIdeaBlocks: decisionHint.fullIdeaBlocks,
            showFullIdea: _showFullIdeaInTheoryPeek,
            onShowFullIdea: decisionHint.hasFullIdea
                ? () async {
                    if (!await _exposeDecisionAssistanceV1(
                      Act0DecisionAssistanceV1.theoryRecall,
                    ))
                      return;
                    if (mounted)
                      setState(() {
                        _showFullIdeaInTheoryPeek = true;
                      });
                  }
                : null,
            onClose: _closeTheoryRecallPeek,
          );
    final showStepIntro =
        isTeaching && runner.teachingStepIndex == 0 && runner.beatIndex > 1;
    final showTopInstructionCard = !isRefinedDev2;
    final pageX = isRefinedDev2 ? 8.0 : Act0ShellTokensV1.runnerPageX;
    final compactTableStageTopInset = 0.0;
    final showCompletionToast =
        isRefinedDev2 &&
        isReview &&
        runner.reviewQuality != Act0FeedbackQualityV1.wrong &&
        widget.completionSummary != null &&
        !widget.isAssistedDecision;
    final interactionKey = _interactionKey(runner);
    if (_showdownInteractionKey != interactionKey) {
      _actionTrailFocusedIndex = null;
      _showdownInteractionKey = interactionKey;
      _interactiveHighlightedCardIds = const <String>[];
      _interactiveShowdownLine = '';
    }
    final trailPlaybackEnabled =
        _heroDecisionReady &&
        table.scope == Act0TableScopeV1.playedHand &&
        _actionTrailFocusedIndex != null &&
        _actionTrailFocusedIndex! >= 0 &&
        _actionTrailFocusedIndex! < table.actionTrail.length &&
        !table.actionTrail[_actionTrailFocusedIndex!].isNote &&
        !isTeaching;
    final mergedHighlightIds = <String>{
      ...presentationTable.highlightedCardIds,
      ..._interactiveHighlightedCardIds,
    }.toList(growable: false);
    final playbackActiveSeatId =
        activeChoreographyFrame?.focusSeatId ??
        (trailPlaybackEnabled
            ? _activeSeatIdFromActionTrail(table, _actionTrailFocusedIndex)
            : null);
    final choreographyCommitmentSeatId =
        activeChoreographyFrame?.latestCommitmentSeatId;
    final choreographyBetOverride =
        activeChoreographyFrame != null && choreographyCommitmentSeatId != null
        ? activeChoreographyFrame.commitments[choreographyCommitmentSeatId]
        : null;
    final betOverride =
        choreographyBetOverride ??
        (trailPlaybackEnabled
            ? _deriveBetFromTrailStep(table, _actionTrailFocusedIndex)
            : null);
    // Dynamic pot & street derived from replaying the trail up to current step.
    String? playbackPotLabel;
    String? playbackStreetLabel;
    if (trailPlaybackEnabled && _actionTrailFocusedIndex != null) {
      final calc = _calculatePotAtTrailIndex(table, _actionTrailFocusedIndex!);
      if (calc.potBb >= 0) {
        playbackPotLabel = _formatPotLabel(calc.potBb);
        playbackStreetLabel = calc.street.isNotEmpty ? calc.street : null;
      }
    }
    final teachingFocusLabel = teachingStep?.focusLabels
        .where((label) => label.trim().isNotEmpty)
        .firstOrNull;
    final interactiveCallout = _interactiveShowdownLine.trim().isNotEmpty
        ? _interactiveShowdownLine
        : isReview
        ? feedbackSignalProof?.label ?? ''
        : isTheory
        ? teachingFocusLabel ?? ''
        : hasSeatTargets && isDrill
        ? (act0IsRuLocaleV1(context)
              ? '\u041D\u0430\u0436\u043C\u0438\u0442\u0435 \u043D\u0430 \u043F\u043E\u0434\u0441\u0432\u0435\u0447\u0435\u043D\u043D\u043E\u0435 \u043C\u0435\u0441\u0442\u043E'
              : 'Tap a highlighted seat')
        : '';
    final rawShowActionTrail =
        _heroDecisionReady && bottomContext.showActionTrail;
    final selectedSeatId = runner.selectedOption?.seatId?.trim();
    final selectedSeatFeedbackState = switch (runner.reviewQuality) {
      Act0FeedbackQualityV1.wrong => _SeatSelectionFeedbackStateV1.wrong,
      Act0FeedbackQualityV1.correct || Act0FeedbackQualityV1.suboptimal =>
        selectedSeatId != null && selectedSeatId.isNotEmpty
            ? _SeatSelectionFeedbackStateV1.confirmed
            : _SeatSelectionFeedbackStateV1.none,
    };
    final compactAnswerListDecision =
        _usesCompactAnswerListDockV1(
          context,
          interactionMode: interactionMode,
          framingProfile: framingProfile,
        ) ||
        (isRefinedDev2 &&
            table.density == Act0TableDensityV1.compactLesson &&
            MediaQuery.sizeOf(context).shortestSide < 600 &&
            _compositionFamily == Act0RunnerCompositionFamilyV1.f2AnswerList);
    final viewportPressureReason = _stableViewportPressureReasonV1(
      context,
      viewportFamily: viewportFamily,
    );
    final usesSharedActiveRunnerAllocation =
        isRefinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson &&
        MediaQuery.sizeOf(context).shortestSide < 600;
    // Compact seats already render a distinct learner badge. Keep the text
    // label to the table position so the visible identity is "You" + "BTN".
    final identityPolicy = usesSharedActiveRunnerAllocation
        ? Act0TableIdentityPolicyV1.learnerPosition
        : sourceIdentityPolicy;
    // B7: the canonical scene owns its own geometry, so the lower surface is a
    // scene-attached control shelf that sizes to its content instead of a slot
    // the scene had to fund.
    final usesSceneAttachedShelfV1 =
        _usesCanonicalIntegratedLearningSceneV1 &&
        usesSharedActiveRunnerAllocation;
    final coupleTableToDock =
        usesSharedActiveRunnerAllocation ||
        (viewportPressureReason != _compactAnswerListNoPressureReasonV1 &&
            _viewportFamilyUsesAnswerListCompositionV1(viewportFamily));
    final hasRepairContext =
        widget.selectedTaskFamily == Act0TaskFamilyV1.repair ||
        (widget.repairReasonLine?.trim().isNotEmpty ?? false) ||
        (widget.repairResultReceiptLine?.trim().isNotEmpty ?? false) ||
        (widget.repairOutcomeProofLine?.trim().isNotEmpty ?? false) ||
        widget.repairSessionSummaryLines.any((line) => line.trim().isNotEmpty);
    final repairFillMode = isDrill && hasRepairContext;
    final isRepairFocusFeedback =
        isReview &&
        !widget.rapidReviewMode &&
        (widget.repairReasonLine?.trim().isNotEmpty ?? false);
    // B5: where the learner is, from state Wave A already exposes. No new
    // poker meaning is inferred \u2014 every branch maps onto a phase the runner
    // already knows.
    // B5: where the learner is, from canonical state the shell already
    // carries. `isSourceRecheckAttempt` is the product's own identity for the
    // source recheck attempt, and `repairContinuesToSourceRecheck` marks the
    // repair that leads to it \u2014 both already fields on this widget, both
    // already driven by the preview shell's repair orchestration.
    //
    // An earlier build inferred these from `repairResultReceiptLine`, which is
    // set for a task rather than for a stage: measured against the canonical
    // capture sequence it resolved targeted repair to `decision` and never
    // reached `recheck` at all. Copy and receipt strings are not phase truth.
    // The learning route's own transition owner is authoritative. The
    // Play-only same-signal flags stay valid for their path but never fire
    // here, which is what B5_PHASE_SIGNAL_BLOCKER measured.
    final loopStage = widget.learningLoopStage;
    final isTargetedRecheck =
        loopStage == Act0ActionSequenceStageV1.recheck ||
        (loopStage == null && widget.isSourceRecheckAttempt);
    final isTargetedRepair =
        !isTargetedRecheck &&
        (loopStage == Act0ActionSequenceStageV1.repair ||
            (loopStage == null &&
                (widget.repairContinuesToSourceRecheck || hasRepairContext)));
    final sceneAttentionPhase = isTheory
        ? Act0SceneAttentionPhaseV1.theory
        : isReview
        ? (runner.reviewQuality == Act0FeedbackQualityV1.wrong
              ? Act0SceneAttentionPhaseV1.wrongFeedback
              : isRepairFocusFeedback
              ? Act0SceneAttentionPhaseV1.repair
              : Act0SceneAttentionPhaseV1.correctFeedback)
        : isDrill && isTargetedRecheck
        ? Act0SceneAttentionPhaseV1.recheck
        : isDrill && isTargetedRepair
        ? Act0SceneAttentionPhaseV1.repair
        : Act0SceneAttentionPhaseV1.decision;
    // B6: the same phase, plus the in-flight interpolation toward it.
    final sceneAttention = _resolveSceneAttentionMotionV1(
      sceneAttentionPhase,
      disableMotion: MediaQuery.of(context).disableAnimations,
    );
    final usesCompactRepairFeedbackDock =
        isReview &&
        !widget.rapidReviewMode &&
        (runner.reviewQuality == Act0FeedbackQualityV1.wrong ||
            isRepairFocusFeedback);
    final usesShortSafeCompactAnswerListEnvelope =
        _usesShortSafeCompactAnswerListEnvelopeV1(
          context,
          options: runner.options,
        );
    final taskCycleEnvelope = _resolveRunnerTaskCycleViewportEnvelopeV1(
      context,
      viewportFamily: viewportFamily,
      pressureReason: viewportPressureReason,
      repairFillMode: repairFillMode,
      shortSafeAnswerList: usesShortSafeCompactAnswerListEnvelope,
      compactRepairFeedbackDock: usesCompactRepairFeedbackDock,
      interactionMode: interactionMode,
      // A compact hand receives one table allocation for its full learning
      // cycle. The lower stage must use the remaining surface rather than
      // re-solving the table around a decision or feedback state.
      forceCompactStateAllocation: false,
    );
    final normalLowerSurfaceDemand = _normalRunnerLowerSurfaceDemandV1(
      context,
      question: question,
      options: runner.options,
      showsLearningRail: _showBottomLearningRail,
    );
    final media = MediaQuery.of(context);
    final safeVertical = media.viewPadding.vertical > 0
        ? media.viewPadding.vertical
        : media.padding.vertical;
    // The compact table, runner chrome, and stage padding own this much of the
    // short phone.
    // If the measured content exceeds the actual remaining lane, the lane
    // scrolls; default-size content remains a fixed, non-scrolling group.
    final compactDecisionNeedsScroll =
        compactAnswerListDecision &&
        (media.textScaler.scale(1) > 1.1 ||
            _normalRunnerLowerSurfaceDemandV1(
                  context,
                  question: question,
                  options: runner.options,
                  showsLearningRail: _showBottomLearningRail,
                  includeStableLaneFloor: false,
                ) >
                media.size.height - safeVertical - 630);
    final lowerStageNeedsScroll =
        compactDecisionNeedsScroll ||
        (!compactAnswerListDecision &&
            media.size.height >= 900 &&
            (media.textScaler.scale(1) > 1.1 ||
                normalLowerSurfaceDemand >
                    media.size.height - safeVertical - 674));
    final lowerStageProfile = isAccessibilityFlow
        ? _RunnerLowerStageProfileV1.accessibility
        : widget.lowerSurfacePrototypeState != null
        ? _RunnerLowerStageProfileV1.expandedFeedback
        : _resolveRunnerLowerStageProfileV1(
            isTeaching: isTeaching,
            isTheory: isTheory,
            isReview: isReview,
            compactRepairFeedbackDock: usesCompactRepairFeedbackDock,
            interactionMode: interactionMode,
            fillsDecisionStage: compactAnswerListDecision,
          );
    // The shared active runner fills one profile-stable cycle envelope while
    // short child cards remain intrinsic inside it.
    final lowerStageUsesAvailableHeight =
        usesSharedActiveRunnerAllocation ||
        taskCycleEnvelope.usesFixedLowerSlot;
    final showActionTrail =
        rawShowActionTrail && !taskCycleEnvelope.usesFixedLowerSlot;
    final hintCompact = compactAnswerListDecision && decisionHint != null;
    final shouldDeemphasizeTableForRepairLearning =
        usesCompactRepairFeedbackDock;
    final causalFeedback = Act0CausalFeedbackV1.fromStructured(
      quality: runner.reviewQuality,
      authoredReason: runner.reviewReason,
      chosenAction: runner.reviewSelectedLabel,
      preferredAction: runner.reviewPreferredLabel,
      betterAction: runner.reviewBetterLabel,
      structuredClue: feedbackSignalProof?.label ?? '',
    );
    Widget buildFeedbackShell() => Act0FeedbackShellV1(
      title: act0AcademyW1InstructionV1(
        context,
        widget.selectedTaskId,
        runner.reviewTitle,
      ),
      reason: act0AcademyW1InstructionV1(
        context,
        widget.selectedTaskId,
        causalFeedback.whyChosen,
      ),
      nextClueLine: causalFeedback.nextHandInstruction,
      quality: runner.reviewQuality,
      sharkyLine: runner.reviewQuality == Act0FeedbackQualityV1.correct
          ? runner.sharky.correctReaction
          : runner.sharky.wrongReaction,
      sharkyMood: runner.reviewQuality == Act0FeedbackQualityV1.correct
          ? runner.sharky.correctMood
          : (runner.reviewQuality == Act0FeedbackQualityV1.suboptimal
                ? Act0SharkyMoodV1.thinking
                : runner.sharky.wrongMood),
      selectedLabel: act0AcademyW1OptionLabelV1(
        context,
        runner.reviewSelectedLabel,
      ),
      preferredLabel: act0AcademyW1OptionLabelV1(
        context,
        runner.reviewPreferredLabel,
      ),
      betterLabel: act0AcademyW1OptionLabelV1(
        context,
        runner.reviewBetterLabel,
      ),
      taskFamily: widget.selectedTaskFamily,
      hasSeatTargets: hasSeatTargets,
      potLabel: runner.table.potLabel,
      showPotSweep: _shouldShowPotSweep(runner),
      signalProof: feedbackSignalProof,
      contextLabels: <String>[
        ...bottomContext.feedbackContextLabels,
        ...runner.reviewContextLabels,
      ],
      refined: isRefinedDev2,
      completionSummary: null,
      isAssistedDecision: widget.isAssistedDecision,
      localizeW1Ctas: act0AcademyW1InstructionTaskV1(widget.selectedTaskId),
      firstValueReceiptLine: widget.firstValueReceiptLine,
      repairReasonLine: widget.repairReasonLine,
      repairResultReceiptLine: widget.repairResultReceiptLine,
      repairOutcomeProofLine: widget.repairOutcomeProofLine,
      forceShowRepairOutcomeProof: widget.forceShowRepairOutcomeProof,
      repairContinuesToSourceRecheck: widget.repairContinuesToSourceRecheck,
      isSourceRecheckAttempt: widget.isSourceRecheckAttempt,
      repairSessionSummaryLines: widget.repairSessionSummaryLines,
      forwardCtaLabel: widget.feedbackForwardCtaLabel,
      suppressRepairFocus: widget.suppressFeedbackRepairFocus,
      onBack: null,
      rapidMode: widget.rapidReviewMode,
      streamlinedDirectDecisionFeedback: isAccessibilityFlow,
      cycleStableEnvelope: usesSharedActiveRunnerAllocation,
      forceCompactPhoneFeedback: usesSharedActiveRunnerAllocation,
      ensureFullCtaGeometry: _usesCanonicalIntegratedLearningSceneV1,
      sceneOwnsFeedbackExplanation:
          _usesCanonicalIntegratedLearningSceneV1 &&
          usesSharedActiveRunnerAllocation,
      coachVoiceSeed:
          '${runner.lessonId}|${runner.beatIndex}|${runner.phase.name}|${runner.selectedOptionId ?? ''}',
      onContinue: widget.onContinueReview,
    );
    Widget buildRunnerActionDock({bool sceneAttachedShelf = false}) {
      // The integrated scene owns its standard question chrome, but the
      // Placement quick-check must expose each distinct source-owned prompt.
      final actionDockQuestion =
          _usesCanonicalIntegratedLearningSceneV1 &&
              !widget.preserveSourceOwnedQuestion
          ? ''
          : question;
      return _RunnerActionDockV1(
        sceneAttachedShelf: sceneAttachedShelf,
        pageX: pageX,
        taskRailLabel:
            compactAnswerListDecision ||
                (isRefinedDev2 && widget.selectedTaskId != 'apply_recap')
            ? null
            : taskRailLabel,
        sizingPresets: runner.sizingConfig.isEnabled
            ? runner.sizingConfig.presets
            : null,
        selectedPresetId: runner.selectedPresetId,
        onSelectPreset: widget.onSelectSizingPreset == null
            ? null
            : _handleSelectSizingPresetV1,
        integratedLowerSurface: _showBottomLearningRail,
        compactAnswerListDecision: compactAnswerListDecision,
        fillCompactPromptToDock: false,
        scrollContentInEnvelope:
            (lowerStageNeedsScroll &&
            (isDrill || isReview) &&
            !_showBottomLearningRail &&
            widget.lowerSurfacePrototypeState == null &&
            !isAccessibilityFlow &&
            (!usesSharedActiveRunnerAllocation || !isReview)),
        centerBoundedLowerSurface:
            !usesSharedActiveRunnerAllocation &&
            _showBottomLearningRail &&
            lowerStageProfile != _RunnerLowerStageProfileV1.instruction,
        fillLowerStage: lowerStageUsesAvailableHeight,
        cycleStableEnvelope: usesSharedActiveRunnerAllocation,
        lowerStageProfile: lowerStageProfile,
        accessibilityFeedbackSurface: isAccessibilityFlow && isReview,
        protectFixedSlotBottom:
            taskCycleEnvelope.usesFixedLowerSlot && isReview,
        child: isAccessibilityDirectDecision
            ? _AccessibilityDirectDecisionV1(
                question: question,
                guidance: act0RuntimeNeutralTableReadCueLabelV1(context),
                options: runner.options,
                onChoose: _handleChooseOptionTelemetry,
              )
            : widget.lowerSurfacePrototypeState != null
            ? _PrototypeRepairSurfaceV1(
                state: widget.lowerSurfacePrototypeState!,
              )
            : _showBottomLearningRail
            ? _LearningRailV1(
                maxHeight: usesSharedActiveRunnerAllocation
                    ? _sharedActiveRunnerLearningRailMaxHeightV1
                    : _learningRailMaxHeightV1,
                taskLabel: taskRailLabel,
                prompt: prompt,
                supportSegments: effectiveLearningRailPages,
                activeSupportSegmentIndex: cappedSupportSegmentIndex,
                progressLabel: learningRailProgress,
                backSemanticLabel:
                    hasPreviousSupportSegment || runner.teachingStepIndex > 0
                    ? 'Previous theory page'
                    : 'Back to lesson',
                canGoBack:
                    hasPreviousSupportSegment ||
                    runner.teachingStepIndex > 0 ||
                    _usesCanonicalIntegratedLearningSceneV1,
                onBack: hasPreviousSupportSegment
                    ? () => setState(() => _learningRailSupportSegmentIndex--)
                    : (runner.teachingStepIndex > 0
                          ? widget.onPreviousTheory
                          : (_usesCanonicalIntegratedLearningSceneV1
                                ? _handleRunnerBackV1
                                : null)),
                canAdvance: _canAdvanceTheory,
                onAdvance: hasNextSupportSegment
                    ? () => setState(() => _learningRailSupportSegmentIndex++)
                    : widget.onContinueTheory,
                advanceLabel: act0AcademySurfaceAtomV1(
                  context,
                  hasNextSupportSegment
                      ? 'runner_cta_next'
                      : 'home_checklist_continue_label',
                  fallback: hasNextSupportSegment ? 'Next' : 'Continue',
                ),
                sharkyLine: theoryCoachLine,
                sharkyMood: runner.sharky.preSessionMood,
                emphasizePrompt:
                    theoryPresentationRole ==
                        Act0TheoryPresentationRoleV1.conceptIntro ||
                    theoryPresentationRole ==
                        Act0TheoryPresentationRoleV1.actionPrep ||
                    theoryPresentationRole ==
                        Act0TheoryPresentationRoleV1.recapCheck,
                fillsAvailableHeight: usesSharedActiveRunnerAllocation,
                contextOwnsTeachingCopy:
                    _usesCanonicalIntegratedLearningSceneV1,
              )
            : isTeaching
            ? FilledButton(
                key: const Key('act0_shell_continue_cta'),
                onPressed: widget.onContinueTheory,
                style: Act0ShellTokensV1.primaryButtonStyle(
                  height: Act0ShellTokensV1.compactCtaHeight,
                ),
                child: Text(teachingStep!.ctaLabel),
              )
            : isTheory
            ? FilledButton(
                key: const Key('act0_shell_continue_cta'),
                onPressed: widget.onContinueTheory,
                style: Act0ShellTokensV1.primaryButtonStyle(
                  height: Act0ShellTokensV1.compactCtaHeight,
                ),
                child: Text(runner.primaryCtaLabel),
              )
            : isDrill
            ? runner.options.any((option) => option.seatId != null)
                  ? _SeatTapPromptV1(
                      taskLabel: taskRailLabel,
                      question: actionDockQuestion,
                      helperLine: promptCoachLine,
                      options: runner.options,
                      onBack: null,
                      recallLabel: widget.theoryRecallStep == null
                          ? null
                          : act0AcademyW1InstructionTaskV1(
                              widget.selectedTaskId,
                            )
                          ? act0AcademyW1CtaV1(context, 'Need a hint?')
                          : 'Need a hint?',
                      onRecall: widget.theoryRecallStep == null
                          ? null
                          : _openTheoryRecallSheet,
                      fillsAvailableHeight: false,
                    )
                  : runner.sizingConfig.isEnabled
                  ? _ActionPromptPanelV1(
                      taskLabel: taskRailLabel,
                      questionBadgeLabel: bottomContext.questionBadgeLabel,
                      contextLine: promptContextLine,
                      trailingContext: showStreetReplayInline
                          ? _StreetReplayInlineV1(replay: streetReplay!)
                          : null,
                      embedChildInSurface: bottomContext.isTrailHistory,
                      compactDecision: compactAnswerListDecision,
                      question: actionDockQuestion,
                      onBack: null,
                      recallLabel:
                          decisionHint == null ||
                              widget.theoryRecallStep == null
                          ? null
                          : act0AcademyW1InstructionTaskV1(
                              widget.selectedTaskId,
                            )
                          ? act0AcademyW1CtaV1(context, 'Need a hint?')
                          : 'Need a hint?',
                      onRecall:
                          decisionHint == null ||
                              widget.theoryRecallStep == null
                          ? null
                          : _openTheoryRecallPeek,
                      child: _showTheoryPeek && theoryRecallPeek != null
                          ? theoryRecallPeek
                          : _SizingConfirmPanelV1(
                              selectedPreset: runner.selectedPreset,
                              onConfirm: _heroDecisionReady
                                  ? _handleConfirmSizingPreset
                                  : null,
                            ),
                    )
                  : _ActionPromptPanelV1(
                      taskLabel: taskRailLabel,
                      questionBadgeLabel: bottomContext.questionBadgeLabel,
                      contextLine: promptContextLine,
                      trailingContext: showStreetReplayInline
                          ? _StreetReplayInlineV1(replay: streetReplay!)
                          : null,
                      embedChildInSurface: bottomContext.isTrailHistory,
                      compactDecision: compactAnswerListDecision,
                      // Equal answer rows are content-driven, never a share
                      // of the remaining viewport.
                      fillAllocatedDock: false,
                      question: actionDockQuestion,
                      onBack: null,
                      recallLabel:
                          decisionHint == null ||
                              widget.theoryRecallStep == null
                          ? null
                          : act0AcademyW1InstructionTaskV1(
                              widget.selectedTaskId,
                            )
                          ? act0AcademyW1CtaV1(context, 'Need a hint?')
                          : 'Need a hint?',
                      onRecall:
                          decisionHint == null ||
                              widget.theoryRecallStep == null
                          ? null
                          : _openTheoryRecallPeek,
                      child: _showTheoryPeek && theoryRecallPeek != null
                          ? theoryRecallPeek
                          : _ActionPanelV1(
                              options: runner.options,
                              selectedOptionId: runner.selectedOptionId,
                              onChoose: _handleChooseOptionTelemetry,
                              compactDecision: compactAnswerListDecision,
                              // The lower surface may fill its stage, but answer rows
                              // retain their natural height inside it.
                              fillAvailableHeight: false,
                            ),
                    )
            : isReview
            ? Column(
                mainAxisSize:
                    (isAccessibilityFlow || usesSharedActiveRunnerAllocation) &&
                        !usesSceneAttachedShelfV1
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  if ((isAccessibilityFlow ||
                          usesSharedActiveRunnerAllocation) &&
                      !usesSceneAttachedShelfV1)
                    Expanded(child: buildFeedbackShell())
                  else
                    buildFeedbackShell(),
                  if (!_usesCanonicalIntegratedLearningSceneV1)
                    if (widget.actionRecommendation case final recommendation?)
                      Act0ActionRecommendationSurfaceV1(
                        recommendation: recommendation,
                      ),
                ],
              )
            : const SizedBox.shrink(),
      );
    }

    // B7: one construction of the physical table, consumed both by the
    // camera-owned world plane and by the legacy in-column stage. Two call
    // sites building their own table is how geometry ownership drifted before.
    Widget buildPhysicalTableV1({
      double? maxTableHeight,
      Size? cameraStageSize,
      Act0SceneRegistrationV1? sceneRegistration,
    }) {
      Widget tableStage = _RunnerTableStageV1(
        sceneRegistration: sceneRegistration,
        attention: sceneAttention,
        table: presentationTable,
        highlightedCardIds: mergedHighlightIds,
        interactiveCalloutLabel: interactiveCallout,
        onBoardCardTap: _heroDecisionReady ? _onBoardTappedForShowdown : (_) {},
        onChooseSeat:
            _heroDecisionReady &&
                !_isTheory &&
                widget.selectedTaskFamily != Act0TaskFamilyV1.learn
            ? _handleChooseSeat
            : null,
        visualVariant: widget.tableVisualVariant,
        showFocusBadge: !_showBottomLearningRail,
        showRepairCallout: isTheory || (isDrill && hasSeatTargets),
        playbackActiveSeatId: playbackActiveSeatId,
        animateBetMotion:
            choreographyCommitmentSeatId != null || trailPlaybackEnabled,
        betOverride: betOverride,
        centerLabelOverride: choreographyActive
            ? ''
            : centerStatDisplay.centerCueLabel,
        potLabelOverride: choreographyActive
            ? ''
            : playbackPotLabel ?? centerStatDisplay.potLabel,
        toCallLabelOverride: choreographyActive
            ? ''
            : centerStatDisplay.toCallLabel,
        streetLabelOverride:
            activeChoreographyFrame?.street.label ?? playbackStreetLabel,
        completionSummary: showCompletionToast
            ? widget.completionSummary
            : null,
        selectedSeatId: selectedSeatId,
        selectedSeatFeedbackState: selectedSeatFeedbackState,
        compactBottomDockClearance: compactBottomDockClearance,
        interactionMode: interactionMode,
        framingProfile: framingProfile,
        viewportFamily: viewportFamily,
        lateRouteSignal: lateRouteTableSignal,
        identityPolicy: identityPolicy,
        maxTableHeight: maxTableHeight,
        cameraStageSize: cameraStageSize,
        lockSharedActiveTableGeometry: usesSharedActiveRunnerAllocation,
        integratedPerspectivePrototype: _usesCanonicalIntegratedLearningSceneV1,
      );
      if (isAccessibilityFlow || usesSharedActiveRunnerAllocation) {
        final effectiveOnFeltScale = isAccessibilityFlow
            ? 1.0
            : math.min(media.textScaler.scale(1), 1.2);
        tableStage = MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(effectiveOnFeltScale)),
          child: tableStage,
        );
      }
      return Opacity(
        key: Key(
          'act0_shell_feedback_table_context_receded_'
          '$shouldDeemphasizeTableForRepairLearning',
        ),
        opacity: shouldDeemphasizeTableForRepairLearning ? 0.84 : 1,
        child: tableStage,
      );
    }

    Widget buildRunnerStage({
      double? maxTableHeight,
      bool usesElasticSharedTableZone = false,
    }) {
      return LayoutBuilder(
        builder: (context, stageConstraints) {
          final runnerStagePadding = EdgeInsets.fromLTRB(
            pageX,
            Act0ShellTokensV1.gapSm,
            pageX,
            coupleTableToDock ? 0 : Act0ShellTokensV1.gapMd,
          );
          final effectiveMaxTableHeight = usesElasticSharedTableZone
              ? math.max(
                  0.0,
                  stageConstraints.maxHeight -
                      _runnerUpperStageChromeHeightV1(
                        showTopInstructionCard: showTopInstructionCard,
                        isRefinedDev2: isRefinedDev2,
                        compactTableStageTopInset: compactTableStageTopInset,
                      ) -
                      (_sharedRunnerTableFramingInsetV1 * 2),
                )
              : maxTableHeight;
          final tablePresentation = buildPhysicalTableV1(
            maxTableHeight: effectiveMaxTableHeight,
          );
          final runnerStageColumn = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!_usesCanonicalIntegratedLearningSceneV1)
                _RunnerProgressV1(
                  runner: runner,
                  extraPracticeProgress: widget.extraPracticeProgress,
                  onBack: _handleRunnerBackV1,
                  showGlossary: isTheory || isTeaching || isReview,
                ),
              SizedBox(
                height: showTopInstructionCard
                    ? Act0ShellTokensV1.gapSm
                    : Act0ShellTokensV1.gapXs,
              ),
              if (!isRefinedDev2) ...[
                _PhaseTrackerV1(phase: runner.phase),
                const SizedBox(height: Act0ShellTokensV1.gapSm),
              ],
              if (showTopInstructionCard) ...[
                _RunnerInstructionSlotV1(
                  showContent: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showStepIntro) ...[
                        _StepIntroPillV1(
                          label: 'New step',
                          title: '${runner.beatIndex}/${runner.beatCount}',
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapXs),
                      ],
                      _CoachCardV1(
                        prompt: prompt,
                        hint: hint,
                        focusLabels:
                            teachingStep?.focusLabels ?? const <String>[],
                        compact: isRefinedDev2,
                        refined: isRefinedDev2,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: isRefinedDev2
                      ? Act0ShellTokensV1.gapSm
                      : Act0ShellTokensV1.gapMd,
                ),
              ],
              if (compactTableStageTopInset > 0)
                SizedBox(height: compactTableStageTopInset),
              if (usesElasticSharedTableZone)
                Expanded(
                  child: Center(
                    key: const Key('act0_shell_shared_runner_table_zone'),
                    child: tablePresentation,
                  ),
                )
              else ...[
                if (coupleTableToDock && maxTableHeight == null) const Spacer(),
                Center(child: tablePresentation),
              ],
              if (!usesElasticSharedTableZone &&
                  !_usesCanonicalIntegratedLearningSceneV1 &&
                  interactiveCallout.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Container(
                  key: const Key('act0_shell_showdown_explain_line'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusBase,
                    ),
                    border: Border.all(
                      color: Act0ShellTokensV1.info.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Text(
                    interactiveCallout,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              if (!usesElasticSharedTableZone && showActionTrail) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                _ActionTrailV1(
                  items: table.actionTrail,
                  isHandHistory: table.scope == Act0TableScopeV1.playedHand,
                  variant:
                      bottomContext.actionTrailVariant ??
                      _ActionTrailVariantV1.compactContext,
                  streetLabel: table.streetLabel,
                  refined: isRefinedDev2,
                  onFocusedIndexChanged: (index) {
                    if (_actionTrailFocusedIndex == index) {
                      return;
                    }
                    setState(() => _actionTrailFocusedIndex = index);
                  },
                ),
              ],
            ],
          );
          if (coupleTableToDock) {
            final paddedStage = Padding(
              padding: runnerStagePadding,
              child: runnerStageColumn,
            );
            if (isReview && !usesElasticSharedTableZone) {
              return SingleChildScrollView(
                key: const Key('act0_shell_runner_scroll'),
                primary: false,
                physics: const ClampingScrollPhysics(),
                child: paddedStage,
              );
            }
            return KeyedSubtree(
              key: const Key('act0_shell_runner_scroll'),
              child: paddedStage,
            );
          }
          return SingleChildScrollView(
            key: const Key('act0_shell_runner_scroll'),
            padding: runnerStagePadding,
            child: runnerStageColumn,
          );
        },
      );
    }

    if (widget.tablePresentation ==
            Act0TaskTablePresentationV1.stablePractice &&
        ((isDrill && !isTeaching) || isReview) &&
        !usesSharedActiveRunnerAllocation) {
      return KeyedSubtree(
        key: const Key('act0_shell_runner_screen'),
        child: _TaskOwnedStablePracticePresentationV1(
          runner: runner,
          table: table,
          isReview: isReview,
          question: question,
          onBack: _handleRunnerBackV1,
          onChooseOption: _handleChooseOptionTelemetry,
          onContinueReview: widget.onContinueReview,
          forwardCtaLabel: widget.feedbackForwardCtaLabel,
          recallLabel: decisionHint != null && widget.theoryRecallStep != null
              ? act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
                    ? act0AcademyW1CtaV1(context, 'Need a hint?')
                    : 'Need a hint?'
              : null,
          onRecall: decisionHint != null && widget.theoryRecallStep != null
              ? _openTheoryRecallPeek
              : null,
          hintPeek: _showTheoryPeek ? theoryRecallPeek : null,
          actionRecommendation: widget.actionRecommendation,
          actionPayoff: widget.actionPayoff,
          tableHeight: 460,
          lowerPanelHeight: 282,
          compactFeedback: false,
        ),
      );
    }

    Widget buildIntegratedPrompt({bool focusPointsUp = false}) {
      // Academy scene copy only; legacy table locale helpers remain frozen.
      final isRu = act0AcademyLanguageV1(context) == 'ru';
      final phase = isTheory || isTeaching
          ? Act0LearningScenePhaseV3.theory
          : isReview && runner.reviewQuality == Act0FeedbackQualityV1.wrong
          ? Act0LearningScenePhaseV3.feedbackWrong
          : isReview && runner.reviewQuality == Act0FeedbackQualityV1.suboptimal
          ? Act0LearningScenePhaseV3.feedbackSuboptimal
          : isReview
          ? Act0LearningScenePhaseV3.feedbackCorrect
          : Act0LearningScenePhaseV3.tableTask;
      final purpose = isTheory || isTeaching
          ? (isRu
                ? '\u041E\u0414\u041D\u0410 \u0418\u0414\u0415\u042F'
                : 'ONE TABLE IDEA')
          : isReview
          ? switch (runner.reviewQuality) {
              Act0FeedbackQualityV1.wrong =>
                isRu
                    ? '\u041F\u0420\u041E\u041F\u0423\u0429\u0415\u041D\u041D\u0410\u042F \u041F\u041E\u0414\u0421\u041A\u0410\u0417\u041A\u0410'
                    : 'MISSED CLUE',
              Act0FeedbackQualityV1.suboptimal =>
                isRu
                    ? '\u0420\u0410\u0417\u0411\u0415\u0420\u0401\u041C \u041F\u041E\u0414\u0421\u041A\u0410\u0417\u041A\u0423'
                    : "LET'S CHECK THE CLUE",
              Act0FeedbackQualityV1.correct =>
                widget.isAssistedDecision
                    ? (isRu
                          ? '\u0412\u0415\u0420\u041d\u041e \u0421 \u041F\u041E\u0414\u0421\u041A\u0410\u0417\u041A\u041E\u0419'
                          : 'CORRECT WITH HELP')
                    : (isRu
                          ? '\u0412\u0415\u0420\u041D\u041E\u0415 \u0427\u0422\u0415\u041D\u0418\u0415'
                          : 'CORRECT READ'),
            }
          : (isRu ? '\u0412\u0410\u0428 \u0425\u041E\u0414' : 'YOUR MOVE');
      final feedbackAction =
          (runner.reviewQuality == Act0FeedbackQualityV1.wrong
                  ? runner.reviewBetterLabel
                  : runner.reviewPreferredLabel)
              .trim();
      final feedbackActionIsSentence =
          feedbackAction.endsWith('.') ||
          feedbackAction.endsWith('!') ||
          feedbackAction.endsWith('?');
      final repairReceipt = widget.repairResultReceiptLine?.trim() ?? '';
      final headline = isTheory || isTeaching
          ? prompt
          : isReview &&
                isRu &&
                act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
          ? (runner.reviewQuality == Act0FeedbackQualityV1.wrong
                ? '${act0AcademyW1OptionLabelV1(context, feedbackAction)} - \u0432\u0435\u0440\u043D\u044B\u0439 \u0432\u0430\u0440\u0438\u0430\u043D\u0442.'
                : widget.isAssistedDecision
                ? '${act0AcademyW1OptionLabelV1(context, feedbackAction)} - \u0432\u0435\u0440\u043D\u043E \u0441 \u043F\u043E\u0434\u0441\u043A\u0430\u0437\u043A\u043E\u0439.'
                : '${act0AcademyW1OptionLabelV1(context, feedbackAction)} - \u0432\u0435\u0440\u043D\u043E.')
          : isReview
          ? repairReceipt.isNotEmpty
                ? repairReceipt
                : runner.reviewQuality == Act0FeedbackQualityV1.suboptimal
                // Uncertainty is not a factual error, but it is never proof
                // of a correct read. Do not reuse the preferred answer as
                // evidence that the learner chose it.
                ? runner.selectedOptionId == 'not_sure_yet'
                      ? (isRu
                            ? '\u041F\u043E\u043A\u0430 \u043D\u0435 \u0443\u0432\u0435\u0440\u0435\u043D\u044B? \u0420\u0430\u0437\u0431\u0435\u0440\u0451\u043C \u043F\u043E\u0434\u0441\u043A\u0430\u0437\u043A\u0443.'
                            : "Not sure yet? Let's check the table clue.")
                      : (isRu
                            ? '\u041F\u043E\u0441\u043C\u043E\u0442\u0440\u0438\u043C \u043D\u0430 \u043F\u043E\u0434\u0441\u043A\u0430\u0437\u043A\u0443 \u0438 \u0443\u043B\u0443\u0447\u0448\u0438\u043C \u0440\u0435\u0448\u0435\u043D\u0438\u0435.'
                            : "Let's check the table clue and improve the read.")
                : feedbackAction.isEmpty
                ? runner.reviewTitle
                : feedbackActionIsSentence
                ? feedbackAction
                : runner.reviewQuality == Act0FeedbackQualityV1.wrong
                ? '$feedbackAction was the better play.'
                : widget.isAssistedDecision
                ? (isRu
                      ? '\u0412\u0435\u0440\u043d\u043e \u0441 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u043e\u0439: $feedbackAction.'
                      : '$feedbackAction was right with help.')
                : '$feedbackAction was right.'
          : question;
      // This authored model's premises are task information, not answer help.
      // Keep the disclosure scoped to the two admitted, unsubmitted ASM05 tasks.
      final showAsm05ModelAssumptions =
          isDrill &&
          !isTeaching &&
          runner.selectedOptionId == null &&
          runner.lessonId == 'decision_over_outcome' &&
          runner.feedbackSignalId == 'asm05_known_holes_ev' &&
          const {
            'asm05_new_known_holes_turn_call_10',
            'asm05_new_known_holes_turn_call_40',
          }.contains(widget.selectedTaskId);
      // Complete authored hand premises are task data, not answer help.
      final showSourceOrderPremises =
          isDrill &&
          !isTeaching &&
          runner.selectedOptionId == null &&
          runner.table.decisionSeatId != null;
      final support = showSourceOrderPremises
          ? act0LearnerFacingPremisesV1(runner.caption)
          : showAsm05ModelAssumptions
          ? '${runner.caption} ${runner.hint}'
          : isTheory || isTeaching
          ? hint
          : isReview
          ? act0AcademyW1InstructionV1(
              context,
              widget.selectedTaskId,
              causalFeedback.whyChosen,
            )
          : (runner.lessonId == 'w10_vs_nit_open_wider' ||
                runner.lessonId == 'w10_overbluff_punish')
          ? runner.caption
          : hasSeatTargets
          ? (isRu
                ? '\u041D\u0430\u0436\u043C\u0438\u0442\u0435 \u043D\u0430 \u043E\u0434\u043D\u043E \u0438\u0437 \u043E\u0434\u0438\u043D\u0430\u043A\u043E\u0432\u043E \u043F\u043E\u0434\u0441\u0432\u0435\u0447\u0435\u043D\u043D\u044B\u0445 \u043C\u0435\u0441\u0442.'
                : 'Tap one equally highlighted seat on the table.')
          : (isRu && act0AcademyW1InstructionTaskV1(widget.selectedTaskId)
                ? '\u0412\u044B\u0431\u0435\u0440\u0438\u0442\u0435 \u0432\u0435\u0440\u043D\u044B\u0439 \u0432\u0430\u0440\u0438\u0430\u043D\u0442 \u043D\u0438\u0436\u0435.'
                : isRu
                ? '\u0412\u044B\u0431\u0435\u0440\u0438\u0442\u0435 \u043E\u0434\u043D\u043E \u0434\u0435\u0439\u0441\u0442\u0432\u0438\u0435 \u043D\u0438\u0436\u0435.'
                : 'Choose one answer below.');
      final focusLabel = isReview
          ? feedbackSignalProof == null
                ? null
                : (isRu
                      ? '\u041F\u043E\u0434\u0441\u043A\u0430\u0437\u043A\u0430 \u043F\u043E\u043A\u0430\u0437\u0430\u043D\u0430 \u043D\u0430 \u0441\u0442\u043E\u043B\u0435'
                      : 'The exact clue is marked on the table')
          : isTheory
          ? teachingFocusLabel == null
                ? null
                : (isRu
                      ? '\u0421\u043c\u043e\u0442\u0440\u0438\u0442\u0435: ${teachingFocusLabel == 'Read' ? '\u0447\u0442\u0435\u043d\u0438\u0435 \u0441\u0442\u043e\u043b\u0430' : teachingFocusLabel}'
                      : 'Look at: $teachingFocusLabel')
          : hasSeatTargets
          ? (isRu
                ? '\u041C\u043E\u0436\u043D\u043E \u043D\u0430\u0436\u0438\u043C\u0430\u0442\u044C \u043F\u043E\u0434\u0441\u0432\u0435\u0447\u0435\u043D\u043D\u044B\u0435 \u043C\u0435\u0441\u0442\u0430'
                : 'Highlighted seats are tappable')
          : null;
      final progressLabel = isTheory && runner.teachingSteps.length > 1
          ? '${runner.teachingStepIndex + 1}/${runner.teachingSteps.length}'
          : null;
      final sharkyState = act0SharkySceneCoachStateV1(
        attentionPhase: sceneAttentionPhase,
        // A highlighted clue does not turn an unsure answer into a
        // confirmed correct observation.
        hasDirectObservationEvidence:
            feedbackSignalProof != null &&
            runner.reviewQuality != Act0FeedbackQualityV1.suboptimal,
        hasOpenRepairTargetEvidence:
            widget.repairReasonLine?.trim().isNotEmpty ?? false,
      );
      final sharkyGrowthStage = act0SharkyGrowthStageForWorldNumberV1(
        widget.worldNumber,
      );
      return Act0LearningSceneGuideV3(
        phase: phase,
        attentionPhase: sceneAttentionPhase,
        sharkyState: sharkyState,
        growthStage: sharkyGrowthStage,
        eyebrow: purpose,
        headline: headline,
        support: support,
        scrollSupport: showAsm05ModelAssumptions || showSourceOrderPremises,
        focusPointsUp: focusPointsUp,
        focusLabel: focusLabel,
        progressLabel: progressLabel,
      );
    }

    Widget buildRunnerScreen({bool registeredScene = false}) {
      // Source premises must remain readable without covering an answer seat.
      // Reuse the existing scrollable guide shelf; the registered table stays
      // at its source-owned camera/seat anchors.
      final dockSourceSeatGuide =
          isDrill &&
          !isTeaching &&
          runner.selectedOptionId == null &&
          hasSeatTargets &&
          runner.table.decisionSeatId != null;
      final dockIntegratedFeedbackGuide =
          _usesCanonicalIntegratedLearningSceneV1 &&
          usesSharedActiveRunnerAllocation &&
          (isReview || (dockSourceSeatGuide && registeredScene));

      Widget buildIntegratedLowerSurface() {
        final actionDock = buildRunnerActionDock(
          sceneAttachedShelf: usesSceneAttachedShelfV1,
        );
        if (!dockIntegratedFeedbackGuide) return actionDock;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: Key(
                isReview
                    ? 'act0_shell_feedback_guide_viewport'
                    : 'act0_shell_seat_decision_guide_viewport',
              ),
              // Keep the same bounded shelf for feedback and seat decisions.
              height: 88,
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: Key(
                        isReview
                            ? 'act0_shell_feedback_guide_scroll'
                            : 'act0_shell_seat_decision_guide_scroll',
                      ),
                      primary: false,
                      physics: const ClampingScrollPhysics(),
                      child: buildIntegratedPrompt(focusPointsUp: true),
                    ),
                  ),
                  const Icon(Icons.unfold_more_rounded, size: 14),
                ],
              ),
            ),
            actionDock,
          ],
        );
      }

      return Column(
        key: const Key('act0_shell_runner_screen'),
        children: [
          SizedBox.shrink(
            key: Key('act0_shell_runner_interaction_${interactionMode.name}'),
          ),
          SizedBox.shrink(
            key: Key(
              'act0_shell_runner_composition_${_compositionFamily.name}',
            ),
          ),
          SizedBox.shrink(
            key: Key('act0_shell_runner_framing_${framingProfile.name}'),
          ),
          SizedBox.shrink(
            key: Key('act0_shell_runner_viewport_${viewportFamily.name}'),
          ),
          SizedBox.shrink(
            key: Key(
              'act0_shell_runner_envelope_${taskCycleEnvelope.familyName}',
            ),
          ),
          SizedBox.shrink(
            key: Key('act0_shell_runner_pressure_$viewportPressureReason'),
          ),
          SizedBox.shrink(
            key: Key(
              'act0_shell_runner_action_dock_compact_$compactAnswerListDecision',
            ),
          ),
          SizedBox.shrink(
            key: Key(
              'act0_shell_runner_prompt_panel_compact_$compactAnswerListDecision',
            ),
          ),
          SizedBox.shrink(
            key: Key('act0_shell_runner_hint_compact_$hintCompact'),
          ),
          if (compactAnswerListDecision)
            const SizedBox.shrink(
              key: Key('act0_shell_compact_answer_list_branch'),
            ),
          if (_usesCanonicalIntegratedLearningSceneV1 &&
              (isTheory || isDrill || isReview))
            _RunnerProgressV1(
              runner: runner,
              extraPracticeProgress: widget.extraPracticeProgress,
              onBack: _handleRunnerBackV1,
              showGlossary: isTheory || isTeaching || isReview,
            ),
          if (isReview && dockIntegratedFeedbackGuide && question.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 5, 14, 1),
              padding: const EdgeInsets.fromLTRB(12, 5, 10, 6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.surface.withValues(alpha: 0.95),
                border: const Border(
                  left: BorderSide(color: Act0ShellTokensV1.primary, width: 3),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 52),
                child: SingleChildScrollView(
                  primary: false,
                  child: Text(
                    question,
                    key: const Key('act0_shell_review_question'),
                    style: Act0ShellTokensV1.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ),
              ),
            ),
          if (_usesCanonicalIntegratedLearningSceneV1 &&
              usesSharedActiveRunnerAllocation &&
              !dockIntegratedFeedbackGuide &&
              (isTheory || isDrill || isReview)) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            // Seat decisions use a passive guide here. Let taps in its
            // overlapping painted area reach the physical seats underneath.
            IgnorePointer(
              ignoring:
                  isDrill &&
                  !isTeaching &&
                  hasSeatTargets &&
                  runner.table.decisionSeatId == null,
              child: buildIntegratedPrompt(),
            ),
          ],
          if (taskCycleEnvelope.usesFixedLowerSlot &&
              !usesSharedActiveRunnerAllocation)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final lowerSlotHeight = taskCycleEnvelope.lowerSlotHeightFor(
                    constraints.maxHeight,
                  );
                  final upperSlotHeight = math.max(
                    0.0,
                    constraints.maxHeight - lowerSlotHeight,
                  );
                  final tableMaxHeight = math.max(
                    0.0,
                    upperSlotHeight -
                        _runnerUpperStageChromeHeightV1(
                          showTopInstructionCard: showTopInstructionCard,
                          isRefinedDev2: isRefinedDev2,
                          compactTableStageTopInset: compactTableStageTopInset,
                        ),
                  );
                  return Column(
                    children: [
                      SizedBox(
                        height: upperSlotHeight,
                        child: buildRunnerStage(maxTableHeight: tableMaxHeight),
                      ),
                      SizedBox(
                        height: lowerSlotHeight,
                        child: buildRunnerActionDock(),
                      ),
                    ],
                  );
                },
              ),
            )
          else if (usesSharedActiveRunnerAllocation) ...[
            // B7 canonical scene composition.
            //
            // The runner column no longer allocates the table any height at all.
            // It reserves a transparent window onto the world plane, which is
            // painted behind this column and owned solely by
            // `Act0SceneCameraV1`. That is what closes
            // `TABLE_GEOMETRY_INVARIANT_V1`: review states can still claim a
            // different amount of vertical space, but there is no longer a path
            // by which that claim can reach the physical table.
            const Expanded(
              child: SizedBox.expand(key: Key('act0_shell_scene_window')),
            ),
            KeyedSubtree(
              key: const Key('act0_shell_shared_runner_cycle_envelope'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -14,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        key: const Key(
                          'act0_integrated_scene_action_foreground',
                        ),
                        decoration: BoxDecoration(
                          // Scene-attached control shelf: one top boundary, no
                          // all-around card, and the room stays visible through
                          // the top of the shelf so the scene reads as
                          // continuing behind the controls.
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Act0ShellTokensV1.surface2.withValues(
                                alpha: 0.62,
                              ),
                              Act0ShellTokensV1.surface2.withValues(
                                alpha: 0.95,
                              ),
                              Act0ShellTokensV1.surface,
                            ],
                            stops: const <double>[0, 0.34, 1],
                          ),
                          border: Border(
                            top: BorderSide(
                              color: Act0ShellTokensV1.primary.withValues(
                                alpha: 0.34,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  KeyedSubtree(
                    key: const Key('act0_shell_shared_runner_lower_surface'),
                    child: buildIntegratedLowerSurface(),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(child: buildRunnerStage()),
            buildRunnerActionDock(),
          ],
        ],
      );
    }

    if (!_usesCanonicalIntegratedLearningSceneV1 ||
        !usesSharedActiveRunnerAllocation) {
      return buildRunnerScreen();
    }
    // B7: world plane first, interaction plane on top.
    //
    // The room is painted across the whole scene box rather than inside the
    // table's own layout rectangle, so lowering the far rail exposes more room
    // instead of exposing flat app background. The table is then placed at the
    // camera's rect. Neither reads anything from the learning state.
    Widget originalScene(BuildContext context) => LayoutBuilder(
      key: const Key('act0_shell_canonical_scene_box'),
      builder: (context, sceneConstraints) {
        const camera = Act0SceneCameraV1.canonical;
        final sceneBox = sceneConstraints.biggest;
        final stageRect = camera.stageRect(sceneBox);
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            IgnorePointer(
              child: Act0SceneRecedeMotionV1(
                motion: sceneAttention,
                plane: Act0SceneRecedePlaneV1.room,
                child: Act0SceneHybridShellPlaneV1(
                  key: const Key('act0_scene_environment_plane'),
                  horizon: camera.horizonFraction,
                ),
              ),
            ),
            Positioned.fromRect(
              rect: stageRect,
              child: buildPhysicalTableV1(cameraStageSize: stageRect.size),
            ),
          ],
        );
      },
    );
    final scenarioKey =
        '${_compositionTaskIdentity(widget)}|${widget.evidenceRunId}|$_f7AttemptGenerationV1|${widget.runner.question}';
    final runtimeSource = Act0F7SceneSourceV1.fromRunner(
      runner: runner,
      taskFamily: widget.selectedTaskFamily,
      scenarioKey: scenarioKey,
    );
    final recall = widget.theoryRecallStep;
    final source = Act0F7SceneSourceV1(
      scenarioKey: scenarioKey,
      tables: {
        ...runtimeSource.tables,
        'current/presentation': presentationTable,
        if (recall != null) 'external-recall/raw': recall.table ?? runner.table,
        if (recall != null)
          'external-recall/projected': act0TeachingTableForRunnerV1(
            runner.table,
            recall,
          ),
      },
    );
    return Act0F7SceneGateV1(
      source: source,
      enabled:
          kAct0F7TableScenePreview &&
          Localizations.localeOf(context).languageCode == 'en',
      originalBuilder: originalScene,
      registeredBuilder: (context, image, profile) => LayoutBuilder(
        key: const Key('act0_f7_registered_scene'),
        builder: (context, constraints) {
          final registration = profile.register(constraints.biggest);
          final scrimBottom = profile.headerScrimBottom;
          final shelfTop = profile.controlShelfTop;
          return Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: CustomPaint(
                  key: const Key('act0_f7_baked_room_cast_hero'),
                  painter: Act0F7RegisteredScenePainterV1(
                    image: image,
                    registration: registration,
                  ),
                ),
              ),
              if (scrimBottom != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: registration.map(Offset(0, scrimBottom)).dy,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Act0ShellTokensV1.surface.withValues(alpha: .86),
                            Act0ShellTokensV1.surface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (shelfTop != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: registration.map(Offset(0, shelfTop)).dy,
                  bottom: 0,
                  child: const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Act0ShellTokensV1.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: buildPhysicalTableV1(sceneRegistration: registration),
              ),
            ],
          );
        },
      ),
      foregroundBuilder: (context, registered) =>
          buildRunnerScreen(registeredScene: registered),
    );
  }
}

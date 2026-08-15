import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_recommendation_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_sequence_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_session_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_causal_feedback_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_ids_v1.dart';

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
      label: 'W11 · Transfer',
      detail: 'Name the cue. Choose one action.',
      icon: Icons.alt_route_rounded,
    ),
    12 => const Act0LateRouteTableSignalV1(
      label: 'W12 · Reset',
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

  String get toastRewardLabel => leveledUp ? 'Read banked' : 'Clean rep';

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
      Act0SkillReceiptOutcomeV1.learned =>
        skillAtomId == 'action_read'
            ? 'Table read improved'
            : '$skillLabel improved',
      Act0SkillReceiptOutcomeV1.repairStarted => 'Good spot to repair',
      Act0SkillReceiptOutcomeV1.needsRep => 'One more read will help',
    };
  }

  String get detail => switch (outcome) {
    Act0SkillReceiptOutcomeV1.learned =>
      'You noticed $sourceSignalLabel before choosing an action.',
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

  final String lessonTitle;
  final int xpEarned;
  final int errorCount;
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

  int get accuracyPercent =>
      taskCount <= 0 ? 100 : ((correctCount * 100) / taskCount).round();

  bool get qualifiesForNextLesson =>
      !hasNextLesson || accuracyPercent >= unlockAccuracyPercent;

  Act0MasteryStatusV1 get masteryStatus {
    if (errorCount == 0 && taskCount > 0) {
      return Act0MasteryStatusV1.cleanPass;
    }
    if (deepLeakCount > 0 || !qualifiesForNextLesson) {
      return Act0MasteryStatusV1.needsReview;
    }
    return Act0MasteryStatusV1.solid;
  }

  String get masteryLabel => switch (masteryStatus) {
    Act0MasteryStatusV1.cleanPass => 'Clean pass',
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
      return 'Perfect path';
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
      lines.add('Skill in motion: $focus');
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
        ? 'Tomorrow starts warmer because this world is already in motion.'
        : 'Tomorrow starts warmer because $focus is already in motion.';
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
    return '$opener One short return keeps it sharp.';
  }

  String? get nextUnlockReasonLabel {
    if (!isWorldComplete ||
        nextWorldTitle == null ||
        nextWorldTitle!.trim().isEmpty) {
      return null;
    }
    final focus = primarySkillFocusLabel;
    if (focus == null) {
      return '$nextWorldTitle is next because this base is now in place.';
    }
    return '$nextWorldTitle is next because $focus is already in motion.';
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
      'You learned how to read the table before acting.';

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
      'You can now read the table, hand, action, and position before '
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
      return 'Replay this block before moving on.';
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
      return 'Skill moved';
    }
    if (errorCount == 0 && taskCount > 0) {
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
      return 'Practiced: $growthLabel. This read will help in the next spot.';
    }
    if (errorCount == 0 && taskCount > 0) {
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

const Map<int, _WorldCompletionMetaV1> _worldCompletionMetaByNumberV1 =
    <int, _WorldCompletionMetaV1>{
      2: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how to separate playable hands from tempting ones.',
        previewLine:
            'World 3 starts with a simple question: does your seat change '
            'what you should play?',
      ),
      3: _WorldCompletionMetaV1(
        learningLabel: 'You learned how position changes what a hand can do.',
        previewLine:
            'World 4 starts with a simple question: why did that bet '
            'happen, and what price did it create?',
      ),
      4: _WorldCompletionMetaV1(
        learningLabel:
            "You learned why a bet happens and what price it's asking you "
            'to risk.',
        previewLine:
            'World 5 starts with a simple question: what does the board '
            'let you keep doing?',
      ),
      5: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how to read board texture and let streets change '
            'your plan.',
        previewLine:
            'World 6 starts with a simple question: what could they still '
            'be holding?',
      ),
      6: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how to group hands into ranges and compare who '
            'is ahead.',
        previewLine:
            'World 7 starts with a simple question: what do the visible '
            'cards rule out?',
      ),
      7: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how visible cards remove combinations and narrow '
            'ranges.',
        previewLine:
            'World 8 starts with a simple question: how much risk can the '
            'stack still create?',
      ),
      8: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how effective stack depth changes commitment and '
            'risk.',
        previewLine:
            'World 9 starts with a simple question: when does tournament '
            'pressure change the risk bar?',
      ),
      9: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how survival pressure and risk premium change '
            'decisions.',
        previewLine:
            'World 10 starts with a simple question: which player tendency '
            'changes the plan?',
      ),
      10: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how to tag player tendencies, adjust one lever, and '
            'keep adjustment guardrails.',
        previewLine:
            'World 11 starts with a simple question: how does one clear plan '
            'transfer to real play?',
      ),
      11: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how to plan a session, use table triggers, and close '
            'the review loop.',
        previewLine:
            'World 12 starts with a simple question: how do you keep process '
            'steady when outcomes get noisy?',
      ),
      12: _WorldCompletionMetaV1(
        learningLabel:
            'You learned how to judge process, reset tilt, and keep discipline '
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
  return sorted.take(2).map((gain) => gain.label).join('  •  ');
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

// ── Pure pot-calculation helpers (top-level so they are unit-testable) ────────

/// Parses a BB amount string like "2.5 BB", "0.5 BB", "3BB" → double.
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
///   – Each player's contribution is the **maximum** amount they put in
///     during that street (raise or call to X BB).
///   – On street transition the per-street map is flushed into [runningPot].
({double potBb, String street}) act0CalcTrailPotV1(
  List<String> labels,
  int upToIndex,
) {
  if (labels.isEmpty) return (potBb: -1.0, street: '');

  final firstLower = labels[0].toLowerCase();
  // In a valid cash-game trail the *first* entry must be the small blind post.
  // A trail starting with BB only (or any other action) is incomplete — fall
  // back to the static potLabel so we never display a wrong pot.
  if (!firstLower.contains('sb blind')) {
    return (potBb: -1.0, street: '');
  }

  double runningPot = 0.0;
  final streetContribs = <String, double>{};
  String currentStreet = 'Preflop';

  for (int i = 0; i <= upToIndex && i < labels.length; i++) {
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
    if (amount > existing) streetContribs[actor] = amount;
  }

  final totalPot =
      runningPot + streetContribs.values.fold(0.0, (acc, v) => acc + v);
  return (potBb: totalPot, street: currentStreet);
}

/// Formats a pot double as a readable label: 6.5 → "Pot 6.5 BB", 7.0 → "Pot 7 BB".
String act0FormatPotLabelV1(double bb) {
  final rounded = (bb * 2).round() / 2; // nearest 0.5 BB
  final isWhole = rounded == rounded.truncateToDouble();
  return 'Pot ${isWhole ? rounded.toInt() : rounded} BB';
}

// ─────────────────────────────────────────────────────────────────────────────

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
    required this.onContinueReview,
    this.completionSummary,
    this.firstValueReceiptLine,
    this.repairReasonLine,
    this.repairResultReceiptLine,
    this.repairOutcomeProofLine,
    this.forceShowRepairOutcomeProof = false,
    this.repairContinuesToSourceRecheck = false,
    this.isSourceRecheckAttempt = false,
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
    this.reviewKindId = 'initialAssessment',
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
  final VoidCallback onContinueReview;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? firstValueReceiptLine;
  final String? repairReasonLine;
  final String? repairResultReceiptLine;
  final String? repairOutcomeProofLine;
  final bool forceShowRepairOutcomeProof;
  final bool repairContinuesToSourceRecheck;
  final bool isSourceRecheckAttempt;
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
  final String reviewKindId;
  final Act0LowerSurfacePrototypeStateV1? lowerSurfacePrototypeState;
  final Act0AccessibilityPrototypeStepV1? accessibilityPrototypeStep;
  final ValueChanged<Act0AccessibilityPrototypeStepV1>?
  onAccessibilityPrototypeStepChanged;
  final Act0RunnerCompositionFamilyV1 compositionFamily;

  @override
  State<Act0LessonRunnerShellV1> createState() =>
      _Act0LessonRunnerShellV1State();
}

class _Act0LessonRunnerShellV1State extends State<Act0LessonRunnerShellV1> {
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
  String _showdownInteractionKey = '';
  final Stopwatch _decisionTelemetryStopwatch = Stopwatch();
  List<String> _interactiveHighlightedCardIds = const <String>[];
  String _interactiveShowdownLine = '';
  int? _actionTrailFocusedIndex;
  int _learningRailSupportSegmentIndex = 0;
  String _learningRailSupportStepKey = '';
  bool _showTheoryPeek = false;
  bool _showFullIdeaInTheoryPeek = false;
  late Act0RunnerCompositionFamilyV1 _compositionFamily;
  late String _compositionTaskKey;

  @override
  void initState() {
    super.initState();
    _syncTheoryAdvanceLock(initial: true);
    _syncRapidReviewAdvance();
    _maybeEmitTaskShownTelemetry();
    _compositionFamily = widget.compositionFamily;
    _compositionTaskKey = _compositionTaskIdentity(widget);
  }

  @override
  void didUpdateWidget(covariant Act0LessonRunnerShellV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTheoryAdvanceLock();
    _syncLearningRailSupportSegment();
    _syncRapidReviewAdvance();
    _maybeEmitTaskShownTelemetry();
    _maybeEmitFeedbackViewedTelemetry();
    final nextCompositionTaskKey = _compositionTaskIdentity(widget);
    if (nextCompositionTaskKey != _compositionTaskKey) {
      _compositionTaskKey = nextCompositionTaskKey;
      _compositionFamily = widget.compositionFamily;
    }
    final nextKey = _interactionKey(widget.runner);
    if (_showdownInteractionKey != nextKey) {
      _actionTrailFocusedIndex = null;
      _showdownInteractionKey = nextKey;
      _interactiveHighlightedCardIds = const <String>[];
      _interactiveShowdownLine = '';
      _showTheoryPeek = false;
      _showFullIdeaInTheoryPeek = false;
    }
  }

  @override
  void dispose() {
    _theoryUnlockTimer?.cancel();
    _rapidReviewTimer?.cancel();
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
      ..reset()
      ..start();
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
  }) {
    final key =
        '${widget.selectedWorldId ?? ''}|$_stableLessonTelemetryId|$_stableTaskTelemetryId|${widget.runner.phase.name}|${option.id}';
    if (_userChoiceTelemetryKey == key) {
      return;
    }
    _userChoiceTelemetryKey = key;
    final projection = _decisionTelemetryProjectionV1(option);
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
  }) {
    final projection = _decisionTelemetryProjectionV1(option);
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

  void _handleChooseOptionTelemetry(Act0RunnerOptionV1 option) {
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
    final projection = _decisionTelemetryProjectionV1(option);
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
  _decisionTelemetryProjectionV1(Act0RunnerOptionV1 option) {
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
      attemptId:
          'v1|${widget.selectedWorldId?.trim() ?? ''}|'
          '$_stableLessonTelemetryId|$_stableTaskTelemetryId|${option.id}|1',
      boardCardIds: widget.runner.table.boardCards
          .map((card) => card.label)
          .where((label) => label.trim().isNotEmpty)
          .toList(growable: false),
      streetLabel: widget.runner.table.streetLabel.trim(),
    );
  }

  void _handleChooseSeat(String seatId) {
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
      final telemetryDecisionTimeBucket = decisionTimeBucket ?? 'unknown';
      _maybeEmitUserChoiceTelemetry(
        option,
        decisionTimeBucket: telemetryDecisionTimeBucket,
      );
      _emitCanonicalDecisionMadeTelemetryV1(
        option,
        decisionTimeBucket: telemetryDecisionTimeBucket,
      );
    }
    widget.onChooseSeat?.call(seatId);
    if (option != null) {
      _emitCompletedDecision(
        option,
        Act0CompletedDecisionKindV1.seat,
        decisionTimeBucket: decisionTimeBucket,
      );
    }
  }

  void _handleConfirmSizingPreset() {
    final presetId = widget.runner.selectedPresetId;
    final option = presetId == null
        ? null
        : widget.runner.options.cast<Act0RunnerOptionV1?>().firstWhere(
            (candidate) => candidate?.id == presetId,
            orElse: () => null,
          );
    widget.onConfirmSizingPreset?.call();
    if (option != null) {
      _emitCompletedDecision(option, Act0CompletedDecisionKindV1.sizing);
    }
  }

  void _emitCompletedDecision(
    Act0RunnerOptionV1 option,
    Act0CompletedDecisionKindV1 kind, {
    String? decisionTimeBucket,
  }) {
    final taskKey =
        '${widget.selectedWorldId ?? ''}|$_stableLessonTelemetryId|'
        '$_stableTaskTelemetryId|${kind.name}';
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
        attemptKey:
            'v1|${normalizedWorldId ?? ''}|$_stableLessonTelemetryId|'
            '$_stableTaskTelemetryId|${kind.name}|${option.id}|'
            '$_completedDecisionOrdinal',
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
    // Strip street prefix: "Flop: BB checks" → "BB checks"
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

    // Folds / checks → no chip
    return null;
  }

  // ── Pot calculation ─────────────────────────────────────────────────────────

  /// Calculates the running pot by replaying the trail up to [upToIndex].
  /// Delegates to top-level [act0CalcTrailPotV1].
  ({double potBb, String street}) _calculatePotAtTrailIndex(
    Act0TableStateV1 table,
    int upToIndex,
  ) {
    final labels = table.actionTrail
        .map((item) => item.label)
        .toList(growable: false);
    return act0CalcTrailPotV1(labels, upToIndex);
  }

  /// Delegates to top-level [act0FormatPotLabelV1].
  String _formatPotLabel(double bb) => act0FormatPotLabelV1(bb);

  // ─────────────────────────────────────────────────────────────────────────

  _Act0ShowdownInsightV1? _computeShowdownInsight(Act0TableStateV1 table) {
    if (table.boardCards.length < 5) {
      return null;
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
    final winnerVerb = winnerPhrase == 'You' ? 'win' : 'wins';
    String summary;
    if (winnerIndexes.length > 1) {
      summary = 'Split pot: $winnerPhrase with ${_humanHandName(leadHand)}.';
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
            '$winnerPhrase $winnerVerb with ${_humanHandName(leadHand)} over ${_humanHandName(hands[bestLoser]!)}.';
      } else {
        summary = '$winnerPhrase $winnerVerb with ${_humanHandName(leadHand)}.';
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
      case '♠':
        return 's';
      case 'h':
      case '♥':
        return 'h';
      case 'd':
      case '♦':
        return 'd';
      case 'c':
      case '♣':
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
    final bodyBlocks = act0BuildInstructionBlocksV1(
      text: step.body,
      compact: true,
    );
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => _TheoryRecallSheetV1(
        label: act0RuntimeTheoryRecallLabelV1(context),
        title: step.title,
        bodyBlocks: bodyBlocks,
      ),
    );
  }

  void _openTheoryRecallPeek() {
    if (widget.theoryRecallStep == null || _showTheoryPeek) {
      return;
    }
    setState(() => _showTheoryPeek = true);
  }

  void _closeTheoryRecallPeek() {
    if (!_showTheoryPeek) {
      return;
    }
    setState(() {
      _showTheoryPeek = false;
      _showFullIdeaInTheoryPeek = false;
    });
  }

  void _syncTheoryAdvanceLock({bool initial = false}) {
    _theoryUnlockTimer?.cancel();
    final nextKey = _currentAdvanceLockKey;
    if (nextKey.isEmpty) {
      _advanceLockKey = '';
      if (initial) {
        _canAdvanceTheory = true;
      } else if (!_canAdvanceTheory) {
        setState(() => _canAdvanceTheory = true);
      }
      return;
    }
    if (_advanceLockKey == nextKey) {
      return;
    }
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
        ? act0LocalizedTeachingStepTitleAtomByTaskIdV1(
            widget.selectedTaskId,
            runner.teachingStepIndex,
            fallback: teachingStep!.title,
            isRu: act0IsRuLocaleV1(context),
          )
        : act0LocalizedRunnerPromptAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: runner.caption,
            isRu: act0IsRuLocaleV1(context),
          );
    final shouldShowRunnerHint = switch (runner.hintPolicy) {
      Act0HintPolicyV1.always => true,
      Act0HintPolicyV1.theoryOnly => isTheory,
      Act0HintPolicyV1.hidden => false,
    };
    final hint = isTeaching
        ? act0LocalizedTeachingStepBodyAtomByTaskIdV1(
            widget.selectedTaskId,
            runner.teachingStepIndex,
            fallback: teachingStep!.body,
            isRu: act0IsRuLocaleV1(context),
          )
        : act0LocalizedRunnerSupportAtomByTaskIdV1(
            widget.selectedTaskId,
            fallback: shouldShowRunnerHint ? runner.hint : '',
            isRu: act0IsRuLocaleV1(context),
          );
    final question = act0LocalizedRunnerQuestionAtomByTaskIdV1(
      widget.selectedTaskId,
      fallback: runner.question,
      isRu: act0IsRuLocaleV1(context),
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
    final effectiveLearningRailPages = learningRailPages.isNotEmpty
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
        ? _repairTable(runner.table, runner.selectedOption)
        : _teachingTable(runner.table, teachingStep);
    final feedbackSignalProof = isReview
        ? _feedbackSignalProofForRunnerV1(
            runner: runner,
            option: runner.selectedOption,
            taskFamily: widget.selectedTaskFamily,
            hasSeatTargets: hasSeatTargets,
          )
        : null;
    final table = feedbackSignalProof == null
        ? baseTable
        : _tableWithFeedbackSignalProofV1(baseTable, feedbackSignalProof);
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
      runner: runner,
      table: table,
      isTeaching: isTeaching,
      isTheory: isTheory,
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
      isTheory: isTheory,
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
    final selectedTaskTitle = widget.selectedTaskTitle?.trim() ?? '';
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
        streetReplay?.isConsumerSafe == true && isDrill && !isTeaching;
    final decisionHint = _resolveDecisionHintV1(
      taskFamily: widget.selectedTaskFamily,
      runner: runner,
      prompt: prompt,
      question: question,
      supportLine: promptContextLine ?? hint,
      fullIdeaStep: widget.theoryRecallStep,
    );
    final theoryRecallPeek = decisionHint == null
        ? null
        : _DecisionHintPeekV1(
            quickHint: decisionHint.quickHint,
            fullIdeaTitle: decisionHint.fullIdeaTitle,
            fullIdeaBlocks: decisionHint.fullIdeaBlocks,
            showFullIdea: _showFullIdeaInTheoryPeek,
            onShowFullIdea: decisionHint.hasFullIdea
                ? () => setState(() => _showFullIdeaInTheoryPeek = true)
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
        widget.completionSummary != null;
    final interactionKey = _interactionKey(runner);
    if (_showdownInteractionKey != interactionKey) {
      _actionTrailFocusedIndex = null;
      _showdownInteractionKey = interactionKey;
      _interactiveHighlightedCardIds = const <String>[];
      _interactiveShowdownLine = '';
    }
    final trailPlaybackEnabled =
        _actionTrailFocusedIndex != null && !isTeaching;
    final mergedHighlightIds = <String>{
      ...table.highlightedCardIds,
      ..._interactiveHighlightedCardIds,
    }.toList(growable: false);
    final playbackActiveSeatId = trailPlaybackEnabled
        ? _activeSeatIdFromActionTrail(table, _actionTrailFocusedIndex)
        : null;
    final betOverride = trailPlaybackEnabled
        ? _deriveBetFromTrailStep(table, _actionTrailFocusedIndex)
        : null;
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
    final interactiveCallout = _interactiveShowdownLine;
    final rawShowActionTrail = bottomContext.showActionTrail;
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
      title: runner.reviewTitle,
      reason: causalFeedback.whyChosen,
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
      selectedLabel: runner.reviewSelectedLabel,
      preferredLabel: runner.reviewPreferredLabel,
      betterLabel: runner.reviewBetterLabel,
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
      coachVoiceSeed:
          '${runner.lessonId}|${runner.beatIndex}|${runner.phase.name}|${runner.selectedOptionId ?? ''}',
      onContinue: widget.onContinueReview,
    );
    Widget buildRunnerActionDock() {
      final actionDockQuestion = _usesCanonicalIntegratedLearningSceneV1
          ? ''
          : question;
      return _RunnerActionDockV1(
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
        onSelectPreset: widget.onSelectSizingPreset,
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
                guidance: runner.hint,
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
                canGoBack:
                    hasPreviousSupportSegment ||
                    runner.teachingStepIndex > 0 ||
                    _usesCanonicalIntegratedLearningSceneV1,
                onBack: hasPreviousSupportSegment
                    ? () => setState(() => _learningRailSupportSegmentIndex--)
                    : (runner.teachingStepIndex > 0
                          ? widget.onPreviousTheory
                          : (_usesCanonicalIntegratedLearningSceneV1
                                ? widget.onBack
                                : null)),
                canAdvance: _canAdvanceTheory,
                onAdvance: hasNextSupportSegment
                    ? () => setState(() => _learningRailSupportSegmentIndex++)
                    : widget.onContinueTheory,
                advanceLabel: hasNextSupportSegment ? 'Next' : 'Continue',
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
                      recallLabel: decisionHint == null ? null : 'Need a hint?',
                      onRecall: decisionHint == null
                          ? null
                          : _openTheoryRecallPeek,
                      child: _showTheoryPeek && theoryRecallPeek != null
                          ? theoryRecallPeek
                          : _SizingConfirmPanelV1(
                              selectedPreset: runner.selectedPreset,
                              onConfirm: _handleConfirmSizingPreset,
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
                      recallLabel: decisionHint == null ? null : 'Need a hint?',
                      onRecall: decisionHint == null
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
                    isAccessibilityFlow || usesSharedActiveRunnerAllocation
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  if (isAccessibilityFlow || usesSharedActiveRunnerAllocation)
                    Expanded(child: buildFeedbackShell())
                  else
                    buildFeedbackShell(),
                  if (widget.actionRecommendation case final recommendation?)
                    Act0ActionRecommendationSurfaceV1(
                      recommendation: recommendation,
                    ),
                ],
              )
            : const SizedBox.shrink(),
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
          Widget tableStage = _RunnerTableStageV1(
            table: table,
            highlightedCardIds: mergedHighlightIds,
            interactiveCalloutLabel: interactiveCallout,
            onBoardCardTap: _onBoardTappedForShowdown,
            onChooseSeat: _handleChooseSeat,
            visualVariant: widget.tableVisualVariant,
            showFocusBadge: !_showBottomLearningRail,
            showRepairCallout: !_isReview,
            playbackActiveSeatId: playbackActiveSeatId,
            animateBetMotion: trailPlaybackEnabled,
            betOverride: betOverride,
            centerLabelOverride: centerStatDisplay.centerCueLabel,
            potLabelOverride: playbackPotLabel ?? centerStatDisplay.potLabel,
            toCallLabelOverride: centerStatDisplay.toCallLabel,
            streetLabelOverride: playbackStreetLabel,
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
            maxTableHeight: effectiveMaxTableHeight,
            lockSharedActiveTableGeometry: usesSharedActiveRunnerAllocation,
            integratedPerspectivePrototype:
                _usesCanonicalIntegratedLearningSceneV1,
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
          final tablePresentation = Opacity(
            key: Key(
              'act0_shell_feedback_table_context_receded_'
              '$shouldDeemphasizeTableForRepairLearning',
            ),
            opacity: shouldDeemphasizeTableForRepairLearning ? 0.84 : 1,
            child: tableStage,
          );
          final runnerStageColumn = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!_usesCanonicalIntegratedLearningSceneV1)
                _RunnerProgressV1(runner: runner, onBack: widget.onBack),
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
          onBack: widget.onBack,
          onChooseOption: _handleChooseOptionTelemetry,
          onContinueReview: widget.onContinueReview,
          actionRecommendation: widget.actionRecommendation,
          actionPayoff: widget.actionPayoff,
          tableHeight: 460,
          lowerPanelHeight: 282,
          compactFeedback: false,
        ),
      );
    }

    Widget buildIntegratedPrompt() {
      return SizedBox(
        height: media.textScaler.scale(50).clamp(50, 60),
        child: Container(
          key: const Key('act0_integrated_scene_prompt'),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            border: Border.all(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            question,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: 14.2,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ),
      );
    }

    final runnerScreen = Column(
      key: const Key('act0_shell_runner_screen'),
      children: [
        SizedBox.shrink(
          key: Key('act0_shell_runner_interaction_${interactionMode.name}'),
        ),
        SizedBox.shrink(
          key: Key('act0_shell_runner_composition_${_compositionFamily.name}'),
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
        if (_usesCanonicalIntegratedLearningSceneV1 && (isDrill || isReview))
          _RunnerProgressV1(runner: runner, onBack: widget.onBack),
        if (_usesCanonicalIntegratedLearningSceneV1 &&
            usesSharedActiveRunnerAllocation &&
            (isDrill || isReview)) ...[
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          buildIntegratedPrompt(),
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
        else if (usesSharedActiveRunnerAllocation)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final allocation = resolveAct0RunnerCompositionAllocationV1(
                  viewport: media.size,
                  safeArea: media.viewPadding,
                  textScale: media.textScaler.scale(1),
                  family: _compositionFamily,
                );
                final lowerHeight = math.min(
                  allocation.lowerHeight,
                  math.max(
                    Act0ShellTokensV1.runnerActionDockMinHeight,
                    constraints.maxHeight -
                        _runnerCompositionHeaderAndGapV1 -
                        _sharedRunnerSeamV1,
                  ),
                );
                final boundedLowerHeight =
                    _usesCanonicalIntegratedLearningSceneV1
                    ? math.min(
                        lowerHeight,
                        math.max(220.0, constraints.maxHeight * 0.29),
                      )
                    : lowerHeight;
                final tableStageChrome = _usesCanonicalIntegratedLearningSceneV1
                    ? 20.0
                    : _runnerCompositionHeaderAndGapV1;
                final tableHeight = math.min(
                  allocation.tableHeight,
                  math.max(
                    0.0,
                    constraints.maxHeight -
                        tableStageChrome -
                        _sharedRunnerSeamV1 -
                        boundedLowerHeight,
                  ),
                );
                final integratedLowerSurfaceHeight = math.max(
                  0.0,
                  constraints.maxHeight - tableHeight - tableStageChrome,
                );
                return Column(
                  children: [
                    SizedBox(
                      height: tableHeight + tableStageChrome,
                      child: buildRunnerStage(
                        maxTableHeight: math.max(0.0, tableHeight),
                      ),
                    ),
                    if (!_usesCanonicalIntegratedLearningSceneV1)
                      SizedBox(
                        key: const Key('act0_shell_shared_runner_seam'),
                        height: _sharedRunnerSeamV1,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: _sharedRunnerSeamDecorationV1(),
                        ),
                      ),
                    SizedBox(
                      key: const Key('act0_shell_shared_runner_cycle_envelope'),
                      height: _usesCanonicalIntegratedLearningSceneV1
                          ? integratedLowerSurfaceHeight
                          : boundedLowerHeight,
                      child: _usesCanonicalIntegratedLearningSceneV1
                          ? Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.expand,
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
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            Act0ShellTokensV1.surface2
                                                .withValues(alpha: 0.97),
                                            Act0ShellTokensV1.surface,
                                          ],
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(28),
                                            ),
                                        border: Border(
                                          top: BorderSide(
                                            color: Act0ShellTokensV1.primary
                                                .withValues(alpha: 0.34),
                                          ),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Act0ShellTokensV1.primary
                                                .withValues(alpha: 0.10),
                                            blurRadius: 22,
                                            spreadRadius: 2,
                                            offset: const Offset(0, -7),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                KeyedSubtree(
                                  key: const Key(
                                    'act0_shell_shared_runner_lower_surface',
                                  ),
                                  child: buildRunnerActionDock(),
                                ),
                              ],
                            )
                          : KeyedSubtree(
                              key: const Key(
                                'act0_shell_shared_runner_lower_surface',
                              ),
                              child: buildRunnerActionDock(),
                            ),
                    ),
                  ],
                );
              },
            ),
          )
        else ...[
          Expanded(child: buildRunnerStage()),
          buildRunnerActionDock(),
        ],
      ],
    );
    return runnerScreen;
  }
}

/// Keeps the task-owned practice table in one slot while only the lower
/// decision/feedback panel changes. No reachable state is allowed to resize or
/// translate the table.
class _TaskOwnedStablePracticePresentationV1 extends StatelessWidget {
  const _TaskOwnedStablePracticePresentationV1({
    required this.runner,
    required this.table,
    required this.isReview,
    required this.question,
    required this.onBack,
    required this.onChooseOption,
    required this.onContinueReview,
    this.actionRecommendation,
    this.actionPayoff,
    this.tableHeight = 460,
    this.lowerPanelHeight = 282,
    this.compactFeedback = false,
  });

  final Act0RunnerStateV1 runner;
  final Act0TableStateV1 table;
  final bool isReview;
  final String question;
  final VoidCallback onBack;
  final ValueChanged<Act0RunnerOptionV1> onChooseOption;
  final VoidCallback onContinueReview;
  final Act0ActionRecommendationV1? actionRecommendation;
  final Act0ActionSessionPayoffV1? actionPayoff;
  final double tableHeight;
  final double lowerPanelHeight;
  final bool compactFeedback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedTableHeight = math.max(
            0.0,
            math.min(
              tableHeight,
              constraints.maxHeight - lowerPanelHeight - 20,
            ),
          );
          final tableWidth = math.min(
            constraints.maxWidth - 24,
            resolvedTableHeight * 0.576,
          );
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              children: [
                SizedBox(
                  key: const Key('act0_task_owned_practice_table_bounds'),
                  height: resolvedTableHeight,
                  width: tableWidth,
                  child: Act0TableSceneV1(
                    table: table,
                    config: Act0TablePresentationConfigV1(
                      maxTableHeight: tableHeight,
                      showFocusBadge: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    key: const Key('act0_task_owned_practice_panel'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Act0ShellTokensV1.primary.withValues(
                          alpha: 0.28,
                        ),
                      ),
                    ),
                    child: isReview
                        ? Column(
                            key: const Key('act0_shell_feedback_card'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                actionPayoff?.type ==
                                        Act0ActionPayoffTypeV1.recoveredSuccess
                                    ? 'Repair proved'
                                    : actionPayoff?.type ==
                                          Act0ActionPayoffTypeV1.cleanSuccess
                                    ? 'Action read confirmed'
                                    : actionPayoff == null
                                    ? runner.reviewTitle
                                    : 'Action read needs repair',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Act0ShellTokensV1.sectionTitle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                actionPayoff == null
                                    ? (actionRecommendation?.explanation ??
                                          runner.reviewReason)
                                    : '${actionPayoff!.proofStatement} ${actionPayoff!.meaningStatement}',
                                key: actionRecommendation == null
                                    ? null
                                    : const Key(
                                        'act0_action_recommendation_surface',
                                      ),
                                maxLines: actionPayoff == null
                                    ? (actionRecommendation == null ? 4 : 2)
                                    : 3,
                                overflow: TextOverflow.ellipsis,
                                style: Act0ShellTokensV1.body,
                              ),
                              if (compactFeedback) const SizedBox(height: 16),
                              if (!compactFeedback) const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: KeyedSubtree(
                                  key: const Key('act0_shell_continue_cta'),
                                  child: FilledButton(
                                    key: const Key(
                                      'act0_shell_feedback_continue_cta',
                                    ),
                                    onPressed: onContinueReview,
                                    child: Text(
                                      actionPayoff?.primaryActionLabel ??
                                          'Continue',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Act0ShellTokensV1.sectionTitle,
                              ),
                              const SizedBox(height: 8),
                              for (final option in runner.options)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      key: Key(
                                        'act0_shell_option_${option.id}',
                                      ),
                                      onPressed: () => onChooseOption(option),
                                      child: Text(
                                        option.label,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: onBack,
                                  child: const Text('Back'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RunnerTaskCycleViewportEnvelopeV1 {
  const _RunnerTaskCycleViewportEnvelopeV1({
    required this.familyName,
    required this.usesFixedLowerSlot,
    required this.targetLowerSlotHeight,
    required this.minLowerSlotHeight,
    required this.maxLowerSlotShare,
  });

  final String familyName;
  final bool usesFixedLowerSlot;
  final double targetLowerSlotHeight;
  final double minLowerSlotHeight;
  final double maxLowerSlotShare;

  double lowerSlotHeightFor(double availableHeight) {
    if (!usesFixedLowerSlot) {
      return 0;
    }
    final maxLowerSlotHeight = math.max(
      minLowerSlotHeight,
      availableHeight * maxLowerSlotShare,
    );
    return targetLowerSlotHeight.clamp(minLowerSlotHeight, maxLowerSlotHeight);
  }
}

_RunnerLowerStageProfileV1 _resolveRunnerLowerStageProfileV1({
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required bool compactRepairFeedbackDock,
  required _RunnerInteractionModeV1 interactionMode,
  required bool fillsDecisionStage,
}) {
  if (isReview) {
    return compactRepairFeedbackDock
        ? _RunnerLowerStageProfileV1.expandedFeedback
        : _RunnerLowerStageProfileV1.compactFeedback;
  }
  if (interactionMode == _RunnerInteractionModeV1.tableTapDecision) {
    return _RunnerLowerStageProfileV1.tableTapDecision;
  }
  // Instruction owns the complete remaining stage so its body can balance
  // above a fixed navigation rail without changing the table allocation.
  if (isTeaching || isTheory) {
    return _RunnerLowerStageProfileV1.instruction;
  }
  if (fillsDecisionStage) {
    return _RunnerLowerStageProfileV1.decision;
  }
  return _RunnerLowerStageProfileV1.instruction;
}

_RunnerTaskCycleViewportEnvelopeV1 _resolveRunnerTaskCycleViewportEnvelopeV1(
  BuildContext context, {
  required _RunnerViewportFamilyV1 viewportFamily,
  required String pressureReason,
  required bool repairFillMode,
  required bool shortSafeAnswerList,
  required bool compactRepairFeedbackDock,
  required _RunnerInteractionModeV1 interactionMode,
  required bool forceCompactStateAllocation,
}) {
  if (forceCompactStateAllocation) {
    return _RunnerTaskCycleViewportEnvelopeV1(
      familyName: 'compact_${interactionMode.name}',
      usesFixedLowerSlot: true,
      targetLowerSlotHeight:
          interactionMode == _RunnerInteractionModeV1.feedback
          ? _runnerRepairFeedbackDockTargetLowerSlotHeightV1
          : interactionMode == _RunnerInteractionModeV1.tableTapDecision
          ? _runnerCompactSeatTapTargetLowerSlotHeightV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeTargetLowerSlotHeightV1
                : _runnerEnvelopeWave1bTargetLowerSlotHeightV1),
      minLowerSlotHeight: interactionMode == _RunnerInteractionModeV1.feedback
          ? _runnerCompactFeedbackMinLowerSlotHeightV1
          : interactionMode == _RunnerInteractionModeV1.tableTapDecision
          ? _runnerCompactSeatTapMinLowerSlotHeightV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMinLowerSlotHeightV1
                : _runnerEnvelopeWave1bMinLowerSlotHeightV1),
      maxLowerSlotShare: interactionMode == _RunnerInteractionModeV1.feedback
          ? _runnerRepairFeedbackDockMaxLowerSlotShareV1
          : interactionMode == _RunnerInteractionModeV1.tableTapDecision
          ? _runnerCompactSeatTapMaxLowerSlotShareV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMaxLowerSlotShareV1
                : _runnerEnvelopeWave1bMaxLowerSlotShareV1),
    );
  }
  final usesFixedAnswerListEnvelope =
      pressureReason != _compactAnswerListNoPressureReasonV1 &&
      _viewportFamilyUsesAnswerListCompositionV1(viewportFamily);
  if (usesFixedAnswerListEnvelope) {
    final media = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.viewPaddingOf(context).vertical > 0
        ? MediaQuery.viewPaddingOf(context).vertical
        : MediaQuery.paddingOf(context).vertical;
    final usableHeight = media.height - safePadding;
    final targetLowerSlotHeight = compactRepairFeedbackDock
        ? _runnerRepairFeedbackDockTargetLowerSlotHeightV1
        : (usableHeight *
                  (repairFillMode
                      ? _runnerRepairEnvelopeTargetLowerSlotShareV1
                      : _runnerEnvelopeWave1bTargetLowerSlotShareV1))
              .clamp(
                repairFillMode
                    ? _runnerRepairEnvelopeMinLowerSlotHeightV1
                    : _runnerEnvelopeWave1bMinLowerSlotHeightV1,
                repairFillMode
                    ? _runnerRepairEnvelopeTargetLowerSlotHeightV1
                    : _runnerEnvelopeWave1bTargetLowerSlotHeightV1,
              );
    return _RunnerTaskCycleViewportEnvelopeV1(
      familyName: repairFillMode ? 'repairFill' : viewportFamily.name,
      usesFixedLowerSlot: true,
      targetLowerSlotHeight:
          !compactRepairFeedbackDock && !repairFillMode && shortSafeAnswerList
          ? _runnerShortAnswerEnvelopeTargetLowerSlotHeightV1
          : targetLowerSlotHeight,
      minLowerSlotHeight: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMinLowerSlotHeightV1
          : repairFillMode
          ? _runnerRepairEnvelopeMinLowerSlotHeightV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMinLowerSlotHeightV1
                : _runnerEnvelopeWave1bMinLowerSlotHeightV1),
      maxLowerSlotShare: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMaxLowerSlotShareV1
          : repairFillMode
          ? _runnerRepairEnvelopeMaxLowerSlotShareV1
          : (shortSafeAnswerList
                ? _runnerShortAnswerEnvelopeMaxLowerSlotShareV1
                : _runnerEnvelopeWave1bMaxLowerSlotShareV1),
    );
  }
  if (repairFillMode) {
    final media = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.viewPaddingOf(context).vertical > 0
        ? MediaQuery.viewPaddingOf(context).vertical
        : MediaQuery.paddingOf(context).vertical;
    final usableHeight = media.height - safePadding;
    final targetLowerSlotHeight =
        (usableHeight *
                (compactRepairFeedbackDock
                    ? _runnerRepairFeedbackDockTargetLowerSlotShareV1
                    : _runnerRepairEnvelopeTargetLowerSlotShareV1))
            .clamp(
              _runnerRepairEnvelopeMinLowerSlotHeightV1,
              _runnerRepairEnvelopeTargetLowerSlotHeightV1,
            );
    return _RunnerTaskCycleViewportEnvelopeV1(
      familyName: 'repairFill',
      usesFixedLowerSlot: true,
      targetLowerSlotHeight: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockTargetLowerSlotHeightV1
          : targetLowerSlotHeight,
      minLowerSlotHeight: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMinLowerSlotHeightV1
          : _runnerRepairEnvelopeMinLowerSlotHeightV1,
      maxLowerSlotShare: compactRepairFeedbackDock
          ? _runnerRepairFeedbackDockMaxLowerSlotShareV1
          : _runnerRepairEnvelopeMaxLowerSlotShareV1,
    );
  }
  return _RunnerTaskCycleViewportEnvelopeV1(
    familyName: viewportFamily.name,
    usesFixedLowerSlot: false,
    targetLowerSlotHeight: 0,
    minLowerSlotHeight: 0,
    maxLowerSlotShare: 0,
  );
}

double _runnerUpperStageChromeHeightV1({
  required bool showTopInstructionCard,
  required bool isRefinedDev2,
  required double compactTableStageTopInset,
}) {
  var height = Act0ShellTokensV1.gapSm;
  height += _runnerProgressRowHeightV1;
  height += showTopInstructionCard
      ? Act0ShellTokensV1.gapSm
      : Act0ShellTokensV1.gapXs;
  if (!isRefinedDev2) {
    height += Act0ShellTokensV1.gapSm;
    height += 24;
  }
  if (showTopInstructionCard) {
    height += Act0ShellTokensV1.refinedInstructionSlotHeight;
    height += isRefinedDev2 ? Act0ShellTokensV1.gapSm : Act0ShellTokensV1.gapMd;
  }
  height += compactTableStageTopInset;
  return height;
}

String? _learningRailProgressLabel(Act0RunnerStateV1 runner) {
  final total = runner.teachingSteps.length;
  if (total < 4) {
    return null;
  }
  final current = runner.teachingStepIndex.clamp(0, total - 1) + 1;
  return '$current/$total';
}

_RunnerInteractionModeV1 _resolveRunnerInteractionModeV1({
  required bool isDrill,
  required bool isReview,
  required bool hasSeatTargets,
}) {
  if (isReview) {
    return _RunnerInteractionModeV1.feedback;
  }
  if (isDrill && hasSeatTargets) {
    return _RunnerInteractionModeV1.tableTapDecision;
  }
  return _RunnerInteractionModeV1.answerListDecision;
}

Act0RunnerFramingProfileV1 _resolveRunnerFramingProfileV1({
  required Act0RunnerFramingProfileV1 requestedProfile,
  required _RunnerInteractionModeV1 interactionMode,
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (interactionMode == _RunnerInteractionModeV1.tableTapDecision ||
      hasSeatTargets) {
    return Act0RunnerFramingProfileV1.seatFocus;
  }
  if (requestedProfile != Act0RunnerFramingProfileV1.neutral) {
    return requestedProfile;
  }

  final hasHeroCards =
      table.heroCards.isNotEmpty ||
      table.seats.any((seat) => seat.holeCards.isNotEmpty && seat.isHero);
  final hasBoardCards = table.boardCards.isNotEmpty;
  final hasPotOrPrice =
      table.potLabel.trim().isNotEmpty ||
      table.toCallLabel.trim().isNotEmpty ||
      table.centerLabel.trim().isNotEmpty;

  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.sizing ||
      taskFamily == Act0TaskFamilyV1.repair) {
    return Act0RunnerFramingProfileV1.heroAction;
  }
  if (hasHeroCards && hasBoardCards && hasPotOrPrice) {
    return Act0RunnerFramingProfileV1.boardHeroPot;
  }
  if (hasBoardCards) {
    return Act0RunnerFramingProfileV1.boardOnly;
  }
  return Act0RunnerFramingProfileV1.neutral;
}

_RunnerViewportFamilyV1 _resolveRunnerViewportFamilyV1({
  required Act0RunnerFramingProfileV1 framingProfile,
  required bool hasSeatTargets,
}) {
  if (hasSeatTargets ||
      framingProfile == Act0RunnerFramingProfileV1.seatFocus) {
    return _RunnerViewportFamilyV1.tableTapSeatFocus;
  }
  return switch (framingProfile) {
    Act0RunnerFramingProfileV1.boardHeroPot ||
    Act0RunnerFramingProfileV1.boardOnly =>
      _RunnerViewportFamilyV1.answerListBoardHeroPot,
    Act0RunnerFramingProfileV1.heroAction =>
      _RunnerViewportFamilyV1.answerListHeroAction,
    Act0RunnerFramingProfileV1.seatFocus =>
      _RunnerViewportFamilyV1.tableTapSeatFocus,
    Act0RunnerFramingProfileV1.neutral => _RunnerViewportFamilyV1.neutral,
  };
}

class _RunnerInstructionSlotV1 extends StatelessWidget {
  const _RunnerInstructionSlotV1({
    required this.child,
    required this.showContent,
  });

  final Widget child;
  final bool showContent;

  @override
  Widget build(BuildContext context) {
    final content = showContent
        ? child
        : const SizedBox(key: Key('act0_shell_runner_prompt_spacer'));

    return showContent ? content : const SizedBox.shrink();
  }
}

class _RunnerActionDockV1 extends StatelessWidget {
  const _RunnerActionDockV1({
    required this.child,
    required this.pageX,
    this.taskRailLabel,
    this.sizingPresets,
    this.selectedPresetId,
    this.onSelectPreset,
    this.integratedLowerSurface = false,
    this.compactAnswerListDecision = false,
    this.fillCompactPromptToDock = false,
    this.scrollContentInEnvelope = false,
    this.protectFixedSlotBottom = false,
    this.centerBoundedLowerSurface = false,
    this.fillLowerStage = false,
    this.cycleStableEnvelope = false,
    this.lowerStageProfile = _RunnerLowerStageProfileV1.instruction,
    this.accessibilityFeedbackSurface = false,
  });

  final Widget child;
  final double pageX;
  final String? taskRailLabel;
  final List<Act0SizingPresetV1>? sizingPresets;
  final String? selectedPresetId;
  final ValueChanged<Act0SizingPresetV1>? onSelectPreset;
  final bool integratedLowerSurface;
  final bool compactAnswerListDecision;
  final bool fillCompactPromptToDock;
  final bool scrollContentInEnvelope;
  final bool protectFixedSlotBottom;
  final bool centerBoundedLowerSurface;
  final bool fillLowerStage;
  final bool cycleStableEnvelope;
  final _RunnerLowerStageProfileV1 lowerStageProfile;
  final bool accessibilityFeedbackSurface;

  @override
  Widget build(BuildContext context) {
    final hasSizingPresets = sizingPresets != null && sizingPresets!.isNotEmpty;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final usesAccessibilitySharedSurface =
        lowerStageProfile == _RunnerLowerStageProfileV1.accessibility;
    final effectiveTaskRailLabel = compactAnswerListDecision
        ? null
        : taskRailLabel;
    final fillsLowerStage =
        cycleStableEnvelope ||
        (fillLowerStage &&
            (lowerStageProfile == _RunnerLowerStageProfileV1.instruction ||
                lowerStageProfile == _RunnerLowerStageProfileV1.decision ||
                lowerStageProfile ==
                    _RunnerLowerStageProfileV1.tableTapDecision ||
                lowerStageProfile == _RunnerLowerStageProfileV1.accessibility));
    final double stageBottomPadding =
        lowerStageProfile == _RunnerLowerStageProfileV1.compactFeedback
        // SafeArea has already consumed the device inset. Keep only the
        // intentional stage-to-safe-area clearance here.
        ? 12.0
        : compactAnswerListDecision
        ? (protectFixedSlotBottom && safeBottom > 0 ? safeBottom + 12 : 0)
        : (scrollContentInEnvelope && safeBottom > 0
              ? safeBottom + 12
              : Act0ShellTokensV1.gapMd);
    // A scroll viewport gives its child unbounded vertical constraints, so it
    // must contain intrinsic content rather than an Expanded fill contract.
    final fillDockBody =
        (fillCompactPromptToDock || fillsLowerStage) &&
        !scrollContentInEnvelope &&
        (lowerStageProfile != _RunnerLowerStageProfileV1.accessibility ||
            accessibilityFeedbackSurface);
    final dockBody = _CompactAnswerListDecisionScopeV1(
      compact: compactAnswerListDecision,
      child: Column(
        mainAxisSize: fillDockBody ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (effectiveTaskRailLabel != null &&
              effectiveTaskRailLabel.isNotEmpty) ...[
            _TaskRailV1(label: effectiveTaskRailLabel),
            const SizedBox(height: 6),
          ],
          if (hasSizingPresets) ...[
            _SizingPresetsLaneV1(
              presets: sizingPresets!,
              selectedPresetId: selectedPresetId,
              onSelectPreset: onSelectPreset!,
            ),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
          if (fillDockBody)
            Expanded(
              child:
                  cycleStableEnvelope &&
                      (lowerStageProfile ==
                              _RunnerLowerStageProfileV1.decision ||
                          lowerStageProfile ==
                              _RunnerLowerStageProfileV1.tableTapDecision)
                  ? Align(alignment: Alignment.topCenter, child: child)
                  : child,
            )
          else
            child,
        ],
      ),
    );
    final effectiveDockBody =
        scrollContentInEnvelope && !fillCompactPromptToDock
        ? _BoundedLowerStageScrollV1(
            showActionFirst:
                lowerStageProfile ==
                _RunnerLowerStageProfileV1.expandedFeedback,
            child: dockBody,
          )
        : dockBody;
    final integratedDockBody = centerBoundedLowerSurface
        ? LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  height: math.min(
                    constraints.maxHeight,
                    _learningRailMaxHeightV1,
                  ),
                  child: effectiveDockBody,
                ),
              );
            },
          )
        : effectiveDockBody;
    final stageComposedDockBody = switch (lowerStageProfile) {
      _RunnerLowerStageProfileV1.compactFeedback =>
        cycleStableEnvelope
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_compact_feedback'),
                child: integratedDockBody,
              )
            : LayoutBuilder(
                builder: (context, constraints) => Align(
                  key: const Key('act0_shell_lower_stage_compact_feedback'),
                  alignment: Alignment.topCenter,
                  child: integratedDockBody,
                ),
              ),
      _RunnerLowerStageProfileV1.decision => SizedBox.expand(
        key: const Key('act0_shell_lower_stage_decision'),
        child: Align(alignment: Alignment.topCenter, child: integratedDockBody),
      ),
      _RunnerLowerStageProfileV1.tableTapDecision =>
        fillsLowerStage
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_table_tap_decision'),
                child: integratedDockBody,
              )
            : Align(
                key: const Key('act0_shell_lower_stage_table_tap_decision'),
                alignment: Alignment.topCenter,
                child: integratedDockBody,
              ),
      _RunnerLowerStageProfileV1.instruction =>
        fillsLowerStage
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_instruction'),
                child: integratedDockBody,
              )
            : Align(
                key: const Key('act0_shell_lower_stage_instruction'),
                alignment: Alignment.topCenter,
                child: integratedDockBody,
              ),
      _RunnerLowerStageProfileV1.expandedFeedback =>
        cycleStableEnvelope
            ? SizedBox.expand(
                key: const Key('act0_shell_lower_stage_expanded_feedback'),
                child: integratedDockBody,
              )
            : LayoutBuilder(
                builder: (context, constraints) => Align(
                  key: const Key('act0_shell_lower_stage_expanded_feedback'),
                  alignment: Alignment.topCenter,
                  child: integratedDockBody,
                ),
              ),
      _RunnerLowerStageProfileV1.accessibility => SizedBox.expand(
        key: const Key('act0_shell_lower_stage_accessibility'),
        child: accessibilityFeedbackSurface
            ? integratedDockBody
            : Align(alignment: Alignment.center, child: integratedDockBody),
      ),
    };
    final dockContent = usesAccessibilitySharedSurface
        ? SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pageX),
              child: Container(
                key: const Key('act0_shell_accessibility_shared_surface'),
                width: double.infinity,
                decoration: Act0ShellTokensV1.surfaceDecoration(
                  color: Act0ShellTokensV1.surface2,
                  borderColor: Act0ShellTokensV1.info.withValues(alpha: 0.24),
                ),
                child: stageComposedDockBody,
              ),
            ),
          )
        : integratedLowerSurface
        ? Padding(
            padding: EdgeInsets.fromLTRB(pageX, 0, pageX, 0),
            child: Container(
              key: const Key('act0_shell_runner_action_surface'),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                0,
                6,
                0,
                safeBottom > 0 ? safeBottom + 6 : 0,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Act0ShellTokensV1.surface2,
                    Act0ShellTokensV1.surface,
                  ],
                ),
              ),
              child: stageComposedDockBody,
            ),
          )
        : SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pageX,
                compactAnswerListDecision
                    ? 3
                    : lowerStageProfile ==
                          _RunnerLowerStageProfileV1.compactFeedback
                    ? 4
                    : Act0ShellTokensV1.gapSm,
                pageX,
                stageBottomPadding,
              ),
              child: stageComposedDockBody,
            ),
          );
    final visualDock = Container(
      key: const Key('act0_shell_runner_action_dock'),
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: Act0ShellTokensV1.runnerActionDockMinHeight,
      ),
      decoration: Act0ShellTokensV1.glassDecoration(top: true),
      child: dockContent,
    );
    return visualDock;
  }
}

/// Keeps an overflowing repair body discoverable with its primary CTA already
/// inside the safe viewport. The body scrolls upward from that stable action.
class _BoundedLowerStageScrollV1 extends StatelessWidget {
  const _BoundedLowerStageScrollV1({
    required this.child,
    this.showActionFirst = false,
  });

  final Widget child;
  final bool showActionFirst;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('act0_shell_lower_stage_scroll'),
      primary: false,
      reverse: showActionFirst,
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }
}

class _CompactAnswerListDecisionScopeV1 extends InheritedWidget {
  const _CompactAnswerListDecisionScopeV1({
    required this.compact,
    required super.child,
  });

  final bool compact;

  static bool isCompact(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              _CompactAnswerListDecisionScopeV1
            >()
            ?.compact ??
        false;
  }

  @override
  bool updateShouldNotify(_CompactAnswerListDecisionScopeV1 oldWidget) {
    return compact != oldWidget.compact;
  }
}

class _SizingPresetsLaneV1 extends StatelessWidget {
  const _SizingPresetsLaneV1({
    required this.presets,
    required this.selectedPresetId,
    required this.onSelectPreset,
  });

  final List<Act0SizingPresetV1> presets;
  final String? selectedPresetId;
  final ValueChanged<Act0SizingPresetV1> onSelectPreset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sizing',
          key: Key('act0_shell_sizing_presets_label'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Act0ShellTokensV1.info,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            for (var i = 0; i < presets.length; i++) ...[
              Expanded(
                child: _SizingPresetButtonV1(
                  preset: presets[i],
                  isSelected: presets[i].id == selectedPresetId,
                  onPressed: () => onSelectPreset(presets[i]),
                ),
              ),
              if (i < presets.length - 1)
                const SizedBox(width: Act0ShellTokensV1.gapXs),
            ],
          ],
        ),
      ],
    );
  }
}

class _SizingConfirmPanelV1 extends StatelessWidget {
  const _SizingConfirmPanelV1({
    required this.selectedPreset,
    required this.onConfirm,
  });

  final Act0SizingPresetV1? selectedPreset;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final preset = selectedPreset;
    final canConfirm = preset != null && onConfirm != null;
    final label = preset == null
        ? 'Select one size'
        : preset.ctaLabel ?? 'Lock ${preset.displayLabel ?? preset.label}';

    return FilledButton(
      key: const Key('act0_shell_sizing_confirm_cta'),
      onPressed: canConfirm ? onConfirm : null,
      style: Act0ShellTokensV1.primaryButtonStyle(
        height: Act0ShellTokensV1.compactCtaHeight,
      ),
      child: Text(label),
    );
  }
}

class _SizingPresetButtonV1 extends StatelessWidget {
  const _SizingPresetButtonV1({
    required this.preset,
    required this.isSelected,
    required this.onPressed,
  });

  final Act0SizingPresetV1 preset;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? Act0ShellTokensV1.primary.withValues(alpha: 0.16)
        : Act0ShellTokensV1.surface2;
    final borderColor = isSelected
        ? Act0ShellTokensV1.primary.withValues(alpha: 0.92)
        : Act0ShellTokensV1.primary.withValues(alpha: 0.3);

    return OutlinedButton(
      key: Key('act0_shell_sizing_preset_${preset.id}'),
      onPressed: onPressed,
      style: Act0ShellTokensV1.quietButtonStyle(height: 40).copyWith(
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        side: WidgetStatePropertyAll(
          BorderSide(color: borderColor, width: 1.5),
        ),
        foregroundColor: WidgetStatePropertyAll(
          isSelected ? Act0ShellTokensV1.primary : Act0ShellTokensV1.text,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            preset.displayLabel ?? preset.label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          if ((preset.detailLabel ?? '').isNotEmpty)
            Text(
              preset.detailLabel!,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    (isSelected
                            ? Act0ShellTokensV1.primary
                            : Act0ShellTokensV1.textMuted)
                        .withValues(alpha: isSelected ? 0.92 : 0.9),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepIntroPillV1 extends StatelessWidget {
  const _StepIntroPillV1({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_step_intro_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.text,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRailV1 extends StatelessWidget {
  const _TaskRailV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_task_rail'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 12,
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 3,
              style: Act0ShellTokensV1.body.copyWith(
                fontSize: 12,
                color: Act0ShellTokensV1.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharkyCuePillV1 extends StatelessWidget {
  const _SharkyCuePillV1({
    required this.line,
    required this.tone,
    required this.mood,
  });

  final String line;
  final Color tone;
  final Act0SharkyMoodV1 mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Act0SharkyMascotV1(mood: mood, tone: tone, size: 32),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              line,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Act0SharkyMascotV1 extends StatelessWidget {
  const Act0SharkyMascotV1({
    super.key,
    required this.mood,
    required this.tone,
    this.size = 32,
  });

  final Act0SharkyMoodV1 mood;
  final Color tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final motionScale = switch (mood) {
      Act0SharkyMoodV1.happy => 1.08,
      Act0SharkyMoodV1.celebrate => 1.12,
      Act0SharkyMoodV1.repair => 0.96,
      Act0SharkyMoodV1.thinking => 1.03,
      Act0SharkyMoodV1.neutral => 1.0,
    };
    final motionTilt = switch (mood) {
      Act0SharkyMoodV1.happy => -0.05,
      Act0SharkyMoodV1.celebrate => 0.08,
      Act0SharkyMoodV1.repair => -0.08,
      Act0SharkyMoodV1.thinking => 0.04,
      Act0SharkyMoodV1.neutral => 0.0,
    };

    return Semantics(
      label: 'Sharky mascot',
      child: SizedBox(
        key: const Key('act0_shell_sharky_mascot_motion'),
        child: TweenAnimationBuilder<double>(
          key: ValueKey('act0_shell_sharky_mascot_motion_${mood.name}'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final easedScale = 1 + ((motionScale - 1) * value);
            final easedTilt = motionTilt * value;
            return Transform.rotate(
              angle: easedTilt,
              child: Transform.scale(scale: easedScale, child: child),
            );
          },
          child: SizedBox(
            key: const Key('act0_shell_sharky_mascot'),
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  size * Act0ShellTokensV1.sharkyTileRadiusRatio,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tone.withValues(alpha: 0.20),
                    blurRadius: size * 0.24,
                    offset: Offset(0, size * 0.08),
                  ),
                ],
              ),
              child: KeyedSubtree(
                key: Key('act0_shell_sharky_mascot_${mood.name}'),
                child: Act0SharkyPresenceMascotV1(
                  mood: mood,
                  tone: tone,
                  size: size,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const double _learningRailMaxHeightV1 = 148;
const double _sharedActiveRunnerLearningRailMaxHeightV1 = 148;
const double _runnerCompositionHeaderAndGapV1 = 48;
const double _sharedRunnerSeamV1 = 10;
const double _sharedRunnerTableFramingInsetV1 = 12;
const double _sharedRunnerEnlargedTextDockGrowthV1 = 285;

double _sharedRunnerCycleStableEnvelopeHeightV1({
  required double stageHeight,
  required double accessibilityScale,
}) {
  final boundedScale = accessibilityScale.clamp(1.0, 1.4);
  final decisionDockDemand =
      156 + ((boundedScale - 1) * _sharedRunnerEnlargedTextDockGrowthV1);
  final cyclePeakFraction = boundedScale >= 1.3 ? 0.50 : 0.36;
  final cyclePeak = stageHeight * cyclePeakFraction;
  final reserveMax = stageHeight * 0.13;
  return math.min(cyclePeak, decisionDockDemand + reserveMax);
}

BoxDecoration _sharedRunnerSeamDecorationV1() => BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 1),
  ),
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Act0ShellTokensV1.surface2.withValues(alpha: 0.18),
      Act0ShellTokensV1.surface2.withValues(alpha: 0.04),
    ],
  ),
);

double _normalRunnerLowerSurfaceDemandV1(
  BuildContext context, {
  required String question,
  required List<Act0RunnerOptionV1> options,
  required bool showsLearningRail,
  bool includeStableLaneFloor = true,
}) {
  // An answer runner keeps one measured decision demand through its ordinary
  // theory, decision, and feedback cycle so the table does not jump.
  if (options.isNotEmpty) {
    final media = MediaQuery.of(context);
    final width = math.max(1.0, media.size.width - 56);
    final scaler = media.textScaler;
    // A normal decision row must keep its complete touch/read target as copy
    // grows. This uses the live scaler, rather than a public scale threshold,
    // so activation follows measured lower-surface demand.
    final scaledControlFloor = math.max(44.0, 44.0 * scaler.scale(1));
    double measuredHeight(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: null,
      )..layout(maxWidth: width);
      return painter.height;
    }

    final questionHeight = measuredHeight(
      question,
      Act0ShellTokensV1.body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        height: 1.06,
      ),
    );
    final optionDemand = options.fold<double>(0, (sum, option) {
      final labelHeight = measuredHeight(
        option.label,
        Act0ShellTokensV1.body.copyWith(fontSize: 12.6, height: 1.08),
      );
      return sum + math.max(scaledControlFloor, labelHeight + 10);
    });
    // Surface padding, question-to-answer rhythm, dividers, and bounded
    // bottom clearance. This is intrinsic content demand, not final layout
    // allocation or empty lower-surface space.
    final intrinsicDemand = questionHeight + optionDemand + 34;
    // Table allocation is a stable stage contract. It is deliberately
    // separate from the intrinsic content demand used for accessibility
    // activation below, so short copy cannot resize the accepted hand.
    return includeStableLaneFloor
        ? math.max(279, intrinsicDemand)
        : intrinsicDemand;
  }
  return showsLearningRail
      ? _sharedActiveRunnerLearningRailMaxHeightV1
      : Act0ShellTokensV1.runnerActionDockMinHeight;
}

/// Predicts compact-mode activation before the normal table-plus-answer layout
/// renders. It measures the actual question and option copy at the admitted
/// text scale against the lower space left by the accepted table geometry.
bool act0ShouldActivateCompactAccessibilityPrototypeV1(
  BuildContext context, {
  required String question,
  required List<Act0RunnerOptionV1> options,
  List<String> tableCriticalLabels = const <String>[],
}) {
  final media = MediaQuery.of(context);
  final supportedPhone = media.size.shortestSide < 600;
  if (!supportedPhone || options.length != 4) {
    return false;
  }
  final required = _normalRunnerLowerSurfaceDemandV1(
    context,
    question: question,
    options: options,
    showsLearningRail: false,
    includeStableLaneFloor: false,
  );
  final safe = media.viewPadding.vertical > 0
      ? media.viewPadding.vertical
      : media.padding.vertical;
  // This is the smallest accepted normal table stage plus runner chrome. If
  // even that stage and the measured lower demand cannot coexist, preserve
  // the hand through Evidence -> Decision rather than shrinking it further.
  const acceptedTableAndChrome = 533.0;
  final available = media.size.height - safe - acceptedTableAndChrome;
  // A broad unwrapped-label width cannot establish a table collision: the
  // admitted centre guidance may wrap safely to two lines. Activation follows
  // intrinsic composition demand; table geometry retains collision ownership.
  return required > available;
}

class _AccessibilityDirectDecisionV1 extends StatelessWidget {
  const _AccessibilityDirectDecisionV1({
    required this.question,
    required this.guidance,
    required this.options,
    required this.onChoose,
  });

  final String question;
  final String guidance;
  final List<Act0RunnerOptionV1> options;
  final ValueChanged<Act0RunnerOptionV1> onChoose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        key: const Key('act0_shell_accessibility_answer_group'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const Key('act0_shell_accessibility_decision_module'),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    question,
                    key: const Key('act0_shell_accessibility_question'),
                    style: Act0ShellTokensV1.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                ),
                if (guidance.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      guidance,
                      key: const Key('act0_shell_accessibility_guidance'),
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        fontSize: 11,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Container(
                  height: 1,
                  color: Act0ShellTokensV1.info.withValues(alpha: 0.34),
                ),
                const SizedBox(height: 2),
                for (final option in options) ...[
                  Semantics(
                    button: true,
                    label: option.label,
                    child: Material(
                      color: Act0ShellTokensV1.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        key: Key('act0_shell_option_${option.id}'),
                        onTap: () => onChoose(option),
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 48,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                option.label,
                                style: Act0ShellTokensV1.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (option != options.last) const SizedBox(height: 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A bounded, opt-in artifact for the Phase 1 lower-surface gate. Core repair
/// is deliberately short and paginated; only the optional reference article
/// receives a body viewport. Its footer is a sibling, never scroll content.
class _PrototypeRepairSurfaceV1 extends StatelessWidget {
  const _PrototypeRepairSurfaceV1({required this.state});

  final Act0LowerSurfacePrototypeStateV1 state;

  @override
  Widget build(BuildContext context) {
    final expanded =
        state == Act0LowerSurfacePrototypeStateV1.expandedReference;
    final beat = switch (state) {
      Act0LowerSurfacePrototypeStateV1.coreRepairBeat1 => (
        title: 'Missed clue',
        body: 'Start with the visible table clue before choosing an action.',
        footer: 'Next',
      ),
      Act0LowerSurfacePrototypeStateV1.coreRepairBeat2 => (
        title: 'Reusable rule',
        body:
            'Read the seats, board, and price together. The same order works in the next hand.',
        footer: 'Next',
      ),
      Act0LowerSurfacePrototypeStateV1.coreRepairFinalBeat => (
        title: 'Prepare to recheck',
        body: 'Use that one table read now, then make the same decision again.',
        footer: 'Recheck',
      ),
      Act0LowerSurfacePrototypeStateV1.expandedReference => (
        title: 'Learn more',
        body: '',
        footer: 'Done reading',
      ),
    };
    final body = expanded
        ? SingleChildScrollView(
            key: const Key('act0_shell_expanded_reference_body_scroll'),
            primary: false,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 56),
            child: Column(
              key: const Key('act0_shell_expanded_reference_body'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Learn more',
                  key: Key('act0_shell_expanded_reference_top'),
                ),
                SizedBox(height: 8),
                Text(
                  'The quick repair is enough for the next decision. This reference keeps the longer explanation separate: read the table first, then identify the price, then choose the action that matches both facts.'
                  '\n\nThe body is intentionally longer than the compact surface. It can move without moving the table, the surface seam, or the action rail below it.'
                  '\n\nWhen the table changes, repeat the same read in order. That turns one missed clue into a reusable rule instead of a long default lesson.',
                ),
                SizedBox(height: 16),
                Text(
                  'Use this longer reference only when you want the extra why. It is not the default repair: the short three beats are the learner path, while this body is a separate place to revisit the same rule at your own pace.'
                  '\n\nKeep the table as the source of truth. A label is useful only when it points back to a visible seat, card, board, pot, or action.'
                  '\n\nFinish the reference by returning to one concrete recheck. The footer stays available while this explanation moves beneath it.',
                ),
                SizedBox(height: 24),
                Text(
                  'End of reference',
                  key: Key('act0_shell_expanded_reference_bottom'),
                ),
              ],
            ),
          )
        : KeyedSubtree(
            key: const Key('act0_shell_core_repair_body'),
            child: Text(beat.body),
          );
    return Container(
      key: const Key('act0_shell_prototype_repair_surface'),
      constraints: const BoxConstraints.tightFor(height: 148),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        key: const Key('act0_shell_prototype_repair_column'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            beat.title,
            key: const Key('act0_shell_prototype_repair_title'),
            maxLines: 2,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: expanded
                ? body
                : Align(alignment: Alignment.topLeft, child: body),
          ),
          const SizedBox(height: 8),
          SizedBox(
            key: const Key('act0_shell_prototype_repair_footer'),
            height: Act0ShellTokensV1.compactCtaHeight,
            child: FilledButton(
              key: const Key('act0_shell_prototype_repair_cta'),
              onPressed: () {},
              child: Text(beat.footer),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningRailV1 extends StatelessWidget {
  const _LearningRailV1({
    required this.taskLabel,
    required this.prompt,
    required this.supportSegments,
    required this.activeSupportSegmentIndex,
    required this.progressLabel,
    required this.canGoBack,
    required this.onBack,
    required this.canAdvance,
    required this.onAdvance,
    required this.sharkyLine,
    required this.sharkyMood,
    required this.advanceLabel,
    this.maxHeight = _learningRailMaxHeightV1,
    this.emphasizePrompt = false,
    this.fillsAvailableHeight = false,
  });

  final String? taskLabel;
  final String prompt;
  final List<String> supportSegments;
  final int activeSupportSegmentIndex;
  final String? progressLabel;
  final bool canGoBack;
  final VoidCallback? onBack;
  final bool canAdvance;
  final VoidCallback onAdvance;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;
  final String advanceLabel;
  final double maxHeight;
  final bool emphasizePrompt;
  final bool fillsAvailableHeight;

  @override
  Widget build(BuildContext context) {
    final showTaskLabel = taskLabel != null && taskLabel!.trim().isNotEmpty;
    final hasSupportLine = supportSegments.isNotEmpty;
    final showRailProgress =
        progressLabel != null && progressLabel!.trim().isNotEmpty;
    final fallbackCoachLine = sharkyLine.trim();
    final showFallbackCoachLine =
        !hasSupportLine && fallbackCoachLine.isNotEmpty;
    final tone = canAdvance
        ? Act0ShellTokensV1.primary
        : Act0ShellTokensV1.textMuted;
    return Material(
      color: Colors.transparent,
      child: Container(
        key: const Key('act0_shell_learning_rail'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.min(102, maxHeight),
            maxHeight: fillsAvailableHeight ? double.infinity : maxHeight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const footerHeight = 34.0;
              final compactRail =
                  !fillsAvailableHeight && constraints.maxHeight <= maxHeight;
              final compactLaneMaxWidth = compactRail ? 286.0 : double.infinity;
              final activePage = hasSupportLine
                  ? supportSegments[activeSupportSegmentIndex.clamp(
                      0,
                      supportSegments.length - 1,
                    )]
                  : fallbackCoachLine;
              final title = showTaskLabel ? taskLabel! : 'Read the table';
              final pageCount = math.max(1, supportSegments.length);
              final pageNumber =
                  activeSupportSegmentIndex.clamp(0, pageCount - 1) + 1;
              final usesBoundedContentScroll =
                  MediaQuery.textScalerOf(context).scale(1) > 1.1;
              final contentLane = Semantics(
                label: 'Theory page $pageNumber of $pageCount',
                child: ConstrainedBox(
                  key: const Key('act0_shell_learning_rail_content_lane'),
                  constraints: BoxConstraints(maxWidth: compactLaneMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        key: const Key('act0_shell_learning_rail_task_label'),
                        maxLines: 2,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.info,
                          letterSpacing: 0.16,
                          fontSize: 10.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatInstructionCopyV1(
                          activePage,
                          allowSingleClauseSplit: true,
                        ),
                        key: const Key('act0_shell_runner_prompt'),
                        softWrap: true,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: compactRail ? 13.0 : 14.0,
                          height: 1.24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compactRail ? 10 : 12,
                  vertical: emphasizePrompt ? 3 : 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: usesBoundedContentScroll
                          ? SingleChildScrollView(
                              key: const Key(
                                'act0_shell_learning_rail_content_scroll',
                              ),
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: contentLane,
                              ),
                            )
                          : Align(
                              // The navigation footer is the next action for
                              // this instruction. Short pages stay intrinsic
                              // and compose directly above it.
                              alignment: fillsAvailableHeight
                                  ? Alignment.topCenter
                                  : Alignment.bottomCenter,
                              child: contentLane,
                            ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      key: const Key('act0_shell_learning_rail_fixed_footer'),
                      height: 28,
                      child: Row(
                        children: [
                          _LearningRailNavButtonV1(
                            icon: Icons.arrow_back_ios_new_rounded,
                            buttonKey: const Key('act0_shell_previous_cta'),
                            enabled: canGoBack,
                            onPressed: onBack,
                            compact: compactRail,
                          ),
                          if (pageCount > 1) ...[
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: _LearningRailSupportDotsV1(
                                  key: const Key(
                                    'act0_shell_learning_rail_support_dots',
                                  ),
                                  count: pageCount,
                                  current: activeSupportSegmentIndex.clamp(
                                    0,
                                    pageCount - 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: Act0ShellTokensV1.gapSm),
                          ] else
                            const Spacer(),
                          _LearningRailNavButtonV1(
                            icon: Icons.arrow_forward_ios_rounded,
                            buttonKey: const Key('act0_shell_continue_cta'),
                            enabled: canAdvance,
                            onPressed: canAdvance ? onAdvance : null,
                            tone: tone,
                            compact: compactRail,
                            label: act0RuntimeLocalizedGeneralLabelV1(
                              context,
                              advanceLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RailFocusChipV1 extends StatelessWidget {
  const _RailFocusChipV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.textMuted.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.textMuted.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textMuted,
          fontSize: 9,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LearningRailSupportDotsV1 extends StatelessWidget {
  const _LearningRailSupportDotsV1({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: i == current ? 10 : 4,
            height: 4,
            decoration: BoxDecoration(
              color: i == current
                  ? Act0ShellTokensV1.primary
                  : Act0ShellTokensV1.textMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
        ],
      ],
    );
  }
}

class _LearningRailNavButtonV1 extends StatelessWidget {
  const _LearningRailNavButtonV1({
    required this.icon,
    required this.buttonKey,
    required this.enabled,
    this.onPressed,
    this.tone = Act0ShellTokensV1.text,
    this.compact = false,
    this.label,
  });

  final IconData icon;
  final Key buttonKey;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color tone;
  final bool compact;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final hasLabel = (label ?? '').trim().isNotEmpty;
    final resolvedLabel = label?.trim() ?? '';
    return Container(
      width: hasLabel ? null : (compact ? 32 : 40),
      height: compact ? 32 : 40,
      constraints: BoxConstraints(
        minWidth: hasLabel ? (compact ? 92 : 110) : (compact ? 32 : 40),
      ),
      decoration: BoxDecoration(
        color: enabled
            ? tone.withValues(alpha: 0.12)
            : Act0ShellTokensV1.surface3.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
        border: Border.all(
          color: enabled
              ? tone.withValues(alpha: 0.30)
              : Act0ShellTokensV1.border.withValues(alpha: 0.76),
        ),
      ),
      child: TextButton(
        key: buttonKey,
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: hasLabel ? 10 : 0,
            vertical: 0,
          ),
          minimumSize: Size(
            hasLabel ? (compact ? 92 : 110) : (compact ? 32 : 40),
            compact ? 32 : 40,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
          ),
        ),
        child: hasLabel
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      resolvedLabel,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: enabled ? tone : Act0ShellTokensV1.textDim,
                        fontSize: compact ? 11.0 : 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    icon,
                    size: compact ? 12 : 16,
                    color: enabled ? tone : Act0ShellTokensV1.textDim,
                  ),
                ],
              )
            : Icon(
                icon,
                size: compact ? 12 : 16,
                color: enabled ? tone : Act0ShellTokensV1.textDim,
              ),
      ),
    );
  }
}

/// Reusable production-quality full table scene.
///
/// The public constructor intentionally exposes only semantic table state and a
/// data-only presentation config. The runner uses [_fromRunner] to retain its
/// private interaction, overlay, and viewport policy without making those
/// policies part of this scene's external contract.
class Act0TableSceneV1 extends StatelessWidget {
  const Act0TableSceneV1({
    super.key,
    required this.table,
    this.config = const Act0TablePresentationConfigV1(),
    this.onBoardCardTap,
  }) : _runnerInput = null;

  Act0TableSceneV1._fromRunner({required _Act0TableSceneRunnerInput input})
    : table = input.table,
      config = null,
      onBoardCardTap = null,
      _runnerInput = input;

  final Act0TableStateV1 table;
  final Act0TablePresentationConfigV1? config;
  final ValueChanged<Act0TableStateV1>? onBoardCardTap;
  final _Act0TableSceneRunnerInput? _runnerInput;

  @override
  Widget build(BuildContext context) {
    final input = _runnerInput;
    if (input != null) {
      return _Act0TableV1(
        table: input.table,
        highlightedCardIds: input.highlightedCardIds,
        interactiveCalloutLabel: input.interactiveCalloutLabel,
        onBoardCardTap: input.onBoardCardTap,
        onChooseSeat: input.onChooseSeat,
        visualVariant: input.visualVariant,
        showFocusBadge: input.showFocusBadge,
        showRepairCallout: input.showRepairCallout,
        playbackActiveSeatId: input.playbackActiveSeatId,
        animateBetMotion: input.animateBetMotion,
        betOverride: input.betOverride,
        centerLabelOverride: input.centerLabelOverride,
        potLabelOverride: input.potLabelOverride,
        toCallLabelOverride: input.toCallLabelOverride,
        streetLabelOverride: input.streetLabelOverride,
        completionSummary: input.completionSummary,
        selectedSeatId: input.selectedSeatId,
        selectedSeatFeedbackState: input.selectedSeatFeedbackState,
        compactBottomDockClearance: input.compactBottomDockClearance,
        interactionMode: input.interactionMode,
        framingProfile: input.framingProfile,
        viewportFamily: input.viewportFamily,
        lateRouteSignal: input.lateRouteSignal,
        identityPolicy: input.identityPolicy,
        maxTableHeight: input.maxTableHeight,
        lockSharedActiveTableGeometry: input.lockSharedActiveTableGeometry,
        integratedPerspectivePrototype: input.integratedPerspectivePrototype,
      );
    }
    final resolved = config!;
    return _Act0TableV1(
      table: table,
      highlightedCardIds: resolved.highlightedCardIds,
      interactiveCalloutLabel: '',
      onBoardCardTap: (table) => onBoardCardTap?.call(table),
      visualVariant: resolved.useRefinedVisualVariant
          ? Act0ShellTableVisualVariantV1.refinedDev2
          : Act0ShellTableVisualVariantV1.classic,
      showFocusBadge: resolved.showFocusBadge,
      showRepairCallout: resolved.showRepairCallout,
      compactBottomDockClearance: resolved.compactBottomDockClearance,
      identityPolicy: resolved.identityPolicy,
      interactionMode: _RunnerInteractionModeV1.answerListDecision,
      framingProfile: Act0RunnerFramingProfileV1.neutral,
      viewportFamily: _RunnerViewportFamilyV1.neutral,
      maxTableHeight: resolved.maxTableHeight,
    );
  }
}

class _Act0TableSceneRunnerInput {
  const _Act0TableSceneRunnerInput({
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    required this.onChooseSeat,
    required this.visualVariant,
    required this.showFocusBadge,
    required this.showRepairCallout,
    required this.playbackActiveSeatId,
    required this.animateBetMotion,
    required this.betOverride,
    required this.centerLabelOverride,
    required this.potLabelOverride,
    required this.toCallLabelOverride,
    required this.streetLabelOverride,
    required this.completionSummary,
    required this.selectedSeatId,
    required this.selectedSeatFeedbackState,
    required this.compactBottomDockClearance,
    required this.interactionMode,
    required this.framingProfile,
    required this.viewportFamily,
    required this.lateRouteSignal,
    required this.identityPolicy,
    required this.maxTableHeight,
    required this.lockSharedActiveTableGeometry,
    required this.integratedPerspectivePrototype,
  });
  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final String? playbackActiveSeatId;
  final bool animateBetMotion;
  final Act0SeatBetStateV1? betOverride;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? selectedSeatId;
  final _SeatSelectionFeedbackStateV1 selectedSeatFeedbackState;
  final bool compactBottomDockClearance;
  final _RunnerInteractionModeV1 interactionMode;
  final Act0RunnerFramingProfileV1 framingProfile;
  final _RunnerViewportFamilyV1 viewportFamily;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final double? maxTableHeight;
  final bool lockSharedActiveTableGeometry;
  final bool integratedPerspectivePrototype;
}

class _RunnerTableStageV1 extends StatelessWidget {
  const _RunnerTableStageV1({
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    required this.onChooseSeat,
    required this.visualVariant,
    this.showFocusBadge = true,
    this.showRepairCallout = true,
    this.playbackActiveSeatId,
    this.animateBetMotion = false,
    this.betOverride,
    this.centerLabelOverride,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
    this.completionSummary,
    this.selectedSeatId,
    this.selectedSeatFeedbackState = _SeatSelectionFeedbackStateV1.none,
    this.compactBottomDockClearance = false,
    required this.interactionMode,
    required this.framingProfile,
    required this.viewportFamily,
    this.lateRouteSignal,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.maxTableHeight,
    this.lockSharedActiveTableGeometry = false,
    this.integratedPerspectivePrototype = false,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final String? playbackActiveSeatId;
  final bool animateBetMotion;
  final Act0SeatBetStateV1? betOverride;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? selectedSeatId;
  final _SeatSelectionFeedbackStateV1 selectedSeatFeedbackState;
  final bool compactBottomDockClearance;
  final _RunnerInteractionModeV1 interactionMode;
  final Act0RunnerFramingProfileV1 framingProfile;
  final _RunnerViewportFamilyV1 viewportFamily;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final double? maxTableHeight;
  final bool lockSharedActiveTableGeometry;
  final bool integratedPerspectivePrototype;

  @override
  Widget build(BuildContext context) {
    return Act0TableSceneV1._fromRunner(
      input: _Act0TableSceneRunnerInput(
        table: table,
        highlightedCardIds: highlightedCardIds,
        interactiveCalloutLabel: interactiveCalloutLabel,
        onBoardCardTap: onBoardCardTap,
        onChooseSeat: onChooseSeat,
        visualVariant: visualVariant,
        showFocusBadge: showFocusBadge,
        showRepairCallout: showRepairCallout,
        playbackActiveSeatId: playbackActiveSeatId,
        animateBetMotion: animateBetMotion,
        betOverride: betOverride,
        centerLabelOverride: centerLabelOverride,
        potLabelOverride: potLabelOverride,
        toCallLabelOverride: toCallLabelOverride,
        streetLabelOverride: streetLabelOverride,
        completionSummary: completionSummary,
        selectedSeatId: selectedSeatId,
        selectedSeatFeedbackState: selectedSeatFeedbackState,
        compactBottomDockClearance: compactBottomDockClearance,
        interactionMode: interactionMode,
        framingProfile: framingProfile,
        viewportFamily: viewportFamily,
        lateRouteSignal: lateRouteSignal,
        identityPolicy: identityPolicy,
        maxTableHeight: maxTableHeight,
        lockSharedActiveTableGeometry: lockSharedActiveTableGeometry,
        integratedPerspectivePrototype: integratedPerspectivePrototype,
      ),
    );
  }
}

Act0TableStateV1 _teachingTable(
  Act0TableStateV1 base,
  Act0TeachingStepV1? step,
) {
  if (step == null) {
    return base;
  }
  final source = step.table ?? base;
  final preserveBaseSeatContext =
      (base.activeSeatId ?? '').trim().isNotEmpty ||
      base.seats.any((seat) => seat.isActive);
  final seatContextSource = preserveBaseSeatContext ? base : source;
  final anchorSeatIds = _instructionAnchorSeatIds(source);
  final anchorCardIds = _instructionAnchorCardIds(source);
  return source.copyWith(
    seats: seatContextSource.seats,
    heroSeatId: seatContextSource.heroSeatId ?? source.heroSeatId,
    activeSeatId: preserveBaseSeatContext
        ? seatContextSource.activeSeatId
        : source.activeSeatId,
    highlightedSeatIds: step.focusSeatIds.isEmpty
        ? (source.highlightedSeatIds.isEmpty
              ? anchorSeatIds
              : source.highlightedSeatIds)
        : step.focusSeatIds,
    highlightedCardIds: step.focusCardIds.isEmpty
        ? (source.highlightedCardIds.isEmpty
              ? anchorCardIds
              : source.highlightedCardIds)
        : step.focusCardIds,
  );
}

List<String> _instructionAnchorSeatIds(Act0TableStateV1 table) {
  switch (table.instructionAnchor) {
    case 'hero':
      final heroSeatId = table.heroSeatId ?? table.heroSeat.seatId;
      return <String>[heroSeatId];
    default:
      return const <String>[];
  }
}

List<String> _instructionAnchorCardIds(Act0TableStateV1 table) {
  switch (table.instructionAnchor) {
    case 'cards':
      return List<String>.generate(
        table.heroCards.length,
        (index) => 'hero_$index',
      );
    case 'board':
      return List<String>.generate(
        table.boardCards.length,
        (index) => 'board_$index',
      );
    default:
      return const <String>[];
  }
}

Act0TableStateV1 _repairTable(
  Act0TableStateV1 base,
  Act0RunnerOptionV1? option,
) {
  if (option == null) {
    return base;
  }
  return base.copyWith(
    highlightedSeatIds: option.repairFocusSeatIds.isEmpty
        ? base.highlightedSeatIds
        : option.repairFocusSeatIds,
    highlightedCardIds: option.repairFocusCardIds.isEmpty
        ? base.highlightedCardIds
        : option.repairFocusCardIds,
  );
}

Act0FeedbackSignalProofV1? _feedbackSignalProofForRunnerV1({
  required Act0RunnerStateV1 runner,
  required Act0RunnerOptionV1? option,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final table = runner.table;
  final selectedOption = option ?? runner.selectedOption;
  final correctOption = runner.options.cast<Act0RunnerOptionV1?>().firstWhere(
    (candidate) => candidate?.isCorrect == true,
    orElse: () => null,
  );
  final targetOption = selectedOption?.isCorrect == true
      ? selectedOption
      : correctOption;
  if (selectedOption != null) {
    final repairSeatIds = _trimmedUniqueStringsV1(
      selectedOption.repairFocusSeatIds,
    );
    final repairCardIds = _trimmedUniqueStringsV1(
      selectedOption.repairFocusCardIds,
    );
    final repairLabels = _trimmedUniqueStringsV1(
      selectedOption.repairFocusLabels,
    );
    final repairTableProof = _proofFromTableSignalsV1(
      table: table,
      seatIds: repairSeatIds,
      cardIds: repairCardIds,
      repairLabels: repairLabels,
    );
    if (repairTableProof != null) {
      return repairTableProof;
    }
  }

  final targetSeatId = (targetOption?.seatId ?? '').trim();
  if (targetSeatId.isNotEmpty) {
    return _proofFromSeatSignalV1(table, targetSeatId);
  }

  if (hasSeatTargets) {
    final activeSeatId = (table.activeSeatId ?? '').trim();
    if (activeSeatId.isNotEmpty) {
      return _proofFromSeatSignalV1(table, activeSeatId);
    }
  }

  final tableText =
      '${runner.lessonId} ${runner.lessonTitle} ${runner.caption} '
              '${runner.hint} ${runner.question} ${runner.reviewReason} '
              '${table.centerLabel} ${table.potLabel} ${table.toCallLabel}'
          .toLowerCase();
  final looksLikeTableRead =
      taskFamily == Act0TaskFamilyV1.transfer ||
      tableText.contains('table read') ||
      (tableText.contains('board') && tableText.contains('pot'));
  if (looksLikeTableRead &&
      table.heroCards.isNotEmpty &&
      table.boardCards.isNotEmpty &&
      table.potLabel.trim().isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'hero_cards_board_pot',
      label: 'Hero cards + board + pot',
      cardIds: <String>[
        for (var i = 0; i < table.heroCards.length; i++) 'hero_$i',
        for (var i = 0; i < table.boardCards.length; i++) 'board_$i',
      ],
      statKeys: const <String>['pot'],
    );
  }

  if (table.toCallLabel.trim().isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'pot_to_call',
      label: 'Pot / to call',
      statKeys: const <String>['pot', 'to_call'],
    );
  }

  final centerLabel = table.centerLabel.trim().toLowerCase();
  if (centerLabel.contains('no bet') || centerLabel.contains('check')) {
    return _feedbackSignalProofV1(signalId: 'no_bet_yet', label: 'No bet yet');
  }

  if (table.boardCards.isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'board_cards',
      label: 'Board cards',
      cardIds: <String>[
        for (var i = 0; i < table.boardCards.length; i++) 'board_$i',
      ],
    );
  }

  return null;
}

Act0SkillReceiptV1? _skillReceiptForSignalProofV1({
  required Act0FeedbackSignalProofV1? proof,
  required Act0FeedbackQualityV1 quality,
}) {
  if (proof == null) {
    return null;
  }
  final sourceSignalLabel = proof.label.trim();
  if (sourceSignalLabel.isEmpty) {
    return null;
  }
  final spec = _skillReceiptSpecForSignalIdV1(proof.signalId);
  return Act0SkillReceiptV1(
    skillAtomId: spec.skillAtomId,
    skillLabel: spec.skillLabel,
    sourceSignalId: proof.signalId.trim().isEmpty
        ? _feedbackSignalIdForLabelV1(sourceSignalLabel)
        : proof.signalId.trim(),
    sourceSignalLabel: sourceSignalLabel,
    outcome: switch (quality) {
      Act0FeedbackQualityV1.correct => Act0SkillReceiptOutcomeV1.learned,
      Act0FeedbackQualityV1.wrong => Act0SkillReceiptOutcomeV1.repairStarted,
      Act0FeedbackQualityV1.suboptimal => Act0SkillReceiptOutcomeV1.needsRep,
    },
    nextRepId: spec.nextRepId,
    nextRepLabel: spec.nextRepLabel,
  );
}

Act0SkillReceiptV1? act0FirstValueSkillReceiptForRunnerV1({
  required Act0RunnerStateV1 runner,
  required Act0RunnerOptionV1 option,
  required Act0TaskFamilyV1? taskFamily,
}) {
  final proof = _feedbackSignalProofForRunnerV1(
    runner: runner.copyWith(selectedOptionId: option.id),
    option: option,
    taskFamily: taskFamily,
    hasSeatTargets: runner.options.any((option) => option.seatId != null),
  );
  return _skillReceiptForSignalProofV1(proof: proof, quality: option.quality);
}

({String skillAtomId, String skillLabel, String nextRepId, String nextRepLabel})
_skillReceiptSpecForSignalIdV1(String signalId) {
  return switch (signalId.trim()) {
    'hero_button' => (
      skillAtomId: 'table_position_read',
      skillLabel: 'Table position read',
      nextRepId: 'repeat_table_position_read',
      nextRepLabel: 'use the same position read once more',
    ),
    'hero_cards' => (
      skillAtomId: 'starting_hand_read',
      skillLabel: 'Starting hand read',
      nextRepId: 'repeat_starting_hand_read',
      nextRepLabel: 'use the same hand read once more',
    ),
    'board_cards' => (
      skillAtomId: 'board_read',
      skillLabel: 'Board read',
      nextRepId: 'repeat_board_read',
      nextRepLabel: 'use the same board read once more',
    ),
    'no_bet_yet' => (
      skillAtomId: 'action_read',
      skillLabel: 'Action read',
      nextRepId: 'repeat_action_read',
      nextRepLabel: 'use the same action read once more',
    ),
    'pot_to_call' => (
      skillAtomId: 'price_read',
      skillLabel: 'Price read',
      nextRepId: 'repeat_price_read',
      nextRepLabel: 'use the same price read once more',
    ),
    _ => (
      skillAtomId: 'table_read',
      skillLabel: 'Table read',
      nextRepId: 'repeat_table_read',
      nextRepLabel: 'use the same table read once more',
    ),
  };
}

Act0TableStateV1 _tableWithFeedbackSignalProofV1(
  Act0TableStateV1 table,
  Act0FeedbackSignalProofV1 proof,
) {
  return table.copyWith(
    highlightedSeatIds: _trimmedUniqueStringsV1(<String>[
      ...table.highlightedSeatIds,
      ...proof.seatIds,
    ]),
    highlightedCardIds: _trimmedUniqueStringsV1(<String>[
      ...table.highlightedCardIds,
      ...proof.cardIds,
    ]),
  );
}

Act0FeedbackSignalProofV1? _proofFromTableSignalsV1({
  required Act0TableStateV1 table,
  required List<String> seatIds,
  required List<String> cardIds,
  required List<String> repairLabels,
}) {
  final hasHeroCards = cardIds.any((id) => id.startsWith('hero_'));
  final hasBoardCards = cardIds.any((id) => id.startsWith('board_'));
  if (hasHeroCards && hasBoardCards && table.potLabel.trim().isNotEmpty) {
    return _feedbackSignalProofV1(
      signalId: 'hero_cards_board_pot',
      label: 'Hero cards + board + pot',
      seatIds: seatIds,
      cardIds: cardIds,
      statKeys: const <String>['pot'],
    );
  }
  if (seatIds.isNotEmpty) {
    return _proofFromSeatSignalV1(
      table,
      seatIds.first,
      extraSeatIds: seatIds.skip(1),
      cardIds: cardIds,
    );
  }
  if (hasHeroCards) {
    return _feedbackSignalProofV1(
      signalId: 'hero_cards',
      label: 'Hero cards',
      cardIds: cardIds,
    );
  }
  if (hasBoardCards) {
    return _feedbackSignalProofV1(
      signalId: 'board_cards',
      label: 'Board cards',
      cardIds: cardIds,
    );
  }
  final repairLabel = repairLabels.isEmpty
      ? ''
      : _feedbackSignalLabelFromRepairLabelV1(repairLabels.first);
  if (repairLabel.isEmpty) {
    return null;
  }
  return _feedbackSignalProofV1(
    signalId: _feedbackSignalIdForLabelV1(repairLabel),
    label: repairLabel,
  );
}

Act0FeedbackSignalProofV1? _proofFromSeatSignalV1(
  Act0TableStateV1 table,
  String seatId, {
  Iterable<String> extraSeatIds = const <String>[],
  List<String> cardIds = const <String>[],
}) {
  final cleanSeatId = seatId.trim();
  if (cleanSeatId.isEmpty) {
    return null;
  }
  final label = _feedbackSeatSignalLabelV1(table, cleanSeatId);
  if (label.isEmpty) {
    return null;
  }
  return _feedbackSignalProofV1(
    signalId: _feedbackSignalIdForLabelV1(label),
    label: label,
    seatIds: _trimmedUniqueStringsV1(<String>[cleanSeatId, ...extraSeatIds]),
    cardIds: cardIds,
  );
}

Act0FeedbackSignalProofV1 _feedbackSignalProofV1({
  required String signalId,
  required String label,
  List<String> seatIds = const <String>[],
  List<String> cardIds = const <String>[],
  List<String> statKeys = const <String>[],
}) {
  final cleanLabel = label.trim();
  return Act0FeedbackSignalProofV1(
    signalId: signalId.trim().isEmpty
        ? _feedbackSignalIdForLabelV1(cleanLabel)
        : signalId.trim(),
    label: cleanLabel,
    proofLine: 'Signal: $cleanLabel',
    seatIds: _trimmedUniqueStringsV1(seatIds),
    cardIds: _trimmedUniqueStringsV1(cardIds),
    statKeys: _trimmedUniqueStringsV1(statKeys),
  );
}

String _feedbackSeatSignalLabelV1(Act0TableStateV1 table, String seatId) {
  final seat = table.seats.cast<Act0SeatStateV1?>().firstWhere(
    (candidate) => candidate?.seatId == seatId,
    orElse: () => null,
  );
  if (seat == null) {
    return '';
  }
  if (seat.isHero && seat.isDealerButton) {
    return 'Hero on the Button';
  }
  if (seat.isHero) {
    return 'Hero seat';
  }
  if (seat.isDealerButton) {
    return 'Button';
  }
  if (seat.isSmallBlind) {
    return 'Small Blind';
  }
  if (seat.isBigBlind) {
    return 'Big Blind';
  }
  final displayName = seat.displayName.trim();
  if (displayName.isNotEmpty) {
    return displayName;
  }
  return seat.seatLabel.trim();
}

String _feedbackSignalLabelFromRepairLabelV1(String label) {
  final clean = _premiumSafeFeedbackOptionLabelV1(label.trim());
  final lower = clean.toLowerCase();
  if (lower == 'button' || lower == 'btn') {
    return 'Hero on the Button';
  }
  if (lower.contains('no bet')) {
    return 'No bet yet';
  }
  if (lower.contains('board')) {
    return 'Board cards';
  }
  if (lower.contains('pot') || lower.contains('to call')) {
    return 'Pot / to call';
  }
  return clean;
}

String _feedbackSignalIdForLabelV1(String label) {
  final lower = label.trim().toLowerCase();
  if (lower == 'hero on the button') {
    return 'hero_button';
  }
  if (lower == 'hero cards + board + pot') {
    return 'hero_cards_board_pot';
  }
  if (lower == 'pot / to call') {
    return 'pot_to_call';
  }
  if (lower == 'no bet yet') {
    return 'no_bet_yet';
  }
  if (lower == 'board cards') {
    return 'board_cards';
  }
  if (lower == 'hero cards') {
    return 'hero_cards';
  }
  final slug = lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return slug.isEmpty ? 'table_signal' : slug;
}

List<String> _trimmedUniqueStringsV1(Iterable<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    final clean = value.trim();
    if (clean.isEmpty || !seen.add(clean)) {
      continue;
    }
    result.add(clean);
  }
  return result;
}

class _RunnerProgressV1 extends StatelessWidget {
  const _RunnerProgressV1({required this.runner, required this.onBack});

  final Act0RunnerStateV1 runner;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: IconButton(
            key: const Key('act0_shell_runner_back'),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_rounded),
            color: Act0ShellTokensV1.text,
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapMd),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            child: LinearProgressIndicator(
              minHeight: Act0ShellTokensV1.progressHeight,
              value: runner.beatIndex / runner.beatCount,
              backgroundColor: Act0ShellTokensV1.surface3,
              color: Act0ShellTokensV1.primary,
            ),
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapMd),
        Text(
          'Step ${runner.beatIndex}/${runner.beatCount}',
          style: Act0ShellTokensV1.body.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SeatTapPromptV1 extends StatelessWidget {
  const _SeatTapPromptV1({
    required this.taskLabel,
    required this.question,
    required this.helperLine,
    required this.options,
    this.onBack,
    this.recallLabel,
    this.onRecall,
    this.fillsAvailableHeight = false,
  });

  final String taskLabel;
  final String question;
  final String helperLine;
  final List<Act0RunnerOptionV1> options;
  final VoidCallback? onBack;
  final String? recallLabel;
  final VoidCallback? onRecall;
  final bool fillsAvailableHeight;

  @override
  Widget build(BuildContext context) {
    final isFirstTableOrientation = question.trim().toLowerCase().contains(
      'you badge',
    );
    return Container(
      key: const Key('act0_shell_seat_tap_prompt'),
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: isFirstTableOrientation
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Act0ShellTokensV1.info.withValues(alpha: 0.16),
                  Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                  Act0ShellTokensV1.surface3.withValues(alpha: 0.94),
                ],
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.42),
              ),
            )
          : Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            _DockBackButtonV1(onPressed: onBack!),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: fillsAvailableHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                if (isFirstTableOrientation)
                  Column(
                    key: const Key('act0_shell_first_table_read_milestone'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        key: const Key('act0_shell_first_table_orientation'),
                        children: [
                          const Icon(
                            Icons.table_restaurant_rounded,
                            size: 14,
                            color: Act0ShellTokensV1.info,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'First table read',
                              key: const Key('act0_shell_seat_tap_task_label'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.info,
                                letterSpacing: 0,
                                fontSize: 10.4,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        key: const Key(
                          'act0_shell_wave1b_actionability_anchor',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: Act0ShellTokensV1.primary.withValues(
                              alpha: 0.26,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 12,
                              color: Act0ShellTokensV1.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Tap your seat',
                              key: const Key('act0_shell_wave1b_answer_peek'),
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.text,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    taskLabel,
                    key: const Key('act0_shell_seat_tap_task_label'),
                    maxLines: 2,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.info,
                      letterSpacing: 0.12,
                      fontSize: 9.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 5),
                if (question.isNotEmpty)
                  Text(
                    question,
                    key: const Key('act0_shell_action_question'),
                    maxLines: 3,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: 15.8,
                      height: 1.10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (fillsAvailableHeight)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _SeatTapPromptActionV1(
                        isFirstTableOrientation: isFirstTableOrientation,
                        helperLine: helperLine,
                        recallLabel: recallLabel,
                        onRecall: onRecall,
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 5),
                  _SeatTapPromptActionV1(
                    isFirstTableOrientation: isFirstTableOrientation,
                    helperLine: helperLine,
                    recallLabel: recallLabel,
                    onRecall: onRecall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatTapPromptActionV1 extends StatelessWidget {
  const _SeatTapPromptActionV1({
    required this.isFirstTableOrientation,
    required this.helperLine,
    required this.recallLabel,
    required this.onRecall,
  });

  final bool isFirstTableOrientation;
  final String helperLine;
  final String? recallLabel;
  final VoidCallback? onRecall;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFirstTableOrientation
              ? 'Use the table markers, then tap.'
              : helperLine,
          key: const Key('act0_shell_seat_tap_prompt_text'),
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: Act0ShellTokensV1.muted.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isFirstTableOrientation ? 10.6 : 12.2,
            height: 1.08,
          ),
        ),
        if (onRecall != null && recallLabel != null) ...[
          const SizedBox(height: 6),
          _TheoryRecallCtaV1(label: recallLabel!, onPressed: onRecall!),
        ],
      ],
    );
  }
}

class _CoachCardV1 extends StatelessWidget {
  const _CoachCardV1({
    required this.prompt,
    required this.hint,
    required this.focusLabels,
    this.compact = false,
    this.refined = false,
  });

  final String prompt;
  final String hint;
  final List<String> focusLabels;
  final bool compact;
  final bool refined;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 14 : (compact ? 11 : 12),
        vertical: refined ? 6 : (compact ? 8 : 10),
      ),
      decoration: refined
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Act0ShellTokensV1.surface.withValues(alpha: 0.82),
                  Act0ShellTokensV1.surface.withValues(alpha: 0.62),
                ],
              ),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : Act0ShellTokensV1.surfaceDecoration(
              color: Act0ShellTokensV1.surface2,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatInstructionCopyV1(prompt, allowSingleClauseSplit: true),
            key: const Key('act0_shell_runner_prompt'),
            textAlign: refined ? TextAlign.left : TextAlign.center,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            SingleChildScrollView(
              primary: false,
              physics: const ClampingScrollPhysics(),
              child: Text(
                _formatInstructionCopyV1(hint),
                textAlign: refined ? TextAlign.left : TextAlign.center,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: compact ? 11 : 13,
                  color: Act0ShellTokensV1.textDim,
                ),
              ),
            ),
          ],
          if (focusLabels.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Wrap(
              key: const Key('act0_shell_teaching_focus_labels'),
              alignment: refined ? WrapAlignment.start : WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final label in focusLabels)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.textMuted.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.textMuted.withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    return refined
        ? ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: card,
            ),
          )
        : card;
  }
}

String _formatInstructionCopyV1(
  String text, {
  bool allowSingleClauseSplit = false,
}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return normalized;
  }

  final sentences = normalized
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList();

  if (sentences.length >= 3) {
    final midpoint = (sentences.length / 2).ceil();
    return <String>[
      sentences.take(midpoint).join(' '),
      sentences.skip(midpoint).join(' '),
    ].join('\n');
  }

  if (sentences.length == 2) {
    if (normalized.length < 72) {
      return normalized;
    }
    return sentences.join('\n');
  }

  if (!allowSingleClauseSplit || normalized.length < 72) {
    return normalized;
  }

  final breakpoints = <String>[' — ', ': ', '; ', ', '];
  final middle = normalized.length ~/ 2;

  int? bestIndex;
  int bestDistance = normalized.length;
  for (final marker in breakpoints) {
    var start = 0;
    while (true) {
      final index = normalized.indexOf(marker, start);
      if (index == -1) {
        break;
      }
      final candidate = index + marker.length;
      final distance = (candidate - middle).abs();
      if (candidate > 24 && candidate < normalized.length - 18) {
        if (distance < bestDistance) {
          bestDistance = distance;
          bestIndex = candidate;
        }
      }
      start = index + marker.length;
    }
  }

  if (bestIndex == null) {
    return normalized;
  }

  final first = normalized.substring(0, bestIndex).trimRight();
  final second = normalized.substring(bestIndex).trimLeft();
  return '$first\n$second';
}

class Act0FeedbackShellV1 extends StatelessWidget {
  const Act0FeedbackShellV1({
    super.key,
    required this.title,
    required this.reason,
    this.nextClueLine = '',
    required this.quality,
    required this.sharkyLine,
    required this.sharkyMood,
    required this.selectedLabel,
    required this.preferredLabel,
    required this.betterLabel,
    this.taskFamily,
    this.hasSeatTargets = false,
    this.potLabel = '',
    this.showPotSweep = false,
    this.signalProof,
    this.contextLabels = const <String>[],
    this.refined = false,
    this.completionSummary,
    this.firstValueReceiptLine,
    this.repairReasonLine,
    this.repairResultReceiptLine,
    this.repairOutcomeProofLine,
    this.forceShowRepairOutcomeProof = false,
    this.repairContinuesToSourceRecheck = false,
    this.isSourceRecheckAttempt = false,
    this.repairSessionSummaryLines = const <String>[],
    this.forwardCtaLabel,
    this.suppressRepairFocus = false,
    this.onBack,
    this.rapidMode = false,
    this.streamlinedDirectDecisionFeedback = false,
    this.cycleStableEnvelope = false,
    this.forceCompactPhoneFeedback = false,
    this.ensureFullCtaGeometry = false,
    this.coachVoiceSeed,
    required this.onContinue,
  });

  final String title;
  final String reason;
  final String nextClueLine;
  final Act0FeedbackQualityV1 quality;
  final String sharkyLine;
  final Act0SharkyMoodV1 sharkyMood;
  final String selectedLabel;
  final String preferredLabel;
  final String betterLabel;
  final Act0TaskFamilyV1? taskFamily;
  final bool hasSeatTargets;
  final String potLabel;
  final bool showPotSweep;
  final Act0FeedbackSignalProofV1? signalProof;
  final List<String> contextLabels;
  final bool refined;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? firstValueReceiptLine;
  final String? repairReasonLine;
  final String? repairResultReceiptLine;
  final String? repairOutcomeProofLine;
  final bool forceShowRepairOutcomeProof;
  final bool repairContinuesToSourceRecheck;
  final bool isSourceRecheckAttempt;
  final List<String> repairSessionSummaryLines;
  final String? forwardCtaLabel;
  final bool suppressRepairFocus;
  final VoidCallback? onBack;
  final bool rapidMode;
  final bool streamlinedDirectDecisionFeedback;
  final bool cycleStableEnvelope;
  final bool forceCompactPhoneFeedback;
  final bool ensureFullCtaGeometry;
  final String? coachVoiceSeed;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isWrong = quality == Act0FeedbackQualityV1.wrong;
    final isSuboptimal = quality == Act0FeedbackQualityV1.suboptimal;
    final isRepairFocusState =
        !rapidMode &&
        !suppressRepairFocus &&
        (repairReasonLine?.trim().isNotEmpty ?? false);
    final repairReceiptLine = repairResultReceiptLine?.trim() ?? '';
    final repairOutcomeProofLine = this.repairOutcomeProofLine?.trim() ?? '';
    final hasRepairOutcomeProof = repairOutcomeProofLine.isNotEmpty;
    // Repair success remains partial. Only the explicit source-recheck
    // projection can make the stronger recovery claim.
    final isRecoveredSourceRecheck =
        hasRepairOutcomeProof && forceShowRepairOutcomeProof;
    final isFailedSourceRecheck = isWrong && isSourceRecheckAttempt;
    final hasProofEarnedState =
        hasRepairOutcomeProof ||
        repairReceiptLine.toLowerCase().startsWith('repair fixed:') ||
        repairReceiptLine.toLowerCase().startsWith('replay fixed:') ||
        repairReceiptLine.toLowerCase().startsWith('fix landed:');
    final reservesFullCtaGeometry =
        ensureFullCtaGeometry && hasProofEarnedState;
    final media = MediaQuery.of(context);
    final view = View.of(context);
    final fullViewportHeight = view.physicalSize.height / view.devicePixelRatio;
    final safeVertical = media.viewPadding.vertical > 0
        ? media.viewPadding.vertical
        : media.padding.vertical;
    final usableHeight = media.size.height - safeVertical;
    final isCompactRefinedFeedback =
        !rapidMode &&
        (forceCompactPhoneFeedback ||
            (refined &&
                (usableHeight <= 900 ||
                    (fullViewportHeight > 900 && fullViewportHeight <= 980))) ||
            (!refined &&
                fullViewportHeight > 900 &&
                fullViewportHeight <= 980));
    const missedCueTone = Color(0xFF90A4C7);
    final tone = hasProofEarnedState
        ? Act0ShellTokensV1.gold
        : isRepairFocusState
        ? Act0ShellTokensV1.gold
        : isWrong
        ? missedCueTone
        : isSuboptimal
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final icon = hasProofEarnedState
        ? Icons.verified_rounded
        : isWrong
        ? Icons.search_off_rounded
        : isSuboptimal
        ? Icons.trending_up_rounded
        : Icons.check_rounded;
    final iconKey = hasProofEarnedState
        ? const Key('act0_shell_feedback_icon_proof_earned')
        : isWrong
        ? const Key('act0_shell_feedback_icon_wrong')
        : (isSuboptimal
              ? const Key('act0_shell_feedback_icon_suboptimal')
              : const Key('act0_shell_feedback_icon_correct'));
    final sharkyTone = hasProofEarnedState
        ? Act0ShellTokensV1.gold
        : isWrong
        ? missedCueTone
        : isSuboptimal
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final resolvedTitle = _feedbackTitleFloorV1(
      context,
      title: title,
      quality: quality,
      contextLabels: contextLabels,
    );
    final resolvedSharkyLine =
        _premiumSafeFeedbackTitleV1(sharkyLine.trim()) ?? sharkyLine;
    final reactionLine = act0RuntimeFeedbackCoachLineV1(
      context,
      authoredLine: resolvedSharkyLine,
      title: resolvedTitle,
      quality: quality,
      variationSeed:
          coachVoiceSeed ??
          '${quality.name}|${resolvedTitle.trim().toLowerCase()}|${resolvedSharkyLine.trim().toLowerCase()}',
      taskFamily: taskFamily,
    );
    final primaryResultLabel = _feedbackPrimaryResultLabelV1(
      quality: quality,
      repairReceiptLine: repairResultReceiptLine,
    );
    final stateLabel = isRecoveredSourceRecheck
        ? 'Original read proven'
        : isFailedSourceRecheck
        ? 'Original read needs one more rep'
        : isRepairFocusState
        ? 'Practice the clue'
        : primaryResultLabel;
    final stateDetail = isFailedSourceRecheck
        ? 'This was the original hand. Review the clue before the next practice.'
        : isRepairFocusState
        ? 'This practice hand keeps the missed clue in view.'
        : isWrong
        ? 'Start with the table clue, then choose the action.'
        : '';
    // Sharky coaches a miss and acknowledges proven recovery only. Ordinary
    // correct and repair feedback keep the learning scene calm.
    final showSharkyCompanion =
        isRecoveredSourceRecheck || (!isCompactRefinedFeedback && isWrong);
    final showVerdictTitle = resolvedTitle.isNotEmpty;
    final actionPrefix = act0RuntimeFeedbackActionPrefixV1(
      context,
      quality,
      taskFamily: taskFamily,
      hasSeatTargets: hasSeatTargets,
    );
    final fullActionLabel = _premiumSafeFeedbackOptionLabelV1(
      act0RuntimeLocalizedOptionLabelV1(
        context,
        isWrong ? betterLabel : preferredLabel,
      ),
    );
    final actionLabel = isCompactRefinedFeedback
        ? _compactFeedbackActionLabelV1(fullActionLabel)
        : fullActionLabel;
    final localizedContextLabels = [
      for (final label in (refined ? contextLabels.take(1) : contextLabels))
        _premiumSafeFeedbackOptionLabelV1(
          act0RuntimeLocalizedContextLabelV1(context, label),
        ).trim(),
    ];
    final visibleContextLabels = _dedupedFeedbackContextLabelsV1(
      localizedContextLabels,
      preferredLine: actionLabel,
      selectedLine: isWrong || isSuboptimal ? selectedLabel : '',
      statusLine: showVerdictTitle
          ? act0RuntimeLocalizedGeneralLabelV1(context, resolvedTitle).trim()
          : '',
      signalLabel: signalProof?.label ?? '',
      proofLine: signalProof?.proofLine ?? '',
    );
    final resolvedReason = _feedbackReasonFloorV1(
      context,
      reason: reason,
      quality: quality,
      selectedLabel: selectedLabel,
      preferredLabel: preferredLabel,
      betterLabel: betterLabel,
      contextLabels: contextLabels,
    );
    final preserveFullCompactReason =
        isCompactRefinedFeedback &&
        _shouldPreserveFullCompactFeedbackReasonV1(resolvedReason);
    final skillReceipt = firstValueReceiptLine == null
        ? null
        : _skillReceiptForSignalProofV1(proof: signalProof, quality: quality);
    final repairReason = repairReasonLine?.trim() ?? '';
    final visibleRepairReasonLines = suppressRepairFocus
        ? const <String>[]
        : _visibleRepairReasonLinesV1(
            quality: quality,
            signalProof: signalProof,
            repairReasonLine: repairReason,
            repairReceiptLine: repairReceiptLine,
          );
    final visibleRepairSessionSummaryLines = [
      for (final line in repairSessionSummaryLines)
        if (line.trim().isNotEmpty) line.trim(),
    ];
    final fallbackReceiptLine = repairReceiptLine.isNotEmpty
        ? repairReceiptLine
        : firstValueReceiptLine?.trim();
    final receiptSplitIndex = fallbackReceiptLine?.indexOf('. Next:') ?? -1;
    final receiptTitle = isRecoveredSourceRecheck
        ? ''
        : hasRepairOutcomeProof
        ? 'Repair landed'
        : repairReceiptLine.isNotEmpty
        ? 'Repair result'
        : skillReceipt?.title ??
              (fallbackReceiptLine == null || fallbackReceiptLine.isEmpty
                  ? ''
                  : receiptSplitIndex < 0
                  ? fallbackReceiptLine
                  : fallbackReceiptLine.substring(0, receiptSplitIndex + 1));
    final receiptDetail = hasRepairOutcomeProof
        ? repairOutcomeProofLine
        : repairReceiptLine.isNotEmpty
        ? repairReceiptLine
        : skillReceipt?.detail ??
              (fallbackReceiptLine == null ||
                      fallbackReceiptLine.isEmpty ||
                      receiptSplitIndex < 0
                  ? ''
                  : fallbackReceiptLine
                        .substring(receiptSplitIndex + 2)
                        .trim());
    final isFocusedCompactProofFeedback =
        isCompactRefinedFeedback && hasProofEarnedState;
    final shouldShowReceiptProof =
        !rapidMode &&
        (!isFocusedCompactProofFeedback || forceShowRepairOutcomeProof) &&
        (receiptTitle.isNotEmpty ||
            (isRecoveredSourceRecheck && receiptDetail.isNotEmpty)) &&
        (!isWrong || hasRepairOutcomeProof);
    final receiptNextLine = skillReceipt == null
        ? ''
        : switch (skillReceipt.outcome) {
            Act0SkillReceiptOutcomeV1.learned =>
              'Next: practice the same table clue once more.',
            Act0SkillReceiptOutcomeV1.repairStarted =>
              'Next: try this table clue once more.',
            Act0SkillReceiptOutcomeV1.needsRep =>
              'Next: practice the same table clue once more.',
          };
    final selectedContrastLine =
        !isCompactRefinedFeedback &&
            (isWrong || isSuboptimal) &&
            selectedLabel.isNotEmpty
        ? _feedbackSelectedLineV1(context, selectedLabel)
        : '';
    final hasRepairTeachingBlock =
        isWrong && visibleRepairReasonLines.isNotEmpty;
    final showSignalProofInProofStack =
        !rapidMode && !hasRepairTeachingBlock && signalProof != null;
    final showActionContrast = actionLabel.isNotEmpty;
    final usesSharedAccessibilitySurface =
        (streamlinedDirectDecisionFeedback || cycleStableEnvelope) &&
        isCompactRefinedFeedback;
    final pinsAllocatedFeedbackCta =
        usesSharedAccessibilitySurface && ensureFullCtaGeometry && !rapidMode;
    final pinsF1FeedbackCta =
        usesSharedAccessibilitySurface &&
        hasSeatTargets &&
        !hasRepairTeachingBlock;
    final isExactReplayRepair =
        repairResultReceiptLine?.trim().toLowerCase().startsWith('replay ') ==
            true ||
        repairResultReceiptLine?.trim() ==
            'Fix landed: you handled this spot correctly.' ||
        repairResultReceiptLine?.trim() ==
            'This spot still needs one more careful rep.';
    Widget buildContinueAction() {
      return Row(
        children: [
          if (onBack != null) ...[
            _DockBackButtonV1(
              key: const Key('act0_shell_interaction_back_cta'),
              onPressed: onBack!,
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: FilledButton(
              key: const Key('act0_shell_feedback_continue_cta'),
              onPressed: onContinue,
              style: Act0ShellTokensV1.premiumActionButtonStyle(
                height: usesSharedAccessibilitySurface
                    ? 48
                    : isCompactRefinedFeedback
                    ? 44
                    : Act0ShellTokensV1.compactCtaHeight,
              ),
              child: Text(
                key: const Key('act0_shell_feedback_continue_cta_label'),
                forwardCtaLabel ??
                    (isRecoveredSourceRecheck
                        ? 'Continue'
                        : isWrong && isSourceRecheckAttempt
                        ? 'Continue to Review'
                        : repairReceiptLine.isNotEmpty && !isWrong
                        ? repairContinuesToSourceRecheck
                              ? 'Check original read'
                              : 'Continue to Review'
                        : isWrong || isRepairFocusState
                        ? isExactReplayRepair
                              ? 'Try this spot again'
                              : 'Try same clue'
                        : 'Next hand'),
              ),
            ),
          ),
        ],
      );
    }

    final showReason = !rapidMode && !hasRepairTeachingBlock;
    final foldsNextClueIntoExplanation =
        pinsF1FeedbackCta &&
        showReason &&
        cycleStableEnvelope &&
        nextClueLine.trim().isNotEmpty;
    final showRepairFocus = !rapidMode && visibleRepairReasonLines.isNotEmpty;
    final showProofStack =
        !rapidMode &&
        (showSignalProofInProofStack ||
            showActionContrast ||
            showReason ||
            showRepairFocus);
    // Keep the outer cycle envelope stable, but center the complete semantic
    // outcome only when it has no repair, proof-earned, receipt, completion,
    // or long-copy obligation. These are state flags rather than copy heuristics.
    final usesCohesiveShortOutcome =
        usesSharedAccessibilitySurface &&
        !isWrong &&
        !isSuboptimal &&
        !hasRepairTeachingBlock &&
        !hasProofEarnedState &&
        !isRecoveredSourceRecheck &&
        !isSourceRecheckAttempt &&
        repairReceiptLine.isEmpty &&
        !shouldShowReceiptProof &&
        visibleRepairSessionSummaryLines.isEmpty &&
        completionSummary == null;
    final showActionContrastEyebrow =
        !(streamlinedDirectDecisionFeedback && isCompactRefinedFeedback) &&
        !usesCohesiveShortOutcome;
    final feedbackStateKey = hasProofEarnedState
        ? const Key('act0_shell_wave2_feedback_proof_earned_state')
        : isRepairFocusState
        ? const Key('act0_shell_wave2_feedback_repair_state')
        : isWrong
        ? const Key('act0_shell_wave2_feedback_miss_state')
        : const Key('act0_shell_wave2_feedback_correct_state');
    final feedbackTreatmentKey = isWrong
        ? const Key('act0_shell_feedback_missed_cue_treatment')
        : const Key('act0_shell_feedback_non_miss_treatment');
    final feedbackSharkySlotKey = hasProofEarnedState
        ? const Key('act0_shell_feedback_sharky_slot_proof_earned')
        : isRepairFocusState || isSuboptimal
        ? const Key('act0_shell_feedback_sharky_slot_repair')
        : isWrong
        ? const Key('act0_shell_feedback_sharky_slot_wrong')
        : const Key('act0_shell_feedback_sharky_slot_proof');
    final companionRoleLabel = hasProofEarnedState
        ? isRecoveredSourceRecheck
              ? 'Original read proven'
              : 'Repair landed'
        : isRepairFocusState
        ? 'Repair focus'
        : isSuboptimal
        ? 'Better read'
        : isWrong
        ? 'Missed cue'
        : 'Correct read';
    return _ProofMotionRevealV1(
      key: const Key('act0_shell_feedback_card_motion_reveal'),
      child: KeyedSubtree(
        key: feedbackStateKey,
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            key: const Key('act0_shell_feedback_card'),
            constraints: usesSharedAccessibilitySurface
                ? BoxConstraints.tightFor(height: constraints.maxHeight)
                : null,
            padding: usesSharedAccessibilitySurface
                ? EdgeInsets.fromLTRB(
                    5,
                    pinsF1FeedbackCta || reservesFullCtaGeometry
                        ? 0
                        : Act0ShellTokensV1.gapMd,
                    5,
                    // The runner is already inside the route-level SafeArea.
                    // Reserving viewPadding again clips the compact feedback
                    // CTA at enlarged text.
                    4,
                  )
                : EdgeInsets.all(
                    rapidMode
                        ? 8
                        : (isCompactRefinedFeedback ? 5 : (refined ? 8 : 10)),
                  ),
            // Feedback states share the runner's single lower-stage surface.
            // Accent belongs to the outcome, not to a state-specific card.
            decoration: usesSharedAccessibilitySurface
                ? null
                : BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                  ),
            child: Builder(
              builder: (context) {
                final feedbackBody = Column(
              key: usesCohesiveShortOutcome
                  ? const Key('act0_shell_feedback_cohesive_group')
                  : null,
              mainAxisSize: pinsAllocatedFeedbackCta
                  ? MainAxisSize.min
                  : usesCohesiveShortOutcome
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: pinsAllocatedFeedbackCta
                  ? MainAxisAlignment.start
                  : usesCohesiveShortOutcome
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSharkyCompanion) ...[
                      Act0SharkyMascotV1(
                        key: feedbackSharkySlotKey,
                        mood: sharkyMood,
                        tone: sharkyTone,
                        size: isCompactRefinedFeedback
                            ? 30
                            : (refined ? 46 : 50),
                      ),
                      const SizedBox(width: 8),
                    ] else if (!isCompactRefinedFeedback) ...[
                      Container(
                        key: const Key('act0_shell_feedback_state_mark'),
                        width: refined ? 42 : 46,
                        height: refined ? 42 : 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tone.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Icon(icon, color: tone, size: refined ? 21 : 23),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!rapidMode && stateLabel.isNotEmpty) ...[
                            KeyedSubtree(
                              key: const Key(
                                'act0_shell_feedback_primary_result_block',
                              ),
                              child: KeyedSubtree(
                                key: const Key(
                                  'act0_shell_feedback_primary_result_label',
                                ),
                                child: Text(
                                  stateLabel,
                                  key: const Key(
                                    'act0_shell_feedback_rhythm_verdict',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: Act0ShellTokensV1.label.copyWith(
                                    color: tone,
                                    fontSize: 13.5,
                                    height: 1.04,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                          ],
                          if (!isCompactRefinedFeedback &&
                              (stateDetail.isNotEmpty ||
                                  (showSharkyCompanion &&
                                      reactionLine.isNotEmpty)))
                            KeyedSubtree(
                              key: const Key(
                                'act0_shell_feedback_companion_role',
                              ),
                              child: Text(
                                stateDetail.isNotEmpty
                                    ? stateDetail
                                    : '$companionRoleLabel · $reactionLine',
                                key: const Key(
                                  'act0_shell_sharky_outcome_reaction',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: Act0ShellTokensV1.muted.copyWith(
                                  color: Act0ShellTokensV1.textMuted,
                                  fontSize: refined ? 10.0 : 10.5,
                                  height: 1.06,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (rapidMode && actionLabel.isNotEmpty) ...[
                  Text(
                    '$actionPrefix: $actionLabel',
                    key: const Key('act0_shell_feedback_hero_action'),
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: 15,
                      height: 1.06,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 0),
                ],
                if (!rapidMode && !isCompactRefinedFeedback) ...[
                  SizedBox(height: isCompactRefinedFeedback ? 4 : 6),
                  _FeedbackStateRailV1(
                    tone: tone,
                    compact: isCompactRefinedFeedback,
                  ),
                ],
                if (showProofStack) ...[
                  SizedBox(height: isCompactRefinedFeedback ? 4 : 8),
                  Builder(
                    builder: (context) {
                      final proofStack = Column(
                        key: const Key('act0_shell_feedback_proof_stack'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showActionContrast) ...[
                            _FeedbackActionContrastBlockV1(
                              actionLine: '$actionPrefix: $actionLabel',
                              selectedLine: selectedContrastLine,
                              tone: tone,
                              compact: isCompactRefinedFeedback,
                              refined: refined,
                              showEyebrow: showActionContrastEyebrow,
                            ),
                            SizedBox(height: isCompactRefinedFeedback ? 7 : 10),
                          ],
                          if (showSignalProofInProofStack) ...[
                            _FeedbackSignalProofRowV1(
                              proofLine: signalProof!.proofLine,
                              tone: tone,
                              compact: isCompactRefinedFeedback,
                            ),
                            SizedBox(height: isCompactRefinedFeedback ? 2 : 3),
                          ],
                          if (showReason)
                            cycleStableEnvelope &&
                                    !usesSharedAccessibilitySurface
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: pinsF1FeedbackCta
                                          ? 20
                                          : isCompactRefinedFeedback
                                          ? 34
                                          : 60,
                                    ),
                                    child: SingleChildScrollView(
                                      key: const Key(
                                        'act0_shell_feedback_explanation_scroll',
                                      ),
                                      primary: false,
                                      physics: const ClampingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            resolvedReason,
                                            key: const Key(
                                              'act0_shell_feedback_reason',
                                            ),
                                            style: Act0ShellTokensV1.body
                                                .copyWith(
                                                  color: Act0ShellTokensV1
                                                      .textMuted,
                                                  fontSize:
                                                      isCompactRefinedFeedback
                                                      ? 11.4
                                                      : (refined ? 12.0 : 12.5),
                                                  height:
                                                      isCompactRefinedFeedback
                                                      ? 1.08
                                                      : 1.16,
                                                ),
                                          ),
                                          if (foldsNextClueIntoExplanation) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              nextClueLine.trim(),
                                              key: const Key(
                                                'act0_shell_feedback_next_clue',
                                              ),
                                              style: Act0ShellTokensV1.label
                                                  .copyWith(
                                                    color: tone.withValues(
                                                      alpha: 0.9,
                                                    ),
                                                    fontSize: 10.5,
                                                    height: 1.1,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                : Text(
                                    resolvedReason,
                                    key: const Key(
                                      'act0_shell_feedback_reason',
                                    ),
                                    maxLines:
                                        isCompactRefinedFeedback &&
                                            !usesSharedAccessibilitySurface &&
                                            !preserveFullCompactReason
                                        ? 2
                                        : null,
                                    overflow:
                                        isCompactRefinedFeedback &&
                                            !usesSharedAccessibilitySurface &&
                                            !preserveFullCompactReason
                                        ? TextOverflow.fade
                                        : null,
                                    style: Act0ShellTokensV1.body.copyWith(
                                      color: Act0ShellTokensV1.textMuted,
                                      fontSize: isCompactRefinedFeedback
                                          ? 11.4
                                          : (refined ? 12.0 : 12.5),
                                      height: isCompactRefinedFeedback
                                          ? 1.08
                                          : 1.16,
                                    ),
                                  ),
                          if (!rapidMode &&
                              nextClueLine.trim().isNotEmpty &&
                              !foldsNextClueIntoExplanation) ...[
                            SizedBox(height: isCompactRefinedFeedback ? 3 : 6),
                            Text(
                              nextClueLine.trim(),
                              key: const Key('act0_shell_feedback_next_clue'),
                              maxLines:
                                  isCompactRefinedFeedback &&
                                      !usesSharedAccessibilitySurface
                                  ? 2
                                  : null,
                              overflow:
                                  isCompactRefinedFeedback &&
                                      !usesSharedAccessibilitySurface
                                  ? TextOverflow.fade
                                  : null,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: tone.withValues(alpha: 0.9),
                                fontSize: isCompactRefinedFeedback
                                    ? 10.5
                                    : 11.0,
                                height: 1.1,
                              ),
                            ),
                          ],
                          if (showRepairFocus) ...[
                            SizedBox(height: isCompactRefinedFeedback ? 6 : 10),
                            const _FeedbackVerdictDividerV1(),
                            SizedBox(height: isCompactRefinedFeedback ? 6 : 8),
                            _FeedbackVisibleRepairReasonBlockV1(
                              lines: visibleRepairReasonLines,
                              compact: isCompactRefinedFeedback,
                            ),
                          ],
                        ],
                      );
                      if (!usesSharedAccessibilitySurface ||
                          (usesCohesiveShortOutcome &&
                              !preserveFullCompactReason)) {
                        return proofStack;
                      }
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 64),
                        child: SingleChildScrollView(
                          key: const Key(
                            'act0_shell_feedback_proof_stack_scroll',
                          ),
                          primary: false,
                          physics: const ClampingScrollPhysics(),
                          child: proofStack,
                        ),
                      );
                    },
                  ),
                ],
                if (!rapidMode &&
                    showVerdictTitle &&
                    !isCompactRefinedFeedback) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(icon, key: iconKey, color: tone, size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          act0RuntimeLocalizedGeneralLabelV1(
                            context,
                            resolvedTitle,
                          ),
                          key: const Key('act0_shell_feedback_status_label'),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.muted.copyWith(
                            color: tone.withValues(alpha: 0.92),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!rapidMode && showPotSweep && potLabel.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  _PotSweepMomentV1(potLabel: potLabel),
                ],
                if (!rapidMode &&
                    !isCompactRefinedFeedback &&
                    visibleContextLabels.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    key: const Key('act0_shell_feedback_context_labels'),
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      for (final label in visibleContextLabels)
                        _DockStatusPillV1(
                          label: label,
                          icon: Icons.check_rounded,
                          tone: tone,
                        ),
                    ],
                  ),
                ],
                if (shouldShowReceiptProof) ...[
                  const SizedBox(height: 8),
                  const _FeedbackVerdictDividerV1(),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final receiptProof = KeyedSubtree(
                        key: const Key('act0_shell_repair_result_system_card'),
                        child: _FeedbackProofKeyWrapperV1(
                          proofKey: repairReceiptLine.isNotEmpty
                              ? const Key(
                                  'act0_shell_repair_receipt_proof_block',
                                )
                              : hasRepairOutcomeProof
                              ? const Key('act0_shell_repair_outcome_proof')
                              : null,
                          child: KeyedSubtree(
                            key: repairReceiptLine.isNotEmpty
                                ? const Key('act0_shell_repair_result_receipt')
                                : hasRepairOutcomeProof
                                ? const Key(
                                    'act0_shell_repair_outcome_proof_card',
                                  )
                                : const Key('act0_shell_first_value_receipt'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (receiptTitle.isNotEmpty)
                                  Text(
                                    receiptTitle,
                                    key: repairReceiptLine.isNotEmpty
                                        ? const Key(
                                            'act0_shell_repair_result_receipt_title',
                                          )
                                        : hasRepairOutcomeProof
                                        ? const Key(
                                            'act0_shell_repair_outcome_proof_title',
                                          )
                                        : null,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: Act0ShellTokensV1.primary,
                                      fontSize: isCompactRefinedFeedback
                                          ? 10.0
                                          : 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                if (receiptDetail.isNotEmpty) ...[
                                  if (receiptTitle.isNotEmpty)
                                    const SizedBox(height: 4),
                                  Text(
                                    receiptDetail,
                                    key: repairReceiptLine.isNotEmpty
                                        ? const Key(
                                            'act0_shell_repair_result_outcome_line',
                                          )
                                        : hasRepairOutcomeProof
                                        ? const Key(
                                            'act0_shell_repair_outcome_proof_line',
                                          )
                                        : null,
                                    style: Act0ShellTokensV1.body.copyWith(
                                      color: Act0ShellTokensV1.text,
                                      fontSize: isCompactRefinedFeedback
                                          ? 13.0
                                          : 15.0,
                                      height: 1.12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                                if (receiptNextLine.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    receiptNextLine,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: Act0ShellTokensV1.textMuted,
                                      fontSize: isCompactRefinedFeedback
                                          ? 10.0
                                          : 10.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                      if (!usesSharedAccessibilitySurface) return receiptProof;
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 44),
                        child: SingleChildScrollView(
                          key: const Key('act0_shell_feedback_receipt_scroll'),
                          primary: false,
                          physics: const ClampingScrollPhysics(),
                          child: receiptProof,
                        ),
                      );
                    },
                  ),
                ],
                if (!rapidMode &&
                    !isFocusedCompactProofFeedback &&
                    visibleRepairSessionSummaryLines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const _FeedbackVerdictDividerV1(),
                  const SizedBox(height: 8),
                  _RepairSystemProofBlockV1(
                    cardKey: const Key('act0_shell_repair_closure_system_card'),
                    tone: Act0ShellTokensV1.gold,
                    showLabel: false,
                    child: _FeedbackProofKeyWrapperV1(
                      proofKey: const Key(
                        'act0_shell_session_summary_proof_block',
                      ),
                      child: _FeedbackSessionSummaryCeremonyBlockV1(
                        lines: visibleRepairSessionSummaryLines,
                      ),
                    ),
                  ),
                ],
                if (!rapidMode && completionSummary != null) ...[
                  const SizedBox(height: 8),
                  _CompletionToastV1(summary: completionSummary!),
                ],
                if (rapidMode) ...[
                  SizedBox(key: feedbackTreatmentKey, height: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Next spot...',
                    key: const Key('act0_shell_feedback_auto_advance_label'),
                    textAlign: TextAlign.center,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: tone,
                      letterSpacing: 0.2,
                    ),
                  ),
                ] else ...[
                  SizedBox(key: feedbackTreatmentKey, height: 0),
                  if (pinsAllocatedFeedbackCta)
                    const SizedBox.shrink()
                  else if (pinsF1FeedbackCta)
                    SizedBox(height: 48, child: buildContinueAction())
                  else if (usesCohesiveShortOutcome) ...[
                    const SizedBox(height: 16),
                    buildContinueAction(),
                  ] else if (usesSharedAccessibilitySurface &&
                      reservesFullCtaGeometry) ...[
                    SizedBox(height: 48, child: buildContinueAction()),
                  ] else if (usesSharedAccessibilitySurface)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: Act0ShellTokensV1.gapSm,
                          ),
                          child: buildContinueAction(),
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(height: isCompactRefinedFeedback ? 4 : 10),
                    buildContinueAction(),
                  ],
                ],
              ],
                );
                if (!pinsAllocatedFeedbackCta) return feedbackBody;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        key: const Key(
                          'act0_shell_feedback_allocated_body_scroll',
                        ),
                        primary: false,
                        physics: const ClampingScrollPhysics(),
                        child: feedbackBody,
                      ),
                    ),
                    SizedBox(height: 48, child: buildContinueAction()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String _compactFeedbackActionLabelV1(String label) => switch (label.trim()) {
  'The visible king leaves fewer king-containing combinations.' =>
    'Fewer king-containing hands remain.',
  'Fewer seven-containing hands remain, but trips are still possible.' =>
    'Fewer seven hands remain; trips are still possible.',
  'Fewer queen-containing combinations remain; no exact hand is proved.' =>
    'Fewer queen hands remain; exact hand unknown.',
  _ => label,
};

class _FeedbackVerdictDividerV1 extends StatelessWidget {
  const _FeedbackVerdictDividerV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Act0ShellTokensV1.border.withValues(alpha: 0.72),
    );
  }
}

class _FeedbackActionContrastBlockV1 extends StatelessWidget {
  const _FeedbackActionContrastBlockV1({
    required this.actionLine,
    required this.selectedLine,
    required this.tone,
    required this.compact,
    required this.refined,
    required this.showEyebrow,
  });

  final String actionLine;
  final String selectedLine;
  final Color tone;
  final bool compact;
  final bool refined;
  final bool showEyebrow;

  @override
  Widget build(BuildContext context) {
    final separator = actionLine.indexOf(':');
    final eyebrow = separator < 0
        ? ''
        : actionLine.substring(0, separator).trim();
    final heroAction = separator < 0
        ? actionLine
        : actionLine.substring(separator + 1).trim();
    return KeyedSubtree(
      key: const Key('act0_shell_feedback_action_contrast_block'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEyebrow && eyebrow.isNotEmpty) ...[
            Text(
              key: const Key('act0_shell_feedback_action_eyebrow'),
              eyebrow,
              style: Act0ShellTokensV1.label.copyWith(
                color: tone,
                fontSize: compact ? 10.0 : 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            heroAction,
            key: const Key('act0_shell_feedback_hero_action'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: compact ? 20.0 : (refined ? 22.0 : 23.0),
              height: 1.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (selectedLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              selectedLine,
              key: const Key('act0_shell_feedback_selected_label'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: refined ? 11.5 : 12.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackStateRailV1 extends StatelessWidget {
  const _FeedbackStateRailV1({required this.tone, required this.compact});

  final Color tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_wave2_feedback_state_rail'),
      height: compact ? 3 : 4,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
      ),
    );
  }
}

class _FeedbackVisibleRepairReasonBlockV1 extends StatelessWidget {
  const _FeedbackVisibleRepairReasonBlockV1({
    required this.lines,
    required this.compact,
  });

  final List<String> lines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      key: const Key('act0_shell_visible_repair_reason'),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repair focus',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              fontSize: compact ? 10.5 : 11.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 3 : 5),
          Text(
            _compactRepairFocusCopyV1(lines),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: compact ? 10.2 : 11.0,
              fontWeight: FontWeight.w700,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

String _compactRepairFocusCopyV1(List<String> lines) {
  final explanation = lines.length > 1
      ? lines[1].replaceFirst(
          RegExp(r'^You missed [^.]+\.\s*', caseSensitive: false),
          '',
        )
      : '';
  return <String>[
    explanation.trim(),
    if (lines.length > 2) lines[2].trim(),
  ].where((line) => line.isNotEmpty).join(' ');
}

bool _shouldPreserveFullCompactFeedbackReasonV1(String reason) {
  final normalized = reason.trim();
  if (normalized.length < 96 || normalized.length > 180) {
    return false;
  }
  final sentenceCount = RegExp(r'[.!?](?:\s|$)').allMatches(normalized).length;
  return sentenceCount >= 2;
}

List<String> _visibleRepairReasonLinesV1({
  required Act0FeedbackQualityV1 quality,
  required Act0FeedbackSignalProofV1? signalProof,
  required String repairReasonLine,
  required String repairReceiptLine,
}) {
  final reasonLine = repairReasonLine.trim();
  final receiptLine = repairReceiptLine.trim();
  if ((reasonLine.isEmpty && receiptLine.isEmpty) ||
      signalProof == null ||
      quality == Act0FeedbackQualityV1.correct) {
    return const <String>[];
  }
  final clue = _visibleRepairCluePhraseV1(signalProof.label);
  if (clue.isEmpty) {
    return const <String>[];
  }
  final focusLine = _visibleRepairFocusLineV1(signalProof.signalId);
  final lines = <String>[
    'You missed the $clue clue.',
    reasonLine.isEmpty
        ? 'This next hand starts with the same table signal.'
        : reasonLine,
    focusLine,
  ];
  if (lines.any(_containsForbiddenVisibleRepairCopyTokenV1)) {
    return const <String>[];
  }
  return List<String>.unmodifiable(lines);
}

String _visibleRepairCluePhraseV1(String label) {
  final normalized = label.trim().toLowerCase();
  return switch (normalized) {
    'no bet yet' => 'no-bet-yet',
    _ => normalized,
  };
}

String _visibleRepairFocusLineV1(String signalId) {
  final normalized = signalId.trim().toLowerCase();
  return switch (normalized) {
    'no_bet_yet' => 'Before choosing, ask whether a bet faces you.',
    _ => 'Before choosing, name the table clue first.',
  };
}

bool _containsForbiddenVisibleRepairCopyTokenV1(String line) {
  final tokens = line
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((part) => part.isNotEmpty)
      .toSet();
  const forbidden = <String>[
    'ai',
    'adaptive',
    'gto',
    'solver',
    'optimal',
    'guarantee',
    'win-rate',
    'premium',
    'paywall',
    'trial',
  ];
  return forbidden.any(tokens.contains);
}

class _FeedbackProofKeyWrapperV1 extends StatelessWidget {
  const _FeedbackProofKeyWrapperV1({
    required this.child,
    required this.proofKey,
  });

  final Widget child;
  final Key? proofKey;

  @override
  Widget build(BuildContext context) {
    final key = proofKey;
    if (key == null) {
      return child;
    }
    final motionKey = key == const Key('act0_shell_repair_outcome_proof')
        ? const Key('act0_shell_repair_outcome_motion_reveal')
        : const Key('act0_shell_feedback_proof_motion_reveal');
    return KeyedSubtree(
      key: key,
      child: _ProofMotionRevealV1(key: motionKey, child: child),
    );
  }
}

class _RepairSystemProofBlockV1 extends StatelessWidget {
  const _RepairSystemProofBlockV1({
    required this.child,
    required this.cardKey,
    required this.tone,
    this.showLabel = true,
  });

  final Widget child;
  final Key cardKey;
  final Color tone;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('act0_shell_repair_system_block'),
      child: Container(
        key: cardKey,
        padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
          border: Border.all(color: tone.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) ...[
              Text(
                'Result',
                key: const Key('act0_shell_repair_system_label'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: tone,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 5),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _ProofMotionRevealV1 extends StatefulWidget {
  const _ProofMotionRevealV1({super.key, required this.child});

  final Widget child;

  @override
  State<_ProofMotionRevealV1> createState() => _ProofMotionRevealV1State();
}

class _ProofMotionRevealV1State extends State<_ProofMotionRevealV1> {
  var _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _settled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.of(context).disableAnimations;
    if (disableMotion) {
      return widget.child;
    }
    return AnimatedScale(
      scale: _settled ? 1 : 0.992,
      duration: Act0MotionTokensV1.standard,
      curve: Act0MotionTokensV1.enter,
      child: AnimatedSlide(
        offset: _settled ? Offset.zero : const Offset(0, 0.035),
        duration: Act0MotionTokensV1.standard,
        curve: Act0MotionTokensV1.enter,
        child: AnimatedOpacity(
          opacity: _settled ? 1 : 0.92,
          duration: Act0MotionTokensV1.micro,
          curve: Act0MotionTokensV1.enter,
          child: widget.child,
        ),
      ),
    );
  }
}

class _FeedbackSessionSummaryCeremonyBlockV1 extends StatelessWidget {
  const _FeedbackSessionSummaryCeremonyBlockV1({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('act0_shell_session_summary_ceremony_block'),
      child: KeyedSubtree(
        key: const Key('act0_shell_session_repair_summary'),
        child: KeyedSubtree(
          key: const Key('act0_shell_session_repair_closure_strip'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session result',
                key: const Key('act0_shell_session_summary_ceremony_label'),
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.gold,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              for (var index = 0; index < lines.length; index++) ...[
                if (index > 0) const SizedBox(height: 3),
                Text(
                  lines[index],
                  style:
                      (index == 0
                              ? Act0ShellTokensV1.body
                              : Act0ShellTokensV1.label)
                          .copyWith(
                            color: index == 0
                                ? Act0ShellTokensV1.gold
                                : Act0ShellTokensV1.textMuted,
                            fontSize: index == 0 ? 15.0 : 10.5,
                            height: index == 0 ? 1.1 : null,
                            fontWeight: index == 0
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackSignalProofRowV1 extends StatelessWidget {
  const _FeedbackSignalProofRowV1({
    required this.proofLine,
    required this.tone,
    this.compact = false,
  });

  final String proofLine;
  final Color tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final line = _humanizedFeedbackProofLineV1(proofLine);
    if (line.isEmpty) {
      return const SizedBox.shrink();
    }
    return KeyedSubtree(
      key: const Key('act0_shell_feedback_signal_proof'),
      child: KeyedSubtree(
        key: const Key('act0_shell_wave1_feedback_signal_bridge'),
        child: KeyedSubtree(
          key: const Key('act0_shell_wave1b_feedback_evidence_bridge'),
          child: Container(
            key: const Key('act0_shell_wave2_feedback_evidence_bridge'),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 7,
              vertical: compact ? 3.5 : 4.5,
            ),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(color: tone.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: tone,
                  size: compact ? 12 : 13,
                ),
                const SizedBox(width: 6),
                Text(
                  'Clue from table',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: tone,
                    fontSize: compact ? 8.0 : 8.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    line,
                    key: const Key('act0_shell_feedback_signal_proof_label'),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: compact ? 10.5 : 11.0,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _humanizedFeedbackProofLineV1(String proofLine) {
  final line = proofLine.trim();
  if (line.isEmpty) {
    return '';
  }
  final signalPrefix = RegExp(r'^signal:\s*', caseSensitive: false);
  final cleaned = line.replaceFirst(signalPrefix, '').trim();
  if (_normalizeFeedbackLabelV1(cleaned) == 'no bet yet') {
    return 'Nobody had bet yet - that was the clue.';
  }
  return cleaned;
}

String _feedbackPrimaryResultLabelV1({
  required Act0FeedbackQualityV1 quality,
  required String? repairReceiptLine,
}) {
  final receipt = repairReceiptLine?.trim().toLowerCase() ?? '';
  if (receipt.startsWith('repair fixed:')) {
    return 'Repair landed';
  }
  if (receipt.startsWith('replay fixed:')) {
    return 'Repair landed';
  }
  if (receipt.startsWith('fix landed:')) {
    return 'Repair landed';
  }
  if (receipt.startsWith('still missed:') ||
      receipt.startsWith('repair missed:') ||
      receipt.startsWith('replay missed:')) {
    return 'Still fragile';
  }
  return switch (quality) {
    Act0FeedbackQualityV1.correct => 'Correct read',
    Act0FeedbackQualityV1.suboptimal => 'Better read',
    Act0FeedbackQualityV1.wrong => 'Missed clue',
  };
}

List<String> _dedupedFeedbackContextLabelsV1(
  List<String> labels, {
  required String preferredLine,
  required String selectedLine,
  required String statusLine,
  required String signalLabel,
  required String proofLine,
}) {
  final seen = <String>{};
  final normalizedSelected = _normalizeFeedbackLabelV1(selectedLine);
  final blocked = <String>{
    _normalizeFeedbackLabelV1(preferredLine),
    _normalizeFeedbackLabelV1(statusLine),
    _normalizeFeedbackLabelV1(signalLabel),
    _normalizeFeedbackLabelV1(_humanizedFeedbackProofLineV1(proofLine)),
    _normalizeFeedbackLabelV1(
      proofLine.replaceFirst(RegExp(r'^signal:\s*', caseSensitive: false), ''),
    ),
  }..remove('');
  final result = <String>[];
  for (final label in labels) {
    final normalized = _normalizeFeedbackLabelV1(label);
    if (normalized.isEmpty ||
        blocked.contains(normalized) ||
        (normalizedSelected.isNotEmpty &&
            (normalized == normalizedSelected ||
                normalized.startsWith('$normalizedSelected '))) ||
        !seen.add(normalized)) {
      continue;
    }
    result.add(label);
  }
  return result;
}

String _normalizeFeedbackLabelV1(String label) {
  return label.trim().toLowerCase();
}

String _feedbackSelectedLineV1(BuildContext context, String selectedLabel) {
  final prefix = act0RuntimeLocalizedGeneralLabelV1(context, 'You picked');
  return '$prefix ${_premiumSafeFeedbackOptionLabelV1(act0RuntimeLocalizedOptionLabelV1(context, selectedLabel))}';
}

String _premiumSafeFeedbackOptionLabelV1(String label) {
  final trimmed = label.trim();
  return switch (trimmed) {
    'Bottom seat' => 'Hero on the Button',
    'Hero is BTN, blinds are posted, and no board is out yet' =>
      'Hero on the Button preflop',
    _ => trimmed,
  };
}

const Set<String> _genericFeedbackTitleFloorInputsV1 = <String>{
  'Almost there.',
  'Clean execution.',
  'Close call.',
  'Excellent spot.',
  'Getting warmer.',
  'Good.',
  'Good direction.',
  'Good instinct.',
  'Nearly there.',
  'Nice read.',
  'On the right track.',
  'One more step.',
  'Playable instinct.',
  'Playable move.',
  'Sharp read.',
  'Solid understanding.',
  'Spot on.',
  'Strong choice.',
  'Very close.',
  'Well done.',
};

String _feedbackTitleFloorV1(
  BuildContext context, {
  required String title,
  required Act0FeedbackQualityV1 quality,
  required List<String> contextLabels,
}) {
  final trimmedTitle = title.trim();
  final premiumSafeTitle = _premiumSafeFeedbackTitleV1(trimmedTitle);
  if (premiumSafeTitle != null) {
    return premiumSafeTitle;
  }
  if (trimmedTitle.isEmpty ||
      !_genericFeedbackTitleFloorInputsV1.contains(trimmedTitle)) {
    return trimmedTitle;
  }

  final localeIsRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  final focusLabel = contextLabels.isEmpty
      ? ''
      : act0RuntimeLocalizedContextLabelV1(context, contextLabels.first).trim();

  if (focusLabel.isNotEmpty) {
    if (quality == Act0FeedbackQualityV1.correct) {
      return focusLabel;
    }
    return localeIsRu ? '$focusLabel сначала' : '$focusLabel first';
  }

  if (quality == Act0FeedbackQualityV1.correct) {
    return localeIsRu ? 'Верное чтение' : 'Correct read';
  }
  return localeIsRu ? 'Сначала перечитай спот' : 'Read the spot first';
}

String? _premiumSafeFeedbackTitleV1(String title) {
  return switch (title) {
    'Specific fix transfers.' => 'Good. Use this read again.',
    'One clean reread.' => 'One quick repair.',
    _ => null,
  };
}

String _feedbackReasonFloorV1(
  BuildContext context, {
  required String reason,
  required Act0FeedbackQualityV1 quality,
  required String selectedLabel,
  required String preferredLabel,
  required String betterLabel,
  required List<String> contextLabels,
}) {
  final resolved = act0RuntimeLocalizedGeneralLabelV1(context, reason).trim();
  if (resolved.isNotEmpty) {
    return resolved;
  }

  final localeIsRu = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');
  final focusLabel = contextLabels.isEmpty
      ? ''
      : act0RuntimeLocalizedContextLabelV1(context, contextLabels.first).trim();
  final betterLine = act0RuntimeLocalizedOptionLabelV1(
    context,
    quality == Act0FeedbackQualityV1.wrong ? betterLabel : preferredLabel,
  ).trim();
  final pickedLine = act0RuntimeLocalizedOptionLabelV1(
    context,
    selectedLabel,
  ).trim();
  final safeBetterLine = _premiumSafeFeedbackOptionLabelV1(betterLine);
  final safePickedLine = _premiumSafeFeedbackOptionLabelV1(pickedLine);

  if (quality == Act0FeedbackQualityV1.correct) {
    if (focusLabel.isNotEmpty) {
      return localeIsRu
          ? '$focusLabel прочитан верно. Сохрани это и продолжай.'
          : '$focusLabel read correctly. Keep it and continue.';
    }
    return localeIsRu
        ? 'Чтение верное. Сохрани его и продолжай.'
        : 'Read is correct. Keep it and continue.';
  }

  if (focusLabel.isNotEmpty && safeBetterLine.isNotEmpty) {
    return localeIsRu
        ? '$focusLabel сначала. Сравни это с $safeBetterLine перед продолжением.'
        : '$focusLabel first. Compare it with $safeBetterLine before you continue.';
  }
  if (safePickedLine.isNotEmpty && safeBetterLine.isNotEmpty) {
    return localeIsRu
        ? 'Сравни $safePickedLine с $safeBetterLine перед продолжением.'
        : 'Compare $safePickedLine with $safeBetterLine before you continue.';
  }
  return localeIsRu
      ? 'Сделай паузу, прочитай спот ещё раз и затем продолжай.'
      : 'Pause, read the spot again, then continue.';
}

class Act0BlockCompletionShellV1 extends StatelessWidget {
  const Act0BlockCompletionShellV1({
    super.key,
    required this.summary,
    this.evidenceSummary,
    this.earnedMomentConsumer = const Act0AchievementSeedConsumerV1(),
    this.repairOutcomeConsumer = const Act0RepairOutcomeConsumerV1(),
    required this.onContinue,
    this.onReplay,
    this.onOpenReview,
    this.onLaunchPracticeRepairQueueTarget,
    required this.onBackToMap,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Act0SessionSummaryEvidenceViewModelV1? evidenceSummary;
  final Act0AchievementSeedConsumerV1 earnedMomentConsumer;
  final Act0RepairOutcomeConsumerV1 repairOutcomeConsumer;
  final VoidCallback onContinue;
  final VoidCallback? onReplay;
  final VoidCallback? onOpenReview;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
  onLaunchPracticeRepairQueueTarget;
  final VoidCallback onBackToMap;

  VoidCallback? _callbackForCta(Act0MilestoneCtaKindV1 kind) {
    return switch (kind) {
      Act0MilestoneCtaKindV1.continueForward => onContinue,
      Act0MilestoneCtaKindV1.replayForPerfect => onReplay,
      Act0MilestoneCtaKindV1.reviewFirst => onOpenReview,
      Act0MilestoneCtaKindV1.reviewForPerfect => onOpenReview,
      Act0MilestoneCtaKindV1.backToMap => onBackToMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final celebrateTone = summary.qualifiesForNextLesson
        ? (summary.leveledUp
              ? Act0ShellTokensV1.gold
              : Act0ShellTokensV1.primary)
        : Act0ShellTokensV1.gold;
    final visibleEvidenceSummary =
        evidenceSummary != null && evidenceSummary!.hasEvidence
        ? evidenceSummary
        : null;
    final visibleEarnedMoment = earnedMomentConsumer.moments.isNotEmpty
        ? earnedMomentConsumer.moments.first
        : null;
    final visibleRepairOutcomeReceipt = repairOutcomeConsumer.sessionReceipt;
    final payoffHero = _SessionSummaryPayoffHeroV1.fromProof(
      moments: earnedMomentConsumer.moments,
      receipt: visibleRepairOutcomeReceipt,
    );
    final summarySharkyLine = summary.sharkyLine.trim().isNotEmpty
        ? summary.sharkyLine.trim()
        : payoffHero != null
        ? act0SharkyCoachLineForMomentV1(
            Act0SharkyCoachMomentV1.sessionSummaryProof,
          )
        : '';
    final sessionSummaryCompanionState = _act0SessionSummaryCompanionStateV1(
      hasWorldCompletionMoment:
          summary.hasWorldOneCompletionPayoff ||
          summary.hasWorldCompletionPayoff ||
          summary.hasBandTransitionPayoff,
      qualifiesForNextLesson: summary.qualifiesForNextLesson,
      receipt: visibleRepairOutcomeReceipt,
    );
    final sessionSummaryCompanionMood = act0SharkyMoodForCompanionStateV1(
      sessionSummaryCompanionState,
    );
    final sessionSummaryCompanionRinged =
        act0SharkyCompanionStateHasAccentRingV1(sessionSummaryCompanionState);
    final sessionSummaryGrowthStage = act0SharkyGrowthStageForWorldNumberV1(
      summary.worldNumber,
    );
    final foldUnlockIntoMilestonePanel =
        summary.isWorldComplete && summary.unlockedLabel != null;
    final showHabitReward =
        !summary.isWorldComplete || summary.growthLabel.isEmpty;
    final tabletLayout = MediaQuery.sizeOf(context).shortestSide >= 700;
    Widget nextActionCard() {
      return _ProofMotionRevealV1(
        key: const Key('act0_shell_block_summary_next_motion_reveal'),
        child: Container(
          key: const Key('act0_shell_block_summary_next_label'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
            border: Border.all(color: Act0ShellTokensV1.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payoffHero == null ? 'What next' : 'Next hand',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.info,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                payoffHero != null &&
                        summary.primaryCtaKind ==
                            Act0MilestoneCtaKindV1.replayForPerfect
                    ? 'Replay the saved read once.'
                    : summary.suggestedNextAction,
                key: const Key('act0_shell_block_summary_suggested_next'),
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (summary.nextUnlockReasonLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  summary.nextUnlockReasonLabel!,
                  key: const Key('act0_shell_block_summary_next_reason'),
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (summarySharkyLine.isNotEmpty && payoffHero == null) ...[
                const SizedBox(height: 6),
                Act0SharkyPresenceBubbleV1(
                  line: summarySharkyLine,
                  mood: sessionSummaryCompanionMood,
                  ringed: sessionSummaryCompanionRinged,
                  growthStage: sessionSummaryGrowthStage,
                  textKey: const Key('act0_shell_block_summary_sharky_line'),
                  mascotSize: 68,
                  bubblePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget primaryCtaButton() {
      return FilledButton(
        key: const Key('act0_shell_block_summary_continue_cta'),
        onPressed: _callbackForCta(summary.primaryCtaKind),
        style: Act0ShellTokensV1.premiumActionButtonStyle(),
        child: Text(
          payoffHero != null &&
                  summary.primaryCtaKind ==
                      Act0MilestoneCtaKindV1.replayForPerfect
              ? 'Replay the saved read'
              : summary.primaryCtaLabel,
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
        ),
        child: Container(
          key: const Key('act0_shell_block_summary_card'),
          constraints: BoxConstraints(maxWidth: tabletLayout ? 720 : 388),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface,
            borderRadius: BorderRadius.circular(
              Act0ShellTokensV1.radiusOverlay,
            ),
            border: Border.all(color: Act0ShellTokensV1.border),
          ),
          child: Column(
            key: const Key('act0_shell_session_summary_victory_lap'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      celebrateTone.withValues(alpha: 0.18),
                      celebrateTone.withValues(alpha: 0.82),
                      Act0ShellTokensV1.info.withValues(alpha: 0.34),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _ProofMotionRevealV1(
                key: const Key(
                  'act0_shell_session_summary_proof_hero_motion_reveal',
                ),
                child: KeyedSubtree(
                  key: const Key(
                    'act0_shell_block_summary_payoff_motion_reveal',
                  ),
                  child: Container(
                    key: payoffHero == null
                        ? const Key('act0_shell_block_summary_milestone_panel')
                        : const Key('act0_shell_session_summary_hero_payoff'),
                    padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          celebrateTone.withValues(alpha: 0.22),
                          Act0ShellTokensV1.surface2.withValues(alpha: 0.96),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPanel,
                      ),
                      border: Border.all(
                        color: celebrateTone.withValues(alpha: 0.28),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: celebrateTone.withValues(alpha: 0.12),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: celebrateTone.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusPill,
                                ),
                                border: Border.all(
                                  color: celebrateTone.withValues(alpha: 0.34),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    summary.qualifiesForNextLesson
                                        ? Icons.auto_awesome_rounded
                                        : Icons.refresh_rounded,
                                    size: 14,
                                    color: celebrateTone,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    payoffHero == null
                                        ? summary.masteryLabel
                                        : payoffHero.kicker,
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: celebrateTone,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (summary.isWorldComplete) ...[
                              const Spacer(),
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 20,
                                color: celebrateTone,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        Text(
                          payoffHero == null
                              ? 'What finished'
                              : 'Session complete',
                          style: Act0ShellTokensV1.label.copyWith(
                            color: celebrateTone,
                            letterSpacing: 0.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        KeyedSubtree(
                          key: payoffHero == null
                              ? null
                              : const Key(
                                  'act0_shell_session_summary_hero_metric',
                                ),
                          child: Text(
                            summary.hasWorldOneCompletionPayoff ||
                                    summary.hasWorldCompletionPayoff
                                ? summary.milestoneTitle
                                : payoffHero?.headline ??
                                      summary.milestoneTitle,
                            key: const Key('act0_shell_block_summary_title'),
                            style: Act0ShellTokensV1.screenTitle.copyWith(
                              fontSize: payoffHero == null ? 30 : 32,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.hasWorldOneCompletionPayoff ||
                                  summary.hasWorldCompletionPayoff
                              ? summary.milestoneDetailTitle
                              : payoffHero?.detail ??
                                    summary.milestoneDetailTitle,
                          key: const Key(
                            'act0_shell_block_summary_detail_title',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          summary.gateMessage,
                          key: const Key(
                            'act0_shell_block_summary_gate_message',
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.textMuted,
                          ),
                        ),
                        if (summarySharkyLine.isNotEmpty &&
                            payoffHero != null) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapSm),
                          Act0SharkyPresenceBubbleV1(
                            key: const Key(
                              'act0_shell_session_summary_payoff_sharky',
                            ),
                            line: summarySharkyLine,
                            mood: sessionSummaryCompanionMood,
                            ringed: sessionSummaryCompanionRinged,
                            growthStage: sessionSummaryGrowthStage,
                            textKey: const Key(
                              'act0_shell_block_summary_sharky_line',
                            ),
                            mascotSize: 64,
                            bubblePadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ],
                        if (summary.hasWorldOneCompletionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _WorldOneCompletionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ],
                        if (summary.hasBandTransitionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _BandTransitionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ] else if (summary.hasTerminalCompletionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _TerminalCompletionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ] else if (summary.hasWorldCompletionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _WorldCompletionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ],
                        if (foldUnlockIntoMilestonePanel) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          Text(
                            summary.unlockedLabel!,
                            key: const Key(
                              'act0_shell_block_summary_unlock_label',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: Act0ShellTokensV1.body.copyWith(
                              color: Act0ShellTokensV1.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            summary.progressStatusLabel,
                            key: const Key(
                              'act0_shell_block_summary_progress_status',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: Act0ShellTokensV1.muted.copyWith(
                              color: Act0ShellTokensV1.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXl),
              if (!foldUnlockIntoMilestonePanel &&
                  summary.isWorldComplete &&
                  (summary.unlockedLabel != null ||
                      summary.progressStatusLabel.isNotEmpty)) ...[
                Container(
                  key: const Key('act0_shell_block_summary_unlock_card'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    border: Border.all(color: Act0ShellTokensV1.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary.unlockedLabel != null) ...[
                        Text(
                          summary.unlockedLabel!,
                          key: const Key(
                            'act0_shell_block_summary_unlock_label',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        summary.progressStatusLabel,
                        key: const Key(
                          'act0_shell_block_summary_progress_status',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Act0ShellTokensV1.muted.copyWith(
                          color: Act0ShellTokensV1.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              nextActionCard(),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              primaryCtaButton(),
              if (summary.secondaryCtaLabel != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                OutlinedButton(
                  key: const Key('act0_shell_block_summary_quality_cta'),
                  onPressed: _callbackForCta(summary.secondaryCtaKind!),
                  style: Act0ShellTokensV1.tonalButtonStyle(
                    tone: Act0ShellTokensV1.info,
                    fullWidth: true,
                  ),
                  child: Text(summary.secondaryCtaLabel!),
                ),
              ],
              if (summary.hasNextLesson ||
                  (summary.isWorldComplete &&
                      summary.nextWorldTitle != null &&
                      summary.nextWorldTitle!.isNotEmpty)) ...[
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                TextButton(
                  key: const Key('act0_shell_block_summary_map_cta'),
                  onPressed: onBackToMap,
                  child: const Text('Back to map'),
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapLg),
              if (showHabitReward) ...[
                Container(
                  key: const Key('act0_shell_block_summary_habit_reward'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    border: Border.all(color: Act0ShellTokensV1.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: celebrateTone.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusLg,
                          ),
                        ),
                        child: Icon(
                          summary.deepLeakCount > 0
                              ? Icons.build_circle_rounded
                              : summary.quickFixCount > 0
                              ? Icons.trending_up_rounded
                              : summary.leveledUp
                              ? Icons.auto_awesome_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: celebrateTone,
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What improved',
                              key: const Key(
                                'act0_shell_block_summary_habit_reward_label',
                              ),
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.info,
                                letterSpacing: 0.35,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary.habitRewardDetail,
                              key: const Key(
                                'act0_shell_block_summary_habit_reward_detail',
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.fade,
                              style: Act0ShellTokensV1.body.copyWith(
                                color: Act0ShellTokensV1.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (visibleEvidenceSummary != null) ...[
                _SessionSummaryEvidenceCardV1(
                  summary: visibleEvidenceSummary,
                  onLaunchPracticeRepairQueueTarget:
                      onLaunchPracticeRepairQueueTarget,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (visibleEarnedMoment != null) ...[
                _SessionSummaryEarnedMomentCardV1(
                  moment: visibleEarnedMoment,
                  tone: celebrateTone,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (visibleRepairOutcomeReceipt != null) ...[
                _SessionSummaryRepairOutcomeReceiptCardV1(
                  receipt: visibleRepairOutcomeReceipt,
                  tone: celebrateTone,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (summary.isWorldComplete &&
                  summary.growthLabel.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _GrowthHighlightV1(
                  key: const Key('act0_shell_block_summary_growth_highlight'),
                  title: summary.isWorldComplete
                      ? 'What improved'
                      : 'What moved',
                  label: summary.growthLabel,
                  tone: celebrateTone,
                ),
              ],
              if (summary.ownershipHighlights.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _BlockSummaryListCardV1(
                  cardKey: const Key('act0_shell_block_summary_ownership_card'),
                  title: 'You can now',
                  lines: summary.ownershipHighlights,
                  icon: Icons.workspace_premium_rounded,
                ),
              ],
              if (summary.hasMasteryPack) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _BlockSummaryListCardV1(
                  cardKey: const Key(
                    'act0_shell_block_summary_mastery_pack_card',
                  ),
                  title: 'Keep sharp',
                  lines: summary.masteryPackLines,
                  icon: Icons.track_changes_rounded,
                ),
              ],
              if (summary.hasReturnPlan) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _BlockSummaryListCardV1(
                  cardKey: const Key('act0_shell_block_summary_return_card'),
                  title: 'Tomorrow',
                  lines: <String>[summary.returnPlanLabel],
                  icon: Icons.event_repeat_rounded,
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _BlockXpProgressCardV1(summary: summary),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                '${summary.accuracyPercent}% accuracy · ${summary.correctCount}/${summary.taskCount} correct · ${summary.errorCount} ${summary.errorCount == 1 ? 'error' : 'errors'}',
                key: const Key('act0_shell_block_summary_accuracy'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (summary.quickFixCount > 0 || summary.deepLeakCount > 0) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Container(
                  key: const Key('act0_shell_block_summary_repair_mix'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusLg,
                    ),
                    border: Border.all(color: Act0ShellTokensV1.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Quick fixes: ${summary.quickFixCount}',
                          key: const Key(
                            'act0_shell_block_summary_quick_fixes',
                          ),
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Text(
                          'Deep leaks: ${summary.deepLeakCount}',
                          key: const Key('act0_shell_block_summary_deep_leaks'),
                          textAlign: TextAlign.right,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: summary.deepLeakCount == 0
                                ? Act0ShellTokensV1.textMuted
                                : Act0ShellTokensV1.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldOneCompletionPayoffV1 extends StatelessWidget {
  const _WorldOneCompletionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_world1_completion',
      tone: tone,
      payoffLabel: summary.worldOneCompletionPayoffLabel,
      learningLabel: summary.worldOneCompletionLearningLabel,
      nextLabel: summary.worldOneCompletionNextLabel,
      previewLine: summary.worldOneCompletionPreviewLine,
      proofFallbackLabel: summary.worldOneCompletionProofFallbackLabel,
      receipt: receipt,
    );
  }
}

/// Ordinary World 2-6 completion payoff. Shares the exact hierarchy/visual
/// grammar accepted for World 1 via [_WorldMilestoneCardV1]; only the
/// deterministic per-world copy differs (`_worldCompletionMetaByNumberV1`).
/// World 4 intentionally receives no special treatment here — the future
/// W4->W5 band transition PR can key off `summary.worldNumber == 4` to swap
/// in its own stronger variant before this widget is reached.
class _WorldCompletionPayoffV1 extends StatelessWidget {
  const _WorldCompletionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_world_completion',
      tone: tone,
      payoffLabel: summary.worldCompletionPayoffLabel,
      learningLabel: summary.worldCompletionLearningLabel,
      nextLabel: summary.worldCompletionNextLabel,
      previewLine: summary.worldCompletionPreviewLine,
      proofFallbackLabel: summary.worldCompletionProofFallbackLabel,
      receipt: receipt,
    );
  }
}

/// The one W4->W5 Foundation -> Developing Player band-transition milestone.
/// Strictly gated to `worldNumber == 4` with valid World 5 route truth
/// (see [Act0BlockCompletionSummaryV1.hasBandTransitionPayoff]) and checked
/// with higher priority than [_WorldCompletionPayoffV1] at the render site,
/// so World 4 never also renders the ordinary card. Reuses the exact shared
/// [_WorldMilestoneCardV1] hierarchy with band-specific copy and the
/// reserved emphasized milestone seal. Not a general multi-band framework:
/// no other world number reaches this widget.
class _BandTransitionPayoffV1 extends StatelessWidget {
  const _BandTransitionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_band_transition_completion',
      tone: tone,
      payoffLabel: summary.bandTransitionIdentityLabel,
      learningLabel: summary.bandTransitionLearningLabel,
      nextLabel: summary.bandTransitionNextLabel,
      previewLine: summary.bandTransitionPreviewLine,
      proofFallbackLabel: summary.bandTransitionProofFallbackLabel,
      receipt: receipt,
      emphasizeMilestone: true,
    );
  }
}

/// The one World 12 Volume I terminal closure milestone. Strictly gated to
/// `worldNumber == 12` (see
/// [Act0BlockCompletionSummaryV1.hasTerminalCompletionPayoff]) and checked
/// with higher priority than [_WorldCompletionPayoffV1] at the render site,
/// so World 12 never also renders the ordinary card. Reuses the exact
/// shared [_WorldMilestoneCardV1] hierarchy and the emphasized milestone
/// seal already used by [_BandTransitionPayoffV1], with terminal-specific
/// identity copy and the same honest, already-accepted `Volume I review`
/// next-step/preview text. Not a general multi-terminal framework: no other
/// world number reaches this widget, and no W13+ route is implied.
class _TerminalCompletionPayoffV1 extends StatelessWidget {
  const _TerminalCompletionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_terminal_completion',
      tone: tone,
      payoffLabel: summary.terminalCompletionIdentityLabel,
      learningLabel: summary.terminalCompletionLearningLabel,
      nextLabel: summary.terminalCompletionNextLabel,
      previewLine: summary.terminalCompletionPreviewLine,
      proofFallbackLabel: summary.terminalCompletionProofFallbackLabel,
      receipt: receipt,
      emphasizeMilestone: true,
    );
  }
}

/// Shared card layout for the accepted world-completion payoff hierarchy:
/// milestone identity, learning takeaway, gated proof row, next-world
/// preview. Used by both the World 1 dedicated copy and the ordinary
/// World 2-6 copy so the visual grammar never forks per world.
class _WorldMilestoneCardV1 extends StatelessWidget {
  const _WorldMilestoneCardV1({
    required this.keyPrefix,
    required this.tone,
    required this.payoffLabel,
    required this.learningLabel,
    required this.nextLabel,
    required this.previewLine,
    required this.proofFallbackLabel,
    this.receipt,
    this.emphasizeMilestone = false,
  });

  final String keyPrefix;
  final Color tone;
  final String payoffLabel;
  final String learningLabel;
  final String nextLabel;
  final String previewLine;
  final String proofFallbackLabel;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  /// Reserved for the one W4->W5 band-transition consumer. Every ordinary
  /// world-completion wrapper leaves this at its default so the accepted
  /// W1-W6 card renders byte-identically.
  final bool emphasizeMilestone;

  bool get _hasEarnedProof => receipt?.isBankedFixProof == true;

  @override
  Widget build(BuildContext context) {
    final proofIconRole = !_hasEarnedProof
        ? null
        : receipt!.hasReinforcedEvidence
        ? Act0ProofIconRoleV1.reinforced
        : Act0ProofIconRoleV1.repairCompleted;
    return KeyedSubtree(
      key: Key('${keyPrefix}_payoff'),
      child: Padding(
        padding: const EdgeInsets.only(top: Act0ShellTokensV1.gapSm),
        child: _MilestoneMotionRevealV1(
          key: Key('${keyPrefix}_motion_reveal'),
          emphasized: emphasizeMilestone,
          identity: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Act0ProofIconV1(
                key: Key('${keyPrefix}_milestone_icon'),
                role: Act0ProofIconRoleV1.milestone,
                size: Act0ProofIconSizeV1.seal,
                emphasized: emphasizeMilestone,
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  payoffLabel,
                  key: Key('${keyPrefix}_payoff_label'),
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          details: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                learningLabel,
                key: Key('${keyPrefix}_learning_label'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (proofIconRole != null) ...[
                    Act0ProofIconV1(
                      key: Key('${keyPrefix}_proof_icon'),
                      role: proofIconRole,
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapXs),
                  ],
                  Expanded(
                    child: Text(
                      _hasEarnedProof
                          ? receipt!.lines.first
                          : proofFallbackLabel,
                      key: Key('${keyPrefix}_proof_line'),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: Act0ShellTokensV1.muted.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                nextLabel,
                key: Key('${keyPrefix}_next_label'),
                style: Act0ShellTokensV1.body.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                previewLine,
                key: Key('${keyPrefix}_preview_line'),
                maxLines: 3,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared `milestone`-category motion contract for
/// [_WorldCompletionPayoffV1] and [_BandTransitionPayoffV1] (see
/// `docs/_reviews/motion_direction_system_v1.md`). A single, bounded
/// staged reveal: the milestone identity (icon + payoff label) settles in
/// first, then the supporting details (learning line, proof row, next-world
/// preview) follow. `emphasized` (the same flag [_WorldMilestoneCardV1]
/// already uses for the W4->W5 seal) drives a slightly stronger identity
/// settle for the band transition only - no new asset, no new category.
///
/// Runs once per admitted milestone appearance: state lives in this
/// [StatefulWidget]'s [State], so a parent rebuild while this element stays
/// mounted (identical `Key`, same tree position) does not replay it. A real
/// unmount/remount (a new completion actually appearing) starts fresh,
/// which is the correct semantics for "once per admitted appearance".
///
/// Reduced motion ([MediaQuery.disableAnimations]) resolves both stages to
/// their settled state on the very first build, before any post-frame
/// callback runs, so no content is ever hidden while motion is off and no
/// animated frame is produced.
class _MilestoneMotionRevealV1 extends StatefulWidget {
  const _MilestoneMotionRevealV1({
    super.key,
    required this.emphasized,
    required this.identity,
    required this.details,
  });

  final bool emphasized;
  final Widget identity;
  final Widget details;

  @override
  State<_MilestoneMotionRevealV1> createState() =>
      _MilestoneMotionRevealV1State();
}

class _MilestoneMotionRevealV1State extends State<_MilestoneMotionRevealV1> {
  var _identityRevealed = false;
  var _detailsRevealed = false;
  Timer? _detailsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _identityRevealed = true);
      if (MediaQuery.of(context).disableAnimations) {
        setState(() => _detailsRevealed = true);
        return;
      }
      _detailsTimer = Timer(Act0MotionTokensV1.micro, () {
        if (!mounted) return;
        setState(() => _detailsRevealed = true);
      });
    });
  }

  @override
  void dispose() {
    _detailsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [widget.identity, widget.details],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedScale(
          scale: _identityRevealed ? 1.0 : (widget.emphasized ? 0.94 : 0.97),
          duration: widget.emphasized
              ? Act0MotionTokensV1.milestone
              : Act0MotionTokensV1.standard,
          curve: Act0MotionTokensV1.emphasisCurve,
          child: AnimatedOpacity(
            opacity: _identityRevealed ? 1 : 0,
            duration: Act0MotionTokensV1.micro,
            curve: Act0MotionTokensV1.enter,
            child: widget.identity,
          ),
        ),
        AnimatedSlide(
          offset: _detailsRevealed ? Offset.zero : const Offset(0, 0.02),
          duration: Act0MotionTokensV1.standard,
          curve: Act0MotionTokensV1.enter,
          child: AnimatedOpacity(
            opacity: _detailsRevealed ? 1 : 0,
            duration: Act0MotionTokensV1.standard,
            curve: Act0MotionTokensV1.enter,
            child: widget.details,
          ),
        ),
      ],
    );
  }
}

/// Resolves the Session Summary Sharky companion state from the exact same
/// structured evidence already used to decide this screen's copy and proof
/// icons: real world/band completion, a source-backed improvement
/// observation, banked-fix proof, and the ordinary repair-vs-forward gate.
/// Priority is milestone > improve > confirm > repair > neutral, so a
/// genuine completion boundary always wins and `repair` can never coexist
/// with a success/milestone moment. Never parses copy text.
Act0SharkyCompanionStateV1 _act0SessionSummaryCompanionStateV1({
  required bool hasWorldCompletionMoment,
  required bool qualifiesForNextLesson,
  Act0RepairOutcomeSessionReceiptV1? receipt,
}) {
  if (hasWorldCompletionMoment) {
    return Act0SharkyCompanionStateV1.milestone;
  }
  if (receipt?.hasImprovementObservation == true) {
    return Act0SharkyCompanionStateV1.improve;
  }
  if (receipt?.isBankedFixProof == true) {
    return Act0SharkyCompanionStateV1.confirm;
  }
  if (!qualifiesForNextLesson) {
    return Act0SharkyCompanionStateV1.repair;
  }
  return Act0SharkyCompanionStateV1.neutral;
}

class _SessionSummaryPayoffHeroV1 {
  const _SessionSummaryPayoffHeroV1({
    required this.kicker,
    required this.headline,
    required this.detail,
  });

  final String kicker;
  final String headline;
  final String detail;

  static _SessionSummaryPayoffHeroV1? fromProof({
    required List<Act0AchievementMomentViewModelV1> moments,
    required Act0RepairOutcomeSessionReceiptV1? receipt,
  }) {
    final hasCorrectRead = moments.any(
      (moment) => moment.label == 'First correct read',
    );
    final hasGoodFix =
        receipt?.lines.any((line) => line.startsWith('Good fixes:')) ?? false;
    if (!hasCorrectRead && !hasGoodFix) {
      return null;
    }
    return _SessionSummaryPayoffHeroV1(
      kicker: 'Saved read',
      headline: hasCorrectRead && hasGoodFix
          ? 'One clean table read is saved.'
          : hasCorrectRead
          ? 'One clean table read is saved.'
          : 'Repair landed.',
      detail: hasCorrectRead && hasGoodFix
          ? 'Keep this clue: read the table before acting.'
          : hasCorrectRead
          ? 'Keep this clue for the next hand.'
          : 'Keep this repair for the next hand.',
    );
  }
}

class _BlockXpProgressCardV1 extends StatelessWidget {
  const _BlockXpProgressCardV1({required this.summary});

  final Act0BlockCompletionSummaryV1 summary;

  @override
  Widget build(BuildContext context) {
    final tone = summary.leveledUp
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPanel),
            border: Border.all(color: Act0ShellTokensV1.border),
          ),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                    ),
                    child: Text(
                      'One clean read',
                      key: const Key('act0_shell_block_summary_xp_gain'),
                      style: Act0ShellTokensV1.label.copyWith(
                        color: tone,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: Text(
                      'Local read saved',
                      key: const Key('act0_shell_block_summary_xp_total'),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.right,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                child: LinearProgressIndicator(
                  key: const Key('act0_shell_block_summary_xp_progress'),
                  minHeight: 8,
                  value: summary.xpEarned <= 0 ? 0.0 : 1.0,
                  backgroundColor: Act0ShellTokensV1.surface3,
                  color: tone,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionSummaryEvidenceCardV1 extends StatelessWidget {
  const _SessionSummaryEvidenceCardV1({
    required this.summary,
    this.onLaunchPracticeRepairQueueTarget,
  });

  final Act0SessionSummaryEvidenceViewModelV1 summary;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
  onLaunchPracticeRepairQueueTarget;

  @override
  Widget build(BuildContext context) {
    final repairFocusLine = summary.repairFocusLine;
    final repairCandidateLine = summary.repairCandidateLine;
    final learningProofLine = summary.learningProofLine;
    final practiceLaunchRequest = summary.practiceLaunchRequest;
    final showPracticeCta =
        practiceLaunchRequest?.isLaunchable == true &&
        onLaunchPracticeRepairQueueTarget != null;
    return Container(
      key: const Key('act0_shell_block_summary_evidence_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.title,
            key: const Key('act0_shell_block_summary_evidence_title'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.spotsLine,
            key: const Key('act0_shell_block_summary_evidence_spots'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.resultLine,
            key: const Key('act0_shell_block_summary_evidence_result'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (repairFocusLine != null && repairFocusLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              repairFocusLine,
              key: const Key('act0_shell_block_summary_evidence_repair_focus'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (repairCandidateLine != null &&
              repairCandidateLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              repairCandidateLine,
              key: const Key(
                'act0_shell_block_summary_evidence_repair_candidate',
              ),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (learningProofLine != null && learningProofLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ProofMotionRevealV1(
              key: const Key(
                'act0_shell_block_summary_evidence_learning_proof_reveal',
              ),
              child: Text(
                learningProofLine,
                key: const Key(
                  'act0_shell_block_summary_evidence_learning_proof',
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (showPracticeCta) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            TextButton(
              key: const Key('act0_shell_session_summary_practice_cta'),
              onPressed: () =>
                  onLaunchPracticeRepairQueueTarget!(practiceLaunchRequest!),
              style: TextButton.styleFrom(
                foregroundColor: Act0ShellTokensV1.info,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: Act0ShellTokensV1.gapXs,
                  vertical: Act0ShellTokensV1.gapSm,
                ),
              ),
              child: const Text('Practice this next'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrowthHighlightV1 extends StatelessWidget {
  const _GrowthHighlightV1({
    super.key,
    required this.label,
    required this.tone,
    this.title = 'Skill gain',
  });

  final String title;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0ShellTokensV1.border),
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
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: Icon(Icons.auto_graph_rounded, size: 17, color: tone),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummaryEarnedMomentCardV1 extends StatelessWidget {
  const _SessionSummaryEarnedMomentCardV1({
    required this.moment,
    required this.tone,
  });

  final Act0AchievementMomentViewModelV1 moment;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_block_summary_earned_moment'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('act0_shell_block_summary_earned_moment_mark'),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            ),
            child: Icon(Icons.check_circle_rounded, color: tone, size: 18),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collected read',
                  key: const Key('act0_shell_block_summary_earned_label'),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  moment.label,
                  key: const Key('act0_shell_block_summary_earned_seed'),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  act0SharkyCoachLineForMomentV1(
                    Act0SharkyCoachMomentV1.sessionSummaryEarnedMoment,
                  ),
                  key: const Key('act0_shell_block_summary_earned_proof'),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.muted.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummaryRepairOutcomeReceiptCardV1 extends StatelessWidget {
  const _SessionSummaryRepairOutcomeReceiptCardV1({
    required this.receipt,
    required this.tone,
  });

  final Act0RepairOutcomeSessionReceiptV1 receipt;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final proofIconRole = !receipt.isBankedFixProof
        ? null
        : receipt.hasReinforcedEvidence
        ? Act0ProofIconRoleV1.reinforced
        : Act0ProofIconRoleV1.repairCompleted;
    final titleRow = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (proofIconRole != null) ...[
          Act0ProofIconV1(
            key: const Key('act0_shell_session_repair_outcome_proof_icon'),
            role: proofIconRole,
            size: Act0ProofIconSizeV1.tile,
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
        ],
        Expanded(
          child: Text(
            receipt.title,
            key: const Key('act0_shell_session_repair_outcome_title'),
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              letterSpacing: 0.35,
            ),
          ),
        ),
      ],
    );
    return Container(
      key: const Key('act0_shell_session_repair_outcome_receipt'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          const SizedBox(height: 6),
          for (var index = 0; index < receipt.lines.length; index++) ...[
            if (index > 0) const SizedBox(height: 4),
            Text(
              receipt.lines[index],
              key: Key('act0_shell_session_repair_outcome_line_$index'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.body.copyWith(
                color: index == 0
                    ? Act0ShellTokensV1.text
                    : Act0ShellTokensV1.textMuted,
                fontWeight: index == 0 ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockSummaryListCardV1 extends StatelessWidget {
  const _BlockSummaryListCardV1({
    required this.cardKey,
    required this.title,
    required this.lines,
    required this.icon,
  });

  final Key cardKey;
  final String title;
  final List<String> lines;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0ShellTokensV1.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: Icon(icon, size: 17, color: Act0ShellTokensV1.info),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                for (final line in lines) ...[
                  Text(
                    line,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (line != lines.last)
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Act0RunnerCompletionSummaryV1 _blockSummaryProgressAtGain(
  Act0BlockCompletionSummaryV1 summary,
  int gain,
) {
  final xpTarget = summary.xpTarget <= 0 ? 1 : summary.xpTarget;
  final totalXp = summary.startXp + gain;
  return Act0RunnerCompletionSummaryV1(
    xpGain: gain,
    startLevel: summary.startLevel,
    endLevel: summary.startLevel + (totalXp ~/ xpTarget),
    startXp: summary.startXp,
    endXp: totalXp % xpTarget,
    xpTarget: summary.xpTarget,
  );
}

class _CompletionToastV1 extends StatelessWidget {
  const _CompletionToastV1({
    required this.summary,
    this.overlayStyle = _CompletionToastOverlayStyleV1.standard,
  });

  final Act0RunnerCompletionSummaryV1 summary;
  final _CompletionToastOverlayStyleV1 overlayStyle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final disappear = Curves.easeIn.transform(
          ((value - 0.72) / 0.28).clamp(0.0, 1.0),
        );
        final opacity = (appear * (1 - disappear)).clamp(0.0, 1.0);
        final tone = summary.leveledUp
            ? Act0ShellTokensV1.gold
            : Act0ShellTokensV1.primary;
        final onTableOverlay =
            overlayStyle == _CompletionToastOverlayStyleV1.table;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, (1 - appear) * (onTableOverlay ? 5 : 6)),
            child: Container(
              key: const Key('act0_shell_completion_toast'),
              constraints: BoxConstraints(
                minWidth: onTableOverlay ? 164 : 176,
                maxWidth: onTableOverlay ? 204 : 220,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: onTableOverlay ? 11 : 12,
                vertical: onTableOverlay ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: onTableOverlay
                    ? Act0ShellTokensV1.surface2.withValues(alpha: 0.88)
                    : Act0ShellTokensV1.surface2.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                border: Border.all(
                  color: tone.withValues(alpha: onTableOverlay ? 0.24 : 0.34),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: onTableOverlay ? 0.10 : 0.24,
                    ),
                    blurRadius: onTableOverlay ? 8 : 18,
                    offset: Offset(0, onTableOverlay ? 3 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Read banked',
                          key: const Key(
                            'act0_shell_completion_toast_reward_label',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: tone,
                            letterSpacing: onTableOverlay ? 0.16 : 0.25,
                            fontSize: onTableOverlay ? 9.0 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: onTableOverlay ? 2 : 3),
                  Text(
                    'Table read improved',
                    key: const Key('act0_shell_completion_toast_total'),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.body.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: onTableOverlay ? 10.8 : 11.5,
                    ),
                  ),
                  SizedBox(height: onTableOverlay ? 5 : 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                    child: LinearProgressIndicator(
                      key: const Key('act0_shell_completion_toast_progress'),
                      minHeight: onTableOverlay ? 5 : 6,
                      value: summary.xpGain <= 0 ? 0.0 : 1.0,
                      backgroundColor: Act0ShellTokensV1.surface3,
                      color: tone,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _CompletionToastOverlayStyleV1 { standard, table }

class _PotSweepMomentV1 extends StatelessWidget {
  const _PotSweepMomentV1({required this.potLabel});

  final String potLabel;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const Key('act0_shell_pot_sweep_moment'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1180),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final settle = Curves.easeInOut.transform(
          ((value - 0.12) / 0.70).clamp(0.0, 1.0),
        );
        final fade = Curves.easeIn.transform(
          ((value - 0.78) / 0.22).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: (appear * (1 - fade)).clamp(0.0, 1.0),
          child: Align(
            alignment:
                Alignment.lerp(
                  const Alignment(0, -0.04),
                  const Alignment(0, 0.58),
                  settle,
                ) ??
                const Alignment(0, 0.58),
            child: Transform.scale(scale: 0.90 + (0.10 * appear), child: child),
          ),
        );
      },
      child: Container(
        key: const Key('act0_shell_pot_sweep_chip'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          border: Border.all(
            color: Act0ShellTokensV1.gold.withValues(alpha: 0.38),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Act0ShellTokensV1.gold.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino_rounded, size: 13, color: Act0ShellTokensV1.gold),
            const SizedBox(width: 5),
            Text(
              potLabel,
              key: const Key('act0_shell_pot_sweep_label'),
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
                fontSize: 9.4,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Act0RunnerCompletionSummaryV1 _feedbackProgressAtGain(
  Act0RunnerCompletionSummaryV1 summary,
  int gain,
) {
  final xpTarget = summary.xpTarget <= 0 ? 1 : summary.xpTarget;
  final totalXp = summary.startXp + gain;
  return Act0RunnerCompletionSummaryV1(
    xpGain: gain,
    startLevel: summary.startLevel,
    endLevel: summary.startLevel + (totalXp ~/ xpTarget),
    startXp: summary.startXp,
    endXp: totalXp % xpTarget,
    xpTarget: summary.xpTarget,
  );
}

class _IntegratedPerspectiveTableShapeV2 extends ShapeBorder {
  const _IntegratedPerspectiveTableShapeV2({this.side = BorderSide.none});

  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  Path _path(Rect rect) {
    final w = rect.width;
    final h = rect.height;
    return Path()
      ..moveTo(rect.left + (w * 0.22), rect.top)
      ..cubicTo(
        rect.left + (w * 0.34),
        rect.top - (h * 0.008),
        rect.left + (w * 0.66),
        rect.top - (h * 0.008),
        rect.left + (w * 0.78),
        rect.top,
      )
      ..quadraticBezierTo(
        rect.left + (w * 0.87),
        rect.top + (h * 0.025),
        rect.left + (w * 0.90),
        rect.top + (h * 0.12),
      )
      ..lineTo(rect.left + (w * 0.985), rect.top + (h * 0.80))
      ..quadraticBezierTo(
        rect.right,
        rect.top + (h * 0.93),
        rect.left + (w * 0.88),
        rect.top + (h * 0.985),
      )
      ..quadraticBezierTo(
        rect.left + (w * 0.50),
        rect.bottom + (h * 0.012),
        rect.left + (w * 0.12),
        rect.top + (h * 0.985),
      )
      ..quadraticBezierTo(
        rect.left,
        rect.top + (h * 0.93),
        rect.left + (w * 0.015),
        rect.top + (h * 0.80),
      )
      ..lineTo(rect.left + (w * 0.10), rect.top + (h * 0.12))
      ..quadraticBezierTo(
        rect.left + (w * 0.13),
        rect.top + (h * 0.025),
        rect.left + (w * 0.22),
        rect.top,
      )
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      _IntegratedPerspectiveTableShapeV2(side: side.scale(t));
}

Offset _integratedPerspectivePointV2(Offset point) {
  final horizontalScale = 0.72 + (0.34 * point.dy.clamp(0.0, 1.0));
  final y = point.dy <= 0.34
      ? point.dy + 0.012
      : point.dy >= 0.68
      ? point.dy - 0.006
      : point.dy;
  return Offset(0.5 + ((point.dx - 0.5) * horizontalScale), y);
}

class _Act0TableV1 extends StatelessWidget {
  const _Act0TableV1({
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    this.onChooseSeat,
    this.visualVariant = Act0ShellTableVisualVariantV1.classic,
    this.showFocusBadge = true,
    this.showRepairCallout = true,
    this.playbackActiveSeatId,
    this.animateBetMotion = false,
    this.betOverride,
    this.centerLabelOverride,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
    this.completionSummary,
    this.selectedSeatId,
    this.selectedSeatFeedbackState = _SeatSelectionFeedbackStateV1.none,
    this.compactBottomDockClearance = false,
    required this.interactionMode,
    required this.framingProfile,
    required this.viewportFamily,
    this.lateRouteSignal,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.maxTableHeight,
    this.lockSharedActiveTableGeometry = false,
    this.integratedPerspectivePrototype = false,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final String? playbackActiveSeatId;
  final bool animateBetMotion;
  final Act0SeatBetStateV1? betOverride;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? selectedSeatId;
  final _SeatSelectionFeedbackStateV1 selectedSeatFeedbackState;
  final bool compactBottomDockClearance;
  final _RunnerInteractionModeV1 interactionMode;
  final Act0RunnerFramingProfileV1 framingProfile;
  final _RunnerViewportFamilyV1 viewportFamily;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final double? maxTableHeight;
  final bool lockSharedActiveTableGeometry;
  final bool integratedPerspectivePrototype;

  @override
  Widget build(BuildContext context) {
    final seats = _visualSeatOrder(table.seats);
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final isTablet =
        Act0ShellTokensV1.isTabletWidth(context) &&
        MediaQuery.sizeOf(context).shortestSide >= 600;
    var tableMaxWidth = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.runnerTableMaxWidth,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableMaxWidth,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableMaxWidth += 48;
    }
    if (isTablet) {
      tableMaxWidth = switch (table.density) {
        Act0TableDensityV1.compactLesson => refined ? 560 : 520,
        Act0TableDensityV1.handView => refined ? 600 : 560,
      };
    }
    final usesCompactAnswerListComposition =
        !lockSharedActiveTableGeometry &&
        _usesCompactAnswerListCompositionV1(
          context,
          refined: refined,
          isTablet: isTablet,
          viewportFamily: viewportFamily,
          density: table.density,
        );
    tableMaxWidth *= _compactDockTableScaleV1(
      context,
      refined: refined,
      isTablet: isTablet,
      compactBottomDockClearance: compactBottomDockClearance,
      density: table.density,
      compactAnswerListComposition: usesCompactAnswerListComposition,
    );
    if (usesCompactAnswerListComposition && !isTablet) {
      tableMaxWidth = math.max(
        tableMaxWidth,
        MediaQuery.sizeOf(context).width - 16,
      );
    }
    var tableAspect = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.tableAspect,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableAspect,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableAspect = lockSharedActiveTableGeometry ? 0.60 : 0.576;
    }
    if (isTablet) {
      tableAspect = switch (table.density) {
        Act0TableDensityV1.compactLesson => refined ? 0.88 : 0.84,
        Act0TableDensityV1.handView => refined ? 0.82 : 0.80,
      };
    }
    if (usesCompactAnswerListComposition) {
      tableAspect = _compactAnswerListStageFillAspectV1;
    }
    final maxTableHeight = this.maxTableHeight;
    if (maxTableHeight != null && maxTableHeight > 0) {
      tableMaxWidth = math.min(tableMaxWidth, maxTableHeight * tableAspect);
    }
    final scene = ConstrainedBox(
      key: const Key('act0_shell_table'),
      constraints: BoxConstraints(maxWidth: tableMaxWidth),
      child: AspectRatio(
        aspectRatio: tableAspect,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final baseSeatSlots = _seatSlotsForVariant(
              visualVariant,
              compactBottomDockClearance: compactBottomDockClearance,
              useAnswerListPerimeterRing:
                  _viewportFamilyUsesAnswerListCompositionV1(viewportFamily),
            );
            final baseChipSlots = _chipSlotsForVariant(
              visualVariant,
              compactBottomDockClearance: compactBottomDockClearance,
            );
            final seatSlots = integratedPerspectivePrototype
                ? baseSeatSlots.map(_integratedPerspectivePointV2).toList()
                : baseSeatSlots;
            final chipSlots = integratedPerspectivePrototype
                ? baseChipSlots.map(_integratedPerspectivePointV2).toList()
                : baseChipSlots;
            final activeSeatId = (playbackActiveSeatId ?? '').trim().isNotEmpty
                ? playbackActiveSeatId
                : _resolveActiveSeatId(table);
            final decisionPriceOwnedByTable =
                (toCallLabelOverride ?? table.toCallLabel).trim().isNotEmpty;
            final resolvedSelectedSeatId =
                (selectedSeatId ?? table.selectedSeatId)?.trim();
            final focusResolution = _resolvePrimarySeatFocusV1(
              activeSeatId: activeSeatId,
              highlightedSeatIds: table.highlightedSeatIds,
              selectableSeatIds: table.selectableSeatIds,
              selectedSeatId: resolvedSelectedSeatId,
              selectionFeedbackState: selectedSeatFeedbackState,
            );
            final hasRepairCallout =
                lateRouteSignal == null &&
                showRepairCallout &&
                (table.focusCalloutLabel.isNotEmpty ||
                    interactiveCalloutLabel.isNotEmpty);
            return Container(
              key: integratedPerspectivePrototype
                  ? const Key('act0_integrated_scene_perspective_silhouette')
                  : const Key('act0_shell_table_scene'),
              padding: const EdgeInsets.all(10),
              decoration: integratedPerspectivePrototype
                  ? ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Act0TableFeltCanonV1.railInner,
                          Act0TableFeltCanonV1.railMid,
                          Act0TableFeltCanonV1.railOuter,
                        ],
                        stops: <double>[0, 0.42, 1],
                      ),
                      shadows: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0xD8000000),
                          blurRadius: 48,
                          offset: Offset(0, 28),
                        ),
                        BoxShadow(
                          color: Act0TableFeltCanonV1.railAmbientShadow,
                          blurRadius: 18,
                          spreadRadius: 3,
                          offset: Offset(0, 7),
                        ),
                      ],
                      shape: _IntegratedPerspectiveTableShapeV2(
                        side: BorderSide(
                          color: Act0TableFeltCanonV1.innerHairline,
                          width: 1.5,
                        ),
                      ),
                    )
                  : Act0ShellTokensV1.tableRimDecoration(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      key: const Key('act0_shell_table_felt'),
                      decoration: integratedPerspectivePrototype
                          ? ShapeDecoration(
                              gradient: const RadialGradient(
                                center: Alignment(0, -0.16),
                                radius: 1.08,
                                colors: <Color>[
                                  Act0TableFeltCanonV1.feltCenter,
                                  Act0TableFeltCanonV1.feltMid,
                                  Act0TableFeltCanonV1.feltEdge,
                                ],
                                stops: <double>[0, 0.55, 1],
                              ),
                              shape: _IntegratedPerspectiveTableShapeV2(
                                side: BorderSide(
                                  color: Act0ShellTokensV1.feltLine,
                                  width: 2,
                                ),
                              ),
                            )
                          : Act0ShellTokensV1.feltDecoration(),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: DecoratedBox(
                        decoration: integratedPerspectivePrototype
                            ? ShapeDecoration(
                                shape: _IntegratedPerspectiveTableShapeV2(
                                  side: BorderSide(
                                    color: Act0ShellTokensV1.feltLine
                                        .withValues(alpha: 0.30),
                                    width: 1,
                                  ),
                                ),
                              )
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.tableInnerRadius,
                                ),
                                border: Border.all(
                                  color: Act0ShellTokensV1.feltLine.withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: integratedPerspectivePrototype
                            ? ShapeDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.white.withValues(
                                      alpha: refined ? 0.06 : 0.04,
                                    ),
                                    Colors.transparent,
                                    Act0VisualCanonV1.deepNavy.withValues(
                                      alpha: refined ? 0.14 : 0.10,
                                    ),
                                  ],
                                  stops: const <double>[0, 0.34, 1],
                                ),
                                shape:
                                    const _IntegratedPerspectiveTableShapeV2(),
                              )
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.tableInnerRadius,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.white.withValues(
                                      alpha: refined ? 0.06 : 0.04,
                                    ),
                                    Colors.transparent,
                                    Act0VisualCanonV1.deepNavy.withValues(
                                      alpha: refined ? 0.14 : 0.10,
                                    ),
                                  ],
                                  stops: const <double>[0, 0.34, 1],
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        child: FractionallySizedBox(
                          widthFactor: refined ? 0.56 : 0.52,
                          heightFactor: refined ? 0.20 : 0.18,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusPill,
                              ),
                              gradient: RadialGradient(
                                center: const Alignment(0, -0.12),
                                radius: refined ? 1.12 : 1.04,
                                colors: <Color>[
                                  Act0TableFeltCanonV1.feltSoftLift.withValues(
                                    alpha: refined ? 0.10 : 0.08,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const <double>[0, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.translate(
                      // The callout owns the upper-center teaching lane; keep
                      // the context/street stack in its reserved middle lane.
                      offset: Offset(0, hasRepairCallout ? height * 0.075 : 0),
                      child: _CenterPotV1(
                        table: table,
                        highlightedCardIds: highlightedCardIds,
                        onBoardCardTap: () => onBoardCardTap(table),
                        visualVariant: visualVariant,
                        showFocusBadge: showFocusBadge,
                        centerLabelOverride: centerLabelOverride,
                        lateRouteSignal: lateRouteSignal,
                        potLabelOverride: potLabelOverride,
                        toCallLabelOverride: toCallLabelOverride,
                        streetLabelOverride: streetLabelOverride,
                      ),
                    ),
                  ),
                  if (hasRepairCallout)
                    Positioned(
                      key: const Key('act0_shell_table_repair_callout'),
                      left: width * 0.20,
                      right: width * 0.20,
                      // Reserve the upper-center lane for the teaching callout;
                      // the center context/street stack owns the middle lane.
                      top: height * 0.23,
                      child: _TableRepairCalloutV1(
                        label: table.focusCalloutLabel.isNotEmpty
                            ? table.focusCalloutLabel
                            : interactiveCalloutLabel,
                      ),
                    ),
                  if (completionSummary != null)
                    Positioned(
                      key: const Key('act0_shell_completion_reward_lane'),
                      left: width * 0.29,
                      right: width * 0.29,
                      top: height * (refined ? 0.205 : 0.17),
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _CompletionToastV1(
                            summary: completionSummary!,
                            overlayStyle: _CompletionToastOverlayStyleV1.table,
                          ),
                        ),
                      ),
                    ),
                  for (var slot = 0; slot < seats.length; slot++)
                    _BetChipPlacementV1(
                      slot: slot,
                      seat: seats[slot],
                      betOverride: activeSeatId == seats[slot].seatId
                          ? betOverride
                          : null,
                      animateMotion:
                          animateBetMotion &&
                          activeSeatId == seats[slot].seatId &&
                          betOverride != null,
                      tableWidth: width,
                      tableHeight: height,
                      chipSlots: chipSlots,
                      seatSlots: seatSlots,
                      visualVariant: visualVariant,
                    ),
                  for (var slot = 0; slot < seats.length; slot++)
                    _SeatPlacementV1(
                      slot: slot,
                      seat: seats[slot],
                      heroCards: table.heroCards,
                      highlightedCardIds: table.highlightedCardIds,
                      active:
                          activeSeatId == seats[slot].seatId &&
                          selectedSeatFeedbackState ==
                              _SeatSelectionFeedbackStateV1.none &&
                          (focusResolution.kind !=
                                  _PrimarySeatFocusKindV1.target ||
                              focusResolution.seatId == seats[slot].seatId),
                      emphasized: table.highlightedSeatIds.contains(
                        seats[slot].seatId,
                      ),
                      hero:
                          seats[slot].isHero ||
                          seats[slot].seatId == table.heroSeatId,
                      selectable: table.selectableSeatIds.contains(
                        seats[slot].seatId,
                      ),
                      decisionPriceOwnedByTable: decisionPriceOwnedByTable,
                      visualState: _resolveSeatVisualStateV1(
                        seatId: seats[slot].seatId,
                        hero:
                            seats[slot].isHero ||
                            seats[slot].seatId == table.heroSeatId,
                        selectable: table.selectableSeatIds.contains(
                          seats[slot].seatId,
                        ),
                        selected: resolvedSelectedSeatId == seats[slot].seatId,
                        selectionFeedbackState: selectedSeatFeedbackState,
                        focusResolution: focusResolution,
                      ),
                      onChooseSeat: onChooseSeat,
                      tableWidth: width,
                      tableHeight: height,
                      seatSlots: seatSlots,
                      visualVariant: visualVariant,
                      identityPolicy: identityPolicy,
                      depthTieredPrototype: integratedPerspectivePrototype,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (!integratedPerspectivePrototype) {
      return scene;
    }
    return KeyedSubtree(
      key: const Key('act0_integrated_scene_perspective_table'),
      child: scene,
    );
  }

  String? _resolveActiveSeatId(Act0TableStateV1 table) {
    final explicitRaw = table.activeSeatId;
    if (explicitRaw != null) {
      final explicit = explicitRaw.trim();
      return explicit.isEmpty ? null : explicit;
    }
    for (final seat in table.seats) {
      if (seat.isActive) {
        return seat.seatId;
      }
    }
    return null;
  }
}

class _TableRepairCalloutV1 extends StatelessWidget {
  const _TableRepairCalloutV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: Act0ShellTokensV1.onFeltPanelDecoration(
          radius: Act0ShellTokensV1.radiusPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flag_rounded,
              key: Key('act0_shell_table_repair_callout_icon'),
              size: 13,
              color: Act0TableFeltCanonV1.innerHairline,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                key: const Key('act0_shell_table_repair_callout_text'),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontSize: 9.4,
                  letterSpacing: 0,
                  height: 1.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _compactDockTableScaleV1(
  BuildContext context, {
  required bool refined,
  required bool isTablet,
  required bool compactBottomDockClearance,
  required Act0TableDensityV1 density,
  required bool compactAnswerListComposition,
}) {
  const compactSafeAreaTableScale = 0.832;
  const compactAnswerListSafeAreaTableScale = 0.917;
  if (!refined ||
      isTablet ||
      !compactBottomDockClearance ||
      density != Act0TableDensityV1.compactLesson) {
    return 1;
  }

  final media = MediaQuery.of(context);
  final hasSystemBottomInset = media.viewPadding.bottom > 0;
  final isCompactPortrait =
      media.size.width < media.size.height && media.size.height <= 900;
  if (!hasSystemBottomInset || !isCompactPortrait) {
    return 1;
  }

  return compactAnswerListComposition
      ? compactAnswerListSafeAreaTableScale
      : compactSafeAreaTableScale;
}

bool _usesCompactAnswerListCompositionV1(
  BuildContext context, {
  required bool refined,
  required bool isTablet,
  required _RunnerViewportFamilyV1 viewportFamily,
  required Act0TableDensityV1 density,
}) {
  if (!refined ||
      isTablet ||
      !_viewportFamilyUsesAnswerListCompositionV1(viewportFamily) ||
      density != Act0TableDensityV1.compactLesson) {
    return false;
  }

  return _stableViewportPressureReasonV1(
        context,
        viewportFamily: viewportFamily,
      ) !=
      _compactAnswerListNoPressureReasonV1;
}

bool _usesCompactAnswerListDockV1(
  BuildContext context, {
  required _RunnerInteractionModeV1 interactionMode,
  required Act0RunnerFramingProfileV1 framingProfile,
}) {
  return _compactAnswerListPressureReasonV1(
        context,
        interactionMode: interactionMode,
        framingProfile: framingProfile,
      ) !=
      _compactAnswerListNoPressureReasonV1;
}

bool _usesCompactAnswerListLeafFallbackV1(BuildContext context) {
  final media = MediaQuery.of(context);
  return media.size.width < media.size.height && media.size.height <= 900;
}

bool _viewportFamilyUsesAnswerListCompositionV1(
  _RunnerViewportFamilyV1 viewportFamily,
) {
  return switch (viewportFamily) {
    _RunnerViewportFamilyV1.answerListBoardHeroPot ||
    _RunnerViewportFamilyV1.answerListHeroAction => true,
    _RunnerViewportFamilyV1.tableTapSeatFocus ||
    _RunnerViewportFamilyV1.neutral => false,
  };
}

String _stableViewportPressureReasonV1(
  BuildContext context, {
  required _RunnerViewportFamilyV1 viewportFamily,
}) {
  return switch (viewportFamily) {
    _RunnerViewportFamilyV1.answerListBoardHeroPot =>
      _compactAnswerListPressureReasonV1(
        context,
        interactionMode: _RunnerInteractionModeV1.answerListDecision,
        framingProfile: Act0RunnerFramingProfileV1.boardHeroPot,
      ),
    _RunnerViewportFamilyV1.answerListHeroAction =>
      _compactAnswerListPressureReasonV1(
        context,
        interactionMode: _RunnerInteractionModeV1.answerListDecision,
        framingProfile: Act0RunnerFramingProfileV1.heroAction,
      ),
    _RunnerViewportFamilyV1.tableTapSeatFocus ||
    _RunnerViewportFamilyV1.neutral => _compactAnswerListNoPressureReasonV1,
  };
}

const String _compactAnswerListNoPressureReasonV1 = 'none';
const String _compactAnswerListTableDockPressureReasonV1 = 'tableDockPressure';
const double _compactAnswerListPhoneMaxShortestSideV1 = 600;
const double _compactAnswerListUsableHeightBudgetV1 = 900;
const double _compactAnswerListStageFillAspectV1 = 0.66;
const double _runnerProgressRowHeightV1 = 34;
const double _runnerEnvelopeWave1bMinLowerSlotHeightV1 = 365;
const double _runnerEnvelopeWave1bTargetLowerSlotHeightV1 = 405;
const double _runnerEnvelopeWave1bTargetLowerSlotShareV1 = 0.50;
const double _runnerEnvelopeWave1bMaxLowerSlotShareV1 = 0.54;
const double _runnerShortAnswerEnvelopeMinLowerSlotHeightV1 = 300;
const double _runnerShortAnswerEnvelopeTargetLowerSlotHeightV1 = 320;
const double _runnerShortAnswerEnvelopeMaxLowerSlotShareV1 = 0.47;
const double _runnerRepairEnvelopeMinLowerSlotHeightV1 = 320;
const double _runnerRepairEnvelopeTargetLowerSlotHeightV1 = 420;
const double _runnerRepairEnvelopeTargetLowerSlotShareV1 = 0.40;
const double _runnerRepairEnvelopeMaxLowerSlotShareV1 = 0.46;
// The miss/repair header is part of the learning proof, not expendable scroll
// content. Reserve enough of a compact phone for it to clear the table seam
// while keeping the action CTA in the same viewport.
const double _runnerRepairFeedbackDockMinLowerSlotHeightV1 = 360;
const double _runnerRepairFeedbackDockTargetLowerSlotHeightV1 = 420;
const double _runnerRepairFeedbackDockTargetLowerSlotShareV1 = 0.40;
const double _runnerRepairFeedbackDockMaxLowerSlotShareV1 = 0.52;
const double _runnerCompactSeatTapMinLowerSlotHeightV1 = 220;
const double _runnerCompactSeatTapTargetLowerSlotHeightV1 = 248;
const double _runnerCompactSeatTapMaxLowerSlotShareV1 = 0.38;
const double _runnerCompactFeedbackMinLowerSlotHeightV1 = 240;

String _compactAnswerListPressureReasonV1(
  BuildContext context, {
  required _RunnerInteractionModeV1 interactionMode,
  required Act0RunnerFramingProfileV1 framingProfile,
}) {
  if (interactionMode != _RunnerInteractionModeV1.answerListDecision) {
    return _compactAnswerListNoPressureReasonV1;
  }
  if (!_answerListProfileNeedsProtectedTableV1(framingProfile)) {
    return _compactAnswerListNoPressureReasonV1;
  }

  final media = MediaQuery.of(context);
  final isPortrait = media.size.width < media.size.height;
  final isPhoneWidth =
      media.size.shortestSide <= _compactAnswerListPhoneMaxShortestSideV1;
  if (!isPortrait || !isPhoneWidth) {
    return _compactAnswerListNoPressureReasonV1;
  }

  final view = View.maybeOf(context);
  final viewPaddingVertical = view == null
      ? 0.0
      : (view.viewPadding.top + view.viewPadding.bottom) /
            view.devicePixelRatio;
  final safeAreaVertical = <double>[
    media.viewPadding.top + media.viewPadding.bottom,
    media.padding.top + media.padding.bottom,
    viewPaddingVertical,
  ].reduce((value, element) => value > element ? value : element);
  final usableHeight = media.size.height - safeAreaVertical;
  if (usableHeight <= _compactAnswerListUsableHeightBudgetV1) {
    return _compactAnswerListTableDockPressureReasonV1;
  }
  return _compactAnswerListNoPressureReasonV1;
}

bool _usesShortSafeCompactAnswerListEnvelopeV1(
  BuildContext context, {
  required List<Act0RunnerOptionV1> options,
}) {
  if (options.length != 4) {
    return false;
  }
  return options.every((option) {
    final label = act0RuntimeLocalizedOptionLabelV1(
      context,
      option.label,
    ).trim();
    return option.amountLabel.trim().isEmpty && label.length <= 36;
  });
}

bool _answerListProfileNeedsProtectedTableV1(
  Act0RunnerFramingProfileV1 framingProfile,
) {
  return switch (framingProfile) {
    Act0RunnerFramingProfileV1.boardHeroPot ||
    Act0RunnerFramingProfileV1.boardOnly ||
    Act0RunnerFramingProfileV1.heroAction ||
    Act0RunnerFramingProfileV1.seatFocus => true,
    Act0RunnerFramingProfileV1.neutral => false,
  };
}

class _DockBackButtonV1 extends StatelessWidget {
  const _DockBackButtonV1({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: Act0ShellTokensV1.quietButtonStyle().copyWith(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          side: WidgetStatePropertyAll(
            BorderSide(color: Act0ShellTokensV1.border.withValues(alpha: 0.82)),
          ),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
      ),
    );
  }
}

List<Offset> _seatSlotsForVariant(
  Act0ShellTableVisualVariantV1 variant, {
  bool compactBottomDockClearance = false,
  bool useAnswerListPerimeterRing = false,
}) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _SeatPlacementV1.defaultSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
      if (compactBottomDockClearance) {
        final heroY = useAnswerListPerimeterRing ? 0.86 : 0.80;
        return <Offset>[
          Offset(0.47, heroY),
          Offset(0.08, 0.69),
          Offset(0.08, 0.31),
          Offset(0.47, 0.06),
          Offset(0.86, 0.31),
          Offset(0.86, 0.69),
        ];
      }
      return const <Offset>[
        Offset(0.50, 0.91),
        Offset(0.12, 0.75),
        Offset(0.12, 0.33),
        Offset(0.50, 0.12),
        Offset(0.88, 0.33),
        Offset(0.88, 0.75),
      ];
  }
}

List<Offset> _chipSlotsForVariant(
  Act0ShellTableVisualVariantV1 variant, {
  bool compactBottomDockClearance = false,
}) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _BetChipPlacementV1.defaultChipSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
      if (compactBottomDockClearance) {
        return const <Offset>[
          Offset(0.50, 0.62),
          Offset(0.20, 0.55),
          Offset(0.22, 0.45),
          Offset(0.50, 0.29),
          Offset(0.80, 0.39),
          Offset(0.84, 0.59),
        ];
      }
      return const <Offset>[
        Offset(0.50, 0.71),
        Offset(0.24, 0.64),
        Offset(0.26, 0.30),
        Offset(0.50, 0.29),
        Offset(0.74, 0.30),
        Offset(0.76, 0.64),
      ];
  }
}

List<Act0SeatStateV1> _visualSeatOrder(List<Act0SeatStateV1> seats) {
  final canonicalOrder = _inferCanonicalSeatOrder(seats);
  final byLabel = <String, Act0SeatStateV1>{
    for (final seat in seats) seat.seatLabel.toUpperCase(): seat,
  };
  final hero = seats.where((seat) => seat.isHero).toList(growable: false);
  final heroLabel = hero.isEmpty
      ? canonicalOrder.first
      : hero.first.seatLabel.toUpperCase();
  final heroIndex = canonicalOrder.indexOf(heroLabel);
  final start = heroIndex < 0 ? 0 : heroIndex;
  final canonicalSeats = <Act0SeatStateV1>[
    for (var i = 0; i < canonicalOrder.length; i++)
      if (byLabel[canonicalOrder[(start + i) % canonicalOrder.length]] != null)
        byLabel[canonicalOrder[(start + i) % canonicalOrder.length]]!,
  ];
  if (canonicalSeats.isEmpty) {
    final others = seats.where((seat) => !seat.isHero).toList(growable: false);
    return <Act0SeatStateV1>[...hero, ...others];
  }
  final canonicalIds = canonicalSeats.map((seat) => seat.seatId).toSet();
  return <Act0SeatStateV1>[
    ...canonicalSeats,
    for (final seat in seats)
      if (!canonicalIds.contains(seat.seatId)) seat,
  ];
}

List<String> _inferCanonicalSeatOrder(List<Act0SeatStateV1> seats) {
  final labels = seats.map((seat) => seat.seatLabel.toUpperCase()).toSet();
  for (final format in Act0TableFormatV1.values) {
    final order = act0CanonicalSeatOrderForFormatV1(format);
    if (labels.every(order.contains)) {
      return order;
    }
  }
  return act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.sixMax);
}

class _CenterPotV1 extends StatelessWidget {
  const _CenterPotV1({
    required this.table,
    required this.highlightedCardIds,
    required this.onBoardCardTap,
    required this.visualVariant,
    this.showFocusBadge = true,
    this.centerLabelOverride,
    this.lateRouteSignal,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final VoidCallback onBoardCardTap;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final String? centerLabelOverride;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final resolvedCenterLabel = (centerLabelOverride ?? table.centerLabel)
        .trim();
    final shouldShowFocusBadge =
        (showFocusBadge || _isSafePriorActionTableCueV1(resolvedCenterLabel)) &&
        resolvedCenterLabel.isNotEmpty &&
        !(refined &&
            (resolvedCenterLabel == 'Blinds posted' ||
                resolvedCenterLabel == 'Action on hero'));
    final streetLabel = act0RuntimeLocalizedStreetLabelV1(
      context,
      streetLabelOverride ?? table.streetLabel,
    ).toUpperCase();
    final resolvedToCallLabel = (toCallLabelOverride ?? table.toCallLabel)
        .trim();
    final usesCompactCenterSafeLane =
        refined && table.density == Act0TableDensityV1.compactLesson;
    final centerCard = Container(
      key: const Key('act0_shell_center_info_card'),
      width: refined ? 182 : Act0ShellTokensV1.centerInfoWidth,
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 6 : 4,
        vertical: refined ? 4 : 3,
      ),
      decoration: refined ? Act0ShellTokensV1.onFeltPanelDecoration() : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            key: const Key('act0_shell_wave1_status_cluster'),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (usesCompactCenterSafeLane)
                Column(
                  key: const Key('act0_shell_wave1b_status_lane'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (lateRouteSignal != null) ...[
                      _LateRouteCenterSignalV1(signal: lateRouteSignal!),
                    ] else if (shouldShowFocusBadge) ...[
                      _CenterSignalAnchorV1(
                        label: act0RuntimeLocalizedCenterLabelV1(
                          context,
                          resolvedCenterLabel,
                        ),
                        compact: refined,
                      ),
                    ],
                    const SizedBox(height: 3),
                    _CenterStreetStatusV1(label: streetLabel, compact: refined),
                  ],
                )
              else
                Wrap(
                  key: const Key('act0_shell_wave1b_status_lane'),
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5,
                  runSpacing: 3,
                  children: [
                    if (lateRouteSignal != null) ...[
                      _LateRouteCenterSignalV1(signal: lateRouteSignal!),
                    ] else if (shouldShowFocusBadge) ...[
                      _CenterSignalAnchorV1(
                        label: act0RuntimeLocalizedCenterLabelV1(
                          context,
                          resolvedCenterLabel,
                        ),
                        compact: refined,
                      ),
                    ],
                    _CenterStreetStatusV1(label: streetLabel, compact: refined),
                  ],
                ),
            ],
          ),
          if (table.boardCards.isNotEmpty) ...[
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < table.boardCards.length; i++) ...[
                    _BoardCardV1(
                      card: table.boardCards[i],
                      cardId: 'board_$i',
                      highlighted: highlightedCardIds.contains('board_$i'),
                      onTap: onBoardCardTap,
                    ),
                    if (i < table.boardCards.length - 1)
                      const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 3,
            children: [
              _CenterPriorityStatV1(
                key: const Key('act0_shell_wave1_pot_priority_stat'),
                legacyKey: const Key('act0_shell_center_pot_stat'),
                label: act0RuntimeLocalizedPotLabelV1(
                  context,
                  potLabelOverride ?? table.potLabel,
                ),
                tone: Act0ShellTokensV1.text,
                icon: Icons.casino_rounded,
                compact: refined,
                pulse: table.actionTrail.isNotEmpty,
              ),
              if (resolvedToCallLabel.isNotEmpty)
                _CenterPriorityStatV1(
                  key: const Key('act0_shell_wave1_price_priority_stat'),
                  legacyKey: const Key('act0_shell_center_to_call_stat'),
                  label: act0RuntimeLocalizedToCallLabelV1(
                    context,
                    resolvedToCallLabel,
                  ),
                  tone: Act0ShellTokensV1.info,
                  icon: Icons.arrow_downward_rounded,
                  compact: refined,
                ),
            ],
          ),
        ],
      ),
    );

    final resolvedCenterCard = refined
        ? ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: centerCard,
            ),
          )
        : centerCard;

    return Center(child: resolvedCenterCard);
  }
}

class _LateRouteCenterSignalV1 extends StatelessWidget {
  const _LateRouteCenterSignalV1({required this.signal});

  final Act0LateRouteTableSignalV1 signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_late_route_table_signal'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(signal.icon, size: 11, color: Act0ShellTokensV1.gold),
          const SizedBox(width: 4),
          Text(
            signal.label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              fontSize: 8.5,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterSignalAnchorV1 extends StatelessWidget {
  const _CenterSignalAnchorV1({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('act0_shell_wave1_table_signal_anchor'),
      child: Tooltip(
        message: 'Table clue',
        child: Container(
          key: const Key('act0_shell_wave1b_table_signal_chip'),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 9,
            vertical: compact ? 3.5 : 4.5,
          ),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.primary.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            border: Border.all(
              color: Act0ShellTokensV1.primary.withValues(alpha: 0.30),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Act0ShellTokensV1.primary.withValues(alpha: 0.08),
                blurRadius: compact ? 5 : 7,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                // Compact seats leave a fixed center lane between BB and HJ.
                // The full two-line label owns that lane; the decorative eye
                // did not, and was pushing the chip into both seat cards.
                constraints: BoxConstraints(maxWidth: compact ? 80 : 118),
                child: Text(
                  label,
                  key: const Key('act0_shell_wave1b_table_signal_text'),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontSize: compact ? 8.8 : 9.6,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(
                key: Key('act0_shell_center_focus_badge'),
                width: 0,
                height: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterStreetStatusV1 extends StatelessWidget {
  const _CenterStreetStatusV1({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_center_street_badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers_rounded,
            color: Act0ShellTokensV1.gold.withValues(alpha: 0.92),
            size: compact ? 9 : 10,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold.withValues(alpha: 0.94),
              fontSize: compact ? 7.8 : 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterPriorityStatV1 extends StatelessWidget {
  const _CenterPriorityStatV1({
    super.key,
    required this.legacyKey,
    required this.label,
    required this.tone,
    required this.icon,
    required this.compact,
    this.pulse = false,
  });

  final Key legacyKey;
  final String label;
  final Color tone;
  final IconData icon;
  final bool compact;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final stat = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4.5 : 5.5,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 12, color: tone),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                fontSize: compact ? 8.8 : 9.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
    final keyedStat = KeyedSubtree(key: legacyKey, child: stat);
    if (!pulse) {
      return keyedStat;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.97, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: keyedStat,
    );
  }
}

class _BetChipPlacementV1 extends StatelessWidget {
  const _BetChipPlacementV1({
    required this.slot,
    required this.seat,
    required this.tableWidth,
    required this.tableHeight,
    required this.chipSlots,
    required this.seatSlots,
    required this.visualVariant,
    required this.animateMotion,
    this.betOverride,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final double tableWidth;
  final double tableHeight;
  final List<Offset> chipSlots;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool animateMotion;

  /// When non-null, shown instead of seat.bet (used during action trail playback).
  final Act0SeatBetStateV1? betOverride;

  static const List<Offset> defaultChipSlots = <Offset>[
    Offset(0.50, 0.75),
    Offset(0.055, 0.60),
    Offset(0.055, 0.50),
    Offset(0.50, 0.25),
    Offset(0.945, 0.50),
    Offset(0.945, 0.60),
  ];

  @override
  Widget build(BuildContext context) {
    final bet = betOverride ?? seat.bet;
    if (bet == null || seat.isFolded) {
      return const SizedBox.shrink();
    }
    final safeSlot = slot.clamp(0, chipSlots.length - 1);
    final chipPoint = chipSlots[safeSlot];
    final seatPoint = seatSlots[safeSlot.clamp(0, seatSlots.length - 1)];
    final child = KeyedSubtree(
      key: Key('act0_shell_bet_chip_owner_${seat.seatId}'),
      child: _BetChipV1(
        bet: bet,
        compact: visualVariant == Act0ShellTableVisualVariantV1.refinedDev2,
      ),
    );
    if (!animateMotion) {
      return Positioned(
        left: tableWidth * chipPoint.dx,
        top: tableHeight * chipPoint.dy,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: IgnorePointer(child: child),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      key: Key('act0_shell_bet_chip_motion_${seat.seatId}_${bet.label}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _chipMotionDuration(bet.kind),
      curve: bet.kind == Act0SeatBetKindV1.post
          ? Curves.easeInOutCubic
          : Curves.easeOutCubic,
      builder: (context, value, child) {
        final point = Offset.lerp(seatPoint, chipPoint, value) ?? chipPoint;
        return Positioned(
          left: tableWidth * point.dx,
          top: tableHeight * point.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: IgnorePointer(
              child: Transform.scale(
                scale: 0.94 + (0.06 * value),
                child: Opacity(opacity: 0.72 + (0.28 * value), child: child),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  Duration _chipMotionDuration(Act0SeatBetKindV1 kind) {
    return switch (kind) {
      Act0SeatBetKindV1.post => const Duration(milliseconds: 380),
      Act0SeatBetKindV1.call => const Duration(milliseconds: 360),
      Act0SeatBetKindV1.bet ||
      Act0SeatBetKindV1.raise ||
      Act0SeatBetKindV1.allIn => const Duration(milliseconds: 440),
    };
  }
}

class _SeatPlacementV1 extends StatelessWidget {
  const _SeatPlacementV1({
    required this.slot,
    required this.seat,
    required this.heroCards,
    required this.highlightedCardIds,
    required this.active,
    required this.emphasized,
    required this.hero,
    required this.selectable,
    required this.visualState,
    required this.decisionPriceOwnedByTable,
    required this.onChooseSeat,
    required this.tableWidth,
    required this.tableHeight,
    required this.seatSlots,
    required this.visualVariant,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.depthTieredPrototype = false,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final List<Act0CardStateV1> heroCards;
  final List<String> highlightedCardIds;
  final bool active;
  final bool emphasized;
  final bool hero;
  final bool selectable;
  final _SeatVisualStateV1 visualState;
  final bool decisionPriceOwnedByTable;
  final ValueChanged<String>? onChooseSeat;
  final double tableWidth;
  final double tableHeight;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final bool depthTieredPrototype;

  static const List<Offset> defaultSlots = <Offset>[
    Offset(0.50, 0.90),
    Offset(0.08, 0.72),
    Offset(0.06, 0.36),
    Offset(0.50, 0.08),
    Offset(0.94, 0.36),
    Offset(0.92, 0.72),
  ];

  @override
  Widget build(BuildContext context) {
    final point = seatSlots[slot.clamp(0, seatSlots.length - 1)];
    final tierScale = !depthTieredPrototype
        ? 1.0
        : point.dy >= 0.68
        ? 1.05
        : point.dy <= 0.34
        ? 0.91
        : 0.97;
    return Positioned(
      left: tableWidth * point.dx,
      top: tableHeight * point.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.scale(
          key: Key(
            'act0_integrated_scene_depth_${point.dy >= 0.68
                ? 'near'
                : point.dy <= 0.34
                ? 'far'
                : 'mid'}_${seat.seatId}',
          ),
          scale: tierScale,
          child: _SeatNodeV1(
            seat: seat,
            heroCards: heroCards,
            highlightedCardIds: highlightedCardIds,
            active: active,
            emphasized: emphasized,
            hero: hero,
            selectable: selectable,
            visualState: visualState,
            decisionPriceOwnedByTable: decisionPriceOwnedByTable,
            visualVariant: visualVariant,
            identityPolicy: identityPolicy,
            onTap: selectable && onChooseSeat != null
                ? () => onChooseSeat!(seat.seatId)
                : null,
            compact: slot != 0,
          ),
        ),
      ),
    );
  }
}

class _SeatNodeV1 extends StatelessWidget {
  const _SeatNodeV1({
    required this.seat,
    required this.heroCards,
    required this.highlightedCardIds,
    required this.active,
    required this.emphasized,
    required this.hero,
    required this.selectable,
    required this.visualState,
    required this.decisionPriceOwnedByTable,
    required this.visualVariant,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.onTap,
    this.compact = false,
  });

  final Act0SeatStateV1 seat;
  final List<Act0CardStateV1> heroCards;
  final List<String> highlightedCardIds;
  final bool active;
  final bool emphasized;
  final bool hero;
  final bool selectable;
  final _SeatVisualStateV1 visualState;
  final bool decisionPriceOwnedByTable;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final seatVisualState = visualState;
    final markerDisplay = _resolveSeatMarkerDisplayV1(
      context,
      seat: seat,
      active: active,
      hero: hero,
      refined: refined,
      decisionPriceOwnedByTable: decisionPriceOwnedByTable,
      identityPolicy: identityPolicy,
    );
    final stackLabel = (seat.stackLabel ?? '').trim();
    final showsOpponentStack =
        !hero && stackLabel.isNotEmpty && markerDisplay.subLabel == stackLabel;
    final highlighted = switch (seatVisualState) {
      _SeatVisualStateV1.passive || _SeatVisualStateV1.selectable => false,
      _ => true,
    };
    final useSlimRefinedSeat = refined && !hero;
    final folded = seat.isFolded;
    final isPassive = seatVisualState == _SeatVisualStateV1.passive;
    final primaryLabelColor = hero
        ? Act0ShellTokensV1.text
        : isPassive
        ? (refined ? Act0ShellTokensV1.textDim : Act0ShellTokensV1.textMuted)
        : (refined ? Act0ShellTokensV1.textMuted : Act0ShellTokensV1.text);
    final subLabelColor = hero
        ? Act0ShellTokensV1.textMuted
        : isPassive
        ? (refined
              ? Act0ShellTokensV1.textDim.withValues(alpha: 0.65)
              : Act0ShellTokensV1.textDim)
        : (refined ? Act0ShellTokensV1.textDim : Act0ShellTokensV1.textMuted);
    final borderColor = _seatBorderColorV1(seatVisualState, refined: refined);
    final ringColor = _seatRingColorV1(seatVisualState);
    // A selectable seat is an answer control. It receives the same bounded
    // outer affordance plane as focus states, while its cyan tone remains
    // distinct from gold target/current-player and correctness semantics.
    final shouldShowRing = seatVisualState != _SeatVisualStateV1.passive;
    final visibleCards = hero ? heroCards : seat.holeCards;
    final showFaceDown =
        !hero &&
        seat.isOccupied &&
        seat.isInHand &&
        !folded &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceDown &&
        visibleCards.isNotEmpty;
    final showFaceUp =
        !hero &&
        seat.isOccupied &&
        seat.isInHand &&
        !folded &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp &&
        visibleCards.isNotEmpty;
    final occupiedOpacity = !seat.isOccupied
        ? 0.42
        : folded || !seat.isInHand
        ? 0.58
        : 1.0;
    final node = Container(
      key: Key('act0_shell_seat_node_${seat.seatId}'),
      constraints: BoxConstraints(
        minWidth: compact
            ? Act0ShellTokensV1.compactSeatMinWidth
            : Act0ShellTokensV1.seatMinWidth,
      ),
      child: Opacity(
        opacity: occupiedOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hero && visibleCards.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    _CardV1(
                      card: visibleCards[i],
                      cardId: 'hero_$i',
                      highlighted: highlightedCardIds.contains('hero_$i'),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 4),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ] else if (showFaceDown) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    Transform.rotate(
                      angle: i == 0 ? -0.06 : 0.06,
                      child: const _MiniCardBackV1(),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 2),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ] else if (showFaceUp) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    _CardV1(
                      card: visibleCards[i],
                      cardId: '${seat.seatId}_$i',
                      highlighted: highlightedCardIds.contains(
                        '${seat.seatId}_$i',
                      ),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 3),
                  ],
                ],
              ),
              const SizedBox(height: 3),
            ],
            if (folded) ...[const _FoldedBadgeV1(), const SizedBox(height: 3)],
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: hero
                      ? Key('act0_shell_hero_identity_${seat.seatId}')
                      : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact
                        ? (refined ? 5 : 7)
                        : (useSlimRefinedSeat ? 7 : (refined ? 9 : 8)),
                    vertical: useSlimRefinedSeat ? 5 : (refined ? 6 : 5),
                  ),
                  decoration: BoxDecoration(
                    color: refined
                        ? (seatVisualState == _SeatVisualStateV1.hero
                              ? Act0ShellTokensV1.runnerPanelSurface
                              : highlighted
                              ? Act0ShellTokensV1.surface2
                              : Act0ShellTokensV1.surface.withValues(
                                  alpha: 0.78,
                                ))
                        : highlighted
                        ? Act0ShellTokensV1.surface2
                        : Act0ShellTokensV1.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusSm,
                    ),
                    border: Border.all(
                      color: borderColor.withValues(alpha: refined ? 0.86 : 1),
                      width: refined ? 1.15 : 1,
                    ),
                    boxShadow: <BoxShadow>[
                      if (shouldShowRing)
                        BoxShadow(
                          color: ringColor.withValues(
                            alpha: seatVisualState == _SeatVisualStateV1.hero
                                ? 0.12
                                : 0.16,
                          ),
                          blurRadius: refined ? 10 : 14,
                        ),
                      if (!shouldShowRing &&
                          seatVisualState == _SeatVisualStateV1.hero)
                        BoxShadow(
                          color: Act0ShellTokensV1.primary.withValues(
                            alpha: 0.15,
                          ),
                          blurRadius: refined ? 9 : 12,
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: compact
                            ? (refined ? 18 : 22)
                            : (useSlimRefinedSeat ? 22 : (refined ? 26 : 24)),
                        height: compact
                            ? (refined ? 18 : 22)
                            : (useSlimRefinedSeat ? 22 : (refined ? 26 : 24)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: hero
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Act0ShellTokensV1.runnerTagBlue,
                                    Act0ShellTokensV1.runnerSharkBlueDark,
                                  ],
                                )
                              : null,
                          color: hero
                              ? null
                              : refined
                              ? (seatVisualState ==
                                        _SeatVisualStateV1.selectable
                                    ? Act0ShellTokensV1.info.withValues(
                                        alpha: 0.10,
                                      )
                                    : Act0ShellTokensV1.surface2)
                              : Act0ShellTokensV1.surface3,
                          borderRadius: BorderRadius.circular(
                            refined
                                ? Act0ShellTokensV1.radiusXs
                                : Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: hero
                                ? Act0ShellTokensV1.gold.withValues(alpha: 0.86)
                                : refined
                                ? Act0ShellTokensV1.border.withValues(
                                    alpha: 0.72,
                                  )
                                : Colors.transparent,
                            width: hero ? 1.2 : 1.0,
                          ),
                          boxShadow: hero
                              ? const <BoxShadow>[
                                  BoxShadow(
                                    color: Act0ShellTokensV1.shadowSoftStrong,
                                    blurRadius: 3,
                                    offset: Offset(0, 1.5),
                                  ),
                                ]
                              : null,
                        ),
                        child: hero
                            ? KeyedSubtree(
                                key: const Key(
                                  'act0_shell_wave1_hero_you_badge',
                                ),
                                child: FittedBox(
                                  key: const Key(
                                    'act0_shell_wave1b_hero_badge',
                                  ),
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'You',
                                    style: Act0ShellTokensV1.label.copyWith(
                                      color: Act0ShellTokensV1.onPrimary,
                                      fontSize: refined ? 7.2 : 7.6,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              )
                            : Icon(
                                seat.isOccupied
                                    ? Icons.person_rounded
                                    : Icons.circle_outlined,
                                size: useSlimRefinedSeat
                                    ? 11
                                    : (refined ? 12 : 13),
                                color:
                                    seatVisualState ==
                                        _SeatVisualStateV1.selectable
                                    ? Act0ShellTokensV1.info.withValues(
                                        alpha: 0.56,
                                      )
                                    : refined
                                    ? Act0ShellTokensV1.textDim
                                    : Act0ShellTokensV1.textMuted,
                              ),
                      ),
                      SizedBox(width: useSlimRefinedSeat ? 4 : 5),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act0RuntimeLocalizedSeatPrimaryLabelV1(
                              context,
                              seat: seat,
                              hero: hero,
                              refined: refined,
                              identityPolicy: identityPolicy,
                            ),
                            maxLines: 2,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: primaryLabelColor,
                              fontSize: useSlimRefinedSeat
                                  ? 8.5
                                  : (refined ? 9.0 : 10),
                              letterSpacing: refined ? 0.1 : 0.4,
                            ),
                          ),
                          if (markerDisplay.subLabel != null)
                            KeyedSubtree(
                              key: showsOpponentStack
                                  ? Key(
                                      'act0_shell_opponent_stack_${seat.seatId}',
                                    )
                                  : null,
                              child: Text(
                                markerDisplay.subLabel!,
                                key: Key(
                                  'act0_shell_seat_sublabel_${seat.seatId}',
                                ),
                                style: Act0ShellTokensV1.muted.copyWith(
                                  fontSize: useSlimRefinedSeat
                                      ? 8.0
                                      : (refined ? 8.5 : 9),
                                  color: subLabelColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (markerDisplay.markers.isNotEmpty)
                  _SeatMarkerPlacementV1(
                    seatId: seat.seatId,
                    leftSide: seat.seatLabel == 'SB' || seat.seatLabel == 'BB',
                    markers: markerDisplay.markers,
                    hero: hero,
                    visualVariant: visualVariant,
                  ),
                if (shouldShowRing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        key: const Key('act0_shell_active_seat_ring'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusSm,
                          ),
                          border: Border.all(
                            color: ringColor.withValues(alpha: 0.42),
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          key: Key(
                            'act0_shell_active_seat_ring_${seat.seatId}',
                          ),
                        ),
                      ),
                    ),
                  ),
                if (seatVisualState != _SeatVisualStateV1.passive)
                  Positioned(
                    child: SizedBox(
                      key: Key(
                        'act0_shell_seat_state_${seat.seatId}_${seatVisualState.name}',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (onTap == null) {
      return node;
    }
    return GestureDetector(
      key: Key('act0_shell_seat_tap_${seat.seatId}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Center(child: node),
      ),
    );
  }
}

enum _SeatSelectionFeedbackStateV1 { none, wrong, confirmed }

enum _PrimarySeatFocusKindV1 { none, active, target }

class _PrimarySeatFocusResolutionV1 {
  const _PrimarySeatFocusResolutionV1({required this.kind, this.seatId});

  final _PrimarySeatFocusKindV1 kind;
  final String? seatId;
}

enum _SeatVisualStateV1 {
  wrongSelected,
  confirmedSelected,
  hero,
  activeFocus,
  targetFocus,
  selectable,
  passive,
}

enum _SeatMarkerKindV1 { dealer, smallBlind, bigBlind, aggressor, act }

class _SeatMarkerDisplayV1 {
  const _SeatMarkerDisplayV1({required this.markers, this.subLabel});

  final List<_SeatMarkerKindV1> markers;
  final String? subLabel;
}

_PrimarySeatFocusResolutionV1 _resolvePrimarySeatFocusV1({
  required String? activeSeatId,
  required List<String> highlightedSeatIds,
  required List<String> selectableSeatIds,
  required String? selectedSeatId,
  required _SeatSelectionFeedbackStateV1 selectionFeedbackState,
}) {
  final normalizedHighlights = highlightedSeatIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList(growable: false);
  final normalizedSelectable = selectableSeatIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  final explicitTargets = normalizedHighlights
      .where((id) => normalizedSelectable.contains(id))
      .toList(growable: false);
  final selected = (selectedSeatId ?? '').trim();

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.confirmed &&
      selected.isNotEmpty) {
    return const _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.none,
    );
  }

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.wrong) {
    final repairTargets = normalizedHighlights
        .where((id) => id != selected)
        .toList(growable: false);
    if (repairTargets.length == 1) {
      return _PrimarySeatFocusResolutionV1(
        kind: _PrimarySeatFocusKindV1.target,
        seatId: repairTargets.first,
      );
    }
  }

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.none) {
    final active = (activeSeatId ?? '').trim();
    if (active.isNotEmpty) {
      return _PrimarySeatFocusResolutionV1(
        kind: _PrimarySeatFocusKindV1.active,
        seatId: active,
      );
    }
  }

  if (explicitTargets.length == 1) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.target,
      seatId: explicitTargets.first,
    );
  }

  if (normalizedHighlights.length == 1) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.target,
      seatId: normalizedHighlights.first,
    );
  }

  return const _PrimarySeatFocusResolutionV1(
    kind: _PrimarySeatFocusKindV1.none,
  );
}

_SeatVisualStateV1 _resolveSeatVisualStateV1({
  required String seatId,
  required bool hero,
  required bool selectable,
  required bool selected,
  required _SeatSelectionFeedbackStateV1 selectionFeedbackState,
  required _PrimarySeatFocusResolutionV1 focusResolution,
}) {
  if (selected &&
      selectionFeedbackState == _SeatSelectionFeedbackStateV1.wrong) {
    return _SeatVisualStateV1.wrongSelected;
  }
  if (selected &&
      selectionFeedbackState == _SeatSelectionFeedbackStateV1.confirmed) {
    return _SeatVisualStateV1.confirmedSelected;
  }
  if (hero) {
    return _SeatVisualStateV1.hero;
  }
  if (focusResolution.kind == _PrimarySeatFocusKindV1.active &&
      focusResolution.seatId == seatId) {
    return _SeatVisualStateV1.activeFocus;
  }
  if (focusResolution.kind == _PrimarySeatFocusKindV1.target &&
      focusResolution.seatId == seatId) {
    return _SeatVisualStateV1.targetFocus;
  }
  if (selectable) {
    return _SeatVisualStateV1.selectable;
  }
  return _SeatVisualStateV1.passive;
}

bool _seatHasBlindPostChipV1(Act0SeatStateV1 seat) {
  final bet = seat.bet;
  return bet != null &&
      bet.kind == Act0SeatBetKindV1.post &&
      !seat.isFolded &&
      (bet.label == 'SB' || bet.label == 'BB' || bet.label == 'POST');
}

bool _seatCurrentBetIsOwnedByChipV1(Act0SeatStateV1 seat) {
  final bet = seat.bet;
  final currentBetLabel = seat.currentBetLabel?.trim() ?? '';
  if (bet == null || currentBetLabel.isEmpty || seat.isFolded) {
    return false;
  }
  return currentBetLabel == bet.amountLabel.trim();
}

String _localizedSeatRoleLabelV1(
  BuildContext context, {
  required String atomId,
  required String fallback,
}) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

_SeatMarkerDisplayV1 _resolveSeatMarkerDisplayV1(
  BuildContext context, {
  required Act0SeatStateV1 seat,
  required bool active,
  required bool hero,
  required bool refined,
  required bool decisionPriceOwnedByTable,
  required Act0TableIdentityPolicyV1 identityPolicy,
}) {
  final markers = <_SeatMarkerKindV1>[
    if (seat.isDealerButton &&
        (identityPolicy == Act0TableIdentityPolicyV1.currentProduction ||
            identityPolicy == Act0TableIdentityPolicyV1.learnerPosition ||
            identityPolicy ==
                Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder))
      _SeatMarkerKindV1.dealer,
    if (!refined && seat.isSmallBlind && !_seatHasBlindPostChipV1(seat))
      _SeatMarkerKindV1.smallBlind,
    if (!refined && seat.isBigBlind && !_seatHasBlindPostChipV1(seat))
      _SeatMarkerKindV1.bigBlind,
    if (seat.isLastAggressor && !active) _SeatMarkerKindV1.aggressor,
    // Active seats retain the amber focus ring and the semantic To act
    // sublabel. An additional Act badge repeats that same state.
  ];
  final stackLabel = (seat.stackLabel ?? '').trim();

  if (!hero && active) {
    if (decisionPriceOwnedByTable) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: stackLabel.isEmpty ? null : stackLabel,
      );
    }
    final toActAmountLabel =
        (seat.currentBetLabel ?? seat.blindAmountLabel ?? '').trim();
    final toAct = _localizedSeatRoleLabelV1(
      context,
      atomId: 'table_word_to_act',
      fallback: 'To act',
    );
    return _SeatMarkerDisplayV1(
      markers: markers,
      subLabel: toActAmountLabel.isEmpty ? toAct : '$toAct: $toActAmountLabel',
    );
  }

  if (stackLabel.isNotEmpty) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: stackLabel);
  }

  if (_seatCurrentBetIsOwnedByChipV1(seat) || _seatHasBlindPostChipV1(seat)) {
    return _SeatMarkerDisplayV1(markers: markers);
  }

  final currentBetLabel = (seat.currentBetLabel ?? '').trim();
  if (currentBetLabel.isNotEmpty) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: currentBetLabel);
  }

  final blindAmountLabel = (seat.blindAmountLabel ?? '').trim();
  if (blindAmountLabel.isNotEmpty && !_seatHasBlindPostChipV1(seat)) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: blindAmountLabel);
  }

  if (refined && !hero) {
    if (seat.isDealerButton) {
      return _SeatMarkerDisplayV1(markers: markers);
    }
    if (seat.isSmallBlind) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: _localizedSeatRoleLabelV1(
          context,
          atomId: 'table_word_small_blind',
          fallback: 'Small blind',
        ),
      );
    }
    if (seat.isBigBlind) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: _localizedSeatRoleLabelV1(
          context,
          atomId: 'table_word_big_blind',
          fallback: 'Big blind',
        ),
      );
    }
  }

  return _SeatMarkerDisplayV1(markers: markers);
}

Color _seatBorderColorV1(_SeatVisualStateV1 state, {required bool refined}) {
  return switch (state) {
    _SeatVisualStateV1.wrongSelected => Act0ShellTokensV1.danger,
    _SeatVisualStateV1.confirmedSelected => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.hero => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.activeFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.targetFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.selectable =>
      refined
          ? Act0ShellTokensV1.info.withValues(alpha: 0.42)
          : Act0ShellTokensV1.info.withValues(alpha: 0.58),
    _SeatVisualStateV1.passive => Act0ShellTokensV1.border,
  };
}

Color _seatRingColorV1(_SeatVisualStateV1 state) {
  return switch (state) {
    _SeatVisualStateV1.wrongSelected => Act0ShellTokensV1.danger,
    _SeatVisualStateV1.confirmedSelected => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.hero => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.activeFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.targetFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.selectable => Act0ShellTokensV1.info,
    _SeatVisualStateV1.passive => Act0ShellTokensV1.border,
  };
}

enum _ActionTrailVariantV1 { compactContext, replay }

enum _RunnerBottomOwnerV1 { coachRail, questionPrompt, feedback }

class _RunnerBottomContextV1 {
  const _RunnerBottomContextV1({
    required this.owner,
    required this.isTrailHistory,
    required this.promptOwnsDecisionContext,
    required this.showActionTrail,
    this.actionTrailVariant,
    required this.taskLabel,
    required this.questionBadgeLabel,
    this.promptSupportLine,
    this.feedbackContextLabels = const <String>[],
  });

  final _RunnerBottomOwnerV1 owner;
  final bool isTrailHistory;
  final bool promptOwnsDecisionContext;
  final bool showActionTrail;
  final _ActionTrailVariantV1? actionTrailVariant;
  final String taskLabel;
  final String questionBadgeLabel;
  final String? promptSupportLine;
  final List<String> feedbackContextLabels;
}

class _CenterStatDisplayV1 {
  const _CenterStatDisplayV1({
    required this.centerCueLabel,
    required this.potLabel,
    required this.toCallLabel,
  });

  final String centerCueLabel;
  final String potLabel;
  final String toCallLabel;

  bool get ownsDecisionPrice => toCallLabel.trim().isNotEmpty;
}

bool _isActiveAssessmentStateV1({
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required Act0RunnerStateV1 runner,
}) {
  return !isTeaching &&
      !isTheory &&
      !isReview &&
      (runner.selectedOptionId ?? '').trim().isEmpty;
}

String _normalizeAnswerLeakTextV1(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _isAnswerBearingTableCueV1({
  required String cueLabel,
  required String question,
  required List<Act0RunnerOptionV1> options,
}) {
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  if (normalizedCue.isEmpty) {
    return false;
  }
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  final optionLabels = <String>{
    for (final option in options) ...[
      _normalizeAnswerLeakTextV1(option.label),
      _normalizeAnswerLeakTextV1(option.preferredLabel),
      _normalizeAnswerLeakTextV1(option.betterAnswerLabel),
    ],
  }..remove('');

  final cueTokens = normalizedCue.split(' ').where((token) => token.isNotEmpty);
  if (optionLabels.contains(normalizedCue)) {
    return true;
  }
  for (final optionLabel in optionLabels) {
    if (optionLabel.isEmpty) {
      continue;
    }
    if (normalizedCue.contains(optionLabel) ||
        optionLabel.contains(normalizedCue)) {
      return true;
    }
  }
  final categoryQuestions = <String>[
    'which bucket',
    'what bucket',
    'which made hand',
    'what made hand',
    'which hand category',
    'what hand category',
    'which hand class',
  ];
  if (categoryQuestions.any(normalizedQuestion.contains)) {
    return cueTokens.any(optionLabels.contains);
  }
  return false;
}

bool _looksLikeActionDecisionPromptV1(
  String question, {
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (hasSeatTargets) {
    return false;
  }
  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.sizing ||
      taskFamily == Act0TaskFamilyV1.repair) {
    return true;
  }
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  return normalizedQuestion.contains('what is the') ||
      normalizedQuestion.contains('best action') ||
      normalizedQuestion.contains('simple action') ||
      normalizedQuestion.contains('simple response') ||
      normalizedQuestion.contains('clean action') ||
      normalizedQuestion.contains('clean response') ||
      normalizedQuestion.contains('disciplined action') ||
      normalizedQuestion.contains('disciplined response') ||
      normalizedQuestion.contains('first in action') ||
      normalizedQuestion.contains('response');
}

bool _isAnswerLeadingTableCueV1(
  String cueLabel, {
  required String question,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final rawCue = cueLabel.trim().toLowerCase();
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  if (normalizedCue.isEmpty) {
    return false;
  }
  final cueKeywords = <String>[
    'weak continue',
    'strong continue',
    'easy fold',
    'call spot',
    'value spot',
    'bluff catch',
    'fold pressure',
    'low fold pressure',
    'one third',
    'half pot',
    'pot size',
    'range bucket',
    'value action',
    'bucket',
  ];
  final isDecisionPrompt = _looksLikeActionDecisionPromptV1(
    question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  );
  if (rawCue.contains('?')) {
    return true;
  }
  if (cueKeywords.any(normalizedCue.contains)) {
    return true;
  }
  if (isDecisionPrompt) {
    const decisionWords = <String>[
      'continue',
      'fold',
      'call',
      'raise',
      'value',
      'bluff',
      'pressure',
      'sizing',
    ];
    if (decisionWords.any(normalizedCue.contains)) {
      return true;
    }
  }
  return false;
}

bool _isSafePriorActionTableCueV1(String cueLabel) {
  final label = cueLabel.trim();
  if (label.isEmpty) {
    return false;
  }
  return RegExp(
    r'^[A-Z0-9]+\s+(?:opens?|opened|raises?|raised|bets?|bet|calls?|called|checks?|checked|folds?|folded|all[- ]?in|goes\s+all(?:\s+in)?)\b',
    caseSensitive: false,
  ).hasMatch(label);
}

String? _safePriorActionCueV1(Act0TableStateV1 table) {
  final candidates = <String>[
    table.centerLabel,
    for (final item in table.actionTrail.reversed) item.label,
  ];
  for (final candidate in candidates) {
    final label = candidate.trim();
    if (_isSafePriorActionTableCueV1(label)) {
      return label;
    }
  }
  return null;
}

String? _deriveFacingActorCueV1(
  BuildContext context, {
  required Act0TableStateV1 table,
}) {
  final candidates = <String>[
    for (final item in table.actionTrail.reversed) item.label,
    table.centerLabel,
  ];
  for (final raw in candidates) {
    final label = raw.trim();
    final openMatch = RegExp(
      r'^([A-Z0-9]+)\s+opens\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (openMatch != null) {
      return act0RuntimeNeutralFacingActorCueLabelV1(
        context,
        actor: openMatch.group(1)!.toUpperCase(),
        amount: openMatch.group(2)!,
      );
    }
    final betMatch = RegExp(
      r'^([A-Z0-9]+)\s+bets\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (betMatch != null) {
      return act0RuntimeNeutralFacingActorCueLabelV1(
        context,
        actor: betMatch.group(1)!.toUpperCase(),
        amount: betMatch.group(2)!,
      );
    }
  }
  return null;
}

String _neutralizeLeadingTableCueV1(
  BuildContext context, {
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
}) {
  if (taskFamily == Act0TaskFamilyV1.sizing) {
    return act0RuntimeNeutralSizingCueLabelV1(context);
  }
  final facingActorCue = _deriveFacingActorCueV1(context, table: table);
  if (facingActorCue != null) {
    return facingActorCue;
  }
  if (table.potLabel.trim().isNotEmpty && table.toCallLabel.trim().isNotEmpty) {
    return act0RuntimeNeutralPotAndPriceCueLabelV1(context);
  }
  if (table.toCallLabel.trim().isNotEmpty) {
    return act0RuntimeNeutralFacingPriceCueLabelV1(context);
  }
  return act0RuntimeNeutralDecisionCueLabelV1(context);
}

String? _resolveDecisionPromptSupportLineV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (!_looksLikeActionDecisionPromptV1(
    runner.question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  )) {
    return null;
  }
  return _safePriorActionCueV1(table) ??
      _deriveFacingActorCueV1(context, table: table);
}

String _neutralizeAnswerBearingCueV1({
  required BuildContext context,
  required String cueLabel,
  required String question,
}) {
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  if (normalizedQuestion.contains('bucket') ||
      normalizedCue.contains('bucket')) {
    return act0RuntimeNeutralBucketCueLabelV1(context);
  }
  if (normalizedQuestion.contains('made hand') ||
      normalizedQuestion.contains('hand category') ||
      normalizedQuestion.contains('showdown')) {
    return act0RuntimeNeutralHandReadCueLabelV1(context);
  }
  if (normalizedQuestion.contains('trail') ||
      normalizedQuestion.contains('history')) {
    return 'Hand history';
  }
  return act0RuntimeNeutralTableReadCueLabelV1(context);
}

String _resolveTableCueDisplayV1({
  required BuildContext context,
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final rawCue = table.centerLabel.trim();
  if (rawCue.isEmpty) {
    return rawCue;
  }
  if (!_isActiveAssessmentStateV1(
    isTeaching: isTeaching,
    isTheory: isTheory,
    isReview: isReview,
    runner: runner,
  )) {
    return rawCue;
  }
  if (_looksLikeTrailHistoryQuestionV1(runner, table)) {
    return '';
  }
  if (_isSafePriorActionTableCueV1(rawCue)) {
    return rawCue;
  }
  if (_isAnswerBearingTableCueV1(
    cueLabel: rawCue,
    question: runner.question,
    options: runner.options,
  )) {
    return _neutralizeAnswerBearingCueV1(
      context: context,
      cueLabel: rawCue,
      question: runner.question,
    );
  }
  if (_isAnswerLeadingTableCueV1(
    rawCue,
    question: runner.question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  )) {
    return _neutralizeLeadingTableCueV1(
      context,
      table: table,
      taskFamily: taskFamily,
    );
  }
  return rawCue;
}

bool _isCenterPriceContextCueV1(BuildContext context, String cueLabel) {
  final normalizedCue = cueLabel.trim().toLowerCase();
  if (normalizedCue.isEmpty) {
    return false;
  }
  if (normalizedCue.startsWith('facing ') ||
      normalizedCue.startsWith('против ')) {
    return true;
  }
  final facingPrice = act0RuntimeNeutralFacingPriceCueLabelV1(
    context,
  ).toLowerCase();
  final potAndPrice = act0RuntimeNeutralPotAndPriceCueLabelV1(
    context,
  ).toLowerCase();
  return normalizedCue == facingPrice || normalizedCue == potAndPrice;
}

_CenterStatDisplayV1 _resolveCenterStatDisplayV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required _RunnerBottomContextV1 bottomContext,
  required String centerCueLabel,
  required bool isTeaching,
  required bool isTheory,
  required bool isReview,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final potLabel = table.potLabel.trim();
  final isActiveAssessment = _isActiveAssessmentStateV1(
    isTeaching: isTeaching,
    isTheory: isTheory,
    isReview: isReview,
    runner: runner,
  );
  final isDecisionPrompt =
      isActiveAssessment &&
      _looksLikeActionDecisionPromptV1(
        runner.question,
        taskFamily: taskFamily,
        hasSeatTargets: hasSeatTargets,
      );
  final showToCall =
      table.toCallLabel.trim().isNotEmpty && !bottomContext.isTrailHistory;
  var resolvedCue = centerCueLabel.trim();

  if (isDecisionPrompt && showToCall && resolvedCue.isNotEmpty) {
    final genericDecisionCue = taskFamily == Act0TaskFamilyV1.sizing
        ? act0RuntimeNeutralSizingCueLabelV1(context)
        : act0RuntimeNeutralDecisionCueLabelV1(context);
    if (bottomContext.promptOwnsDecisionContext &&
        _isCenterPriceContextCueV1(context, resolvedCue)) {
      resolvedCue = genericDecisionCue;
    } else if (_isCenterPriceContextCueV1(context, resolvedCue) &&
        !bottomContext.promptOwnsDecisionContext) {
      resolvedCue = genericDecisionCue;
    }
  }

  return _CenterStatDisplayV1(
    centerCueLabel: resolvedCue,
    potLabel: potLabel,
    toCallLabel: showToCall ? table.toCallLabel.trim() : '',
  );
}

String _normalizedTrailStreetFromLabelV1(String label) {
  final match = RegExp(
    r'^(Preflop|Flop|Turn|River)[:\s]',
    caseSensitive: false,
  ).firstMatch(label.trim());
  return match?.group(1)?.trim() ?? '';
}

bool _looksLikeTrailHistoryQuestionV1(
  Act0RunnerStateV1 runner,
  Act0TableStateV1 table,
) {
  if (table.actionTrail.isEmpty) {
    return false;
  }
  final question = runner.question.trim().toLowerCase();
  if (question.contains('trail') ||
      question.contains('history') ||
      question.contains('happened last') ||
      question.contains('latest action')) {
    return true;
  }
  final trailLabels = table.actionTrail
      .map((item) => item.label.trim())
      .where((label) => label.isNotEmpty)
      .toSet();
  for (final option in runner.options) {
    final optionLabel = option.label.trim();
    final preferredLabel = option.preferredLabel.trim();
    if (trailLabels.contains(optionLabel) ||
        trailLabels.contains(preferredLabel)) {
      return true;
    }
  }
  return false;
}

_RunnerBottomContextV1 _resolveRunnerBottomContextV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required bool isTeaching,
  required bool isTheory,
  required bool isDrill,
  required bool isReview,
  required bool showBottomLearningRail,
  required bool hasSeatTargets,
  required Act0TaskFamilyV1? taskFamily,
}) {
  final isTrailHistory = !isTeaching && !isTheory
      ? _looksLikeTrailHistoryQuestionV1(runner, table)
      : false;
  final taskLabel = act0RuntimeTaskRailLabelV1(
    context,
    isTeaching: isTeaching,
    isTheory: isTheory,
    isDrill: isDrill,
    isReview: isReview,
    isTrailHistory: isTrailHistory,
    hasSeatTargets: hasSeatTargets,
    question: runner.question,
    options: runner.options,
    taskFamily: taskFamily,
  );
  final tableStreet = table.streetLabel.trim();
  final trailStreet = table.actionTrail.isEmpty
      ? ''
      : _normalizedTrailStreetFromLabelV1(table.actionTrail.last.label);
  final decisionPromptSupportLine = !isTrailHistory
      ? _resolveDecisionPromptSupportLineV1(
          context,
          runner: runner,
          table: table,
          taskFamily: taskFamily,
          hasSeatTargets: hasSeatTargets,
        )
      : null;
  final promptSupportLine = isTrailHistory
      ? act0RuntimeTrailPromptSupportLineV1(
          context,
          currentStreetLabel: tableStreet,
          trailStreetLabel: trailStreet,
        )
      : decisionPromptSupportLine;
  final feedbackContextLabels = isTrailHistory
      ? <String>[act0RuntimeTrailFeedbackContextLabelV1(context)]
      : const <String>[];

  if (showBottomLearningRail || isTeaching || isTheory) {
    return _RunnerBottomContextV1(
      owner: _RunnerBottomOwnerV1.coachRail,
      isTrailHistory: isTrailHistory,
      promptOwnsDecisionContext: false,
      showActionTrail: false,
      taskLabel: taskLabel,
      questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(context),
      promptSupportLine: promptSupportLine,
      feedbackContextLabels: feedbackContextLabels,
    );
  }
  if (isReview) {
    return _RunnerBottomContextV1(
      owner: _RunnerBottomOwnerV1.feedback,
      isTrailHistory: isTrailHistory,
      promptOwnsDecisionContext: false,
      showActionTrail: table.actionTrail.isNotEmpty,
      actionTrailVariant: table.actionTrail.isNotEmpty
          ? _ActionTrailVariantV1.replay
          : null,
      taskLabel: taskLabel,
      questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(
        context,
        isTrailHistory: isTrailHistory,
      ),
      promptSupportLine: promptSupportLine,
      feedbackContextLabels: feedbackContextLabels,
    );
  }
  return _RunnerBottomContextV1(
    owner: _RunnerBottomOwnerV1.questionPrompt,
    isTrailHistory: isTrailHistory,
    promptOwnsDecisionContext: decisionPromptSupportLine != null,
    showActionTrail: false,
    taskLabel: taskLabel,
    questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(
      context,
      isTrailHistory: isTrailHistory,
    ),
    promptSupportLine: promptSupportLine,
    feedbackContextLabels: feedbackContextLabels,
  );
}

class _ActionTrailV1 extends StatefulWidget {
  const _ActionTrailV1({
    required this.items,
    required this.variant,
    this.streetLabel,
    this.refined = false,
    this.onFocusedIndexChanged,
  });

  final List<Act0ActionTrailItemV1> items;
  final _ActionTrailVariantV1 variant;
  final String? streetLabel;
  final bool refined;
  final ValueChanged<int>? onFocusedIndexChanged;

  @override
  State<_ActionTrailV1> createState() => _ActionTrailV1State();
}

class _ActionTrailV1State extends State<_ActionTrailV1> {
  Timer? _revealTimer;
  Timer? _playbackTimer;
  int _visibleCount = 0;
  int _focusedIndex = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.items.length;
    _focusedIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    _emitFocusedIndex();
  }

  @override
  void didUpdateWidget(covariant _ActionTrailV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLabels = oldWidget.items.map((item) => item.label).toList();
    final newLabels = widget.items.map((item) => item.label).toList();
    if (_isSamePrefix(oldLabels, newLabels) &&
        newLabels.length > oldLabels.length) {
      _revealTimer?.cancel();
      setState(() => _visibleCount = oldLabels.length);
      _scheduleRevealUntil(newLabels.length);
      return;
    }
    _revealTimer?.cancel();
    _playbackTimer?.cancel();
    _isAutoPlaying = false;
    setState(() {
      _visibleCount = newLabels.length;
      _focusedIndex = newLabels.isEmpty ? 0 : newLabels.length - 1;
    });
    _emitFocusedIndex();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _emitFocusedIndex() {
    if (widget.items.isEmpty) {
      return;
    }
    final normalized = _focusedIndex.clamp(0, widget.items.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onFocusedIndexChanged?.call(normalized);
    });
  }

  bool _isSamePrefix(List<String> oldLabels, List<String> nextLabels) {
    if (oldLabels.length > nextLabels.length) {
      return false;
    }
    for (var i = 0; i < oldLabels.length; i++) {
      if (oldLabels[i] != nextLabels[i]) {
        return false;
      }
    }
    return true;
  }

  void _scheduleRevealUntil(int target) {
    if (!mounted || _visibleCount >= target) {
      return;
    }
    _revealTimer = Timer(const Duration(milliseconds: 130), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visibleCount = (_visibleCount + 1).clamp(0, target);
      });
      _scheduleRevealUntil(target);
    });
  }

  void _focusStep(int nextIndex) {
    if (widget.items.isEmpty) {
      return;
    }
    final maxIndex = widget.items.length - 1;
    final normalized = nextIndex.clamp(0, maxIndex);
    if (_focusedIndex == normalized) {
      return;
    }
    setState(() {
      _focusedIndex = normalized;
    });
    _emitFocusedIndex();
  }

  /// Returns the street name if this trail label starts a new street
  /// (e.g. "Flop: BB checks" → "FLOP", "Flop dealt" → "FLOP"), otherwise null.
  String? _streetNameFromLabel(String label) {
    final m = RegExp(
      r'^(Flop|Turn|River)[:\s]',
      caseSensitive: false,
    ).firstMatch(label.trim());
    return m != null ? m.group(1)!.toUpperCase() : null;
  }

  void _toggleAutoPlay() {
    if (widget.items.length < 2) {
      return;
    }
    if (_isAutoPlaying) {
      _playbackTimer?.cancel();
      setState(() => _isAutoPlaying = false);
      return;
    }
    setState(() => _isAutoPlaying = true);
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || widget.items.isEmpty) {
        return;
      }
      final maxIndex = widget.items.length - 1;
      final atEnd = _focusedIndex >= maxIndex;
      setState(() {
        _focusedIndex = atEnd ? 0 : (_focusedIndex + 1);
      });
      _emitFocusedIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final refined = widget.refined;
    final compactContext =
        widget.variant == _ActionTrailVariantV1.compactContext;
    final streetLabel = widget.streetLabel?.trim() ?? '';
    final visibleCount = _visibleCount.clamp(0, items.length);
    final focusedIndex = items.isEmpty
        ? 0
        : _focusedIndex.clamp(0, visibleCount - 1);
    final text = items.map((item) => item.label).join('  .  ');
    final focusedLabel = items.isEmpty
        ? ''
        : act0RuntimeLocalizedActionTrailLabelV1(
            context,
            items[focusedIndex].label,
          );
    final compactStreetLabel = streetLabel.isNotEmpty
        ? act0RuntimeLocalizedStreetLabelV1(context, streetLabel)
        : '';
    return Container(
      key: const Key('act0_shell_action_trail'),
      constraints: BoxConstraints(maxWidth: refined ? 332 : 370),
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 8 : 11,
        vertical: refined ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: refined
            ? Act0ShellTokensV1.surface.withValues(alpha: 0.26)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(
            alpha: refined ? 0.16 : 0.44,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (compactContext) {
            return Row(
              key: const Key('act0_shell_action_trail_compact_context'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compactStreetLabel.isNotEmpty)
                  Container(
                    key: const Key('act0_shell_action_trail_street_badge'),
                    padding: EdgeInsets.symmetric(
                      horizontal: refined ? 7 : 8,
                      vertical: refined ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Text(
                      compactStreetLabel,
                      style: Act0ShellTokensV1.label.copyWith(
                        fontSize: refined ? 7.2 : 7.8,
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.88),
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                if (compactStreetLabel.isNotEmpty)
                  SizedBox(width: refined ? 7 : 8),
                Expanded(
                  child: Text(
                    focusedLabel,
                    key: const Key('act0_shell_action_trail_text'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.text.withValues(
                        alpha: refined ? 0.84 : 0.90,
                      ),
                      fontSize: refined ? 10.2 : 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          }
          final stackControls =
              items.length > 1 && refined && constraints.maxWidth < 206;
          final trailControls = Row(
            key: const Key('act0_shell_action_trail_replay_controls'),
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_prev'),
                icon: Icons.skip_previous_rounded,
                onTap: () {
                  _playbackTimer?.cancel();
                  if (_isAutoPlaying) {
                    setState(() => _isAutoPlaying = false);
                  }
                  _focusStep(focusedIndex - 1);
                },
                compact: refined,
              ),
              SizedBox(width: refined ? 4 : 5),
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_toggle'),
                icon: _isAutoPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                onTap: _toggleAutoPlay,
                active: _isAutoPlaying,
                compact: refined,
              ),
              SizedBox(width: refined ? 4 : 5),
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_next'),
                icon: Icons.skip_next_rounded,
                onTap: () {
                  _playbackTimer?.cancel();
                  if (_isAutoPlaying) {
                    setState(() => _isAutoPlaying = false);
                  }
                  _focusStep(focusedIndex + 1);
                },
                compact: refined,
              ),
              const SizedBox(width: 6),
              Text(
                '${focusedIndex + 1}/${items.length}',
                style: TextStyle(
                  color: Act0ShellTokensV1.textMuted,
                  fontSize: refined ? 8.5 : 9.5,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          );
          final trailMain = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: refined ? 22 : 26,
                height: refined ? 22 : 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface3.withValues(
                    alpha: refined ? 0.28 : 0.62,
                  ),
                  borderRadius: BorderRadius.circular(
                    refined
                        ? Act0ShellTokensV1.radiusXs
                        : Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.border.withValues(
                      alpha: refined ? 0.20 : 0.28,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  key: const Key('act0_shell_action_trail_icon'),
                  size: refined ? 12 : 14,
                  color: Act0ShellTokensV1.textMuted.withValues(
                    alpha: refined ? 0.66 : 0.82,
                  ),
                ),
              ),
              SizedBox(width: refined ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.shrink(
                      child: Text(
                        text,
                        key: const Key('act0_shell_action_trail_text'),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final badgeWidth = streetLabel.isNotEmpty
                            ? (refined ? 54.0 : 58.0)
                            : 0.0;
                        final scrollerWidth = streetLabel.isNotEmpty
                            ? (constraints.maxWidth -
                                      badgeWidth -
                                      (refined ? 5 : 7))
                                  .clamp(80.0, constraints.maxWidth)
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: refined ? 5 : 7,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (streetLabel.isNotEmpty)
                              refined
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                        vertical: 1,
                                      ),
                                      child: Text(
                                        streetLabel,
                                        key: const Key(
                                          'act0_shell_action_trail_street_badge',
                                        ),
                                        style: Act0ShellTokensV1.label.copyWith(
                                          fontSize: 7.1,
                                          color: Act0ShellTokensV1.info
                                              .withValues(alpha: 0.84),
                                          letterSpacing: 0.25,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      key: const Key(
                                        'act0_shell_action_trail_street_badge',
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Act0ShellTokensV1.info
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          Act0ShellTokensV1.radiusPill,
                                        ),
                                        border: Border.all(
                                          color: Act0ShellTokensV1.info
                                              .withValues(alpha: 0.34),
                                        ),
                                      ),
                                      child: Text(
                                        streetLabel,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          fontSize: 7.2,
                                          color: Act0ShellTokensV1.info,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                            SizedBox(
                              width: scrollerWidth,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    for (var i = 0; i < visibleCount; i++) ...[
                                      if (i > 0 &&
                                          _streetNameFromLabel(
                                                items[i].label,
                                              ) !=
                                              null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: refined ? 4 : 5,
                                          ),
                                          child: _TrailStreetDividerV1(
                                            label: _streetNameFromLabel(
                                              items[i].label,
                                            )!,
                                            refined: refined,
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: i == visibleCount - 1
                                              ? 0
                                              : (refined ? 4 : 5),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            _playbackTimer?.cancel();
                                            if (_isAutoPlaying) {
                                              setState(
                                                () => _isAutoPlaying = false,
                                              );
                                            }
                                            _focusStep(i);
                                          },
                                          child: _ActionTrailStepV1(
                                            item: items[i],
                                            index: i,
                                            isLatest: i == focusedIndex,
                                            refined: refined,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (items.length > 1 && !stackControls) ...[
                SizedBox(width: refined ? 7 : 8),
                trailControls,
              ],
            ],
          );
          if (!stackControls) {
            return trailMain;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              trailMain,
              SizedBox(height: refined ? 6 : 8),
              Align(alignment: Alignment.centerRight, child: trailControls),
            ],
          );
        },
      ),
    );
  }
}

class _TrailStreetDividerV1 extends StatelessWidget {
  const _TrailStreetDividerV1({required this.label, this.refined = false});
  final String label;
  final bool refined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          fontSize: refined ? 7.0 : 7.4,
          color: Act0ShellTokensV1.gold,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrailPlaybackButtonV1 extends StatelessWidget {
  const _TrailPlaybackButtonV1({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact
        ? Act0ShellTokensV1.radiusXs
        : Act0ShellTokensV1.radiusPill;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 4,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? Act0ShellTokensV1.primary.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: compact ? 0.025 : 0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: active
                  ? Act0ShellTokensV1.primary.withValues(alpha: 0.48)
                  : Act0ShellTokensV1.border.withValues(
                      alpha: compact ? 0.28 : 0.44,
                    ),
            ),
          ),
          child: Icon(
            icon,
            size: compact ? 14 : 16,
            color: active
                ? Act0ShellTokensV1.primary
                : Act0ShellTokensV1.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ActionTrailStepV1 extends StatefulWidget {
  const _ActionTrailStepV1({
    required this.item,
    required this.index,
    required this.isLatest,
    required this.refined,
  });

  final Act0ActionTrailItemV1 item;
  final int index;
  final bool isLatest;
  final bool refined;

  @override
  State<_ActionTrailStepV1> createState() => _ActionTrailStepV1State();
}

class _ActionTrailStepV1State extends State<_ActionTrailStepV1> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final refined = widget.refined;
    final isLatest = widget.isLatest;
    return AnimatedSlide(
      key: Key('act0_shell_action_trail_step_${widget.index}'),
      duration: Duration(milliseconds: refined ? 260 : 220),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0.10, 0),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: refined ? 240 : 200),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: Container(
          key: isLatest
              ? const Key('act0_shell_action_trail_latest_step')
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: refined ? 7 : 8,
            vertical: refined ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: isLatest
                ? Act0ShellTokensV1.gold.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: refined ? 0.035 : 0.05),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            border: Border.all(
              color: isLatest
                  ? Act0ShellTokensV1.gold.withValues(alpha: 0.36)
                  : Colors.white.withValues(alpha: refined ? 0.06 : 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: refined ? 4 : 5,
                height: refined ? 4 : 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLatest
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.textMuted.withValues(
                          alpha: refined ? 0.46 : 0.58,
                        ),
                ),
              ),
              SizedBox(width: refined ? 5 : 6),
              Text(
                act0RuntimeLocalizedActionTrailLabelV1(
                  context,
                  widget.item.label,
                ),
                key: Key('act0_shell_action_trail_step_label_${widget.index}'),
                maxLines: 2,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: refined ? 8.8 : 9.5,
                  fontWeight: isLatest ? FontWeight.w900 : FontWeight.w800,
                  color: isLatest
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.textMuted.withValues(
                          alpha: refined ? 0.74 : 0.86,
                        ),
                ),
              ),
              if (isLatest) ...[
                SizedBox(width: refined ? 5 : 6),
                Container(
                  key: const Key('act0_shell_action_trail_latest_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                  ),
                  child: Text(
                    act0RuntimeLocalizedLatestBadgeV1(context),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.gold,
                      fontSize: refined ? 7.4 : 7.8,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatMarkersV1 extends StatelessWidget {
  const _SeatMarkersV1({required this.seatId, required this.markers});

  final String seatId;
  final List<_SeatMarkerKindV1> markers;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: Key('act0_shell_marker_cluster_$seatId'),
      spacing: 3,
      runSpacing: 3,
      children: [
        for (final marker in markers)
          KeyedSubtree(
            key: Key('act0_shell_marker_${seatId}_${marker.name}'),
            child: _MarkerDotV1(marker: marker),
          ),
      ],
    );
  }
}

class _SeatMarkerPlacementV1 extends StatelessWidget {
  const _SeatMarkerPlacementV1({
    required this.seatId,
    required this.leftSide,
    required this.markers,
    required this.hero,
    required this.visualVariant,
  });

  final String seatId;
  final bool leftSide;
  final List<_SeatMarkerKindV1> markers;
  final bool hero;
  final Act0ShellTableVisualVariantV1 visualVariant;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final bottomHero = hero;
    return Positioned(
      top: bottomHero ? (refined ? 6 : 4) : (refined ? -10 : -12),
      left: leftSide ? (refined ? -6 : -10) : null,
      right: bottomHero
          ? (refined ? -38 : -48)
          : (leftSide ? null : (refined ? -6 : -10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: refined ? 42 : 50),
        child: _SeatMarkersV1(seatId: seatId, markers: markers),
      ),
    );
  }
}

class _MiniCardBackV1 extends StatelessWidget {
  const _MiniCardBackV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_face_down_card'),
      width: 22,
      height: 31,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radius3xs),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Act0ShellTokensV1.shadowSoftStrong,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF101D30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF172B45), Color(0xFF233B59)],
            ),
            borderRadius: BorderRadius.circular(
              Act0ShellTokensV1.radius3xs - 1.5,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const SizedBox(key: Key('act0_shell_quiet_card_back')),
        ),
      ),
    );
  }
}

class _BetChipV1 extends StatelessWidget {
  const _BetChipV1({required this.bet, this.compact = false});

  final Act0SeatBetStateV1 bet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final showLabelPill =
        !(compact &&
            bet.kind == Act0SeatBetKindV1.post &&
            (bet.label == 'SB' || bet.label == 'BB'));
    final color = switch (bet.kind) {
      Act0SeatBetKindV1.post => Act0ShellTokensV1.gold,
      Act0SeatBetKindV1.call => Act0ShellTokensV1.info,
      Act0SeatBetKindV1.bet ||
      Act0SeatBetKindV1.raise => Act0ShellTokensV1.primary,
      Act0SeatBetKindV1.allIn => Act0ShellTokensV1.danger,
    };
    return ClipRRect(
      key: Key('act0_shell_bet_chip_${bet.label}'),
      borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 6,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            border: Border.all(color: color.withValues(alpha: 0.8), width: 1.2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ChipStackIconV1(color: color, compact: compact),
              SizedBox(width: compact ? 3 : 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLabelPill)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 3 : 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusPill,
                        ),
                      ),
                      child: Text(
                        bet.label,
                        style: TextStyle(
                          color: color,
                          fontSize: compact ? 5.6 : 6.1,
                          height: 0.95,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  if (showLabelPill) SizedBox(height: compact ? 1 : 2),
                  Text(
                    bet.amountLabel,
                    style: TextStyle(
                      color: Act0ShellTokensV1.text,
                      fontSize: compact ? 7.0 : 7.8,
                      height: 0.98,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipStackIconV1 extends StatelessWidget {
  const _ChipStackIconV1({required this.color, this.compact = false});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 12 : 14;
    return SizedBox(
      width: size,
      height: size + 4,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: _ChipDiscV1(color: color, compact: compact, isBottom: true),
          ),
          Positioned(
            bottom: 2,
            child: _ChipDiscV1(color: color, compact: compact, isBottom: true),
          ),
          Positioned(
            bottom: 4,
            child: _ChipDiscV1(color: color, compact: compact),
          ),
        ],
      ),
    );
  }
}

class _ChipDiscV1 extends StatelessWidget {
  const _ChipDiscV1({
    required this.color,
    this.compact = false,
    this.isBottom = false,
  });

  final Color color;
  final bool compact;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 12 : 14;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        gradient: isBottom
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.6),
                  color.withValues(alpha: 0.3),
                ],
              )
            : RadialGradient(
                center: const Alignment(-0.2, -0.4),
                radius: 0.8,
                colors: <Color>[Colors.white.withValues(alpha: 0.4), color],
              ),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: isBottom ? 0.1 : 0.8),
          width: isBottom ? 0.5 : 1.2,
        ),
        boxShadow: [
          if (isBottom)
            const BoxShadow(
              color: Color(0x66000000),
              blurRadius: 3,
              offset: Offset(0, 2),
            )
          else
            const BoxShadow(
              color: Color(0xAA000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
        ],
      ),
      child: Center(
        child: isBottom
            ? null
            : Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
      ),
    );
  }
}

class _FoldedBadgeV1 extends StatelessWidget {
  const _FoldedBadgeV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_folded_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(alpha: 0.9),
        ),
      ),
      child: Text(
        'Folded',
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textMuted,
          fontSize: 7,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MarkerDotV1 extends StatelessWidget {
  const _MarkerDotV1({required this.marker});

  final _SeatMarkerKindV1 marker;

  @override
  Widget build(BuildContext context) {
    if (marker == _SeatMarkerKindV1.dealer) {
      return KeyedSubtree(
        key: const Key('act0_shell_wave1_dealer_marker'),
        child: Container(
          key: const Key('act0_shell_wave1b_button_marker'),
          width: 24,
          height: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFF8FAFC), Color(0xFFDCE7F2)],
            ),
            border: Border.all(color: const Color(0xFFB7C4D3), width: 1),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 1.4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'D',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 7.0,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
      );
    }

    final localizedActLabel =
        Localizations.localeOf(
          context,
        ).languageCode.toLowerCase().startsWith('ru')
        ? 'Ход'
        : 'Act';
    final (color, label, isCircle) = switch (marker) {
      _SeatMarkerKindV1.dealer => (Colors.white, 'BTN', false),
      _SeatMarkerKindV1.smallBlind => (
        Act0ShellTokensV1.runnerTagBlue,
        'SB',
        true,
      ),
      _SeatMarkerKindV1.bigBlind => (Act0ShellTokensV1.gold, 'BB', true),
      _SeatMarkerKindV1.aggressor => (Act0ShellTokensV1.danger, 'Agg', false),
      _SeatMarkerKindV1.act => (
        Act0ShellTokensV1.primary,
        localizedActLabel,
        false,
      ),
    };

    return Container(
      key:
          marker == _SeatMarkerKindV1.smallBlind ||
              marker == _SeatMarkerKindV1.bigBlind
          ? Key('act0_shell_wave1_blind_marker_${marker.name}')
          : null,
      width: isCircle ? 16 : null,
      height: isCircle ? 16 : null,
      padding: isCircle
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      alignment: isCircle ? Alignment.center : null,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[color, color.withValues(alpha: 0.78)],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: marker == _SeatMarkerKindV1.bigBlind
              ? const Color(0xFF5C3A21)
              : Colors.white,
          fontSize: isCircle ? 6.5 : 7.0,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _CardV1 extends StatelessWidget {
  const _CardV1({required this.card, this.cardId, this.highlighted = false});

  final Act0CardStateV1 card;
  final String? cardId;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = _cardInkColor(card);
    final suit = _displaySuit(card.suit);
    return Container(
      key: cardId != null ? Key('act0_shell_card_$cardId') : null,
      width: Act0ShellTokensV1.heroCardWidth,
      height: Act0ShellTokensV1.heroCardHeight,
      constraints: const BoxConstraints(
        minWidth: Act0ShellTokensV1.heroCardWidth,
      ),
      decoration: _playingCardDecorationV1(highlighted: highlighted),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const <double>[0, 0.4, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 3,
            top: 2,
            child: Text(
              card.rank,
              style: TextStyle(
                color: color,
                fontSize: 18,
                height: 1.0,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: 3,
            bottom: 2,
            child: Text(
              suit.isEmpty ? '' : suit,
              style: TextStyle(color: color, fontSize: 28, height: 1.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardCardV1 extends StatelessWidget {
  const _BoardCardV1({
    required this.card,
    this.cardId,
    this.highlighted = false,
    this.onTap,
  });

  final Act0CardStateV1 card;
  final String? cardId;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _cardInkColor(card);
    final suit = _displaySuit(card.suit);
    final child = Container(
      key: cardId != null
          ? Key('act0_shell_card_$cardId')
          : const Key('act0_shell_board_card'),
      width: Act0ShellTokensV1.boardCardWidth,
      height: Act0ShellTokensV1.boardCardHeight,
      decoration: _playingCardDecorationV1(
        board: true,
        highlighted: highlighted,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const <double>[0, 0.4, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 3,
            top: 1,
            child: Text(
              card.rank,
              style: TextStyle(
                color: color,
                fontSize: 16,
                height: 1.0,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: 3,
            bottom: 2,
            child: Text(
              suit.isEmpty ? '' : suit,
              style: TextStyle(color: color, fontSize: 24, height: 1.0),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class _Act0ShowdownParticipantV1 {
  const _Act0ShowdownParticipantV1({
    required this.seatId,
    required this.displayLabel,
    required this.cards,
    required this.cardIdsBySolver,
  });

  final String seatId;
  final String displayLabel;
  final List<String> cards;
  final Map<String, List<String>> cardIdsBySolver;
}

class _Act0ShowdownInsightV1 {
  const _Act0ShowdownInsightV1({
    required this.highlightedCardIds,
    required this.summaryLine,
  });

  final List<String> highlightedCardIds;
  final String summaryLine;
}

BoxDecoration _playingCardDecorationV1({
  bool board = false,
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
    border: Border.all(
      color: highlighted
          ? Act0ShellTokensV1.gold.withValues(alpha: 0.90)
          : const Color(0xFFD1D8E0),
      width: highlighted ? 1.6 : 1,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
      if (highlighted)
        BoxShadow(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.35),
          blurRadius: 8,
          spreadRadius: 1.0,
        ),
    ],
  );
}

Color _cardInkColor(Act0CardStateV1 card) {
  return card.tone == Act0CardToneV1.red
      ? Act0ShellTokensV1.runnerAnswerDanger
      : Act0ShellTokensV1.runnerAnswerText;
}

String _displaySuit(String suit) {
  switch (suit.trim().toLowerCase()) {
    case 's':
    case 'spade':
    case 'spades':
    case '♠':
      return '♠';
    case 'h':
    case 'heart':
    case 'hearts':
    case '♥':
      return '♥';
    case 'd':
    case 'diamond':
    case 'diamonds':
    case '♦':
      return '♦';
    case 'c':
    case 'club':
    case 'clubs':
    case '♣':
      return '♣';
    default:
      return suit.toUpperCase();
  }
}

class _PhaseTrackerV1 extends StatelessWidget {
  const _PhaseTrackerV1({required this.phase});

  final Act0LessonPhaseV1 phase;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('act0_shell_phase_tracker'),
      children: Act0LessonPhaseV1.values
          .map((item) {
            final active = item == phase;
            final label = switch (item) {
              Act0LessonPhaseV1.theory => 'Learn',
              Act0LessonPhaseV1.drill => 'Practice',
              Act0LessonPhaseV1.review => 'Review',
            };
            final activeColor = switch (item) {
              Act0LessonPhaseV1.theory => Act0ShellTokensV1.info,
              Act0LessonPhaseV1.drill => Act0ShellTokensV1.primary,
              Act0LessonPhaseV1.review => Act0ShellTokensV1.gold,
            };
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? activeColor.withValues(alpha: 0.18)
                      : Act0ShellTokensV1.surface2,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: active ? activeColor : Act0ShellTokensV1.border,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: active ? activeColor : Act0ShellTokensV1.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _DecisionHintV1 {
  const _DecisionHintV1({
    required this.quickHint,
    required this.fullIdeaTitle,
    required this.fullIdeaBlocks,
  });

  final String quickHint;
  final String fullIdeaTitle;
  final List<String> fullIdeaBlocks;

  bool get hasFullIdea =>
      fullIdeaTitle.trim().isNotEmpty || fullIdeaBlocks.isNotEmpty;
}

_DecisionHintV1? _resolveDecisionHintV1({
  required Act0TaskFamilyV1? taskFamily,
  required Act0RunnerStateV1 runner,
  required String prompt,
  required String question,
  required String supportLine,
  required Act0TeachingStepV1? fullIdeaStep,
}) {
  if (runner.phase != Act0LessonPhaseV1.drill || runner.options.isEmpty) {
    return null;
  }
  final quickHint = _genericDecisionHintV1(
    taskFamily: taskFamily,
    text:
        '$prompt $question $supportLine '
        '${runner.lessonTitle} ${runner.lessonSubtitle}',
  );
  if (quickHint.isEmpty) {
    return null;
  }
  return _DecisionHintV1(
    quickHint: quickHint,
    fullIdeaTitle: fullIdeaStep?.title.trim() ?? '',
    fullIdeaBlocks: fullIdeaStep == null
        ? const <String>[]
        : act0BuildSupportingCopyBlocksV1(
            text: fullIdeaStep.body,
            compact: true,
          ),
  );
}

String _genericDecisionHintV1({
  required Act0TaskFamilyV1? taskFamily,
  required String text,
}) {
  final normalized = text.toLowerCase();
  if (taskFamily == Act0TaskFamilyV1.sizing ||
      taskFamily == Act0TaskFamilyV1.counting ||
      normalized.contains('pot') ||
      normalized.contains('chip') ||
      normalized.contains('matched')) {
    return 'Count only chips that are actually in the pot or matched.';
  }
  if (normalized.contains('position') ||
      normalized.contains('seat') ||
      normalized.contains('button') ||
      normalized.contains('btn') ||
      normalized.contains('utg') ||
      normalized.contains('blind')) {
    return 'Start from the button, then follow seat order.';
  }
  if (taskFamily == Act0TaskFamilyV1.recognition ||
      taskFamily == Act0TaskFamilyV1.compare ||
      normalized.contains('board') ||
      normalized.contains('card') ||
      normalized.contains('flop') ||
      normalized.contains('turn') ||
      normalized.contains('river')) {
    return 'Read the board cards before using memory.';
  }
  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.transfer ||
      taskFamily == Act0TaskFamilyV1.repair ||
      normalized.contains('action') ||
      normalized.contains('fold') ||
      normalized.contains('check') ||
      normalized.contains('call') ||
      normalized.contains('raise') ||
      normalized.contains('bet')) {
    return 'Name the action before choosing what it means.';
  }
  return 'Start with what is visible on the table.';
}

class _ActionPanelV1 extends StatelessWidget {
  const _ActionPanelV1({
    required this.options,
    required this.selectedOptionId,
    required this.onChoose,
    this.compactDecision = false,
    this.fillAvailableHeight = false,
  });

  final List<Act0RunnerOptionV1> options;
  final String? selectedOptionId;
  final ValueChanged<Act0RunnerOptionV1> onChoose;
  final bool compactDecision;
  final bool fillAvailableHeight;

  bool _shouldStackOptionsV1(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= 420) {
      return true;
    }
    if (options.length > 3) {
      return true;
    }
    var longestLabelLength = 0;
    for (final option in options) {
      final localizedLabel = act0RuntimeLocalizedOptionLabelV1(
        context,
        option.label,
      );
      if (localizedLabel.length > longestLabelLength) {
        longestLabelLength = localizedLabel.length;
      }
    }
    return longestLabelLength > 24 || options.length > 3;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCompactDecision =
        compactDecision ||
        _CompactAnswerListDecisionScopeV1.isCompact(context) ||
        _usesCompactAnswerListLeafFallbackV1(context);
    final stackOptions = _shouldStackOptionsV1(context);
    final hasLongStackedLabel = options.any(
      (option) =>
          act0RuntimeLocalizedOptionLabelV1(context, option.label).length >
              16 ||
          option.amountLabel.trim().isNotEmpty,
    );
    final unselectedForeground = Act0ShellTokensV1.text;
    final unselectedBackground = Act0ShellTokensV1.surface2.withValues(
      alpha: stackOptions ? 0.88 : 0.82,
    );
    final unselectedBorder = stackOptions
        ? Act0ShellTokensV1.info.withValues(alpha: 0.22)
        : Act0ShellTokensV1.border.withValues(alpha: 0.92);
    Widget withCommitMotion(Widget child) {
      return _DecisionCommitMotionV1(child: child);
    }

    if (stackOptions) {
      if (effectiveCompactDecision) {
        return withCommitMotion(
          Column(
            key: const Key('act0_shell_action_panel'),
            mainAxisSize: fillAvailableHeight
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              if (fillAvailableHeight)
                Expanded(
                  child: Column(
                    key: const Key('act0_shell_answer_sheet'),
                    children: [
                      for (final entry in options.indexed) ...[
                        Expanded(
                          child: _AnswerChoiceRowV1(
                            option: entry.$2,
                            optionIndex: entry.$1,
                            selected: entry.$2.id == selectedOptionId,
                            onChoose: onChoose,
                            compact: true,
                            readableCompactHeight:
                                options.length <= 3 && hasLongStackedLabel,
                          ),
                        ),
                        if (entry.$1 < options.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Act0ShellTokensV1.info.withValues(
                              alpha: 0.08,
                            ),
                          ),
                      ],
                    ],
                  ),
                )
              else
                Column(
                  key: const Key('act0_shell_answer_sheet'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in options.indexed) ...[
                      _AnswerChoiceRowV1(
                        option: entry.$2,
                        optionIndex: entry.$1,
                        selected: entry.$2.id == selectedOptionId,
                        onChoose: onChoose,
                        compact: true,
                        readableCompactHeight:
                            options.length <= 3 && hasLongStackedLabel,
                      ),
                      if (entry.$1 < options.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.08),
                        ),
                    ],
                  ],
                ),
            ],
          ),
        );
      }
      return withCommitMotion(
        Container(
          key: const Key('act0_shell_action_panel'),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(
              effectiveCompactDecision ? 16 : 22,
            ),
            border: Border.all(color: unselectedBorder),
          ),
          child: Column(
            key: const Key('act0_shell_answer_sheet'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in options.indexed) ...[
                _AnswerChoiceRowV1(
                  option: entry.$2,
                  optionIndex: entry.$1,
                  selected: entry.$2.id == selectedOptionId,
                  onChoose: onChoose,
                  compact: effectiveCompactDecision,
                  readableCompactHeight:
                      effectiveCompactDecision &&
                      options.length <= 3 &&
                      hasLongStackedLabel,
                ),
                if (entry.$1 < options.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                  ),
              ],
            ],
          ),
        ),
      );
    }

    final buttons = options.indexed
        .map((entry) {
          final optionIndex = entry.$1;
          final option = entry.$2;
          final selected = option.id == selectedOptionId;
          final tone = selected
              ? option.isCorrect
                    ? Act0VisualCanonV1.greenTable
                    : Act0ShellTokensV1.danger
              : unselectedForeground;
          final background = selected
              ? tone.withValues(alpha: 0.16)
              : unselectedBackground;
          final buttonHeight = stackOptions ? 62.0 : 48.0;
          final marker = String.fromCharCode(65 + optionIndex);
          return OutlinedButton(
            key: Key('act0_shell_option_${option.id}'),
            onPressed: () => onChoose(option),
            style: Act0ShellTokensV1.quietButtonStyle(height: buttonHeight)
                .copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                    selected ? tone : unselectedForeground,
                  ),
                  backgroundColor: WidgetStatePropertyAll(background),
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: selected
                          ? tone.withValues(alpha: 0.92)
                          : unselectedBorder,
                      width: selected ? 1.3 : 1,
                    ),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(
                      horizontal: effectiveCompactDecision
                          ? 10
                          : (stackOptions ? 14 : 12),
                      vertical: effectiveCompactDecision
                          ? 6
                          : (stackOptions ? 10 : 8),
                    ),
                  ),
                  alignment: stackOptions
                      ? Alignment.centerLeft
                      : Alignment.center,
                ),
            child: stackOptions
                ? Row(
                    children: [
                      Container(
                        key: Key('act0_shell_option_marker_${option.id}'),
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? tone.withValues(alpha: 0.18)
                              : Act0ShellTokensV1.info.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: selected
                                ? tone.withValues(alpha: 0.46)
                                : Act0ShellTokensV1.info.withValues(
                                    alpha: 0.24,
                                  ),
                          ),
                        ),
                        child: Text(
                          marker,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: selected
                                ? tone
                                : Act0ShellTokensV1.info.withValues(
                                    alpha: 0.92,
                                  ),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act0RuntimeLocalizedOptionLabelV1(
                                context,
                                option.label,
                              ),
                              textAlign: TextAlign.left,
                              style: Act0ShellTokensV1.body.copyWith(
                                color: selected ? tone : unselectedForeground,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                            if (option.amountLabel.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                option.amountLabel,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 9,
                                  height: 1.0,
                                  color: selected
                                      ? tone.withValues(alpha: 0.9)
                                      : Act0ShellTokensV1.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        act0RuntimeLocalizedOptionLabelV1(
                          context,
                          option.label,
                        ),
                        textAlign: TextAlign.center,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: selected ? tone : unselectedForeground,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 10,
                        child: option.amountLabel.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  option.amountLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1.0,
                                    color: selected
                                        ? tone.withValues(alpha: 0.9)
                                        : Act0ShellTokensV1.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
          );
        })
        .toList(growable: false);
    if (buttons.length <= 3 && !stackOptions) {
      return withCommitMotion(
        Row(
          key: const Key('act0_shell_action_panel'),
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              Expanded(child: buttons[i]),
              if (i < buttons.length - 1)
                const SizedBox(width: Act0ShellTokensV1.gapSm),
            ],
          ],
        ),
      );
    }
    return withCommitMotion(
      Column(
        key: const Key('act0_shell_action_panel'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            buttons[i],
            if (i < buttons.length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ),
    );
  }
}

class _DecisionCommitMotionV1 extends StatefulWidget {
  const _DecisionCommitMotionV1({required this.child});

  final Widget child;

  @override
  State<_DecisionCommitMotionV1> createState() =>
      _DecisionCommitMotionV1State();
}

class _DecisionCommitMotionV1State extends State<_DecisionCommitMotionV1> {
  var _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _settled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return KeyedSubtree(
        key: const Key('act0_shell_decision_commit_motion'),
        child: widget.child,
      );
    }
    return AnimatedScale(
      key: const Key('act0_shell_decision_commit_motion'),
      scale: _settled ? 1 : 0.985,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: widget.child,
    );
  }
}

class _AnswerChoiceRowV1 extends StatelessWidget {
  const _AnswerChoiceRowV1({
    required this.option,
    required this.optionIndex,
    required this.selected,
    required this.onChoose,
    this.compact = false,
    this.readableCompactHeight = false,
  });

  final Act0RunnerOptionV1 option;
  final int optionIndex;
  final bool selected;
  final ValueChanged<Act0RunnerOptionV1> onChoose;
  final bool compact;
  final bool readableCompactHeight;

  @override
  Widget build(BuildContext context) {
    final actionVisual = _pokerActionChoiceVisualV1(option.label);
    final tone = selected
        ? option.isCorrect
              ? Act0VisualCanonV1.greenTable
              : Act0ShellTokensV1.danger
        : Act0ShellTokensV1.text;
    final markerTone = selected ? tone : Act0ShellTokensV1.info;
    final marker = option.id == 'not_sure_yet'
        ? '?'
        : String.fromCharCode(65 + optionIndex);
    return KeyedSubtree(
      key: actionVisual == null
          ? null
          : Key('act0_shell_poker_action_button_${actionVisual.id}'),
      child: Material(
        key: actionVisual == null
            ? null
            : Key('act0_shell_poker_action_tactile_surface_${option.id}'),
        elevation: actionVisual == null ? 0 : (selected ? 5 : 2),
        shadowColor: markerTone.withValues(alpha: selected ? 0.34 : 0.18),
        color: selected
            ? tone.withValues(alpha: 0.16)
            : actionVisual == null
            ? Colors.transparent
            : Act0ShellTokensV1.surface3.withValues(alpha: 0.76),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected
                ? tone.withValues(alpha: 0.52)
                : actionVisual == null
                ? Colors.transparent
                : markerTone.withValues(alpha: 0.22),
          ),
        ),
        child: InkWell(
          key: Key('act0_shell_option_${option.id}'),
          onTap: () => onChoose(option),
          borderRadius: BorderRadius.circular(18),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: compact ? (readableCompactHeight ? 56 : 48) : 52,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 14,
                vertical: compact ? 5 : 10,
              ),
              child: Row(
                children: [
                  Container(
                    key: Key('act0_shell_option_marker_${option.id}'),
                    width: compact ? 26 : 32,
                    height: compact ? 26 : 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? tone.withValues(alpha: 0.18)
                          : markerTone.withValues(
                              alpha: actionVisual == null ? 0.10 : 0.13,
                            ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: selected
                            ? tone.withValues(alpha: 0.46)
                            : markerTone.withValues(
                                alpha: actionVisual == null ? 0.24 : 0.34,
                              ),
                      ),
                    ),
                    child: Text(
                      marker,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: selected
                            ? tone
                            : Act0ShellTokensV1.info.withValues(alpha: 0.92),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act0RuntimeLocalizedOptionLabelV1(
                            context,
                            option.label,
                          ),
                          textAlign: TextAlign.left,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: tone,
                            fontSize: compact ? 12.6 : 13.2,
                            fontWeight: actionVisual == null
                                ? FontWeight.w700
                                : FontWeight.w900,
                            height: compact ? 1.08 : 1.14,
                          ),
                        ),
                        if (option.amountLabel.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            option.amountLabel,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.0,
                              color: selected
                                  ? tone.withValues(alpha: 0.9)
                                  : Act0ShellTokensV1.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PokerActionChoiceVisualV1 {
  const _PokerActionChoiceVisualV1({
    required this.id,
    required this.icon,
    required this.tone,
  });

  final String id;
  final IconData icon;
  final Color tone;
}

_PokerActionChoiceVisualV1? _pokerActionChoiceVisualV1(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }
  final firstWord = normalized.split(RegExp(r'\s+')).first;
  if (normalized == 'fold' || firstWord == 'fold') {
    return const _PokerActionChoiceVisualV1(
      id: 'fold',
      icon: Icons.logout_rounded,
      tone: Act0ShellTokensV1.danger,
    );
  }
  if (normalized == 'check' || firstWord == 'check') {
    return const _PokerActionChoiceVisualV1(
      id: 'check',
      icon: Icons.check_rounded,
      tone: Act0VisualCanonV1.greenTable,
    );
  }
  if (normalized == 'call' || firstWord == 'call') {
    return const _PokerActionChoiceVisualV1(
      id: 'call',
      icon: Icons.call_received_rounded,
      tone: Act0ShellTokensV1.primary,
    );
  }
  if (normalized == 'raise' ||
      normalized == 'bet' ||
      normalized.endsWith('-bet') ||
      firstWord == 'raise' ||
      firstWord == 'bet') {
    return const _PokerActionChoiceVisualV1(
      id: 'raise',
      icon: Icons.trending_up_rounded,
      tone: Act0ShellTokensV1.gold,
    );
  }
  return null;
}

class _ActionPromptPanelV1 extends StatelessWidget {
  const _ActionPromptPanelV1({
    required this.taskLabel,
    required this.questionBadgeLabel,
    required this.question,
    required this.child,
    this.contextLine,
    this.trailingContext,
    this.embedChildInSurface = false,
    this.compactDecision = false,
    this.fillAllocatedDock = false,
    this.onBack,
    this.recallLabel,
    this.onRecall,
  });

  final String taskLabel;
  final String questionBadgeLabel;
  final String question;
  final Widget child;
  final String? contextLine;
  final Widget? trailingContext;
  final bool embedChildInSurface;
  final bool compactDecision;
  final bool fillAllocatedDock;
  final VoidCallback? onBack;
  final String? recallLabel;
  final VoidCallback? onRecall;

  @override
  Widget build(BuildContext context) {
    final effectiveCompactDecision =
        !embedChildInSurface &&
        (compactDecision ||
            _CompactAnswerListDecisionScopeV1.isCompact(context) ||
            _usesCompactAnswerListLeafFallbackV1(context));
    final formattedTaskLabel = _formatActionPromptCopyV1(
      taskLabel,
      shortThreshold: 32,
    );
    final formattedQuestion = _formatActionPromptCopyV1(
      question,
      shortThreshold: 58,
    );
    final compactContextLine = (contextLine ?? '').trim();
    final showCompactContextLine =
        compactContextLine.isNotEmpty &&
        compactContextLine != 'Start with what is visible.';
    final normalizedQuestion = question.trim().toLowerCase();
    final normalizedTaskLabel = taskLabel.trim().toLowerCase();
    final isFirstTableOrientation =
        normalizedQuestion.contains('hero seat') ||
        normalizedTaskLabel.contains('correct seat');
    Widget buildPromptHeader({bool integrated = false}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _DockBackButtonV1(
                key: const Key('act0_shell_interaction_back_cta'),
                onPressed: onBack!,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstTableOrientation) ...[
                  if (effectiveCompactDecision)
                    Row(
                      key: const Key('act0_shell_first_table_read_milestone'),
                      children: [
                        const Icon(
                          Icons.table_restaurant_rounded,
                          size: 13,
                          color: Act0ShellTokensV1.info,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'First table read · Locate your seat',
                            key: const Key(
                              'act0_shell_first_table_orientation',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.info,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Column(
                      key: const Key('act0_shell_first_table_read_milestone'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          key: const Key('act0_shell_first_table_orientation'),
                          children: [
                            const Icon(
                              Icons.table_restaurant_rounded,
                              size: 14,
                              color: Act0ShellTokensV1.info,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'First table read',
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.info,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Step 1 · Locate your seat',
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Read the table from your seat before any action.',
                      style: Act0ShellTokensV1.muted.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
                if (!effectiveCompactDecision) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _DockStatusPillV1(
                      key: const Key('act0_shell_question_badge'),
                      label: questionBadgeLabel,
                      icon: Icons.help_outline_rounded,
                      tone: Act0ShellTokensV1.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTaskLabel,
                    key: const Key('act0_shell_action_task_label'),
                    textAlign: TextAlign.left,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.info,
                      letterSpacing: 0.12,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.6,
                    ),
                  ),
                ],
                if (!effectiveCompactDecision &&
                    contextLine != null &&
                    contextLine!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    contextLine!,
                    key: const Key('act0_shell_action_context_line'),
                    textAlign: TextAlign.left,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
                if (!effectiveCompactDecision) const SizedBox(height: 7),
                if (effectiveCompactDecision &&
                    onRecall != null &&
                    recallLabel != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          formattedQuestion,
                          key: const Key('act0_shell_action_question'),
                          textAlign: TextAlign.left,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900,
                            height: 1.06,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      KeyedSubtree(
                        key: const Key('act0_shell_compact_hint_inline'),
                        child: _TheoryRecallCtaV1(
                          label: recallLabel!,
                          onPressed: onRecall!,
                          centered: false,
                          compact: true,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    formattedQuestion,
                    key: const Key('act0_shell_action_question'),
                    textAlign: TextAlign.left,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: effectiveCompactDecision ? 14.0 : 15.8,
                      fontWeight: FontWeight.w900,
                      height: effectiveCompactDecision ? 1.06 : 1.14,
                    ),
                  ),
                if (effectiveCompactDecision && showCompactContextLine) ...[
                  const SizedBox(height: 1),
                  Text(
                    compactContextLine,
                    key: const Key('act0_shell_action_context_line'),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 10.6,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                    ),
                  ),
                ],
                if (!effectiveCompactDecision &&
                    onRecall != null &&
                    recallLabel != null) ...[
                  SizedBox(height: effectiveCompactDecision ? 2 : 6),
                  _TheoryRecallCtaV1(
                    label: recallLabel!,
                    onPressed: onRecall!,
                    centered: false,
                    compact: effectiveCompactDecision,
                  ),
                ],
                if (integrated) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Act0ShellTokensV1.info.withValues(alpha: 0.16),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      key: const Key('act0_shell_action_prompt_panel'),
      mainAxisSize:
          fillAllocatedDock && question.isNotEmpty && effectiveCompactDecision
          ? MainAxisSize.max
          : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.isNotEmpty && embedChildInSurface) ...[
          Container(
            key: const Key('act0_shell_action_prompt_integrated_surface'),
            padding: const EdgeInsets.fromLTRB(
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapSm,
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapMd,
            ),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildPromptHeader(integrated: true),
                if (trailingContext != null) ...[
                  trailingContext!,
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
                child,
              ],
            ),
          ),
        ] else if (question.isNotEmpty && effectiveCompactDecision) ...[
          if (fillAllocatedDock)
            Expanded(child: _buildCompactDecisionSurface(buildPromptHeader))
          else
            _buildCompactDecisionSurface(buildPromptHeader),
        ] else if (question.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.fromLTRB(
              effectiveCompactDecision ? 12 : Act0ShellTokensV1.gapMd,
              effectiveCompactDecision ? 6 : Act0ShellTokensV1.gapSm,
              effectiveCompactDecision ? 12 : Act0ShellTokensV1.gapMd,
              effectiveCompactDecision ? 7 : Act0ShellTokensV1.gapMd,
            ),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
              ),
            ),
            child: buildPromptHeader(),
          ),
          SizedBox(
            height: effectiveCompactDecision ? 5 : Act0ShellTokensV1.gapSm,
          ),
        ] else if (onBack != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: _DockBackButtonV1(
              key: const Key('act0_shell_interaction_back_cta'),
              onPressed: onBack!,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
        if (!embedChildInSurface &&
            !(question.isNotEmpty && effectiveCompactDecision)) ...[
          if (trailingContext != null) ...[
            trailingContext!,
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
          child,
        ],
      ],
    );
  }

  Widget _buildCompactDecisionContent(
    Widget Function({bool integrated}) buildPromptHeader,
  ) {
    return Column(
      mainAxisSize: fillAllocatedDock ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildPromptHeader(),
        const SizedBox(height: 3),
        if (trailingContext != null) ...[
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          trailingContext!,
          const SizedBox(height: Act0ShellTokensV1.gapXs),
        ],
        if (fillAllocatedDock)
          Expanded(
            child: KeyedSubtree(
              key: const Key('act0_shell_wave1b_actionability_anchor'),
              child: KeyedSubtree(
                key: const Key('act0_shell_wave1b_answer_peek'),
                child: child,
              ),
            ),
          )
        else
          KeyedSubtree(
            key: const Key('act0_shell_wave1b_actionability_anchor'),
            child: KeyedSubtree(
              key: const Key('act0_shell_wave1b_answer_peek'),
              child: child,
            ),
          ),
      ],
    );
  }

  Widget _buildCompactDecisionSurface(
    Widget Function({bool integrated}) buildPromptHeader,
  ) {
    return KeyedSubtree(
      key: const Key('act0_shell_runner_decision_rhythm_surface'),
      child: Container(
        key: const Key('act0_shell_compact_decision_surface'),
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Act0ShellTokensV1.info.withValues(alpha: 0.20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: _buildCompactDecisionContent(buildPromptHeader),
      ),
    );
  }
}

class _TheoryRecallCtaV1 extends StatelessWidget {
  const _TheoryRecallCtaV1({
    required this.label,
    required this.onPressed,
    this.centered = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool centered;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final effectiveCompact =
        compact || _CompactAnswerListDecisionScopeV1.isCompact(context);
    if (effectiveCompact) {
      final button = IconButton(
        key: const Key('act0_shell_theory_recall_cta'),
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 24),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: Act0ShellTokensV1.info,
        ),
        icon: const Icon(Icons.auto_stories_rounded, size: 15),
      );
      if (centered) {
        return Align(alignment: Alignment.center, child: button);
      }
      return Align(alignment: Alignment.centerLeft, child: button);
    }
    final button = TextButton.icon(
      key: const Key('act0_shell_theory_recall_cta'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Act0ShellTokensV1.info.withValues(alpha: 0.10),
        side: BorderSide(color: Act0ShellTokensV1.info.withValues(alpha: 0.24)),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: effectiveCompact ? 6 : 0,
          vertical: effectiveCompact ? 1 : 2,
        ),
        minimumSize: Size(0, effectiveCompact ? 22 : 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Act0ShellTokensV1.info,
      ),
      icon: Icon(Icons.auto_stories_rounded, size: effectiveCompact ? 14 : 16),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.info,
          fontSize: effectiveCompact ? 10.6 : 11.6,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.12,
        ),
      ),
    );
    final coachingChip = KeyedSubtree(
      key: const Key('act0_shell_hint_coaching_chip'),
      child: button,
    );
    if (centered) {
      return Align(alignment: Alignment.center, child: coachingChip);
    }
    return Align(alignment: Alignment.centerLeft, child: coachingChip);
  }
}

class _DecisionHintPeekV1 extends StatelessWidget {
  const _DecisionHintPeekV1({
    required this.quickHint,
    required this.fullIdeaTitle,
    required this.fullIdeaBlocks,
    required this.showFullIdea,
    required this.onShowFullIdea,
    required this.onClose,
  });

  final String quickHint;
  final String fullIdeaTitle;
  final List<String> fullIdeaBlocks;
  final bool showFullIdea;
  final VoidCallback? onShowFullIdea;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hasFullIdea =
        fullIdeaTitle.trim().isNotEmpty || fullIdeaBlocks.isNotEmpty;
    return Container(
      key: const Key('act0_shell_theory_recall_sheet'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick hint',
                  key: const Key('act0_shell_hint_title'),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    fontSize: 10.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
              TextButton.icon(
                key: const Key('act0_shell_theory_recall_close_cta'),
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: Act0ShellTokensV1.info,
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 15),
                label: Text(
                  'Back to choices',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            quickHint,
            key: const Key('act0_shell_hint_body'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: 12.6,
              height: 1.14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasFullIdea && !showFullIdea) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              key: const Key('act0_shell_review_full_idea_cta'),
              onPressed: onShowFullIdea,
              style: TextButton.styleFrom(
                foregroundColor: Act0ShellTokensV1.info,
                minimumSize: const Size(0, 28),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.auto_stories_rounded, size: 15),
              label: Text(
                'Review full idea',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.info,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          if (hasFullIdea && showFullIdea) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              height: 1,
              color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
            ),
            if (fullIdeaTitle.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                fullIdeaTitle.trim(),
                key: const Key('act0_shell_theory_recall_title'),
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontSize: 14.2,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            for (var i = 0; i < fullIdeaBlocks.length; i++) ...[
              SizedBox(height: i == 0 ? 7 : 5),
              Text(
                fullIdeaBlocks[i],
                key: i == 0 ? const Key('act0_shell_theory_recall_body') : null,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontSize: 12.4,
                  height: 1.14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TheoryRecallSheetV1 extends StatelessWidget {
  const _TheoryRecallSheetV1({
    required this.label,
    required this.title,
    required this.bodyBlocks,
  });

  final String label;
  final String title;
  final List<String> bodyBlocks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Container(
          key: const Key('act0_shell_theory_recall_sheet'),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            border: Border.all(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.info,
                        fontSize: 10.4,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('act0_shell_theory_recall_close_cta'),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ],
              ),
              if (title.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  title.trim(),
                  key: const Key('act0_shell_theory_recall_title'),
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontSize: 16,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              for (var i = 0; i < bodyBlocks.length; i++) ...[
                SizedBox(height: i == 0 ? 8 : 6),
                Text(
                  bodyBlocks[i],
                  key: i == 0
                      ? const Key('act0_shell_theory_recall_body')
                      : null,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontSize: 13,
                    height: 1.14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetReplayInlineV1 extends StatelessWidget {
  const _StreetReplayInlineV1({required this.replay});

  final Act0StreetReplayV1 replay;

  @override
  Widget build(BuildContext context) {
    final currentStreet = replay.steps
        .where((step) => step.isCurrentStreet)
        .toList(growable: false);
    final visibleSteps = currentStreet.isEmpty ? replay.steps : currentStreet;
    return Container(
      key: const Key('act0_shell_street_replay_inline'),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How we got here',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontSize: 10.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < visibleSteps.length; i++) ...[
            _ProofMotionRevealV1(
              key: Key('act0_shell_street_replay_step_motion_$i'),
              child: _StreetReplayStepRowV1(step: visibleSteps[i], index: i),
            ),
            if (i < visibleSteps.length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapXs),
          ],
          if (!visibleSteps.any((step) => step.isCurrentStreet)) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            _StreetReplayCurrentDecisionMarkerV1(replay: replay),
          ],
          if (replay.decisionContext.trim().isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              replay.decisionContext.trim(),
              key: const Key('act0_shell_street_replay_decision_context'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: 10.4,
                height: 1.08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreetReplayCurrentDecisionMarkerV1 extends StatelessWidget {
  const _StreetReplayCurrentDecisionMarkerV1({required this.replay});

  final Act0StreetReplayV1 replay;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_street_replay_current_street'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${replay.currentStreet.name[0].toUpperCase()}${replay.currentStreet.name.substring(1)} decision',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                fontSize: 10.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            key: const Key('act0_shell_street_replay_here_marker'),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: Text(
              'You are here',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.info,
                fontSize: 8.6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetReplayStepRowV1 extends StatelessWidget {
  const _StreetReplayStepRowV1({required this.step, required this.index});

  final Act0StreetReplayStepV1 step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final board = step.boardCardsAtStreet.join(' ');
    return Container(
      key: Key('act0_shell_street_replay_step_$index'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      decoration: BoxDecoration(
        color: step.isCurrentStreet
            ? Act0ShellTokensV1.info.withValues(alpha: 0.10)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: step.isCurrentStreet
              ? Act0ShellTokensV1.info.withValues(alpha: 0.32)
              : Act0ShellTokensV1.border.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface3.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: Text(
              '${index + 1}',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        board.isEmpty
                            ? step.streetLabel
                            : '${step.streetLabel} - $board',
                        key: step.isCurrentStreet
                            ? const Key(
                                'act0_shell_street_replay_current_street',
                              )
                            : null,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (step.isCurrentStreet) ...[
                      const SizedBox(width: 7),
                      Container(
                        key: const Key('act0_shell_street_replay_here_marker'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                        ),
                        child: Text(
                          step.youAreHereLabel,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.info,
                            fontSize: 8.6,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  step.actionSummary,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontSize: 12,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (step.potAtStreet.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.potAtStreet.trim(),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.textDim,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatActionPromptCopyV1(String text, {required int shortThreshold}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= shortThreshold) {
    return normalized;
  }
  return _formatInstructionCopyV1(normalized, allowSingleClauseSplit: true);
}

class _DockStatusPillV1 extends StatelessWidget {
  const _DockStatusPillV1({
    super.key,
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: tone,
              fontSize: 9.5,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionToneV1 {
  const _ActionToneV1({required this.foreground});

  final Color foreground;

  static _ActionToneV1 fromOption(Act0RunnerOptionV1 option) {
    final key = '${option.id} ${option.label}'.toLowerCase();
    if (key.contains('call')) {
      return _ActionToneV1(foreground: Act0ShellTokensV1.info);
    }
    if (key.contains('raise') || key.contains('bet') || key.contains('all')) {
      return _ActionToneV1(foreground: Act0ShellTokensV1.primary);
    }
    if (key.contains('fold') || key.contains('check')) {
      return _ActionToneV1(foreground: Act0ShellTokensV1.text);
    }
    return _ActionToneV1(foreground: Act0ShellTokensV1.text);
  }
}

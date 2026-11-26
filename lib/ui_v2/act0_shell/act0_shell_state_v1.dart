import 'act0_action_reason_v1.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_solver/poker_solver.dart' as solver;

import 'act0_curriculum_pilot_v1.dart';
import 'act0_decision_reasoning_v1.dart';
import 'act0_b19_turn_truth_v1.dart';
import 'act0_goal_route_v1.dart';
import 'act0_decision_ledger_v1.dart';
import 'act0_hand_contributions_v1.dart';
import 'act0_hand_timeline_v1.dart';
import 'act0_seat_order_v1.dart';
import 'act0_street_summary_v1.dart';
import 'act0_poker_reference_math_v1.dart';
import 'act0_practice_showdown_v1.dart';
import 'act0_preflop_equity_v1.dart';
import 'act0_starting_chart_v1.dart';
import 'act0_asm05_authored_decision_truth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

import 'act0_w1_rules_check_v1.dart';

part 'act0_shell_review_tasks_v1.dart';
part 'act0_daily_deal_generator_v1.dart';
part 'act0_daily_deal_pilot_v1.dart';
part 'act0_multi_street_v1.dart';
part 'act0_shell_day7_review_v1.dart';
part 'act0_shell_hand_timelines_v1.dart';
part 'act0_shell_hand_timelines_w1_w4_v1.dart';
part 'act0_shell_day7_content_v1.dart';
part 'act0_shell_lessons_w1_w4_v1.dart';
part 'act0_shell_lessons_w5_w8_v1.dart';
part 'act0_shell_lessons_w9_w12_v1.dart';
part 'act0_shell_w12_summary_v1.dart';
part 'act0_shell_lessons_w13_w14_v1.dart';
part 'act0_shell_lessons_w15_w16_v1.dart';
part 'act0_shell_lessons_w17_w18_v1.dart';
part 'act0_shell_lessons_w19_w20_v1.dart';
part 'act0_shell_lessons_w21_w22_v1.dart';
part 'act0_shell_lessons_w23_w24_v1.dart';
part 'act0_shell_lessons_b19_v1.dart';
part 'act0_shell_lessons_ninemax_v1.dart';
part 'act0_shell_lessons_live_room_v1.dart';
part 'act0_shell_runners_part1_v1.dart';
part 'act0_shell_runners_part2_v1.dart';
part 'act0_shell_runners_part3_v1.dart';
part 'act0_shell_runners_part4_v1.dart';
part 'act0_y5d_lesson_tasks_v1.dart';

const act0NineSeatDebugEnabledV1 =
    kDebugMode && bool.fromEnvironment('tableNineSeatV1');

const act0LiveRoomModuleIdV1 = 'live_room_v1';

enum Act0ShellTabV1 { home, learn, play, review, profile }

enum Act0LessonStateV1 { completed, current, locked, available }

enum Act0WorldStateV1 { completed, current, locked, passedByRulesCheck }

enum Act0LessonPhaseV1 { theory, drill, review }

enum Act0LessonStepKindV1 { learn, practice, fixMistakes, review, proveIt }

enum Act0FeedbackQualityV1 {
  correct('correct'),
  coCorrect('co_correct'),
  acceptable('acceptable'),
  suboptimal('suboptimal'),
  wrong('incorrect');

  const Act0FeedbackQualityV1(this.resultKind);

  final String resultKind;

  bool get isPreferred => this == correct || this == coCorrect;

  bool get passes => isPreferred || this == acceptable;
}

enum Act0CompletionDisplayStateV1 { locked, current, clear, perfect }

enum Act0MasteryStatusV1 { learning, needsReview, solid, cleanPass }

enum Act0TableDensityV1 { compactLesson, handView }

enum Act0TableFormatV1 { sixMax, nineMax, tenMax }

enum Act0CardToneV1 { dark, red }

enum Act0SeatBetKindV1 { post, call, bet, raise, allIn }

enum Act0CardsVisibleModeV1 { none, faceDown, faceUp }

enum Act0PlacementResultLevelV1 { newPlayer, rustyBeginner, readyForBasics }

enum Act0TaskFamilyV1 {
  learn,
  recognition,
  decision,
  sizing,
  compare,
  counting,
  repair,
  review,
  transfer,
}

final Map<Act0TableFormatV1, List<String>> act0CanonicalSeatOrderByFormatV1 =
    Map.unmodifiable({
      Act0TableFormatV1.sixMax: act0PreflopPositionsByCountV1[6]!,
      Act0TableFormatV1.nineMax: act0PreflopPositionsByCountV1[9]!,
      // Retained for existing data and labels.
      Act0TableFormatV1.tenMax: const [
        'UTG',
        'UTG+1',
        'UTG+2',
        'MP',
        'LJ',
        'HJ',
        'CO',
        'BTN',
        'SB',
        'BB',
      ],
    });

List<String> act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1 format) =>
    act0CanonicalSeatOrderByFormatV1[format]!;

int act0ExpectedPlayerCountForFormatV1(Act0TableFormatV1 format) =>
    act0CanonicalSeatOrderForFormatV1(format).length;

Act0CompletionDisplayStateV1 act0ResolveTaskCompletionDisplayStateV1({
  required String taskId,
  required bool isLocked,
  required bool isCurrent,
  required Set<String> completedTaskIds,
  required Set<String> perfectTaskIds,
}) {
  if (isLocked) {
    return Act0CompletionDisplayStateV1.locked;
  }
  if (isCurrent) {
    return Act0CompletionDisplayStateV1.current;
  }
  if (perfectTaskIds.contains(taskId)) {
    return Act0CompletionDisplayStateV1.perfect;
  }
  if (completedTaskIds.contains(taskId)) {
    return Act0CompletionDisplayStateV1.clear;
  }
  return Act0CompletionDisplayStateV1.current;
}

String act0TableFormatLabelV1(Act0TableFormatV1 format) => switch (format) {
  Act0TableFormatV1.sixMax => '6-max',
  Act0TableFormatV1.nineMax => '9-max',
  Act0TableFormatV1.tenMax => '10-max',
};

Act0TaskFamilyV1 act0InferTaskFamilyV1({
  required Act0LessonPhaseV1 phase,
  required Act0LessonStepKindV1 stepKind,
}) {
  if (stepKind == Act0LessonStepKindV1.fixMistakes) {
    return Act0TaskFamilyV1.repair;
  }
  if (stepKind == Act0LessonStepKindV1.proveIt) {
    return Act0TaskFamilyV1.transfer;
  }
  return switch (phase) {
    Act0LessonPhaseV1.theory => Act0TaskFamilyV1.learn,
    Act0LessonPhaseV1.drill => Act0TaskFamilyV1.decision,
    Act0LessonPhaseV1.review => Act0TaskFamilyV1.review,
  };
}

// Detached wiring boundary:
// BeatV1/task data -> Act0ShellStateV1 -> Act0RunnerStateV1
// -> Act0TableStateV1 -> dumb Flutter renderers.

// TODO(Wave F): Split Act0ShellStateV1 into progression, review, recommendation, placement, profile/habit, tokens, feedback modules (see ACT0_ARCHITECTURE_SPLIT_ROADMAP_v1.md)
class Act0ShellStateV1 {
  const Act0ShellStateV1({
    required this.courseTitle,
    required this.courseSubtitle,
    required this.levelLabel,
    required this.xp,
    required this.xpTarget,
    required this.streakDays,
    required this.dailyGoalLabel,
    required this.dailyGoalValue,
    required this.pathProgressLabel,
    required this.selectedWorldId,
    required this.worlds,
    this.liveRoom,
    required this.lessons,
    required this.review,
    required this.profile,
  });

  final String courseTitle;
  final String courseSubtitle;
  final String levelLabel;
  final int xp;
  final int xpTarget;
  final int streakDays;
  final String dailyGoalLabel;
  final String dailyGoalValue;
  final String pathProgressLabel;
  final String selectedWorldId;
  // TODO(Wave F): Move to progression_state.dart
  final List<Act0WorldCardV1> worlds;
  final Act0WorldCardV1? liveRoom;
  final List<Act0LessonCardV1> lessons;

  Iterable<Act0WorldCardV1> get learningSections sync* {
    yield* worlds;
    if (liveRoom case final module?) yield module;
  }

  // TODO(Wave F): Move to review_state.dart
  final Act0ReviewStateV1 review;
  // TODO(Wave F): Move to profile_state.dart
  final Act0ProfileStateV1 profile;

  Act0WorldCardV1 get selectedWorld => worlds.firstWhere(
    (world) => world.worldId == selectedWorldId,
    orElse: () => worlds.first,
  );

  Act0WorldCardV1 worldById(String worldId) =>
      learningSections.firstWhere((world) => world.worldId == worldId);

  Act0LessonCardV1 get currentLesson => lessons.firstWhere(
    (lesson) => lesson.state == Act0LessonStateV1.current,
    orElse: () => lessons.firstWhere(
      (lesson) => !lesson.isLocked,
      orElse: () => lessons.first,
    ),
  );

  Act0LessonCardV1 lessonById(String lessonId) => lessons.firstWhere(
    (lesson) => lesson.lessonId == lessonId,
    orElse: () => learningSections
        .expand((world) => world.lessons)
        .firstWhere((lesson) => lesson.lessonId == lessonId),
  );

  Act0RunnerStateV1 runnerFor(String lessonId) => lessonById(lessonId).runner;

  double get xpProgress => xpTarget <= 0 ? 0 : (xp / xpTarget).clamp(0, 1);

  /// The normal Act0 entry uses the route-safe view of the authored catalog.
  static final sample = learnerCatalog();
  static final _learnerSixSeatCatalog = catalog(
    nineSeatPreview: false,
  ).forLearners();
  static final _learnerNineSeatCatalog = catalog(
    nineSeatPreview: true,
  ).forLearners(nineSeatPreview: true);

  static Act0ShellStateV1 learnerCatalog({
    bool nineSeatPreview = act0NineSeatDebugEnabledV1,
  }) => kDebugMode && nineSeatPreview
      ? _learnerNineSeatCatalog
      : _learnerSixSeatCatalog;

  Act0ShellStateV1 forLearners({bool nineSeatPreview = false}) {
    final routedLessons = <Act0LessonCardV1, Act0LessonCardV1?>{};
    Act0LessonCardV1? admitted(Act0LessonCardV1 lesson) {
      if (routedLessons.containsKey(lesson)) return routedLessons[lesson];
      return routedLessons[lesson] = lesson._forLearners(
        kDebugMode && nineSeatPreview,
      );
    }

    final projectedWorlds = <Act0WorldCardV1>[];
    for (final world in worlds) {
      final visible = world.lessons.map(admitted).nonNulls.toList();
      if (visible.length == world.lessons.length &&
          world.lessons.every(
            (lesson) => identical(admitted(lesson), lesson),
          )) {
        projectedWorlds.add(world);
      } else if (visible.isNotEmpty) {
        projectedWorlds.add(
          world.copyWith(lessons: List.unmodifiable(visible)),
        );
      }
    }
    final projectedLessons = lessons.map(admitted).nonNulls.toList();
    if (projectedWorlds.length == worlds.length &&
        projectedWorlds.every((world) => worlds.contains(world)) &&
        projectedLessons.length == lessons.length &&
        lessons.every((lesson) => identical(admitted(lesson), lesson))) {
      return this;
    }
    final selected =
        projectedWorlds
            .where((world) => world.worldId == selectedWorldId)
            .firstOrNull ??
        projectedWorlds.firstOrNull;
    return Act0ShellStateV1(
      courseTitle: courseTitle,
      courseSubtitle: courseSubtitle,
      levelLabel: levelLabel,
      xp: xp,
      xpTarget: xpTarget,
      streakDays: streakDays,
      dailyGoalLabel: dailyGoalLabel,
      dailyGoalValue: dailyGoalValue,
      pathProgressLabel: pathProgressLabel,
      selectedWorldId: selected?.worldId ?? selectedWorldId,
      worlds: List.unmodifiable(projectedWorlds),
      liveRoom: liveRoom,
      lessons: List.unmodifiable(
        projectedLessons.isEmpty ? selected?.lessons ?? [] : projectedLessons,
      ),
      review: review,
      profile: profile,
    );
  }

  static final authoredCatalog = catalog();
  static final _numberedCatalog = _buildCatalog(null, _act0PreviewWorlds);
  static final _catalogWithLiveRoom = _buildCatalog(
    _act0LiveRoomV1,
    _act0PreviewWorlds,
  );
  static final _nineSeatCatalog = _buildCatalog(null, _act0NineSeatWorldsV1);
  static final _nineSeatCatalogWithLiveRoom = _buildCatalog(
    _act0LiveRoomV1,
    _act0NineSeatWorldsV1,
  );

  static Act0ShellStateV1 catalog({
    bool liveRoomV1 = const bool.fromEnvironment('liveRoomV1'),
    bool nineSeatPreview = act0NineSeatDebugEnabledV1,
  }) => switch ((liveRoomV1, kDebugMode && nineSeatPreview)) {
    (true, true) => _nineSeatCatalogWithLiveRoom,
    (false, true) => _nineSeatCatalog,
    (true, false) => _catalogWithLiveRoom,
    (false, false) => _numberedCatalog,
  };

  static Act0ShellStateV1 _buildCatalog(
    Act0WorldCardV1? liveRoom,
    List<Act0WorldCardV1> worlds,
  ) => Act0ShellStateV1(
    courseTitle: 'Poker from Zero',
    courseSubtitle: 'Learn the table one clear decision at a time.',
    levelLabel: 'Level 1',
    xp: 120,
    xpTarget: 200,
    streakDays: 3,
    dailyGoalLabel: 'Daily goal',
    dailyGoalValue: '5 minutes today',
    pathProgressLabel: '4 of 10 lessons complete',
    selectedWorldId: 'world_1',
    worlds: worlds,
    liveRoom: liveRoom,
    lessons: worlds.first.lessons,
    review: Act0ReviewStateV1(
      title: 'What to fix next',
      subtitle: 'Clean up one decision before moving on.',
      weaknessLabel: 'Calling and raising still feel close.',
      reason:
          'Review when matching the blind is enough and when pressure helps.',
      stats: <Act0ReviewStatV1>[
        Act0ReviewStatV1(label: 'Weak spot', value: 'Action'),
        Act0ReviewStatV1(label: 'Today', value: '1 card'),
        Act0ReviewStatV1(label: 'Goal', value: 'Clear'),
      ],
      chosenLabel: 'Raise',
      betterLabel: 'Call',
    ),
    profile: Act0ProfileStateV1(
      playerName: 'New player',
      level: 'Level 1',
      xpLine: '120 / 200 XP',
      lessonsLine: '3 lessons complete',
      accuracyLine: '82% practice accuracy',
      qualityLine: 'Ready for your next hand',
      consistencyActiveDays: 11,
      streakLast7: const <bool>[false, false, false, false, true, true, true],
      achievements: <Act0AchievementV1>[
        Act0AchievementV1(id: 'first_table_read', label: 'First clear read'),
        Act0AchievementV1(
          id: 'three_day_streak',
          label: 'Three Days of Practice',
        ),
        Act0AchievementV1(
          id: 'first_perfect_drill',
          label: 'Clean drill chain',
          locked: true,
        ),
      ],
      strongCategories: <String>['Table', 'Cards', 'Streets'],
      weakCategories: <String>['Actions'],
      recentProgress: <String>[
        'Found the Button',
        'Named private cards',
        'Reached action practice',
      ],
      recentSkillGains: <Act0SkillGainV1>[
        Act0SkillGainV1(
          label: 'Table sense',
          gain: 4,
          source: 'Button and blinds',
        ),
        Act0SkillGainV1(
          label: 'Board reading',
          gain: 3,
          source: 'Read the flop',
        ),
      ],
      skillStats: <Act0PlacementSkillStatV1>[
        Act0PlacementSkillStatV1.core(label: 'Table sense', value: 38),
        Act0PlacementSkillStatV1.core(label: 'Board reading', value: 24),
        Act0PlacementSkillStatV1.core(label: 'Hand reading', value: 30),
        Act0PlacementSkillStatV1.core(label: 'Betting decisions', value: 36),
        Act0PlacementSkillStatV1.core(label: 'Position play', value: 20),
        Act0PlacementSkillStatV1.core(label: 'Blind play', value: 16),
      ],
    ),
  );
}

// TODO(Wave F): Move to world_card.dart
class Act0WorldCardV1 implements Act0GoalRouteWorldV1 {
  const Act0WorldCardV1({
    required this.worldId,
    required this.worldNumber,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progressLabel,
    required this.primaryCtaLabel,
    required this.unlockLabel,
    required this.isSelectable,
    required this.isLocked,
    required this.rewardXp,
    required this.lessons,
  });

  @override
  final String worldId;
  @override
  final int worldNumber;
  final String title;
  final String subtitle;
  final Act0WorldStateV1 status;
  final String progressLabel;
  final String primaryCtaLabel;
  final String unlockLabel;
  final bool isSelectable;
  final bool isLocked;
  final int rewardXp;
  final List<Act0LessonCardV1> lessons;

  Act0WorldCardV1 copyWith({
    Act0WorldStateV1? status,
    String? progressLabel,
    String? primaryCtaLabel,
    String? unlockLabel,
    bool? isSelectable,
    bool? isLocked,
    List<Act0LessonCardV1>? lessons,
  }) {
    return Act0WorldCardV1(
      worldId: worldId,
      worldNumber: worldNumber,
      title: title,
      subtitle: subtitle,
      status: status ?? this.status,
      progressLabel: progressLabel ?? this.progressLabel,
      primaryCtaLabel: primaryCtaLabel ?? this.primaryCtaLabel,
      unlockLabel: unlockLabel ?? this.unlockLabel,
      isSelectable: isSelectable ?? this.isSelectable,
      isLocked: isLocked ?? this.isLocked,
      rewardXp: rewardXp,
      lessons: lessons ?? this.lessons,
    );
  }
}

// TODO(Wave F): Move to lesson_card.dart
class Act0LessonCardV1 {
  const Act0LessonCardV1({
    required this.lessonId,
    String? authoredLessonId,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.phaseLabel,
    required this.primaryCtaLabel,
    required this.isSelectable,
    required this.isLocked,
    required this.rewardXp,
    required this.runner,
    this.tasks = const <Act0LessonTaskV1>[],
  }) : authoredLessonId = authoredLessonId ?? lessonId;

  final String lessonId;
  final String authoredLessonId;
  final String title;
  final String subtitle;
  final Act0LessonStateV1 state;
  final String phaseLabel;
  final String primaryCtaLabel;
  final bool isSelectable;
  final bool isLocked;
  final int rewardXp;
  final Act0RunnerStateV1 runner;
  final List<Act0LessonTaskV1> tasks;

  List<Act0LessonTaskV1> get taskList => tasks.isEmpty
      ? <Act0LessonTaskV1>[
          Act0LessonTaskV1(
            taskId: '${lessonId}_single',
            title: title,
            phase: runner.phase,
            runner: runner,
            rewardXp: rewardXp,
          ),
        ]
      : tasks;

  /// The mandatory route; repair targets stay addressable in the full catalog.
  List<Act0LessonTaskV1> get courseTaskList =>
      taskList.where((task) => !task.repairOnly).toList(growable: false);

  Act0LessonCardV1? _forLearners(bool nineSeatPreview) {
    bool supportsTable(Act0RunnerStateV1 value) =>
        value.supportsLearnerTable ||
        (nineSeatPreview && act0RunnerSupportsNineSeatPreviewV1(value));
    final all = taskList;
    final visible = all.where((task) => supportsTable(task.runner)).toList();
    if (visible.length == all.length && supportsTable(runner)) return this;
    final firstCourseTask = visible
        .where((task) => !task.repairOnly)
        .firstOrNull;
    if (firstCourseTask == null) return null;
    return copyWith(
      runner: supportsTable(runner) ? runner : firstCourseTask.runner,
      tasks: List.unmodifiable(visible),
    );
  }

  Act0LessonCardV1 copyWith({
    Act0LessonStateV1? state,
    String? primaryCtaLabel,
    bool? isSelectable,
    bool? isLocked,
    Act0RunnerStateV1? runner,
    List<Act0LessonTaskV1>? tasks,
  }) {
    return Act0LessonCardV1(
      lessonId: lessonId,
      authoredLessonId: authoredLessonId,
      title: title,
      subtitle: subtitle,
      state: state ?? this.state,
      phaseLabel: phaseLabel,
      primaryCtaLabel: primaryCtaLabel ?? this.primaryCtaLabel,
      isSelectable: isSelectable ?? this.isSelectable,
      isLocked: isLocked ?? this.isLocked,
      rewardXp: rewardXp,
      runner: runner ?? this.runner,
      tasks: tasks ?? this.tasks,
    );
  }
}

String act0LockedWorldProgressLabelV1({required bool isImmediateNext}) {
  return isImmediateNext ? 'Next in Volume I' : 'Later in Volume I';
}

String act0LockedWorldPrimaryCtaLabelV1({required bool isImmediateNext}) {
  return isImmediateNext ? 'View next world' : 'View route';
}

String act0LockedWorldUnlockLabelV1(String prerequisiteTitle) {
  return 'Finish $prerequisiteTitle to open this world.';
}

/// Source-owned answer-submission semantics for the two runner compositions.
///
/// The table-native family is intentionally keyed by authored task identity,
/// not inferred from incidental option fields. New table-submit tasks must be
/// admitted here before they can receive F1 geometry.
enum Act0RunnerCompositionFamilyV1 { f1TableNative, f2AnswerList }

const Set<String> act0F1TableNativeTaskIdsV1 = <String>{
  'what_poker_is_theory',
  'what_poker_is_find_hero',
  'blinds_posts_drill',
  'blinds_first_actor',
  'blinds_last_actor',
  'blinds_postflop_button',
  'blinds_review',
  'positions_theory',
  'positions_button',
  'positions_utg',
  'positions_cutoff',
  'positions_late_seat',
  'positions_early_late',
  'position_six_seats_positions_utg',
  'position_six_seats_hj_co_contrast',
  'position_six_seats_positions_cutoff',
  'position_six_seats_positions_button',
  'position_six_seats_sb_recognition',
  'position_six_seats_bb_recognition',
  'position_six_seats_position_repair_seat_id_btn',
  'position_six_seats_position_repair_seat_id_utg',
  'button_advantage_button_intro',
  'button_advantage_find_button',
  'button_advantage_button_last',
  'button_advantage_button_vs_cutoff',
  'button_advantage_position_repair_btn_last_postflop',
  'button_advantage_button_recap',
  'early_vs_late_w2_position_intro',
  'early_vs_late_w2_late_position',
  'early_vs_late_w2_early_position',
  'early_vs_late_w2_position_recap',
  'same_hand_different_seat_w3_same_hand_recap',
  'position_apply_intro',
  'position_checkpoint_position_checkpoint_intro',
};

Act0RunnerCompositionFamilyV1 act0RunnerCompositionFamilyForTaskIdV1(
  String taskId,
) {
  return act0F1TableNativeTaskIdsV1.contains(taskId.trim())
      ? Act0RunnerCompositionFamilyV1.f1TableNative
      : Act0RunnerCompositionFamilyV1.f2AnswerList;
}

/// Four-option answer lists are closed by default. A future compact parallel
/// action set must be explicitly admitted here after native compact 1.4x proof.
const Set<String> act0CompactFourActionAdmissionTaskIdsV1 = <String>{};

bool act0IsAdmittedCompactFourActionTaskV1(Act0LessonTaskV1 task) {
  if (!act0CompactFourActionAdmissionTaskIdsV1.contains(task.taskId) ||
      task.runner.options.length != 4) {
    return false;
  }
  return task.runner.options.every(
    (option) =>
        option.amountLabel.trim().isEmpty && option.label.trim().length <= 36,
  );
}

class Act0LessonTaskV1 {
  const Act0LessonTaskV1({
    required this.taskId,
    required this.title,
    required this.phase,
    required this.runner,
    required this.rewardXp,
    this.stepKind = Act0LessonStepKindV1.practice,
    this.taskFamily,
    this.tablePresentation = Act0TaskTablePresentationV1.legacy,
    this.repairOnly = false,
    this.guidedDecision = false,
    this.summary,
    this.lockedSummary,
    this.multiStreet,
    this.betSize,
  });

  final String taskId;
  final String title;
  final Act0LessonPhaseV1 phase;

  /// Authored review is a learning role; runtime review is evaluated feedback.
  /// A review task with choices must first collect an answer, like a drill.
  Act0LessonPhaseV1 get entryPhase =>
      phase == Act0LessonPhaseV1.review && runner.options.isNotEmpty
      ? Act0LessonPhaseV1.drill
      : phase;

  final Act0RunnerStateV1 runner;
  final int rewardXp;
  final Act0LessonStepKindV1 stepKind;
  final Act0TaskFamilyV1? taskFamily;
  final Act0TaskTablePresentationV1 tablePresentation;
  final bool repairOnly;

  /// The teaching step models the answer for this decision.
  final bool guidedDecision;
  final String? summary;
  final String? lockedSummary;
  final Act0MultiStreetV1? multiStreet;
  final Act0BetSizeV1? betSize;

  List<Act0ReasonV1>? get reasons => act0ActionReasonPilotsV1[taskId]?.reasons;

  Act0TaskFamilyV1 get resolvedTaskFamily =>
      taskFamily ?? act0InferTaskFamilyV1(phase: phase, stepKind: stepKind);

  Act0RunnerCompositionFamilyV1 get resolvedCompositionFamily =>
      act0RunnerCompositionFamilyForTaskIdV1(taskId);
}

/// Opt-in answer format. Grades and feedback belong to the existing authored
/// options with these IDs; only the pot fractions are new authored data.
class Act0BetSizeV1 {
  const Act0BetSizeV1(this.fractions);

  static const answerType = 'bet_size';

  final Map<String, ({int numerator, int denominator})> fractions;
}

/// Source-owned table presentation behavior for one canonical task.
enum Act0TaskTablePresentationV1 { legacy, spatialTheory, stablePractice }

enum Act0HintPolicyV1 { always, theoryOnly, hidden }

enum Act0SizingUiModeV1 { hidden, presetsOnly, presetsWithSlider }

class Act0SizingPresetV1 {
  const Act0SizingPresetV1({
    required this.id,
    required this.label,
    required this.potFraction,
    this.displayLabel,
    this.semanticLabel,
    this.detailLabel,
    this.ctaLabel,
    this.isPrimary = false,
  });

  final String id;
  final String label;
  final double potFraction;
  final String? displayLabel;
  final String? semanticLabel;
  final String? detailLabel;
  final String? ctaLabel;
  final bool isPrimary;
}

class Act0SizingConfigV1 {
  const Act0SizingConfigV1({
    this.mode = Act0SizingUiModeV1.hidden,
    this.presets = const <Act0SizingPresetV1>[],
    this.showGuidance = true,
  });

  const Act0SizingConfigV1.disabled()
    : mode = Act0SizingUiModeV1.hidden,
      presets = const <Act0SizingPresetV1>[],
      showGuidance = true;

  final Act0SizingUiModeV1 mode;
  final List<Act0SizingPresetV1> presets;
  final bool showGuidance;

  bool get isEnabled => mode != Act0SizingUiModeV1.hidden;
}

/// The F2 model declares the table format and player count. Older snapshots
/// can still carry a seat list with more places than the declared count.
int act0TableSeatCountV1(Act0TableStateV1 table) {
  final modelCount = table.tableFormat == Act0TableFormatV1.sixMax
      ? table.playerCount
      : act0ExpectedPlayerCountForFormatV1(table.tableFormat);
  return modelCount > table.seats.length ? modelCount : table.seats.length;
}

/// Full-ring layouts stay out of the learner route until designer admission.
bool act0RequiresNineSeatPreviewV1(Act0TableStateV1 table) =>
    act0TableSeatCountV1(table) > 6;

bool act0RunnerRequiresNineSeatPreviewV1(Act0RunnerStateV1 runner) =>
    act0RequiresNineSeatPreviewV1(runner.table) ||
    runner.teachingSteps.any(
      (step) =>
          step.table != null && act0RequiresNineSeatPreviewV1(step.table!),
    );

bool act0RunnerSupportsNineSeatPreviewV1(Act0RunnerStateV1 runner) =>
    act0RunnerRequiresNineSeatPreviewV1(runner) &&
    act0TableSeatCountV1(runner.table) <= 9 &&
    runner.teachingSteps.every(
      (step) => step.table == null || act0TableSeatCountV1(step.table!) <= 9,
    );

bool act0RunnerAllowedByNineSeatGateV1(
  Act0RunnerStateV1 runner, {
  required bool nineSeatPreview,
}) =>
    !act0RunnerRequiresNineSeatPreviewV1(runner) ||
    (nineSeatPreview && act0RunnerSupportsNineSeatPreviewV1(runner));

Act0LessonTaskV1 act0FirstIncompleteLessonTaskV1(
  Act0LessonCardV1 lesson,
  Set<String> pathClosedTaskIds, {
  bool Function(Act0RunnerStateV1)? runnerAllowed,
}) {
  final tasks = lesson.courseTaskList;
  final allowed =
      runnerAllowed ??
      (Act0RunnerStateV1 runner) =>
          !act0RunnerRequiresNineSeatPreviewV1(runner);
  final eligible = tasks.where((task) => allowed(task.runner));
  return eligible.firstWhere(
    (task) => !pathClosedTaskIds.contains(task.taskId),
    orElse: () => eligible.firstOrNull ?? tasks.first,
  );
}

int act0LessonStepIndexV1(Act0LessonCardV1 lesson, String taskId) {
  final index = lesson.courseTaskList.indexWhere(
    (task) => task.taskId == taskId,
  );
  return index < 0 ? 1 : index + 1;
}

class Act0RunnerStateV1 {
  const Act0RunnerStateV1({
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonSubtitle,
    required this.beatIndex,
    required this.beatCount,
    required this.phase,
    required this.caption,
    required this.hint,
    required this.question,
    required this.options,
    this.selectedOptionId,
    required this.feedbackTitle,
    required this.feedbackReason,
    required this.primaryCtaLabel,
    required this.nextLessonId,
    required this.returnTarget,
    required this.table,
    this.hideTable = false,
    this.teachingSteps = const <Act0TeachingStepV1>[],
    this.teachingStepIndex = 0,
    this.hintPolicy = Act0HintPolicyV1.theoryOnly,
    this.sizingConfig = const Act0SizingConfigV1.disabled(),
    this.selectedPresetId,
    this.sharky = Act0SharkyCueV1.beginner,
    this.feedbackSignalId,
  });

  final String lessonId;
  final String lessonTitle;
  final String lessonSubtitle;
  final int beatIndex;
  final int beatCount;
  final Act0LessonPhaseV1 phase;
  final String caption;
  final String hint;
  final String question;
  final List<Act0RunnerOptionV1> options;
  final String? selectedOptionId;
  final String feedbackTitle;
  final String feedbackReason;
  final String primaryCtaLabel;
  final String? nextLessonId;
  final String returnTarget;
  final Act0TableStateV1 table;
  final bool hideTable;
  final List<Act0TeachingStepV1> teachingSteps;
  final int teachingStepIndex;
  final Act0HintPolicyV1 hintPolicy;
  final Act0SizingConfigV1 sizingConfig;
  final String? selectedPresetId;
  final Act0SharkyCueV1 sharky;
  final String? feedbackSignalId;

  bool get supportsLearnerTable =>
      table.supportsLearnerTable &&
      teachingSteps.every((step) => step.table?.supportsLearnerTable ?? true);

  Act0TeachingStepV1? get activeTeachingStep {
    if (teachingStepIndex < 0 || teachingStepIndex >= teachingSteps.length) {
      return null;
    }
    return teachingSteps[teachingStepIndex];
  }

  Act0RunnerStateV1 copyWith({
    String? lessonId,
    String? lessonTitle,
    String? lessonSubtitle,
    int? beatIndex,
    int? beatCount,
    Act0LessonPhaseV1? phase,
    String? caption,
    String? hint,
    String? question,
    List<Act0RunnerOptionV1>? options,
    String? selectedOptionId,
    String? feedbackTitle,
    String? feedbackReason,
    String? primaryCtaLabel,
    String? nextLessonId,
    String? returnTarget,
    Act0TableStateV1? table,
    List<Act0TeachingStepV1>? teachingSteps,
    int? teachingStepIndex,
    Act0HintPolicyV1? hintPolicy,
    Act0SizingConfigV1? sizingConfig,
    String? selectedPresetId,
    Act0SharkyCueV1? sharky,
    String? feedbackSignalId,
  }) {
    return Act0RunnerStateV1(
      lessonId: lessonId ?? this.lessonId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      lessonSubtitle: lessonSubtitle ?? this.lessonSubtitle,
      beatIndex: beatIndex ?? this.beatIndex,
      beatCount: beatCount ?? this.beatCount,
      phase: phase ?? this.phase,
      caption: caption ?? this.caption,
      hint: hint ?? this.hint,
      question: question ?? this.question,
      options: options ?? this.options,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      feedbackTitle: feedbackTitle ?? this.feedbackTitle,
      feedbackReason: feedbackReason ?? this.feedbackReason,
      primaryCtaLabel: primaryCtaLabel ?? this.primaryCtaLabel,
      nextLessonId: nextLessonId ?? this.nextLessonId,
      returnTarget: returnTarget ?? this.returnTarget,
      table: table ?? this.table,
      hideTable: hideTable,
      teachingSteps: teachingSteps ?? this.teachingSteps,
      teachingStepIndex: teachingStepIndex ?? this.teachingStepIndex,
      hintPolicy: hintPolicy ?? this.hintPolicy,
      sizingConfig: sizingConfig ?? this.sizingConfig,
      selectedPresetId: selectedPresetId ?? this.selectedPresetId,
      sharky: sharky ?? this.sharky,
      feedbackSignalId: feedbackSignalId ?? this.feedbackSignalId,
    );
  }

  Act0RunnerOptionV1? get selectedOption {
    final id = selectedOptionId;
    if (id == null) {
      return null;
    }
    for (final option in options) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  Act0SizingPresetV1? get selectedPreset {
    final id = selectedPresetId;
    if (id == null) {
      return null;
    }
    for (final preset in sizingConfig.presets) {
      if (preset.id == id) {
        return preset;
      }
    }
    return null;
  }

  String get reviewTitle => selectedOption?.feedbackTitle ?? feedbackTitle;

  String get reviewReason => selectedOption?.feedbackReason ?? feedbackReason;

  Act0FeedbackQualityV1 get reviewQuality =>
      selectedOption?.quality ?? Act0FeedbackQualityV1.correct;

  String get reviewPreferredLabel {
    final selection = selectedOption;
    if (selection == null) return '';
    return selection.quality == Act0FeedbackQualityV1.coCorrect
        ? selection.label
        : selection.preferredLabel;
  }

  String get reviewSelectedLabel => selectedOption?.label ?? '';

  String get reviewBetterLabel {
    final selection = selectedOption;
    if (selection == null) return '';
    final quality = selection.quality;
    if (quality == Act0FeedbackQualityV1.acceptable ||
        quality == Act0FeedbackQualityV1.suboptimal) {
      return options.where(act0RunnerOptionIsPreferredV1).firstOrNull?.label ??
          selection.betterAnswerLabel;
    }
    return selection.betterAnswerLabel;
  }

  List<String> get reviewContextLabels {
    final optionLabels = selectedOption?.repairFocusLabels ?? const <String>[];
    if (optionLabels.isNotEmpty) {
      return optionLabels;
    }
    return <String>[
      if (table.centerLabel.isNotEmpty) table.centerLabel,
      if (table.potLabel.isNotEmpty) table.potLabel,
      if (table.toCallLabel.isNotEmpty) table.toCallLabel,
    ];
  }
}

enum Act0SharkyMoodV1 { neutral, happy, thinking, repair, celebrate }

class Act0SharkyCueV1 {
  const Act0SharkyCueV1({
    required this.preSessionLine,
    required this.correctReaction,
    required this.wrongReaction,
    required this.repairLine,
    required this.summaryLine,
    this.preSessionMood = Act0SharkyMoodV1.thinking,
    this.correctMood = Act0SharkyMoodV1.happy,
    this.wrongMood = Act0SharkyMoodV1.repair,
    this.repairMood = Act0SharkyMoodV1.repair,
    this.summaryMood = Act0SharkyMoodV1.celebrate,
  });

  final String preSessionLine;
  final String correctReaction;
  final String wrongReaction;
  final String repairLine;
  final String summaryLine;
  final Act0SharkyMoodV1 preSessionMood;
  final Act0SharkyMoodV1 correctMood;
  final Act0SharkyMoodV1 wrongMood;
  final Act0SharkyMoodV1 repairMood;
  final Act0SharkyMoodV1 summaryMood;

  Act0SharkyCueV1 copyWith({
    String? preSessionLine,
    String? correctReaction,
    String? wrongReaction,
    String? repairLine,
    String? summaryLine,
    Act0SharkyMoodV1? preSessionMood,
    Act0SharkyMoodV1? correctMood,
    Act0SharkyMoodV1? wrongMood,
    Act0SharkyMoodV1? repairMood,
    Act0SharkyMoodV1? summaryMood,
  }) {
    return Act0SharkyCueV1(
      preSessionLine: preSessionLine ?? this.preSessionLine,
      correctReaction: correctReaction ?? this.correctReaction,
      wrongReaction: wrongReaction ?? this.wrongReaction,
      repairLine: repairLine ?? this.repairLine,
      summaryLine: summaryLine ?? this.summaryLine,
      preSessionMood: preSessionMood ?? this.preSessionMood,
      correctMood: correctMood ?? this.correctMood,
      wrongMood: wrongMood ?? this.wrongMood,
      repairMood: repairMood ?? this.repairMood,
      summaryMood: summaryMood ?? this.summaryMood,
    );
  }

  static const beginner = Act0SharkyCueV1(
    preSessionLine: 'One clear read, then one clear action.',
    correctReaction: 'Sharp read.',
    wrongReaction: 'Check the clue again.',
    repairLine: 'Take one breath. I will point at the clue.',
    summaryLine: 'Keep this read for the next hand.',
  );
}

/// Source-owned instructional fact about the learner's table identity.
///
/// `legacy` is intentionally the default until a step is explicitly migrated;
/// it preserves current production table rendering.
enum Act0TableIdentityTeachingSemanticsV1 {
  legacy,
  learnerOnly,
  position,
  dealerOrder,
}

class Act0TeachingStepV1 {
  const Act0TeachingStepV1({
    required this.title,
    required this.body,
    this.table,
    this.focusSeatIds = const <String>[],
    this.focusCardIds = const <String>[],
    this.focusLabels = const <String>[],
    this.identityTeachingSemantics =
        Act0TableIdentityTeachingSemanticsV1.legacy,
    this.ctaLabel = 'Next',
  });

  final String title;
  final String body;
  final Act0TableStateV1? table;
  final List<String> focusSeatIds;
  final List<String> focusCardIds;
  final List<String> focusLabels;
  final Act0TableIdentityTeachingSemanticsV1 identityTeachingSemantics;
  final String ctaLabel;
}

class Act0RunnerOptionV1 {
  const Act0RunnerOptionV1({
    required this.id,
    required this.label,
    this.amountLabel = '',
    this.seatId,
    required this.isCorrect,
    required this.preferredLabel,
    String? betterAnswerLabel,
    required this.quality,
    required this.feedbackTitle,
    required this.feedbackReason,
    this.repairFocusSeatIds = const <String>[],
    this.repairFocusCardIds = const <String>[],
    this.repairFocusLabels = const <String>[],
  }) : betterAnswerLabel = betterAnswerLabel ?? preferredLabel;

  final String id;
  final String label;
  final String amountLabel;
  final String? seatId;
  final bool isCorrect;
  final String preferredLabel;
  final String betterAnswerLabel;
  final Act0FeedbackQualityV1 quality;
  final String feedbackTitle;
  final String feedbackReason;
  final List<String> repairFocusSeatIds;
  final List<String> repairFocusCardIds;
  final List<String> repairFocusLabels;
}

/// Source grading predicate shared by runtime proof and content guards.
bool act0RunnerOptionIsAuthoredCorrectV1(Act0RunnerOptionV1 option) =>
    option.isCorrect && option.quality.passes;

/// Preferred alternatives exclude answers that merely pass.
bool act0RunnerOptionIsPreferredV1(Act0RunnerOptionV1 option) =>
    option.isCorrect && option.quality.isPreferred;

/// Authored instructional intent, never a certificate of hand legality.
/// Unclassified tables fail closed at hand-history consumers.
enum Act0TableScopeV1 { unclassified, playedHand, orientation, explanation }

class Act0TableStateV1 {
  const Act0TableStateV1({
    this.scope = Act0TableScopeV1.unclassified,
    this.showDecisionPremise = false,
    required this.tableFormat,
    required this.playerCount,
    this.density = Act0TableDensityV1.compactLesson,
    required this.seats,
    required this.heroCards,
    required this.boardCards,
    required this.streetLabel,
    required this.potLabel,
    required this.toCallLabel,
    required this.centerLabel,
    this.focusCalloutLabel = '',
    this.emptyBoardLabel = '',
    this.actionTrail = const <Act0ActionTrailItemV1>[],
    this.handContributions,
    this.handTimelinePrefix,
    this.autoPlayHistory = true,
    this.activeSeatId,
    this.decisionSeatId,
    this.heroSeatId,
    required this.highlightedSeatIds,
    required this.highlightedCardIds,
    this.selectableSeatIds = const <String>[],
    this.selectedSeatId,
    this.instructionAnchor,
  });

  final Act0TableScopeV1 scope;
  // The authored caption supplies facts required to answer this scenario.
  final bool showDecisionPremise;
  final Act0TableFormatV1 tableFormat;
  final int playerCount;
  final Act0TableDensityV1 density;
  final List<Act0SeatStateV1> seats;
  final List<Act0CardStateV1> heroCards;
  final List<Act0CardStateV1> boardCards;
  final String streetLabel;
  final String potLabel;
  final String toCallLabel;
  final String centerLabel;
  final String focusCalloutLabel;
  final String emptyBoardLabel;
  final List<Act0ActionTrailItemV1> actionTrail;
  final Act0HandContributionsV1? handContributions;
  final Act0HandTimelinePrefixV1? handTimelinePrefix;

  Act0HandHistoryCoverageV1 get handHistoryCoverage =>
      handTimelinePrefix?.coverage ?? Act0HandHistoryCoverageV1.missing;
  final bool autoPlayHistory;
  final String? activeSeatId;
  // Source-owned current actor; independent of answer-revealing display focus.
  final String? decisionSeatId;
  final String? heroSeatId;
  final List<String> highlightedSeatIds;
  final List<String> highlightedCardIds;
  final List<String> selectableSeatIds;
  final String? selectedSeatId;
  final String? instructionAnchor;

  // Larger tables can be authored and audited before their visual layout ships.
  bool get supportsLearnerTable =>
      tableFormat == Act0TableFormatV1.sixMax &&
      playerCount <= 6 &&
      seats.length <= 6;

  String get tableSize => act0TableFormatLabelV1(tableFormat);

  List<String> get canonicalSeatOrder =>
      act0CanonicalSeatOrderForFormatV1(tableFormat);

  bool get usesCanonicalPlayerCount =>
      playerCount == act0ExpectedPlayerCountForFormatV1(tableFormat);

  /// The observed player can be different from Hero.
  String get decisionActorSeatId => decisionSeatId ?? heroSeat.seatId;

  Act0SeatStateV1 get heroSeat => seats.firstWhere((seat) => seat.isHero);

  Act0TableStateV1 copyWith({
    Act0TableScopeV1? scope,
    bool? showDecisionPremise,
    Act0TableFormatV1? tableFormat,
    int? playerCount,
    Act0TableDensityV1? density,
    List<Act0SeatStateV1>? seats,
    List<Act0CardStateV1>? heroCards,
    List<Act0CardStateV1>? boardCards,
    String? streetLabel,
    String? potLabel,
    String? toCallLabel,
    String? centerLabel,
    String? focusCalloutLabel,
    String? emptyBoardLabel,
    List<Act0ActionTrailItemV1>? actionTrail,
    Act0HandContributionsV1? handContributions,
    Act0HandTimelinePrefixV1? handTimelinePrefix,
    bool? autoPlayHistory,
    String? activeSeatId,
    String? decisionSeatId,
    bool clearDecisionSeatId = false,
    String? heroSeatId,
    List<String>? highlightedSeatIds,
    List<String>? highlightedCardIds,
    List<String>? selectableSeatIds,
    String? selectedSeatId,
    String? instructionAnchor,
  }) {
    return Act0TableStateV1(
      scope: scope ?? this.scope,
      showDecisionPremise: showDecisionPremise ?? this.showDecisionPremise,
      tableFormat: tableFormat ?? this.tableFormat,
      playerCount: playerCount ?? this.playerCount,
      density: density ?? this.density,
      seats: (seats ?? this.seats)
          .map(
            (seat) => heroCards != null && seat.isHero
                ? _act0CopySeatStateV1(seat, holeCards: heroCards)
                : seat,
          )
          .toList(growable: false),
      heroCards: heroCards ?? this.heroCards,
      boardCards: boardCards ?? this.boardCards,
      streetLabel: streetLabel ?? this.streetLabel,
      potLabel: potLabel ?? this.potLabel,
      toCallLabel: toCallLabel ?? this.toCallLabel,
      centerLabel: centerLabel ?? this.centerLabel,
      focusCalloutLabel: focusCalloutLabel ?? this.focusCalloutLabel,
      emptyBoardLabel: emptyBoardLabel ?? this.emptyBoardLabel,
      actionTrail: actionTrail ?? this.actionTrail,
      handContributions:
          handContributions ??
          (actionTrail == null &&
                  (streetLabel == null || streetLabel == this.streetLabel)
              ? this.handContributions
              : null),
      handTimelinePrefix:
          handTimelinePrefix ??
          (streetLabel != null && streetLabel != this.streetLabel ||
                  boardCards != null &&
                      !identical(boardCards, this.boardCards) ||
                  actionTrail != null &&
                      !identical(actionTrail, this.actionTrail)
              ? null
              : this.handTimelinePrefix),
      autoPlayHistory: autoPlayHistory ?? this.autoPlayHistory,
      activeSeatId: activeSeatId ?? this.activeSeatId,
      decisionSeatId: clearDecisionSeatId
          ? null
          : decisionSeatId ?? this.decisionSeatId,
      heroSeatId: heroSeatId ?? this.heroSeatId,
      highlightedSeatIds: highlightedSeatIds ?? this.highlightedSeatIds,
      // A changed card array cannot inherit focus on cards no longer present.
      // Explicit authored focus remains intact so source guards catch errors.
      highlightedCardIds:
          highlightedCardIds ??
          this.highlightedCardIds
              .where((id) {
                final match = RegExp(r'^(hero|board)_(\d+)$').firstMatch(id);
                if (match == null) return true;
                final changed = match[1] == 'hero' ? heroCards : boardCards;
                return changed == null || int.parse(match[2]!) < changed.length;
              })
              .toList(growable: false),
      selectableSeatIds: selectableSeatIds ?? this.selectableSeatIds,
      selectedSeatId: selectedSeatId ?? this.selectedSeatId,
      instructionAnchor: instructionAnchor ?? this.instructionAnchor,
    );
  }
}

enum Act0ActionTrailKindV1 { action, note }

class Act0ActionTrailItemV1 {
  const Act0ActionTrailItemV1({required this.label, this.displayLabel})
    : kind = Act0ActionTrailKindV1.action;

  const Act0ActionTrailItemV1.note({required this.label, this.displayLabel})
    : kind = Act0ActionTrailKindV1.note;

  final String label;
  final String? displayLabel;
  String get learnerLabel => displayLabel ?? label;
  final Act0ActionTrailKindV1 kind;
  bool get isNote => kind == Act0ActionTrailKindV1.note;
}

class Act0CardStateV1 {
  const Act0CardStateV1({
    required this.rank,
    required this.suit,
    this.tone = Act0CardToneV1.dark,
  });

  final String rank;
  final String suit;
  final Act0CardToneV1 tone;

  String get label => suit.isEmpty ? rank : '$rank$suit';

  /// Hearts and diamonds are red, spades and clubs are dark, whatever [tone]
  /// says: the suit is what the learner reads. [tone] only decides when the
  /// suit is unknown (hidden or placeholder cards).
  bool get isRedSuit {
    switch (suit.trim().toLowerCase()) {
      case 'h':
      case 'heart':
      case 'hearts':
      case '\u2665':
      case 'd':
      case 'diamond':
      case 'diamonds':
      case '\u2666':
        return true;
      case 's':
      case 'spade':
      case 'spades':
      case '\u2660':
      case 'c':
      case 'club':
      case 'clubs':
      case '\u2663':
        return false;
      default:
        return tone == Act0CardToneV1.red;
    }
  }
}

class Act0SeatBetStateV1 {
  const Act0SeatBetStateV1({
    required this.kind,
    required this.label,
    required this.amountLabel,
  });

  final Act0SeatBetKindV1 kind;
  final String label;
  final String amountLabel;
}

class Act0SeatStateV1 {
  const Act0SeatStateV1({
    required this.seatId,
    required this.seatLabel,
    required this.displayName,
    this.isHero = false,
    this.isDealerButton = false,
    this.isSmallBlind = false,
    this.isBigBlind = false,
    this.blindAmountLabel,
    this.isActive = false,
    this.isTarget = false,
    this.isInHand = true,
    this.isFolded = false,
    this.hasActed = false,
    this.isLastAggressor = false,
    this.isOccupied = true,
    this.stackLabel,
    this.holeCards = const <Act0CardStateV1>[],
    this.cardsVisibleMode = Act0CardsVisibleModeV1.faceDown,
    this.currentBetLabel,
    this.bet,
  });

  final String seatId;
  final String seatLabel;
  final String displayName;
  final bool isHero;
  final bool isDealerButton;
  final bool isSmallBlind;
  final bool isBigBlind;
  final String? blindAmountLabel;
  final bool isActive;
  final bool isTarget;
  final bool isInHand;
  final bool isFolded;
  final bool hasActed;
  final bool isLastAggressor;
  final bool isOccupied;
  final String? stackLabel;
  final List<Act0CardStateV1> holeCards;
  final Act0CardsVisibleModeV1 cardsVisibleMode;
  final String? currentBetLabel;
  final Act0SeatBetStateV1? bet;
}

String _act0DefaultSeatDisplayNameV1(Act0SeatStateV1 seat) {
  if (seat.isSmallBlind) {
    return 'Small blind';
  }
  if (seat.isBigBlind) {
    return 'Big blind';
  }
  switch (seat.seatId) {
    case 'btn':
      return 'Button';
    case 'co':
      return 'Cutoff';
    default:
      return 'Seat';
  }
}

Act0SeatStateV1 _act0CopySeatStateV1(
  Act0SeatStateV1 seat, {
  String? displayName,
  String? stackLabel,
  bool? isHero,
  bool? isActive,
  bool? isInHand,
  bool? isFolded,
  bool? hasActed,
  bool? isOccupied,
  bool? isLastAggressor,
  bool clearCommitment = false,
  Act0SeatBetStateV1? bet,
  List<Act0CardStateV1>? holeCards,
  Act0CardsVisibleModeV1? cardsVisibleMode,
}) {
  return Act0SeatStateV1(
    seatId: seat.seatId,
    seatLabel: seat.seatLabel,
    displayName: displayName ?? seat.displayName,
    isHero: isHero ?? seat.isHero,
    isDealerButton: seat.isDealerButton,
    isSmallBlind: seat.isSmallBlind,
    isBigBlind: seat.isBigBlind,
    blindAmountLabel: clearCommitment ? null : seat.blindAmountLabel,
    isActive: isActive ?? seat.isActive,
    isTarget: seat.isTarget,
    isInHand: isInHand ?? seat.isInHand,
    isFolded: isFolded ?? seat.isFolded,
    hasActed: hasActed ?? seat.hasActed,
    isLastAggressor: isLastAggressor ?? seat.isLastAggressor,
    isOccupied: isOccupied ?? seat.isOccupied,
    stackLabel: stackLabel ?? seat.stackLabel,
    holeCards: holeCards ?? seat.holeCards,
    cardsVisibleMode: cardsVisibleMode ?? seat.cardsVisibleMode,
    currentBetLabel: clearCommitment ? bet?.amountLabel : seat.currentBetLabel,
    bet: clearCommitment ? bet : (bet ?? seat.bet),
  );
}

// Explicit authored current-street commitments; old street chips are collected.
// This helper does not infer actors, amounts, folds or a pot from partial trails.
Act0TableStateV1 _act0CurrentStreetTableV1(
  Act0TableStateV1 table, {
  Map<String, Act0SeatBetStateV1> bets = const {},
}) => table.copyWith(
  seats: [
    for (final seat in table.seats)
      _act0CopySeatStateV1(seat, clearCommitment: true, bet: bets[seat.seatId]),
  ],
);

Act0TableStateV1 _act0ExplicitFoldsV1(
  Act0TableStateV1 table,
  Set<String> folded,
) => table.copyWith(
  seats: [
    for (final seat in table.seats)
      folded.contains(seat.seatId)
          ? _act0CopySeatStateV1(
              seat,
              isFolded: true,
              isInHand: false,
              isActive: false,
              cardsVisibleMode: Act0CardsVisibleModeV1.none,
            )
          : seat,
  ],
);

// An authored pre-action scene must not inherit stale folded/empty flags
// from a different Hero's turn. Opt in only where the scenario owns this frame.
Act0TableStateV1 _act0WithAuthoredPreActionSeatsV1(
  Act0TableStateV1 table, {
  Set<String> foldedSeatIds = const <String>{},
}) {
  return table.copyWith(
    seats: table.seats
        .map((seat) {
          final folded = foldedSeatIds.contains(seat.seatId);
          return _act0CopySeatStateV1(
            seat,
            isOccupied: true,
            isInHand: !folded,
            isFolded: folded,
            hasActed: folded,
          );
        })
        .toList(growable: false),
  );
}

Act0TableStateV1 _act0ReassignHeroSeatV1(
  Act0TableStateV1 table, {
  required String heroSeatId,
  String? activeSeatId,
  Act0CardsVisibleModeV1 heroCardsVisibleMode = Act0CardsVisibleModeV1.faceUp,
}) {
  final previousHeroSeatId = table.heroSeatId ?? table.heroSeat.seatId;
  final resolvedActiveSeatId = activeSeatId ?? table.activeSeatId ?? heroSeatId;
  final seats = table.seats
      .map((seat) {
        final isHeroSeat = seat.seatId == heroSeatId;
        final wasHeroSeat = seat.seatId == previousHeroSeatId;
        return _act0CopySeatStateV1(
          seat,
          displayName: isHeroSeat
              ? 'Hero'
              : (wasHeroSeat ? _act0DefaultSeatDisplayNameV1(seat) : null),
          isHero: isHeroSeat,
          isActive: seat.seatId == resolvedActiveSeatId,
          holeCards: isHeroSeat
              ? table.heroCards
              : (wasHeroSeat ? _unknownHoleCards : null),
          cardsVisibleMode: isHeroSeat
              ? heroCardsVisibleMode
              : (wasHeroSeat ? Act0CardsVisibleModeV1.faceDown : null),
        );
      })
      .toList(growable: false);
  return table.copyWith(
    seats: seats,
    heroSeatId: heroSeatId,
    activeSeatId: resolvedActiveSeatId,
    // A reassigned Hero turn must not retain the previous Hero's terminal
    // marker. Prior actions and independently authored opponent turns stay.
    handContributions: table.handContributions,
    actionTrail: [
      for (var i = 0; i < table.actionTrail.length; i++)
        if (i == table.actionTrail.length - 1 &&
            !table.actionTrail[i].isNote &&
            resolvedActiveSeatId == heroSeatId &&
            table.actionTrail[i].label == '${table.heroSeat.seatLabel} acts')
          Act0ActionTrailItemV1(
            label: '${seats.firstWhere((seat) => seat.isHero).seatLabel} acts',
          )
        else
          table.actionTrail[i],
    ],
  );
}

class Act0ReviewStateV1 {
  const Act0ReviewStateV1({
    required this.title,
    required this.subtitle,
    required this.weaknessLabel,
    required this.reason,
    required this.stats,
    required this.chosenLabel,
    required this.betterLabel,
    this.mistakes = const <Act0MistakeCardV1>[],
    this.fixedMistakes = const <Act0MistakeCardV1>[],
    this.strongSpots = const <String>[],
    this.emptyTitle = 'No weak spots yet.',
    this.emptyBody = 'Finish a drill to build your review list.',
  });

  final String title;
  final String subtitle;
  final String weaknessLabel;
  final String reason;
  final List<Act0ReviewStatV1> stats;
  final String chosenLabel;
  final String betterLabel;
  final List<Act0MistakeCardV1> mistakes;
  final List<Act0MistakeCardV1> fixedMistakes;
  final List<String> strongSpots;
  final String emptyTitle;
  final String emptyBody;
}

class Act0ReviewStatV1 {
  const Act0ReviewStatV1({required this.label, required this.value});

  final String label;
  final String value;
}

class Act0MistakeCardV1 {
  const Act0MistakeCardV1({
    required this.taskId,
    required this.lessonId,
    this.worldId = '',
    required this.title,
    required this.weaknessLabel,
    required this.selectedOptionId,
    required this.selectedLabel,
    required this.betterLabel,
    required this.reason,
    required this.attempts,
    this.severityLabel = 'Needs repair',
    this.contextLabels = const <String>[],
    this.repairActionLabel = 'Run the spot again',
    this.resolved = false,
    this.completionState,
    this.qualityLine = '',
    this.sourceRetriedCorrectly = false,
  });

  final String taskId;
  final String lessonId;
  final String worldId;
  final String title;
  final String weaknessLabel;
  final String selectedOptionId;
  final String selectedLabel;
  final String betterLabel;
  final String reason;
  final int attempts;
  final String severityLabel;
  final List<String> contextLabels;
  final String repairActionLabel;
  final bool resolved;
  final Act0CompletionDisplayStateV1? completionState;
  final String qualityLine;

  /// The original clue was later answered correctly; a different mapped
  /// same-signal repair is still owed.
  final bool sourceRetriedCorrectly;
}

class Act0ProfileStateV1 {
  const Act0ProfileStateV1({
    required this.playerName,
    required this.level,
    required this.xpLine,
    required this.lessonsLine,
    required this.accuracyLine,
    this.qualityLine = '',
    required this.consistencyActiveDays,
    required this.achievements,
    this.streakLine = '',
    this.streakLast7 = const <bool>[],
    this.streakDays = 0,
    this.strongCategories = const <String>[],
    this.weakCategories = const <String>[],
    this.recentProgress = const <String>[],
    this.recentSkillGains = const <Act0SkillGainV1>[],
    this.skillStats = const <Act0PlacementSkillStatV1>[],
    this.recommendedFocusTitle = '',
    this.recommendedFocusBody = '',
    this.recommendedFocusCtaLabel = '',
    this.worldsClearedCount = 0,
    this.worldsActiveCount = 0,
    this.totalWorldsCount = 0,
    this.mistakesFixedLine = '',
  });

  final String playerName;
  final String level;
  final String xpLine;
  final String lessonsLine;
  final String accuracyLine;
  final String qualityLine;
  final int consistencyActiveDays;
  final String streakLine;
  final List<bool> streakLast7;
  final int streakDays;
  final List<Act0AchievementV1> achievements;
  final List<String> strongCategories;
  final List<String> weakCategories;
  final List<String> recentProgress;
  final List<Act0SkillGainV1> recentSkillGains;
  final List<Act0PlacementSkillStatV1> skillStats;
  final String recommendedFocusTitle;
  final String recommendedFocusBody;
  final String recommendedFocusCtaLabel;
  final int worldsClearedCount;
  final int worldsActiveCount;
  final int totalWorldsCount;
  final String mistakesFixedLine;
}

class Act0SkillGainV1 {
  const Act0SkillGainV1({
    required this.label,
    required this.gain,
    required this.source,
  });

  final String label;
  final int gain;
  final String source;
}

class Act0AchievementV1 {
  const Act0AchievementV1({this.id, required this.label, this.locked = false});

  final String? id;
  final String label;
  final bool locked;

  String get stableId {
    final resolved = id?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }
    return label.toLowerCase().replaceAll(' ', '_');
  }
}

class Act0PracticeGroupV1 {
  const Act0PracticeGroupV1({
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.categoryLabel,
    required this.isEnabled,
    this.targetWorldId,
    this.targetLessonId,
    this.targetTaskId,
    this.countLabel = '',
    this.sessionLabel = '',
    this.durationLabel = '',
    this.isRecommended = false,
    this.skipTeaching = false,
    this.allowDrillBypass = false,
    this.useRapidPracticeLoop = false,
  });

  final String groupId;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String categoryLabel;
  final bool isEnabled;
  final String? targetWorldId;
  final String? targetLessonId;
  final String? targetTaskId;
  final String countLabel;
  final String sessionLabel;
  final String durationLabel;
  final bool isRecommended;
  final bool skipTeaching;
  final bool allowDrillBypass;
  final bool useRapidPracticeLoop;
}

class Act0PlacementQuestionV1 {
  const Act0PlacementQuestionV1({
    required this.questionId,
    required this.title,
    required this.subtitle,
    required this.options,
    this.eyebrow,
    this.helper,
    this.icon = Icons.psychology_alt_rounded,
    this.allowsMultiple = false,
    this.minSelections = 1,
    this.maxSelections,
  });

  final String questionId;
  final String? eyebrow;
  final String title;
  final String subtitle;
  final String? helper;
  final IconData icon;
  final List<Act0PlacementOptionV1> options;
  final bool allowsMultiple;
  final int minSelections;
  final int? maxSelections;
}

class Act0PlacementOptionV1 {
  const Act0PlacementOptionV1({
    required this.optionId,
    required this.label,
    required this.score,
    required this.profileTag,
    this.subtitle,
    this.icon,
    this.badge,
  });

  final String optionId;
  final String label;
  final int score;
  final String profileTag;
  final String? subtitle;
  final IconData? icon;
  final String? badge;
}

class Act0PlacementResultV1 {
  const Act0PlacementResultV1({
    required this.level,
    required this.levelLabel,
    required this.summary,
    required this.reportHeadline,
    required this.reportBody,
    required this.coachTitle,
    required this.coachLine,
    required this.profileSummary,
    required this.diagnosticCorrect,
    required this.diagnosticTotal,
    required this.profileSignals,
    required this.analysisHighlights,
    required this.firstSessionPlan,
    required this.skillStats,
    required this.strengths,
    required this.weakSpots,
    required this.recommendedLessonId,
    required this.recommendedTaskId,
    required this.recommendedTitle,
    required this.recommendedReason,
    required this.routeTrustLine,
    required this.premiumPitch,
    required this.trialValuePoints,
  });

  final Act0PlacementResultLevelV1 level;
  final String levelLabel;
  final String summary;
  final String reportHeadline;
  final String reportBody;
  final String coachTitle;
  final String coachLine;
  final String profileSummary;
  final int diagnosticCorrect;
  final int diagnosticTotal;
  final List<String> profileSignals;
  final List<String> analysisHighlights;
  final List<String> firstSessionPlan;
  final List<Act0PlacementSkillStatV1> skillStats;
  final List<String> strengths;
  final List<String> weakSpots;
  final String recommendedLessonId;
  final String recommendedTaskId;
  final String recommendedTitle;
  final String recommendedReason;
  final String routeTrustLine;
  final String premiumPitch;
  final List<String> trialValuePoints;
}

class Act0PlacementSkillStatV1 {
  const Act0PlacementSkillStatV1({
    required this.label,
    required this.value,
    required this.meaning,
    required this.affects,
    required this.whyImportant,
    this.locked = false,
  });

  factory Act0PlacementSkillStatV1.core({
    required String label,
    required int value,
    bool locked = false,
  }) {
    final canonicalLabel = switch (label) {
      'Situational awareness' => 'Table sense',
      'Hand flow' => 'Table sense',
      'Table flow' => 'Table sense',
      'Action decisions' => 'Betting decisions',
      'Betting choices' => 'Betting decisions',
      'Calm under pressure' => 'Betting decisions',
      'Blind defense' => 'Blind play',
      '3-bet pots' => 'Blind play',
      '3-bet game' => 'Blind play',
      'Showdown reading' => 'Hand reading',
      _ => label,
    };

    final details = switch (canonicalLabel) {
      'Table sense' => (
        meaning:
            'How naturally you track where the action is, who acts when, what the blinds mean, and how the hand is unfolding.',
        affects:
            'Cleaner table reads, fewer missed details, and less confusion when the hand moves fast.',
        whyImportant:
            'Poker gets much easier once the table picture feels automatic instead of noisy.',
      ),
      'Board reading' => (
        meaning:
            'How clearly you read what the flop, turn, and river change in the hand.',
        affects:
            'Spotting scary cards, made hands, draws, and how the texture shifts across streets.',
        whyImportant:
            'The board is the main story of the hand. If you read it slowly, every later decision gets harder.',
      ),
      'Hand reading' => (
        meaning:
            'How well you estimate what hands are likely and who is ahead by showdown.',
        affects:
            'Range guesses, stronger comparisons, and fewer random hero calls or folds.',
        whyImportant:
            'Hand reading is where poker starts feeling strategic instead of reactive.',
      ),
      'Betting decisions' => (
        meaning:
            'How confidently you choose between fold, check, call, and raise once the decision is on you.',
        affects:
            'Cleaner action selection, less second-guessing, and more stable play when the pot grows.',
        whyImportant:
            'This is where understanding turns into actual poker decisions.',
      ),
      'Position play' => (
        meaning:
            'How well you understand acting early, acting late, and why position changes hand value.',
        affects:
            'Better seat-based decisions and faster recognition of who has the advantage.',
        whyImportant:
            'Position is one of the clearest edges in poker. Feeling it early improves everything else.',
      ),
      'Blind play' => (
        meaning:
            'How well you handle hands that start from the blinds or become awkward preflop pressure spots.',
        affects:
            'Cleaner choices when money is already invested and less leaking in repeated blind battles.',
        whyImportant:
            'Blind spots repeat constantly. Even small leaks here add up fast over a session.',
      ),
      _ => (
        meaning:
            'A core poker skill that shapes how clearly you read and play a hand.',
        affects: 'How stable your decisions are once a hand becomes real.',
        whyImportant:
            'Poker gets easier when core skills improve together instead of one spot at a time.',
      ),
    };

    return Act0PlacementSkillStatV1(
      label: canonicalLabel,
      value: value,
      meaning: details.meaning,
      affects: details.affects,
      whyImportant: details.whyImportant,
      locked: locked,
    );
  }

  final String label;
  final int value;
  final String meaning;
  final String affects;
  final String whyImportant;
  final bool locked;

  ({int level, int xpIntoLevel, int xpRequired}) get _progress {
    var level = 0;
    var remaining = value.clamp(0, 9999);
    while (remaining >= _xpNeededForNextLevel(level)) {
      remaining -= _xpNeededForNextLevel(level);
      level += 1;
    }
    return (
      level: level,
      xpIntoLevel: remaining,
      xpRequired: _xpNeededForNextLevel(level),
    );
  }

  int get level => locked ? 0 : _progress.level;
  int get xpIntoLevel => locked ? 0 : _progress.xpIntoLevel;
  int get xpRequiredForNextLevel => _progress.xpRequired;
  int get pointsToNextLevel => locked
      ? xpRequiredForNextLevel
      : (xpRequiredForNextLevel - xpIntoLevel).clamp(0, 9999);
  double get nextLevelProgress => locked
      ? 0
      : (xpIntoLevel / xpRequiredForNextLevel).clamp(0, 1).toDouble();
  String get levelLabel => 'Lv $level';
  String get nextLevelLabel => '$pointsToNextLevel to Lv ${level + 1}';

  static int _xpNeededForNextLevel(int level) => 12 + (level * 8);
}

final _act0PreviewWorlds = <Act0WorldCardV1>[
  Act0WorldCardV1(
    worldId: 'world_1',
    worldNumber: 1,
    title: 'Poker from Zero',
    subtitle: 'Table literacy: cards, seats, blinds, stack, and pot.',
    status: Act0WorldStateV1.current,
    progressLabel: '4 of 10 lessons complete',
    primaryCtaLabel: 'Open lessons',
    unlockLabel: 'Current world',
    isSelectable: true,
    isLocked: false,
    rewardXp: 165,
    lessons: _foundationLessonsV1(_pokerFromZeroLessons),
  ),
  Act0WorldCardV1(
    worldId: 'world_2',
    worldNumber: 2,
    title: 'Hand Discipline',
    subtitle: 'Choose which hands deserve chips, then use table clues.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: true),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: true),
    unlockLabel: act0LockedWorldUnlockLabelV1('Poker from Zero'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 265,
    lessons: _foundationLessonsV1(_handDisciplineLessons),
  ),
  Act0WorldCardV1(
    worldId: 'world_3',
    worldNumber: 3,
    title: 'Position Thinking',
    subtitle: 'Use position to choose the preflop open, call, or fold.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Hand Discipline'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 252,
    lessons: _foundationLessonsV1(_positionThinkingLessons),
  ),
  Act0WorldCardV1(
    worldId: 'world_4',
    worldNumber: 4,
    title: 'Bet Purpose / Price',
    subtitle: 'Understand why bets happen and what price asks you to risk.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Position Thinking'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 205,
    lessons: _foundationLessonsV1(_betPurposePriceLessons),
  ),
  Act0WorldCardV1(
    worldId: 'world_5',
    worldNumber: 5,
    title: 'Board Awareness',
    subtitle: 'Read board texture, draws, and how streets change the plan.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Bet Purpose / Price'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 225,
    lessons: _boardDrawsLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_6',
    worldNumber: 6,
    title: 'Range Thinking',
    subtitle: 'Group hands into ranges and see who has the advantage.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Board Awareness'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 264,
    lessons: _rangeThinkingFoundationLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_7',
    worldNumber: 7,
    title: 'Visible Cards Change Ranges',
    subtitle: 'Use visible cards to narrow what hands can still be there.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Range Thinking'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 260,
    lessons: _visibleCardRangeContinuationLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_8',
    worldNumber: 8,
    title: 'Stack Depth And Risk',
    subtitle: 'See why 100 BB and 20 BB need different plans.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Visible Cards Change Ranges'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 280,
    lessons: _stackDepthRiskLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_9',
    worldNumber: 9,
    title: 'Tournament Pressure',
    subtitle: 'Read your stack, chip price and payout risk.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Stack Depth And Risk'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 300,
    lessons: _tournamentPressureLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_10',
    worldNumber: 10,
    title: 'Player Adjustment',
    subtitle: 'Change how you play when the table gives you a clear read.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Tournament Pressure'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 320,
    lessons: _playerAdjustmentLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_11',
    worldNumber: 11,
    title: 'Real Play Transfer',
    subtitle: 'Combine the course into a practical table-ready checkpoint.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Player Adjustment'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 340,
    lessons: _realPlayTransferLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_12',
    worldNumber: 12,
    title: 'Mindset Bridge',
    subtitle:
        'Stabilize process, reset, and discipline for deeper postflop work.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Real Play Transfer'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 360,
    lessons: _mindsetBridgeLessons,
  ),
  if (act0CurriculumPilotEnabledV1) ...[
    _world13Pilot,
    _world14Pilot,
    _world15Pilot,
    _world16Pilot,
    _world17Pilot,
    _world18Pilot,
    _world19Pilot,
    _world20Pilot,
    _world21Pilot,
    _world22Pilot,
    _world23Pilot,
    _world24Pilot,
  ],
];

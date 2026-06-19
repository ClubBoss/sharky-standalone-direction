import 'package:flutter/material.dart';

enum Act0ShellTabV1 { home, learn, play, review, profile }

enum Act0LessonStateV1 { completed, current, locked }

enum Act0WorldStateV1 { completed, current, locked }

enum Act0LessonPhaseV1 { theory, drill, review }

enum Act0LessonStepKindV1 { learn, practice, fixMistakes, review, proveIt }

enum Act0FeedbackQualityV1 { correct, wrong, suboptimal }

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

const Map<Act0TableFormatV1, List<String>> act0CanonicalSeatOrderByFormatV1 =
    <Act0TableFormatV1, List<String>>{
      Act0TableFormatV1.sixMax: <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
      Act0TableFormatV1.nineMax: <String>[
        'UTG',
        'UTG+1',
        'MP',
        'LJ',
        'HJ',
        'CO',
        'BTN',
        'SB',
        'BB',
      ],
      Act0TableFormatV1.tenMax: <String>[
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
    };

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
  final List<Act0LessonCardV1> lessons;
  // TODO(Wave F): Move to review_state.dart
  final Act0ReviewStateV1 review;
  // TODO(Wave F): Move to profile_state.dart
  final Act0ProfileStateV1 profile;

  Act0WorldCardV1 get selectedWorld => worlds.firstWhere(
    (world) => world.worldId == selectedWorldId,
    orElse: () => worlds.first,
  );

  Act0WorldCardV1 worldById(String worldId) =>
      worlds.firstWhere((world) => world.worldId == worldId);

  Act0LessonCardV1 get currentLesson =>
      lessons.firstWhere((lesson) => lesson.state == Act0LessonStateV1.current);

  Act0LessonCardV1 lessonById(String lessonId) => lessons.firstWhere(
    (lesson) => lesson.lessonId == lessonId,
    orElse: () => worlds
        .expand((world) => world.lessons)
        .firstWhere((lesson) => lesson.lessonId == lessonId),
  );

  Act0RunnerStateV1 runnerFor(String lessonId) => lessonById(lessonId).runner;

  double get xpProgress => xpTarget <= 0 ? 0 : (xp / xpTarget).clamp(0, 1);

  static final sample = Act0ShellStateV1(
    courseTitle: 'Poker from Zero',
    courseSubtitle: 'Learn the table one clear decision at a time.',
    levelLabel: 'Level 1',
    xp: 120,
    xpTarget: 200,
    streakDays: 3,
    dailyGoalLabel: 'Daily goal',
    dailyGoalValue: '5 minutes today',
    pathProgressLabel: '4 of 9 lessons complete',
    selectedWorldId: 'world_1',
    worlds: _act0PreviewWorlds,
    lessons: _pokerFromZeroLessons,
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
      qualityLine: 'Perfect path open',
      consistencyActiveDays: 11,
      streakLast7: const <bool>[false, false, false, false, true, true, true],
      achievements: <Act0AchievementV1>[
        Act0AchievementV1(id: 'first_table_read', label: 'First clear read'),
        Act0AchievementV1(id: 'three_day_streak', label: 'Three day rhythm'),
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
class Act0WorldCardV1 {
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

  final String worldId;
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
  });

  final String lessonId;
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

class Act0LessonTaskV1 {
  const Act0LessonTaskV1({
    required this.taskId,
    required this.title,
    required this.phase,
    required this.runner,
    required this.rewardXp,
    this.stepKind = Act0LessonStepKindV1.practice,
    this.taskFamily,
    this.summary,
    this.lockedSummary,
  });

  final String taskId;
  final String title;
  final Act0LessonPhaseV1 phase;
  final Act0RunnerStateV1 runner;
  final int rewardXp;
  final Act0LessonStepKindV1 stepKind;
  final Act0TaskFamilyV1? taskFamily;
  final String? summary;
  final String? lockedSummary;

  Act0TaskFamilyV1 get resolvedTaskFamily =>
      taskFamily ?? act0InferTaskFamilyV1(phase: phase, stepKind: stepKind);
}

enum Act0HintPolicyV1 { always, theoryOnly, hidden }

enum Act0SizingUiModeV1 { hidden, presetsOnly, presetsWithSlider }

class Act0SizingPresetV1 {
  const Act0SizingPresetV1({
    required this.id,
    required this.label,
    required this.potFraction,
    this.displayLabel,
    this.detailLabel,
    this.ctaLabel,
    this.isPrimary = false,
  });

  final String id;
  final String label;
  final double potFraction;
  final String? displayLabel;
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
    this.teachingSteps = const <Act0TeachingStepV1>[],
    this.teachingStepIndex = 0,
    this.hintPolicy = Act0HintPolicyV1.theoryOnly,
    this.sizingConfig = const Act0SizingConfigV1.disabled(),
    this.selectedPresetId,
    this.sharky = Act0SharkyCueV1.beginner,
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
  final List<Act0TeachingStepV1> teachingSteps;
  final int teachingStepIndex;
  final Act0HintPolicyV1 hintPolicy;
  final Act0SizingConfigV1 sizingConfig;
  final String? selectedPresetId;
  final Act0SharkyCueV1 sharky;

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
      teachingSteps: teachingSteps ?? this.teachingSteps,
      teachingStepIndex: teachingStepIndex ?? this.teachingStepIndex,
      hintPolicy: hintPolicy ?? this.hintPolicy,
      sizingConfig: sizingConfig ?? this.sizingConfig,
      selectedPresetId: selectedPresetId ?? this.selectedPresetId,
      sharky: sharky ?? this.sharky,
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

  String get reviewPreferredLabel => selectedOption?.preferredLabel ?? '';

  String get reviewSelectedLabel => selectedOption?.label ?? '';

  String get reviewBetterLabel =>
      selectedOption?.betterAnswerLabel ?? selectedOption?.preferredLabel ?? '';

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
    wrongReaction: 'Good spot to fix.',
    repairLine: 'Take one breath. I will point at the clue.',
    summaryLine: 'You are reading the table with more control.',
  );
}

class Act0TeachingStepV1 {
  const Act0TeachingStepV1({
    required this.title,
    required this.body,
    this.table,
    this.focusSeatIds = const <String>[],
    this.focusCardIds = const <String>[],
    this.focusLabels = const <String>[],
    this.ctaLabel = 'Next',
  });

  final String title;
  final String body;
  final Act0TableStateV1? table;
  final List<String> focusSeatIds;
  final List<String> focusCardIds;
  final List<String> focusLabels;
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

class Act0TableStateV1 {
  const Act0TableStateV1({
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
    this.activeSeatId,
    this.heroSeatId,
    required this.highlightedSeatIds,
    required this.highlightedCardIds,
    this.selectableSeatIds = const <String>[],
    this.selectedSeatId,
    this.instructionAnchor,
  });

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
  final String? activeSeatId;
  final String? heroSeatId;
  final List<String> highlightedSeatIds;
  final List<String> highlightedCardIds;
  final List<String> selectableSeatIds;
  final String? selectedSeatId;
  final String? instructionAnchor;

  String get tableSize => act0TableFormatLabelV1(tableFormat);

  List<String> get canonicalSeatOrder =>
      act0CanonicalSeatOrderForFormatV1(tableFormat);

  bool get usesCanonicalPlayerCount =>
      playerCount == act0ExpectedPlayerCountForFormatV1(tableFormat);

  Act0SeatStateV1 get heroSeat => seats.firstWhere((seat) => seat.isHero);

  Act0TableStateV1 copyWith({
    Act0TableFormatV1? tableFormat,
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
    String? activeSeatId,
    String? heroSeatId,
    List<String>? highlightedSeatIds,
    List<String>? highlightedCardIds,
    List<String>? selectableSeatIds,
    String? selectedSeatId,
    String? instructionAnchor,
  }) {
    return Act0TableStateV1(
      tableFormat: tableFormat ?? this.tableFormat,
      playerCount: playerCount,
      density: density ?? this.density,
      seats: seats ?? this.seats,
      heroCards: heroCards ?? this.heroCards,
      boardCards: boardCards ?? this.boardCards,
      streetLabel: streetLabel ?? this.streetLabel,
      potLabel: potLabel ?? this.potLabel,
      toCallLabel: toCallLabel ?? this.toCallLabel,
      centerLabel: centerLabel ?? this.centerLabel,
      focusCalloutLabel: focusCalloutLabel ?? this.focusCalloutLabel,
      emptyBoardLabel: emptyBoardLabel ?? this.emptyBoardLabel,
      actionTrail: actionTrail ?? this.actionTrail,
      activeSeatId: activeSeatId ?? this.activeSeatId,
      heroSeatId: heroSeatId ?? this.heroSeatId,
      highlightedSeatIds: highlightedSeatIds ?? this.highlightedSeatIds,
      highlightedCardIds: highlightedCardIds ?? this.highlightedCardIds,
      selectableSeatIds: selectableSeatIds ?? this.selectableSeatIds,
      selectedSeatId: selectedSeatId ?? this.selectedSeatId,
      instructionAnchor: instructionAnchor ?? this.instructionAnchor,
    );
  }
}

class Act0ActionTrailItemV1 {
  const Act0ActionTrailItemV1({required this.label});

  final String label;
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
  bool? isHero,
  bool? isActive,
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
    blindAmountLabel: seat.blindAmountLabel,
    isActive: isActive ?? seat.isActive,
    isTarget: seat.isTarget,
    isInHand: seat.isInHand,
    isFolded: seat.isFolded,
    hasActed: seat.hasActed,
    isLastAggressor: seat.isLastAggressor,
    isOccupied: seat.isOccupied,
    stackLabel: seat.stackLabel,
    holeCards: holeCards ?? seat.holeCards,
    cardsVisibleMode: cardsVisibleMode ?? seat.cardsVisibleMode,
    currentBetLabel: seat.currentBetLabel,
    bet: seat.bet,
  );
}

Act0TableStateV1 _act0ReassignHeroSeatV1(
  Act0TableStateV1 table, {
  required String heroSeatId,
  String? activeSeatId,
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
              ? Act0CardsVisibleModeV1.faceUp
              : (wasHeroSeat ? Act0CardsVisibleModeV1.faceDown : null),
        );
      })
      .toList(growable: false);
  return table.copyWith(
    seats: seats,
    heroSeatId: heroSeatId,
    activeSeatId: resolvedActiveSeatId,
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

final _pokerFromZeroLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'what_poker_is',
    title: 'First Table Guide',
    subtitle: 'Learn the table, answer once, and see why.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Start',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 20,
    runner: _firstTableGuideMeetTableRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'what_poker_is_theory',
        title: 'Meet the table',
        phase: Act0LessonPhaseV1.theory,
        runner: _firstTableGuideMeetTableRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
        summary:
            'Start with one calm read: hero, blinds, table, and the Sharky loop.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_find_hero',
        title: 'Find your seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideFindHeroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Spot where Hero sits before anything else starts moving.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_table_read_transfer',
        title: 'Read the table',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideReadTableRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Read one real table spot: your cards, the board, and the pot.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_table_read_recheck',
        title: 'Table read recheck',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideReadTableRecheckRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Repeat the same table scan on a second spot: Hero cards, board, and pot.',
      ),
      Act0LessonTaskV1(
        taskId: 'first_table_guide_one_clear_choice',
        title: 'Read the preflop setup',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstTableGuideActionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Carry the same scan into a preflop setup read before strategy choices start.',
      ),
      Act0LessonTaskV1(
        taskId: 'first_table_guide_route_roles',
        title: 'Where to go next',
        phase: Act0LessonPhaseV1.review,
        runner: _firstTableGuideRouteRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Lock in what Home, Learn, Practice, Review, and You do after the first loop.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'what_poker_is_content',
    title: 'What poker is',
    subtitle: 'How the pot, folds, and showdown decide the hand.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Poker',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 15,
    runner: _potStackRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'what_poker_is_pot_stack',
        title: 'Pot and stack',
        phase: Act0LessonPhaseV1.theory,
        runner: _potStackRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.learn,
        summary:
            'Separate chips in the middle from chips that still belong to a player.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_win_ways',
        title: 'How pots are won',
        phase: Act0LessonPhaseV1.drill,
        runner: _winWaysRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'See the two basic ways a hand ends: folds or showdown.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_showdown_win',
        title: 'Win at showdown',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Pick which hand wins once the cards are all face up.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_all_in_meaning',
        title: 'All-in meaning',
        phase: Act0LessonPhaseV1.drill,
        runner: _allInMeaningRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'See that all-in means all remaining chips are committed, not that the pot is automatically won.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_matched_chips_transfer',
        title: 'Matched chips',
        phase: Act0LessonPhaseV1.drill,
        runner: _matchedChipsTransferRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'A short stack can only win the chips that were actually matched in front of it.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_live_win_transfer',
        title: 'Live win paths',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1LiveWinTransferRunner,
        rewardXp: 4,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Carry folds and showdown into one live table frame before strategy starts.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_review',
        title: 'Poker recap',
        phase: Act0LessonPhaseV1.review,
        runner: _tableRecapRunner,
        rewardXp: 3,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary:
            'Close the lesson by separating hero, pot, folds, and showdown cleanly.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'cards_ranks_suits',
    title: 'Cards, ranks & suits',
    subtitle: '52 cards, 4 suits, 13 ranks.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Cards',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 20,
    runner: _firstHandRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_theory',
        title: 'The deck',
        phase: Act0LessonPhaseV1.theory,
        runner: _deckIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_rank_drill',
        title: 'Higher card',
        phase: Act0LessonPhaseV1.drill,
        runner: _cardsRanksRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_suit_drill',
        title: 'Name a suit',
        phase: Act0LessonPhaseV1.drill,
        runner: _suitsRunner,
        taskFamily: Act0TaskFamilyV1.recognition,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_private_board',
        title: 'Private vs board',
        phase: Act0LessonPhaseV1.drill,
        runner: _privateBoardRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_board_count',
        title: 'Board count',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardCountRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_best_five',
        title: 'Best five idea',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveCardsRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'cards_ranks_suits_recap',
        title: 'Cards recap',
        phase: Act0LessonPhaseV1.review,
        runner: _cardsRecapRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary:
            'Prove you can separate rank, suit, board, and best-five ideas cleanly.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'your_first_hand',
    title: 'Your first hand, dealt',
    subtitle: 'Watch a hand from start to showdown.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Hand',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 25,
    runner: _firstHandRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'your_first_hand_preflop',
        title: 'Preflop',
        phase: Act0LessonPhaseV1.theory,
        runner: _firstHandRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_private_cards_recheck',
        title: 'Private cards recheck',
        phase: Act0LessonPhaseV1.drill,
        runner: _privateCardsRecheckRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Recheck the two private cards that belong to Hero before the board appears.',
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_flop',
        title: 'Flop',
        phase: Act0LessonPhaseV1.drill,
        runner: _readBoardRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_turn',
        title: 'Turn card',
        phase: Act0LessonPhaseV1.drill,
        runner: _turnBoardRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_river',
        title: 'River card',
        phase: Act0LessonPhaseV1.drill,
        runner: _riverBoardRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_showdown',
        title: 'Showdown read',
        phase: Act0LessonPhaseV1.review,
        runner: _showdownBestHandRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.review,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_action_trail',
        title: 'Action history',
        phase: Act0LessonPhaseV1.drill,
        runner: _actionTrailRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'your_first_hand_recap',
        title: 'Street recap',
        phase: Act0LessonPhaseV1.review,
        runner: _streetOrderRecapRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'fold_check_call_raise',
    title: 'Fold, check, call, raise',
    subtitle: 'Name each action before the table asks you.',
    state: Act0LessonStateV1.current,
    phaseLabel: 'Action',
    primaryCtaLabel: 'Continue',
    isSelectable: true,
    isLocked: false,
    rewardXp: 20,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'actions_theory',
        title: 'Action words',
        phase: Act0LessonPhaseV1.theory,
        runner: _actionWordsRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
        summary: 'Lock in the four core verbs first: fold, check, call, raise.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_legal_context',
        title: 'Legal actions',
        phase: Act0LessonPhaseV1.drill,
        runner: _legalActionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Match the table state to the actions that are actually allowed.',
        lockedSummary:
            'Open Action words first, then this node starts making sense.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_check_drill',
        title: 'Check when no bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _checkActionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Recognize the one moment checking is free and correct.',
        lockedSummary: 'Clear Action words first, then unlock the no-bet read.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_fold_drill',
        title: 'Fold weak hands',
        phase: Act0LessonPhaseV1.drill,
        runner: _foldActionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        summary: 'Train the clean exit when continuing would only burn chips.',
        lockedSummary:
            'Finish the opener first, then come back to this repair node.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_call_drill',
        title: 'Call a price',
        phase: Act0LessonPhaseV1.drill,
        runner: _callActionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Read when matching the bet is the cheapest correct continue.',
        lockedSummary:
            'This opens after Action words, once the basic verbs are stable.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_raise_drill',
        title: 'Raise on the Button',
        phase: Act0LessonPhaseV1.drill,
        runner: _whatYouCanDoRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Use raise in the cleanest beginner spot: unopened action on the Button.',
        lockedSummary:
            'First learn the action menu, then unlock the aggressive option.',
      ),
      Act0LessonTaskV1(
        taskId: 'actions_review',
        title: 'Action recap',
        phase: Act0LessonPhaseV1.review,
        runner: _actionRecapRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary: 'Prove you can name the right action without prompts.',
        lockedSummary: 'The recap opens after the action drills are clean.',
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'blinds_action_order',
    title: 'Blinds & action order',
    subtitle: 'Why someone always puts money in first.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Order',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 20,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'blinds_theory',
        title: 'Blinds post first',
        phase: Act0LessonPhaseV1.theory,
        runner: _blindsOrderRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_posts_drill',
        title: '1 BB baseline',
        phase: Act0LessonPhaseV1.drill,
        runner: _bigBlindPostRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_first_actor',
        title: 'First preflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _firstPreflopActorRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_last_actor',
        title: 'Last preflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _lastPreflopActorRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_postflop_button',
        title: 'Last postflop actor',
        phase: Act0LessonPhaseV1.drill,
        runner: _postflopButtonActorRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_button_moves',
        title: 'Button moves',
        phase: Act0LessonPhaseV1.drill,
        runner: _buttonMovesRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'blinds_review',
        title: 'Order recap',
        phase: Act0LessonPhaseV1.review,
        runner: _blindsOrderRecapRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'positions',
    title: 'The 6 positions',
    subtitle: 'Each seat has a name and a job.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Seats',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 20,
    runner: _meetTableRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'positions_theory',
        title: 'Six seats',
        phase: Act0LessonPhaseV1.theory,
        runner: _positionsRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_button',
        title: 'Tap the Button',
        phase: Act0LessonPhaseV1.drill,
        runner: _buttonSeatRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_utg',
        title: 'Tap UTG',
        phase: Act0LessonPhaseV1.drill,
        runner: _utgSeatRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_cutoff',
        title: 'Tap the cutoff',
        phase: Act0LessonPhaseV1.drill,
        runner: _cutoffSeatRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_late_seat',
        title: 'Late seat meaning',
        phase: Act0LessonPhaseV1.drill,
        runner: _latePositionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_early_late',
        title: 'Early vs late',
        phase: Act0LessonPhaseV1.drill,
        runner: _earlyLatePositionRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'positions_review',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _positionsRecapRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_rankings_table',
    title: 'Hand rankings, on the table',
    subtitle: 'What beats what with real boards.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Ranks',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _readBoardRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_rankings_theory',
        title: 'Hands use five cards',
        phase: Act0LessonPhaseV1.theory,
        runner: _handRankingIntroRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_pair_drill',
        title: 'Find the pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _handRankingsRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_two_pair_drill',
        title: 'Two pair vs one pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _twoPairRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_trips_drill',
        title: 'Trips or set',
        phase: Act0LessonPhaseV1.drill,
        runner: _tripsRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_straight_drill',
        title: 'Find the straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _straightRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_flush_drill',
        title: 'Flush beats straight',
        phase: Act0LessonPhaseV1.drill,
        runner: _flushRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_full_house_drill',
        title: 'Full house shape',
        phase: Act0LessonPhaseV1.drill,
        runner: _fullHouseRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_quads_drill',
        title: 'Four of a kind',
        phase: Act0LessonPhaseV1.drill,
        runner: _quadsRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_royal_flush_drill',
        title: 'Royal flush check',
        phase: Act0LessonPhaseV1.drill,
        runner: _royalFlushRankRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_full_house_vs_flush_drill',
        title: 'Full house beats flush',
        phase: Act0LessonPhaseV1.drill,
        runner: _fullHouseVsFlushRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_quads_vs_full_house_drill',
        title: 'Quads beat full house',
        phase: Act0LessonPhaseV1.drill,
        runner: _quadsVsFullHouseRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_royal_vs_flush_drill',
        title: 'Royal flush wins',
        phase: Act0LessonPhaseV1.drill,
        runner: _royalFlushVsFlushRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_best_five_drill',
        title: 'Choose best five',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveShowdownRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_rankings_review',
        title: 'Ranking recap',
        phase: Act0LessonPhaseV1.review,
        runner: _rankingRecapRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'showdown_winning',
    title: 'Showdown & winning',
    subtitle: 'How a hand actually ends.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Showdown',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _whatYouCanDoRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'showdown_theory',
        title: 'Two ways to win',
        phase: Act0LessonPhaseV1.theory,
        runner: _showdownIntroRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_foldout_drill',
        title: 'Everyone folds',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_best_hand_drill',
        title: 'Best hand at showdown',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_kicker_drill',
        title: 'Same pair, better kicker',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_board_plays_drill',
        title: 'Board plays',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardPlaysRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_tie_drill',
        title: 'Tie the pot',
        phase: Act0LessonPhaseV1.drill,
        runner: _tiePotRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'showdown_review',
        title: 'Win recap',
        phase: Act0LessonPhaseV1.review,
        runner: _worldOneCheckpointRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

List<Act0LessonTaskV1> _retitledTasksV1(
  List<Act0LessonTaskV1> tasks, {
  required String lessonId,
  required String lessonTitle,
  required String lessonSubtitle,
  required String taskPrefix,
}) {
  return <Act0LessonTaskV1>[
    for (final task in tasks)
      Act0LessonTaskV1(
        taskId: '${taskPrefix}_${task.taskId}',
        title: task.title,
        phase: task.phase,
        runner: task.runner.copyWith(
          lessonId: lessonId,
          lessonTitle: lessonTitle,
          lessonSubtitle: lessonSubtitle,
        ),
        rewardXp: task.rewardXp,
        stepKind: task.stepKind,
        taskFamily: task.taskFamily,
        summary: task.summary,
        lockedSummary: task.lockedSummary,
      ),
  ];
}

Act0LessonCardV1 _lessonFromTasksV1({
  required String lessonId,
  required String title,
  required String subtitle,
  required String phaseLabel,
  required int rewardXp,
  required List<Act0LessonTaskV1> sourceTasks,
  List<Act0LessonTaskV1> extraDrills = const <Act0LessonTaskV1>[],
}) {
  final recapStartIndex = sourceTasks.lastIndexWhere(
    (task) => task.phase == Act0LessonPhaseV1.review,
  );
  final insertIndex = recapStartIndex == -1
      ? sourceTasks.length
      : recapStartIndex;
  final mergedSourceTasks = <Act0LessonTaskV1>[
    ...sourceTasks.take(insertIndex),
    ...extraDrills,
    ...sourceTasks.skip(insertIndex),
  ];
  final tasks = _retitledTasksV1(
    mergedSourceTasks,
    lessonId: lessonId,
    lessonTitle: title,
    lessonSubtitle: subtitle,
    taskPrefix: lessonId,
  );
  return Act0LessonCardV1(
    lessonId: lessonId,
    title: title,
    subtitle: subtitle,
    state: Act0LessonStateV1.locked,
    phaseLabel: phaseLabel,
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: rewardXp,
    runner: tasks.first.runner,
    tasks: tasks,
  );
}

final _handValuePositionLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'which_hand_wins',
    title: 'Which hand wins?',
    subtitle: 'Compare hands cleanly at showdown.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Showdown',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2ShowdownIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_showdown_intro',
        title: 'Showdown rule',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2ShowdownIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_hand_drill',
        title: 'Best hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_kicker_drill',
        title: 'Kicker check',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_showdown_recap',
        title: 'Compare recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2ShowdownRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'best_five_cards',
    title: 'Best five cards',
    subtitle: 'Use only the five cards that count.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Best five',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2BestFiveIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_best_five_intro',
        title: 'Five cards count',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2BestFiveIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_five_count',
        title: 'Count the hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveCardsRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_five_showdown',
        title: 'Showdown five',
        phase: Act0LessonPhaseV1.drill,
        runner: _bestFiveShowdownRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.compare,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_best_five_recap',
        title: 'Five-card recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2BestFiveRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'kicker_decides',
    title: 'Kicker decides',
    subtitle: 'Break ties when the main hand matches.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Kicker',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2KickerIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_kicker_intro',
        title: 'Side card rule',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2KickerIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_kicker_side_card',
        title: 'Find the kicker',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownKickerRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_same_board_tie',
        title: 'No kicker help',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardPlaysRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_kicker_recap',
        title: 'Tie-break recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2KickerRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'board_plays',
    title: 'Board plays',
    subtitle: 'See when the board makes the same hand.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Board',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2BoardIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_board_intro',
        title: 'Shared board',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2BoardIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_board_same_five',
        title: 'Same five',
        phase: Act0LessonPhaseV1.drill,
        runner: _boardPlaysRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_board_split_pot',
        title: 'Split pot',
        phase: Act0LessonPhaseV1.drill,
        runner: _tiePotRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_board_recap',
        title: 'Board recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2BoardRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'position_changes_value',
    title: 'Position changes value',
    subtitle: 'Later seats see more before acting.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Position',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world2PositionIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_position_intro',
        title: 'Info changes',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2PositionIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_late_position',
        title: 'Late seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _latePositionRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_early_position',
        title: 'Early seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _earlyLatePositionRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_position_recap',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2PositionRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'who_has_initiative',
    title: 'Who has initiative?',
    subtitle: 'Track who made the last aggressive action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Initiative',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world2InitiativeIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_initiative_intro',
        title: 'Last aggressor',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2InitiativeIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_initiative_find',
        title: 'Find initiative',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2InitiativeDrillRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_initiative_active',
        title: 'Active seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2InitiativeActiveRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_initiative_recap',
        title: 'Initiative recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2InitiativeRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'hand_value_checkpoint',
    title: 'Hand value checkpoint',
    subtitle: 'Mix showdown, position, and initiative.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world2CheckpointIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_intro',
        title: 'Bridge setup',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2CheckpointIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_showdown',
        title: 'Compare hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_position',
        title: 'Use position',
        phase: Act0LessonPhaseV1.drill,
        runner: _earlyLatePositionRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w2_checkpoint_review',
        title: 'Bridge recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2CheckpointRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _preflopBasicsLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'preflop_hand_buckets',
    title: 'Hand buckets',
    subtitle: 'Sort hands before choosing an action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Buckets',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3BucketsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_buckets_intro',
        title: 'Four buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3BucketsIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_premium_bucket',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PremiumBucketRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_trash_bucket',
        title: 'Trash hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3TrashBucketRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_buckets_recap',
        title: 'Bucket recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3BucketsRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'first_in_open',
    title: 'First-in open',
    subtitle: 'When nobody entered, raising starts the pot.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Open',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3FirstInIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_first_in_intro',
        title: 'Unopened pot',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3FirstInIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_button_open',
        title: 'Button open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_early_fold',
        title: 'Early fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3EarlyFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_first_in_recap',
        title: 'Open recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FirstInRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'facing_an_open',
    title: 'Facing an open',
    subtitle: 'A raise before you changes the first decision.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Facing open',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3FacingOpenIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_facing_open_intro',
        title: 'Someone opened',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3FacingOpenIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_playable_call',
        title: 'Playable call',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_weak_facing_fold',
        title: 'Weak facing fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3WeakFacingFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_facing_open_recap',
        title: 'Facing-open recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FacingOpenRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'position_preflop',
    title: 'Position preflop',
    subtitle: 'Position can improve a hand, not rescue every hand.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Position',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3PositionIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_position_intro',
        title: 'Seat changes context',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3PositionIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_late_position_open',
        title: 'Late open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_position_not_free_pass',
        title: 'Not a free pass',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionDisciplineRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_position_recap',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3PositionRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'same_hand_different_frame',
    title: 'Same hand, different frame',
    subtitle: 'One hand can open, call, or fold by context.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Frame',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world3SameHandIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_intro',
        title: 'Context first',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3SameHandIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_open',
        title: 'Open frame',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3CutoffOpenRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_call',
        title: 'Call frame',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3CutoffCallRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_recap',
        title: 'Frame recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3SameHandRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'dominated_hand_warning',
    title: 'Dominated hand warning',
    subtitle: 'Familiar hands can still be trouble.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Discipline',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world3DominatedIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_dominated_intro',
        title: 'Trouble hands',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3DominatedIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_dominated_fold',
        title: 'Fold trouble',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3DominatedFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_strong_continue',
        title: 'Strong continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2StrongContinueRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_dominated_recap',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3DominatedRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'preflop_checkpoint',
    title: 'Preflop checkpoint',
    subtitle: 'Bucket, position, frame, then action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _world3CheckpointIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_intro',
        title: 'Three checks',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3CheckpointIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_open',
        title: 'Open decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_fold',
        title: 'Fold decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3EarlyFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_checkpoint_review',
        title: 'Preflop recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3CheckpointRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _handDisciplineLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'hand_discipline_buckets',
    title: 'Hand buckets',
    subtitle: 'Sort hands before putting chips in.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Buckets',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world3BucketsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_intro',
        title: 'Four buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3BucketsIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_premium',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PremiumBucketRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_strong',
        title: 'Strong hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1StrongBucketRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_medium',
        title: 'Medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1MediumBucketRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_trash',
        title: 'Trash hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3TrashBucketRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_borderline',
        title: 'Borderline strong',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1StrongBucketRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'hand_discipline_buckets_recap',
        title: 'Bucket recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3BucketsRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'fold_discipline',
    title: 'Fold discipline',
    subtitle: 'Learn that folding weak hands saves chips.',
    phaseLabel: 'Discipline',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'discipline_intro',
        title: 'Fold is a tool',
        phase: Act0LessonPhaseV1.theory,
        runner: _foldActionRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'early_fold',
        title: 'Early weak hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3EarlyFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'facing_fold',
        title: 'Facing pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3WeakFacingFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'discipline_stack_protect',
        title: 'Protect stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3DominatedFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'fold_recap',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3DominatedRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'weak_ace_warning',
    title: 'Weak ace warning',
    subtitle: 'Familiar hands can still be dominated.',
    phaseLabel: 'Trouble hands',
    rewardXp: 35,
    sourceTasks: _preflopBasicsLessons[5].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'weak_ace_pressure_fold',
        title: 'Pressure fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3WeakFacingFoldPressureRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_ace_kicker_compare',
        title: 'A7 vs KQ spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2KqoContrastRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'continue_or_let_go',
    title: 'Continue or let go',
    subtitle: 'Separate strong continues from weak hopes.',
    phaseLabel: 'Continue',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'continue_intro',
        title: 'Strong enough',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3BucketsIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'premium_continue',
        title: 'Premium continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PremiumBucketRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium_open',
        title: 'Medium hand opens',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1MediumOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_let_go',
        title: 'Weak let go',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3WeakFacingFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'medium_call_or_fold',
        title: 'Medium facing open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'continue_recap',
        title: 'Continue recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FacingOpenRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  // Apply lesson: combines bucket + seat + frame in a realistic table scenario.
  Act0LessonCardV1(
    lessonId: 'hand_discipline_apply',
    title: 'Discipline at the table',
    subtitle: 'Bucket, seat, and frame — then the action is simple.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Apply',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _w1DisciplineApplyIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'apply_intro',
        title: 'Three-step habit',
        phase: Act0LessonPhaseV1.theory,
        runner: _w1DisciplineApplyIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_utg_fold',
        title: 'UTG, trash hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1DisciplineApplyEarlyFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_btn_open',
        title: 'BTN, strong hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1DisciplineApplyLateOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_hj_decision',
        title: 'HJ, medium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1DisciplineApplyEarlyFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'apply_recap',
        title: 'Discipline holds',
        phase: Act0LessonPhaseV1.review,
        runner: _world3DominatedRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'discipline_checkpoint',
    title: 'Hand discipline checkpoint',
    subtitle: 'Name the bucket, then protect your stack.',
    phaseLabel: 'Checkpoint',
    rewardXp: 40,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'checkpoint_intro',
        title: 'Bucket first',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3BucketsRecapRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_premium',
        title: 'Premium hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PremiumBucketRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_fold',
        title: 'Disciplined fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3DominatedFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_borderline_continue',
        title: 'Borderline continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _world2BorderlineContinueRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_table_discipline',
        title: 'Real-table discipline read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w2DisciplineTableNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'checkpoint_review',
        title: 'Discipline recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w1DisciplineCheckpointRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _positionThinkingLessons = <Act0LessonCardV1>[
  _lessonFromTasksV1(
    lessonId: 'position_six_seats',
    title: 'The 6 positions',
    subtitle: 'Recognize UTG, HJ, CO, BTN, SB, and BB.',
    phaseLabel: 'Seats',
    rewardXp: 30,
    sourceTasks: _pokerFromZeroLessons[5].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'seat_order_decision',
        title: 'Who acts earlier?',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatOrderDecisionRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_early_late_order',
        title: 'Repair early vs late',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3EarlyLateOrderRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_seat_id_btn',
        title: 'Repair BTN seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdBtnRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_seat_id_utg',
        title: 'Repair UTG seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SeatIdUtgRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'button_advantage',
    title: 'Button advantage',
    subtitle: 'The Button often acts last and sees more.',
    phaseLabel: 'Button',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'button_intro',
        title: 'Best seat',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2PositionIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'find_button',
        title: 'Tap BTN',
        phase: Act0LessonPhaseV1.drill,
        runner: _buttonSeatRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_open',
        title: 'BTN first-in open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_last',
        title: 'Acts last',
        phase: Act0LessonPhaseV1.drill,
        runner: _postflopButtonActorRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_vs_cutoff',
        title: 'BTN vs CO',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3LateSeatContrastRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'button_recap',
        title: 'Button recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world2PositionRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_repair_btn_last_postflop',
        title: 'Repair BTN last postflop',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3BtnLastPostflopRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'early_vs_late',
    title: 'Early vs late',
    subtitle: 'Early seats decide with less information.',
    phaseLabel: 'Seat value',
    rewardXp: 35,
    sourceTasks: _handValuePositionLessons[4].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'early_pressure_choice',
        title: 'Early pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3EarlySeatPressureRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_utg_players_behind',
        title: 'Repair UTG pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3UtgPlayersBehindRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'late_info_choice',
        title: 'Late info edge',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3LateInfoEdgeRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'same_hand_different_seat',
    title: 'Same hand, different seat',
    subtitle: 'A seat can change how comfortable a hand is.',
    phaseLabel: 'Context',
    rewardXp: 35,
    sourceTasks: _preflopBasicsLessons[4].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'same_hand_early_fold',
        title: 'Early seat fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionDisciplineRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'same_hand_late_open',
        title: 'Late seat open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_repair_same_hand_different_seat',
        title: 'Repair same hand, different seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3SameHandDifferentSeatRepairRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
    ],
  ),
  // Apply lesson: position in action — same hand, different seat, strategic decision.
  Act0LessonCardV1(
    lessonId: 'position_apply',
    title: 'Position at the table',
    subtitle: 'Seat shapes the decision before anything else.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Apply',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _w3PositionApplyIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_apply_intro',
        title: 'Position shapes action',
        phase: Act0LessonPhaseV1.theory,
        runner: _w3PositionApplyIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_btn_open',
        title: 'BTN: open strong hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenQtsRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_late_open',
        title: 'Late: open or limp?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_early_fold',
        title: 'Early: same hand folds',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionDisciplineRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_hj_fold',
        title: 'HJ: discipline hold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3HijDisciplineRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.fixMistakes,
      ),
      Act0LessonTaskV1(
        taskId: 'position_apply_recap',
        title: 'Position apply recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3PositionRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'position_checkpoint',
    title: 'Position checkpoint',
    subtitle: 'Use seat order before choosing an action.',
    phaseLabel: 'Checkpoint',
    rewardXp: 40,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_intro',
        title: 'Seat before action',
        phase: Act0LessonPhaseV1.theory,
        runner: _world2PositionIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_late_open',
        title: 'Late: open or limp?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3LateOpenRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_early_fold',
        title: 'Early: same hand folds',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3CheckpointEarlyFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_btn_call',
        title: 'BTN: callable spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PositionCheckpointCallRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_table_notice',
        title: 'Real-table seat read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w3TablePositionNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_review',
        title: 'Position recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3PositionRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _preflopFrameworkLessons = <Act0LessonCardV1>[
  _lessonFromTasksV1(
    lessonId: 'preflop_first_in_open',
    title: 'First-in open',
    subtitle: 'When nobody entered, raising can start the hand.',
    phaseLabel: 'Open',
    rewardXp: 30,
    sourceTasks: _preflopBasicsLessons[1].taskList,
  ),
  _lessonFromTasksV1(
    lessonId: 'preflop_facing_open',
    title: 'Facing an open',
    subtitle: 'A raise before you changes the decision.',
    phaseLabel: 'Facing open',
    rewardXp: 30,
    sourceTasks: _preflopBasicsLessons[2].taskList,
  ),
  _lessonFromTasksV1(
    lessonId: 'open_call_fold',
    title: 'Open, call, fold',
    subtitle: 'Read first-in, facing-open, then act.',
    phaseLabel: 'Frame',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'frame_intro',
        title: 'Frame first',
        phase: Act0LessonPhaseV1.theory,
        runner: _world3FirstInIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_open',
        title: 'Open',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3ButtonOpenA9sRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_call',
        title: 'Call',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4CallFrameRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_recap',
        title: 'Action frame recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world3FirstInRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'preflop_frame_before_action',
    title: 'Frame before action',
    subtitle: 'Same hand, different action frame.',
    phaseLabel: 'Context',
    rewardXp: 35,
    sourceTasks: _preflopBasicsLessons[4].taskList,
  ),
  _lessonFromTasksV1(
    lessonId: 'preflop_framework_checkpoint',
    title: 'Preflop checkpoint',
    subtitle: 'Bucket, seat, frame, then action.',
    phaseLabel: 'Checkpoint',
    rewardXp: 40,
    sourceTasks: _preflopBasicsLessons[6].taskList,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'checkpoint_table_frame',
        title: 'Real-table frame read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w4TableFrameNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
  ),
];

final _betPurposePriceLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'why_bets_happen',
    title: 'Why bets happen',
    subtitle: 'Every bet should have a simple purpose.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Purpose',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4PurposeIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_purpose_intro',
        title: 'Bet purpose',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4PurposeIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_purpose',
        title: 'Value reason',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValuePurposeRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_purpose',
        title: 'Bluff reason',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BluffPurposeRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_purpose_recap',
        title: 'Purpose recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4PurposeRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'value_bets',
    title: 'Value bets',
    subtitle: 'Bet when worse hands can still call.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Value',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4ValueIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_value_intro',
        title: 'Worse calls',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4ValueIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_bet',
        title: 'Bet top pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValueBetRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_missed',
        title: 'Do not hide value',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValueCheckMissRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_value_recap',
        title: 'Value recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4ValueRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'bluff_pressure',
    title: 'Bluff pressure',
    subtitle: 'A bluff tries to make better hands fold.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Bluff',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4BluffIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_bluff_intro',
        title: 'Fold pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4BluffIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_pressure',
        title: 'Apply pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BluffPressureRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bad_bluff',
        title: 'Bad pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BadBluffRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bluff_recap',
        title: 'Bluff recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4BluffRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'protection_and_denial',
    title: 'Protection and denial',
    subtitle: 'Bet so the next card is not free.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Protection',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4ProtectionIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_protection_intro',
        title: 'Deny free card',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4ProtectionIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_bet',
        title: 'Protect pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ProtectionBetRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_check',
        title: 'Free card risk',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ProtectionCheckRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_protection_recap',
        title: 'Protection recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4ProtectionRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'call_price',
    title: 'Call price',
    subtitle: 'A bet gives you a price to continue.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Price',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 30,
    runner: _world4PriceIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_price_intro',
        title: 'Facing a price',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4PriceIntroRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_good_price_call',
        title: 'Call small price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4GoodPriceCallRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_bad_price_fold',
        title: 'Fold high price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BadPriceFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_cheap_price_marginal_call',
        title: 'Cheap call with middle pair',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4CheapPriceMarginalCallRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_big_price_marginal_fold',
        title: 'Big price, thinner hand',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BigPriceMarginalFoldRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_price_recap',
        title: 'Price recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4PriceRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'small_half_pot',
    title: 'Small, half, pot',
    subtitle: 'Size says how much pressure you create.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Sizing',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 35,
    runner: _world4SizingIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_sizing_intro',
        title: 'Size language',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4SizingIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_small_bet',
        title: 'One-third bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4SmallBetRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_half_pot_bet',
        title: 'Half-pot bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4HalfPotRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_pot_bet',
        title: 'Pot-size bet',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4PotBetRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.sizing,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_sizing_recap',
        title: 'Sizing recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4SizingRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'price_checkpoint',
    title: 'Price checkpoint',
    subtitle: 'Read purpose, size, and price before action.',
    state: Act0LessonStateV1.locked,
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    isSelectable: false,
    isLocked: true,
    rewardXp: 40,
    runner: _world4CheckpointIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_intro',
        title: 'Three reads',
        phase: Act0LessonPhaseV1.theory,
        runner: _world4CheckpointIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_value',
        title: 'Value or bluff',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4ValuePurposeRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_price',
        title: 'Call or fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4BadPriceFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_table_price',
        title: 'Real-table price read',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4PriceTableTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_table_purpose_price',
        title: 'Live purpose and price',
        phase: Act0LessonPhaseV1.drill,
        runner: _world4PurposePriceTableTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w4_checkpoint_review',
        title: 'Price recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world4CheckpointRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _boardDrawsLessons = <Act0LessonCardV1>[
  _lessonFromTasksV1(
    lessonId: 'board_texture_basics',
    title: 'Dry or wet board',
    subtitle: 'Start by asking how much the board can change.',
    phaseLabel: 'Texture',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_texture_intro',
        title: 'Board texture',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5TextureIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_dry_board',
        title: 'Dry board',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5DryBoardRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_wet_board',
        title: 'Wet board',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5WetBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_texture_recap',
        title: 'Texture recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5TextureRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'connected_boards',
    title: 'Connected boards',
    subtitle: 'Connected ranks create more ways to improve.',
    phaseLabel: 'Connected',
    rewardXp: 35,
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_connected_intro',
        title: 'Connected ranks',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5ConnectedIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_disconnected_board',
        title: 'Disconnected board',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5DisconnectedBoardRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_connected_board',
        title: 'Connected board',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5ConnectedBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_connected_recap',
        title: 'Connected recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5ConnectedRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'flush_draws',
    title: 'Flush draws',
    subtitle: 'Three or four cards of a suit make suit pressure visible.',
    phaseLabel: 'Flush draw',
    rewardXp: 35,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_made_hand_vs_flush_draw_transfer',
        title: 'Made hand or future pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5MadeHandVsFlushDrawTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_draw_recheck_transfer',
        title: 'Flush draw or made flush',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5FlushDrawRecheckTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_flush_intro',
        title: 'Same suit pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5FlushIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_draw_find',
        title: 'Find flush draw',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5FlushDrawRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_no_flush_draw',
        title: 'No flush draw',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5NoFlushDrawRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_recap',
        title: 'Flush recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5FlushRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'straight_draws',
    title: 'Straight draws',
    subtitle: 'Neighboring ranks can point to a straight.',
    phaseLabel: 'Straight draw',
    rewardXp: 35,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_gutshot_contrast_transfer',
        title: 'Gutshot or open-ended?',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5GutshotContrastTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_straight_intro',
        title: 'Rank ladder',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5StraightIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_straight_draw_find',
        title: 'Find straight draw',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5StraightDrawRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_gap_board',
        title: 'Gap board',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5GapBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_gutshot_draw',
        title: 'Gutshot draw',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5GutshotDrawRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_straight_recap',
        title: 'Straight recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5StraightRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'outs_improvement',
    title: 'Outs as improvement cards',
    subtitle: 'Outs are cards that can improve a hand.',
    phaseLabel: 'Outs',
    rewardXp: 35,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_table_outs_flush_transfer',
        title: 'Live heart outs',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TableOutsFlushTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_clean_vs_risky_out_transfer',
        title: 'Safer out or risky out',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5CleanVsRiskyOutTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_table_outs_straight_transfer',
        title: 'Live straight outs',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TableOutsStraightTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_outs_intro',
        title: 'Improvement cards',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5OutsIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_flush_out',
        title: 'Flush out',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5FlushOutRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_straight_out',
        title: 'Straight out',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5StraightOutRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_outs_recap',
        title: 'Outs recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world5OutsRecapRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  _lessonFromTasksV1(
    lessonId: 'turn_river_changes',
    title: 'Turn and river changes',
    subtitle: 'Later streets can complete or miss a draw.',
    phaseLabel: 'Street changes',
    rewardXp: 40,
    extraDrills: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_turn_texture_shift_transfer',
        title: 'Turn changes the texture',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TurnTextureShiftTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_river_draw_story_transfer',
        title: 'River keeps the draw story honest',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5RiverDrawStoryTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
    sourceTasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w5_street_change_intro',
        title: 'One new card',
        phase: Act0LessonPhaseV1.theory,
        runner: _world5StreetChangeIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_turn_hits',
        title: 'Turn hits',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5TurnHitsRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_river_misses',
        title: 'River misses',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5RiverMissesRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_street_repair',
        title: 'Repair the turn read',
        phase: Act0LessonPhaseV1.drill,
        runner: _world5StreetRepairRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.repair,
      ),
      Act0LessonTaskV1(
        taskId: 'w5_board_checkpoint',
        title: 'Board checkpoint',
        phase: Act0LessonPhaseV1.review,
        runner: _world5BoardCheckpointRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _rangeThinkingLiteLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'range_bucket_basics',
    title: 'Range buckets',
    subtitle: 'Sort hands into value, bluff candidate, and missed buckets.',
    phaseLabel: 'Buckets',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6RangeIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_range_intro',
        title: 'Three buckets',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6RangeIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_value_dry_board',
        title: 'Value on dry board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueDryBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_missed_dry_board',
        title: 'Missed on dry board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6MissedDryBoardRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_table_bucket_notice',
        title: 'First live read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TableBucketNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_buckets_recap',
        title: 'Buckets recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6BucketsRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_board_fit',
    title: 'Range meets board',
    subtitle: 'Board texture can shift a hand from value to missed.',
    phaseLabel: 'Board fit',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6BoardFitIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_board_fit_intro',
        title: 'Board shifts bucket',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6BoardFitIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_wrong_board',
        title: 'Missed on wet board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6WrongBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_value_wet_board',
        title: 'Value on wet board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueWetBoardRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_turn_shift_bucket',
        title: 'Turn changes bucket',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TurnShiftBucketRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_board_fit_recap',
        title: 'Board fit recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6BoardFitRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_pressure_lines',
    title: 'Value, bluff, missed',
    subtitle: 'Each bucket suggests a different action direction.',
    phaseLabel: 'Pressure',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6PressureLinesIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_pressure_lines_intro',
        title: 'Bucket shapes action',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6PressureLinesIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_value_range_action',
        title: 'Value bets',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueRangeActionRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_bluff_candidate',
        title: 'Bluff candidate',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6BluffCandidateRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_missed_hand_action',
        title: 'Missed hand direction',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6MissedHandActionRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_table_value_line_transfer',
        title: 'Live-table value line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TableValueLineTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_turn_pressure_shift_transfer',
        title: 'Turn pressure shift',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6TurnPressureShiftTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_wet_board_repair',
        title: 'Repair wet-board read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6WetBoardRepairRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.fixMistakes,
        taskFamily: Act0TaskFamilyV1.repair,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_pressure_lines_recap',
        title: 'Pressure recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6PressureLinesRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_combo_counts',
    title: 'Count the combos',
    subtitle: 'AK has 16 combos. A pocket pair has 6.',
    phaseLabel: 'Combos',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w6ComboCountsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w6_combo_counts_intro',
        title: 'Why combo counts matter',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6ComboCountsIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_ak_combos',
        title: 'AK combo count',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6AkComboRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_pair_combos',
        title: 'Pocket pair combo count',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6PairComboRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_combo_weight_compare',
        title: 'Which family appears more?',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ComboWeightCompareRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.counting,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_combo_counts_recap',
        title: 'Combo recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w6ComboCountsRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'range_thinking_checkpoint',
    title: 'Range thinking checkpoint',
    subtitle: 'Bucket, board fit, combo count, then pressure.',
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _world6RangeCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_intro',
        title: 'Three-step read',
        phase: Act0LessonPhaseV1.theory,
        runner: _w6RangeIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_value',
        title: 'Value on dry board',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6ValueDryBoardRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_board_fit',
        title: 'Board changes bucket',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6WrongBoardRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_combos',
        title: 'Count the family',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6AkComboRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_suited_offsuit_weight_compare',
        title: 'Suited or offsuit weight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6SuitedOffsuitWeightCompareRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_pair_vs_suited_weight_compare',
        title: 'Pair or suited family',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6PairVsSuitedWeightCompareRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_checkpoint_table_combo_weight',
        title: 'Live-table combo weight',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6CheckpointTableComboWeightRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_pressure',
        title: 'Bluff candidate',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6BluffCandidateRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_kicker_showdown_compare',
        title: 'Same pair, better kicker',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6KickerShowdownCompareRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_board_pair_strength_compare',
        title: 'Paired board changes the winner',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6BoardPairStrengthCompareRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w6_checkpoint_table_best_five',
        title: 'Live-table best five',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6CheckpointTableBestFiveRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'range_checkpoint_review',
        title: 'Range recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world6RangeCheckpointRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _stackDepthRiskLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'effective_stack_basics',
    title: 'Effective stack',
    subtitle: 'The smaller stack sets the maximum risk in the hand.',
    phaseLabel: 'Effective stack',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w7EffectiveStackIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_intro',
        title: 'Smaller stack rules',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7EffectiveStackIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_30bb',
        title: '200 vs 30',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7EffectiveStackThirtyRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_100bb',
        title: '100 vs 100',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7EffectiveStackEvenRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_table_effective_notice',
        title: 'Find the real risk',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7EffectiveStackTableNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_effective_stack_recap',
        title: 'Effective stack recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7EffectiveStackRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'same_hand_different_depth',
    title: 'Same hand, different depth',
    subtitle: 'A hand can widen at 20 BB and tighten at 100 BB.',
    phaseLabel: 'Depth shift',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w7DepthShiftIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_depth_shift_intro',
        title: 'Depth changes the plan',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7DepthShiftIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_20bb_wider',
        title: '20 BB decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7TwentyBbWiderRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_100bb_tighter',
        title: '100 BB decision',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7HundredBbTighterRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_40bb_middle',
        title: '40 BB middle plan',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7FortyBbMiddleRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_ajs_btn_25bb_transfer',
        title: 'A-J suited at 25 BB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7AjsButtonTwentyFiveBbRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_ajs_btn_100bb_transfer',
        title: 'A-J suited at 100 BB',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7AjsButtonHundredBbRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_depth_shift_recap',
        title: 'Depth recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7DepthShiftRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'spr_and_commitment',
    title: 'Room or commitment',
    subtitle: 'Low SPR means less room. High SPR means more room to maneuver.',
    phaseLabel: 'SPR',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 40,
    runner: _w7SprIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_spr_intro',
        title: 'Low room vs high room',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7SprIntroRunner,
        rewardXp: 6,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_low_spr_commit',
        title: 'SPR 2',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7LowSprCommitRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_high_spr_room',
        title: 'SPR 8',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7HighSprRoomRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_spr4_middle',
        title: 'SPR 4',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7SprFourRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_side_pot_intro',
        title: 'Side pot basics',
        phase: Act0LessonPhaseV1.drill,
        runner: _sidePotIntroRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'After short-stack commitment is clear, separate the matched main pot from the extra side-pot chips.',
      ),
      Act0LessonTaskV1(
        taskId: 'w7_top_pair_spr2_transfer',
        title: 'Top pair at SPR 2',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7TopPairSprTwoRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_top_pair_spr8_transfer',
        title: 'Top pair at SPR 8',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7TopPairSprEightRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_spr_recap',
        title: 'SPR recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7SprRecapRunner,
        rewardXp: 15,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'format_pressure',
    title: '6-max vs full ring',
    subtitle: 'The same hand can open wider in 6-max than in full ring.',
    phaseLabel: 'Format',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w7FormatPressureIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w7_format_intro',
        title: 'Format changes pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _w7FormatPressureIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_6max_wider',
        title: '6-max opens wider',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7SixMaxWiderRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_fullring_tighter',
        title: 'Full ring tightens',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7FullRingTighterRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_format_table_notice',
        title: 'Count players behind',
        phase: Act0LessonPhaseV1.drill,
        runner: _w7FormatTableNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_format_recap',
        title: 'Format recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w7FormatRecapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.review,
      ),
      Act0LessonTaskV1(
        taskId: 'w7_stack_checkpoint',
        title: 'Stack-depth checkpoint',
        phase: Act0LessonPhaseV1.review,
        runner: _world7StackCheckpointRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _tournamentPressureLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'survival_pressure_basics',
    title: 'Chips are not life',
    subtitle: 'Tournament chips have survival pressure that cash chips do not.',
    phaseLabel: 'Survival',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w9SurvivalIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w9_survival_intro',
        title: 'Tournament life pressure',
        phase: Act0LessonPhaseV1.theory,
        runner: _w9SurvivalIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_cash_vs_tournament',
        title: 'Cash vs tournament',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9CashVsTournamentRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_short_stack_survival',
        title: 'Short stack survival',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9ShortStackSurvivalRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_survival_stack_tradeoff',
        title: 'Life vs reload',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9SurvivalTradeoffRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_survival_recap',
        title: 'Survival recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w9SurvivalRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'm_ratio_zones_lite',
    title: 'M-ratio zones',
    subtitle: 'Use simple zones to choose urgency without formulas.',
    phaseLabel: 'M-ratio',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w9MRatioIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w9_m_ratio_intro',
        title: 'Zone thinking',
        phase: Act0LessonPhaseV1.theory,
        runner: _w9MRatioIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_m_ratio_red_zone',
        title: 'Red zone urgency',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9MZoneRedRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_m_ratio_green_zone',
        title: 'Green zone patience',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9MZoneGreenRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_m_ratio_yellow_zone',
        title: 'Yellow zone planning',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9MZoneYellowRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_m_ratio_table_window_transfer',
        title: 'Yellow-zone table read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9MTableWindowTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_m_ratio_recap',
        title: 'M-ratio recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w9MRatioRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'bubble_risk_premium',
    title: 'Bubble risk premium',
    subtitle: 'Medium stacks tighten while big stacks can apply pressure.',
    phaseLabel: 'Bubble',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w9BubblePressureIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w9_bubble_intro',
        title: 'Bubble pressure basics',
        phase: Act0LessonPhaseV1.theory,
        runner: _w9BubblePressureIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_medium_stack_tighten',
        title: 'Medium stack discipline',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9MediumStackTightenRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_big_stack_leverage',
        title: 'Big stack leverage',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9BigStackLeverageRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_bubble_short_stack',
        title: 'Short stack urgency',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9BubbleShortStackRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_bubble_table_risk_transfer',
        title: 'Bubble risk at a real table',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9BubbleTableRiskTransferRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_bubble_recap',
        title: 'Bubble recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w9BubbleRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'tournament_pressure_checkpoint',
    title: 'Tournament pressure checkpoint',
    subtitle:
        'Survival, M-ratio, and bubble pressure before player adjustment.',
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 50,
    runner: _world9TournamentCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w9_checkpoint_intro',
        title: 'Three-part pressure read',
        phase: Act0LessonPhaseV1.theory,
        runner: _w9SurvivalIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_checkpoint_survival_line',
        title: 'Preserve tournament life',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9CheckpointSurvivalLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_checkpoint_zone_line',
        title: 'Urgency by zone',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9CheckpointZoneLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_checkpoint_bubble_line',
        title: 'Bubble risk premium line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9CheckpointBubbleLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_checkpoint_table_notice',
        title: 'Real-table pressure read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w9TablePressureNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w9_checkpoint_review',
        title: 'Tournament pressure recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world9TournamentCheckpointRunner,
        rewardXp: 17,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _playerAdjustmentLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'player_type_basics',
    title: 'Who is at the table',
    subtitle: 'Tag players by one tendency before changing your line.',
    phaseLabel: 'Player types',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w10PlayerTypeIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w10_player_type_intro',
        title: 'One tendency first',
        phase: Act0LessonPhaseV1.theory,
        runner: _w10PlayerTypeIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_nit_tag',
        title: 'Nit profile',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10NitTagRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_loose_passive_tag',
        title: 'Loose-passive profile',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10LoosePassiveTagRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_overaggressive_tag',
        title: 'Over-aggressive profile',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10OveraggressiveTagRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_player_type_recap',
        title: 'Player-type recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w10PlayerTypeRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'adjust_one_lever',
    title: 'Adjust one lever',
    subtitle: 'Change one action size or frequency, not everything at once.',
    phaseLabel: 'Single-lever',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w10OneLeverIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w10_one_lever_intro',
        title: 'One change at a time',
        phase: Act0LessonPhaseV1.theory,
        runner: _w10OneLeverIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_vs_nit_open_wider',
        title: 'Steal more vs tight folds',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10VsNitOpenWiderRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_vs_caller_value_heavier',
        title: 'Value heavier vs callers',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10VsCallerValueHeavierRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_vs_sticky_defender_tighten_steals',
        title: 'Tighten steals vs sticky defenders',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10VsStickyDefenderTightenStealsRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_table_value_vs_caller_transfer',
        title: 'Value shift at the table',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10TableValueVsCallerTransferRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_one_lever_recap',
        title: 'One-lever recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w10OneLeverRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'exploit_guardrails',
    title: 'Exploit guardrails',
    subtitle: 'Exploit with discipline so your line stays coherent.',
    phaseLabel: 'Guardrails',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w10ExploitGuardrailsIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w10_guardrails_intro',
        title: 'Exploit without chaos',
        phase: Act0LessonPhaseV1.theory,
        runner: _w10ExploitGuardrailsIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_overbluff_punish',
        title: 'Punish overbluffs',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10OverbluffPunishRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_underbluff_fold_more',
        title: 'Fold more vs underbluffs',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10UnderbluffFoldMoreRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_guardrail_sample_size',
        title: 'Respect sample size',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10GuardrailSampleSizeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_guardrails_recap',
        title: 'Guardrails recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w10ExploitGuardrailsRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'player_adjustment_checkpoint',
    title: 'Player-adjustment checkpoint',
    subtitle:
        'Tag tendency, adjust one lever, keep guardrails, then transfer to real play.',
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 50,
    runner: _world10PlayerAdjustmentCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w10_checkpoint_intro',
        title: 'Three-step exploit loop',
        phase: Act0LessonPhaseV1.theory,
        runner: _w10PlayerTypeIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_checkpoint_tag_line',
        title: 'Tag then act',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10CheckpointTagLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_checkpoint_lever_line',
        title: 'One-lever exploit line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10CheckpointLeverLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_checkpoint_guardrail_line',
        title: 'Guardrail discipline',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10CheckpointGuardrailLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_checkpoint_table_notice',
        title: 'Real-table exploit read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w10TableAdjustmentNoticeRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w10_checkpoint_review',
        title: 'Player-adjustment recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world10PlayerAdjustmentCheckpointRunner,
        rewardXp: 17,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _realPlayTransferLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'session_plan_basics',
    title: 'Session plan in 30 seconds',
    subtitle: 'Pick one focus before cards are dealt.',
    phaseLabel: 'Plan',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w11SessionPlanIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w11_session_plan_intro',
        title: 'One-focus plan',
        phase: Act0LessonPhaseV1.theory,
        runner: _w11SessionPlanIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_plan_focus_choice',
        title: 'Choose one focus',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11PlanFocusChoiceRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_plan_avoid_overload',
        title: 'Avoid overload plan',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11PlanAvoidOverloadRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_plan_table_focus_transfer',
        title: 'Real-table focus plan',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11PlanTableFocusTransferRunner,
        rewardXp: 12,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_session_plan_recap',
        title: 'Session-plan recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w11SessionPlanRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'table_trigger_reads',
    title: 'In-session trigger reads',
    subtitle: 'Spot one trigger and apply one adjustment immediately.',
    phaseLabel: 'Trigger',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w11TriggerReadIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w11_trigger_intro',
        title: 'Trigger-first loop',
        phase: Act0LessonPhaseV1.theory,
        runner: _w11TriggerReadIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_trigger_overfold_blinds',
        title: 'Blind overfold trigger',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11TriggerOverfoldBlindsRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_trigger_overcall_flop',
        title: 'Overcall trigger',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11TriggerOvercallFlopRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_trigger_small_price_continue',
        title: 'Small-price continue',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11TriggerSmallPriceContinueRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_trigger_bad_price_fold',
        title: 'Bad-price fold',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11TriggerBadPriceFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_trigger_recap',
        title: 'Trigger recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w11TriggerReadRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'post_session_review_loop',
    title: 'Post-session review loop',
    subtitle: 'Convert one leak into one repair target for tomorrow.',
    phaseLabel: 'Review loop',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w11ReviewLoopIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w11_review_loop_intro',
        title: 'One leak one fix',
        phase: Act0LessonPhaseV1.theory,
        runner: _w11ReviewLoopIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_review_pick_leak',
        title: 'Pick priority leak',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11ReviewPickLeakRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_review_define_fix',
        title: 'Define tomorrow fix',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11ReviewDefineFixRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_review_loop_recap',
        title: 'Review-loop recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w11ReviewLoopRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'real_play_transfer_checkpoint',
    title: 'Real-play transfer checkpoint',
    subtitle: 'Plan, trigger, review, then repeat as a daily loop.',
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 50,
    runner: _world11RealPlayCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w11_checkpoint_intro',
        title: 'Transfer loop map',
        phase: Act0LessonPhaseV1.theory,
        runner: _w11SessionPlanIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_checkpoint_plan_line',
        title: 'Plan line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11CheckpointPlanLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_checkpoint_trigger_line',
        title: 'Trigger line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11CheckpointTriggerLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_checkpoint_review_line',
        title: 'Review line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11CheckpointReviewLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_checkpoint_mixed_table_line',
        title: 'Mixed table line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w11CheckpointMixedTableLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w11_checkpoint_review',
        title: 'Real-play recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world11RealPlayCheckpointRunner,
        rewardXp: 17,
        stepKind: Act0LessonStepKindV1.proveIt,
      ),
    ],
  ),
];

final _mindsetBridgeLessons = <Act0LessonCardV1>[
  Act0LessonCardV1(
    lessonId: 'decision_over_outcome',
    title: 'Decision quality over outcome',
    subtitle: 'Judge decisions by process, not one result.',
    phaseLabel: 'Process',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w12DecisionQualityIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w12_decision_quality_intro',
        title: 'Process first',
        phase: Act0LessonPhaseV1.theory,
        runner: _w12DecisionQualityIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_good_fold_bad_result',
        title: 'Good fold, bad result',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12GoodFoldBadResultRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_bad_call_good_result',
        title: 'Bad call, lucky win',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12BadCallGoodResultRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_decision_quality_recap',
        title: 'Process recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w12DecisionQualityRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'tilt_reset_protocol',
    title: 'Tilt reset protocol',
    subtitle: 'Use a short reset so one hand does not own the session.',
    phaseLabel: 'Reset',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w12TiltResetIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w12_tilt_reset_intro',
        title: 'Reset in under 20s',
        phase: Act0LessonPhaseV1.theory,
        runner: _w12TiltResetIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_after_bad_beat_reset',
        title: 'After bad beat',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12AfterBadBeatResetRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_after_mistake_reset',
        title: 'After your own mistake',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12AfterMistakeResetRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_tilt_reset_recap',
        title: 'Reset recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w12TiltResetRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'confidence_and_discipline',
    title: 'Confidence with discipline',
    subtitle: 'Play assertively without drifting into ego calls.',
    phaseLabel: 'Discipline',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 45,
    runner: _w12ConfidenceDisciplineIntroRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w12_confidence_intro',
        title: 'Calm assertive baseline',
        phase: Act0LessonPhaseV1.theory,
        runner: _w12ConfidenceDisciplineIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_assertive_not_ego',
        title: 'Assertive, not ego',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12AssertiveNotEgoRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_discipline_under_pressure',
        title: 'Discipline under pressure',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12DisciplineUnderPressureRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_pretty_hand_bad_price_fold',
        title: 'Pretty hand, bad price',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12PrettyHandBadPriceFoldRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_revenge_raise_trap',
        title: 'Do not raise to take control',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12RevengeRaiseTrapRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_confidence_recap',
        title: 'Confidence recap',
        phase: Act0LessonPhaseV1.review,
        runner: _w12ConfidenceDisciplineRecapRunner,
        rewardXp: 16,
        stepKind: Act0LessonStepKindV1.review,
      ),
    ],
  ),
  Act0LessonCardV1(
    lessonId: 'mindset_bridge_checkpoint',
    title: 'Mindset bridge checkpoint',
    subtitle: 'Carry process, reset, and discipline into postflop growth.',
    phaseLabel: 'Checkpoint',
    primaryCtaLabel: 'Locked',
    state: Act0LessonStateV1.locked,
    isLocked: true,
    isSelectable: false,
    rewardXp: 50,
    runner: _world12MindsetCheckpointRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'w12_checkpoint_intro',
        title: 'Mindset loop map',
        phase: Act0LessonPhaseV1.theory,
        runner: _w12DecisionQualityIntroRunner,
        rewardXp: 7,
        stepKind: Act0LessonStepKindV1.learn,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_checkpoint_process_line',
        title: 'Process line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12CheckpointProcessLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_checkpoint_reset_line',
        title: 'Reset line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12CheckpointResetLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_checkpoint_discipline_line',
        title: 'Discipline line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12CheckpointDisciplineLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_checkpoint_full_loop_line',
        title: 'Full loop line',
        phase: Act0LessonPhaseV1.drill,
        runner: _w12CheckpointFullLoopLineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
      Act0LessonTaskV1(
        taskId: 'w12_checkpoint_review',
        title: 'Mindset recap',
        phase: Act0LessonPhaseV1.review,
        runner: _world12MindsetCheckpointRunner,
        rewardXp: 17,
        stepKind: Act0LessonStepKindV1.proveIt,
        taskFamily: Act0TaskFamilyV1.transfer,
      ),
    ],
  ),
];

final _lockedPreviewLessons = <Act0LessonCardV1>[];

final _act0PreviewWorlds = <Act0WorldCardV1>[
  Act0WorldCardV1(
    worldId: 'world_1',
    worldNumber: 1,
    title: 'Poker from Zero',
    subtitle: 'Table literacy: cards, seats, blinds, stack, and pot.',
    status: Act0WorldStateV1.current,
    progressLabel: '4 of 9 lessons complete',
    primaryCtaLabel: 'Open lessons',
    unlockLabel: 'Current world',
    isSelectable: true,
    isLocked: false,
    rewardXp: 165,
    lessons: _pokerFromZeroLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_2',
    worldNumber: 2,
    title: 'Hand Discipline',
    subtitle: 'Learn which hands deserve chips and which can fold.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: true),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: true),
    unlockLabel: act0LockedWorldUnlockLabelV1('Poker from Zero'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 220,
    lessons: _handDisciplineLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_3',
    worldNumber: 3,
    title: 'Position Thinking',
    subtitle: 'See why seat order changes hand value and comfort.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Hand Discipline'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 200,
    lessons: _positionThinkingLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_4',
    worldNumber: 4,
    title: 'Preflop Framework',
    subtitle: 'Use bucket, seat, and action frame before choosing.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Position Thinking'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 205,
    lessons: _preflopFrameworkLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_5',
    worldNumber: 5,
    title: 'Bet Purpose And Price',
    subtitle: 'Understand value, bluff, protection, and call price.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Preflop Framework'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 225,
    lessons: _betPurposePriceLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_6',
    worldNumber: 6,
    title: 'Board And Draws',
    subtitle: 'Read board texture, draws, and changing streets.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Bet Purpose And Price'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 240,
    lessons: _boardDrawsLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_7',
    worldNumber: 7,
    title: 'Range Thinking Lite',
    subtitle: 'Group hands into simple buckets without solver talk.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Board And Draws'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 260,
    lessons: _rangeThinkingLiteLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_8',
    worldNumber: 8,
    title: 'Stack Depth And Risk',
    subtitle: 'See why 100 BB and 20 BB need different plans.',
    status: Act0WorldStateV1.locked,
    progressLabel: act0LockedWorldProgressLabelV1(isImmediateNext: false),
    primaryCtaLabel: act0LockedWorldPrimaryCtaLabelV1(isImmediateNext: false),
    unlockLabel: act0LockedWorldUnlockLabelV1('Range Thinking Lite'),
    isSelectable: false,
    isLocked: true,
    rewardXp: 280,
    lessons: _stackDepthRiskLessons,
  ),
  Act0WorldCardV1(
    worldId: 'world_9',
    worldNumber: 9,
    title: 'Tournament Pressure',
    subtitle: 'Learn survival pressure and risk without equations.',
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
    subtitle: 'Adjust one lever at a time against real player types.',
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
];

const _unknownHoleCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '?', suit: ''),
  Act0CardStateV1(rank: '?', suit: ''),
];

const _heroKtCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 's'),
  Act0CardStateV1(rank: 'T', suit: 's'),
];

const _heroAkCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
];

const _heroQqCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 's'),
];

const _heroA7oCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
];

const _heroAs7sCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: '7', suit: 's'),
];

const _hero7s7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '7', suit: 's'),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _heroAjCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 'd', tone: Act0CardToneV1.red),
];

const _heroAJsCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 's'),
];

const _heroQJsCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 's'),
];

const _flopA72Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
];

const _smallBlindPost = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.post,
  label: 'SB',
  amountLabel: '0.5 BB',
);

const _bigBlindPost = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.post,
  label: 'BB',
  amountLabel: '1 BB',
);

const _hjBet1Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'HJ',
  amountLabel: '1 BB',
);

const _hjBet2Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'HJ',
  amountLabel: '2 BB',
);

const _hjOpen25Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'HJ',
  amountLabel: '2.5 BB',
);

const _coOpen25Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'CO',
  amountLabel: '2.5 BB',
);

const _btnRaise3Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'BTN',
  amountLabel: '3 BB',
);

const _btnBet2Bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'BTN',
  amountLabel: '2 BB',
);

const _heroKqCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'd'),
  Act0CardStateV1(rank: 'Q', suit: 'c'),
];

const _villainKqCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
];

const _villainK8Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'c'),
  Act0CardStateV1(rank: '8', suit: 's'),
];

const _heroA5Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
];

const _villainK4Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 's'),
  Act0CardStateV1(rank: '4', suit: 'c'),
];

const _boardK7294Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '9', suit: 's'),
  Act0CardStateV1(rank: '4', suit: 'c'),
];

const _boardJ8822Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '8', suit: 'c'),
  Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 's'),
  Act0CardStateV1(rank: '2', suit: 'c'),
];

const _boardBroadwayCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'J', suit: 's'),
  Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
];

const _boardJ74FlopCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardJ742TurnCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 's'),
];

const _boardA84TwoToneCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '4', suit: 'c'),
];

const _heroKhQhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
];

const _boardFlushHearts = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardFlushVsStraight = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: 'T', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardTripsAces = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardFullHouseVsFlush = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'c'),
];

const _boardQuadsQueens = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
];

const _boardQuadsVsFullHouse = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 's'),
];

const _boardRoyalFlushHearts = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '2', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardThreeQueens = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 's'),
];

const _opponentAh7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponentJd7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'J', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponent8c9sCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '8', suit: 'c'),
  Act0CardStateV1(rank: '9', suit: 's'),
];

const _opponentKhQhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponentAc7hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponent9h3hCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '3', suit: 'h', tone: Act0CardToneV1.red),
];
const _hero89Cards = <Act0CardStateV1>[
  Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '9', suit: 's'),
];

const _boardStraight = <Act0CardStateV1>[
  Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: '6', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
];

const _opponentKhJhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
];

const _boardAce = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'c'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'J', suit: 'c'),
  Act0CardStateV1(rank: '4', suit: 's'),
];

const _heroAsKhCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
];

const _opponentAdQdCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
];

const _boardRoyalFlush = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 's'),
  Act0CardStateV1(rank: 'Q', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 's'),
  Act0CardStateV1(rank: 'T', suit: 's'),
];

const _heroQcQdCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'Q', suit: 'c'),
  Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
];

const _meetTableRunner = Act0RunnerStateV1(
  lessonId: 'meet_table',
  lessonTitle: 'Meet the table',
  lessonSubtitle: 'Find the Button, blinds, pot, and your seat.',
  beatIndex: 1,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'You are always the hero seat at the bottom.',
  hint: 'Button, blinds, and your seat stay visible.',
  question: 'Which seat is the hero seat?',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'top',
      label: 'Top seat',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'Bottom seat',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'The hero marker is at the bottom seat in this lesson.',
    ),
    Act0RunnerOptionV1(
      id: 'bottom',
      label: 'Bottom seat',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'Bottom seat',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Hero seat found!',
      feedbackReason: 'The hero marker shows your seat at the bottom.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'Random seat',
      seatId: 'hj',
      isCorrect: false,
      preferredLabel: 'Bottom seat',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'Your seat is marked by the hero badge, not random.',
    ),
  ],
  feedbackTitle: 'Sharp read.',
  feedbackReason:
      'The hero marker shows your seat. The dealer button moves around the table.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'what_you_can_do',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'Cutoff'),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        isTarget: true,
        stackLabel: '100 BB',
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        currentBetLabel: '0.5 BB',
        bet: _smallBlindPost,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        currentBetLabel: '1 BB',
        bet: _bigBlindPost,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: <Act0CardStateV1>[],
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: 'Blinds posted',
    emptyBoardLabel: 'No community cards yet',
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
    ],
    heroSeatId: 'btn',
    highlightedSeatIds: <String>['btn', 'sb', 'bb'],
    highlightedCardIds: <String>[],
    selectableSeatIds: <String>['utg', 'btn', 'hj'],
    instructionAnchor: 'hero',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'We start with Hold\'em cash.',
      body:
          'Each player gets 2 private hole cards. The table shares 5 community cards. You build the best 5-card hand from those 7. This course starts with No-Limit Hold\'em cash, where chip values stay stable hand to hand.',
      focusLabels: <String>[
        '2 hole cards',
        'Cash vs tournament',
        'Stable value',
      ],
    ),
    Act0TeachingStepV1(
      title: 'This is a poker table.',
      body:
          'BTN is your button seat. SB and BB are the blind seats. UTG, HJ, and CO are the other positions.',
      focusSeatIds: <String>['btn', 'hj', 'sb', 'bb'],
      focusLabels: <String>['Hero', 'Opponents'],
    ),
    Act0TeachingStepV1(
      title: 'The goal is the pot.',
      body: 'Players put chips in the middle. The winner takes that pot.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['Pot', 'Blinds create it'],
    ),
    Act0TeachingStepV1(
      title: 'Blinds start the hand.',
      body:
          'SB posts 0.5 BB and BB posts 1 BB before anyone chooses. The blinds appear before the first decision, and the hole cards stay hidden so you can read the table cleanly.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['SB 0.5', 'BB 1', 'Cards hidden first'],
    ),
  ],
);

const _whatYouCanDoRunner = Act0RunnerStateV1(
  lessonId: 'what_you_can_do',
  lessonTitle: 'What you can do',
  lessonSubtitle: 'Use fold, call, and raise from one clear table spot.',
  beatIndex: 2,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'You are on the Button with KTs.',
  hint: 'Folded to you. Raising can win blinds or build a bigger pot.',
  question: 'Choose how to play your first action.',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'First in on the Button, folding gives up a playable spot.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero acts', 'Blinds posted', 'KTs'],
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Calling is legal, but raise is sharper.',
      feedbackReason:
          'Calling is legal and not a disaster, but it starts passively on the Button. Raising can win the blinds right away and build a better pot.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Call is legal', 'Raise sharper', 'Button'],
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '3 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'First in on the Button, raising takes the lead and pressures the blinds.',
      repairFocusSeatIds: <String>['btn'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Button raise', 'Hero acts'],
    ),
  ],
  feedbackTitle: 'Solid understanding.',
  feedbackReason:
      'Raising is the clean first-in Button action; calling only matches the blind.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'read_board',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        isFolded: true,
        isInHand: false,
        hasActed: true,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        isActive: true,
        stackLabel: '100 BB',
        holeCards: _heroKtCards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        currentBetLabel: '0.5 BB',
        bet: _smallBlindPost,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        currentBetLabel: '1 BB',
        bet: _bigBlindPost,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: _heroKtCards,
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: 'Action on hero',
    emptyBoardLabel: 'No community cards yet',
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: <String>['btn'],
    highlightedCardIds: <String>[],
    instructionAnchor: 'hero',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Look before you act.',
      body: 'First ask: is anyone already in the pot?',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['Hero acts', 'Blinds posted'],
    ),
    Act0TeachingStepV1(
      title: 'No one entered yet.',
      body:
          'Calling only matches the blind. First in usually means raise or fold.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['First in', 'Button'],
    ),
  ],
);

final _findHeroSeatRunner = _meetTableRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'find_hero_seat',
  caption: 'Your seat is marked as Hero.',
  hint: 'Start every hand by finding your own cards and seat.',
  question: 'Which seat is the hero seat?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Hero means you.',
      body: 'Your decisions happen from the seat marked Hero.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Hero seat'],
    ),
  ],
);

const _firstHandRunner = Act0RunnerStateV1(
  lessonId: 'your_first_hand',
  lessonTitle: 'Your first hand',
  lessonSubtitle: 'See how one hand moves from deal to decision.',
  beatIndex: 3,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'Your two cards stay with you through the hand.',
  hint: 'Board cards arrive later.',
  question: 'How many private cards do you start with?',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one',
      label: 'One',
      isCorrect: false,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'You start with two private cards.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero cards'],
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: true,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Two cards: correct.',
      feedbackReason: 'You start with two private cards.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero cards'],
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Five cards can make a hand, but you start with two.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero cards'],
    ),
  ],
  feedbackTitle: 'Two private cards: correct.',
  feedbackReason:
      'You start with two private cards. The board cards are shared by everyone.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'read_board',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroAkCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
        bet: _smallBlindPost,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
        bet: _bigBlindPost,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: _heroAkCards,
    boardCards: <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: 'Private cards',
    emptyBoardLabel: 'No community cards yet',
    highlightedSeatIds: <String>['btn'],
    highlightedCardIds: <String>[],
    instructionAnchor: 'cards',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A hand starts preflop.',
      body: 'You get two private cards. No board cards are out yet.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['2 private cards', '0 board cards'],
    ),
    Act0TeachingStepV1(
      title: 'Private means yours.',
      body: 'Only you can use your private cards.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Private cards'],
    ),
  ],
);

final _privateCardsRecheckRunner = _firstHandRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'your_first_hand_private_cards_recheck',
  lessonTitle: 'Your first hand',
  lessonSubtitle: 'See your private cards before the board appears.',
  caption: 'Hero has two private cards before any board cards appear.',
  hint: 'Your private cards sit by the Hero seat.',
  question: 'Which two private cards are yours?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ace_king',
      label: 'A and K',
      isCorrect: true,
      preferredLabel: 'A and K',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean private-card read.',
      feedbackReason:
          'Hero\'s two private cards are A and K. They belong to Hero before any board cards appear.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero cards'],
    ),
    Act0RunnerOptionV1(
      id: 'queen_queen',
      label: 'Q and Q',
      isCorrect: false,
      preferredLabel: 'A and K',
      betterAnswerLabel: 'A and K',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good spot to recheck.',
      feedbackReason:
          'Those are not Hero\'s cards in this spot. Read the two cards beside Hero.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero cards'],
    ),
    Act0RunnerOptionV1(
      id: 'board_cards',
      label: 'The board cards',
      isCorrect: false,
      preferredLabel: 'A and K',
      betterAnswerLabel: 'A and K',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not this street.',
      feedbackReason:
          'Board cards are shared later. This recheck asks for Hero\'s two private cards.',
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Hero cards'],
    ),
  ],
  feedbackTitle: 'Private cards locked in.',
  feedbackReason:
      'You found Hero\'s two private cards before looking for any board cards.',
  table: _firstHandRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[],
    centerLabel: 'Hero private cards',
    potLabel: 'Pot 1.5 BB',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
    emptyBoardLabel: 'No community cards yet',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Start with Hero\'s cards.',
      body:
          'Before the board appears, Hero has exactly two private cards. Read those two cards first.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Hero cards'],
    ),
  ],
);

const _readBoardRunner = Act0RunnerStateV1(
  lessonId: 'read_board',
  lessonTitle: 'Read the board',
  lessonSubtitle: 'Spot what changed on the flop, turn, and river.',
  beatIndex: 4,
  beatCount: 8,
  phase: Act0LessonPhaseV1.theory,
  caption: 'The flop puts three shared cards in the middle.',
  hint: 'Everyone can use the board.',
  question: 'How many cards are on this flop?',
  options: <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: false,
      preferredLabel: 'Three',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'The flop has three board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'three',
      label: 'Three',
      isCorrect: true,
      preferredLabel: 'Three',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'A flop has three board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Three',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'Five board cards appear only by the river.',
    ),
  ],
  feedbackTitle: 'Excellent spot.',
  feedbackReason:
      'A flop has three board cards. Turn and river add one card each.',
  primaryCtaLabel: 'Continue',
  nextLessonId: 'first_simple_decision',
  returnTarget: 'learn',
  table: Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        isActive: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    heroCards: _heroQqCards,
    boardCards: _flopA72Cards,
    streetLabel: 'Flop',
    potLabel: 'Pot 5 BB',
    toCallLabel: '',
    centerLabel: 'Shared board',
    highlightedSeatIds: <String>['co'],
    highlightedCardIds: <String>['board_0', 'board_1', 'board_2'],
    instructionAnchor: 'board',
  ),
  teachingSteps: <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The board is shared.',
      body: 'Everyone still in the hand can use these middle cards.',
      focusCardIds: <String>['board_0', 'board_1', 'board_2'],
      focusLabels: <String>['Shared board'],
    ),
    Act0TeachingStepV1(
      title: 'The flop has three cards.',
      body: 'Turn adds one more. River adds the fifth.',
      focusCardIds: <String>['board_0', 'board_1', 'board_2'],
      focusLabels: <String>['Flop = 3'],
    ),
  ],
);

final _cardsRanksRunner = _firstHandRunner.copyWith(
  lessonId: 'cards_ranks_suits',
  lessonTitle: 'Cards, ranks & suits',
  lessonSubtitle: 'Recognize ranks, suits, and private cards.',
  caption: 'Poker uses ranks and suits.',
  hint: 'Aces are high in this beginner drill.',
  question: 'Which rank is higher here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'king',
      label: 'King',
      isCorrect: false,
      preferredLabel: 'Ace',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'Ace is higher than king in this beginner drill.',
    ),
    Act0RunnerOptionV1(
      id: 'ace',
      label: 'Ace',
      isCorrect: true,
      preferredLabel: 'Ace',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'Compare top card first: ace outranks king in this spot.',
    ),
    Act0RunnerOptionV1(
      id: 'suit',
      label: 'Suit decides',
      isCorrect: false,
      preferredLabel: 'Ace',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'Suit does not make one rank higher than another.',
    ),
  ],
  table: _firstHandRunner.table.copyWith(
    centerLabel: 'Ranks and suits',
    emptyBoardLabel: '',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Every card has two parts.',
      body: 'Rank tells how high it is. Suit tells the symbol family.',
      focusLabels: <String>['Rank', 'Suit'],
    ),
    Act0TeachingStepV1(
      title: 'Ranks have an order.',
      body:
          'The beginner order is 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, A.\n\nAce is highest for now, so ace beats king in this drill.',
      focusLabels: <String>['2 ... 10', 'J Q K A', 'A beats K'],
    ),
  ],
);

final _deckIntroRunner = _cardsRanksRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'deck_intro',
  caption: 'A deck has 52 cards.',
  hint: 'Each card combines one rank with one suit.',
  question: 'What are the two parts of a card?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Deck first.',
      body:
          'Holdem uses a 52-card deck: 13 ranks across 4 suits. Numbers run from 2 up to 10. J means Jack, Q means Queen, K means King, and A means Ace.',
      focusLabels: <String>[
        '52 cards',
        '13 ranks',
        '4 suits',
        '2 ... 10',
        'J Q K A',
      ],
    ),
  ],
);

final _potStackRunner = _meetTableRunner.copyWith(
  lessonId: 'pot_stack',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Texas Hold\'em cash starts with stable table reads.',
  caption:
      'Texas Hold\'em gives you 2 private cards, up to 5 community cards, and one pot to win.',
  hint: 'Best 5 wins at showdown. Folds can win the pot earlier.',
  question: 'Which label shows the chips in the middle?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pot',
      label: 'Pot',
      isCorrect: true,
      preferredLabel: 'Pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: 'The pot is the chips in the middle.',
    ),
    Act0RunnerOptionV1(
      id: 'stack',
      label: 'Stack',
      isCorrect: false,
      preferredLabel: 'Pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'Your stack stays with your seat. The pot is the shared chips in the middle that everyone is playing for.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    centerLabel: 'Pot vs stack',
    potLabel: 'Pot 1.5 BB',
  ),
  feedbackReason:
      'The pot is the chips in the middle. In Texas Hold\'em, you build the best 5-card hand from 2 private cards and 5 community cards.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Texas Hold\'em first.',
      body:
          'You start with 2 private cards. The table can share up to 5 community cards. At showdown, the best 5-card hand wins.',
      focusLabels: <String>['2 private', '5 community', 'Best 5-card hand'],
    ),
    Act0TeachingStepV1(
      title: 'Cash-style fundamentals first.',
      body:
          'Sharky starts with cash-style fundamentals because cards, position, pot, action, and reason stay stable hand to hand. Tournament pressure comes later.',
      focusLabels: <String>[
        'Cash-style fundamentals',
        'Stable reads',
        'Tournaments later',
      ],
    ),
    Act0TeachingStepV1(
      title: 'BB also counts chips.',
      body:
          'BB also measures chips. Pot 8 BB = eight big blinds.\n\nIn a \$1/\$2 game, 1 BB = \$2.\n\nA \$200 stack there is 100 BB. BB works across stakes.',
      focusLabels: <String>[
        'Pot in BB',
        '\$1/\$2 -> 1 BB = \$2',
        '\$200 = 100 BB',
      ],
    ),
    Act0TeachingStepV1(
      title: 'Pot and stack are different.',
      body: 'The pot is in the middle. Your stack stays with your seat.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Pot', 'Stack'],
    ),
  ],
);

final _allInMeaningRunner = _potStackRunner.copyWith(
  lessonId: 'all_in_meaning',
  caption:
      'Hero is all-in for 20 BB. CO called 20 BB and still has chips behind.',
  hint:
      'All-in means one player has put in all remaining chips. The cards or folds still decide the pot.',
  question: 'What does all-in mean here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'all_remaining_committed',
      label: 'Hero put in all remaining chips',
      isCorrect: true,
      preferredLabel: 'Hero put in all remaining chips',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct table read.',
      feedbackReason:
          'All-in means Hero committed all remaining chips. It does not automatically win the pot, because cards or folds still decide what happens next.',
    ),
    Act0RunnerOptionV1(
      id: 'automatic_win',
      label: 'Hero wins the pot automatically',
      isCorrect: false,
      preferredLabel: 'Hero put in all remaining chips',
      betterAnswerLabel: 'Hero put in all remaining chips',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not a win condition.',
      feedbackReason:
          'All-in does not automatically win. If another player calls, the hand can still go to showdown and the cards still decide the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'largest_stack_only',
      label: 'Only the bigger stack matters now',
      isCorrect: false,
      preferredLabel: 'Hero put in all remaining chips',
      betterAnswerLabel: 'Hero put in all remaining chips',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Stack size still has a role, but not that role.',
      feedbackReason:
          'CO covering Hero matters for how many chips can be matched, but all-in first means Hero has no chips left behind. The bigger stack does not win by size alone.',
    ),
  ],
  table: _potStackRunner.table.copyWith(
    centerLabel: 'All-in is all remaining chips',
    potLabel: 'Pot 41.5 BB',
    toCallLabel: '',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Blinds: 1.5 BB'),
      Act0ActionTrailItemV1(label: 'Hero shoves 20 BB'),
      Act0ActionTrailItemV1(label: 'CO calls 20 BB'),
    ],
    highlightedSeatIds: const <String>['btn', 'co'],
    seats: _potStackRunner.table.seats
        .map<Act0SeatStateV1>(
          (seat) => seat.seatId == 'btn'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'Hero',
                  isHero: true,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: seat.isActive,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '0 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '20 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.raise,
                    label: 'All-in',
                    amountLabel: '20 BB',
                  ),
                )
              : seat.seatId == 'co'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'CO',
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: true,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '80 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '20 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.call,
                    label: 'Call',
                    amountLabel: '20 BB',
                  ),
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'All-in means no chips behind.',
      body: '0 BB behind = all-in. Cards or folds still decide.',
      focusLabels: <String>['0 BB behind', '20 BB in', 'Cards still decide'],
    ),
  ],
);

final _matchedChipsTransferRunner = _allInMeaningRunner.copyWith(
  lessonId: 'matched_chips_transfer',
  caption:
      'Real table. Hero is all-in for 20 BB. CO covers with 100 BB total but only called 20 BB.',
  hint:
      'Start with matched chips, not the biggest stack behind. Ask what Hero can actually contest right now.',
  question: 'What can Hero win from CO first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'matched_amount_only',
      label: 'Only the chips CO matched against the 20 BB all-in',
      isCorrect: true,
      preferredLabel: 'Only the chips CO matched against the 20 BB all-in',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct beginner transfer.',
      feedbackReason:
          'Hero can only win the matched chips, not the extra 80 BB still behind CO. The short stack contests what got matched in front of it, not chips nobody put in.',
    ),
    Act0RunnerOptionV1(
      id: 'entire_covering_stack',
      label: 'All 100 BB from the covering stack',
      isCorrect: false,
      preferredLabel: 'Only the chips CO matched against the 20 BB all-in',
      betterAnswerLabel: 'Only the chips CO matched against the 20 BB all-in',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too many chips counted.',
      feedbackReason:
          'Hero cannot win chips CO never matched. Extra chips behind a covering stack stay out of Hero\'s contest until they are actually committed.',
    ),
    Act0RunnerOptionV1(
      id: 'nothing_until_showdown',
      label: 'Nothing counts until every stack is equal',
      isCorrect: false,
      preferredLabel: 'Only the chips CO matched against the 20 BB all-in',
      betterAnswerLabel: 'Only the chips CO matched against the 20 BB all-in',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Matched already matters.',
      feedbackReason:
          'You do not need equal stacks everywhere first. Once Hero is all-in and CO matches 20 BB, those matched chips are already the honest contest.',
    ),
  ],
  table: _allInMeaningRunner.table.copyWith(
    centerLabel: 'Matched chips set the contest',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Short stacks cannot win unmatched chips.',
      body: 'Only matched chips count. CO\'s 80 BB behind stays out.',
      focusLabels: <String>['Matched chips', '80 BB behind', 'Not contested'],
    ),
  ],
);

final _sidePotIntroRunner = _matchedChipsTransferRunner.copyWith(
  lessonId: 'side_pot_intro',
  caption:
      'Hero is all-in for 20 BB. CO and BB each matched Hero for 20 BB, then each added 30 BB more against each other.',
  hint:
      'Start with the short stack truth first. Main pot: three matched 20 BB stacks plus the 1.5 BB blinds. Side pot: the extra 30 BB from CO and 30 BB from BB.',
  question: 'Which statement is true here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_main_only',
      label: 'Hero can win the main pot, but not the side pot',
      isCorrect: true,
      preferredLabel: 'Hero can win the main pot, but not the side pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct side-pot intro.',
      feedbackReason:
          'Hero matched only 20 BB, so Hero fights for the main pot. The extra 30 BB from CO and BB forms a side pot that only those bigger stacks can win.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_wins_everything',
      label: 'Hero can win every chip once all-in',
      isCorrect: false,
      preferredLabel: 'Hero can win the main pot, but not the side pot',
      betterAnswerLabel: 'Hero can win the main pot, but not the side pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too many chips assigned.',
      feedbackReason:
          'All-in is not a claim on unmatched extra chips. Hero cannot win the side pot because Hero never matched those extra 30 BB between CO and BB.',
    ),
    Act0RunnerOptionV1(
      id: 'side_pot_is_penalty',
      label: 'The side pot is a penalty for the short stack',
      isCorrect: false,
      preferredLabel: 'Hero can win the main pot, but not the side pot',
      betterAnswerLabel: 'Hero can win the main pot, but not the side pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not a penalty, just a separate contest.',
      feedbackReason:
          'A side pot is not punishment. It is just the extra chips that only the bigger stacks matched after the short stack was already all-in.',
    ),
  ],
  table: _matchedChipsTransferRunner.table.copyWith(
    centerLabel: 'Hero cannot win side pot',
    potLabel: 'Main 60 BB + blinds 1.5 BB; side 60 BB',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Blinds: 1.5 BB'),
      Act0ActionTrailItemV1(label: 'Hero all-in 20 BB'),
      Act0ActionTrailItemV1(label: 'CO matches Hero for 20 BB'),
      Act0ActionTrailItemV1(label: 'BB matches Hero for 20 BB'),
      Act0ActionTrailItemV1(label: 'CO adds 30 BB extra'),
      Act0ActionTrailItemV1(label: 'BB adds 30 BB extra'),
    ],
    highlightedSeatIds: const <String>['btn', 'co', 'bb'],
    seats: _matchedChipsTransferRunner.table.seats
        .map<Act0SeatStateV1>(
          (seat) => seat.seatId == 'btn'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'Hero',
                  isHero: true,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: seat.isActive,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '0 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '20 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.allIn,
                    label: 'All-in',
                    amountLabel: '20 BB',
                  ),
                )
              : seat.seatId == 'co'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'CO',
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: true,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '50 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '50 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.raise,
                    label: 'Side pot',
                    amountLabel: '50 BB',
                  ),
                )
              : seat.seatId == 'bb'
              ? Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: 'Big blind',
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isActive: false,
                  isTarget: seat.isTarget,
                  isInHand: seat.isInHand,
                  isFolded: seat.isFolded,
                  hasActed: seat.hasActed,
                  isLastAggressor: seat.isLastAggressor,
                  isOccupied: seat.isOccupied,
                  stackLabel: '50 BB',
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                  currentBetLabel: '50 BB',
                  bet: const Act0SeatBetStateV1(
                    kind: Act0SeatBetKindV1.call,
                    label: 'Side pot call',
                    amountLabel: '50 BB',
                  ),
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Main pot first, side pot second.',
      body: 'Main: 20 BB matched + blinds. Side: CO/BB add 30 BB.',
      focusLabels: <String>[
        'Main pot',
        'Side pot',
        'Hero did not match extra chips',
      ],
    ),
  ],
);

final _winWaysRunner = _meetTableRunner.copyWith(
  lessonId: 'win_ways',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'A pot can end before showdown or at showdown.',
  caption: 'You win when others fold or when your hand wins showdown.',
  hint: 'Early lessons only need these two endings.',
  question: 'Which is a way to win the pot before showdown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'everyone_folds',
      label: 'Everyone folds',
      isCorrect: true,
      preferredLabel: 'Everyone folds',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'That is the early ending.',
      feedbackReason:
          'If everyone folds, the hand ends before showdown and the last player standing wins the pot immediately.',
    ),
    Act0RunnerOptionV1(
      id: 'largest_stack',
      label: 'Largest stack',
      isCorrect: false,
      preferredLabel: 'Everyone folds',
      betterAnswerLabel: 'Everyone folds',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'A larger stack can apply pressure later, but it does not end this pot by itself. Before showdown, you win only when everyone else folds.',
    ),
    Act0RunnerOptionV1(
      id: 'best_hand_showdown',
      label: 'Best hand at showdown',
      isCorrect: false,
      preferredLabel: 'Everyone folds',
      betterAnswerLabel: 'Everyone folds',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'That is the other ending.',
      feedbackReason:
          'Best hand at showdown is a real way to win, but this question asks for the early ending before cards are revealed.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A pot can end two ways.',
      body: 'Everyone else folds, or players compare hands at showdown.',
      focusLabels: <String>['Folds', 'Showdown'],
    ),
  ],
);

final _suitsRunner = _firstHandRunner.copyWith(
  lessonId: 'suits_drill',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'Each card has a rank and a suit. Ah means ace of hearts.',
  hint: 'A means ace. We write suits as s, h, d, c here, and h means hearts.',
  question: 'In Ah, what suit does h mean?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart',
      label: 'Hearts',
      isCorrect: true,
      preferredLabel: 'Hearts',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One goal clears the noise.',
      feedbackReason: 'Card code check: A means ace and h means hearts.',
    ),
    Act0RunnerOptionV1(
      id: 'rank',
      label: 'Ace',
      isCorrect: false,
      preferredLabel: 'Hearts',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'A is the rank. h is the suit.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Suits are card families.',
      body:
          'Card code uses s, h, d, and c for suits. A means ace, so Ah means ace of hearts.',
      focusLabels: <String>['s h d c', 'A = Ace', 'Ah = Ace of hearts'],
    ),
  ],
);

final _privateBoardRunner = _firstHandRunner.copyWith(
  lessonId: 'private_board',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'Private cards belong to you. Board cards are shared.',
  hint: 'Your two cards stay near the hero seat.',
  question: 'Which cards can everyone use?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'board',
      label: 'Board cards',
      isCorrect: true,
      preferredLabel: 'Board cards',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Overfold means widen.',
      feedbackReason: 'Board cards are shared by everyone still in the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'private',
      label: 'Private cards',
      isCorrect: false,
      preferredLabel: 'Board cards',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'Private cards belong only to one player. Board cards sit in the middle as shared cards, so everyone still in the hand can use them.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    centerLabel: 'Shared board',
    potLabel: 'Pot 5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Private cards stay private.',
      body: 'Board cards are shared by every player still in the hand.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['board_0', 'board_1', 'board_2'],
      focusLabels: <String>['Private', 'Shared'],
    ),
  ],
);

final _turnBoardRunner = _readBoardRunner.copyWith(
  lessonId: 'your_first_hand_turn',
  lessonTitle: 'Your first hand, dealt',
  lessonSubtitle: 'The turn adds one more shared card.',
  caption: 'The turn is the fourth board card.',
  hint: 'Flop has three cards. Turn makes four.',
  question: 'How many board cards are visible on the turn?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'three',
      label: 'Three',
      isCorrect: false,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'Three cards is the flop. Turn makes four.',
    ),
    Act0RunnerOptionV1(
      id: 'four',
      label: 'Four',
      isCorrect: true,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Callers want value.',
      feedbackReason: 'The turn is the fourth board card.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Four',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'Five board cards appear on the river.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Turn',
    boardCards: const <Act0CardStateV1>[
      ..._flopA72Cards,
      Act0CardStateV1(rank: 'J', suit: 'c'),
    ],
    potLabel: 'Pot 5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Turn means one more board card.',
      body: 'After the flop, exactly one shared card is added.',
      focusCardIds: <String>['board_3'],
      focusLabels: <String>['Fourth board card'],
    ),
  ],
);

final _riverBoardRunner = _readBoardRunner.copyWith(
  lessonId: 'your_first_hand_river',
  lessonTitle: 'Your first hand, dealt',
  lessonSubtitle: 'The river completes the board.',
  caption: 'The river is the fifth board card.',
  hint: 'Now the shared board is complete.',
  question: 'How many board cards are visible on the river?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'four',
      label: 'Four',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'Four cards is the turn. River makes five.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: true,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pick the repeat leak.',
      feedbackReason: 'The river completes five board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: 'Six',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'Holdem uses five board cards, not six.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'River',
    boardCards: const <Act0CardStateV1>[
      ..._flopA72Cards,
      Act0CardStateV1(rank: 'J', suit: 'c'),
      Act0CardStateV1(rank: '4', suit: 's'),
    ],
    potLabel: 'Pot 5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'River completes the board.',
      body: 'The fifth shared card is the last board card.',
      focusCardIds: <String>['board_4'],
      focusLabels: <String>['Fifth board card'],
    ),
  ],
);

final _checkActionRunner = _firstHandRunner.copyWith(
  lessonId: 'actions_check',
  lessonTitle: 'Fold, check, call, raise',
  lessonSubtitle: 'No bet means checking is available.',
  caption: 'No one has bet on this street.',
  hint: 'Checking keeps your hand without adding chips.',
  question: 'What action keeps playing for free?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'Folding gives up the hand. Checking is free here.',
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Specific fix transfers.',
      feedbackReason: 'Checking keeps the hand going when no bet faces you.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      isCorrect: false,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'Calling means matching a bet. There is no bet here.',
    ),
  ],
  table: _firstHandRunner.table.copyWith(
    streetLabel: 'Flop',
    boardCards: _flopA72Cards,
    potLabel: 'Pot 3 BB',
    toCallLabel: '',
    centerLabel: 'No bet yet',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'No bet is facing you.',
      body: 'When no one has bet, check keeps playing for free.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['No bet', 'Check is free'],
    ),
  ],
);

final _foldActionRunner = _readBoardRunner.copyWith(
  lessonId: 'actions_fold',
  lessonTitle: 'Fold, check, call, raise',
  lessonSubtitle: 'Facing a bet with a weak hand can be a fold.',
  caption: 'HJ bets and your hand is weak.',
  hint: 'Folding saves chips when continuing is not worth it.',
  question: 'Which action gives up the hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Low-energy plan first.',
      feedbackReason: 'Fold gives up the hand and saves the call.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'Calling spends chips to continue with a weak hand.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Raising adds more chips with a weak hand.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 7 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Facing a bet',
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        bet: _hjBet2Bb,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'HJ bets 2 BB'),
      Act0ActionTrailItemV1(label: 'Hero acts'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'A bet creates a price.',
      body: 'If your hand is not worth the price, folding saves chips.',
      focusSeatIds: <String>['btn', 'hj'],
      focusLabels: <String>['Facing bet', 'Fold saves'],
    ),
  ],
);

final _callActionRunner = _readBoardRunner.copyWith(
  lessonId: 'actions_call',
  lessonTitle: 'Fold, check, call, raise',
  lessonSubtitle: 'Calling matches the current price.',
  caption: 'You face a small bet and want the cheapest continue.',
  hint: 'Call means match the bet.',
  question: 'Which action matches the 1 BB price?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'Folding gives up instead of continuing.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One trigger, one lever.',
      feedbackReason: 'Calling matches the current price.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '4 BB',
      isCorrect: false,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'Raising adds more chips than the call price.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 5 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: 'Facing a price',
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        bet: _hjBet1Bb,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'HJ bets 1 BB'),
      Act0ActionTrailItemV1(label: 'Hero acts'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Calling matches the price.',
      body: 'Call means put in exactly enough chips to continue.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['To call 1 BB'],
    ),
  ],
);

final _blindsOrderRunner = _meetTableRunner.copyWith(
  lessonId: 'blinds_action_order',
  lessonTitle: 'Blinds & action order',
  lessonSubtitle: 'The blinds seed the pot before the hand begins.',
  caption: 'SB and BB post before cards are played.',
  hint: 'The first decision comes after the big blind.',
  question: 'Which blind posts 1 BB?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Blinds force a starting pot.',
      body:
          'Blinds are real chips or money put in first. Players often count them in big blinds because BB is the clean shortcut for the price.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['Real money', 'Count in BB'],
    ),
    Act0TeachingStepV1(
      title: 'Action starts after BB.',
      body:
          'If the big blind is 1 BB, then a 3 BB open means three times that price. Preflop, UTG is first to choose after the blinds post.',
      focusSeatIds: <String>['utg', 'bb'],
      focusLabels: <String>['1 BB baseline', 'UTG first'],
    ),
  ],
);

final _firstPreflopActorRunner = _meetTableRunner.copyWith(
  lessonId: 'first_preflop_actor',
  lessonTitle: 'Blinds & action order',
  caption: 'Preflop starts left of the big blind.',
  hint: 'Tap the first preflop actor.',
  question: 'Tap UTG.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG acts first preflop.',
      feedbackReason: 'UTG acts first before the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'The Button acts late, not first preflop.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['utg', 'btn'],
    highlightedSeatIds: const <String>['utg'],
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Preflop begins after BB.',
      body: 'The first seat left of the big blind is UTG.',
      focusSeatIds: <String>['utg', 'bb'],
      focusLabels: <String>['UTG first'],
    ),
  ],
);

final _lastPreflopActorRunner = _meetTableRunner.copyWith(
  lessonId: 'last_preflop_actor',
  lessonTitle: 'Blinds & action order',
  caption: 'The big blind closes preflop when nobody raises.',
  hint: 'Tap the last preflop actor.',
  question: 'Tap BB.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'The big blind can act last before the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'The small blind acts before the big blind preflop.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['bb', 'sb'],
    highlightedSeatIds: const <String>['bb'],
    activeSeatId: 'bb',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same BB, new job.',
      body:
          'After posting the full blind, the big blind can still act last preflop if nobody raises.',
      focusSeatIds: <String>['bb'],
      focusLabels: <String>['BB last preflop'],
    ),
  ],
);

final _postflopButtonActorRunner = _meetTableRunner.copyWith(
  lessonId: 'postflop_button_actor',
  lessonTitle: 'Blinds & action order',
  caption: 'After the flop, Button often acts last.',
  hint: 'Tap BTN.',
  question: 'Tap the last postflop actor.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process beats reveal.',
      feedbackReason: 'Button acts last after the flop in this hand.',
    ),
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'UTG is early, not the late postflop seat here.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'utg'],
    highlightedSeatIds: const <String>['btn'],
    activeSeatId: 'btn',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Postflop order changes.',
      body: 'After the flop, blinds act early and Button often acts last.',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['BTN late'],
    ),
  ],
);

final _w3BtnLastPostflopRepairRunner = _postflopButtonActorRunner.copyWith(
  lessonId: 'w3_repair_btn_last_postflop',
  lessonTitle: 'Button advantage',
  caption: 'Repair: BTN acts last after the flop.',
  hint: 'Find the Button on the table.',
  question: 'Who acts last after the flop?',
  feedbackTitle: 'BTN-last repaired.',
  feedbackReason: 'Button acts after the blinds postflop in this hand.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the postflop order.',
      body: 'After the flop, Button is the late seat and acts last here.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['BTN acts last postflop'],
    ),
  ],
);

final _positionsRunner = _meetTableRunner.copyWith(
  lessonId: 'positions',
  lessonTitle: 'The 6 positions',
  lessonSubtitle: 'Every seat has a name.',
  caption: 'The six seats are UTG, HJ, CO, BTN, SB, and BB.',
  hint: 'Button acts last after the flop.',
  question: 'Which seat is the Button?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seats have names.',
      body:
          'UTG means under the gun, the first seat to act. HJ is hijack. CO is cutoff. BTN is button, and SB plus BB are the blinds.',
      focusLabels: <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
    ),
    Act0TeachingStepV1(
      title: 'Position changes information.',
      body: 'Late seats see more actions before they decide.',
      focusSeatIds: <String>['btn', 'utg'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

final _buttonSeatRunner = _meetTableRunner.copyWith(
  lessonId: 'button_seat',
  lessonTitle: 'The 6 positions',
  caption: 'Button is the dealer seat in this hand.',
  hint: 'Tap BTN.',
  question: 'Tap the Button.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Win can hide a leak.',
      feedbackReason: 'BTN is the dealer button and acts last postflop.',
    ),
    Act0RunnerOptionV1(
      id: 'co',
      label: 'CO',
      seatId: 'co',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'CO is one seat before the Button.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'co'],
    highlightedSeatIds: const <String>['btn'],
    activeSeatId: 'btn',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'BTN marks the Button.',
      body: 'The dealer button shows the late seat for this hand.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['BTN'],
    ),
  ],
);

final _utgSeatRunner = _meetTableRunner.copyWith(
  lessonId: 'utg_seat',
  lessonTitle: 'The 6 positions',
  caption: 'UTG is the earliest preflop seat.',
  hint: 'Tap UTG.',
  question: 'Tap UTG.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Reset before next hand.',
      feedbackReason:
          'UTG acts first preflop, so opening range should stay tighter.',
    ),
    Act0RunnerOptionV1(
      id: 'hj',
      label: 'HJ',
      seatId: 'hj',
      isCorrect: false,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'HJ is after UTG in this order.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['utg', 'hj'],
    highlightedSeatIds: const <String>['utg'],
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'UTG is early.',
      body: 'UTG acts first preflop and has the least information.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['Early seat'],
    ),
  ],
);

final _w3SeatIdBtnRepairRunner = _buttonSeatRunner.copyWith(
  lessonId: 'w3_repair_seat_id_btn',
  caption: 'Repair: BTN is the Button seat.',
  hint: 'Find the dealer button, then tap BTN.',
  question: 'Tap BTN again.',
  feedbackTitle: 'BTN repaired.',
  feedbackReason: 'BTN is the Button seat and the late-position anchor.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the Button seat.',
      body: 'BTN is the seat marked by the dealer button.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Button seat'],
    ),
  ],
);

final _w3SeatIdUtgRepairRunner = _utgSeatRunner.copyWith(
  lessonId: 'w3_repair_seat_id_utg',
  caption: 'Repair: UTG is the first preflop seat.',
  hint: 'Find the earliest preflop seat, then tap UTG.',
  question: 'Tap UTG again.',
  feedbackTitle: 'UTG repaired.',
  feedbackReason:
      'UTG is the early seat that acts first before the rest of the table.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the UTG seat.',
      body: 'UTG is the first preflop seat after the blinds are posted.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['UTG seat'],
    ),
  ],
);

final _latePositionRunner = _meetTableRunner.copyWith(
  lessonId: 'late_position',
  lessonTitle: 'The 6 positions',
  caption: 'Late seats see more actions before deciding.',
  hint: 'Button is the clearest late seat.',
  question: 'Which seat acts latest after the flop?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Log it, then reset.',
      feedbackReason: 'BTN is late and often acts last after the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'UTG is early and has less information.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'utg'],
    highlightedSeatIds: const <String>['btn'],
    activeSeatId: 'btn',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late means more information.',
      body: 'Late seats see more choices before they decide.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Late seat'],
    ),
  ],
);

final _handRankingsRunner = _readBoardRunner.copyWith(
  lessonId: 'hand_rankings_table',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Hands are compared by their best five cards.',
  hint: 'A pair beats one high card.',
  question: 'What does hero have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pair',
      label: 'Pair',
      isCorrect: true,
      preferredLabel: 'Pair',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process ignores table talk.',
      feedbackReason: 'Hero has a pair with the board.',
    ),
    Act0RunnerOptionV1(
      id: 'high_card',
      label: 'High card',
      isCorrect: false,
      preferredLabel: 'Pair',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'A matching rank makes a pair.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    heroCards: _heroAkCards,
    highlightedCardIds: const <String>['hero_0', 'board_0'],
    seats: _readBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(seat, holeCards: _heroAkCards)
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Hands use the best five cards.',
      body: 'You combine private cards with the board, then compare hand rank.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['Best five'],
    ),
    Act0TeachingStepV1(
      title: 'A pair beats high card.',
      body: 'Matching ranks make the first made hand beginners need.',
      focusLabels: <String>['Pair'],
    ),
  ],
);

final _handRankingIntroRunner = _handRankingsRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'hand_ranking_intro',
  caption: 'Hand rank names describe made hands.',
  hint:
      'Start with the ladder: pair, two pair, trips, straight, flush, full house, quads, straight flush.',
  question: 'What do hand rankings compare?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Ranking ladder.',
      body:
          'Hand names tell which made hand is stronger, all the way up to full house, quads, and straight flush.',
      focusLabels: <String>[
        'Pair',
        'Two pair',
        'Straight',
        'Flush',
        'Full house',
        'Quads',
      ],
    ),
  ],
);

final _flushRankRunner = _readBoardRunner.copyWith(
  lessonId: 'flush_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A flush uses five cards of one suit.',
  hint: 'Flush beats straight in Holdem.',
  question: 'Which hand ranks higher?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush',
      label: 'Flush',
      isCorrect: true,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Flush found.',
      feedbackReason:
          'Start with the suit match: five cards of one suit make a flush, and a flush ranks above a straight.',
    ),
    Act0RunnerOptionV1(
      id: 'straight',
      label: 'Straight',
      isCorrect: false,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'A straight uses connected ranks, but it does not need five cards of one suit, so it stays below a flush.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'River',
    heroCards: _heroKhQhCards,
    boardCards: _boardFlushVsStraight,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Hero flush beats CO straight',
    seats: _readBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponent8c9sCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Flush means same suit.',
      body:
          'Hero uses five hearts for a flush, while CO only reaches a 7-8-9-T-J straight. This is an ace-high flush, not a royal flush, because the hearts do not run T-J-Q-K-A together. Flushes rank above straights because they are rarer: roughly 5,100 flush combinations exist in a deck versus about 10,200 straights. Rarer combinations rank higher.',
      focusLabels: <String>[
        'Same suit',
        'Ace-high flush',
        'Not royal',
        'Rarer = higher',
      ],
    ),
  ],
);

final _fullHouseRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'full_house_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A full house is three of one rank plus two of another.',
  hint: 'Trips plus a pair make a full house.',
  question: 'What does hero have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'full_house',
      label: 'Full house',
      isCorrect: true,
      preferredLabel: 'Full house',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Full house found.',
      feedbackReason:
          'Hero uses A-A-A with 7-7, which makes a full house. That rank sits above a flush because the hand is stronger and rarer.',
    ),
    Act0RunnerOptionV1(
      id: 'trips',
      label: 'Trips',
      isCorrect: false,
      preferredLabel: 'Full house',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One pair short.',
      feedbackReason:
          'Trips are only part of the hand. Hero also has a pair of sevens, so the best five become a full house instead of bare trips.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _hero7s7hCards,
    boardCards: _boardTripsAces,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'A-A-A with 7-7',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _hero7s7hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Full house = trips plus pair.',
      body:
          'The board gives Hero three aces, and Hero pocket sevens add the pair. That makes a full house, which outranks a flush.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'hero_0',
        'hero_1',
      ],
      focusLabels: <String>['A-A-A', '7-7', 'Full house'],
    ),
  ],
);

final _quadsRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'quads_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Four of a kind means all four cards of one rank.',
  hint: 'Look for all four queens.',
  question: 'What does hero have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'quads',
      label: 'Four of a kind',
      isCorrect: true,
      preferredLabel: 'Four of a kind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Quads spotted.',
      feedbackReason:
          'Hero uses all four queens. Four of a kind ranks above a full house because no extra pair can beat all four cards of one rank.',
    ),
    Act0RunnerOptionV1(
      id: 'full_house',
      label: 'Full house',
      isCorrect: false,
      preferredLabel: 'Four of a kind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close on the ladder.',
      feedbackReason:
          'A full house needs three of one rank and two of another. Here Hero has all four queens, so the hand is four of a kind.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroQqCards,
    boardCards: _boardQuadsQueens,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
    centerLabel: 'Four queens play',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroQqCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Quads mean all four cards.',
      body:
          'Hero uses Q-Q from hand and Q-Q from the board. All four queens count, so this hand outranks a full house.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['Q-Q-Q-Q', 'Quads'],
    ),
  ],
);

final _royalFlushRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'royal_flush_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A royal flush is T-J-Q-K-A all in one suit.',
  hint: 'A flush with an ace is not royal unless the ranks run to ace.',
  question: 'What does hero have here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'royal_flush',
      label: 'Royal flush',
      isCorrect: true,
      preferredLabel: 'Royal flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Top of the ladder.',
      feedbackReason:
          'Hero makes T-J-Q-K-A in hearts. That is a royal flush, which is the ace-high straight flush and beats every ordinary flush.',
    ),
    Act0RunnerOptionV1(
      id: 'ace_high_flush',
      label: 'Ace-high flush',
      isCorrect: false,
      preferredLabel: 'Royal flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Same suit, but stronger.',
      feedbackReason:
          'Hero does have an ace-high flush, but the five hearts also run T-J-Q-K-A in sequence. That makes it the royal flush, not just a normal ace-high flush.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroKhQhCards,
    boardCards: _boardRoyalFlushHearts,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'A-K-Q-J-T hearts',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Royal flush is the ace-high straight flush.',
      body:
          'Hero uses T-J-Q-K-A in hearts. A normal ace-high flush is not enough unless the five suited cards also run in sequence to the ace.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'hero_0',
        'hero_1',
      ],
      focusLabels: <String>['T-J-Q-K-A', 'Same suit', 'Royal flush'],
    ),
  ],
);

final _fullHouseVsFlushRunner = _riverBoardRunner.copyWith(
  lessonId: 'full_house_vs_flush',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'At showdown, a full house beats a flush.',
  hint: 'Build both best five hands before choosing the winner.',
  question: 'Who wins at showdown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_full_house',
      label: 'Hero full house',
      isCorrect: true,
      preferredLabel: 'Hero full house',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct winner.',
      feedbackReason:
          'Hero makes A-A-A-7-7 for a full house. CO has a heart flush, but a full house ranks above a flush.',
    ),
    Act0RunnerOptionV1(
      id: 'co_flush',
      label: 'CO flush',
      isCorrect: false,
      preferredLabel: 'Hero full house',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Strong hand, lower rank.',
      feedbackReason:
          'CO does make a flush, but Hero full house is stronger. Always compare the hand rank before admiring a strong-looking suit pattern.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroAs7sCards,
    boardCards: _boardFullHouseVsFlush,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Hero full house beats CO flush',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroAs7sCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the full best five.',
      body:
          'Hero uses A-A-A with 7-7 for a full house. CO uses five hearts for a flush, but the full house wins because it ranks higher.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      focusLabels: <String>['A-A-A', '7-7', 'Full house wins'],
    ),
  ],
);

final _quadsVsFullHouseRunner = _riverBoardRunner.copyWith(
  lessonId: 'quads_vs_full_house',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Four of a kind beats a full house.',
  hint: 'One player has all four queens. The other only has a full house.',
  question: 'Who wins at showdown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_quads',
      label: 'Hero four of a kind',
      isCorrect: true,
      preferredLabel: 'Hero four of a kind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Top hand found.',
      feedbackReason:
          'Hero uses all four queens. CO makes a full house with three sevens and two queens, but quads rank above a full house.',
    ),
    Act0RunnerOptionV1(
      id: 'co_full_house',
      label: 'CO full house',
      isCorrect: false,
      preferredLabel: 'Hero four of a kind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close on the ladder.',
      feedbackReason:
          'CO does make a full house, but Hero holds all four queens. Four of a kind outranks a full house at showdown.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroQqCards,
    boardCards: _boardQuadsVsFullHouse,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
    centerLabel: 'Hero quads beat CO full house',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroQqCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentAc7hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Quads outrank a full house.',
      body:
          'Hero uses Q-Q-Q-Q with a seven kicker. CO uses 7-7-7 with Q-Q for a full house, but four of a kind still wins.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['Q-Q-Q-Q', 'Quads win'],
    ),
  ],
);

final _royalFlushVsFlushRunner = _riverBoardRunner.copyWith(
  lessonId: 'royal_flush_vs_flush',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A royal flush beats an ace-high flush.',
  hint: 'Same suit is not enough. Check whether the cards also run T-J-Q-K-A.',
  question: 'Which hand ranks higher?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_royal_flush',
      label: 'Hero royal flush',
      isCorrect: true,
      preferredLabel: 'Hero royal flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'Hero has the royal flush because the hearts run T-J-Q-K-A. CO has only an ace-high flush, so Hero wins with the higher flush type.',
    ),
    Act0RunnerOptionV1(
      id: 'co_ace_high_flush',
      label: 'CO ace-high flush',
      isCorrect: false,
      preferredLabel: 'Hero royal flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Same suit, different ceiling.',
      feedbackReason:
          'CO does make an ace-high flush, but the five hearts do not run to the ace in sequence. Hero straight flushes all the way to A, so it is the royal flush.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroKhQhCards,
    boardCards: _boardRoyalFlushHearts,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    centerLabel: 'Hero royal flush beats CO ace-high flush',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroKhQhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponent9h3hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Royal flush is more than ace-high.',
      body:
          'Hero uses T-J-Q-K-A in hearts. CO also has five hearts, but only Hero connects the ranks all the way to the ace.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'hero_0',
        'hero_1',
      ],
      focusLabels: <String>['T-J-Q-K-A', 'Royal flush wins'],
    ),
  ],
);

final _twoPairRunner = _riverBoardRunner.copyWith(
  lessonId: 'two_pair_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Two pair beats one pair.',
  hint: 'Count matching ranks on the board and in hand.',
  question: 'Which hand is stronger?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_pair',
      label: 'Two pair',
      isCorrect: true,
      preferredLabel: 'Two pair',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Two pair spotted.',
      feedbackReason:
          'Count the matching ranks in the best five first: Hero makes two pair, and two pair outranks one pair.',
    ),
    Act0RunnerOptionV1(
      id: 'one_pair',
      label: 'One pair',
      isCorrect: false,
      preferredLabel: 'Two pair',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Count the matching ranks before judging the hand: one pair uses only one match, so it stays below Hero two pair in the best five.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroA7oCards,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
    centerLabel: 'Hero two pair beats CO one pair',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroA7oCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentKhJhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Two pair uses two ranks.',
      body:
          'Hero uses A with A and 7 with 7. CO only matches the J once, so Hero two pair is stronger than one pair.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0', 'board_1'],
      focusLabels: <String>['A + A', '7 + 7', 'Two pair'],
    ),
  ],
);

final _showdownRunner = _readBoardRunner.copyWith(
  lessonId: 'showdown_winning',
  lessonTitle: 'Showdown & winning',
  caption: 'A hand can end by folds or by showdown.',
  hint: 'If everyone folds, the last player wins now.',
  question: 'What happens if everyone folds to you?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'win_now',
      label: 'Win now',
      isCorrect: true,
      preferredLabel: 'Win now',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'When everyone folds, the last player wins the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'show_cards',
      label: 'Show cards',
      isCorrect: false,
      preferredLabel: 'Win now',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'No showdown is needed when everyone else folds.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown means reveal.',
      body: 'If players remain after the river, hands are compared.',
      focusLabels: <String>['Reveal', 'Compare'],
    ),
    Act0TeachingStepV1(
      title: 'Folds can end earlier.',
      body: 'If everyone else folds, no reveal is needed.',
      focusLabels: <String>['Win by folds'],
    ),
  ],
);

final _showdownIntroRunner = _showdownRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'showdown_intro',
  caption: 'A hand can end before or at showdown.',
  hint: 'Folds end it early. Showdown compares hands.',
  question: 'What are the two broad ways to win?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Two endings.',
      body: 'Win when everyone folds, or win by best hand at showdown.',
      focusLabels: <String>['Folds', 'Showdown'],
    ),
  ],
);

final _showdownBestHandRunner = _riverBoardRunner.copyWith(
  lessonId: 'showdown_best_hand',
  lessonTitle: 'Showdown & winning',
  caption: 'At showdown, the best hand wins the pot.',
  hint: 'Compare the final five-card hand.',
  question: 'What decides a showdown?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'best_hand',
      label: 'Best hand',
      isCorrect: true,
      preferredLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'At showdown, players use the best five-card hand they can make from private cards plus the shared board.',
    ),
    Act0RunnerOptionV1(
      id: 'first_actor',
      label: 'First actor',
      isCorrect: false,
      preferredLabel: 'Best hand',
      betterAnswerLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'Seat order decides who acts first, not who wins at showdown. Once cards are revealed, players compare the best full hand they can make from private cards plus the shared board.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_only',
      label: 'Hero cards only',
      isCorrect: false,
      preferredLabel: 'Best hand',
      betterAnswerLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Only part of the hand.',
      feedbackReason:
          'Private cards matter, but showdown uses the whole five-card result. The shared board can help both players, so the best full hand decides it.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_3',
    ],
    centerLabel: 'Hero pair of queens beats CO pair of jacks',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentKhJhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown compares hands.',
      body:
          'Hero best five are Q-Q-A-J-7, while CO best five are J-J-A-K-7. The bigger pair wins before the kicker matters.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_3',
      ],
      focusLabels: <String>['Q-Q-A-J-7', 'Hero wins'],
    ),
  ],
);

final _showdownKickerRunner = _riverBoardRunner.copyWith(
  lessonId: 'showdown_kicker',
  lessonTitle: 'Showdown & winning',
  caption: 'If both players share a pair, the side card can matter.',
  hint: 'That side card is called a kicker.',
  question: 'Same pair. What can break the tie?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'kicker',
      label: 'Kicker',
      isCorrect: true,
      preferredLabel: 'Kicker',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason: 'The better kicker can win when the main pair matches.',
    ),
    Act0RunnerOptionV1(
      id: 'seat',
      label: 'Seat name',
      isCorrect: false,
      preferredLabel: 'Kicker',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'Seat name does not break a tied hand.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroAsKhCards,
    boardCards: _boardAce,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'co_0',
      'co_1',
    ],
    centerLabel: 'Hero A-K beats CO A-Q by kicker',
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroAsKhCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentAdQdCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Kickers break some ties.',
      body:
          'Both players share a pair of aces from the board and one ace in hand. Hero K plays above CO Q, while the J and 7 stay the same for both best fives.',
      focusCardIds: <String>['hero_1', 'co_1', 'board_0'],
      focusLabels: <String>['K kicker', 'Q kicker', 'Same pair of aces'],
    ),
  ],
);

final _tableObjectsRunner = _meetTableRunner.copyWith(
  lessonId: 'table_objects',
  lessonTitle: 'What poker is',
  caption: 'Button, small blind, and big blind explain the hand setup.',
  hint: 'The big blind posts 1 BB before action starts.',
  question: 'Which seat posted 1 BB?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'BB is the big blind and posts 1 BB.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'SB posts 0.5 BB. BB posts 1 BB.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['bb', 'sb'],
    highlightedSeatIds: const <String>['bb', 'sb', 'btn'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Blinds are forced posts.',
      body: 'SB posts the small blind. BB posts the full big blind.',
      focusSeatIds: <String>['sb', 'bb'],
      focusLabels: <String>['0.5 BB', '1 BB'],
    ),
  ],
);

final _tableRecapRunner = _winWaysRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'table_recap',
  caption: 'Lesson learned: read the table before choosing.',
  hint: 'Hero is you, opponents fight you, blinds create the first pot.',
  question: 'What is the pot?',
  feedbackTitle: 'Table takeaway.',
  feedbackReason:
      'The pot is the prize in the middle. Stacks belong to players until chips move in.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Table checklist.',
      body: 'Find hero, opponents, blinds, and pot before any decision.',
      focusLabels: <String>['Hero', 'Pot', 'Blinds'],
    ),
  ],
);

final _w1TableReadTransferRunner = _tableRecapRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w1_table_read_transfer',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Poker from Zero',
  caption: 'Real table. 2 cards, flop 3, pot 6 BB.',
  hint: 'Separate private cards, board cards, and pot before any action.',
  question: 'What is the clean first table read?',
  feedbackTitle: 'Table read first.',
  feedbackReason:
      'Real-table transfer starts with the same three checks every time: private cards, board cards, and chips in the pot.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_three_six',
      label: '2 private cards, 3 board cards, 6 BB in the pot',
      isCorrect: true,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'That is the clean first live read. Separate hero cards, shared board, and chips in the middle before choosing anything.',
    ),
    Act0RunnerOptionV1(
      id: 'five_board_now',
      label: '5 board cards are already out',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'The flop has only three shared cards. Five board cards appear only by the river.',
    ),
    Act0RunnerOptionV1(
      id: 'hand_first_only',
      label: 'Only hero hand matters first',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 6 BB in the pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable instinct.',
      feedbackReason:
          'Hero cards matter, but a live table read also needs the shared board and pot before the decision starts.',
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    heroCards: _heroAkCards,
    boardCards: _flopA72Cards,
    centerLabel: 'Read hand, board, pot',
    potLabel: 'Pot 6 BB',
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry the first table scan.',
      body:
          'Real tables use the same simple scan.\n\nFind your two cards and the shared board.\n\nThen check how many chips are already in the pot.',
      focusLabels: <String>['2 private', '3 board', 'Pot'],
    ),
  ],
);

final _firstTableGuideReadTableRecheckRunner = _w1TableReadTransferRunner.copyWith(
  lessonId: 'what_poker_is_table_read_recheck',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Poker from Zero',
  caption:
      'New spot. Hero has two cards, the flop has three, and the pot is 4 BB.',
  hint: 'Read Hero cards, shared board, and pot before any action.',
  question: 'What is the clean table read here?',
  feedbackTitle: 'Same scan, new spot.',
  feedbackReason:
      'You repeated the table scan: Hero cards, shared board, then pot.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two_three_four',
      label: '2 private cards, 3 board cards, 4 BB in the pot',
      isCorrect: true,
      preferredLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean table read.',
      feedbackReason:
          'Same scan, new numbers: Hero has two private cards, the board has three shared cards, and the pot is 4 BB.',
      repairFocusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      repairFocusLabels: <String>['Hero cards', 'Board cards', 'Pot 4 BB'],
    ),
    Act0RunnerOptionV1(
      id: 'five_board_cards',
      label: '5 board cards are out',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good spot to recheck.',
      feedbackReason:
          'Only the flop is out, so the board has three shared cards here.',
      repairFocusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      repairFocusLabels: <String>['Hero cards', 'Board cards', 'Pot 4 BB'],
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_only',
      label: 'Only Hero cards matter',
      isCorrect: false,
      preferredLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      betterAnswerLabel: '2 private cards, 3 board cards, 4 BB in the pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Part of the read.',
      feedbackReason:
          'Hero cards matter, but the clean table read also includes the shared board and the pot.',
      repairFocusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      repairFocusLabels: <String>['Hero cards', 'Board cards', 'Pot 4 BB'],
    ),
  ],
  table: _readBoardRunner.table.copyWith(
    heroCards: _heroQqCards,
    boardCards: _flopA72Cards,
    centerLabel: 'Read hand, board, pot',
    potLabel: 'Pot 4 BB',
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_2',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repeat the same scan.',
      body:
          'Read your two cards, then the shared board, then the pot. Same scan, different spot.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      ],
      focusLabels: <String>['2 private', '3 board', 'Pot 4 BB'],
    ),
  ],
);

final _w1LiveWinTransferRunner = _winWaysRunner.copyWith(
  lessonId: 'w1_live_win_transfer',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Poker from Zero',
  caption:
      'Real table. Hero is BTN, blinds are posted, and the pot starts at 1.5 BB.',
  hint: 'After the first read, remember how this pot can still finish.',
  question: 'In this live hand, what can still decide the pot?',
  feedbackTitle: 'That is the live loop.',
  feedbackReason:
      'A real hand still ends the same two clean ways: everyone folds, or players reach showdown and the best hand wins.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_or_showdown',
      label: 'A fold or a showdown',
      isCorrect: true,
      preferredLabel: 'A fold or a showdown',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'The table can look busier, but the pot still closes by fold or by best hand at showdown.',
    ),
    Act0RunnerOptionV1(
      id: 'button_wins_now',
      label: 'The button wins automatically',
      isCorrect: false,
      preferredLabel: 'A fold or a showdown',
      betterAnswerLabel: 'A fold or a showdown',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more read.',
      feedbackReason:
          'BTN tells you Hero acts late. The seat does not win the pot by itself.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_cards_decide_now',
      label: 'Hero cards decide it immediately',
      isCorrect: false,
      preferredLabel: 'A fold or a showdown',
      betterAnswerLabel: 'A fold or a showdown',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partly right.',
      feedbackReason:
          'Hero cards matter if the hand reaches showdown, but the pot can still end earlier when everyone else folds.',
    ),
  ],
  table: _tableObjectsRunner.table.copyWith(
    centerLabel: 'BTN, blinds, pot',
    potLabel: 'Pot 1.5 BB',
    selectableSeatIds: const <String>[],
    highlightedSeatIds: const <String>['btn', 'sb', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Real hand, same endings.',
      body:
          'Even in a real hand, the pot still ends one of two ways: everyone folds, or players reach showdown.',
      focusLabels: <String>['Fold', 'Showdown', 'Pot 1.5 BB'],
    ),
  ],
);

final _firstTableGuideMeetTableRunner = _meetTableRunner.copyWith(
  lessonId: 'first_table_guide_meet_table',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 1,
  beatCount: 5,
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'One loop first.',
      body:
          'Sharky teaches one spot at a time. Read, answer, and get a clear why.',
      focusLabels: <String>['Read', 'Answer', 'Why'],
    ),
    Act0TeachingStepV1(
      title: 'Start with the table.',
      body:
          'Hero is you. SB = Small Blind. BB = Big Blind.\n\nSB posts 0.5 BB. BB posts 1 BB.',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['Hero', 'Blinds', 'Table first'],
    ),
  ],
);

final _firstTableGuideFindHeroRunner = _findHeroSeatRunner.copyWith(
  lessonId: 'first_table_guide_find_hero',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 2,
  beatCount: 5,
);

final _firstTableGuideReadTableRunner = _w1TableReadTransferRunner.copyWith(
  lessonId: 'first_table_guide_read_table',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 3,
  beatCount: 5,
);

final _firstTableGuideActionRunner = _whatYouCanDoRunner.copyWith(
  lessonId: 'first_table_guide_one_clear_choice',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 4,
  beatCount: 5,
  caption: 'Same scan, new spot: Hero is first in on the Button with KTs.',
  hint: 'No board is out yet. Start with Hero, blinds, pot, and who acts next.',
  question: 'What is the clean preflop setup here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_btn_preflop_setup',
      label: 'Hero is BTN, blinds are posted, and no board is out yet',
      isCorrect: true,
      preferredLabel: 'Hero is BTN, blinds are posted, and no board is out yet',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'That is the setup.',
      feedbackReason:
          'That is the clean first read. Hero is on the Button, the blinds already seeded the pot, and no board is out yet because this spot is still preflop.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>[
        'Hero on the Button',
        'Blinds posted',
        'No board yet',
      ],
    ),
    Act0RunnerOptionV1(
      id: 'co_still_acting',
      label: 'CO is still in the hand and Hero must wait',
      isCorrect: false,
      preferredLabel: 'Hero is BTN, blinds are posted, and no board is out yet',
      betterAnswerLabel:
          'Hero is BTN, blinds are posted, and no board is out yet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Read one seat earlier.',
      feedbackReason:
          'CO already folded in this setup, so action is on Hero now. The next safe job is to name who acts, not to solve the whole hand.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>[
        'Hero on the Button',
        'Blinds posted',
        'No board yet',
      ],
    ),
    Act0RunnerOptionV1(
      id: 'flop_already_out',
      label: 'The flop is already out and this is postflop',
      isCorrect: false,
      preferredLabel: 'Hero is BTN, blinds are posted, and no board is out yet',
      betterAnswerLabel:
          'Hero is BTN, blinds are posted, and no board is out yet',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not yet.',
      feedbackReason:
          'No board cards are out yet, so this is still preflop. The clean setup read comes before any later action choice.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>[
        'Hero on the Button',
        'Blinds posted',
        'No board yet',
      ],
    ),
  ],
  feedbackTitle: 'Setup locked in.',
  feedbackReason:
      'You read one spot, named the setup, and got one clear why back. That foundation makes later lessons move faster because later lessons keep reusing the same table-first scan.',
  table: _whatYouCanDoRunner.table.copyWith(
    toCallLabel: '',
    centerLabel: 'Hero acts next',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same scan, simpler job.',
      body:
          'Preflop means no board yet. Read Hero, blinds, pot, and who acts next. Name the setup once.',
      focusSeatIds: <String>['btn', 'sb', 'bb'],
      focusLabels: <String>['Hero acts next', 'Blinds posted', 'No board yet'],
    ),
  ],
);

final _firstTableGuideRouteRunner = _whatYouCanDoRunner.copyWith(
  lessonId: 'first_table_guide_route_roles',
  lessonTitle: 'First Table Guide',
  lessonSubtitle: 'Read one spot, answer once, and see why.',
  beatIndex: 5,
  beatCount: 5,
  phase: Act0LessonPhaseV1.review,
  caption: 'After the first loop, each tab has one clear job.',
  hint: 'Home shows what to do now. Learn shows what to study next.',
  question: 'Where do you go to fix mistakes after a miss?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'review',
      label: 'Review',
      isCorrect: true,
      preferredLabel: 'Review',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'Review fixes mistakes. Home shows what to do now, Learn shows what to study next, Practice gives extra reps, and You shows progress.',
    ),
    Act0RunnerOptionV1(
      id: 'practice',
      label: 'Practice',
      isCorrect: false,
      preferredLabel: 'Review',
      betterAnswerLabel: 'Review',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close, but one tab is sharper.',
      feedbackReason:
          'Practice gives extra reps after Learn teaches the concept. Review is where a miss gets fixed first.',
    ),
    Act0RunnerOptionV1(
      id: 'learn',
      label: 'Learn',
      isCorrect: false,
      preferredLabel: 'Review',
      betterAnswerLabel: 'Review',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more distinction.',
      feedbackReason:
          'Learn shows what to study next. Review is the tab that turns a mistake into the next repair step.',
    ),
  ],
  feedbackTitle: 'Tab jobs locked in.',
  feedbackReason:
      'Home shows what to do now, Learn shows what to study next, Practice gives extra reps, Review fixes mistakes, and You shows progress.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Know the five jobs.',
      body:
          'Home shows what to do now. Learn shows what to study next. Practice gives extra reps. Review fixes mistakes. You shows progress and settings.',
      focusLabels: <String>['Home', 'Learn', 'Practice', 'Review', 'You'],
    ),
  ],
);

final _boardCountRunner = _readBoardRunner.copyWith(
  lessonId: 'board_count',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'A full board has five shared cards.',
  hint: 'Flop 3, turn 4, river 5.',
  question: 'How many board cards can be visible by the river?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: true,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'The river completes five shared board cards.',
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'Two is your private card count, not the full board.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(centerLabel: 'Five board cards'),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board count grows by street.',
      body: 'Flop shows 3, turn shows 4, and river shows 5.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'board_3',
        'board_4',
      ],
      focusLabels: <String>['3 -> 4 -> 5'],
    ),
  ],
);

final _bestFiveCardsRunner = _riverBoardRunner.copyWith(
  lessonId: 'best_five_cards',
  lessonTitle: 'Cards, ranks & suits',
  caption: 'A poker hand uses the best five cards available.',
  hint: 'Use your private cards and the shared board together.',
  question: 'How many cards make your final hand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: true,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pause on big nodes.',
      feedbackReason: 'Your final poker hand is the best five cards.',
    ),
    Act0RunnerOptionV1(
      id: 'seven',
      label: 'Seven',
      isCorrect: false,
      preferredLabel: 'Five',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'You may see seven cards, but only five form the hand.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_3',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seven seen, five count.',
      body: 'Two private cards plus five board cards are available.',
      focusLabels: <String>['Choose best five'],
    ),
  ],
);

final _cardsRecapRunner = _bestFiveCardsRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'cards_recap',
  caption: 'Lesson learned: cards have a job.',
  hint: 'Ranks compare strength, suits make flushes, board cards are shared.',
  question: 'What do board cards mean?',
  feedbackTitle: 'Card takeaway.',
  feedbackReason:
      'You hold two private cards, share the board, and make the best five-card hand.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Card takeaway.',
      body:
          'Rank compares height. Suit groups cards, and board cards are shared.',
      focusLabels: <String>['Rank', 'Suit', 'Board'],
    ),
  ],
);

final _actionTrailRunner = _riverBoardRunner.copyWith(
  lessonId: 'action_trail',
  lessonTitle: 'Your first hand, dealt',
  caption: 'The action history records what happened street by street.',
  hint: 'Read it left to right.',
  question: 'Which previous action happened last?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb_check',
      label: 'Flop: BB checks',
      isCorrect: true,
      preferredLabel: 'Flop: BB checks',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Right timeline.',
      feedbackReason:
          'The last action in the history is the newest one, so Flop: BB checks comes after the blind posts and preflop action.',
    ),
    Act0RunnerOptionV1(
      id: 'sb_post',
      label: 'SB blind posted',
      isCorrect: false,
      preferredLabel: 'Flop: BB checks',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'Posting blinds happened before the hand developed.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'Flop: BB checks'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Action history shows the hand.',
      body: 'Read left to right to see what already happened.',
      focusLabels: <String>['Oldest -> newest'],
    ),
  ],
);

final _streetOrderRecapRunner = _riverBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'street_order_recap',
  lessonTitle: 'Your first hand, dealt',
  caption: 'Lesson learned: streets tell time.',
  hint: 'Preflop has no board, then flop 3, turn 4, river 5.',
  question: 'Which street comes after the turn?',
  feedbackTitle: 'Street takeaway.',
  feedbackReason:
      'A hand moves forward street by street. The action history records what already happened.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'river',
      label: 'River',
      isCorrect: true,
      preferredLabel: 'River',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct order.',
      feedbackReason:
          'A hand moves preflop, flop, turn, then river. The river comes right after the turn.',
    ),
    Act0RunnerOptionV1(
      id: 'flop',
      label: 'Flop',
      isCorrect: false,
      preferredLabel: 'River',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'The flop comes before the turn.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Street order never skips.',
      body: 'Preflop comes first, then flop, turn, and river.',
      focusLabels: <String>['Preflop', 'Flop', 'Turn', 'River'],
    ),
  ],
);

final _actionWordsRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'action_words',
  caption: 'Four action words matter first: fold, check, call, raise.',
  hint: 'The table state tells which actions are legal.',
  question: 'Which action adds more chips first in?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Actions are table verbs.',
      body:
          'Fold exits and check waits. Call matches the price, and raise adds more.',
      focusLabels: <String>['Fold', 'Check', 'Call', 'Raise'],
    ),
  ],
);

final _legalActionRunner = _checkActionRunner.copyWith(
  lessonId: 'legal_actions',
  caption: 'Legal actions depend on whether a bet is facing you.',
  hint: 'No bet means check is available; facing a bet means call or fold.',
  question: 'No bet faces you. Which action is legal and free?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Legality depends on price.',
      body: 'No price means check is available. A price unlocks call.',
      focusLabels: <String>['No bet', 'Check'],
    ),
  ],
);

final _actionRecapRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'action_recap',
  caption: 'Lesson learned: action words depend on price.',
  hint: 'No bet allows check. Facing a bet creates fold, call, or raise.',
  question: 'First in on the Button. What is cleaner than limping?',
  feedbackTitle: 'Action takeaway.',
  feedbackReason:
      'Check is free, fold exits, call matches the price, and raise adds more.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Action takeaway.',
      body: 'First read the price. Then choose the matching action family.',
      focusLabels: <String>['Price first'],
    ),
  ],
);

final _bigBlindPostRunner = _tableObjectsRunner.copyWith(
  lessonId: 'big_blind_post',
  lessonTitle: 'Blinds & action order',
  caption: 'BB sets the 1 BB baseline for the hand.',
  hint: 'Later prices like 3 BB count from this post.',
  question: 'Tap the blind that sets the 1 BB baseline.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Right baseline.',
      feedbackReason:
          'BB posts the full 1 BB blind, so later prices count from that baseline.',
    ),
    Act0RunnerOptionV1(
      id: 'sb',
      label: 'SB',
      seatId: 'sb',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not the baseline.',
      feedbackReason:
          'SB posts only 0.5 BB. BB is the full 1 BB post players count from.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'BB is the 1 BB baseline.',
      body:
          'Find the seat marked BB, because later prices like 3 BB count from that 1 BB post.',
      focusSeatIds: <String>['bb'],
      focusLabels: <String>['1 BB baseline', 'Count from BB'],
    ),
  ],
);

final _buttonMovesRunner = _buttonSeatRunner.copyWith(
  lessonId: 'button_moves',
  lessonTitle: 'Blinds & action order',
  caption: 'The Button moves one seat after each hand.',
  hint: 'That keeps blinds and late position rotating.',
  question: 'Which marker shows the dealer button this hand?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Button rotates.',
      body: 'After each hand, the button moves so blinds rotate too.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['D marker'],
    ),
  ],
);

final _blindsOrderRecapRunner = _lastPreflopActorRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'blinds_order_recap',
  caption: 'Lesson learned: blinds start the order.',
  hint: 'SB posts 0.5, BB posts 1, then action begins around the table.',
  question: 'Who acts first preflop?',
  feedbackTitle: 'Order takeaway.',
  feedbackReason:
      'Preflop starts left of the big blind. After the flop, action starts left of the Button.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Order takeaway.',
      body: 'Blinds post first. Then each street follows the table order.',
      focusSeatIds: <String>['sb', 'bb', 'utg'],
      focusLabels: <String>['Post', 'Act'],
    ),
  ],
);

final _cutoffSeatRunner = _meetTableRunner.copyWith(
  lessonId: 'cutoff_seat',
  lessonTitle: 'The 6 positions',
  caption: 'CO means cutoff. It is one seat before the Button.',
  hint: 'Tap CO.',
  question: 'Tap the cutoff.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'co',
      label: 'CO',
      seatId: 'co',
      isCorrect: true,
      preferredLabel: 'CO',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Evidence beats respect.',
      feedbackReason: 'CO is the cutoff seat before the Button.',
    ),
    Act0RunnerOptionV1(
      id: 'hj',
      label: 'HJ',
      seatId: 'hj',
      isCorrect: false,
      preferredLabel: 'CO',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'HJ is before CO in the six-seat order.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    selectableSeatIds: const <String>['co', 'hj'],
    highlightedSeatIds: const <String>['co'],
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'CO is before BTN.',
      body: 'Cutoff is the seat immediately before the Button.',
      focusSeatIds: <String>['co', 'btn'],
      focusLabels: <String>['CO -> BTN'],
    ),
  ],
);

final _earlyLatePositionRunner = _latePositionRunner.copyWith(
  lessonId: 'early_late_position',
  caption: 'Early seats act with less information than late seats.',
  hint: 'UTG is early. BTN is late.',
  question: 'Which seat is early preflop?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason: 'UTG is the early preflop seat.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'BTN is late and usually has more information.',
    ),
  ],
  table: _latePositionRunner.table.copyWith(
    selectableSeatIds: const <String>['btn', 'utg'],
    highlightedSeatIds: const <String>['utg'],
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Early seats decide sooner.',
      body: 'UTG acts before seeing what most players will do.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

final _positionsRecapRunner = _positionsRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'positions_recap',
  caption: 'Lesson learned: position changes information.',
  hint: 'Early seats decide sooner. Late seats see more before acting.',
  question: 'Which seat is latest after the flop here?',
  feedbackTitle: 'Position takeaway.',
  feedbackReason:
      'The six names are UTG, HJ, CO, BTN, SB, and BB. BTN is the clearest late seat.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position takeaway.',
      body: 'Seat name tells when you act and how much you can observe.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Sooner', 'Later'],
    ),
  ],
);

final _tripsRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'trips_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'Trips and sets are three cards of one rank.',
  hint: 'Three of a kind beats two pair.',
  question: 'Which hand ranks higher?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'trips',
      label: 'Trips',
      isCorrect: true,
      preferredLabel: 'Trips',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'Three of a kind ranks above two pair.',
    ),
    Act0RunnerOptionV1(
      id: 'two_pair',
      label: 'Two pair',
      isCorrect: false,
      preferredLabel: 'Trips',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'Two pair is below three of a kind.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    boardCards: _boardThreeQueens,
    highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroQqCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _opponentJd7hCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Three of a kind is above two pair.',
      body: 'Three cards of one rank beat two separate pairs.',
      focusLabels: <String>['Three of a kind'],
    ),
  ],
);

final _straightRankRunner = _riverBoardRunner.copyWith(
  lessonId: 'straight_rank',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'A straight is five ranks in a row.',
  hint: 'Example: 5, 6, 7, 8, 9.',
  question: 'What makes a straight?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five_in_row',
      label: 'Five in a row',
      isCorrect: true,
      preferredLabel: 'Five in a row',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason: 'A straight uses five ranks in sequence.',
    ),
    Act0RunnerOptionV1(
      id: 'same_suit',
      label: 'Same suit',
      isCorrect: false,
      preferredLabel: 'Five in a row',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Same suit makes a flush, not a straight.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _hero89Cards,
    boardCards: _boardStraight,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'hero_0',
      'hero_1',
    ],
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _hero89Cards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Straight means sequence.',
      body: 'A straight is five ranks in a row, not five of one suit.',
      focusLabels: <String>['5 ranks in order'],
    ),
  ],
);

final _bestFiveShowdownRunner = _bestFiveCardsRunner.copyWith(
  lessonId: 'best_five_showdown',
  lessonTitle: 'Hand rankings, on the table',
  caption: 'At showdown, compare each player best five cards.',
  hint: 'Unused extra cards do not count.',
  question: 'How many cards count at showdown?',
  table: _bestFiveCardsRunner.table.copyWith(
    heroCards: _heroA7oCards,
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
      'board_3',
    ],
    centerLabel: 'Best five: A A 7 7 J',
    seats: _bestFiveCardsRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroA7oCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Extra cards are ignored.',
      body:
          'Here the best five are A, A, 7, 7, and J. The 4 is still visible on the board, but it does not play because only the strongest five cards count.',
      focusCardIds: <String>[
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_3',
      ],
      focusLabels: <String>['Best five', 'Unused card'],
    ),
  ],
);

final _rankingRecapRunner = _flushRankRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'ranking_recap',
  caption: 'Lesson learned: compare the best five.',
  hint: 'Pair, two pair, trips, straight, and flush are the first ladder.',
  question: 'Which ranks higher: flush or straight?',
  feedbackTitle: 'Ranking takeaway.',
  feedbackReason:
      'Only the best five cards count. A flush ranks above a straight.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Ranking takeaway.',
      body: 'First identify the hand type, then compare the ladder.',
      focusLabels: <String>['Pair', 'Straight', 'Flush'],
    ),
  ],
);

final _boardPlaysRunner = _riverBoardRunner.copyWith(
  lessonId: 'board_plays',
  lessonTitle: 'Showdown & winning',
  caption: 'Sometimes the best five cards are all on the board.',
  hint: 'Then both players may play the board.',
  question: 'If both players use the same board, what can happen?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tie',
      label: 'Tie',
      isCorrect: true,
      preferredLabel: 'Tie',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'If the same five cards play, the pot can be split.',
    ),
    Act0RunnerOptionV1(
      id: 'seat_wins',
      label: 'BTN wins',
      isCorrect: false,
      preferredLabel: 'Tie',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'Seat position does not win when the same hand plays.',
    ),
  ],
  table: _riverBoardRunner.table.copyWith(
    heroCards: _heroQcQdCards,
    boardCards: _boardBroadwayCards,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'board_3',
      'board_4',
    ],
    seats: _riverBoardRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _heroQcQdCards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                )
              : seat.seatId == 'co'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: _villainK4Cards,
                  cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  isActive: true,
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Sometimes the board plays.',
      body:
          'Hero and CO both use the same A-K-Q-J-T straight from the board here, so private cards do not improve either player.',
      focusCardIds: <String>[
        'board_0',
        'board_1',
        'board_2',
        'board_3',
        'board_4',
      ],
      focusLabels: <String>['Same best five'],
    ),
  ],
);

final _tiePotRunner = _boardPlaysRunner.copyWith(
  lessonId: 'tie_pot',
  caption: 'A tie means the pot is split.',
  hint: 'This can happen when the same best five cards play.',
  question: 'What happens to the pot on a tie?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'split',
      label: 'Split',
      isCorrect: true,
      preferredLabel: 'Split',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: 'A tied pot is split between tied players.',
    ),
    Act0RunnerOptionV1(
      id: 'first_seat',
      label: 'First seat wins',
      isCorrect: false,
      preferredLabel: 'Split',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'Acting order does not break a tied hand.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Split means share.',
      body:
          'Hero and CO share the same best five-card straight from the board, so they split the pot.',
      focusLabels: <String>['Split pot'],
    ),
  ],
);

final _worldOneCheckpointRunner = _showdownBestHandRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'world_one_checkpoint',
  lessonTitle: 'Showdown & winning',
  caption: 'Lesson learned: now you can follow a hand.',
  hint:
      'Next, you will sort starting hands into buckets before deciding to continue.',
  question: 'What wins at showdown?',
  feedbackTitle: 'World 1 takeaway.',
  feedbackReason:
      'You can now read table flow and showdown. The next skill is preflop hand buckets: premium, strong, medium, and trash.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 1 checkpoint.',
      body:
          'Read table flow first, then sort the starting hand into the right bucket.',
      focusLabels: <String>['Table', 'Action', 'Showdown', 'Bucket next'],
    ),
  ],
);

final _world2ShowdownIntroRunner = _showdownBestHandRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_showdown_intro',
  lessonTitle: 'Which hand wins?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'World 2 starts by comparing real showdowns.',
  hint: 'Do not guess by seat. Compare the hand that reaches showdown.',
  question: 'What decides this showdown?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the hands.',
      body: 'At showdown, the strongest best-five hand wins the pot.',
      focusLabels: <String>['Showdown', 'Best hand'],
    ),
  ],
);

final _world2ShowdownRecapRunner = _showdownBestHandRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_showdown_recap',
  lessonTitle: 'Which hand wins?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: compare hand strength first.',
  hint: 'Seat, stack, and action do not beat the best hand at showdown.',
  question: 'What is the first showdown question?',
  feedbackTitle: 'Showdown takeaway.',
  feedbackReason:
      'At showdown, compare each player best five-card hand before thinking about seat or action.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown checklist.',
      body: 'Name the hand type, compare kickers if needed, then award pot.',
      focusLabels: <String>['Hand type', 'Kicker', 'Pot'],
    ),
  ],
);

final _world2BestFiveIntroRunner = _bestFiveCardsRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_best_five_intro',
  lessonTitle: 'Best five cards',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'You may see seven cards, but only five count.',
  hint: 'Your best five can use private cards, board cards, or both.',
  question: 'How many cards decide your final hand?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Only five count.',
      body: 'Choose the strongest five-card hand from all available cards.',
      focusLabels: <String>['Best five'],
    ),
  ],
);

final _world2BestFiveRecapRunner = _bestFiveShowdownRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_best_five_recap',
  lessonTitle: 'Best five cards',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: extra cards are only helpers.',
  hint: 'Compare the final five, not every card you can see.',
  question: 'What counts at showdown?',
  feedbackTitle: 'Best-five takeaway.',
  feedbackReason:
      'A player can see up to seven cards, but showdown uses only the strongest five-card hand.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Best-five checklist.',
      body: 'Build the best five, ignore unused cards, then compare.',
      focusLabels: <String>['Build', 'Ignore extra', 'Compare'],
    ),
  ],
);

final _world2KickerIntroRunner = _showdownKickerRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_kicker_intro',
  lessonTitle: 'Kicker decides',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'A kicker is the side card that can break a tie.',
  hint: 'It matters only when the main hand is otherwise close.',
  question: 'When can a kicker matter?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Side cards can decide.',
      body: 'If the main hand matches, compare the highest side card.',
      focusLabels: <String>['Same hand', 'Kicker'],
    ),
  ],
);

final _world2KickerRecapRunner = _showdownKickerRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_kicker_recap',
  lessonTitle: 'Kicker decides',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: ties need a clean tiebreak.',
  hint: 'Use kickers only when they are part of the best five.',
  question: 'What breaks some matching-hand ties?',
  feedbackTitle: 'Kicker takeaway.',
  feedbackReason:
      'When two players share the same made hand, the best side card can decide the pot.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Kicker checklist.',
      body: 'Match the made hand first, then compare the best side card.',
      focusLabels: <String>['Made hand', 'Side card'],
    ),
  ],
);

final _world2BoardIntroRunner = _boardPlaysRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_board_intro',
  lessonTitle: 'Board plays',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Shared board cards can sometimes make the best hand.',
  hint:
      'If private cards do not improve, both players may share the same five.',
  question: 'What can happen when the same board plays?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The board is shared.',
      body: 'If the board makes the best five, private cards may not matter.',
      focusLabels: <String>['Shared board', 'Same five'],
    ),
  ],
);

final _world2BoardRecapRunner = _tiePotRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_board_recap',
  lessonTitle: 'Board plays',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: shared cards can split the pot.',
  hint: 'A tie is normal when both players use the same best five.',
  question: 'What happens when both players tie?',
  feedbackTitle: 'Board takeaway.',
  feedbackReason:
      'When both players have the same best five-card hand, the pot is split instead of awarded by seat.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board-play checklist.',
      body: 'Check if private cards improve the board. If not, ties can split.',
      focusLabels: <String>['Private cards', 'Shared five', 'Split'],
    ),
  ],
);

final _world2PositionIntroRunner = _latePositionRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_position_intro',
  lessonTitle: 'Position changes value',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'The same hand feels different from early and late seats.',
  hint: 'Late seats act after seeing more decisions.',
  question: 'Why can late position help?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position is information.',
      body: 'Early seats decide sooner. Late seats see more before acting.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

final _world2PositionRecapRunner = _positionsRecapRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_position_recap',
  lessonTitle: 'Position changes value',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: hand value depends on seat context.',
  hint: 'A later seat usually has more information before choosing.',
  question: 'Which seat usually sees more first?',
  feedbackTitle: 'Position-value takeaway.',
  feedbackReason:
      'Hand strength is not the whole decision. Seat position changes how much information you have.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position-value checklist.',
      body: 'Name the seat, note who acts first, then compare the hand.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Seat', 'Order', 'Hand'],
    ),
  ],
);

final _world2InitiativeIntroRunner = _actionTrailRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_initiative_intro',
  lessonTitle: 'Who has initiative?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Initiative starts with the last aggressive action.',
  hint: 'For now, track who raised or bet most recently.',
  question: 'Who usually has initiative here?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Last aggressor matters.',
      body: 'The player who last raised or bet is the aggressor for this spot.',
      focusLabels: <String>['Raise', 'Bet', 'Aggressor'],
    ),
  ],
);

final _world2InitiativeDrillRunner = _actionTrailRunner.copyWith(
  lessonId: 'w2_initiative_find',
  lessonTitle: 'Who has initiative?',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'BTN raised before the flop and BB called.',
  hint: 'The raiser, not the caller, has initiative.',
  question: 'Who has initiative?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: true,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG is the early seat.',
      feedbackReason: 'BTN made the aggressive raise. BB only called.',
    ),
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: false,
      preferredLabel: 'BTN',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Calling continues the hand, but the raise gives BTN initiative.',
    ),
  ],
  table: _actionTrailRunner.table.copyWith(
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
    selectableSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Raise beats call for initiative.',
      body: 'BTN raised. BB called. Track the last aggressive action.',
      focusSeatIds: <String>['btn', 'bb'],
      focusLabels: <String>['BTN raises', 'BB calls'],
    ),
  ],
);

final _world2InitiativeActiveRunner = _world2InitiativeDrillRunner.copyWith(
  lessonId: 'w2_initiative_active',
  caption: 'Now action is on BB after BTN showed aggression.',
  hint:
      'Active seat is who must decide now; initiative is who applied pressure.',
  question: 'Who must act now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb',
      label: 'BB',
      seatId: 'bb',
      isCorrect: true,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'BB is active now, even though BTN has initiative.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'BTN has initiative, but BB is the active seat now.',
    ),
  ],
  table: _actionTrailRunner.table.copyWith(
    activeSeatId: 'bb',
    highlightedSeatIds: const <String>['btn', 'bb'],
    selectableSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Active seat is different.',
      body: 'Initiative says who pressured. Active seat says who acts now.',
      focusSeatIds: <String>['btn', 'bb'],
      focusLabels: <String>['Initiative', 'Active'],
    ),
  ],
);

final _world2InitiativeRecapRunner = _world2InitiativeDrillRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_initiative_recap',
  caption: 'Lesson learned: track pressure and current action separately.',
  hint: 'Aggressor applied pressure; active player chooses now.',
  question: 'What gives a player initiative?',
  feedbackTitle: 'Initiative takeaway.',
  feedbackReason:
      'A raise or bet is the simple beginner signal for initiative. The active seat is still read from the current table state.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Initiative checklist.',
      body:
          'Read the action history, find the last bet or raise, then find who acts now.',
      focusLabels: <String>['History', 'Aggressor', 'Active seat'],
    ),
  ],
);

final _world2CheckpointIntroRunner = _world2ShowdownIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_checkpoint_intro',
  lessonTitle: 'Hand value checkpoint',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Checkpoint: compare hand, position, and initiative together.',
  hint: 'Keep it simple: hand first, seat second, action history third.',
  question: 'What three checks matter here?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bridge checklist.',
      body: 'Compare the hand, name the seat, then read who applied pressure.',
      focusLabels: <String>['Hand', 'Position', 'Initiative'],
    ),
  ],
);

final _world2CheckpointRunner = _world2InitiativeDrillRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w2_checkpoint_review',
  lessonTitle: 'Hand value checkpoint',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Lesson learned: good decisions start with context.',
  hint:
      'Hand value, position, and initiative are the bridge to preflop basics.',
  question: 'What should you read before choosing?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'context',
      label: 'Hand, seat, action',
      isCorrect: true,
      preferredLabel: 'Hand, seat, action',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Read hand value, position, and initiative before moving into strategy.',
    ),
    Act0RunnerOptionV1(
      id: 'seat_only',
      label: 'Seat only',
      isCorrect: false,
      preferredLabel: 'Hand, seat, action',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'Seat matters, but it is only one part of the context.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 2 bridge.',
      body: 'You can now compare showdowns and read basic table context.',
      focusLabels: <String>['Showdown', 'Position', 'Initiative'],
    ),
  ],
);

final _world3BucketsIntroRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_buckets_intro',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Preflop starts by sorting the hand into a simple bucket.',
  hint:
      'Hand code writes the two ranks together. T means ten, s means suited, and o means offsuit.',
  question: 'What should you name before the action?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket first.',
      body:
          'Name the hand bucket before choosing open, call, or fold. Hand code writes the two ranks together: T means ten, s means suited, and o means offsuit. So KTs is king-ten suited, and J8o is jack-eight offsuit.',
      focusLabels: <String>[
        'Premium',
        'Strong',
        'Medium',
        'Trash',
        'T = Ten',
        's = Suited',
        'o = Offsuit',
      ],
    ),
  ],
);

final _world3PremiumBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w3_premium_bucket',
  caption: 'AA is a premium preflop hand.',
  hint: 'Premium hands usually want to build the pot.',
  question: 'Which bucket is AA?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'premium',
      label: 'Premium',
      isCorrect: true,
      preferredLabel: 'Premium',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'AA belongs to premium pairs and usually raises for value.',
    ),
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: false,
      preferredLabel: 'Premium',
      betterAnswerLabel: 'Premium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'AA is stronger than a medium hand.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'A', suit: 'h'),
    ],
    centerLabel: 'Premium bucket',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Premium means top bucket.',
      body: 'AA starts in the premium bucket before context changes anything.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['AA', 'Premium'],
    ),
  ],
);

final _world3TrashBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w3_trash_bucket',
  caption: 'J8o is a weak offsuit starter from early position.',
  hint: 'Weak early hands should not be forced into action.',
  question: 'Which bucket fits J8o early?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'trash',
      label: 'Trash',
      isCorrect: true,
      preferredLabel: 'Trash',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'J8o from early position belongs in the trash bucket.',
    ),
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: false,
      preferredLabel: 'Trash',
      betterAnswerLabel: 'Trash',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'Offsuit disconnected hands are not strong starters.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _whatYouCanDoRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'J', suit: 's'),
        Act0CardStateV1(rank: '8', suit: 'd'),
      ],
      centerLabel: 'Trash bucket',
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG acts'),
      ],
      highlightedSeatIds: const <String>['utg'],
      highlightedCardIds: const <String>['hero_0', 'hero_1'],
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weak and early is trouble.',
      body: 'J8o has little help, especially before seeing others act.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['J8o', 'Early'],
    ),
  ],
);

final _world3BucketsRecapRunner = _world3BucketsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_buckets_recap',
  caption: 'Lesson learned: bucket the hand before the action.',
  hint: 'Premium, strong, medium, or trash is the first preflop read.',
  question: 'What is the first preflop habit?',
  feedbackTitle: 'Bucket takeaway.',
  feedbackReason:
      'Preflop choices get calmer when you name the hand bucket before choosing open, call, or fold.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket checklist.',
      body: 'Name the hand bucket, then read position and action frame.',
      focusLabels: <String>['Bucket', 'Position', 'Frame'],
    ),
  ],
);

final _world3FirstInIntroRunner = _whatYouCanDoRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_first_in_intro',
  lessonTitle: 'First-in open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'First in means nobody has entered the pot yet.',
  hint: 'You can limp by calling the blind, but open or fold is cleaner.',
  question: 'What is cleaner than limping first in?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Unopened pot.',
      body:
          'When nobody entered, raising is called opening. Calling is limping.',
      focusLabels: <String>['Nobody entered', 'Open cleaner'],
    ),
  ],
);

final _world3ButtonOpenRunner = _whatYouCanDoRunner.copyWith(
  lessonId: 'w3_button_open',
  lessonTitle: 'First-in open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Folded to BTN with KTs.',
  hint: 'First in and late position: opening is the clean action.',
  question: 'What is the simple first-in action?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late playable hand.',
      body: 'KTs on the Button is playable when nobody entered.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KTs', 'Open'],
    ),
  ],
);

final _world3ButtonOpenQtsRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_button_open_qts',
  caption: 'Folded to BTN with QTs.',
  hint:
      'Same late seat, different playable hand, same clean open-or-fold rule.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late playable hand.',
      body: 'QTs can still open first in from the Button.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['QTs', 'Open'],
    ),
  ],
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'T', suit: 's'),
    ],
    seats: _world3ButtonOpenRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'Q', suit: 's'),
                    Act0CardStateV1(rank: 'T', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
  ),
);

final _world3CutoffOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_cutoff_open',
  caption: 'Folded to CO with AJo.',
  hint: 'Cutoff is late, but Button and blinds still remain behind.',
  question: 'What is the cleaner first-in action from CO?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'AJo can open first in from the Cutoff before only three seats remain behind.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Legal, but passive.',
      feedbackReason:
          'Calling first in is still a limp. Cutoff is late enough to open the playable hand cleanly.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3ButtonOpenRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'd'),
        Act0CardStateV1(rank: 'J', suit: 'c'),
      ],
      activeSeatId: 'co',
      highlightedSeatIds: const <String>['co', 'btn', 'sb', 'bb'],
      centerLabel: 'Folded to CO',
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ folds'),
        Act0ActionTrailItemV1(label: 'CO acts'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late, but not last.',
      body:
          'AJo can open from CO, but you still respect the Button behind you.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO', 'BTN behind', 'Open'],
    ),
  ],
);

final _world3ButtonOpenA9sRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_button_open_a9s',
  caption: 'Folded to BTN with A9s.',
  hint: 'Button still opens the playable suited ace when nobody entered.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Playable suited ace.',
      body: 'A9s can still open first in when the Button is the acting seat.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['A9s', 'Open'],
    ),
  ],
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: '9', suit: 's'),
    ],
    seats: _world3ButtonOpenRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'A', suit: 's'),
                    Act0CardStateV1(rank: '9', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
  ),
);

final _world3CutoffOpenKJsRunner = _world3CutoffOpenRunner.copyWith(
  lessonId: 'w3_cutoff_open_kjs',
  caption: 'Folded to CO with KJs.',
  hint: 'Still a late playable hand, but one seat earlier than the Button.',
  table: _act0ReassignHeroSeatV1(
    _world3CutoffOpenRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 's'),
        Act0CardStateV1(rank: 'J', suit: 's'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Cutoff still opens.',
      body:
          'KJs stays playable first in from CO, but the Button still matters.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO', 'KJs', 'Open'],
    ),
  ],
);

final _world3EarlyFoldRunner = _world3TrashBucketRunner.copyWith(
  lessonId: 'w3_early_fold',
  lessonTitle: 'First-in open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Unopened pot. Hero is early with J8o.',
  hint: 'Early position removes the comfort from weak offsuit hands.',
  question: 'What is the clean action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason: 'Weak offsuit hands from early position can simply fold.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Position is early and the hand bucket is too weak.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Discipline is allowed.',
      body: 'Opening weak early hands creates hard spots later.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['Early', 'Fold'],
    ),
  ],
);

final _world3FirstInRecapRunner = _world3ButtonOpenRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_first_in_recap',
  caption: 'Lesson learned: first in means open or fold.',
  hint: 'Calling the blind is a limp; it is legal, but not the clean default.',
  question: 'What is the passive first-in action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Calling first in is limping. It is legal, but usually weaker than a clean open-or-fold habit.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'Folding is legal first in. Calling is the passive limp this question asks for.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'First-in takeaway.',
      body: 'Unopened pots ask whether to open or let the hand go.',
      focusLabels: <String>['Open', 'Fold', 'Limp passive'],
    ),
  ],
);

final _world3FacingOpenIntroRunner = _world3FirstInIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_facing_open_intro',
  lessonTitle: 'Facing an open',
  caption: 'Facing an open means someone raised before you.',
  hint: 'Now calling can exist, and weak continues can fold.',
  question: 'What changed from first in?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'The frame changed.',
      body: 'An opener created a price. Now call or fold can be natural.',
      focusLabels: <String>['Facing open', 'Price'],
    ),
  ],
);

final _world3PlayableCallRunner = _callActionRunner.copyWith(
  lessonId: 'w3_playable_call',
  lessonTitle: 'Facing an open',
  lessonSubtitle: 'Preflop Basics',
  caption: 'CO opened. Hero is BTN with KQo.',
  hint: 'Playable hand in position: call keeps the hand in.',
  question: 'What is the simple response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'BTN versus a CO open, KQo can continue in position. For this beginner baseline, call is the simple continue.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'Folding is too tight here. BTN versus a CO open, KQo can continue in position.',
    ),
  ],
  table: _callActionRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
    boardCards: const <Act0CardStateV1>[],
    streetLabel: 'Preflop',
    potLabel: 'Pot 4 BB',
    toCallLabel: 'To call 2.5 BB',
    centerLabel: 'CO opened',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['co', 'btn'],
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        bet: _coOpen25Bb,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroKqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Playable and in position.',
      body: 'KQo can call a simple open when hero acts after CO.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO opens', 'BTN calls'],
    ),
  ],
);

final _world2StrongContinueRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w2_strong_continue_kqo',
  caption: 'HJ opened. Hero is BTN with KQo.',
  hint:
      'Broadway cards are T, J, Q, K, and A. One seat earlier from the opener still leaves hero in position with a playable broadway.',
  question: 'What is the simple continue?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'BTN versus an HJ open, KQo can still continue in position. For this beginner baseline, call is the simple continue.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'Folding is still too tight. KQo keeps enough strength and position against an HJ open.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    centerLabel: 'HJ opened',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'HJ opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    highlightedSeatIds: const <String>['hj', 'btn'],
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Hijack',
        bet: _hjOpen25Bb,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroKqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Playable broadway, tighter opener.',
      body:
          'KQo is a broadway hand because both cards are broadway ranks. It still continues in position, but the opener seat is one step tighter now.',
      focusSeatIds: <String>['hj', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Broadway = T J Q K A', 'HJ opens', 'BTN calls'],
    ),
  ],
);

final _world2KqoContrastRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w2_kqo_contrast',
  caption: 'CO opened. Hero is BTN with KQo instead of A7o.',
  hint: 'Same seat, different hand class, much less domination risk.',
  question: 'Why is KQo the cleaner continue?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'less_dominated',
      label: 'It keeps position and avoids weak-ace domination',
      isCorrect: true,
      preferredLabel: 'It keeps position and avoids weak-ace domination',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong contrast read.',
      feedbackReason:
          'KQo still plays in position, and it is not trapped by stronger aces the way A7o is.',
    ),
    Act0RunnerOptionV1(
      id: 'two_big_cards_auto',
      label: 'Two broadway cards always continue after an open',
      isCorrect: false,
      preferredLabel: 'It keeps position and avoids weak-ace domination',
      betterAnswerLabel: 'It keeps position and avoids weak-ace domination',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The clean reason is not auto-continue. It is the mix of position and lower domination risk.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Compare the hand class.',
      body:
          'KQo still has broadway strength, while A7o runs into stronger aces too often.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KQo', 'Less domination'],
    ),
  ],
);

final _world2BorderlineContinueRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w2_borderline_continue_qjs',
  caption: 'CO opened. Hero is BTN with QJs.',
  hint:
      'Playable suited broadways can continue, but the reason is still seat plus hand class.',
  question: 'What is the simple continue?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'BTN versus a CO open, QJs can continue in position. For this beginner baseline, call is the simple continue.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A bit too tight.',
      feedbackReason:
          'QJs keeps enough playability in position here, so folding gives up a workable continue.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world3PlayableCallRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'Q', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
    centerLabel: 'Playable broadway',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Borderline but playable.',
      body:
          'QJs still continues from the Button because position and playability line up cleanly.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['QJs', 'Button', 'Call'],
    ),
  ],
);

final _world3CutoffCallRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w3_cutoff_call_kqo',
  caption: 'HJ opened. Hero is CO with KQo.',
  hint: 'Same hand, one seat earlier, still facing an opener.',
  question: 'What is the cleaner response from CO?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong frame read.',
      feedbackReason:
          'KQo can still continue from CO, but the seat is less comfortable than BTN because one more strong seat stays behind.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A bit too cautious.',
      feedbackReason:
          'The seat is tighter than BTN, but KQo still has enough strength to continue facing one HJ open.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world2StrongContinueRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'd'),
        Act0CardStateV1(rank: 'Q', suit: 'c'),
      ],
      activeSeatId: 'co',
      highlightedSeatIds: const <String>['hj', 'co'],
      centerLabel: 'HJ opened',
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'HJ opens 2.5 BB'),
        Act0ActionTrailItemV1(label: 'CO acts'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, tighter seat.',
      body:
          'KQo still continues here, but one earlier seat makes the call a little less comfortable.',
      focusSeatIds: <String>['hj', 'co'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['CO', 'KQo', 'Call'],
    ),
  ],
);

final _world3WeakFacingFoldPressureRunner = _world3WeakFacingFoldRunner
    .copyWith(
      lessonId: 'w3_weak_facing_fold_pressure',
      hint: 'Late position adds comfort, not permission.',
      question: 'What does discipline say here?',
      teachingSteps: const <Act0TeachingStepV1>[
        Act0TeachingStepV1(
          title: 'Comfort is not a rescue.',
          body:
              'J8o stays too weak even when the Button acts after the opener.',
          focusSeatIds: <String>['btn'],
          focusCardIds: <String>['hero_0', 'hero_1'],
          focusLabels: <String>['J8o', 'Still fold'],
        ),
      ],
    );

final _world3PositionCheckpointCallRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w3_position_btn_call_kjs',
  caption: 'HJ opened. Hero is BTN with KJs.',
  hint: 'Late position helps when the hand can still continue cleanly.',
  question: 'What is the simple response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'BTN versus an HJ open, KJs can continue in position. For this beginner baseline, call is the simple continue.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'KJs keeps enough strength and position here, so folding gives up a workable continue.',
    ),
  ],
  table: _world2StrongContinueRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world2StrongContinueRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'K', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
    centerLabel: 'HJ opens, BTN decides',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seat plus hand class.',
      body:
          'KJs is not just late-position noise. The hand still needs enough playability to continue cleanly.',
      focusSeatIds: <String>['hj', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['HJ opens', 'BTN', 'KJs'],
    ),
  ],
);

final _world4CallFrameRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w4_call_frame_ajs',
  caption: 'CO opened. Hero is BTN with AJs.',
  hint:
      'Facing an open, late position can still continue with the stronger broadway hand.',
  question: 'What is the simple call-frame action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Frame read first.',
      feedbackReason:
          'Once CO opened, AJs on the Button fits the call frame. For this beginner baseline, call is the simple continue.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too tight for the frame.',
      feedbackReason:
          'AJs keeps both strength and position here, so the cleaner frame is continue rather than fold.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world3PlayableCallRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'A', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
    centerLabel: 'Facing a CO open',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Call frame, not open frame.',
      body:
          'Once someone opened, AJs does not ask whether to open first in anymore.',
      focusSeatIds: <String>['co', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Open already happened', 'Call frame'],
    ),
  ],
);

final _world4SameHandCallRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w4_same_hand_call_qjs',
  caption: 'HJ opened. Hero is BTN with QJs.',
  hint: 'Same frame family, different opener seat and different playable hand.',
  question: 'What is the cleaner continue here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean frame read.',
      feedbackReason:
          'QJs still continues in position here, but you still start from seat plus frame before clicking call.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'A bit too cautious.',
      feedbackReason:
          'The frame changed because HJ opened first, but QJs on the Button still has enough playability to continue.',
    ),
  ],
  table: _world2StrongContinueRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    seats: _world2StrongContinueRunner.table.seats
        .map(
          (seat) => seat.seatId == 'btn'
              ? _act0CopySeatStateV1(
                  seat,
                  holeCards: const <Act0CardStateV1>[
                    Act0CardStateV1(rank: 'Q', suit: 's'),
                    Act0CardStateV1(rank: 'J', suit: 's'),
                  ],
                )
              : seat,
        )
        .toList(growable: false),
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame first, then hand comfort.',
      body:
          'Same facing-open family, but the specific opener seat and hand class still matter.',
      focusSeatIds: <String>['hj', 'btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['HJ opens', 'QJs', 'Call'],
    ),
  ],
);

final _world3WeakFacingFoldRunner = _world3PlayableCallRunner.copyWith(
  lessonId: 'w3_weak_facing_fold',
  caption: 'CO opened. Hero is BTN with J8o.',
  hint: 'Position helps, but this hand is still too weak to continue.',
  question: 'What is the clean response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'BTN is the late seat.',
      feedbackReason:
          'BTN versus a CO open, J8o is still too weak to continue.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Late position helps, but J8o is still too weak versus a CO open.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd'),
    ],
    centerLabel: 'Weak continue?',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position is not a free pass.',
      body: 'J8o still folds when the hand bucket is too weak.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Weak bucket', 'Fold'],
    ),
  ],
);

final _world3FacingOpenRecapRunner = _world3PlayableCallRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_facing_open_recap',
  caption: 'Lesson learned: facing an open creates a price.',
  hint: 'Playable hands can call; weak hands can still fold.',
  question: 'What did the opener create?',
  feedbackTitle: 'Facing-open takeaway.',
  feedbackReason:
      'Once someone opens, your first preflop read changes from open-or-fold to continue-or-fold.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Facing-open checklist.',
      body: 'Read the hand bucket, your position, and the price.',
      focusLabels: <String>['Bucket', 'Position', 'Price'],
    ),
  ],
);

final _world3PositionIntroRunner = _world2PositionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_position_intro',
  lessonTitle: 'Position preflop',
  lessonSubtitle: 'Preflop Basics',
  caption: 'Position changes how comfortable a preflop hand is.',
  hint: 'Late position helps more than early position.',
  question: 'What does position change?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position modifies the bucket.',
      body:
          'Late position can upgrade comfort. Early position demands discipline.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early', 'Late'],
    ),
  ],
);

final _world3LateOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w3_late_position_open',
  lessonTitle: 'Position preflop',
  caption: 'Unopened pot. Hero is late with ATo.',
  hint: 'Late position supports a clean open with this playable hand.',
  question: 'What is the simple action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'ATo in late position can open an unopened pot.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Limp is legal, raise is stronger.',
      feedbackReason:
          'Limping ATo is legal, but raising takes advantage of late position and puts pressure on the blinds.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'd'),
      Act0CardStateV1(rank: 'T', suit: 'c'),
    ],
    centerLabel: 'Unopened pot',
  ),
);

final _world3PositionDisciplineRunner = _world3EarlyFoldRunner.copyWith(
  lessonId: 'w3_position_not_free_pass',
  lessonTitle: 'Position preflop',
  caption: 'Unopened pot. Hero is early with ATo.',
  hint: 'The same hand is less comfortable from early position.',
  question: 'What is the disciplined action?',
  table: _act0ReassignHeroSeatV1(
    _world3EarlyFoldRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'd'),
        Act0CardStateV1(rank: 'T', suit: 'c'),
      ],
      centerLabel: 'Early position',
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, worse seat.',
      body: 'Early position can turn a close hand into a fold.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['ATo', 'Early'],
    ),
  ],
);

final _world3HijDisciplineRunner = _world3PositionDisciplineRunner.copyWith(
  lessonId: 'w3_hj_discipline_hold',
  caption: 'Unopened pot. Hero is HJ with KTo.',
  hint:
      'Middle position still needs discipline when the offsuit hand gets loose.',
  table: _act0ReassignHeroSeatV1(
    _world3PositionDisciplineRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'K', suit: 'd'),
        Act0CardStateV1(rank: 'T', suit: 'c'),
      ],
      centerLabel: 'Middle position',
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
        Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ acts'),
      ],
    ),
    heroSeatId: 'hj',
    activeSeatId: 'hj',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Middle still needs discipline.',
      body:
          'KTo from HJ is still too loose to auto-open just because UTG folded first.',
      focusSeatIds: <String>['hj'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KTo', 'HJ', 'Fold'],
    ),
  ],
);

final _world3CheckpointEarlyFoldRunner = _world3PositionDisciplineRunner.copyWith(
  lessonId: 'w3_checkpoint_early_fold_a9o',
  caption: 'Unopened pot. Hero is UTG with A9o.',
  hint: 'A tempting ace still needs an early-seat discipline check.',
  table: _act0ReassignHeroSeatV1(
    _world3PositionDisciplineRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'c'),
        Act0CardStateV1(rank: '9', suit: 'd'),
      ],
      centerLabel: 'UTG discipline',
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Tempting ace, same discipline.',
      body:
          'A9o still needs the early-seat fold because the seat is too exposed for a thin open.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['A9o', 'UTG', 'Fold'],
    ),
  ],
);

final _w3LateSeatContrastRunner = _latePositionRunner.copyWith(
  lessonId: 'w3_late_seat_contrast',
  caption: 'CO is late, but BTN still acts after CO.',
  hint: 'Compare the two latest seats directly.',
  question: 'Which seat is later than CO?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late has levels.',
      body:
          'Cutoff is late, but Button still gets the final late-position edge.',
      focusSeatIds: <String>['co', 'btn'],
      focusLabels: <String>['CO', 'BTN'],
    ),
  ],
);

final _w3LateInfoEdgeRunner = _latePositionRunner.copyWith(
  lessonId: 'w3_late_info_edge',
  caption: 'CO already saw UTG and HJ fold before acting.',
  hint: 'Late comfort comes from fewer players left to act.',
  question: 'What gives CO more comfort than UTG here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fewer_behind',
      label: 'Fewer players still act after CO',
      isCorrect: true,
      preferredLabel: 'Fewer players still act after CO',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'That is the late-position edge: more information first, fewer players left to respond after you.',
    ),
    Act0RunnerOptionV1(
      id: 'always_last',
      label: 'CO already acts last every street',
      isCorrect: false,
      preferredLabel: 'Fewer players still act after CO',
      betterAnswerLabel: 'Fewer players still act after CO',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'CO is late, but BTN and the blinds still remain. The real edge is fewer players behind than UTG faces.',
    ),
  ],
  table: _latePositionRunner.table.copyWith(
    highlightedSeatIds: const <String>['co', 'btn', 'sb', 'bb'],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ folds'),
      Act0ActionTrailItemV1(label: 'CO acts'),
    ],
    centerLabel: 'CO after two folds',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Late edge is practical.',
      body:
          'Seeing two folds before CO acts is already more information than UTG gets.',
      focusSeatIds: <String>['co', 'btn'],
      focusLabels: <String>['Two folds seen', 'Players behind'],
    ),
  ],
);

final _w3SeatOrderDecisionRunner = _earlyLatePositionRunner.copyWith(
  lessonId: 'w3_seat_order_decision',
  caption: 'UTG and BTN are visible. One acts before the other preflop.',
  hint: 'Earlier seats get less information first.',
  question: 'Which seat acts before BTN?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Order matters before comfort.',
      body: 'UTG acts before BTN.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['UTG first', 'BTN later'],
    ),
    Act0TeachingStepV1(
      title: 'Information arrives later.',
      body: 'BTN can use more late-position information.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['BTN sees more'],
    ),
  ],
);

final _w3EarlyLateOrderRepairRunner = _earlyLatePositionRunner.copyWith(
  lessonId: 'w3_repair_early_late_order',
  caption: 'Repair: compare early and late seats on this six-seat table.',
  hint: 'UTG acts sooner. BTN sees more first.',
  question: 'Which seat acts earlier on this six-seat table?',
  feedbackTitle: 'Early-late order repaired.',
  feedbackReason:
      'On this six-seat table, UTG acts sooner and BTN gets more information first.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'utg',
      label: 'UTG',
      seatId: 'utg',
      isCorrect: true,
      preferredLabel: 'UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Early-late order repaired.',
      feedbackReason:
          'UTG acts earlier on this six-seat table, before BTN gets to use late information.',
    ),
    Act0RunnerOptionV1(
      id: 'btn',
      label: 'BTN',
      seatId: 'btn',
      isCorrect: false,
      preferredLabel: 'UTG',
      betterAnswerLabel: 'UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good spot to repair.',
      feedbackReason:
          'BTN is later on this table. The missed signal is that UTG acts sooner.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the order read.',
      body:
          'On this six-seat table, UTG is early and acts sooner; BTN is late and sees more first.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['UTG early', 'BTN late'],
    ),
  ],
);

final _w3EarlySeatPressureRunner = _earlyLatePositionRunner.copyWith(
  lessonId: 'w3_early_pressure',
  caption: 'UTG must act before HJ, CO, BTN, SB, and BB.',
  hint: 'More players behind means more pressure on the opening range.',
  question: 'Why does UTG need more discipline here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_players_behind',
      label: 'Five players still act after UTG',
      isCorrect: true,
      preferredLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'That is the early-seat problem. More players still act, so weak opens get punished more often.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_btn',
      label: 'UTG gets the same information as BTN',
      isCorrect: false,
      preferredLabel: 'Five players still act after UTG',
      betterAnswerLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'BTN is later and sees much more first. UTG is pressured because almost everyone still acts after it.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Early means pressure first.',
      body:
          'UTG faces the most unseen decisions behind, so discipline starts there.',
      focusSeatIds: <String>['utg'],
      focusLabels: <String>['UTG', 'Five behind'],
    ),
  ],
);

final _w3UtgPlayersBehindRepairRunner = _w3EarlySeatPressureRunner.copyWith(
  lessonId: 'w3_repair_utg_players_behind',
  caption: 'Repair: UTG has five players behind.',
  hint: 'Count who still acts after UTG.',
  question: 'Why is UTG under pressure here?',
  feedbackTitle: 'UTG pressure repaired.',
  feedbackReason:
      'Five players still act after UTG, so early seats need extra discipline.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five_players_behind',
      label: 'Five players still act after UTG',
      isCorrect: true,
      preferredLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG pressure repaired.',
      feedbackReason:
          'Five players still act after UTG, so the seat has less information.',
    ),
    Act0RunnerOptionV1(
      id: 'utg_has_late_info',
      label: 'UTG already has late-position information',
      isCorrect: false,
      preferredLabel: 'Five players still act after UTG',
      betterAnswerLabel: 'Five players still act after UTG',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good spot to repair.',
      feedbackReason:
          'UTG acts before the rest of the table, so the missed signal is players behind.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair the early-seat read.',
      body: 'UTG acts first, with HJ, CO, BTN, SB, and BB still behind it.',
      focusSeatIds: <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'],
      focusLabels: <String>['UTG', 'Five players behind'],
    ),
  ],
);

final _world3PositionRecapRunner = _world3LateOpenRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_position_recap',
  caption: 'Lesson learned: position changes preflop comfort.',
  hint: 'Late helps. Early demands stronger buckets and cleaner frames.',
  question: 'What should you check after the bucket?',
  feedbackTitle: 'Position-preflop takeaway.',
  feedbackReason:
      'Preflop is not one-hand-one-answer. Position changes how confidently the hand can continue in first-in and facing-open frames.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Position checklist.',
      body: 'Bucket the hand, then ask if the seat helps or hurts.',
      focusLabels: <String>['Bucket', 'Seat'],
    ),
  ],
);

final _w3TablePositionNoticeRunner = _world3LateOpenRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w3_table_position_notice',
  caption: 'Real table. Hero is CO with QJs and three seats still act after.',
  hint: 'Before choosing an action, notice what the seat order gives you.',
  question: 'What is the clean seat read here?',
  feedbackTitle: 'Seat read first.',
  feedbackReason:
      'Count the players behind before treating the seat as comfortable.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'players_behind',
      label: 'BTN, SB, and BB still act after you',
      isCorrect: true,
      preferredLabel: 'BTN, SB, and BB still act after you',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'That is the real-table transfer. Count the players behind before treating the seat as comfortable.',
    ),
    Act0RunnerOptionV1(
      id: 'acts_last',
      label: 'You already act last',
      isCorrect: false,
      preferredLabel: 'BTN, SB, and BB still act after you',
      betterAnswerLabel: 'BTN, SB, and BB still act after you',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'Cutoff is late, but Button and the blinds still act after hero.',
    ),
    Act0RunnerOptionV1(
      id: 'late_free_pass',
      label: 'Late seat makes every hand easy',
      isCorrect: false,
      preferredLabel: 'BTN, SB, and BB still act after you',
      betterAnswerLabel: 'BTN, SB, and BB still act after you',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'Late position helps, but it is not a free pass. First notice who still acts after you.',
    ),
  ],
  table: _world3LateOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    activeSeatId: 'co',
    highlightedSeatIds: const <String>['co', 'btn', 'sb', 'bb'],
    centerLabel: 'CO with three seats behind',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ folds'),
      Act0ActionTrailItemV1(label: 'CO acts'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seat read before action.',
      body:
          'Late position helps, but Cutoff still leaves Button and the blinds behind you.',
      focusSeatIds: <String>['co', 'btn', 'sb', 'bb'],
      focusLabels: <String>['CO', 'Players behind', 'Not last to act'],
    ),
  ],
);

final _world3SameHandIntroRunner = _world3PositionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_same_hand_intro',
  lessonTitle: 'Same hand, different frame',
  caption: 'The same hand can change action when the frame changes.',
  hint: 'First in, facing open, and early position are different frames.',
  question: 'What should you re-check?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'No permanent answer.',
      body: 'Re-check bucket, seat, and whether someone already opened.',
      focusLabels: <String>['Bucket', 'Seat', 'Frame'],
    ),
  ],
);

final _world3SameHandRecapRunner = _world3SameHandIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_same_hand_recap',
  caption: 'Lesson learned: context can change the action.',
  hint:
      'A hand can open first in, call facing an open, or fold in a worse frame.',
  question: 'What prevents one-hand-one-answer thinking?',
  feedbackTitle: 'Frame takeaway.',
  feedbackReason:
      'The reusable preflop read is hand bucket, position, and action frame before choosing.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame checklist.',
      body: 'Ask if the pot is unopened or if a raise already happened.',
      focusLabels: <String>['Unopened', 'Facing open'],
    ),
  ],
);

final _w3SameHandDifferentSeatRepairRunner = _world3PositionDisciplineRunner.copyWith(
  lessonId: 'w3_repair_same_hand_different_seat',
  lessonTitle: 'Same hand, different seat',
  caption: 'Repair: same ATo, different seats on this six-seat table.',
  hint: 'Look at who still acts after Hero before judging comfort.',
  question: 'What changed most between the two frames?',
  feedbackTitle: 'Same-hand seat shift repaired.',
  feedbackReason:
      'The cards stayed ATo. The seat changed who still acts after Hero, so the hand feels different.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'seat_context',
      label: 'Seat context changed the hand comfort',
      isCorrect: true,
      preferredLabel: 'Seat context changed the hand comfort',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Seat context repaired.',
      feedbackReason:
          'Same hand, different seat: early has more players behind; later has fewer players behind.',
      repairFocusSeatIds: <String>['utg', 'co', 'btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Same hand', 'Players behind'],
    ),
    Act0RunnerOptionV1(
      id: 'cards_changed',
      label: 'The cards changed strength by themselves',
      isCorrect: false,
      preferredLabel: 'Seat context changed the hand comfort',
      betterAnswerLabel: 'Seat context changed the hand comfort',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good spot to repair.',
      feedbackReason:
          'The hand is still ATo. The missed signal is the seat and who still acts after Hero.',
      repairFocusSeatIds: <String>['utg', 'co', 'btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Same hand', 'Players behind'],
    ),
    Act0RunnerOptionV1(
      id: 'position_unimportant',
      label: 'Seat does not matter for this hand',
      isCorrect: false,
      preferredLabel: 'Seat context changed the hand comfort',
      betterAnswerLabel: 'Seat context changed the hand comfort',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Repair the table read.',
      feedbackReason:
          'Position matters because it changes how many players still act after Hero.',
      repairFocusSeatIds: <String>['utg', 'co', 'btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Same hand', 'Players behind'],
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _world3PositionDisciplineRunner.table.copyWith(
      centerLabel: 'Same hand, seat changes',
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'A', suit: 'd'),
        Act0CardStateV1(rank: 'T', suit: 'c'),
      ],
      highlightedSeatIds: const <String>['utg', 'co', 'btn', 'sb', 'bb'],
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'Frame 1: UTG has more behind'),
        Act0ActionTrailItemV1(label: 'Frame 2: CO has fewer behind'),
        Act0ActionTrailItemV1(label: 'Hero compares seats'),
      ],
    ),
    heroSeatId: 'co',
    activeSeatId: 'co',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame one: early seat.',
      body:
          'ATo from UTG faces more players behind and less information on this six-seat table.',
      focusSeatIds: <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['ATo', 'More behind'],
    ),
    Act0TeachingStepV1(
      title: 'Frame two: later seat.',
      body:
          'The same ATo later in the order has fewer players behind and more information first.',
      focusSeatIds: <String>['co', 'btn', 'sb', 'bb'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['Same hand', 'Fewer behind'],
    ),
  ],
);

final _world3DominatedIntroRunner = _world3FacingOpenIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_dominated_intro',
  lessonTitle: 'Dominated hand warning',
  caption: 'Some familiar hands are trouble when stronger versions open.',
  hint: 'A weak ace can be behind a better ace.',
  question: 'What kind of hand needs caution?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Familiar is not always safe.',
      body: 'Weak aces and weak broadways can run into stronger versions.',
      focusLabels: <String>['Weak ace', 'Trouble'],
    ),
  ],
);

final _world3DominatedFoldRunner = _world3WeakFacingFoldRunner.copyWith(
  lessonId: 'w3_dominated_fold',
  lessonTitle: 'Dominated hand warning',
  caption: 'CO opened. Hero is BTN with A7o.',
  hint: 'This can be behind stronger aces, so folding is clean.',
  question: 'What is the disciplined response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Disciplined fold.',
      feedbackReason:
          'A7o can run into better aces after a CO open. Position is not enough to rescue that domination risk.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2.5 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tempting, but fold.',
      feedbackReason:
          'The ace looks tempting, but A7o is too often dominated after a CO open.',
    ),
  ],
  table: _world3WeakFacingFoldRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    centerLabel: 'Weak ace',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weak ace caution.',
      body: 'A7o can be dominated when someone opened first.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['A7o', 'Fold'],
    ),
  ],
);

final _world3DominatedRecapRunner = _world3DominatedFoldRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_dominated_recap',
  caption: 'Lesson learned: familiar cards still need context.',
  hint: 'Do not continue just because one card looks high.',
  question: 'What should weak familiar hands avoid?',
  feedbackTitle: 'Discipline takeaway.',
  feedbackReason:
      'Some hands look playable but are often behind stronger versions after an open.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Trouble-hand checklist.',
      body: 'High card alone is not enough. Read the opener and bucket.',
      focusLabels: <String>['High card', 'Opener', 'Bucket'],
    ),
  ],
);

final _w1DisciplineCheckpointRunner = _world3DominatedRecapRunner.copyWith(
  lessonId: 'w1_discipline_checkpoint_bridge',
  lessonTitle: 'Hand discipline checkpoint',
  lessonSubtitle: 'Hand Discipline',
  caption: 'Lesson learned: discipline comes before action.',
  hint: 'Next world adds position: the same bucket can change action by seat.',
  question: 'What comes right after naming the bucket?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'seat_context',
      label: 'Seat context',
      isCorrect: true,
      preferredLabel: 'Seat context',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Bucket is step one. Seat context is the next check before choosing action.',
    ),
    Act0RunnerOptionV1(
      id: 'auto_action',
      label: 'Auto action',
      isCorrect: false,
      preferredLabel: 'Seat context',
      betterAnswerLabel: 'Seat context',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'One bucket does not force one action. Position changes comfort.',
    ),
  ],
  feedbackTitle: 'Discipline bridge takeaway.',
  feedbackReason:
      'You now protect your stack with buckets. Next, add position so the same hand can play differently by seat, without chart memorization.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'W1 to W2 bridge.',
      body: 'Bucket first. Position second. Then choose the action frame.',
      focusLabels: <String>['Bucket', 'Position', 'Action frame'],
    ),
  ],
);

final _w2DisciplineTableNoticeRunner = _w1DisciplineApplyEarlyFoldRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w2_discipline_table_notice',
  lessonTitle: 'Hand discipline checkpoint',
  lessonSubtitle: 'Hand Discipline',
  caption: 'Real table. Hero is HJ with J4o and the pot is unopened.',
  hint: 'Use the bucket first before hope or curiosity shows up.',
  question: 'What is the clean discipline read?',
  feedbackTitle: 'Discipline read first.',
  feedbackReason:
      'Real-table discipline starts by naming the bucket cleanly before inventing reasons to continue.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'trash_fold',
      label: 'Trash bucket, clean fold',
      isCorrect: true,
      preferredLabel: 'Trash bucket, clean fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'That is the transfer. J4o from HJ is not a curiosity spot. Name trash, protect chips, and move on.',
    ),
    Act0RunnerOptionV1(
      id: 'looks_fun_open',
      label: 'Open too loose',
      isCorrect: false,
      preferredLabel: 'Trash bucket, clean fold',
      betterAnswerLabel: 'Trash bucket, clean fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'This is exactly the leak hand-discipline is trying to prevent. J4o does not become playable because it looks fun.',
    ),
    Act0RunnerOptionV1(
      id: 'maybe_limp',
      label: 'Limp the trash hand',
      isCorrect: false,
      preferredLabel: 'Trash bucket, clean fold',
      betterAnswerLabel: 'Trash bucket, clean fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'An unopened pot does not rescue a trash bucket. Discipline still says let it go instead of leaking a limp.',
    ),
  ],
  table: _act0ReassignHeroSeatV1(
    _w1DisciplineApplyEarlyFoldRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: 'J', suit: 'c'),
        Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
      ],
      highlightedSeatIds: const <String>['hj'],
      centerLabel: 'HJ, unopened pot',
      actionTrail: const <Act0ActionTrailItemV1>[
        Act0ActionTrailItemV1(label: 'UTG folds'),
        Act0ActionTrailItemV1(label: 'HJ acts'),
      ],
    ),
    heroSeatId: 'hj',
    activeSeatId: 'hj',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket before curiosity.',
      body:
          'Some live-table leaks start because a weak hand looks tempting. Name the bucket first, then act with discipline.',
      focusSeatIds: <String>['hj'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['J4o', 'Trash', 'Fold'],
    ),
  ],
);

// W1 bucket ID runners — all four buckets so the learner sees the full picture.
final _w1StrongBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w1_strong_bucket',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Hand Discipline',
  caption: 'JJ is a strong preflop hand.',
  hint: 'Strong hands play well but are not the absolute top bucket.',
  question: 'Which bucket is JJ?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: true,
      preferredLabel: 'Strong',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'JJ is a strong hand — second bucket. Very playable, but not premium.',
    ),
    Act0RunnerOptionV1(
      id: 'premium',
      label: 'Premium',
      isCorrect: false,
      preferredLabel: 'Strong',
      betterAnswerLabel: 'Strong',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'Premium is reserved for the absolute top hands like AA, KK, and AKs.',
    ),
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: false,
      preferredLabel: 'Strong',
      betterAnswerLabel: 'Strong',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'JJ is above medium. Medium hands need more context to play well.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 'h'),
      Act0CardStateV1(rank: 'J', suit: 's'),
    ],
    centerLabel: 'Strong bucket',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Strong, not premium.',
      body:
          'JJ is strong but can face an ace on the flop. Strong is the second bucket.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['JJ', 'Strong'],
    ),
  ],
);

final _w1MediumBucketRunner = _world3BucketsIntroRunner.copyWith(
  lessonId: 'w1_medium_bucket',
  lessonTitle: 'Hand buckets',
  lessonSubtitle: 'Hand Discipline',
  caption: 'KQo is a medium preflop hand.',
  hint: 'Medium hands play best in good positions with the right frame.',
  question: 'Which bucket is KQo?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'medium',
      label: 'Medium',
      isCorrect: true,
      preferredLabel: 'Medium',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'KQo is a medium hand — good enough to play but needs a comfortable spot.',
    ),
    Act0RunnerOptionV1(
      id: 'strong',
      label: 'Strong',
      isCorrect: false,
      preferredLabel: 'Medium',
      betterAnswerLabel: 'Medium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'Strong hands need less context. KQo wants a good position and a clear frame.',
    ),
    Act0RunnerOptionV1(
      id: 'trash',
      label: 'Trash',
      isCorrect: false,
      preferredLabel: 'Medium',
      betterAnswerLabel: 'Medium',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'KQo is above trash. Two connected high cards have real playable value.',
    ),
  ],
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
    centerLabel: 'Medium bucket',
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Medium needs position.',
      body: 'KQo is playable but not strong enough to play from anywhere.',
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KQo', 'Medium'],
    ),
  ],
);

// W1: Medium hand first-in on the Button — raise is clean, limp is suboptimal.
final _w1MediumOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w1_medium_open',
  lessonTitle: 'Continue or let go',
  lessonSubtitle: 'Hand Discipline',
  caption: 'BTN. Pot unopened. Hero holds K♦ Q♣.',
  hint: 'Medium hand in the best seat. Raising is sharper than limping.',
  question: 'What is the best first-in action?',
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
    centerLabel: 'Medium, good seat',
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn'],
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  feedbackTitle: 'Clean execution.',
  feedbackReason:
      'KQo on the Button can open cleanly when the pot is unopened.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'KQo on the Button has enough to open. Folding here wastes a strong seat.',
      repairFocusSeatIds: <String>['btn'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['BTN', 'KQo', 'Fold wastes it'],
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: false,
      preferredLabel: 'Raise',
      betterAnswerLabel: 'Raise',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Passive line, weaker pressure.',
      feedbackReason:
          'Limping KQo is legal but starts the hand passively. Raising opens the pot and pressures the blinds.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Limp legal', 'Raise sharper', 'BTN'],
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '2.5 BB',
      isCorrect: true,
      preferredLabel: 'Raise',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Raise is the sharp Button play.',
      feedbackReason: 'KQo on the Button is a clean first-in open.',
      repairFocusSeatIds: <String>['btn'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['BTN open', 'KQo'],
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Medium hand, good seat.',
      body:
          'KQo is medium bucket. The Button is the best seat. Raise to open cleanly.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['KQo', 'BTN', 'Open'],
    ),
  ],
);

// W1 apply runners — table-context scenarios that combine bucket + seat + frame.
final _w1DisciplineApplyIntroRunner = _world3BucketsRecapRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w1_discipline_apply_intro',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'Three steps make the decision easier.',
  hint:
      'Bucket the hand, read the seat, read the frame — then act. No chart memorization required.',
  question: 'What order helps most?',
  feedbackTitle: 'Three-step habit.',
  feedbackReason:
      'Bucket, seat, and frame together give the action a clear reason.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket, seat, frame.',
      body: 'Name the hand bucket. Check the seat. Read who acted first.',
      focusLabels: <String>['Bucket', 'Seat', 'Frame'],
    ),
  ],
);

final _w1DisciplineApplyEarlyFoldRunner = _world3EarlyFoldRunner.copyWith(
  lessonId: 'w1_apply_early_fold',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'UTG. Pot unopened. Hero holds 8♠ 4♦.',
  hint: 'Early position, trash bucket. Discipline says fold.',
  question: 'What is the clean action?',
  feedbackTitle: 'Discipline holds.',
  feedbackReason:
      'Early position with a trash hand needs no extra thought. Fold and wait.',
  table: _act0ReassignHeroSeatV1(
    _world3EarlyFoldRunner.table.copyWith(
      heroCards: const <Act0CardStateV1>[
        Act0CardStateV1(rank: '8', suit: 's'),
        Act0CardStateV1(rank: '4', suit: 'd'),
      ],
      centerLabel: 'Trash early',
      highlightedSeatIds: const <String>['utg'],
      highlightedCardIds: const <String>['hero_0', 'hero_1'],
    ),
    heroSeatId: 'utg',
    activeSeatId: 'utg',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Trash in early seat.',
      body: '8♠4♦ from UTG is clear trash. No context rescues it.',
      focusSeatIds: <String>['utg'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['8 4o', 'UTG', 'Fold'],
    ),
  ],
);

final _w1DisciplineApplyLateOpenRunner = _world3ButtonOpenRunner.copyWith(
  lessonId: 'w1_apply_late_open',
  lessonTitle: 'Discipline at the table',
  lessonSubtitle: 'Hand Discipline',
  caption: 'BTN. Pot unopened. Hero holds A♠ J♦.',
  hint: 'Late position, strong hand, no one entered. Clean open.',
  question: 'What is the clean action?',
  feedbackTitle: 'Discipline confirms.',
  feedbackReason:
      'AJo on the button is a strong late-position open when the pot is clean.',
  table: _world3ButtonOpenRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'd'),
    ],
    centerLabel: 'Strong late',
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn'],
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Strong hand, good seat.',
      body: 'AJo is a strong bucket. BTN acts last. Pot is clean. Open.',
      focusSeatIds: <String>['btn'],
      focusCardIds: <String>['hero_0', 'hero_1'],
      focusLabels: <String>['AJo', 'BTN', 'Open'],
    ),
  ],
);

final _world3CheckpointIntroRunner = _world3SameHandIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_checkpoint_intro',
  lessonTitle: 'Preflop checkpoint',
  caption: 'Checkpoint: bucket, position, frame, then action.',
  hint: 'Keep one reason in focus for each preflop decision.',
  question: 'What is the World 3 preflop order?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Preflop order.',
      body: 'Name the bucket, read position, read frame, choose action.',
      focusLabels: <String>['Bucket', 'Position', 'Frame', 'Action'],
    ),
  ],
);

final _world3CheckpointRunner = _world3SameHandIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w3_checkpoint_review',
  lessonTitle: 'Preflop checkpoint',
  caption: 'Lesson learned: simple preflop choices need a framework.',
  hint: 'No charts yet. Just bucket, position, frame, action.',
  feedbackReason:
      'Bucket, seat, frame keeps preflop clear. Next, every bet needs a purpose too.',
  question: 'What makes preflop less random?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'framework',
      label: 'Bucket, seat, frame',
      isCorrect: true,
      preferredLabel: 'Bucket, seat, frame',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That framework keeps preflop choices clear. Next, every bet needs a purpose too.',
    ),
    Act0RunnerOptionV1(
      id: 'one_answer',
      label: 'One answer per hand',
      isCorrect: false,
      preferredLabel: 'Bucket, seat, frame',
      betterAnswerLabel: 'Bucket, seat, frame',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'One hand can change action when position or action frame changes.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 3 checkpoint.',
      body: 'Use one compact read instead of guessing the first action.',
      focusLabels: <String>['Open', 'Call', 'Fold'],
    ),
  ],
);

final _w4TableFrameNoticeRunner = _world3FacingOpenIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_table_frame_notice',
  lessonTitle: 'Preflop checkpoint',
  lessonSubtitle: 'Preflop Framework',
  caption: 'Real table. HJ opens 2.5 BB and hero is CO with AJo.',
  hint: 'Before deciding call, fold, or raise, name the frame cleanly.',
  question: 'What frame are you in?',
  feedbackTitle: 'Frame first.',
  feedbackReason: 'Name the frame before choosing the action.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'facing_open',
      label: 'Facing an open',
      isCorrect: true,
      preferredLabel: 'Facing an open',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'That is the live-table transfer. Name the frame before choosing the action.',
    ),
    Act0RunnerOptionV1(
      id: 'unopened',
      label: 'Unopened pot',
      isCorrect: false,
      preferredLabel: 'Facing an open',
      betterAnswerLabel: 'Facing an open',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'The open already happened, so the clean frame is no longer unopened.',
    ),
    Act0RunnerOptionV1(
      id: 'call_first',
      label: 'Playable hand, so call first',
      isCorrect: false,
      preferredLabel: 'Facing an open',
      betterAnswerLabel: 'Facing an open',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'AJo may continue sometimes, but frame comes before action. Name facing open first.',
    ),
  ],
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h'),
      Act0CardStateV1(rank: 'J', suit: 'c'),
    ],
    activeSeatId: 'co',
    highlightedSeatIds: const <String>['hj', 'co'],
    centerLabel: 'HJ opens 2.5 BB',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'CO acts'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Frame before action.',
      body:
          'Real tables get simpler when you first ask whether the pot is unopened or facing an open.',
      focusSeatIds: <String>['hj', 'co'],
      focusLabels: <String>['Facing open', 'Price exists', 'Action comes next'],
    ),
  ],
);

// W3 position apply intro — used in the W3 apply lesson below.
final _w3PositionApplyIntroRunner = _world3PositionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w3_position_apply_intro',
  lessonTitle: 'Position at the table',
  lessonSubtitle: 'Position Thinking',
  caption: 'Position tells you how comfortable a hand is before you act.',
  hint:
      'BTN is the best seat. UTG needs stronger hands to open. No charts needed yet.',
  question: 'Why does position matter at the table?',
  feedbackTitle: 'Position habit.',
  feedbackReason:
      'Seat changes when you act and how much information you have before the decision.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Seat, then hand.',
      body: 'Check where you sit before deciding what to do with the hand.',
      focusSeatIds: <String>['utg', 'btn'],
      focusLabels: <String>['Early needs more', 'Late can open more'],
    ),
  ],
);

final _world4PurposeIntroRunner = _readBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_purpose_intro',
  lessonTitle: 'Why bets happen',
  lessonSubtitle: 'Bet Purpose And Price',
  beatIndex: 1,
  beatCount: 4,
  caption: 'A bet should have a reason before it has a size.',
  hint: 'Start with purpose: value, bluff, or protection.',
  question: 'What should you name before sizing a bet?',
  options: const <Act0RunnerOptionV1>[],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 6 BB',
    toCallLabel: '',
    centerLabel: 'Name purpose',
    boardCards: _flopA72Cards,
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'Flop dealt'),
    ],
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Purpose first.',
      body:
          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',
      focusLabels: <String>['Value', 'Bluff', 'Protection'],
    ),
  ],
);

final _world4ValuePurposeRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_value_purpose',
  caption: 'Hero has top pair. Worse hands can call.',
  hint: 'This bet is not just noise. It wants calls from weaker hands.',
  question: 'What is the main purpose?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: true,
      preferredLabel: 'Value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason: 'A value bet wants weaker hands to call.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'Hero is not trying to fold out everything; weaker hands can pay.',
    ),
  ],
  table: _world4PurposeIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 'd'),
    ],
    centerLabel: 'Top pair',
    highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Value wants calls.',
      body: 'With top pair, weaker pairs and worse aces may continue.',
      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],
      focusLabels: <String>['Top pair', 'Weaker calls'],
    ),
  ],
);

final _world4BluffPurposeRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_bluff_purpose',
  caption: 'Hero missed. The bet tries to win by folds.',
  hint: 'A bluff needs fold pressure, not a made hand.',
  question: 'What is the main purpose?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff',
      isCorrect: true,
      preferredLabel: 'Bluff',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: 'A bluff tries to make better hands fold.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: false,
      preferredLabel: 'Bluff',
      betterAnswerLabel: 'Bluff',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'Hero missed, so the bet is not asking weaker hands to pay.',
    ),
  ],
  table: _world4PurposeIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
    centerLabel: 'Missed hand',
    highlightedSeatIds: const <String>['btn', 'bb'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bluff wants folds.',
      body: 'When hero has no pair, the bet works only if folds happen.',
      focusLabels: <String>['Missed', 'Fold pressure'],
    ),
  ],
);

final _world4PurposeRecapRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_purpose_recap',
  caption: 'Lesson learned: name the purpose before the size.',
  hint: 'Value gets calls. Bluff gets folds. Protection denies free cards.',
  question: 'What comes before the bet size?',
  feedbackTitle: 'Purpose takeaway.',
  feedbackReason:
      'Betting gets clearer when every chip has a job: value, bluff, or protection.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Purpose checklist.',
      body: 'Ask what the bet wants before asking how big it should be.',
      focusLabels: <String>['Purpose', 'Then size'],
    ),
  ],
);

final _world4ValueIntroRunner = _world4ValuePurposeRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_value_intro',
  lessonTitle: 'Value bets',
  caption: 'A value bet targets weaker hands that can call.',
  hint: 'If no weaker hand can call, value is thin or missing.',
  question: 'Who should a value bet get called by?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Worse calls.',
      body: 'Value means worse hands can still call.',
      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],
    ),
  ],
);

final _world4ValueBetRunner = _world4ValuePurposeRunner.copyWith(
  lessonId: 'w4_value_bet',
  lessonTitle: 'Value bets',
  caption: 'Top pair on a safe flop. BB can call worse.',
  hint: 'A half-pot bet is a simple value size here.',
  question: 'What action fits the purpose?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_half',
      label: 'Bet half-pot',
      amountLabel: '3 BB',
      isCorrect: true,
      preferredLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Half-pot asks weaker hands to pay without using a huge size.',
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Checking can miss value when worse hands can call.',
    ),
  ],
  table: _world4ValuePurposeRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Value spot',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
  ),
);

final _world4ValueCheckMissRunner = _world4ValueBetRunner.copyWith(
  lessonId: 'w4_value_missed',
  caption: 'Hero has top pair. Checking gives up a value chance.',
  hint: 'When worse hands can call, betting is the lesson.',
  question: 'Which action misses value?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'Checking can miss value in this simple top-pair spot.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_half',
      label: 'Bet half-pot',
      amountLabel: '3 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'The question asks which action misses value; betting is the value action.',
    ),
  ],
);

final _world4ValueRecapRunner = _world4ValueIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_value_recap',
  caption: 'Lesson learned: value means worse can call.',
  hint: 'Do not hide strong but call-able hands every time.',
  question: 'What makes a bet value?',
  feedbackTitle: 'Value takeaway.',
  feedbackReason:
      'A value bet is not just betting a strong hand. It needs weaker hands that can call.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Value checklist.',
      body: 'Ask what worse hands can call before choosing a size.',
      focusLabels: <String>['Worse calls', 'Size next'],
    ),
  ],
);

final _world4BluffIntroRunner = _world4BluffPurposeRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_bluff_intro',
  lessonTitle: 'Bluff pressure',
  caption: 'A bluff tries to win when better hands fold.',
  hint: 'No fold chance, no clean bluff.',
  question: 'What does a bluff need?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fold pressure.',
      body: 'A bluff is a story backed by chips, not random betting.',
      focusLabels: <String>['Better folds', 'Pressure'],
    ),
  ],
);

final _world4BluffPressureRunner = _world4BluffPurposeRunner.copyWith(
  lessonId: 'w4_bluff_pressure',
  lessonTitle: 'Bluff pressure',
  caption: 'Hero missed, but BB checked and can fold.',
  hint: 'A small bet can apply pressure without risking too much.',
  question: 'What action matches the bluff purpose?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_small',
      label: 'Bet one-third',
      amountLabel: '2 BB',
      isCorrect: true,
      preferredLabel: 'Bet one-third',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'A one-third bet creates fold pressure at a controlled price.',
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet one-third',
      betterAnswerLabel: 'Bet one-third',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Legal, but betting is sharper.',
      feedbackReason:
          'Checking is legal and not a disaster, but a small bet creates fold pressure at low cost.',
    ),
  ],
  table: _world4BluffPurposeRunner.table.copyWith(
    centerLabel: 'Fold pressure',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'BB checks'),
    ],
  ),
);

final _world4BadBluffRunner = _world4BluffPressureRunner.copyWith(
  lessonId: 'w4_bad_bluff',
  caption: 'Villain called big already. Fold pressure is low.',
  hint: 'A bluff is weaker when the opponent is not folding.',
  question: 'What is the safer beginner action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: true,
      preferredLabel: 'Check',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Check is the cleaner line.',
      feedbackReason:
          'When fold pressure is low, checking avoids a forced bluff.',
    ),
    Act0RunnerOptionV1(
      id: 'pot_bet',
      label: 'Bet pot-size',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Check',
      betterAnswerLabel: 'Check',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'A pot-size bluff is too ambitious when fold pressure is unclear.',
    ),
  ],
  table: _world4BluffPressureRunner.table.copyWith(
    centerLabel: 'Low fold pressure',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN raises 3 BB'),
      Act0ActionTrailItemV1(label: 'BB calls 3 BB'),
      Act0ActionTrailItemV1(label: 'Flop: BB calls 3 BB'),
    ],
  ),
);

final _world4BluffRecapRunner = _world4BluffIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_bluff_recap',
  caption: 'Lesson learned: bluff only when folds can happen.',
  hint: 'Pressure matters, but not every missed hand must fire.',
  question: 'What does a bluff try to create?',
  feedbackTitle: 'Bluff takeaway.',
  feedbackReason:
      'Bluffing is pressure with a purpose: make better hands fold without risking chips blindly.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bluff checklist.',
      body: 'Ask whether better hands can fold before betting a miss.',
      focusLabels: <String>['Better folds', 'Controlled risk'],
    ),
  ],
);

final _world4ProtectionIntroRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_protection_intro',
  lessonTitle: 'Protection and denial',
  caption: 'Protection bets make the next card cost something.',
  hint: 'This is value-adjacent, but the key word is deny.',
  question: 'What does protection deny?',
  options: const <Act0RunnerOptionV1>[],
  table: _world4PurposeIntroRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 'h'),
      Act0CardStateV1(rank: '9', suit: 'h'),
      Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    centerLabel: 'Next card matters',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Deny free cards.',
      body: 'Protection makes the next card cost something.',
      focusLabels: <String>['Next card', 'Cost', 'Deny'],
    ),
  ],
);

final _world4ProtectionBetRunner = _world4ProtectionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_protection_bet',
  caption: 'Hero has top pair. Checking gives villain a free next card.',
  hint: 'Betting protects value by denying that free card.',
  question: 'What action fits protection?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_half',
      label: 'Bet half-pot',
      amountLabel: '3 BB',
      isCorrect: true,
      preferredLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'The bet makes the next card cost something.',
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check',
      isCorrect: false,
      preferredLabel: 'Bet half-pot',
      betterAnswerLabel: 'Bet half-pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'Checking lets villain see the next card for free.',
    ),
  ],
  table: _world4ProtectionIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'd'),
    ],
    highlightedCardIds: const <String>['hero_0', 'board_0', 'board_1'],
  ),
);

final _world4ProtectionCheckRunner = _world4ProtectionBetRunner.copyWith(
  lessonId: 'w4_protection_check',
  caption: 'Hero checks. Villain gets a free next card.',
  hint: 'This is the risk protection bets are trying to avoid.',
  question: 'What did checking allow?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'free_card',
      label: 'Free card',
      isCorrect: true,
      preferredLabel: 'Free card',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason: 'Checking allowed villain to continue without paying.',
    ),
    Act0RunnerOptionV1(
      id: 'made_pay',
      label: 'Made pay',
      isCorrect: false,
      preferredLabel: 'Free card',
      betterAnswerLabel: 'Free card',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'Villain pays only when Hero bets.',
    ),
  ],
);

final _world4ProtectionRecapRunner = _world4ProtectionIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_protection_recap',
  caption: 'Lesson learned: protection denies a free next card.',
  hint: 'Denying a free card is a real purpose.',
  question: 'What does a protection bet deny?',
  feedbackTitle: 'Protection takeaway.',
  feedbackReason:
      'Protection means the next card is not free for the player trying to continue.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Protection checklist.',
      body: 'Ask if checking gives away the next card too cheaply.',
      focusLabels: <String>['Next card', 'Free card', 'Bet'],
    ),
  ],
);

final _world4PriceIntroRunner = _callActionRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_price_intro',
  lessonTitle: 'Call price',
  lessonSubtitle: 'Bet Purpose And Price',
  caption: 'When someone bets, they set your price to continue.',
  hint:
      'Price is what you must pay to continue. Read pot, to call, and hand strength together.',
  question: 'What does a bet give the caller?',
  options: const <Act0RunnerOptionV1>[],
  table: _callActionRunner.table.copyWith(
    streetLabel: 'Turn',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Facing price',
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Cutoff',
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        bet: _btnBet2Bb,
        holeCards: _heroQqCards,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        holeCards: _unknownHoleCards,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        holeCards: _unknownHoleCards,
      ),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h'),
      Act0CardStateV1(rank: '8', suit: 'c'),
      Act0CardStateV1(rank: '3', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN bets 2 BB'),
      Act0ActionTrailItemV1(label: 'BB acts'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Price to continue.',
      body: 'Pot = what you can win. To call = what you risk.',
      focusLabels: <String>['Pot', 'To call', 'Price'],
    ),
  ],
);

final _world4GoodPriceCallRunner = _world4PriceIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_good_price_call',
  caption: 'Pot is 8 BB. To call is 1 BB with one pair.',
  hint: 'Small price, paired hand: calling is acceptable.',
  question: 'What action fits the price?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Pot 8 BB gives you something real to win, to call is only 1 BB, and one pair is enough reason to continue.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'Do not look only at the hand. Pot 8 BB is worth fighting for, to call is only 1 BB, and one pair is enough to continue once.',
    ),
  ],
  table: _world4PriceIntroRunner.table.copyWith(
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: 'Small price',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h'),
      Act0CardStateV1(rank: '8', suit: 'c'),
      Act0CardStateV1(rank: '3', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
  ),
);

final _world4BadPriceFoldRunner = _world4GoodPriceCallRunner.copyWith(
  lessonId: 'w4_bad_price_fold',
  caption: 'Pot is 8 BB. To call is 7 BB with a weak pair.',
  hint: 'The price is high and the hand is not strong enough.',
  question: 'What action fits the price?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Pot 8 BB is not enough to justify risking 7 BB with a weak pair. The hand is too thin for that price.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '7 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'Calling spends 7 BB to win a pot that is only 8 BB, and a weak pair is not a strong enough reason.',
    ),
  ],
  table: _world4GoodPriceCallRunner.table.copyWith(
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 7 BB',
    centerLabel: 'High price',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '8', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'h'),
      Act0CardStateV1(rank: '8', suit: 'c'),
      Act0CardStateV1(rank: '4', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
  ),
);

final _world4CheapPriceMarginalCallRunner = _world4GoodPriceCallRunner.copyWith(
  lessonId: 'w4_cheap_price_marginal_call',
  caption: 'Pot is 10 BB. To call is 1 BB with middle pair.',
  hint:
      'A cheap call can be okay when the pot is large enough and the hand still has value.',
  question: 'What action fits the price?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '1 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Good price read.',
      feedbackReason:
          'Pot 10 BB offers plenty to win, to call is only 1 BB, and middle pair is enough reason to continue once.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too tight here.',
      feedbackReason:
          'Folding ignores the price. Pot 10 BB is large, to call is tiny, and middle pair is enough to keep going.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '4 BB',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'Raising adds more risk than this spot asks for. The clean read is use the cheap 1 BB price and call.',
    ),
  ],
  table: _world4GoodPriceCallRunner.table.copyWith(
    potLabel: 'Pot 10 BB',
    toCallLabel: 'To call 1 BB',
    centerLabel: 'Cheap price, middle pair',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    highlightedCardIds: const <String>['hero_0', 'board_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Cheap price, honest hand.',
      body:
          'Do not look only at fear. Pot 10 BB and To call 1 BB make middle pair worth one calm continue.',
      focusLabels: <String>['Pot 10 BB', 'To call 1 BB', 'Middle pair'],
    ),
  ],
);

final _world4BigPriceMarginalFoldRunner = _world4BadPriceFoldRunner.copyWith(
  lessonId: 'w4_big_price_marginal_fold',
  caption: 'Pot is 9 BB. To call is 6 BB with top pair, weak kicker.',
  hint:
      'A bigger call needs a stronger reason. Hand strength alone is not enough here.',
  question: 'What action fits the price?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: true,
      preferredLabel: 'Fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong discipline.',
      feedbackReason:
          'Top pair sounds good, but Pot 9 BB is not enough to justify risking 6 BB with a weak kicker.',
    ),
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Look at the price too.',
      feedbackReason:
          'Do not stop at top pair. To call 6 BB is a big risk compared with the 9 BB pot and this marginal hand.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '12 BB',
      isCorrect: false,
      preferredLabel: 'Fold',
      betterAnswerLabel: 'Fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much pressure back.',
      feedbackReason:
          'Raising adds even more risk when the call price already asks too much from a thin top pair.',
    ),
  ],
  table: _world4BadPriceFoldRunner.table.copyWith(
    potLabel: 'Pot 9 BB',
    toCallLabel: 'To call 6 BB',
    centerLabel: 'Top pair, big price',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: 'J', suit: 'c'),
      Act0CardStateV1(rank: '3', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    highlightedCardIds: const <String>['hero_0', 'board_0'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Big price needs more.',
      body:
          'Top pair is not an auto-continue. Pot 9 BB and To call 6 BB mean the hand needs a stronger reason.',
      focusLabels: <String>[
        'Pot 9 BB',
        'To call 6 BB',
        'Top pair, weak kicker',
      ],
    ),
  ],
);

final _world4PriceRecapRunner = _world4PriceIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_price_recap',
  caption: 'Lesson learned: every call has a price.',
  hint: 'Compare the price to hand strength and future cards.',
  question: 'What should you read before calling?',
  feedbackTitle: 'Price takeaway.',
  feedbackReason:
      'A call is not just staying curious. Pot tells what you can win, To call tells what you must risk, and the hand must be strong enough for that trade.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Price checklist.',
      body: 'Read pot, to-call, and hand strength before calling.',
      focusLabels: <String>['Pot', 'To call', 'Hand'],
    ),
  ],
);

final _world4SizingIntroRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_sizing_intro',
  lessonTitle: 'Small, half, pot',
  caption: 'Bet size changes pressure and price.',
  hint: 'One-third is light, half-pot is common, pot-size is heavy.',
  question: 'What does size change?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Size is pressure.',
      body:
          'One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.',
      focusLabels: <String>['One-third', 'Half-pot', 'Pot-size'],
    ),
  ],
);

final _world4SmallBetRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_small_bet',
  caption: 'Pot is 6 BB. Hero wants light pressure.',
  hint: 'One-third pot is the smallest simple pressure size here.',
  question: 'Which size is one-third pot?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: true,
      preferredLabel: '2 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason: '2 BB into 6 BB is one-third pot.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '2 BB',
      betterAnswerLabel: '2 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: '6 BB into 6 BB is pot-size, not one-third.',
    ),
  ],
  table: _world4SizingIntroRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'One-third?',
  ),
);

final _world4HalfPotRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_half_pot_bet',
  caption: 'Pot is 6 BB. Hero wants the clean middle size.',
  hint:
      'Half-pot means betting half the pot, not the smallest or biggest size.',
  question: 'Which size is half-pot?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'three',
      label: '3 BB',
      isCorrect: true,
      preferredLabel: '3 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'Into a 6 BB pot, 3 BB is exactly a half-pot size.',
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: false,
      preferredLabel: '3 BB',
      betterAnswerLabel: '3 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: '2 BB into 6 BB is one-third pot, not half-pot.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 BB',
      isCorrect: false,
      preferredLabel: '3 BB',
      betterAnswerLabel: '3 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: '6 BB into 6 BB is pot-size, not half-pot.',
    ),
  ],
  table: _world4SizingIntroRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Half-pot?',
  ),
);

final _world4PotBetRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w4_pot_bet',
  caption: 'Pot is 6 BB. A pot-size bet is heavy pressure.',
  hint: 'Pot-size means the bet matches the pot.',
  question: 'Which size is pot-size?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 BB',
      isCorrect: true,
      preferredLabel: '6 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: '6 BB into 6 BB is a pot-size bet.',
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: '2 BB',
      isCorrect: false,
      preferredLabel: '6 BB',
      betterAnswerLabel: '6 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: '2 BB is one-third pot here, not pot-size.',
    ),
  ],
  table: _world4SizingIntroRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Pot-size?',
  ),
);

final _world4SizingRecapRunner = _world4SizingIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_sizing_recap',
  caption: 'Lesson learned: size sets pressure and price.',
  hint: 'Small, half-pot, and pot-size should match the purpose.',
  question: 'What should size match?',
  feedbackTitle: 'Sizing takeaway.',
  feedbackReason:
      'Size is not decoration. It creates the price your opponent must face.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Sizing checklist.',
      body:
          'Name purpose, then choose a size that fits the pressure: light, middle, or heavy.',
      focusLabels: <String>['Purpose', 'Pressure', 'Price'],
    ),
  ],
);

final _world4CheckpointIntroRunner = _world4PurposeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w4_checkpoint_intro',
  lessonTitle: 'Price checkpoint',
  caption: 'Checkpoint: purpose, size, and price work together.',
  hint: 'The bettor sets pressure. The caller reads the price.',
  question: 'What are the three World 4 reads?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Three reads.',
      body: 'Purpose explains why. Size creates pressure. Price decides calls.',
      focusLabels: <String>['Purpose', 'Size', 'Price'],
    ),
  ],
);

final _world4PriceTableTransferRunner = _world4GoodPriceCallRunner.copyWith(
  lessonId: 'w4_price_table_transfer',
  caption: 'Real table. Pot is 7 BB. To call is 2 BB. Hero has second pair.',
  hint:
      'Do not look only at your hand. Compare hand strength with the price before reacting.',
  question: 'What is the clean turn action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call',
      label: 'Call',
      amountLabel: '2 BB',
      isCorrect: true,
      preferredLabel: 'Call',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean table read.',
      feedbackReason:
          'Pot 7 BB is worth contesting, To call is only 2 BB, and second pair is enough to continue once.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too cautious here.',
      feedbackReason:
          'Folding ignores the price. The pot is 7 BB, the call costs only 2 BB, and the hand still has enough value.',
    ),
    Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise',
      amountLabel: '6 BB',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'Raising spends more than this price read needs. The clean transfer is call the small price with second pair.',
    ),
  ],
  table: _world4GoodPriceCallRunner.table.copyWith(
    streetLabel: 'Turn',
    potLabel: 'Pot 7 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Second pair, live table',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '4', suit: 'c'),
      Act0CardStateV1(rank: '2', suit: 'd'),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BB bets 2 BB'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
    highlightedCardIds: const <String>['hero_1', 'board_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Live table price read.',
      body:
          'Pot tells what you can win. To call tells what you must risk. Compare both with second pair before choosing.',
      focusLabels: <String>['Pot 7 BB', 'To call 2 BB', 'Second pair'],
    ),
  ],
);

final _world4PurposePriceTableTransferRunner = _world4ValueBetRunner.copyWith(
  lessonId: 'w4_purpose_price_table_transfer',
  caption:
      'Real table. Pot is 6 BB. BTN bets 2 BB with top pair on a dry flop.',
  hint:
      'Read both halves together: the bet has a value purpose, and the small size gives BB a cheap continue price.',
  question: 'What is the clean read?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'small_value_price',
      label: 'Small value bet that sets a cheap continue price',
      isCorrect: true,
      preferredLabel: 'Small value bet that sets a cheap continue price',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'Top pair wants calls from worse hands, and the 2 BB size keeps the continue price cheap instead of forcing a huge decision.',
    ),
    Act0RunnerOptionV1(
      id: 'pot_bluff',
      label: 'Pot-size bluff trying to force folds',
      isCorrect: false,
      preferredLabel: 'Small value bet that sets a cheap continue price',
      betterAnswerLabel: 'Small value bet that sets a cheap continue price',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not this frame.',
      feedbackReason:
          'The action is too small for a pot-size bluff story. With top pair, the cleaner read is value plus a manageable price.',
    ),
    Act0RunnerOptionV1(
      id: 'random_size',
      label: 'Random bet with no clear job',
      isCorrect: false,
      preferredLabel: 'Small value bet that sets a cheap continue price',
      betterAnswerLabel: 'Small value bet that sets a cheap continue price',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Look one layer deeper.',
      feedbackReason:
          'The size is not random once you connect purpose and price. The 2 BB bet keeps weaker hands in while still charging them to continue.',
    ),
  ],
  table: _world4ValueBetRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Value plus price',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 'd'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'c'),
      Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN bets 2 BB'),
      Act0ActionTrailItemV1(label: 'BB acts'),
    ],
    highlightedSeatIds: const <String>['btn', 'bb'],
    highlightedCardIds: const <String>['hero_0', 'board_0'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Purpose and price travel together.',
      body:
          'A live bet is clearer when you name both the job and the price it creates. Here top pair wants calls, and 2 BB keeps that continue cheap.',
      focusLabels: <String>['Value', '2 BB', 'Cheap price'],
    ),
  ],
);

final _world4CheckpointRunner = _world4CheckpointIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_checkpoint_review',
  caption: 'Lesson learned: betting is purpose plus price.',
  hint: 'Value, bluff, protection, and call price are now one system.',
  question: 'What makes a bet easier to understand?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'purpose_price',
      label: 'Purpose and price',
      isCorrect: true,
      preferredLabel: 'Purpose and price',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Discipline: fold early trash.',
      feedbackReason:
          'A bet tells a purpose, creates a size, and gives the caller a price. Next, board texture tells you which bet purpose fits.',
    ),
    Act0RunnerOptionV1(
      id: 'random_size',
      label: 'Random size',
      isCorrect: false,
      preferredLabel: 'Purpose and price',
      betterAnswerLabel: 'Purpose and price',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Random sizes hide the lesson. Good beginner bets have a clear job.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 4 checkpoint.',
      body: 'Read what the bet wants and what it costs to continue.',
      focusLabels: <String>['Value', 'Bluff', 'Protection', 'Price'],
    ),
  ],
);

final _world5TextureIntroRunner = _readBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_texture_intro',
  lessonTitle: 'Dry or wet board',
  lessonSubtitle: 'Board And Draws',
  caption: 'Board texture asks how much the next cards can change.',
  hint: 'Dry boards change less. Wet boards create more threats.',
  question: 'What does board texture describe?',
  options: const <Act0RunnerOptionV1>[],
  table: _readBoardRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 5 BB',
    centerLabel: 'Texture read',
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'd', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    highlightedCardIds: const <String>['board_0', 'board_1', 'board_2'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Texture first.',
      body: 'Before action, ask if the board is calm or changing fast.',
      focusLabels: <String>['Dry', 'Wet', 'Board'],
    ),
  ],
);

final _world5DryBoardRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_dry_board',
  caption: 'K-7-2 rainbow is spread out and different suits.',
  hint: 'Few obvious straight or flush paths are visible.',
  question: 'What texture is this?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'dry',
      label: 'Dry',
      isCorrect: true,
      preferredLabel: 'Dry',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'Spread ranks and mixed suits make this a dry board.',
    ),
    Act0RunnerOptionV1(
      id: 'wet',
      label: 'Wet',
      isCorrect: false,
      preferredLabel: 'Dry',
      betterAnswerLabel: 'Dry',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'Wet boards show more connected ranks or suit pressure.',
    ),
  ],
);

final _world5WetBoardRunner = _world5TextureIntroRunner.copyWith(
  lessonId: 'w5_wet_board',
  caption: 'T-9-8 with two hearts can change quickly.',
  hint: 'Connected ranks and suit pressure make this wet.',
  question: 'What texture is this?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'wet',
      label: 'Wet',
      isCorrect: true,
      preferredLabel: 'Wet',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'The connected ranks and two hearts create many changes. Straight paths, heart pressure, and future cards can all change the next decision quickly.',
    ),
    Act0RunnerOptionV1(
      id: 'dry',
      label: 'Dry',
      isCorrect: false,
      preferredLabel: 'Wet',
      betterAnswerLabel: 'Wet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'This is not dry. Connected ranks plus two hearts mean future cards can change the story fast, so the board already carries wet pressure.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '8', suit: 'c'),
    ],
    centerLabel: 'Wet board',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Wet boards can turn fast.',
      body:
          'When ranks connect and two cards share a suit, more turn and river cards can change who is comfortable. Read that pressure before you choose an easy autopilot line.',
      focusLabels: <String>['Connected', 'Two hearts', 'Future cards'],
    ),
  ],
);

final _world5TextureRecapRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_texture_recap',
  caption: 'Lesson learned: texture says how fast a board can change.',
  hint: 'Dry is calmer. Wet has more obvious improvement paths.',
  question: 'What is the first board read?',
  feedbackTitle: 'Texture takeaway.',
  feedbackReason:
      'Read dry or wet first so the board tells you how much can change.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Texture checklist.',
      body: 'Look at rank connection and suits before choosing an action.',
      focusLabels: <String>['Ranks', 'Suits', 'Change'],
    ),
  ],
);

final _world5ConnectedIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_connected_intro',
  lessonTitle: 'Connected boards',
  caption: 'Connected ranks sit close together, like 9-8-7.',
  hint: 'Close ranks create more straight paths.',
  question: 'What makes a board connected?',
  options: const <Act0RunnerOptionV1>[],
  table: _world5WetBoardRunner.table.copyWith(centerLabel: 'Connected ranks'),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Ranks can connect.',
      body: 'Cards close in rank create more straight possibilities.',
      focusLabels: <String>['9', '8', '7', 'Connected'],
    ),
  ],
);

final _world5DisconnectedBoardRunner = _world5DryBoardRunner.copyWith(
  lessonId: 'w5_disconnected_board',
  caption: 'A-K-4 is high-card heavy but not connected.',
  hint: 'The ranks are far apart.',
  question: 'Is this board connected?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'disconnected',
      label: 'Disconnected',
      isCorrect: true,
      preferredLabel: 'Disconnected',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason: 'The ranks are far apart, so it is disconnected.',
    ),
    Act0RunnerOptionV1(
      id: 'connected',
      label: 'Connected',
      isCorrect: false,
      preferredLabel: 'Disconnected',
      betterAnswerLabel: 'Disconnected',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'Connected boards have close ranks, not big gaps.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    centerLabel: 'Disconnected',
  ),
);

final _world5ConnectedBoardRunner = _world5WetBoardRunner.copyWith(
  lessonId: 'w5_connected_board',
  caption: '9-8-7 is connected.',
  hint: 'Many nearby ranks can complete a straight.',
  question: 'What is the key board clue?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'connected_ranks',
      label: 'Connected ranks',
      isCorrect: true,
      preferredLabel: 'Connected ranks',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason: '9-8-7 are connected ranks, so straight draws are live.',
    ),
    Act0RunnerOptionV1(
      id: 'paired_board',
      label: 'Paired board',
      isCorrect: false,
      preferredLabel: 'Connected ranks',
      betterAnswerLabel: 'Connected ranks',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'A paired board repeats a rank. This board connects ranks.',
    ),
  ],
  table: _world5WetBoardRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'c'),
    ],
    centerLabel: '9-8-7',
  ),
);

final _world5ConnectedRecapRunner = _world5ConnectedIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_connected_recap',
  caption: 'Lesson learned: connected boards create straight pressure.',
  hint: 'Close ranks matter even before anyone bets.',
  question: 'What do connected ranks create?',
  feedbackTitle: 'Connected takeaway.',
  feedbackReason: 'Close ranks create more straight paths and more change.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Connected checklist.',
      body: 'If ranks sit close together, slow down and watch straight paths.',
      focusLabels: <String>['Close ranks', 'Straight path'],
    ),
  ],
);

final _world5FlushIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_flush_intro',
  lessonTitle: 'Flush draws',
  caption: 'A flush draw appears when one more suit card can help.',
  hint: 'Count suits on the board and in hand.',
  question: 'What does a flush draw need?',
  options: const <Act0RunnerOptionV1>[],
  table: _world5TextureIntroRunner.table.copyWith(
    centerLabel: 'Two hearts',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 'c'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same suit clue.',
      body:
          'When you hold two hearts and the board has hearts, more hearts matter.',
      focusLabels: <String>['Suit', 'Heart', 'Flush draw'],
    ),
  ],
);

final _world5FlushDrawRunner = _world5FlushIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_flush_draw',
  caption: 'Hero has hearts and the board has hearts.',
  hint: 'One more heart can improve Hero to a flush.',
  question: 'What draw is visible?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush_draw',
      label: 'Flush draw',
      isCorrect: true,
      preferredLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'This is a flush draw, not a flush yet. Four hearts are visible, so one more heart can complete the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'made_flush',
      label: 'Made flush',
      isCorrect: false,
      preferredLabel: 'Flush draw',
      betterAnswerLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'Not complete yet. With four hearts showing, flush pressure is live, but a made flush needs five cards of the same suit.',
    ),
    Act0RunnerOptionV1(
      id: 'straight_draw',
      label: 'Straight draw',
      isCorrect: false,
      preferredLabel: 'Flush draw',
      betterAnswerLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Suit clue first.',
      feedbackReason:
          'The visible clue is the four-heart story. Start with same-suit pressure before inventing a rank-ladder draw.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Four hearts is pressure, not a made hand.',
      body:
          'Do not stop at matching suits. Four hearts means the draw is live, and one more heart changes the hand. Until then, it is still only a draw.',
      focusLabels: <String>['Four hearts', 'Not made yet', 'One more heart'],
    ),
  ],
);

final _world5NoFlushDrawRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_no_flush_draw',
  caption: 'Hero has mixed suits and the board is rainbow.',
  hint: 'Rainbow means three different suits on the flop.',
  question: 'Is a flush draw obvious?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'no',
      label: 'No',
      isCorrect: true,
      preferredLabel: 'No',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason: 'Different suits make no obvious flush draw.',
    ),
    Act0RunnerOptionV1(
      id: 'yes',
      label: 'Yes',
      isCorrect: false,
      preferredLabel: 'No',
      betterAnswerLabel: 'No',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'A rainbow flop does not show flush pressure yet.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(centerLabel: 'Rainbow flop'),
);

final _world5FlushRecapRunner = _world5FlushIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_flush_recap',
  caption: 'Lesson learned: suits can create flush pressure.',
  hint: 'Count matching suits before calling a board safe.',
  question: 'What do you count for flush draws?',
  feedbackTitle: 'Flush takeaway.',
  feedbackReason:
      'Count suits in your hand and on the board before calling it safe.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Flush checklist.',
      body: 'Same-suit cards show whether one more suit can change the hand.',
      focusLabels: <String>['Suits', 'One more card'],
    ),
  ],
);

final _world5MadeHandVsFlushDrawTransferRunner = _world5FlushDrawRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_made_hand_vs_flush_draw_transfer',
  caption:
      'Real table. Hero holds A-spade and J-club on A-heart, 8-heart, 4-club.',
  hint:
      'Name what is already real now, then name the draw pressure that can still change the turn or river.',
  question: 'What is the clean read first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'made_hand_with_draw_pressure',
      label:
          'Hero already has top pair, and the heart draw is still only pressure',
      isCorrect: true,
      preferredLabel:
          'Hero already has top pair, and the heart draw is still only pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct transfer.',
      feedbackReason:
          'Hero already has top pair. The heart draw matters, but it is not a made flush yet, so the clean read starts with the made hand plus future draw pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'made_flush_now',
      label: 'The heart draw is already a made flush',
      isCorrect: false,
      preferredLabel:
          'Hero already has top pair, and the heart draw is still only pressure',
      betterAnswerLabel:
          'Hero already has top pair, and the heart draw is still only pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not made yet.',
      feedbackReason:
          'Two hearts on the board create pressure, but that is not a made flush yet. The draw is still future potential, not current value.',
    ),
    Act0RunnerOptionV1(
      id: 'draw_means_pair_does_not_count',
      label: 'The draw matters, so the pair does not count yet',
      isCorrect: false,
      preferredLabel:
          'Hero already has top pair, and the heart draw is still only pressure',
      betterAnswerLabel:
          'Hero already has top pair, and the heart draw is still only pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Current hand first.',
      feedbackReason:
          'The draw matters because later cards can change the danger, but Hero still has a real made hand right now. Start with what already exists on the flop.',
    ),
  ],
  table: _world5FlushDrawRunner.table.copyWith(
    potLabel: 'Pot 8 BB',
    centerLabel: 'Top pair, heart draw live',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'c'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    highlightedCardIds: const <String>['hero_0', 'board_0', 'board_1'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Made hand first, draw pressure second.',
      body:
          'Top pair is already real. The two-heart board adds future pressure, but it does not erase the made hand or turn the draw into a finished flush.',
      focusLabels: <String>['Top pair', 'Two hearts', 'Not made yet'],
    ),
  ],
);

final _world5FlushDrawRecheckTransferRunner = _world5FlushDrawRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_flush_draw_recheck_transfer',
  caption: 'Hero holds Q-heart and 7-heart on A-heart, 8-club, 2-heart.',
  hint:
      'Use the visible hearts on the table first. One more heart can change the hand, but it has not arrived yet.',
  question: 'What is true right now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flush_draw_only',
      label: 'Hero has a flush draw, not a made flush yet',
      isCorrect: true,
      preferredLabel: 'Hero has a flush draw, not a made flush yet',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct recovery.',
      feedbackReason:
          'There are four hearts visible, so Hero is one heart short of a flush. That keeps the hand in draw territory until one more heart appears.',
    ),
    Act0RunnerOptionV1(
      id: 'made_flush_now',
      label: 'Hero already has a made flush',
      isCorrect: false,
      preferredLabel: 'Hero has a flush draw, not a made flush yet',
      betterAnswerLabel: 'Hero has a flush draw, not a made flush yet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Still one card short.',
      feedbackReason:
          'Four hearts create strong pressure, but four hearts are still not a made flush yet. Hero needs one more heart before calling it complete.',
    ),
    Act0RunnerOptionV1(
      id: 'no_flush_pressure',
      label: 'There is no flush pressure yet',
      isCorrect: false,
      preferredLabel: 'Hero has a flush draw, not a made flush yet',
      betterAnswerLabel: 'Hero has a flush draw, not a made flush yet',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Count the hearts.',
      feedbackReason:
          'The visible table already shows four hearts between Hero and the board. That creates real flush pressure even though the flush is not made yet.',
    ),
  ],
  table: _world5FlushDrawRunner.table.copyWith(
    potLabel: 'Pot 7 BB',
    centerLabel: 'Four hearts, not home yet',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '8', suit: 'c'),
      Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
    ],
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_2',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Four same-suit cards still mean draw, not made hand.',
      body:
          'Count the visible hearts before naming the hand. Four hearts mean one more heart can complete the flush, but the flush is not real yet.',
      focusLabels: <String>['Four hearts', 'One more heart', 'Not made yet'],
    ),
  ],
);

final _world5StraightIntroRunner = _world5ConnectedIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_straight_intro',
  lessonTitle: 'Straight draws',
  caption: 'A straight draw uses nearby ranks to chase a five-card line.',
  hint: 'Look for rank ladders.',
  question: 'What does a straight draw use?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Rank ladder.',
      body: 'Straight pressure comes from nearby ranks, not suits.',
      focusLabels: <String>['Ranks', 'Ladder', 'Straight draw'],
    ),
  ],
);

final _world5StraightDrawRunner = _world5StraightIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_straight_draw',
  caption: 'Hero has 6-5 and the board shows 8-7-2.',
  hint: 'A 4 or 9 can improve the rank ladder.',
  question: 'What draw is visible?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'straight_draw',
      label: 'Straight draw',
      isCorrect: true,
      preferredLabel: 'Straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason: 'Nearby ranks create straight outs.',
    ),
    Act0RunnerOptionV1(
      id: 'flush_draw',
      label: 'Flush draw',
      isCorrect: false,
      preferredLabel: 'Straight draw',
      betterAnswerLabel: 'Straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'The clue is rank connection, not matching suits.',
    ),
  ],
  table: _world5ConnectedIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '6', suit: 's'),
      Act0CardStateV1(rank: '5', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '8', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 's'),
    ],
    centerLabel: '4 or 9 helps',
  ),
);

final _world5GutshotDrawRunner = _world5StraightIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_gutshot_draw',
  caption: 'Hero has 9-8 and the board shows K-7-5.',
  hint: 'Only a 6 completes the missing middle rank.',
  question: 'What draw is visible?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'gutshot',
      label: 'Gutshot straight draw',
      isCorrect: true,
      preferredLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exact read.',
      feedbackReason:
          'This is a gutshot. 5-7-8-9 are close, but only the 6 fills the missing middle rank.',
    ),
    Act0RunnerOptionV1(
      id: 'open_ended',
      label: 'Open-ended straight draw',
      isCorrect: false,
      preferredLabel: 'Gutshot straight draw',
      betterAnswerLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close, but too wide.',
      feedbackReason:
          'Open-ended draws improve from either end. Here only the 6 works, so the draw is narrower than open-ended.',
    ),
    Act0RunnerOptionV1(
      id: 'made_straight',
      label: 'Made straight',
      isCorrect: false,
      preferredLabel: 'Gutshot straight draw',
      betterAnswerLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not complete yet.',
      feedbackReason:
          'The straight is not complete yet. The board and hand still miss the 6, so this stays a draw, not a made hand.',
    ),
  ],
  table: _world5StraightIntroRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '5', suit: 's'),
    ],
    centerLabel: 'Only a 6 helps',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Gutshot means one middle card is missing.',
      body:
          'A gutshot is still a straight draw, but it is thinner than open-ended. Read the exact missing rank before acting like the straight is already there.',
      focusLabels: <String>['Gutshot', 'Only 6', 'Not complete yet'],
    ),
  ],
);

final _world5GutshotContrastTransferRunner = _world5GutshotDrawRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_gutshot_contrast_transfer',
  caption: 'Hero has 9-8 and the board shows Q-7-5.',
  hint:
      'Read the exact missing rank before upgrading the draw. A gutshot is narrower than open-ended and still not a made straight.',
  question: 'What is the clean read now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'gutshot',
      label: 'Gutshot straight draw',
      isCorrect: true,
      preferredLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct transfer.',
      feedbackReason:
          'Only the 6 completes the middle rank, so this stays a gutshot. The straight is close, but it is not open-ended and not complete yet.',
    ),
    Act0RunnerOptionV1(
      id: 'open_ended',
      label: 'Open-ended straight draw',
      isCorrect: false,
      preferredLabel: 'Gutshot straight draw',
      betterAnswerLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too many outs claimed.',
      feedbackReason:
          'Open-ended draws improve from either end. Here only the 6 works, so the board does not give Hero either-end improvement.',
    ),
    Act0RunnerOptionV1(
      id: 'made_straight',
      label: 'Made straight',
      isCorrect: false,
      preferredLabel: 'Gutshot straight draw',
      betterAnswerLabel: 'Gutshot straight draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not there yet.',
      feedbackReason:
          'Hero still needs the 6 to finish five in a row. Until that card arrives, the straight is future potential, not a made hand.',
    ),
  ],
  table: _world5GutshotDrawRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Only a 6 fits',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '5', suit: 's'),
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Name the exact draw before acting on it.',
      body:
          'A gutshot uses one missing middle rank. If only the 6 completes the line, do not upgrade the hand into open-ended or treat it like a made straight.',
      focusLabels: <String>['Only 6', 'Gutshot', 'Not made yet'],
    ),
  ],
);

final _world5GapBoardRunner = _world5StraightIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_gap_board',
  caption: 'A-Q-4 has large rank gaps.',
  hint: 'Big gaps mean no obvious straight draw.',
  question: 'Is straight pressure obvious?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'no',
      label: 'No',
      isCorrect: true,
      preferredLabel: 'No',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Discipline: open strong late.',
      feedbackReason:
          'The ranks are too far apart for an obvious straight path.',
    ),
    Act0RunnerOptionV1(
      id: 'yes',
      label: 'Yes',
      isCorrect: false,
      preferredLabel: 'No',
      betterAnswerLabel: 'No',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'Straight pressure needs closer ranks.',
    ),
  ],
  table: _world5DisconnectedBoardRunner.table.copyWith(centerLabel: 'Big gaps'),
);

final _world5StraightRecapRunner = _world5StraightIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_straight_recap',
  caption: 'Lesson learned: straight draws are rank stories.',
  hint: 'Suits do not make straights. Nearby ranks do.',
  question: 'What do you inspect for straight draws?',
  feedbackTitle: 'Straight takeaway.',
  feedbackReason: 'Look for nearby ranks that can form a five-card line.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Straight checklist.',
      body: 'Find nearby ranks, then ask which next cards complete the line.',
      focusLabels: <String>['Nearby ranks', 'Outs'],
    ),
  ],
);

final _world5OutsIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_outs_intro',
  lessonTitle: 'Outs as improvement cards',
  caption: 'Outs are cards that can improve your hand.',
  hint: 'At this level, just name the kind of card that helps.',
  question: 'What is an out?',
  options: const <Act0RunnerOptionV1>[],
  table: _world5StraightDrawRunner.table.copyWith(centerLabel: 'Outs help'),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Outs are helpers.',
      body: 'An out is a future card that can improve your hand.',
      focusLabels: <String>['Future card', 'Improve', 'Out'],
    ),
  ],
);

final _world5FlushOutRunner = _world5FlushDrawRunner.copyWith(
  lessonId: 'w5_flush_out',
  caption: 'Hero needs one more heart.',
  hint: 'Any heart is the improvement card type.',
  question: 'Which card type is the out?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart',
      label: 'Heart',
      isCorrect: true,
      preferredLabel: 'Heart',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'A heart can complete the flush.',
    ),
    Act0RunnerOptionV1(
      id: 'club',
      label: 'Club',
      isCorrect: false,
      preferredLabel: 'Heart',
      betterAnswerLabel: 'Heart',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason: 'The flush path is hearts, so hearts are the outs.',
    ),
  ],
);

final _world5StraightOutRunner = _world5StraightDrawRunner.copyWith(
  lessonId: 'w5_straight_out',
  caption: 'With 6-5 on 8-7-2, a 4 or 9 helps.',
  hint: 'Those cards complete the straight line.',
  question: 'Which out improves Hero?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'nine',
      label: '9',
      isCorrect: true,
      preferredLabel: '9',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason: 'With 5-6-7-8 on board, any 9 completes the straight.',
    ),
    Act0RunnerOptionV1(
      id: 'king',
      label: 'K',
      isCorrect: false,
      preferredLabel: '9',
      betterAnswerLabel: '9',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'A king does not connect this rank ladder.',
    ),
  ],
);

final _world5OutsRecapRunner = _world5OutsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_outs_recap',
  caption: 'Lesson learned: outs are improvement cards.',
  hint: 'Name what can help before paying a price.',
  question: 'What is an out?',
  feedbackTitle: 'Outs takeaway.',
  feedbackReason:
      'An out is a card that can improve the hand on a later street.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Outs checklist.',
      body: 'Ask what future card improves you, then decide if the price fits.',
      focusLabels: <String>['Improve', 'Future card', 'Price'],
    ),
  ],
);

final _world5TableOutsFlushTransferRunner = _world5FlushOutRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_table_outs_flush_transfer',
  caption:
      'Real table. Pot 10 BB. Hero has A-heart and 7-heart on T-heart, 4-heart, 2-club, 9-spade.',
  hint:
      'Before calling a small bet, name the live improvement cards that still help.',
  question: 'Which improvement cards still matter first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart_outs',
      label: 'Any heart still completes the flush',
      isCorrect: true,
      preferredLabel: 'Any heart still completes the flush',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Live outs first.',
      feedbackReason:
          'That is the clean transfer. Hero still has heart outs, so naming those improvement cards comes before judging whether the 2 BB price is worth it in a 10 BB pot.',
    ),
    Act0RunnerOptionV1(
      id: 'ace_only',
      label: 'Only an ace matters now',
      isCorrect: false,
      preferredLabel: 'Any heart still completes the flush',
      betterAnswerLabel: 'Any heart still completes the flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too narrow.',
      feedbackReason:
          'The live draw story still matters more. Hearts are the real outs here, so start by naming the flush improvement cards before inventing a one-pair rescue line.',
    ),
    Act0RunnerOptionV1(
      id: 'price_only',
      label: 'Only the small price matters',
      isCorrect: false,
      preferredLabel: 'Any heart still completes the flush',
      betterAnswerLabel: 'Any heart still completes the flush',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Sequence first.',
      feedbackReason:
          'Price matters after the draw read. On a real table, name the heart outs first, then decide whether paying 2 BB into Pot 10 BB is worth it.',
    ),
  ],
  table: _world5FlushDrawRunner.table.copyWith(
    streetLabel: 'Turn',
    potLabel: 'Pot 10 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Live heart outs',
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 's'),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Flop: heart draw live'),
      Act0ActionTrailItemV1(label: 'Turn: 9 spades'),
      Act0ActionTrailItemV1(label: 'BB bets 2 BB'),
      Act0ActionTrailItemV1(label: 'Hero acts'),
    ],
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Name outs before price.',
      body:
          'A live table adds pressure, but the same transfer rule still holds: name the cards that improve Hero first, then judge the price.',
      focusLabels: <String>['Real table', 'Heart outs', 'Price second'],
    ),
  ],
);

final _world5CleanVsRiskyOutTransferRunner = _world5TableOutsStraightTransferRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_clean_vs_risky_out_transfer',
  caption:
      'Real table. Turn board shows A-heart, 7-heart, 6-club, 2-diamond. Hero has 9-spade and 8-diamond.',
  hint:
      'Both a 5-club and a 5-heart complete Hero straight. Ask which one helps more cleanly and which one adds extra board danger.',
  question: 'Which river is the safer out for Hero?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'five_clubs_cleaner',
      label: '5-club is safer',
      isCorrect: true,
      preferredLabel: '5-club is safer',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct intro read.',
      feedbackReason:
          'Both cards complete the straight, but 5-club is safer because it helps Hero without adding a third heart. The straight is real either way, but this river keeps the board calmer.',
    ),
    Act0RunnerOptionV1(
      id: 'five_hearts_riskier',
      label: '5-heart is just as clean',
      isCorrect: false,
      preferredLabel: '5-club is safer',
      betterAnswerLabel: '5-club is safer',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'It still helps, but it is riskier.',
      feedbackReason:
          '5-heart still completes Hero straight, so it is not useless. But it is riskier because it also adds a third heart to the board, which makes the river more dangerous than 5-club.',
    ),
    Act0RunnerOptionV1(
      id: 'neither_helps',
      label: 'Neither card helps yet',
      isCorrect: false,
      preferredLabel: '5-club is safer',
      betterAnswerLabel: '5-club is safer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'The straight really does complete.',
      feedbackReason:
          'Hero already has 9-8 with 7-6 on the board, so any 5 completes the straight. The beginner question is not whether Hero improves, but which completing card is safer.',
    ),
  ],
  table: _world5TableOutsStraightTransferRunner.table.copyWith(
    potLabel: 'Pot 9 BB',
    toCallLabel: 'River preview',
    centerLabel: 'Some outs are safer',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '6', suit: 'c'),
      Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Flop: A hearts, 7 hearts, 6 clubs'),
      Act0ActionTrailItemV1(label: 'Turn: 2 diamonds'),
      Act0ActionTrailItemV1(label: 'River can bring a 5'),
      Act0ActionTrailItemV1(label: 'Hero compares safer vs riskier'),
    ],
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_1',
      'board_2',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Not every helping card is equally clean.',
      body:
          'A card can improve Hero and still make the board more dangerous. Start with simple language: safer out when the board stays calmer, riskier out when the board adds new danger.',
      focusLabels: <String>['Safer card', 'Riskier card', 'Third heart'],
    ),
  ],
);

final _world5TableOutsStraightTransferRunner = _world5StraightOutRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_table_outs_straight_transfer',
  caption:
      'Real table. Pot 9 BB. Hero has 6-spade and 5-diamond on 8-club, 7-heart, 2-spade, K-diamond.',
  hint:
      'Keep the same rank ladder and ask which cards still finish it on a live turn.',
  question: 'Which improvement cards still matter first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'four_or_nine',
      label: 'A 4 or 9 still completes the straight',
      isCorrect: true,
      preferredLabel: 'A 4 or 9 still completes the straight',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Correct transfer.',
      feedbackReason:
          'The same ladder still works on a real table. A 4 or 9 completes the straight, so those remain the live outs before you judge the 3 BB decision.',
    ),
    Act0RunnerOptionV1(
      id: 'king_pairs',
      label: 'Only a king can help now',
      isCorrect: false,
      preferredLabel: 'A 4 or 9 still completes the straight',
      betterAnswerLabel: 'A 4 or 9 still completes the straight',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong improvement story.',
      feedbackReason:
          'Pairing the king is not the draw lesson here. The transfer is keep the same straight ladder and name the 4 or 9 outs first.',
    ),
    Act0RunnerOptionV1(
      id: 'blank_turn_killed',
      label: 'Blank turn means give up',
      isCorrect: false,
      preferredLabel: 'A 4 or 9 still completes the straight',
      betterAnswerLabel: 'A 4 or 9 still completes the straight',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Do not drop the ladder.',
      feedbackReason:
          'A blank turn does not erase the draw. The live-table transfer is keep following the same 4 or 9 straight outs before making the next choice.',
    ),
  ],
  table: _world5StraightDrawRunner.table.copyWith(
    streetLabel: 'Turn',
    potLabel: 'Pot 9 BB',
    toCallLabel: 'To call 3 BB',
    centerLabel: 'Live straight outs',
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '8', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 's'),
      Act0CardStateV1(rank: 'K', suit: 'd', tone: Act0CardToneV1.red),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Flop: 8-7-2'),
      Act0ActionTrailItemV1(label: 'Turn: K diamonds'),
      Act0ActionTrailItemV1(label: 'BTN bets 3 BB'),
      Act0ActionTrailItemV1(label: 'Hero acts'),
    ],
    highlightedCardIds: const <String>[
      'hero_0',
      'hero_1',
      'board_0',
      'board_1',
    ],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Blank turns do not erase outs.',
      body:
          'A live turn card can miss without killing the draw. Keep the same straight ladder in mind and name the 4 or 9 outs before deciding.',
      focusLabels: <String>['Real table', 'Rank ladder', '4 or 9'],
    ),
  ],
);

final _world5StreetChangeIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w5_street_change_intro',
  lessonTitle: 'Turn and river changes',
  caption: 'Turn and river can complete draws or miss them.',
  hint: 'Read the same draw story again after each new street card.',
  question: 'What changes after the flop?',
  options: const <Act0RunnerOptionV1>[],
  table: _turnBoardRunner.table.copyWith(
    centerLabel: 'Turn changes',
    potLabel: 'Pot 7 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'One card can matter.',
      body:
          'The turn and river each add one shared card. Re-read the same board: did the draw hit, miss, or become stronger?',
      focusLabels: <String>['Turn', 'River', 'Draw story'],
    ),
  ],
);

final _world5TurnHitsRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_turn_hits',
  caption: 'The turn brings a heart. The same flush story now completes.',
  hint:
      'The next street did not start a new story. It finished the heart draw.',
  question: 'What happened on the turn?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'draw_hit',
      label: 'Draw hit',
      isCorrect: true,
      preferredLabel: 'Draw hit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'The new heart completes the same flush draw you were already tracking on the flop.',
    ),
    Act0RunnerOptionV1(
      id: 'blank',
      label: 'Blank',
      isCorrect: false,
      preferredLabel: 'Draw hit',
      betterAnswerLabel: 'Draw hit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'A heart is not blank when the flop already showed a live heart draw.',
    ),
  ],
  table: _world5FlushIntroRunner.table.copyWith(
    streetLabel: 'Turn',
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
    ],
    centerLabel: 'Heart lands',
  ),
);

final _world5RiverMissesRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_river_misses',
  caption: 'The river is a black 2. The same heart story now misses.',
  hint: 'The river did not help the draw you were tracking.',
  question: 'What happened by the river?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'draw_missed',
      label: 'Draw missed',
      isCorrect: true,
      preferredLabel: 'Draw missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'The final card did not complete the same flush draw, so the story ends as a miss.',
    ),
    Act0RunnerOptionV1(
      id: 'draw_hit',
      label: 'Draw hit',
      isCorrect: false,
      preferredLabel: 'Draw missed',
      betterAnswerLabel: 'Draw missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'No heart arrived on the river, so the tracked heart draw stayed incomplete.',
    ),
  ],
  table: _world5FlushIntroRunner.table.copyWith(
    streetLabel: 'River',
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
    ],
    centerLabel: 'Draw missed',
  ),
);

final _world5StreetRepairRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_street_repair',
  caption:
      'The turn connected the board, but hero still treats one pair like the flop stayed easy.',
  hint: 'Repair the street-change read before repeating the flop plan.',
  question: 'What needs fixing first?',
  feedbackTitle: 'Repair the street read.',
  feedbackReason:
      'When a turn card changes the draw story, thin one-pair plans need more caution. Repair the board read before copying the flop line.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'repair_story',
      label:
          'The board got more dangerous, so the old easy-value story needs caution',
      isCorrect: true,
      preferredLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice repair.',
      feedbackReason:
          'That is the fix. The new card changed the board story, so action should respect the new pressure instead of replaying the old one.',
    ),
    Act0RunnerOptionV1(
      id: 'same_story',
      label: 'Nothing changed, so keep the same flop plan',
      isCorrect: false,
      preferredLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      betterAnswerLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'Street-change worlds exist because later cards really do change the draw story. Ignoring the turn is the leak.',
    ),
    Act0RunnerOptionV1(
      id: 'small_same_story',
      label: 'Bet smaller but keep the same old story',
      isCorrect: false,
      preferredLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      betterAnswerLabel:
          'The board got more dangerous, so the old easy-value story needs caution',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable patch.',
      feedbackReason:
          'Changing the size without repairing the board story still leaves the core read behind.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair story before line.',
      body:
          'Turn and river are not cosmetic. If the board got more connected or completed a draw, re-read the whole story before acting.',
      focusLabels: <String>['Turn change', 'Repair read', 'One-pair caution'],
    ),
  ],
);

final _world5TurnTextureShiftTransferRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_turn_texture_shift_transfer',
  caption:
      'Real table. Flop K-9-2 looked calm, but the turn brings the T of hearts.',
  hint:
      'Do not replay the flop read. Ask what the new turn card changed first.',
  question: 'What changed first on the turn?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'board_got_wetter',
      label: 'The board got wetter and more connected',
      isCorrect: true,
      preferredLabel: 'The board got wetter and more connected',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean transfer read.',
      feedbackReason:
          'That is the first real-table update. top pair is still real, but the heart and connected turn card make the same board more dangerous before you copy the flop plan.',
    ),
    Act0RunnerOptionV1(
      id: 'nothing_changed',
      label: 'Nothing changed, so keep the same easy plan',
      isCorrect: false,
      preferredLabel: 'The board got wetter and more connected',
      betterAnswerLabel: 'The board got wetter and more connected',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more street read.',
      feedbackReason:
          'Turn cards are not cosmetic. The new card changes texture and future-card pressure, so the flop story cannot stay frozen.',
    ),
    Act0RunnerOptionV1(
      id: 'size_only_changed',
      label: 'Only the bet size matters now',
      isCorrect: false,
      preferredLabel: 'The board got wetter and more connected',
      betterAnswerLabel: 'The board got wetter and more connected',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Part of the picture.',
      feedbackReason:
          'Size matters, but not before the board read. The turn changed texture first, so action should start from that update.',
    ),
  ],
  table: _world5StreetChangeIntroRunner.table.copyWith(
    streetLabel: 'Turn',
    potLabel: 'Pot 8 BB',
    centerLabel: 'Turn texture shift',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 's'),
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BB checks flop'),
      Act0ActionTrailItemV1(label: 'BTN bets'),
      Act0ActionTrailItemV1(label: 'BB calls'),
      Act0ActionTrailItemV1(label: 'Turn: T hearts'),
    ],
    highlightedCardIds: const <String>['board_1', 'board_3'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Street changes can change texture.',
      body:
          'On a real table, a turn card can make the same board wetter, more connected, and less comfortable for one-pair autopilot. top pair can stay ahead while still needing more caution.',
      focusLabels: <String>[
        'Real table',
        'Turn card',
        'Wetter board',
        'Reconnect the story',
      ],
    ),
  ],
);

final _world5RiverDrawStoryTransferRunner = _world5StreetChangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w5_river_draw_story_transfer',
  caption:
      'Real table. The flop and turn showed a heart draw, but the river bricks with the black 3.',
  hint:
      'Keep the same draw story in mind and decide whether it finished or missed.',
  question: 'What is the clean river read first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'draw_missed_story',
      label: 'The same draw story missed',
      isCorrect: true,
      preferredLabel: 'The same draw story missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Exactly.',
      feedbackReason:
          'No heart arrived, so the same draw story missed. The clean read is keep the same story all the way to the river instead of inventing a new one.',
    ),
    Act0RunnerOptionV1(
      id: 'river_restarts_story',
      label: 'The river starts a new story from zero',
      isCorrect: false,
      preferredLabel: 'The same draw story missed',
      betterAnswerLabel: 'The same draw story missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too disconnected.',
      feedbackReason:
          'River reads do not reset the hand. The right transfer is keep following the same draw story and mark it as a miss when the suit never lands.',
    ),
    Act0RunnerOptionV1(
      id: 'draw_hit_anyway',
      label: 'The draw probably got there anyway',
      isCorrect: false,
      preferredLabel: 'The same draw story missed',
      betterAnswerLabel: 'The same draw story missed',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting shortcut.',
      feedbackReason:
          'That guess skips the board. The clean recheck is simpler: no heart means the same draw story missed.',
    ),
  ],
  table: _world5StreetChangeIntroRunner.table.copyWith(
    streetLabel: 'River',
    potLabel: 'Pot 10 BB',
    centerLabel: 'River draw story',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 'c'),
      Act0CardStateV1(rank: '9', suit: 's'),
      Act0CardStateV1(rank: '3', suit: 'c'),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Flop: heart draw live'),
      Act0ActionTrailItemV1(label: 'Turn: draw still live'),
      Act0ActionTrailItemV1(label: 'River: black 3'),
    ],
    highlightedCardIds: const <String>['board_0', 'board_1', 'board_4'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'One draw story across all streets.',
      body:
          'Do not start over on the river. Follow the same draw story through flop, turn, and river, then say clearly whether it hit or missed.',
      focusLabels: <String>['Same story', 'Flop-turn-river', 'Hit or missed'],
    ),
  ],
);

final _world5BoardCheckpointRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w5_board_checkpoint',
  lessonTitle: 'Turn and river changes',
  caption: 'Lesson learned: board reading starts before the action.',
  hint: 'Board first. Action second.',
  question: 'What is the World 5 read?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'texture_draw_outs',
      label: 'Texture, draw, outs',
      isCorrect: true,
      preferredLabel: 'Texture, draw, outs',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Board reading starts with texture, visible draws, and improvement cards. Next, you will group hands into simple ranges.',
    ),
    Act0RunnerOptionV1(
      id: 'just_outs',
      label: 'Just count outs',
      isCorrect: false,
      preferredLabel: 'Texture, draw, outs',
      betterAnswerLabel: 'Texture, draw, outs',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Counting outs is a real skill, but texture and draws round out the full board read.',
    ),
    Act0RunnerOptionV1(
      id: 'random_guess',
      label: 'Random guess',
      isCorrect: false,
      preferredLabel: 'Texture, draw, outs',
      betterAnswerLabel: 'Texture, draw, outs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason: 'The board gives clues before you guess.',
    ),
  ],
  feedbackTitle: 'Board takeaway.',
  feedbackReason:
      'Texture, draws, outs, and later streets explain how the board changes.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 5 checkpoint.',
      body:
          'Pause the board, name texture, find draws, then re-read the same story when the next card lands.',
      focusLabels: <String>['Texture', 'Draws', 'Outs', 'Street change'],
    ),
  ],
);

final _world6RangeCheckpointRunner = _world5BoardCheckpointRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_range_checkpoint',
  lessonTitle: 'Range thinking checkpoint',
  caption: 'Lesson learned: range buckets need board-fit context.',
  hint: 'Bucket first, board fit second, stack depth next.',
  question: 'What carries this read into World 8?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'range_plus_stack_depth',
      label: 'Range plus stack depth',
      isCorrect: true,
      preferredLabel: 'Range plus stack depth',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Range buckets map likely hands, and stack depth sets the risk profile for those hands.',
    ),
    Act0RunnerOptionV1(
      id: 'range_only',
      label: 'Range only',
      isCorrect: false,
      preferredLabel: 'Range plus stack depth',
      betterAnswerLabel: 'Range plus stack depth',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Range reading is a real step, but depth changes how much pressure each range can absorb.',
    ),
    Act0RunnerOptionV1(
      id: 'guess_line',
      label: 'Guess the line',
      isCorrect: false,
      preferredLabel: 'Range plus stack depth',
      betterAnswerLabel: 'Range plus stack depth',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'Clean planning comes from range + texture + stack depth, not guessing.',
    ),
  ],
  feedbackTitle: 'Range takeaway.',
  feedbackReason:
      'Use bucketed ranges with board texture first, then carry the read into stack-depth risk decisions.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'World 7 checkpoint.',
      body:
          'Group hands into ranges, fit them to texture, then adjust risk by stack depth.',
      focusLabels: <String>['Range buckets', 'Texture fit', 'Stack depth'],
    ),
  ],
);

final _w6WetBoardRepairRunner = _w6WrongBoardRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_wet_board_repair',
  lessonTitle: 'Range meets board',
  lessonSubtitle: 'Range Thinking Lite',
  caption:
      'Turn card connected the board, but hero still treats one pair like the flop stayed dry.',
  hint: 'Repair the board read before forcing the same old action.',
  question: 'What needs fixing first?',
  feedbackTitle: 'Repair the board read.',
  feedbackReason:
      'When the board gets wetter, thin value and easy bets need more caution. Repair the texture read before repeating the flop plan.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'respect_wetter_board',
      label: 'The board got wetter, so the old thin-value plan needs caution',
      isCorrect: true,
      preferredLabel:
          'The board got wetter, so the old thin-value plan needs caution',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice repair.',
      feedbackReason:
          'That is the fix. Connected turn cards can shift one-pair hands away from easy value and toward more disciplined control.',
    ),
    Act0RunnerOptionV1(
      id: 'nothing_changed',
      label: 'Nothing changed, keep the same dry-board plan',
      isCorrect: false,
      preferredLabel:
          'The board got wetter, so the old thin-value plan needs caution',
      betterAnswerLabel:
          'The board got wetter, so the old thin-value plan needs caution',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'The new turn card changed how many stronger and drawing hands can exist. Treating it like the same dry board is the leak.',
    ),
    Act0RunnerOptionV1(
      id: 'smaller_same_story',
      label: 'Bet smaller but keep the same dry-board story',
      isCorrect: false,
      preferredLabel:
          'The board got wetter, so the old thin-value plan needs caution',
      betterAnswerLabel:
          'The board got wetter, so the old thin-value plan needs caution',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable patch.',
      feedbackReason:
          'Changing the size is not enough if the board read is still wrong. Repair the story first, then choose the line.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Repair story before line.',
      body:
          'Board texture changed. Fix the story first, then decide whether the old value plan still belongs.',
      focusLabels: <String>['Wet turn', 'Repair read', 'One pair caution'],
    ),
  ],
);

// ── W6: Range Thinking Lite — fresh runners ──────────────────────────────

final _w6RangeIntroRunner = _world5TextureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_range_intro',
  lessonTitle: 'Range buckets',
  lessonSubtitle: 'Range Thinking Lite',
  caption: 'A range is the group of hands that fit a situation.',
  hint: 'Value, bluff candidate, and missed are the three range buckets.',
  question: 'What are range buckets?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Three buckets.',
      body:
          'After the flop, sort your hand into value (can bet for profit), '
          'bluff candidate (can create fold pressure), or missed (no plan).',
      focusLabels: <String>['Value', 'Bluff candidate', 'Missed'],
    ),
  ],
);

// K-7-2 rainbow: hero has KQ → value range (top pair, good kicker)
final _w6ValueDryBoardRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_value_dry_board',
  caption: 'K-7-2 rainbow. Hero holds K-Q.',
  hint: 'Top pair with the best possible kicker.',
  question: 'Which range bucket is K-Q on this board?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: true,
      preferredLabel: 'Value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Top pair with the top kicker is a strong value hand on this dry board.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'K-Q hit the king. Bluff candidates are hands that missed and can still fold opponents out.',
    ),
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'K-Q flopped top pair. Missed hands do not connect to the board at all.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(centerLabel: 'Range bucket?'),
);

// K-7-2 rainbow: hero has J-T → missed, but bluff-candidate is suboptimal
final _w6MissedDryBoardRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_missed_dry_board',
  caption: 'Same K-7-2 rainbow. Hero holds J-T.',
  hint: 'No pair, no draw on a dry board.',
  question: 'Which range bucket is J-T on this board?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: true,
      preferredLabel: 'Missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Missed: no pair, no draw.',
      feedbackReason:
          'J-T has no pair and no clear draw on K-7-2. It is in the missed bucket.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: false,
      preferredLabel: 'Missed',
      betterAnswerLabel: 'Missed',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable read.',
      feedbackReason:
          'J-T can bluff sometimes, but on a dry board with no equity it is mostly missed '
          'rather than a strong bluff candidate.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: false,
      preferredLabel: 'Missed',
      betterAnswerLabel: 'Missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'Value hands connect to the board. J-T has no pair or flush draw here.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(centerLabel: 'Range bucket?'),
);

final _w6TableBucketNoticeRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_table_bucket_notice',
  caption: 'Real table. K-7-2 rainbow lands and you hold A-Q.',
  hint: 'Before picking a size, make the first useful read.',
  question: 'What should you ask first?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bucket_first',
      label: 'Which bucket is my hand in?',
      isCorrect: true,
      preferredLabel: 'Which bucket is my hand in?',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice start.',
      feedbackReason:
          'That is the clean live-table transfer. Bucket first, then action.',
    ),
    Act0RunnerOptionV1(
      id: 'size_first',
      label: 'What size should I bet right now?',
      isCorrect: false,
      preferredLabel: 'Which bucket is my hand in?',
      betterAnswerLabel: 'Which bucket is my hand in?',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too fast.',
      feedbackReason:
          'Size comes after the bucket. First decide if the hand is value, bluff candidate, or missed.',
    ),
    Act0RunnerOptionV1(
      id: 'preflop_only',
      label: 'Was this hand strong preflop?',
      isCorrect: false,
      preferredLabel: 'Which bucket is my hand in?',
      betterAnswerLabel: 'Which bucket is my hand in?',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Useful start.',
      feedbackReason:
          'Preflop strength matters, but the flop bucket is the first sharp live-table read now.',
    ),
  ],
);

final _w6BucketsRecapRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_buckets_recap',
  caption: 'Lesson learned: range buckets start with board fit.',
  hint: 'Ask which bucket before choosing an action.',
  question: 'Which range bucket reads the board first?',
  feedbackTitle: 'Buckets takeaway.',
  feedbackReason:
      'Value, bluff candidate, and missed. Board fit decides which bucket your hand lands in.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket before action.',
      body:
          'Assign your hand to a range bucket before choosing to bet, check, or fold.',
      focusLabels: <String>['Value', 'Bluff candidate', 'Missed', 'Board fit'],
    ),
  ],
);

// Board-fit lesson: 8-7-6 two-tone board ─────────────────────────────────

final _w6BoardFitIntroRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_board_fit_intro',
  lessonTitle: 'Range meets board',
  caption: 'Board texture can shift a hand from value to missed.',
  hint: 'The same hand can be value on one board and missed on another.',
  question: 'What changes a hand\'s range bucket?',
  options: const <Act0RunnerOptionV1>[],
  table: _w6RangeIntroRunner.table.copyWith(
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '6', suit: 'c'),
    ],
    centerLabel: 'Range shift',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board changes the bucket.',
      body:
          'A preflop strong hand can become missed if it does not connect with the flop.',
      focusLabels: <String>['Board fit', 'Value', 'Missed', 'Texture'],
    ),
  ],
);

// 8-7-6 two-tone: hero has K-Q (no pair, no draw) → missed, bluff-candidate suboptimal
final _w6WrongBoardRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_wrong_board',
  caption: '8-7-6 two-tone. Hero holds K-Q.',
  hint: 'K-Q was strong preflop, but this board changed everything.',
  question: 'Which range bucket is K-Q on 8-7-6?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: true,
      preferredLabel: 'Missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'K-Q has no pair and no draw on 8-7-6. It missed this board completely.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: false,
      preferredLabel: 'Missed',
      betterAnswerLabel: 'Missed',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable read.',
      feedbackReason:
          'K-Q can bluff sometimes on wet boards, but with two overcards and no '
          'backdoor draws it leans more toward missed.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: false,
      preferredLabel: 'Missed',
      betterAnswerLabel: 'Missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'K-Q did not pair on 8-7-6. Only hands that connect to the board '
          'carry value betting equity.',
    ),
  ],
);

// 8-7-6 two-tone: hero has 9-8 (two pair) → value range
final _w6ValueWetBoardRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_value_wet_board',
  caption: 'Same 8-7-6 two-tone. Hero holds 9-8.',
  hint: '9-8 flopped two pair on a connected board.',
  question: 'Which range bucket is 9-8 on 8-7-6?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: true,
      preferredLabel: 'Value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          '9-8 flopped two pair. Two pair is a strong value hand on any texture.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          '9-8 has real equity. Bluff candidates are hands with little made equity '
          'but enough fold pressure potential.',
    ),
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: false,
      preferredLabel: 'Value',
      betterAnswerLabel: 'Value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'Two pair is a strong made hand. Missed hands have no pair and no useful draw.',
    ),
  ],
);

final _w6TurnShiftBucketRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_turn_shift_bucket',
  caption: 'Flop gave you a bluff candidate. Turn bricks and pairs the board.',
  hint: 'When pressure drops, the bucket can slide.',
  question: 'What often happens to the hand now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'slide_missed',
      label: 'It can slide toward missed',
      isCorrect: true,
      preferredLabel: 'It can slide toward missed',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Street changes can remove pressure and push a former bluff candidate closer to missed.',
    ),
    Act0RunnerOptionV1(
      id: 'always_value',
      label: 'It becomes value automatically',
      isCorrect: false,
      preferredLabel: 'It can slide toward missed',
      betterAnswerLabel: 'It can slide toward missed',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'A brick turn does not create value. Often it removes pressure instead.',
    ),
    Act0RunnerOptionV1(
      id: 'never_changes',
      label: 'The bucket never changes after flop',
      isCorrect: false,
      preferredLabel: 'It can slide toward missed',
      betterAnswerLabel: 'It can slide toward missed',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too static.',
      feedbackReason:
          'Buckets can shift across streets when the board changes and pressure disappears.',
    ),
  ],
);

final _w6BoardFitRecapRunner = _w6BoardFitIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_board_fit_recap',
  caption:
      'Lesson learned: the same hand hits different buckets on different boards.',
  hint: 'Always read the board before assigning a bucket.',
  question: 'What decides which bucket a hand lands in?',
  feedbackTitle: 'Board-fit takeaway.',
  feedbackReason:
      'Board texture decides whether your hand is value, bluff candidate, or missed — '
      'not just its preflop strength.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Texture shifts buckets.',
      body:
          'Read the board, then assign the bucket. Preflop hand strength is only the starting point.',
      focusLabels: <String>['Board fit', 'Value', 'Missed', 'Texture'],
    ),
  ],
);

// Pressure lines lesson ───────────────────────────────────────────────────

final _w6PressureLinesIntroRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_pressure_lines_intro',
  lessonTitle: 'Value, bluff, missed',
  caption: 'Each range bucket suggests a different action direction.',
  hint:
      'Value bets to get called. Bluff candidates can bet to fold out better hands.',
  question: 'What does a value hand do?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket shapes action.',
      body:
          'Value hands bet for profit. Bluff candidates bet for fold equity. '
          'Missed hands usually check or fold.',
      focusLabels: <String>['Bet value', 'Bluff', 'Check-fold'],
    ),
  ],
);

// K-7-2: hero has K-Q (value) → bet for value (correct), check=suboptimal, fold=wrong
final _w6ValueRangeActionRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_value_range_action',
  caption: 'K-7-2 rainbow. Hero holds K-Q. You are in the value range.',
  hint: 'Value hands want to build the pot.',
  question: 'What does K-Q do here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet',
      label: 'Bet for value',
      isCorrect: true,
      preferredLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Top pair good kicker bets to get value from worse hands that will call.',
    ),
    Act0RunnerOptionV1(
      id: 'check',
      label: 'Check and see',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Legal check, lost value.',
      feedbackReason:
          'Checking is legal but leaves value behind. Strong value hands build the pot '
          'by betting, not by waiting.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Folding top pair good kicker on a dry board gives up a very profitable spot.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(centerLabel: 'Value action'),
);

// K-7-2: hero has A-Q (overcards, no pair) → bluff candidate (correct), value=wrong, missed=suboptimal
final _w6BluffCandidateRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_bluff_candidate',
  caption: 'K-7-2 rainbow. Hero holds A-Q.',
  hint: 'Two overcards, no pair. Some fold equity exists.',
  question: 'Which range bucket is A-Q here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluff',
      label: 'Bluff candidate',
      isCorrect: true,
      preferredLabel: 'Bluff candidate',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'A-Q has two overcards and ace-blocker. It can represent pressure '
          'without made-hand equity.',
    ),
    Act0RunnerOptionV1(
      id: 'missed',
      label: 'Missed',
      isCorrect: false,
      preferredLabel: 'Bluff candidate',
      betterAnswerLabel: 'Bluff candidate',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable read.',
      feedbackReason:
          'A-Q did miss the board, but the ace blocker and backdoor draw give it '
          'more potential than a pure missed hand.',
    ),
    Act0RunnerOptionV1(
      id: 'value',
      label: 'Value',
      isCorrect: false,
      preferredLabel: 'Bluff candidate',
      betterAnswerLabel: 'Bluff candidate',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'A-Q has no pair here. Value hands have made equity that opponents '
          'will call with worse.',
    ),
  ],
  table: _world5TextureIntroRunner.table.copyWith(centerLabel: 'Bucket?'),
);

final _w6MissedHandActionRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_missed_hand_action',
  caption: 'K-7-2 rainbow. Hero holds J-T with no draw.',
  hint: 'Pure missed hands usually do not want a big pot.',
  question: 'What is the clean action direction?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check_fold',
      label: 'Usually check or fold',
      isCorrect: true,
      preferredLabel: 'Usually check or fold',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Pure missed hands conserve chips more often than they force action.',
    ),
    Act0RunnerOptionV1(
      id: 'value_bet',
      label: 'Bet for value',
      isCorrect: false,
      preferredLabel: 'Usually check or fold',
      betterAnswerLabel: 'Usually check or fold',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong bucket.',
      feedbackReason:
          'Value betting belongs to made hands, not pure missed hands.',
    ),
    Act0RunnerOptionV1(
      id: 'always_barrel',
      label: 'Always barrel as pressure',
      isCorrect: false,
      preferredLabel: 'Usually check or fold',
      betterAnswerLabel: 'Usually check or fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too aggressive.',
      feedbackReason:
          'Some missed hands can bluff, but pure missed hands usually check or fold more often than they force large pressure.',
    ),
  ],
);

final _w6TableValueLineTransferRunner = _w6ValueRangeActionRunner.copyWith(
  lessonId: 'w6_table_value_line_transfer',
  caption:
      'Real table. K-8-4 rainbow. Hero holds K-J on the button after BB checks.',
  hint:
      'Bucket first, then line: top pair is value, so the clean action is bet for value.',
  question: 'What is the clean flop action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bet_value',
      label: 'Bet for value',
      isCorrect: true,
      preferredLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean transfer.',
      feedbackReason:
          'On a real table, K-J on K-8-4 lands in the value bucket. Once the bucket is clear, the clean line is bet for value.',
    ),
    Act0RunnerOptionV1(
      id: 'check_back',
      label: 'Check back',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable, but passive.',
      feedbackReason:
          'Checking is legal, but it leaves value behind. Top pair on a dry board wants a value line more often than a quiet check.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_bluff',
      label: 'Bet as a bluff',
      isCorrect: false,
      preferredLabel: 'Bet for value',
      betterAnswerLabel: 'Bet for value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Right action, wrong reason.',
      feedbackReason:
          'The bet is fine, but the reason matters. This is not bluff pressure. It is a value line because top pair can get called by worse.',
    ),
  ],
  table: _w6ValueRangeActionRunner.table.copyWith(
    potLabel: 'Pot 6 BB',
    centerLabel: 'Real table value line',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: 'J', suit: 'c'),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BB checks'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
    highlightedCardIds: const <String>['hero_0', 'board_0'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket first, line second.',
      body:
          'On a real table, top pair on a dry board belongs to value. Once the bucket is clear, the clean line is bet for value instead of guessing.',
      focusLabels: <String>['Real table', 'Value bucket', 'Bet for value'],
    ),
  ],
);

final _w6TurnPressureShiftTransferRunner = _w6BluffCandidateRunner.copyWith(
  lessonId: 'w6_turn_pressure_shift_transfer',
  caption:
      'Real table. Flop K-7-2 made A-Q a bluff candidate. BB called, and the turn pairs the 2.',
  hint:
      'When the board pairs and the first bluff gets called, some pressure lines cool off.',
  question: 'What is the cleaner turn plan now?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'check_more',
      label: 'Check more often',
      isCorrect: true,
      preferredLabel: 'Check more often',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Good pressure reset.',
      feedbackReason:
          'The flop bluff candidate lost momentum. After the call and paired turn, the cleaner pressure line is check more often instead of forcing another barrel.',
    ),
    Act0RunnerOptionV1(
      id: 'barrel_big',
      label: 'Barrel big again',
      isCorrect: false,
      preferredLabel: 'Check more often',
      betterAnswerLabel: 'Check more often',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting, but noisy.',
      feedbackReason:
          'Big pressure can happen sometimes, but the paired turn and called flop reduce the clean bluff story. Checking is the calmer transfer read here.',
    ),
    Act0RunnerOptionV1(
      id: 'bet_value',
      label: 'Bet for value',
      isCorrect: false,
      preferredLabel: 'Check more often',
      betterAnswerLabel: 'Check more often',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong bucket now.',
      feedbackReason:
          'A-Q still has no made hand on K-7-2-2. This is not a value line. The better read is that the bluff pressure cooled off.',
    ),
  ],
  table: _w6BluffCandidateRunner.table.copyWith(
    streetLabel: 'Turn',
    potLabel: 'Pot 11 BB',
    centerLabel: 'Turn pressure shift',
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 'd', tone: Act0CardToneV1.red),
    ],
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'c'),
      Act0CardStateV1(rank: '7', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 's'),
      Act0CardStateV1(rank: '2', suit: 'd', tone: Act0CardToneV1.red),
    ],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN bets flop'),
      Act0ActionTrailItemV1(label: 'BB calls'),
      Act0ActionTrailItemV1(label: 'BB checks turn'),
      Act0ActionTrailItemV1(label: 'BTN acts'),
    ],
    activeSeatId: 'btn',
    highlightedSeatIds: const <String>['btn', 'bb'],
    highlightedCardIds: const <String>['board_2', 'board_3'],
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Street changes can cool pressure.',
      body:
          'A bluff candidate is not a forever-barrel pass. On a paired turn after a call, the cleaner transfer can be slow down and check more often.',
      focusLabels: <String>['Paired turn', 'Called flop', 'Check more often'],
    ),
  ],
);

final _w6PressureLinesRecapRunner = _w6PressureLinesIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_pressure_lines_recap',
  caption: 'Lesson learned: bucket decides the action direction.',
  hint: 'Value bets. Bluff candidates can bet or fold. Missed usually folds.',
  question: 'What does each range bucket suggest?',
  feedbackTitle: 'Pressure takeaway.',
  feedbackReason:
      'Value bets for profit. Bluff candidates apply fold pressure. '
      'Missed hands conserve chips by folding or checking.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Action follows bucket.',
      body: 'Assign the bucket first, then let it guide your action.',
      focusLabels: <String>['Value bets', 'Bluff folds out', 'Missed folds'],
    ),
  ],
);

// Combo-count lesson ───────────────────────────────────────────────────────

final _w6ComboCountsIntroRunner = _w6RangeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w6_combo_counts_intro',
  lessonTitle: 'Count the combos',
  caption: 'Ranges are not just hand names. They also have combo counts.',
  hint: 'More combos means that hand family appears more often in a range.',
  question: 'Why do combo counts matter?',
  options: const <Act0RunnerOptionV1>[],
  table: _w6RangeIntroRunner.table.copyWith(centerLabel: 'Combo count'),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Families have counts.',
      body:
          'Some hand families have more possible versions than others. A-K has '
          '16 combos; a pocket pair has 6.',
      focusLabels: <String>['16 combos', '6 combos', 'Range density'],
    ),
  ],
);

final _w6AkComboRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_ak_combos',
  caption: 'A-K can be suited or offsuit.',
  hint: 'Four aces can pair with four kings.',
  question: 'How many combos does A-K have before blockers?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'sixteen',
      label: '16 combos',
      isCorrect: true,
      preferredLabel: '16 combos',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice count.',
      feedbackReason:
          'A-K has 16 combos before blockers: 4 suited and 12 offsuit combinations.',
    ),
    Act0RunnerOptionV1(
      id: 'twelve',
      label: '12 combos',
      isCorrect: false,
      preferredLabel: '16 combos',
      betterAnswerLabel: '16 combos',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close count.',
      feedbackReason:
          '12 counts only the offsuit versions. Add the 4 suited combos and A-K reaches 16 total combinations.',
    ),
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 combos',
      isCorrect: false,
      preferredLabel: '16 combos',
      betterAnswerLabel: '16 combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'Six combos is the count for a pocket pair. Two different ranks like A-K appear much more often.',
    ),
  ],
);

final _w6PairComboRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_pair_combos',
  caption: 'Pocket eights are one pair family.',
  hint: 'You pick 2 suits out of the 4 eights in the deck.',
  question: 'How many combos does 8-8 have?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'six',
      label: '6 combos',
      isCorrect: true,
      preferredLabel: '6 combos',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice count.',
      feedbackReason:
          'A pocket pair has 6 combinations. That is why pair families appear less often than broad non-pair hands.',
    ),
    Act0RunnerOptionV1(
      id: 'twelve',
      label: '12 combos',
      isCorrect: false,
      preferredLabel: '6 combos',
      betterAnswerLabel: '6 combos',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close count.',
      feedbackReason:
          'Twelve is too high for one pair family. With four eights in the deck, only 6 suit pairings are possible.',
    ),
    Act0RunnerOptionV1(
      id: 'sixteen',
      label: '16 combos',
      isCorrect: false,
      preferredLabel: '6 combos',
      betterAnswerLabel: '6 combos',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'Sixteen combos belongs to two different ranks like A-K, not to one pocket pair.',
    ),
  ],
);

final _w6ComboWeightCompareRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_combo_weight_compare',
  caption: 'Compare A-K with pocket eights before blockers.',
  hint: 'One family has 16 combos. The other has 6.',
  question: 'Which family appears more often in a range?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ak_more',
      label: 'A-K appears more often',
      isCorrect: true,
      preferredLabel: 'A-K appears more often',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Nice count.',
      feedbackReason:
          'A-K has 16 combos, so it appears more often than a pocket pair with only 6.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: 'They appear equally often',
      isCorrect: false,
      preferredLabel: 'A-K appears more often',
      betterAnswerLabel: 'A-K appears more often',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close start.',
      feedbackReason:
          'The hand names may feel equally important, but combo weight is not equal: 16 beats 6.',
    ),
    Act0RunnerOptionV1(
      id: 'pair_more',
      label: 'Pocket eights appear more often',
      isCorrect: false,
      preferredLabel: 'A-K appears more often',
      betterAnswerLabel: 'A-K appears more often',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'Pocket pairs have only 6 combos. Broad non-pair families like A-K are denser.',
    ),
  ],
);

final _w6ComboCountsRecapRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w6_combo_counts_recap',
  caption:
      'Lesson learned: combo counts measure how often a hand family appears.',
  hint: 'A-K = 16 combos. A pocket pair = 6 combos.',
  question: 'What do combo counts help you measure?',
  feedbackTitle: 'Combo takeaway.',
  feedbackReason:
      'Combo counts measure range density. Some hand families appear far more often than others.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Count before you guess.',
      body:
          'Range thinking is not only names like A-K or pocket eights. The combo count shows how much weight that family carries.',
      focusLabels: <String>['16 combos', '6 combos', 'Range density'],
    ),
  ],
);

final _w6SuitedOffsuitWeightCompareRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_suited_offsuit_weight_compare',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking Lite',
  caption: 'Compare A-K suited with A-K offsuit before blockers.',
  hint: 'Offsuit hands usually have more combinations than suited hands.',
  question: 'Which family appears more often in a range?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ak_offsuit',
      label: 'A-K offsuit',
      isCorrect: true,
      preferredLabel: 'A-K offsuit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean weight read.',
      feedbackReason:
          'A-K offsuit has 12 combos, while A-K suited has only 4. More combos means the offsuit family shows up more often.',
    ),
    Act0RunnerOptionV1(
      id: 'ak_suited',
      label: 'A-K suited',
      isCorrect: false,
      preferredLabel: 'A-K offsuit',
      betterAnswerLabel: 'A-K offsuit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Easy trap.',
      feedbackReason:
          'Suited feels special, but it is rarer. Only 4 suited combinations exist, while the offsuit family has 12.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: 'They appear equally often',
      isCorrect: false,
      preferredLabel: 'A-K offsuit',
      betterAnswerLabel: 'A-K offsuit',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close start.',
      feedbackReason:
          'The rank names match, but combo weight does not. Twelve offsuit combos clearly outweigh four suited combos.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Suited is rarer.',
      body:
          'Combos count how many ways a hand can exist. Offsuit versions usually carry more weight because there are more of them.',
      focusLabels: <String>['12 offsuit', '4 suited', 'Range weight'],
    ),
  ],
);

final _w6PairVsSuitedWeightCompareRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_pair_vs_suited_weight_compare',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking Lite',
  caption: 'Compare pocket nines with K-Q suited before blockers.',
  hint: 'Not every unpaired hand is denser than a pocket pair.',
  question: 'Which family appears more often in a range?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pair_nines',
      label: 'Pocket nines',
      isCorrect: true,
      preferredLabel: 'Pocket nines',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Good compare.',
      feedbackReason:
          'Pocket nines have 6 combos. K-Q suited has only 4, so the pocket pair appears more often here.',
    ),
    Act0RunnerOptionV1(
      id: 'kq_suited',
      label: 'K-Q suited',
      isCorrect: false,
      preferredLabel: 'Pocket nines',
      betterAnswerLabel: 'Pocket nines',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more count.',
      feedbackReason:
          'Unpaired does not always mean more common. Once you limit K-Q to suited only, it drops to 4 combos and loses to the pair family at 6.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: 'They appear equally often',
      isCorrect: false,
      preferredLabel: 'Pocket nines',
      betterAnswerLabel: 'Pocket nines',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close idea.',
      feedbackReason:
          'These families are closer than A-K versus a pocket pair, but they are still not equal. Six pair combos outweigh four suited combos.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Weight beats intuition.',
      body:
          'A pocket pair has fewer combos than a broad unpaired hand overall, but it can still outweigh one suited hand family. Use the count, not the label.',
      focusLabels: <String>[
        '6 pair combos',
        '4 suited combos',
        'Use the count',
      ],
    ),
  ],
);

final _w6CheckpointTableComboWeightRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_checkpoint_table_combo_weight',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking Lite',
  caption:
      'Real table. CO opens preflop. Before guessing exact hands in a simple opening range, you want the heavier family first.',
  hint: 'Use combo counts as weight, not as a guess.',
  question:
      'Which family should you expect more often in a simple opening range before blockers?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _unknownHoleCards,
    centerLabel: 'Range weight',
    highlightedSeatIds: const <String>['co', 'btn'],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN reads the range'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'ak_offsuit',
      label: 'A-K offsuit',
      isCorrect: true,
      preferredLabel: 'A-K offsuit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Practical read.',
      feedbackReason:
          'A-K offsuit carries 12 combos, while pocket nines have 6. More combos means that family shows up more often in the range before blockers.',
    ),
    Act0RunnerOptionV1(
      id: 'pair_nines',
      label: 'Pocket nines',
      isCorrect: false,
      preferredLabel: 'A-K offsuit',
      betterAnswerLabel: 'A-K offsuit',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Reasonable guess.',
      feedbackReason:
          'Pocket nines are real and strong enough to appear, but 6 pair combos still weigh less than 12 offsuit A-K combos.',
    ),
    Act0RunnerOptionV1(
      id: 'same_weight',
      label: 'They appear equally often',
      isCorrect: false,
      preferredLabel: 'A-K offsuit',
      betterAnswerLabel: 'A-K offsuit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Combo weight is not equal here. Twelve combos versus six means one family reaches the spot about twice as often.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Start with the heavier family.',
      body:
          'More combos means the family appears more often. That does not prove the exact hand, but it gives your first range read a better weight.',
      focusLabels: <String>['12 beats 6', 'Range weight', 'First read'],
    ),
  ],
);

final _w6KickerShowdownCompareRunner = _world6RangeCheckpointRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_kicker_showdown_compare',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking Lite',
  caption: 'River board is K-7-2-9-4. Hero shows A-K. Villain shows K-Q.',
  hint: 'Name the made hand first. Both players have one pair.',
  question: 'Which hand is stronger at showdown?',
  table: _w6RangeIntroRunner.table.copyWith(
    streetLabel: 'River',
    potLabel: 'Pot 11 BB',
    toCallLabel: '',
    centerLabel: 'Showdown read',
    boardCards: _boardK7294Cards,
    heroCards: _heroAkCards,
    highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],
    highlightedSeatIds: const <String>['co', 'btn'],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'River checks through'),
      Act0ActionTrailItemV1(label: 'Cards tabled'),
    ],
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Villain',
        holeCards: _villainKqCards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        isTarget: true,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroAkCards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        isTarget: true,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_ak',
      label: 'Hero A-K',
      isCorrect: true,
      preferredLabel: 'Hero A-K',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp compare.',
      feedbackReason:
          'Both players have one pair of kings, so the kicker decides. A-K uses A as the best side card, which beats Q.',
    ),
    Act0RunnerOptionV1(
      id: 'villain_kq',
      label: 'Villain K-Q',
      isCorrect: false,
      preferredLabel: 'Hero A-K',
      betterAnswerLabel: 'Hero A-K',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more compare.',
      feedbackReason:
          'Do not stop at pair. Both players share kings, but Hero keeps the better kicker in the best five.',
    ),
    Act0RunnerOptionV1(
      id: 'tie',
      label: 'Tie',
      isCorrect: false,
      preferredLabel: 'Hero A-K',
      betterAnswerLabel: 'Hero A-K',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close read.',
      feedbackReason:
          'The pair matches, but the showdown is not tied. The fifth card still matters when it is part of the best five.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pair first, kicker second.',
      body:
          'Name the made hand before judging the winner. If the pair matches, compare the kicker that still plays in the best five.',
      focusLabels: <String>['One pair', 'Kicker', 'Best five'],
    ),
  ],
);

final _w6BoardPairStrengthCompareRunner = _world6RangeCheckpointRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_board_pair_strength_compare',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking Lite',
  caption: 'River board is J-8-8-2-2. Hero shows A-J. Villain shows K-8.',
  hint: 'The board helped both players. Compare the full five-card hand.',
  question: 'Which hand is stronger at showdown?',
  table: _w6RangeIntroRunner.table.copyWith(
    streetLabel: 'River',
    potLabel: 'Pot 14 BB',
    toCallLabel: '',
    centerLabel: 'River compare',
    boardCards: _boardJ8822Cards,
    heroCards: _heroAjCards,
    highlightedCardIds: const <String>['hero_1', 'board_0', 'board_1'],
    highlightedSeatIds: const <String>['co', 'btn'],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'River checks through'),
      Act0ActionTrailItemV1(label: 'Cards tabled'),
    ],
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Villain',
        holeCards: _villainK8Cards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        isTarget: true,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroAjCards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        isTarget: true,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'hero_aj',
      label: 'Hero A-J',
      isCorrect: false,
      preferredLabel: 'Villain K-8',
      betterAnswerLabel: 'Villain K-8',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting read.',
      feedbackReason:
          'A-J makes two pair, jacks and eights, but K-8 uses the paired board to make trips. Trips beat two pair.',
    ),
    Act0RunnerOptionV1(
      id: 'villain_k8',
      label: 'Villain K-8',
      isCorrect: true,
      preferredLabel: 'Villain K-8',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean compare.',
      feedbackReason:
          'Do not stop at top pair. The extra 8 turns Villain into trips, and trips outrank Hero two pair.',
    ),
    Act0RunnerOptionV1(
      id: 'tie',
      label: 'Tie',
      isCorrect: false,
      preferredLabel: 'Villain K-8',
      betterAnswerLabel: 'Villain K-8',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'The board is paired, but both players did not land on the same best five. Villain improves beyond the shared board.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board can help both players.',
      body:
          'Do not stop at pair. Compare the full five-card hand after the board pairs, because one player may jump to trips while the other stays on two pair.',
      focusLabels: <String>['Paired board', 'Trips', 'Two pair', 'Best five'],
    ),
  ],
);

final _w6CheckpointTableBestFiveRunner = _world6RangeCheckpointRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w6_checkpoint_table_best_five',
  lessonTitle: 'Range thinking checkpoint',
  lessonSubtitle: 'Range Thinking Lite',
  caption:
      'Real table showdown. River board is A-K-Q-J-T. Hero shows A-5. Villain shows K-4.',
  hint: 'Best five cards decide the hand, not the loudest private card.',
  question: 'What is the clean read before the pot is pushed?',
  table: _w6RangeIntroRunner.table.copyWith(
    streetLabel: 'River',
    potLabel: 'Pot 18 BB',
    toCallLabel: '',
    centerLabel: 'Live showdown',
    boardCards: _boardBroadwayCards,
    heroCards: _heroA5Cards,
    highlightedCardIds: const <String>[
      'board_0',
      'board_1',
      'board_2',
      'board_3',
      'board_4',
    ],
    highlightedSeatIds: const <String>['co', 'btn'],
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'River checks through'),
      Act0ActionTrailItemV1(label: 'Cards tabled'),
    ],
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(
        seatId: 'utg',
        seatLabel: 'UTG',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'hj',
        seatLabel: 'HJ',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'co',
        seatLabel: 'CO',
        displayName: 'Villain',
        holeCards: _villainK4Cards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        isTarget: true,
      ),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        holeCards: _heroA5Cards,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        isTarget: true,
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Seat',
        isOccupied: false,
        isInHand: false,
        cardsVisibleMode: Act0CardsVisibleModeV1.none,
      ),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'split',
      label: 'Split the pot',
      isCorrect: true,
      preferredLabel: 'Split the pot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong live read.',
      feedbackReason:
          'The straight is already on the board. Best five cards are A-K-Q-J-T for both players, so private kickers do not help.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_wins',
      label: 'Hero wins with aces',
      isCorrect: false,
      preferredLabel: 'Split the pot',
      betterAnswerLabel: 'Split the pot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more check.',
      feedbackReason:
          'Do not stop at the hole cards. The board already makes the best five-card straight, so Hero ace does not outrank the board.',
    ),
    Act0RunnerOptionV1(
      id: 'villain_wins',
      label: 'Villain wins with kings',
      isCorrect: false,
      preferredLabel: 'Split the pot',
      betterAnswerLabel: 'Split the pot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close start.',
      feedbackReason:
          'Villain king feels relevant, but both players use the same straight from the board. When the same best five play, the pot is split.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Board can lock the showdown.',
      body:
          'Best five cards decide the hand. When the full straight sits on the board, private cards do not break the tie.',
      focusLabels: <String>['Best five', 'Board plays', 'Split pot'],
    ),
  ],
);

// Stack depth and risk ────────────────────────────────────────────────────

final _w7EffectiveStackIntroRunner = _w6ComboCountsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_effective_stack_intro',
  lessonTitle: 'Effective stack',
  lessonSubtitle: 'Stack Depth And Risk',
  caption: 'The smaller stack sets the maximum risk in the hand.',
  hint: 'No one can win or lose more than the smaller stack.',
  question: 'What is the effective stack?',
  table: _w6ComboCountsIntroRunner.table.copyWith(
    centerLabel: 'Effective stack',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Smaller stack rules.',
      body:
          'If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.',
      focusLabels: <String>['200 BB', '30 BB', 'Effective stack'],
    ),
  ],
);

final _w7EffectiveStackThirtyRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_effective_stack_30bb',
  caption: 'Hero has 200 BB. Villain has 30 BB.',
  hint: 'Look for the smaller stack.',
  question: 'What is the effective stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '30',
      label: '30 BB',
      isCorrect: true,
      preferredLabel: '30 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'The effective stack is always the smaller stack. Here only 30 BB can really go into the pot.',
    ),
    Act0RunnerOptionV1(
      id: '200',
      label: '200 BB',
      isCorrect: false,
      preferredLabel: '30 BB',
      betterAnswerLabel: '30 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'Your own stack can be deeper, but the hand risk is capped by the smaller stack across from you.',
    ),
    Act0RunnerOptionV1(
      id: '115',
      label: '115 BB',
      isCorrect: false,
      preferredLabel: '30 BB',
      betterAnswerLabel: '30 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close idea.',
      feedbackReason:
          'Effective stack is not the average. It is the smaller stack, because that stack caps what either player can lose.',
    ),
  ],
);

final _w7EffectiveStackEvenRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_effective_stack_100bb',
  caption: 'Hero has 100 BB. Villain has 100 BB.',
  hint: 'Equal stacks keep the full depth in play.',
  question: 'What is the effective stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '100',
      label: '100 BB',
      isCorrect: true,
      preferredLabel: '100 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Bucket first: ask before acting.',
      feedbackReason:
          'When both stacks are equal, that shared stack is the effective stack.',
    ),
    Act0RunnerOptionV1(
      id: '50',
      label: '50 BB',
      isCorrect: false,
      preferredLabel: '100 BB',
      betterAnswerLabel: '100 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Nothing cuts the stack in half here. With equal 100 BB stacks, the full 100 BB remains in play.',
    ),
    Act0RunnerOptionV1(
      id: '200',
      label: '200 BB',
      isCorrect: false,
      preferredLabel: '100 BB',
      betterAnswerLabel: '100 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'Add the stacks and you get total chips, not effective stack. The hand still plays 100 BB deep.',
    ),
  ],
);

final _w7EffectiveStackTableNoticeRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_table_effective_notice',
  caption: 'You cover a player 120 BB to 18 BB on a real table.',
  hint: 'Notice the number that caps the real risk.',
  question: 'What should you notice first before planning?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'eighteen_effective',
      label: '18 BB effective stack',
      isCorrect: true,
      preferredLabel: '18 BB effective stack',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the real live-table risk. The smaller stack sets the hand depth.',
    ),
    Act0RunnerOptionV1(
      id: 'your_120',
      label: 'Your own 120 BB stack',
      isCorrect: false,
      preferredLabel: '18 BB effective stack',
      betterAnswerLabel: '18 BB effective stack',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'That answer is tempting because your stack looks bigger and feels more powerful. The cleaner read is the smaller 18 BB stack, because that is the number that actually caps what can go in.',
    ),
    Act0RunnerOptionV1(
      id: 'total_138',
      label: '138 BB total in play',
      isCorrect: false,
      preferredLabel: '18 BB effective stack',
      betterAnswerLabel: '18 BB effective stack',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Total chips are a real table detail, so this looks useful at first. But total chips do not drive the plan here. The dominant cue is the effective stack that caps the real risk.',
    ),
  ],
);

final _w7EffectiveStackRecapRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_effective_stack_recap',
  caption: 'Lesson learned: the smaller stack sets the hand risk.',
  hint: 'Effective stack tells you how much room the hand really has.',
  question: 'Why does effective stack matter?',
  feedbackTitle: 'Effective-stack takeaway.',
  feedbackReason:
      'Effective stack tells you the real risk in the hand. Deep stacks leave room. Short stacks simplify decisions.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Risk starts here.',
      body:
          'Find the smaller stack first. That tells you how deep the hand really plays.',
      focusLabels: <String>['Smaller stack', 'Real risk', 'Hand depth'],
    ),
  ],
);

final _w7DepthShiftIntroRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_depth_shift_intro',
  lessonTitle: 'Same hand, different depth',
  caption: 'The same hand can widen at 20 BB and tighten at 100 BB.',
  hint: 'Short stacks simplify decisions. Deep stacks create more future risk.',
  question: 'Why does stack depth change the plan?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Depth changes commitment.',
      body:
          'At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.',
      focusLabels: <String>['20 BB', '100 BB', 'More room', 'More risk'],
    ),
  ],
);

final _w7TwentyBbWiderRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_20bb_wider',
  caption: 'You hold A-J suited with 20 BB effective.',
  hint: 'Shorter stacks reduce the postflop burden.',
  question: 'Which depth usually plays this hand more simply and more often?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '20bb',
      label: '20 BB',
      isCorrect: true,
      preferredLabel: '20 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'At 20 BB, the hand plays more simply. Less money is left behind, so the decision tree is shorter.',
    ),
    Act0RunnerOptionV1(
      id: '100bb',
      label: '100 BB',
      isCorrect: false,
      preferredLabel: '20 BB',
      betterAnswerLabel: '20 BB',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close idea.',
      feedbackReason:
          'A-J suited is still playable deep, but deep stacks create more tough streets. The shorter stack usually simplifies the choice.',
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: 'Same either way',
      isCorrect: false,
      preferredLabel: '20 BB',
      betterAnswerLabel: '20 BB',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Stack depth changes both risk and commitment. The same hand does not play the same way at every depth.',
    ),
  ],
);

final _w7HundredBbTighterRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_100bb_tighter',
  caption: 'Now look at the same hand with 100 BB effective.',
  hint: 'More streets create more ways to make a second-best hand.',
  question: 'What changes when the hand is 100 BB deep?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_risk',
      label: 'More room and more risk',
      isCorrect: true,
      preferredLabel: 'More room and more risk',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Deep stacks create more room to maneuver, but they also punish weak top pairs and dominated hands more often.',
    ),
    Act0RunnerOptionV1(
      id: 'less_risk',
      label: 'Less risk than 20 BB',
      isCorrect: false,
      preferredLabel: 'More room and more risk',
      betterAnswerLabel: 'More room and more risk',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'Deep stacks do not remove risk. They increase it because more money can go in across more streets.',
    ),
    Act0RunnerOptionV1(
      id: 'forced_jam',
      label: 'Mostly jam now',
      isCorrect: false,
      preferredLabel: 'More room and more risk',
      betterAnswerLabel: 'More room and more risk',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Forced jam logic belongs more to short stacks. With 100 BB, the key change is extra room and extra risk, not immediate all-in pressure.',
    ),
  ],
);

final _w7FortyBbMiddleRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_40bb_middle',
  caption: 'Now the same hand plays 40 BB effective.',
  hint: 'This is not pure jam depth and not carefree deep depth.',
  question: 'What is the cleaner 40 BB read?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'middle_ground',
      label: 'Some room, but not carefree deep',
      isCorrect: true,
      preferredLabel: 'Some room, but not carefree deep',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          '40 BB sits in the middle. You still have room, but depth still creates future-street risk.',
    ),
    Act0RunnerOptionV1(
      id: 'pure_jam',
      label: 'Mostly shove-or-fold only',
      isCorrect: false,
      preferredLabel: 'Some room, but not carefree deep',
      betterAnswerLabel: 'Some room, but not carefree deep',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too shallow.',
      feedbackReason:
          'That overstates short-stack pressure. 40 BB keeps more play than pure jam depth.',
    ),
    Act0RunnerOptionV1(
      id: 'same_100',
      label: 'It plays just like 100 BB deep',
      isCorrect: false,
      preferredLabel: 'Some room, but not carefree deep',
      betterAnswerLabel: 'Some room, but not carefree deep',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too relaxed.',
      feedbackReason:
          '40 BB has meaningful room, but it is still less forgiving than full deep-stack play.',
    ),
  ],
);

final _w7AjsButtonTwentyFiveBbRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_ajs_btn_25bb_transfer',
  caption:
      'Real table. CO opens 2.5 BB. Hero is BTN with A-J suited at 25 BB effective.',
  hint:
      'Read hand, position, then notice how the shorter depth simplifies the future.',
  question: 'What is the cleaner stack-depth read here?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroAJsCards,
    centerLabel: '25 BB effective',
    potLabel: 'Pot 4 BB',
    toCallLabel: 'To call 2.5 BB',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'cleaner_shallow',
      label: 'Use the short-stack read',
      isCorrect: true,
      preferredLabel: 'Use the short-stack read',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong transfer read.',
      feedbackReason:
          'Position and hand quality help, but 25 BB is the stack clue that matters. Shorter depth brings less risk because it reduces future-street risk and makes the continue cleaner.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_100',
      label: 'Treat depth as irrelevant',
      isCorrect: false,
      preferredLabel: 'Use the short-stack read',
      betterAnswerLabel: 'Use the short-stack read',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Hand right, depth wrong.',
      feedbackReason:
          'A-J suited is still A-J suited, but stack depth changes how much future money and domination risk remain. 25 BB is simpler than 100 BB.',
    ),
    Act0RunnerOptionV1(
      id: 'too_fragile_now',
      label: 'Treat it as too fragile',
      isCorrect: false,
      preferredLabel: 'Use the short-stack read',
      betterAnswerLabel: 'Use the short-stack read',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting deep-stack thought.',
      feedbackReason:
          'That caution belongs more to deep stacks. At 25 BB, there is less room for the hand to drift into a costly long decision tree.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, simpler shallow.',
      body:
          'The same hand can be cleaner shallow because less stack remains to punish second-best outcomes later.',
      focusLabels: <String>['25 BB', 'Position', 'Less future risk'],
    ),
  ],
);

final _w7AjsButtonHundredBbRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_ajs_btn_100bb_transfer',
  caption:
      'Same spot again. CO opens 2.5 BB. Hero is BTN with A-J suited at 100 BB effective.',
  hint: 'The hand did not change. The stack did.',
  question: 'What changes when this spot becomes 100 BB deep?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroAJsCards,
    centerLabel: '100 BB effective',
    potLabel: 'Pot 4 BB',
    toCallLabel: 'To call 2.5 BB',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'more_fragile_deep',
      label: 'Treat it as deeper',
      isCorrect: true,
      preferredLabel: 'Treat it as deeper',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean contrast.',
      feedbackReason:
          'Deep stacks give more room and position to maneuver, but they also create more risk because much more money is left behind when A-J suited makes a second-best pair or draw.',
    ),
    Act0RunnerOptionV1(
      id: 'same_clean_call',
      label: 'Treat it like 25 BB',
      isCorrect: false,
      preferredLabel: 'Treat it as deeper',
      betterAnswerLabel: 'Treat it as deeper',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Price-only read.',
      feedbackReason:
          'The price is part of the spot, but deep stacks change the future risk behind that price. The same call is not equally simple at every depth.',
    ),
    Act0RunnerOptionV1(
      id: 'shove_now',
      label: 'Use shove logic',
      isCorrect: false,
      preferredLabel: 'Treat it as deeper',
      betterAnswerLabel: 'Treat it as deeper',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too shallow a plan.',
      feedbackReason:
          'Shove logic belongs more to short stacks. At 100 BB, the main change is more future-street room and more ways to make an expensive mistake.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, deeper caution.',
      body:
          'Deep stacks give more room, but they also punish dominated and fragile hands more because more money can keep flowing later.',
      focusLabels: <String>['100 BB', 'More room', 'More risk'],
    ),
  ],
);

final _w7DepthShiftRecapRunner = _w7DepthShiftIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_depth_shift_recap',
  caption: 'Lesson learned: stack depth changes hand value and plan.',
  hint: 'Short stacks simplify. Deep stacks ask for more caution.',
  question: 'What changes when stack depth changes?',
  feedbackTitle: 'Depth takeaway.',
  feedbackReason:
      'The same hand can play wider short and tighter deep. Stack depth changes both risk and commitment.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, new plan.',
      body:
          'Do not memorize one answer for every hand. Depth changes what the hand can safely do.',
      focusLabels: <String>['Short stack', 'Deep stack', 'Risk', 'Commitment'],
    ),
  ],
);

final _w7SprIntroRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_spr_intro',
  lessonTitle: 'Room or commitment',
  caption: 'SPR tells you how much room is left after the flop.',
  hint: 'Low SPR means little room. High SPR means more room to maneuver.',
  question: 'What does low SPR usually mean?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Low room, high room.',
      body: 'SPR = stack vs pot. Low = commitment. High = room.',
      focusLabels: <String>['Low SPR', 'Commitment', 'High SPR', 'Room'],
    ),
  ],
);

final _w7LowSprCommitRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_low_spr_commit',
  caption: 'SPR is 2 on the flop and you hold top pair.',
  hint: 'Little room is left.',
  question: 'What does low SPR usually tell you?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'commit',
      label: 'One bet can commit the hand',
      isCorrect: true,
      preferredLabel: 'One bet can commit the hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'SPR 2 means there is not much room left. One bet can make the hand close to committed.',
    ),
    Act0RunnerOptionV1(
      id: 'float',
      label: 'Plenty of room to float and wait',
      isCorrect: false,
      preferredLabel: 'One bet can commit the hand',
      betterAnswerLabel: 'One bet can commit the hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'That is the opposite of low SPR. Low SPR reduces room and speeds up commitment.',
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: 'It plays the same as SPR 8',
      isCorrect: false,
      preferredLabel: 'One bet can commit the hand',
      betterAnswerLabel: 'One bet can commit the hand',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'SPR changes the hand structure. SPR 2 is a much more commit-heavy situation than SPR 8.',
    ),
  ],
);

final _w7HighSprRoomRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_high_spr_room',
  caption: 'SPR is 8 on the flop.',
  hint: 'A lot of stack is still behind.',
  question: 'What does high SPR usually give you?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'room',
      label: 'More room to maneuver',
      isCorrect: true,
      preferredLabel: 'More room to maneuver',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'High SPR leaves more stack behind, so you still have room to bet, check, fold, or plan later streets.',
    ),
    Act0RunnerOptionV1(
      id: 'force',
      label: 'Immediate commitment',
      isCorrect: false,
      preferredLabel: 'More room to maneuver',
      betterAnswerLabel: 'More room to maneuver',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'Immediate commitment is a low-SPR feature. High SPR creates more room, not less.',
    ),
    Act0RunnerOptionV1(
      id: 'none',
      label: 'No difference from preflop',
      isCorrect: false,
      preferredLabel: 'More room to maneuver',
      betterAnswerLabel: 'More room to maneuver',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'SPR changes how postflop decisions feel. High SPR gives you more future streets and more flexibility.',
    ),
  ],
);

final _w7SprFourRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_spr4_middle',
  caption: 'SPR is 4 with one pair and some stack still behind.',
  hint: 'Middle SPR is neither pure jam nor huge freedom.',
  question: 'What does SPR 4 usually feel like?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'middle_spr',
      label: 'Middle ground: some room, some commitment',
      isCorrect: true,
      preferredLabel: 'Middle ground: some room, some commitment',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'SPR 4 often means you still have choices, but commitment pressure is already starting to matter.',
    ),
    Act0RunnerOptionV1(
      id: 'auto_commit',
      label: 'Automatic commitment right now',
      isCorrect: false,
      preferredLabel: 'Middle ground: some room, some commitment',
      betterAnswerLabel: 'Middle ground: some room, some commitment',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too shallow.',
      feedbackReason:
          'That is more like very low SPR. SPR 4 is tighter than SPR 8, but not auto-commit by default.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_eight',
      label: 'The same as SPR 8',
      isCorrect: false,
      preferredLabel: 'Middle ground: some room, some commitment',
      betterAnswerLabel: 'Middle ground: some room, some commitment',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'SPR 4 has less room and more commitment pressure than SPR 8. It is a middle node, not a deep one.',
    ),
  ],
);

final _w7TopPairSprTwoRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_top_pair_spr2_transfer',
  caption: 'Real table. K-7-2 rainbow flop. Hero has K-Q and SPR is 2.',
  hint:
      'The hand did not change from the deeper version. Read what the low SPR changes first.',
  question: 'What does low SPR add to this top-pair spot?',
  table: _w6ValueRangeActionRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 3 BB',
    centerLabel: 'SPR 2, top pair',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'faster_commitment',
      label: 'Less room, more commitment pressure',
      isCorrect: true,
      preferredLabel: 'Less room, more commitment pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean SPR contrast.',
      feedbackReason:
          'That is the low-SPR transfer. Top pair still needs board discipline, but SPR 2 leaves much less room and makes one bet push the hand closer to commitment.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_spr8',
      label: 'Treat it like SPR 8',
      isCorrect: false,
      preferredLabel: 'Less room, more commitment pressure',
      betterAnswerLabel: 'Less room, more commitment pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Depth changed the job.',
      feedbackReason:
          'The board and hand stayed the same, but SPR did not. At SPR 2, low room changes the pressure and makes the hand much closer to commitment than at SPR 8.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_stack_pressure',
      label: 'Top pair matters, so stack pressure can wait',
      isCorrect: false,
      preferredLabel: 'Less room, more commitment pressure',
      betterAnswerLabel: 'Less room, more commitment pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Only part of the picture.',
      feedbackReason:
          'Top pair is the made hand, but low SPR is the pressure clue. Name the reduced room first, then judge how willing the hand is to keep money flowing.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same top pair, tighter room.',
      body:
          'Compare this directly with the SPR 8 version. Low SPR keeps less room behind, so commitment pressure becomes part of the first read instead of a later warning.',
      focusLabels: <String>['Top pair', 'SPR 2', 'Less room', 'Commitment'],
    ),
  ],
);

final _w7TopPairSprEightRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_top_pair_spr8_transfer',
  caption: 'Real table. K-7-2 rainbow flop. Hero has K-Q and SPR is 8.',
  hint: 'Top pair is good, but deep room keeps future-street risk alive.',
  question: 'What does stack depth add to this top-pair spot?',
  table: _w6ValueRangeActionRunner.table.copyWith(
    streetLabel: 'Flop',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 3 BB',
    centerLabel: 'SPR 8, top pair',
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'room_and_risk',
      label: 'More room, more risk',
      isCorrect: true,
      preferredLabel: 'More room, more risk',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp stack read.',
      feedbackReason:
          'Top pair looks strong, but SPR 8 means a lot of stack is still behind. Deep room gives flexibility, yet it also creates more chances to overplay a fragile made hand.',
    ),
    Act0RunnerOptionV1(
      id: 'same_as_spr2',
      label: 'Treat it like SPR 2',
      isCorrect: false,
      preferredLabel: 'More room, more risk',
      betterAnswerLabel: 'More room, more risk',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tempting shortcut.',
      feedbackReason:
          'Top pair makes this answer tempting, but SPR changes the structure. At SPR 8, one bet does not commit the hand the way SPR 2 can.',
    ),
    Act0RunnerOptionV1(
      id: 'stack_irrelevant',
      label: 'Ignore the depth cue',
      isCorrect: false,
      preferredLabel: 'More room, more risk',
      betterAnswerLabel: 'More room, more risk',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Only part of the picture.',
      feedbackReason:
          'Board texture still matters, but stack depth changes how much that one-pair hand can safely absorb across later streets.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Top pair is not the same at every SPR.',
      body:
          'Read hand, board, and price first, then ask how much stack is still behind. High SPR keeps more room and more ways to make a costly mistake.',
      focusLabels: <String>['Top pair', 'SPR 8', 'Future risk'],
    ),
  ],
);

final _w7SprRecapRunner = _w7SprIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_spr_recap',
  caption: 'Lesson learned: low SPR pushes commitment, high SPR keeps room.',
  hint: 'Do not treat every flop the same when stack room changes.',
  question: 'What does SPR help you feel?',
  feedbackTitle: 'SPR takeaway.',
  feedbackReason:
      'SPR tells you whether the hand is room-heavy or commitment-heavy. That changes what a normal action looks like.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Room matters.',
      body:
          'Low SPR speeds up commitment. High SPR keeps later-street choices alive.',
      focusLabels: <String>['Low SPR', 'Commitment', 'High SPR', 'Room'],
    ),
  ],
);

final _w7FormatPressureIntroRunner = _w7EffectiveStackIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w7_format_intro',
  lessonTitle: '6-max vs full ring',
  caption: 'The same hand can open wider in 6-max than in full ring.',
  hint:
      'Fewer players behind means less chance someone wakes up with a premium hand.',
  question: 'Why does 6-max usually widen ranges?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fewer players behind.',
      body:
          'In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.',
      focusLabels: <String>['6-max', 'Full ring', 'Fewer players behind'],
    ),
  ],
);

final _w7SixMaxWiderRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_6max_wider',
  caption: 'A-J offsuit in early position.',
  hint: 'Compare 6-max with 9-handed full ring.',
  question: 'Where does this hand usually open wider?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: '6max',
      label: '6-max',
      isCorrect: true,
      preferredLabel: '6-max',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Board fit: sharp read.',
      feedbackReason:
          '6-max widens many opens because fewer players are left behind to wake up with premiums.',
    ),
    Act0RunnerOptionV1(
      id: 'fullring',
      label: 'Full ring',
      isCorrect: false,
      preferredLabel: '6-max',
      betterAnswerLabel: '6-max',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'Full ring has more players left to act, so early-position ranges usually tighten rather than widen.',
    ),
    Act0RunnerOptionV1(
      id: 'same',
      label: 'Same in both',
      isCorrect: false,
      preferredLabel: '6-max',
      betterAnswerLabel: '6-max',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close idea.',
      feedbackReason:
          'The hand class stays the same, but the format changes pressure. Fewer players behind usually widens the opening range.',
    ),
  ],
);

final _w7FullRingTighterRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_fullring_tighter',
  caption: 'Now imagine the same hand in full ring.',
  hint: 'More players still need to act.',
  question: 'What usually changes in full ring?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighter',
      label: 'Range tightens',
      isCorrect: true,
      preferredLabel: 'Range tightens',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'Full ring means more players behind. That added pressure usually tightens early-position opens.',
    ),
    Act0RunnerOptionV1(
      id: 'wider',
      label: 'Range widens more',
      isCorrect: false,
      preferredLabel: 'Range tightens',
      betterAnswerLabel: 'Range tightens',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'More players behind do not widen the range. They increase the chance of running into strength and usually tighten it.',
    ),
    Act0RunnerOptionV1(
      id: 'depth',
      label: 'Only stack depth matters',
      isCorrect: false,
      preferredLabel: 'Range tightens',
      betterAnswerLabel: 'Range tightens',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Stack depth matters too, but format matters here because table size changes how many players are left to act.',
    ),
  ],
);

final _w7FormatTableNoticeRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w7_format_table_notice',
  caption: 'You jump from 6-max online to a 9-handed live table.',
  hint: 'Start by counting how many players are still behind you.',
  question: 'What is the first useful adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_early',
      label: 'Count more players behind and tighten early opens a bit',
      isCorrect: true,
      preferredLabel: 'Count more players behind and tighten early opens a bit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'That is the real-table transfer: more players behind usually means tighter early-position pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'open_same',
      label: 'Open just as wide as 6-max',
      isCorrect: false,
      preferredLabel: 'Count more players behind and tighten early opens a bit',
      betterAnswerLabel:
          'Count more players behind and tighten early opens a bit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too wide.',
      feedbackReason:
          'Full ring adds players behind, so the same open widths are usually too loose early.',
    ),
    Act0RunnerOptionV1(
      id: 'depth_only',
      label: 'Only watch stack depth, not player count',
      isCorrect: false,
      preferredLabel: 'Count more players behind and tighten early opens a bit',
      betterAnswerLabel:
          'Count more players behind and tighten early opens a bit',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Part of the picture.',
      feedbackReason:
          'Depth matters too, but table format starts with how many players are left behind to wake up with strength.',
    ),
  ],
);

final _w7FormatRecapRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_format_recap',
  caption:
      'Lesson learned: the same hand can open wider in 6-max and tighter in full ring.',
  hint: 'Format changes pressure before the cards even hit the flop.',
  question: 'Why does format change opening pressure?',
  feedbackTitle: 'Format takeaway.',
  feedbackReason:
      'Format changes how many players still act behind you. Fewer players behind usually widen ranges. More players behind tighten them.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Format shapes pressure.',
      body:
          'The hand is the same, but table format changes how often someone behind wakes up with strength.',
      focusLabels: <String>['6-max', 'Full ring', 'Players behind'],
    ),
  ],
);

final _world7StackCheckpointRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w7_stack_checkpoint',
  caption: 'Lesson learned: depth, SPR, and format all change risk.',
  hint:
      'Next you will see how tournament pressure makes stack risk even sharper.',
  question: 'What does stack-depth thinking add to range thinking?',
  feedbackTitle: 'Stack-depth checkpoint.',
  feedbackReason:
      'Range reading tells you what hand families exist. Stack depth tells you how much risk those families can absorb. Tournament pressure is the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry the range into risk.',
      body:
          'Group the range first, then ask how deep the hand plays, how much room is left, and what the format changes.',
      focusLabels: <String>[
        'Range',
        'Effective stack',
        'SPR',
        'Tournament pressure',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'range_plus_depth',
      label: 'Range plus stack risk',
      isCorrect: true,
      preferredLabel: 'Range plus stack risk',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Good planning now needs both parts: what range is present and how much risk that depth creates. Tournament pressure is the next step.',
    ),
    Act0RunnerOptionV1(
      id: 'range_only',
      label: 'Range only',
      isCorrect: false,
      preferredLabel: 'Range plus stack risk',
      betterAnswerLabel: 'Range plus stack risk',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Range is still the base, but stack depth changes commitment, room, and future risk. Tournament pressure builds on both.',
    ),
    Act0RunnerOptionV1(
      id: 'chips_only',
      label: 'Chip count only',
      isCorrect: false,
      preferredLabel: 'Range plus stack risk',
      betterAnswerLabel: 'Range plus stack risk',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'Raw chip count alone is too thin. Effective stack, SPR, and format explain the real pressure better than chips by themselves.',
    ),
  ],
);

final _w9SurvivalIntroRunner = _w7FormatPressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_survival_intro',
  lessonTitle: 'Chips are not life',
  lessonSubtitle: 'Tournament Pressure',
  caption: 'Tournament chips carry survival value, not only chip EV.',
  hint: 'When you bust, your tournament run ends.',
  question: 'What makes tournament chips different from cash chips?',
  feedbackTitle: 'Survival foundation.',
  feedbackReason:
      'Tournament pressure means survival has value. Losing all chips ends the run, so not every thin chip-EV spot is equal.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Life has value.',
      body:
          'In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.',
      focusLabels: <String>['Tournament life', 'Survival', 'Bubble'],
    ),
  ],
);

final _w9CashVsTournamentRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_cash_vs_tournament',
  caption: 'You face a thin all-in edge with 20 BB.',
  hint: 'Compare cash-game reload logic with tournament survival.',
  question: 'Which frame should be stronger in a tournament?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'survival',
      label: 'Survival pressure matters more',
      isCorrect: true,
      preferredLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Tournament chips are tied to staying alive. You still seek EV, but survival pressure changes which thin spots are worth taking.',
    ),
    Act0RunnerOptionV1(
      id: 'same_cash',
      label: 'Play it exactly like cash',
      isCorrect: false,
      preferredLabel: 'Survival pressure matters more',
      betterAnswerLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'Cash and tournament contexts are not the same. Tournament life creates extra downside for busting.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Avoid all risk until paid',
      isCorrect: false,
      preferredLabel: 'Survival pressure matters more',
      betterAnswerLabel: 'Survival pressure matters more',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'Risk control is useful, but freezing is too passive. Good tournament play balances survival with selective aggression.',
    ),
  ],
);

final _w9ShortStackSurvivalRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_short_stack_survival',
  caption: 'You have 9 BB with blinds about to hit.',
  hint: 'Very short stacks cannot wait forever.',
  question: 'What is usually the sharper plan?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'take_spot',
      label: 'Take a reasonable jam or reshove spot',
      isCorrect: true,
      preferredLabel: 'Take a reasonable jam or reshove spot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'At very low stack depth, survival comes from acting before you get blinded out. Controlled urgency beats passive waiting.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_premium',
      label: 'Wait only for premium pairs',
      isCorrect: false,
      preferredLabel: 'Take a reasonable jam or reshove spot',
      betterAnswerLabel: 'Take a reasonable jam or reshove spot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too tight here.',
      feedbackReason:
          'Waiting only for monsters often costs too many blinds. In short-stack spots you need practical urgency, not perfect cards.',
    ),
    Act0RunnerOptionV1(
      id: 'open_fold',
      label: 'Open small and fold to pressure',
      isCorrect: false,
      preferredLabel: 'Take a reasonable jam or reshove spot',
      betterAnswerLabel: 'Take a reasonable jam or reshove spot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Open-fold lines with very short stacks burn too many chips. Tournament pressure rewards cleaner commit-or-fold plans.',
    ),
  ],
);

final _w9SurvivalTradeoffRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_survival_stack_tradeoff',
  caption: 'Cash table can reload. Tournament table cannot.',
  hint: 'The same thin edge does not carry the same downside.',
  question: 'Which table should pass more thin stack-off spots?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tournament_table',
      label: 'Tournament table',
      isCorrect: true,
      preferredLabel: 'Tournament table',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Tournament life adds elimination risk. That makes thin stack-offs more expensive than in reloadable cash spots.',
    ),
    Act0RunnerOptionV1(
      id: 'cash_table',
      label: 'Cash table',
      isCorrect: false,
      preferredLabel: 'Tournament table',
      betterAnswerLabel: 'Tournament table',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Close call.',
      feedbackReason:
          'Cash chips still matter, but reload makes busting less final. Tournament pressure creates the bigger penalty for thin stack-offs.',
    ),
    Act0RunnerOptionV1(
      id: 'same_both',
      label: 'Both should pass equally',
      isCorrect: false,
      preferredLabel: 'Tournament table',
      betterAnswerLabel: 'Tournament table',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close start.',
      feedbackReason:
          'Hand strength matters in both formats, but tournament life changes the downside. The risk tradeoff is not equal.',
    ),
  ],
);

final _w9SurvivalRecapRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_survival_recap',
  caption: 'Lesson learned: tournament chips include survival value.',
  hint: 'Life pressure changes which thin spots are worth taking.',
  question: 'What is the key survival takeaway?',
  feedbackTitle: 'Survival takeaway.',
  feedbackReason:
      'Tournament pressure does not remove aggression. It asks for cleaner risk selection because busting ends your run.',
);

final _w9MRatioIntroRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_m_ratio_intro',
  lessonTitle: 'M-ratio zones',
  caption: 'M-ratio gives a quick urgency signal for tournament decisions.',
  hint: 'Think in simple zones first, not formulas.',
  question: 'What does M-ratio help you read?',
  feedbackTitle: 'Zone foundation.',
  feedbackReason:
      'M-ratio is a practical urgency signal. Lower zones mean less time and more pressure to act.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Urgency by zone.',
      body:
          'Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.',
      focusLabels: <String>['M-ratio', 'Green', 'Yellow', 'Red'],
    ),
  ],
);

final _w9MZoneRedRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_red_zone',
  caption: 'Your M-ratio is in the red zone.',
  hint: 'Low zone means blinds are hurting fast.',
  question: 'What is the sharper mindset?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'urgent',
      label: 'Use controlled urgency',
      isCorrect: true,
      preferredLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Red-zone stacks cannot drift. Tournament pressure rewards timely commitment when edges appear.',
    ),
    Act0RunnerOptionV1(
      id: 'wait',
      label: 'Wait for perfect premium only',
      isCorrect: false,
      preferredLabel: 'Use controlled urgency',
      betterAnswerLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too narrow.',
      feedbackReason:
          'Perfect-card waiting in red zone usually leaks fold equity and stack health. You need practical action windows.',
    ),
    Act0RunnerOptionV1(
      id: 'flat_call',
      label: 'Flat-call wide and see flops',
      isCorrect: false,
      preferredLabel: 'Use controlled urgency',
      betterAnswerLabel: 'Use controlled urgency',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason:
          'Short tournament stacks often play poorly as passive flats. Clearer commit-or-fold lines are usually stronger.',
    ),
  ],
);

final _w9MZoneGreenRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_green_zone',
  caption: 'Your M-ratio is in the green zone.',
  hint: 'You still have room to pick spots.',
  question: 'What usually improves in green zone?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'patience',
      label: 'Patience and table selection',
      isCorrect: true,
      preferredLabel: 'Patience and table selection',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Green zone gives room.',
      feedbackReason:
          'With room in green zone, you can pass thin spots and choose cleaner pressure lines.',
    ),
    Act0RunnerOptionV1(
      id: 'panic',
      label: 'Force all-ins quickly',
      isCorrect: false,
      preferredLabel: 'Patience and table selection',
      betterAnswerLabel: 'Patience and table selection',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not needed.',
      feedbackReason:
          'Green zone does not require panic. You have time to use stronger setup and seat selection.',
    ),
    Act0RunnerOptionV1(
      id: 'never_risk',
      label: 'Avoid pressure spots entirely',
      isCorrect: false,
      preferredLabel: 'Patience and table selection',
      betterAnswerLabel: 'Patience and table selection',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Patience is good, but full passivity leaks value. Green zone is for selective pressure, not fear-based folding.',
    ),
  ],
);

final _w9MZoneYellowRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_yellow_zone',
  caption: 'Your M-ratio is in the yellow zone.',
  hint: 'Yellow zone asks for planning before panic.',
  question: 'What usually becomes sharper in yellow zone?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'prepare_windows',
      label: 'Prepare action windows before red-zone panic',
      isCorrect: true,
      preferredLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'Yellow zone is not emergency mode yet, but it is no longer pure patience. Good tournament play starts planning cleaner shove, reshove, and steal windows here.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore',
      label: 'Ignore urgency until the red zone',
      isCorrect: false,
      preferredLabel: 'Prepare action windows before red-zone panic',
      betterAnswerLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason:
          'Waiting until the stack is critical often removes good options. Yellow zone is where you prepare instead of drift.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_now',
      label: 'Force any spot immediately',
      isCorrect: false,
      preferredLabel: 'Prepare action windows before red-zone panic',
      betterAnswerLabel: 'Prepare action windows before red-zone panic',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rushed.',
      feedbackReason:
          'Yellow zone needs sharper planning, not panic. You still want selective aggression with room for better spots.',
    ),
  ],
);

final _w9MTableWindowTransferRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_m_ratio_table_window_transfer',
  caption: 'Real table. Hero is BTN with A-J offsuit at 12 BB in yellow zone.',
  hint:
      'This is not red-zone panic yet, but the stack should not drift. Read what yellow-zone urgency changes first.',
  question: 'What is the cleaner first zone adjustment here?',
  table: _w9MRatioIntroRunner.table.copyWith(
    heroCards: _heroAjCards,
    streetLabel: 'Preflop',
    boardCards: const <Act0CardStateV1>[],
    potLabel: 'Pot 1.5 BB',
    toCallLabel: 'To call 0 BB',
    centerLabel: 'BTN, 12 BB, yellow zone',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Folded to BTN'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'prepare_now',
      label: 'Plan a practical action window now',
      isCorrect: true,
      preferredLabel: 'Plan a practical action window now',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp transfer.',
      feedbackReason:
          'That is the live-table yellow-zone transfer. You still have a little room, but urgency is real enough that you should prepare an action window before the stack slips into red zone.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_for_red',
      label: 'Wait until red zone before changing anything',
      isCorrect: false,
      preferredLabel: 'Plan a practical action window now',
      betterAnswerLabel: 'Plan a practical action window now',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too late.',
      feedbackReason:
          'Yellow zone is where urgency starts to matter. If you wait for red zone, you lose cleaner timing and let the stack drift into panic decisions.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_now',
      label: 'Treat yellow zone like instant all-in panic',
      isCorrect: false,
      preferredLabel: 'Plan a practical action window now',
      betterAnswerLabel: 'Plan a practical action window now',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Right idea, wrong speed.',
      feedbackReason:
          'Urgency is real, but yellow zone still leaves some room. The cleaner read is plan practical action windows before red-zone panic, not force every spot immediately.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Yellow zone starts the countdown.',
      body:
          'This is the changed frame: same M-ratio idea, live table now. Yellow zone is not freeze mode and not red-zone panic. It is the spot where urgency becomes actionable before the stack gets desperate.',
      focusLabels: <String>['Yellow zone', '12 BB', 'Urgency', 'Plan early'],
    ),
  ],
);

final _w9MRatioRecapRunner = _w9MRatioIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_m_ratio_recap',
  caption: 'Lesson learned: M-ratio zones map urgency.',
  hint: 'Green keeps room. Red needs action soon.',
  question: 'What is the M-ratio takeaway?',
  feedbackTitle: 'M-ratio takeaway.',
  feedbackReason:
      'Use M-ratio as a quick pressure map. The lower the zone, the less freedom you have to wait.',
);

final _w9BubblePressureIntroRunner = _w9SurvivalIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w9_bubble_intro',
  lessonTitle: 'Bubble risk premium',
  caption:
      'Near the bubble, losing chips can hurt more than winning chips helps.',
  hint: 'Medium stacks often feel this pressure most.',
  question: 'What is risk premium in simple terms?',
  feedbackTitle: 'Bubble foundation.',
  feedbackReason:
      'Risk premium means you need extra hand strength before risking tournament life near payout pressure.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bubble pressure shifts ranges.',
      body:
          'Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.',
      focusLabels: <String>[
        'Bubble',
        'Risk premium',
        'Medium stack',
        'Leverage',
      ],
    ),
  ],
);

final _w9MediumStackTightenRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_medium_stack_tighten',
  caption: 'You are a medium stack two spots from the money.',
  hint: 'Bust risk is expensive here.',
  question: 'What is usually the sharper adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_calls',
      label: 'Tighten marginal calls',
      isCorrect: true,
      preferredLabel: 'Tighten marginal calls',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Risk premium near the bubble means medium stacks should avoid thin call-offs and protect tournament life.',
    ),
    Act0RunnerOptionV1(
      id: 'call_wide',
      label: 'Call off as wide as chip EV says',
      isCorrect: false,
      preferredLabel: 'Tighten marginal calls',
      betterAnswerLabel: 'Tighten marginal calls',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason:
          'Pure chip-EV calls can be too loose near bubble pressure. Tournament survival increases the cost of busting.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_all',
      label: 'Fold everything until paid',
      isCorrect: false,
      preferredLabel: 'Tighten marginal calls',
      betterAnswerLabel: 'Tighten marginal calls',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'Over-folding gives away too much. The sharper line is selective discipline, not total shutdown.',
    ),
  ],
);

final _w9BigStackLeverageRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_big_stack_leverage',
  caption: 'You cover both blinds near the bubble.',
  hint: 'Leverage works because others face elimination risk.',
  question: 'What usually improves for the big stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'apply_pressure',
      label: 'Apply selective open pressure',
      isCorrect: true,
      preferredLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Big stacks can leverage bubble pressure because medium stacks cannot call as freely.',
    ),
    Act0RunnerOptionV1(
      id: 'freeze',
      label: 'Avoid stealing to protect stack',
      isCorrect: false,
      preferredLabel: 'Apply selective open pressure',
      betterAnswerLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Protection matters, but freezing misses one of the strongest bubble advantages of covering stacks.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_any_two',
      label: 'Jam any two cards every hand',
      isCorrect: false,
      preferredLabel: 'Apply selective open pressure',
      betterAnswerLabel: 'Apply selective open pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not that extreme.',
      feedbackReason:
          'Leverage is selective, not reckless. You still need position, blockers, and player tendencies.',
    ),
  ],
);

final _w9BubbleShortStackRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_short_stack',
  caption: 'You are the short stack near the bubble.',
  hint: 'Short stacks still need survival spots, not endless folding.',
  question: 'What usually stays true for the short stack?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'still_take_spots',
      label: 'Still take practical jam spots before blinded out',
      isCorrect: true,
      preferredLabel: 'Still take practical jam spots before blinded out',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Bubble pressure matters, but short stacks cannot fold forever. Survival still needs practical action windows before the stack disappears.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_to_money',
      label: 'Fold every hand until payouts begin',
      isCorrect: false,
      preferredLabel: 'Still take practical jam spots before blinded out',
      betterAnswerLabel: 'Still take practical jam spots before blinded out',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Short stacks lose too much by freezing completely. Bubble caution is real, but waiting forever often removes all fold equity.',
    ),
    Act0RunnerOptionV1(
      id: 'call_off_light',
      label: 'Call off too light',
      isCorrect: false,
      preferredLabel: 'Still take practical jam spots before blinded out',
      betterAnswerLabel: 'Still take practical jam spots before blinded out',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason:
          'Calling off light near bubble pressure is still expensive. The better plan is selective action, not loose stack-offs.',
    ),
  ],
);

final _w9BubbleTableRiskTransferRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_bubble_table_risk_transfer',
  caption:
      'Real table. Hero is BTN with A-J offsuit as a medium stack near the bubble.',
  hint:
      'The covering big blind can hurt you more than you can hurt them. Name the bubble risk premium before acting.',
  question: 'What is the cleaner first bubble adjustment here?',
  table: _w9BubblePressureIntroRunner.table.copyWith(
    heroCards: _heroAjCards,
    streetLabel: 'Preflop',
    boardCards: const <Act0CardStateV1>[],
    potLabel: 'Pot 2.5 BB',
    toCallLabel: 'To call 15.5 BB',
    centerLabel: 'BTN, medium stack, bubble pressure',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'CO folds'),
      Act0ActionTrailItemV1(label: 'BTN opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BB shoves 18 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_stackoff',
      label: 'Tighten thin stack-offs versus the covering blind',
      isCorrect: true,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong transfer.',
      feedbackReason:
          'That is the live-table bubble transfer. Against a covering big blind, a medium stack feels extra risk premium before calling off, so thin chip-EV stack-offs tighten first.',
    ),
    Act0RunnerOptionV1(
      id: 'call_chip_ev',
      label: 'Call as wide as normal chip EV allows',
      isCorrect: false,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      betterAnswerLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose for bubble pressure.',
      feedbackReason:
          'Pure chip-EV calls miss the tournament tax here. A covering big blind creates real bubble pressure, so medium stacks need more hand strength before risking tournament life.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_anything_close',
      label: 'Over-fold every close hand',
      isCorrect: false,
      preferredLabel: 'Tighten thin stack-offs versus the covering blind',
      betterAnswerLabel: 'Tighten thin stack-offs versus the covering blind',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Right caution, too extreme.',
      feedbackReason:
          'Risk premium is not total shutdown. The real-table bubble read is selective tightening for a medium stack, not folding every playable spot just because the big blind covers you.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bubble pressure changes the stack-off bar.',
      body:
          'Real table, same concept, clearer transfer. A medium stack near the bubble cannot call off like pure chip EV when the big blind covers them. Bubble risk premium means tighter stack-offs first, not panic folds everywhere.',
      focusLabels: <String>[
        'Real table',
        'Bubble',
        'Medium stack',
        'Big blind leverage',
      ],
    ),
  ],
);

final _w9BubbleRecapRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_bubble_recap',
  caption: 'Lesson learned: bubble pressure changes who can risk chips.',
  hint: 'Medium stacks tighten more; big stacks can lean with leverage.',
  question: 'What is the bubble-pressure takeaway?',
  feedbackTitle: 'Bubble takeaway.',
  feedbackReason:
      'Risk premium is not fear. It is a context shift: medium stacks defend life, big stacks can pressure selectively.',
);

final _w9CheckpointSurvivalLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_survival_line',
  caption: 'You are short with one orbit left.',
  hint: 'Tournament life still needs action windows.',
  question: 'What is the best pressure line?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'disciplined_urgency',
      label: 'Disciplined urgency in reasonable spots',
      isCorrect: true,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Good tournament pressure play combines survival with timely action, not passive waiting.',
    ),
    Act0RunnerOptionV1(
      id: 'panic_any_two',
      label: 'Panic with any two cards now',
      isCorrect: false,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      betterAnswerLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too extreme.',
      feedbackReason:
          'Urgency is real, but panic jams are not the target. You still choose spots with fold equity and blockers.',
    ),
    Act0RunnerOptionV1(
      id: 'wait_only_aa',
      label: 'Wait only for aces',
      isCorrect: false,
      preferredLabel: 'Disciplined urgency in reasonable spots',
      betterAnswerLabel: 'Disciplined urgency in reasonable spots',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too tight.',
      feedbackReason:
          'Waiting for perfect hands often runs out the clock. Tournament pressure rewards practical urgency.',
    ),
  ],
);

final _w9CheckpointZoneLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_zone_line',
  caption: 'Two players face similar hand strength in different M-ratio zones.',
  hint: 'Zone changes urgency.',
  question: 'Which player should act sooner?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'red_zone',
      label: 'Red-zone player',
      isCorrect: true,
      preferredLabel: 'Red-zone player',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Lower M-ratio means fewer orbits and higher urgency. Red-zone stacks need earlier action windows.',
    ),
    Act0RunnerOptionV1(
      id: 'green_zone',
      label: 'Green-zone player',
      isCorrect: false,
      preferredLabel: 'Red-zone player',
      betterAnswerLabel: 'Red-zone player',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not quite.',
      feedbackReason:
          'Green-zone players usually have room to wait for cleaner spots.',
    ),
    Act0RunnerOptionV1(
      id: 'same_zone',
      label: 'Both should act the same way',
      isCorrect: false,
      preferredLabel: 'Red-zone player',
      betterAnswerLabel: 'Red-zone player',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Close idea.',
      feedbackReason:
          'Hand class matters, but pressure context differs by zone. Urgency is not equal across stacks.',
    ),
  ],
);

final _w9CheckpointBubbleLineRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_checkpoint_bubble_line',
  caption: 'Near bubble: medium stack faces big-stack open.',
  hint: 'Risk premium should influence the response.',
  question: 'What is often the cleaner medium-stack plan?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_defense',
      label: 'Tighten defend and avoid thin all-ins',
      isCorrect: true,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'Bubble risk premium raises the bar for medium-stack stack-offs against covering stacks.',
    ),
    Act0RunnerOptionV1(
      id: 'chip_ev_only',
      label: 'Defend as wide as normal chip EV spot',
      isCorrect: false,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      betterAnswerLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Good direction.',
      feedbackReason:
          'Near bubble, tournament pressure changes the downside of busting. Pure chip-EV defense can be too loose.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Fold every hand until payout',
      isCorrect: false,
      preferredLabel: 'Tighten defend and avoid thin all-ins',
      betterAnswerLabel: 'Tighten defend and avoid thin all-ins',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Full shutdown leaks too much equity. The stronger line is disciplined but still competitive.',
    ),
  ],
);

final _world9TournamentCheckpointRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w9_tournament_checkpoint',
  caption:
      'Lesson learned: tournament pressure changes risk and adjustment windows.',
  hint:
      'Next you will convert pressure reads into opponent-specific player adjustments.',
  question:
      'What does tournament-pressure thinking add before player adjustment?',
  feedbackTitle: 'Tournament-pressure checkpoint.',
  feedbackReason:
      'You now read survival pressure, M-ratio urgency, and bubble risk premium. Next, apply those reads against specific player types.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pressure before exploit.',
      body:
          'First map pressure with stack and payout context. Then choose exploit lines based on who is overfolding, calling too wide, or avoiding risk.',
      focusLabels: <String>[
        'Survival pressure',
        'M-ratio',
        'Risk premium',
        'Player adjustment',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pressure_then_adjust',
      label: 'Map pressure first, then adjust by player',
      isCorrect: true,
      preferredLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pressure comes first.',
      feedbackReason:
          'That sequence is the bridge to World 10: pressure context first, player-specific exploit second.',
    ),
    Act0RunnerOptionV1(
      id: 'player_only',
      label: 'Adjust only by player type',
      isCorrect: false,
      preferredLabel: 'Map pressure first, then adjust by player',
      betterAnswerLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable start.',
      feedbackReason:
          'Player reads matter, but tournament pressure changes incentives first. Good exploits combine both layers.',
    ),
    Act0RunnerOptionV1(
      id: 'cards_only',
      label: 'Use only hole cards and ignore pressure',
      isCorrect: false,
      preferredLabel: 'Map pressure first, then adjust by player',
      betterAnswerLabel: 'Map pressure first, then adjust by player',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason:
          'Raw hand strength is not enough in tournament phases. Pressure context changes both your range and theirs.',
    ),
  ],
);

final _w9TablePressureNoticeRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w9_table_pressure_notice',
  lessonTitle: 'Tournament pressure checkpoint',
  lessonSubtitle: 'Tournament Pressure',
  caption:
      'Real table. Medium stack near the bubble faces a covering big-stack open.',
  hint: 'Read the pressure before you click call or jam.',
  question: 'What is the clean first pressure read?',
  feedbackTitle: 'Pressure read first.',
  feedbackReason:
      'Real-table tournament transfer starts by naming who carries the risk premium and who carries the leverage.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'medium_stack_pressure',
      label: 'Respect bubble pressure',
      isCorrect: true,
      preferredLabel: 'Respect bubble pressure',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the transfer. Bubble pressure hits the medium stack harder, while the covering stack can apply leverage.',
    ),
    Act0RunnerOptionV1(
      id: 'same_cash_logic',
      label: 'Treat it like cash',
      isCorrect: false,
      preferredLabel: 'Respect bubble pressure',
      betterAnswerLabel: 'Respect bubble pressure',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'That answer is tempting because the hand may still look playable in chip-EV terms. But the dominant cue is bubble pressure: the medium stack pays a much bigger bust-out cost than in cash, so call freedom tightens.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything_bubble',
      label: 'Fold everything',
      isCorrect: false,
      preferredLabel: 'Respect bubble pressure',
      betterAnswerLabel: 'Respect bubble pressure',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'This looks disciplined because bubble fear is real. But full shutdown folds too much. The cleaner read is selective pressure awareness: tighten versus leverage, not panic-fold every spot.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Name pressure before action.',
      body:
          'Real tournament spots get easier when you first identify who can pressure and who pays the bigger busting cost.',
      focusLabels: <String>['Bubble', 'Medium stack', 'Leverage'],
    ),
  ],
);

final _w10PlayerTypeIntroRunner = _w9BubblePressureIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_player_type_intro',
  lessonTitle: 'Who is at the table',
  lessonSubtitle: 'Player Adjustment',
  caption: 'Tag one clear tendency before you change strategy.',
  hint: 'One useful read beats five vague labels.',
  question: 'What is the first step in player adjustment?',
  feedbackTitle: 'Adjustment foundation.',
  feedbackReason:
      'Start by naming one reliable tendency. Then apply one targeted change instead of a full strategy rewrite.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Tag first, exploit second.',
      body:
          'Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.',
      focusLabels: <String>['Tendency', 'Tag', 'Exploit'],
    ),
  ],
);

final _w10NitTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_nit_tag',
  caption: 'Villain folds to steals repeatedly and rarely 3-bets.',
  hint: 'Tight fold-heavy behavior has one obvious label.',
  question: 'What is the most useful quick tag?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'nit',
      label: 'Tight-folding profile (nit)',
      isCorrect: true,
      preferredLabel: 'Tight-folding profile (nit)',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Frequent folds and low aggression map to a tight profile. That supports selective steal pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'maniac',
      label: 'Overbluffing maniac',
      isCorrect: false,
      preferredLabel: 'Tight-folding profile (nit)',
      betterAnswerLabel: 'Tight-folding profile (nit)',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Opposite profile.',
      feedbackReason:
          'A maniac over-aggresses. Here the evidence is repeated folds and low contest frequency.',
    ),
    Act0RunnerOptionV1(
      id: 'unknown',
      label: 'No read yet, ignore it',
      isCorrect: false,
      preferredLabel: 'Tight-folding profile (nit)',
      betterAnswerLabel: 'Tight-folding profile (nit)',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'Avoid overfitting tiny samples, but repeated folds are enough to begin a light exploit adjustment.',
    ),
  ],
);

final _w10LoosePassiveTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_loose_passive_tag',
  caption: 'Villain calls often preflop and postflop but rarely raises.',
  hint: 'Calling wide without raises signals a common profile.',
  question: 'What quick tag fits best?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'loose_passive',
      label: 'Loose-passive caller',
      isCorrect: true,
      preferredLabel: 'Loose-passive caller',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Frequent calls with low raise rate is the classic loose-passive tendency.',
    ),
    Act0RunnerOptionV1(
      id: 'tight_aggressive',
      label: 'Tight-aggressive reg',
      isCorrect: false,
      preferredLabel: 'Loose-passive caller',
      betterAnswerLabel: 'Loose-passive caller',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Not this one.',
      feedbackReason:
          'Tight-aggressive profiles fold more and raise more. This pattern is call-heavy and passive.',
    ),
    Act0RunnerOptionV1(
      id: 'random',
      label: 'Just random variance',
      isCorrect: false,
      preferredLabel: 'Loose-passive caller',
      betterAnswerLabel: 'Loose-passive caller',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Could happen short term.',
      feedbackReason:
          'Short samples can mislead, but repeated call-heavy behavior is actionable enough for mild value-heavy adjustment.',
    ),
  ],
);

final _w10OveraggressiveTagRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overaggressive_tag',
  caption: 'Villain double-barrels missed boards and raises often.',
  hint: 'Frequent pressure with weak showdowns points to one useful tag.',
  question: 'What quick tag fits best?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'overaggressive',
      label: 'Over-aggressive bluffer',
      isCorrect: true,
      preferredLabel: 'Over-aggressive bluffer',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'Repeated thin barrels and raise-heavy pressure suggest an over-aggressive profile worth tagging before you widen bluff-catches.',
    ),
    Act0RunnerOptionV1(
      id: 'nit',
      label: 'Tight-folding nit',
      isCorrect: false,
      preferredLabel: 'Over-aggressive bluffer',
      betterAnswerLabel: 'Over-aggressive bluffer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'Nits fold and avoid pressure. This player is doing the opposite by pushing action too often.',
    ),
    Act0RunnerOptionV1(
      id: 'unknown',
      label: 'No useful read yet',
      isCorrect: false,
      preferredLabel: 'Over-aggressive bluffer',
      betterAnswerLabel: 'Over-aggressive bluffer',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Careful instinct.',
      feedbackReason:
          'Tiny samples can be noisy, but repeated pressure plus weak showdowns is enough for a light over-aggressive tag.',
    ),
  ],
);

final _w10PlayerTypeRecapRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_type_recap',
  caption: 'Lesson learned: one tendency tag creates a cleaner exploit plan.',
  hint: 'Avoid complex labels before evidence is stable.',
  question: 'What is the tagging takeaway?',
  feedbackTitle: 'Player-type takeaway.',
  feedbackReason:
      'Start with one repeated tendency and one actionable adjustment. Complexity comes later if the read stays stable.',
);

final _w10OneLeverIntroRunner = _w10PlayerTypeIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_one_lever_intro',
  lessonTitle: 'Adjust one lever',
  caption:
      'Change one lever first: opening width, value density, or bluff rate.',
  hint: 'Small precise changes are easier to trust and test.',
  question: 'Why adjust one lever at a time?',
  feedbackTitle: 'One-lever foundation.',
  feedbackReason:
      'Single-lever changes reduce chaos. You can see if the exploit works before layering more adjustments.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Precision over chaos.',
      body:
          'If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.',
      focusLabels: <String>['One lever', 'Steal wider', 'Value heavier'],
    ),
  ],
);

final _w10VsNitOpenWiderRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_nit_open_wider',
  caption: 'Blinds fold too much to late-position steals.',
  hint: 'Overfolding behind you increases steal EV.',
  question: 'What is the clean first exploit?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'open_wider',
      label: 'Open slightly wider in late position',
      isCorrect: true,
      preferredLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Against overfolders, wider late opens capture blinds more often with low resistance.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff_more_streets',
      label: 'Triple-barrel every bluff spot',
      isCorrect: false,
      preferredLabel: 'Open slightly wider in late position',
      betterAnswerLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much change.',
      feedbackReason:
          'That is a broad multi-lever shift. Start with a simpler preflop widen exploit first.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Keep baseline and ignore read',
      isCorrect: false,
      preferredLabel: 'Open slightly wider in late position',
      betterAnswerLabel: 'Open slightly wider in late position',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but misses value.',
      feedbackReason:
          'Baseline is okay when uncertain, but repeated overfolding supports a measured widen adjustment.',
    ),
  ],
);

final _w10VsCallerValueHeavierRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_caller_value_heavier',
  caption: 'Villain calls down too wide with weak pairs.',
  hint: 'Call-heavy opponents pay off thin value more often.',
  question: 'What is the cleaner exploit lever?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value_heavier',
      label: 'Value-bet heavier, bluff less often',
      isCorrect: true,
      preferredLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'Overcallers pay value and resist bluffs. Shift the mix toward value first.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff_heavier',
      label: 'Bluff more anyway',
      isCorrect: false,
      preferredLabel: 'Value-bet heavier, bluff less often',
      betterAnswerLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Inverse exploit.',
      feedbackReason:
          'If opponents call too much, bluffs lose EV. Heavier value is the direct exploit.',
    ),
    Act0RunnerOptionV1(
      id: 'allin_only',
      label: 'Only shove strong hands',
      isCorrect: false,
      preferredLabel: 'Value-bet heavier, bluff less often',
      betterAnswerLabel: 'Value-bet heavier, bluff less often',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too coarse.',
      feedbackReason:
          'You want a value-heavy mix, not a one-size all-in strategy. Keep your line flexible and disciplined.',
    ),
  ],
);

final _w10VsStickyDefenderTightenStealsRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_vs_sticky_defender_tighten_steals',
  caption: 'Blinds defend wide and call postflop too often.',
  hint: 'A sticky defender changes the cleanest steal lever.',
  question: 'What is the better first adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'tighten_steals',
      label: 'Tighten the weakest steals and keep stronger value',
      isCorrect: true,
      preferredLabel: 'Tighten the weakest steals and keep stronger value',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'If blinds defend too wide, weak auto-steals lose value. Keep the exploit specific by trimming trash and preserving stronger opens.',
    ),
    Act0RunnerOptionV1(
      id: 'steal_wider_anyway',
      label: 'Steal even wider',
      isCorrect: false,
      preferredLabel: 'Tighten the weakest steals and keep stronger value',
      betterAnswerLabel: 'Tighten the weakest steals and keep stronger value',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'Sticky defenders reduce fold equity. The cleaner lever is to drop the weakest steals and rely on stronger value-heavy opens.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Make no change until the sample is huge',
      isCorrect: false,
      preferredLabel: 'Tighten the weakest steals and keep stronger value',
      betterAnswerLabel: 'Tighten the weakest steals and keep stronger value',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe default.',
      feedbackReason:
          'Massive samples are not required for a light one-lever adjustment. Repeated sticky defense is enough to trim the weakest steals.',
    ),
  ],
);

final _w10TableValueVsCallerTransferRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_table_value_vs_caller_transfer',
  caption:
      'Real table. BTN opens K-Q, BB calls too wide, and the flop is K-7-2 rainbow.',
  hint:
      'Call-heavy opponents pay value more often. Ask what changes first before adding more bluffs.',
  question: 'What is the cleaner first adjustment here?',
  table: _w6ValueRangeActionRunner.table.copyWith(
    heroCards: _heroKqCards,
    boardCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: '7', suit: 'd'),
      Act0CardStateV1(rank: '2', suit: 'c'),
    ],
    streetLabel: 'Flop',
    potLabel: 'Pot 6 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Top pair vs caller',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'BTN opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BB calls'),
      Act0ActionTrailItemV1(label: 'BB checks'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'lean_value',
      label: 'Lean value, bluff less',
      isCorrect: true,
      preferredLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp live adjustment.',
      feedbackReason:
          'That is the real-table transfer. If BB calls too wide, top pair gets paid by weaker hands more often, so value rises and bluff frequency should shrink.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff_more',
      label: 'Bluff more versus passive BB',
      isCorrect: false,
      preferredLabel: 'Lean value, bluff less',
      betterAnswerLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong mix shift.',
      feedbackReason:
          'Passive callers do not fold enough to make extra bluffs clean. The better first lever is value heavier, bluff lighter.',
    ),
    Act0RunnerOptionV1(
      id: 'force_big_pot',
      label: 'Make every top pair hand huge immediately',
      isCorrect: false,
      preferredLabel: 'Lean value, bluff less',
      betterAnswerLabel: 'Lean value, bluff less',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too coarse.',
      feedbackReason:
          'The exploit is not to inflate every pot blindly. Keep the shift controlled: extract more value from callers without turning one read into a reckless line.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Caller changes the mix.',
      body:
          'This is the changed frame: same one-lever idea, now at a live table. When BB calls too wide, value hands move up in priority and bluffs move down.',
      focusLabels: <String>['Real table', 'Calls too wide', 'Value', 'Bluff'],
    ),
  ],
);

final _w10OneLeverRecapRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_one_lever_recap',
  caption: 'Lesson learned: one lever gives cleaner exploit feedback loops.',
  hint: 'Test one change before stacking new assumptions.',
  question: 'What is the one-lever takeaway?',
  feedbackTitle: 'One-lever takeaway.',
  feedbackReason:
      'Exploit quality improves when changes are precise and testable. Broad rewrites create noise and confusion.',
);

final _w10ExploitGuardrailsIntroRunner = _w10OneLeverIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w10_guardrails_intro',
  lessonTitle: 'Exploit guardrails',
  caption: 'Exploit does not mean abandoning discipline or hand quality.',
  hint: 'Guardrails keep you from over-adjusting on thin evidence.',
  question: 'Why do exploit guardrails matter?',
  feedbackTitle: 'Guardrail foundation.',
  feedbackReason:
      'Guardrails stop you from turning a useful exploit into a leak. Strong exploit play stays selective and evidence-based.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Exploit with control.',
      body:
          'Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.',
      focusLabels: <String>['Sample quality', 'Baseline', 'Control'],
    ),
  ],
);

final _w10OverbluffPunishRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_overbluff_punish',
  caption: 'Villain barrels many missed draws in obvious spots.',
  hint: 'Overbluffing can be punished by wider bluff-catch windows.',
  question: 'What is the cleaner exploit response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bluffcatch_more',
      label: 'Bluff-catch a bit wider with blockers',
      isCorrect: true,
      preferredLabel: 'Bluff-catch a bit wider with blockers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Selective bluff-catch works.',
      feedbackReason:
          'Against overbluffs, selective wider bluff-catching is profitable when your line blocks value combos.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything',
      label: 'Fold everything to avoid variance',
      isCorrect: false,
      preferredLabel: 'Bluff-catch a bit wider with blockers',
      betterAnswerLabel: 'Bluff-catch a bit wider with blockers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Versus overbluffers, over-folding gives away too much EV. You need selective bluff-catch defense.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_call_any',
      label: 'Hero-call every river',
      isCorrect: false,
      preferredLabel: 'Bluff-catch a bit wider with blockers',
      betterAnswerLabel: 'Bluff-catch a bit wider with blockers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too extreme.',
      feedbackReason:
          'You should widen selectively, not call blindly. Guardrails keep exploit from becoming a punt.',
    ),
  ],
);

final _w10UnderbluffFoldMoreRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_underbluff_fold_more',
  caption: 'Villain reaches river with strong value and few bluffs.',
  hint: 'Underbluffing changes bluff-catch requirements.',
  question: 'What is the sharper adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_more',
      label: 'Fold more marginal bluff-catchers',
      isCorrect: true,
      preferredLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'If bluff frequency is too low, marginal calls lose EV. Disciplined folds become the exploit.',
    ),
    Act0RunnerOptionV1(
      id: 'call_normal',
      label: 'Call normal baseline frequency',
      isCorrect: false,
      preferredLabel: 'Fold more marginal bluff-catchers',
      betterAnswerLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Reasonable default.',
      feedbackReason:
          'Baseline is okay with uncertainty, but clear underbluff evidence supports tighter bluff-catch calls.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_bluff',
      label: 'Raise bluff more often',
      isCorrect: false,
      preferredLabel: 'Fold more marginal bluff-catchers',
      betterAnswerLabel: 'Fold more marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'Against underbluffers, aggressive bluff-raise lines usually burn chips. Tighten instead.',
    ),
  ],
);

final _w10GuardrailSampleSizeRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_guardrail_sample_size',
  caption: 'You saw two odd hands but no long pattern yet.',
  hint: 'Guardrails protect you when evidence is still thin.',
  question: 'What is the cleaner exploit posture?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'small_probe',
      label: 'Make only a small adjustment and keep watching',
      isCorrect: true,
      preferredLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong choice.',
      feedbackReason:
          'Two hands can justify attention, not a full strategy swing. Small exploit probes plus more evidence keep your line disciplined.',
    ),
    Act0RunnerOptionV1(
      id: 'full_counter',
      label: 'Commit to a full counter-strategy immediately',
      isCorrect: false,
      preferredLabel: 'Make only a small adjustment and keep watching',
      betterAnswerLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'Guardrails exist to stop overreaction on thin samples. Extreme counters create noise faster than value.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_everything',
      label: 'Ignore the hands completely',
      isCorrect: false,
      preferredLabel: 'Make only a small adjustment and keep watching',
      betterAnswerLabel: 'Make only a small adjustment and keep watching',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'You should not overreact, but ignoring useful early evidence also wastes exploit edge. Watch and adjust lightly.',
    ),
  ],
);

final _w10ExploitGuardrailsRecapRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_guardrails_recap',
  caption: 'Lesson learned: exploits work best with guardrails and evidence.',
  hint: 'Do not let one read become a full strategy collapse.',
  question: 'What is the guardrail takeaway?',
  feedbackTitle: 'Guardrail takeaway.',
  feedbackReason:
      'Exploit discipline means selective changes, stable baselines, and enough evidence before major shifts.',
);

final _w10CheckpointTagLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_tag_line',
  caption: 'Opponent folds blinds often but calls rivers too wide.',
  hint: 'You can tag both tendencies, then choose one main lever first.',
  question: 'What is the cleaner first step?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'primary_tag',
      label: 'Choose one primary tendency and act on it',
      isCorrect: true,
      preferredLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Prioritizing one tendency keeps the exploit coherent and measurable before layering more changes.',
    ),
    Act0RunnerOptionV1(
      id: 'all_changes',
      label: 'Change preflop and postflop everything now',
      isCorrect: false,
      preferredLabel: 'Choose one primary tendency and act on it',
      betterAnswerLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too chaotic.',
      feedbackReason:
          'Full rewrites hide whether your exploit is working. Start with one controllable lever.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_read',
      label: 'Ignore reads and stay static',
      isCorrect: false,
      preferredLabel: 'Choose one primary tendency and act on it',
      betterAnswerLabel: 'Choose one primary tendency and act on it',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe default.',
      feedbackReason:
          'Static play is safer than chaos, but reliable reads deserve small targeted adjustment.',
    ),
  ],
);

final _w10CheckpointLeverLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_lever_line',
  caption: 'A tight blind fold profile appears in your sample.',
  hint: 'Single-lever adjustment is the test.',
  question: 'Which exploit line is the cleanest first move?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'widen_steal',
      label: 'Widen late steals slightly',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Well done.',
      feedbackReason:
          'That is a clear one-lever exploit against fold-heavy blinds and is easy to track.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_all_sizes',
      label: 'Change every sizing in all positions',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Over-adjustment.',
      feedbackReason:
          'This creates too much noise. One measured lever gives better feedback and lower risk.',
    ),
    Act0RunnerOptionV1(
      id: 'flat_everything',
      label: 'Flat-call more in every seat',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Not targeted.',
      feedbackReason:
          'Calling wider everywhere does not directly attack blind overfolding. Keep the exploit specific.',
    ),
  ],
);

final _w10CheckpointGuardrailLineRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_checkpoint_guardrail_line',
  caption: 'You saw one wild bluff from villain this orbit.',
  hint: 'Single hand reads can be noisy.',
  question: 'What is the best guardrail action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'small_adjust',
      label: 'Make a small adjustment and gather more evidence',
      isCorrect: true,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Excellent spot.',
      feedbackReason:
          'Guardrails mean respecting uncertainty. Small exploit moves plus more data beats extreme reactions.',
    ),
    Act0RunnerOptionV1(
      id: 'hard_counter',
      label: 'Hard-counter every future street now',
      isCorrect: false,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      betterAnswerLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'One hand is rarely enough for a full counter-strategy. Overreaction creates new leaks.',
    ),
    Act0RunnerOptionV1(
      id: 'no_adjust',
      label: 'Ignore all reads forever',
      isCorrect: false,
      preferredLabel: 'Make a small adjustment and gather more evidence',
      betterAnswerLabel: 'Make a small adjustment and gather more evidence',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'You should avoid overreaction, but never adjusting also misses exploit value.',
    ),
  ],
);

final _world10PlayerAdjustmentCheckpointRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w10_player_adjustment_checkpoint',
  caption: 'Lesson learned: tag tendency, adjust one lever, keep guardrails.',
  hint:
      'Next you will transfer these guardrails-based adjustments into real-play decisions across mixed table conditions.',
  question: 'What does player adjustment add before real-play transfer?',
  feedbackTitle: 'Player-adjustment checkpoint.',
  feedbackReason:
      'You can now convert pressure reads and tendency tags into opponent-specific exploit lines while keeping guardrails and discipline. Real-play transfer is the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Exploit with structure.',
      body:
          'Tag one tendency, choose one lever, keep guardrails, then test across table dynamics instead of one isolated hand.',
      focusLabels: <String>[
        'Tendency tag',
        'One lever',
        'Guardrails',
        'Real-play transfer',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'structured_exploit',
      label: 'Structured exploit before transfer',
      isCorrect: true,
      preferredLabel: 'Structured exploit before transfer',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Spot on.',
      feedbackReason:
          'That is the W10 bridge to W11: structured adaptation first, then robust transfer across live play conditions.',
    ),
    Act0RunnerOptionV1(
      id: 'intuition_only',
      label: 'Pure intuition with no structure',
      isCorrect: false,
      preferredLabel: 'Structured exploit before transfer',
      betterAnswerLabel: 'Structured exploit before transfer',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too loose.',
      feedbackReason:
          'Intuition helps, but without structure your adjustments become inconsistent and hard to trust.',
    ),
    Act0RunnerOptionV1(
      id: 'baseline_only',
      label: 'Never adjust, stay baseline forever',
      isCorrect: false,
      preferredLabel: 'Structured exploit before transfer',
      betterAnswerLabel: 'Structured exploit before transfer',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but capped.',
      feedbackReason:
          'Baseline protects you, but learning to exploit safely is the point of this world before real-play transfer.',
    ),
  ],
);

final _w10TableAdjustmentNoticeRunner = _w10CheckpointLeverLineRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w10_table_adjustment_notice',
  lessonTitle: 'Player-adjustment checkpoint',
  lessonSubtitle: 'Player Adjustment',
  caption:
      'Real table. Both blinds have folded to your late steals again and again.',
  hint: 'Choose the first exploit you can actually track at the table.',
  question: 'What is the clean first live adjustment?',
  feedbackTitle: 'Adjustment first, not chaos.',
  feedbackReason:
      'Real-table exploit transfer works when one repeated tendency turns into one small tracked adjustment.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'widen_late_steals_small',
      label: 'Widen late steals a bit',
      isCorrect: true,
      preferredLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'That is the clean transfer: repeated blind overfolding supports one small late-position widen, not a full strategy rewrite.',
    ),
    Act0RunnerOptionV1(
      id: 'rewrite_everything',
      label: 'Rewrite everything now',
      isCorrect: false,
      preferredLabel: 'Widen late steals a bit',
      betterAnswerLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'That answer is tempting because the pattern feels obvious and profitable. But the dominant cue is sample quality: one repeated blind-fold pattern supports one small tracked lever, not a whole strategy rewrite.',
    ),
    Act0RunnerOptionV1(
      id: 'never_adjust',
      label: 'Ignore the pattern',
      isCorrect: false,
      preferredLabel: 'Widen late steals a bit',
      betterAnswerLabel: 'Widen late steals a bit',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe fallback.',
      feedbackReason:
          'Baseline feels safe because it avoids overreaction. But repeated overfolding is enough evidence for one small exploit shift. The cleaner read is measured adjustment, not permanent passivity.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Carry one exploit to the table.',
      body:
          'Tag the tendency, pick one lever, and keep the change small enough that you can see whether it is working.',
      focusLabels: <String>['Repeated fold', 'One lever', 'Trackable change'],
    ),
  ],
);

final _w11SessionPlanIntroRunner = _w10ExploitGuardrailsIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_session_plan_intro',
  lessonTitle: 'Session plan in 30 seconds',
  lessonSubtitle: 'Real Play Transfer',
  caption: 'Pick one concrete focus before each real session starts.',
  hint: 'One focus keeps decisions clear under pressure.',
  question: 'What is the best pre-session plan style?',
  feedbackTitle: 'Transfer foundation.',
  feedbackReason:
      'Real-play transfer improves when your session starts with one target behavior, not a long checklist.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'One focus, many reps.',
      body:
          'Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.',
      focusLabels: <String>['One focus', 'Reps', 'Post-session review'],
    ),
  ],
);

final _w11PlanFocusChoiceRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_focus_choice',
  caption: 'You have 45 minutes and noisy tables today.',
  hint: 'Simple focus beats wide ambition.',
  question: 'What is the cleaner session objective?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_focus',
      label: 'One measurable focus for the whole session',
      isCorrect: true,
      preferredLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Stack risk: correct.',
      feedbackReason:
          'A single measurable focus transfers training into real play with less mental overload.',
    ),
    Act0RunnerOptionV1(
      id: 'many_focuses',
      label: 'Track six improvements at once',
      isCorrect: false,
      preferredLabel: 'One measurable focus for the whole session',
      betterAnswerLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much load.',
      feedbackReason:
          'Too many goals blur feedback and weaken transfer. One target gives cleaner repetition.',
    ),
    Act0RunnerOptionV1(
      id: 'no_plan',
      label: 'No plan, just react',
      isCorrect: false,
      preferredLabel: 'One measurable focus for the whole session',
      betterAnswerLabel: 'One measurable focus for the whole session',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable fallback.',
      feedbackReason:
          'Reactive play can still work, but transfer quality rises when one focus is defined before action starts.',
    ),
  ],
);

final _w11PlanAvoidOverloadRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_avoid_overload',
  caption: 'Your prior session had scattered notes and no clear pattern.',
  hint: 'Reduce cognitive load first.',
  question: 'What is the sharper adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'narrow_goal',
      label: 'Narrow to one transfer goal next session',
      isCorrect: true,
      preferredLabel: 'Narrow to one transfer goal next session',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One goal clears the noise.',
      feedbackReason:
          'Transfer improves when you narrow scope and collect cleaner evidence on one behavior.',
    ),
    Act0RunnerOptionV1(
      id: 'more_complexity',
      label: 'Add more tracking categories',
      isCorrect: false,
      preferredLabel: 'Narrow to one transfer goal next session',
      betterAnswerLabel: 'Narrow to one transfer goal next session',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Wrong direction.',
      feedbackReason:
          'More categories usually increase noise. Start simpler to get stable transfer behavior first.',
    ),
    Act0RunnerOptionV1(
      id: 'repeat_none',
      label: 'Avoid setting any goal again',
      isCorrect: false,
      preferredLabel: 'Narrow to one transfer goal next session',
      betterAnswerLabel: 'Narrow to one transfer goal next session',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too passive.',
      feedbackReason:
          'Removing goals avoids overload but also weakens deliberate transfer. Keep one simple target.',
    ),
  ],
);

final _w11PlanTableFocusTransferRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_plan_table_focus_transfer',
  caption:
      'Real table. You have one hour before a tired evening session starts and the first orbit will move fast.',
  hint:
      'Pick one focus you can notice as a trigger during the session and review after the session ends.',
  question: 'What is the cleaner session plan here?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_focus_loop',
      label: 'Pick one focus for the session',
      isCorrect: true,
      preferredLabel: 'Pick one focus for the session',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean transfer plan.',
      feedbackReason:
          'That is the real-table transfer. One focus keeps the session executable, gives you one trigger to notice live, and leaves one clean review target after the session.',
    ),
    Act0RunnerOptionV1(
      id: 'many_focuses_now',
      label: 'Track every leak from the start',
      isCorrect: false,
      preferredLabel: 'Pick one focus for the session',
      betterAnswerLabel: 'Pick one focus for the session',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too noisy.',
      feedbackReason:
          'A crowded plan weakens transfer. If the session starts with too many goals, the live trigger is harder to see and the review becomes blur instead of one actionable output.',
    ),
    Act0RunnerOptionV1(
      id: 'no_focus_until_review',
      label: 'Play first and decide later',
      isCorrect: false,
      preferredLabel: 'Pick one focus for the session',
      betterAnswerLabel: 'Pick one focus for the session',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too loose a loop.',
      feedbackReason:
          'Review still matters, but the loop is weaker without a one-focus plan. Real table transfer is stronger when the session starts with one focus, then checks one trigger, then closes with one review note.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Plan the loop before the cards fly.',
      body:
          'Real table transfer starts before the first hand. One focus sets the session goal, one trigger tells you when to apply it, and one review note closes the loop after play.',
      focusLabels: <String>['Real table', 'One focus', 'Trigger', 'Review'],
    ),
  ],
);

final _w11SessionPlanRecapRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_session_plan_recap',
  caption: 'Lesson learned: one focus plan creates cleaner real-play transfer.',
  hint: 'Simple plan first, then repetitions.',
  question: 'What is the session-plan takeaway?',
  feedbackTitle: 'Plan takeaway.',
  feedbackReason:
      'Consistent one-focus planning improves execution quality and makes post-session review actionable.',
);

final _w11TriggerReadIntroRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_trigger_intro',
  lessonTitle: 'In-session trigger reads',
  caption: 'When a trigger appears, apply one prepared adjustment quickly.',
  hint: 'Trigger -> one lever -> observe result.',
  question: 'What is a trigger read for transfer play?',
  feedbackTitle: 'Trigger foundation.',
  feedbackReason:
      'A trigger read is a repeated in-session pattern that activates one preplanned adjustment.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pattern to action.',
      body:
          'If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.',
      focusLabels: <String>['Trigger', 'One lever', 'Observe result'],
    ),
  ],
);

final _w11TriggerOverfoldBlindsRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_overfold_blinds',
  caption: 'Both blinds folded to 5 of your last 6 steals.',
  hint: 'Overfold trigger supports a preflop widen lever.',
  question: 'What is the cleaner transfer action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'widen_late_steal',
      label: 'Widen late steals slightly',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Overfold means widen.',
      feedbackReason:
          'This is a direct trigger-to-lever transfer with clear evidence and low complexity.',
    ),
    Act0RunnerOptionV1(
      id: 'threebarrel_all',
      label: 'Shift to heavy multi-street bluff plan',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'The trigger is preflop overfolding. Use a matching preflop lever first, not a full postflop rewrite.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_trigger',
      label: 'Ignore the trigger and keep static',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly',
      betterAnswerLabel: 'Widen late steals slightly',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe but misses edge.',
      feedbackReason:
          'Static play is stable, but repeated triggers support small targeted transfer adjustments.',
    ),
  ],
);

final _w11TriggerOvercallFlopRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_overcall_flop',
  caption: 'Villain keeps calling flop and turn with weak pairs.',
  hint: 'Overcall trigger points to value-density change.',
  question: 'What is the sharper one-lever response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'value_heavier',
      label: 'Bet value heavier and trim bluffs',
      isCorrect: true,
      preferredLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Callers want value.',
      feedbackReason:
          'Against overcalls, value-heavy transfer lines outperform bluff-heavy defaults.',
    ),
    Act0RunnerOptionV1(
      id: 'bluff_more',
      label: 'Bluff more since they look weak',
      isCorrect: false,
      preferredLabel: 'Bet value heavier and trim bluffs',
      betterAnswerLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Inverse exploit.',
      feedbackReason:
          'Frequent callers reduce bluff EV. Value density is the cleaner transfer adjustment.',
    ),
    Act0RunnerOptionV1(
      id: 'no_change',
      label: 'Never adjust in-session',
      isCorrect: false,
      preferredLabel: 'Bet value heavier and trim bluffs',
      betterAnswerLabel: 'Bet value heavier and trim bluffs',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too rigid.',
      feedbackReason:
          'Rigid baseline avoids errors but gives up clear transfer edges from repeated triggers.',
    ),
  ],
);

final _w11TriggerSmallPriceContinueRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_small_price_continue',
  caption:
      'Real table. CO opens, Hero calls BTN with Q-J suited. Flop comes J-7-4 rainbow. CO bets 2 BB into 8 BB at 35 BB effective.',
  hint: 'Real play means combining cues, not naming one concept.',
  question: 'What is the cleaner response?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroQJsCards,
    boardCards: _boardJ74FlopCards,
    streetLabel: 'Flop',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'BTN, top pair, small price',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls'),
      Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call_once',
      label: 'Call once in position',
      isCorrect: true,
      preferredLabel: 'Call once in position',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean table read.',
      feedbackReason:
          'Position, top pair, and a cheap price all support a continue once. The clean action comes from the whole table, not just the hand label.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_now',
      label: 'Fold now',
      isCorrect: false,
      preferredLabel: 'Call once in position',
      betterAnswerLabel: 'Call once in position',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too tight.',
      feedbackReason:
          'Folding is tempting if you fear later streets, but the price is kind, the board is dry, and position keeps the continue clean for now.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_now',
      label: 'Raise for protection now',
      isCorrect: false,
      preferredLabel: 'Call once in position',
      betterAnswerLabel: 'Call once in position',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable but noisy.',
      feedbackReason:
          'Raising can feel proactive, but it bloats the pot too early. The sharper transfer line is use position and the cheap price first.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Price plus position can support a continue.',
      body:
          'Read seat, hand, board, and price together. A marginal made hand can continue when the price is small and position keeps control.',
      focusLabels: <String>['Position', 'Top pair', 'Small price', 'Dry board'],
    ),
  ],
);

final _w11TriggerBadPriceFoldRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_trigger_bad_price_fold',
  caption:
      'Same hand again. Turn bricks on J-7-4-2. CO now bets 12 BB into 14 BB at 100 BB effective.',
  hint: 'A good hand can still be the wrong continue at the wrong price.',
  question: 'What is the cleaner response now?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroQJsCards,
    boardCards: _boardJ742TurnCards,
    streetLabel: 'Turn',
    potLabel: 'Pot 14 BB',
    toCallLabel: 'To call 12 BB',
    centerLabel: 'BTN, top pair, bad price',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls'),
      Act0ActionTrailItemV1(label: 'Flop bet called'),
      Act0ActionTrailItemV1(label: 'CO bets 12 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_turn',
      label: 'Fold the turn',
      isCorrect: true,
      preferredLabel: 'Fold the turn',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong contrast read.',
      feedbackReason:
          'Top pair still looks decent, which makes calling tempting. But the price is now bad, the action shows pressure, and deep stacks keep costly future risk alive.',
    ),
    Act0RunnerOptionV1(
      id: 'call_top_pair',
      label: 'Call the top pair',
      isCorrect: false,
      preferredLabel: 'Fold the turn',
      betterAnswerLabel: 'Fold the turn',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting hand-label trap.',
      feedbackReason:
          'Top pair is why this feels close, but real play is not only hand naming. Price, action trail, and deeper future risk now lean against the continue.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_turn',
      label: 'Jam to deny equity',
      isCorrect: false,
      preferredLabel: 'Fold the turn',
      betterAnswerLabel: 'Fold the turn',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too much pressure back.',
      feedbackReason:
          'The cue is not to force a larger pot. The cleaner read is step away from the expensive continue instead of escalating a fragile one-pair hand.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Same hand, worse continue.',
      body:
          'A hand can be fine at one price and wrong at another. Read the action trail and future risk before treating top pair like an auto-continue.',
      focusLabels: <String>[
        'Same hand',
        'Bad price',
        'Action pressure',
        'Deep risk',
      ],
    ),
  ],
);

final _w11TriggerReadRecapRunner = _w11TriggerReadIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_trigger_recap',
  caption:
      'Lesson learned: trigger reads convert pattern into one action lever.',
  hint: 'Trigger must be repeated, not imagined.',
  question: 'What is the trigger-read takeaway?',
  feedbackTitle: 'Trigger takeaway.',
  feedbackReason:
      'Strong transfer uses repeated triggers and simple one-lever responses you can track over time.',
);

final _w11ReviewLoopIntroRunner = _w11SessionPlanIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w11_review_loop_intro',
  lessonTitle: 'Post-session review loop',
  caption: 'After play, name one leak and one repair target for tomorrow.',
  hint: 'One leak, one fix, one next session test.',
  question: 'What makes review actionable?',
  feedbackTitle: 'Review-loop foundation.',
  feedbackReason:
      'Actionable review links one observed leak to one concrete repair task for the next session.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Close the loop daily.',
      body:
          'Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.',
      focusLabels: <String>['Plan', 'Trigger', 'Review', 'Daily loop'],
    ),
  ],
);

final _w11ReviewPickLeakRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_review_pick_leak',
  caption: 'Today you missed thin value and overcalled one river.',
  hint: 'Pick the leak that repeats most often first.',
  question: 'What is the clean first review action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'pick_priority',
      label: 'Select one repeated leak as priority',
      isCorrect: true,
      preferredLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pick the repeat leak.',
      feedbackReason:
          'Choosing one repeated leak gives the highest transfer value for the next focused session.',
    ),
    Act0RunnerOptionV1(
      id: 'fix_everything',
      label: 'Fix all leaks at once tomorrow',
      isCorrect: false,
      preferredLabel: 'Select one repeated leak as priority',
      betterAnswerLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Overload risk.',
      feedbackReason:
          'Trying to repair everything usually weakens execution. Prioritize one leak for stronger transfer.',
    ),
    Act0RunnerOptionV1(
      id: 'skip_review',
      label: 'Skip review and just play more volume',
      isCorrect: false,
      preferredLabel: 'Select one repeated leak as priority',
      betterAnswerLabel: 'Select one repeated leak as priority',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Volume helps.',
      feedbackReason:
          'Volume without structured review slows improvement. One focused repair keeps the loop productive.',
    ),
  ],
);

final _w11ReviewDefineFixRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_review_define_fix',
  caption: 'Priority leak: overcalling rivers vs tight players.',
  hint: 'Define an if-then fix for next session.',
  question: 'Which repair target is most actionable?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'if_then_fix',
      label: 'If villain underbluffs, fold marginal bluff-catchers',
      isCorrect: true,
      preferredLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Specific fix transfers.',
      feedbackReason:
          'Specific if-then repair targets transfer directly into live decisions better than generic intentions.',
    ),
    Act0RunnerOptionV1(
      id: 'generic_fix',
      label: 'Play better rivers somehow',
      isCorrect: false,
      preferredLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      betterAnswerLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too vague.',
      feedbackReason:
          'Vague goals are hard to execute. Use behavior-specific repair rules instead.',
    ),
    Act0RunnerOptionV1(
      id: 'no_fix',
      label: 'Do not set any repair task',
      isCorrect: false,
      preferredLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      betterAnswerLabel: 'If villain underbluffs, fold marginal bluff-catchers',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Missed chance.',
      feedbackReason:
          'Skipping repair leaves the leak unchanged. A simple explicit fix improves next-session transfer.',
    ),
  ],
);

final _w11ReviewLoopRecapRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_review_loop_recap',
  caption: 'Lesson learned: review closes the transfer loop into tomorrow.',
  hint: 'Write one leak and one fix before ending session.',
  question: 'What is the review-loop takeaway?',
  feedbackTitle: 'Review-loop takeaway.',
  feedbackReason:
      'Post-session review converts play into learning only when it outputs one clear repair target for the next day.',
);

final _w11CheckpointPlanLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_plan_line',
  caption: 'You start a session after a long workday with low energy.',
  hint: 'Plan should stay simple and executable.',
  question: 'What is the clean transfer plan?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'simple_focus',
      label: 'Set one low-friction focus target',
      isCorrect: true,
      preferredLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Low-energy plan first.',
      feedbackReason:
          'Low-energy sessions still transfer well when focus is clear, small, and measurable.',
    ),
    Act0RunnerOptionV1(
      id: 'complex_plan',
      label: 'Set a complex multi-phase improvement plan',
      isCorrect: false,
      preferredLabel: 'Set one low-friction focus target',
      betterAnswerLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too heavy.',
      feedbackReason:
          'Complex plans collapse under fatigue. Transfer needs practical execution, not idealized complexity.',
    ),
    Act0RunnerOptionV1(
      id: 'no_objective',
      label: 'Play with no objective',
      isCorrect: false,
      preferredLabel: 'Set one low-friction focus target',
      betterAnswerLabel: 'Set one low-friction focus target',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Simpler, but blind.',
      feedbackReason:
          'No objective removes overload but also removes learning direction. One simple target is better.',
    ),
  ],
);

final _w11CheckpointTriggerLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_trigger_line',
  caption: 'You detect repeated blind overfold and river underbluff patterns.',
  hint: 'Pick one trigger-action pair first.',
  question: 'Which transfer action is best?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_trigger_action',
      label: 'Activate one trigger-action lever now',
      isCorrect: true,
      preferredLabel: 'Activate one trigger-action lever now',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'One trigger, one lever.',
      feedbackReason:
          'Single trigger-action execution keeps transfer disciplined and observable in real play.',
    ),
    Act0RunnerOptionV1(
      id: 'all_trigger_actions',
      label: 'Apply all exploit levers immediately',
      isCorrect: false,
      preferredLabel: 'Activate one trigger-action lever now',
      betterAnswerLabel: 'Activate one trigger-action lever now',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'Multi-lever changes create noise and execution errors. Start with one trigger-action pair.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_triggers',
      label: 'Ignore triggers and wait for review only',
      isCorrect: false,
      preferredLabel: 'Activate one trigger-action lever now',
      betterAnswerLabel: 'Activate one trigger-action lever now',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Review matters.',
      feedbackReason:
          'Review is important, but in-session trigger execution is the transfer mechanism itself.',
    ),
  ],
);

final _w11CheckpointReviewLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_review_line',
  caption: 'Session ends with mixed results and two recurring mistakes.',
  hint: 'Review should output one next-session repair task.',
  question: 'What is the strongest closeout action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'one_repair_output',
      label: 'Review one leak',
      isCorrect: true,
      preferredLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Loop closed cleanly.',
      feedbackReason:
          'Transfer compounds when review creates one actionable output that directly shapes the next session plan.',
    ),
    Act0RunnerOptionV1(
      id: 'long_notes',
      label: 'Write long notes',
      isCorrect: false,
      preferredLabel: 'Review one leak',
      betterAnswerLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Incomplete loop.',
      feedbackReason:
          'Long notes feel productive because they capture a lot. But the dominant cue here is actionability. Without one chosen repair, the next session still starts fuzzy.',
    ),
    Act0RunnerOptionV1(
      id: 'skip_closeout',
      label: 'Skip closeout',
      isCorrect: false,
      preferredLabel: 'Review one leak',
      betterAnswerLabel: 'Review one leak',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Common habit.',
      feedbackReason:
          'Skipping closeout is tempting because the session is over and the key hands still feel fresh. But memory fades fast. The cleaner read is protect tomorrow with one explicit leak-and-fix note.',
    ),
  ],
);

final _w11CheckpointMixedTableLineRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w11_checkpoint_mixed_table_line',
  caption:
      'Real table. HJ opens 2.5 BB. Hero calls BTN with A-J suited at 30 BB effective. Flop is A-8-4 two-tone. HJ bets 5 BB into 8 BB.',
  hint: 'Read seat, hand, board, price, and stack before choosing.',
  question: 'What is the cleaner integrated response?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroAJsCards,
    boardCards: _boardA84TwoToneCards,
    streetLabel: 'Flop',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 5 BB',
    centerLabel: 'BTN, top pair, 30 BB',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'HJ opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls'),
      Act0ActionTrailItemV1(label: 'HJ bets 5 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call_in_position',
      label: 'Call in position and keep the range wide',
      isCorrect: true,
      preferredLabel: 'Call in position and keep the range wide',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Integrated read.',
      feedbackReason:
          'Position, top pair, and a still-manageable stack depth support a continue, but the bigger price and two-tone board argue for control rather than immediate escalation.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_for_protection',
      label: 'Raise now for protection',
      isCorrect: false,
      preferredLabel: 'Call in position and keep the range wide',
      betterAnswerLabel: 'Call in position and keep the range wide',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Tempting pressure line.',
      feedbackReason:
          'Protection is the tempting idea, but the full table read is more mixed: position helps, stack depth still leaves risk, and the board is not dry enough to force a bigger pot now.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_to_pressure',
      label: 'Fold to the c-bet',
      isCorrect: false,
      preferredLabel: 'Call in position and keep the range wide',
      betterAnswerLabel: 'Call in position and keep the range wide',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too cautious.',
      feedbackReason:
          'The price is not tiny, but folding ignores hand quality and position. The clean action comes from all the cues together, not just one large-looking bet.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Real play combines cues.',
      body:
          'Real play means combining seat, hand, board, price, and stack depth before acting. One cue alone is usually too thin.',
      focusLabels: <String>['Position', 'Top pair', 'Two-tone board', '30 BB'],
    ),
  ],
);

final _world11RealPlayCheckpointRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w11_real_play_checkpoint',
  caption:
      'Lesson learned: plan, trigger, and review form one daily transfer loop.',
  hint:
      'This closes the core route and feeds your daily play-review habit loop. Next you build the mindset bridge.',
  question: 'What does real-play transfer produce when done well?',
  feedbackTitle: 'Real-play checkpoint.',
  feedbackReason:
      'You can now carry course logic into real sessions through a repeatable transfer loop: one plan, one trigger lever, one review repair output. The mindset bridge is the next layer.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Loop beats intensity.',
      body:
          'Sustainable progress comes from repeating a clean transfer loop daily, not from occasional complex sessions.',
      focusLabels: <String>[
        'Session plan',
        'Trigger action',
        'Review repair',
        'Daily habit loop',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'repeatable_loop',
      label: 'A repeatable daily transfer loop',
      isCorrect: true,
      preferredLabel: 'A repeatable daily transfer loop',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the intended endpoint: practical, repeatable transfer from learning into daily table decisions.',
    ),
    Act0RunnerOptionV1(
      id: 'one_time_mastery',
      label: 'One big session to master everything',
      isCorrect: false,
      preferredLabel: 'A repeatable daily transfer loop',
      betterAnswerLabel: 'A repeatable daily transfer loop',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too brittle.',
      feedbackReason:
          'Transfer is compounding and iterative. One massive session is less reliable than steady loops.',
    ),
    Act0RunnerOptionV1(
      id: 'content_only',
      label: 'More content without loop execution',
      isCorrect: false,
      preferredLabel: 'A repeatable daily transfer loop',
      betterAnswerLabel: 'A repeatable daily transfer loop',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partial progress.',
      feedbackReason:
          'Content helps, but transfer happens only when lessons are converted into repeated session behavior and review.',
    ),
  ],
);

final _w12DecisionQualityIntroRunner = _w11ReviewLoopIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_decision_quality_intro',
  lessonTitle: 'Decision quality over outcome',
  lessonSubtitle: 'Mindset Bridge',
  caption: 'Short-term outcomes can lie. Process quality must stay the anchor.',
  hint: 'Judge choices by logic, not one card on river.',
  question: 'What should be judged first after a hand?',
  feedbackTitle: 'Mindset foundation.',
  feedbackReason:
      'A strong mindset evaluates whether the decision process was sound before reacting to outcome variance.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Process beats variance.',
      body:
          'Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.',
      focusLabels: <String>['Process', 'Variance', 'Outcome bias'],
    ),
  ],
);

final _w12GoodFoldBadResultRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_good_fold_bad_result',
  caption:
      'You folded a marginal bluff-catcher and villain later showed a bluff.',
  hint: 'Do not auto-label by reveal result only.',
  question: 'What is the sharper review reaction?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'process_review',
      label: 'Review the decision process before judging result',
      isCorrect: true,
      preferredLabel: 'Review the decision process before judging result',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process beats reveal.',
      feedbackReason:
          'One reveal does not invalidate disciplined logic. Process review protects you from outcome bias.',
    ),
    Act0RunnerOptionV1(
      id: 'instant_regret',
      label: 'Assume fold was always wrong',
      isCorrect: false,
      preferredLabel: 'Review the decision process before judging result',
      betterAnswerLabel: 'Review the decision process before judging result',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Outcome trap.',
      feedbackReason:
          'Single-hand reveal can mislead. Decision quality should be judged by range logic and context.',
    ),
    Act0RunnerOptionV1(
      id: 'ignore_hand',
      label: 'Ignore the hand completely',
      isCorrect: false,
      preferredLabel: 'Review the decision process before judging result',
      betterAnswerLabel: 'Review the decision process before judging result',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Avoids tilt.',
      feedbackReason:
          'Ignoring helps emotions, but quick process review is better for learning transfer.',
    ),
  ],
);

final _w12BadCallGoodResultRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_bad_call_good_result',
  caption: 'You made a loose call and got lucky on river.',
  hint: 'Winning the pot does not guarantee a good decision.',
  question: 'What is the best mindset response?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'flag_leak',
      label: 'Flag the loose call as a possible leak',
      isCorrect: true,
      preferredLabel: 'Flag the loose call as a possible leak',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Win can hide a leak.',
      feedbackReason:
          'Good results can mask weak process. Flagging the decision keeps your learning honest.',
    ),
    Act0RunnerOptionV1(
      id: 'celebrate_only',
      label: 'Result was good so process is good',
      isCorrect: false,
      preferredLabel: 'Flag the loose call as a possible leak',
      betterAnswerLabel: 'Flag the loose call as a possible leak',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Result bias.',
      feedbackReason:
          'Outcome can be lucky. Process discipline means auditing suspicious calls even after wins.',
    ),
    Act0RunnerOptionV1(
      id: 'self_blame',
      label: 'Call was lucky so confidence is gone',
      isCorrect: false,
      preferredLabel: 'Flag the loose call as a possible leak',
      betterAnswerLabel: 'Flag the loose call as a possible leak',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too harsh.',
      feedbackReason:
          'Leak review should be calm and specific, not confidence collapse. Keep a constructive audit tone.',
    ),
  ],
);

final _w12DecisionQualityRecapRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w12_decision_quality_recap',
  caption: 'Lesson learned: process quality is the anchor under variance.',
  hint: 'Outcome is data, not verdict.',
  question: 'What is the process-quality takeaway?',
  feedbackTitle: 'Process takeaway.',
  feedbackReason:
      'Stable improvement comes from process audits that survive both wins and losses.',
);

final _w12TiltResetIntroRunner = _w12DecisionQualityIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_tilt_reset_intro',
  lessonTitle: 'Tilt reset protocol',
  caption:
      'One short reset can protect decision quality after emotional spikes.',
  hint: 'Pause, breathe, re-anchor to plan.',
  question: 'What is the purpose of a tilt reset?',
  feedbackTitle: 'Reset foundation.',
  feedbackReason:
      'Tilt reset prevents one hand from contaminating the next decisions and keeps session discipline alive.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Fast reset loop.',
      body:
          'Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.',
      focusLabels: <String>['Emotion label', 'Breath', 'Re-anchor'],
    ),
  ],
);

final _w12AfterBadBeatResetRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_after_bad_beat_reset',
  caption: 'You lose a big all-in as favorite and feel immediate anger.',
  hint: 'Reset before next hand starts.',
  question: 'What is the cleaner immediate action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'reset_protocol',
      label: 'Run short reset protocol before next major spot',
      isCorrect: true,
      preferredLabel: 'Run short reset protocol before next major spot',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Reset before next hand.',
      feedbackReason:
          'A fast reset protects your next decisions from emotional carryover.',
    ),
    Act0RunnerOptionV1(
      id: 'revenge_hand',
      label: 'Force action to win chips back now',
      isCorrect: false,
      preferredLabel: 'Run short reset protocol before next major spot',
      betterAnswerLabel: 'Run short reset protocol before next major spot',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tilt pattern.',
      feedbackReason:
          'Revenge actions usually worsen variance damage. Reset first, then return to plan.',
    ),
    Act0RunnerOptionV1(
      id: 'quit_immediately',
      label: 'Auto-quit session every time',
      isCorrect: false,
      preferredLabel: 'Run short reset protocol before next major spot',
      betterAnswerLabel: 'Run short reset protocol before next major spot',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Sometimes valid.',
      feedbackReason:
          'Ending session can help if control is gone, but the first step is a brief reset and re-check.',
    ),
  ],
);

final _w12AfterMistakeResetRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_after_mistake_reset',
  caption: 'You realize you made an avoidable call error.',
  hint: 'Use reset to prevent second error spiral.',
  question: 'What response keeps discipline highest?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'note_and_reset',
      label: 'Log leak briefly and reset to current hand',
      isCorrect: true,
      preferredLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Log it, then reset.',
      feedbackReason:
          'Quick logging plus reset preserves learning without carrying emotional noise into next hands.',
    ),
    Act0RunnerOptionV1(
      id: 'self_attack',
      label: 'Mentally attack yourself for several orbits',
      isCorrect: false,
      preferredLabel: 'Log leak briefly and reset to current hand',
      betterAnswerLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Harmful loop.',
      feedbackReason:
          'Self-attack increases future mistake risk. Keep review structured and calm.',
    ),
    Act0RunnerOptionV1(
      id: 'deny_mistake',
      label: 'Pretend mistake did not happen',
      isCorrect: false,
      preferredLabel: 'Log leak briefly and reset to current hand',
      betterAnswerLabel: 'Log leak briefly and reset to current hand',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Protects emotion short term.',
      feedbackReason:
          'Ignoring may reduce pain now, but short structured logging improves long-term transfer.',
    ),
  ],
);

final _w12TiltResetRecapRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w12_tilt_reset_recap',
  caption: 'Lesson learned: reset protects process under emotional pressure.',
  hint: 'Fast reset now prevents leak cascade later.',
  question: 'What is the reset takeaway?',
  feedbackTitle: 'Reset takeaway.',
  feedbackReason:
      'Consistent small resets are a core bridge from knowledge to stable execution.',
);

final _w12ConfidenceDisciplineIntroRunner = _w12TiltResetIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w12_confidence_intro',
  lessonTitle: 'Confidence with discipline',
  caption: 'Confident play means clear actions, not ego battles.',
  hint: 'Assertive decisions still obey plan and evidence.',
  question: 'What balance should confidence hold?',
  feedbackTitle: 'Confidence foundation.',
  feedbackReason:
      'Best mindset combines calm assertiveness with disciplined filters on risk and evidence.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Assertive, not reckless.',
      body:
          'Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.',
      focusLabels: <String>['Assertive', 'Evidence', 'Discipline'],
    ),
  ],
);

final _w12AssertiveNotEgoRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_assertive_not_ego',
  caption: 'Villain needles you after winning a pot.',
  hint: 'Decision quality should not react to table talk.',
  question: 'What is the stronger mindset line?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'stick_process',
      label: 'Stick to process and planned exploit line',
      isCorrect: true,
      preferredLabel: 'Stick to process and planned exploit line',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process ignores table talk.',
      feedbackReason:
          'Process-led confidence ignores ego hooks and preserves decision quality.',
    ),
    Act0RunnerOptionV1(
      id: 'prove_point',
      label: 'Take marginal spot to prove a point',
      isCorrect: false,
      preferredLabel: 'Stick to process and planned exploit line',
      betterAnswerLabel: 'Stick to process and planned exploit line',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Ego trap.',
      feedbackReason:
          'Point-proving lines usually detach from EV and increase variance mistakes.',
    ),
    Act0RunnerOptionV1(
      id: 'play_scared',
      label: 'Play overly scared to avoid conflict',
      isCorrect: false,
      preferredLabel: 'Stick to process and planned exploit line',
      betterAnswerLabel: 'Stick to process and planned exploit line',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safer but capped.',
      feedbackReason:
          'Fear-based tightening can avoid blowups but also leaks EV. Keep calm assertive discipline instead.',
    ),
  ],
);

final _w12DisciplineUnderPressureRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_discipline_under_pressure',
  caption: 'Deep in session, fatigue rises and decisions speed up.',
  hint: 'Discipline means slowing only the critical spots.',
  question: 'What is the best pressure adjustment?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'critical_pause',
      label: 'Pause briefly on high-EV decision nodes',
      isCorrect: true,
      preferredLabel: 'Pause briefly on high-EV decision nodes',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Pause on big nodes.',
      feedbackReason:
          'Small targeted pauses preserve discipline where it matters most without killing flow.',
    ),
    Act0RunnerOptionV1(
      id: 'autopilot',
      label: 'Stay on autopilot to keep pace',
      isCorrect: false,
      preferredLabel: 'Pause briefly on high-EV decision nodes',
      betterAnswerLabel: 'Pause briefly on high-EV decision nodes',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Leak risk.',
      feedbackReason:
          'Autopilot under fatigue often degrades decision quality in the largest pots.',
    ),
    Act0RunnerOptionV1(
      id: 'tank_every_spot',
      label: 'Tank every hand for max control',
      isCorrect: false,
      preferredLabel: 'Pause briefly on high-EV decision nodes',
      betterAnswerLabel: 'Pause briefly on high-EV decision nodes',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Overcorrection.',
      feedbackReason:
          'Overthinking every hand burns energy. Discipline should be targeted to meaningful nodes.',
    ),
  ],
);

final _w12PrettyHandBadPriceFoldRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_pretty_hand_bad_price_fold',
  caption:
      'Real table. A tight player barrels into river and now bets 18 BB into 20 BB on K-7-2-9-4. Hero holds K-Q at 100 BB effective.',
  hint: 'Do not hero call only because the hand looks pretty.',
  question: 'What is the cleaner disciplined action?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroKqCards,
    boardCards: _boardK7294Cards,
    streetLabel: 'River',
    potLabel: 'Pot 20 BB',
    toCallLabel: 'To call 18 BB',
    centerLabel: 'Top pair, bad river price',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls'),
      Act0ActionTrailItemV1(label: 'CO barrels flop'),
      Act0ActionTrailItemV1(label: 'CO barrels turn'),
      Act0ActionTrailItemV1(label: 'CO bets 18 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'fold_river',
      label: 'Fold the river',
      isCorrect: true,
      preferredLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Calm fold.',
      feedbackReason:
          'Top pair looks good, which is why the call feels tempting. But the bad river price, tight action history, and deep remaining risk all point to a disciplined fold.',
    ),
    Act0RunnerOptionV1(
      id: 'hero_call',
      label: 'Hero-call top pair',
      isCorrect: false,
      preferredLabel: 'Fold the river',
      betterAnswerLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Pretty-hand trap.',
      feedbackReason:
          'The hand label makes this tempting, but real play rewards the full read: action trail, price, and opponent profile matter more than wanting to be right.',
    ),
    Act0RunnerOptionV1(
      id: 'jam_back',
      label: 'Jam for control',
      isCorrect: false,
      preferredLabel: 'Fold the river',
      betterAnswerLabel: 'Fold the river',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too dramatic.',
      feedbackReason:
          'This is the opposite of stable discipline. The table read says stop rather than escalate a thin bluff-catcher into a much larger mistake.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pretty hands still obey price.',
      body:
          'Use the same loop even when the hand looks attractive: seat, hand, board, price, stack and action, then the clean action.',
      focusLabels: <String>[
        'Top pair',
        'Bad price',
        'Tight action',
        'Fold clean',
      ],
    ),
  ],
);

final _w12RevengeRaiseTrapRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_revenge_raise_trap',
  caption:
      'The same villain bluffed you last orbit and needles you now. New hand: Hero holds Q-J suited on J-7-4 rainbow. CO bets 2 BB into 8 BB at 35 BB effective.',
  hint:
      'Do not raise just to take control when the table read says stay simple.',
  question: 'What is the clean discipline line?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroQJsCards,
    boardCards: _boardJ74FlopCards,
    streetLabel: 'Flop',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'Top pair, ego trap',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Villain needled you last orbit'),
      Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call_once',
      label: 'Call once and keep the pot controlled',
      isCorrect: true,
      preferredLabel: 'Call once and keep the pot controlled',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Stable line.',
      feedbackReason:
          'Price is kind, board is dry, and top pair in position can continue calmly. The table talk is noise, not a reason to force a bigger pot.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_to_take_control',
      label: 'Raise now to take control back',
      isCorrect: false,
      preferredLabel: 'Call once and keep the pot controlled',
      betterAnswerLabel: 'Call once and keep the pot controlled',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Revenge leak.',
      feedbackReason:
          'Taking control sounds assertive, but here it is emotional, not evidence-based. The clean action comes from hand, board, price, and position, not from wanting the last word.',
    ),
    Act0RunnerOptionV1(
      id: 'snap_fold_noise',
      label: 'Fold now to avoid the annoying player',
      isCorrect: false,
      preferredLabel: 'Call once and keep the pot controlled',
      betterAnswerLabel: 'Call once and keep the pot controlled',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Emotion still steering.',
      feedbackReason:
          'Folding out of irritation is still letting emotion drive. A calm continue is cleaner than either revenge or avoidance here.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Noise is not a cue.',
      body:
          'Real play rewards stable decisions more than dramatic decisions. Ignore ego hooks and return to the table read.',
      focusLabels: <String>['Position', 'Small price', 'Top pair', 'No ego'],
    ),
  ],
);

final _w12ConfidenceDisciplineRecapRunner = _w12ConfidenceDisciplineIntroRunner
    .copyWith(
      phase: Act0LessonPhaseV1.review,
      lessonId: 'w12_confidence_recap',
      caption:
          'Lesson learned: calm confidence plus discipline is stable edge.',
      hint: 'Assertive line, evidence filter, no ego side quests.',
      question: 'What is the confidence-discipline takeaway?',
      feedbackTitle: 'Discipline takeaway.',
      feedbackReason:
          'Mindset edge comes from repeatable emotional control and disciplined execution, not mood swings.',
    );

final _w12CheckpointProcessLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_process_line',
  caption: 'A correct line loses in a high-variance pot.',
  hint: 'Process verdict comes before emotional verdict.',
  question: 'What is the best immediate checkpoint reaction?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'process_first',
      label: 'Audit process first, then outcome',
      isCorrect: true,
      preferredLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Process held steady.',
      feedbackReason:
          'That sequence keeps you grounded through variance and supports long-term growth.',
    ),
    Act0RunnerOptionV1(
      id: 'outcome_only',
      label: 'Outcome proves decision quality',
      isCorrect: false,
      preferredLabel: 'Audit process first, then outcome',
      betterAnswerLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Bias warning.',
      feedbackReason:
          'Outcome-first judgement is tempting because the result feels vivid and final. But the dominant cue is decision quality. One result cannot grade the process by itself.',
    ),
    Act0RunnerOptionV1(
      id: 'avoid_review',
      label: 'Skip review to avoid frustration',
      isCorrect: false,
      preferredLabel: 'Audit process first, then outcome',
      betterAnswerLabel: 'Audit process first, then outcome',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Protective instinct.',
      feedbackReason:
          'Avoiding review feels protective because it lowers frustration in the moment. But the cleaner bridge is short process review first, so emotion does not hide the actual lesson.',
    ),
  ],
);

final _w12CheckpointResetLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_reset_line',
  caption: 'You feel tilt signs after two rough spots in a row.',
  hint: 'Reset should be fast and repeatable.',
  question: 'What is the cleaner bridge action?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'run_reset',
      label: 'Run brief reset and re-anchor to plan',
      isCorrect: true,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Reset keeps quality steady.',
      feedbackReason:
          'Reset and re-anchor protects next decisions without derailing session rhythm.',
    ),
    Act0RunnerOptionV1(
      id: 'revenge_mode',
      label: 'Force action to recover immediately',
      isCorrect: false,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      betterAnswerLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Tilt escalation.',
      feedbackReason:
          'Revenge mode usually worsens errors. Controlled reset is the bridge habit.',
    ),
    Act0RunnerOptionV1(
      id: 'deny_tilt',
      label: 'Ignore emotion and continue unchanged',
      isCorrect: false,
      preferredLabel: 'Run brief reset and re-anchor to plan',
      betterAnswerLabel: 'Run brief reset and re-anchor to plan',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Common response.',
      feedbackReason:
          'Ignoring signals can work briefly, but explicit reset better preserves quality under pressure.',
    ),
  ],
);

final _w12CheckpointDisciplineLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_discipline_line',
  caption: 'A player taunts you into marginal high-variance spots.',
  hint: 'Discipline means evidence over ego.',
  question: 'Which line is strongest?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'evidence_line',
      label: 'Take only evidence-backed lines',
      isCorrect: true,
      preferredLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Evidence beats respect.',
      feedbackReason:
          'Evidence-first discipline is the stable bridge into deeper strategic worlds.',
    ),
    Act0RunnerOptionV1(
      id: 'ego_line',
      label: 'Take thin line to win respect',
      isCorrect: false,
      preferredLabel: 'Take only evidence-backed lines',
      betterAnswerLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Ego leak.',
      feedbackReason:
          'Respect-seeking lines detach from quality logic and create avoidable variance.',
    ),
    Act0RunnerOptionV1(
      id: 'fear_line',
      label: 'Fold every close spot now',
      isCorrect: false,
      preferredLabel: 'Take only evidence-backed lines',
      betterAnswerLabel: 'Take only evidence-backed lines',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Defensive but capped.',
      feedbackReason:
          'Overfolding avoids ego spots but also misses edges. Evidence-based selectivity is stronger.',
    ),
  ],
);

final _w12CheckpointFullLoopLineRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.drill,
  lessonId: 'w12_checkpoint_full_loop_line',
  caption:
      'You made a loose bluff last orbit. New hand: CO opens, Hero calls BTN with A-J suited at 25 BB effective. Flop is A-8-4 two-tone. CO bets 2 BB into 8 BB.',
  hint:
      'Use the same decision loop even after a mistake: seat, hand, board, price, stack and action, then the clean action.',
  question: 'What keeps the next decision stable?',
  table: _world3PlayableCallRunner.table.copyWith(
    heroCards: _heroAJsCards,
    boardCards: _boardA84TwoToneCards,
    streetLabel: 'Flop',
    potLabel: 'Pot 8 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: 'After mistake, stay clean',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'Last orbit: loose bluff'),
      Act0ActionTrailItemV1(label: 'CO opens 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls'),
      Act0ActionTrailItemV1(label: 'CO bets 2 BB'),
    ],
  ),
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'call_clean',
      label: 'Call with the same loop',
      isCorrect: true,
      preferredLabel: 'Call with the same loop',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Strong reset.',
      feedbackReason:
          'Position, top pair, kind price, and shorter stack depth support a calm continue. The prior mistake matters only if it changes your process, not if it changes this table read.',
    ),
    Act0RunnerOptionV1(
      id: 'raise_to_recover',
      label: 'Raise to recover confidence',
      isCorrect: false,
      preferredLabel: 'Call with the same loop',
      betterAnswerLabel: 'Call with the same loop',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Confidence chase.',
      feedbackReason:
          'This is exactly the wrong bridge habit. Confidence should come from following the loop, not from forcing a louder action after a mistake.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_scared',
      label: 'Fold to play safer now',
      isCorrect: false,
      preferredLabel: 'Call with the same loop',
      betterAnswerLabel: 'Call with the same loop',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Too reactive.',
      feedbackReason:
          'Fear after a mistake is still emotion steering the next hand. The cleaner bridge is keep the same seat-hand-board-price-stack loop and follow what this spot says.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Stable loop beats emotional correction.',
      body:
          'A prior mistake should not rewrite the next decision. Real play gets stronger when the same clean loop survives noise, temptation, and regret.',
      focusLabels: <String>[
        'After mistake',
        'Seat-hand-board-price',
        '25 BB',
        'Stay stable',
      ],
    ),
  ],
);

final _world12MindsetCheckpointRunner = _w12ConfidenceDisciplineIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w12_mindset_checkpoint',
  caption:
      'Lesson learned: process, reset, and discipline stabilize your game.',
  hint:
      'Next you carry this mindset into deeper postflop decision trees and pressure spots.',
  question: 'What does mindset bridge add before deeper strategy worlds?',
  feedbackTitle: 'Mindset checkpoint.',
  feedbackReason:
      'You now have emotional, process, and discipline guardrails that keep strategic learning stable under variance and pressure.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Stability before complexity.',
      body:
          'Strong strategy growth requires stable mindset loops. Process audits, resets, and discipline make advanced learning stick.',
      focusLabels: <String>[
        'Process quality',
        'Tilt reset',
        'Discipline',
        'Postflop growth',
      ],
    ),
  ],
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'stable_bridge',
      label: 'A stable bridge into deeper strategy',
      isCorrect: true,
      preferredLabel: 'A stable bridge into deeper strategy',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Solid understanding.',
      feedbackReason:
          'Mindset stability is what lets complex strategic lessons transfer instead of collapsing under pressure.',
    ),
    Act0RunnerOptionV1(
      id: 'optional_soft',
      label: 'Optional soft skill with little EV impact',
      isCorrect: false,
      preferredLabel: 'A stable bridge into deeper strategy',
      betterAnswerLabel: 'A stable bridge into deeper strategy',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Underestimation.',
      feedbackReason:
          'Mindset errors are EV errors. Stability directly affects execution of every strategic concept.',
    ),
    Act0RunnerOptionV1(
      id: 'done_forever',
      label: 'One-time fix, no daily upkeep needed',
      isCorrect: false,
      preferredLabel: 'A stable bridge into deeper strategy',
      betterAnswerLabel: 'A stable bridge into deeper strategy',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Partly true start.',
      feedbackReason:
          'Initial tools help, but mindset edge stays strong only through repeated daily use.',
    ),
  ],
);

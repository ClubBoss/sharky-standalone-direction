import 'package:flutter/material.dart';

enum Act0ShellTabV1 { home, learn, play, review, profile }

enum Act0LessonStateV1 { completed, current, locked }

enum Act0WorldStateV1 { completed, current, locked }

enum Act0LessonPhaseV1 { theory, drill, review }

enum Act0LessonStepKindV1 { learn, practice, fixMistakes, review, proveIt }

enum Act0FeedbackQualityV1 { correct, wrong, suboptimal }

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

  Act0LessonCardV1 lessonById(String lessonId) =>
      lessons.firstWhere((lesson) => lesson.lessonId == lessonId);

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
    pathProgressLabel: '3 of 8 lessons complete',
    selectedWorldId: 'world_1',
    worlds: _act0PreviewWorlds,
    lessons: _pokerFromZeroLessons,
    review: Act0ReviewStateV1(
      title: 'Repair board',
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
    this.isPrimary = false,
  });

  final String id;
  final String label;
  final double potFraction;
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
  });

  final String taskId;
  final String lessonId;
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
}

class Act0ProfileStateV1 {
  const Act0ProfileStateV1({
    required this.playerName,
    required this.level,
    required this.xpLine,
    required this.lessonsLine,
    required this.accuracyLine,
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
    title: 'What poker is',
    subtitle: 'Meet the table, the players, and the goal.',
    state: Act0LessonStateV1.completed,
    phaseLabel: 'Table',
    primaryCtaLabel: 'Replay',
    isSelectable: true,
    isLocked: false,
    rewardXp: 15,
    runner: _meetTableRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: 'what_poker_is_theory',
        title: 'Meet the table',
        phase: Act0LessonPhaseV1.theory,
        runner: _meetTableRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.learn,
        summary:
            'Get the basic layout: seats, chips, cards, and what the table is trying to decide.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_find_hero',
        title: 'Find your seat',
        phase: Act0LessonPhaseV1.drill,
        runner: _findHeroSeatRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Spot where Hero sits before anything else starts moving.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_pot_stack',
        title: 'Pot and stack',
        phase: Act0LessonPhaseV1.drill,
        runner: _potStackRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary:
            'Separate chips in the middle from chips still in a player stack.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_win_ways',
        title: 'How pots are won',
        phase: Act0LessonPhaseV1.drill,
        runner: _winWaysRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'See the two basic ways a hand ends: folds or showdown.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_showdown_win',
        title: 'Win at showdown',
        phase: Act0LessonPhaseV1.drill,
        runner: _showdownBestHandRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        summary: 'Pick which hand wins once the cards are all face up.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_table_read_transfer',
        title: 'Real-table first read',
        phase: Act0LessonPhaseV1.drill,
        runner: _w1TableReadTransferRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.practice,
        taskFamily: Act0TaskFamilyV1.transfer,
        summary:
            'Carry the first table scan into a live-looking spot: private cards, board, then pot.',
      ),
      Act0LessonTaskV1(
        taskId: 'what_poker_is_review',
        title: 'Table recap',
        phase: Act0LessonPhaseV1.review,
        runner: _tableRecapRunner,
        rewardXp: 5,
        stepKind: Act0LessonStepKindV1.proveIt,
        summary:
            'Run the full table read once clean, from seat to pot to finish.',
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
        title: 'Action trail',
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
        title: 'Open on the Button',
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
        title: 'Who posts 1 BB',
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
        runner: _world3ButtonOpenRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'w3_same_hand_call',
        title: 'Call frame',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
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
        runner: _world3PlayableCallRunner,
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
        runner: _world3WeakFacingFoldRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'weak_ace_kicker_compare',
        title: 'A7 vs KQ spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
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
        runner: _world3PlayableCallRunner,
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
        runner: _earlyLatePositionRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
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
        runner: _latePositionRunner,
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
        runner: _earlyLatePositionRunner,
        rewardXp: 9,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'late_info_choice',
        title: 'Late info edge',
        phase: Act0LessonPhaseV1.drill,
        runner: _latePositionRunner,
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
        runner: _world3ButtonOpenRunner,
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
        runner: _world3PositionDisciplineRunner,
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
        runner: _world3PositionDisciplineRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'position_checkpoint_btn_call',
        title: 'BTN: callable spot',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
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
        runner: _world3ButtonOpenRunner,
        rewardXp: 8,
        stepKind: Act0LessonStepKindV1.practice,
      ),
      Act0LessonTaskV1(
        taskId: 'frame_call',
        title: 'Call',
        phase: Act0LessonPhaseV1.drill,
        runner: _world3PlayableCallRunner,
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
        taskId: 'range_checkpoint_pressure',
        title: 'Bluff candidate',
        phase: Act0LessonPhaseV1.drill,
        runner: _w6BluffCandidateRunner,
        rewardXp: 10,
        stepKind: Act0LessonStepKindV1.practice,
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
    progressLabel: '3 of 8 lessons complete',
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
      body: 'You are the hero. The other seats are opponents.',
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
  hint: 'Folded to you. Opening can win blinds or build a pot.',
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
      feedbackTitle: 'Limp is legal, but raise is sharper.',
      feedbackReason:
          'Calling is legal and not a disaster, but limping on the Button is passive. Raising wins blinds outright and builds better pots.',
      repairFocusSeatIds: <String>['btn', 'sb', 'bb'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Limp is legal', 'Raise sharper', 'Button'],
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
          'First in on the Button, raising opens the pot and pressures the blinds.',
      repairFocusSeatIds: <String>['btn'],
      repairFocusCardIds: <String>['hero_0', 'hero_1'],
      repairFocusLabels: <String>['Button open', 'Hero acts'],
    ),
  ],
  feedbackTitle: 'Solid understanding.',
  feedbackReason:
      'Raising is the clean first-in Button action; calling would only limp.',
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
      body: 'Calling would limp. First in usually means raise or fold.',
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
    ),
    Act0RunnerOptionV1(
      id: 'two',
      label: 'Two',
      isCorrect: true,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Two cards: correct.',
      feedbackReason: 'You start with two private cards.',
    ),
    Act0RunnerOptionV1(
      id: 'five',
      label: 'Five',
      isCorrect: false,
      preferredLabel: 'Two',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Five cards can make a hand, but you start with two.',
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
      body: 'In this beginner drill, ace is higher than king.',
      focusLabels: <String>['A beats K'],
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
      body: 'Holdem uses a 52-card deck: 13 ranks across 4 suits.',
      focusLabels: <String>['52 cards', '13 ranks', '4 suits'],
    ),
  ],
);

final _potStackRunner = _meetTableRunner.copyWith(
  lessonId: 'pot_stack',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'Pot and stack are separate numbers.',
  caption: 'Stack is your chips. Pot is what players fight for.',
  hint: 'Do not mix your stack with the pot.',
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
      feedbackReason: 'Your stack is your chips, not the middle pot.',
    ),
  ],
  table: _meetTableRunner.table.copyWith(
    centerLabel: 'Pot vs stack',
    potLabel: 'Pot 1.5 BB',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Pot and stack are different.',
      body: 'The pot is in the middle. Your stack stays with your seat.',
      focusSeatIds: <String>['btn'],
      focusLabels: <String>['Pot', 'Stack'],
    ),
  ],
);

final _winWaysRunner = _meetTableRunner.copyWith(
  lessonId: 'win_ways',
  lessonTitle: 'What poker is',
  lessonSubtitle: 'A pot can end before showdown or at showdown.',
  caption: 'You win when others fold or when your hand wins showdown.',
  hint: 'Early lessons only need these two endings.',
  question: 'Which is a way to win a pot?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'everyone_folds',
      label: 'Everyone folds',
      isCorrect: true,
      preferredLabel: 'Everyone folds',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'UTG acts first.',
      feedbackReason: 'If everyone folds, the last player wins the pot.',
    ),
    Act0RunnerOptionV1(
      id: 'largest_stack',
      label: 'Largest stack',
      isCorrect: false,
      preferredLabel: 'Everyone folds',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'One more step.',
      feedbackReason: 'A larger stack does not automatically win the pot.',
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
  caption: 'Each card has a rank and a suit.',
  hint: 'We write suits as s, h, d, c here.',
  question: 'In Ah, what is the suit?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'heart',
      label: 'h',
      isCorrect: true,
      preferredLabel: 'h',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'Card code check: A means ace and h means hearts.',
    ),
    Act0RunnerOptionV1(
      id: 'rank',
      label: 'A',
      isCorrect: false,
      preferredLabel: 'h',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Getting warmer.',
      feedbackReason: 'A is the rank. h is the suit.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Suits are card families.',
      body: 'Use s, h, d, and c for spades, hearts, diamonds, and clubs.',
      focusLabels: <String>['s h d c'],
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
      feedbackTitle: 'Strong choice.',
      feedbackReason: 'Board cards are shared by everyone still in the hand.',
    ),
    Act0RunnerOptionV1(
      id: 'private',
      label: 'Private cards',
      isCorrect: false,
      preferredLabel: 'Board cards',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'Private cards belong only to one player.',
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
      feedbackTitle: 'Solid understanding.',
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
      feedbackTitle: 'Well done.',
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
      feedbackTitle: 'Excellent spot.',
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
      feedbackTitle: 'Spot on.',
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
      feedbackTitle: 'Clean execution.',
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
      title: 'BB closes the first round.',
      body: 'If nobody raises, the big blind can act last preflop.',
      focusSeatIds: <String>['bb'],
      focusLabels: <String>['Last preflop'],
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
      feedbackTitle: 'Strong choice.',
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
      body: 'UTG, HJ, CO, BTN, SB, and BB describe table position.',
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
      feedbackTitle: 'Solid understanding.',
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
      feedbackTitle: 'Well done.',
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
      feedbackTitle: 'Excellent spot.',
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
      feedbackTitle: 'Spot on.',
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
  hint: 'Start with the ladder: pair, two pair, trips, straight, flush.',
  question: 'What do hand rankings compare?',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Ranking ladder.',
      body: 'Hand names tell which made hand is stronger.',
      focusLabels: <String>['Pair', 'Two pair', 'Straight', 'Flush'],
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
      feedbackTitle: 'Clean execution.',
      feedbackReason: 'A flush ranks above a straight.',
    ),
    Act0RunnerOptionV1(
      id: 'straight',
      label: 'Straight',
      isCorrect: false,
      preferredLabel: 'Flush',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'A straight is strong, but a flush ranks higher.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Flush means same suit.',
      body:
          'Five cards of one suit make a flush. Flushes rank above straights because they are rarer: roughly 5,100 flush combinations exist in a deck versus about 10,200 straights. Rarer combinations rank higher.',
      focusLabels: <String>['Same suit', 'Rarer = higher', '~5,100 combos'],
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
      feedbackTitle: 'Button acts last postflop.',
      feedbackReason: 'Two pair ranks above one pair.',
    ),
    Act0RunnerOptionV1(
      id: 'one_pair',
      label: 'One pair',
      isCorrect: false,
      preferredLabel: 'Two pair',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason: 'Two pair beats one pair, so this hand is second best.',
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
    centerLabel: 'A with A and 7 with 7',
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Two pair uses two ranks.',
      body:
          'Hero uses A with A and 7 with 7. That makes two pair, with the J as the fifth card.',
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
      feedbackReason: 'The best hand wins at showdown.',
    ),
    Act0RunnerOptionV1(
      id: 'first_actor',
      label: 'First actor',
      isCorrect: false,
      preferredLabel: 'Best hand',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'Acting first does not win a showdown.',
    ),
  ],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Showdown compares hands.',
      body: 'When players remain, reveal cards and compare best hands.',
      focusLabels: <String>['Best hand wins'],
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
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Kickers break some ties.',
      body: 'If the main hand matches, the best side card can decide.',
      focusLabels: <String>['Side card'],
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
  caption:
      'Real table. Hero has two cards, flop has three board cards, pot is 6 BB.',
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
          'Real tables still start with the same simple scan: your two cards, the shared board, and how many chips sit in the pot.',
      focusLabels: <String>['2 private', '3 board', 'Pot'],
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
      feedbackTitle: 'Clean execution.',
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
  caption: 'The action trail records what happened street by street.',
  hint: 'Read it left to right.',
  question: 'Which trail item happened last?',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'bb_check',
      label: 'Flop: BB checks',
      isCorrect: true,
      preferredLabel: 'Flop: BB checks',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'CO is the cutoff seat.',
      feedbackReason: 'The last trail item is the latest action.',
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
      title: 'Action trail is history.',
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
      'A hand moves forward street by street. The action trail records what already happened.',
  options: const <Act0RunnerOptionV1>[
    Act0RunnerOptionV1(
      id: 'river',
      label: 'River',
      isCorrect: true,
      preferredLabel: 'River',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason: 'The river comes after the turn.',
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
  caption: 'BB posts the full 1 BB blind.',
  hint: 'SB posts the smaller 0.5 BB blind.',
  question: 'Tap the big blind.',
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Big blind is the full blind.',
      body: 'Find the seat marked BB with the 1 BB post.',
      focusSeatIds: <String>['bb'],
      focusLabels: <String>['BB 1 BB'],
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
      feedbackTitle: 'Strong choice.',
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
  ),
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Extra cards are ignored.',
      body:
          'Here the best five are A, A, 7, 7, and J. The 4 is visible, but it does not play.',
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
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Sometimes the board plays.',
      body: 'If the same five board cards are best, private cards do not help.',
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
      body: 'When tied players have the same best hand, they split the pot.',
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
          'Read the action trail, find the last bet or raise, then find who acts now.',
      focusLabels: <String>['Trail', 'Aggressor', 'Active seat'],
    ),
  ],
);

final _world2CheckpointIntroRunner = _world2ShowdownIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.theory,
  lessonId: 'w2_checkpoint_intro',
  lessonTitle: 'Hand value checkpoint',
  lessonSubtitle: 'Hand Value And Position',
  caption: 'Checkpoint: compare hand, position, and initiative together.',
  hint: 'Keep it simple: hand first, seat second, action trail third.',
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
      'Use premium, strong, medium, and trash before choosing. No charts needed at this stage.',
  question: 'What should you name before the action?',
  options: const <Act0RunnerOptionV1>[],
  teachingSteps: const <Act0TeachingStepV1>[
    Act0TeachingStepV1(
      title: 'Bucket first.',
      body:
          'Name the hand bucket before choosing open, call, or fold. Keep it simple and repeatable.',
      focusLabels: <String>['Premium', 'Strong', 'Medium', 'Trash'],
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
  table: _whatYouCanDoRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd'),
    ],
    centerLabel: 'Trash bucket',
    activeSeatId: 'utg',
    highlightedSeatIds: const <String>['utg'],
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
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
      feedbackReason: 'KQo can continue in position against a simple open.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Almost got it.',
      feedbackReason: 'This hand is playable enough to continue in position.',
    ),
  ],
  table: _callActionRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'd'),
      Act0CardStateV1(rank: 'Q', suit: 'c'),
    ],
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
      feedbackReason: 'J8o is too weak to continue against the open.',
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
      feedbackReason: 'Position does not rescue every weak offsuit hand.',
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
  table: _world3EarlyFoldRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'd'),
      Act0CardStateV1(rank: 'T', suit: 'c'),
    ],
    centerLabel: 'Early position',
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
      label: 'Open because suited-looking hands can surprise people',
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
      label: 'Limp because nobody entered yet',
      isCorrect: false,
      preferredLabel: 'Trash bucket, clean fold',
      betterAnswerLabel: 'Trash bucket, clean fold',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable thought.',
      feedbackReason:
          'An unopened pot does not rescue a trash bucket. Discipline still says let it go instead of leaking a limp.',
    ),
  ],
  table: _w1DisciplineApplyEarlyFoldRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 'c'),
      Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
    ],
    activeSeatId: 'hj',
    highlightedSeatIds: const <String>['hj'],
    centerLabel: 'HJ, unopened pot',
    actionTrail: const <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'HJ acts'),
    ],
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
  table: _world3EarlyFoldRunner.table.copyWith(
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: '8', suit: 's'),
      Act0CardStateV1(rank: '4', suit: 'd'),
    ],
    centerLabel: 'Trash early',
    activeSeatId: 'utg',
    highlightedSeatIds: const <String>['utg'],
    highlightedCardIds: const <String>['hero_0', 'hero_1'],
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
          'Before choosing chips, ask what the bet is trying to do. Pot is 6 BB on the flop. Are you betting to collect chips from weaker hands (value), to fold out better hands (bluff), or to charge the next card before it arrives free (protection)? Name one reason, then pick a size.',
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
      body:
          'Value is simple: bet because worse hands can still pay. Hero has top pair with AQ on an A-7-2 board. Pot is 6 BB. Betting 3 BB asks every weaker ace, every pair of sevens, every pair of twos to put in chips you win on average.',
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
      feedbackTitle: 'Limp is legal, but raise is sharper.',
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
      feedbackTitle: 'Raise is the clean open.',
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
      body:
          'If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.',
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
  hint: 'Small price can invite a call. Big price can force a fold.',
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
      body: 'Calling means paying the listed price to see more cards.',
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
      feedbackReason: 'A small price can be worth paying with a real hand.',
    ),
    Act0RunnerOptionV1(
      id: 'fold',
      label: 'Fold',
      isCorrect: false,
      preferredLabel: 'Call',
      betterAnswerLabel: 'Call',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'The price is small enough to continue with one pair.',
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
      feedbackReason: 'A high price with a weak hand can simply fold.',
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
      feedbackReason: 'Calling pays too much for this weak hand.',
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

final _world4PriceRecapRunner = _world4PriceIntroRunner.copyWith(
  phase: Act0LessonPhaseV1.review,
  lessonId: 'w4_price_recap',
  caption: 'Lesson learned: every call has a price.',
  hint: 'Compare the price to hand strength and future cards.',
  question: 'What should you read before calling?',
  feedbackTitle: 'Price takeaway.',
  feedbackReason:
      'A call is not just staying curious. It pays a price, so the price must make sense.',
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
      feedbackReason: 'Connected ranks and two hearts create many changes.',
    ),
    Act0RunnerOptionV1(
      id: 'dry',
      label: 'Dry',
      isCorrect: false,
      preferredLabel: 'Wet',
      betterAnswerLabel: 'Wet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Nearly there.',
      feedbackReason: 'This board is connected and suited enough to be wet.',
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
      feedbackReason: 'More hearts can complete a flush.',
    ),
    Act0RunnerOptionV1(
      id: 'straight_draw',
      label: 'Straight draw',
      isCorrect: false,
      preferredLabel: 'Flush draw',
      betterAnswerLabel: 'Flush draw',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'On the right track.',
      feedbackReason: 'The visible clue is same suit, not connected ranks.',
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
          'A non-pair hand like A-K has 16 combos before blockers. A pocket pair '
          'has 6. Combo counts tell you how dense a hand family is inside a range.',
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
          'Your deeper stack matters less than the smaller stack that actually caps what can go in.',
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
          'Total chips are not the live planning number. Effective stack is.',
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
      body:
          'When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.',
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
      feedbackTitle: 'Effective stack: correct.',
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
      label: 'Call off light because payouts are close',
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
      feedbackTitle: '6-max: wider open.',
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
      label: 'Medium stack faces bubble pressure and cannot call as freely',
      isCorrect: true,
      preferredLabel:
          'Medium stack faces bubble pressure and cannot call as freely',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Sharp read.',
      feedbackReason:
          'That is the transfer. Bubble pressure hits the medium stack harder, while the covering stack can apply leverage.',
    ),
    Act0RunnerOptionV1(
      id: 'same_cash_logic',
      label: 'Treat it like the same cash-game spot',
      isCorrect: false,
      preferredLabel:
          'Medium stack faces bubble pressure and cannot call as freely',
      betterAnswerLabel:
          'Medium stack faces bubble pressure and cannot call as freely',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Very close.',
      feedbackReason:
          'Tournament life and bubble risk change this spot. Cash-style call freedom is too loose here.',
    ),
    Act0RunnerOptionV1(
      id: 'fold_everything_bubble',
      label: 'Fold everything because the bubble is near',
      isCorrect: false,
      preferredLabel:
          'Medium stack faces bubble pressure and cannot call as freely',
      betterAnswerLabel:
          'Medium stack faces bubble pressure and cannot call as freely',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Playable caution.',
      feedbackReason:
          'Bubble fear is not the whole lesson. The cleaner read is selective pressure awareness, not full shutdown.',
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
      label: 'Bluff more because they call anyway',
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
      label: 'Steal even wider because they call badly',
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
      feedbackTitle: 'Full ring: tighten early.',
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
      label: 'Widen late steals slightly and keep the change small',
      isCorrect: true,
      preferredLabel: 'Widen late steals slightly and keep the change small',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Clean execution.',
      feedbackReason:
          'That is the clean transfer: repeated blind overfolding supports one small late-position widen, not a full strategy rewrite.',
    ),
    Act0RunnerOptionV1(
      id: 'rewrite_everything',
      label: 'Rewrite preflop and postflop strategy everywhere now',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly and keep the change small',
      betterAnswerLabel: 'Widen late steals slightly and keep the change small',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Too broad.',
      feedbackReason:
          'One live read does not justify a global rewrite. Keep the exploit measurable and controlled.',
    ),
    Act0RunnerOptionV1(
      id: 'never_adjust',
      label: 'Keep baseline forever and ignore the pattern',
      isCorrect: false,
      preferredLabel: 'Widen late steals slightly and keep the change small',
      betterAnswerLabel: 'Widen late steals slightly and keep the change small',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Safe fallback.',
      feedbackReason:
          'Baseline is safer than chaos, but repeated overfolding is enough for one small, trackable exploit shift.',
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
      feedbackTitle: 'Sharp read.',
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
      feedbackTitle: 'Strong choice.',
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
      feedbackTitle: 'Solid understanding.',
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
      feedbackTitle: 'Well done.',
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
      feedbackTitle: 'Excellent spot.',
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
      feedbackTitle: 'Spot on.',
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
      feedbackTitle: 'Clean execution.',
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
      label: 'Write one priority leak and one fix for tomorrow',
      isCorrect: true,
      preferredLabel: 'Write one priority leak and one fix for tomorrow',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: 'Survival: tournament pressure matters.',
      feedbackReason:
          'Transfer compounds when review creates one actionable output that directly shapes the next session plan.',
    ),
    Act0RunnerOptionV1(
      id: 'long_notes',
      label: 'Write long notes with no chosen fix',
      isCorrect: false,
      preferredLabel: 'Write one priority leak and one fix for tomorrow',
      betterAnswerLabel: 'Write one priority leak and one fix for tomorrow',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Incomplete loop.',
      feedbackReason:
          'Notes without a selected repair action do not reliably transfer into behavior change.',
    ),
    Act0RunnerOptionV1(
      id: 'skip_closeout',
      label: 'Skip closeout and rely on memory tomorrow',
      isCorrect: false,
      preferredLabel: 'Write one priority leak and one fix for tomorrow',
      betterAnswerLabel: 'Write one priority leak and one fix for tomorrow',
      quality: Act0FeedbackQualityV1.suboptimal,
      feedbackTitle: 'Common habit.',
      feedbackReason:
          'Memory fades. A tiny explicit closeout step protects transfer quality between sessions.',
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
      feedbackTitle: 'Strong choice.',
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
      feedbackTitle: 'Solid understanding.',
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
      feedbackTitle: 'Well done.',
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
      feedbackTitle: 'Excellent spot.',
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
      feedbackTitle: 'Spot on.',
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
      feedbackTitle: 'Clean execution.',
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
      feedbackTitle: 'M-ratio: urgency zone read.',
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
          'Outcome-only judgement creates unstable learning and emotional swings.',
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
          'Skipping review may reduce frustration now, but it slows correction and transfer.',
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
      feedbackTitle: 'Sharp read.',
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
      feedbackTitle: 'Strong choice.',
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

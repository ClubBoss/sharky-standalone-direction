import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Act0LessonTaskV1> _allAct0TasksV1([Act0ShellStateV1? state]) {
  final resolvedState = state ?? Act0ShellStateV1.sample;
  final tasks = <Act0LessonTaskV1>[];
  for (var index = 1; index <= 12; index++) {
    tasks.addAll(
      resolvedState
          .worldById('world_$index')
          .lessons
          .expand((lesson) => lesson.taskList),
    );
  }
  return tasks;
}

bool _isAllowlistedDuplicateRoleV1(Act0LessonTaskV1 task) {
  final taskId = task.taskId.toLowerCase();
  final lessonId = task.runner.lessonId.toLowerCase();
  return task.phase == Act0LessonPhaseV1.review ||
      task.resolvedTaskFamily == Act0TaskFamilyV1.transfer ||
      taskId.contains('checkpoint') ||
      lessonId.contains('checkpoint') ||
      taskId.contains('recap') ||
      lessonId.contains('recap');
}

Map<(String, String, String), List<Act0LessonTaskV1>>
_duplicateDrillTripletClustersV1([Act0ShellStateV1? state]) {
  final clusters = <(String, String, String), List<Act0LessonTaskV1>>{};
  for (final task in _allAct0TasksV1(state)) {
    if (task.phase != Act0LessonPhaseV1.drill ||
        _isAllowlistedDuplicateRoleV1(task)) {
      continue;
    }
    final key = (
      task.runner.caption.trim(),
      task.runner.hint.trim(),
      task.runner.question.trim(),
    );
    clusters.putIfAbsent(key, () => <Act0LessonTaskV1>[]).add(task);
  }
  clusters.removeWhere((_, tasks) => tasks.length < 2);
  return clusters;
}

int _countDrillTripletMatchesV1(
  String caption,
  String hint,
  String question, [
  Act0ShellStateV1? state,
]) {
  return _duplicateDrillTripletClustersV1(
        state,
      )[(caption.trim(), hint.trim(), question.trim())]?.length ??
      0;
}

Act0LessonTaskV1 _taskByIdV1(List<Act0LessonTaskV1> tasks, String taskId) {
  return tasks.firstWhere((candidate) => candidate.taskId == taskId);
}

bool _isExplanationStyleOptionLabelV1(String label) {
  final normalized = label.toLowerCase();
  return normalized.contains('because') ||
      normalized.contains('so that') ||
      normalized.contains('even though');
}

bool _isCompactThreeOptionRiskLabelV1(
  Act0LessonTaskV1 task,
  Act0RunnerOptionV1 option,
) {
  if (task.runner.options.length != 3) {
    return false;
  }
  final wordCount = option.label.trim().split(RegExp(r'\s+')).length;
  return _isExplanationStyleOptionLabelV1(option.label) ||
      option.label.length >= 40 ||
      wordCount >= 7;
}

List<(Act0LessonTaskV1, Act0RunnerOptionV1)> _threeOptionRiskLabelsV1([
  Act0ShellStateV1? state,
]) {
  final rows = <(Act0LessonTaskV1, Act0RunnerOptionV1)>[];
  for (final task in _allAct0TasksV1(state)) {
    for (final option in task.runner.options) {
      if (_isCompactThreeOptionRiskLabelV1(task, option)) {
        rows.add((task, option));
      }
    }
  }
  return rows;
}

List<Act0LessonTaskV1> _simplifiedPreflopContinueCandidatesV1([
  Act0ShellStateV1? state,
]) {
  final tasks = _allAct0TasksV1(state);
  return <String>[
    'continue_or_let_go_medium_call_or_fold',
    'weak_ace_warning_w3_strong_continue',
    'discipline_checkpoint_checkpoint_borderline_continue',
    'position_checkpoint_position_checkpoint_btn_call',
    'open_call_fold_frame_call',
  ].map((taskId) => _taskByIdV1(tasks, taskId)).toList(growable: false);
}

int _wordCountV1(String text) {
  return RegExp(r"[A-Za-z0-9+'-]+").allMatches(text).length;
}

bool _containsTeachingStepJargonV1(String text) {
  final normalized = text.toLowerCase();
  return normalized.contains('combos') ||
      normalized.contains('blockers') ||
      normalized.contains('spr') ||
      normalized.contains('chip-ev');
}

List<(Act0LessonTaskV1, Act0TeachingStepV1)> _admittedTeachingStepBudgetRowsV1([
  Act0ShellStateV1? state,
]) {
  final tasks = _allAct0TasksV1(state);
  return <String>[
        'w4_purpose_intro',
        'w4_value_intro',
        'w4_protection_intro',
        'w6_combo_counts_intro',
        'w6_ak_combos',
        'w7_spr_intro',
      ]
      .expand((taskId) {
        final task = _taskByIdV1(tasks, taskId);
        return task.runner.teachingSteps.map((step) => (task, step));
      })
      .toList(growable: false);
}

List<(Act0LessonTaskV1, Act0TeachingStepV1, String)> _teachingStepJargonRowsV1([
  Act0ShellStateV1? state,
]) {
  final rows = <(Act0LessonTaskV1, Act0TeachingStepV1, String)>[];
  for (final task in _allAct0TasksV1(state)) {
    for (final step in task.runner.teachingSteps) {
      if (_containsTeachingStepJargonV1(step.body)) {
        rows.add((task, step, step.body));
      }
    }
  }
  return rows;
}

List<
  ({
    String worldId,
    String lessonId,
    String? taskId,
    bool hasRuLesson,
    bool hasRuTaskTitle,
    bool hasRuPrompt,
    bool hasRuSupport,
    bool hasRuQuestion,
    bool hasRuTeachingSteps,
  })
>
_ruLearnerSurfaceCoverageRowsV1([Act0ShellStateV1? state]) {
  final resolvedState = state ?? Act0ShellStateV1.sample;
  final bundle = act0CopyBundleForLanguageCodeV1('ru');
  final rows =
      <
        ({
          String worldId,
          String lessonId,
          String? taskId,
          bool hasRuLesson,
          bool hasRuTaskTitle,
          bool hasRuPrompt,
          bool hasRuSupport,
          bool hasRuQuestion,
          bool hasRuTeachingSteps,
        })
      >[];

  if (bundle == null) {
    return rows;
  }

  for (var worldIndex = 1; worldIndex <= 12; worldIndex++) {
    final world = resolvedState.worldById('world_$worldIndex');
    for (final lesson in world.lessons) {
      final localizedLesson = bundle.lessons[lesson.lessonId];
      final hasRuLesson =
          localizedLesson != null &&
          localizedLesson.title.isNotEmpty &&
          localizedLesson.subtitle.isNotEmpty;
      rows.add((
        worldId: world.worldId,
        lessonId: lesson.lessonId,
        taskId: null,
        hasRuLesson: hasRuLesson,
        hasRuTaskTitle: true,
        hasRuPrompt: true,
        hasRuSupport: true,
        hasRuQuestion: true,
        hasRuTeachingSteps: true,
      ));
      for (final task in lesson.taskList) {
        final localizedTask = bundle.tasks[task.taskId];
        final expectedTeachingStepCount = task.runner.teachingSteps.length;
        final localizedTeachingSteps = localizedTask?.teachingSteps;
        final hasRuTeachingSteps =
            expectedTeachingStepCount == 0 ||
            (localizedTeachingSteps != null &&
                localizedTeachingSteps.length == expectedTeachingStepCount &&
                localizedTeachingSteps.every(
                  (step) =>
                      (step.title ?? '').trim().isNotEmpty &&
                      (step.body ?? '').trim().isNotEmpty,
                ));
        rows.add((
          worldId: world.worldId,
          lessonId: lesson.lessonId,
          taskId: task.taskId,
          hasRuLesson: hasRuLesson,
          hasRuTaskTitle: (localizedTask?.title ?? '').trim().isNotEmpty,
          hasRuPrompt: (localizedTask?.runnerPrompt ?? '').trim().isNotEmpty,
          hasRuSupport: (localizedTask?.runnerSupport ?? '').trim().isNotEmpty,
          hasRuQuestion: (localizedTask?.runnerQuestion ?? '')
              .trim()
              .isNotEmpty,
          hasRuTeachingSteps: hasRuTeachingSteps,
        ));
      }
    }
  }
  return rows;
}

String _formatRuCoverageRowV1(
  ({
    String worldId,
    String lessonId,
    String? taskId,
    bool hasRuLesson,
    bool hasRuTaskTitle,
    bool hasRuPrompt,
    bool hasRuSupport,
    bool hasRuQuestion,
    bool hasRuTeachingSteps,
  })
  row,
) {
  return '${row.worldId}/${row.lessonId}/${row.taskId ?? 'lesson'} '
      'lesson=${row.hasRuLesson} title=${row.hasRuTaskTitle} '
      'prompt=${row.hasRuPrompt} support=${row.hasRuSupport} '
      'question=${row.hasRuQuestion} steps=${row.hasRuTeachingSteps}';
}

void _expectHeroOwnershipAlignmentV1(
  Act0LessonTaskV1 task,
  String expectedHeroSeatId,
) {
  final table = task.runner.table;
  final heroSeats = table.seats.where((seat) => seat.isHero).toList();

  expect(
    table.heroSeatId,
    expectedHeroSeatId,
    reason: '${task.taskId} should move hero ownership to $expectedHeroSeatId',
  );
  expect(
    table.activeSeatId,
    expectedHeroSeatId,
    reason:
        '${task.taskId} should keep the active decision seat on $expectedHeroSeatId',
  );
  expect(
    heroSeats,
    hasLength(1),
    reason: '${task.taskId} should expose exactly one hero-marked seat',
  );
  expect(heroSeats.single.seatId, expectedHeroSeatId);
  expect(heroSeats.single.displayName, 'Hero');
  expect(
    heroSeats.single.holeCards.map((card) => card.label).toList(),
    table.heroCards.map((card) => card.label).toList(),
    reason: '${task.taskId} should show the hero cards on the hero-owned seat',
  );
}

void _expectNoBtnHeroResidueV1(Act0LessonTaskV1 task) {
  final btnSeat = task.runner.table.seats.firstWhere(
    (seat) => seat.seatId == 'btn',
  );

  expect(
    btnSeat.isHero,
    isFalse,
    reason: '${task.taskId} should not keep BTN as Hero',
  );
  expect(
    btnSeat.displayName,
    isNot('Hero'),
    reason: '${task.taskId} should clear the stale BTN Hero label',
  );
  expect(
    btnSeat.cardsVisibleMode,
    isNot(Act0CardsVisibleModeV1.faceUp),
    reason: '${task.taskId} should not keep hero-visible cards on BTN',
  );
}

String _finalActionTrailActorSeatIdV1(Act0LessonTaskV1 task) {
  final trail = task.runner.table.actionTrail;
  if (trail.isEmpty) {
    return '';
  }
  final lastLabel = trail.last.label.trim();
  for (final seat in task.runner.table.seats) {
    final seatLabel = seat.seatLabel.trim();
    if (seatLabel.isNotEmpty && lastLabel.startsWith('$seatLabel ')) {
      return seat.seatId;
    }
  }
  return '';
}

void main() {
  _registerPotCalcTests();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Feedback shell falls back to scenario-first reason when empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Almost there.',
            reason: '',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine: 'Good spot to fix.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Raise',
            preferredLabel: 'Call',
            betterLabel: 'Call',
            contextLabels: const <String>['BTN'],
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsOneWidget);
    expect(find.text('BTN first'), findsOneWidget);
    expect(
      find.text('BTN first. Compare it with Call before you continue.'),
      findsOneWidget,
    );
  });

  testWidgets('Feedback shell prefers wrapped density over hard truncation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Almost there.',
            reason:
                'Button acts first in this spot, so compare the action order before you pay more to continue into the hand.',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine:
                'One calm repair here keeps the same leak from following you into the next rep.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Call',
            preferredLabel: 'Fold and reset the spot',
            betterLabel: 'Fold and reset the spot',
            contextLabels: const <String>['BTN first', 'Facing a bet'],
            onContinue: () {},
          ),
        ),
      ),
    );

    final reaction = tester.widget<Text>(
      find.byKey(const Key('act0_shell_sharky_outcome_reaction')),
    );
    final selected = tester.widget<Text>(
      find.byKey(const Key('act0_shell_feedback_selected_label')),
    );
    final preferred = tester.widget<Text>(
      find.byKey(const Key('act0_shell_feedback_preferred_label')),
    );
    final reason = tester.widget<Text>(
      find.byKey(const Key('act0_shell_feedback_reason')),
    );

    expect(reaction.overflow, TextOverflow.fade);
    expect(selected.overflow, TextOverflow.fade);
    expect(preferred.maxLines, 2);
    expect(preferred.overflow, TextOverflow.fade);
    expect(reason.maxLines, 4);
    expect(reason.overflow, TextOverflow.fade);
  });

  testWidgets('Feedback shell keeps better option above picked answer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Almost there.',
            reason: 'Five board cards appear only by the river.',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine: 'Good spot to fix.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Five',
            preferredLabel: 'Three',
            betterLabel: 'Three',
            contextLabels: const <String>['Board count'],
            onContinue: () {},
          ),
        ),
      ),
    );

    final betterTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_feedback_preferred_label')),
        )
        .dy;
    final pickedTop = tester
        .getTopLeft(find.byKey(const Key('act0_shell_feedback_selected_label')))
        .dy;

    expect(find.text('Better option: Three'), findsOneWidget);
    expect(find.text('You picked Five'), findsOneWidget);
    expect(betterTop, lessThan(pickedTop));
    expect(find.textContaining('failed'), findsNothing);
    expect(find.textContaining('repaired'), findsNothing);
    expect(find.textContaining('cleared with error'), findsNothing);
  });

  testWidgets('Feedback shell keeps positive answer as the primary line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Nice read.',
            reason: 'The cutoff acts just before the button.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Sharp read.',
            sharkyMood: Act0SharkyMoodV1.happy,
            selectedLabel: 'CO',
            preferredLabel: 'CO',
            betterLabel: 'CO',
            taskFamily: Act0TaskFamilyV1.recognition,
            contextLabels: const <String>['Position'],
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Correct answer: CO'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_status_label')),
      findsOneWidget,
    );
    expect(find.text('Nice read.'), findsNothing);
  });

  testWidgets(
    'Feedback shell keeps table-read answers in English on English locale',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0FeedbackShellV1(
              title: 'Sharp read.',
              reason: 'Private cards, board cards, then pot.',
              quality: Act0FeedbackQualityV1.correct,
              sharkyLine: 'Sharp read.',
              sharkyMood: Act0SharkyMoodV1.happy,
              selectedLabel: '2 private cards, 3 board cards, 6 BB in the pot',
              preferredLabel: '2 private cards, 3 board cards, 6 BB in the pot',
              betterLabel: '2 private cards, 3 board cards, 6 BB in the pot',
              taskFamily: Act0TaskFamilyV1.transfer,
              contextLabels: const <String>['Table read'],
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Clean read: 2 private cards, 3 board cards, 6 BB in the pot',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('закрытые карты'), findsNothing);
      expect(find.textContaining('общие карты'), findsNothing);
    },
  );

  Widget host({
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
    Act0LessonPhaseV1 phase = Act0LessonPhaseV1.theory,
    Act0ShellStateV1? state,
    bool showPlacementOnStart = false,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: tab,
        initialPhase: phase,
        state: state,
        showPlacementOnStart: showPlacementOnStart,
      ),
    );
  }

  Act0ShellStateV1 stateWithProgress({required int xp, required int level}) {
    final sample = Act0ShellStateV1.sample;
    return Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: 'Level $level',
      xp: xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: sample.selectedWorldId,
      worlds: sample.worlds,
      lessons: sample.lessons,
      review: sample.review,
      profile: Act0ProfileStateV1(
        playerName: sample.profile.playerName,
        level: 'Level $level',
        xpLine: '$xp / ${sample.xpTarget} XP',
        lessonsLine: sample.profile.lessonsLine,
        accuracyLine: sample.profile.accuracyLine,
        qualityLine: sample.profile.qualityLine,
        consistencyActiveDays: sample.profile.consistencyActiveDays,
        achievements: sample.profile.achievements,
        strongCategories: sample.profile.strongCategories,
        weakCategories: sample.profile.weakCategories,
        recentProgress: sample.profile.recentProgress,
        recentSkillGains: sample.profile.recentSkillGains,
        skillStats: sample.profile.skillStats,
        recommendedFocusTitle: sample.profile.recommendedFocusTitle,
        recommendedFocusBody: sample.profile.recommendedFocusBody,
        recommendedFocusCtaLabel: sample.profile.recommendedFocusCtaLabel,
      ),
    );
  }

  Act0ShellStateV1 stateWithLessons(List<Act0LessonCardV1> lessons) {
    final sample = Act0ShellStateV1.sample;
    return Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: 'world_1',
      worlds: <Act0WorldCardV1>[
        sample
            .worldById('world_1')
            .copyWith(lessons: lessons, isSelectable: true, isLocked: false),
      ],
      lessons: lessons,
      review: sample.review,
      profile: sample.profile,
    );
  }

  Act0ShellStateV1 stateWithWorlds({
    required String selectedWorldId,
    required List<Act0WorldCardV1> worlds,
  }) {
    final sample = Act0ShellStateV1.sample;
    final selectedWorld = worlds.firstWhere(
      (world) => world.worldId == selectedWorldId,
    );
    return Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: selectedWorldId,
      worlds: worlds,
      lessons: selectedWorld.lessons,
      review: sample.review,
      profile: sample.profile,
    );
  }

  Act0ShellStateV1 stateWithNoCompletedPractice() {
    final sample = Act0ShellStateV1.sample;
    final world1 = sample.worldById('world_1');
    final lessons = <Act0LessonCardV1>[
      for (var i = 0; i < world1.lessons.length; i++)
        world1.lessons[i].copyWith(
          state: i == 0 ? Act0LessonStateV1.current : Act0LessonStateV1.locked,
          isSelectable: i == 0,
          isLocked: i != 0,
        ),
    ];
    final worlds = <Act0WorldCardV1>[
      world1.copyWith(
        status: Act0WorldStateV1.current,
        isSelectable: true,
        isLocked: false,
        lessons: lessons,
      ),
    ];
    return stateWithWorlds(selectedWorldId: 'world_1', worlds: worlds);
  }

  Act0ShellStateV1 stateWithoutRecentSkillGains() {
    final sample = Act0ShellStateV1.sample;
    return Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: sample.selectedWorldId,
      worlds: sample.worlds,
      lessons: sample.lessons,
      review: sample.review,
      profile: Act0ProfileStateV1(
        playerName: sample.profile.playerName,
        level: sample.profile.level,
        xpLine: sample.profile.xpLine,
        lessonsLine: sample.profile.lessonsLine,
        accuracyLine: sample.profile.accuracyLine,
        qualityLine: sample.profile.qualityLine,
        consistencyActiveDays: sample.profile.consistencyActiveDays,
        achievements: sample.profile.achievements,
        strongCategories: sample.profile.strongCategories,
        weakCategories: sample.profile.weakCategories,
        recentProgress: sample.profile.recentProgress,
        recentSkillGains: const <Act0SkillGainV1>[],
        skillStats: sample.profile.skillStats,
        recommendedFocusTitle: sample.profile.recommendedFocusTitle,
        recommendedFocusBody: sample.profile.recommendedFocusBody,
        recommendedFocusCtaLabel: sample.profile.recommendedFocusCtaLabel,
      ),
    );
  }

  String persistedProgressWithCompletedWorlds({
    required int completedWorldCount,
  }) {
    final sample = Act0ShellStateV1.sample;
    final worlds = sample.worlds
        .where((world) => world.worldNumber <= 6)
        .take(completedWorldCount)
        .toList(growable: false);
    final completedTaskIds = <String>{};
    final completedLessonIds = <String>{};
    for (final world in worlds) {
      for (final lesson in world.lessons) {
        completedLessonIds.add(lesson.lessonId);
        for (final task in lesson.taskList) {
          completedTaskIds.add(task.taskId);
        }
      }
    }
    final currentLesson = sample.currentLesson;
    final selectedTaskId = currentLesson.taskList.first.taskId;
    return jsonEncode(<String, Object>{
      'schemaVersion': 1,
      'completedTaskIds': completedTaskIds.toList(growable: false)..sort(),
      'completedLessonIds': completedLessonIds.toList(growable: false)..sort(),
      'selectedWorldId': sample.selectedWorldId,
      'selectedLessonId': currentLesson.lessonId,
      'selectedTaskId': selectedTaskId,
      'earnedXp': 0,
    });
  }

  Future<void> pumpTall(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> pumpCompact(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> openBottomTabAndDrainV1(
    WidgetTester tester,
    String label, {
    Duration drain = const Duration(seconds: 2),
  }) async {
    await tester.tap(find.text(label).first);
    await tester.pumpAndSettle();
    await tester.pump(drain);
    await tester.pumpAndSettle();
  }

  Future<void> openBottomTabV1(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).first);
    await tester.pumpAndSettle();
  }

  Future<void> advanceRunnerUntil(
    WidgetTester tester,
    bool Function() isDone, {
    String failureMessage = 'Runner did not reach the expected state.',
    int maxTaps = 24,
  }) async {
    for (var i = 0; i < maxTaps; i++) {
      if (isDone()) {
        return;
      }
      final cta = find.byKey(const Key('act0_shell_continue_cta'));
      expect(cta, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(cta);
      await tester.pumpAndSettle();
    }
    if (isDone()) {
      return;
    }
    fail(failureMessage);
  }

  Future<void> advanceTeachingToDrill(WidgetTester tester) async {
    const practiceGroupPriority = <String>[
      'continue',
      'daily',
      'actions',
      'weak_spots',
      'positions',
      'streets',
      'rankings',
      'showdown',
    ];
    for (var i = 0; i < 8; i++) {
      if (find
              .byKey(const Key('act0_shell_action_panel'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_sizing_confirm_cta'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_raise'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_check'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_call'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_fold'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_seat_tap_prompt'))
              .evaluate()
              .isNotEmpty) {
        return;
      }
      if (find
          .byKey(const Key('act0_shell_play_screen'))
          .evaluate()
          .isNotEmpty) {
        for (final groupId in practiceGroupPriority) {
          final group = find.byKey(Key('act0_shell_practice_group_$groupId'));
          if (group.evaluate().isNotEmpty) {
            await tester.ensureVisible(group);
            await tester.pumpAndSettle();
            await tester.tap(group);
            await tester.pumpAndSettle();
            break;
          }
        }
        continue;
      }
      await advanceRunnerUntil(
        tester,
        () =>
            find
                .byKey(const Key('act0_shell_action_panel'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_sizing_confirm_cta'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_option_raise'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_option_check'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_option_call'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_option_fold'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_seat_tap_prompt'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_play_screen'))
                .evaluate()
                .isNotEmpty,
        failureMessage: 'Teaching steps did not reveal a drill surface.',
        maxTaps: 12,
      );
      if (find
          .byKey(const Key('act0_shell_play_screen'))
          .evaluate()
          .isNotEmpty) {
        continue;
      }
      return;
    }
    fail('Teaching steps did not reveal a drill surface.');
  }

  Future<void> completeVisibleTheoryTask(WidgetTester tester) async {
    await advanceRunnerUntil(
      tester,
      () =>
          find.text('2/7').evaluate().isNotEmpty ||
          find
              .byKey(const Key('act0_shell_play_screen'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_action_panel'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_seat_tap_prompt'))
              .evaluate()
              .isNotEmpty,
      failureMessage: 'Theory task did not advance.',
      maxTaps: 16,
    );
  }

  Future<void> advanceCurrentRunnerToDrill(WidgetTester tester) async {
    if (find.byKey(const Key('act0_shell_play_screen')).evaluate().isNotEmpty) {
      fail('Expected runner entry, but Play hub was still visible.');
    }
    await advanceRunnerUntil(
      tester,
      () =>
          find
              .byKey(const Key('act0_shell_action_panel'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_raise'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_check'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_call'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_fold'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_seat_tap_prompt'))
              .evaluate()
              .isNotEmpty,
      failureMessage: 'Runner did not advance into a drill prompt.',
      maxTaps: 12,
    );
  }

  Future<void> startPlacementIfNeeded(WidgetTester tester) async {
    final introCta = find.byKey(const Key('act0_shell_placement_intro_cta'));
    if (introCta.evaluate().isNotEmpty) {
      await tester.tap(introCta);
      await tester.pumpAndSettle();
    }
  }

  Future<void> answerPlacementQuestion(
    WidgetTester tester,
    String optionId,
  ) async {
    await startPlacementIfNeeded(tester);
    await tester.tap(find.byKey(Key('act0_shell_placement_option_$optionId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> answerPlacementQuestionMulti(
    WidgetTester tester,
    List<String> optionIds,
  ) async {
    await startPlacementIfNeeded(tester);
    for (final optionId in optionIds) {
      await tester.tap(
        find.byKey(Key('act0_shell_placement_option_$optionId')),
      );
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> runPlacementToResult(WidgetTester tester) async {
    await answerPlacementQuestion(tester, 'new');
    await answerPlacementQuestionMulti(tester, <String>[
      'basics',
      'home_games',
    ]);
    await answerPlacementQuestion(tester, 'rules');
    await answerPlacementQuestion(tester, 'guided');
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_diagnostic')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_two_three_six')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_board')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> completeWelcomeLayer(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_option_hero_bottom')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> answerVisiblePromptWrongly(WidgetTester tester) async {
    final runnerFinder = find.byType(Act0LessonRunnerShellV1);
    expect(runnerFinder, findsOneWidget);
    final runnerWidget = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
    final wrongOption = runnerWidget.runner.options.firstWhere(
      (option) => !option.isCorrect,
    );

    if (runnerWidget.runner.sizingConfig.isEnabled) {
      final preset = find.byKey(
        Key('act0_shell_sizing_preset_${wrongOption.id}'),
      );
      expect(preset, findsOneWidget);
      await tester.tap(preset);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
      await tester.pumpAndSettle();
      return;
    }

    final answerKey = wrongOption.seatId == null
        ? Key('act0_shell_option_${wrongOption.id}')
        : Key('act0_shell_seat_tap_${wrongOption.seatId}');
    final answerFinder = find.byKey(answerKey);
    expect(answerFinder, findsOneWidget);
    await tester.tap(answerFinder);
    await tester.pumpAndSettle();
  }

  Future<void> createActionsMistakeFromPlayHub(WidgetTester tester) async {
    await openBottomTabV1(tester, 'Practice');
    await tester.pumpAndSettle();
    final dailyTile = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyTile.evaluate().isNotEmpty) {
      await tester.tap(dailyTile);
      await tester.pumpAndSettle();
    } else {
      expect(
        find.byKey(const Key('act0_shell_play_featured_card')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('act0_shell_play_featured_cta')));
      await tester.pumpAndSettle();
    }
    await advanceCurrentRunnerToDrill(tester);
    await answerVisiblePromptWrongly(tester);
  }

  Future<void> openSelectedLessonFromLearn(WidgetTester tester) async {
    final cta = find.byKey(const Key('act0_shell_selected_lesson_cta'));
    expect(cta, findsOneWidget);
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }

  Future<void> answerAnyVisiblePrompt(WidgetTester tester) async {
    final runnerScope = find.byKey(const Key('act0_shell_runner_screen'));
    const optionKeys = <Key>[
      Key('act0_shell_option_two_three_six'),
      Key('act0_shell_option_board'),
      Key('act0_shell_option_check'),
      Key('act0_shell_option_fold'),
      Key('act0_shell_option_call'),
      Key('act0_shell_option_raise'),
      Key('act0_shell_option_three'),
      Key('act0_shell_seat_tap_btn'),
      Key('act0_shell_seat_tap_sb'),
      Key('act0_shell_seat_tap_bb'),
      Key('act0_shell_seat_tap_utg'),
      Key('act0_shell_seat_tap_hj'),
      Key('act0_shell_seat_tap_co'),
    ];
    for (final key in optionKeys) {
      final finder = find.descendant(
        of: runnerScope,
        matching: find.byKey(key),
      );
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder);
        await tester.pumpAndSettle();
        return;
      }
    }
    final genericChoice = find.descendant(
      of: runnerScope,
      matching: find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is! ValueKey<String>) {
          return false;
        }
        return key.value.startsWith('act0_shell_option_') ||
            key.value.startsWith('act0_shell_seat_tap_');
      }),
    );
    if (genericChoice.evaluate().isNotEmpty) {
      await tester.tap(genericChoice.first);
      await tester.pumpAndSettle();
      return;
    }
    fail('No visible runner option was available to answer.');
  }

  Future<void> answerVisiblePromptCorrectly(WidgetTester tester) async {
    final runnerFinder = find.byType(Act0LessonRunnerShellV1);
    expect(runnerFinder, findsOneWidget);
    final runnerWidget = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
    final correctOption = runnerWidget.runner.options.firstWhere(
      (option) => option.isCorrect,
    );

    if (runnerWidget.runner.sizingConfig.isEnabled) {
      final preset = find.byKey(
        Key('act0_shell_sizing_preset_${correctOption.id}'),
      );
      expect(preset, findsOneWidget);
      await tester.tap(preset);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
      await tester.pumpAndSettle();
      return;
    }

    final answerKey = correctOption.seatId == null
        ? Key('act0_shell_option_${correctOption.id}')
        : Key('act0_shell_seat_tap_${correctOption.seatId}');
    final answerFinder = find.byKey(answerKey);
    expect(answerFinder, findsOneWidget);
    await tester.tap(answerFinder);
    await tester.pumpAndSettle();
  }

  Future<void> finishPracticeRepAndReturnToHub(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      if (find
          .byKey(const Key('act0_shell_play_screen'))
          .evaluate()
          .isNotEmpty) {
        return;
      }
      final feedbackContinue = find.byKey(
        const Key('act0_shell_feedback_continue_cta'),
      );
      if (feedbackContinue.evaluate().isNotEmpty) {
        await tester.tap(feedbackContinue);
        await tester.pumpAndSettle();
        continue;
      }
      final blockSummaryContinue = find.byKey(
        const Key('act0_shell_block_summary_continue_cta'),
      );
      if (blockSummaryContinue.evaluate().isNotEmpty) {
        await tester.tap(blockSummaryContinue);
        await tester.pumpAndSettle();
        continue;
      }
      final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
      if (runnerBack.evaluate().isNotEmpty) {
        await tester.tap(runnerBack);
        await tester.pumpAndSettle();
        continue;
      }
      break;
    }
    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
  }

  Future<void> waitForRapidPracticeTransition(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  }

  Future<void> startDailyPracticeFromHub(WidgetTester tester) async {
    final dailyTile = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyTile.evaluate().isNotEmpty) {
      await tester.ensureVisible(dailyTile);
      await tester.pumpAndSettle();
      await tester.tap(dailyTile);
      await tester.pumpAndSettle();
      return;
    }

    expect(
      find.byKey(const Key('act0_shell_play_featured_card')),
      findsOneWidget,
    );
    expect(find.text('Start daily set'), findsWidgets);
    await tester.tap(find.byKey(const Key('act0_shell_play_featured_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> exitActiveRunnerToPlayHub(WidgetTester tester) async {
    if (find.byKey(const Key('act0_shell_play_screen')).evaluate().isNotEmpty) {
      return;
    }
    final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
    expect(runnerBack, findsOneWidget);
    await tester.tap(runnerBack);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
  }

  Future<void> completeDailySetFromPlay(WidgetTester tester) async {
    await startDailyPracticeFromHub(tester);

    await advanceCurrentRunnerToDrill(tester);
    for (var round = 0; round < 3; round++) {
      await answerVisiblePromptCorrectly(tester);
      await waitForRapidPracticeTransition(tester);
      if (find
          .byKey(const Key('act0_shell_play_screen'))
          .evaluate()
          .isNotEmpty) {
        return;
      }
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_play_screen')), findsNothing);
    }

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
  }

  test('Table-format helpers expose canonical seat orders by format', () {
    expect(
      act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.sixMax),
      <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
    );
    expect(
      act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.nineMax),
      <String>['UTG', 'UTG+1', 'MP', 'LJ', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
    );
    expect(
      act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.tenMax),
      <String>[
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
    );
    expect(act0ExpectedPlayerCountForFormatV1(Act0TableFormatV1.sixMax), 6);
    expect(act0ExpectedPlayerCountForFormatV1(Act0TableFormatV1.nineMax), 9);
    expect(act0ExpectedPlayerCountForFormatV1(Act0TableFormatV1.tenMax), 10);
    expect(act0TableFormatLabelV1(Act0TableFormatV1.sixMax), '6-max');
    expect(act0TableFormatLabelV1(Act0TableFormatV1.nineMax), '9-max');
    expect(act0TableFormatLabelV1(Act0TableFormatV1.tenMax), '10-max');
  });

  test('Canonical path root remains Act0 preview shell', () {
    final root = buildCanonicalPathRootV1();
    expect(root, isA<Act0ShellPreviewScreenV1>());
    final act0Root = root as Act0ShellPreviewScreenV1;
    expect(act0Root.showPlacementOnStart, isTrue);
  });

  test('Sample table keeps typed format and canonical player-count truth', () {
    final table = Act0ShellStateV1.sample.currentLesson.runner.table;
    expect(table.tableFormat, Act0TableFormatV1.sixMax);
    expect(table.tableSize, '6-max');
    expect(table.usesCanonicalPlayerCount, isTrue);
    expect(
      table.canonicalSeatOrder,
      act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.sixMax),
    );
  });

  test('Task-family inference is typed and overridable', () {
    final sample = Act0ShellStateV1.sample;
    final learnTask = sample.worldById('world_1').lessons.first.taskList.first;
    expect(learnTask.resolvedTaskFamily, Act0TaskFamilyV1.learn);

    final repairTask = sample
        .worldById('world_2')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_apply')
        .taskList
        .firstWhere(
          (task) => task.stepKind == Act0LessonStepKindV1.fixMistakes,
        );
    expect(repairTask.resolvedTaskFamily, Act0TaskFamilyV1.repair);

    final proveItTask = sample
        .worldById('world_7')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_thinking_checkpoint')
        .taskList
        .last;
    expect(proveItTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);

    final customTask = Act0LessonTaskV1(
      taskId: 'custom_counting',
      title: 'Count outs',
      phase: Act0LessonPhaseV1.drill,
      runner: learnTask.runner,
      rewardXp: 1,
      taskFamily: Act0TaskFamilyV1.counting,
    );
    expect(customTask.resolvedTaskFamily, Act0TaskFamilyV1.counting);

    final world5SizingTask = sample
        .worldById('world_5')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'small_half_pot')
        .taskList
        .firstWhere((task) => task.taskId == 'w4_half_pot_bet');
    expect(world5SizingTask.resolvedTaskFamily, Act0TaskFamilyV1.sizing);

    final compareTask = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'showdown_winning')
        .taskList
        .firstWhere((task) => task.taskId == 'showdown_best_hand_drill');
    expect(compareTask.resolvedTaskFamily, Act0TaskFamilyV1.compare);

    final countingTask = sample
        .worldById('world_7')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_combo_counts')
        .taskList
        .firstWhere((task) => task.taskId == 'w6_ak_combos');
    expect(countingTask.resolvedTaskFamily, Act0TaskFamilyV1.counting);
  });

  Future<void> completeCurrentLessonBlock(WidgetTester tester) async {
    await completeVisibleTheoryTask(tester);
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_call')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
  }

  testWidgets('Home shell shows Poker from Zero and exactly one main CTA', (
    tester,
  ) async {
    await pumpTall(tester, host());

    expect(find.text('Active world: Poker from Zero'), findsOneWidget);
    expect(find.text('Fold, check, call, raise'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_repair_panel')),
      findsOneWidget,
    );
    expect(find.text('All sharp.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_repair_clear_state')),
      findsOneWidget,
    );
    expect(find.text('Nothing to fix right now.'), findsNothing);
    expect(find.text('Extra reps'), findsNothing);
    expect(find.text('Optional rep'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_optional_practice_hint')),
      findsNothing,
    );
    expect(
      find.text('Play stays optional. The main route still lives in Learn.'),
      findsNothing,
    );
    expect(find.text('One extra rep, only if you want it.'), findsNothing);
    expect(find.text('Now: Actions'), findsNothing);
    expect(find.text('Next: Blinds & action order'), findsNothing);
    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_primary_tap_target')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_home_cta_hint')), findsNothing);
    expect(find.text('Continue this lesson now.'), findsNothing);
    expect(find.byKey(const Key('act0_shell_home_streak_strip')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_home_dev_menu_button')),
      findsOneWidget,
    );
    _expectNoForbiddenLabels();
  });

  testWidgets('Dev menu can jump straight to the map', (tester) async {
    await pumpTall(tester, host());

    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_dev_menu_open_map')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('act0_shell_dev_menu_open_map')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
  });

  testWidgets(
    'Dev menu reset returns to first-start placement after clearing app progress',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'onboarding_complete': true,
        'dummy_progress': 1,
      });
      await pumpTall(tester, host());

      await tester.tap(
        find.byKey(const Key('act0_shell_home_dev_menu_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_dev_menu_reset_progress')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_dev_menu_reset_confirm')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_placement_screen')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
    },
  );

  testWidgets(
    'Dev menu reset rewrites persisted progress to first-start zero state',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final world1 = sample.worldById('world_1');
      final world2 = sample.worldById('world_2');
      final world3 = sample.worldById('world_3');
      final completedTaskIds = <String>{
        for (final lesson in world1.lessons)
          for (final task in lesson.taskList) task.taskId,
        for (final lesson in world2.lessons)
          for (final task in lesson.taskList) task.taskId,
      };
      final completedLessonIds = <String>{
        for (final lesson in world1.lessons) lesson.lessonId,
        for (final lesson in world2.lessons) lesson.lessonId,
      };
      final world3Lesson = world3.lessons.first;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'onboarding_complete': true,
        'act0_shell_progress_v1': jsonEncode(<String, Object>{
          'schemaVersion': 5,
          'completedTaskIds': completedTaskIds.toList(growable: false)..sort(),
          'skippedTaskIds': <String>[],
          'completedLessonIds': completedLessonIds.toList(growable: false)
            ..sort(),
          'selectedWorldId': 'world_3',
          'selectedLessonId': world3Lesson.lessonId,
          'selectedTaskId': world3Lesson.taskList.first.taskId,
          'earnedXp': 140,
          'lastActiveDay': '',
          'persistedStreakDays': 0,
          'resumeInRunner': false,
          'resumePhase': 'theory',
          'resumeTeachingStepIndex': 0,
        }),
      });

      await pumpTall(tester, host());

      await tester.tap(
        find.byKey(const Key('act0_shell_home_dev_menu_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_dev_menu_reset_progress')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_dev_menu_reset_confirm')),
      );
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('act0_shell_progress_v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['selectedWorldId'], 'world_1');
      expect(decoded['selectedLessonId'], world1.lessons.first.lessonId);
      expect(
        decoded['selectedTaskId'],
        world1.lessons.first.taskList.first.taskId,
      );
      expect(decoded['earnedXp'], 0);
      expect((decoded['completedTaskIds'] as List<dynamic>), isEmpty);
      expect((decoded['completedLessonIds'] as List<dynamic>), isEmpty);
    },
  );

  testWidgets('AppRoot boots into canonical first-start placement', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(
      find.byKey(const Key('act0_shell_placement_screen')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Dev menu can open placement manually from Today', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_dev_menu_open_placement')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_placement_screen')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  });

  testWidgets('Dev menu can jump to review, profile, play hub and runner', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_dev_menu_open_review')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_dev_menu_open_profile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_profile_screen')), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_dev_menu_open_play_hub')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_dev_menu_open_runner')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('First-run placement asks questions before the app shell', (
    tester,
  ) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    expect(
      find.byKey(const Key('act0_shell_placement_screen')),
      findsOneWidget,
    );
    expect(find.text('Find your start'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_placement_hero')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_intro_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_for_who')),
      findsOneWidget,
    );
    expect(find.text('Quick route check. No long setup.'), findsOneWidget);
    expect(find.text('What happens next'), findsOneWidget);
    expect(
      find.textContaining(
        'One clear place to start instead of a generic opener',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_reassurance')),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'You see where to start and your first hand before any premium prompt',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Two minutes. Then Sharky shows where to start.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_flow_action_bar')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_cta')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('act0_shell_placement_intro_cta')));
    await tester.pumpAndSettle();
    expect(find.text('Where are you starting from?'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('Choose one'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);

    await answerPlacementQuestion(tester, 'new');
    expect(find.text('What do you want poker for?'), findsOneWidget);
    await answerPlacementQuestion(tester, 'basics');
    expect(find.text('What feels most confusing?'), findsOneWidget);
    await answerPlacementQuestion(tester, 'rules');
    expect(find.text('How should Sharky coach you?'), findsOneWidget);
    await answerPlacementQuestion(tester, 'guided');

    expect(
      find.byKey(const Key('act0_shell_placement_diagnostic_ready')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_ready_steps')),
      findsOneWidget,
    );
    expect(
      find.text(
        'One short live check. Then Sharky locks the best place to begin.',
      ),
      findsOneWidget,
    );
    expect(find.text('Five quick reads'), findsOneWidget);
    expect(find.textContaining('Live table scan'), findsOneWidget);
    expect(
      find.textContaining('Private cards versus shared board'),
      findsOneWidget,
    );
    expect(find.textContaining('Action order'), findsOneWidget);
    expect(find.textContaining('legal-action check'), findsOneWidget);
    expect(
      find.textContaining('Early versus late position value'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Then you land in one start that fits, opens fast, and proves itself early.',
      ),
      findsOneWidget,
    );
    expect(find.text('Start quick check'), findsOneWidget);
  });

  testWidgets('Placement multi-select keeps all selected answers', (
    tester,
  ) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await answerPlacementQuestion(tester, 'friends');

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_option_basics')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_option_cash')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_option_tournaments')),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 selected'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_option_basics')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_option_cash')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_option_tournaments')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Placement keeps the continue CTA pinned while the question scrolls',
    (tester) async {
      await pumpCompact(tester, host(showPlacementOnStart: true));

      await startPlacementIfNeeded(tester);
      await tester.drag(
        find.byKey(const Key('act0_shell_placement_screen')),
        const Offset(0, -260),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_placement_flow_action_bar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_placement_next_cta')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_placement_option_new')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
      await tester.pumpAndSettle();

      expect(find.text('What do you want poker for?'), findsOneWidget);
    },
  );

  testWidgets('Placement diagnostic hands off into Welcome before Home', (
    tester,
  ) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await runPlacementToResult(tester);

    expect(
      find.byKey(const Key('act0_shell_placement_result')),
      findsOneWidget,
    );
    expect(find.textContaining('5/5'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_placement_report_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_right_place_banner')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_skill_stats')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_primary_recommendation')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_value_preview')),
      findsNothing,
    );
    expect(find.text('Sharky recommendation'), findsOneWidget);
    expect(find.text('Core poker skills'), findsOneWidget);
    expect(find.textContaining('Lv'), findsWidgets);
    expect(find.text('Start here'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_placement_open_recommended_path')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_destination_trust_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_report_body_block_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_report_body_block_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('act0_shell_placement_destination_trust_line_block_0'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_first_win_card')),
      findsOneWidget,
    );
    expect(find.text('What should feel better first'), findsOneWidget);
    expect(find.textContaining('By the end of the first hand'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_placement_next_10_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_recommended_reason_block_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_next_10_blocks_block_0')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_placement_skill_stat_Table sense')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_skill_stat_Table sense')),
    );
    await tester.pumpAndSettle();
    expect(find.text('What it means'), findsOneWidget);
    expect(find.text('What it affects'), findsOneWidget);
    expect(find.text('Why it matters'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_open_recommended_path')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_placement_recommended_sheet')),
      findsOneWidget,
    );
    expect(find.text('Start here'), findsWidgets);
    expect(find.text('First sessions'), findsOneWidget);
    expect(find.text('Preview 7-day trial'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_recommended_trust_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('act0_shell_placement_sheet_recommended_reason_block_0'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('act0_shell_placement_recommended_trust_line_block_0'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_premium_pitch_block_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_recommended_proof_banner')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_recommended')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_welcome_primary_cta')),
      findsOneWidget,
    );

    await completeWelcomeLayer(tester);

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    expect(find.text('Start here'), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_continue_cta')), findsOneWidget);
  });

  testWidgets('Placement seeds poker skill stats into Profile', (tester) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await answerPlacementQuestion(tester, 'new');
    await answerPlacementQuestionMulti(tester, <String>[
      'basics',
      'home_games',
    ]);
    await answerPlacementQuestion(tester, 'rules');
    await answerPlacementQuestion(tester, 'guided');
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_diagnostic')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_two_three_six')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_board')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_open_recommended_path')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_recommended')),
    );
    await tester.pumpAndSettle();
    await completeWelcomeLayer(tester);

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_profile_skill_stats')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_profile_skill_stat_Table sense')),
      findsOneWidget,
    );
    expect(find.textContaining('to Lv'), findsWidgets);
    expect(find.text('Blind play'), findsOneWidget);
  });

  testWidgets(
    'Returning boot with completed Welcome skips placement and Welcome',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final currentLesson = sample.currentLesson;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        'act0_shell_progress_v1': jsonEncode(<String, Object>{
          'schemaVersion': 5,
          'completedTaskIds': <String>[],
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': sample.selectedWorldId,
          'selectedLessonId': currentLesson.lessonId,
          'selectedTaskId': currentLesson.taskList.first.taskId,
          'earnedXp': 0,
        }),
      });

      await pumpTall(tester, host(showPlacementOnStart: true));

      expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_placement_screen')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_primary_cta')),
        findsNothing,
      );
    },
  );

  testWidgets('Profile replay opens Welcome and keeps route progress intact', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final currentLesson = sample.currentLesson;
    final secondTask = currentLesson.taskList[1];
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 5,
        'completedTaskIds': <String>[currentLesson.taskList.first.taskId],
        'skippedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': sample.selectedWorldId,
        'selectedLessonId': currentLesson.lessonId,
        'selectedTaskId': secondTask.taskId,
        'earnedXp': 10,
      }),
    });

    await pumpTall(tester, host(showPlacementOnStart: true));
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_profile_replay_welcome')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_profile_replay_welcome')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_welcome_primary_cta')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);

    await tester.tap(find.byKey(const Key('act0_shell_welcome_close')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_profile_screen')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('act0_shell_progress_v1');
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect(decoded['selectedTaskId'], secondTask.taskId);
    expect(
      (decoded['completedTaskIds'] as List<dynamic>).cast<String>(),
      contains(currentLesson.taskList.first.taskId),
    );
  });

  testWidgets('Placement trial preview opens value-first premium sheet', (
    tester,
  ) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await answerPlacementQuestion(tester, 'new');
    await answerPlacementQuestionMulti(tester, <String>[
      'basics',
      'home_games',
    ]);
    await answerPlacementQuestion(tester, 'rules');
    await answerPlacementQuestion(tester, 'guided');
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_diagnostic')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_two_three_six')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_board')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_open_recommended_path')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_placement_trial_cta')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_premium_preview_sheet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_premium_preview_title')),
      findsOneWidget,
    );
    expect(find.text('Stay on free route'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_premium_preview_free_label')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_premium_preview_value_label')),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Premium only expands the work after Sharky has already shown value',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Home Continue opens runner', (tester) async {
    await pumpTall(tester, host());

    expect(find.byKey(const Key('act0_shell_home_cta_hint')), findsNothing);
    expect(find.text('Continue this lesson now.'), findsNothing);
    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
  });

  testWidgets('Home primary tap target opens runner', (tester) async {
    await pumpTall(tester, host());

    await tester.tap(
      find.byKey(const Key('act0_shell_home_primary_tap_target')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
  });

  testWidgets('Home shows Sharky cue and earned achievements', (tester) async {
    await pumpTall(tester, host());

    expect(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_daily_trust_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_footer_sharky_line')),
      findsOneWidget,
    );
    expect(find.textContaining('3 day streak'), findsOneWidget);
    expect(
      find.text('3 days running. One clean rep keeps the rhythm warm.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_repair_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_repair_panel')),
      findsOneWidget,
    );
    expect(find.text('First perfect drill'), findsNothing);
  });

  testWidgets('Learn tab auto-expands current lesson on first open', (
    tester,
  ) async {
    await pumpCompact(tester, host());

    await openBottomTabAndDrainV1(tester, 'Learn');

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_lesson_hub_steps')),
      findsOneWidget,
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
          )
          .dy,
      greaterThan(44),
    );
  });

  testWidgets('Learn tab CTA opens runner from expanded current lesson', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await openBottomTabAndDrainV1(tester, 'Learn');

    // Auto-expand should have opened the current lesson panel.
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_lesson_hub_steps')),
      findsOneWidget,
    );

    // The panel is in a sliver; tap its first step to open the task focus popup.
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_theory')),
    );
    await tester.pumpAndSettle();
    await openSelectedLessonFromLearn(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('Learn tab localizes current lesson task copy in Russian', (
    tester,
  ) async {
    await pumpTall(tester, host(locale: const Locale('ru')));

    await openBottomTabAndDrainV1(tester, 'Обучение');

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(find.text('Слова действий'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_theory')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Сначала закрепи четыре главных глагола: фолд, чек, колл и рейз.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('World 2 discipline lesson copy localizes through stable ids', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_2')
        .lessons
        .firstWhere((entry) => entry.lessonId == 'hand_discipline_buckets');
    final task = lesson.taskList.firstWhere(
      (entry) => entry.taskId == 'hand_discipline_buckets_intro',
    );

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(act0LocalizedLessonTitleV1(context, lesson)),
                Text(act0LocalizedTaskSummaryV1(context, task)),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Группы стартовых рук'), findsOneWidget);
    expect(
      find.text(
        'Перед действием сначала назови группу руки: премиум, сильная, средняя или мусор.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Learn tab opened directly shows expanded current lesson panel', (
    tester,
  ) async {
    // Navigating to Learn via bottom nav auto-expands the current lesson.
    await pumpTall(tester, host());
    await openBottomTabAndDrainV1(tester, 'Learn');

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_lesson_hub_steps')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Selected lesson panel keeps compact subtitle headroom and guidance strip',
    (tester) async {
      await pumpCompact(tester, host());
      await openBottomTabAndDrainV1(tester, 'Learn');

      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );

      final subtitle = tester.widget<Text>(
        find.byKey(const Key('act0_shell_selected_lesson_subtitle')),
      );
      expect(subtitle.maxLines, 2);
      expect(subtitle.overflow, TextOverflow.fade);
      expect((subtitle.data ?? '').isNotEmpty, isTrue);

      final guidance = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('act0_shell_selected_lesson_guidance')),
          matching: find.byType(Text),
        ),
      );
      expect(guidance.maxLines, 2);
      expect(guidance.overflow, TextOverflow.fade);
      expect((guidance.data ?? '').isNotEmpty, isTrue);
    },
  );

  testWidgets('Learn module header shows progress bar', (tester) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    expect(
      find.byKey(const Key('act0_shell_learn_progress_bar')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Expanded lesson panel shows primary CTA and tapping it launches runner',
    (tester) async {
      await pumpTall(tester, host());

      await openBottomTabAndDrainV1(tester, 'Learn');

      // Auto-expanded lesson panel must be visible.
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );

      // Primary CTA button must be visible on the expanded (non-locked) lesson.
      final ctaFinder = find.byKey(const Key('act0_shell_lesson_start_cta'));
      await tester.ensureVisible(ctaFinder);
      expect(ctaFinder, findsOneWidget);

      // Nested learn overlays can make pointer hit-testing brittle here.
      // Call the button directly so the contract stays focused on launch behavior.
      final ctaButton = tester.widget<ElevatedButton>(ctaFinder);
      ctaButton.onPressed!.call();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    },
  );

  testWidgets('Profile habit section shows streak nudge', (tester) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.profile));

    expect(find.byKey(const Key('act0_shell_profile_screen')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_streak_nudge')),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_profile_streak_nudge')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_profile_consistency_active_days')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_profile_streak_icon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_profile_momentum_line')),
      findsOneWidget,
    );
  });

  testWidgets('Current lesson starts the first incomplete task', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();

    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('Actions are table verbs.'), findsOneWidget);
    expect(find.text('Fold'), findsNothing);

    await completeVisibleTheoryTask(tester);

    expect(find.text('2/7'), findsWidgets);
    expect(find.text('Legality depends on price.'), findsOneWidget);
    expect(find.text('Check'), findsNothing);

    await tester.pump(const Duration(milliseconds: 900));
    await advanceRunnerUntil(
      tester,
      () => find.text('Check').evaluate().isNotEmpty,
      failureMessage: 'Second task did not reach its drill question.',
      maxTaps: 12,
    );

    expect(find.text('2/7'), findsOneWidget);
    expect(
      find.text('No bet faces you. Which action is legal and free?'),
      findsOneWidget,
    );
    expect(find.text('Check'), findsOneWidget);
  });

  testWidgets(
    'Active runner drill progress survives a fresh dev shell mount but lands on Home',
    (tester) async {
      await pumpTall(tester, host());

      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      expect(find.text('1/7'), findsOneWidget);

      await completeVisibleTheoryTask(tester);
      await advanceTeachingToDrill(tester);
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
      expect(
        find.text('No bet faces you. Which action is legal and free?'),
        findsOneWidget,
      );
      expect(find.text('Check'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await pumpTall(tester, host());

      expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
      expect(find.text('1/7'), findsNothing);

      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(find.text('2/7'), findsOneWidget);
    },
  );

  testWidgets('First beginner task starts with teaching before questions', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_What poker is')),
    );
    await tester.tap(find.byKey(const Key('act0_shell_lesson_What poker is')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_cta')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_what_poker_is_theory')),
    );
    await tester.pumpAndSettle();
    await openSelectedLessonFromLearn(tester);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text("We start with Hold'em cash."), findsOneWidget);
    expect(find.text('Which seat is the hero seat?'), findsNothing);
    expect(find.text('Top seat'), findsNothing);
    expect(find.text('Bottom seat'), findsNothing);

    await advanceRunnerUntil(
      tester,
      () => find.text('This is a poker table.').evaluate().isNotEmpty,
      failureMessage: 'Teaching did not advance to the next structured step.',
      maxTaps: 20,
    );
    expect(find.text('This is a poker table.'), findsOneWidget);

    await advanceRunnerUntil(
      tester,
      () => find.text('The goal is the pot.').evaluate().isNotEmpty,
      failureMessage:
          'Teaching did not advance to the next compact support step.',
      maxTaps: 12,
    );
    expect(find.text('The goal is the pot.'), findsOneWidget);
  });

  testWidgets('Drill options stay hidden until teaching is complete', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
    expect(find.text('Fold'), findsNothing);

    await advanceTeachingToDrill(tester);

    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
    expect(find.text('Fold'), findsOneWidget);
  });

  testWidgets('Sizing drills use family-aware runner prompt copy', (
    tester,
  ) async {
    final sizingTask = Act0ShellStateV1.sample
        .worldById('world_5')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'small_half_pot')
        .taskList
        .firstWhere((task) => task.taskId == 'w4_half_pot_bet');
    final drillReadyRunner = sizingTask.runner.copyWith(
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Act0LessonRunnerShellV1(
          runner: drillReadyRunner.copyWith(
            sizingConfig: Act0SizingConfigV1(
              mode: Act0SizingUiModeV1.presetsOnly,
              presets: const <Act0SizingPresetV1>[
                Act0SizingPresetV1(
                  id: 'two',
                  label: '2 BB',
                  displayLabel: 'One-third',
                  detailLabel: '2 BB',
                  ctaLabel: 'Lock One-third',
                  potFraction: 1 / 3,
                ),
                Act0SizingPresetV1(
                  id: 'three',
                  label: '3 BB',
                  displayLabel: 'Half-pot',
                  detailLabel: '3 BB',
                  ctaLabel: 'Lock Half-pot',
                  potFraction: 1 / 2,
                ),
                Act0SizingPresetV1(
                  id: 'six',
                  label: '6 BB',
                  displayLabel: 'Pot-size',
                  detailLabel: '6 BB',
                  ctaLabel: 'Lock Pot-size',
                  potFraction: 1,
                ),
              ],
            ),
          ),
          selectedTaskFamily: sizingTask.resolvedTaskFamily,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onSelectSizingPreset: (_) {},
          onConfirmSizingPreset: () {},
          onContinueReview: () {},
        ),
      ),
    );

    expect(find.text('Choose the best size'), findsWidgets);
    expect(find.text('Choose the best action'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_sizing_presets_label')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
    expect(find.text('Half-pot'), findsOneWidget);
    expect(find.text('3 BB'), findsOneWidget);
  });

  testWidgets(
    'World 5 sizing drills use presets-only control and confirm into review',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final world5 = sample.worldById('world_5');
      final sizingLesson = world5.lessons
          .firstWhere((lesson) => lesson.lessonId == 'small_half_pot')
          .copyWith(
            state: Act0LessonStateV1.current,
            isSelectable: true,
            isLocked: false,
            primaryCtaLabel: 'Open lesson',
          );
      final state = stateWithWorlds(
        selectedWorldId: 'world_5',
        worlds: <Act0WorldCardV1>[
          world5.copyWith(
            isSelectable: true,
            isLocked: false,
            lessons: <Act0LessonCardV1>[sizingLesson],
          ),
        ],
      );

      await pumpTall(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.theory,
          state: state,
        ),
      );

      await advanceTeachingToDrill(tester);

      expect(
        find.byKey(const Key('act0_shell_sizing_presets_label')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_sizing_confirm_cta')),
        findsOneWidget,
      );
      expect(find.text('Sizing'), findsOneWidget);
      expect(find.text('One-third'), findsOneWidget);
      expect(find.text('2 BB'), findsOneWidget);
      expect(find.text('Select one size'), findsOneWidget);

      await tester.tap(find.byKey(const Key('act0_shell_sizing_preset_two')));
      await tester.pumpAndSettle();

      expect(find.text('Lock One-third'), findsOneWidget);

      await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect(find.text('2 BB into 6 BB is one-third pot.'), findsOneWidget);
    },
  );

  testWidgets('Compare drills use family-aware runner prompt copy', (
    tester,
  ) async {
    final compareTask = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'showdown_winning')
        .taskList
        .firstWhere((task) => task.taskId == 'showdown_best_hand_drill');
    final drillReadyRunner = compareTask.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Act0LessonRunnerShellV1(
          runner: drillReadyRunner,
          selectedTaskFamily: compareTask.resolvedTaskFamily,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    expect(find.text('Choose the winning hand'), findsWidgets);
    expect(find.text('Choose the best action'), findsNothing);
  });

  testWidgets('Counting drills use family-aware runner prompt copy', (
    tester,
  ) async {
    final countingTask = Act0ShellStateV1.sample
        .worldById('world_7')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_combo_counts')
        .taskList
        .firstWhere((task) => task.taskId == 'w6_ak_combos');
    final drillReadyRunner = countingTask.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Act0LessonRunnerShellV1(
          runner: drillReadyRunner,
          selectedTaskFamily: countingTask.resolvedTaskFamily,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    expect(find.text('Choose the correct count'), findsWidgets);
    expect(find.text('Choose the best action'), findsNothing);
    expect(find.text('16 combos'), findsOneWidget);
  });

  testWidgets('Runner localizes active action prompt copy in Russian', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample.currentLesson.taskList.first;

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Act0LessonRunnerShellV1(
          runner: task.runner,
          selectedTaskId: task.taskId,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    final prompt = tester.widget<Text>(
      find.byKey(const Key('act0_shell_runner_prompt')),
    );
    final support = tester.widget<Text>(
      find.byKey(const Key('act0_shell_learning_rail_support_line')),
    );

    expect(prompt.data, 'Действия — это глаголы за столом.');
    expect(support.data, contains('Фолд уходит, а чек ждёт.'));
    expect(support.data, contains('Колл уравнивает цену'));
    expect(support.data, contains('рейз добавляет ещё'));
  });

  testWidgets(
    'Runner localizes action options and counting answers in Russian',
    (tester) async {
      final actionTask = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
          .taskList
          .firstWhere((task) => task.taskId == 'actions_raise_drill');
      final actionRunner = actionTask.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      );

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: actionRunner,
              selectedTaskId: actionTask.taskId,
              selectedTaskFamily: actionTask.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.text('Проверка спота'), findsOneWidget);
      expect(find.text('Пас'), findsOneWidget);
      expect(find.text('Колл'), findsOneWidget);
      expect(find.text('Рейз'), findsOneWidget);
      expect(find.text('Spot check'), findsNothing);
      expect(find.text('Fold'), findsNothing);
      expect(find.text('Call'), findsNothing);
      expect(find.text('Raise'), findsNothing);

      final countingTask = Act0ShellStateV1.sample
          .worldById('world_7')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'range_combo_counts')
          .taskList
          .firstWhere((task) => task.taskId == 'w6_ak_combos');
      final countingRunner = countingTask.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      );

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: countingRunner,
              selectedTaskId: countingTask.taskId,
              selectedTaskFamily: countingTask.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.text('16 комбинаций'), findsOneWidget);
      expect(find.text('12 комбинаций'), findsOneWidget);
      expect(find.text('6 комбинаций'), findsOneWidget);
      expect(find.text('16 combos'), findsNothing);
    },
  );

  testWidgets('Runner localizes early feedback labels in Russian', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
        .taskList
        .firstWhere((entry) => entry.taskId == 'actions_raise_drill');
    final reviewRunner = task.runner.copyWith(
      phase: Act0LessonPhaseV1.review,
      selectedOptionId: 'fold',
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: reviewRunner,
            selectedTaskId: task.taskId,
            selectedTaskFamily: task.resolvedTaskFamily,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Ты выбрал Пас'), findsOneWidget);
    expect(find.text('Лучший вариант: Рейз'), findsOneWidget);
    expect(
      find.text(
        'Когда до тебя все выбросили на баттоне, пас слишком легко отдаёт играбельный спот.',
      ),
      findsOneWidget,
    );
    expect(find.text('Limp is legal'), findsNothing);
    expect(find.text('You picked Fold'), findsNothing);
    expect(find.text('Better option: Raise'), findsNothing);
  });

  testWidgets(
    'Runner fallback reaction lines stay Russian when authored cue is empty',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
          .taskList
          .firstWhere((entry) => entry.taskId == 'actions_raise_drill');
      final reviewRunner = task.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: 'fold',
        teachingSteps: const <Act0TeachingStepV1>[],
        sharky: task.runner.sharky.copyWith(wrongReaction: ''),
      );

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: reviewRunner,
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      final reaction = tester.widget<Text>(
        find.byKey(const Key('act0_shell_sharky_outcome_reaction')),
      );
      expect(reaction.data, isNotNull);
      expect(
        <String>{
          'Полезный разбор.',
          'Замедлись и проверь подсказку.',
          'Ещё одно чистое перечитывание.',
          'Это легко починить.',
          'Вернись к столу и попробуй снова.',
          'Одна спокойная попытка ещё раз.',
        }.contains(reaction.data),
        isTrue,
      );
      expect(find.textContaining('Sharp read'), findsNothing);
      expect(find.textContaining('Good spot to fix'), findsNothing);
    },
  );

  testWidgets(
    'Coach voice helpers stay deterministic and vary by safe context',
    (tester) async {
      await pumpTall(
        tester,
        MaterialApp(
          home: Builder(
            builder: (context) {
              final sameA = act0RuntimeFeedbackCoachLineV1(
                context,
                authoredLine: 'Sharp read.',
                title: 'Correct read',
                quality: Act0FeedbackQualityV1.correct,
                variationSeed: 'review|same',
                taskFamily: Act0TaskFamilyV1.review,
              );
              final sameB = act0RuntimeFeedbackCoachLineV1(
                context,
                authoredLine: 'Sharp read.',
                title: 'Correct read',
                quality: Act0FeedbackQualityV1.correct,
                variationSeed: 'review|same',
                taskFamily: Act0TaskFamilyV1.review,
              );
              final variedA = act0RuntimeFeedbackCoachLineV1(
                context,
                authoredLine: 'Good spot to fix.',
                title: 'Read the spot first',
                quality: Act0FeedbackQualityV1.wrong,
                variationSeed: 'wrong|a',
                taskFamily: Act0TaskFamilyV1.repair,
              );
              final variedB = act0RuntimeFeedbackCoachLineV1(
                context,
                authoredLine: 'Good spot to fix.',
                title: 'Read the spot first',
                quality: Act0FeedbackQualityV1.wrong,
                variationSeed: 'wrong|b',
                taskFamily: Act0TaskFamilyV1.repair,
              );
              return Column(
                children: <Widget>[
                  Text(sameA, key: const Key('coach_voice_same_a')),
                  Text(sameB, key: const Key('coach_voice_same_b')),
                  Text(variedA, key: const Key('coach_voice_varied_a')),
                  Text(variedB, key: const Key('coach_voice_varied_b')),
                ],
              );
            },
          ),
        ),
      );

      final sameA = tester.widget<Text>(
        find.byKey(const Key('coach_voice_same_a')),
      );
      final sameB = tester.widget<Text>(
        find.byKey(const Key('coach_voice_same_b')),
      );
      final variedA = tester.widget<Text>(
        find.byKey(const Key('coach_voice_varied_a')),
      );
      final variedB = tester.widget<Text>(
        find.byKey(const Key('coach_voice_varied_b')),
      );

      expect(sameA.data, sameB.data);
      expect(variedA.data, isNot(variedB.data));
      expect(variedA.data!.toLowerCase().contains('failed'), isFalse);
      expect(variedA.data!.toLowerCase().contains('shame'), isFalse);
      expect(variedB.data!.toLowerCase().contains('failed'), isFalse);
      expect(variedB.data!.toLowerCase().contains('shame'), isFalse);
    },
  );

  testWidgets(
    'Prompt coach line stays process-first and does not leak answers',
    (tester) async {
      await pumpTall(
        tester,
        MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: <Widget>[
                Text(
                  act0RuntimePromptCoachLineV1(
                    context,
                    lessonId: 'bucket_lesson',
                    beatIndex: 3,
                    question: 'Which bucket is JJ?',
                    taskFamily: Act0TaskFamilyV1.recognition,
                    hasSeatTargets: false,
                    isTrailHistory: false,
                  ),
                  key: const Key('coach_voice_bucket_prompt'),
                ),
                Text(
                  act0RuntimePromptCoachLineV1(
                    context,
                    lessonId: 'seat_lesson',
                    beatIndex: 2,
                    question: 'Which seat is the hero seat?',
                    taskFamily: Act0TaskFamilyV1.recognition,
                    hasSeatTargets: true,
                    isTrailHistory: false,
                  ),
                  key: const Key('coach_voice_seat_prompt'),
                ),
              ],
            ),
          ),
        ),
      );

      final bucketLine = tester.widget<Text>(
        find.byKey(const Key('coach_voice_bucket_prompt')),
      );
      final seatLine = tester.widget<Text>(
        find.byKey(const Key('coach_voice_seat_prompt')),
      );

      expect(bucketLine.data!.toLowerCase().contains('strong'), isFalse);
      expect(bucketLine.data!.toLowerCase().contains('premium'), isFalse);
      expect(bucketLine.data!.toLowerCase().contains('medium'), isFalse);
      expect(seatLine.data!.toLowerCase().contains('big blind'), isFalse);
      expect(
        <String>{
          'Read the table, then tap one seat.',
          'Find the seat, then choose.',
          'One clean read, then tap.',
        }.contains(seatLine.data),
        isTrue,
      );
    },
  );

  testWidgets('Runtime surface helper localizes repeated families in Russian', (
    tester,
  ) async {
    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => ListView(
            children: <Widget>[
              Text(
                act0RuntimeLocalizedGeneralLabelV1(context, '16 combos'),
                key: const Key('runtime_probe_combos'),
              ),
              Text(
                act0RuntimeLocalizedGeneralLabelV1(
                  context,
                  '18 BB effective stack',
                ),
                key: const Key('runtime_probe_effective_stack'),
              ),
              Text(
                act0RuntimeLocalizedGeneralLabelV1(
                  context,
                  '2 private cards, 3 board cards, 6 BB in the pot',
                ),
                key: const Key('runtime_probe_table_read'),
              ),
              Text(
                act0RuntimeLocalizedGeneralLabelV1(context, '6-max'),
                key: const Key('runtime_probe_max_players'),
              ),
              Text(
                act0RuntimeLocalizedActionTrailLabelV1(
                  context,
                  'BB calls 3 BB',
                ),
                key: const Key('runtime_probe_calls'),
              ),
              Text(
                act0RuntimeLocalizedActionTrailLabelV1(
                  context,
                  'Flop: BB checks',
                ),
                key: const Key('runtime_probe_flop_checks'),
              ),
              Text(
                act0RuntimeLocalizedGeneralLabelV1(
                  context,
                  'Widen late steals slightly',
                ),
                key: const Key('runtime_probe_widen'),
              ),
              Text(
                act0RuntimeLocalizedGeneralLabelV1(context, 'Bet half-pot'),
                key: const Key('runtime_probe_half_pot'),
              ),
              Text(
                act0RuntimeLocalizedGeneralLabelV1(context, 'Facing an open'),
                key: const Key('runtime_probe_facing_open'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('runtime_probe_combos'))).data,
      '16 комбинаций',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('runtime_probe_effective_stack')))
          .data,
      'Эффективный стек 18 BB',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('runtime_probe_table_read')))
          .data,
      '2 закрытые карты, 3 общие карты, в банке 6 BB',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('runtime_probe_max_players')))
          .data,
      '6-макс',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('runtime_probe_calls'))).data,
      'BB коллирует 3 BB',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('runtime_probe_flop_checks')))
          .data,
      'Флоп: BB чекает',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('runtime_probe_widen'))).data,
      'Чуть шире крадём из поздней позиции',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('runtime_probe_half_pot'))).data,
      'Ставь полбанка',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('runtime_probe_facing_open')))
          .data,
      'Перед тобой уже было открытие',
    );
    expect(find.text('16 combos'), findsNothing);
    expect(find.text('18 BB effective stack'), findsNothing);
    expect(
      find.text('2 private cards, 3 board cards, 6 BB in the pot'),
      findsNothing,
    );
    expect(find.text('6-max'), findsNothing);
    expect(find.text('BB calls 3 BB'), findsNothing);
    expect(find.text('Flop: BB checks'), findsNothing);
    expect(find.text('Widen late steals slightly'), findsNothing);
    expect(find.text('Bet half-pot'), findsNothing);
    expect(find.text('Facing an open'), findsNothing);
  });

  testWidgets('Runner localizes World 2 discipline prompt copy in Russian', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_2')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_apply')
        .taskList
        .firstWhere((entry) => entry.taskId == 'apply_intro');

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Act0LessonRunnerShellV1(
          runner: task.runner,
          selectedTaskId: task.taskId,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    final prompt = tester.widget<Text>(
      find.byKey(const Key('act0_shell_runner_prompt')),
    );
    final support = tester.widget<Text>(
      find.byKey(const Key('act0_shell_learning_rail_support_line')),
    );

    expect(prompt.data, 'Группа руки, место, ситуация.');
    expect(
      support.data,
      contains('Сначала назови группу руки и посмотри на место.'),
    );
    expect(support.data, contains('Затем прочитай ситуацию за столом.'));
  });

  testWidgets('Runner localizes World 2 discipline question copy in Russian', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_2')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_buckets')
        .taskList
        .firstWhere(
          (entry) => entry.taskId == 'hand_discipline_buckets_premium',
        );
    final drillReadyRunner = task.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Act0LessonRunnerShellV1(
          runner: drillReadyRunner,
          selectedTaskId: task.taskId,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('act0_shell_action_question')), findsOneWidget);
    expect(find.text('Какая группа у АА?'), findsOneWidget);
  });

  testWidgets(
    'Bucket active prompt neutralizes premium answer-bearing table cue',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_2')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_buckets')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'hand_discipline_buckets_premium',
          );
      final runner = task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: task.taskId,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.text('Which bucket is AA?'), findsOneWidget);
      expect(find.text('Premium bucket'), findsNothing);
      expect(find.text('Bucket check'), findsOneWidget);
    },
  );

  testWidgets(
    'Bucket active prompt neutralizes strong answer-bearing table cue',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_2')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_buckets')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'hand_discipline_buckets_strong',
          );
      final runner = task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: task.taskId,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.text('Which bucket is JJ?'), findsOneWidget);
      expect(find.text('Strong bucket'), findsNothing);
      expect(find.text('Bucket check'), findsOneWidget);
      expect(find.text('PREFLOP'), findsOneWidget);
    },
  );

  testWidgets('Bucket feedback can restore the revealed answer-bearing cue', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_2')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_buckets')
        .taskList
        .firstWhere(
          (entry) => entry.taskId == 'hand_discipline_buckets_strong',
        );
    final runner = task.runner.copyWith(
      phase: Act0LessonPhaseV1.review,
      selectedOptionId: 'strong',
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            selectedTaskId: task.taskId,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_center_focus_badge')),
        matching: find.text('Strong bucket'),
      ),
      findsOneWidget,
    );
    expect(find.text('Bucket check'), findsNothing);
  });

  testWidgets('Leading decision cue is neutralized during active prompt', (
    tester,
  ) async {
    final runner = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .firstWhere(
          (entry) => entry.runner.table.centerLabel == 'Weak continue?',
        )
        .runner
        .copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.text('Weak continue?'), findsNothing);
    expect(find.text('Facing CO 2.5 BB'), findsOneWidget);
    expect(find.text('Decision spot'), findsOneWidget);
    expect(find.text('Pot 4 BB'), findsOneWidget);
    expect(find.text('To call 2.5 BB'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_action_context_line')),
      findsOneWidget,
    );
  });

  testWidgets('Non-answer table context remains visible during active prompt', (
    tester,
  ) async {
    final runner = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .firstWhere(
          (entry) => entry.runner.caption.contains('Hero is BTN with KQo'),
        )
        .runner
        .copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.text('CO opened'), findsOneWidget);
    expect(find.text('Bucket check'), findsNothing);
    expect(find.text('Pot 4 BB'), findsOneWidget);
    expect(find.text('To call 2.5 BB'), findsOneWidget);
  });

  testWidgets(
    'Decision prompt does not fake facing context when no safe actor source exists',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        question: 'What should Hero do here?',
        teachingSteps: const <Act0TeachingStepV1>[],
        options: const <Act0RunnerOptionV1>[
          Act0RunnerOptionV1(
            id: 'fold',
            label: 'Fold',
            preferredLabel: 'Fold',
            isCorrect: false,
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Not this time.',
            feedbackReason: 'Folding gives up too much equity here.',
          ),
          Act0RunnerOptionV1(
            id: 'call',
            label: 'Call',
            preferredLabel: 'Call',
            isCorrect: true,
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Keep going.',
            feedbackReason: 'Calling keeps the price in line.',
          ),
        ],
        table: Act0ShellStateV1.sample.currentLesson.runner.table.copyWith(
          centerLabel: 'Call spot?',
          potLabel: 'Pot 5 BB',
          toCallLabel: 'To call 2 BB',
          actionTrail: const <Act0ActionTrailItemV1>[
            Act0ActionTrailItemV1(label: 'Preflop action'),
          ],
        ),
      );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskFamily: Act0TaskFamilyV1.decision,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.text('Call spot?'), findsNothing);
      expect(find.text('Pot 5 BB'), findsOneWidget);
      expect(find.text('To call 2 BB'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_action_context_line')),
        findsNothing,
      );
      expect(find.textContaining('Facing '), findsNothing);
    },
  );

  testWidgets('Runner localizes seat-tap table chrome in Russian', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'blinds_action_order')
        .taskList
        .firstWhere((entry) => entry.taskId == 'blinds_first_actor');
    final runner = task.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingSteps: const <Act0TeachingStepV1>[],
    );

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            selectedTaskId: task.taskId,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.text('Нажми на правильное место'), findsOneWidget);
    expect(
      find.text('Сначала прочитай стол, потом нажми на одно место.'),
      findsOneWidget,
    );
    expect(find.text('Блайнды поставлены'), findsNothing);
    expect(find.text('Банк 1.5 BB'), findsOneWidget);
    expect(find.text('Ход: 1 BB'), findsNothing);
    expect(find.text('SB блайнд 0.5 BB'), findsNothing);
    expect(find.text('BB блайнд 1 BB'), findsNothing);
    expect(find.byKey(const Key('act0_shell_bet_chip_SB')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bet_chip_BB')), findsOneWidget);
    expect(find.text('Tap the correct seat'), findsNothing);
    expect(find.text('Read the table, then tap one seat.'), findsNothing);
    expect(find.text('Blinds posted'), findsNothing);
    expect(find.text('Pot 1.5 BB'), findsNothing);
    expect(find.text('To act - 1 BB'), findsNothing);
  });

  testWidgets(
    'Runner Russian table chrome keeps seat prompt and trail labels out of ellipsis mode',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'blinds_action_order')
          .taskList
          .firstWhere((entry) => entry.taskId == 'blinds_first_actor');
      final runner = task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      );

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: task.taskId,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      final taskLabel = tester.widget<Text>(
        find.byKey(const Key('act0_shell_seat_tap_task_label')),
      );
      final helperLabel = tester.widget<Text>(
        find.byKey(const Key('act0_shell_seat_tap_prompt_text')),
      );
      final trailLabel = tester.widget<Text>(
        find.byKey(const Key('act0_shell_action_trail_step_label_0')),
      );

      expect(taskLabel.overflow, isNot(TextOverflow.ellipsis));
      expect(helperLabel.overflow, isNot(TextOverflow.ellipsis));
      expect(trailLabel.overflow, isNot(TextOverflow.ellipsis));
    },
  );

  testWidgets('World 1 table-read runner copy localizes through stable ids', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
        .taskList
        .firstWhere(
          (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
        );
    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Column(
            children: <Widget>[
              Text(act0LocalizedTaskTitleV1(context, task)),
              Text(
                act0LocalizedRunnerPromptAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.caption,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
              Text(
                act0LocalizedRunnerQuestionAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.question,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Первое чтение живого стола'), findsOneWidget);
    expect(
      find.text(
        'Сначала посмотри на свои карты, потом на борд, потом на банк.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('С чего лучше начать быстрое чтение стола?'),
      findsOneWidget,
    );
  });

  testWidgets(
    'World 1 teaching steps switch Russian copy instead of freezing one task line',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere((entry) => entry.taskId == 'what_poker_is_theory');

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(
              teachingStepIndex: 0,
              selectedOptionId: null,
              phase: Act0LessonPhaseV1.theory,
            ),
            selectedTaskId: task.taskId,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onPreviousTheory: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      );

      expect(find.text('Начинаем с кэш-игры в холдем.'), findsOneWidget);
      expect(
        find.textContaining('2 закрытые карты', findRichText: true),
        findsOneWidget,
      );

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(
              teachingStepIndex: 1,
              selectedOptionId: null,
              phase: Act0LessonPhaseV1.theory,
            ),
            selectedTaskId: task.taskId,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onPreviousTheory: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      );

      final prompt = tester.widget<Text>(
        find.byKey(const Key('act0_shell_runner_prompt')),
      );
      final support = tester.widget<Text>(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );

      expect(prompt.data, 'Перед тобой покерный стол.');
      expect(support.data, contains('Ты играешь за нижнее место.'));
      expect(support.data, contains('Остальные места за столом'));
      expect(find.text('Начинаем с кэш-игры в холдем.'), findsNothing);
    },
  );

  testWidgets('World 3 position-apply lesson localizes through stable ids', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_3')
        .lessons
        .firstWhere((entry) => entry.lessonId == 'position_apply');
    final task = lesson.taskList.firstWhere(
      (entry) => entry.taskId == 'position_apply_intro',
    );

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Column(
            children: <Widget>[
              Text(act0LocalizedLessonTitleV1(context, lesson)),
              Text(act0LocalizedTaskTitleV1(context, task)),
              Text(
                act0LocalizedRunnerQuestionAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.question,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Позиция за столом'), findsOneWidget);
    expect(find.text('Позиция меняет решение'), findsOneWidget);
    expect(find.text('Почему позиция так важна за столом?'), findsOneWidget);
    expect(find.text('Position at the table'), findsNothing);
  });

  test(
    'RU active beginner slice keeps explicit learner copy through W1 to W3',
    () {
      final missingRows = _ruLearnerSurfaceCoverageRowsV1()
          .where(
            (row) =>
                row.worldId == 'world_1' ||
                row.worldId == 'world_2' ||
                row.worldId == 'world_3',
          )
          .where(
            (row) =>
                !row.hasRuLesson || (row.taskId != null && !row.hasRuTaskTitle),
          )
          .map(_formatRuCoverageRowV1)
          .toList(growable: false);

      expect(
        missingRows,
        isEmpty,
        reason:
            'Active RU W1-W3 learner surfaces should not fall back to English.\n${missingRows.join('\n')}',
      );
    },
  );

  test(
    'RU coverage report keeps W4 to W12 fallback explicit instead of silent',
    () {
      final fallbackRows = _ruLearnerSurfaceCoverageRowsV1()
          .where(
            (row) =>
                row.worldId != 'world_1' &&
                row.worldId != 'world_2' &&
                row.worldId != 'world_3',
          )
          .where(
            (row) =>
                row.taskId != null && (!row.hasRuLesson || !row.hasRuTaskTitle),
          )
          .toList(growable: false);

      expect(
        fallbackRows,
        isNotEmpty,
        reason:
            'Unsupported later worlds should stay visibly fallback-backed until a separate translation wave lands.',
      );
      expect(
        fallbackRows.map((row) => row.worldId).toSet(),
        equals(<String>{
          'world_4',
          'world_5',
          'world_6',
          'world_7',
          'world_8',
          'world_9',
          'world_10',
          'world_11',
          'world_12',
        }),
      );
      expect(
        fallbackRows.any((row) => row.worldId == 'world_4'),
        isTrue,
        reason:
            'World 4 should remain explicit fallback in RU after this slice-only wave.',
      );
    },
  );

  testWidgets(
    'Runner localizes newly covered W2 fold discipline copy in Russian',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_2')
          .lessons
          .firstWhere((entry) => entry.lessonId == 'fold_discipline');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'fold_discipline_early_fold',
      );

      await pumpTall(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Column(
              children: <Widget>[
                Text(act0LocalizedLessonTitleV1(context, lesson)),
                Text(act0LocalizedTaskTitleV1(context, task)),
                Text(
                  act0LocalizedRunnerPromptAtomByTaskIdV1(
                    task.taskId,
                    fallback: task.runner.caption,
                    isRu: act0IsRuLocaleV1(context),
                  ),
                ),
                Text(
                  act0LocalizedRunnerQuestionAtomByTaskIdV1(
                    task.taskId,
                    fallback: task.runner.question,
                    isRu: act0IsRuLocaleV1(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Дисциплина фолда'), findsOneWidget);
      expect(find.text('Слабая рука рано'), findsOneWidget);
      expect(
        find.text('Банк не открыт. Hero в ранней позиции с J8o.'),
        findsOneWidget,
      );
      expect(find.text('Какое действие здесь самое чистое?'), findsOneWidget);
    },
  );

  testWidgets('World 1 positions residue localizes through stable ids', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'positions')
        .taskList
        .firstWhere((entry) => entry.taskId == 'positions_review');

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Column(
            children: <Widget>[
              Text(act0LocalizedTaskTitleV1(context, task)),
              Text(
                act0LocalizedRunnerPromptAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.caption,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
              Text(
                act0LocalizedRunnerQuestionAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.question,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Повтор по позициям'), findsOneWidget);
    expect(
      find.text(
        'Главная мысль проста: позиция меняет не силу карты, а удобство решения.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Какое место здесь действует позже остальных после флопа?'),
      findsOneWidget,
    );
  });

  test('World 1 position seat drills keep seat affordances aligned', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((entry) => entry.lessonId == 'positions');

    final seatDrillTasks = lesson.taskList
        .where((task) {
          return task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.any((option) => option.seatId != null);
        })
        .toList(growable: false);

    expect(seatDrillTasks, isNotEmpty);

    for (final task in seatDrillTasks) {
      final seatOptions = task.runner.options
          .where((option) => option.seatId != null)
          .toList(growable: false);
      final correctOptions = seatOptions
          .where((option) => option.isCorrect)
          .toList(growable: false);

      expect(
        correctOptions,
        hasLength(1),
        reason: 'Expected exactly one correct seat option in ${task.taskId}',
      );

      final correctSeatId = correctOptions.single.seatId!;
      final optionSeatIds = seatOptions.map((option) => option.seatId!).toSet();

      expect(
        task.runner.table.selectableSeatIds.toSet(),
        optionSeatIds,
        reason:
            'Selectable seats must match authored seat options in ${task.taskId}',
      );
      expect(
        task.runner.table.activeSeatId,
        correctSeatId,
        reason:
            'Active seat must point at the correct answer in ${task.taskId}',
      );
      expect(
        task.runner.table.highlightedSeatIds,
        contains(correctSeatId),
        reason:
            'Highlighted seats must include the correct answer in ${task.taskId}',
      );
    }
  });

  test('All Act0 task seat references resolve after runtime normalization', () {
    final state = Act0ShellStateV1.sample;

    for (final world in state.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final runner = normalizeAct0DrillSeatHighlightPolicyV1(
            normalizeAct0SeatTapRunnerV1(
              task.runner.copyWith(phase: task.phase),
            ),
          );
          final tableSeatIds = runner.table.seats
              .map((seat) => seat.seatId)
              .where((seatId) => seatId.trim().isNotEmpty)
              .toSet();

          expect(
            tableSeatIds,
            isNotEmpty,
            reason: 'Expected at least one seat in ${task.taskId}',
          );

          final activeSeatId = (runner.table.activeSeatId ?? '').trim();
          if (activeSeatId.isNotEmpty) {
            expect(
              tableSeatIds.contains(activeSeatId),
              isTrue,
              reason: 'Unknown activeSeatId in ${task.taskId}',
            );
          }

          if (task.phase == Act0LessonPhaseV1.drill) {
            expect(
              runner.table.highlightedSeatIds,
              activeSeatId.isEmpty ? isEmpty : <String>[activeSeatId],
              reason:
                  'Drill seat highlights must match the active seat in ${task.taskId}',
            );
          }

          final heroSeatId = (runner.table.heroSeatId ?? '').trim();
          if (heroSeatId.isNotEmpty) {
            expect(
              tableSeatIds.contains(heroSeatId),
              isTrue,
              reason: 'Unknown heroSeatId in ${task.taskId}',
            );
          }

          expect(
            runner.table.highlightedSeatIds.every(tableSeatIds.contains),
            isTrue,
            reason: 'Unknown highlighted seat id in ${task.taskId}',
          );
          expect(
            runner.table.selectableSeatIds.every(tableSeatIds.contains),
            isTrue,
            reason: 'Unknown selectable seat id in ${task.taskId}',
          );

          for (final option in runner.options) {
            final seatId = (option.seatId ?? '').trim();
            if (seatId.isNotEmpty) {
              expect(
                tableSeatIds.contains(seatId),
                isTrue,
                reason: 'Unknown option seat id in ${task.taskId}',
              );
            }
            expect(
              option.repairFocusSeatIds.every(tableSeatIds.contains),
              isTrue,
              reason: 'Unknown repair focus seat id in ${task.taskId}',
            );
          }

          for (final step in runner.teachingSteps) {
            final stepSeatIds = (step.table ?? runner.table).seats
                .map((seat) => seat.seatId)
                .where((seatId) => seatId.trim().isNotEmpty)
                .toSet();
            expect(
              step.focusSeatIds.every(stepSeatIds.contains),
              isTrue,
              reason: 'Unknown teaching focus seat id in ${task.taskId}',
            );
          }
        }
      }
    }
  });

  testWidgets('Seat target flags do not create stale drill gold rings', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'positions')
        .taskList
        .firstWhere((entry) => entry.taskId == 'positions_utg');

    final runner = normalizeAct0SeatTapRunnerV1(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingStepIndex: task.runner.teachingSteps.length,
      ),
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onChooseSeat: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_utg')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_btn')),
      findsNothing,
    );
  });

  testWidgets('World 1 showdown residue localizes through stable ids', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'showdown_winning')
        .taskList
        .firstWhere((entry) => entry.taskId == 'showdown_kicker_drill');

    await pumpTall(
      tester,
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Column(
            children: <Widget>[
              Text(act0LocalizedTaskTitleV1(context, task)),
              Text(
                act0LocalizedRunnerSupportAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.hint,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
              Text(
                act0LocalizedRunnerQuestionAtomByTaskIdV1(
                  task.taskId,
                  fallback: task.runner.question,
                  isRu: act0IsRuLocaleV1(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Та же пара, лучший кикер'), findsOneWidget);
    expect(
      find.text(
        'Эта боковая карта называется кикером. Она часто ломает кажущуюся ничью.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Что может разбить ничью при одинаковой паре?'),
      findsOneWidget,
    );
  });

  test(
    'Act0 language bundle normalizes locale codes and falls back safely',
    () {
      expect(
        act0LocalizedTaskTitleAtomByLanguageV1(
          'what_poker_is_table_read_transfer',
          fallback: 'Real-table first read',
          languageCode: 'ru-RU',
        ),
        'Первое чтение живого стола',
      );
      expect(
        act0LocalizedTaskTitleAtomByLanguageV1(
          'what_poker_is_table_read_transfer',
          fallback: 'Real-table first read',
          languageCode: 'es',
        ),
        'Real-table first read',
      );
    },
  );

  testWidgets(
    'Home launch-path copy keeps two-line safety in compact Russian',
    (tester) async {
      await pumpCompact(tester, host(locale: const Locale('ru')));

      final subtitle = tester.widget<Text>(
        find.byKey(const Key('act0_shell_home_next_action_subtitle')),
      );

      expect(subtitle.maxLines, 2);
      expect((subtitle.data ?? '').isNotEmpty, isTrue);
      expect(
        find.byKey(const Key('act0_shell_home_optional_practice_hint')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Home support copy prefers wrapped density over hard truncation',
    (tester) async {
      await pumpCompact(tester, host(locale: const Locale('ru')));

      final subtitle = tester.widget<Text>(
        find.byKey(const Key('act0_shell_home_next_action_subtitle')),
      );
      final dailySupport = tester.widget<Text>(
        find.byKey(const Key('act0_shell_home_daily_support_line')),
      );

      expect(subtitle.overflow, TextOverflow.fade);
      expect(
        find.byKey(const Key('act0_shell_home_optional_practice_hint')),
        findsNothing,
      );
      expect(dailySupport.maxLines, 2);
      expect(dailySupport.overflow, TextOverflow.fade);
    },
  );

  testWidgets('Home repair panel keeps multi-line density for long copy', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0HomeShellV1(
            state: Act0ShellStateV1.sample,
            repairLabel: 'Fix next',
            repairHeadline:
                'Action order drifted after the first read and needs a calmer second pass.',
            repairDetail:
                'Last miss came from Actions. Rebuild the sequence before you add more volume.',
            repairOutcome:
                'One fix now keeps the leak from following you forward into the next block.',
            repairCtaLabel: 'Fix it',
            onStartRepair: () {},
            onContinue: () {},
          ),
        ),
      ),
    );

    final headline = tester.widget<Text>(
      find.byKey(const Key('act0_shell_home_repair_headline')),
    );
    final detail = tester.widget<Text>(
      find.byKey(const Key('act0_shell_home_repair_detail')),
    );
    final outcome = tester.widget<Text>(
      find.byKey(const Key('act0_shell_home_repair_outcome')),
    );

    expect(headline.maxLines, 3);
    expect(headline.overflow, TextOverflow.fade);
    expect(detail.maxLines, 3);
    expect(detail.overflow, TextOverflow.fade);
    expect(outcome.maxLines, 3);
    expect(outcome.overflow, TextOverflow.fade);
  });

  testWidgets('Learn task titles allow two-line safety in compact Russian', (
    tester,
  ) async {
    await pumpCompact(tester, host(locale: const Locale('ru')));

    await tester.tap(find.text('Обучение'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(
      find.byKey(const Key('act0_shell_lesson_step_title_actions_theory')),
    );
    expect(title.maxLines, 2);
    expect(title.data, 'Слова действий');
  });

  testWidgets(
    'Runner compact Russian copy keeps extra prompt and support headroom',
    (tester) async {
      final task = Act0ShellStateV1.sample.currentLesson.taskList.first;

      await pumpCompact(
        tester,
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0LessonRunnerShellV1(
            runner: task.runner,
            selectedTaskId: task.taskId,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      );

      final prompt = tester.widget<Text>(
        find.byKey(const Key('act0_shell_runner_prompt')),
      );
      final support = tester.widget<Text>(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );

      expect(prompt.maxLines, 2);
      expect(prompt.overflow, TextOverflow.fade);
      expect(support.maxLines, 2);
      expect(support.overflow, TextOverflow.fade);
      expect(
        find.byKey(const Key('act0_shell_learning_rail_support_scroll')),
        findsNothing,
      );
      expect(prompt.data, 'Действия — это глаголы за столом.');
      expect(support.data, contains('Фолд уходит, а чек ждёт.'));
      expect(support.data, contains('Колл уравнивает цену'));
      expect(support.data, contains('рейз добавляет ещё'));
    },
  );

  testWidgets(
    'Learning rail segments long teaching support instead of scrolling it',
    (tester) async {
      final baseTask = Act0ShellStateV1.sample.currentLesson.taskList.first;
      final runner = baseTask.runner.copyWith(
        phase: Act0LessonPhaseV1.theory,
        teachingSteps: const <Act0TeachingStepV1>[
          Act0TeachingStepV1(
            title: 'Read the table first',
            body:
                'Each player gets 2 private hole cards. The table shares 5 community cards. You build the best 5-card hand from those 7. This course starts with No-Limit Hold\'em cash, where chip values stay stable hand to hand.',
          ),
        ],
        teachingStepIndex: 0,
      );
      var continueCalls = 0;

      await pumpCompact(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: baseTask.taskId,
              onBack: () {},
              onContinueTheory: () => continueCalls++,
              onChooseOption: (_) {},
              onContinueReview: () {},
              relaxTheoryAdvanceLock: true,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_learning_rail_support_scroll')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_learning_rail_support_dots')),
        findsOneWidget,
      );

      final firstSupport = tester.widget<Text>(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );
      expect(firstSupport.maxLines, 2);
      expect(firstSupport.overflow, TextOverflow.fade);
      expect(
        firstSupport.data,
        contains('Each player gets 2 private hole cards.'),
      );
      expect(
        firstSupport.data,
        contains('The table shares 5 community cards.'),
      );

      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();

      expect(continueCalls, 0);

      final secondSupport = tester.widget<Text>(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );
      expect(secondSupport.maxLines, 2);
      expect(secondSupport.overflow, TextOverflow.fade);
      expect(
        secondSupport.data,
        contains('You build the best 5-card hand from those 7.'),
      );

      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();

      expect(continueCalls, 0);

      final thirdSupport = tester.widget<Text>(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );
      expect(thirdSupport.maxLines, 2);
      expect(thirdSupport.overflow, TextOverflow.fade);
      expect(
        thirdSupport.data,
        contains('This course starts with No-Limit Hold\'em cash'),
      );

      await advanceRunnerUntil(
        tester,
        () => continueCalls == 1,
        failureMessage:
            'Learning rail did not hand control back after the final support segment.',
        maxTaps: 8,
      );
      expect(continueCalls, 1);
    },
  );

  testWidgets(
    'Compact theory rail gives prompt and support two-line readability without overflow',
    (tester) async {
      final baseTask = Act0ShellStateV1.sample.currentLesson.taskList.first;
      final runner = baseTask.runner.copyWith(
        phase: Act0LessonPhaseV1.theory,
        teachingSteps: const <Act0TeachingStepV1>[
          Act0TeachingStepV1(
            title: 'Read the table first before you name the action.',
            body:
                'The support line explains why the action word matters before you continue to the next teaching beat.',
          ),
        ],
        teachingStepIndex: 0,
      );

      await pumpCompact(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: baseTask.taskId,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final prompt = tester.widget<Text>(
        find.byKey(const Key('act0_shell_runner_prompt')),
      );
      final support = tester.widget<Text>(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );
      final railRect = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final ctaRect = tester.getRect(
        find.byKey(const Key('act0_shell_continue_cta')),
      );

      expect(prompt.maxLines, 2);
      expect(prompt.overflow, TextOverflow.fade);
      expect(support.maxLines, 2);
      expect(support.overflow, TextOverflow.fade);
      expect(railRect.height, lessThanOrEqualTo(146));
      expect(tableRect.overlaps(ctaRect), isFalse);
      expect(ctaRect.bottom, lessThanOrEqualTo(812));
    },
  );

  testWidgets(
    'Play repair empty state localizes and keeps two-line safety in Russian',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Act0PlayShellV1(
              groups: const <Act0PracticeGroupV1>[
                Act0PracticeGroupV1(
                  groupId: 'weak_spots',
                  title: 'Repair one leak',
                  subtitle: 'Repair lane',
                  ctaLabel: 'Fix now',
                  categoryLabel: 'Repair',
                  isEnabled: false,
                ),
              ],
              recommendedGroupId: 'weak_spots',
              recommendedTitle: 'Best next action',
              recommendedSubtitle: 'One disabled group for copy truth.',
              recommendedReasonLabel: 'Why this next',
              recommendedOutcome: 'Keeps the route honest.',
              recommendedOutcomeLead: 'This next run',
              masteryLabel: 'Route step',
              onStartGroup: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_play_featured_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_play_repair_empty')),
        findsNothing,
      );
      expect(find.text('Практика'), findsOneWidget);
      expect(find.text('Нет активных разборов'), findsOneWidget);
    },
  );

  testWidgets(
    'Review board localizes clean-state guidance and keeps support headroom in Russian',
    (tester) async {
      await pumpTall(
        tester,
        host(tab: Act0ShellTabV1.review, locale: const Locale('ru')),
      );

      expect(find.text('Разбор ошибок'), findsOneWidget);
      expect(find.text('Сейчас всё чисто'), findsOneWidget);

      final support = tester.widget<Text>(
        find.byKey(const Key('act0_shell_review_board_support_text')),
      );
      final emptyBody = tester.widget<Text>(
        find.byKey(const Key('act0_shell_review_empty_body')),
      );
      expect(support.maxLines, 4);
      expect(support.overflow, TextOverflow.fade);
      expect(emptyBody.maxLines, 3);
      expect(emptyBody.overflow, TextOverflow.fade);
      expect(
        support.data,
        'Сейчас разбирать нечего. Просто продолжай по маршруту.',
      );
    },
  );

  testWidgets(
    'Review repair card prefers wrapped density over hard truncation',
    (tester) async {
      await pumpTall(tester, host());
      await createActionsMistakeFromPlayHub(tester);
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      await openBottomTabV1(tester, 'Review');
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_mistake_card')),
      );
      await tester.pumpAndSettle();

      final reason = tester.widget<Text>(
        find.byKey(const Key('act0_shell_mistake_reason')),
      );
      expect(reason.maxLines, 4);
      expect(reason.overflow, TextOverflow.fade);
    },
  );

  testWidgets(
    'Profile consistency card localizes momentum copy and keeps headroom in Russian',
    (tester) async {
      await pumpTall(
        tester,
        host(tab: Act0ShellTabV1.profile, locale: const Locale('ru')),
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_streak_nudge')),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ритм'), findsOneWidget);
      expect(find.textContaining('дня'), findsOneWidget);

      final support = tester.widget<Text>(
        find.byKey(const Key('act0_shell_profile_consistency_support_text')),
      );

      expect(support.maxLines, 2);
      expect(support.overflow, TextOverflow.fade);
      expect(
        find.byKey(const Key('act0_shell_profile_momentum_text')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Серия уже держится. Ещё несколько спокойных заходов — и этот ритм закрепится.',
        ),
        findsNothing,
      );
      expect(support.data, 'Постоянство уже начинает превращаться в ощущение.');
    },
  );

  testWidgets('Welcome app-shape uses natural Russian product copy', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': false,
    });

    await pumpTall(
      tester,
      host(showPlacementOnStart: true, locale: const Locale('ru')),
    );

    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
    await tester.pumpAndSettle();

    expect(
      find.text('Показывает следующий полезный шаг прямо сейчас.'),
      findsOneWidget,
    );
    expect(
      find.text('Даёт больше практики, когда хочется ещё немного.'),
      findsOneWidget,
    );
    expect(
      find.text('Возвращает к ошибкам сразу, чтобы они не копились.'),
      findsOneWidget,
    );
  });

  testWidgets('Welcome intro beat localizes cleanly in Russian', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': false,
    });

    await pumpTall(
      tester,
      host(showPlacementOnStart: true, locale: const Locale('ru')),
    );

    expect(find.text('Учись по одному споту за раз.'), findsOneWidget);
    expect(find.text('Старт'), findsOneWidget);
    expect(find.text('Понять, почему это работает'), findsOneWidget);
    expect(find.text('Learn one spot at a time.'), findsNothing);
    expect(find.text('Welcome'), findsNothing);
    expect(find.text('See why it works'), findsNothing);
  });

  testWidgets(
    'Welcome text beats show a visual product preview before the demo spot',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': false,
      });

      await pumpTall(tester, host(showPlacementOnStart: true));

      expect(
        find.byKey(const Key('act0_shell_welcome_visual_preview')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_welcome_visual_preview')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_welcome_role_home')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_role_learn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_role_play')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_welcome_role_review')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Profile identity and focus prefer wrapped density over hard truncation',
    (tester) async {
      final sample = Act0ShellStateV1.sample;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ProfileShellV1(
              profile: Act0ProfileStateV1(
                playerName: sample.profile.playerName,
                level: sample.profile.level,
                xpLine: sample.profile.xpLine,
                lessonsLine: sample.profile.lessonsLine,
                accuracyLine: sample.profile.accuracyLine,
                qualityLine: sample.profile.qualityLine,
                consistencyActiveDays: sample.profile.consistencyActiveDays,
                achievements: sample.profile.achievements,
                streakLine: sample.profile.streakLine,
                streakDays: sample.profile.streakDays,
                strongCategories: const <String>['Table sense'],
                recentSkillGains: const <Act0SkillGainV1>[
                  Act0SkillGainV1(
                    label: 'Table sense',
                    gain: 6,
                    source:
                        'Long transfer source that should keep compact headroom instead of collapsing into a single clipped line',
                  ),
                ],
                skillStats: <Act0PlacementSkillStatV1>[
                  Act0PlacementSkillStatV1(
                    label: 'Table sense',
                    value: 62,
                    meaning: 'Tracks table order and shifting context.',
                    affects:
                        'Keeps the table picture coherent while action changes.',
                    whyImportant:
                        'Lets the next decision feel cleaner instead of noisy.',
                  ),
                ],
                recommendedFocusTitle:
                    'Repair one weak spot before the next session starts to drift into a repeated pattern',
                recommendedFocusBody:
                    'Fix this mistake before it becomes a habit and before the route starts teaching the wrong rhythm through repetition.',
                recommendedFocusCtaLabel: 'Fix this now',
              ),
              onRetakePlacement: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final summary = tester.widget<Text>(
        find.byKey(const Key('act0_shell_profile_identity_summary')),
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_recommended_focus')),
        220,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      final focusBody = tester.widget<Text>(
        find.byKey(const Key('act0_shell_profile_recommended_focus_body')),
      );

      expect(summary.maxLines, 2);
      expect(summary.overflow, TextOverflow.fade);
      expect(focusBody.maxLines, 3);
      expect(focusBody.overflow, TextOverflow.fade);
    },
  );

  testWidgets(
    'Profile shows compact progress header and encouraging completion line',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.profile));

      expect(
        find.byKey(const Key('act0_shell_profile_header_band')),
        findsOneWidget,
      );
      expect(find.text('You'), findsWidgets);
      expect(find.textContaining('Progress profile'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_profile_hero_card')),
        findsOneWidget,
      );
      expect(find.text('New player'), findsWidgets);
      expect(find.textContaining('tasks complete'), findsWidgets);
      expect(find.text('Perfect path open'), findsOneWidget);
      expect(find.textContaining('practice accuracy'), findsNothing);
      expect(find.textContaining('of 329 tasks complete'), findsNothing);
    },
  );

  testWidgets('Profile recent gains dedupe repeated labels in display', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ProfileShellV1(
            profile: Act0ProfileStateV1(
              playerName: sample.profile.playerName,
              level: sample.profile.level,
              xpLine: sample.profile.xpLine,
              lessonsLine: sample.profile.lessonsLine,
              accuracyLine: sample.profile.accuracyLine,
              qualityLine: sample.profile.qualityLine,
              consistencyActiveDays: sample.profile.consistencyActiveDays,
              achievements: sample.profile.achievements,
              streakLine: sample.profile.streakLine,
              streakDays: sample.profile.streakDays,
              recentSkillGains: <Act0SkillGainV1>[
                Act0SkillGainV1(label: 'Table sense', gain: 5, source: 'A'),
                Act0SkillGainV1(label: 'Table sense', gain: 5, source: 'B'),
              ],
              skillStats: <Act0PlacementSkillStatV1>[
                Act0PlacementSkillStatV1(
                  label: 'Table sense',
                  value: 62,
                  meaning: 'Tracks table order and shifting context.',
                  affects:
                      'Keeps the table picture coherent while action changes.',
                  whyImportant:
                      'Lets the next decision feel cleaner instead of noisy.',
                ),
              ],
              recommendedFocusTitle: 'Today is banked',
              recommendedFocusBody:
                  'One short return tomorrow keeps the rhythm warm.',
              recommendedFocusCtaLabel: 'View progress',
            ),
            onRetakePlacement: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Table sense +10'), findsOneWidget);
    expect(find.text('Table sense +5  ·  Table sense +5'), findsNothing);
  });

  testWidgets(
    'Profile first-start tools move behind a compact utility entry and localize cleanly in Russian',
    (tester) async {
      final sample = Act0ShellStateV1.sample;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: Act0ProfileShellV1(
              profile: sample.profile,
              onRetakePlacement: () {},
              onReplayWelcome: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
        240,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_profile_first_start_tools')),
        findsNothing,
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_profile_first_start_tools')),
        findsOneWidget,
      );
      expect(find.text('Инструменты старта'), findsNWidgets(2));
      expect(find.text('Повторить знакомство'), findsOneWidget);
      expect(find.text('Пройти плейсмент снова'), findsOneWidget);
      expect(find.text('First start tools'), findsNothing);
      expect(find.text('Replay welcome'), findsNothing);
      expect(find.text('Retake placement'), findsNothing);
    },
  );

  testWidgets('Learn Path shows lesson cards and safe bottom padding', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    expect(find.text('Learn'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_learn_journey_strip')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_levels_menu_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_levels_menu')), findsNothing);
    expect(find.text('Poker from Zero'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_learn_route_board')),
      findsOneWidget,
    );
    expect(find.textContaining('lesson'), findsWidgets);
    expect(find.text('Hand Discipline'), findsNothing);
    expect(find.byKey(const Key('act0_shell_world_1')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_cta')),
      findsNothing,
    );
    for (final title in const <String>[
      'What poker is',
      'Cards, ranks & suits',
      'Your first hand, dealt',
      'Fold, check, call, raise',
      'Blinds & action order',
      'The 6 positions',
      'Hand rankings, on the table',
      'Showdown & winning',
    ]) {
      expect(find.text(title), findsWidgets);
    }
    expect(find.text('Locked'), findsWidgets);
    final learnSource = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();
    expect(learnSource, contains('Act0ShellTokensV1.bottomNavHeight'));
  });

  testWidgets(
    'Learn route keeps one dominant header and plain lesson state text',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

      expect(
        find.byKey(const Key('act0_shell_learn_journey_strip')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_learn_progress_bar')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.key != null &&
              widget.key.toString().contains(
                'act0_shell_learn_lesson_state_text_',
              ),
        ),
        findsWidgets,
      );
    },
  );

  testWidgets('Learn Path lesson cards show no subtitle in list view', (
    tester,
  ) async {
    final baseLesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .first;
    final lesson = Act0LessonCardV1(
      lessonId: baseLesson.lessonId,
      title: baseLesson.title,
      subtitle: 'First sentence. Second sentence should stay hidden.',
      state: Act0LessonStateV1.current,
      phaseLabel: baseLesson.phaseLabel,
      primaryCtaLabel: baseLesson.primaryCtaLabel,
      isSelectable: true,
      isLocked: false,
      rewardXp: baseLesson.rewardXp,
      runner: baseLesson.runner,
      tasks: baseLesson.tasks,
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.learn,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    expect(find.textContaining('First sentence'), findsNothing);
    expect(find.textContaining('Second sentence'), findsNothing);
  });

  testWidgets(
    'Levels menu is separate and keeps Level 1 selected with locked levels gated',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_levels_menu')), findsOneWidget);
      expect(find.text('Worlds'), findsWidgets);
      expect(find.text('3 volumes · 36 worlds'), findsOneWidget);
      expect(find.text('Volume I'), findsOneWidget);
      expect(find.text('Volume II'), findsOneWidget);
      expect(find.text('Volume III'), findsOneWidget);
      expect(find.text('Foundations'), findsOneWidget);
      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Mastery'), findsOneWidget);
      expect(find.text('3 of 8 lessons complete'), findsOneWidget);
      expect(find.text('World 1 of 12 active'), findsOneWidget);
      expect(find.text('Current: Poker from Zero'), findsOneWidget);
      expect(find.text('Next: Hand Discipline'), findsOneWidget);

      await tester.tap(find.byKey(const Key('act0_shell_world_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_levels_menu')), findsNothing);
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
      expect(find.text('What poker is'), findsWidgets);
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();

      for (final title in const <String>[
        'Poker from Zero',
        'Hand Discipline',
        'Position Thinking',
        'Preflop Framework',
        'Bet Purpose And Price',
        'Board And Draws',
        'Range Thinking Lite',
        'Stack Depth And Risk',
        'Tournament Pressure',
        'Player Adjustment',
        'Real Play Transfer',
        'Mindset Bridge',
      ]) {
        await tester.ensureVisible(find.text(title).first);
        await tester.pumpAndSettle();
        expect(find.text(title), findsWidgets);
      }
      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_close')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('act0_shell_world_2')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_selected_world_panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_world_unlock_label')),
        findsOneWidget,
      );
      expect(find.text('Next'), findsWidgets);
      expect(
        find.byKey(const Key('act0_shell_world_unlock_label')),
        findsOneWidget,
      );
      expect(
        find.text('Finish Poker from Zero to open this world.'),
        findsWidgets,
      );
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);

      await tester.tapAt(const Offset(24, 100));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_world_panel')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_levels_menu')), findsNothing);
    },
  );

  testWidgets(
    'Levels sticky selected-world meta keeps compact headroom without hard truncation',
    (tester) async {
      await pumpCompact(tester, host(tab: Act0ShellTabV1.learn));

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();

      final statusLine = tester.widget<Text>(
        find.byKey(const Key('act0_shell_levels_selected_world_status_line')),
      );
      expect(statusLine.maxLines, 2);
      expect(statusLine.overflow, TextOverflow.fade);

      final currentLine = tester.widget<Text>(
        find.byKey(const Key('act0_shell_levels_selected_world_current_line')),
      );
      expect(currentLine.maxLines, 1);
      expect(currentLine.overflow, TextOverflow.fade);
      expect((currentLine.data ?? '').isNotEmpty, isTrue);

      final landmarkLine = tester.widget<Text>(
        find.byKey(const Key('act0_shell_levels_selected_world_next_landmark')),
      );
      expect(landmarkLine.maxLines, 2);
      expect(landmarkLine.overflow, TextOverflow.fade);
    },
  );

  testWidgets('Volume strip shows active and locked journey states', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_volume_strip')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_volume_i')),
        matching: find.text('Active'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_volume_ii')),
        matching: find.text('Locked'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_volume_iii')),
        matching: find.text('Locked'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Locked Volume II opens compact route preview without premium copy',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_volume_ii')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_volume_ii_preview_panel')),
        findsOneWidget,
      );
      expect(find.text('Volume II'), findsWidgets);
      expect(find.text('Strategy'), findsWidgets);
      expect(find.text('Unlocks after Volume I.'), findsOneWidget);
      expect(
        find.text(
          'Preview: position, preflop structure, bet purpose, and board reading.',
        ),
        findsOneWidget,
      );
      expect(find.text('Premium preview'), findsNothing);
      expect(find.text('See what premium adds'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_volume_ii_continue_current_cta')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_volume_ii_continue_current_cta')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_volume_ii_preview_panel')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Next world locked detail uses progression copy, not premium copy',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_world_2')));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsWidgets);
      expect(
        find.text('Finish Poker from Zero to open this world.'),
        findsWidgets,
      );
      expect(
        find.byKey(const Key('act0_shell_world_continue_current_cta')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_selected_world_panel')),
          matching: find.text(
            'Learn which hands deserve chips and which can fold.',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Premium preview'), findsNothing);
      expect(find.text('See what premium adds'), findsNothing);

      await tester.tap(
        find.byKey(const Key('act0_shell_world_continue_current_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_levels_menu')), findsNothing);
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    },
  );

  testWidgets('Later locked world stays locked without premium paywall copy', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('act0_shell_world_3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_world_3')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_selected_world_panel')),
      findsOneWidget,
    );
    expect(find.text('Locked'), findsWidgets);
    expect(find.text('Premium preview'), findsNothing);
    expect(find.text('See what premium adds'), findsNothing);
    expect(
      find.textContaining('This world opens later in the route'),
      findsOneWidget,
    );
  });

  test('Worlds route order remains unchanged across Volume I', () {
    final worlds = Act0ShellStateV1.sample.worlds;
    expect(worlds.map((world) => world.title).toList(), const <String>[
      'Poker from Zero',
      'Hand Discipline',
      'Position Thinking',
      'Preflop Framework',
      'Bet Purpose And Price',
      'Board And Draws',
      'Range Thinking Lite',
      'Stack Depth And Risk',
      'Tournament Pressure',
      'Player Adjustment',
      'Real Play Transfer',
      'Mindset Bridge',
    ]);
    expect(
      worlds.map((world) => world.worldNumber).toList(),
      List<int>.generate(12, (index) => index + 1),
    );
  });

  testWidgets('Learn completed and current cards open runner', (tester) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_What poker is')),
    );
    await tester.tap(find.byKey(const Key('act0_shell_lesson_What poker is')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_lesson_popup_scrim')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_lesson_hub_steps')),
      findsOneWidget,
    );
    expect(find.text('Loop'), findsNothing);
    expect(find.byKey(const Key('act0_shell_lesson_hub_header')), findsNothing);
    expect(find.text('Find your seat'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_cta')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_what_poker_is_theory')),
    );
    await tester.pumpAndSettle();

    await openSelectedLessonFromLearn(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text("We start with Hold'em cash."), findsOneWidget);
    expect(find.textContaining('Hero'), findsWidgets);

    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    final actionLesson = find.byKey(
      const Key('act0_shell_lesson_Fold, check, call, raise'),
    );
    await tester.ensureVisible(actionLesson);
    await tester.tap(actionLesson);
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(
      find.text('Name each action before the table asks you.'),
      findsWidgets,
    );
    expect(find.text('Loop'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_theory')),
    );
    await tester.pumpAndSettle();

    await openSelectedLessonFromLearn(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Actions are table verbs.'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_learning_rail')), findsOneWidget);
  });

  testWidgets('Current lesson expands inline into a mini learning loop', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));
    final blindsLesson = find.byKey(
      const Key('act0_shell_lesson_Blinds & action order'),
    );
    await tester.ensureVisible(blindsLesson);
    final beforeTop = tester.getTopLeft(blindsLesson).dy;

    final foldLesson = find.byKey(
      const Key('act0_shell_lesson_Fold, check, call, raise'),
    );
    await tester.ensureVisible(foldLesson);
    await tester.tap(foldLesson);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_lesson_hub_steps')),
      findsOneWidget,
    );
    expect(find.text('Action words'), findsWidgets);
    expect(find.text('Fold weak hands'), findsOneWidget);
    expect(find.text('Action recap'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_cta')),
      findsNothing,
    );
    expect(find.text('Now'), findsWidgets);
    final afterTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
        )
        .dy;
    expect(afterTop, greaterThan(beforeTop));

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_call_drill')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
      findsOneWidget,
    );
    expect(find.text('Call a price'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_task_detail')),
      findsOneWidget,
    );
    expect(find.text('Later'), findsWidgets);

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_theory')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
      findsOneWidget,
    );

    await openSelectedLessonFromLearn(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('Actions are table verbs.'), findsOneWidget);
  });

  testWidgets(
    'Learn task popup repeat tap closes details and outside tap closes lesson zone',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

      final foldLesson = find.byKey(
        const Key('act0_shell_lesson_Fold, check, call, raise'),
      );
      await tester.ensureVisible(foldLesson);
      await tester.tap(foldLesson);
      await tester.pumpAndSettle();

      final step = find.byKey(
        const Key('act0_shell_lesson_step_actions_theory'),
      );

      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_selected_lesson_guidance')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );

      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsOneWidget,
      );

      await tester.tapAt(const Offset(8, 220));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsNothing,
      );

      await tester.tap(foldLesson);
      await tester.pumpAndSettle();
      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsOneWidget,
      );

      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );

      await tester.tap(step);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_task_detail')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Expanded lesson collapses without leaving the map', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    final foldLesson = find.byKey(
      const Key('act0_shell_lesson_Fold, check, call, raise'),
    );
    await tester.ensureVisible(foldLesson);
    await tester.tap(foldLesson);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );

    await tester.ensureVisible(foldLesson);
    await tester.tap(foldLesson);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
  });

  testWidgets('Completed lesson substeps can be replayed from the inline hub', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    final whatPokerLesson = find.byKey(
      const Key('act0_shell_lesson_What poker is'),
    );
    await tester.ensureVisible(whatPokerLesson);
    await tester.tap(whatPokerLesson);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_outcome')),
      findsOneWidget,
    );
    expect(
      find.text('Already clear. Next open lesson: Cards, ranks & suits.'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_step_what_poker_is_find_hero')),
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_what_poker_is_find_hero')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Already clear. One calm replay turns this into a perfect clear.',
      ),
      findsOneWidget,
    );
    expect(find.text('Replay once for perfect.'), findsOneWidget);
    expect(find.textContaining('cleared with error'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        matching: find.text('Review'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_selected_lesson_task_focus')),
        matching: find.text('Replay'),
      ),
      findsOneWidget,
    );

    await openSelectedLessonFromLearn(tester);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('Opening a lower lesson auto-scrolls its inline hub into view', (
    tester,
  ) async {
    await pumpCompact(tester, host(tab: Act0ShellTabV1.learn));

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsNothing,
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
          )
          .dy,
      greaterThan(44),
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
          )
          .dy,
      lessThan(260),
    );
  });

  testWidgets(
    'Learn hub shows a perfect marker only when canonical perfectTaskIds are present',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final world = sample.worlds.first;
      final lesson = world.lessons.first;
      final task = lesson.taskList.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LearnPathShellV1(
              moduleTitle: sample.courseTitle,
              moduleProgressLabel: sample.pathProgressLabel,
              worlds: sample.worlds,
              selectedWorldId: world.worldId,
              showWorldMenu: false,
              worldDetailId: null,
              lessons: world.lessons,
              selectedLessonId: lesson.lessonId,
              selectedTaskId: task.taskId,
              activePopupTaskId: task.taskId,
              completedTaskIds: <String>{task.taskId},
              perfectTaskIds: <String>{task.taskId},
              skippedTaskIds: const <String>{},
              pathClosedTaskIds: <String>{task.taskId},
              detailLessonId: lesson.lessonId,
              lessonOutcomeLabels: <String, String>{
                lesson.lessonId: 'Already clear.',
              },
              onSelectWorld: (_) {},
              onOpenWorldMenu: () {},
              onCloseWorldMenu: () {},
              onDismissWorldDetail: () {},
              onPreviewPremiumWorld: (_) {},
              onSelectLesson: (_) => true,
              onOpenLessonAfterScroll: (_) {},
              onDismissDetail: () {},
              onSelectTask: (_, __) {},
              onDismissTaskPopup: () {},
              onStartTask: (_, __) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key('act0_shell_lesson_step_perfect_${task.taskId}')),
        findsOneWidget,
      );
      expect(find.text('Perfect clear complete.'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    },
  );

  testWidgets('Switching lessons scrolls first and opens the new hub after', (
    tester,
  ) async {
    await pumpCompact(tester, host(tab: Act0ShellTabV1.learn));

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.text('Action words'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsNothing,
    );
    expect(find.text('Action words'), findsNothing);

    for (var i = 0; i < 30; i++) {
      if (find
          .byKey(const Key('act0_shell_selected_lesson_panel'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(find.text('Why someone always puts money in first.'), findsWidgets);
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
          )
          .dy,
      greaterThan(44),
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
          )
          .dy,
      lessThan(260),
    );
  });

  testWidgets('Stale learn lesson callback is ignored without crashing', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    final learnShell = tester.widget<Act0LearnPathShellV1>(
      find.byType(Act0LearnPathShellV1),
    );

    expect(
      () => learnShell.onSelectLesson('missing_lesson_id'),
      returnsNormally,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
  });

  testWidgets('Learn locked card does not open runner', (tester) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    final blindsLesson = find.byKey(
      const Key('act0_shell_lesson_Blinds & action order'),
    );
    await tester.ensureVisible(blindsLesson);
    await tester.tap(blindsLesson);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(find.text('Why someone always puts money in first.'), findsWidgets);
    expect(find.text('Loop'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_cta')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_blinds_theory')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_cta')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Locked lesson detail points at the active route blocker instead of its own first task',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final currentLesson = sample.currentLesson;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_shell_progress_v1': jsonEncode(<String, Object>{
          'schemaVersion': 2,
          'completedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': sample.selectedWorldId,
          'selectedLessonId': currentLesson.lessonId,
          'selectedTaskId': currentLesson.taskList[1].taskId,
          'earnedXp': 0,
        }),
      });

      await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

      final blindsLesson = find.byKey(
        const Key('act0_shell_lesson_Blinds & action order'),
      );
      await tester.ensureVisible(blindsLesson);
      await tester.tap(blindsLesson);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('act0_shell_lesson_step_blinds_theory')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Clear meet the table first, then this node opens.'),
        findsOneWidget,
      );
      expect(
        find.text('Clear blinds post first first, then this node opens.'),
        findsNothing,
      );
    },
  );

  testWidgets('Level 2 remains locked with multiple preview lessons', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    final levelsButton = find.byKey(const Key('act0_shell_levels_menu_button'));
    await tester.ensureVisible(levelsButton);
    await tester.tap(levelsButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_world_2')));
    await tester.pumpAndSettle();

    expect(find.text('Hand Discipline'), findsWidgets);
    expect(find.text('Next'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_world_unlock_label')),
      findsOneWidget,
    );
    expect(
      find.text('Finish Poker from Zero to open this world.'),
      findsWidgets,
    );
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);

    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    expect(world2.isLocked, isTrue);
    expect(world2.lessons.length, greaterThanOrEqualTo(5));
  });

  testWidgets('Learn lesson expansion dismisses on second node tap', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    final foldLesson = find.byKey(
      const Key('act0_shell_lesson_Fold, check, call, raise'),
    );
    await tester.ensureVisible(foldLesson);
    await tester.tap(foldLesson);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );

    await tester.ensureVisible(foldLesson);
    await tester.tap(foldLesson);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
  });

  testWidgets('Runner Theory has table and Continue without options', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
    expect(find.byKey(const Key('act0_shell_continue_cta')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    expect(find.text('Fold'), findsNothing);
    expect(find.text('Call'), findsNothing);
    expect(find.text('Raise'), findsNothing);
    expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_sharky_mascot')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_motion')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_thinking')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_learning_rail_task_label')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_learning_rail_support_line')),
      findsOneWidget,
    );
    expect(find.textContaining('chat'), findsNothing);
    expect(find.textContaining('Ask Sharky'), findsNothing);
    expect(find.textContaining('generated'), findsNothing);
    expect(find.textContaining('BTN'), findsWidgets);
    expect(find.text('SB'), findsWidgets);
    expect(find.text('BB'), findsWidgets);
    expect(find.textContaining('Hero'), findsWidgets);
    expect(find.text('0.5 BB'), findsWidgets);
    expect(find.text('1 BB'), findsWidgets);
    expect(find.byKey(const Key('act0_shell_bet_chip_SB')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bet_chip_BB')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_empty_board_label')), findsNothing);
    expect(find.byKey(const Key('act0_shell_action_trail')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_center_pot_pulse_Pot 1.5 BB')),
      findsOneWidget,
    );
    expect(find.text('K'), findsWidgets);
    expect(find.text('T'), findsWidgets);
    expect(find.byKey(const Key('act0_shell_board_card')), findsNothing);
  });

  testWidgets(
    'Runner Theory keeps table and Continue visible on compact portrait',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

      expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_continue_cta')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);

      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final ctaRect = tester.getRect(
        find.byKey(const Key('act0_shell_continue_cta')),
      );
      expect(tableRect.top, greaterThanOrEqualTo(0));
      expect(tableRect.height, lessThanOrEqualTo(640));
      expect(tableRect.bottom, lessThanOrEqualTo(812));
      expect(ctaRect.bottom, lessThanOrEqualTo(812));
      expect(tableRect.overlaps(ctaRect), isFalse);
      expect(find.byKey(const Key('act0_shell_action_trail')), findsNothing);
    },
  );

  testWidgets(
    'Runner Drill keeps table and action options visible on compact portrait',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final baseLesson = sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
      final drillTask = baseLesson.taskList.firstWhere(
        (task) => task.taskId == 'actions_raise_drill',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: <Act0LessonTaskV1>[drillTask],
      );

      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.drill,
          state: stateWithLessons(<Act0LessonCardV1>[lesson]),
        ),
      );

      await advanceTeachingToDrill(tester);

      expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_sizing_presets_label')),
        findsNothing,
      );
      expect(find.text('Fold'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Raise'), findsOneWidget);

      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final optionRect = tester.getRect(
        find.byKey(const Key('act0_shell_option_call')),
      );
      expect(tableRect.bottom, lessThanOrEqualTo(812));
      expect(optionRect.bottom, lessThanOrEqualTo(812));
    },
  );

  testWidgets(
    'Compact drill stacks long 3-option answer labels when the row budget is exceeded',
    (tester) async {
      Future<void> pumpTask(Act0LessonTaskV1 task) async {
        await pumpCompact(
          tester,
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: task.runner.copyWith(
                  phase: Act0LessonPhaseV1.drill,
                  teachingSteps: const <Act0TeachingStepV1>[],
                ),
                selectedTaskId: task.taskId,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        );
      }

      final tasks = <Act0LessonTaskV1>[
        _taskByIdV1(
          _allAct0TasksV1(),
          'discipline_checkpoint_checkpoint_table_discipline',
        ),
        _taskByIdV1(_allAct0TasksV1(), 'w7_ajs_btn_25bb_transfer'),
        _taskByIdV1(_allAct0TasksV1(), 'w12_pretty_hand_bad_price_fold'),
      ];

      for (final task in tasks) {
        await pumpTask(task);
        final optionRects = task.runner.options
            .map(
              (option) => tester.getRect(
                find.byKey(Key('act0_shell_option_${option.id}')),
              ),
            )
            .toList(growable: false);
        final topSet = optionRects.map((rect) => rect.top).toSet();
        final heights = optionRects.map((rect) => rect.height).toList();
        final heightSpread =
            heights.reduce((a, b) => a > b ? a : b) -
            heights.reduce((a, b) => a < b ? a : b);

        expect(
          topSet.length,
          greaterThan(1),
          reason: '${task.taskId} should stack long 3-option labels vertically',
        );
        expect(
          heightSpread,
          lessThanOrEqualTo(24),
          reason:
              '${task.taskId} should keep compact option heights near parity after fallback',
        );
        for (final rect in optionRects) {
          expect(rect.bottom, lessThanOrEqualTo(812));
        }
      }
    },
  );

  testWidgets(
    'Action prompt keeps compact question readable without truncation',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
          .taskList
          .firstWhere((entry) => entry.taskId == 'actions_legal_context');
      final runner = task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      );

      await pumpCompact(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskId: task.taskId,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      final questionText = tester.widget<Text>(
        find.byKey(const Key('act0_shell_action_question')),
      );
      expect(questionText.maxLines, isNull);
      expect(questionText.overflow, isNull);
      expect(
        questionText.data,
        'No bet faces you. Which action is legal and free?',
      );
    },
  );

  testWidgets(
    'Runner Review keeps table and Continue visible on compact portrait',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.review),
      );

      expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );

      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final ctaRect = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      expect(tableRect.bottom, lessThanOrEqualTo(812));
      expect(ctaRect.bottom, lessThanOrEqualTo(812));
    },
  );

  testWidgets('Runner table renders compact player nodes from state', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    for (final seatId in const <String>['btn', 'bb', 'co', 'sb']) {
      expect(find.byKey(Key('act0_shell_seat_node_$seatId')), findsOneWidget);
    }
    expect(find.textContaining('BTN'), findsWidgets);
    expect(find.text('SB'), findsWidgets);
    expect(find.text('BB'), findsWidgets);
    expect(find.textContaining('Hero'), findsWidgets);
    expect(find.text('0.5 BB'), findsWidgets);
    expect(find.text('1 BB'), findsWidgets);
    expect(find.byKey(const Key('act0_shell_bet_chip_SB')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bet_chip_BB')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring')),
      findsOneWidget,
    );
  });

  testWidgets('Blind bet chips stay clear of compact center info', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    final center = tester.getRect(
      find.byKey(const Key('act0_shell_center_info_card')),
    );
    final sbChip = tester.getRect(
      find.byKey(const Key('act0_shell_bet_chip_SB')),
    );
    final bbChip = tester.getRect(
      find.byKey(const Key('act0_shell_bet_chip_BB')),
    );

    expect(
      find.byKey(const Key('act0_shell_bet_chip_motion_sb_SB')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_bet_chip_motion_bb_BB')),
      findsNothing,
    );
    expect(sbChip.overlaps(center), isFalse);
    expect(bbChip.overlaps(center), isFalse);
  });

  testWidgets(
    'Canonical detached shell keeps blind bet chips between center and blind seats',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final utg = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_utg')),
      );
      final center = tester.getRect(
        find.byKey(const Key('act0_shell_center_info_card')),
      );
      final sbSeat = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_sb')),
      );
      final bbSeat = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_bb')),
      );
      final sbChip = tester.getRect(
        find.byKey(const Key('act0_shell_bet_chip_SB')),
      );
      final bbChip = tester.getRect(
        find.byKey(const Key('act0_shell_bet_chip_BB')),
      );

      expect(sbChip.overlaps(center), isFalse);
      expect(bbChip.overlaps(center), isFalse);
      expect(sbChip.center.dx, greaterThan(table.left));
      expect(bbChip.center.dx, greaterThan(table.left));
      expect(sbChip.center.dx, greaterThan(sbSeat.center.dx));
      expect(bbChip.center.dx, greaterThan(bbSeat.center.dx));
      expect(sbChip.center.dx, lessThan(center.center.dx));
      expect(bbChip.center.dx, lessThan(center.center.dx));
    },
  );

  testWidgets(
    'Canonical detached shell keeps theory guidance in one place and readable suits',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final rail = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );

      expect(find.byKey(const Key('act0_shell_learning_rail')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_learning_rail_progress')),
        findsNothing,
      );
      expect(find.text('1/2'), findsNothing);
      expect(find.byKey(const Key('act0_shell_task_rail')), findsNothing);
      expect(find.byKey(const Key('act0_shell_phase_tracker')), findsNothing);
      expect(rail.top, greaterThan(table.bottom));
      expect(rail.top - table.bottom, lessThanOrEqualTo(44));
      expect(rail.height, greaterThanOrEqualTo(104));
      expect(find.text('♠'), findsWidgets);
    },
  );

  testWidgets(
    'Live compact portrait runner prioritizes table and readable rail',
    (tester) async {
      await pumpCompact(tester, host());

      await tester.tap(
        find.byKey(const Key('act0_shell_home_daily_goal_card')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_top_bar')), findsNothing);
      expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_seat_tap_prompt')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
      expect(find.byKey(const Key('act0_shell_learning_rail')), findsNothing);
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsNothing,
      );

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final bottomPanel = tester.getRect(
        find.byKey(const Key('act0_shell_seat_tap_prompt')),
      );
      final prompt = tester.widget<Text>(
        find.byKey(const Key('act0_shell_action_question')),
      );

      expect(table.top, lessThanOrEqualTo(72));
      expect(table.height, greaterThanOrEqualTo(520));
      expect(bottomPanel.top, greaterThan(table.bottom));
      expect(bottomPanel.top - table.bottom, lessThanOrEqualTo(28));
      expect(bottomPanel.height, greaterThanOrEqualTo(124));
      expect(prompt.style?.fontSize, greaterThanOrEqualTo(13.0));
    },
  );

  testWidgets(
    'Canonical detached shell shows teaching prompt during drill teaching states',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        selectedOptionId: null,
        teachingSteps: const <Act0TeachingStepV1>[
          Act0TeachingStepV1(
            title: 'Find the active seat first.',
            body: 'Use the table before moving on.',
          ),
        ],
        teachingStepIndex: 0,
      );

      await pumpCompact(
        tester,
        MaterialApp(
          home: Act0LessonRunnerShellV1(
            runner: runner,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      );

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final rail = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );

      expect(find.byKey(const Key('act0_shell_learning_rail')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_learning_rail_progress')),
        findsNothing,
      );
      expect(find.text('1/1'), findsNothing);
      expect(find.text('Find the active seat first.'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_continue_cta')), findsOneWidget);
      expect(rail.top, greaterThan(table.bottom));
    },
  );

  testWidgets(
    'Canonical detached shell shows long teaching progress at the rail top right',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.runner.copyWith(
        phase: Act0LessonPhaseV1.theory,
        selectedOptionId: null,
        teachingSteps: const <Act0TeachingStepV1>[
          Act0TeachingStepV1(title: 'Step one.', body: 'First idea.'),
          Act0TeachingStepV1(title: 'Step two.', body: 'Second idea.'),
          Act0TeachingStepV1(title: 'Step three.', body: 'Third idea.'),
          Act0TeachingStepV1(title: 'Step four.', body: 'Fourth idea.'),
        ],
        teachingStepIndex: 1,
      );

      await pumpCompact(
        tester,
        MaterialApp(
          home: Act0LessonRunnerShellV1(
            runner: runner,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      );

      final rail = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );
      final progress = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_progress')),
      );

      expect(
        find.byKey(const Key('act0_shell_learning_rail_progress')),
        findsOneWidget,
      );
      expect(progress.center.dx, greaterThan(rail.center.dx));
      expect(progress.center.dy, lessThan(rail.center.dy));
    },
  );

  testWidgets(
    'Canonical detached shell learning rail blocks rapid forward and supports back',
    (tester) async {
      var teachingStepIndex = 1;
      var forwardCount = 0;
      var backCount = 0;
      final baseRunner = Act0ShellStateV1.sample.currentLesson.runner.copyWith(
        phase: Act0LessonPhaseV1.theory,
        selectedOptionId: null,
        teachingSteps: const <Act0TeachingStepV1>[
          Act0TeachingStepV1(
            title: 'Step one stays readable.',
            body: 'First concept.',
          ),
          Act0TeachingStepV1(
            title: 'Step two should not be skippable instantly.',
            body: 'Second concept.',
          ),
        ],
      );

      await pumpCompact(
        tester,
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Act0LessonRunnerShellV1(
                  runner: baseRunner.copyWith(
                    teachingStepIndex: teachingStepIndex,
                  ),
                  tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                  onBack: () {},
                  onPreviousTheory: () {
                    setState(() {
                      backCount += 1;
                      teachingStepIndex -= 1;
                    });
                  },
                  onContinueTheory: () {
                    setState(() {
                      forwardCount += 1;
                      teachingStepIndex += 1;
                    });
                  },
                  onChooseOption: (_) {},
                  onContinueReview: () {},
                ),
              );
            },
          ),
        ),
      );

      expect(
        find.text('Step two should not be skippable instantly.'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('act0_shell_previous_cta')));
      await tester.pumpAndSettle();

      expect(backCount, 1);
      expect(find.text('Step one stays readable.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();

      expect(forwardCount, 0);
      expect(find.text('Step one stays readable.'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();

      expect(forwardCount, 1);
      expect(
        find.text('Step two should not be skippable instantly.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Learning rail keeps support and nav compact on first theory step',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

      final support = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_support_line')),
      );
      final rail = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );
      final next = tester.getRect(
        find.byKey(const Key('act0_shell_continue_cta')),
      );
      final previousRect = tester.getRect(
        find.byKey(const Key('act0_shell_previous_cta')),
      );
      final previous = tester.widget<IconButton>(
        find.byKey(const Key('act0_shell_previous_cta')),
      );

      expect(next.top - support.bottom, lessThanOrEqualTo(18));
      expect(rail.height, lessThanOrEqualTo(124));
      expect(previousRect.center.dx, lessThan(rail.center.dx));
      expect(next.center.dx, greaterThan(rail.center.dx));
      expect(previous.onPressed, isNull);
    },
  );

  testWidgets('Home keeps the global top bar visible', (tester) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.home, phase: Act0LessonPhaseV1.theory),
    );

    expect(find.byKey(const Key('act0_shell_top_bar')), findsOneWidget);
  });

  testWidgets(
    'Active runner hides the global top bar but keeps session progress visible',
    (tester) async {
      await pumpCompact(tester, host());
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_top_bar')), findsNothing);
      expect(find.byKey(const Key('act0_shell_runner_back')), findsOneWidget);
      expect(find.text('1/7'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
    },
  );

  testWidgets(
    'Canonical detached shell keeps drill guidance below the table only',
    (tester) async {
      await pumpCompact(tester, host());
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      await advanceTeachingToDrill(tester);

      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsNothing);
      expect(find.byKey(const Key('act0_shell_task_rail')), findsNothing);
      expect(
        find
                .byKey(const Key('act0_shell_seat_tap_prompt'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('act0_shell_action_panel'))
                .evaluate()
                .isNotEmpty,
        isTrue,
      );
      expect(
        find.byKey(const Key('act0_shell_action_question')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_question_badge')),
        findsOneWidget,
      );
      expect(find.text('Spot check'), findsOneWidget);
    },
  );

  testWidgets(
    'Canonical detached shell keeps table position stable across theory and drill',
    (tester) async {
      await pumpCompact(tester, host());
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();

      final theoryTable = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      await advanceTeachingToDrill(tester);
      final drillTable = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );

      expect((theoryTable.top - drillTable.top).abs(), lessThanOrEqualTo(16));
      expect(theoryTable.height, greaterThanOrEqualTo(500));
    },
  );

  testWidgets('Canonical detached shell keeps a tighter top instruction slot', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
    final progress = tester.getRect(find.byType(LinearProgressIndicator));
    final rail = tester.getRect(
      find.byKey(const Key('act0_shell_learning_rail')),
    );

    expect(table.top - progress.bottom, greaterThanOrEqualTo(0));
    expect(table.top - progress.bottom, lessThanOrEqualTo(32));
    expect(rail.top - table.bottom, lessThanOrEqualTo(44));
  });

  testWidgets(
    'Canonical detached shell review shows animated XP closing summary',
    (tester) async {
      await pumpCompact(tester, host());
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      await completeVisibleTheoryTask(tester);
      await advanceTeachingToDrill(tester);

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump(const Duration(milliseconds: 120));

      final toast = tester.getRect(
        find.byKey(const Key('act0_shell_completion_toast')),
      );
      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final utg = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_utg')),
      );
      final center = tester.getRect(
        find.byKey(const Key('act0_shell_center_info_card')),
      );

      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_reward_label')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_total')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_progress')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_reward_lane')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_pot_sweep_moment')),
        findsNothing,
      );
      expect(find.textContaining('Clean rep'), findsOneWidget);
      expect(toast.top, greaterThan(table.top));
      expect(toast.top, greaterThan(utg.bottom));
      expect(toast.bottom, lessThan(center.top));
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_feedback_card')),
          matching: find.byKey(const Key('act0_shell_completion_toast')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_table')),
          matching: find.byKey(const Key('act0_shell_completion_toast')),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_closing_summary')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Canonical detached shell review shows level up when XP crosses the target',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final baseLesson = sample.currentLesson;
      final drillTask = baseLesson.taskList.firstWhere(
        (task) => task.taskId == 'actions_legal_context',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: <Act0LessonTaskV1>[drillTask],
      );
      final baseState = stateWithLessons(<Act0LessonCardV1>[lesson]);
      final rewardState = Act0ShellStateV1(
        courseTitle: baseState.courseTitle,
        courseSubtitle: baseState.courseSubtitle,
        levelLabel: 'Level 1',
        xp: 195,
        xpTarget: baseState.xpTarget,
        streakDays: baseState.streakDays,
        dailyGoalLabel: baseState.dailyGoalLabel,
        dailyGoalValue: baseState.dailyGoalValue,
        pathProgressLabel: baseState.pathProgressLabel,
        selectedWorldId: baseState.selectedWorldId,
        worlds: baseState.worlds,
        lessons: baseState.lessons,
        review: baseState.review,
        profile: Act0ProfileStateV1(
          playerName: baseState.profile.playerName,
          level: 'Level 1',
          xpLine: '195 / 200 XP',
          lessonsLine: baseState.profile.lessonsLine,
          accuracyLine: baseState.profile.accuracyLine,
          qualityLine: baseState.profile.qualityLine,
          consistencyActiveDays: baseState.profile.consistencyActiveDays,
          achievements: baseState.profile.achievements,
          strongCategories: baseState.profile.strongCategories,
          weakCategories: baseState.profile.weakCategories,
          recentProgress: baseState.profile.recentProgress,
          recentSkillGains: baseState.profile.recentSkillGains,
          skillStats: baseState.profile.skillStats,
          recommendedFocusTitle: baseState.profile.recommendedFocusTitle,
          recommendedFocusBody: baseState.profile.recommendedFocusBody,
          recommendedFocusCtaLabel: baseState.profile.recommendedFocusCtaLabel,
        ),
      );

      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.drill,
          state: rewardState,
        ),
      );
      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        find.byKey(const Key('act0_shell_completion_toast_level_up')),
        findsOneWidget,
      );
      expect(find.textContaining('Level up'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
    },
  );

  testWidgets(
    'Canonical detached shell does not show replay XP toast for completed task replays',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final currentLesson = sample.currentLesson;
      final replayTaskId = currentLesson.taskList[1].taskId;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_shell_progress_v1': jsonEncode(<String, Object>{
          'schemaVersion': 7,
          'completedTaskIds': <String>[replayTaskId],
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': sample.selectedWorldId,
          'selectedLessonId': currentLesson.lessonId,
          'selectedTaskId': replayTaskId,
          'earnedXp': 5,
        }),
      });

      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
      );
      await tester.tap(find.byKey(const Key('act0_shell_seat_node_btn')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsNothing,
      );
      expect(find.textContaining('Clean rep'), findsNothing);
      expect(find.textContaining('+5 XP'), findsNothing);
    },
  );

  testWidgets(
    'Canonical detached shell shows block completion summary and continues in-node',
    (tester) async {
      await pumpCompact(tester, host());
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();

      await completeCurrentLessonBlock(tester);

      expect(
        find.byKey(const Key('act0_shell_block_summary_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_accuracy')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_xp_progress')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
        findsOneWidget,
      );
      expect(find.text('Open next lesson'), findsOneWidget);
      expect(find.text('Lesson complete'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_block_summary_replay_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_unlock_label')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_map_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_sharky_line')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_suggested_next')),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_block_summary_card')),
        findsNothing,
      );
    },
  );

  testWidgets('Canonical detached shell last block summary returns to map', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final lesson = sample.currentLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
    );

    await pumpCompact(
      tester,
      host(state: stateWithLessons(<Act0LessonCardV1>[lesson])),
    );
    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();

    await completeCurrentLessonBlock(tester);

    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsOneWidget,
    );
    expect(find.text('Back to map'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(
          find.byKey(const Key('act0_shell_block_summary_continue_cta')),
        )
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
  });

  testWidgets('Block summary locks continue below accuracy threshold', (
    tester,
  ) async {
    var continued = 0;
    var replayed = 0;
    var backedToMap = 0;

    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Button open basics',
              xpEarned: 18,
              errorCount: 3,
              taskCount: 5,
              correctCount: 2,
              startLevel: 1,
              endLevel: 1,
              startXp: 42,
              endXp: 60,
              xpTarget: 200,
              nextLessonTitle: 'Facing a limp',
            ),
            onReplay: () {
              replayed += 1;
            },
            onContinue: () {
              continued += 1;
            },
            onBackToMap: () {
              backedToMap += 1;
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('Need 80% accuracy'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_map_cta')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('act0_shell_block_summary_continue_cta')),
          )
          .onPressed,
      isNotNull,
    );
    expect(find.text('Replay before next lesson'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_quality_cta')),
      findsNothing,
    );

    tester
        .widget<FilledButton>(
          find.byKey(const Key('act0_shell_block_summary_continue_cta')),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_block_summary_map_cta')));
    await tester.pumpAndSettle();

    expect(continued, 0);
    expect(replayed, 1);
    expect(backedToMap, 1);
  });

  testWidgets('Last lesson in a world continues into next world', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final world1Lesson = sample.currentLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
    );
    final world2Lesson = sample
        .worldById('world_2')
        .lessons
        .first
        .copyWith(
          state: Act0LessonStateV1.locked,
          isSelectable: false,
          isLocked: true,
          primaryCtaLabel: 'Locked',
        );

    await pumpCompact(
      tester,
      host(
        state: stateWithWorlds(
          selectedWorldId: 'world_1',
          worlds: <Act0WorldCardV1>[
            sample
                .worldById('world_1')
                .copyWith(
                  status: Act0WorldStateV1.current,
                  isSelectable: true,
                  isLocked: false,
                  lessons: <Act0LessonCardV1>[world1Lesson],
                ),
            sample
                .worldById('world_2')
                .copyWith(
                  status: Act0WorldStateV1.locked,
                  isSelectable: false,
                  isLocked: true,
                  lessons: <Act0LessonCardV1>[world2Lesson],
                ),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();

    await completeCurrentLessonBlock(tester);

    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsOneWidget,
    );
    expect(find.text('World 1 complete'), findsOneWidget);
    expect(find.text('Poker from Zero'), findsOneWidget);
    expect(
      find.text('Unlocked now: World 2 - Hand Discipline'),
      findsOneWidget,
    );
    expect(find.text('Open next world'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_quality_cta')),
      findsNothing,
    );
    expect(find.textContaining(world2Lesson.title), findsNothing);

    tester
        .widget<FilledButton>(
          find.byKey(const Key('act0_shell_block_summary_continue_cta')),
        )
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsNothing,
    );
  });

  testWidgets('Canonical detached shell hides redundant blind marker dots', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    expect(find.byKey(const Key('act0_shell_bet_chip_SB')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bet_chip_BB')), findsOneWidget);
    expect(find.text('SB'), findsAtLeastNWidgets(1));
    expect(find.text('BB'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('act0_shell_marker_cluster_sb')), findsNothing);
    expect(find.byKey(const Key('act0_shell_marker_cluster_bb')), findsNothing);
    expect(find.byKey(const Key('act0_shell_seat_sublabel_sb')), findsNothing);
    expect(find.byKey(const Key('act0_shell_seat_sublabel_bb')), findsNothing);
  });

  testWidgets('Blind bet chips stay clear of center info card', (tester) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    final center = tester.getRect(
      find.byKey(const Key('act0_shell_center_info_card')),
    );
    final sbChip = tester.getRect(
      find.byKey(const Key('act0_shell_bet_chip_SB')),
    );
    final bbChip = tester.getRect(
      find.byKey(const Key('act0_shell_bet_chip_BB')),
    );

    expect(sbChip.overlaps(center), isFalse);
    expect(bbChip.overlaps(center), isFalse);
    expect(
      find.byKey(const Key('act0_shell_center_focus_badge')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_shell_center_pot_stat')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_center_to_call_stat')),
      findsOneWidget,
    );
    expect(find.text('Action on hero'), findsNothing);
    expect(find.text('PREFLOP'), findsOneWidget);
    expect(find.text('Pot 1.5 BB'), findsOneWidget);
    expect(find.text('To call 1 BB'), findsOneWidget);
  });

  testWidgets('Hero marker cluster stays clear of hero cards and seat label', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    final marker = tester.getRect(
      find.byKey(const Key('act0_shell_marker_cluster_btn')),
    );
    final heroSeat = tester.getRect(
      find.byKey(const Key('act0_shell_seat_node_btn')),
    );
    final heroK = tester.getRect(find.text('K').first);
    final heroT = tester.getRect(find.text('T').first);

    expect(marker.overlaps(heroSeat), isFalse);
    expect(marker.overlaps(heroK), isFalse);
    expect(marker.overlaps(heroT), isFalse);
    expect(find.textContaining('Hero'), findsWidgets);
  });

  testWidgets('Runner table renders canonical 6-max topology in stable order', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    for (final seatId in const <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']) {
      expect(find.byKey(Key('act0_shell_seat_node_$seatId')), findsOneWidget);
    }

    final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
    final btn = tester.getRect(
      find.byKey(const Key('act0_shell_seat_node_btn')),
    );
    final sb = tester.getRect(find.byKey(const Key('act0_shell_seat_node_sb')));
    final bb = tester.getRect(find.byKey(const Key('act0_shell_seat_node_bb')));
    final utg = tester.getRect(
      find.byKey(const Key('act0_shell_seat_node_utg')),
    );
    final hj = tester.getRect(find.byKey(const Key('act0_shell_seat_node_hj')));
    final co = tester.getRect(find.byKey(const Key('act0_shell_seat_node_co')));

    expect(btn.center.dy, greaterThan(table.center.dy));
    expect(utg.center.dy, lessThan(table.center.dy));
    expect(sb.center.dx, lessThan(table.center.dx));
    expect(bb.center.dx, lessThan(table.center.dx));
    expect(hj.center.dx, greaterThan(table.center.dx));
    expect(co.center.dx, greaterThan(table.center.dx));
    expect(sb.center.dy, greaterThan(bb.center.dy));
    expect(co.center.dy, greaterThan(hj.center.dy));
  });

  testWidgets(
    'Occupied opponents render face-down cards and folded seats do not',
    (tester) async {
      final table =
          Act0ShellStateV1.sample.currentLesson.taskList.first.runner.table;
      final expectedFaceDownCards = table.seats
          .where(
            (seat) =>
                !seat.isHero &&
                seat.isOccupied &&
                seat.isInHand &&
                !seat.isFolded &&
                seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceDown,
          )
          .fold<int>(0, (total, seat) => total + seat.holeCards.length);

      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

      expect(find.byKey(const Key('act0_shell_face_down_card')), findsWidgets);
      expect(
        tester
            .widgetList(find.byKey(const Key('act0_shell_face_down_card')))
            .length,
        expectedFaceDownCards,
      );
      expect(find.byKey(const Key('act0_shell_folded_badge')), findsOneWidget);
      expect(find.text('Folded'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_seat_node_utg')), findsOneWidget);
    },
  );

  testWidgets('Runner Continue enters Drill and option tap enters Review', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
    );

    await pumpTall(
      tester,
      host(state: stateWithLessons(<Act0LessonCardV1>[lesson])),
    );

    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();
    await completeVisibleTheoryTask(tester);
    await advanceTeachingToDrill(tester);

    expect(find.text('Fold'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Raise'), findsNothing);
    expect(find.byKey(const Key('act0_shell_continue_cta')), findsNothing);

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_correct')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsOneWidget);
  });

  testWidgets('Wrong drill option yields wrong review state', (tester) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);

    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_sharky_outcome_reaction')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_sharky_mascot')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_repair')),
      findsOneWidget,
    );
    final wrongReaction = tester.widget<Text>(
      find.byKey(const Key('act0_shell_sharky_outcome_reaction')),
    );
    expect(
      <String>{
        'Good spot to fix.',
        'This is repairable.',
        'Use the table, then retry.',
        'One calm retry.',
      }.contains(wrongReaction.data),
      isTrue,
    );
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_wrong')),
      findsOneWidget,
    );
    expect(find.text('You picked Fold'), findsOneWidget);
    expect(find.text('Better option: Raise'), findsOneWidget);
    expect(
      find.text('First in on the Button, folding gives up a playable spot.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_context_labels')),
      findsOneWidget,
    );
    expect(find.text('Hero acts'), findsWidgets);
    expect(find.text('Blinds posted'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_table_repair_callout')),
      findsNothing,
    );
    expect(find.textContaining('failed'), findsNothing);
    expect(find.textContaining('repaired'), findsNothing);
    expect(find.textContaining('cleared with error'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_btn')),
      findsOneWidget,
    );
    expect(find.text('Nice read.'), findsNothing);
  });

  testWidgets('Suboptimal drill option yields gold feedback tier', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_call')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_suboptimal')),
      findsOneWidget,
    );
    expect(find.text('You picked Call'), findsOneWidget);
    expect(find.text('Sharper line: Raise'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsOneWidget);
    expect(find.text('Almost there.'), findsNothing);
    expect(find.text('Nice read.'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_wrong')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_correct')),
      findsNothing,
    );
  });

  testWidgets('Wrong answer gets one in-lesson repair try', (tester) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_wrong')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsNothing);
    expect(find.byKey(const Key('act0_shell_option_raise')), findsOneWidget);
  });

  testWidgets('Lesson wrap-up waits until the final task', (tester) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_legal_context',
    );
    final followUpTask = Act0LessonTaskV1(
      taskId: '${drillTask.taskId}_follow_up',
      title: '${drillTask.title} follow up',
      phase: drillTask.phase,
      runner: drillTask.runner,
      rewardXp: drillTask.rewardXp,
      stepKind: drillTask.stepKind,
      taskFamily: drillTask.taskFamily,
      summary: drillTask.summary,
      lockedSummary: drillTask.lockedSummary,
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask, followUpTask],
    );

    await pumpCompact(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.text('One last check'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsNothing,
    );

    await advanceTeachingToDrill(tester);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
  });

  testWidgets('Final wrap-up of an early miss does not replay lesson tail', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_legal_context',
    );
    final followUpTask = Act0LessonTaskV1(
      taskId: '${drillTask.taskId}_follow_up',
      title: '${drillTask.title} follow up',
      phase: drillTask.phase,
      runner: drillTask.runner,
      rewardXp: drillTask.rewardXp,
      stepKind: drillTask.stepKind,
      taskFamily: drillTask.taskFamily,
      summary: drillTask.summary,
      lockedSummary: drillTask.lockedSummary,
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask, followUpTask],
    );

    await pumpCompact(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.text('One last check'), findsOneWidget);
    await advanceRunnerUntil(
      tester,
      () => find
          .byKey(const Key('act0_shell_action_panel'))
          .evaluate()
          .isNotEmpty,
      failureMessage: 'Final wrap-up did not advance into the retry drill.',
      maxTaps: 12,
    );
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsOneWidget,
    );
    expect(find.text('One last check'), findsNothing);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
  });

  testWidgets('Second wrong answer becomes a deeper Review leak', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await openBottomTabV1(tester, 'Review');
    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_mistake_card')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);
    expect(find.text('Deep leak'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_mistake_attempts_badge')),
      findsNothing,
    );

    await openBottomTabV1(tester, 'Home');
    expect(find.text('Fix next'), findsOneWidget);
    expect(find.textContaining('Fix '), findsWidgets);
    expect(find.text('Fix now'), findsOneWidget);

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_play_featured_card')),
      findsOneWidget,
    );
    expect(find.text('Fix next leak'), findsNothing);

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_recommended_focus')),
      180,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_profile_recommended_focus')),
      findsOneWidget,
    );
    expect(find.text('Fix a deep leak'), findsWidgets);
  });

  testWidgets('Correct repair try becomes a light fixed Review item', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();
    expect(find.text('Button open'), findsWidgets);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await openBottomTabV1(tester, 'Review');

    expect(find.text('Recovered lately'), findsOneWidget);
    expect(find.text('Clear path still open.'), findsOneWidget);
    expect(find.text('Replay for perfect'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_mistake_card')), findsNothing);

    await openBottomTabV1(tester, 'Home');
    expect(find.text('Continue'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_repair_panel')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Final lesson retry replays the miss before summary and can end as a quick fix',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final baseLesson = sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
      final drillTask = baseLesson.taskList.firstWhere(
        (task) => task.taskId == 'actions_legal_context',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: <Act0LessonTaskV1>[drillTask],
      );

      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.drill,
          state: stateWithLessons(<Act0LessonCardV1>[lesson]),
        ),
      );

      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.text('One last check'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_block_summary_card')),
        findsNothing,
      );

      await advanceRunnerUntil(
        tester,
        () => find
            .byKey(const Key('act0_shell_action_panel'))
            .evaluate()
            .isNotEmpty,
        failureMessage: 'Final lesson retry did not reopen the drill.',
        maxTaps: 12,
      );
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_block_summary_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_quick_fixes')),
        findsOneWidget,
      );
      expect(find.text('Quick fixes: 1'), findsOneWidget);
      expect(find.text('Deep leaks: 0'), findsOneWidget);
    },
  );

  testWidgets(
    'Missing the final lesson retry keeps the spot as a deep leak for Review',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final baseLesson = sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
      final drillTask = baseLesson.taskList.firstWhere(
        (task) => task.taskId == 'actions_legal_context',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: <Act0LessonTaskV1>[drillTask],
      );

      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.drill,
          state: stateWithLessons(<Act0LessonCardV1>[lesson]),
        ),
      );

      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.text('One last check'), findsOneWidget);

      await advanceRunnerUntil(
        tester,
        () => find
            .byKey(const Key('act0_shell_action_panel'))
            .evaluate()
            .isNotEmpty,
        failureMessage: 'Deep-leak retry did not reopen the drill.',
        maxTaps: 12,
      );
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_block_summary_card')),
        findsOneWidget,
      );
      expect(find.text('Deep leaks: 1'), findsOneWidget);
    },
  );

  testWidgets('Multiple final mistakes show one wrap-up intro only once', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final firstTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_legal_context',
    );
    final secondTask = Act0LessonTaskV1(
      taskId: '${firstTask.taskId}_second',
      title: '${firstTask.title} second',
      phase: firstTask.phase,
      runner: firstTask.runner,
      rewardXp: firstTask.rewardXp,
      stepKind: firstTask.stepKind,
      taskFamily: firstTask.taskFamily,
      summary: firstTask.summary,
      lockedSummary: firstTask.lockedSummary,
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[firstTask, secondTask],
    );

    await pumpCompact(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.text('One last check'), findsOneWidget);
    final wrapUpSupport = tester.widget<Text>(
      find.byKey(const Key('act0_shell_learning_rail_support_line')),
    );
    expect(wrapUpSupport.data, contains('You missed this earlier.'));
    expect(wrapUpSupport.data, contains('spots to revisit'));
    await advanceRunnerUntil(
      tester,
      () => find
          .byKey(const Key('act0_shell_action_panel'))
          .evaluate()
          .isNotEmpty,
      failureMessage:
          'Repeated wrap-up intro did not advance into the retry drill.',
      maxTaps: 12,
    );
    expect(find.text('One last check'), findsNothing);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.text('One last check'), findsNothing);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
  });

  testWidgets('Quick fix card can replay the repaired spot', (tester) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Clear path still open.'), findsOneWidget);
    expect(find.text('Replay for perfect'), findsOneWidget);
    await tester.ensureVisible(find.text('Replay for perfect'));
    await tester.tap(find.text('Replay for perfect'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('Correct drill option yields correct review state', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);

    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_sharky_outcome_reaction')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_sharky_mascot')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_happy')),
      findsOneWidget,
    );
    final correctReaction = tester.widget<Text>(
      find.byKey(const Key('act0_shell_sharky_outcome_reaction')),
    );
    expect(
      <String>{
        'Sharp read.',
        'Clean read.',
        'Good table check.',
        'Keep that cue.',
      }.contains(correctReaction.data),
      isTrue,
    );
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Button open'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_correct')),
      findsOneWidget,
    );
    expect(find.text('Best play: Raise'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_selected_label')),
      findsNothing,
    );
    expect(find.text('Better option: Raise'), findsNothing);
    expect(
      find.text(
        'First in on the Button, raising opens the pot and pressures the blinds.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_context_labels')),
      findsNothing,
    );
    expect(find.text('Button open'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_btn')),
      findsOneWidget,
    );
    expect(find.text('Almost there.'), findsNothing);
  });

  testWidgets('Detached runner fires sensory events for answers', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final baseLesson = sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
    final drillTask = baseLesson.taskList.firstWhere(
      (task) => task.taskId == 'actions_raise_drill',
    );
    final lesson = baseLesson.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
      primaryCtaLabel: 'Open lesson',
      tasks: <Act0LessonTaskV1>[drillTask],
    );

    final sounds = <UiSoundEventV1>[];
    final haptics = <UiHapticEventV1>[];
    UiSoundV1.overrideHandler(sounds.add);
    UiHapticsV1.setHandler(UiHapticEventV1.success, () async {
      haptics.add(UiHapticEventV1.success);
    });
    UiHapticsV1.setHandler(UiHapticEventV1.error, () async {
      haptics.add(UiHapticEventV1.error);
    });
    addTearDown(UiSoundV1.resetHandler);
    addTearDown(UiHapticsV1.resetHandlers);

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();

    expect(sounds, contains(UiSoundEventV1.error));
    expect(haptics, contains(UiHapticEventV1.error));

    sounds.clear();
    haptics.clear();

    await pumpTall(
      tester,
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.drill,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();

    expect(sounds, contains(UiSoundEventV1.success));
    expect(haptics, contains(UiHapticEventV1.success));
  });

  testWidgets('Action repair feedback falls back to table context truth', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere(
          (candidate) => candidate.lessonId == 'fold_check_call_raise',
        );
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'actions_fold_drill',
    );
    var phase = Act0LessonPhaseV1.drill;
    String? selectedOptionId;

    Widget repairHost() {
      return MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              final runner = task.runner.copyWith(
                phase: phase,
                selectedOptionId: selectedOptionId,
                teachingStepIndex: task.runner.teachingSteps.length,
              );
              return Act0LessonRunnerShellV1(
                runner: runner,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (option) {
                  setState(() {
                    selectedOptionId = option.id;
                    phase = Act0LessonPhaseV1.review;
                  });
                },
                onContinueReview: () {},
              );
            },
          ),
        ),
      );
    }

    await pumpTall(tester, repairHost());
    await tester.tap(find.byKey(const Key('act0_shell_option_call')));
    await tester.pumpAndSettle();

    expect(find.text('Facing a bet first'), findsOneWidget);
    expect(find.text('Better option: Fold'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_context_labels')),
      findsOneWidget,
    );
    expect(find.text('Facing a bet'), findsWidgets);
    expect(find.text('Pot 7 BB'), findsWidgets);
    expect(find.text('To call 2 BB'), findsWidgets);
  });

  testWidgets(
    'Canonical detached shell interaction back undoes review selection',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final baseLesson = sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
      final drillTask = baseLesson.taskList.firstWhere(
        (task) => task.taskId == 'actions_raise_drill',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: <Act0LessonTaskV1>[drillTask],
      );

      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.drill,
          state: stateWithLessons(<Act0LessonCardV1>[lesson]),
        ),
      );

      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_interaction_back_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Canonical detached shell interaction back from drill returns to teaching step',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final baseLesson = sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
      final drillTask = baseLesson.taskList.firstWhere(
        (task) => task.taskId == 'actions_raise_drill',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: <Act0LessonTaskV1>[drillTask],
      );

      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.drill,
          state: stateWithLessons(<Act0LessonCardV1>[lesson]),
        ),
      );

      await advanceTeachingToDrill(tester);
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_interaction_back_cta')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_learning_rail')), findsNothing);
    },
  );

  testWidgets('Runner renders lesson copy from runner state', (tester) async {
    const customRunner = Act0RunnerStateV1(
      lessonId: 'custom_lesson',
      lessonTitle: 'Custom lesson',
      lessonSubtitle: 'Custom lesson subtitle.',
      beatIndex: 1,
      beatCount: 3,
      phase: Act0LessonPhaseV1.drill,
      caption: 'Custom caption from state.',
      hint: 'Custom hint from state.',
      question: 'Custom state question?',
      options: <Act0RunnerOptionV1>[
        Act0RunnerOptionV1(
          id: 'alpha',
          label: 'Alpha',
          isCorrect: false,
          preferredLabel: 'Beta',
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: 'Alpha result.',
          feedbackReason: 'Alpha reason.',
        ),
        Act0RunnerOptionV1(
          id: 'beta',
          label: 'Beta',
          isCorrect: true,
          preferredLabel: 'Beta',
          quality: Act0FeedbackQualityV1.correct,
          feedbackTitle: 'Beta result.',
          feedbackReason: 'Beta reason.',
        ),
        Act0RunnerOptionV1(
          id: 'gamma',
          label: 'Gamma',
          isCorrect: false,
          preferredLabel: 'Beta',
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: 'Gamma result.',
          feedbackReason: 'Gamma reason.',
        ),
      ],
      selectedOptionId: 'beta',
      feedbackTitle: 'Custom result.',
      feedbackReason: 'Custom reason from state.',
      primaryCtaLabel: 'Next custom',
      nextLessonId: 'custom_next',
      returnTarget: 'learn',
      table: Act0TableStateV1(
        tableFormat: Act0TableFormatV1.sixMax,
        playerCount: 4,
        seats: <Act0SeatStateV1>[
          Act0SeatStateV1(
            seatId: 'x_btn',
            seatLabel: 'XBTN',
            displayName: 'Dealer',
            isDealerButton: true,
            stackLabel: '80 chips',
          ),
          Act0SeatStateV1(
            seatId: 'x_sb',
            seatLabel: 'XSB',
            displayName: 'Small',
            isSmallBlind: true,
            blindAmountLabel: '2 chips',
            currentBetLabel: '2 chips',
            bet: Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.call,
              label: 'CALL',
              amountLabel: '2 chips',
            ),
          ),
          Act0SeatStateV1(
            seatId: 'x_bb',
            seatLabel: 'XBB',
            displayName: 'Big',
            isBigBlind: true,
            blindAmountLabel: '4 chips',
          ),
          Act0SeatStateV1(
            seatId: 'x_hero',
            seatLabel: 'XCO',
            displayName: 'Custom hero',
            isHero: true,
            isActive: true,
            isLastAggressor: true,
            stackLabel: '120 chips',
          ),
        ],
        heroCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
        ],
        boardCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
          Act0CardStateV1(rank: '7', suit: 'c'),
        ],
        streetLabel: 'Custom street',
        potLabel: 'Pot 4 BB',
        toCallLabel: 'To call 2 BB',
        centerLabel: 'Custom center',
        actionTrail: <Act0ActionTrailItemV1>[
          Act0ActionTrailItemV1(label: 'XSB calls 2'),
          Act0ActionTrailItemV1(label: 'XCO raises'),
        ],
        activeSeatId: 'x_hero',
        heroSeatId: 'x_hero',
        highlightedSeatIds: <String>['x_hero'],
        highlightedCardIds: <String>['board_0'],
      ),
    );
    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: customRunner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.text('Custom state question?'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Pot 4 BB'), findsOneWidget);
    expect(find.text('To call 2 BB'), findsOneWidget);
    expect(find.text('XBTN'), findsOneWidget);
    expect(find.text('XSB'), findsOneWidget);
    expect(find.text('XBB'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_seat_node_x_hero')),
      findsOneWidget,
    );
    expect(find.text('2 chips'), findsWidgets);
    expect(find.text('4 chips'), findsOneWidget);
    expect(find.text('120 chips'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_action_trail')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_action_context_line')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_action_prompt_integrated_surface')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_bet_chip_CALL')), findsOneWidget);
    expect(find.text('Q'), findsOneWidget);
    expect(find.text('♥'), findsOneWidget);
    expect(find.text('KTs'), findsNothing);
  });

  testWidgets('Runner hides to-call pill when no bet is pending', (
    tester,
  ) async {
    final baseRunner = Act0ShellStateV1.sample.currentLesson.runner;
    final runner = baseRunner.copyWith(
      table: baseRunner.table.copyWith(
        streetLabel: 'Flop',
        potLabel: 'Pot 6 BB',
        toCallLabel: '',
        centerLabel: 'Name purpose',
        boardCards: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
          Act0CardStateV1(rank: '7', suit: 'c'),
          Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
        ],
        actionTrail: const <Act0ActionTrailItemV1>[
          Act0ActionTrailItemV1(label: 'BTN opened'),
          Act0ActionTrailItemV1(label: 'BB called'),
          Act0ActionTrailItemV1(label: 'Flop dealt'),
        ],
      ),
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.text('Name purpose'), findsOneWidget);
    expect(find.text('Pot 6 BB'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_center_to_call_stat')),
      findsNothing,
    );
    expect(find.textContaining('To call'), findsNothing);
  });

  testWidgets('Teaching focus highlights hero and board cards from state', (
    tester,
  ) async {
    final baseRunner = Act0ShellStateV1.sample.currentLesson.runner;
    final runner = baseRunner.copyWith(
      table: baseRunner.table.copyWith(
        heroCards: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
        ],
        boardCards: const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 'd', tone: Act0CardToneV1.red),
          Act0CardStateV1(rank: '7', suit: 'c'),
          Act0CardStateV1(rank: '2', suit: 'h', tone: Act0CardToneV1.red),
        ],
        highlightedCardIds: const <String>['hero_0', 'hero_1', 'board_0'],
      ),
    );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    final heroCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_card_hero_0')),
    );
    final secondHeroCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_card_hero_1')),
    );
    final boardCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_card_board_0')),
    );
    final plainBoardCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_card_board_1')),
    );

    expect(
      ((heroCard.decoration as BoxDecoration).border as Border).top.width,
      greaterThan(1),
    );
    expect(
      ((secondHeroCard.decoration as BoxDecoration).border as Border).top.width,
      greaterThan(1),
    );
    expect(
      ((boardCard.decoration as BoxDecoration).border as Border).top.width,
      greaterThan(1),
    );
    expect(
      ((plainBoardCard.decoration as BoxDecoration).border as Border).top.width,
      equals(1),
    );
  });

  testWidgets('Instruction anchor falls back to private card focus', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'your_first_hand');
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'your_first_hand_preflop',
    );
    final runner = task.runner.copyWith(teachingStepIndex: 0);

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    final firstHeroCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_card_hero_0')),
    );
    final secondHeroCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_card_hero_1')),
    );

    expect(
      ((firstHeroCard.decoration as BoxDecoration).border as Border).top.width,
      greaterThan(1),
    );
    expect(
      ((secondHeroCard.decoration as BoxDecoration).border as Border).top.width,
      greaterThan(1),
    );
  });

  testWidgets(
    'Active non-hero seat uses Act marker when center already owns decision price',
    (tester) async {
      final activeSeatRunner = Act0ShellStateV1
          .sample
          .currentLesson
          .taskList
          .first
          .runner
          .copyWith(
            table: Act0ShellStateV1
                .sample
                .currentLesson
                .taskList
                .first
                .runner
                .table
                .copyWith(
                  seats: <Act0SeatStateV1>[
                    const Act0SeatStateV1(
                      seatId: 'hero_btn',
                      seatLabel: 'BTN',
                      displayName: 'Hero',
                      isHero: true,
                      stackLabel: '100 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: 'A', suit: 's'),
                        Act0CardStateV1(
                          rank: 'Q',
                          suit: 'h',
                          tone: Act0CardToneV1.red,
                        ),
                      ],
                      cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                    ),
                    const Act0SeatStateV1(
                      seatId: 'sb_active',
                      seatLabel: 'SB',
                      displayName: 'Small blind',
                      isSmallBlind: true,
                      isActive: true,
                      blindAmountLabel: '0.5 BB',
                      currentBetLabel: '0.5 BB',
                      bet: Act0SeatBetStateV1(
                        kind: Act0SeatBetKindV1.post,
                        label: 'POST',
                        amountLabel: '0.5 BB',
                      ),
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: '?', suit: ''),
                        Act0CardStateV1(rank: '?', suit: ''),
                      ],
                    ),
                  ],
                  heroSeatId: 'hero_btn',
                  activeSeatId: 'sb_active',
                  highlightedSeatIds: <String>['sb_active'],
                ),
          );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: activeSeatRunner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_active_seat_ring_sb_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_marker_sb_active_act')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_sublabel_sb_active')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_bet_chip_POST')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_center_to_call_stat')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Highlighted seat does not show To act when another seat is active',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
          .copyWith(
            table: Act0ShellStateV1
                .sample
                .currentLesson
                .taskList
                .first
                .runner
                .table
                .copyWith(
                  seats: <Act0SeatStateV1>[
                    const Act0SeatStateV1(
                      seatId: 'hero_btn',
                      seatLabel: 'BTN',
                      displayName: 'Hero',
                      isHero: true,
                      stackLabel: '100 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: 'A', suit: 's'),
                        Act0CardStateV1(
                          rank: 'Q',
                          suit: 'h',
                          tone: Act0CardToneV1.red,
                        ),
                      ],
                      cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                    ),
                    const Act0SeatStateV1(
                      seatId: 'sb_highlight',
                      seatLabel: 'SB',
                      displayName: 'Small blind',
                      isSmallBlind: true,
                      currentBetLabel: '0.5 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: '?', suit: ''),
                        Act0CardStateV1(rank: '?', suit: ''),
                      ],
                    ),
                    const Act0SeatStateV1(
                      seatId: 'bb_active',
                      seatLabel: 'BB',
                      displayName: 'Big blind',
                      isBigBlind: true,
                      isActive: true,
                      currentBetLabel: '1 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: '?', suit: ''),
                        Act0CardStateV1(rank: '?', suit: ''),
                      ],
                    ),
                  ],
                  heroSeatId: 'hero_btn',
                  activeSeatId: 'bb_active',
                  highlightedSeatIds: <String>['sb_highlight'],
                ),
          );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.text('To act: 1 BB'), findsNothing);
      expect(find.text('To act: 0.5 BB'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_active_seat_ring_bb_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_marker_bb_active_act')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_sublabel_bb_active')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_active_seat_ring_sb_highlight')),
        findsNothing,
      );
    },
  );

  testWidgets('Explicit activeSeatId wins over stale seat.isActive flags', (
    tester,
  ) async {
    final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
        .copyWith(
          table: Act0ShellStateV1
              .sample
              .currentLesson
              .taskList
              .first
              .runner
              .table
              .copyWith(
                seats: <Act0SeatStateV1>[
                  const Act0SeatStateV1(
                    seatId: 'hero_btn',
                    seatLabel: 'BTN',
                    displayName: 'Hero',
                    isHero: true,
                    stackLabel: '100 BB',
                    holeCards: <Act0CardStateV1>[
                      Act0CardStateV1(rank: 'A', suit: 's'),
                      Act0CardStateV1(
                        rank: 'Q',
                        suit: 'h',
                        tone: Act0CardToneV1.red,
                      ),
                    ],
                    cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  ),
                  const Act0SeatStateV1(
                    seatId: 'sb_stale',
                    seatLabel: 'SB',
                    displayName: 'Small blind',
                    isSmallBlind: true,
                    isActive: true,
                    currentBetLabel: '0.5 BB',
                    holeCards: <Act0CardStateV1>[
                      Act0CardStateV1(rank: '?', suit: ''),
                      Act0CardStateV1(rank: '?', suit: ''),
                    ],
                  ),
                  const Act0SeatStateV1(
                    seatId: 'bb_current',
                    seatLabel: 'BB',
                    displayName: 'Big blind',
                    isBigBlind: true,
                    isActive: true,
                    currentBetLabel: '1 BB',
                    holeCards: <Act0CardStateV1>[
                      Act0CardStateV1(rank: '?', suit: ''),
                      Act0CardStateV1(rank: '?', suit: ''),
                    ],
                  ),
                ],
                heroSeatId: 'hero_btn',
                activeSeatId: 'bb_current',
              ),
        );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.text('To act: 1 BB'), findsNothing);
    expect(find.text('To act: 0.5 BB'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_bb_current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_marker_bb_current_act')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_seat_sublabel_bb_current')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_sb_stale')),
      findsNothing,
    );
  });

  testWidgets(
    'Active seat keeps To act sublabel only when center does not already own price',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
          .copyWith(
            table: Act0ShellStateV1
                .sample
                .currentLesson
                .taskList
                .first
                .runner
                .table
                .copyWith(
                  toCallLabel: '',
                  seats: <Act0SeatStateV1>[
                    const Act0SeatStateV1(
                      seatId: 'hero_btn',
                      seatLabel: 'BTN',
                      displayName: 'Hero',
                      isHero: true,
                      stackLabel: '100 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: 'A', suit: 's'),
                        Act0CardStateV1(
                          rank: 'Q',
                          suit: 'h',
                          tone: Act0CardToneV1.red,
                        ),
                      ],
                      cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                    ),
                    const Act0SeatStateV1(
                      seatId: 'co_active',
                      seatLabel: 'CO',
                      displayName: 'Cutoff',
                      isActive: true,
                      currentBetLabel: '2.5 BB',
                    ),
                  ],
                  heroSeatId: 'hero_btn',
                  activeSeatId: 'co_active',
                  highlightedSeatIds: <String>['co_active'],
                ),
          );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_marker_co_active_act')),
        findsOneWidget,
      );
      expect(find.text('To act: 2.5 BB'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_seat_sublabel_co_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_center_to_call_stat')),
        findsNothing,
      );
    },
  );

  testWidgets('Dealer puck stays visible while dealer sublabel stays quiet', (
    tester,
  ) async {
    final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
        .copyWith(
          table: Act0ShellStateV1
              .sample
              .currentLesson
              .taskList
              .first
              .runner
              .table
              .copyWith(
                seats: <Act0SeatStateV1>[
                  const Act0SeatStateV1(
                    seatId: 'hero_sb',
                    seatLabel: 'SB',
                    displayName: 'Hero',
                    isHero: true,
                    stackLabel: '100 BB',
                    holeCards: <Act0CardStateV1>[
                      Act0CardStateV1(rank: 'A', suit: 's'),
                      Act0CardStateV1(
                        rank: 'Q',
                        suit: 'h',
                        tone: Act0CardToneV1.red,
                      ),
                    ],
                    cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  ),
                  const Act0SeatStateV1(
                    seatId: 'btn_dealer',
                    seatLabel: 'BTN',
                    displayName: 'Dealer',
                    isDealerButton: true,
                  ),
                ],
                heroSeatId: 'hero_sb',
              ),
        );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_marker_btn_dealer_dealer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_seat_sublabel_btn_dealer')),
      findsNothing,
    );
  });

  testWidgets(
    'Seat semantics keep hero stable while target and selectable opponents stay distinct',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
          .copyWith(
            table: Act0ShellStateV1
                .sample
                .currentLesson
                .taskList
                .first
                .runner
                .table
                .copyWith(
                  seats: <Act0SeatStateV1>[
                    const Act0SeatStateV1(
                      seatId: 'hero_btn',
                      seatLabel: 'BTN',
                      displayName: 'Hero',
                      isHero: true,
                      stackLabel: '100 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: 'A', suit: 's'),
                        Act0CardStateV1(
                          rank: 'Q',
                          suit: 'h',
                          tone: Act0CardToneV1.red,
                        ),
                      ],
                      cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                    ),
                    const Act0SeatStateV1(
                      seatId: 'utg_target',
                      seatLabel: 'UTG',
                      displayName: 'Under the gun',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: '?', suit: ''),
                        Act0CardStateV1(rank: '?', suit: ''),
                      ],
                    ),
                    const Act0SeatStateV1(
                      seatId: 'co_selectable',
                      seatLabel: 'CO',
                      displayName: 'Cutoff',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: '?', suit: ''),
                        Act0CardStateV1(rank: '?', suit: ''),
                      ],
                    ),
                  ],
                  heroSeatId: 'hero_btn',
                  activeSeatId: null,
                  selectableSeatIds: const <String>[
                    'utg_target',
                    'co_selectable',
                  ],
                  highlightedSeatIds: const <String>['utg_target'],
                ),
          );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_seat_state_hero_btn_hero')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_state_utg_target_targetFocus')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_state_co_selectable_selectable')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_active_seat_ring_co_selectable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Wrong selected seat uses wrong state while target stays separate',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
          .copyWith(
            phase: Act0LessonPhaseV1.review,
            selectedOptionId: 'wrong_co',
            options: const <Act0RunnerOptionV1>[
              Act0RunnerOptionV1(
                id: 'wrong_co',
                label: 'CO',
                seatId: 'co_wrong',
                isCorrect: false,
                preferredLabel: 'UTG',
                betterAnswerLabel: 'UTG',
                quality: Act0FeedbackQualityV1.wrong,
                feedbackTitle: 'Almost there.',
                feedbackReason: 'CO is not the target seat in this spot.',
                repairFocusSeatIds: <String>['co_wrong', 'utg_target'],
              ),
              Act0RunnerOptionV1(
                id: 'right_utg',
                label: 'UTG',
                seatId: 'utg_target',
                isCorrect: true,
                preferredLabel: 'UTG',
                betterAnswerLabel: 'UTG',
                quality: Act0FeedbackQualityV1.correct,
                feedbackTitle: 'Sharp read.',
                feedbackReason: 'UTG is the target seat in this spot.',
              ),
            ],
            table: Act0ShellStateV1
                .sample
                .currentLesson
                .taskList
                .first
                .runner
                .table
                .copyWith(
                  seats: <Act0SeatStateV1>[
                    const Act0SeatStateV1(
                      seatId: 'hero_btn',
                      seatLabel: 'BTN',
                      displayName: 'Hero',
                      isHero: true,
                      stackLabel: '100 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: 'A', suit: 's'),
                        Act0CardStateV1(
                          rank: 'Q',
                          suit: 'h',
                          tone: Act0CardToneV1.red,
                        ),
                      ],
                      cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                    ),
                    const Act0SeatStateV1(
                      seatId: 'utg_target',
                      seatLabel: 'UTG',
                      displayName: 'Under the gun',
                    ),
                    const Act0SeatStateV1(
                      seatId: 'co_wrong',
                      seatLabel: 'CO',
                      displayName: 'Cutoff',
                    ),
                  ],
                  heroSeatId: 'hero_btn',
                  highlightedSeatIds: const <String>['utg_target'],
                ),
          );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_seat_state_co_wrong_wrongSelected')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_state_utg_target_targetFocus')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Active actor keeps the single amber focus when generic highlights also exist',
    (tester) async {
      final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
          .copyWith(
            table: Act0ShellStateV1
                .sample
                .currentLesson
                .taskList
                .first
                .runner
                .table
                .copyWith(
                  seats: <Act0SeatStateV1>[
                    const Act0SeatStateV1(
                      seatId: 'hero_btn',
                      seatLabel: 'BTN',
                      displayName: 'Hero',
                      isHero: true,
                      stackLabel: '100 BB',
                      holeCards: <Act0CardStateV1>[
                        Act0CardStateV1(rank: 'A', suit: 's'),
                        Act0CardStateV1(
                          rank: 'Q',
                          suit: 'h',
                          tone: Act0CardToneV1.red,
                        ),
                      ],
                      cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                    ),
                    const Act0SeatStateV1(
                      seatId: 'hj_active',
                      seatLabel: 'HJ',
                      displayName: 'Hijack',
                      isActive: true,
                      currentBetLabel: '2 BB',
                    ),
                    const Act0SeatStateV1(
                      seatId: 'co_other',
                      seatLabel: 'CO',
                      displayName: 'Cutoff',
                    ),
                  ],
                  heroSeatId: 'hero_btn',
                  activeSeatId: 'hj_active',
                  highlightedSeatIds: const <String>['hj_active', 'co_other'],
                  selectableSeatIds: const <String>['co_other'],
                ),
          );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_seat_state_hj_active_activeFocus')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_state_co_other_targetFocus')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_state_co_other_selectable')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Seat tap drill renders correct and wrong feedback from state', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'blinds_action_order');
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'blinds_first_actor',
    );
    var phase = Act0LessonPhaseV1.drill;
    String? selectedOptionId;
    var teachingStepIndex = 0;

    Widget seatHost() {
      return MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            final runner = normalizeAct0SeatTapRunnerV1(
              task.runner.copyWith(
                phase: phase,
                selectedOptionId: selectedOptionId,
                teachingStepIndex: teachingStepIndex,
              ),
            );
            return Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: runner,
                selectedTaskFamily: task.resolvedTaskFamily,
                onBack: () {},
                onContinueTheory: () {
                  setState(() {
                    teachingStepIndex += 1;
                  });
                },
                onChooseOption: (option) {},
                onChooseSeat: (seatId) {
                  setState(() {
                    selectedOptionId = runner.options
                        .firstWhere((option) => option.seatId == seatId)
                        .id;
                    phase = Act0LessonPhaseV1.review;
                  });
                },
                onContinueReview: () {},
              ),
            );
          },
        ),
      );
    }

    await pumpTall(tester, seatHost());
    await advanceTeachingToDrill(tester);
    expect(find.byKey(const Key('act0_shell_seat_tap_utg')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_seat_tap_btn')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_seat_tap_co')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_seat_tap_prompt')), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_co')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Almost there.'), findsNothing);
    expect(find.text('Better option: UTG'), findsOneWidget);
    expect(
      find.text('CO is not the target seat in this spot.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_context_labels')),
      findsNothing,
    );

    phase = Act0LessonPhaseV1.drill;
    selectedOptionId = null;
    teachingStepIndex = 0;
    await pumpTall(tester, seatHost());
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();

    expect(find.text('Correct answer: UTG'), findsOneWidget);
    expect(find.text('UTG acts first before the flop.'), findsOneWidget);
  });

  test('Level 1 lessons have deep task chains with required phases', () {
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    expect(world1.lessons.length, 8);
    expect(world1.lessons.map((lesson) => lesson.title), <String>[
      'What poker is',
      'Cards, ranks & suits',
      'Your first hand, dealt',
      'Fold, check, call, raise',
      'Blinds & action order',
      'The 6 positions',
      'Hand rankings, on the table',
      'Showdown & winning',
    ]);
    for (final lesson in world1.lessons) {
      expect(lesson.taskList.length, greaterThanOrEqualTo(6));
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.first.stepKind, Act0LessonStepKindV1.learn);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
      expect(<Act0LessonStepKindV1>[
        Act0LessonStepKindV1.review,
        Act0LessonStepKindV1.proveIt,
      ], contains(lesson.taskList.last.stepKind));
      expect(
        lesson.taskList.map((task) => task.phase),
        containsAll(<Act0LessonPhaseV1>[
          Act0LessonPhaseV1.theory,
          Act0LessonPhaseV1.drill,
          Act0LessonPhaseV1.review,
        ]),
      );
      expect(
        lesson.taskList.any((task) => task.runner.teachingSteps.isNotEmpty),
        isTrue,
        reason: '${lesson.lessonId} needs an explanatory step',
      );
      final seenTeachingTitles = <String>{};
      for (final task in lesson.taskList) {
        expect(
          task.runner.teachingSteps,
          isNotEmpty,
          reason: '${task.taskId} should not inherit an empty lesson intro',
        );
        final firstTeachingTitle = task.runner.teachingSteps.first.title;
        expect(
          seenTeachingTitles.add(firstTeachingTitle),
          isTrue,
          reason:
              '${task.taskId} repeats "$firstTeachingTitle" inside ${lesson.lessonId}',
        );
      }
      final firstScoredDrill = lesson.taskList.where(
        (task) =>
            task.phase == Act0LessonPhaseV1.drill &&
            task.runner.options.isNotEmpty,
      );
      if (firstScoredDrill.isNotEmpty) {
        expect(
          firstScoredDrill.first.runner.teachingSteps,
          isNotEmpty,
          reason:
              '${lesson.lessonId} should teach before the first scored drill',
        );
      }
    }
  });

  test('Level 1 content covers the beginner bridge to Level 2', () {
    final content = _worldContentText('world_1').toLowerCase();
    for (final topic in const <String>[
      'hero',
      'opponents',
      'goal',
      'pot',
      'stack',
      'blind',
      'blinds create',
      'rank',
      'suit',
      'private',
      'board',
      'preflop',
      'flop',
      'turn',
      'river',
      'showdown',
      'fold',
      'check',
      'call',
      'raise',
      'utg',
      'hj',
      'co',
      'btn',
      'sb',
      'bb',
      'pair',
      'two pair',
      'trips',
      'straight',
      'flush',
      'kicker',
      'tie',
      'split',
      'best five',
    ]) {
      expect(content, contains(topic), reason: 'Missing topic: $topic');
    }
  });

  test('World 2 has a real hand-discipline spine', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    expect(world2.title, 'Hand Discipline');
    expect(world2.lessons.map((lesson) => lesson.title), <String>[
      'Hand buckets',
      'Fold discipline',
      'Weak ace warning',
      'Continue or let go',
      'Discipline at the table',
      'Hand discipline checkpoint',
    ]);
    for (final lesson in world2.lessons) {
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(4),
        reason: '${lesson.lessonId} should not be a flat preview node',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.first.stepKind, Act0LessonStepKindV1.learn);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
      expect(
        lesson.taskList.map((task) => task.phase),
        containsAll(<Act0LessonPhaseV1>[
          Act0LessonPhaseV1.theory,
          Act0LessonPhaseV1.drill,
          Act0LessonPhaseV1.review,
        ]),
      );
      for (final task in lesson.taskList) {
        expect(
          task.runner.teachingSteps,
          isNotEmpty,
          reason: '${task.taskId} needs a teaching step before action',
        );
      }
    }
  });

  test(
    'Hand-ranking drills demonstrate two pair and best five on a real board',
    () {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere(
            (candidate) => candidate.lessonId == 'hand_rankings_table',
          );

      final twoPairTask = lesson.taskList.firstWhere(
        (candidate) => candidate.taskId == 'hand_rankings_two_pair_drill',
      );
      expect(
        twoPairTask.runner.table.heroCards.map((card) => card.rank).toList(),
        <String>['A', '7'],
      );
      expect(twoPairTask.runner.table.centerLabel, 'A with A and 7 with 7');
      expect(
        twoPairTask.runner.teachingSteps.first.body,
        contains('A with A and 7 with 7'),
      );

      final bestFiveTask = lesson.taskList.firstWhere(
        (candidate) => candidate.taskId == 'hand_rankings_best_five_drill',
      );
      expect(
        bestFiveTask.runner.table.heroCards.map((card) => card.rank).toList(),
        <String>['A', '7'],
      );
      expect(bestFiveTask.runner.table.centerLabel, 'Best five: A A 7 7 J');
      expect(
        bestFiveTask.runner.teachingSteps.first.body,
        contains('The 4 is visible, but it does not play.'),
      );
    },
  );

  test('Hand-ranking drills keep trips straight and flush truth explicit', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'hand_rankings_table');

    final tripsTask = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'hand_rankings_trips_drill',
    );
    expect(tripsTask.runner.caption, contains('Trips and sets'));
    expect(
      tripsTask.runner.options
          .firstWhere((option) => option.id == 'trips')
          .feedbackReason,
      contains('ranks above two pair'),
    );

    final straightTask = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'hand_rankings_straight_drill',
    );
    expect(straightTask.runner.caption, contains('five ranks in a row'));
    expect(
      straightTask.runner.options
          .firstWhere((option) => option.id == 'five_in_row')
          .feedbackReason,
      contains('five ranks in sequence'),
    );

    final flushTask = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'hand_rankings_flush_drill',
    );
    expect(flushTask.runner.caption, contains('five cards of one suit'));
    expect(
      flushTask.runner.options
          .firstWhere((option) => option.id == 'flush')
          .feedbackReason,
      contains('ranks above a straight'),
    );
  });

  test('Value-purpose copy stays accurate on an A-high flop', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_5')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'why_bets_happen');

    final valueTask = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'w4_value_purpose',
    );

    expect(
      valueTask.runner.table.boardCards.map((card) => card.rank).toList(),
      <String>['A', '7', '2'],
    );
    expect(
      valueTask.runner.table.heroCards.map((card) => card.rank).toList(),
      <String>['A', 'Q'],
    );
    expect(valueTask.runner.teachingSteps.first.body, contains('worse aces'));
    expect(
      valueTask.runner.teachingSteps.first.body,
      isNot(contains('ace-high hands')),
    );
  });

  test('A7 and KQ examples keep preflop and postflop truth separated', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    final tasks = _allAct0TasksV1();

    final dominatedLesson = world2.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'weak_ace_warning',
    );
    final dominatedTask = _taskByIdV1(
      tasks,
      'weak_ace_warning_w3_dominated_fold',
    );

    expect(
      dominatedTask.runner.caption,
      contains('CO opened. Hero is BTN with A7o.'),
    );
    expect(
      dominatedTask.runner.teachingSteps.first.body,
      contains('when someone opened first'),
    );

    final rankingsLesson = world1.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'hand_rankings_table',
    );
    final twoPairTask = rankingsLesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'hand_rankings_two_pair_drill',
    );

    expect(
      twoPairTask.runner.table.heroCards.map((card) => card.rank).toList(),
      <String>['A', '7'],
    );
    expect(twoPairTask.runner.teachingSteps.first.body, contains('two pair'));

    final kqoContinueTask = _taskByIdV1(
      tasks,
      'continue_or_let_go_medium_call_or_fold',
    );

    expect(kqoContinueTask.runner.caption, contains('Hero is BTN with KQo'));
    expect(kqoContinueTask.runner.table.streetLabel, 'Preflop');
    expect(kqoContinueTask.runner.table.boardCards, isEmpty);
    expect(
      kqoContinueTask.runner.teachingSteps.first.body,
      contains('call a simple open'),
    );

    final purposeLesson = world5.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'why_bets_happen',
    );
    final bluffTask = purposeLesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'w4_bluff_purpose',
    );

    expect(
      bluffTask.runner.table.heroCards.map((card) => card.rank).toList(),
      <String>['K', 'Q'],
    );
    expect(
      bluffTask.runner.table.boardCards.map((card) => card.rank).toList(),
      <String>['A', '7', '2'],
    );
    expect(bluffTask.runner.table.centerLabel, 'Missed hand');
    expect(
      bluffTask.runner.options
          .firstWhere((option) => option.id == 'value')
          .feedbackReason,
      contains('Hero missed'),
    );
  });

  test(
    'Active W1-W12 runner tasks keep street and board-card counts aligned',
    () {
      final state = Act0ShellStateV1.sample;

      for (var index = 1; index <= 12; index++) {
        final world = state.worldById('world_$index');
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final table = task.runner.table;
            final boardCount = table.boardCards.length;
            switch (table.streetLabel) {
              case 'Preflop':
                expect(
                  boardCount,
                  0,
                  reason:
                      '${task.taskId} should show no board cards on Preflop',
                );
              case 'Flop':
                expect(
                  boardCount,
                  3,
                  reason: '${task.taskId} should show 3 board cards on Flop',
                );
              case 'Turn':
                expect(
                  boardCount,
                  4,
                  reason: '${task.taskId} should show 4 board cards on Turn',
                );
              case 'River':
                expect(
                  boardCount,
                  5,
                  reason: '${task.taskId} should show 5 board cards on River',
                );
              default:
                fail(
                  '${task.taskId} uses unexpected street label '
                  '${table.streetLabel}',
                );
            }
          }
        }
      }
    },
  );

  test('Known preflop inherited-board leak family keeps empty boards', () {
    final matchingTasks = <Act0LessonTaskV1>[
      _taskByIdV1(_allAct0TasksV1(), 'continue_or_let_go_medium_call_or_fold'),
      _taskByIdV1(_allAct0TasksV1(), 'fold_discipline_facing_fold'),
      _taskByIdV1(_allAct0TasksV1(), 'weak_ace_warning_w3_dominated_fold'),
      _taskByIdV1(
        _allAct0TasksV1(),
        'preflop_framework_checkpoint_checkpoint_table_frame',
      ),
      _taskByIdV1(_allAct0TasksV1(), 'w6_checkpoint_table_combo_weight'),
      _taskByIdV1(_allAct0TasksV1(), 'w7_ajs_btn_25bb_transfer'),
      _taskByIdV1(_allAct0TasksV1(), 'w7_ajs_btn_100bb_transfer'),
    ];

    for (final task in matchingTasks) {
      expect(task.runner.table.streetLabel, 'Preflop');
      expect(
        task.runner.table.boardCards,
        isEmpty,
        reason:
            '${task.runner.lessonId}/${task.taskId} should not inherit flop cards into a preflop spot',
      );
    }
  });

  test(
    'Early-seat hero-action runners keep prompt, active, and hero ownership aligned',
    () {
      final tasks = _allAct0TasksV1();

      final expectedHeroSeatByTaskId = <String, String>{
        'hand_discipline_buckets_trash': 'utg',
        'fold_discipline_early_fold': 'utg',
        'apply_utg_fold': 'utg',
        'discipline_checkpoint_checkpoint_table_discipline': 'hj',
        'position_apply_early_fold': 'utg',
      };

      for (final entry in expectedHeroSeatByTaskId.entries) {
        _expectHeroOwnershipAlignmentV1(
          _taskByIdV1(tasks, entry.key),
          entry.value,
        );
      }
    },
  );

  test('No BTN Hero residue remains in early-seat hero-action runners', () {
    final tasks = _allAct0TasksV1();

    for (final taskId in const <String>[
      'hand_discipline_buckets_trash',
      'fold_discipline_early_fold',
      'apply_utg_fold',
      'discipline_checkpoint_checkpoint_table_discipline',
      'position_apply_early_fold',
    ]) {
      _expectNoBtnHeroResidueV1(_taskByIdV1(tasks, taskId));
    }
  });

  test('Early-seat unopened actionTrail aligns with active and hero ownership', () {
    final tasks = _allAct0TasksV1();

    final expectedActorSeatByTaskId = <String, String>{
      'hand_discipline_buckets_trash': 'utg',
      'fold_discipline_early_fold': 'utg',
      'apply_utg_fold': 'utg',
      'same_hand_different_seat_same_hand_early_fold': 'utg',
      'position_apply_early_fold': 'utg',
      'position_apply_hj_fold': 'hj',
      'position_checkpoint_position_checkpoint_early_fold': 'utg',
      'preflop_first_in_open_w3_early_fold': 'utg',
      'preflop_framework_checkpoint_w3_checkpoint_fold': 'utg',
    };

    for (final entry in expectedActorSeatByTaskId.entries) {
      final task = _taskByIdV1(tasks, entry.key);
      final table = task.runner.table;
      expect(
        _finalActionTrailActorSeatIdV1(task),
        entry.value,
        reason:
            '${task.taskId} should end its trail on the visible acting seat',
      );
      expect(
        table.activeSeatId,
        entry.value,
        reason:
            '${task.taskId} should keep activeSeatId aligned with the final trail actor',
      );
      expect(
        table.heroSeatId,
        entry.value,
        reason:
            '${task.taskId} should keep hero ownership aligned with the final trail actor',
      );
    }
  });

  test(
    'Inherited feedback titles stay aligned with the active decision family',
    () {
      final state = Act0ShellStateV1.sample;
      final tasks = <Act0LessonTaskV1>[];
      for (var index = 1; index <= 12; index++) {
        tasks.addAll(
          state
              .worldById('world_$index')
              .lessons
              .expand((lesson) => lesson.taskList),
        );
      }

      final expectations =
          <({String taskId, Act0FeedbackQualityV1 quality, String title})>[
            (
              taskId: 'w4_bluff_pressure',
              quality: Act0FeedbackQualityV1.suboptimal,
              title: 'Legal, but betting is sharper.',
            ),
            (
              taskId: 'w4_bad_bluff',
              quality: Act0FeedbackQualityV1.correct,
              title: 'Check is the cleaner line.',
            ),
            (
              taskId: 'w9_m_ratio_green_zone',
              quality: Act0FeedbackQualityV1.correct,
              title: 'Green zone gives room.',
            ),
            (
              taskId: 'w9_checkpoint_review',
              quality: Act0FeedbackQualityV1.correct,
              title: 'Pressure comes first.',
            ),
            (
              taskId: 'w10_overbluff_punish',
              quality: Act0FeedbackQualityV1.correct,
              title: 'Selective bluff-catch works.',
            ),
          ];

      for (final entry in expectations) {
        final task = tasks.firstWhere(
          (candidate) => candidate.taskId == entry.taskId,
        );
        final option = task.runner.options.firstWhere(
          (candidate) => candidate.quality == entry.quality,
        );

        expect(option.feedbackTitle, entry.title);
        expect(
          option.feedbackTitle,
          isNot(
            anyOf(
              'Raise is the clean open.',
              'Limp is legal, but raise is sharper.',
              'Effective stack: correct.',
              '6-max: wider open.',
              'Full ring: tighten early.',
            ),
          ),
          reason:
              '${entry.taskId} should not keep an inherited title from another concept family',
        );
      }
    },
  );

  test(
    'Preflop facing-open feedback stays specific without adding branch bloat',
    () {
      final tasks = _allAct0TasksV1();

      final kqoTask = _taskByIdV1(
        tasks,
        'continue_or_let_go_medium_call_or_fold',
      );
      final j8oTask = _taskByIdV1(tasks, 'fold_discipline_facing_fold');
      final a7oTask = _taskByIdV1(tasks, 'weak_ace_warning_w3_dominated_fold');

      final kqoCorrect = kqoTask.runner.options.firstWhere(
        (option) => option.isCorrect,
      );
      final kqoWrong = kqoTask.runner.options.firstWhere(
        (option) => option.quality == Act0FeedbackQualityV1.wrong,
      );
      expect(kqoCorrect.feedbackReason, contains('CO open'));
      expect(kqoCorrect.feedbackReason, contains('beginner baseline'));
      expect(kqoWrong.feedbackReason, contains('Folding is too tight'));
      expect(kqoWrong.feedbackReason, isNot(contains('playable enough')));

      final j8oCorrect = j8oTask.runner.options.firstWhere(
        (option) => option.isCorrect,
      );
      final j8oWrong = j8oTask.runner.options.firstWhere(
        (option) => option.quality == Act0FeedbackQualityV1.wrong,
      );
      expect(j8oCorrect.feedbackReason, contains('CO open'));
      expect(j8oCorrect.feedbackReason, contains('J8o'));
      expect(j8oWrong.feedbackReason, contains('Late position helps'));
      expect(j8oWrong.feedbackReason, contains('CO open'));

      final a7oCorrect = a7oTask.runner.options.firstWhere(
        (option) => option.isCorrect,
      );
      final a7oWrong = a7oTask.runner.options.firstWhere(
        (option) => option.quality == Act0FeedbackQualityV1.wrong,
      );
      expect(a7oCorrect.feedbackReason, contains('better aces'));
      expect(a7oCorrect.feedbackReason, contains('domination'));
      expect(a7oWrong.feedbackReason, contains('ace looks tempting'));
      expect(a7oWrong.feedbackReason, contains('dominated'));
    },
  );

  test(
    'Simplified preflop continue binaries keep beginner-baseline framing when aggressive options are omitted',
    () {
      for (final task in _simplifiedPreflopContinueCandidatesV1()) {
        final correct = task.runner.options.firstWhere(
          (option) => option.isCorrect,
        );
        expect(
          task.runner.question.toLowerCase(),
          contains('simple'),
          reason:
              '${task.taskId} should scope the binary spot as a simple beginner response',
        );
        expect(
          correct.feedbackReason,
          contains('beginner baseline'),
          reason:
              '${task.taskId} should frame the omitted aggressive branch as outside the beginner baseline',
        );
        expect(
          correct.feedbackReason,
          contains('simple continue'),
          reason:
              '${task.taskId} should name the continue as the simple baseline action',
        );
      }
    },
  );

  test(
    'Three-option labels avoid explanation-style copy outside the allowlist',
    () {
      final explanationLabels = _threeOptionRiskLabelsV1()
          .where(
            (row) =>
                _isExplanationStyleOptionLabelV1(row.$2.label) &&
                row.$1.runner.options.length == 3,
          )
          .toList();

      expect(
        explanationLabels,
        isEmpty,
        reason:
            'Three-option answer labels should name the choice, not embed the reason inside the button.',
      );
    },
  );

  test(
    'Representative compact three-option tasks stay inside the answer-label budget',
    () {
      final tasks = <Act0LessonTaskV1>[
        _taskByIdV1(
          _allAct0TasksV1(),
          'discipline_checkpoint_checkpoint_table_discipline',
        ),
        _taskByIdV1(_allAct0TasksV1(), 'w7_ajs_btn_25bb_transfer'),
        _taskByIdV1(_allAct0TasksV1(), 'w12_pretty_hand_bad_price_fold'),
      ];

      for (final task in tasks) {
        for (final option in task.runner.options) {
          expect(
            _isExplanationStyleOptionLabelV1(option.label),
            isFalse,
            reason:
                '${task.taskId} should keep reasons in feedback, not labels',
          );
          expect(
            option.label.length,
            lessThanOrEqualTo(28),
            reason:
                '${task.taskId}/${option.id} should stay inside the compact 3-option label budget',
          );
        }
      }
    },
  );

  test(
    'Admitted W5 to W8 teaching-step intro bodies stay inside the cognitive-load budget',
    () {
      for (final (task, step) in _admittedTeachingStepBudgetRowsV1()) {
        expect(
          _wordCountV1(step.body),
          lessThanOrEqualTo(18),
          reason:
              '${task.taskId}/${step.title} should teach one idea without turning into a paragraph block',
        );
      }
    },
  );

  test('Teaching-step jargon helper finds only current advanced-term rows', () {
    final rows = _teachingStepJargonRowsV1();
    expect(rows, isNotEmpty);
    expect(
      rows.map((row) => row.$1.taskId),
      containsAll(<String>[
        'w6_combo_counts_intro',
        'w6_ak_combos',
        'w7_spr_intro',
      ]),
    );
  });

  test(
    'Active drill triplets stay below the thin-repetition threshold outside allowlist',
    () {
      final offenders = _duplicateDrillTripletClustersV1().entries
          .where((entry) => entry.value.length > 3)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason: offenders
            .map(
              (entry) =>
                  '${entry.value.length}x ${entry.key.$1} | ${entry.key.$2} | ${entry.key.$3}',
            )
            .join('\n'),
      );
    },
  );

  test('C1 to C4 early-route duplicate clusters stay compressed', () {
    expect(
      _countDrillTripletMatchesV1(
        'CO opened. Hero is BTN with KQo.',
        'Playable hand in position: call keeps the hand in.',
        'What is the simple response?',
      ),
      lessThanOrEqualTo(3),
    );

    expect(
      _countDrillTripletMatchesV1(
        'Folded to BTN with KTs.',
        'First in and late position: opening is the clean action.',
        'What is the simple first-in action?',
      ),
      lessThanOrEqualTo(3),
    );

    expect(
      _countDrillTripletMatchesV1(
        'Late seats see more actions before deciding.',
        'Button is the clearest late seat.',
        'Which seat acts latest after the flop?',
      ),
      lessThanOrEqualTo(3),
    );

    expect(
      _countDrillTripletMatchesV1(
        'Early seats act with less information than late seats.',
        'UTG is early. BTN is late.',
        'Which seat is early preflop?',
      ),
      lessThanOrEqualTo(3),
    );

    expect(
      _countDrillTripletMatchesV1(
        'Unopened pot. Hero is early with ATo.',
        'The same hand is less comfortable from early position.',
        'What is the disciplined action?',
      ),
      lessThanOrEqualTo(2),
    );
  });

  testWidgets('Opponent face-up cards render from seat hole cards', (
    tester,
  ) async {
    final runner = Act0ShellStateV1.sample.currentLesson.taskList.first.runner
        .copyWith(
          table: Act0ShellStateV1
              .sample
              .currentLesson
              .taskList
              .first
              .runner
              .table
              .copyWith(
                seats: <Act0SeatStateV1>[
                  const Act0SeatStateV1(
                    seatId: 'hero_btn',
                    seatLabel: 'BTN',
                    displayName: 'Hero',
                    isHero: true,
                    stackLabel: '100 BB',
                    holeCards: <Act0CardStateV1>[
                      Act0CardStateV1(rank: 'A', suit: 's'),
                      Act0CardStateV1(
                        rank: 'Q',
                        suit: 'h',
                        tone: Act0CardToneV1.red,
                      ),
                    ],
                    cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  ),
                  const Act0SeatStateV1(
                    seatId: 'sb_showdown',
                    seatLabel: 'SB',
                    displayName: 'Small blind',
                    isOccupied: true,
                    isInHand: true,
                    stackLabel: '97 BB',
                    holeCards: <Act0CardStateV1>[
                      Act0CardStateV1(rank: 'K', suit: 'c'),
                      Act0CardStateV1(rank: 'J', suit: 'c'),
                    ],
                    cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
                  ),
                ],
                heroSeatId: 'hero_btn',
                activeSeatId: 'hero_btn',
              ),
        );

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('act0_shell_face_down_card')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_card_sb_showdown_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_card_sb_showdown_1')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_card_hero_0')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_card_hero_1')), findsOneWidget);
  });

  testWidgets(
    'Board tap reveals interactive showdown why line and highlights winners',
    (tester) async {
      final seedRunner =
          Act0ShellStateV1.sample.currentLesson.taskList.first.runner;
      final interactiveRunner = seedRunner.copyWith(
        lessonId: 'flush_rank_interactive',
        table: seedRunner.table.copyWith(
          boardCards: const <Act0CardStateV1>[
            Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
            Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
            Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
            Act0CardStateV1(rank: 'Q', suit: 'c'),
            Act0CardStateV1(rank: '2', suit: 'c'),
          ],
          heroCards: const <Act0CardStateV1>[
            Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
            Act0CardStateV1(rank: '3', suit: 'h', tone: Act0CardToneV1.red),
          ],
          highlightedCardIds: const <String>[],
          seats: <Act0SeatStateV1>[
            const Act0SeatStateV1(
              seatId: 'hero_btn',
              seatLabel: 'BTN',
              displayName: 'Hero',
              isHero: true,
              isInHand: true,
              isOccupied: true,
              holeCards: <Act0CardStateV1>[
                Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
                Act0CardStateV1(rank: '3', suit: 'h', tone: Act0CardToneV1.red),
              ],
              cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
            ),
            const Act0SeatStateV1(
              seatId: 'sb_showdown',
              seatLabel: 'SB',
              displayName: 'Small blind',
              isInHand: true,
              isOccupied: true,
              holeCards: <Act0CardStateV1>[
                Act0CardStateV1(rank: 'K', suit: 's'),
                Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
              ],
              cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
            ),
          ],
        ),
      );

      await pumpTall(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: interactiveRunner,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      final before = tester.widget<Container>(
        find.byKey(const Key('act0_shell_card_board_0')),
      );
      final beforeDecoration = before.decoration! as BoxDecoration;
      final beforeBorder = beforeDecoration.border! as Border;
      expect(beforeBorder.top.width, 1);

      await tester.tap(find.byKey(const Key('act0_shell_card_board_0')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_showdown_explain_line')),
        findsOneWidget,
      );
      expect(find.textContaining('Flush'), findsWidgets);

      final after = tester.widget<Container>(
        find.byKey(const Key('act0_shell_card_board_0')),
      );
      final afterDecoration = after.decoration! as BoxDecoration;
      final afterBorder = afterDecoration.border! as Border;
      expect(afterBorder.top.width, greaterThan(1));
    },
  );

  testWidgets(
    'Trail history drill embeds temporal context into the prompt owner',
    (tester) async {
      final trailTask = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((l) => l.lessonId == 'your_first_hand')
          .taskList
          .firstWhere((t) => t.taskId == 'your_first_hand_action_trail');
      await pumpCompact(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: trailTask.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                teachingStepIndex: trailTask.runner.teachingSteps.length,
              ),
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('act0_shell_action_trail')), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_center_focus_badge')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_action_prompt_integrated_surface')),
        findsOneWidget,
      );
      expect(find.text('Trail check'), findsOneWidget);
      final contextLine = tester.widget<Text>(
        find.byKey(const Key('act0_shell_action_context_line')),
      );
      expect(contextLine.data, contains('Current street: River'));
      expect(contextLine.data, contains('Trail item: Flop'));
      expect(find.text('Hand history'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(
            const Key('act0_shell_action_prompt_integrated_surface'),
          ),
          matching: find.byKey(const Key('act0_shell_action_panel')),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Review action trail keeps replay controls without pot sweep on review',
    (tester) async {
      final trailTask = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((l) => l.lessonId == 'your_first_hand')
          .taskList
          .firstWhere((t) => t.taskId == 'your_first_hand_action_trail');
      final reviewRunner = trailTask.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: 'bb_check',
      );
      await pumpCompact(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: reviewRunner,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_action_trail_icon')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_action_trail_latest_badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_action_trail_replay_controls')),
        findsOneWidget,
      );
      expect(find.textContaining('latest action'), findsOneWidget);

      // Phase 2: verify that answering a drill shows completion toast but no
      // pot-sweep overlay. Use the stateful host on the check-action drill.
      await pumpCompact(tester, host());
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      await completeVisibleTheoryTask(tester);
      await advanceTeachingToDrill(tester);

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_reward_lane')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_total')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_progress')),
        findsOneWidget,
      );
      final toast = tester.getRect(
        find.byKey(const Key('act0_shell_completion_toast')),
      );
      final utg = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_utg')),
      );
      final center = tester.getRect(
        find.byKey(const Key('act0_shell_center_info_card')),
      );
      expect(toast.top, greaterThan(utg.bottom));
      expect(toast.bottom, lessThan(center.top));
      expect(
        find.byKey(const Key('act0_shell_pot_sweep_moment')),
        findsNothing,
      );
    },
  );

  testWidgets('Pot sweep appears for showdown win review moments', (
    tester,
  ) async {
    final showdownTask = Act0ShellStateV1.sample.lessons
        .firstWhere((lesson) => lesson.lessonId.contains('showdown'))
        .taskList
        .firstWhere((task) => task.taskId.contains('showdown'));
    final runner = showdownTask.runner.copyWith(
      phase: Act0LessonPhaseV1.review,
      feedbackReason: 'At showdown, the best hand wins the pot.',
      table: showdownTask.runner.table.copyWith(potLabel: 'Pot 12 BB'),
    );

    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_pot_sweep_moment')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_pot_sweep_label')), findsOneWidget);
    final potSweepLabel = tester.widget<Text>(
      find.byKey(const Key('act0_shell_pot_sweep_label')),
    );
    expect(potSweepLabel.maxLines, 3);
    expect(potSweepLabel.overflow, TextOverflow.fade);
  });

  testWidgets('Action trail reveals appended step after state change', (
    tester,
  ) async {
    final trailTask = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'your_first_hand')
        .taskList
        .firstWhere((task) => task.taskId == 'your_first_hand_action_trail');
    final allSteps = trailTask.runner.table.actionTrail;
    expect(allSteps.length, greaterThanOrEqualTo(3));

    final notifier = ValueNotifier<Act0RunnerStateV1>(
      trailTask.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        table: trailTask.runner.table.copyWith(
          actionTrail: allSteps.take(2).toList(growable: false),
        ),
      ),
    );

    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<Act0RunnerStateV1>(
            valueListenable: notifier,
            builder: (context, runner, _) {
              return Act0LessonRunnerShellV1(
                runner: runner,
                tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_action_trail_step_2')),
      findsNothing,
    );

    notifier.value = trailTask.runner.copyWith(
      phase: Act0LessonPhaseV1.review,
      table: trailTask.runner.table.copyWith(
        actionTrail: allSteps.take(3).toList(growable: false),
      ),
    );

    await tester.pump();
    expect(
      find.byKey(const Key('act0_shell_action_trail_step_2')),
      findsNothing,
    );

    await tester.pump(const Duration(milliseconds: 160));
    expect(
      find.byKey(const Key('act0_shell_action_trail_step_2')),
      findsOneWidget,
    );
  });

  test('Blinds lesson explains money in big-blind units', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'blinds_action_order');
    final theoryTask = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'blinds_theory',
    );

    final teachingText = theoryTask.runner.teachingSteps
        .map(
          (step) => '${step.title} ${step.body} ${step.focusLabels.join(' ')}',
        )
        .join(' ');

    expect(teachingText, contains('real chips or money'));
    expect(teachingText, contains('count them in big blinds'));
    expect(teachingText, contains('3 BB open means three times that price'));
  });

  test('First lesson frames Holdem cash and hidden cards explicitly', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'what_poker_is');
    final theoryTask = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'what_poker_is_theory',
    );

    final teachingText = theoryTask.runner.teachingSteps
        .map(
          (step) => '${step.title} ${step.body} ${step.focusLabels.join(' ')}',
        )
        .join(' ');

    expect(teachingText, contains("No-Limit Hold'em cash"));
    expect(teachingText, contains('chip values stay stable'));
    expect(teachingText, contains('hole cards stay hidden'));
  });

  testWidgets('First lesson starts with hidden hero cards on the table', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'what_poker_is');
    final runner = lesson.taskList
        .firstWhere((candidate) => candidate.taskId == 'what_poker_is_theory')
        .runner;

    await pumpTall(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_card_hero_0')), findsNothing);
    expect(find.byKey(const Key('act0_shell_card_hero_1')), findsNothing);
    expect(find.text('Blinds posted'), findsWidgets);
  });

  test('World 2 content covers hand discipline without strategy jumps', () {
    final content = _worldContentText('world_2').toLowerCase();
    for (final topic in const <String>[
      'bucket',
      'premium',
      'strong',
      'trash',
      'fold',
      'weak',
      'pressure',
      'dominated',
      'continue',
      'stack',
    ]) {
      expect(content, contains(topic), reason: 'Missing World 2 topic: $topic');
    }
    for (final deferred in const <String>[
      'range construction',
      'solver',
      '3-bet',
      'icm',
      'initiative',
    ]) {
      expect(content, isNot(contains(deferred)));
    }
  });

  test('World 2 has enough true decision reps before World 3', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    final decisionDrills = world2.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(8),
      reason:
          'World 2 should provide enough real choices before position world',
    );
  });

  test('World 2 includes suboptimal literacy as non-punitive growth', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    final suboptimalOptions = world2.lessons
        .expand((lesson) => lesson.taskList)
        .expand((task) => task.runner.options)
        .where((option) => option.quality == Act0FeedbackQualityV1.suboptimal)
        .toList();

    expect(
      suboptimalOptions,
      isNotEmpty,
      reason: 'World 2 needs at least one playable-but-sharper line',
    );

    final hasPlayableLanguage = suboptimalOptions.any(
      (option) =>
          option.feedbackTitle.toLowerCase().contains('playable') ||
          option.feedbackReason.toLowerCase().contains('legal'),
    );
    expect(
      hasPlayableLanguage,
      isTrue,
      reason: 'Suboptimal feedback should frame growth, not punishment',
    );
  });

  test('World 2 keeps beginner-safe no-chart framing', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    final applyIntro = world2.lessons
        .firstWhere((lesson) => lesson.lessonId == 'hand_discipline_apply')
        .taskList
        .first
        .runner;
    final checkpoint = world2.lessons
        .firstWhere((lesson) => lesson.lessonId == 'discipline_checkpoint')
        .taskList
        .last
        .runner;

    expect(applyIntro.hint.toLowerCase(), contains('no chart'));
    expect(checkpoint.feedbackReason.toLowerCase(), contains('without chart'));
  });

  test('World 3 has a real position-thinking spine', () {
    final world3 = Act0ShellStateV1.sample.worldById('world_3');
    expect(world3.title, 'Position Thinking');
    expect(world3.lessons.map((lesson) => lesson.title), <String>[
      'The 6 positions',
      'Button advantage',
      'Early vs late',
      'Same hand, different seat',
      'Position at the table',
      'Position checkpoint',
    ]);
    for (final lesson in world3.lessons) {
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(4),
        reason: '${lesson.lessonId} should not be a flat preview node',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.first.stepKind, Act0LessonStepKindV1.learn);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
      expect(
        lesson.taskList.map((task) => task.phase),
        containsAll(<Act0LessonPhaseV1>[
          Act0LessonPhaseV1.theory,
          Act0LessonPhaseV1.drill,
          Act0LessonPhaseV1.review,
        ]),
      );
      for (final task in lesson.taskList) {
        expect(
          task.runner.teachingSteps,
          isNotEmpty,
          reason: '${task.taskId} needs a teaching step before action',
        );
      }
    }
  });

  test('World 3 content covers position thinking without strategy jumps', () {
    final content = _worldContentText('world_3').toLowerCase();
    for (final topic in const <String>[
      'position',
      'seat',
      'utg',
      'hj',
      'co',
      'btn',
      'sb',
      'bb',
      'button',
      'early',
      'late',
      'acts last',
      'same hand',
      'context',
      'players behind',
    ]) {
      expect(content, contains(topic), reason: 'Missing World 3 topic: $topic');
    }
    for (final deferred in const <String>[
      'solver',
      'chart memorization',
      'range construction',
      'icm',
      '3-bet',
      'initiative',
    ]) {
      expect(content, isNot(contains(deferred)));
    }
  });

  test('World 3 has enough true decision reps before World 4', () {
    final world3 = Act0ShellStateV1.sample.worldById('world_3');
    final decisionDrills = world3.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(9),
      reason:
          'World 3 should provide enough real choices before framework world',
    );
  });

  test('World 3 includes a real-table transfer read', () {
    final world3 = Act0ShellStateV1.sample.worldById('world_3');
    final transferTasks = world3.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      contains('position_checkpoint_position_checkpoint_table_notice'),
    );

    final transferText = transferTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(transferText, contains('three seats still act after'));
    expect(
      transferText,
      contains(
        'count the players behind before treating the seat as comfortable',
      ),
    );
  });

  test('World 3 includes suboptimal literacy as non-punitive growth', () {
    final world3 = Act0ShellStateV1.sample.worldById('world_3');
    final suboptimalOptions = world3.lessons
        .expand((lesson) => lesson.taskList)
        .expand((task) => task.runner.options)
        .where((option) => option.quality == Act0FeedbackQualityV1.suboptimal)
        .toList();

    expect(
      suboptimalOptions,
      isNotEmpty,
      reason: 'World 3 needs at least one playable-but-sharper line',
    );

    final hasPlayableLanguage = suboptimalOptions.any(
      (option) =>
          option.feedbackTitle.toLowerCase().contains('playable') ||
          option.feedbackReason.toLowerCase().contains('legal'),
    );
    expect(
      hasPlayableLanguage,
      isTrue,
      reason: 'Suboptimal feedback should frame growth, not punishment',
    );
  });

  test('World 3 checkpoint bridges to frame-first preflop', () {
    final world3 = Act0ShellStateV1.sample.worldById('world_3');
    final checkpoint = world3.lessons
        .firstWhere((lesson) => lesson.lessonId == 'position_checkpoint')
        .taskList
        .last
        .runner;

    final bridgeText = '${checkpoint.hint} ${checkpoint.feedbackReason}'
        .toLowerCase();
    expect(bridgeText, contains('first-in'));
    expect(bridgeText, contains('facing-open'));
    expect(bridgeText, contains('frame'));
  });

  test('World 4 has a real preflop framework spine', () {
    final world4 = Act0ShellStateV1.sample.worldById('world_4');
    expect(world4.title, 'Preflop Framework');
    expect(world4.lessons.map((lesson) => lesson.title), <String>[
      'First-in open',
      'Facing an open',
      'Open, call, fold',
      'Frame before action',
      'Preflop checkpoint',
    ]);
    for (final lesson in world4.lessons) {
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(4),
        reason: '${lesson.lessonId} should not be a flat preview node',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.first.stepKind, Act0LessonStepKindV1.learn);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
      expect(
        lesson.taskList.map((task) => task.phase),
        containsAll(<Act0LessonPhaseV1>[
          Act0LessonPhaseV1.theory,
          Act0LessonPhaseV1.drill,
          Act0LessonPhaseV1.review,
        ]),
      );
      for (final task in lesson.taskList) {
        expect(
          task.runner.teachingSteps,
          isNotEmpty,
          reason: '${task.taskId} needs a teaching step before action',
        );
      }
    }
  });

  test('World 4 content covers preflop framework without charts', () {
    final content = _worldContentText('world_4').toLowerCase();
    for (final topic in const <String>[
      'preflop',
      'bucket',
      'open',
      'call',
      'fold',
      'first in',
      'unopened',
      'facing open',
      'seat',
      'frame',
      'action',
      'name the frame',
    ]) {
      expect(content, contains(topic), reason: 'Missing World 4 topic: $topic');
    }
    for (final deferred in const <String>[
      'solver',
      'chart memorization',
      'range construction',
      'icm',
      '3-bet',
    ]) {
      expect(content, isNot(contains(deferred)));
    }
  });

  test('World 4 has enough true decision reps before World 5', () {
    final world4 = Act0ShellStateV1.sample.worldById('world_4');
    final decisionDrills = world4.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(9),
      reason:
          'World 4 should have enough real choices before bet-purpose world',
    );
  });

  test('World 4 includes a real-table frame transfer rep', () {
    final world4 = Act0ShellStateV1.sample.worldById('world_4');
    final transferTasks = world4.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      contains('preflop_framework_checkpoint_checkpoint_table_frame'),
    );

    final transferText = transferTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(transferText, contains('hj opens 2.5 bb'));
    expect(transferText, contains('name the frame before choosing the action'));
  });

  test('World 4 includes suboptimal literacy as non-punitive growth', () {
    final world4 = Act0ShellStateV1.sample.worldById('world_4');
    final suboptimalOptions = world4.lessons
        .expand((lesson) => lesson.taskList)
        .expand((task) => task.runner.options)
        .where((option) => option.quality == Act0FeedbackQualityV1.suboptimal)
        .toList();

    expect(
      suboptimalOptions,
      isNotEmpty,
      reason: 'World 4 needs at least one playable-but-sharper line',
    );

    final hasPlayableLanguage = suboptimalOptions.any(
      (option) =>
          option.feedbackTitle.toLowerCase().contains('playable') ||
          option.feedbackReason.toLowerCase().contains('legal'),
    );
    expect(
      hasPlayableLanguage,
      isTrue,
      reason: 'Suboptimal feedback should frame growth, not punishment',
    );
  });

  test('World 4 checkpoint bridges to bet-purpose thinking', () {
    final world4 = Act0ShellStateV1.sample.worldById('world_4');
    final checkpoint = world4.lessons
        .firstWhere(
          (lesson) => lesson.lessonId == 'preflop_framework_checkpoint',
        )
        .taskList
        .last
        .runner;

    final bridgeText = '${checkpoint.hint} ${checkpoint.feedbackReason}'
        .toLowerCase();
    expect(bridgeText, contains('bucket'));
    expect(bridgeText, contains('frame'));
    expect(bridgeText, contains('purpose'));
  });

  test('World 5 has a real bet-purpose and price spine', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    expect(world5.title, 'Bet Purpose And Price');
    expect(world5.lessons.map((lesson) => lesson.title), <String>[
      'Why bets happen',
      'Value bets',
      'Bluff pressure',
      'Protection and denial',
      'Call price',
      'Small, half, pot',
      'Price checkpoint',
    ]);
    for (final lesson in world5.lessons) {
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(4),
        reason: '${lesson.lessonId} should not be a flat preview node',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.first.stepKind, Act0LessonStepKindV1.learn);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
      expect(
        lesson.taskList.map((task) => task.phase),
        containsAll(<Act0LessonPhaseV1>[
          Act0LessonPhaseV1.theory,
          Act0LessonPhaseV1.drill,
          Act0LessonPhaseV1.review,
        ]),
      );
      for (final task in lesson.taskList) {
        expect(
          task.runner.teachingSteps,
          isNotEmpty,
          reason: '${task.taskId} needs a teaching step before action',
        );
      }
    }
  });

  test(
    'World 5 sizing lesson includes one-third half-pot and pot-size reps',
    () {
      final world5 = Act0ShellStateV1.sample.worldById('world_5');
      final sizingLesson = world5.lessons.firstWhere(
        (candidate) => candidate.lessonId == 'small_half_pot',
      );

      expect(
        sizingLesson.taskList.map((task) => task.taskId),
        containsAll(<String>['w4_small_bet', 'w4_half_pot_bet', 'w4_pot_bet']),
      );

      final halfPotTask = sizingLesson.taskList.firstWhere(
        (candidate) => candidate.taskId == 'w4_half_pot_bet',
      );
      expect(halfPotTask.runner.table.potLabel, 'Pot 6 BB');
      expect(halfPotTask.runner.table.centerLabel, 'Half-pot?');
      expect(
        halfPotTask.runner.options
            .firstWhere((option) => option.id == 'three')
            .feedbackReason,
        contains('3 BB is exactly a half-pot size'),
      );
    },
  );

  test('World 5 call-price lesson includes expanded caller-side examples', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final priceLesson = world5.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'call_price',
    );

    expect(priceLesson.taskList.length, greaterThanOrEqualTo(6));
    expect(
      priceLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w4_good_price_call',
        'w4_bad_price_fold',
        'w4_cheap_price_marginal_call',
        'w4_big_price_marginal_fold',
      ]),
    );
  });

  test('World 5 call-price drills teach cheap-vs-big price contrast', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final priceLesson = world5.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'call_price',
    );

    final cheapTask = priceLesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'w4_cheap_price_marginal_call',
    );
    final bigTask = priceLesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'w4_big_price_marginal_fold',
    );

    expect(cheapTask.runner.table.potLabel, 'Pot 10 BB');
    expect(cheapTask.runner.table.toCallLabel, 'To call 1 BB');
    expect(cheapTask.runner.table.centerLabel, 'Cheap price, middle pair');
    expect(
      cheapTask.runner.options
          .firstWhere((option) => option.id == 'call')
          .feedbackReason,
      allOf(contains('Pot 10 BB'), contains('to call is only 1 BB')),
    );
    expect(
      cheapTask.runner.options
          .firstWhere((option) => option.id == 'raise')
          .quality,
      Act0FeedbackQualityV1.suboptimal,
    );

    expect(bigTask.runner.table.potLabel, 'Pot 9 BB');
    expect(bigTask.runner.table.toCallLabel, 'To call 6 BB');
    expect(bigTask.runner.table.centerLabel, 'Top pair, big price');
    expect(
      bigTask.runner.options
          .firstWhere((option) => option.id == 'fold')
          .feedbackReason,
      allOf(contains('Pot 9 BB'), contains('risking 6 BB')),
    );
    expect(
      bigTask.runner.options
          .firstWhere((option) => option.id == 'call')
          .feedbackReason,
      allOf(contains('To call 6 BB'), contains('marginal hand')),
    );
  });

  test('World 5 content covers purpose and price without math overload', () {
    final content = _worldContentText('world_5').toLowerCase();
    for (final topic in const <String>[
      'purpose',
      'value',
      'bluff',
      'protection',
      'deny',
      'price',
      'call',
      'fold',
      'one-third',
      'half-pot',
      'pot-size',
      'weaker',
    ]) {
      expect(content, contains(topic), reason: 'Missing World 5 topic: $topic');
    }
    for (final deferred in const <String>[
      'solver',
      'gto',
      'equity formula',
      'range construction',
      'combo',
      'minimum defense',
      'draw',
    ]) {
      expect(content, isNot(contains(deferred)));
    }
  });

  test('World 5 sizing copy teaches light middle and heavy size language', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final sizingLesson = world5.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'small_half_pot',
    );
    final teachingText = sizingLesson.taskList
        .map(
          (task) => task.runner.teachingSteps
              .map(
                (step) =>
                    '${step.title} ${step.body} ${step.focusLabels.join(' ')}',
              )
              .join(' '),
        )
        .join(' ');

    expect(teachingText, contains('clean middle size'));
    expect(teachingText, contains('light, middle, or heavy'));
    expect(teachingText, contains('Half-pot'));
  });

  test('World 5 has enough true decision reps before World 6', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final decisionDrills = world5.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(10),
      reason:
          'World 5 should have enough real choices before board-texture world',
    );
  });

  test('World 5 includes suboptimal literacy as non-punitive growth', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final suboptimalOptions = world5.lessons
        .expand((lesson) => lesson.taskList)
        .expand((task) => task.runner.options)
        .where((option) => option.quality == Act0FeedbackQualityV1.suboptimal)
        .toList();

    expect(
      suboptimalOptions,
      isNotEmpty,
      reason: 'World 5 needs at least one playable-but-sharper line',
    );

    final hasPlayableLanguage = suboptimalOptions.any(
      (option) =>
          option.feedbackTitle.toLowerCase().contains('playable') ||
          option.feedbackReason.toLowerCase().contains('legal'),
    );
    expect(
      hasPlayableLanguage,
      isTrue,
      reason: 'Suboptimal feedback should frame growth, not punishment',
    );
  });

  test('World 5 checkpoint bridges to board texture thinking', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final checkpoint = world5.lessons
        .firstWhere((lesson) => lesson.lessonId == 'price_checkpoint')
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('board'));
    expect(bridgeText, contains('purpose'));
    expect(bridgeText, contains('price'));
  });

  test('World 5 checkpoint includes a real-table price transfer rep', () {
    final world5 = Act0ShellStateV1.sample.worldById('world_5');
    final checkpointLesson = world5.lessons.firstWhere(
      (lesson) => lesson.lessonId == 'price_checkpoint',
    );
    final transferTask = checkpointLesson.taskList.firstWhere(
      (task) => task.taskId == 'w4_checkpoint_table_price',
    );

    expect(transferTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);
    expect(transferTask.runner.caption, contains('Real table.'));
    expect(transferTask.runner.table.potLabel, 'Pot 7 BB');
    expect(transferTask.runner.table.toCallLabel, 'To call 2 BB');
    expect(transferTask.runner.table.centerLabel, 'Second pair, live table');
    expect(
      transferTask.runner.options
          .firstWhere((option) => option.id == 'call')
          .feedbackReason,
      allOf(contains('Pot 7 BB'), contains('To call is only 2 BB')),
    );
    expect(
      transferTask.runner.teachingSteps.first.body,
      allOf(
        contains('Pot tells what you can win'),
        contains('To call tells what you must risk'),
      ),
    );
  });

  test('World 6 has a real board-and-draws spine', () {
    final world6 = Act0ShellStateV1.sample.worldById('world_6');
    expect(world6.title, 'Board And Draws');
    expect(world6.lessons.map((lesson) => lesson.title), <String>[
      'Dry or wet board',
      'Connected boards',
      'Flush draws',
      'Straight draws',
      'Outs as improvement cards',
      'Turn and river changes',
    ]);
    for (final lesson in world6.lessons) {
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(4),
        reason: '${lesson.lessonId} should not be a flat preview node',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.first.stepKind, Act0LessonStepKindV1.learn);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
      expect(
        lesson.taskList.map((task) => task.phase),
        containsAll(<Act0LessonPhaseV1>[
          Act0LessonPhaseV1.theory,
          Act0LessonPhaseV1.drill,
          Act0LessonPhaseV1.review,
        ]),
      );
      for (final task in lesson.taskList) {
        expect(
          task.runner.teachingSteps,
          isNotEmpty,
          reason: '${task.taskId} needs a teaching step before action',
        );
      }
    }
  });

  test(
    'World 6 content covers board texture and draws without math overload',
    () {
      final content = _worldContentText('world_6').toLowerCase();
      for (final topic in const <String>[
        'board',
        'texture',
        'dry',
        'wet',
        'connected',
        'disconnected',
        'flush draw',
        'straight draw',
        'outs',
        'improvement',
        'turn',
        'river',
        'draw hit',
        'draw missed',
        'street change',
      ]) {
        expect(
          content,
          contains(topic),
          reason: 'Missing World 6 topic: $topic',
        );
      }
      for (final deferred in const <String>[
        'blocker',
        'equity formula',
        'combo',
        'minimum defense',
        'solver',
        'gto',
      ]) {
        expect(content, isNot(contains(deferred)));
      }
    },
  );

  test('World 6 has enough true decision reps before World 7', () {
    final world6 = Act0ShellStateV1.sample.worldById('world_6');
    final decisionDrills = world6.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(10),
      reason:
          'World 6 should have enough real choices before range-thinking world',
    );
  });

  test('World 6 includes suboptimal literacy as non-punitive growth', () {
    final world6 = Act0ShellStateV1.sample.worldById('world_6');
    final suboptimalOptions = world6.lessons
        .expand((lesson) => lesson.taskList)
        .expand((task) => task.runner.options)
        .where((option) => option.quality == Act0FeedbackQualityV1.suboptimal)
        .toList();

    expect(
      suboptimalOptions,
      isNotEmpty,
      reason: 'World 6 needs at least one playable-but-sharper line',
    );

    final hasPlayableLanguage = suboptimalOptions.any(
      (option) =>
          option.feedbackTitle.toLowerCase().contains('playable') ||
          option.feedbackReason.toLowerCase().contains('real'),
    );
    expect(
      hasPlayableLanguage,
      isTrue,
      reason: 'Suboptimal feedback should frame growth, not punishment',
    );
  });

  test('World 6 includes an explicit wet-board repair rep', () {
    final world6 = Act0ShellStateV1.sample.worldById('world_6');
    final repairTasks = world6.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.repair)
        .toList();

    expect(
      repairTasks.map((task) => task.taskId),
      contains('turn_river_changes_w5_street_repair'),
    );

    final repairText = repairTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(repairText, contains('turn connected the board'));
    expect(repairText, contains('repair the board read'));
  });

  test('World 6 checkpoint bridges to range grouping', () {
    final world6 = Act0ShellStateV1.sample.worldById('world_6');
    final checkpoint = world6.lessons
        .firstWhere((lesson) => lesson.lessonId == 'turn_river_changes')
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('range'));
    expect(bridgeText, contains('texture'));
  });

  test('World 6 street-change lesson keeps one draw story across streets', () {
    final world6 = Act0ShellStateV1.sample.worldById('world_6');
    final streetLesson = world6.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'turn_river_changes',
    );

    final intro = streetLesson.taskList.firstWhere(
      (candidate) =>
          candidate.taskId == 'turn_river_changes_w5_street_change_intro',
    );
    final turnHit = streetLesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'turn_river_changes_w5_turn_hits',
    );
    final riverMiss = streetLesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'turn_river_changes_w5_river_misses',
    );

    expect(intro.runner.teachingSteps.first.body, contains('same board'));
    expect(intro.runner.teachingSteps.first.body, contains('draw hit, miss'));
    expect(turnHit.runner.caption, contains('same flush story'));
    expect(riverMiss.runner.caption, contains('same heart story'));
  });

  test(
    'World 6 street-change feedback tracks the same draw across turn and river',
    () {
      final world6 = Act0ShellStateV1.sample.worldById('world_6');
      final streetLesson = world6.lessons.firstWhere(
        (candidate) => candidate.lessonId == 'turn_river_changes',
      );
      final turnHit = streetLesson.taskList.firstWhere(
        (candidate) => candidate.taskId == 'turn_river_changes_w5_turn_hits',
      );
      final riverMiss = streetLesson.taskList.firstWhere(
        (candidate) => candidate.taskId == 'turn_river_changes_w5_river_misses',
      );

      expect(
        turnHit.runner.options
            .firstWhere((option) => option.id == 'draw_hit')
            .feedbackReason,
        contains('same flush draw'),
      );
      expect(
        riverMiss.runner.options
            .firstWhere((option) => option.id == 'draw_missed')
            .feedbackReason,
        contains('same flush draw'),
      );
    },
  );

  test('World 7 is locked but has a real range-thinking scaffold', () {
    final world7 = Act0ShellStateV1.sample.worldById('world_7');
    expect(world7.title, 'Range Thinking Lite');
    expect(world7.status, Act0WorldStateV1.locked);
    expect(world7.isLocked, isTrue);
    expect(world7.isSelectable, isFalse);
    expect(world7.lessons.map((lesson) => lesson.title), <String>[
      'Range buckets',
      'Range meets board',
      'Value, bluff, missed',
      'Count the combos',
      'Range thinking checkpoint',
    ]);
    for (final lesson in world7.lessons) {
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(5),
        reason: '${lesson.lessonId} should be real scaffold, not placeholder',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
    }
  });

  test(
    'World 7 content covers range grouping without advanced solver load',
    () {
      final content = _worldContentText('world_7').toLowerCase();
      for (final topic in const <String>[
        'range',
        'bucket',
        'combo',
        '16 combos',
        '6 combos',
        'strong',
        'missed',
        'texture',
        'board',
        'value',
        'bluff',
        'check or fold',
        'real table',
        'more often',
        'stack depth',
      ]) {
        expect(
          content,
          contains(topic),
          reason: 'Missing World 7 topic: $topic',
        );
      }
      for (final deferred in const <String>[
        'gto',
        'minimum defense',
        'solver tree',
        'icm',
        '3-bet frequency',
      ]) {
        expect(content, isNot(contains(deferred)));
      }
    },
  );

  test('World 7 has enough true decision reps before World 8', () {
    final world7 = Act0ShellStateV1.sample.worldById('world_7');
    final decisionDrills = world7.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(14),
      reason:
          'World 7 should have enough real choices before stack-depth world',
    );
  });

  test('World 7 includes combo-count density, not only bucket labels', () {
    final world7 = Act0ShellStateV1.sample.worldById('world_7');
    final comboLesson = world7.lessons.firstWhere(
      (lesson) => lesson.lessonId == 'range_combo_counts',
    );

    expect(comboLesson.taskList.length, greaterThanOrEqualTo(5));
    expect(
      comboLesson.taskList.first.runner.teachingSteps.first.body,
      contains('16 combos'),
    );
    expect(
      comboLesson.taskList.first.runner.teachingSteps.first.body,
      contains('6'),
    );

    final akTask = comboLesson.taskList.firstWhere(
      (task) => task.taskId == 'w6_ak_combos',
    );
    final pairTask = comboLesson.taskList.firstWhere(
      (task) => task.taskId == 'w6_pair_combos',
    );

    expect(akTask.runner.question, contains('A-K'));
    expect(
      akTask.runner.options
          .firstWhere((option) => option.id == 'sixteen')
          .feedbackReason,
      contains('16'),
    );
    expect(pairTask.runner.question, contains('8-8'));
    expect(
      pairTask.runner.options
          .firstWhere((option) => option.id == 'six')
          .feedbackReason,
      contains('6'),
    );
  });

  test(
    'World 7 combo-counting has spaced reinforcement beyond the intro lesson',
    () {
      final checkpoint = Act0ShellStateV1.sample
          .worldById('world_7')
          .lessons
          .firstWhere(
            (lesson) => lesson.lessonId == 'range_thinking_checkpoint',
          );

      expect(
        checkpoint.taskList.map((task) => task.taskId),
        containsAll(<String>[
          'w6_suited_offsuit_weight_compare',
          'w6_pair_vs_suited_weight_compare',
          'w6_checkpoint_table_combo_weight',
        ]),
      );
    },
  );

  test(
    'World 7 combo reinforcement keeps suited-offsuit and pair-weight contrast',
    () {
      final checkpoint = Act0ShellStateV1.sample
          .worldById('world_7')
          .lessons
          .firstWhere(
            (lesson) => lesson.lessonId == 'range_thinking_checkpoint',
          );
      final suitedTask = checkpoint.taskList.firstWhere(
        (task) => task.taskId == 'w6_suited_offsuit_weight_compare',
      );
      final pairTask = checkpoint.taskList.firstWhere(
        (task) => task.taskId == 'w6_pair_vs_suited_weight_compare',
      );

      final suitedText = [
        suitedTask.runner.hint,
        ...suitedTask.runner.options.map((option) => option.feedbackReason),
      ].join(' ').toLowerCase();
      expect(suitedText, contains('offsuit'));
      expect(suitedText, contains('suited'));
      expect(suitedText, contains('12'));
      expect(suitedText, contains('4'));
      expect(suitedText, contains('more often'));

      final pairText = [
        pairTask.runner.hint,
        ...pairTask.runner.options.map((option) => option.feedbackReason),
      ].join(' ').toLowerCase();
      expect(pairText, contains('pocket'));
      expect(pairText, contains('suited'));
      expect(pairText, contains('6'));
      expect(pairText, contains('4'));
      expect(pairText, contains('appears more often'));
    },
  );

  test(
    'World 7 combo reinforcement includes practical transfer and why copy',
    () {
      final checkpoint = Act0ShellStateV1.sample
          .worldById('world_7')
          .lessons
          .firstWhere(
            (lesson) => lesson.lessonId == 'range_thinking_checkpoint',
          );
      final transferTask = checkpoint.taskList.firstWhere(
        (task) => task.taskId == 'w6_checkpoint_table_combo_weight',
      );

      expect(transferTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);
      expect(transferTask.stepKind, Act0LessonStepKindV1.proveIt);

      final transferText = [
        transferTask.runner.caption,
        transferTask.runner.hint,
        ...transferTask.runner.options.map((option) => option.feedbackReason),
      ].join(' ').toLowerCase();
      expect(transferText, contains('real table'));
      expect(transferText, contains('opening range'));
      expect(transferText, contains('12'));
      expect(transferText, contains('6'));
      expect(transferText, contains('more often'));
      expect(transferText, contains('range'));
    },
  );

  test('World 7 checkpoint bridges to stack-depth risk thinking', () {
    final world7 = Act0ShellStateV1.sample.worldById('world_7');
    final checkpoint = world7.lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_thinking_checkpoint')
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('range'));
    expect(bridgeText, contains('stack depth'));
    expect(bridgeText, contains('risk'));
  });

  test('World 7 checkpoint adds spaced made-hand reinforcement after W1', () {
    final checkpoint = Act0ShellStateV1.sample
        .worldById('world_7')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_thinking_checkpoint');

    expect(
      checkpoint.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w6_kicker_showdown_compare',
        'w6_board_pair_strength_compare',
        'w6_checkpoint_table_best_five',
      ]),
    );
  });

  test(
    'World 7 made-hand reinforcement keeps kicker and board-context why copy',
    () {
      final checkpoint = Act0ShellStateV1.sample
          .worldById('world_7')
          .lessons
          .firstWhere(
            (lesson) => lesson.lessonId == 'range_thinking_checkpoint',
          );
      final kickerTask = checkpoint.taskList.firstWhere(
        (task) => task.taskId == 'w6_kicker_showdown_compare',
      );
      final boardTask = checkpoint.taskList.firstWhere(
        (task) => task.taskId == 'w6_board_pair_strength_compare',
      );

      final kickerText = [
        kickerTask.runner.hint,
        ...kickerTask.runner.options.map((option) => option.feedbackReason),
      ].join(' ').toLowerCase();
      expect(kickerText, contains('kicker'));
      expect(kickerText, contains('best five'));
      expect(kickerText, contains('pair'));

      final boardText = [
        boardTask.runner.hint,
        ...boardTask.runner.options.map((option) => option.feedbackReason),
      ].join(' ').toLowerCase();
      expect(boardText, contains('board'));
      expect(boardText, contains('trips'));
      expect(boardText, contains('two pair'));
      expect(boardText, contains('best five'));
    },
  );

  test(
    'World 7 made-hand reinforcement includes a live-table best-five transfer rep',
    () {
      final checkpoint = Act0ShellStateV1.sample
          .worldById('world_7')
          .lessons
          .firstWhere(
            (lesson) => lesson.lessonId == 'range_thinking_checkpoint',
          );
      final transferTask = checkpoint.taskList.firstWhere(
        (task) => task.taskId == 'w6_checkpoint_table_best_five',
      );

      expect(transferTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);
      expect(transferTask.stepKind, Act0LessonStepKindV1.proveIt);

      final transferText = [
        transferTask.runner.caption,
        transferTask.runner.hint,
        transferTask.runner.feedbackReason,
        ...transferTask.runner.options.map((option) => option.feedbackReason),
      ].join(' ').toLowerCase();
      expect(transferText, contains('real table showdown'));
      expect(transferText, contains('best five'));
      expect(transferText, contains('split'));
      expect(transferText, contains('board'));
    },
  );

  test('World 8 is locked but has a real stack-depth scaffold', () {
    final state = Act0ShellStateV1.sample;
    final world8 = state.worldById('world_8');
    expect(world8.status, Act0WorldStateV1.locked);
    expect(world8.isLocked, isTrue);
    expect(world8.isSelectable, isFalse);
    expect(world8.lessons.map((lesson) => lesson.title), <String>[
      'Effective stack',
      'Same hand, different depth',
      'Room or commitment',
      '6-max vs full ring',
    ]);
    for (final lesson in world8.lessons) {
      expect(lesson.taskList.length, greaterThanOrEqualTo(4));
      expect(
        lesson.taskList.length,
        greaterThanOrEqualTo(5),
        reason: '${lesson.lessonId} should feel materially filled, not thin',
      );
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
    }
  });

  test(
    'World 8 content covers stack depth and risk without advanced overload',
    () {
      final content = _worldContentText('world_8').toLowerCase();
      for (final topic in const <String>[
        'effective stack',
        '20 bb',
        '100 bb',
        '40 bb',
        'spr',
        'spr 4',
        'room',
        'commit',
        '6-max',
        'full ring',
        'players behind',
        'tournament pressure',
      ]) {
        expect(
          content,
          contains(topic),
          reason: 'Missing World 8 topic: $topic',
        );
      }
      for (final deferred in const <String>[
        'gto',
        'solver',
        'm-ratio',
        'icm formula',
        'node lock',
      ]) {
        expect(content, isNot(contains(deferred)));
      }
    },
  );

  test('World 8 has enough true decision reps before World 9', () {
    final world8 = Act0ShellStateV1.sample.worldById('world_8');
    final decisionDrills = world8.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(12),
      reason:
          'World 8 should have enough real choices before tournament-pressure world',
    );
  });

  test('World 8 includes expanded stack-depth transfer density', () {
    final world8 = Act0ShellStateV1.sample.worldById('world_8');
    final transferTasks = world8.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      containsAll(<String>[
        'w7_table_effective_notice',
        'w7_40bb_middle',
        'w7_spr4_middle',
        'w7_format_table_notice',
        'w7_ajs_btn_25bb_transfer',
        'w7_ajs_btn_100bb_transfer',
        'w7_top_pair_spr8_transfer',
      ]),
    );
  });

  test('World 8 includes same-hand different-stack contrast', () {
    final depthLesson = Act0ShellStateV1.sample
        .worldById('world_8')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'same_hand_different_depth');

    expect(
      depthLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w7_20bb_wider',
        'w7_100bb_tighter',
        'w7_ajs_btn_25bb_transfer',
        'w7_ajs_btn_100bb_transfer',
      ]),
    );

    final shallowTask = depthLesson.taskList.firstWhere(
      (task) => task.taskId == 'w7_ajs_btn_25bb_transfer',
    );
    final deepTask = depthLesson.taskList.firstWhere(
      (task) => task.taskId == 'w7_ajs_btn_100bb_transfer',
    );

    final shallowText = [
      shallowTask.runner.caption,
      shallowTask.runner.hint,
      ...shallowTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(shallowText, contains('25 bb'));
    expect(shallowText, contains('a-j suited'));
    expect(shallowText, contains('less risk'));

    final deepText = [
      deepTask.runner.caption,
      deepTask.runner.hint,
      ...deepTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(deepText, contains('100 bb'));
    expect(deepText, contains('a-j suited'));
    expect(deepText, contains('more room'));
    expect(deepText, contains('more risk'));
  });

  test('World 8 includes mixed-concept stack-depth transfer with why copy', () {
    final sprLesson = Act0ShellStateV1.sample
        .worldById('world_8')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'spr_and_commitment');
    final mixedTask = sprLesson.taskList.firstWhere(
      (task) => task.taskId == 'w7_top_pair_spr8_transfer',
    );

    expect(mixedTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);

    final mixedText = [
      mixedTask.runner.caption,
      mixedTask.runner.hint,
      ...mixedTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(mixedText, contains('top pair'));
    expect(mixedText, contains('spr 8'));
    expect(mixedText, contains('future-street risk'));
    expect(mixedText, contains('board'));
    expect(mixedText, contains('tempting'));
  });

  test('World 8 checkpoint bridges to tournament pressure', () {
    final world8 = Act0ShellStateV1.sample.worldById('world_8');
    final checkpoint = world8.lessons
        .firstWhere((lesson) => lesson.lessonId == 'format_pressure')
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('tournament pressure'));
    expect(bridgeText, contains('risk'));
    expect(bridgeText, contains('range'));
  });

  test('World 9 is locked but has a real tournament-pressure scaffold', () {
    final state = Act0ShellStateV1.sample;
    final world9 = state.worldById('world_9');
    expect(world9.status, Act0WorldStateV1.locked);
    expect(world9.isLocked, isTrue);
    expect(world9.isSelectable, isFalse);
    expect(world9.lessons.map((lesson) => lesson.title), <String>[
      'Chips are not life',
      'M-ratio zones',
      'Bubble risk premium',
      'Tournament pressure checkpoint',
    ]);
    for (final lesson in world9.lessons) {
      expect(lesson.taskList.length, greaterThanOrEqualTo(5));
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
    }
  });

  test(
    'World 9 content covers tournament pressure without expert overload',
    () {
      final content = _worldContentText('world_9').toLowerCase();
      for (final topic in const <String>[
        'tournament pressure',
        'survival',
        'm-ratio',
        'yellow zone',
        'bubble',
        'risk premium',
        'leverage',
        'short stack',
        'player adjustment',
      ]) {
        expect(
          content,
          contains(topic),
          reason: 'Missing World 9 topic: $topic',
        );
      }
      for (final deferred in const <String>[
        'icm formula',
        'nash equilibrium',
        'gto',
        'solver node',
      ]) {
        expect(content, isNot(contains(deferred)));
      }
    },
  );

  test('World 9 has enough true decision reps before World 10', () {
    final world9 = Act0ShellStateV1.sample.worldById('world_9');
    final decisionDrills = world9.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(11),
      reason:
          'World 9 should have enough real choices before player-adjustment world',
    );
  });

  test('World 9 checkpoint bridges to player adjustment', () {
    final world9 = Act0ShellStateV1.sample.worldById('world_9');
    final checkpoint = world9.lessons
        .firstWhere(
          (lesson) => lesson.lessonId == 'tournament_pressure_checkpoint',
        )
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('player adjustment'));
    expect(bridgeText, contains('pressure'));
    expect(bridgeText, contains('risk premium'));
  });

  test('World 9 includes a real-table tournament pressure transfer rep', () {
    final world9 = Act0ShellStateV1.sample.worldById('world_9');
    final transferTasks = world9.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      contains('w9_checkpoint_table_notice'),
    );

    final transferText = transferTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(transferText, contains('medium stack near the bubble'));
    expect(transferText, contains('risk premium'));
    expect(transferText, contains('leverage'));
  });

  test('World 10 is locked but has a real player-adjustment scaffold', () {
    final state = Act0ShellStateV1.sample;
    final world10 = state.worldById('world_10');
    expect(world10.status, Act0WorldStateV1.locked);
    expect(world10.isLocked, isTrue);
    expect(world10.isSelectable, isFalse);
    expect(world10.lessons.map((lesson) => lesson.title), <String>[
      'Who is at the table',
      'Adjust one lever',
      'Exploit guardrails',
      'Player-adjustment checkpoint',
    ]);
    for (final lesson in world10.lessons) {
      expect(lesson.taskList.length, greaterThanOrEqualTo(5));
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
    }
  });

  test('World 10 content covers player adjustment without expert overload', () {
    final content = _worldContentText('world_10').toLowerCase();
    for (final topic in const <String>[
      'player adjustment',
      'tendency',
      'one lever',
      'sticky',
      'overbluff',
      'underbluff',
      'sample',
      'guardrails',
      'real-play transfer',
    ]) {
      expect(
        content,
        contains(topic),
        reason: 'Missing World 10 topic: $topic',
      );
    }
    for (final deferred in const <String>[
      'node lock',
      'exploitability equation',
      'gto tree',
      'nash equilibrium',
    ]) {
      expect(content, isNot(contains(deferred)));
    }
  });

  test('World 10 has enough true decision reps before World 11', () {
    final world10 = Act0ShellStateV1.sample.worldById('world_10');
    final decisionDrills = world10.lessons
        .expand((lesson) => lesson.taskList)
        .where(
          (task) =>
              task.phase == Act0LessonPhaseV1.drill &&
              task.runner.options.length >= 2,
        )
        .length;
    expect(
      decisionDrills,
      greaterThanOrEqualTo(11),
      reason:
          'World 10 should have enough real choices before real-play transfer world',
    );
  });

  test('World 10 checkpoint bridges to real-play transfer', () {
    final world10 = Act0ShellStateV1.sample.worldById('world_10');
    final checkpoint = world10.lessons
        .firstWhere(
          (lesson) => lesson.lessonId == 'player_adjustment_checkpoint',
        )
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('real-play transfer'));
    expect(bridgeText, contains('guardrails'));
    expect(bridgeText, contains('tendency'));
  });

  test('World 10 includes a real-table exploit transfer rep', () {
    final world10 = Act0ShellStateV1.sample.worldById('world_10');
    final transferTasks = world10.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      contains('w10_checkpoint_table_notice'),
    );

    final transferText = transferTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(transferText, contains('folded to your late steals'));
    expect(transferText, contains('one small tracked adjustment'));
  });

  test('World 11 is locked but has a real play-transfer scaffold', () {
    final state = Act0ShellStateV1.sample;
    final world11 = state.worldById('world_11');
    expect(world11.status, Act0WorldStateV1.locked);
    expect(world11.isLocked, isTrue);
    expect(world11.isSelectable, isFalse);
    expect(world11.lessons.map((lesson) => lesson.title), <String>[
      'Session plan in 30 seconds',
      'In-session trigger reads',
      'Post-session review loop',
      'Real-play transfer checkpoint',
    ]);
    for (final lesson in world11.lessons) {
      expect(lesson.taskList.length, greaterThanOrEqualTo(4));
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
    }
  });

  test(
    'World 11 content covers real-play transfer without expert overload',
    () {
      final content = _worldContentText('world_11').toLowerCase();
      for (final topic in const <String>[
        'real play transfer',
        'session plan',
        'trigger',
        'one lever',
        'review loop',
        'daily',
        'repair',
      ]) {
        expect(
          content,
          contains(topic),
          reason: 'Missing World 11 topic: $topic',
        );
      }
      for (final deferred in const <String>[
        'solver tree',
        'node lock',
        'icm equation',
        'nash equilibrium',
      ]) {
        expect(content, isNot(contains(deferred)));
      }
    },
  );

  test('World 11 checkpoint bridges to daily loop execution', () {
    final world11 = Act0ShellStateV1.sample.worldById('world_11');
    final checkpoint = world11.lessons
        .firstWhere(
          (lesson) => lesson.lessonId == 'real_play_transfer_checkpoint',
        )
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('daily'));
    expect(bridgeText, contains('transfer loop'));
    expect(bridgeText, contains('mindset bridge'));
    expect(bridgeText, contains('review'));
  });

  test('World 11 includes expanded real-play transfer density', () {
    final world11 = Act0ShellStateV1.sample.worldById('world_11');
    final transferTasks = world11.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      containsAll(<String>[
        'w11_trigger_small_price_continue',
        'w11_trigger_bad_price_fold',
        'w11_checkpoint_review_line',
        'w11_checkpoint_mixed_table_line',
      ]),
    );
  });

  test('World 11 includes a close-decision real-play contrast', () {
    final triggerLesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'table_trigger_reads');

    expect(
      triggerLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w11_trigger_small_price_continue',
        'w11_trigger_bad_price_fold',
      ]),
    );

    final smallPriceTask = triggerLesson.taskList.firstWhere(
      (task) => task.taskId == 'w11_trigger_small_price_continue',
    );
    final badPriceTask = triggerLesson.taskList.firstWhere(
      (task) => task.taskId == 'w11_trigger_bad_price_fold',
    );

    final smallText = [
      smallPriceTask.runner.caption,
      ...smallPriceTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(smallText, contains('q-j suited'));
    expect(
      smallPriceTask.runner.table.toCallLabel.toLowerCase(),
      'to call 2 bb',
    );
    expect(smallText, contains('position'));
    expect(smallText, contains('cheap price'));

    final badText = [
      badPriceTask.runner.caption,
      ...badPriceTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(badText, contains('same hand again'));
    expect(
      badPriceTask.runner.table.toCallLabel.toLowerCase(),
      'to call 12 bb',
    );
    expect(badText, contains('deep'));
    expect(badText, contains('tempting'));
  });

  test('World 11 includes mixed-concept transfer with why feedback', () {
    final checkpointLesson = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .firstWhere(
          (lesson) => lesson.lessonId == 'real_play_transfer_checkpoint',
        );
    final mixedTask = checkpointLesson.taskList.firstWhere(
      (task) => task.taskId == 'w11_checkpoint_mixed_table_line',
    );

    expect(mixedTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);

    final mixedText = [
      mixedTask.runner.caption,
      mixedTask.runner.hint,
      ...mixedTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(mixedText, contains('a-j suited'));
    expect(mixedText, contains('position'));
    expect(mixedText, contains('two-tone'));
    expect(mixedText, contains('30 bb'));
    expect(mixedText, contains('price'));
    expect(mixedText, contains('full table read'));
  });

  test('World 12 is locked but has a real mindset-bridge scaffold', () {
    final state = Act0ShellStateV1.sample;
    final world12 = state.worldById('world_12');
    expect(world12.status, Act0WorldStateV1.locked);
    expect(world12.isLocked, isTrue);
    expect(world12.isSelectable, isFalse);
    expect(world12.lessons.map((lesson) => lesson.title), <String>[
      'Decision quality over outcome',
      'Tilt reset protocol',
      'Confidence with discipline',
      'Mindset bridge checkpoint',
    ]);
    for (final lesson in world12.lessons) {
      expect(lesson.taskList.length, greaterThanOrEqualTo(4));
      expect(lesson.taskList.first.phase, Act0LessonPhaseV1.theory);
      expect(lesson.taskList.last.phase, Act0LessonPhaseV1.review);
    }
  });

  test('World 12 content covers mindset bridge without expert overload', () {
    final content = _worldContentText('world_12').toLowerCase();
    for (final topic in const <String>[
      'mindset bridge',
      'process',
      'outcome',
      'tilt',
      'reset',
      'discipline',
      'postflop',
    ]) {
      expect(
        content,
        contains(topic),
        reason: 'Missing World 12 topic: $topic',
      );
    }
    for (final deferred in const <String>[
      'solver node',
      'gto tree',
      'icm formula',
      'nash equilibrium',
    ]) {
      expect(content, isNot(contains(deferred)));
    }
  });

  test('World 12 checkpoint bridges to deeper postflop growth', () {
    final world12 = Act0ShellStateV1.sample.worldById('world_12');
    final checkpoint = world12.lessons
        .firstWhere((lesson) => lesson.lessonId == 'mindset_bridge_checkpoint')
        .taskList
        .last
        .runner;

    final bridgeText = [
      checkpoint.hint,
      checkpoint.feedbackReason,
      ...checkpoint.options.map((o) => o.feedbackReason),
    ].join(' ').toLowerCase();
    expect(bridgeText, contains('postflop'));
    expect(bridgeText, contains('process'));
    expect(bridgeText, contains('discipline'));
  });

  test('World 12 includes added mindset and discipline transfer density', () {
    final world12 = Act0ShellStateV1.sample.worldById('world_12');
    final transferTasks = world12.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      containsAll(<String>[
        'w12_bad_call_good_result',
        'w12_after_mistake_reset',
        'w12_discipline_under_pressure',
        'w12_pretty_hand_bad_price_fold',
        'w12_revenge_raise_trap',
        'w12_checkpoint_full_loop_line',
      ]),
    );
    expect(transferTasks.length, greaterThanOrEqualTo(6));
  });

  test('World 12 includes a close temptation contrast', () {
    final disciplineLesson = Act0ShellStateV1.sample
        .worldById('world_12')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'confidence_and_discipline');

    expect(
      disciplineLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w12_pretty_hand_bad_price_fold',
        'w12_revenge_raise_trap',
      ]),
    );

    final prettyHandTask = disciplineLesson.taskList.firstWhere(
      (task) => task.taskId == 'w12_pretty_hand_bad_price_fold',
    );
    final revengeTask = disciplineLesson.taskList.firstWhere(
      (task) => task.taskId == 'w12_revenge_raise_trap',
    );

    final prettyHandText = [
      prettyHandTask.runner.caption,
      prettyHandTask.runner.hint,
      ...prettyHandTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(prettyHandText, contains('k-q'));
    expect(
      prettyHandTask.runner.table.toCallLabel.toLowerCase(),
      'to call 18 bb',
    );
    expect(prettyHandText, contains('tempting'));
    expect(prettyHandText, contains('bad river price'));

    final revengeText = [
      revengeTask.runner.caption,
      revengeTask.runner.hint,
      ...revengeTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(revengeText, contains('q-j suited'));
    expect(revengeTask.runner.table.toCallLabel.toLowerCase(), 'to call 2 bb');
    expect(revengeText, contains('take control'));
    expect(revengeText, contains('noise'));
  });

  test('World 12 includes mixed-concept discipline with why feedback', () {
    final checkpointLesson = Act0ShellStateV1.sample
        .worldById('world_12')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'mindset_bridge_checkpoint');
    final mixedTask = checkpointLesson.taskList.firstWhere(
      (task) => task.taskId == 'w12_checkpoint_full_loop_line',
    );

    expect(mixedTask.resolvedTaskFamily, Act0TaskFamilyV1.transfer);

    final mixedText = [
      mixedTask.runner.caption,
      mixedTask.runner.hint,
      ...mixedTask.runner.options.map((option) => option.feedbackReason),
    ].join(' ').toLowerCase();
    expect(mixedText, contains('a-j suited'));
    expect(mixedText, contains('two-tone'));
    expect(mixedText, contains('25 bb'));
    expect(mixedText, contains('price'));
    expect(mixedText, contains('same decision loop'));
    expect(mixedText, contains('after a mistake'));
  });

  test('World 8 to 12 keep suboptimal literacy as non-punitive growth', () {
    for (final worldId in const <String>[
      'world_8',
      'world_9',
      'world_10',
      'world_11',
      'world_12',
    ]) {
      final world = Act0ShellStateV1.sample.worldById(worldId);
      final suboptimalOptions = world.lessons
          .expand((lesson) => lesson.taskList)
          .expand((task) => task.runner.options)
          .where((option) => option.quality == Act0FeedbackQualityV1.suboptimal)
          .toList();

      expect(
        suboptimalOptions,
        isNotEmpty,
        reason: '$worldId needs at least one playable-but-sharper line',
      );

      final hasGrowthFraming = suboptimalOptions.any((option) {
        final copy = '${option.feedbackTitle} ${option.feedbackReason}'
            .toLowerCase();
        return copy.contains('tempting') ||
            copy.contains('playable') ||
            copy.contains('safe') ||
            copy.contains('common') ||
            copy.contains('part of the picture') ||
            copy.contains('protective') ||
            copy.contains('reactive') ||
            copy.contains('cautious');
      });
      expect(
        hasGrowthFraming,
        isTrue,
        reason:
            '$worldId suboptimal feedback should explain a tempting but weaker line, not punish it',
      );
    }
  });

  test(
    'World 8 to 12 transfer checkpoints keep explanatory wrong and suboptimal branches',
    () {
      final state = Act0ShellStateV1.sample;
      final taskIds = <String>[
        'w7_table_effective_notice',
        'w9_checkpoint_table_notice',
        'w10_checkpoint_table_notice',
        'w11_checkpoint_review_line',
        'w12_checkpoint_process_line',
      ];

      final tasks = <Act0LessonTaskV1>[];
      for (final worldId in const <String>[
        'world_8',
        'world_9',
        'world_10',
        'world_11',
        'world_12',
      ]) {
        tasks.addAll(
          state.worldById(worldId).lessons.expand((l) => l.taskList),
        );
      }

      for (final taskId in taskIds) {
        final task = tasks.firstWhere(
          (candidate) => candidate.taskId == taskId,
        );
        final wrongOptions = task.runner.options
            .where((option) => option.quality == Act0FeedbackQualityV1.wrong)
            .toList();
        final suboptimalOptions = task.runner.options
            .where(
              (option) => option.quality == Act0FeedbackQualityV1.suboptimal,
            )
            .toList();

        expect(
          wrongOptions,
          isNotEmpty,
          reason: '$taskId needs a wrong branch',
        );
        expect(
          suboptimalOptions,
          isNotEmpty,
          reason: '$taskId needs a suboptimal branch',
        );

        final wrongText = wrongOptions
            .map((option) => option.feedbackReason.toLowerCase())
            .join(' ');
        final suboptimalText = suboptimalOptions
            .map((option) => option.feedbackReason.toLowerCase())
            .join(' ');

        expect(
          wrongText,
          anyOf(contains('tempting'), contains('dominant cue')),
          reason:
              '$taskId wrong feedback should explain why the miss is attractive and what should dominate instead',
        );
        expect(
          suboptimalText,
          anyOf(
            contains('tempting'),
            contains('cleaner read'),
            contains('cleaner bridge'),
            contains('looks useful'),
            contains('dominant cue'),
            contains('protective'),
          ),
          reason:
              '$taskId suboptimal feedback should explain the weaker instinct without shame',
        );
      }
    },
  );

  test('First 12 worlds keep integrity-matrix structural invariants', () {
    final state = Act0ShellStateV1.sample;
    for (var index = 1; index <= 12; index++) {
      final world = state.worldById('world_$index');
      expect(
        world.lessons,
        isNotEmpty,
        reason: 'world_$index needs at least one lesson',
      );

      final tasks = world.lessons.expand((lesson) => lesson.taskList).toList();
      expect(tasks, isNotEmpty, reason: 'world_$index needs at least one task');
      expect(
        tasks.where((task) => task.phase == Act0LessonPhaseV1.theory),
        isNotEmpty,
        reason: 'world_$index needs theory ownership',
      );
      expect(
        tasks.where((task) => task.phase == Act0LessonPhaseV1.drill),
        isNotEmpty,
        reason: 'world_$index needs practice ownership',
      );
      expect(
        tasks.where((task) => task.phase == Act0LessonPhaseV1.review),
        isNotEmpty,
        reason: 'world_$index needs recap ownership',
      );
      expect(
        tasks.where(
          (task) =>
              task.resolvedTaskFamily == Act0TaskFamilyV1.transfer ||
              task.stepKind == Act0LessonStepKindV1.proveIt,
        ),
        isNotEmpty,
        reason: 'world_$index needs a transfer or prove-it seam',
      );
      expect(
        tasks.where((task) => task.runner.options.isNotEmpty),
        isNotEmpty,
        reason: 'world_$index needs answer-bearing drills',
      );

      for (final lesson in world.lessons) {
        expect(
          lesson.taskList,
          isNotEmpty,
          reason: '${lesson.lessonId} cannot be empty',
        );
        expect(
          lesson.taskList.first.phase,
          Act0LessonPhaseV1.theory,
          reason: '${lesson.lessonId} should start with theory',
        );
        expect(
          lesson.taskList.last.phase,
          Act0LessonPhaseV1.review,
          reason: '${lesson.lessonId} should end with review',
        );
      }
    }
  });

  test(
    'Prefixed W5-W12 task ids follow the current allowlisted owner convention',
    () {
      final state = Act0ShellStateV1.sample;
      final allowedPrefixesByWorld = <String, String>{
        'world_5': 'w4_',
        'world_6': 'w5_',
        'world_7': 'w6_',
        'world_8': 'w7_',
        'world_9': 'w9_',
        'world_10': 'w10_',
        'world_11': 'w11_',
        'world_12': 'w12_',
      };

      for (final entry in allowedPrefixesByWorld.entries) {
        final world = state.worldById(entry.key);
        final taskIds = world.lessons
            .expand((lesson) => lesson.taskList)
            .map((task) => task.taskId)
            .toList();
        final prefixedIds = taskIds
            .where(
              (taskId) =>
                  taskId.startsWith(entry.value) ||
                  taskId.contains('_${entry.value}'),
            )
            .toList();

        expect(
          prefixedIds,
          isNotEmpty,
          reason: '${entry.key} should keep stable prefixed authored ids',
        );
        for (final taskId in taskIds) {
          if (!taskId.contains('_w') && !taskId.startsWith('w')) {
            continue;
          }
          expect(
            taskId.startsWith(entry.value) ||
                taskId.contains('_${entry.value}'),
            isTrue,
            reason:
                '${entry.key} uses unexpected prefixed task id $taskId; keep legacy owner prefix explicit or rename in a dedicated wave',
          );
        }
      }
    },
  );

  test('Key concept concern seams keep minimum mastery coverage', () {
    final state = Act0ShellStateV1.sample;

    final bucketsWorld = state.worldById('world_2');
    final bucketTasks = bucketsWorld.lessons
        .where(
          (lesson) => <String>[
            'hand_discipline_buckets',
            'continue_or_let_go',
            'hand_discipline_apply',
            'discipline_checkpoint',
          ].contains(lesson.lessonId),
        )
        .expand((lesson) => lesson.taskList)
        .toList();
    expect(
      bucketTasks.map((task) => task.taskId),
      containsAll(<String>[
        'hand_discipline_buckets_premium',
        'hand_discipline_buckets_strong',
        'hand_discipline_buckets_medium',
        'hand_discipline_buckets_trash',
      ]),
    );
    expect(
      bucketTasks
          .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
          .map((task) => task.taskId),
      contains('discipline_checkpoint_checkpoint_table_discipline'),
    );

    final showdownLesson = state
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'showdown_winning');
    final rankingLesson = state
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'hand_rankings_table');
    expect(
      showdownLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'showdown_best_hand_drill',
        'showdown_kicker_drill',
        'showdown_board_plays_drill',
        'showdown_tie_drill',
      ]),
    );
    expect(
      rankingLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'hand_rankings_pair_drill',
        'hand_rankings_two_pair_drill',
        'hand_rankings_trips_drill',
        'hand_rankings_straight_drill',
        'hand_rankings_flush_drill',
        'hand_rankings_best_five_drill',
      ]),
    );

    final madeHandCheckpoint = state
        .worldById('world_7')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_thinking_checkpoint');
    expect(
      madeHandCheckpoint.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w6_kicker_showdown_compare',
        'w6_board_pair_strength_compare',
        'w6_checkpoint_table_best_five',
      ]),
    );
    expect(
      madeHandCheckpoint.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w6_suited_offsuit_weight_compare',
        'w6_pair_vs_suited_weight_compare',
        'w6_checkpoint_table_combo_weight',
      ]),
    );

    final comboLesson = state
        .worldById('world_7')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_combo_counts');
    expect(comboLesson.taskList.length, greaterThanOrEqualTo(5));
    expect(
      comboLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w6_ak_combos',
        'w6_pair_combos',
        'w6_combo_weight_compare',
      ]),
    );

    final priceLesson = state
        .worldById('world_5')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'call_price');
    expect(
      priceLesson.taskList.map((task) => task.taskId),
      containsAll(<String>[
        'w4_good_price_call',
        'w4_bad_price_fold',
        'w4_cheap_price_marginal_call',
        'w4_big_price_marginal_fold',
      ]),
    );
    final priceCheckpoint = state
        .worldById('world_5')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'price_checkpoint');
    expect(
      priceCheckpoint.taskList.map((task) => task.taskId),
      contains('w4_checkpoint_table_price'),
    );
  });

  test('World 5 and 6 recap tasks use real takeaway copy', () {
    for (final worldId in const <String>['world_5', 'world_6']) {
      final world = Act0ShellStateV1.sample.worldById(worldId);
      for (final lesson in world.lessons) {
        final reviewTasks = lesson.taskList.where(
          (task) => task.phase == Act0LessonPhaseV1.review,
        );
        for (final task in reviewTasks) {
          expect(
            task.runner.caption,
            contains('Lesson learned:'),
            reason: '${task.taskId} needs a learner takeaway caption',
          );
          expect(
            task.runner.feedbackReason.length,
            greaterThan(45),
            reason: '${task.taskId} needs a useful takeaway reason',
          );
          expect(
            task.runner.feedbackReason.toLowerCase(),
            isNot(contains('${task.title.toLowerCase()}:')),
            reason: '${task.taskId} should not only repeat the task title',
          );
        }
      }
    }
  });

  test('World 1 recap tasks use takeaway copy instead of title repeats', () {
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    for (final lesson in world1.lessons) {
      final reviewTasks = lesson.taskList.where(
        (task) =>
            task.phase == Act0LessonPhaseV1.review &&
            (task.taskId.contains('recap') ||
                task.taskId.contains('checkpoint')),
      );
      for (final task in reviewTasks) {
        expect(
          task.runner.caption,
          contains('Lesson learned:'),
          reason: '${task.taskId} needs a learner takeaway caption',
        );
        expect(
          task.runner.feedbackReason.toLowerCase(),
          isNot(contains('recap:')),
          reason: '${task.taskId} feedback should explain the lesson learned',
        );
        expect(
          task.runner.feedbackReason.length,
          greaterThan(40),
          reason: '${task.taskId} needs a real takeaway reason',
        );
      }
    }
  });

  test('World 1 checkpoint explicitly bridges to hand buckets', () {
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    final checkpoint = world1.lessons
        .expand((lesson) => lesson.taskList)
        .firstWhere((task) => task.runner.lessonId == 'world_one_checkpoint')
        .runner;

    final bridgeText = '${checkpoint.hint} ${checkpoint.feedbackReason}'
        .toLowerCase();
    expect(bridgeText, contains('bucket'));
    expect(bridgeText, contains('premium'));
    expect(bridgeText, contains('strong'));
    expect(bridgeText, contains('medium'));
    expect(bridgeText, contains('trash'));
  });

  test('World 1 includes a real-table table-read transfer rep', () {
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    final transferTasks = world1.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      contains('what_poker_is_table_read_transfer'),
    );

    final transferText = transferTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(transferText, contains('hero has two cards'));
    expect(transferText, contains('flop has three board cards'));
    expect(transferText, contains('pot is 6 bb'));
  });

  test('World 2 checkpoint explicitly bridges to position thinking', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    final checkpointLesson = world2.lessons.firstWhere(
      (lesson) => lesson.lessonId == 'discipline_checkpoint',
    );
    final checkpoint = checkpointLesson.taskList.last.runner;

    final bridgeText = '${checkpoint.hint} ${checkpoint.feedbackReason}'
        .toLowerCase();
    expect(bridgeText, contains('position'));
    expect(bridgeText, contains('seat'));
  });

  test('World 2 includes a real-table discipline transfer rep', () {
    final world2 = Act0ShellStateV1.sample.worldById('world_2');
    final transferTasks = world2.lessons
        .expand((lesson) => lesson.taskList)
        .where((task) => task.resolvedTaskFamily == Act0TaskFamilyV1.transfer)
        .toList();

    expect(
      transferTasks.map((task) => task.taskId),
      contains('discipline_checkpoint_checkpoint_table_discipline'),
    );

    final transferText = transferTasks
        .map((task) => '${task.runner.caption} ${task.runner.feedbackReason}')
        .join(' ')
        .toLowerCase();
    expect(transferText, contains('hero is hj with j4o'));
    expect(transferText, contains('naming the bucket cleanly'));
    expect(transferText, contains('inventing reasons to continue'));
  });

  test('Locked worlds cannot contain current or selectable lessons', () {
    final state = Act0ShellStateV1.sample;
    final lockedWorlds = state.worlds.where(
      (world) => world.status == Act0WorldStateV1.locked,
    );

    for (final world in lockedWorlds) {
      for (final lesson in world.lessons) {
        expect(
          lesson.state,
          isNot(Act0LessonStateV1.current),
          reason: '${world.worldId}/${lesson.lessonId} should not be current',
        );
        expect(
          lesson.isSelectable,
          isFalse,
          reason:
              '${world.worldId}/${lesson.lessonId} should not be selectable',
        );
        expect(
          lesson.isLocked,
          isTrue,
          reason: '${world.worldId}/${lesson.lessonId} should stay locked',
        );
      }
    }
  });

  test('Every optioned drill has explicit success and failure truth', () {
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    for (final lesson in world1.lessons) {
      for (final task in lesson.taskList) {
        final options = task.runner.options;
        if (options.isEmpty || task.phase == Act0LessonPhaseV1.theory) {
          continue;
        }
        expect(
          options.any((option) => option.isCorrect),
          isTrue,
          reason: '${task.taskId} needs a correct option',
        );
        expect(
          options.any((option) => !option.isCorrect),
          isTrue,
          reason: '${task.taskId} needs a wrong option',
        );
        for (final option in options) {
          expect(option.preferredLabel, isNotEmpty);
          expect(option.betterAnswerLabel, isNotEmpty);
          expect(option.feedbackTitle, isNotEmpty);
          expect(option.feedbackReason, isNotEmpty);
          if (option.isCorrect) {
            expect(option.quality, Act0FeedbackQualityV1.correct);
          } else {
            expect(
              option.quality == Act0FeedbackQualityV1.wrong ||
                  option.quality == Act0FeedbackQualityV1.suboptimal,
              isTrue,
              reason:
                  '${option.id} must be wrong or suboptimal, not ${option.quality}',
            );
          }
        }
      }
    }
  });

  test(
    'Button KTs beginner spot treats Call as legal limp, not best action',
    () {
      final world1 = Act0ShellStateV1.sample.worldById('world_1');
      for (final lesson in world1.lessons) {
        for (final task in lesson.taskList) {
          final runner = task.runner;
          final isButtonKts =
              runner.caption.contains('Button') &&
              runner.caption.contains('KTs');
          if (!isButtonKts) {
            continue;
          }
          for (final option in runner.options) {
            if (option.label == 'Call') {
              expect(option.isCorrect, isFalse);
              expect(option.preferredLabel, isNot('Call'));
              expect(option.feedbackReason.toLowerCase(), contains('legal'));
              expect(option.feedbackReason.toLowerCase(), contains('limp'));
              expect(
                option.feedbackReason.toLowerCase(),
                isNot(contains('no bet to call')),
              );
              expect(
                option.feedbackReason.toLowerCase(),
                isNot(contains('cannot call')),
              );
            }
          }
        }
      }
    },
  );

  test('First-in preflop copy does not describe limping as illegal', () {
    final world1 = Act0ShellStateV1.sample.worldById('world_1');
    final firstInNeedles = <String>[
      'first in',
      'nobody entered',
      'unopened',
      'button',
    ];
    const bannedCopy = <String>[
      'no bet to call',
      'no open bet to call',
      'cannot call',
      'can not call',
      'call is not',
      'no call',
      'does not fit',
    ];

    for (final lesson in world1.lessons) {
      for (final task in lesson.taskList) {
        final runner = task.runner;
        final runnerText = [
          runner.caption,
          runner.hint,
          runner.question,
          runner.feedbackReason,
          for (final step in runner.teachingSteps) ...[
            step.title,
            step.body,
            ...step.focusLabels,
          ],
          for (final option in runner.options) ...[
            option.feedbackReason,
            ...option.repairFocusLabels,
          ],
        ].join(' ').toLowerCase();

        final firstIn = firstInNeedles.any(runnerText.contains);
        if (!firstIn) {
          continue;
        }
        for (final banned in bannedCopy) {
          expect(
            runnerText,
            isNot(contains(banned)),
            reason: '${task.taskId} should treat first-in call as a legal limp',
          );
        }
      }
    }
  });

  test('Your first hand teaches street board growth in order', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((candidate) => candidate.lessonId == 'your_first_hand');
    final counts = lesson.taskList
        .map((task) => task.runner.table.boardCards.length)
        .toList();
    expect(counts.take(4), <int>[0, 3, 4, 5]);
    expect(counts, containsAllInOrder(<int>[0, 3, 4, 5]));
  });

  testWidgets('Completing current lesson unlocks the next lesson', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    expect(find.text('Blinds & action order'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Later'), findsWidgets);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    await tester.tapAt(const Offset(24, 100));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_theory')),
    );
    await tester.pumpAndSettle();
    await openSelectedLessonFromLearn(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);

    await completeVisibleTheoryTask(tester);
    await advanceTeachingToDrill(tester);
    expect(find.text('Check'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    expect(find.text('Check'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    expect(find.text('Fold'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    expect(find.text('Call'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_option_call')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    expect(find.text('Raise'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('act0_shell_block_summary_map_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(find.text('Blinds & action order'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_blinds_theory')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_lesson_step_blinds_theory')),
      findsOneWidget,
    );
  });

  testWidgets('Runner Review Continue advances to next task when available', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.review),
    );

    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Legality depends on price.'), findsOneWidget);
  });

  testWidgets('Bottom nav switches tabs', (tester) async {
    await pumpTall(tester, host());

    await openBottomTabAndDrainV1(tester, 'Learn');
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);

    await openBottomTabV1(tester, 'Review');
    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);

    await openBottomTabV1(tester, 'You');
    expect(find.byKey(const Key('act0_shell_profile_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_profile_hero_card')),
      findsOneWidget,
    );
    final focusFinder = find.byKey(
      const Key('act0_shell_profile_recommended_focus'),
    );
    await tester.scrollUntilVisible(focusFinder, 180);
    await tester.pumpAndSettle();
    await tester.ensureVisible(focusFinder);
    expect(focusFinder, findsOneWidget);
  });

  testWidgets('Bottom nav surfaces review backlog', (tester) async {
    await pumpTall(tester, host());

    expect(find.byKey(const Key('act0_shell_nav_badge_review')), findsNothing);

    final sample = Act0ShellStateV1.sample;
    final stateWithReviewBacklog = Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: sample.selectedWorldId,
      worlds: sample.worlds,
      lessons: sample.lessons,
      review: Act0ReviewStateV1(
        title: sample.review.title,
        subtitle: sample.review.subtitle,
        weaknessLabel: sample.review.weaknessLabel,
        reason: sample.review.reason,
        stats: sample.review.stats,
        chosenLabel: sample.review.chosenLabel,
        betterLabel: sample.review.betterLabel,
        mistakes: const <Act0MistakeCardV1>[
          Act0MistakeCardV1(
            taskId: 'nav_review_badge_task',
            lessonId: 'world_1_lesson',
            title: 'Fix one action spot',
            weaknessLabel: 'Action timing',
            selectedOptionId: 'call',
            selectedLabel: 'Call',
            betterLabel: 'Raise',
            reason: 'Late position wants more pressure here.',
            attempts: 1,
          ),
        ],
      ),
      profile: sample.profile,
    );

    await pumpTall(tester, host(state: stateWithReviewBacklog));

    expect(
      find.byKey(const Key('act0_shell_nav_badge_review')),
      findsOneWidget,
    );
    expect(find.text('1'), findsNothing);
  });

  testWidgets('Play tab shows practice groups and launches a group runner', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
        completedWorldCount: 2,
      ),
    });
    await pumpTall(tester, host());

    await tester.tap(find.text('Practice').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_play_featured_card')),
      findsOneWidget,
    );
    expect(find.text('Start daily set'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_practice_group_weak_spots')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_play_active_hub')), findsOneWidget);
    expect(find.text('Skill packs'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_play_topic_hub')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_practice_group_placement')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_continue')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_practice_group_blinds')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      180,
    );
    await tester.pumpAndSettle();
    expect(find.text('Actions'), findsOneWidget);
    // Drill sets section header separates quick picks from drills — scroll to Positions.
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_positions')),
      220,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      220,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      220,
    );
    await tester.pumpAndSettle();
    expect(find.text('Actions'), findsOneWidget);

    final actionsTile = find.byKey(
      const Key('act0_shell_practice_group_actions'),
    );
    await tester.ensureVisible(actionsTile);
    await tester.tap(actionsTile);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  });

  testWidgets(
    'Play topic packs launch representative drills and back returns to Play',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
          completedWorldCount: 2,
        ),
      });
      await pumpTall(tester, host());

      await tester.tap(find.text('Practice').first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        220,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_actions')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    },
  );

  testWidgets('Play shell uses Later for disabled practice groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0PlayShellV1(
            groups: const <Act0PracticeGroupV1>[
              Act0PracticeGroupV1(
                groupId: 'actions',
                title: 'Actions',
                subtitle: 'One crisp action family.',
                ctaLabel: 'Practice',
                categoryLabel: 'Drill',
                isEnabled: false,
              ),
            ],
            recommendedGroupId: 'actions',
            recommendedTitle: 'Best next action',
            recommendedSubtitle: 'One disabled group for copy truth.',
            recommendedReasonLabel: 'Why this next',
            recommendedOutcome: 'Keeps the route honest.',
            recommendedOutcomeLead: 'This next run',
            masteryLabel: 'Route step',
            onStartGroup: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Locked'), findsNothing);
  });

  testWidgets('Play shell localizes visible chrome cleanly in Russian', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
    });

    await pumpTall(tester, host(locale: const Locale('ru')));

    await tester.tap(find.text('Практика'));
    await tester.pumpAndSettle();

    expect(find.text('Быстрая практика'), findsOneWidget);
    expect(find.text('Быстрые дриллы'), findsOneWidget);
    expect(find.text('Паки по темам'), findsOneWidget);
    expect(find.text('Запустить дневную серию'), findsWidgets);

    expect(find.text('Quick practice'), findsNothing);
    expect(find.text('Quick drills'), findsNothing);
    expect(find.text('Topic packs'), findsNothing);
    expect(find.text('Start daily set'), findsNothing);
  });

  testWidgets(
    'Play topic packs launch straight into drills without teaching rail',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
          completedWorldCount: 2,
        ),
      });
      await pumpTall(tester, host());

      await tester.tap(find.text('Practice').first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        180,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_actions')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_learning_rail')), findsNothing);
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
    },
  );

  testWidgets(
    'Practice keeps unseen daily and topic reps locked until the route clears them',
    (tester) async {
      await pumpTall(tester, host(state: stateWithNoCompletedPractice()));

      await tester.tap(find.text('Practice').first);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
      expect(find.text('Unlock after one route drill.'), findsOneWidget);

      final actionsTile = find.byKey(
        const Key('act0_shell_practice_group_actions'),
      );
      expect(actionsTile, findsOneWidget);
      await tester.tap(actionsTile);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
      expect(find.text('Clear it on the route first.'), findsWidgets);
    },
  );

  testWidgets('Quick daily drill updates local daily progress', (tester) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    await startDailyPracticeFromHub(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_learning_rail')), findsNothing);
    await advanceCurrentRunnerToDrill(tester);
    await answerVisiblePromptCorrectly(tester);
    await waitForRapidPracticeTransition(tester);

    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_play_screen')), findsNothing);

    await exitActiveRunnerToPlayHub(tester);

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_play_featured_card')),
      findsOneWidget,
    );
    expect(find.text('Start daily set'), findsWidgets);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('1/3 daily spots'), findsOneWidget);
  });

  testWidgets('Daily practice auto-advances without a feedback continue stop', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await startDailyPracticeFromHub(tester);

    await advanceCurrentRunnerToDrill(tester);
    await answerVisiblePromptCorrectly(tester);
    await waitForRapidPracticeTransition(tester);

    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_play_screen')), findsNothing);
  });

  testWidgets(
    'Topic practice auto-advances back to Play without a feedback continue stop',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
          completedWorldCount: 2,
        ),
      });
      await pumpTall(tester, host());

      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        180,
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_actions')),
      );
      await tester.pumpAndSettle();

      await advanceCurrentRunnerToDrill(tester);
      await answerVisiblePromptCorrectly(tester);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_play_intro_card')),
        findsOneWidget,
      );
      expect(find.text('Rep complete'), findsOneWidget);
    },
  );

  testWidgets('Home shows done-for-today state after daily goal is reached', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    await completeDailySetFromPlay(tester);
    expect(find.byKey(const Key('act0_shell_play_intro_card')), findsOneWidget);
    expect(find.text('Daily set complete'), findsWidgets);

    // Home should now reflect done-for-today state
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(
      find.text('Done for today'),
      findsWidgets,
    ); // daily card + hero label
    expect(
      find.byKey(const Key('act0_shell_home_daily_done_badge')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_footer_sharky_line')),
      findsOneWidget,
    );
    final footerLine = tester.widget<Text>(
      find.byKey(const Key('act0_shell_home_footer_sharky_line')),
    );
    expect(
      footerLine.data,
      anyOf(
        'Seat held for tomorrow. One short clean rep extends it.',
        'Rhythm is locked in. One short rep keeps it alive.',
        'Pace is holding. One clean pass keeps tomorrow warm.',
      ),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_home_repair_panel')),
      80,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_home_footer_sharky_line')),
      findsOneWidget,
    );
    expect(find.text('Done for today'), findsWidgets); // daily goal card too
  });

  testWidgets(
    'Profile earned achievement unlocks after first task and streak stat appears',
    (tester) async {
      await pumpTall(tester, host());

      // Complete one correct daily drill to earn the first clear-read badge
      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      await startDailyPracticeFromHub(tester);
      await advanceCurrentRunnerToDrill(tester);
      await answerVisiblePromptCorrectly(tester);
      await waitForRapidPracticeTransition(tester);
      await exitActiveRunnerToPlayHub(tester);

      // Open Profile tab
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_profile_screen')),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_streak_nudge')),
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rhythm'), findsOneWidget);

      // Scroll to Achievements and verify the first clear-read badge is unlocked
      await tester.scrollUntilVisible(
        find.byKey(
          const Key('act0_shell_profile_achievement_first_table_read'),
        ),
        220,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      final achievement = tester.widget<Opacity>(
        find.byKey(
          const Key('act0_shell_profile_achievement_first_table_read'),
        ),
      );
      expect(achievement.opacity, equals(1.0)); // unlocked = full opacity
    },
  );

  testWidgets('Correct answer adds a recent skill gain to Profile', (
    tester,
  ) async {
    await pumpTall(tester, host(state: stateWithoutRecentSkillGains()));

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await startDailyPracticeFromHub(tester);

    await advanceCurrentRunnerToDrill(tester);
    await answerVisiblePromptCorrectly(tester);
    expect(
      find.byKey(const Key('act0_shell_feedback_growth_highlight')),
      findsNothing,
    );
    await waitForRapidPracticeTransition(tester);
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsNothing,
    );
    await exitActiveRunnerToPlayHub(tester);

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Recent progress'),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_profile_skill_stats')),
      findsOneWidget,
    );
    expect(find.text('Recent progress'), findsOneWidget);
    expect(find.textContaining('+'), findsWidgets);
  });

  testWidgets(
    'Representative Play packs feed matching skill families into Profile',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
          completedWorldCount: 2,
        ),
      });
      await pumpTall(tester, host());

      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_actions')),
        220,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_actions')),
      );
      await tester.pumpAndSettle();
      await advanceCurrentRunnerToDrill(tester);
      await answerVisiblePromptCorrectly(tester);
      await waitForRapidPracticeTransition(tester);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_rankings')),
        220,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_rankings')),
      );
      await tester.pumpAndSettle();
      await advanceCurrentRunnerToDrill(tester);
      await answerVisiblePromptCorrectly(tester);
      await waitForRapidPracticeTransition(tester);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);

      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Recent progress'),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Betting decisions'), findsWidgets);
      expect(find.text('Legal actions'), findsWidgets);
      expect(find.text('Hand reading'), findsWidgets);
      expect(find.text('Choose best five'), findsNWidgets(2));
    },
  );

  testWidgets(
    'Skill gains and profile skill stats survive a fresh dev shell mount',
    (tester) async {
      final sample = Act0ShellStateV1.sample;
      final currentLesson = sample.currentLesson;
      final currentTask = currentLesson.taskList.first;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        'act0_shell_progress_v1': jsonEncode(<String, Object>{
          'schemaVersion': 6,
          'completedTaskIds': <String>[currentTask.taskId],
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': sample.selectedWorldId,
          'selectedLessonId': currentLesson.lessonId,
          'selectedTaskId': currentLesson.taskList[1].taskId,
          'earnedXp': currentTask.rewardXp,
          'profileSkillValues': <String, int>{
            'Betting decisions': 4,
            'Table sense': 1,
          },
          'recentSkillGains': <Map<String, Object>>[
            <String, Object>{
              'label': 'Betting decisions',
              'gain': 4,
              'source': currentTask.title,
            },
          ],
        }),
      });

      await pumpTall(tester, host(showPlacementOnStart: true));
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_skill_stats')),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent progress'), findsOneWidget);
      expect(find.text('Betting decisions +4'), findsNWidgets(2));
      expect(
        find.byKey(
          const Key('act0_shell_profile_skill_stat_Betting decisions'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Profile ties focus, strengths, and recent gains into one story',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ProfileShellV1(
              profile: const Act0ProfileStateV1(
                playerName: 'New player',
                level: 'Level 1',
                xpLine: '120 / 200 XP',
                lessonsLine: '8 of 24 tasks complete',
                accuracyLine: '82% practice accuracy',
                qualityLine: '1 perfect clear',
                consistencyActiveDays: 3,
                streakLine: '3 day streak',
                streakDays: 3,
                achievements: <Act0AchievementV1>[
                  Act0AchievementV1(label: 'First clear read'),
                ],
                strongCategories: <String>['Table sense'],
                weakCategories: <String>['Action order'],
                recentSkillGains: <Act0SkillGainV1>[
                  Act0SkillGainV1(
                    label: 'Table sense',
                    gain: 6,
                    source: 'Action words',
                  ),
                ],
                recommendedFocusTitle: 'Repair one weak spot',
                recommendedFocusBody:
                    'Fix this spot before it becomes a habit.',
                recommendedFocusCtaLabel: 'Fix this now',
              ),
              onRetakePlacement: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_profile_hero_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_profile_identity_card')),
        findsNothing,
      );
      expect(find.text('Next focus'), findsOneWidget);
      expect(find.text('Table sense moved recently.'), findsOneWidget);
      expect(
        find.text('You are beginning to read the table before acting.'),
        findsOneWidget,
      );
      expect(find.text('1 perfect clear'), findsOneWidget);
      expect(find.text('82% practice accuracy'), findsNothing);
      expect(find.textContaining('Base: '), findsNothing);
      expect(find.textContaining('Recent gain: '), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_recommended_focus')),
        220,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_profile_recommended_focus_cta_label')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Profile recommended focus returns the user to Home', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.profile));

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_recommended_focus')),
      220,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_profile_recommended_focus')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
  });

  testWidgets(
    'Profile keeps start-reset tools behind a compact utility entry',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.profile));

      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
        220,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_shell_profile_screen')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_profile_first_start_tools')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_profile_first_start_tools_button')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Placement first-start cards localize cleanly in Russian', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(showPlacementOnStart: true, locale: const Locale('ru')),
    );

    expect(find.text('Проверка маршрута'), findsOneWidget);
    expect(
      find.text('Быстрая проверка старта. Без длинной настройки.'),
      findsOneWidget,
    );
    expect(find.text('Что будет дальше'), findsOneWidget);
    expect(
      find.text('Одна короткая живая проверка на реальных столах.'),
      findsOneWidget,
    );

    expect(find.text('Route check'), findsNothing);
    expect(find.text('Quick route check. No long setup.'), findsNothing);
    expect(find.text('What happens next'), findsNothing);
  });

  testWidgets('Placement recommended sheet localizes cleanly in Russian', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(showPlacementOnStart: true, locale: const Locale('ru')),
    );

    await runPlacementToResult(tester);
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_open_recommended_path')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Старт отсюда'), findsWidgets);
    expect(find.text('Первые сессии'), findsOneWidget);
    expect(find.text('Пробный премиум'), findsOneWidget);
    expect(find.text('Посмотреть 7-дневный пробный период'), findsOneWidget);
    expect(find.text('Открыть первую раздачу'), findsOneWidget);
    expect(find.text('Начать с нуля'), findsOneWidget);

    expect(find.text('Start here'), findsNothing);
    expect(find.text('First sessions'), findsNothing);
    expect(find.text('Premium trial'), findsNothing);
    expect(find.text('Preview 7-day trial'), findsNothing);
    expect(find.text('Start first hand'), findsNothing);
    expect(find.text('Start from zero'), findsNothing);
  });

  testWidgets('Play keeps placement out of the main practice surface', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_practice_group_placement')),
      findsNothing,
    );
    expect(find.text('Find my level'), findsNothing);
  });

  testWidgets(
    'Wrong answer creates a Review mistake and Fix next launches it',
    (tester) async {
      await pumpTall(tester, host());
      await createActionsMistakeFromPlayHub(tester);
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);

      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_review_board')), findsOneWidget);
      expect(find.text('Fix next'), findsWidgets);
      expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);
      expect(find.text('Repair next'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_mistake_priority_badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_mistake_attempts_badge')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_mistake_decision_strip')),
        findsOneWidget,
      );
      expect(find.text('You chose'), findsOneWidget);
      expect(find.text('Better'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_mistake_context_labels')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_mistake_context_count_badge')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_mistake_context_labels')),
        findsOneWidget,
      );
      expect(find.text('Missed 1 time'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_mistake_repair_plan')),
        findsOneWidget,
      );
      expect(find.textContaining('Replay'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_fix_next_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_review_fix_next_cta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
      expect(find.text('Repair this spot'), findsOneWidget);
      expect(find.textContaining('Take one breath'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_sharky_mascot_repair')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_table_repair_callout_text')),
        findsOneWidget,
      );
      final repairCallout = tester.widget<Text>(
        find.byKey(const Key('act0_shell_table_repair_callout_text')),
      );
      expect(repairCallout.maxLines, 3);
      expect(repairCallout.overflow, TextOverflow.fade);
      expect(
        find.byKey(const Key('act0_shell_table_repair_callout')),
        findsOneWidget,
      );
      expect(find.textContaining('Repair:'), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
    },
  );

  testWidgets('Review repair session returns with a fixed summary', (
    tester,
  ) async {
    await pumpTall(tester, host(state: Act0ShellStateV1.sample));

    await createActionsMistakeFromPlayHub(tester);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_review_fix_next_cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);

    await advanceTeachingToDrill(tester);
    await answerVisiblePromptCorrectly(tester);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_correct')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_review_board')), findsOneWidget);
    expect(find.text('Recovered lately'), findsOneWidget);
    expect(find.text('Perfect clear complete.'), findsOneWidget);
    expect(find.text('Repaired'), findsNothing);
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('act0_shell_fixed_mistake_');
      }),
      findsOneWidget,
    );
    expect(find.text('No weak spots yet.'), findsOneWidget);
  });

  testWidgets(
    'Clean repair closes the loop across Profile and Review without a permanent scar',
    (tester) async {
      await pumpTall(tester, host(state: Act0ShellStateV1.sample));

      await createActionsMistakeFromPlayHub(tester);
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      await openBottomTabV1(tester, 'Review');
      expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);
      await tester.tap(find.byKey(const Key('act0_shell_review_fix_next_cta')));
      await tester.pumpAndSettle();

      await advanceTeachingToDrill(tester);
      await answerVisiblePromptCorrectly(tester);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perfect clear complete.'), findsOneWidget);
      expect(find.textContaining('repaired'), findsNothing);
      expect(find.textContaining('mistake'), findsNothing);

      await openBottomTabV1(tester, 'You');
      expect(find.text('1 perfect clear'), findsOneWidget);
      expect(find.textContaining('practice accuracy'), findsNothing);
      expect(find.textContaining('mistake'), findsNothing);
    },
  );

  testWidgets('Review resurfaces open mistake regardless of lesson context', (
    tester,
  ) async {
    // Gate A cross-world resurfacing contract:
    // A mistake recorded in one lesson must remain visible in Review after
    // the user navigates away and returns from a different tab/context.
    // This proves the Review loop is session-wide, not filtered by lesson.
    await pumpTall(tester, host());

    // Step 1: Create a mistake in the current lesson (actions context).
    await createActionsMistakeFromPlayHub(tester);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    // Step 2: Navigate away — visit Home, then You, simulating world context switch.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();

    // Step 3: Open Review — mistake must still be present (cross-world resurfacing).
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_review_board_support_text')),
      findsOneWidget,
    );
    // Repair CTA must be available — non-punitive, actionable.
    expect(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Home prioritizes weak spot repair while Play keeps a stable lane layout',
    (tester) async {
      await pumpTall(tester, host());
      await createActionsMistakeFromPlayHub(tester);
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_home_primary_tap_target')),
        findsOneWidget,
      );
      expect(find.text('Fix next'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_home_repair_panel')),
        findsOneWidget,
      );
      expect(find.textContaining('Fix '), findsWidgets);
      expect(find.textContaining('Last miss came from'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_home_repair_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_home_repair_outcome')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'One fix now keeps the leak from following you forward.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_play_featured_card')),
        findsOneWidget,
      );
      expect(find.textContaining('Repair stays in Review'), findsOneWidget);
      expect(find.text('Skill packs'), findsOneWidget);
      await tester.tap(find.byKey(const Key('act0_shell_play_featured_cta')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    },
  );

  testWidgets('Home weak spot CTA opens repair mode directly', (tester) async {
    await pumpTall(tester, host());
    await createActionsMistakeFromPlayHub(tester);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_home_repair_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Repair this spot'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_repair')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
  });

  testWidgets('Home daily goal card pivots to weak-spot repair when needed', (
    tester,
  ) async {
    await pumpTall(tester, host());
    await createActionsMistakeFromPlayHub(tester);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_daily_practice_now')),
      findsOneWidget,
    );
    expect(find.text('Start practice'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_home_daily_goal_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Repair this spot'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_repair')),
      findsNothing,
    );
  });

  testWidgets('Repair plus daily completion earns streak-saved state', (
    tester,
  ) async {
    await pumpTall(tester, host());

    // Create and resolve one weak spot via Review flow.
    await createActionsMistakeFromPlayHub(tester);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_review_fix_next_cta')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    await answerVisiblePromptCorrectly(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    // Complete daily set (3 reps) after repair.
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await completeDailySetFromPlay(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Seat held for tomorrow'), findsWidgets);
  });

  testWidgets('Block summary exposes mastery and suggested next action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Action words',
              xpEarned: 20,
              errorCount: 0,
              taskCount: 4,
              correctCount: 4,
              startLevel: 1,
              endLevel: 1,
              startXp: 80,
              endXp: 100,
              xpTarget: 200,
              nextLessonTitle: 'Blinds and action order',
              sharkyLine: 'Clean pass. Keep the table picture simple.',
              skillGains: <Act0SkillGainV1>[
                Act0SkillGainV1(
                  label: 'Betting decisions',
                  gain: 6,
                  source: 'Action words',
                ),
                Act0SkillGainV1(
                  label: 'Table sense',
                  gain: 2,
                  source: 'Action words',
                ),
              ],
              perfectClearCount: 4,
              completedClearCount: 4,
            ),
            onReplay: () {},
            onContinue: () {},
            onBackToMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clean pass'), findsOneWidget);
    expect(find.text('Lesson complete'), findsOneWidget);
    expect(find.text('Action words'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_suggested_next')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_habit_reward')),
      findsOneWidget,
    );
    expect(find.text('Clean read'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_sharky_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_growth_highlight')),
      findsOneWidget,
    );
    expect(find.text('What moved'), findsOneWidget);
    expect(
      find.text('Betting decisions +6  •  Table sense +2'),
      findsOneWidget,
    );
    expect(find.text('Unlocked now: Blinds and action order'), findsOneWidget);
    expect(find.text('Perfect path'), findsOneWidget);
    expect(find.text('Continue to Blinds and action order.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_quality_cta')),
      findsNothing,
    );
    final gateMessage = tester.widget<Text>(
      find.byKey(const Key('act0_shell_block_summary_gate_message')),
    );
    final suggestedNext = tester.widget<Text>(
      find.byKey(const Key('act0_shell_block_summary_suggested_next')),
    );
    final accuracy = tester.widget<Text>(
      find.byKey(const Key('act0_shell_block_summary_accuracy')),
    );
    expect(gateMessage.maxLines, 4);
    expect(gateMessage.overflow, TextOverflow.fade);
    expect(suggestedNext.maxLines, 4);
    expect(suggestedNext.overflow, TextOverflow.fade);
    expect(accuracy.maxLines, 2);
    expect(accuracy.overflow, TextOverflow.fade);
    expect(
      find.byKey(const Key('act0_shell_block_summary_repair_mix')),
      findsNothing,
    );
  });

  testWidgets('World completion summary surfaces unlock and clean progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Showdown winning',
              xpEarned: 24,
              errorCount: 0,
              taskCount: 4,
              correctCount: 4,
              startLevel: 1,
              endLevel: 2,
              startXp: 188,
              endXp: 12,
              xpTarget: 200,
              sharkyLine: 'You closed the first world cleanly.',
              skillGains: <Act0SkillGainV1>[
                Act0SkillGainV1(
                  label: 'Hand reading',
                  gain: 8,
                  source: 'Poker from Zero',
                ),
                Act0SkillGainV1(
                  label: 'Table sense',
                  gain: 5,
                  source: 'Poker from Zero',
                ),
              ],
              milestoneTier: Act0ProgressMilestoneTierV1.world,
              worldNumber: 1,
              worldTitle: 'Poker from Zero',
              nextWorldNumber: 2,
              nextWorldTitle: 'Hand Discipline',
              perfectClearCount: 12,
              completedClearCount: 12,
            ),
            onReplay: () {},
            onContinue: () {},
            onBackToMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('World 1 complete'), findsOneWidget);
    expect(find.text('Poker from Zero'), findsOneWidget);
    expect(
      find.text('Unlocked now: World 2 - Hand Discipline'),
      findsOneWidget,
    );
    expect(find.text('Perfect path'), findsOneWidget);
    expect(find.text('Open next world'), findsOneWidget);
    expect(find.text('Continue to Hand Discipline.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_quality_cta')),
      findsNothing,
    );

    final detailTitle = tester.widget<Text>(
      find.byKey(const Key('act0_shell_block_summary_detail_title')),
    );
    final unlock = tester.widget<Text>(
      find.byKey(const Key('act0_shell_block_summary_unlock_label')),
    );
    expect(detailTitle.maxLines, 2);
    expect(detailTitle.overflow, TextOverflow.fade);
    expect(unlock.maxLines, 2);
    expect(unlock.overflow, TextOverflow.fade);
  });

  testWidgets(
    'World completion with imperfect clear shows optional Review for perfect when safe',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0BlockCompletionShellV1(
              summary: const Act0BlockCompletionSummaryV1(
                lessonTitle: 'Showdown winning',
                xpEarned: 24,
                errorCount: 1,
                taskCount: 4,
                correctCount: 4,
                startLevel: 1,
                endLevel: 2,
                startXp: 188,
                endXp: 12,
                xpTarget: 200,
                milestoneTier: Act0ProgressMilestoneTierV1.world,
                worldNumber: 1,
                worldTitle: 'Poker from Zero',
                nextWorldNumber: 2,
                nextWorldTitle: 'Hand Discipline',
                perfectClearCount: 10,
                completedClearCount: 12,
                hasSafeReviewTarget: true,
              ),
              onReplay: () {},
              onOpenReview: () {},
              onContinue: () {},
              onBackToMap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open next world'), findsOneWidget);
      expect(find.text('Review for perfect'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_block_summary_quality_cta')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'World completion without safe review target hides Review for perfect',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0BlockCompletionShellV1(
              summary: const Act0BlockCompletionSummaryV1(
                lessonTitle: 'Showdown winning',
                xpEarned: 24,
                errorCount: 0,
                taskCount: 4,
                correctCount: 4,
                startLevel: 1,
                endLevel: 2,
                startXp: 188,
                endXp: 12,
                xpTarget: 200,
                milestoneTier: Act0ProgressMilestoneTierV1.world,
                worldNumber: 1,
                worldTitle: 'Poker from Zero',
                nextWorldNumber: 2,
                nextWorldTitle: 'Hand Discipline',
                perfectClearCount: 10,
                completedClearCount: 12,
                hasSafeReviewTarget: false,
              ),
              onReplay: () {},
              onOpenReview: () {},
              onContinue: () {},
              onBackToMap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open next world'), findsOneWidget);
      expect(find.text('Review for perfect'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_block_summary_quality_cta')),
        findsNothing,
      );
    },
  );

  testWidgets('Block summary separates quick fixes from deep leaks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Action words',
              xpEarned: 20,
              errorCount: 1,
              taskCount: 5,
              correctCount: 4,
              startLevel: 1,
              endLevel: 1,
              startXp: 80,
              endXp: 100,
              xpTarget: 200,
              nextLessonTitle: 'Blinds and action order',
              quickFixCount: 1,
              deepLeakCount: 0,
              perfectClearCount: 4,
              completedClearCount: 5,
              hasReplayForPerfectTarget: true,
            ),
            onReplay: () {},
            onContinue: () {},
            onBackToMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_block_summary_repair_mix')),
      findsOneWidget,
    );
    expect(find.text('Solid'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_suggested_next')),
      findsOneWidget,
    );
    expect(
      find.text('Continue now, then check quick fixes in Review.'),
      findsOneWidget,
    );
    expect(find.text('Replay for perfect'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_quality_cta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_sharky_line')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_quick_fixes')),
      findsOneWidget,
    );
    expect(find.text('Quick fixes: 1'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_deep_leaks')),
      findsOneWidget,
    );
    expect(find.text('Deep leaks: 0'), findsOneWidget);
  });

  testWidgets('Block summary steers deep leaks to Review', (tester) async {
    var continued = 0;
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Action words',
              xpEarned: 20,
              errorCount: 1,
              taskCount: 5,
              correctCount: 4,
              startLevel: 1,
              endLevel: 1,
              startXp: 80,
              endXp: 100,
              xpTarget: 200,
              nextLessonTitle: 'Blinds and action order',
              quickFixCount: 0,
              deepLeakCount: 1,
              perfectClearCount: 4,
              completedClearCount: 5,
              hasSafeReviewTarget: true,
            ),
            onReplay: () {},
            onOpenReview: () {
              continued += 100;
            },
            onContinue: () {
              continued += 1;
            },
            onBackToMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Repair flagged'), findsOneWidget);
    expect(
      find.textContaining('keeps tomorrow from feeling heavier'),
      findsOneWidget,
    );
    expect(find.text('Deep leaks: 1'), findsOneWidget);
    expect(find.text('Go to Review and fix the deep leak.'), findsOneWidget);
    expect(find.textContaining('Deep leak saved for Review.'), findsOneWidget);
    expect(find.text('Review first'), findsOneWidget);
    expect(find.text('Open next lesson'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_quality_cta')),
      findsOneWidget,
    );
    final habitDetail = tester.widget<Text>(
      find.byKey(const Key('act0_shell_block_summary_habit_reward_detail')),
    );
    expect(habitDetail.maxLines, 4);
    expect(habitDetail.overflow, TextOverflow.fade);

    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();
    expect(continued, 100);
  });

  testWidgets('Review and Profile shells feel app-like and avoid taxonomy', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.review));
    expect(find.text('Repair board'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_review_board')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_review_empty_state')),
      findsOneWidget,
    );
    expect(find.text('No weak spots yet.'), findsOneWidget);
    expect(
      find.text('Finish a drill to build your review list.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_review_board_support_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_review_board_trust_line')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_review_board_next_action')),
      findsNothing,
    );
    expect(find.text('Run daily set'), findsNothing);
    expect(find.textContaining('Sharky:'), findsNothing);

    await tester.pumpWidget(host(tab: Act0ShellTabV1.profile));
    await tester.pumpAndSettle();
    expect(find.text('You'), findsWidgets);
    expect(find.text('Locked'), findsNothing);
    expect(find.text('120 / 200 XP'), findsWidgets);
    expect(find.text('Perfect path open'), findsOneWidget);
    expect(find.text('82% practice accuracy'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Poker skills'),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Poker skills'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_profile_skill_stats')),
      findsOneWidget,
    );
    expect(find.text('Table sense'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Rhythm'),
      240,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rhythm'), findsOneWidget);
    expect(find.text('First clear read'), findsOneWidget);
    expect(find.text('Three day rhythm'), findsOneWidget);

    _expectNoForbiddenLabels();
  });

  testWidgets(
    'Review surfaces a dominant repair pattern when evidence repeats',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ReviewShellV1(
              review: const Act0ReviewStateV1(
                title: 'Repair board',
                subtitle: 'Fix the biggest leak first.',
                weaknessLabel: 'Action order',
                reason: 'Late action keeps getting rushed.',
                stats: <Act0ReviewStatV1>[
                  Act0ReviewStatV1(label: 'Open', value: '2'),
                ],
                chosenLabel: 'Call',
                betterLabel: 'Fold',
                mistakes: <Act0MistakeCardV1>[
                  Act0MistakeCardV1(
                    taskId: 'a1',
                    lessonId: 'actions',
                    title: 'BTN opens action',
                    weaknessLabel: 'Action order',
                    selectedOptionId: 'call',
                    selectedLabel: 'Call',
                    betterLabel: 'Fold',
                    reason: 'Action order slipped under pressure.',
                    attempts: 2,
                  ),
                  Act0MistakeCardV1(
                    taskId: 'a2',
                    lessonId: 'actions',
                    title: 'BB closes action',
                    weaknessLabel: 'Action order',
                    selectedOptionId: 'raise',
                    selectedLabel: 'Raise',
                    betterLabel: 'Check',
                    reason: 'Action order blurred again.',
                    attempts: 1,
                  ),
                ],
              ),
              selected: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_pattern_card')),
        findsOneWidget,
      );
      expect(find.text('Pattern starting to form'), findsOneWidget);
      expect(
        find.text('Action order is showing up 2 times. Fix this family first.'),
        findsOneWidget,
      );
    },
  );

  test('Detached shell uses a local token source', () {
    final files = Directory('lib/ui_v2/act0_shell')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    expect(
      files.any((file) => file.path.endsWith('act0_shell_tokens_v1.dart')),
      isTrue,
    );
    for (final file in files) {
      if (file.path.endsWith('act0_shell_state_v1.dart') ||
          file.path.endsWith('act0_shell_tokens_v1.dart') ||
          file.path.endsWith('act0_shell_preview_screen_v2.dart')) {
        continue;
      }
      final source = file.readAsStringSync();
      if (source.contains('Act0ShellTokensV1')) {
        expect(source, contains('act0_shell_tokens_v1.dart'));
      }
    }
  });

  // ── R1: Streak Calendar ────────────────────────────────────────────────────

  test('Sample profile carries 7-day streak calendar', () {
    final profile = Act0ShellStateV1.sample.profile;
    expect(profile.streakLast7.length, equals(7));
  });

  test('Sample streak calendar matches streakDays: 3 (last 3 days active)', () {
    final profile = Act0ShellStateV1.sample.profile;
    final activeDays = profile.streakLast7.where((d) => d).length;
    expect(activeDays, equals(3));
    // The last 3 entries must all be true (consecutive streak)
    expect(profile.streakLast7[4], isTrue);
    expect(profile.streakLast7[5], isTrue);
    expect(profile.streakLast7[6], isTrue);
  });

  test(
    'Completion display state resolves deterministically without fake perfect',
    () {
      expect(
        act0ResolveTaskCompletionDisplayStateV1(
          taskId: 't1',
          isLocked: true,
          isCurrent: false,
          completedTaskIds: const <String>{'t1'},
          perfectTaskIds: const <String>{'t1'},
        ),
        Act0CompletionDisplayStateV1.locked,
      );
      expect(
        act0ResolveTaskCompletionDisplayStateV1(
          taskId: 't1',
          isLocked: false,
          isCurrent: true,
          completedTaskIds: const <String>{'t1'},
          perfectTaskIds: const <String>{'t1'},
        ),
        Act0CompletionDisplayStateV1.current,
      );
      expect(
        act0ResolveTaskCompletionDisplayStateV1(
          taskId: 't1',
          isLocked: false,
          isCurrent: false,
          completedTaskIds: const <String>{'t1'},
          perfectTaskIds: const <String>{'t1'},
        ),
        Act0CompletionDisplayStateV1.perfect,
      );
      expect(
        act0ResolveTaskCompletionDisplayStateV1(
          taskId: 't1',
          isLocked: false,
          isCurrent: false,
          completedTaskIds: const <String>{'t1'},
          perfectTaskIds: const <String>{},
        ),
        Act0CompletionDisplayStateV1.clear,
      );
      expect(
        act0ResolveTaskCompletionDisplayStateV1(
          taskId: 't1',
          isLocked: false,
          isCurrent: false,
          completedTaskIds: const <String>{},
          perfectTaskIds: const <String>{},
        ),
        Act0CompletionDisplayStateV1.current,
        reason:
            'Without canonical completion state, the helper must not fake perfect.',
      );
    },
  );

  testWidgets('Profile renders streak calendar with 7 day cells', (
    tester,
  ) async {
    // Pump the profile shell directly to avoid lazy-ListView clipping.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ProfileShellV1(
            profile: Act0ShellStateV1.sample.profile,
            onRetakePlacement: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll until the streak calendar enters the viewport
    final listKey = find.byKey(const Key('act0_shell_profile_screen'));
    expect(listKey, findsOneWidget);
    await tester.drag(listKey, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_profile_streak_calendar')),
      findsOneWidget,
    );
    // All 7 day cells present
    for (var i = 0; i < 7; i++) {
      expect(
        find.byKey(Key('act0_shell_profile_streak_day_$i')),
        findsOneWidget,
        reason: 'Day cell $i should be present in the streak calendar',
      );
    }
    expect(
      find.byKey(const Key('act0_shell_profile_streak_today_ring')),
      findsOneWidget,
    );
    // Day labels visible
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
  });

  testWidgets('Profile streak calendar localizes day labels in Russian', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.profile, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    final listKey = find.byKey(const Key('act0_shell_profile_screen'));
    await tester.drag(listKey, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Пн'), findsOneWidget);
    expect(find.text('Вс'), findsOneWidget);
    expect(find.text('Mon'), findsNothing);
  });
  // ── R2: Daily Goal Card CTA ────────────────────────────────────────────────

  testWidgets('Home daily goal card shows Practice now when goal not done', (
    tester,
  ) async {
    await pumpTall(tester, host());
    // Fresh session — daily not started, Practice now should appear on the card
    expect(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_daily_practice_now')),
      findsOneWidget,
    );
    expect(find.text('Start practice'), findsOneWidget);
  });

  testWidgets('Tapping daily goal card from Home launches drill runner', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.byKey(const Key('act0_shell_home_daily_goal_card')));
    await tester.pumpAndSettle();

    // Should have entered the runner (Play hub hidden, runner shown)
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  });

  testWidgets('Practice now disappears after daily goal is done', (
    tester,
  ) async {
    await pumpTall(tester, host());

    // Complete 3 daily drills via Play tab
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await completeDailySetFromPlay(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Daily done → Practice now should be gone
    expect(
      find.byKey(const Key('act0_shell_home_daily_practice_now')),
      findsNothing,
    );
    expect(find.text('Done for today'), findsWidgets);
  });

  // ── R3: Spaced Daily Deck ────────────────────────────────────────────────────

  testWidgets('Daily group shows spaced deck subtitle with completed worlds', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
        completedWorldCount: 2,
      ),
    });

    await pumpTall(tester, host());
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_play_featured_card')),
      findsOneWidget,
    );
    expect(find.textContaining('spots'), findsWidgets);
  });

  testWidgets('Daily group from spaced deck still launches runner', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': persistedProgressWithCompletedWorlds(
        completedWorldCount: 2,
      ),
    });

    await pumpTall(tester, host());
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await startDailyPracticeFromHub(tester);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  });

  // ── R6: Day-boundary streak ledger ───────────────────────────────────────

  testWidgets('Same-day restore: persisted streak preserved', (tester) async {
    final today = _isoDate(DateTime.now());
    final sample = Act0ShellStateV1.sample;
    final currentLesson = sample.currentLesson;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 2,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': sample.selectedWorldId,
        'selectedLessonId': currentLesson.lessonId,
        'selectedTaskId': currentLesson.taskList.first.taskId,
        'earnedXp': 0,
        'lastActiveDay': today,
        'persistedStreakDays': 5,
      }),
    });

    await pumpTall(tester, host());

    // Profile shows streak sourced from persisted data
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 day streak'), findsWidgets);
  });

  testWidgets('New-day restore: streak preserved when yesterday was active', (
    tester,
  ) async {
    final yesterday = _isoDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final sample = Act0ShellStateV1.sample;
    final currentLesson = sample.currentLesson;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 2,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': sample.selectedWorldId,
        'selectedLessonId': currentLesson.lessonId,
        'selectedTaskId': currentLesson.taskList.first.taskId,
        'earnedXp': 0,
        'lastActiveDay': yesterday,
        'persistedStreakDays': 4,
      }),
    });

    await pumpTall(tester, host());

    // Streak still shows 4 (day passed but not broken — no miss yet)
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(find.textContaining('4 day streak'), findsWidgets);
  });

  testWidgets('Missed-day restore: streak resets to zero', (tester) async {
    final twoDaysAgo = _isoDate(
      DateTime.now().subtract(const Duration(days: 2)),
    );
    final sample = Act0ShellStateV1.sample;
    final currentLesson = sample.currentLesson;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 2,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': sample.selectedWorldId,
        'selectedLessonId': currentLesson.lessonId,
        'selectedTaskId': currentLesson.taskList.first.taskId,
        'earnedXp': 0,
        'lastActiveDay': twoDaysAgo,
        'persistedStreakDays': 6,
      }),
    });

    await pumpTall(tester, host());

    // Streak is broken — shows 0, no streak text on profile
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(find.textContaining('6 day streak'), findsNothing);
  });

  testWidgets('Hot restart restore ignores runner resume and lands on Home', (
    tester,
  ) async {
    final today = _isoDate(DateTime.now());
    final sample = Act0ShellStateV1.sample;
    final currentLesson = sample.currentLesson;
    final currentTask = currentLesson.taskList.first;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 2,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': sample.selectedWorldId,
        'selectedLessonId': currentLesson.lessonId,
        'selectedTaskId': currentTask.taskId,
        'earnedXp': 0,
        'lastActiveDay': today,
        'persistedStreakDays': 2,
        'resumeInRunner': true,
        'resumePhase': 'review',
        'resumeTeachingStepIndex': 1,
        'resumeSelectedOptionId': currentTask.runner.options.first.id,
      }),
    });

    await pumpTall(tester, host());

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
      findsOneWidget,
    );
  });
}

// ── Pot calculation unit tests ────────────────────────────────────────────────
//
// These tests call act0CalcTrailPotV1 / act0ParseBbAmountV1 / act0FormatPotLabelV1
// directly (pure functions, no widget infrastructure needed).
// Each scenario maps to a real trail found in act0_shell_state_v1.dart.

void _potCalcTests() {
  group('Pot calculation — act0CalcTrailPotV1', () {
    // ── helpers ──────────────────────────────────────────────────────────────

    void expectPot(
      String desc,
      List<String> labels,
      int atIndex,
      double expectedBb, {
      String expectedStreet = 'Preflop',
    }) {
      test(desc, () {
        final result = act0CalcTrailPotV1(labels, atIndex);
        expect(
          result.potBb,
          closeTo(expectedBb, 0.01),
          reason: 'Expected pot $expectedBb BB but got ${result.potBb} BB',
        );
        expect(result.street, expectedStreet);
      });
    }

    // ── act0ParseBbAmountV1 ───────────────────────────────────────────────────
    group('act0ParseBbAmountV1', () {
      test('parses integer BB', () => expect(act0ParseBbAmountV1('3 BB'), 3.0));
      test(
        'parses decimal BB',
        () => expect(act0ParseBbAmountV1('2.5 BB'), 2.5),
      );
      test('parses no-space BB', () => expect(act0ParseBbAmountV1('1BB'), 1.0));
      test(
        'returns 0 for no match',
        () => expect(act0ParseBbAmountV1('checks'), 0.0),
      );
    });

    // ── act0FormatPotLabelV1 ──────────────────────────────────────────────────
    group('act0FormatPotLabelV1', () {
      test(
        'whole number omits decimal',
        () => expect(act0FormatPotLabelV1(7.0), 'Pot 7 BB'),
      );
      test(
        'half-BB keeps decimal',
        () => expect(act0FormatPotLabelV1(6.5), 'Pot 6.5 BB'),
      );
      test(
        'rounds to nearest 0.5',
        () => expect(act0FormatPotLabelV1(6.4), 'Pot 6.5 BB'),
      );
    });

    // ── Fallback cases ────────────────────────────────────────────────────────
    test('empty trail returns -1', () {
      expect(act0CalcTrailPotV1([], 0).potBb, -1.0);
    });

    test('trail without blinds returns -1 (e.g. mid-hand world-4 trails)', () {
      // Line 9616 in state: ['BTN raises 3 BB', 'BB calls 3 BB', 'BTN acts']
      const labels = ['BTN raises 3 BB', 'BB calls 3 BB', 'BTN acts'];
      expect(act0CalcTrailPotV1(labels, 2).potBb, -1.0);
    });

    test('trail starting with BB blind only (missing SB) falls back to -1', () {
      // In real poker SB always posts before BB. A trail that starts with BB
      // means the hand history is incomplete — we must not compute a false pot.
      const labels = ['BB blind 1 BB', 'BTN raises 3 BB'];
      expect(act0CalcTrailPotV1(labels, 1).potBb, -1.0);
    });

    // ── World 1 — step-by-step blinds (line 5500) ────────────────────────────
    group('World 1 blinds trail', () {
      const labels = ['SB blind 0.5 BB', 'BB blind 1 BB'];
      expectPot('after SB posts', labels, 0, 0.5);
      expectPot('after BB posts', labels, 1, 1.5);
    });

    // ── World 1 — BTN acts trail (line 5671) ─────────────────────────────────
    group('World 1 BTN acts trail', () {
      const labels = ['SB blind 0.5 BB', 'BB blind 1 BB', 'BTN acts'];
      expectPot('after SB', labels, 0, 0.5);
      expectPot('after BB', labels, 1, 1.5);
      // "BTN acts" has no amount → pot stays 1.5
      expectPot('after BTN acts (no amount)', labels, 2, 1.5);
    });

    // ── World 2 — action trail runner (line 7360) ────────────────────────────
    // SB 0.5 + BTN 3 + BB 3 = 6.5 on flop; BB checks adds 0 on flop.
    group('World 2 action trail — preflop raise + call + flop check', () {
      const labels = [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'BTN raises 3 BB',
        'BB calls 3 BB',
        'Flop: BB checks',
      ];
      expectPot('after SB blind', labels, 0, 0.5);
      expectPot('after BB blind', labels, 1, 1.5);
      expectPot('after BTN raises 3 BB', labels, 2, 4.5);
      // BB called to 3 BB → BB contrib = max(1, 3) = 3; pot = 0.5+3+3 = 6.5
      expectPot('after BB calls 3 BB', labels, 3, 6.5);
      // New street flushed; BB checks → 0; total still 6.5
      expectPot(
        'after Flop: BB checks',
        labels,
        4,
        6.5,
        expectedStreet: 'Flop',
      );
    });

    // ── World 4 — BTN raises + BB calls, no blinds (line 9439) ──────────────
    // Trail starts mid-hand → fallback expected.
    test('World 4 mid-hand trail falls back to static pot', () {
      const labels = ['BTN raises 3 BB', 'BB calls 3 BB', 'Flop dealt'];
      expect(act0CalcTrailPotV1(labels, 2).potBb, -1.0);
    });

    // ── Multi-street progression ──────────────────────────────────────────────
    group('Multi-street: preflop → flop → turn', () {
      const labels = [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'BTN raises 3 BB',
        'BB calls 3 BB',
        'Flop: BB bets 2 BB',
        'BTN calls 2 BB',
        'Turn: BB checks',
      ];
      // After flop action: preflop pot 6.5 + BB 2 + BTN 2 = 10.5
      expectPot('after flop bet+call', labels, 5, 10.5, expectedStreet: 'Flop');
      // Turn: BB checks → 0 contrib; pot stays 10.5
      expectPot(
        'after Turn: BB checks',
        labels,
        6,
        10.5,
        expectedStreet: 'Turn',
      );
    });

    // ── Raise then re-raise (same player max logic) ───────────────────────────
    test('raise then 3-bet: player max contribution wins', () {
      const labels = [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG opens 2.5 BB',
        'BTN raises 7.5 BB',
        'UTG calls 7.5 BB',
      ];
      final result = act0CalcTrailPotV1(labels, 4);
      // SB=0.5, BB=1, UTG=max(2.5,7.5)=7.5, BTN=7.5 → 16.5
      expect(result.potBb, closeTo(16.5, 0.01));
    });

    // ── Logic-integrity checks ────────────────────────────────────────────────
    // These tests lock in correct behaviour for edge cases that could silently
    // give wrong pot values. Each maps to a real game scenario.

    group('All 20 current content labels produce correct pot effect', () {
      // Labels that carry no amount — pot must NOT change.
      for (final label in const <String>[
        'BB acts',
        'BB checks',
        'BTN acts',
        'CO acts',
        'HJ acts',
        'HJ folds',
        'Hero acts',
        'UTG folds',
        'Flop dealt',
      ]) {
        test('skip: "$label"', () {
          // Embed in a full trail so SB-first guard passes.
          final labels = ['SB blind 0.5 BB', 'BB blind 1 BB', label];
          final before = act0CalcTrailPotV1(labels, 1).potBb; // after blinds
          final after = act0CalcTrailPotV1(labels, 2).potBb;
          expect(
            after,
            closeTo(before, 0.001),
            reason: '"$label" should not change the pot',
          );
        });
      }

      // Labels that DO carry an amount — verify exact contribution.
      test('contribution: "HJ bets 1 BB"', () {
        final labels = [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'Flop: BB checks',
          'HJ bets 1 BB',
        ];
        expect(act0CalcTrailPotV1(labels, 3).potBb, closeTo(2.5, 0.01));
      });
      test('contribution: "CO opens 2.5 BB"', () {
        final labels = ['SB blind 0.5 BB', 'BB blind 1 BB', 'CO opens 2.5 BB'];
        expect(act0CalcTrailPotV1(labels, 2).potBb, closeTo(4.0, 0.01));
      });
    });

    // ── Bug-regression: "goes all in" verb ────────────────────────────────────
    // _act0TrailActor previously missed "goes all in" → pot skipped the amount.
    test(
      '"UTG goes all in 50 BB" contributes to pot (was silently skipped)',
      () {
        const labels = [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG goes all in 50 BB',
          'BB calls 50 BB',
        ];
        final result = act0CalcTrailPotV1(labels, 3);
        // SB=0.5, BB=max(1,50)=50, UTG=50 → 100.5
        expect(result.potBb, closeTo(100.5, 0.01));
      },
    );

    // ── Bug-regression: "Flop dealt" as street separator ─────────────────────
    // If a trail uses "Flop dealt" instead of "Flop:", the flush must still
    // happen so that flop-street contributions aren't merged with preflop.
    test('"Flop dealt" triggers street flush (preflop + flop isolated)', () {
      const labels = [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'BTN raises 3 BB',
        'BB calls 3 BB',
        'Flop dealt', // bare form — must flush
        'BB bets 2 BB',
        'BTN calls 2 BB',
      ];
      // After flop bet+call: preflop pot(6.5) + BB(2) + BTN(2) = 10.5
      // Without flush: BB streetContribs = max(3, 2) = 3 and BTN = max(3, 2) = 3
      // → pot would wrongly stay at 6.5 (flop bets ignored due to max logic)
      expect(act0CalcTrailPotV1(labels, 6).potBb, closeTo(10.5, 0.01));
      expect(act0CalcTrailPotV1(labels, 6).street, 'Flop');
    });
  });
}

// Register the pot-calc group — called from main() before widget tests.
void _registerPotCalcTests() => _potCalcTests();

String _isoDate(DateTime dt) {
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

String _worldContentText(String worldId) {
  final world = Act0ShellStateV1.sample.worldById(worldId);
  final buffer = StringBuffer();
  for (final lesson in world.lessons) {
    buffer
      ..write(' ')
      ..write(lesson.title)
      ..write(' ')
      ..write(lesson.subtitle)
      ..write(' ')
      ..write(lesson.phaseLabel);
    for (final task in lesson.taskList) {
      final runner = task.runner;
      buffer
        ..write(' ')
        ..write(task.title)
        ..write(' ')
        ..write(runner.lessonTitle)
        ..write(' ')
        ..write(runner.lessonSubtitle)
        ..write(' ')
        ..write(runner.caption)
        ..write(' ')
        ..write(runner.hint)
        ..write(' ')
        ..write(runner.question)
        ..write(' ')
        ..write(runner.feedbackTitle)
        ..write(' ')
        ..write(runner.feedbackReason)
        ..write(' ')
        ..write(runner.table.streetLabel)
        ..write(' ')
        ..write(runner.table.potLabel)
        ..write(' ')
        ..write(runner.table.toCallLabel)
        ..write(' ')
        ..write(runner.table.centerLabel);
      for (final option in runner.options) {
        buffer
          ..write(' ')
          ..write(option.label)
          ..write(' ')
          ..write(option.preferredLabel)
          ..write(' ')
          ..write(option.feedbackReason);
      }
      for (final step in runner.teachingSteps) {
        buffer
          ..write(' ')
          ..write(step.title)
          ..write(' ')
          ..write(step.body);
        for (final label in step.focusLabels) {
          buffer
            ..write(' ')
            ..write(label);
        }
        final table = step.table;
        if (table != null) {
          buffer
            ..write(' ')
            ..write(table.streetLabel)
            ..write(' ')
            ..write(table.potLabel)
            ..write(' ')
            ..write(table.centerLabel);
        }
      }
    }
  }
  return buffer.toString();
}

void _expectNoForbiddenLabels() {
  for (final forbidden in const <String>[
    'Campaign Follow-up',
    'recovery',
    'campaign_spine',
    'world1_act0',
    'Expected-action accuracy',
  ]) {
    expect(find.textContaining(forbidden), findsNothing);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_beta_shell.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  _registerPotCalcTests();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget host({
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
    Act0LessonPhaseV1 phase = Act0LessonPhaseV1.theory,
    Act0ShellStateV1? state,
    bool showPlacementOnStart = false,
  }) {
    return MaterialApp(
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

  Future<void> advanceTeachingToDrill(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      if (find
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
              .isNotEmpty) {
        return;
      }
      final cta = find.byKey(const Key('act0_shell_continue_cta'));
      expect(cta, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(cta);
      await tester.pumpAndSettle();
    }
    fail('Teaching steps did not reveal a drill surface.');
  }

  Future<void> completeVisibleTheoryTask(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      final cta = find.byKey(const Key('act0_shell_continue_cta'));
      expect(cta, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(cta);
      await tester.pumpAndSettle();
      if (find.text('2/7').evaluate().isNotEmpty ||
          find
              .byKey(const Key('act0_shell_action_panel'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_seat_tap_prompt'))
              .evaluate()
              .isNotEmpty) {
        return;
      }
    }
    fail('Theory task did not advance.');
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

  Future<void> triggerSelectedLessonCta(WidgetTester tester) async {
    final cta = find.byKey(const Key('act0_shell_selected_lesson_cta'));
    expect(cta, findsOneWidget);
    await tester.tap(cta);
    await tester.pumpAndSettle();
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
    expect(act0Root.showPlacementOnStart, isFalse);
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

    expect(find.text('Poker from Zero'), findsOneWidget);
    expect(find.text('Fold, check, call, raise'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_handoff_panel')),
      findsOneWidget,
    );
    expect(
      find.text('Finish this lesson to unlock Blinds & action order.'),
      findsOneWidget,
    );
    expect(find.text('Then run Actions in Play.'), findsOneWidget);
    expect(find.text('Now: Actions'), findsNothing);
    expect(find.text('Next: Blinds & action order'), findsNothing);
    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_primary_tap_target')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_home_cta_hint')), findsOneWidget);
    expect(find.text('Next route: continue this lesson now.'), findsOneWidget);
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

  testWidgets('Dev menu reset returns to Today after clearing app progress', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'onboarding_complete': true,
      'dummy_progress': 1,
    });
    await pumpTall(tester, host());

    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_dev_menu_reset_progress')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_dev_menu_reset_confirm')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_placement_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsOneWidget);
  });

  testWidgets('Dev menu reset rewrites persisted progress to world_1', (
    tester,
  ) async {
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

    await tester.tap(find.byKey(const Key('act0_shell_home_dev_menu_button')));
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
    expect(decoded['selectedLessonId'], sample.currentLesson.lessonId);
    expect(
      decoded['selectedTaskId'],
      sample.currentLesson.taskList.first.taskId,
    );
  });

  testWidgets('AppRoot boots directly into the Act0 dev shell', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Skip'), findsOneWidget);
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
    expect(find.text('Find your path'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_placement_hero')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_intro_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_for_who')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_why_faster')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_first_10_min')),
      findsOneWidget,
    );
    expect(
      find.text('Your fastest route into real poker understanding.'),
      findsOneWidget,
    );
    expect(find.text('Who this is for'), findsOneWidget);
    expect(find.text('Why this works faster'), findsOneWidget);
    expect(find.text('Your first 10 minutes'), findsOneWidget);
    expect(find.textContaining('never held cards'), findsOneWidget);
    expect(
      find.text(
        'Placement sets your first route, your first skill map, and your first real plan.',
      ),
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
    expect(find.text('What sounds most like you right now?'), findsOneWidget);
    expect(find.text('1/6'), findsOneWidget);
    expect(find.text('Choose one'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);

    await answerPlacementQuestion(tester, 'age_18_24');
    expect(find.text('Where are you starting from?'), findsOneWidget);
    expect(find.text('2/6'), findsOneWidget);
    await answerPlacementQuestion(tester, 'new');
    expect(find.text('How often do you play?'), findsOneWidget);
    await answerPlacementQuestion(tester, 'rarely');
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
        'Before Sharky locks the route, it runs one quick live check to see whether the table already feels natural or still needs slower structure.',
      ),
      findsOneWidget,
    );
    expect(find.text('What the check looks at'), findsOneWidget);
    expect(find.textContaining('Seat awareness'), findsOneWidget);
    expect(find.textContaining('Board awareness'), findsOneWidget);
    expect(find.textContaining('Action order'), findsOneWidget);
    expect(find.text('What you get after'), findsOneWidget);
    expect(find.text('Start skill check'), findsOneWidget);
  });

  testWidgets('Placement multi-select keeps all selected answers', (
    tester,
  ) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await answerPlacementQuestion(tester, 'age_18_24');
    await answerPlacementQuestion(tester, 'friends');
    await answerPlacementQuestion(tester, 'weekly');

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
        find.byKey(const Key('act0_shell_placement_option_age_18_24')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
      await tester.pumpAndSettle();

      expect(find.text('Where are you starting from?'), findsOneWidget);
    },
  );

  testWidgets('Placement diagnostic lands in Home with one-tap useful action', (
    tester,
  ) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await answerPlacementQuestion(tester, 'age_18_24');
    await answerPlacementQuestion(tester, 'new');
    await answerPlacementQuestion(tester, 'rarely');
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

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_seat_tap_prompt')), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.text('How many cards are on this flop?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_option_three')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_seat_tap_prompt')), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_placement_result')),
      findsOneWidget,
    );
    expect(find.textContaining('3/3'), findsWidgets);
    expect(
      find.byKey(const Key('act0_shell_placement_report_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_coach_note')),
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
    expect(find.text('Sharky read'), findsOneWidget);
    expect(find.text('Sharky says'), findsOneWidget);
    expect(find.text('Core poker skills'), findsOneWidget);
    expect(find.text('Blind play'), findsOneWidget);
    expect(find.text('Table sense'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_open_recommended_path')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_destination_trust_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_next_10_block')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_placement_skill_stat_Blind play')),
      240,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_placement_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_skill_stat_Blind play')),
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
    expect(find.text('First route'), findsWidgets);
    expect(find.text('First sessions'), findsOneWidget);
    expect(find.text('Preview 7-day trial'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_recommended_trust_line')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_recommended')),
    );
    await tester.pumpAndSettle();
    // Drain the staggered skip-reveal animation timers (140 ms × up to ~20 tasks).
    await tester.pump(const Duration(seconds: 5));

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    expect(find.text('First guided start'), findsOneWidget);
    expect(find.text('Start first rep'), findsOneWidget);
    expect(
      find.text(
        'One tap opens the first guided rep chosen from your placement result.',
      ),
      findsOneWidget,
    );
    expect(find.text('First route'), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('Placement seeds poker skill stats into Profile', (tester) async {
    await pumpTall(tester, host(showPlacementOnStart: true));

    await answerPlacementQuestion(tester, 'age_18_24');
    await answerPlacementQuestion(tester, 'new');
    await answerPlacementQuestion(tester, 'rarely');
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

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_three')));
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
    // Drain staggered skip-reveal timers before navigating away.
    await tester.pump(const Duration(seconds: 5));

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

  testWidgets('Home Continue opens runner', (tester) async {
    await pumpTall(tester, host());

    expect(find.byKey(const Key('act0_shell_home_cta_hint')), findsOneWidget);
    expect(find.text('Next route: continue this lesson now.'), findsOneWidget);

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
      find.byKey(const Key('act0_shell_home_streak_strip')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_streak_trust_line')),
      findsOneWidget,
    );
    for (var i = 0; i < 7; i++) {
      expect(
        find.byKey(Key('act0_shell_home_streak_day_$i')),
        findsOneWidget,
        reason: 'Home streak strip day $i should be visible',
      );
    }

    expect(
      find.byKey(const Key('act0_shell_home_sharky_card')),
      findsOneWidget,
    );
    // Sample state has streakDays: 3 and daily not yet done → streak milestone cue fires.
    expect(find.text('3 days running. Keep it alive.'), findsOneWidget);
    expect(find.text('Consistency is the edge. You have it.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_achievement_First table read')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_achievement_Three day streak')),
      findsOneWidget,
    );
    expect(find.text('First perfect drill'), findsNothing);
  });

  testWidgets('Learn tab auto-expands current lesson on first open', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

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

  testWidgets('Learn tab CTA opens runner from expanded current lesson', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    // Drain Future.delayed scroll timers triggered by auto-expand.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

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
    await triggerSelectedLessonCta(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('Learn tab opened directly shows expanded current lesson panel', (
    tester,
  ) async {
    // Navigating to Learn via bottom nav auto-expands the current lesson.
    await pumpTall(tester, host());
    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

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

      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Auto-expanded lesson panel must be visible.
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );

      // Primary CTA button must be visible on the expanded (non-locked) lesson.
      final ctaFinder = find.byKey(const Key('act0_shell_lesson_start_cta'));
      await tester.ensureVisible(ctaFinder);
      expect(ctaFinder, findsOneWidget);

      // Tapping the CTA should launch the runner directly.
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    },
  );

  testWidgets('Profile habit section shows streak nudge', (tester) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.profile));

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_streak_nudge')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(
      find.byKey(const Key('act0_shell_profile_streak_nudge')),
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
    await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.text('2/7'), findsOneWidget);
    expect(
      find.text('No bet faces you. Which action is legal and free?'),
      findsOneWidget,
    );
    expect(find.text('Check'), findsOneWidget);
  });

  testWidgets('Active runner drill state survives a fresh dev shell mount', (
    tester,
  ) async {
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

    expect(find.text('1/7'), findsNothing);
    expect(find.text('2/7'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
    expect(
      find.text('No bet faces you. Which action is legal and free?'),
      findsOneWidget,
    );
    expect(find.text('Check'), findsOneWidget);
  });

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
    await triggerSelectedLessonCta(tester);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text("We start with Hold'em cash."), findsOneWidget);
    expect(find.text('Which seat is the hero seat?'), findsNothing);
    expect(find.text('Top seat'), findsNothing);
    expect(find.text('Bottom seat'), findsNothing);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
    await tester.pumpAndSettle();
    expect(find.text('This is a poker table.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
    await tester.pumpAndSettle();
    expect(find.text('The goal is the pot.'), findsOneWidget);
  });

  testWidgets('Drill options stay hidden until teaching is complete', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
          runner: drillReadyRunner,
          selectedTaskFamily: sizingTask.resolvedTaskFamily,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    );

    expect(find.text('Choose the best size'), findsWidgets);
    expect(find.text('Choose the best action'), findsNothing);
    expect(find.text('3 BB'), findsOneWidget);
  });

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

  testWidgets('Learn Path shows lesson cards and safe bottom padding', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    expect(find.text('Learning Path'), findsOneWidget);
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
    expect(find.text('Later'), findsWidgets);
    final learnSource = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();
    expect(learnSource, contains('Act0ShellTokensV1.bottomNavHeight'));
  });

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
      expect(find.text('Levels'), findsWidgets);
      expect(find.text('Full Mastery Path'), findsOneWidget);
      expect(find.text('36 worlds across 3 mastery tiers'), findsOneWidget);
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
        expect(find.text(title), findsWidgets);
      }

      await tester.tap(find.byKey(const Key('act0_shell_world_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_levels_menu')), findsNothing);
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
      expect(find.text('What poker is'), findsWidgets);
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);

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
      expect(find.text('Next in Volume I'), findsWidgets);
      expect(
        find.text('Finish Poker from Zero to open this world.'),
        findsOneWidget,
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

    await triggerSelectedLessonCta(tester);
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
    await tester.pump(const Duration(milliseconds: 1200));
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

    await triggerSelectedLessonCta(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Actions are table verbs.'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_learning_rail')), findsOneWidget);
  });

  testWidgets('Current lesson expands inline into a mini learning loop', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));
    final beforeTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
        )
        .dy;

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_lesson_hub_steps')),
      findsOneWidget,
    );
    for (final label in const <String>[
      'Learn',
      'Practice',
      'Fix mistakes',
      'Prove it',
    ]) {
      expect(find.text(label), findsWidgets);
    }
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
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Later'), findsWidgets);
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
    expect(find.text('Ready'), findsOneWidget);

    await triggerSelectedLessonCta(tester);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('Actions are table verbs.'), findsOneWidget);
  });

  testWidgets('Expanded lesson collapses without leaving the map', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
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

    await tester.tap(find.byKey(const Key('act0_shell_lesson_What poker is')));
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
      find.text('Spot where Hero sits before anything else starts moving.'),
      findsOneWidget,
    );
    expect(find.textContaining('Replay this node'), findsNothing);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Review lesson'), findsOneWidget);

    await triggerSelectedLessonCta(tester);

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
    await tester.pump(const Duration(milliseconds: 700));
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
      lessThan(360),
    );
    expect(
      tester
          .getBottomLeft(
            find.byKey(const Key('act0_shell_selected_lesson_panel')),
          )
          .dy,
      lessThan(812 - Act0ShellTokensV1.bottomNavHeight),
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

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Blinds & action order')),
    );
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

  testWidgets('Level 2 remains locked with multiple preview lessons', (
    tester,
  ) async {
    await pumpTall(tester, host(tab: Act0ShellTabV1.learn));

    await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_world_2')));
    await tester.pumpAndSettle();

    expect(find.text('Hand Discipline'), findsWidgets);
    expect(find.text('Next in Volume I'), findsWidgets);
    expect(
      find.text('Finish Poker from Zero to open this world.'),
      findsOneWidget,
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

    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_selected_lesson_panel')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_Fold, check, call, raise')),
    );
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
    expect(find.textContaining('One clear read'), findsOneWidget);
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
    expect(find.byKey(const Key('act0_shell_action_trail')), findsOneWidget);
    final actionTrailText = tester.widget<Text>(
      find.byKey(const Key('act0_shell_action_trail_text')),
    );
    expect(actionTrailText.data, contains('SB blind 0.5 BB'));
    expect(actionTrailText.data, contains('BB blind 1 BB'));
    expect(actionTrailText.data, contains('  .  '));
    expect(
      find.byKey(const Key('act0_shell_action_trail_step_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_action_trail_latest_step')),
      findsOneWidget,
    );
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
      final actionTrail = tester.getRect(
        find.byKey(const Key('act0_shell_action_trail')),
      );
      final ctaRect = tester.getRect(
        find.byKey(const Key('act0_shell_continue_cta')),
      );
      expect(tableRect.top, greaterThanOrEqualTo(0));
      expect(tableRect.height, lessThanOrEqualTo(560));
      expect(tableRect.bottom, lessThanOrEqualTo(812));
      expect(ctaRect.bottom, lessThanOrEqualTo(812));
      expect(tableRect.overlaps(ctaRect), isFalse);
      expect(actionTrail.overlaps(ctaRect), isFalse);
    },
  );

  testWidgets(
    'Runner Drill keeps table and action options visible on compact portrait',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
      );

      await advanceTeachingToDrill(tester);

      expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
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
      find.byKey(const Key('act0_shell_bet_chip_motion_SB')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_bet_chip_motion_BB')),
      findsOneWidget,
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
      expect(find.text('♠'), findsWidgets);
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

  testWidgets('Canonical detached shell play hides the global top bar', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

    expect(find.byKey(const Key('act0_shell_top_bar')), findsNothing);
  });

  testWidgets(
    'Canonical detached shell keeps drill guidance below the table only',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );
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
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

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

    expect(table.top - progress.bottom, lessThanOrEqualTo(32));
  });

  testWidgets(
    'Canonical detached shell review shows animated XP closing summary',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );
      await completeVisibleTheoryTask(tester);
      await advanceTeachingToDrill(tester);

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump(const Duration(milliseconds: 120));

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final toast = tester.getRect(
        find.byKey(const Key('act0_shell_completion_toast')),
      );

      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_xp')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_completion_toast_reward_label')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_pot_sweep_moment')),
        findsNothing,
      );
      expect(find.text('Clean rep'), findsOneWidget);
      expect(toast.top, greaterThan(table.top));
      expect(toast.bottom, lessThan(table.bottom));
      expect(
        find.byKey(const Key('act0_shell_feedback_closing_summary')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Canonical detached shell review shows level up when XP crosses the target',
    (tester) async {
      await pumpCompact(
        tester,
        host(
          tab: Act0ShellTabV1.play,
          phase: Act0LessonPhaseV1.theory,
          state: stateWithProgress(xp: 193, level: 1),
        ),
      );
      await completeVisibleTheoryTask(tester);
      await advanceTeachingToDrill(tester);

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        find.byKey(const Key('act0_shell_completion_toast_level_up')),
        findsOneWidget,
      );
      expect(find.text('Level up'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
    },
  );

  testWidgets(
    'Canonical detached shell shows block completion summary and continues in-node',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );

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
        find.byKey(const Key('act0_shell_block_summary_xp')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_errors')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_xp_progress')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_replay_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
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
      expect(find.textContaining('Sharky:'), findsWidgets);

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
      host(
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.theory,
        state: stateWithLessons(<Act0LessonCardV1>[lesson]),
      ),
    );

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
    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Daily set'),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_home_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Daily set'), findsOneWidget);
    expect(find.text('Quick daily drill'), findsOneWidget);
    expect(
      find.text('Daily set: three crisp reps, then keep the path moving.'),
      findsOneWidget,
    );
    expect(find.text('3 spot set'), findsOneWidget);
    expect(find.text('Clean pass'), findsOneWidget);
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
      isNull,
    );

    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_replay_cta')),
    );
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
        tab: Act0ShellTabV1.play,
        phase: Act0LessonPhaseV1.theory,
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

    await completeCurrentLessonBlock(tester);

    expect(
      find.byKey(const Key('act0_shell_block_summary_card')),
      findsOneWidget,
    );
    expect(find.textContaining(world2Lesson.title), findsWidgets);

    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
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
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_center_pot_stat')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_center_to_call_stat')),
      findsOneWidget,
    );
    expect(find.text('Action on hero'), findsOneWidget);
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
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
    );

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
    expect(find.text('Nice read.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_correct')),
      findsOneWidget,
    );
    expect(find.text('Best play: Check'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsOneWidget);
  });

  testWidgets('Wrong drill option yields wrong review state', (tester) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
    expect(find.textContaining('Good spot to fix'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Almost there.'), findsOneWidget);
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
    expect(
      find.byKey(const Key('act0_shell_feedback_replay_panel')),
      findsOneWidget,
    );
    expect(find.text('Table replay'), findsOneWidget);
    expect(find.text('Hero acts'), findsWidgets);
    expect(find.text('Blinds posted'), findsWidgets);
    expect(find.text('KTs'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_btn')),
      findsOneWidget,
    );
    expect(find.text('Nice read.'), findsNothing);
  });

  testWidgets('Suboptimal drill option yields gold feedback tier', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_call')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Playable move.'), findsOneWidget);
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
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    expect(find.text('Almost there.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsNothing);
    expect(find.byKey(const Key('act0_shell_option_raise')), findsOneWidget);
  });

  testWidgets('Second wrong answer becomes a deeper Review leak', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);
    expect(find.text('Needs work'), findsOneWidget);
    expect(find.text('Deep leak'), findsOneWidget);
    expect(find.text('2 misses'), findsOneWidget);
    expect(find.text('Missed 2 times'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Deep leak'), findsOneWidget);
    expect(find.text('Fix a deep leak'), findsOneWidget);
    expect(find.text('Fix this now'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Fix a deep leak'), findsOneWidget);
    expect(find.textContaining('Deep leak first'), findsOneWidget);

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_profile_recommended_focus')),
      findsOneWidget,
    );
    expect(find.text('Recommended focus'), findsOneWidget);
    expect(find.text('Fix a deep leak'), findsOneWidget);
  });

  testWidgets('Correct repair try becomes a light fixed Review item', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();
    expect(find.text('Nice read.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.text('Quick fixes'), findsOneWidget);
    expect(find.text('Quick fix'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_mistake_card')), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Quick fix'), findsOneWidget);
    expect(find.text('Review a quick fix'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_handoff_panel')),
      findsOneWidget,
    );
  });

  testWidgets('Quick fix card can replay the repaired spot', (tester) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
    expect(find.text('Run fix again'), findsOneWidget);
    await tester.ensureVisible(find.text('Run fix again'));
    await tester.tap(find.text('Run fix again'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
  });

  testWidgets('Correct drill option yields correct review state', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
    expect(find.textContaining('Sharp read'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Nice read.'), findsOneWidget);
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
      find.byKey(const Key('act0_shell_feedback_replay_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_context_labels')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_replay_panel')),
      findsOneWidget,
    );
    expect(find.text('Table read'), findsOneWidget);
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
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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

    expect(find.text('Almost there.'), findsOneWidget);
    expect(find.text('Better option: Fold'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_context_labels')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_replay_panel')),
      findsOneWidget,
    );
    expect(find.text('Facing a bet'), findsWidgets);
    expect(find.text('Pot 7 BB'), findsWidgets);
    expect(find.text('To call 2 BB'), findsWidgets);
  });

  testWidgets(
    'Canonical detached shell interaction back undoes review selection',
    (tester) async {
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
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
    final customTrailText = tester.widget<Text>(
      find.byKey(const Key('act0_shell_action_trail_text')),
    );
    expect(customTrailText.data, contains('XSB calls 2'));
    expect(customTrailText.data, contains('XCO raises'));
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

  testWidgets('Active non-hero seat shows To act together with bet amount', (
    tester,
  ) async {
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
    expect(find.text('To act - 0.5 BB'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bet_chip_POST')), findsOneWidget);
  });

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

      expect(find.text('To act - 1 BB'), findsOneWidget);
      expect(find.text('To act - 0.5 BB'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_active_seat_ring_bb_active')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_active_seat_ring_sb_highlight')),
        findsOneWidget,
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

    expect(find.text('To act - 1 BB'), findsOneWidget);
    expect(find.text('To act - 0.5 BB'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_bb_current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_active_seat_ring_sb_stale')),
      findsNothing,
    );
  });

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
            final runner = task.runner.copyWith(
              phase: phase,
              selectedOptionId: selectedOptionId,
              teachingStepIndex: teachingStepIndex,
            );
            return Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: runner,
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
    expect(find.byKey(const Key('act0_shell_seat_tap_prompt')), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(find.text('Almost there.'), findsOneWidget);
    expect(find.text('Better option: UTG'), findsOneWidget);

    phase = Act0LessonPhaseV1.drill;
    selectedOptionId = null;
    teachingStepIndex = 0;
    await pumpTall(tester, seatHost());
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_seat_tap_utg')));
    await tester.pumpAndSettle();

    expect(find.text('Nice read.'), findsOneWidget);
    expect(find.text('Best play: UTG'), findsOneWidget);
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

    final dominatedLesson = world2.lessons.firstWhere(
      (candidate) => candidate.lessonId == 'weak_ace_warning',
    );
    final dominatedTask = dominatedLesson.taskList.firstWhere(
      (candidate) => candidate.runner.caption.contains('Hero is BTN with A7o'),
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

    final kqoContinueTask = dominatedLesson.taskList.firstWhere(
      (candidate) => candidate.runner.caption.contains('Hero is BTN with KQo'),
    );

    expect(kqoContinueTask.runner.caption, contains('Hero is BTN with KQo'));
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
    'Action trail highlights the latest step without pot sweep on review',
    (tester) async {
      // Phase 1: verify trail icon and latest badge using a runner that has
      // actionTrail items (the action-trail drill task in your_first_hand).
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
              runner: trailTask.runner,
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

      // Phase 2: verify that answering a drill shows completion toast but no
      // pot-sweep overlay. Use the stateful host on the check-action drill.
      await pumpCompact(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.theory),
      );
      await completeVisibleTheoryTask(tester);
      await advanceTeachingToDrill(tester);

      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsOneWidget,
      );
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

    expect(teachingText, contains("No-Limit Hold'em cash games"));
    expect(teachingText, contains('Cash is the cleanest base'));
    expect(teachingText, contains('Hole cards stay hidden at first'));
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
        contains('3 BB into 6 BB is half-pot'),
      );
    },
  );

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
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_lesson_step_actions_theory')),
    );
    await tester.pumpAndSettle();
    await triggerSelectedLessonCta(tester);
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
    expect(find.text('Start'), findsOneWidget);
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

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_profile_screen')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_retake_placement_cta')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_profile_retake_placement_cta')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_profile_retake_placement_cta')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_placement_screen')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_intro_cta')),
      findsOneWidget,
    );
  });

  testWidgets('Play tab shows practice groups and launches a group runner', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_play_rationale_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_play_outcome_line')),
      findsOneWidget,
    );
    expect(find.text('Best next action'), findsOneWidget);
    expect(
      find.text(
        'Keep the lesson moving. On return: Blinds & action order stays next to unlock.',
      ),
      findsOneWidget,
    );
    expect(find.text('Continue lesson'), findsOneWidget);
    expect(find.text('Find my level'), findsOneWidget);
    expect(find.text('Start check'), findsOneWidget);
    expect(find.text('Placement'), findsOneWidget);
    expect(find.text('Diagnostic'), findsOneWidget);
    expect(find.text('Fix weak spots'), findsOneWidget);
    expect(find.text('Start daily set'), findsOneWidget);
    expect(find.text('0/3 daily spots'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      180,
    );
    expect(find.text('Actions'), findsOneWidget);
    // Drill sets section header separates quick picks from drills — scroll to Positions.
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_positions')),
      220,
    );
    expect(find.text('Positions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_rankings')),
      220,
    );
    expect(find.text('Hand rankings'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      -220,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_practice_group_actions')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  });

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

  testWidgets('Quick daily drill updates local daily progress', (tester) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('0/3 daily spots'), findsWidgets);

    await tester.tap(find.byKey(const Key('act0_shell_practice_group_daily')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      180,
    );
    expect(find.text('1/3 daily spots'), findsWidgets);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('1/3 daily spots'), findsOneWidget);
  });

  testWidgets('Home shows done-for-today state after daily goal is reached', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    // Round 1: theory auto-advances to first drill (actions_legal_context)
    await tester.tap(find.byKey(const Key('act0_shell_practice_group_daily')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    // Round 2: routes directly to actions_check_drill
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      180,
    );
    await tester.tap(find.byKey(const Key('act0_shell_practice_group_daily')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    // Round 3: routes to actions_fold_drill — correct answer is fold
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      180,
    );
    await tester.tap(find.byKey(const Key('act0_shell_practice_group_daily')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

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
    expect(find.text('Great session'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_home_handoff_panel')),
      80,
    );
    await tester.pumpAndSettle();
    expect(find.text('Great session'), findsWidgets);
    expect(find.text('Done for today'), findsWidgets); // daily goal card too
  });

  testWidgets(
    'Profile earned achievement unlocks after first task and streak stat appears',
    (tester) async {
      await pumpTall(tester, host());

      // Complete one correct daily drill to earn "First table read"
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_daily')),
      );
      await tester.pumpAndSettle();
      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(const Key('act0_shell_option_check')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      // Open Profile tab
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_profile_screen')),
        findsOneWidget,
      );

      // Streak stat tile is visible
      expect(find.text('Streak'), findsOneWidget);

      // Scroll to Achievements and verify "First table read" is now unlocked
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

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_practice_group_daily')));
    await tester.pumpAndSettle();

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Recent gains'),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_profile_recent_skill_gains')),
      findsOneWidget,
    );
    expect(find.text('Recent gains'), findsOneWidget);
    expect(find.textContaining('+'), findsWidgets);
  });

  testWidgets(
    'Profile ties focus, strengths, and recent gains into one story',
    (tester) async {
      await pumpTall(tester, host(tab: Act0ShellTabV1.profile));

      expect(
        find.byKey(const Key('act0_shell_profile_identity_card')),
        findsOneWidget,
      );
      expect(find.text('Your game right now'), findsOneWidget);
      expect(find.textContaining('Recent gains'), findsWidgets);
      expect(find.textContaining('Base: '), findsWidgets);
      expect(find.textContaining('Next reps: '), findsWidgets);
      expect(find.textContaining('Recent gain: '), findsWidgets);
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

    await tester.tap(
      find.byKey(const Key('act0_shell_profile_recommended_focus')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.text('Best next action'), findsOneWidget);
  });

  testWidgets('Placement preview launches a deterministic runner', (
    tester,
  ) async {
    await pumpTall(tester, host());

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('act0_shell_practice_group_placement')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
  });

  testWidgets(
    'Wrong answer creates a Review mistake and Fix next launches it',
    (tester) async {
      await pumpTall(
        tester,
        host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
      );

      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);

      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      expect(find.text('Fix this now'), findsWidgets);

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_review_board')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_review_board_open_count')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_board_next_action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_board_next_action_title')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_mistake_card')), findsOneWidget);
      expect(find.text('Repair next'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_mistake_priority_badge')),
        findsOneWidget,
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
      expect(find.text('Hero acts'), findsWidgets);
      expect(find.text('Blinds posted'), findsWidgets);
      expect(find.text('Missed 1 time'), findsOneWidget);
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

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      180,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_practice_group_actions')),
    );
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);

    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
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
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    expect(find.text('Nice read.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_review_board')), findsOneWidget);
    expect(find.text('Quick fixes'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_fixed_mistake_actions_legal_context')),
      findsOneWidget,
    );
    expect(find.text('No weak spots yet.'), findsOneWidget);
  });

  testWidgets('Review resurfaces open mistake regardless of lesson context', (
    tester,
  ) async {
    // Gate A cross-world resurfacing contract:
    // A mistake recorded in one lesson must remain visible in Review after
    // the user navigates away and returns from a different tab/context.
    // This proves the Review loop is session-wide, not filtered by lesson.
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    // Step 1: Create a mistake in the current lesson (actions context).
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
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
      find.byKey(const Key('act0_shell_review_board_open_count')),
      findsOneWidget,
    );
    // Repair CTA must be available — non-punitive, actionable.
    expect(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
      findsOneWidget,
    );
  });

  testWidgets('Home and Play prioritize weak spot repair after a mistake', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Repair first'), findsOneWidget);
    expect(find.text('Repair one weak spot'), findsOneWidget);
    expect(find.textContaining('Fix this mistake'), findsOneWidget);
    expect(find.text('Next route: repair this spot now.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_handoff_outcome')),
      findsOneWidget,
    );
    expect(
      find.textContaining('On repair: return to Actions.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
    expect(find.text('Repair first'), findsOneWidget);
    expect(find.text('Repair one weak spot'), findsOneWidget);
    expect(
      find.text('Fix this now. On repair: return to Actions.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_play_mastery_label')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('act0_shell_play_primary_cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Repair this spot'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_repair')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
  });

  testWidgets('Home weak spot CTA opens repair mode directly', (tester) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Repair this spot'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_repair')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_action_panel')), findsNothing);
  });

  testWidgets(
    'Home handoff panel can be dismissed for the current suggestion',
    (tester) async {
      await pumpTall(tester, host());

      expect(
        find.byKey(const Key('act0_shell_home_handoff_panel')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_home_handoff_dismiss')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_home_handoff_panel')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    },
  );

  testWidgets('Home handoff dismissal expires after seven days', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final dismissedKey = <String>[
      'continueLesson',
      sample.selectedWorldId,
      sample.currentLesson.lessonId,
      sample.currentLesson.taskList.first.taskId,
      'continue',
    ].join('|');
    final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
    final dismissedDay =
        '${eightDaysAgo.year.toString().padLeft(4, '0')}-'
        '${eightDaysAgo.month.toString().padLeft(2, '0')}-'
        '${eightDaysAgo.day.toString().padLeft(2, '0')}';

    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 4,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': sample.selectedWorldId,
        'selectedLessonId': sample.currentLesson.lessonId,
        'selectedTaskId': sample.currentLesson.taskList.first.taskId,
        'earnedXp': 0,
        'lastActiveDay': dismissedDay,
        'persistedStreakDays': 0,
        'dismissedHomeHandoffKey': dismissedKey,
        'dismissedHomeHandoffDay': dismissedDay,
      }),
    });

    await pumpTall(tester, host());

    expect(
      find.byKey(const Key('act0_shell_home_handoff_panel')),
      findsOneWidget,
    );
  });

  testWidgets('Home daily goal card pivots to weak-spot repair when needed', (
    tester,
  ) async {
    await pumpTall(
      tester,
      host(tab: Act0ShellTabV1.play, phase: Act0LessonPhaseV1.drill),
    );

    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Repair weak spot →'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_home_daily_goal_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.text('Repair this spot'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_repair')),
      findsOneWidget,
    );
  });

  testWidgets('Repair plus daily completion earns streak-saved state', (
    tester,
  ) async {
    await pumpTall(tester, host());

    // Create and resolve one weak spot via Review flow.
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_actions')),
      180,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_practice_group_actions')),
    );
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_review_fix_next_cta')));
    await tester.pumpAndSettle();
    await advanceTeachingToDrill(tester);
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    // Complete daily set (3 reps) after repair.
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    final dailyAnswerKeys = <Key>[
      const Key('act0_shell_option_check'),
      const Key('act0_shell_option_fold'),
      const Key('act0_shell_option_call'),
    ];
    for (final answerKey in dailyAnswerKeys) {
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_daily')),
        180,
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_daily')),
      );
      await tester.pumpAndSettle();
      await advanceTeachingToDrill(tester);
      await tester.tap(find.byKey(answerKey));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Streak saved today'), findsWidgets);
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
              sharkyLine: 'Sharky: clean pass. Keep the table picture simple.',
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
    expect(
      find.byKey(const Key('act0_shell_block_summary_suggested_next')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_sharky_line')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_block_summary_habit_reward')),
      findsOneWidget,
    );
    expect(find.text('Clean pass bonus'), findsOneWidget);
    expect(find.textContaining('pattern to repeat tomorrow'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_sharky_mascot_celebrate')),
      findsOneWidget,
    );
    expect(find.text('Continue to Blinds and action order.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_repair_mix')),
      findsNothing,
    );
  });

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
    expect(find.text('Comeback win'), findsOneWidget);
    expect(find.textContaining('Review it once later'), findsOneWidget);
    expect(find.text('Quick fixes'), findsOneWidget);
    expect(find.text('Deep leaks'), findsOneWidget);
    expect(
      find.text('Continue now, then check quick fixes in Review.'),
      findsOneWidget,
    );
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
            ),
            onReplay: () {},
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
    expect(find.text('Repair streak'), findsOneWidget);
    expect(
      find.textContaining('Fixing it now builds the habit'),
      findsOneWidget,
    );
    expect(find.text('Deep leaks'), findsOneWidget);
    expect(find.text('Go to Review and fix the deep leak.'), findsOneWidget);
    expect(find.textContaining('Deep leak saved for Review.'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();
    expect(continued, 1);
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
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_review_board_next_action')),
      findsOneWidget,
    );
    expect(find.text('Run daily set'), findsOneWidget);
    expect(find.textContaining('Sharky:'), findsNothing);

    await tester.pumpWidget(host(tab: Act0ShellTabV1.profile));
    await tester.pumpAndSettle();
    expect(find.text('You'), findsWidgets);
    expect(find.text('Locked'), findsNothing);
    expect(find.text('120 / 200 XP'), findsWidgets);
    expect(find.text('82% practice accuracy'), findsOneWidget);
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
    expect(find.text('Tap any skill to learn what it means.'), findsOneWidget);
    expect(find.text('Later'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Daily habit'),
      240,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Daily habit'), findsOneWidget);
    expect(find.text('First table read'), findsOneWidget);
    expect(find.text('Three day streak'), findsOneWidget);

    _expectNoForbiddenLabels();
  });

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
      expect(source, contains('act0_shell_tokens_v1.dart'));
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
    // Day labels visible
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
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
    expect(find.text('Practice now →'), findsOneWidget);
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
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    for (var round = 0; round < 3; round++) {
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_practice_group_daily')),
        180,
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_practice_group_daily')),
      );
      await tester.pumpAndSettle();
      await advanceTeachingToDrill(tester);
      final answerKey = round < 2
          ? const Key('act0_shell_option_check')
          : const Key('act0_shell_option_fold');
      await tester.tap(find.byKey(answerKey));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
    }

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
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      180,
    );

    expect(
      find.text('Finish three spaced spots across completed worlds.'),
      findsOneWidget,
    );
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
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_practice_group_daily')),
      180,
    );
    await tester.tap(find.byKey(const Key('act0_shell_practice_group_daily')));
    await tester.pumpAndSettle();

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

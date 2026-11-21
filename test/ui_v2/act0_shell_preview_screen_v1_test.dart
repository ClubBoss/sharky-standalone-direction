import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('consecutive civil dates survive spring daylight saving jump', () {
    // New York clocks advance on Mar 8, 2026: 23 elapsed hours
    // separate Mar 8 and Mar 9 local midnights.
    expect(act0AreConsecutiveCivilDaysV1('2026-03-08', '2026-03-09'), isTrue);
    // Most of Europe moves forward on Mar 29, 2026.
    expect(act0AreConsecutiveCivilDaysV1('2026-03-29', '2026-03-30'), isTrue);
  });

  test('regular year boundaries and leap-day runs remain consecutive', () {
    expect(act0AreConsecutiveCivilDaysV1('2026-12-31', '2027-01-01'), isTrue);
    expect(act0AreConsecutiveCivilDaysV1('2028-02-28', '2028-02-29'), isTrue);
    expect(act0AreConsecutiveCivilDaysV1('2028-02-29', '2028-03-01'), isTrue);
  });

  test('same, skipped, backward or missing dates cannot continue streak', () {
    expect(act0AreConsecutiveCivilDaysV1('2026-03-08', '2026-03-08'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('2026-03-08', '2026-03-10'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('2026-03-10', '2026-03-09'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('', '2026-03-09'), isFalse);
    expect(act0AreConsecutiveCivilDaysV1('not-a-day', '2026-03-09'), isFalse);
  });

  Widget host({
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
    bool showPlacementOnStart = false,
    Act0ShellStateV1? overrideState,
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
        debugLegacyPlacementOnStart: true,
        initialTab: tab,
        showPlacementOnStart: showPlacementOnStart,
        state: overrideState,
      ),
    );
  }

  Future<void> pumpCompact(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  testWidgets('Placement root copy follows live EN/RU MaterialApp locale', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      host(showPlacementOnStart: true, locale: const Locale('en')),
    );
    expect(find.text('Find my start'), findsOneWidget);

    await tester.tap(find.byKey(const Key('act0_shell_placement_intro_cta')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_placement_question_experience')),
      findsOneWidget,
    );
    // The eyebrow is supplied by the ROOT, not by the localized leaf.
    expect(find.text('Starting point'), findsOneWidget);

    await tester.pumpWidget(
      host(showPlacementOnStart: true, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        '\u0422\u043e\u0447\u043a\u0430 \u0441\u0442\u0430\u0440\u0442\u0430',
      ),
      findsOneWidget,
    );
    expect(find.text('Starting point'), findsNothing);
    expect(
      find.text(
        '\u042f \u043d\u043e\u0432\u0438\u0447\u043e\u043a \u0432 \u043f\u043e\u043a\u0435\u0440\u0435',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      host(showPlacementOnStart: true, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Starting point'), findsOneWidget);
    expect(
      find.text(
        '\u0422\u043e\u0447\u043a\u0430 \u0441\u0442\u0430\u0440\u0442\u0430',
      ),
      findsNothing,
    );
  });

  Widget wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1 surface) {
    return MaterialApp(
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        debugLegacyPlacementOnStart: true,
        showPlacementOnStart: false,
        debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: surface,
        ),
      ),
    );
  }

  test('Canonical path root remains Act0 preview shell', () {
    final root = buildCanonicalPathRootV1();

    expect(root, isA<Act0ShellPreviewScreenV1>());
    expect((root as Act0ShellPreviewScreenV1).showPlacementOnStart, isTrue);
  });

  test('Act0 sample state keeps canonical W1-W12 runtime identity', () {
    final state = Act0ShellStateV1.sample;
    const expectedTitles = <String, String>{
      'world_1': 'Poker from Zero',
      'world_2': 'Hand Discipline',
      'world_3': 'Position Thinking',
      'world_4': 'Bet Purpose / Price',
      'world_5': 'Board Awareness',
      'world_6': 'Range Thinking',
      'world_7': 'Visible Cards Change Ranges',
      'world_8': 'Stack Depth And Risk',
      'world_9': 'Tournament Pressure',
      'world_10': 'Player Adjustment',
      'world_11': 'Real Play Transfer',
      'world_12': 'Mindset Bridge',
    };

    for (final entry in expectedTitles.entries) {
      final world = state.worldById(entry.key);
      expect(world.worldId, entry.key);
      expect(world.title, entry.value);
      expect(world.lessons, isNotEmpty, reason: '${entry.key} has no lessons.');
    }
  });

  testWidgets('Home uses current authored lesson cue after World 1', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.sample;
    final world = sample
        .worldById('world_2')
        .copyWith(
          status: Act0WorldStateV1.current,
          isSelectable: true,
          isLocked: false,
        );
    final selectedLesson = world.lessons.first.copyWith(
      state: Act0LessonStateV1.current,
      isSelectable: true,
      isLocked: false,
    );
    final lessons = <Act0LessonCardV1>[
      selectedLesson,
      ...world.lessons.skip(1),
    ];
    final selectedState = Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: 'world_2',
      worlds: <Act0WorldCardV1>[world.copyWith(lessons: lessons)],
      lessons: lessons,
      review: sample.review,
      profile: sample.profile,
    );
    await pumpCompact(tester, host(overrideState: selectedState));

    if (act0AcademyHomePreviewV1) {
      expect(find.byType(Act0AcademyHomeLeafV1), findsOneWidget);
      final input = tester
          .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
          .input;
      expect(input.nextAction!.title, selectedLesson.title);
      expect(input.nextAction!.subtitle, selectedLesson.subtitle);
      expect(find.text('Hand Discipline'), findsOneWidget);
      expect(find.text(selectedLesson.subtitle), findsOneWidget);
    } else {
      expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
      expect(find.text(selectedLesson.subtitle), findsOneWidget);
      // The learner has reached World 2: preserve a truthful current world.
      expect(find.text('Current world: Hand Discipline'), findsOneWidget);
    }
    expect(find.text('Week 1: train one table read'), findsNothing);
    expect(
      find.text(
        'Read the legal actions first so the first real hand is not a guess.',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Act0 preview shell renders Home and opens Learn lane', (
    tester,
  ) async {
    await pumpCompact(tester, host());

    if (act0AcademyHomePreviewV1) {
      expect(find.byType(Act0AcademyHomeLeafV1), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsNothing);
      expect(find.text('Start lesson'), findsOneWidget);
      expect(find.byKey(const Key('act0_home_daily_practice')), findsNothing);
      expect(
        find.byKey(const Key('act0_academy_home_leaf_cta')),
        findsOneWidget,
      );
    } else {
      expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsNothing);
      expect(
        find.text(
          'Read the legal actions first so the first real hand is not a guess.',
        ),
        findsOneWidget,
      );
    }
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Learn'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_current_mission_card')),
      findsOneWidget,
    );
    expect(find.text('Learn route'), findsOneWidget);
    expect(find.text('Hand rankings 1'), findsWidgets);
  });

  testWidgets('Wave 2 Learn fresh shows one current mission and one percent', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2LearnFresh),
    );

    final journey = find.byKey(
      const Key('act0_shell_journey_preview_surface_v5'),
    );
    expect(find.text('First Table Guide'), findsOneWidget);
    expect(
      find.descendant(of: journey, matching: find.text('First Table Guide')),
      findsNothing,
    );
    expect(find.text('0%'), findsOneWidget);
    final routeBoard = tester.widget<Text>(
      find.byKey(const Key('act0_shell_learn_route_board')),
    );
    expect(routeBoard.data, '0 of 12 lessons');

    await tester.tap(
      find.byKey(const Key('act0_shell_learn_v5_view_full_path')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: journey, matching: find.text('First Table Guide')),
      findsNothing,
    );
    expect(find.text('All lessons'), findsOneWidget);
  });

  testWidgets('Wave 2 Learn progressed keeps proof without current duplicate', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2LearnProgressed),
    );

    final journey = find.byKey(
      const Key('act0_shell_journey_preview_surface_v5'),
    );
    expect(find.text('Cards, ranks & suits'), findsOneWidget);
    expect(
      find.descendant(of: journey, matching: find.text('Cards, ranks & suits')),
      findsNothing,
    );
    expect(
      find.descendant(of: journey, matching: find.text('First Table Guide')),
      findsOneWidget,
    );
    expect(find.text('8%'), findsOneWidget);
    final routeBoard = tester.widget<Text>(
      find.byKey(const Key('act0_shell_learn_route_board')),
    );
    expect(routeBoard.data, '1 of 12 lessons');
    expect(
      find.byKey(const Key('act0_shell_current_mission_cta')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Home turns confirmed route progress into an honest momentum cue',
    (tester) async {
      await pumpCompact(tester, host());

      if (act0AcademyHomePreviewV1) {
        final input = tester
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input;
        expect(input.earnedLessonCount, 4);
        expect(input.courseLessonCount, 12);
        expect(find.text('4 of 12 lessons complete'), findsOneWidget);
        expect(find.text('Continue with the next hand.'), findsNothing);
        expect(find.textContaining('mastery'), findsNothing);
      } else {
        expect(
          find.byKey(const Key('act0_shell_home_proof_momentum_line')),
          findsOneWidget,
        );
        final momentum = tester.widget<Text>(
          find.byKey(const Key('act0_shell_home_proof_momentum_text')),
        );
        expect(momentum.data, 'Continue with the next hand.');
        expect(find.textContaining('mastery'), findsNothing);
        expect(find.textContaining('streak'), findsNothing);
      }
    },
  );

  testWidgets('Home does not invent proof when progress is unavailable', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0HomeShellV1(
            state: Act0ShellStateV1.sample,
            showChecklist: false,
            onContinue: () {},
          ),
        ),
      ),
    );

    // No earned lesson exists, so a proof/momentum receipt must not render.
    expect(
      find.byKey(const Key('act0_shell_home_proof_momentum_line')),
      findsNothing,
    );
    expect(find.textContaining('lessons complete'), findsNothing);
  });

  testWidgets('Wave 2 Home fresh keeps a useful continuation below the hero', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2HomeFresh),
    );

    if (act0AcademyHomePreviewV1) {
      expect(find.text('First Table Guide'), findsOneWidget);
      expect(find.text('0 of 12 lessons complete'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_academy_home_leaf_next_card')),
        findsOneWidget,
      );
      expect(find.text('Recall'), findsOneWidget);
      expect(find.text('Learn'), findsWidgets);
      expect(find.text('Apply'), findsOneWidget);
      expect(find.text('Route proof is active.'), findsNothing);
      final cta = find.byKey(const Key('act0_academy_home_leaf_cta'));
      expect(tester.getRect(cta).bottom, lessThan(844));
      expect(cta.hitTestable(), findsOneWidget);
    } else {
      expect(find.text('First Table Guide'), findsOneWidget);
      expect(find.text('0 of 12 lessons complete'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_home_daily_plan_card')),
        findsOneWidget,
      );
      expect(find.text('Today\'s sequence'), findsOneWidget);
      expect(find.text('Route proof is active.'), findsNothing);
      expect(
        tester.getBottomLeft(find.byKey(const Key('act0_shell_main_cta'))).dy,
        lessThan(844),
      );
    }
  });

  testWidgets('Wave 2 Home progressed states completion once', (tester) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2HomeProgressed),
    );

    if (act0AcademyHomePreviewV1) {
      expect(find.text('Cards, ranks & suits'), findsOneWidget);
      expect(find.text('1 of 12 lessons complete'), findsOneWidget);
      expect(find.text('8%'), findsOneWidget);
      expect(
        tester
            .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
            .input
            .earnedLessonCount,
        1,
      );
      expect(find.textContaining('1 lessons complete'), findsNothing);
      expect(find.text('Continue with the next hand.'), findsNothing);
      expect(
        find.byKey(const Key('act0_academy_home_leaf_cta')),
        findsOneWidget,
      );
    } else {
      expect(find.text('Cards, ranks & suits'), findsOneWidget);
      expect(find.text('1 of 12 lessons complete'), findsOneWidget);
      expect(find.text('Continue with the next hand.'), findsOneWidget);
      expect(find.textContaining('1 lessons complete'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_home_daily_plan_card')),
        findsOneWidget,
      );
    }
  });

  testWidgets('Home resumes feedback and Review retains the open repair', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final queue = Act0ProgressStoreV1(
      key: 'act0_shell_progress_v1',
      isValidPayload: (_) => false,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await queue.flush();
    final world = Act0ShellStateV1.sample.worldById('world_1');
    final lesson = world.lessons.singleWhere(
      (l) => l.lessonId == 'fold_check_call_raise',
    );
    SharedPreferences.setMockInitialValues({
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 18,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'earnedXp': 0,
        'selectedWorldId': 'world_1',
        'selectedLessonId': lesson.lessonId,
        'selectedTaskId': 'actions_legal_context',
        'skippedTaskIds': [
          for (final l in world.lessons.takeWhile(
            (l) => l.lessonId != lesson.lessonId,
          ))
            for (final t in l.taskList) t.taskId,
          for (final t in lesson.taskList.takeWhile(
            (t) => t.taskId != 'actions_legal_context',
          ))
            t.taskId,
        ],
      }),
    });
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_current_mission_cta')));
    await tester.pumpAndSettle();
    final fold = find.byKey(const Key('act0_shell_option_fold'));
    for (var i = 0; i < 12 && fold.evaluate().isEmpty; i++) {
      final next = find.byKey(const Key('act0_shell_continue_cta'));
      expect(next, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(fold, findsOneWidget);
    for (var i = 0; i < 6; i++)
      await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(fold);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    final dynamic shell = tester.state(find.byType(Act0ShellPreviewScreenV1));
    final intent =
        shell.debugOpenRepairIntentPayloadForSourceTaskV1(
              'actions_legal_context',
            )
            as Map<String, Object?>;
    expect(intent['repairOccurrenceId'], isNot(isEmpty));
    expect(intent['targetTaskId'], 'actions_check_drill');

    if (act0AcademyHomePreviewV1) {
      expect(find.text('Continue lesson'), findsOneWidget);
      expect(find.text('Repair one weak spot'), findsNothing);
      await tester.tap(find.byKey(const Key('act0_academy_home_leaf_cta')));
      await tester.pumpAndSettle();
      final savedFeedback = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(savedFeedback.selectedTaskId, 'actions_legal_context');
      expect(savedFeedback.runner.selectedOptionId, 'fold');
      expect(savedFeedback.runner.phase, Act0LessonPhaseV1.review);
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review').last);
      await tester.pumpAndSettle();
      final repair = find.byKey(
        const Key('act0_academy_review_leaf_repair_cta'),
      );
      await tester.ensureVisible(repair);
      await tester.tap(repair);
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedWorldId, 'world_1');
      expect(runner.selectedLessonId, 'fold_check_call_raise');
      expect(runner.selectedTaskId, 'actions_check_drill');
      expect(tester.takeException(), isNull);
    } else {
      expect(find.text('Repair one weak spot'), findsOneWidget);
      expect(find.text('Practice this spot'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_home_personalized_return_reason')),
        findsOneWidget,
      );
      expect(
        find.textContaining('You missed this clue last time.'),
        findsOneWidget,
      );
    }
  });

  testWidgets('Wave 2 Profile fresh is claim-safe and owns each fact once', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2ProfileFresh),
    );

    if (act0AcademyYouPreviewV1) {
      final input = tester
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      expect(input.completedTaskCount, 0);
      expect(input.practiceDaysLastWeek, 0);
      expect(input.earnedMoments, isEmpty);
      expect(input.bankedRepairCount, 0);
      expect(input.reinforcedRepairCount, 0);
      expect(
        find.byKey(const Key('act0_academy_you_leaf_not_earned')),
        findsOneWidget,
      );
      expect(
        find.text('Answer your first question correctly without help.'),
        findsOneWidget,
      );
      expect(find.text('Your record begins here'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_academy_you_leaf_tasks')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_academy_you_leaf_streak')),
        findsNothing,
      );
      expect(find.text('Recent correct answers'), findsNothing);
      expect(
        find.text('You answered recent questions without help.'),
        findsNothing,
      );
      expect(find.text('You are building this skill.'), findsNothing);
      expect(find.text('Clean progress started'), findsNothing);
      expect(find.text('Clean reads are becoming a habit.'), findsNothing);
    } else {
      expect(find.text('Start with your first hand'), findsOneWidget);
      expect(
        find.text('Your first clear read will appear here.'),
        findsOneWidget,
      );
      expect(find.textContaining('Not confirmed yet'), findsOneWidget);
      expect(find.text('Recent correct answers'), findsNothing);
      expect(find.text('0 tasks complete'), findsOneWidget);
      expect(find.text('Starting now'), findsNothing);
      expect(find.text('Your practice will appear here'), findsOneWidget);
      expect(find.textContaining('First Table Guide'), findsOneWidget);
      expect(find.text('Clean progress started'), findsNothing);
      expect(find.text('Clean reads are becoming a habit.'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_profile_hero_fact_tasks')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_profile_hero_fact_streak')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_profile_evidence_signal')),
        findsOneWidget,
      );
    }
  });

  testWidgets(
    'Wave 2 Profile legacy fixture preserves history without current proof',
    (tester) async {
      await pumpCompact(
        tester,
        wave2SurfaceHost(
          Act0ControlledDemoCaptureSurfaceV1.wave2ProfileProgressed,
        ),
      );

      if (act0AcademyYouPreviewV1) {
        final input = tester
            .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
            .input;
        expect(input.completedTaskCount, 8);
        expect(input.practiceDaysLastWeek, 3);
        expect(input.bankedRepairCount, 0);
        expect(input.reinforcedRepairCount, 0);
        expect(find.text('8 tasks completed'), findsOneWidget);
        expect(
          find.text('3 days practiced in the last 7 days'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_academy_you_leaf_tasks')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_academy_you_leaf_streak')),
          findsOneWidget,
        );
        expect(find.text('Recent correct answers'), findsNothing);
        expect(find.text('What Sharky can prove'), findsNothing);
        expect(
          find.text('You answered recent questions without help.'),
          findsNothing,
        );
        expect(find.text('You are building this skill.'), findsNothing);
      } else {
        expect(find.textContaining('Not confirmed yet'), findsOneWidget);
        expect(find.text('Recent correct answers'), findsNothing);
        expect(
          find.text('Practice saved. Try another hand without help.'),
          findsOneWidget,
        );
        expect(find.text('What Sharky can prove'), findsNothing);
        expect(find.text('7 tasks complete'), findsOneWidget);
        expect(find.text('3d'), findsOneWidget);
        expect(find.text('3 day streak'), findsNothing);
        expect(find.textContaining('Fold, check, call, raise'), findsOneWidget);
        expect(
          find.byKey(const Key('act0_shell_profile_evidence_signal')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_shell_profile_hero_fact_tasks')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('act0_shell_profile_hero_fact_streak')),
          findsNothing,
        );
      }
    },
  );

  testWidgets(
    'F07: real authored theory counter advances exactly one step per tap '
    'and never overshoots its true total',
    (tester) async {
      await pumpCompact(
        tester,
        MaterialApp(
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0ShellPreviewScreenV1(
            debugLegacyPlacementOnStart: true,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerTheory,
              worldId: 'world_1',
              lessonId: 'what_poker_is_content',
              taskId: 'what_poker_is_pot_stack',
            ),
          ),
        ),
      );

      Act0RunnerStateV1 currentRunner() => tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .runner;

      final totalTeachingSteps = currentRunner().teachingSteps.length;
      // A real two-step lesson keeps this guard independent of the new first launch.
      expect(totalTeachingSteps, greaterThan(1));

      for (
        var expectedIndex = 0;
        expectedIndex < totalTeachingSteps;
        expectedIndex++
      ) {
        final runner = currentRunner();
        expect(runner.phase, Act0LessonPhaseV1.theory);
        expect(runner.teachingStepIndex, expectedIndex);
        final next = find.byKey(const Key('act0_shell_continue_cta'));
        expect(
          find.descendant(of: next, matching: find.text('Next')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_shell_previous_cta')),
          expectedIndex == 0 ? findsNothing : findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(const Key('act0_learning_scene_v3_support')),
              )
              .data,
          runner.teachingSteps[expectedIndex].body,
        );

        final progressFinder = find.byKey(
          const Key('act0_learning_scene_v3_progress'),
        );
        if (progressFinder.evaluate().isNotEmpty) {
          final label = tester.widget<Text>(progressFinder).data ?? '';
          final parts = label.split('/');
          expect(parts, hasLength(2));
          final current = int.parse(parts[0]);
          final total = int.parse(parts[1]);
          expect(total, totalTeachingSteps);
          // F07: the counter's current step must never read past its real
          // authored total (the old off-by-one briefly showed e.g. "3/2").
          expect(current, lessThanOrEqualTo(total));
          expect(current, expectedIndex + 1);
        }

        await tester.pump(const Duration(milliseconds: 900));
        await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
        await tester.pumpAndSettle();
      }

      // Exactly one tap per authored step must leave theory. The old guard
      // let the index overshoot by one, so it took one wasted extra tap
      // through an invalid out-of-range step before theory actually ended.
      expect(currentRunner().phase, isNot(Act0LessonPhaseV1.theory));
    },
  );
}

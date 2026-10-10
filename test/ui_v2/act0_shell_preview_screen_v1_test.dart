import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
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

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.text(selectedLesson.subtitle), findsOneWidget);
    // The learner has reached World 2: preserve a truthful current world.
    expect(find.text('Current world: Hand Discipline'), findsOneWidget);
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

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsNothing);
    expect(
      find.text(
        'Read the legal actions first so the first real hand is not a guess.',
      ),
      findsOneWidget,
    );

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
    expect(
      find.text(
        'This lesson teaches one table read: what each legal action means before you choose.',
      ),
      findsOneWidget,
    );
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
    expect(routeBoard.data, '0 of 9 lessons');

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
    expect(find.text('What poker is'), findsOneWidget);
    expect(
      find.descendant(of: journey, matching: find.text('What poker is')),
      findsNothing,
    );
    expect(
      find.descendant(of: journey, matching: find.text('First Table Guide')),
      findsOneWidget,
    );
    expect(find.text('11%'), findsOneWidget);
    final routeBoard = tester.widget<Text>(
      find.byKey(const Key('act0_shell_learn_route_board')),
    );
    expect(routeBoard.data, '1 of 9 lessons');
    expect(
      find.byKey(const Key('act0_shell_current_mission_cta')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Home turns confirmed route progress into an honest momentum cue',
    (tester) async {
      await pumpCompact(tester, host());

      expect(
        find.byKey(const Key('act0_shell_home_proof_momentum_line')),
        findsOneWidget,
      );
      final momentum = tester.widget<Text>(
        find.byKey(const Key('act0_shell_home_proof_momentum_text')),
      );
      expect(
        momentum.data,
        'Route proof is active. Next proof starts with one clean read.',
      );
      expect(find.textContaining('mastery'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);
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

    final momentum = tester.widget<Text>(
      find.byKey(const Key('act0_shell_home_proof_momentum_text')),
    );
    expect(
      momentum.data,
      'Your route is ready. Next proof starts with one clean read.',
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

    expect(find.text('First Table Guide'), findsOneWidget);
    expect(find.text('0 of 9 lessons complete'), findsOneWidget);
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
  });

  testWidgets('Wave 2 Home progressed states completion once', (tester) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2HomeProgressed),
    );

    expect(find.text('What poker is'), findsOneWidget);
    expect(find.text('1 of 9 lessons complete'), findsOneWidget);
    expect(
      find.text(
        'Route proof is active. Next proof starts with one clean read.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('1 lessons complete'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_home_daily_plan_card')),
      findsOneWidget,
    );
  });

  testWidgets('Wave 2 Home repair return keeps its personalized reason', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(
        Act0ControlledDemoCaptureSurfaceV1.wave2HomeRepairReturn,
      ),
    );

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
  });

  testWidgets('Wave 2 Profile fresh is claim-safe and owns each fact once', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(Act0ControlledDemoCaptureSurfaceV1.wave2ProfileFresh),
    );

    expect(find.text('Proof starts here'), findsOneWidget);
    expect(
      find.text('Your first clear read will appear here.'),
      findsOneWidget,
    );
    expect(find.text('Recent route proof'), findsNothing);
    expect(find.text('0 tasks complete'), findsOneWidget);
    expect(find.text('Starting now'), findsNothing);
    expect(find.text('Proof will appear as you learn'), findsOneWidget);
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
      findsNothing,
    );
  });

  testWidgets('Wave 2 Profile progressed keeps real proof without repeats', (
    tester,
  ) async {
    await pumpCompact(
      tester,
      wave2SurfaceHost(
        Act0ControlledDemoCaptureSurfaceV1.wave2ProfileProgressed,
      ),
    );

    expect(find.text('Recent route proof'), findsOneWidget);
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
  });

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
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerTheory,
            ),
          ),
        ),
      );

      Act0RunnerStateV1 currentRunner() => tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .runner;

      final totalTeachingSteps = currentRunner().teachingSteps.length;
      // The real first-value theory task (`what_poker_is_theory`) authors
      // several steps; fail loudly if that source fact ever changes under
      // this test instead of silently testing nothing.
      expect(totalTeachingSteps, greaterThan(1));

      for (
        var expectedIndex = 0;
        expectedIndex < totalTeachingSteps;
        expectedIndex++
      ) {
        final runner = currentRunner();
        expect(runner.phase, Act0LessonPhaseV1.theory);
        expect(runner.teachingStepIndex, expectedIndex);

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

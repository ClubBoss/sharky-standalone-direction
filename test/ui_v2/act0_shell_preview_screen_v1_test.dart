import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget host({
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
    bool showPlacementOnStart = false,
  }) {
    return MaterialApp(
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        initialTab: tab,
        showPlacementOnStart: showPlacementOnStart,
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
}

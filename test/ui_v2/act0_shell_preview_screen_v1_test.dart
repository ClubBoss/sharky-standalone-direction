import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
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
}

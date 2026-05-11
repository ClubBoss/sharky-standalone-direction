import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 40,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    final statusFinder = find.byKey(
      const Key('session_drill_player_status_header'),
    );
    final promptFinder = find.byKey(const Key('session_drill_player_prompt'));
    final loadErrorFinder = find.byKey(
      const Key('session_drill_player_load_error'),
    );
    String describeFinderText(Finder candidate) {
      if (candidate.evaluate().isEmpty) {
        return '<missing>';
      }
      final widget = tester.widget(candidate);
      if (widget is Text) {
        return widget.data ?? '<null>';
      }
      return '<${widget.runtimeType}>';
    }

    final status = describeFinderText(statusFinder);
    final prompt = describeFinderText(promptFinder);
    final loadError = loadErrorFinder.evaluate().isNotEmpty
        ? (tester.widget<Text>(loadErrorFinder).data ?? '<null>')
        : '<missing>';
    fail(
      'Timed out waiting for ${finder.description}; '
      'status=$status; prompt=$prompt; loadError=$loadError',
    );
  }

  SessionDrillItemV1 _item(
    String id, {
    required String prompt,
    required String winner,
    required String why,
    required List<String> heroCards,
    required List<String> villainCards,
    required List<String> boardCards,
    String street = 'river',
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"showdown_winner_choice_v1","prompt":"$prompt","street_v1":"$street","hero_hole_cards_v1":["${heroCards[0]}","${heroCards[1]}"],"villain_hole_cards_v1":["${villainCards[0]}","${villainCards[1]}"],"board_cards_v1":["${boardCards[0]}","${boardCards[1]}","${boardCards[2]}","${boardCards[3]}","${boardCards[4]}"],"available_actions_v1":["hero","villain","board_plays"],"expected":{"actionId":"$winner"},"error_class":"showdown_winner_choice_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'showdown_winner_choice_v1 keeps winner selection deterministic',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _item(
          'hero_pair',
          prompt: 'Hero has top pair and villain has second pair. Who wins?',
          winner: 'hero',
          why: 'Top pair beats second pair.',
          heroCards: const <String>['Ah', 'Qd'],
          villainCards: const <String>['7c', '7s'],
          boardCards: const <String>['Ad', 'Kc', '9h', '4s', '2d'],
        ),
        _item(
          'board_plays',
          prompt: 'The board already makes the best straight. Who wins?',
          winner: 'board_plays',
          why: 'When the board holds the best hand, both players tie.',
          heroCards: const <String>['Ac', '7d'],
          villainCards: const <String>['Kc', '2h'],
          boardCards: const <String>['Ts', '9d', '8c', '7h', '6s'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_showdown_winner_bar_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_showdown_winner_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_showdown_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_showdown_villain_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_showdown_board_plays_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_showdown_source_street_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_showdown_source_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_showdown_source_villain_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_showdown_source_board_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_showdown_villain_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );
      expect(
        find.text('Better answer: Hero. Villain misses this scene.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Notice: Top pair beats second pair.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Next time: Compare the made hands first, then choose the winner.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_showdown_hero_v1')),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('session_drill_player_showdown_board_plays_v1')),
      );
      await tester.pump();
    },
  );

  testWidgets('w2.s01 exposes showdown bridge intro and recap', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s01'),
    ))!;
    expect(
      drills.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_hero_top_pair_showdown',
        'choose_villain_straight_showdown',
        'choose_board_plays_showdown',
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s01',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(
        const Key('session_drill_player_world2_showdown_intro_card_v1'),
      ),
    );

    expect(
      find.byKey(
        const Key('session_drill_player_world2_showdown_intro_card_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world2_showdown_intro_line_1_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_showdown_winner_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_showdown_source_street_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_showdown_source_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_showdown_source_villain_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_showdown_source_board_v1')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_showdown_hero_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_showdown_villain_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_showdown_board_plays_v1')),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(
        const Key('session_drill_player_world2_showdown_recap_card_v1'),
      ),
    );

    expect(
      find.byKey(
        const Key('session_drill_player_world2_showdown_recap_card_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world2_showdown_recap_line_1_v1'),
      ),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
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
    final status = statusFinder.evaluate().isNotEmpty
        ? ((tester.widget(statusFinder) is Text)
              ? (tester.widget<Text>(statusFinder).data ?? '<null>')
              : '<non-text>')
        : '<missing>';
    final prompt = promptFinder.evaluate().isNotEmpty
        ? ((tester.widget(promptFinder) is Text)
              ? (tester.widget<Text>(promptFinder).data ?? '<null>')
              : '<non-text>')
        : '<missing>';
    final loadError = loadErrorFinder.evaluate().isNotEmpty
        ? ((tester.widget(loadErrorFinder) is Text)
              ? (tester.widget<Text>(loadErrorFinder).data ?? '<null>')
              : '<non-text>')
        : '<missing>';
    fail(
      'Timed out waiting for ${finder.description}; '
      'status=$status; prompt=$prompt; loadError=$loadError',
    );
  }

  SessionDrillItemV1 _item(
    String id, {
    required String prompt,
    required String actorId,
    required String why,
    required String heroSeat,
    required String villainSeat,
    required List<String> activeSeats,
    List<String> foldedSeats = const <String>[],
    List<String> emptySeats = const <String>[],
    int playerCount = 2,
    String street = 'flop',
  }) {
    final foldedJson = foldedSeats.isEmpty
        ? ''
        : ',"folded_seats_v1":["${foldedSeats.join('","')}"]';
    final emptyJson = emptySeats.isEmpty
        ? ''
        : ',"empty_seats_v1":["${emptySeats.join('","')}"]';
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"position_thinking_choice_v1","prompt":"$prompt","player_count_v1":$playerCount,"hero_seat_v1":"$heroSeat","villain_seat_v1":"$villainSeat","active_seats_v1":["${activeSeats.join('","')}"]$foldedJson$emptyJson,"street_v1":"$street","available_actions_v1":["hero","villain"],"expected":{"actionId":"$actorId"},"error_class":"position_thinking_choice_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets('position_thinking_choice_v1 keeps actor choice deterministic', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final drills = <SessionDrillItemV1>[
      _item(
        'hero_ip',
        prompt:
            'Hero is on the button versus the big blind. Who is in position?',
        actorId: 'hero',
        why: 'The button acts later after the flop.',
        heroSeat: 'btn',
        villainSeat: 'bb',
        activeSeats: const <String>['btn', 'bb'],
        foldedSeats: const <String>['co'],
        emptySeats: const <String>['sb'],
        playerCount: 4,
      ),
      _item(
        'villain_later',
        prompt:
            'Hero is in the cutoff and villain is on the button. Who acts later?',
        actorId: 'villain',
        why: 'The button acts later after the flop.',
        heroSeat: 'co',
        villainSeat: 'btn',
        activeSeats: const <String>['co', 'btn'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s02',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('session_drill_player_position_thinking_bar_v1')),
    );

    expect(
      find.byKey(const Key('session_drill_player_position_thinking_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_villain_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_street_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_players_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_villain_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_active_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_folded_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_empty_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_table_v1')),
      findsOneWidget,
    );

    final table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_position_table_v1')),
    );
    final scenario = table.scenarioSpec;
    expect(scenario, isNotNull);
    expect(scenario!.seatCount, 4);
    expect(scenario.heroSeat, 0);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(
      scenario.decisionNodeV1.legalActions,
      equals(<String>['hero', 'villain']),
    );
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');
    expect(
      scenario.resolvedSeatOccupanciesV1,
      equals(const <ScenarioSeatOccupancyV1>[
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.folded,
        ScenarioSeatOccupancyV1.empty,
      ]),
    );
    expect(find.byKey(const Key('modern_table_seat_empty_3')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('session_drill_player_position_villain_v1')),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('session_drill_player_result_fail')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Better answer: HERO. VILLAIN misses this scene.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Notice: The button acts later after the flop.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Next time: Compare the live seats after the flop, then mark HERO because BTN acts later.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_position_hero_v1')),
    );
    await _pumpUntilFound(
      tester,
      find.text(
        'Hero is in the cutoff and villain is on the button. Who acts later?',
      ),
    );

    expect(
      find.byKey(const Key('session_drill_player_position_thinking_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Hero is in the cutoff and villain is on the button. Who acts later?',
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('w2.s02 exposes position bridge intro through supplements', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s02'),
    ))!;
    expect(
      drills.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_hero_in_position_btn_vs_bb',
        'choose_hero_out_of_position_bb_vs_btn',
        'choose_villain_acts_later_co_vs_btn',
        'choose_raise_btn_open',
        'choose_call_btn_defend',
        'choose_fold_utg_open',
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s02',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(
        const Key('session_drill_player_world2_position_intro_supplement_v1'),
      ),
    );

    expect(
      find.byKey(
        const Key('session_drill_player_world2_position_intro_supplement_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key(
          'session_drill_player_world2_position_intro_supplement_v1_title',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key(
          'session_drill_player_world2_position_intro_supplement_v1_body',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_street_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_players_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_villain_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_active_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_folded_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_source_empty_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_position_table_v1')),
      findsOneWidget,
    );

    final table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_position_table_v1')),
    );
    final scenario = table.scenarioSpec;
    expect(scenario, isNotNull);
    expect(scenario!.seatCount, 4);
    expect(scenario.heroSeat, 0);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(
      scenario.decisionNodeV1.legalActions,
      equals(<String>['hero', 'villain']),
    );
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');
    expect(
      scenario.resolvedSeatOccupanciesV1,
      equals(const <ScenarioSeatOccupancyV1>[
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.active,
        ScenarioSeatOccupancyV1.folded,
        ScenarioSeatOccupancyV1.empty,
      ]),
    );
    expect(find.byKey(const Key('modern_table_seat_empty_3')), findsOneWidget);
    expect(
      find.byKey(const Key('session_drill_player_position_thinking_bar_v1')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_position_hero_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_position_hero_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_position_villain_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_texture_raise_v1')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_raise_v1')),
    );
    await _pumpUntilFound(
      tester,
      find.text(
        'Button facing one open with playable price: choose the defined response.',
      ),
    );
    expect(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Button facing one open with playable price: choose the defined response.',
      ),
      findsAtLeastNWidgets(1),
    );
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await _pumpUntilFound(
      tester,
      find.text('Early-seat weak opener candidate: choose the safer default.'),
    );
    expect(
      find.byKey(const Key('session_drill_player_texture_fold_v1')),
      findsOneWidget,
    );
    expect(
      find.text('Early-seat weak opener candidate: choose the safer default.'),
      findsAtLeastNWidgets(1),
    );
  });
}

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
    required String lastAggressor,
    required String initiativeOwner,
    int playerCount = 2,
    String street = 'flop',
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"initiative_aggressor_choice_v1","prompt":"$prompt","player_count_v1":$playerCount,"hero_seat_v1":"$heroSeat","villain_seat_v1":"$villainSeat","active_seats_v1":["${activeSeats.join('","')}"],"street_v1":"$street","last_aggressor_v1":"$lastAggressor","initiative_owner_v1":"$initiativeOwner","available_actions_v1":["hero","villain"],"expected":{"actionId":"$actorId"},"error_class":"initiative_aggressor_choice_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'initiative_aggressor_choice_v1 keeps aggressor choice deterministic',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _item(
          'hero_initiative',
          prompt: 'Hero raised and villain called. Who has initiative?',
          actorId: 'hero',
          why: 'The raiser keeps initiative.',
          heroSeat: 'btn',
          villainSeat: 'bb',
          activeSeats: const <String>['btn', 'bb'],
          lastAggressor: 'hero',
          initiativeOwner: 'hero',
        ),
        _item(
          'villain_aggressor',
          prompt: 'Villain raised and hero called. Who was the last aggressor?',
          actorId: 'villain',
          why: 'Villain made the last raise.',
          heroSeat: 'bb',
          villainSeat: 'btn',
          activeSeats: const <String>['btn', 'bb'],
          lastAggressor: 'villain',
          initiativeOwner: 'villain',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s03',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_initiative_bar_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_initiative_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_initiative_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_initiative_villain_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_street_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_players_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_initiative_source_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_villain_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_active_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_last_aggressor_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_owner_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_initiative_table_v1')),
        findsOneWidget,
      );

      final table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_initiative_table_v1')),
      );
      final scenario = table.scenarioSpec;
      expect(scenario, isNotNull);
      expect(scenario!.seatCount, 2);
      expect(scenario.heroSeat, 0);
      expect(scenario.actingSeatStart, 0);
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(
        scenario.decisionNodeV1.legalActions,
        equals(<String>['hero', 'villain']),
      );
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_initiative_villain_v1')),
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
        find.textContaining('Notice: The raiser keeps initiative.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Next time: Start from the last raise, then carry initiative forward to HERO before you choose.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_initiative_hero_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.text(
          'Villain raised and hero called. Who was the last aggressor?',
        ),
      );

      expect(
        find.byKey(const Key('session_drill_player_initiative_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Villain raised and hero called. Who was the last aggressor?',
        ),
        findsAtLeastNWidgets(1),
      );
    },
  );

  testWidgets(
    'w2.s03 exposes initiative bridge intro and recap through supplements',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s03'),
      ))!;
      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_hero_has_initiative_open_vs_call',
          'choose_villain_last_aggressor_open_vs_call',
          'choose_hero_more_likely_to_continue_pressure',
          'choose_call_facing_bet',
          'choose_raise_oop_isolation',
          'choose_fold_oop_pressure',
        ]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s03',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_intro_supplement_v1',
          ),
        ),
      );

      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_intro_supplement_v1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_intro_supplement_v1_title',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_intro_supplement_v1_body',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_street_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_players_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_initiative_source_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_villain_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_active_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_last_aggressor_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_initiative_source_owner_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_initiative_table_v1')),
        findsOneWidget,
      );

      final table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_initiative_table_v1')),
      );
      final scenario = table.scenarioSpec;
      expect(scenario, isNotNull);
      expect(scenario!.seatCount, 2);
      expect(scenario.heroSeat, 0);
      expect(scenario.actingSeatStart, 0);
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(
        scenario.decisionNodeV1.legalActions,
        equals(<String>['hero', 'villain']),
      );
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');
      expect(
        find.byKey(const Key('session_drill_player_initiative_bar_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_initiative_hero_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(
        find.byKey(const Key('session_drill_player_initiative_villain_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(
        find.byKey(const Key('session_drill_player_initiative_hero_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_recap_supplement_v1',
          ),
        ),
      );

      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_recap_supplement_v1',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_initiative_recap_supplement_v1_body',
          ),
        ),
        findsOneWidget,
      );
    },
  );
}

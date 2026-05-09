import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine_v2/decision/decision_bar_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  SessionDrillItemV1 _item(String id) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"bet_sizing_choice_v1","prompt":"Choose sizing preset.","expected":{"presetId":"half_pot"},"acceptable_preset_ids":["one_third_pot"],"error_class":"expected_action_mismatch","why_v1":"Half pot builds value while keeping worse hands in.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'bet_sizing_choice_v1 preset buttons render and expected/acceptable/fail outcomes are deterministic',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = <SessionDrillItemV1>[_item('size_a'), _item('size_b')];
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_bet_sizing_preset_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_preset_pot_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_preset_min_raise_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_pot_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_detail')),
        findsOneWidget,
      );
      expect(
        find.text('Better line: BET 1/2. BET POT is weaker here.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Half pot builds value while keeping worse hands in.'),
        findsOneWidget,
      );

      // Acceptable preset => soft-pass line + why visible
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_soft_pass_info_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'BET 1/3 works, but BET 1/2 is the stronger line here.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_result_soft_pass_reason_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Half pot builds value while keeping worse hands in.'),
        findsOneWidget,
      );
    },
  );

  test('world1 visible betting mini-cluster reuses canonical preset ids', () async {
    final drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
      'w1.s01',
    );
    final pilots = drills
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .toList(growable: false);

    expect(
      pilots.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_half_pot_value',
        'choose_one_third_pot_keep_price',
        'choose_pot_pressure',
        'choose_min_raise_reopen',
      ]),
    );
    expect(pilots, hasLength(4));

    final valuePilot = pilots[0];
    expect(
      valuePilot.spec.prompt,
      'Pick the value size that still keeps worse hands in.',
    );
    expect(
      valuePilot.spec.whyV1,
      'Half pot builds value without pushing marginal hands out as often.',
    );
    expect(valuePilot.spec.expected.presetId, 'half_pot');
    expect(
      valuePilot.spec.acceptablePresetIds,
      equals(const <String>['one_third_pot']),
    );

    final smallPilot = pilots[1];
    expect(
      smallPilot.spec.prompt,
      'Pick the smaller size that still keeps the price easy for weaker hands.',
    );
    expect(
      smallPilot.spec.whyV1,
      'One third pot keeps the price comfortable and still gets paid by many weaker hands.',
    );
    expect(smallPilot.spec.expected.presetId, 'one_third_pot');
    expect(
      smallPilot.spec.acceptablePresetIds,
      equals(const <String>['half_pot']),
    );

    final pressurePilot = pilots[2];
    expect(
      pressurePilot.spec.prompt,
      'Pick the size that puts the most pressure on hands that want a cheap call.',
    );
    expect(
      pressurePilot.spec.whyV1,
      'Pot makes the call expensive and creates the most pressure.',
    );
    expect(pressurePilot.spec.expected.presetId, 'pot');
    expect(
      pressurePilot.spec.acceptablePresetIds,
      equals(const <String>['half_pot']),
    );

    final reopenPilot = pilots[3];
    expect(
      reopenPilot.spec.prompt,
      'Pick the smallest legal raise that reopens the action without bloating the pot.',
    );
    expect(
      reopenPilot.spec.whyV1,
      'Min raise reopens the action while risking less than a bigger raise.',
    );
    expect(reopenPilot.spec.expected.presetId, 'min_raise');
    expect(
      reopenPilot.spec.acceptablePresetIds,
      equals(const <String>['half_pot']),
    );

    expect(
      DecisionBarV1.pilotBetSizingDecisionLabelForPresetIdV1(
        valuePilot.spec.expected.presetId!,
      ),
      'BET 1/2',
    );
    expect(
      DecisionBarV1.pilotBetSizingDecisionLabelForPresetIdV1(
        smallPilot.spec.expected.presetId!,
      ),
      'BET 1/3',
    );
    expect(
      DecisionBarV1.pilotBetSizingDecisionLabelForPresetIdV1(
        pressurePilot.spec.expected.presetId!,
      ),
      'BET POT',
    );
    expect(
      DecisionBarV1.pilotBetSizingDecisionLabelForPresetIdV1(
        reopenPilot.spec.expected.presetId!,
      ),
      'RAISE MIN',
    );
  });

  test(
    'world4 mainline bet-sizing opener reuses canonical preset ids',
    () async {
      final drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s01',
      );
      final cluster = drills
          .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
          .toList(growable: false);

      expect(
        cluster.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_half_pot_value',
          'choose_one_third_pot_keep_price',
          'choose_pot_pressure',
          'choose_min_raise_reopen',
        ]),
      );
      expect(cluster, hasLength(4));
      expect(cluster.first.spec.expected.presetId, 'half_pot');
      expect(cluster[1].spec.expected.presetId, 'one_third_pot');
      expect(cluster[2].spec.expected.presetId, 'pot');
      expect(cluster[3].spec.expected.presetId, 'min_raise');
    },
  );

  test(
    'world4 continuation bet-sizing slice reuses canonical preset ids',
    () async {
      final drillsS02 = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s02',
      );
      final drillsS03 = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s03',
      );

      final s02Cluster = drillsS02
          .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
          .toList(growable: false);
      final s03Cluster = drillsS03
          .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
          .toList(growable: false);

      expect(
        s02Cluster.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_pot_bluff_pressure',
          'choose_half_pot_denial_charge',
          'choose_one_third_pot_bluff_probe',
          'choose_min_raise_denial_reopen',
        ]),
      );
      expect(
        s03Cluster.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_half_pot_value_checkpoint',
          'choose_one_third_pot_keep_price_checkpoint',
          'choose_pot_bluff_checkpoint',
          'choose_min_raise_reopen_checkpoint',
        ]),
      );
      expect(
        s02Cluster.map((item) => item.spec.expected.presetId).toList(),
        equals(const <String>['pot', 'half_pot', 'one_third_pot', 'min_raise']),
      );
      expect(
        s03Cluster.map((item) => item.spec.expected.presetId).toList(),
        equals(const <String>['half_pot', 'one_third_pot', 'pot', 'min_raise']),
      );
    },
  );

  test(
    'world4 stability bet-sizing slice reuses canonical preset ids',
    () async {
      final drillsS04 = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s04',
      );
      final drillsS05 = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s05',
      );
      final drillsS06 = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s06',
      );

      final s04Cluster = drillsS04
          .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
          .toList(growable: false);
      final s05Cluster = drillsS05
          .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
          .toList(growable: false);
      final s06Cluster = drillsS06
          .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
          .toList(growable: false);

      expect(
        s04Cluster.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_half_pot_value_stability',
          'choose_one_third_pot_thin_value_stability',
          'choose_pot_overpressure_value_check',
          'choose_min_raise_controlled_value_reopen',
        ]),
      );
      expect(
        s05Cluster.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_half_pot_protection_charge',
          'choose_pot_max_pressure_draw_charge',
          'choose_one_third_pot_block_cheap_realization',
          'choose_min_raise_protection_reopen',
        ]),
      );
      expect(
        s06Cluster.map((item) => item.drillId).toList(),
        equals(const <String>[
          'choose_half_pot_denial_checkpoint',
          'choose_one_third_pot_denial_price_keep_checkpoint',
          'choose_pot_denial_pressure_checkpoint',
          'choose_min_raise_denial_reopen_checkpoint',
        ]),
      );

      expect(
        s04Cluster.map((item) => item.spec.expected.presetId).toList(),
        equals(const <String>[
          'half_pot',
          'one_third_pot',
          'half_pot',
          'min_raise',
        ]),
      );
      expect(
        s05Cluster.map((item) => item.spec.expected.presetId).toList(),
        equals(const <String>['half_pot', 'pot', 'one_third_pot', 'min_raise']),
      );
      expect(
        s06Cluster.map((item) => item.spec.expected.presetId).toList(),
        equals(const <String>['half_pot', 'one_third_pot', 'pot', 'min_raise']),
      );
    },
  );

  test(
    'world4 spatial projection defaults hydrate the w4.s04 learner-facing scene',
    () async {
      final drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s04',
      );

      final seatAnchor = drills.firstWhere(
        (item) => item.drillId == 'find_btn_repeat',
      );
      final boardAnchor = drills.firstWhere(
        (item) => item.drillId == 'tap_flop_left_repeat',
      );
      final holeAnchor = drills.firstWhere(
        (item) => item.drillId == 'tap_hole_left_repeat',
      );
      final firstAction = drills.firstWhere(
        (item) => item.drillId == 'choose_half_pot_value_stability',
      );

      expect(
        seatAnchor.spec.scenarioSeatContextV1?.activeSeatsV1,
        equals(const <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb']),
      );
      expect(
        boardAnchor.spec.scenarioBoardContextV1?.boardCardsV1,
        equals(const <String>['Qh', '8d', '3c']),
      );
      expect(
        holeAnchor.spec.scenarioBoardContextV1?.heroHoleCardsV1,
        equals(const <String>['Ah', 'Kd']),
      );
      expect(firstAction.spec.scenarioTableContextV1, isNotNull);
    },
  );

  test(
    'worlds 6 to 8 spatial projection defaults hydrate representative learner-facing scenes',
    () async {
      final w6Drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w6.s01',
      );
      final w7Drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w7.s01',
      );
      final w8Drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w8.s01',
      );

      final w6SeatAnchor = w6Drills.firstWhere(
        (item) => item.drillId == 'find_btn',
      );
      final w6BoardAnchor = w6Drills.firstWhere(
        (item) => item.drillId == 'tap_flop_mid',
      );
      final w6HoleAnchor = w6Drills.firstWhere(
        (item) => item.drillId == 'tap_hole_left_as',
      );
      final w6FirstAction = w6Drills.firstWhere(
        (item) => item.drillId == 'choose_call_range',
      );

      expect(
        w6SeatAnchor.spec.scenarioSeatContextV1?.activeSeatsV1,
        equals(const <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb']),
      );
      expect(
        w6BoardAnchor.spec.scenarioBoardContextV1?.boardCardsV1,
        equals(const <String>['Kh', '8d', '3c', '2s']),
      );
      expect(
        w6HoleAnchor.spec.scenarioBoardContextV1?.heroHoleCardsV1,
        equals(const <String>['As', 'Kd']),
      );
      expect(w6FirstAction.spec.scenarioTableContextV1, isNotNull);

      final w7SeatAnchor = w7Drills.firstWhere(
        (item) => item.drillId == 'find_sb',
      );
      final w7BoardAnchor = w7Drills.firstWhere(
        (item) => item.drillId == 'tap_turn_depth',
      );
      final w7HoleAnchor = w7Drills.firstWhere(
        (item) => item.drillId == 'tap_hole_right_ks',
      );
      final w7FirstAction = w7Drills.firstWhere(
        (item) => item.drillId == 'choose_call_adjust',
      );

      expect(
        w7SeatAnchor.spec.scenarioSeatContextV1?.activeSeatsV1,
        equals(const <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb']),
      );
      expect(
        w7BoardAnchor.spec.scenarioBoardContextV1?.boardCardsV1,
        equals(const <String>['Kd', '7h', '3c', '2s']),
      );
      expect(
        w7HoleAnchor.spec.scenarioBoardContextV1?.heroHoleCardsV1,
        equals(const <String>['Ah', 'Ks']),
      );
      expect(w7FirstAction.spec.scenarioTableContextV1, isNotNull);

      final w8SeatAnchor = w8Drills.firstWhere(
        (item) => item.drillId == 'find_bb',
      );
      final w8BoardAnchor = w8Drills.firstWhere(
        (item) => item.drillId == 'tap_flop_bubble',
      );
      final w8HoleAnchor = w8Drills.firstWhere(
        (item) => item.drillId == 'tap_hole_left_as',
      );
      final w8FirstAction = w8Drills.firstWhere(
        (item) => item.drillId == 'choose_call_survival',
      );

      expect(
        w8SeatAnchor.spec.scenarioSeatContextV1?.activeSeatsV1,
        equals(const <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb']),
      );
      expect(
        w8BoardAnchor.spec.scenarioBoardContextV1?.boardCardsV1,
        equals(const <String>['Kh', '8c', '4d', '2s']),
      );
      expect(
        w8HoleAnchor.spec.scenarioBoardContextV1?.heroHoleCardsV1,
        equals(const <String>['As', 'Qd']),
      );
      expect(w8FirstAction.spec.scenarioTableContextV1, isNotNull);
    },
  );

  testWidgets(
    'world10 cash s05 keeps projected table and bet sizing controls on the canonical seam',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('cash.s05'),
      );
      final betSizing = drills!.firstWhere(
        (item) => item.drillId == 'size_half_pot_value',
      );

      expect(betSizing.spec.scenarioTableContextV1, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s05',
            debugDrillsOverrideV1: <SessionDrillItemV1>[betSizing],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_bet_sizing_preset_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
        findsOneWidget,
      );
    },
  );

  test('world4 tail bet-sizing slice reuses canonical preset ids', () async {
    final drillsS07 = await const DrillRuntimeAdapterV1().loadSessionDrills(
      'w4.s07',
    );
    final drillsS08 = await const DrillRuntimeAdapterV1().loadSessionDrills(
      'w4.s08',
    );
    final drillsS09 = await const DrillRuntimeAdapterV1().loadSessionDrills(
      'w4.s09',
    );
    final drillsS10 = await const DrillRuntimeAdapterV1().loadSessionDrills(
      'w4.s10',
    );

    final s07Cluster = drillsS07
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .toList(growable: false);
    final s08Cluster = drillsS08
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .toList(growable: false);
    final s09Cluster = drillsS09
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .toList(growable: false);
    final s10Cluster = drillsS10
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .toList(growable: false);

    expect(
      s07Cluster.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_half_pot_value_followthrough',
        'choose_one_third_pot_keep_value_flow',
        'choose_pot_value_pressure_finish',
        'choose_min_raise_value_reopen_followthrough',
      ]),
    );
    expect(
      s08Cluster.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_half_pot_protection_followthrough',
        'choose_pot_protection_crank_pressure',
        'choose_one_third_pot_light_protection_keepout',
        'choose_min_raise_protection_followthrough',
      ]),
    );
    expect(
      s09Cluster.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_pot_bluff_followthrough',
        'choose_half_pot_bluff_pressure_tradeoff',
        'choose_one_third_pot_probe_bluff_followthrough',
        'choose_min_raise_bluff_reopen_tradeoff',
      ]),
    );
    expect(
      s10Cluster.map((item) => item.drillId).toList(),
      equals(const <String>[
        'choose_half_pot_denial_final_checkpoint',
        'choose_one_third_pot_denial_price_gate_final',
        'choose_pot_denial_lockout_final',
        'choose_min_raise_denial_reopen_final',
      ]),
    );

    expect(
      s07Cluster.map((item) => item.spec.expected.presetId).toList(),
      equals(const <String>['half_pot', 'one_third_pot', 'pot', 'min_raise']),
    );
    expect(
      s08Cluster.map((item) => item.spec.expected.presetId).toList(),
      equals(const <String>['half_pot', 'pot', 'one_third_pot', 'min_raise']),
    );
    expect(
      s09Cluster.map((item) => item.spec.expected.presetId).toList(),
      equals(const <String>['pot', 'half_pot', 'one_third_pot', 'min_raise']),
    );
    expect(
      s10Cluster.map((item) => item.spec.expected.presetId).toList(),
      equals(const <String>['half_pot', 'one_third_pot', 'pot', 'min_raise']),
    );
  });

  testWidgets(
    'w1.s01 betting mini-cluster shows one compact onboarding card before the first drill',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final pilots = <SessionDrillItemV1>[
        SessionDrillItemV1(
          drillId: 'choose_half_pot_value',
          spec: DrillSpecV1.fromJsonString(
            '{"id":"choose_half_pot_value","kind":"bet_sizing_choice_v1","prompt":"Pick the value size that still keeps worse hands in.","intent_v1":"value_bet_sizing_intro","why_v1":"Half pot builds value without pushing marginal hands out as often.","expected":{"presetId":"half_pot"},"acceptable_preset_ids":["one_third_pot"],"error_class":"bet_sizing_selection"}',
          ),
        ),
        SessionDrillItemV1(
          drillId: 'choose_one_third_pot_keep_price',
          spec: DrillSpecV1.fromJsonString(
            '{"id":"choose_one_third_pot_keep_price","kind":"bet_sizing_choice_v1","prompt":"Pick the smaller size that still keeps the price easy for weaker hands.","intent_v1":"small_bet_sizing_intro","why_v1":"One third pot keeps the price comfortable and still gets paid by many weaker hands.","expected":{"presetId":"one_third_pot"},"acceptable_preset_ids":["half_pot"],"error_class":"bet_sizing_selection"}',
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w1.s01',
            debugDrillsOverrideV1: pilots,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsOneWidget,
      );
      expect(find.text('Bet Size Practice'), findsOneWidget);
      expect(
        find.text(
          'This mode teaches what different sizes are trying to accomplish.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Focus on the tradeoff: keep weaker hands in, charge more, or apply pressure.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Short repeats help you match a size to its purpose.'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsNothing,
      );
    },
  );

  testWidgets('w1.s01 betting mini-cluster shows a compact recap card on completion', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 3.0;

    final pilots = <SessionDrillItemV1>[
      SessionDrillItemV1(
        drillId: 'choose_half_pot_value',
        spec: DrillSpecV1.fromJsonString(
          '{"id":"choose_half_pot_value","kind":"bet_sizing_choice_v1","prompt":"Pick the value size that still keeps worse hands in.","intent_v1":"value_bet_sizing_intro","why_v1":"Half pot builds value without pushing marginal hands out as often.","expected":{"presetId":"half_pot"},"acceptable_preset_ids":["one_third_pot"],"error_class":"bet_sizing_selection"}',
        ),
      ),
      SessionDrillItemV1(
        drillId: 'choose_one_third_pot_keep_price',
        spec: DrillSpecV1.fromJsonString(
          '{"id":"choose_one_third_pot_keep_price","kind":"bet_sizing_choice_v1","prompt":"Pick the smaller size that still keeps the price easy for weaker hands.","intent_v1":"small_bet_sizing_intro","why_v1":"One third pot keeps the price comfortable and still gets paid by many weaker hands.","expected":{"presetId":"one_third_pot"},"acceptable_preset_ids":["half_pot"],"error_class":"bet_sizing_selection"}',
        ),
      ),
      SessionDrillItemV1(
        drillId: 'choose_pot_pressure',
        spec: DrillSpecV1.fromJsonString(
          '{"id":"choose_pot_pressure","kind":"bet_sizing_choice_v1","prompt":"Pick the size that puts the most pressure on hands that want a cheap call.","intent_v1":"pressure_bet_sizing_intro","why_v1":"Pot makes the call expensive and creates the most pressure.","expected":{"presetId":"pot"},"acceptable_preset_ids":["half_pot"],"error_class":"bet_sizing_selection"}',
        ),
      ),
      SessionDrillItemV1(
        drillId: 'choose_min_raise_reopen',
        spec: DrillSpecV1.fromJsonString(
          '{"id":"choose_min_raise_reopen","kind":"bet_sizing_choice_v1","prompt":"Pick the smallest legal raise that reopens the action without bloating the pot.","intent_v1":"min_raise_reopen_intro","why_v1":"Min raise reopens the action while risking less than a bigger raise.","expected":{"presetId":"min_raise"},"acceptable_preset_ids":["half_pot"],"error_class":"bet_sizing_selection"}',
        ),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w1.s01',
          debugDrillsOverrideV1: pilots,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    await tester.tap(
      find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('session_drill_player_preset_pot_v1')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('session_drill_player_preset_min_raise_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_recap_card_v1')),
      findsOneWidget,
    );
    expect(find.text('Size Recap'), findsOneWidget);
    expect(
      find.text(
        'BET 1/3 keeps weaker hands in. BET 1/2 balances value and price.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('BET POT applies pressure. RAISE MIN reopens cheaply.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'w4.s01 mainline bet-sizing opener shows one compact onboarding card before the first drill',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s01'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsOneWidget,
      );
      expect(find.text('Bet Size Practice'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'w4.s01 mainline bet-sizing opener shows a compact recap card on completion',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s01'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_min_raise_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_recap_card_v1')),
        findsOneWidget,
      );
      expect(find.text('Size Recap'), findsOneWidget);
    },
  );

  testWidgets(
    'w4.s02 continuation cluster shows onboarding and recap on the bet-sizing seam',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s02'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s02',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_min_raise_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_recap_card_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets('w4.s03 mixed checkpoint stays on the same bet-sizing seam', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 3.0;

    final drills = await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s03'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w4.s03',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_bet_sizing_preset_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_intro_card_v1')),
      findsOneWidget,
    );
  });

  testWidgets(
    'w4.s04 stability cluster shows onboarding and recap on the bet-sizing seam',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s04'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s04',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_min_raise_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_recap_card_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w4.s03 renders stacked seatId markers and preserved blind overlays',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s03'),
      ))!
          .where((item) => item.drillId == 'find_seat_s3')
          .toList(growable: false);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s03',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(find.byType(ModernTableScreenV1), findsOneWidget);

      final btnMarker = find.byKey(const Key('modern_table_seat_marker_0'));
      expect(btnMarker, findsOneWidget);
      expect(
        find.descendant(of: btnMarker, matching: find.text('S1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: btnMarker, matching: find.text('BTN')),
        findsOneWidget,
      );

      final coMarker = find.byKey(const Key('modern_table_seat_marker_1'));
      expect(coMarker, findsOneWidget);
      expect(
        find.descendant(of: coMarker, matching: find.text('S2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: coMarker, matching: find.text('CO')),
        findsOneWidget,
      );

      final hjMarker = find.byKey(const Key('modern_table_seat_marker_2'));
      expect(hjMarker, findsOneWidget);
      expect(
        find.descendant(of: hjMarker, matching: find.text('S3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hjMarker, matching: find.text('HJ')),
        findsOneWidget,
      );

      final sbMarker = find.byKey(const Key('modern_table_seat_marker_5'));
      expect(sbMarker, findsOneWidget);
      expect(
        find.descendant(of: sbMarker, matching: find.text('S6')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sbMarker, matching: find.text('SB')),
        findsOneWidget,
      );

      final bbMarker = find.byKey(const Key('modern_table_seat_marker_6'));
      expect(bbMarker, findsOneWidget);
      expect(
        find.descendant(of: bbMarker, matching: find.text('S7')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bbMarker, matching: find.text('BB')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('modern_table_seat_forced_bet_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_forced_bet_6')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w4.s04 shows the projected table on the first learner-facing rep',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await const DrillRuntimeAdapterV1().loadSessionDrills(
        'w4.s04',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s04',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_oval')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('w4.s06 denial checkpoint stays on the same bet-sizing seam', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 3.0;

    final drills = await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s06'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w4.s06',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_bet_sizing_preset_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_intro_card_v1')),
      findsOneWidget,
    );
  });

  testWidgets(
    'w4.s07 tail cluster shows onboarding and recap on the bet-sizing seam',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 3.0;

      final drills = await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s07'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w4.s07',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(
        find.byKey(const Key('session_drill_player_intro_card_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_one_third_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_pot_v1')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_min_raise_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_recap_card_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets('w4.s10 final checkpoint stays on the same bet-sizing seam', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 3.0;

    final drills = await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w4.s10'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w4.s10',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_bet_sizing_preset_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_intro_card_v1')),
      findsOneWidget,
    );
  });

  testWidgets('w4.s10 completion card surfaces W4 to W5 handoff context', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 3.0;

    final drills = <SessionDrillItemV1>[
      _item('w4_tail_a'),
      _item('w4_tail_b'),
      _item('w4_tail_c'),
      _item('w4_tail_d'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w4.s10',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < drills.length; i++) {
      await tester.tap(
        find.byKey(const Key('session_drill_player_preset_half_pot_v1')),
      );
      await tester.pump();
    }

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world4_block_completion_card_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world4_block_completion_handoff_v1'),
      ),
      findsOneWidget,
    );
    expect(find.text('Campaign route -> World 5 sessions'), findsOneWidget);
    expect(
      find.text(
        'Next route: World 5 turns board texture into the first clean pressure read before choosing a response.',
      ),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  void _expectStatusHeaderVisible(WidgetTester tester) {
    expect(
      find.byKey(const Key('session_drill_player_status_header')),
      findsOneWidget,
    );
  }

  void _expectStatusStep(
    WidgetTester tester, {
    required int current,
    required int total,
  }) {
    final headerFinder = find.byKey(
      const Key('session_drill_player_status_header'),
    );
    expect(headerFinder, findsOneWidget);
    final headerWidget = tester.widget(headerFinder);
    final Text header;
    if (headerWidget is Text) {
      header = headerWidget;
    } else {
      final headerTextFinder = find.descendant(
        of: headerFinder,
        matching: find.byType(Text),
      );
      expect(headerTextFinder, findsOneWidget);
      header = tester.widget<Text>(headerTextFinder);
    }
    final text = (header.data ?? '').toLowerCase();
    expect(
      text.contains('step $current of $total') ||
          text.contains('step $current/$total'),
      isTrue,
    );
  }

  SessionDrillItemV1 _chainItem() {
    return SessionDrillItemV1(
      drillId: 'chain_demo',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"chain_demo","kind":"hand_chain_v1","chain_id":"chain_demo","prompt":"Play chain.","expected":{},"error_class":"unused","steps":[{"street":"preflop","prompt":"Step 1: call.","expected_action":"call","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"Call is best on this step."},{"street":"flop","prompt":"Step 2: raise.","expected_action":"raise","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}]}',
      ),
    );
  }

  SessionDrillItemV1 _threeStepChainItem() {
    return SessionDrillItemV1(
      drillId: 'chain_flop_turn_river_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"chain_flop_turn_river_v1","kind":"hand_chain_v1","chain_id":"w6_s03_chain_flop_turn_river_v1","prompt":"Play this three-step range chain.","expected":{},"error_class":"expected_action_mismatch","steps":[{"street":"flop","prompt":"Flop: pressure spot with live equity. Choose action.","expected_action":"call","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},{"street":"turn","prompt":"Turn: value and pressure both improve. Choose action.","expected_preset_id":"half_pot","acceptable_preset_ids":["one_third_pot"],"why_v1":"Half pot builds value while still keeping weaker hands in.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},{"street":"river","prompt":"River: value edge remains and bluff catchers can pay. Choose action.","expected_action":"raise","acceptable_actions":["call"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}]}',
      ),
    );
  }

  testWidgets('hand_chain_v1 completes deterministic 2-step chain', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w6.s01',
          debugDrillsOverrideV1: <SessionDrillItemV1>[_chainItem()],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 1: call.'), findsOneWidget);
    _expectStatusHeaderVisible(tester);

    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump();

    expect(find.text('Step 2: raise.'), findsOneWidget);
    _expectStatusHeaderVisible(tester);

    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_raise_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
  });

  testWidgets('hand_chain_v1 completes deterministic 3-step chain', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w6.s03',
          debugDrillsOverrideV1: <SessionDrillItemV1>[_threeStepChainItem()],
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusStep(tester, current: 1, total: 3);
    expect(
      find.text('Flop: pressure spot with live equity. Choose action.'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump();

    _expectStatusStep(tester, current: 2, total: 3);
    expect(
      find.text('Turn: value and pressure both improve. Choose action.'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const Key('session_drill_player_hand_chain_preset_half_pot_v1'),
      ),
    );
    await tester.pump();

    _expectStatusStep(tester, current: 3, total: 3);
    expect(
      find.text(
        'River: value edge remains and bluff catchers can pay. Choose action.',
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('session_drill_player_result_soft_pass_info_v1')),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsNothing,
    );
  });

  testWidgets('w2.s07 uses source-driven multi-step table scenarios', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s07'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_position_then_initiative_v1',
    ]);
    expect(drills.single.spec.kind, DrillKindV1.handChain);
    final chainContext = drills.single.spec.scenarioFactualHandChainContextV1;
    expect(chainContext, isNotNull);
    expect(chainContext!.chainIdV1, 'w2_s07_position_then_initiative_v1');
    expect(chainContext.stepCountV1, 2);
    expect(chainContext.stepAtIndexV1(0)?.coreV1.streetV1, 'preflop');
    expect(chainContext.stepAtIndexV1(1)?.coreV1.streetV1, 'flop');
    expect(
      chainContext.stepAtIndexV1(0)?.promptV1,
      'Step 1: Hero is on the button and villain is in the big blind. Who is in position?',
    );
    expect(
      chainContext.stepAtIndexV1(1)?.whyV1,
      'Initiative stays with the player who made the last aggressive action.',
    );
    expect(chainContext.stepAtIndexV1(0)?.coreV1.availableActionsV1, <String>[
      'hero',
      'villain',
    ]);
    expect(chainContext.stepAtIndexV1(1)?.coreV1.availableActionsV1, <String>[
      'hero',
      'villain',
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s07',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusHeaderVisible(tester);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_hand_chain_action_villain_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      findsOneWidget,
    );

    var table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    var scenario = table.scenarioSpec;
    expect(scenario, isNotNull);
    expect(scenario!.seatCount, 4);
    expect(scenario.heroSeat, 0);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.street, Street.preflop);
    expect(scenario.decisionNodeV1.legalActions, <String>['hero', 'villain']);
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');
    expect(scenario.resolvedSeatOccupanciesV1, const <ScenarioSeatOccupancyV1>[
      ScenarioSeatOccupancyV1.active,
      ScenarioSeatOccupancyV1.active,
      ScenarioSeatOccupancyV1.folded,
      ScenarioSeatOccupancyV1.empty,
    ]);
    expect(find.byKey(const Key('modern_table_seat_empty_3')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pump();

    _expectStatusHeaderVisible(tester);
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec;
    expect(scenario, isNotNull);
    expect(scenario!.decisionNodeV1.street, Street.flop);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

    await tester.tap(
      find.byKey(
        const Key('session_drill_player_hand_chain_action_villain_v1'),
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('session_drill_player_result_fail')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Incorrect. Hero raised last preflop, so hero keeps initiative into the flop.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsNothing,
    );
  });

  testWidgets('w3.s01 surfaces a preflop bridge intro card on promoted entry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s01'),
    ))!;
    expect(drills, isNotEmpty);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w3.s01',
          debugDrillsOverrideV1: drills,
          handoffContextV1: buildProgressionHandoffContextForPackV1(
            'world3_spine_campaign_v1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const Key('session_drill_player_world3_preflop_bridge_card_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world3_preflop_bridge_handoff_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const Key('session_drill_player_world3_preflop_bridge_card_v1'),
        ),
        matching: find.text(
          'Stage shift · World 2 table reads -> World 3 preflop framework',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world3_preflop_bridge_line_1_v1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('w2.s08 reuses source-driven board context across steps', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s08'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_texture_then_outs_v1',
    ]);
    expect(drills.single.spec.kind, DrillKindV1.handChain);
    final chainContext = drills.single.spec.scenarioFactualHandChainContextV1;
    expect(chainContext, isNotNull);
    expect(chainContext!.chainIdV1, 'w2_s08_texture_then_outs_v1');
    expect(chainContext.stepCountV1, 2);
    expect(
      chainContext.stepAtIndexV1(0)?.promptV1,
      'Step 1: On this flop, which action matches the more pressure-building texture?',
    );
    expect(
      chainContext.stepAtIndexV1(0)?.coreV1.feedbackIncorrectV1,
      'Incorrect. This connected two-tone flop builds more pressure than a dry board.',
    );
    expect(
      chainContext
          .stepAtIndexV1(1)
          ?.tableContextV1
          ?.boardContextV1
          ?.heroHoleCardsV1,
      <String>['Qh', '8h'],
    );
    expect(chainContext.stepAtIndexV1(0)?.coreV1.availableActionsV1, <String>[
      'call',
      'raise',
    ]);
    expect(chainContext.stepAtIndexV1(1)?.coreV1.availableActionsV1, <String>[
      '4',
      '8',
      '9',
      '15',
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s08',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusHeaderVisible(tester);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_source_street_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_source_board_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
      findsNothing,
    );

    var table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    var scenario = table.scenarioSpec;
    expect(scenario, isNotNull);
    expect(scenario!.decisionNodeV1.street, Street.flop);
    expect(scenario.decisionNodeV1.legalActions, <String>['call', 'raise']);
    expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
    expect(table.debugBoardCardLabels, <String>['J♥', 'T♥', '9♣']);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('session_drill_player_result_fail')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Incorrect. This connected two-tone flop builds more pressure than a dry board.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pump();

    _expectStatusHeaderVisible(tester);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_4_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_8_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_9_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_15_v1')),
      findsOneWidget,
    );

    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec;
    expect(scenario, isNotNull);
    expect(scenario!.decisionNodeV1.street, Street.flop);
    expect(scenario.decisionNodeV1.legalActions, <String>['4', '8', '9', '15']);
    expect(scenario.decisionNodeV1.solutionBestAction, '9');
    expect(table.debugBoardCardLabels, <String>['J♥', 'T♥', '9♣']);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_8_v1')),
    );
    await tester.pump();
    expect(
      find.text(
        'Incorrect. Two hearts in hand plus two on board leave nine flush outs.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_9_v1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsNothing,
    );
  });

  testWidgets('w2.s09 carries one source-driven table scene across 3 steps', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s09'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_position_initiative_texture_v1',
    ]);
    expect(drills.single.spec.kind, DrillKindV1.handChain);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s09',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusHeaderVisible(tester);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      findsOneWidget,
    );
    var table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    var scenario = table.scenarioSpec!;
    expect(scenario.seatCount, 4);
    expect(scenario.heroSeat, 0);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.street, Street.preflop);
    expect(scenario.decisionNodeV1.legalActions, <String>['hero', 'villain']);
    expect(scenario.resolvedSeatOccupanciesV1, const <ScenarioSeatOccupancyV1>[
      ScenarioSeatOccupancyV1.active,
      ScenarioSeatOccupancyV1.active,
      ScenarioSeatOccupancyV1.folded,
      ScenarioSeatOccupancyV1.empty,
    ]);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pump();

    _expectStatusHeaderVisible(tester);
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pump();

    _expectStatusHeaderVisible(tester);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
      findsOneWidget,
    );
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
    expect(table.debugBoardCardLabels, <String>['J♥', 'T♥', '9♣']);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
    );
    await tester.pump();
    expect(
      find.text(
        'Incorrect. Connected two-tone flops create more straight and flush pressure than dry boards.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsNothing,
    );
  });

  testWidgets('w2.s09 carries one source-driven table scene across 3 steps', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s09'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_position_initiative_texture_v1',
    ]);
    expect(drills.single.spec.kind, DrillKindV1.handChain);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s09',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusHeaderVisible(tester);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      findsOneWidget,
    );
    var table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    var scenario = table.scenarioSpec!;
    expect(scenario.seatCount, 4);
    expect(scenario.heroSeat, 0);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.street, Street.preflop);
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');
    expect(table.debugBoardCardLabels, isNull);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pump();

    _expectStatusHeaderVisible(tester);
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(scenario.actingSeatStart, 0);
    expect(scenario.decisionNodeV1.solutionBestAction, 'hero');
    expect(table.debugBoardCardLabels, isNull);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pump();

    _expectStatusHeaderVisible(tester);
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(scenario.decisionNodeV1.legalActions, <String>['call', 'raise']);
    expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
    expect(table.debugBoardCardLabels, <String>['J♥', 'T♥', '9♣']);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
    );
    await tester.pump();
    expect(
      find.text(
        'Incorrect. Connected two-tone flops create more straight and flush pressure than dry boards.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
      findsNothing,
    );
  });

  testWidgets('w2.s10 carries one board-context scene through 3 steps', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s10'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_texture_outs_action_v1',
    ]);
    expect(drills.single.spec.kind, DrillKindV1.handChain);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s10',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectStatusStep(tester, current: 1, total: 3);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
      findsOneWidget,
    );
    var table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    var scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.street, Street.flop);
    expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
    expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pump();

    _expectStatusStep(tester, current: 2, total: 3);
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
      findsOneWidget,
    );
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.legalActions, <String>['4', '8', '9', '15']);
    expect(scenario.decisionNodeV1.solutionBestAction, '9');
    expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_9_v1')),
    );
    await tester.pump();

    _expectStatusStep(tester, current: 3, total: 3);
    table = tester.widget<ModernTableScreenV1>(
      find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
    );
    scenario = table.scenarioSpec!;
    expect(scenario.decisionNodeV1.legalActions, <String>['call', 'raise']);
    expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
    expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
    );
    await tester.pump();
    expect(
      find.text(
        'Incorrect. This board and draw combination supports a more pressure-building action than a passive line.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_result_ok')),
      findsOneWidget,
    );
  });

  testWidgets(
    'w2.s11 carries one table scene through position, initiative, and action',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s11'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_position_initiative_action_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s11',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusStep(tester, current: 1, total: 3);
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.seatCount, 4);
      expect(scenario.heroSeat, 0);
      expect(scenario.actingSeatStart, 0);
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 2, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.actingSeatStart, 0);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 3, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.decisionNodeV1.legalActions, <String>['call', 'raise']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. This dynamic flop supports a more pressure-building line than a passive call.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w2.s12 carries one capstone scene through four linked World 2 checks',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s12'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_world2_capstone_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s12',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusStep(tester, current: 1, total: 4);
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.seatCount, 4);
      expect(scenario.heroSeat, 0);
      expect(scenario.actingSeatStart, 0);
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 2, total: 4);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.actingSeatStart, 0);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 3, total: 4);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.decisionNodeV1.legalActions, <String>['call', 'raise']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 4, total: 4);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
        findsOneWidget,
      );
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.decisionNodeV1.legalActions, <String>['call', 'raise']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. This scene combines position, initiative, and strong draw pressure, so the passive line leaves value on the table.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_capstone_recap_card_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_capstone_recap_title_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Read the whole scene in order'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w2.s13 carries one draw-and-price scene through texture, outs, and continue intuition',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s13'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_texture_outs_continue_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s13',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusHeaderVisible(tester);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
        findsOneWidget,
      );
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      _expectStatusHeaderVisible(tester);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
        findsOneWidget,
      );
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.legalActions, <String>[
        '4',
        '8',
        '9',
        '15',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, '9');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_9_v1')),
      );
      await tester.pump();

      _expectStatusHeaderVisible(tester);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.legalActions, <String>['fold', 'call']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'call');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '9c']);

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. With a dynamic board, a strong draw, and a cheap price, folding is too tight here.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w2.s14 carries one draw-and-price scene through texture, weaker outs, and disciplined fold intuition',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s14'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_texture_outs_fold_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s14',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusHeaderVisible(tester);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
        findsOneWidget,
      );

      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.flop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '4h']);

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      _expectStatusHeaderVisible(tester);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
        findsOneWidget,
      );
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.legalActions, <String>[
        '4',
        '8',
        '9',
        '15',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, '4');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_4_v1')),
      );
      await tester.pump();

      _expectStatusHeaderVisible(tester);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.legalActions, <String>['fold', 'call']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'fold');
      expect(table.debugBoardCardLabels, <String>['Jh', 'Th', '4h']);

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. This draw is too thin for a bigger price, so calling is too loose.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_block_completion_card_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_block_completion_title_v1'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Best quick review'), findsOneWidget);
    },
  );

  testWidgets('w2.s14 completion card surfaces W2 to W3 handoff context', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s14'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_texture_outs_fold_v1',
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s14',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_4_v1')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(
        const Key('session_drill_player_world2_block_completion_card_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world2_block_completion_handoff_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Stage shift · World 2 table reads -> World 3 preflop framework',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Next route: World 3 turns hand category into the first clean open, call, or fold decision.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('w3.s14 completion card surfaces W3 to W4 handoff context', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s14'),
    ))!;
    expect(drills.map((item) => item.drillId).toList(), <String>[
      'chain_position_sensitive_open_fold_v1',
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w3.s14',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world3_block_completion_card_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world3_block_completion_handoff_v1'),
      ),
      findsOneWidget,
    );
    expect(find.text('Campaign route -> World 4 sessions'), findsOneWidget);
    expect(
      find.text(
        'Next route: World 4 turns action purpose into one clean size choice for value, pressure, and price.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'w3.s11 carries one preflop framework scene through position, unopened-pot raise, and facing-open call',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s11'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_position_open_call_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w3.s11',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusStep(tester, current: 1, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_villain_v1'),
        ),
        findsOneWidget,
      );
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 2, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
        findsOneWidget,
      );
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 3, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, 'call');

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. Once villain opened first, this spot is no longer the same as an unopened pot. Calling is the simpler in-position response.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w3.s12 carries one preflop framework scene through position, facing-open continue, and disciplined fold',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s12'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_position_continue_fold_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w3.s12',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusStep(tester, current: 1, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
        findsOneWidget,
      );
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 2, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
        findsOneWidget,
      );
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>['fold', 'call']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'call');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. Suited broadway strength plus position makes continuing the cleaner response here.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 3, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>['fold', 'call']);
      expect(scenario.decisionNodeV1.solutionBestAction, 'fold');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. This offsuit hand is too loose to continue just because hero has position.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w3.s13 carries one preflop framework scene through position, unopened-pot open, and disciplined weak-hand fold',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s13'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_position_open_fold_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w3.s13',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusStep(tester, current: 1, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
        findsOneWidget,
      );
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 2, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_source_hero_v1')),
        findsOneWidget,
      );
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. This is a good in-position unopened-pot open, so the simple frame is raise.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 3, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, 'fold');

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. Position improves the spot, but it does not turn this weaker offsuit hand into a good unopened-pot open.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w3.s14 carries one preflop framework scene through position, late-position open, and earlier-seat fold with the same hand',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s14'),
      ))!;
      expect(drills.map((item) => item.drillId).toList(), <String>[
        'chain_position_sensitive_open_fold_v1',
      ]);
      expect(drills.single.spec.kind, DrillKindV1.handChain);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w3.s14',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      _expectStatusStep(tester, current: 1, total: 3);
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
        findsOneWidget,
      );
      var table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      var scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.solutionBestAction, 'hero');

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 2, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, 'raise');

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      _expectStatusStep(tester, current: 3, total: 3);
      table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      scenario = table.scenarioSpec!;
      expect(scenario.decisionNodeV1.street, Street.preflop);
      expect(scenario.decisionNodeV1.legalActions, <String>[
        'fold',
        'call',
        'raise',
      ]);
      expect(scenario.decisionNodeV1.solutionBestAction, 'fold');

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();
      expect(
        find.text(
          'Incorrect. The same hand does not keep the same value when hero loses late position in the unopened pot.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );
}

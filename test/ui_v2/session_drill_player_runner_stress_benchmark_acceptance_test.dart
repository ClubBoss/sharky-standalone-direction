import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 100,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  Future<void> _pumpBounded(
    WidgetTester tester, {
    int ticks = 12,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < ticks; i++) {
      await tester.pump(step);
    }
  }

  Future<void> _tapVisible(
    WidgetTester tester,
    Finder finder, {
    Duration settle = const Duration(milliseconds: 80),
  }) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump(settle);
  }

  Future<void> _tapSeat(WidgetTester tester, int seatIndex) async {
    final table = tester.widget<ModernTableScreenV1>(
      find.byType(ModernTableScreenV1),
    );
    expect(table.onSeatTapV1, isNotNull);
    table.onSeatTapV1!(seatIndex);
  }

  SessionDrillItemV1 _positionItem() {
    return SessionDrillItemV1(
      drillId: 'world2_rendered_acceptance_position_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_rendered_acceptance_position_v1","kind":"position_thinking_choice_v1","prompt":"Hero is on the button versus the big blind. Who acts later after the flop?","player_count_v1":4,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","bb"],"folded_seats_v1":["co"],"empty_seats_v1":["sb"],"street_v1":"flop","available_actions_v1":["hero","villain"],"expected":{"actionId":"hero"},"error_class":"position_thinking_choice_mismatch","why_v1":"The button acts later after the flop.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _boardTextureItem() {
    return SessionDrillItemV1(
      drillId: 'world2_rendered_acceptance_texture_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_rendered_acceptance_texture_v1","kind":"board_texture_classifier_v1","prompt":"Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.","intro_v1":"Read the real board first. Dry flops usually keep pressure lower because fewer turn cards change the picture fast.","street_v1":"flop","board_cards_v1":["As","7d","2c"],"board_texture_v1":"dry","board_texture_policy_shape_v1":"pressure_level","board_texture_policy_target_v1":"calmer","available_actions_v1":["call","raise"],"expected_action":"call","error_class":"expected_action_mismatch","why_v1":"A-7-2 rainbow is dry, so fewer draws and turn shifts build pressure right away.","feedback_correct_v1":"Correct. This flop stays calmer because it does not create many immediate draw paths.","feedback_incorrect_v1":"Incorrect. This flop is the calmer board because the texture stays dry and stable."}',
      ),
    );
  }

  SessionDrillItemV1 _outsItem(
    String id, {
    required String prompt,
    required String outs,
    required String why,
    required List<String> heroHoleCards,
    required List<String> boardCards,
    String street = 'flop',
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"outs_count_choice_v1","prompt":"$prompt","street_v1":"$street","hero_hole_cards_v1":["${heroHoleCards.join('","')}"],"board_cards_v1":["${boardCards.join('","')}"],"available_actions_v1":["4","8","9","15"],"expected":{"actionId":"$outs"},"error_class":"outs_count_choice_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _reviewItem(
    String id, {
    required String expectedAction,
    String texture = 'dry',
    List<String> boardCards = const <String>['As', '7d', '2c'],
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_texture_classifier_v1","prompt":"Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.","street_v1":"flop","board_cards_v1":["${boardCards.join('","')}"],"board_texture_v1":"$texture","available_actions_v1":["call","raise","fold"],"expected_action":"$expectedAction","error_class":"expected_action_mismatch","why_v1":"Read the board texture before you lock in the action.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _loadHandChainDrillFromFile(
    String sessionId,
    String filename,
  ) {
    final path =
        'content/worlds/world3/v1/sessions/$sessionId/drills/$filename';
    final json = File(path).readAsStringSync();
    final spec = DrillSpecV1.fromJsonString(json);
    return SessionDrillItemV1(drillId: spec.id, spec: spec);
  }

  SessionDrillItemV1 _spatializedActionBearingDrill({
    required SessionDrillItemV1 spatialAnchorDrill,
    required SessionDrillItemV1 actionBearingDrill,
  }) {
    final anchorSpec = spatialAnchorDrill.spec;
    final actionSpec = actionBearingDrill.spec;
    return SessionDrillItemV1(
      drillId: actionBearingDrill.drillId,
      spec: DrillSpecV1(
        id: actionSpec.id,
        kind: actionSpec.kind,
        prompt: actionSpec.prompt,
        expected: actionSpec.expected,
        errorClass: actionSpec.errorClass,
        intentV1: actionSpec.intentV1,
        questionShapeV1: actionSpec.questionShapeV1,
        initiativePolicyShapeV1: actionSpec.initiativePolicyShapeV1,
        boardTexturePolicyShapeV1: actionSpec.boardTexturePolicyShapeV1,
        boardTexturePolicyTargetV1: actionSpec.boardTexturePolicyTargetV1,
        whyV1: actionSpec.whyV1,
        acceptableActions: actionSpec.acceptableActions,
        acceptablePresetIds: actionSpec.acceptablePresetIds,
        boardTextureV1: actionSpec.boardTextureV1,
        availableActionsV1: actionSpec.availableActionsV1,
        streetV1: anchorSpec.streetV1 ?? actionSpec.streetV1,
        boardCardsV1: anchorSpec.boardCardsV1,
        playerCountV1: anchorSpec.playerCountV1,
        heroSeatV1: anchorSpec.heroSeatV1,
        villainSeatV1: anchorSpec.villainSeatV1,
        activeSeatsV1: anchorSpec.activeSeatsV1,
        foldedSeatsV1: anchorSpec.foldedSeatsV1,
        emptySeatsV1: anchorSpec.emptySeatsV1,
        lastAggressorV1: anchorSpec.lastAggressorV1,
        initiativeOwnerV1: anchorSpec.initiativeOwnerV1,
        smallBlindSeatV1: anchorSpec.smallBlindSeatV1,
        bigBlindSeatV1: anchorSpec.bigBlindSeatV1,
        smallBlindAmountV1: anchorSpec.smallBlindAmountV1,
        bigBlindAmountV1: anchorSpec.bigBlindAmountV1,
        anteAmountV1: anchorSpec.anteAmountV1,
        pressureOwnerV1: actionSpec.pressureOwnerV1,
        heroHoleCardsV1: anchorSpec.heroHoleCardsV1,
        villainHoleCardsV1: anchorSpec.villainHoleCardsV1,
        introV1: actionSpec.introV1,
        recapV1: actionSpec.recapV1,
        feedbackCorrectV1: actionSpec.feedbackCorrectV1,
        feedbackIncorrectV1: actionSpec.feedbackIncorrectV1,
        expectedActionV1: actionSpec.expectedActionV1,
        rangeBucketV1: actionSpec.rangeBucketV1,
        chainIdV1: actionSpec.chainIdV1,
        chainStepsV1: actionSpec.chainStepsV1,
      ),
    );
  }

  void _setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets(
    'benchmark re-sweep keeps world 2 seat-context and dense texture scenes readable on phone size',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      _setPhoneViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: <SessionDrillItemV1>[_positionItem()],
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      await tester.pumpAndSettle();

      final seatPromptRect = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
      );
      final seatTableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      expect(
        find.byKey(const Key('session_drill_player_acting_focus_chip_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_action_marker_0')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(seatPromptRect.bottom, lessThan(seatTableRect.top));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s04',
            debugDrillsOverrideV1: <SessionDrillItemV1>[_boardTextureItem()],
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_scene_support_lane_v1')),
      );
      await tester.pumpAndSettle();

      final feedbackRect = tester.getRect(
        find.byKey(const Key('session_drill_player_feedback_block_v1')),
      );
      final supportLaneRect = tester.getRect(
        find.byKey(const Key('session_drill_player_scene_support_lane_v1')),
      );
      final actionRect = tester.getRect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      expect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_feedback_block_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );
      expect(supportLaneRect.top - tableRect.bottom, greaterThanOrEqualTo(8));
      expect(actionRect.top - feedbackRect.bottom, greaterThanOrEqualTo(8));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'benchmark re-sweep keeps world 2 review and outs support-action states readable through completion',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      _setPhoneViewport(tester);

      final reviewDrills = <SessionDrillItemV1>[
        _reviewItem(
          'bridge_review_dry_cheap_continue_v1',
          expectedAction: 'call',
        ),
        _reviewItem(
          'bridge_review_wet_expensive_release_v1',
          expectedAction: 'fold',
          texture: 'wet',
          boardCards: const <String>['Ah', 'Jh', '9c'],
        ),
        _reviewItem(
          'bridge_review_paired_fair_price_continue_v1',
          expectedAction: 'call',
          texture: 'paired',
          boardCards: const <String>['Kd', 'Kc', '4s'],
        ),
        _reviewItem(
          'bridge_review_connected_future_street_release_v1',
          expectedAction: 'fold',
          texture: 'connected',
          boardCards: const <String>['9h', '8c', '7d'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s05',
            debugDrillsOverrideV1: reviewDrills,
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      final reviewCardFinder = find.byKey(
        const Key('session_drill_player_world2_review_intro_card_v1'),
      );
      final reviewPromptFinder = find.byKey(
        const Key('session_drill_player_prompt'),
      );
      final reviewActionBarFinder = find.byKey(
        const Key('session_drill_player_texture_action_bar_v1'),
      );
      final reviewIntroRect = tester.getRect(reviewCardFinder);
      final reviewPromptRect = tester.getRect(reviewPromptFinder);
      final reviewActionRect = tester.getRect(reviewActionBarFinder);

      expect(reviewCardFinder, findsOneWidget);
      expect(reviewPromptFinder, findsOneWidget);
      expect(reviewActionBarFinder, findsOneWidget);
      expect(reviewIntroRect.bottom, lessThanOrEqualTo(reviewPromptRect.top));
      expect(reviewPromptRect.bottom, lessThan(reviewActionRect.top));

      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_review_recap_card_v1'),
        ),
      );

      final reviewRecapRect = tester.getRect(
        find.byKey(
          const Key('session_drill_player_world2_review_recap_card_v1'),
        ),
      );
      final reviewCompletionRect = tester.getRect(
        find.byKey(const Key('session_drill_player_completion_surface_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(reviewRecapRect.bottom, lessThan(reviewCompletionRect.top));
      expect(
        reviewCompletionRect.top - reviewRecapRect.bottom,
        greaterThanOrEqualTo(8),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s06',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _outsItem(
                'count_flush_draw_nine_outs',
                prompt: 'Four-flush on the flop. How many outs?',
                outs: '9',
                why: 'A flush draw usually has 9 outs.',
                heroHoleCards: const <String>['Ah', 'Qh'],
                boardCards: const <String>['Kc', '7h', '2h'],
              ),
              _outsItem(
                'count_open_ended_straight_draw_eight_outs',
                prompt: 'Open-ended straight draw. How many outs?',
                outs: '8',
                why: 'An open-ended straight draw usually has 8 outs.',
                heroHoleCards: const <String>['Qc', 'Jd'],
                boardCards: const <String>['Th', '9c', '2d'],
              ),
              _outsItem(
                'count_gutshot_four_outs',
                prompt: 'Gutshot straight draw. How many outs?',
                outs: '4',
                why: 'A gutshot usually has 4 outs.',
                heroHoleCards: const <String>['Qc', 'Jd'],
                boardCards: const <String>['Ah', 'Tc', '2d'],
              ),
            ],
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      final outsPromptRect = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
      );
      final outsTableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      final outsIntroRect = tester.getRect(
        find.byKey(
          const Key('session_drill_player_world2_outs_intro_supplement_v1'),
        ),
      );
      final outsSupportLaneRect = tester.getRect(
        find.byKey(const Key('session_drill_player_scene_support_lane_v1')),
      );
      final outsBarRect = tester.getRect(
        find.byKey(const Key('session_drill_player_outs_count_bar_v1')),
      );

      expect(outsPromptRect.bottom, lessThan(outsTableRect.top));
      expect(
        outsSupportLaneRect.top - outsTableRect.bottom,
        greaterThanOrEqualTo(8),
      );
      expect(outsIntroRect.bottom, lessThan(outsBarRect.top));

      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_9_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_8_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_4_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_outs_recap_supplement_v1'),
        ),
      );

      expect(
        find.byKey(
          const Key('session_drill_player_world2_outs_recap_supplement_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_count_bar_v1')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'benchmark re-sweep keeps world 3 completion transition stable on the direct canonical path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      _setPhoneViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w3.s06',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _loadHandChainDrillFromFile(
                'w3.s06',
                'd.chain_preflop_mixed_context_checkpoint_v1.json',
              ),
            ],
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pumpAndSettle();

      final tableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      final completionRect = tester.getRect(
        find.byKey(const Key('session_drill_player_completion_surface_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_completion_surface_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_completion_why_v1')),
        findsOneWidget,
      );
      expect(completionRect.top - tableRect.bottom, greaterThanOrEqualTo(8));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'benchmark re-sweep keeps world 9 spatial slice readable from seat anchor to first action-bearing state',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      _setPhoneViewport(tester);

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s05'),
      ))!;
      final spatialAnchorDrill = drills.firstWhere(
        (item) => item.drillId == 'find_seat_s2_position',
      );
      final actionBearingDrill = drills.firstWhere(
        (item) => item.drillId == 'choose_call_position_control',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w9.s05',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              spatialAnchorDrill,
              _spatializedActionBearingDrill(
                spatialAnchorDrill: spatialAnchorDrill,
                actionBearingDrill: actionBearingDrill,
              ),
            ],
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
      );
      await tester.pumpAndSettle();

      final promptRect = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
      );
      final targetMarkerRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_marker_1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_surfaced_header')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('S2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('CO'),
        ),
        findsOneWidget,
      );
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(targetMarkerRect.height, greaterThanOrEqualTo(20));

      await _tapSeat(tester, 1);
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.pumpAndSettle();

      final actionBarRect = tester.getRect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(actionBarRect.top - tableRect.bottom, greaterThanOrEqualTo(8));
      expect(tester.takeException(), isNull);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';

void main() {
  Future<void> _pumpUntilReady(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 140,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (find
              .byKey(const Key('session_drill_player_table_viewport'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('session_drill_player_load_error'))
              .evaluate()
              .isNotEmpty) {
        return;
      }
    }
  }

  SessionDrillItemV1 _positionItem() {
    return SessionDrillItemV1(
      drillId: 'world2_rendered_acceptance_position_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_rendered_acceptance_position_v1","kind":"position_thinking_choice_v1","prompt":"Hero is on the button versus the big blind. Who acts later after the flop?","player_count_v1":4,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","bb"],"folded_seats_v1":["co"],"empty_seats_v1":["sb"],"street_v1":"flop","available_actions_v1":["hero","villain"],"expected":{"actionId":"hero"},"error_class":"position_thinking_choice_mismatch","why_v1":"The button acts later after the flop.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _positionGeometryGuardItem() {
    return SessionDrillItemV1(
      drillId: 'world2_rendered_geometry_guard_position_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_rendered_geometry_guard_position_v1","kind":"position_thinking_choice_v1","prompt":"Hero is on the button with late seats still between hero and the big blind. Who acts later after the flop?","player_count_v1":6,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","co","hj","bb"],"folded_seats_v1":["sb"],"empty_seats_v1":["lj"],"street_v1":"flop","available_actions_v1":["hero","villain"],"expected":{"actionId":"hero"},"error_class":"position_thinking_choice_mismatch","why_v1":"The button still acts later after the flop even when other late seats remain on the arc.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
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

  testWidgets(
    'rendered acceptance sweep keeps seat-context surfaced scenes truthful and hierarchy-forward at phone size',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: <SessionDrillItemV1>[_positionItem()],
          ),
        ),
      );
      await _pumpUntilReady(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_acting_focus_chip_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_scene_proof_badge')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_scene_proof_badge')),
          matching: find.text('POSITION'),
        ),
        findsOneWidget,
      );
      expect(find.text('ACTING HERO'), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_role_0')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_0')),
          matching: find.text('HERO'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_role_1')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_1')),
          matching: find.text('VILLAIN'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_folded_2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_empty_3')),
        findsOneWidget,
      );

      final promptRect = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
      );
      final headerRect = tester.getRect(
        find.byKey(const Key('session_drill_player_surfaced_header')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      expect(headerRect.height, lessThanOrEqualTo(68));
      expect(promptRect.height, lessThanOrEqualTo(28));
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(tableRect.height, greaterThan(headerRect.height * 5));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rendered acceptance sweep keeps authored arc order on geometry-bearing position scenes',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _positionGeometryGuardItem(),
            ],
          ),
        ),
      );
      await _pumpUntilReady(tester);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_marker_1')), findsNothing);
      expect(find.byKey(const Key('modern_table_seat_marker_2')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_3')),
          matching: find.text('POST BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_4')),
          matching: find.text('POST SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_0')),
          matching: find.text('HERO'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_3')),
          matching: find.text('VILLAIN'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_role_1')), findsNothing);

      expect(
        find.byKey(const Key('modern_table_seat_folded_4')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_empty_5')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rendered acceptance sweep keeps dense surfaced scenes readable without support-action collapse',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s04',
            debugDrillsOverrideV1: <SessionDrillItemV1>[_boardTextureItem()],
          ),
        ),
      );
      await _pumpUntilReady(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_scene_proof_badge')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_scene_proof_badge')),
          matching: find.text('BOARD TEXTURE'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_scene_support_lane_v1')),
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

      final headerRect = tester.getRect(
        find.byKey(const Key('session_drill_player_surfaced_header')),
      );
      final promptRect = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
      );
      final feedbackRect = tester.getRect(
        find.byKey(const Key('session_drill_player_feedback_block_v1')),
      );
      final actionRect = tester.getRect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      expect(headerRect.height, lessThanOrEqualTo(68));
      expect(promptRect.height, lessThanOrEqualTo(32));
      expect(actionRect.top - feedbackRect.bottom, greaterThanOrEqualTo(10));
      expect(tester.takeException(), isNull);
    },
  );
}

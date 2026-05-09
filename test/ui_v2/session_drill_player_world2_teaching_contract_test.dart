import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';

void main() {
  Future<void> _pumpUntilSessionReady(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 120,
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

  SessionDrillItemV1 _boardTextureItem() {
    return SessionDrillItemV1(
      drillId: 'world2_teaching_contract_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_teaching_contract_v1","kind":"board_texture_classifier_v1","prompt":"Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.","intro_v1":"Read the real board first. Dry flops usually keep pressure lower because fewer turn cards change the picture fast.","street_v1":"flop","board_cards_v1":["As","7d","2c"],"board_texture_v1":"dry","board_texture_policy_shape_v1":"pressure_level","board_texture_policy_target_v1":"calmer","available_actions_v1":["call","raise"],"expected_action":"call","error_class":"expected_action_mismatch","why_v1":"A-7-2 rainbow is dry, so fewer draws and turn shifts build pressure right away.","feedback_correct_v1":"Correct. This flop stays calmer because it does not create many immediate draw paths.","feedback_incorrect_v1":"Incorrect. This flop is the calmer board because the texture stays dry and stable."}',
      ),
    );
  }

  testWidgets(
    'surfaced World 2 teaching contract keeps prompt reveal and fail hierarchy aligned',
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
      await _pumpUntilSessionReady(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_surfaced_header')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_surfaced_prompt_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_surfaced_header')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_prompt_sheet_title')),
        findsOneWidget,
      );
      final promptSheetTitle = tester.widget<Text>(
        find.byKey(const Key('session_drill_player_prompt_sheet_title')),
      );
      expect(promptSheetTitle.data, 'Board Texture');
      expect(
        find.byKey(const Key('session_drill_player_prompt_sheet_body')),
        findsOneWidget,
      );
      final promptSheetBody = tester.widget<Text>(
        find.byKey(const Key('session_drill_player_prompt_sheet_body')),
      );
      expect(
        promptSheetBody.data,
        'Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.',
      );

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_detail')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Incorrect. This flop is the calmer board because the texture stays dry and stable.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'A-7-2 rainbow is dry, so fewer draws and turn shifts build pressure right away.',
        ),
        findsOneWidget,
      );
    },
  );
}

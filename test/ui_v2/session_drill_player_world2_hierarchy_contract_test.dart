import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';

void main() {
  Future<void> _pumpUntilReady(
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

  SessionDrillItemV1 _positionItem() {
    return SessionDrillItemV1(
      drillId: 'world2_hierarchy_contract_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_hierarchy_contract_v1","kind":"position_thinking_choice_v1","prompt":"Hero is on the button versus the big blind. Who acts later after the flop?","player_count_v1":4,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","bb"],"folded_seats_v1":["co"],"empty_seats_v1":["sb"],"street_v1":"flop","available_actions_v1":["hero","villain"],"expected":{"actionId":"hero"},"error_class":"position_thinking_choice_mismatch","why_v1":"The button acts later after the flop.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'surfaced World 2 seat-context scenes surface dominant task prompt and acting-focus chip at phone size',
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
        find.byKey(const Key('session_drill_player_status_header')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_acting_focus_chip_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_acting_focus_text_v1')),
        findsOneWidget,
      );
      expect(find.text('ACTING HERO'), findsOneWidget);

      final headerRect = tester.getRect(
        find.byKey(const Key('session_drill_player_surfaced_header')),
      );
      final promptRect = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
      );
      final chipRect = tester.getRect(
        find.byKey(const Key('session_drill_player_acting_focus_chip_v1')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_table_viewport')),
      );

      expect(headerRect.height, lessThanOrEqualTo(66));
      expect(promptRect.height, greaterThanOrEqualTo(22));
      expect(promptRect.height, lessThanOrEqualTo(28));
      expect(promptRect.width, greaterThanOrEqualTo(320));
      expect(chipRect.top, greaterThanOrEqualTo(headerRect.top));
      expect(chipRect.bottom, lessThanOrEqualTo(headerRect.bottom));
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(tableRect.height, greaterThan(headerRect.height * 5));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isNull);
      expect(appBar.toolbarHeight, equals(40));
      expect(tester.takeException(), isNull);
    },
  );
}

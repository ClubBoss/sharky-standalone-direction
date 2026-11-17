import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

/// Advances the ordinary runtime timers before the test submits its one answer.
/// Each pump covers the longest existing beat (500 ms); the extra pump covers
/// the initial 160 ms delay. No input or decision-ready state is injected.
Future<void> pumpSourceChoreographyToDecisionV1(
  WidgetTester tester,
  Act0TableStateV1 table,
) async {
  final plan = act0TableChoreographyPlanForTableV1(table);
  if (plan != null) {
    for (var beat = 0; beat <= plan.beats.length; beat++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }
  await tester.pumpAndSettle();
}

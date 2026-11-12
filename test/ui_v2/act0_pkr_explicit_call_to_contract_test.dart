// Existing canonical parser: explicit total vs additional-call grammar.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import '../support/w4_theory_source_projection.dart';

Act0TableStateV1 withCall(String label) {
  final table = projectTheorySource().runner.table;
  return table.copyWith(
    actionTrail: [
      for (final e in table.actionTrail)
        Act0ActionTrailItemV1(
          label: e.label == 'SB calls to 2.5 BB' ? label : e.label,
        ),
    ],
  );
}

void main() {
  for (final label in [
    'SB calls to 2.5 BB',
    'SB call to 2.5 BB',
    'SB calls 2.5 BB',
    'SB calls 2 BB more',
  ]) {
    test('total or incremental canonical call: $label', () {
      final table = withCall(label);
      expect(
        act0BettingRoundOrderTruthForTableV1(table),
        Act0BettingRoundOrderTruthV1.consistent,
      );
      final read = act0TablePriceV1(table);
      expect(read.facts, isNotNull, reason: read.reason);
      expect(read.facts!.potBeforeActionBb, 8);
      expect(read.facts!.callCostBb, 2);
    });
  }
  for (final label in [
    'SB calls to 2 BB more',
    'SB call to 2 BB more',
    'SB calls to 2.5 BB garbage',
    'SB calls to to 2.5 BB',
    'SB calls by 2.5 BB',
  ]) {
    test('malformed or contradictory call units remain rejected: $label', () {
      final table = withCall(label);
      expect(
        act0BettingRoundOrderTruthForTableV1(table),
        isNot(Act0BettingRoundOrderTruthV1.consistent),
      );
      expect(act0TablePriceV1(table).facts, isNull);
    });
  }
}

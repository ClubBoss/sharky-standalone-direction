import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_outs_scenario_state_v1.dart';

void main() {
  test(
    'canonical outs scenario state returns null when outs context is absent',
    () {
      final state = resolveSessionDrillCanonicalOutsScenarioStateV1(
        const DrillSpecV1(
          id: 'missing_outs_context',
          kind: DrillKindV1.outsCountChoice,
          prompt: 'Count the outs.',
          expected: DrillExpectedV1(actionId: '9'),
          errorClass: 'outs_error',
        ),
      );

      expect(state, isNull);
    },
  );

  test('canonical outs scenario state preserves authored outs context', () {
    final state = resolveSessionDrillCanonicalOutsScenarioStateV1(
      const DrillSpecV1(
        id: 'count_flush_draw_nine_outs',
        kind: DrillKindV1.outsCountChoice,
        prompt: 'Count the outs for the flush draw.',
        expected: DrillExpectedV1(actionId: '9'),
        errorClass: 'outs_error',
        streetV1: 'flop',
        boardCardsV1: <String>['Ah', '7h', '2c'],
        heroHoleCardsV1: <String>['Kh', 'Qh'],
        availableActionsV1: <String>['4', '8', '9', '15'],
        expectedActionV1: '9',
      ),
    );

    expect(state, isNotNull);
    expect(state!.streetV1, 'flop');
    expect(state.heroHoleCardsV1, <String>['Kh', 'Qh']);
    expect(state.boardCardsV1, <String>['Ah', '7h', '2c']);
    expect(state.availableActionsV1, <String>['4', '8', '9', '15']);
    expect(state.expectedActionIdV1, '9');
  });
}

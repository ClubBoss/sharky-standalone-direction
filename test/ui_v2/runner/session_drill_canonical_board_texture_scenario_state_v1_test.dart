import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1.dart';

void main() {
  test(
    'canonical board-texture scenario state preserves authored texture context',
    () {
      final state = resolveSessionDrillCanonicalBoardTextureScenarioStateV1(
        sessionId: 'w2.s05',
        spec: const DrillSpecV1(
          id: 'review_texture_dry_board_stays_calmer',
          kind: DrillKindV1.boardTextureClassifier,
          prompt: 'Classify this flop texture.',
          expected: DrillExpectedV1(actionId: 'dry'),
          errorClass: 'board_texture_mismatch',
          streetV1: 'flop',
          boardCardsV1: <String>['As', '7d', '2c'],
          boardTextureV1: 'dry',
          availableActionsV1: <String>['dry', 'wet'],
          expectedActionV1: 'dry',
        ),
      );

      expect(state, isNotNull);
      expect(state!.streetV1, 'flop');
      expect(state.boardCardsV1, <String>['As', '7d', '2c']);
      expect(state.boardTextureV1, 'dry');
      expect(state.availableActionsV1, <String>['dry', 'wet']);
      expect(state.expectedActionIdV1, 'dry');
    },
  );

  test(
    'canonical board-texture scenario state derives world5 fallback truth once',
    () {
      final state = resolveSessionDrillCanonicalBoardTextureScenarioStateV1(
        sessionId: 'w5.s04',
        spec: const DrillSpecV1(
          id: 'classify_texture_turn_connected_v1',
          kind: DrillKindV1.boardTextureClassifier,
          prompt: 'The turn keeps this connected. Classify the board texture.',
          expected: DrillExpectedV1(actionId: 'connected'),
          errorClass: 'board_texture_mismatch',
          boardTextureV1: 'connected',
        ),
      );

      expect(state, isNotNull);
      expect(state!.streetV1, 'turn');
      expect(state.boardCardsV1, <String>['Js', 'Td', '9c', '8h']);
      expect(state.boardTextureV1, 'connected');
      expect(state.expectedActionIdV1, 'connected');
    },
  );
}

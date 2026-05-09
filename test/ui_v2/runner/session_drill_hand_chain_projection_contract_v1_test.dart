import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_hand_chain_projection_contract_v1.dart';

void main() {
  test('text-only hand chain stays outside the projection contract', () {
    const spec = DrillSpecV1(
      id: 'chain_world4_purpose_checkpoint_v1',
      kind: DrillKindV1.handChain,
      prompt: 'Play this short checkpoint chain.',
      expected: DrillExpectedV1(actionId: 'raise'),
      errorClass: 'unused',
      chainIdV1: 'w4_s03_purpose_checkpoint_v1',
      chainStepsV1: <DrillChainStepV1>[
        DrillChainStepV1(
          street: 'flop',
          prompt: 'Choose action.',
          errorClass: 'expected_action_mismatch',
          availableActionsV1: <String>['fold', 'call', 'raise'],
          expectedActionV1: 'raise',
        ),
      ],
    );

    final evaluation = SessionDrillHandChainProjectionContractV1.evaluate(
      hostSurface: 'sessionDrillPlayer',
      layoutFamily: 'text_action_stack',
      drill: spec,
    );

    expect(evaluation.applies, isFalse);
    expect(evaluation.tableRequired, isFalse);
  });

  test('authored table hand chain requires embedded projected layout', () {
    const spec = DrillSpecV1(
      id: 'w2_chain',
      kind: DrillKindV1.handChain,
      prompt: 'Play chain.',
      expected: DrillExpectedV1(actionId: 'raise'),
      errorClass: 'unused',
      chainIdV1: 'w2_s07_position_then_initiative_v1',
      chainStepsV1: <DrillChainStepV1>[
        DrillChainStepV1(
          street: 'flop',
          prompt: 'Choose action.',
          errorClass: 'expected_action_mismatch',
          availableActionsV1: <String>['fold', 'call', 'raise'],
          expectedActionV1: 'raise',
          playerCountV1: 6,
          heroSeatV1: 'btn',
          villainSeatV1: 'bb',
          activeSeatsV1: <String>['btn', 'co', 'hj', 'utg', 'sb', 'bb'],
          boardCardsV1: <String>['Ah', 'Kd', '7c'],
          heroHoleCardsV1: <String>['Qs', 'Qd'],
        ),
      ],
    );

    final evaluation = SessionDrillHandChainProjectionContractV1.evaluate(
      hostSurface: 'sessionDrillPlayer',
      layoutFamily: 'text_action_stack',
      drill: spec,
    );

    expect(evaluation.applies, isTrue);
    expect(evaluation.tableRequired, isTrue);
    expect(evaluation.authoredProjectionStepCount, 1);
    expect(evaluation.hostGateSatisfied, isFalse);
    expect(
      evaluation.hostGateReasonCode,
      kSessionDrillHandChainProjectionHostGateReasonCodeV1,
    );
  });

  test('authored table hand chain is green on embedded projected layout', () {
    const spec = DrillSpecV1(
      id: 'w2_chain',
      kind: DrillKindV1.handChain,
      prompt: 'Play chain.',
      expected: DrillExpectedV1(actionId: 'raise'),
      errorClass: 'unused',
      chainIdV1: 'w2_s07_position_then_initiative_v1',
      chainStepsV1: <DrillChainStepV1>[
        DrillChainStepV1(
          street: 'flop',
          prompt: 'Choose action.',
          errorClass: 'expected_action_mismatch',
          availableActionsV1: <String>['fold', 'call', 'raise'],
          expectedActionV1: 'raise',
          playerCountV1: 6,
          heroSeatV1: 'btn',
          villainSeatV1: 'bb',
          activeSeatsV1: <String>['btn', 'co', 'hj', 'utg', 'sb', 'bb'],
          boardCardsV1: <String>['Ah', 'Kd', '7c'],
          heroHoleCardsV1: <String>['Qs', 'Qd'],
        ),
      ],
    );

    final evaluation = SessionDrillHandChainProjectionContractV1.evaluate(
      hostSurface: 'sessionDrillPlayer',
      layoutFamily: 'embedded_table_projected',
      drill: spec,
    );

    expect(evaluation.applies, isTrue);
    expect(evaluation.hostGateSatisfied, isTrue);
    expect(evaluation.hasRequiredScenePayload, isTrue);
    expect(
      evaluation.payloadFamily,
      kSessionDrillHandChainProjectionPayloadFamilyV1,
    );
  });
}

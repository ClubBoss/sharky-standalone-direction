import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/drill_host_capability_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';

void main() {
  test('surfaced drill contract activates shared host zones and action lane', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"texture_1","kind":"board_texture_classifier_v1","prompt":"Classify the board texture.","board_texture_v1":"dry","street_v1":"flop","board_cards_v1":["As","7d","2c"],"expected_action":"fold","error_class":"expected_action_mismatch","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
    );
    final contract = resolveDrillHostCapabilityContractV1(
      DrillHostCapabilityContractInputV1(
        sessionId: 'w2.s04',
        spec: spec,
        currentDrillIndex: 0,
        currentChainStepIndex: 0,
        isCompleted: false,
        showsSurfacedScenarioHostV1: true,
        showsEmbeddedScenarioTableV1: true,
        sections: const RunnerHostSectionResponsibilityV1(
          showIntro: true,
          showSourceMeta: true,
          showRecap: true,
          showEmbeddedFeedbackBelowTable: true,
        ),
      ),
    );

    expect(spec.kind, DrillKindV1.boardTextureClassifier);
    expect(contract.promptSourceId, 'w2.s04#drill1');
    expect(contract.showsSurfacedScenarioHost, isTrue);
    expect(contract.showsEmbeddedScenarioTable, isTrue);
    expect(contract.showsActionZone, isTrue);
    expect(contract.showsCompletionContinuationSurface, isFalse);
    expect(contract.hasCapability(DrillHostCapabilityV1.introSection), isTrue);
    expect(
      contract.hasCapability(DrillHostCapabilityV1.sourceMetaSection),
      isTrue,
    );
    expect(
      contract.hasCapability(DrillHostCapabilityV1.embeddedFeedbackBelowTable),
      isTrue,
    );
  });

  test('completed hand-chain contract flips to continuation surface', () {
    final contract = resolveDrillHostCapabilityContractV1(
      const DrillHostCapabilityContractInputV1(
        sessionId: 'w2.s07',
        spec: DrillSpecV1(
          id: 'chain_1',
          kind: DrillKindV1.handChain,
          prompt: 'Continue the hand.',
          expected: DrillExpectedV1(),
          errorClass: 'expected_action_mismatch',
        ),
        currentDrillIndex: 1,
        currentChainStepIndex: 2,
        isCompleted: true,
        showsSurfacedScenarioHostV1: true,
        showsEmbeddedScenarioTableV1: true,
      ),
    );

    expect(contract.promptSourceId, 'w2.s07#drill2#step3');
    expect(
      contract.hasCapability(DrillHostCapabilityV1.handChainProgression),
      isTrue,
    );
    expect(contract.showsActionZone, isFalse);
    expect(contract.showsCompletionContinuationSurface, isTrue);
    expect(
      contract.hasCapability(DrillHostCapabilityV1.completionContinuationZone),
      isTrue,
    );
  });

  test(
    'seat-tap contract keeps action lane off and exposes seat interaction',
    () {
      const spec = DrillSpecV1(
        id: 'seat_1',
        kind: DrillKindV1.seatTap,
        prompt: 'Tap the button seat.',
        expected: DrillExpectedV1(seatId: 'S0'),
        errorClass: 'seat_mismatch',
      );
      final contract = resolveDrillHostCapabilityContractV1(
        DrillHostCapabilityContractInputV1(
          sessionId: 'w0.s01',
          spec: spec,
          currentDrillIndex: 2,
          currentChainStepIndex: 0,
          isCompleted: false,
          showsSurfacedScenarioHostV1: false,
          showsEmbeddedScenarioTableV1: false,
        ),
      );

      expect(contract.promptSourceId, 'w0.s01#drill3');
      expect(contract.showsSurfacedScenarioHost, isFalse);
      expect(contract.showsEmbeddedScenarioTable, isFalse);
      expect(contract.showsActionZone, isFalse);
      expect(contract.showsCompletionContinuationSurface, isFalse);
      expect(
        contract.hasCapability(DrillHostCapabilityV1.seatTapInteraction),
        isTrue,
      );
      expect(contract.hasCapability(DrillHostCapabilityV1.actionZone), isFalse);
    },
  );
}

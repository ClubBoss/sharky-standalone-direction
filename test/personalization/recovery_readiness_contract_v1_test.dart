import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recovery_readiness_contract_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';

void main() {
  test('derive resolves rebuild for active weakness state', () {
    final contract = RecoveryReadinessContractFactoryV1.derive(
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'w2.s02',
        correctCount: 2,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'action_order',
        reasonCode: 'weakness_confidence_active',
        shortHintText: 'Review it.',
        recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: 'action_order_btn_last',
      ),
      weaknessAssessment: const WeaknessConfidenceAssessmentV1(
        focusId: 'action_order',
        state: WeaknessConfidenceStateV1.active,
        recentMistakeCount: 2,
        correctiveHistoryCount: 1,
      ),
      worldMasteryLevel: WorldMasteryLevelV1.bronze,
    );

    expect(contract, isNotNull);
    expect(contract!.state, RecoveryReadinessStateV1.rebuild);
    expect(
      contract.fitLine,
      'Readiness: Rebuild first. This weakness is still showing up across recent sessions.',
    );
  });

  test('derive resolves ready to step for clean silver session', () {
    final contract = RecoveryReadinessContractFactoryV1.derive(
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'w2.s04',
        correctCount: 3,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'board_texture',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.nextModule,
        recommendedNextSessionTarget: 'w2.s05',
      ),
      weaknessAssessment: null,
      worldMasteryLevel: WorldMasteryLevelV1.silver,
    );

    expect(contract, isNotNull);
    expect(contract!.state, RecoveryReadinessStateV1.readyToStep);
    expect(contract.deltaSignal, contains('Ready to step'));
  });

  test('derive returns null when mastery state is unavailable', () {
    final contract = RecoveryReadinessContractFactoryV1.derive(
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'w2.s04',
        correctCount: 3,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'board_texture',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.nextModule,
        recommendedNextSessionTarget: 'w2.s05',
      ),
      weaknessAssessment: null,
      worldMasteryLevel: null,
    );

    expect(contract, isNull);
  });
}

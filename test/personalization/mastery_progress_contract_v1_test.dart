import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/mastery_progress_contract_v1.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';

void main() {
  test('derive builds repeat-fit framing and mastery delta', () {
    final contract = MasteryProgressContractFactoryV1.derive(
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'world1_spine_campaign_v1',
        correctCount: 2,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'initiative',
        reasonCode: 'progression_repeat_fit',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.repeatPack,
        recommendedNextSessionTarget: 'world1_spine_campaign_v1',
      ),
      worldMasteryLevel: WorldMasteryLevelV1.silver,
      campaignRankLabel: 'Fish',
    );

    expect(contract, isNotNull);
    expect(
      contract!.fitLine,
      'Fit now: One more rep at this level should settle the pattern before you move on.',
    );
    expect(
      contract.deltaSignal,
      'Progress delta: Reinforce Silver mastery · Fish tier',
    );
  });

  test('derive returns null when mastery state is unavailable', () {
    final contract = MasteryProgressContractFactoryV1.derive(
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'world1_spine_campaign_v1',
        correctCount: 3,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'board_texture',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.continueCampaign,
        recommendedNextSessionTarget: 'world2_spine_campaign_v1',
      ),
      worldMasteryLevel: null,
    );

    expect(contract, isNull);
  });
}

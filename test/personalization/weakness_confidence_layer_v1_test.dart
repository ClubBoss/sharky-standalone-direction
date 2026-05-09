import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await WeaknessConfidenceLayerV1.clearForTesting();
  });

  test('apply marks a recurring weakness as active and promotes review', () {
    final history = WeaknessConfidenceLayerV1.appendInMemory(
      history: const <WeaknessConfidenceHistoryEntryV1>[
        WeaknessConfidenceHistoryEntryV1(
          focusId: 'action_order',
          nextAction: PersonalizedNextActionV1.reviewFocus,
          moduleId: 'world1_spine_campaign_v1',
          hadMistake: true,
          recordedAtMs: 1,
        ),
      ],
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'action_order',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.continueCampaign,
        recommendedNextSessionTarget: 'world2_spine_campaign_v1',
      ),
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'world1_spine_campaign_v1',
        correctCount: 2,
        totalCount: 3,
        isCampaignSession: true,
      ),
    );
    final result = WeaknessConfidenceLayerV1.apply(
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'action_order',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.continueCampaign,
        recommendedNextSessionTarget: 'world2_spine_campaign_v1',
      ),
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'world1_spine_campaign_v1',
        correctCount: 2,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recentSignals: const <RecentTelemetrySignalV1>[
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'correct': false,
            'error_type': 'incorrect_seat',
          },
        ),
      ],
      history: history,
    );

    expect(result, isNotNull);
    expect(result!.reasonCode, 'weakness_confidence_active');
    expect(result.recommendedNextAction, PersonalizedNextActionV1.reviewFocus);
  });

  test('apply marks a reviewed clean run as stabilizing', () {
    final result = WeaknessConfidenceLayerV1.apply(
      recommendation: const PersonalizedRecommendationV1(
        recommendedFocusId: 'board_texture',
        reasonCode: 'review_focus',
        shortHintText: 'Review it.',
        recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: 'w2.s04',
      ),
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'w2.s04',
        correctCount: 3,
        totalCount: 3,
        isCampaignSession: true,
      ),
      recentSignals: const <RecentTelemetrySignalV1>[],
      history: const <WeaknessConfidenceHistoryEntryV1>[
        WeaknessConfidenceHistoryEntryV1(
          focusId: 'board_texture',
          nextAction: PersonalizedNextActionV1.reviewFocus,
          moduleId: 'w2.s04',
          hadMistake: true,
          recordedAtMs: 1,
        ),
      ],
    );

    expect(result, isNotNull);
    expect(result!.reasonCode, 'weakness_confidence_stabilizing');
    expect(result.recommendedNextAction, PersonalizedNextActionV1.repeatPack);
  });
}

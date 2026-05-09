import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ProgressionQualityGateV1.clearForTesting();
  });

  test(
    'gate downgrades continue to repeat for shaky recent campaign state',
    () {
      const recommendation = PersonalizedRecommendationV1(
        recommendedFocusId: 'initiative',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.continueCampaign,
        recommendedNextSessionTarget: 'world2_spine_campaign_v1',
      );
      final gated = ProgressionQualityGateV1.apply(
        recommendation: recommendation,
        latestSession: const LatestSessionOutcomeSnapshotV1(
          moduleId: 'world1_spine_campaign_v1',
          correctCount: 2,
          totalCount: 3,
          isCampaignSession: true,
          outcomeKind: OutcomeKindV1.mistake,
          errorType: 'incorrect_line',
        ),
        recentSignals: const <RecentTelemetrySignalV1>[
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{'correct': false},
          ),
        ],
      );

      expect(gated, isNotNull);
      expect(gated!.recommendedNextAction, PersonalizedNextActionV1.repeatPack);
      expect(gated.recommendedNextSessionTarget, 'world1_spine_campaign_v1');
      expect(gated.reasonCode, 'progression_repeat_fit');
    },
  );

  test('gate escalates to review for clustered misses', () {
    const recommendation = PersonalizedRecommendationV1(
      recommendedFocusId: 'board_texture',
      reasonCode: 'slow_action_decisions',
      shortHintText: 'Pause on texture first.',
      recommendedNextAction: PersonalizedNextActionV1.nextModule,
      recommendedNextSessionTarget: 'w2.s01',
    );
    final gated = ProgressionQualityGateV1.apply(
      recommendation: recommendation,
      latestSession: const LatestSessionOutcomeSnapshotV1(
        moduleId: 'w1.s03',
        correctCount: 0,
        totalCount: 3,
        isCampaignSession: false,
        outcomeKind: OutcomeKindV1.mistake,
        errorType: 'paired_board_misses',
      ),
      recentSignals: const <RecentTelemetrySignalV1>[
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{'correct': false},
        ),
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{'correct': false},
        ),
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{'correct': false},
        ),
      ],
    );

    expect(gated, isNotNull);
    expect(gated!.recommendedNextAction, PersonalizedNextActionV1.reviewFocus);
    expect(gated.recommendedNextSessionTarget, 'w2.s01');
    expect(gated.reasonCode, 'progression_review_fit');
  });
}

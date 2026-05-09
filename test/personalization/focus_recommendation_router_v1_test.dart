import 'package:poker_analyzer/personalization/focus_recommendation_router_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:test/test.dart';

void main() {
  group('FocusRecommendationRouterV1', () {
    test('focus due overrides everything', () {
      final rec = FocusRecommendationRouterV1.route(
        FocusRecommendationInputsV1(
          isCampaignSession: true,
          focusReviewDue: true,
          campaignOutcomeSummary: _mistakeSummary(),
          topErrorBuckets: const <MapEntry<String, int>>[
            MapEntry<String, int>('Timing', 3),
          ],
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.reviewFocus);
      expect(rec.reason, 'Focus review due');
      expect(rec.priority, FocusRecommendationRouterV1.priorityFocusReviewDue);
    });

    test('campaign mistakes recommend repeat pack', () {
      final rec = FocusRecommendationRouterV1.route(
        FocusRecommendationInputsV1(
          isCampaignSession: true,
          focusReviewDue: false,
          campaignOutcomeSummary: _mistakeSummary(),
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.repeatPack);
      expect(rec.reason, 'Fix recent mistakes');
      expect(rec.priority, FocusRecommendationRouterV1.priorityRepeatPack);
    });

    test('personalization result can promote review focus', () {
      final rec = FocusRecommendationRouterV1.route(
        const FocusRecommendationInputsV1(
          isCampaignSession: true,
          focusReviewDue: false,
          personalizationResultV1: PersonalizedRecommendationV1(
            recommendedFocusId: 'action_order',
            reasonCode: 'repeated_error_type',
            shortHintText:
                'Missed seat order twice recently. '
                'Name who acts first before you tap a seat.',
            recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
            recommendedNextSessionTarget: 'core_positions_and_initiative',
          ),
          campaignOutcomeSummary: OutcomeSummaryV1(
            packId: 'world1_spine_campaign_v1',
            worldId: 1,
            beatIndex: 0,
            outcomeKind: OutcomeKindV1.mistake,
            errorType: 'expected_seat_mismatch',
            lines: <String>['Outcome: mistake punished'],
          ),
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.reviewFocus);
      expect(
        rec.priority,
        FocusRecommendationRouterV1.priorityPersonalizedReviewFocus,
      );
      expect(rec.reason, 'Missed seat order twice recently');
    });

    test('top bucket recommends review focus for campaign session', () {
      final rec = FocusRecommendationRouterV1.route(
        const FocusRecommendationInputsV1(
          isCampaignSession: true,
          focusReviewDue: false,
          topErrorBuckets: <MapEntry<String, int>>[
            MapEntry<String, int>('Range', 2),
          ],
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.reviewFocus);
      expect(rec.reason, 'Top leak: Range');
      expect(rec.priority, FocusRecommendationRouterV1.priorityTopLeak);
    });

    test('non-campaign top bucket does not emit top leak recommendation', () {
      final rec = FocusRecommendationRouterV1.route(
        const FocusRecommendationInputsV1(
          isCampaignSession: false,
          focusReviewDue: false,
          topErrorBuckets: <MapEntry<String, int>>[
            MapEntry<String, int>('Range', 2),
          ],
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.nextModule);
      expect(rec.reason, 'Continue');
      expect(rec.priority, FocusRecommendationRouterV1.priorityNextModule);
    });

    test('campaign with no mistakes continues campaign', () {
      final rec = FocusRecommendationRouterV1.route(
        FocusRecommendationInputsV1(
          isCampaignSession: true,
          focusReviewDue: false,
          campaignOutcomeSummary: _successSummary(),
          topErrorBuckets: const <MapEntry<String, int>>[],
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.continueCampaign);
      expect(rec.reason, 'Continue campaign');
      expect(
        rec.priority,
        FocusRecommendationRouterV1.priorityContinueCampaign,
      );
    });

    test('non-campaign with no signals recommends next module', () {
      final rec = FocusRecommendationRouterV1.route(
        const FocusRecommendationInputsV1(
          isCampaignSession: false,
          focusReviewDue: false,
        ),
      );

      expect(rec.kind, FocusRecommendationKindV1.nextModule);
      expect(rec.reason, 'Continue');
      expect(rec.priority, FocusRecommendationRouterV1.priorityNextModule);
    });

    test('same inputs produce same output', () {
      const inputs = FocusRecommendationInputsV1(
        isCampaignSession: false,
        focusReviewDue: false,
        topErrorBuckets: <MapEntry<String, int>>[
          MapEntry<String, int>('Timing', 4),
        ],
      );

      final first = FocusRecommendationRouterV1.route(inputs);
      final second = FocusRecommendationRouterV1.route(inputs);

      expect(first, second);
      expect(first.toString(), second.toString());
    });
  });
}

OutcomeSummaryV1 _mistakeSummary() {
  return const OutcomeSummaryV1(
    packId: 'world1_spine_campaign_v1',
    worldId: 1,
    beatIndex: 0,
    outcomeKind: OutcomeKindV1.mistake,
    errorType: 'incorrect_line',
    lines: <String>['Outcome: mistake punished'],
  );
}

OutcomeSummaryV1 _successSummary() {
  return const OutcomeSummaryV1(
    packId: 'world1_spine_campaign_v1',
    worldId: 1,
    beatIndex: 1,
    outcomeKind: OutcomeKindV1.success,
    lines: <String>['Outcome: line held'],
  );
}

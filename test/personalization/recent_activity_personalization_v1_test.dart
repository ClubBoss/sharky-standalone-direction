import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:test/test.dart';

void main() {
  group('RecentActivityPersonalizationV1', () {
    test(
      'repeated seat mismatch infers action-order focus and review next',
      () {
        final result = RecentActivityPersonalizationV1.infer(
          RecentActivityPersonalizationInputV1(
            isCampaignSession: true,
            moduleId: 'world1_spine_campaign_v1',
            mode: 'campaign_spine',
            latestOutcomeSummary: const OutcomeSummaryV1(
              packId: 'world1_spine_campaign_v1',
              worldId: 1,
              beatIndex: 0,
              outcomeKind: OutcomeKindV1.mistake,
              errorType: 'expected_seat_mismatch',
              lines: <String>['Outcome: mistake punished'],
            ),
            signals: const <RecentTelemetrySignalV1>[
              RecentTelemetrySignalV1(
                name: 'user_choice',
                payload: <String, Object?>{
                  'module_id': 'world1_spine_campaign_v1',
                  'mode': 'campaign_spine',
                  'step_index': 0,
                  'choice': 'hj',
                },
              ),
              RecentTelemetrySignalV1(
                name: 'correct',
                payload: <String, Object?>{
                  'module_id': 'world1_spine_campaign_v1',
                  'mode': 'campaign_spine',
                  'step_index': 0,
                  'correct': false,
                  'error_type': 'expected_seat_mismatch',
                },
              ),
              RecentTelemetrySignalV1(
                name: 'time_to_decision',
                payload: <String, Object?>{
                  'module_id': 'world1_spine_campaign_v1',
                  'mode': 'campaign_spine',
                  'step_index': 0,
                  'time_to_decision_ms': 5100,
                },
              ),
              RecentTelemetrySignalV1(
                name: 'user_choice',
                payload: <String, Object?>{
                  'module_id': 'world1_spine_campaign_v1',
                  'mode': 'campaign_spine',
                  'step_index': 1,
                  'choice': 'co',
                },
              ),
              RecentTelemetrySignalV1(
                name: 'correct',
                payload: <String, Object?>{
                  'module_id': 'world1_spine_campaign_v1',
                  'mode': 'campaign_spine',
                  'step_index': 1,
                  'correct': false,
                  'error_type': 'expected_seat_mismatch',
                },
              ),
            ],
          ),
        );

        expect(result, isNotNull);
        expect(result!.recommendedFocusId, 'action_order');
        expect(result.reasonCode, 'slow_incorrect_decision');
        expect(
          result.recommendedNextAction,
          PersonalizedNextActionV1.reviewFocus,
        );
        expect(
          result.shortHintText,
          'Missed seat order twice after long pauses. '
          'Name who acts first before you tap a seat.',
        );
        expect(
          result.recommendedNextSessionTarget,
          'core_positions_and_initiative',
        );
      },
    );

    test('slow action decisions infer initiative focus', () {
      final result = RecentActivityPersonalizationV1.infer(
        const RecentActivityPersonalizationInputV1(
          isCampaignSession: false,
          moduleId: 'world1_act0_action_literacy',
          mode: 'table_practice',
          signals: <RecentTelemetrySignalV1>[
            RecentTelemetrySignalV1(
              name: 'user_choice',
              payload: <String, Object?>{
                'module_id': 'world1_act0_action_literacy',
                'mode': 'table_practice',
                'step_index': 0,
                'choice': 'action_call',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'correct',
              payload: <String, Object?>{
                'module_id': 'world1_act0_action_literacy',
                'mode': 'table_practice',
                'step_index': 0,
                'correct': true,
                'error_type': 'none',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'time_to_decision',
              payload: <String, Object?>{
                'module_id': 'world1_act0_action_literacy',
                'mode': 'table_practice',
                'step_index': 0,
                'time_to_decision_ms': 4700,
              },
            ),
            RecentTelemetrySignalV1(
              name: 'user_choice',
              payload: <String, Object?>{
                'module_id': 'world1_act0_action_literacy',
                'mode': 'table_practice',
                'step_index': 1,
                'choice': 'action_raise',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'correct',
              payload: <String, Object?>{
                'module_id': 'world1_act0_action_literacy',
                'mode': 'table_practice',
                'step_index': 1,
                'correct': true,
                'error_type': 'none',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'time_to_decision',
              payload: <String, Object?>{
                'module_id': 'world1_act0_action_literacy',
                'mode': 'table_practice',
                'step_index': 1,
                'time_to_decision_ms': 4900,
              },
            ),
          ],
        ),
      );

      expect(result, isNotNull);
      expect(result!.recommendedFocusId, 'initiative');
      expect(result.reasonCode, 'slow_action_decisions');
      expect(
        result.recommendedNextAction,
        PersonalizedNextActionV1.reviewFocus,
      );
      expect(
        result.shortHintText,
        'Found the initiative cue, but slowly twice. '
        'Pause on the initiative cue before you act.',
      );
    });

    test('keeps decision pairing scoped across mixed learner surfaces', () {
      final result = RecentActivityPersonalizationV1.infer(
        const RecentActivityPersonalizationInputV1(
          isCampaignSession: true,
          signals: <RecentTelemetrySignalV1>[
            RecentTelemetrySignalV1(
              name: 'user_choice',
              payload: <String, Object?>{
                'surface': 'universal_intake_plan',
                'step_index': 0,
                'choice': 'bb',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'correct',
              payload: <String, Object?>{
                'surface': 'universal_intake_plan',
                'step_index': 0,
                'correct': false,
                'error_type': 'incorrect_seat',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'user_choice',
              payload: <String, Object?>{
                'surface': 'universal_intake_plan',
                'step_index': 1,
                'choice': 'hj',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'correct',
              payload: <String, Object?>{
                'surface': 'universal_intake_plan',
                'step_index': 1,
                'correct': false,
                'error_type': 'incorrect_seat',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'user_choice',
              payload: <String, Object?>{
                'module_id': 'world1_spine_campaign_v1',
                'mode': 'campaign_spine',
                'step_index': 0,
                'choice': 'action_raise',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'correct',
              payload: <String, Object?>{
                'module_id': 'world1_spine_campaign_v1',
                'mode': 'campaign_spine',
                'step_index': 0,
                'correct': true,
                'error_type': 'none',
              },
            ),
            RecentTelemetrySignalV1(
              name: 'time_to_decision',
              payload: <String, Object?>{
                'module_id': 'world1_spine_campaign_v1',
                'mode': 'campaign_spine',
                'step_index': 0,
                'time_to_decision_ms': 4900,
              },
            ),
          ],
        ),
      );

      expect(result, isNotNull);
      expect(result!.recommendedFocusId, 'action_order');
      expect(result.reasonCode, 'repeated_error_type');
      expect(
        result.shortHintText,
        'Missed seat order twice recently. '
        'Name who acts first before you tap a seat.',
      );
    });
  });
}

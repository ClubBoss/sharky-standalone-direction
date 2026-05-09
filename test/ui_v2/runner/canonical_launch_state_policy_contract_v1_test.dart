import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_state_policy_contract_v1.dart';

void main() {
  test(
    'canonical launch state policy resolves campaign bootstrap and clamps start index',
    () {
      final resolved = resolveCanonicalLaunchStatePolicyV1(
        const CanonicalLaunchStatePolicyInputV1(
          explicitMode: 'campaign_spine_v1',
          isCheckpoint: false,
          isDailyRun: false,
          isTablePractice: false,
          startItemIndex: 9,
          resolvedItemCount: 5,
          shouldApplyCheckpointSeed: false,
          campaignSpineModeId: 'campaign_spine_v1',
          reviewQueueModeId: 'review_queue_v1',
          checkpointModeId: 'checkpoint_v1',
          dailyRunModeId: 'daily_v1',
          tablePracticeModeId: 'table_practice_v1',
          defaultModeId: 'foundations_v1',
        ),
      );

      expect(resolved.mode, 'campaign_spine_v1');
      expect(resolved.initialItemIndex, 4);
      expect(resolved.shouldApplyCheckpointSeed, isFalse);
      expect(resolved.shouldBootstrapCampaignState, isTrue);
      expect(resolved.shouldBootstrapIntroPreludes, isTrue);
      expect(resolved.shouldBootstrapReviewQueue, isFalse);
    },
  );

  test(
    'canonical launch state policy resolves review queue and zero start fallback',
    () {
      final resolved = resolveCanonicalLaunchStatePolicyV1(
        const CanonicalLaunchStatePolicyInputV1(
          explicitMode: null,
          isCheckpoint: false,
          isDailyRun: false,
          isTablePractice: false,
          startItemIndex: 3,
          resolvedItemCount: 0,
          shouldApplyCheckpointSeed: true,
          campaignSpineModeId: 'campaign_spine_v1',
          reviewQueueModeId: 'review_queue_v1',
          checkpointModeId: 'checkpoint_v1',
          dailyRunModeId: 'daily_v1',
          tablePracticeModeId: 'table_practice_v1',
          defaultModeId: 'review_queue_v1',
        ),
      );

      expect(resolved.mode, 'review_queue_v1');
      expect(resolved.initialItemIndex, 0);
      expect(resolved.shouldApplyCheckpointSeed, isTrue);
      expect(resolved.shouldBootstrapCampaignState, isFalse);
      expect(resolved.shouldBootstrapIntroPreludes, isFalse);
      expect(resolved.shouldBootstrapReviewQueue, isTrue);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';

void main() {
  const fallbackSteps = <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find BTN.',
      hint: 'Bottom center.',
      expectedSeatIds: <String>['btn'],
    ),
  ];

  test('world1 host-state entry resolves campaign bootstrap and explicit start', () {
    final resolved = resolveWorld1CanonicalHostStateEntryV1(
      const World1CanonicalHostStateEntryInputV1(
        moduleId: 'world1_spine_campaign_v1',
        explicitMode: 'campaign_spine_v1',
        isCheckpoint: false,
        isDailyRun: false,
        isTablePractice: false,
        startHandIndex: 4,
        isGlobalCheckpointPack: false,
        checkpointSteps: <MicroTaskStep>[],
        packSteps: <MicroTaskStep>[
          MicroTaskStep(
            prompt: 'A',
            hint: 'a',
            expectedSeatIds: <String>['btn'],
          ),
          MicroTaskStep(
            prompt: 'B',
            hint: 'b',
            expectedSeatIds: <String>['sb'],
          ),
          MicroTaskStep(
            prompt: 'C',
            hint: 'c',
            expectedSeatIds: <String>['bb'],
          ),
          MicroTaskStep(
            prompt: 'D',
            hint: 'd',
            expectedSeatIds: <String>['hj'],
          ),
          MicroTaskStep(
            prompt: 'E',
            hint: 'e',
            expectedSeatIds: <String>['co'],
          ),
        ],
        fallbackSteps: fallbackSteps,
        campaignSpineModeId: 'campaign_spine_v1',
        reviewQueueModeId: 'review_queue_v1',
        checkpointModeId: 'checkpoint_v1',
        dailyRunModeId: 'daily_v1',
        tablePracticeModeId: 'table_practice_v1',
        defaultModeId: 'foundations_v1',
      ),
    );

    expect(resolved.mode, 'campaign_spine_v1');
    expect(resolved.initialStepIndex, 4);
    expect(resolved.steps.length, 5);
    expect(resolved.shouldBootstrapCampaignState, isTrue);
    expect(resolved.shouldBootstrapIntroPreludes, isTrue);
    expect(resolved.shouldBootstrapReviewQueue, isFalse);
  });

  test('world1 host-state entry falls back and resolves review queue bootstrap', () {
    final resolved = resolveWorld1CanonicalHostStateEntryV1(
      const World1CanonicalHostStateEntryInputV1(
        moduleId: 'world1_review_queue_v1',
        explicitMode: 'review_queue_v1',
        isCheckpoint: false,
        isDailyRun: false,
        isTablePractice: false,
        startHandIndex: null,
        isGlobalCheckpointPack: true,
        checkpointSteps: <MicroTaskStep>[],
        packSteps: <MicroTaskStep>[],
        fallbackSteps: fallbackSteps,
        campaignSpineModeId: 'campaign_spine_v1',
        reviewQueueModeId: 'review_queue_v1',
        checkpointModeId: 'checkpoint_v1',
        dailyRunModeId: 'daily_v1',
        tablePracticeModeId: 'table_practice_v1',
        defaultModeId: 'foundations_v1',
      ),
    );

    expect(resolved.mode, 'review_queue_v1');
    expect(resolved.steps, same(fallbackSteps));
    expect(resolved.initialStepIndex, 0);
    expect(resolved.shouldApplyCheckpointSeed, isTrue);
    expect(resolved.shouldBootstrapCampaignState, isFalse);
    expect(resolved.shouldBootstrapIntroPreludes, isFalse);
    expect(resolved.shouldBootstrapReviewQueue, isTrue);
  });
}

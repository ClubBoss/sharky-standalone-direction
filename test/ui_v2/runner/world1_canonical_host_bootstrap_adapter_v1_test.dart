import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_bootstrap_adapter_v1.dart';

void main() {
  const fallbackSteps = <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find BTN.',
      hint: 'Bottom center.',
      expectedSeatIds: <String>['btn'],
    ),
    MicroTaskStep(
      prompt: 'Find SB.',
      hint: 'Left of BB.',
      expectedSeatIds: <String>['sb'],
    ),
    MicroTaskStep(
      prompt: 'Find BB.',
      hint: 'Right of SB.',
      expectedSeatIds: <String>['bb'],
    ),
  ];

  test(
    'world1 checkpoint bootstrap resolves seeded steps and clamps index',
    () async {
      final resolved = await bootstrapWorld1CheckpointSeedV1(
        steps: fallbackSteps,
        stepIndex: 9,
        checkpointPackId: ProgressService.checkpointPackIdV1,
        checkpointCueMapper: (step) => MicroTaskStep(
          prompt: step.prompt,
          hint: step.hint,
          expectedSeatIds: List<String>.from(step.expectedSeatIds),
          instructionText: 'Checkpoint cue',
        ),
        loadSeedClasses: (_) async => <String>['timing', 'range', 'sizing'],
      );

      expect(resolved, isNotNull);
      expect(resolved!.steps.length, 3);
      expect(resolved.stepIndex, 2);
      expect(resolved.topErrorClasses, <String>['timing', 'range', 'sizing']);
      expect(resolved.stepErrorClasses, <String>['timing', 'range', 'sizing']);
      expect(
        resolved.steps.every(
          (step) => step.instructionText == 'Checkpoint cue',
        ),
        isTrue,
      );
    },
  );

  test(
    'world1 review bootstrap returns sorted queued indices and pop fallback',
    () async {
      final resolved = await bootstrapWorld1ReviewQueueSessionV1(
        packId: 'world1_review_queue_v1',
        stepCount: 5,
        loadReviewQueue: (_) async => const <ReviewRefV1>[
          ReviewRefV1(packId: 'world1_review_queue_v1', stepIndex: 4),
          ReviewRefV1(packId: 'world1_review_queue_v1', stepIndex: 1),
          ReviewRefV1(packId: 'world1_review_queue_v1', stepIndex: 1),
          ReviewRefV1(packId: 'world1_review_queue_v1', stepIndex: 7),
        ],
      );

      expect(resolved.shouldPop, isFalse);
      expect(resolved.queuedStepIndices, <int>[1, 1, 4]);

      final empty = await bootstrapWorld1ReviewQueueSessionV1(
        packId: 'world1_review_queue_v1',
        stepCount: 5,
        loadReviewQueue: (_) async => const <ReviewRefV1>[],
      );
      expect(empty.shouldPop, isTrue);
    },
  );

  test(
    'world1 campaign bootstrap resolves step index and fallback persistence',
    () async {
      final pointer = CampaignSpineBeatPointerV1(
        packId: 'world1_spine_campaign_v1',
        worldId: 1,
        beatIndex: 2,
        totalBeats: 3,
        beat: fallbackSteps[2],
      );
      final runPlan = CampaignSpineRunPlanV1(
        pointer: pointer,
        scenario: const ScenarioReplayerSpec(
          initialSnapshot: ReplayerSnapshot(
            heroStack: 100,
            villainStack: 100,
            pot: 15,
            toCall: 5,
            street: ReplayerStreet.preflop,
            actingSeat: ReplayerSeat.hero,
            minRaiseTo: 10,
          ),
          steps: <ReplayerStep>[
            ReplayerStep(
              actingSeat: ReplayerSeat.hero,
              legalActions: <ReplayerActionSpec>[
                ReplayerActionSpec(kind: ReplayerActionKind.callCheck),
              ],
            ),
          ],
        ),
      );

      final resolved = await bootstrapWorld1CampaignStateV1(
        moduleId: 'world1_spine_campaign_v1',
        stepIndex: 0,
        stepCount: 3,
        shouldBootstrapCampaignProgress: true,
        startRun: () async => runPlan,
        getBankrollBalance: () async => 1200,
        getRank: () async => 5,
        isCalibrationCompleted: () async => true,
        getCalibrationBand: () async => 2,
      );

      expect(resolved.stepIndex, 2);
      expect(resolved.bankroll, 1200);
      expect(resolved.rank, 5);
      expect(resolved.calibrationCompleted, isTrue);
      expect(resolved.calibrationBand, 2);

      String? persistedPackId;
      int? persistedStepIndex;
      final fallbackResolved = await bootstrapWorld1CampaignStateV1(
        moduleId: 'world1_spine_campaign_v1',
        stepIndex: 1,
        stepCount: 3,
        shouldBootstrapCampaignProgress: true,
        startRun: () async => throw Exception('boom'),
        getBankrollBalance: () async => 900,
        getRank: () async => 3,
        isCalibrationCompleted: () async => false,
        getCalibrationBand: () async => null,
        setActivePackId: (packId) async {
          persistedPackId = packId;
        },
        setNextHandIndex: (index) async {
          persistedStepIndex = index;
        },
      );

      expect(persistedPackId, 'world1_spine_campaign_v1');
      expect(persistedStepIndex, 1);
      expect(
        fallbackResolved.calibrationBand,
        ProgressService.spineCalibrationBandIntermediate,
      );
    },
  );
}

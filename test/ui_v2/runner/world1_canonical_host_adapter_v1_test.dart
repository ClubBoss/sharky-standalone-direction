import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  test(
    'world1 canonical host adapter consumes canonical runtime config defaults',
    () {
      final runtimeConfig = resolveCanonicalTerminalWorld1RuntimeConfigV1(
        const CanonicalTerminalWorld1RuntimeConfigInputV1(
          moduleId: 'world1_spine_campaign_v1',
          startHandIndexV1: 3,
          hintsEnabledV1: true,
        ),
      );

      expect(
        runtimeConfig.moduleTitleV1,
        recommendedModuleTitleForId('world1_spine_campaign_v1'),
      );
      expect(runtimeConfig.modeV1, kWorld1RunnerModeCampaignSpine);
      expect(runtimeConfig.startHandIndexV1, 3);
      expect(runtimeConfig.hintsEnabledV1, isTrue);
    },
  );

  test(
    'world1 canonical resolved host launch uses resolved mode and bootstrap flags',
    () {
      final resolved = resolveWorld1CanonicalResolvedHostLaunchV1(
        entryInput: const World1CanonicalHostStateEntryInputV1(
          moduleId: 'world1_spine_campaign_v1',
          explicitMode: null,
          isCheckpoint: false,
          isDailyRun: false,
          isTablePractice: false,
          startHandIndex: 2,
          isGlobalCheckpointPack: false,
          checkpointSteps: <MicroTaskStep>[],
          packSteps: <MicroTaskStep>[
            MicroTaskStep(
              prompt: 'Prompt',
              hint: 'Hint',
              expectedSeatIds: <String>['btn'],
            ),
          ],
          fallbackSteps: <MicroTaskStep>[
            MicroTaskStep(
              prompt: 'Fallback',
              hint: 'Fallback hint',
              expectedSeatIds: <String>['bb'],
            ),
          ],
          campaignSpineModeId: kWorld1RunnerModeCampaignSpine,
          reviewQueueModeId: kWorld1RunnerModeReviewQueue,
          checkpointModeId: kWorld1RunnerModeCheckpoint,
          dailyRunModeId: kWorld1RunnerModeDailyRun,
          tablePracticeModeId: kWorld1RunnerModeTablePractice,
          defaultModeId: kWorld1RunnerModeFoundationsCheck,
        ),
        learningEffectSliceMarker: 'world1_spine_campaign_v1::campaign',
      );

      expect(resolved.mode, kWorld1RunnerModeFoundationsCheck);
      expect(
        resolved.learningEffectSliceMarker,
        'world1_spine_campaign_v1::campaign',
      );
      expect(resolved.steps.single.prompt, 'Prompt');
      expect(resolved.initialStepIndex, 0);
      expect(resolved.shouldApplyCheckpointSeed, isFalse);
      expect(resolved.shouldBootstrapCampaignState, isFalse);
      expect(resolved.shouldBootstrapIntroPreludes, isFalse);
      expect(resolved.shouldBootstrapReviewQueue, isFalse);
    },
  );

  test(
    'world1 canonical host session identity tracks session reset inputs',
    () {
      final first = resolveWorld1CanonicalHostSessionIdentityV1(
        'world1_spine_campaign_v1',
        checkpointId: null,
        startHandIndex: 0,
      );
      final second = resolveWorld1CanonicalHostSessionIdentityV1(
        'world1_spine_campaign_v1',
        checkpointId: null,
        startHandIndex: 2,
      );

      expect(first, 'world1_spine_campaign_v1::none::0');
      expect(second, 'world1_spine_campaign_v1::none::2');
      expect(second, isNot(first));
    },
  );
}

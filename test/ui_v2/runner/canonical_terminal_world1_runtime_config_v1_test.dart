import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_signal_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_shell_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

class _FakeRunnerInstructionSourceV1 implements RunnerInstructionSourceV1 {
  const _FakeRunnerInstructionSourceV1();

  @override
  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  }) {
    return fallback;
  }

  @override
  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  }) {
    return fallback;
  }

  @override
  RunnerInstructionContentV1? getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  }) {
    return fallback;
  }
}

void main() {
  test('world1 runtime config resolves canonical defaults in one place', () {
    final runtimeConfig = resolveCanonicalTerminalWorld1RuntimeConfigV1(
      const CanonicalTerminalWorld1RuntimeConfigInputV1(
        moduleId: 'world1_spine_campaign_v1',
      ),
    );

    expect(
      runtimeConfig.moduleTitleV1,
      recommendedModuleTitleForId('world1_spine_campaign_v1'),
    );
    expect(runtimeConfig.modeV1, kWorld1RunnerModeCampaignSpine);
    expect(runtimeConfig.startHandIndexV1, 0);
    expect(runtimeConfig.checkpointIdV1, isNull);
    expect(runtimeConfig.hintsEnabledV1, isTrue);
    expect(runtimeConfig.instructionSourceV1, isNull);
  });

  test('world1 terminal launches preserve the shared runtime config', () {
    const instructionSource = _FakeRunnerInstructionSourceV1();
    final resolved = CanonicalTerminalResolvedHostLaunchV1.world1Microtask(
      moduleId: 'world1_spine_campaign_v1',
      hostShellControllerV1: World1CanonicalHostShellControllerV1(
        createCanonicalInitialLaunchBoundaryShellSignalV1(
          sessionIdentity: 'world1::campaign',
        ),
      ),
      resolvedHostLaunchV1: const World1CanonicalResolvedHostLaunchV1(
        mode: kWorld1RunnerModeCampaignSpine,
        learningEffectSliceMarker: 'world1_spine_campaign_v1::campaign',
        steps: <MicroTaskStep>[],
        initialStepIndex: 0,
        shouldApplyCheckpointSeed: false,
        shouldBootstrapCampaignState: false,
        shouldBootstrapIntroPreludes: false,
        shouldBootstrapReviewQueue: false,
      ),
      runtimeConfigV1: const CanonicalTerminalWorld1RuntimeConfigV1(
        moduleTitleV1: 'Campaign Spine',
        modeV1: kWorld1RunnerModeCampaignSpine,
        startHandIndexV1: 3,
        checkpointIdV1: 7,
        hintsEnabledV1: false,
        instructionSourceV1: instructionSource,
      ),
    );

    final payload = resolved.world1MicrotaskPayloadV1;
    expect(payload.moduleTitle, 'Campaign Spine');
    expect(payload.mode, kWorld1RunnerModeCampaignSpine);
    expect(payload.startHandIndex, 3);
    expect(payload.checkpointId, 7);
    expect(payload.hintsEnabledV1, isFalse);
    expect(payload.instructionSourceV1, same(instructionSource));
  });

  test(
    'session-drill surfaced launches preserve the shared world1 runtime config',
    () {
      const instructionSource = _FakeRunnerInstructionSourceV1();
      final resolved =
          CanonicalTerminalResolvedHostLaunchV1.sessionDrillSurfaced(
            sessionId: 'w2.s07',
            debugDrillsOverrideV1: null,
            handoffContextV1: null,
            runtimeConfigV1: const CanonicalTerminalWorld1RuntimeConfigV1(
              moduleTitleV1: 'Hand Chain',
              modeV1: kWorld1RunnerModeReviewQueue,
              startHandIndexV1: 2,
              checkpointIdV1: 5,
              hintsEnabledV1: false,
              instructionSourceV1: instructionSource,
            ),
          );

      final payload = resolved.sessionDrillSurfacedPayloadV1;
      expect(payload.world1ModuleTitleV1, 'Hand Chain');
      expect(payload.world1ModeV1, kWorld1RunnerModeReviewQueue);
      expect(payload.world1StartHandIndexV1, 2);
      expect(payload.world1CheckpointIdV1, 5);
      expect(payload.world1HintsEnabledV1, isFalse);
      expect(payload.world1InstructionSourceV1, same(instructionSource));
    },
  );
}

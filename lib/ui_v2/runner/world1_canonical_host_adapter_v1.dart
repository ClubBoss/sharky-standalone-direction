import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_signal_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_shell_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_screen.dart';

class World1CanonicalHostLaunchInputV1 {
  const World1CanonicalHostLaunchInputV1({
    required this.moduleId,
    required this.world1ModuleTitle,
    required this.world1Mode,
    required this.world1StartHandIndex,
    required this.world1CheckpointId,
    required this.world1HintsEnabled,
    required this.world1InstructionSource,
  });

  final String moduleId;
  final String? world1ModuleTitle;
  final String? world1Mode;
  final int? world1StartHandIndex;
  final int? world1CheckpointId;
  final bool? world1HintsEnabled;
  final RunnerInstructionSourceV1? world1InstructionSource;
}

String resolveWorld1CanonicalHostSessionIdentityV1(
  String moduleId, {
  required int? checkpointId,
  required int startHandIndex,
}) {
  return '$moduleId::${checkpointId ?? 'none'}::$startHandIndex';
}

class World1CanonicalHostAdapterV1 extends StatefulWidget {
  const World1CanonicalHostAdapterV1({super.key, required this.input});

  final World1CanonicalHostLaunchInputV1 input;

  @override
  State<World1CanonicalHostAdapterV1> createState() =>
      _World1CanonicalHostAdapterV1State();
}

class _World1CanonicalHostAdapterV1State
    extends State<World1CanonicalHostAdapterV1> {
  late CanonicalTerminalWorld1RuntimeConfigV1 _runtimeConfigV1;
  late World1CanonicalResolvedHostLaunchV1 _resolvedHostLaunchV1;
  late World1CanonicalHostShellControllerV1 _hostShellControllerV1;
  late String _sessionIdentityV1;

  static const List<MicroTaskStep> _fallbackStepsV1 = <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button seat.',
      hint: 'Dealer button is bottom center.',
      expectedSeatIds: <String>['btn'],
    ),
    MicroTaskStep(
      prompt: 'Find the Big Blind seat.',
      hint: 'Tap the right-lower blind seat.',
      expectedSeatIds: <String>['bb'],
    ),
    MicroTaskStep(
      prompt: 'Skip empty seats and tap Hijack.',
      hint: 'Ignore empty UTG and continue to Hijack.',
      expectedSeatIds: <String>['hj'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _applyResolvedHostLaunchV1();
    _sessionIdentityV1 = resolveWorld1CanonicalHostSessionIdentityV1(
      widget.input.moduleId,
      checkpointId: _runtimeConfigV1.checkpointIdV1,
      startHandIndex: _runtimeConfigV1.startHandIndexV1,
    );
    _hostShellControllerV1 = World1CanonicalHostShellControllerV1(
      createCanonicalInitialLaunchBoundaryShellSignalV1(
        sessionIdentity: _sessionIdentityV1,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant World1CanonicalHostAdapterV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameLaunchInputV1(oldWidget.input, widget.input)) {
      _applyResolvedHostLaunchV1();
      final nextSessionIdentityV1 = resolveWorld1CanonicalHostSessionIdentityV1(
        widget.input.moduleId,
        checkpointId: _runtimeConfigV1.checkpointIdV1,
        startHandIndex: _runtimeConfigV1.startHandIndexV1,
      );
      if (nextSessionIdentityV1 != _sessionIdentityV1) {
        _sessionIdentityV1 = nextSessionIdentityV1;
        _hostShellControllerV1.value =
            createCanonicalResetLaunchBoundaryShellSignalV1(
              current: _hostShellControllerV1.value,
              sessionIdentity: _sessionIdentityV1,
            );
      }
    }
  }

  bool _sameLaunchInputV1(
    World1CanonicalHostLaunchInputV1 a,
    World1CanonicalHostLaunchInputV1 b,
  ) {
    return a.moduleId == b.moduleId &&
        a.world1ModuleTitle == b.world1ModuleTitle &&
        a.world1Mode == b.world1Mode &&
        a.world1StartHandIndex == b.world1StartHandIndex &&
        a.world1CheckpointId == b.world1CheckpointId &&
        a.world1HintsEnabled == b.world1HintsEnabled &&
        a.world1InstructionSource == b.world1InstructionSource;
  }

  void _applyResolvedHostLaunchV1() {
    _runtimeConfigV1 = resolveCanonicalTerminalWorld1RuntimeConfigV1(
      CanonicalTerminalWorld1RuntimeConfigInputV1(
        moduleId: widget.input.moduleId,
        moduleTitleV1: widget.input.world1ModuleTitle,
        modeV1: widget.input.world1Mode,
        startHandIndexV1: widget.input.world1StartHandIndex,
        checkpointIdV1: widget.input.world1CheckpointId,
        hintsEnabledV1: widget.input.world1HintsEnabled,
        instructionSourceV1: widget.input.world1InstructionSource,
      ),
    );
    _resolvedHostLaunchV1 = resolveWorld1CanonicalResolvedHostLaunchV1(
      entryInput: World1CanonicalHostStateEntryInputV1(
        moduleId: widget.input.moduleId,
        explicitMode: _runtimeConfigV1.modeV1,
        isCheckpoint: _runtimeConfigV1.checkpointIdV1 != null,
        isDailyRun: _runtimeConfigV1.modeV1 == kWorld1RunnerModeDailyRun,
        isTablePractice:
            _runtimeConfigV1.modeV1 == kWorld1RunnerModeTablePractice,
        startHandIndex: _runtimeConfigV1.startHandIndexV1,
        isGlobalCheckpointPack:
            widget.input.moduleId == ProgressService.checkpointPackIdV1,
        checkpointSteps: _runtimeConfigV1.checkpointIdV1 == null
            ? const <MicroTaskStep>[]
            : kWorld1CheckpointTaskPacks[_runtimeConfigV1.checkpointIdV1] ??
                  const <MicroTaskStep>[],
        packSteps: _runtimeConfigV1.checkpointIdV1 == null
            ? world1MicroTaskPackFor(widget.input.moduleId)
            : const <MicroTaskStep>[],
        fallbackSteps: _fallbackStepsV1,
        campaignSpineModeId: kWorld1RunnerModeCampaignSpine,
        reviewQueueModeId: kWorld1RunnerModeReviewQueue,
        checkpointModeId: kWorld1RunnerModeCheckpoint,
        dailyRunModeId: kWorld1RunnerModeDailyRun,
        tablePracticeModeId: kWorld1RunnerModeTablePractice,
        defaultModeId: kWorld1RunnerModeFoundationsCheck,
      ),
      learningEffectSliceMarker: world1LearningEffectSliceMarkerV1(
        moduleId: widget.input.moduleId,
        mode: _runtimeConfigV1.modeV1!,
      ),
    );
  }

  @override
  void dispose() {
    _hostShellControllerV1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CanonicalLaunchBoundaryRunnerSurfaceV1(
      resolvedHostLaunchV1: CanonicalLaunchBoundaryResolvedHostLaunchV1(
        sessionIdentity: _sessionIdentityV1,
        hostShellControllerV1: _hostShellControllerV1,
        terminalResolvedHostLaunchV1:
            CanonicalTerminalResolvedHostLaunchV1.world1Microtask(
              moduleId: widget.input.moduleId,
              hostShellControllerV1: _hostShellControllerV1,
              resolvedHostLaunchV1: _resolvedHostLaunchV1,
              runtimeConfigV1: _runtimeConfigV1,
            ),
      ),
    );
  }
}

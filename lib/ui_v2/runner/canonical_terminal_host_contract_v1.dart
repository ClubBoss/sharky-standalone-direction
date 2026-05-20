import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_shell_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_screen.dart';

enum CanonicalTerminalFamilyV1 {
  world1Microtask,
  sessionDrillSurfaced,
  legacyDrill,
  phase1,
  phase2,
  phase3,
}

abstract class CanonicalTerminalFamilyPayloadV1 {
  const CanonicalTerminalFamilyPayloadV1();

  CanonicalTerminalFamilyV1 get family;
}

class CanonicalTerminalWorld1RuntimeConfigInputV1 {
  const CanonicalTerminalWorld1RuntimeConfigInputV1({
    required this.moduleId,
    this.moduleTitleV1,
    this.modeV1,
    this.startHandIndexV1,
    this.checkpointIdV1,
    this.hintsEnabledV1,
    this.instructionSourceV1,
  });

  final String moduleId;
  final String? moduleTitleV1;
  final String? modeV1;
  final int? startHandIndexV1;
  final int? checkpointIdV1;
  final bool? hintsEnabledV1;
  final RunnerInstructionSourceV1? instructionSourceV1;
}

class CanonicalTerminalWorld1RuntimeConfigV1 {
  const CanonicalTerminalWorld1RuntimeConfigV1({
    this.moduleTitleV1,
    this.modeV1,
    this.startHandIndexV1 = 0,
    this.checkpointIdV1,
    this.hintsEnabledV1 = true,
    this.instructionSourceV1,
  });

  final String? moduleTitleV1;
  final String? modeV1;
  final int startHandIndexV1;
  final int? checkpointIdV1;
  final bool hintsEnabledV1;
  final RunnerInstructionSourceV1? instructionSourceV1;
}

CanonicalTerminalWorld1RuntimeConfigV1
resolveCanonicalTerminalWorld1RuntimeConfigV1(
  CanonicalTerminalWorld1RuntimeConfigInputV1 input,
) {
  return CanonicalTerminalWorld1RuntimeConfigV1(
    moduleTitleV1:
        input.moduleTitleV1 ?? recommendedModuleTitleForId(input.moduleId),
    modeV1: input.modeV1 ?? kWorld1RunnerModeCampaignSpine,
    startHandIndexV1: input.startHandIndexV1 ?? 0,
    checkpointIdV1: input.checkpointIdV1,
    hintsEnabledV1: input.hintsEnabledV1 ?? true,
    instructionSourceV1: input.instructionSourceV1,
  );
}

class CanonicalTerminalPhaseRuntimeConfigV1 {
  const CanonicalTerminalPhaseRuntimeConfigV1({
    required this.runIdV1,
    this.sessionStartLoggedV1 = false,
  });

  final String runIdV1;
  final bool sessionStartLoggedV1;
}

class CanonicalTerminalLegacyDrillRuntimeConfigV1 {
  const CanonicalTerminalLegacyDrillRuntimeConfigV1({
    required this.moduleIdV1,
    required this.resolvedItemsV1,
  });

  final String moduleIdV1;
  final List<Map<String, dynamic>> resolvedItemsV1;
}

class CanonicalTerminalWorld1MicrotaskPayloadV1
    extends CanonicalTerminalFamilyPayloadV1 {
  const CanonicalTerminalWorld1MicrotaskPayloadV1({
    required this.moduleId,
    required this.hostShellControllerV1,
    required this.resolvedHostLaunchV1,
    required this.runtimeConfigV1,
  });

  final String moduleId;
  final World1CanonicalHostShellControllerV1 hostShellControllerV1;
  final World1CanonicalResolvedHostLaunchV1 resolvedHostLaunchV1;
  final CanonicalTerminalWorld1RuntimeConfigV1 runtimeConfigV1;

  String get moduleTitle => runtimeConfigV1.moduleTitleV1!;
  String get mode => runtimeConfigV1.modeV1!;
  int get startHandIndex => runtimeConfigV1.startHandIndexV1;
  int? get checkpointId => runtimeConfigV1.checkpointIdV1;
  bool get hintsEnabledV1 => runtimeConfigV1.hintsEnabledV1;
  RunnerInstructionSourceV1? get instructionSourceV1 =>
      runtimeConfigV1.instructionSourceV1;

  @override
  CanonicalTerminalFamilyV1 get family =>
      CanonicalTerminalFamilyV1.world1Microtask;
}

class CanonicalTerminalResolvedHostLaunchV1 {
  const CanonicalTerminalResolvedHostLaunchV1({
    required this.family,
    required this.payload,
  });

  factory CanonicalTerminalResolvedHostLaunchV1.world1Microtask({
    required String moduleId,
    required World1CanonicalHostShellControllerV1 hostShellControllerV1,
    required World1CanonicalResolvedHostLaunchV1 resolvedHostLaunchV1,
    required CanonicalTerminalWorld1RuntimeConfigV1 runtimeConfigV1,
  }) {
    return CanonicalTerminalResolvedHostLaunchV1(
      family: CanonicalTerminalFamilyV1.world1Microtask,
      payload: CanonicalTerminalWorld1MicrotaskPayloadV1(
        moduleId: moduleId,
        hostShellControllerV1: hostShellControllerV1,
        resolvedHostLaunchV1: resolvedHostLaunchV1,
        runtimeConfigV1: runtimeConfigV1,
      ),
    );
  }

  factory CanonicalTerminalResolvedHostLaunchV1.sessionDrillSurfaced({
    required String sessionId,
    required List<SessionDrillItemV1>? debugDrillsOverrideV1,
    required ProgressionHandoffContextV1? handoffContextV1,
    required CanonicalTerminalWorld1RuntimeConfigV1 runtimeConfigV1,
  }) {
    return CanonicalTerminalResolvedHostLaunchV1(
      family: CanonicalTerminalFamilyV1.sessionDrillSurfaced,
      payload: CanonicalTerminalSessionDrillSurfacedPayloadV1(
        sessionId: sessionId,
        debugDrillsOverrideV1: debugDrillsOverrideV1,
        handoffContextV1: handoffContextV1,
        runtimeConfigV1: runtimeConfigV1,
      ),
    );
  }

  factory CanonicalTerminalResolvedHostLaunchV1.legacyDrill({
    required CanonicalTerminalLegacyDrillRuntimeConfigV1 runtimeConfigV1,
  }) {
    return CanonicalTerminalResolvedHostLaunchV1(
      family: CanonicalTerminalFamilyV1.legacyDrill,
      payload: CanonicalTerminalLegacyDrillPayloadV1(
        runtimeConfigV1: runtimeConfigV1,
      ),
    );
  }

  factory CanonicalTerminalResolvedHostLaunchV1.phase1({
    required CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1,
  }) {
    return CanonicalTerminalResolvedHostLaunchV1(
      family: CanonicalTerminalFamilyV1.phase1,
      payload: CanonicalTerminalPhasePayloadV1(
        family: CanonicalTerminalFamilyV1.phase1,
        runtimeConfigV1: runtimeConfigV1,
      ),
    );
  }

  factory CanonicalTerminalResolvedHostLaunchV1.phase2({
    required CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1,
  }) {
    return CanonicalTerminalResolvedHostLaunchV1(
      family: CanonicalTerminalFamilyV1.phase2,
      payload: CanonicalTerminalPhasePayloadV1(
        family: CanonicalTerminalFamilyV1.phase2,
        runtimeConfigV1: runtimeConfigV1,
      ),
    );
  }

  factory CanonicalTerminalResolvedHostLaunchV1.phase3({
    required CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1,
  }) {
    return CanonicalTerminalResolvedHostLaunchV1(
      family: CanonicalTerminalFamilyV1.phase3,
      payload: CanonicalTerminalPhasePayloadV1(
        family: CanonicalTerminalFamilyV1.phase3,
        runtimeConfigV1: runtimeConfigV1,
      ),
    );
  }

  final CanonicalTerminalFamilyV1 family;
  final CanonicalTerminalFamilyPayloadV1 payload;

  CanonicalTerminalWorld1MicrotaskPayloadV1 get world1MicrotaskPayloadV1 {
    final resolvedPayload = payload;
    if (resolvedPayload is! CanonicalTerminalWorld1MicrotaskPayloadV1) {
      throw StateError(
        'Canonical terminal payload mismatch for family: $family',
      );
    }
    return resolvedPayload;
  }

  CanonicalTerminalSessionDrillSurfacedPayloadV1
  get sessionDrillSurfacedPayloadV1 {
    final resolvedPayload = payload;
    if (resolvedPayload is! CanonicalTerminalSessionDrillSurfacedPayloadV1) {
      throw StateError(
        'Canonical terminal payload mismatch for family: $family',
      );
    }
    return resolvedPayload;
  }

  CanonicalTerminalLegacyDrillPayloadV1 get legacyDrillPayloadV1 {
    final resolvedPayload = payload;
    if (resolvedPayload is! CanonicalTerminalLegacyDrillPayloadV1) {
      throw StateError(
        'Canonical terminal payload mismatch for family: $family',
      );
    }
    return resolvedPayload;
  }

  CanonicalTerminalPhasePayloadV1 get phasePayloadV1 {
    final resolvedPayload = payload;
    if (resolvedPayload is! CanonicalTerminalPhasePayloadV1) {
      throw StateError(
        'Canonical terminal payload mismatch for family: $family',
      );
    }
    return resolvedPayload;
  }
}

class CanonicalTerminalSessionDrillSurfacedPayloadV1
    extends CanonicalTerminalFamilyPayloadV1 {
  const CanonicalTerminalSessionDrillSurfacedPayloadV1({
    required this.sessionId,
    required this.debugDrillsOverrideV1,
    required this.handoffContextV1,
    required this.runtimeConfigV1,
  });

  final String sessionId;
  final List<SessionDrillItemV1>? debugDrillsOverrideV1;
  final ProgressionHandoffContextV1? handoffContextV1;
  final CanonicalTerminalWorld1RuntimeConfigV1 runtimeConfigV1;

  String? get world1ModuleTitleV1 => runtimeConfigV1.moduleTitleV1;
  String? get world1ModeV1 => runtimeConfigV1.modeV1;
  int get world1StartHandIndexV1 => runtimeConfigV1.startHandIndexV1;
  int? get world1CheckpointIdV1 => runtimeConfigV1.checkpointIdV1;
  bool get world1HintsEnabledV1 => runtimeConfigV1.hintsEnabledV1;
  RunnerInstructionSourceV1? get world1InstructionSourceV1 =>
      runtimeConfigV1.instructionSourceV1;

  @override
  CanonicalTerminalFamilyV1 get family =>
      CanonicalTerminalFamilyV1.sessionDrillSurfaced;
}

class CanonicalTerminalLegacyDrillPayloadV1
    extends CanonicalTerminalFamilyPayloadV1 {
  const CanonicalTerminalLegacyDrillPayloadV1({required this.runtimeConfigV1});

  final CanonicalTerminalLegacyDrillRuntimeConfigV1 runtimeConfigV1;

  String get moduleId => runtimeConfigV1.moduleIdV1;
  List<Map<String, dynamic>> get resolvedItemsV1 =>
      runtimeConfigV1.resolvedItemsV1;

  @override
  CanonicalTerminalFamilyV1 get family => CanonicalTerminalFamilyV1.legacyDrill;
}

class CanonicalTerminalPhasePayloadV1 extends CanonicalTerminalFamilyPayloadV1 {
  const CanonicalTerminalPhasePayloadV1({
    required CanonicalTerminalFamilyV1 family,
    required this.runtimeConfigV1,
  }) : _family = family;

  final CanonicalTerminalFamilyV1 _family;
  final CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1;

  @override
  CanonicalTerminalFamilyV1 get family => _family;
}

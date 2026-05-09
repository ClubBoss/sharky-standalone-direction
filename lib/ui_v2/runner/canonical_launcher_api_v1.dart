import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_signal_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase1_canonical_host_launch_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase2_canonical_host_launch_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase3_canonical_host_launch_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

enum CanonicalLauncherFamilyV1 { phase1, phase2, phase3, sessionDrill }

enum CanonicalPracticeLaunchKindV1 {
  world1TablePractice,
  sessionDrill,
  legacyDrill,
}

Route<void> canonicalSessionDrillRouteV1({
  required String sessionId,
  ProgressionHandoffContextV1? handoffContextV1,
  String? world1ModuleTitleV1,
  String? world1ModeV1,
  int world1StartHandIndexV1 = 0,
  int? world1CheckpointIdV1,
  bool world1HintsEnabledV1 = true,
  RunnerInstructionSourceV1? world1InstructionSourceV1,
}) {
  return MaterialPageRoute<void>(
    builder: (_) => CanonicalLauncherV1.sessionDrill(
      sessionId: sessionId,
      handoffContextV1: handoffContextV1,
      world1ModuleTitleV1: world1ModuleTitleV1,
      world1ModeV1: world1ModeV1,
      world1StartHandIndexV1: world1StartHandIndexV1,
      world1CheckpointIdV1: world1CheckpointIdV1,
      world1HintsEnabledV1: world1HintsEnabledV1,
      world1InstructionSourceV1: world1InstructionSourceV1,
    ),
  );
}

Route<T> canonicalWorld1RunnerRouteV1<T>({
  required String moduleId,
  required String moduleTitle,
  String mode = kWorld1RunnerModeCampaignSpine,
  int startHandIndex = 0,
  int? checkpointId,
  bool hintsEnabledV1 = true,
  RunnerInstructionSourceV1? instructionSourceV1,
  ProgressionHandoffContextV1? handoffContextV1,
}) {
  return MaterialPageRoute<T>(
    builder: (_) => CanonicalLauncherV1.sessionDrill(
      sessionId: moduleId,
      handoffContextV1: handoffContextV1,
      world1ModuleTitleV1: moduleTitle,
      world1ModeV1: mode,
      world1StartHandIndexV1: startHandIndex,
      world1CheckpointIdV1: checkpointId,
      world1HintsEnabledV1: hintsEnabledV1,
      world1InstructionSourceV1: instructionSourceV1,
    ),
  );
}

Future<T?> pushCanonicalWorld1RunnerV1<T>(
  BuildContext context, {
  required String moduleId,
  required String moduleTitle,
  String mode = kWorld1RunnerModeCampaignSpine,
  int startHandIndex = 0,
  int? checkpointId,
  bool hintsEnabledV1 = true,
  RunnerInstructionSourceV1? instructionSourceV1,
  ProgressionHandoffContextV1? handoffContextV1,
}) async {
  if (!context.mounted) return null;
  return Navigator.of(context).push<T>(
    canonicalWorld1RunnerRouteV1<T>(
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      mode: mode,
      startHandIndex: startHandIndex,
      checkpointId: checkpointId,
      hintsEnabledV1: hintsEnabledV1,
      instructionSourceV1: instructionSourceV1,
      handoffContextV1: handoffContextV1,
    ),
  );
}

Future<T?> pushReplacementCanonicalWorld1RunnerV1<T, TO>(
  BuildContext context, {
  required String moduleId,
  required String moduleTitle,
  String mode = kWorld1RunnerModeCampaignSpine,
  int startHandIndex = 0,
  int? checkpointId,
  bool hintsEnabledV1 = true,
  RunnerInstructionSourceV1? instructionSourceV1,
  ProgressionHandoffContextV1? handoffContextV1,
}) async {
  if (!context.mounted) return null;
  return Navigator.of(context).pushReplacement<T, TO>(
    canonicalWorld1RunnerRouteV1<T>(
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      mode: mode,
      startHandIndex: startHandIndex,
      checkpointId: checkpointId,
      hintsEnabledV1: hintsEnabledV1,
      instructionSourceV1: instructionSourceV1,
      handoffContextV1: handoffContextV1,
    ),
  );
}

Route<void> canonicalLegacyDrillRouteV1({
  required String moduleId,
  List<Map<String, dynamic>>? debugItemsOverrideV1,
}) {
  return MaterialPageRoute<void>(
    builder: (_) => LegacyDrillCanonicalHostAdapterV1(
      input: LegacyDrillCanonicalHostLaunchInputV1(
        moduleId: moduleId,
        debugItemsOverrideV1: debugItemsOverrideV1,
      ),
    ),
  );
}

Future<CanonicalPracticeLaunchKindV1> resolveCanonicalPracticeLaunchKindV1(
  String moduleId, {
  Future<bool> Function(String moduleId)? hasSessionDrillsOverrideV1,
}) async {
  if (usesWorld1TablePracticeV1(moduleId)) {
    return CanonicalPracticeLaunchKindV1.world1TablePractice;
  }
  final hasSessionDrillsFuture =
      hasSessionDrillsOverrideV1 ??
      const DrillRuntimeAdapterV1().hasSessionDrills;
  try {
    final hasSessionDrills = await hasSessionDrillsFuture(moduleId);
    if (hasSessionDrills) {
      return CanonicalPracticeLaunchKindV1.sessionDrill;
    }
  } on FormatException {
    // Fall through to the surfaced legacy drill host when session-drill
    // manifests are malformed or missing.
  }
  return CanonicalPracticeLaunchKindV1.legacyDrill;
}

Future<void> pushCanonicalPracticeLaunchV1(
  BuildContext context, {
  required String moduleId,
  required String moduleTitle,
  String world1ModeV1 = kWorld1RunnerModeTablePractice,
  RunnerInstructionSourceV1? world1InstructionSourceV1,
  Future<bool> Function(String moduleId)? hasSessionDrillsOverrideV1,
}) async {
  final launchKind = await resolveCanonicalPracticeLaunchKindV1(
    moduleId,
    hasSessionDrillsOverrideV1: hasSessionDrillsOverrideV1,
  );
  if (!context.mounted) return;
  switch (launchKind) {
    case CanonicalPracticeLaunchKindV1.world1TablePractice:
      await Navigator.of(context).push<void>(
        canonicalSessionDrillRouteV1(
          sessionId: moduleId,
          world1ModuleTitleV1: moduleTitle,
          world1ModeV1: world1ModeV1,
          world1InstructionSourceV1: world1InstructionSourceV1,
        ),
      );
      return;
    case CanonicalPracticeLaunchKindV1.sessionDrill:
      await Navigator.of(
        context,
      ).push<void>(canonicalSessionDrillRouteV1(sessionId: moduleId));
      return;
    case CanonicalPracticeLaunchKindV1.legacyDrill:
      await Navigator.of(
        context,
      ).push<void>(canonicalLegacyDrillRouteV1(moduleId: moduleId));
      return;
  }
}

class CanonicalLauncherV1 extends StatefulWidget {
  const CanonicalLauncherV1.phase1({super.key})
    : family = CanonicalLauncherFamilyV1.phase1,
      sessionId = null,
      debugDrillsOverrideV1 = null,
      handoffContextV1 = null,
      world1ModuleTitleV1 = null,
      world1ModeV1 = null,
      world1StartHandIndexV1 = 0,
      world1CheckpointIdV1 = null,
      world1HintsEnabledV1 = true,
      world1InstructionSourceV1 = null;

  const CanonicalLauncherV1.phase2({super.key})
    : family = CanonicalLauncherFamilyV1.phase2,
      sessionId = null,
      debugDrillsOverrideV1 = null,
      handoffContextV1 = null,
      world1ModuleTitleV1 = null,
      world1ModeV1 = null,
      world1StartHandIndexV1 = 0,
      world1CheckpointIdV1 = null,
      world1HintsEnabledV1 = true,
      world1InstructionSourceV1 = null;

  const CanonicalLauncherV1.phase3({super.key})
    : family = CanonicalLauncherFamilyV1.phase3,
      sessionId = null,
      debugDrillsOverrideV1 = null,
      handoffContextV1 = null,
      world1ModuleTitleV1 = null,
      world1ModeV1 = null,
      world1StartHandIndexV1 = 0,
      world1CheckpointIdV1 = null,
      world1HintsEnabledV1 = true,
      world1InstructionSourceV1 = null;

  const CanonicalLauncherV1.sessionDrill({
    super.key,
    required this.sessionId,
    this.debugDrillsOverrideV1,
    this.handoffContextV1,
    this.world1ModuleTitleV1,
    this.world1ModeV1,
    this.world1StartHandIndexV1 = 0,
    this.world1CheckpointIdV1,
    this.world1HintsEnabledV1 = true,
    this.world1InstructionSourceV1,
  }) : family = CanonicalLauncherFamilyV1.sessionDrill;

  final CanonicalLauncherFamilyV1 family;
  final String? sessionId;
  final List<SessionDrillItemV1>? debugDrillsOverrideV1;
  final ProgressionHandoffContextV1? handoffContextV1;
  final String? world1ModuleTitleV1;
  final String? world1ModeV1;
  final int world1StartHandIndexV1;
  final int? world1CheckpointIdV1;
  final bool world1HintsEnabledV1;
  final RunnerInstructionSourceV1? world1InstructionSourceV1;

  @override
  State<CanonicalLauncherV1> createState() => _CanonicalLauncherV1State();
}

class _CanonicalLauncherV1State extends State<CanonicalLauncherV1> {
  late final CanonicalLaunchBoundaryShellControllerV1 _hostShellControllerV1;
  late final String _sessionIdentityV1;
  late final CanonicalTerminalResolvedHostLaunchV1
  _terminalResolvedHostLaunchV1;

  @override
  void initState() {
    super.initState();
    final resolvedHostLaunchV1 = _resolveHostLaunchV1(widget.family);
    _sessionIdentityV1 = resolvedHostLaunchV1.sessionIdentity;
    _terminalResolvedHostLaunchV1 =
        resolvedHostLaunchV1.terminalResolvedHostLaunchV1;
    _hostShellControllerV1 = CanonicalLaunchBoundaryShellControllerV1(
      createCanonicalInitialLaunchBoundaryShellSignalV1(
        sessionIdentity: _sessionIdentityV1,
      ),
    );
  }

  CanonicalLaunchBoundaryResolvedHostLaunchV1 _resolveHostLaunchV1(
    CanonicalLauncherFamilyV1 family,
  ) {
    final now = DateTime.now();
    switch (family) {
      case CanonicalLauncherFamilyV1.phase1:
        final runId = generatePhase1CanonicalRunIdV1(now);
        return CanonicalLaunchBoundaryResolvedHostLaunchV1(
          sessionIdentity: 'phase1::$runId',
          hostShellControllerV1: CanonicalLaunchBoundaryShellControllerV1(
            createCanonicalInitialLaunchBoundaryShellSignalV1(
              sessionIdentity: 'phase1::$runId',
            ),
          ),
          terminalResolvedHostLaunchV1:
              CanonicalTerminalResolvedHostLaunchV1.phase1(
                runtimeConfigV1: CanonicalTerminalPhaseRuntimeConfigV1(
                  runIdV1: runId,
                ),
              ),
        );
      case CanonicalLauncherFamilyV1.phase2:
        final runId = generatePhase2CanonicalRunIdV1(now);
        debugPrint(buildPhase2CanonicalSessionStartPayloadV1(runId, now));
        return CanonicalLaunchBoundaryResolvedHostLaunchV1(
          sessionIdentity: 'phase2::$runId',
          hostShellControllerV1: CanonicalLaunchBoundaryShellControllerV1(
            createCanonicalInitialLaunchBoundaryShellSignalV1(
              sessionIdentity: 'phase2::$runId',
            ),
          ),
          terminalResolvedHostLaunchV1:
              CanonicalTerminalResolvedHostLaunchV1.phase2(
                runtimeConfigV1: CanonicalTerminalPhaseRuntimeConfigV1(
                  runIdV1: runId,
                  sessionStartLoggedV1: true,
                ),
              ),
        );
      case CanonicalLauncherFamilyV1.phase3:
        final runId = generatePhase3CanonicalRunIdV1(now);
        return CanonicalLaunchBoundaryResolvedHostLaunchV1(
          sessionIdentity: 'phase3::$runId',
          hostShellControllerV1: CanonicalLaunchBoundaryShellControllerV1(
            createCanonicalInitialLaunchBoundaryShellSignalV1(
              sessionIdentity: 'phase3::$runId',
            ),
          ),
          terminalResolvedHostLaunchV1:
              CanonicalTerminalResolvedHostLaunchV1.phase3(
                runtimeConfigV1: CanonicalTerminalPhaseRuntimeConfigV1(
                  runIdV1: runId,
                ),
              ),
        );
      case CanonicalLauncherFamilyV1.sessionDrill:
        final sessionId = widget.sessionId!;
        return CanonicalLaunchBoundaryResolvedHostLaunchV1(
          sessionIdentity: 'sessionDrill::$sessionId',
          hostShellControllerV1: CanonicalLaunchBoundaryShellControllerV1(
            createCanonicalInitialLaunchBoundaryShellSignalV1(
              sessionIdentity: 'sessionDrill::$sessionId',
            ),
          ),
          terminalResolvedHostLaunchV1:
              CanonicalTerminalResolvedHostLaunchV1.sessionDrillSurfaced(
                sessionId: sessionId,
                debugDrillsOverrideV1: widget.debugDrillsOverrideV1,
                handoffContextV1: widget.handoffContextV1,
                runtimeConfigV1: CanonicalTerminalWorld1RuntimeConfigV1(
                  moduleTitleV1: widget.world1ModuleTitleV1,
                  modeV1: widget.world1ModeV1,
                  startHandIndexV1: widget.world1StartHandIndexV1,
                  checkpointIdV1: widget.world1CheckpointIdV1,
                  hintsEnabledV1: widget.world1HintsEnabledV1,
                  instructionSourceV1: widget.world1InstructionSourceV1,
                ),
              ),
        );
    }
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
        terminalResolvedHostLaunchV1: _terminalResolvedHostLaunchV1,
      ),
    );
  }
}

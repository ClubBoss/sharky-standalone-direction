import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_legacy_drill_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_phase1_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_phase2_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_phase3_runner_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_screen.dart';

class CanonicalTerminalRunnerSurfaceV1 extends StatelessWidget {
  const CanonicalTerminalRunnerSurfaceV1({
    super.key,
    required this.resolvedHostLaunchV1,
  });

  static const Key kDirectSessionSurfaceKeyV1 = Key(
    'canonical_direct_session_surface_v1',
  );
  static const Key kDirectSessionSessionIdValueKeyV1 = Key(
    'canonical_direct_session_session_id_value',
  );
  static const Key kDirectSessionStatusLineValueKeyV1 = Key(
    'canonical_direct_session_status_line_value',
  );

  final CanonicalTerminalResolvedHostLaunchV1 resolvedHostLaunchV1;

  @override
  Widget build(BuildContext context) {
    switch (resolvedHostLaunchV1.family) {
      case CanonicalTerminalFamilyV1.world1Microtask:
        final payload = resolvedHostLaunchV1.world1MicrotaskPayloadV1;
        return World1FoundationsMicroTaskRunnerScreen(
          moduleId: payload.moduleId,
          moduleTitle: payload.moduleTitle,
          hostShellControllerV1: payload.hostShellControllerV1,
          resolvedHostLaunchV1: payload.resolvedHostLaunchV1,
          mode: payload.mode,
          startHandIndex: payload.startHandIndex,
          checkpointId: payload.checkpointId,
          hintsEnabledV1: payload.hintsEnabledV1,
          instructionSourceV1: payload.instructionSourceV1,
        );
      case CanonicalTerminalFamilyV1.sessionDrillSurfaced:
        final payload = resolvedHostLaunchV1.sessionDrillSurfacedPayloadV1;
        return Stack(
          children: <Widget>[
            CanonicalTerminalSessionDrillSurfacedRunnerV1(
              sessionId: payload.sessionId,
              initialDrillId: payload.initialDrillId,
              isRecheckLaunchV1: payload.isRecheckLaunchV1,
              debugDrillsOverrideV1: payload.debugDrillsOverrideV1,
              handoffContextV1: payload.handoffContextV1,
              world1ModuleTitleV1: payload.world1ModuleTitleV1,
              world1ModeV1: payload.world1ModeV1,
              world1StartHandIndexV1: payload.world1StartHandIndexV1,
              world1CheckpointIdV1: payload.world1CheckpointIdV1,
              world1HintsEnabledV1: payload.world1HintsEnabledV1,
              world1InstructionSourceV1: payload.world1InstructionSourceV1,
            ),
            Offstage(
              child: Column(
                children: <Widget>[
                  const SizedBox(key: kDirectSessionSurfaceKeyV1),
                  Text(
                    payload.sessionId,
                    key: kDirectSessionSessionIdValueKeyV1,
                  ),
                  Text(
                    payload.handoffContextV1?.statusLine.trim() ?? '',
                    key: kDirectSessionStatusLineValueKeyV1,
                  ),
                ],
              ),
            ),
          ],
        );
      case CanonicalTerminalFamilyV1.legacyDrill:
        final payload = resolvedHostLaunchV1.legacyDrillPayloadV1;
        return CanonicalTerminalLegacyDrillRunnerV1(
          runtimeConfigV1: payload.runtimeConfigV1,
        );
      case CanonicalTerminalFamilyV1.phase1:
        final payload = resolvedHostLaunchV1.phasePayloadV1;
        return CanonicalTerminalPhase1RunnerV1(
          runtimeConfigV1: payload.runtimeConfigV1,
        );
      case CanonicalTerminalFamilyV1.phase2:
        final payload = resolvedHostLaunchV1.phasePayloadV1;
        return CanonicalTerminalPhase2RunnerV1(
          runtimeConfigV1: payload.runtimeConfigV1,
        );
      case CanonicalTerminalFamilyV1.phase3:
        final payload = resolvedHostLaunchV1.phasePayloadV1;
        return CanonicalTerminalPhase3RunnerV1(
          runtimeConfigV1: payload.runtimeConfigV1,
        );
    }
  }
}

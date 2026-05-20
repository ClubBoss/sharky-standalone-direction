import 'package:flutter/material.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart';

class SessionDrillPlayerV1Screen extends StatelessWidget {
  const SessionDrillPlayerV1Screen({
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
  });

  final String sessionId;
  final List<SessionDrillItemV1>? debugDrillsOverrideV1;
  final ProgressionHandoffContextV1? handoffContextV1;
  final String? world1ModuleTitleV1;
  final String? world1ModeV1;
  final int world1StartHandIndexV1;
  final int? world1CheckpointIdV1;
  final bool world1HintsEnabledV1;
  final RunnerInstructionSourceV1? world1InstructionSourceV1;

  static Route<void> route({
    required String sessionId,
    ProgressionHandoffContextV1? handoffContextV1,
    String? world1ModuleTitleV1,
    String? world1ModeV1,
    int world1StartHandIndexV1 = 0,
    int? world1CheckpointIdV1,
    bool world1HintsEnabledV1 = true,
    RunnerInstructionSourceV1? world1InstructionSourceV1,
  }) {
    return canonicalSessionDrillRouteV1(
      sessionId: sessionId,
      handoffContextV1: handoffContextV1,
      world1ModuleTitleV1: world1ModuleTitleV1,
      world1ModeV1: world1ModeV1,
      world1StartHandIndexV1: world1StartHandIndexV1,
      world1CheckpointIdV1: world1CheckpointIdV1,
      world1HintsEnabledV1: world1HintsEnabledV1,
      world1InstructionSourceV1: world1InstructionSourceV1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CanonicalTerminalSessionDrillSurfacedRunnerV1(
      sessionId: sessionId,
      debugDrillsOverrideV1: debugDrillsOverrideV1,
      handoffContextV1: handoffContextV1,
      world1ModuleTitleV1: world1ModuleTitleV1,
      world1ModeV1: world1ModeV1,
      world1StartHandIndexV1: world1StartHandIndexV1,
      world1CheckpointIdV1: world1CheckpointIdV1,
      world1HintsEnabledV1: world1HintsEnabledV1,
      world1InstructionSourceV1: world1InstructionSourceV1,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_module_theory_host_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Route<void> moduleTheoryHostRouteV1({
  required String moduleId,
  required String moduleTitle,
  ProgressionHandoffContextV1? handoffContextV1,
}) {
  return canonicalModuleTheoryHostRouteV1(
    moduleId: moduleId,
    moduleTitle: moduleTitle,
    handoffContextV1: handoffContextV1,
  );
}

Future<void> navigateToTheorySession(
  BuildContext context,
  String moduleId, {
  String? moduleTitle,
  ProgressionHandoffContextV1? handoffContextV1,
}) async {
  await pushReplacementCanonicalModuleTheoryHostV1(
    context,
    moduleId,
    moduleTitle: moduleTitle,
    handoffContextV1: handoffContextV1,
  );
}

Future<void> startDemoSpine(BuildContext context) async {
  if (!kDebugMode || kTableFirstDemoSpine.isEmpty) return;
  await navigateToTheorySession(context, kTableFirstDemoSpine.first);
}

Route<T> world1FoundationsRunnerRouteV1<T>({
  required String moduleId,
  required String moduleTitle,
  String mode = kWorld1RunnerModeCampaignSpine,
  int startHandIndex = 0,
  int? checkpointId,
  bool hintsEnabledV1 = true,
  RunnerInstructionSourceV1? instructionSourceV1,
  ProgressionHandoffContextV1? handoffContextV1,
}) {
  return canonicalWorld1RunnerRouteV1<T>(
    moduleId: moduleId,
    moduleTitle: moduleTitle,
    mode: mode,
    startHandIndex: startHandIndex,
    checkpointId: checkpointId,
    hintsEnabledV1: hintsEnabledV1,
    instructionSourceV1: instructionSourceV1,
    handoffContextV1: handoffContextV1,
  );
}

Future<T?> pushWorld1FoundationsRunnerV1<T>(
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
  return pushCanonicalWorld1RunnerV1<T>(
    context,
    moduleId: moduleId,
    moduleTitle: moduleTitle,
    mode: mode,
    startHandIndex: startHandIndex,
    checkpointId: checkpointId,
    hintsEnabledV1: hintsEnabledV1,
    instructionSourceV1: instructionSourceV1,
    handoffContextV1: handoffContextV1,
  );
}

Future<T?> pushReplacementWorld1FoundationsRunnerV1<T, TO>(
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
  return pushReplacementCanonicalWorld1RunnerV1<T, TO>(
    context,
    moduleId: moduleId,
    moduleTitle: moduleTitle,
    mode: mode,
    startHandIndex: startHandIndex,
    checkpointId: checkpointId,
    hintsEnabledV1: hintsEnabledV1,
    instructionSourceV1: instructionSourceV1,
    handoffContextV1: handoffContextV1,
  );
}

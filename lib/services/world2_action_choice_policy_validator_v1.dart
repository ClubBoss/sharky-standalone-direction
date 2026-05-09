import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

const Set<String> kWorld2ActionChoicePolicyIntentsV1 = <String>{
  'draw_price_continue',
  'draw_price_release',
  'draw_pressure_assertive',
  'position_btn_vs_early',
  'position_ip_advantage',
  'position_oop_pain',
  'texture_pressure_building',
  'world2_authored_bridge',
};

const Set<String> kWorld2ActionChoicePolicyActionsV1 = <String>{
  'call',
  'fold',
  'raise',
};

const Map<String, Set<String>> kWorld2ActionChoicePolicyAcceptableShapesV1 =
    <String, Set<String>>{
      'call': <String>{'call', 'call|fold'},
      'fold': <String>{'fold'},
      'raise': <String>{'raise', 'call|raise'},
    };

class World2ActionChoicePolicyValidationReportV1 {
  const World2ActionChoicePolicyValidationReportV1({
    required this.familySources,
    required this.checkedCount,
    required this.excludedCount,
    required this.checkedSources,
    required this.excludedSources,
    required this.excludedReasons,
    required this.issues,
  });

  final List<String> familySources;
  final int checkedCount;
  final int excludedCount;
  final List<String> checkedSources;
  final List<String> excludedSources;
  final Map<String, String> excludedReasons;
  final List<String> issues;
}

bool _isSupportedWorld2ActionChoicePolicyChainStepV1(DrillChainStepV1 step) {
  final expectedAction = step.expectedActionV1;
  final availableActions = step.availableActionsV1;
  final intent = step.intentV1;
  if (expectedAction == null ||
      availableActions == null ||
      intent == null ||
      !kWorld2ActionChoicePolicyActionsV1.contains(expectedAction)) {
    return false;
  }
  if (availableActions.length != 2 ||
      availableActions.toSet().length != 2 ||
      !availableActions.every(kWorld2ActionChoicePolicyActionsV1.contains)) {
    return false;
  }
  return true;
}

List<String> _validateWorld2ActionChoicePolicyFieldsV1({
  required String? expectedAction,
  required List<String>? acceptableActions,
  required String? intent,
  required String source,
  required String expectedFieldLabel,
}) {
  final issues = <String>[];
  if (expectedAction == null ||
      !kWorld2ActionChoicePolicyActionsV1.contains(expectedAction)) {
    issues.add(
      '$source: $expectedFieldLabel must be one of call|fold|raise for World 2 action_choice policy v1',
    );
    return issues;
  }

  if (acceptableActions != null) {
    if (!acceptableActions.contains(expectedAction)) {
      issues.add(
        '$source: acceptable_actions must include $expectedFieldLabel $expectedAction when present',
      );
    }
    final acceptableShape = acceptableActions.join('|');
    final allowedShapes =
        kWorld2ActionChoicePolicyAcceptableShapesV1[expectedAction]!;
    if (!allowedShapes.contains(acceptableShape)) {
      issues.add(
        '$source: acceptable_actions ${acceptableActions.join("/")} contradict $expectedFieldLabel $expectedAction for World 2 action_choice policy v1',
      );
    }
  }

  if (intent == null || !kWorld2ActionChoicePolicyIntentsV1.contains(intent)) {
    issues.add(
      '$source: intent_v1 must stay within the World 2 action_choice policy buckets ${kWorld2ActionChoicePolicyIntentsV1.toList()..sort()}',
    );
  }
  return issues;
}

List<String> validateWorld2ActionChoicePolicySpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (spec.kind != DrillKindV1.actionChoice) {
    return const <String>[];
  }
  return _validateWorld2ActionChoicePolicyFieldsV1(
    expectedAction: spec.expected.actionId,
    acceptableActions: spec.acceptableActions,
    intent: spec.intentV1,
    source: source,
    expectedFieldLabel: 'expected.actionId',
  );
}

List<String> validateWorld2ActionChoicePolicyChainStepV1({
  required DrillChainStepV1 step,
  required String source,
}) {
  if (!_isSupportedWorld2ActionChoicePolicyChainStepV1(step)) {
    return const <String>[];
  }
  return _validateWorld2ActionChoicePolicyFieldsV1(
    expectedAction: step.expectedActionV1,
    acceptableActions: step.acceptableActions,
    intent: step.intentV1,
    source: source,
    expectedFieldLabel: 'expected_action',
  );
}

World2ActionChoicePolicyValidationReportV1
validateWorld2ActionChoicePolicyDirectoryV1(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 action_choice policy validator root not found: $rootPath',
    );
  }

  final issues = <String>[];
  final familySources = <String>[];
  final checkedSources = <String>[];
  final excludedSources = <String>[];
  final excludedReasons = <String, String>{};
  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final spec = DrillSpecV1.fromJsonString(file.readAsStringSync());
    if (spec.kind == DrillKindV1.actionChoice) {
      familySources.add(file.path);
      checkedSources.add(file.path);
      issues.addAll(
        validateWorld2ActionChoicePolicySpecV1(spec: spec, source: file.path),
      );
      continue;
    }
    if (spec.kind != DrillKindV1.handChain || spec.chainStepsV1 == null) {
      continue;
    }
    for (var i = 0; i < spec.chainStepsV1!.length; i++) {
      final step = spec.chainStepsV1![i];
      if (!_isSupportedWorld2ActionChoicePolicyChainStepV1(step)) {
        continue;
      }
      final source = '${file.path}#step${i + 1}';
      familySources.add(source);
      checkedSources.add(source);
      issues.addAll(
        validateWorld2ActionChoicePolicyChainStepV1(step: step, source: source),
      );
    }
  }

  return World2ActionChoicePolicyValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedSources.length,
    excludedCount: excludedSources.length,
    checkedSources: List<String>.unmodifiable(checkedSources),
    excludedSources: List<String>.unmodifiable(excludedSources),
    excludedReasons: Map<String, String>.unmodifiable(excludedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

const String kWorld2InitiativePressurePolicyShapeV1 = 'pressure_owner';
const Set<String> kWorld2InitiativePressurePolicyOwnersV1 = <String>{
  'hero',
  'villain',
};

class World2InitiativePressurePolicyValidationReportV1 {
  const World2InitiativePressurePolicyValidationReportV1({
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

List<String> validateWorld2InitiativePressurePolicySpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2InitiativePressurePolicySpecV1(spec)) {
    return const <String>[];
  }

  final issues = <String>[];
  final pressureOwner = spec.pressureOwnerV1!;
  final expectedAction = spec.expected.actionId!;

  if (expectedAction != pressureOwner) {
    issues.add(
      '$source: expected.actionId $expectedAction contradicts pressure_owner_v1 $pressureOwner',
    );
  }

  final availableActions = spec.availableActionsV1;
  if (availableActions != null && !availableActions.contains(expectedAction)) {
    issues.add(
      '$source: available_actions_v1 must include expected.actionId $expectedAction when present',
    );
  }

  if (spec.whyV1 == null || spec.whyV1!.trim().isEmpty) {
    issues.add(
      '$source: why_v1 must be present for World 2 initiative pressure policy v1',
    );
  }

  final combinedText = [
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
    if (spec.recapV1 != null) spec.recapV1!,
  ].join(' ');
  issues.addAll(
    _validateInitiativePressureCopyConsistencyV1(
      source: source,
      pressureOwner: pressureOwner,
      text: combinedText,
    ),
  );

  return issues;
}

World2InitiativePressurePolicyValidationReportV1
validateWorld2InitiativePressurePolicyDirectoryV1(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 initiative pressure policy validator root not found: $rootPath',
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
    if (!_isWorld2InitiativePressurePolicyFamilySourceV1(spec)) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2InitiativePressurePolicySpecV1(spec)) {
      excludedSources.add(file.path);
      excludedReasons[file.path] =
          'excluded: initiative pressure policy v1 requires initiative_policy_shape_v1 pressure_owner with pressure_owner_v1, expected.actionId, and hero/villain pressure owner';
      continue;
    }
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2InitiativePressurePolicySpecV1(
        spec: spec,
        source: file.path,
      ),
    );
  }

  return World2InitiativePressurePolicyValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedSources.length,
    excludedCount: excludedSources.length,
    checkedSources: List<String>.unmodifiable(checkedSources),
    excludedSources: List<String>.unmodifiable(excludedSources),
    excludedReasons: Map<String, String>.unmodifiable(excludedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isWorld2InitiativePressurePolicyFamilySourceV1(DrillSpecV1 spec) {
  return spec.kind == DrillKindV1.initiativeAggressorChoice &&
      spec.initiativePolicyShapeV1 == kWorld2InitiativePressurePolicyShapeV1;
}

bool _isSupportedWorld2InitiativePressurePolicySpecV1(DrillSpecV1 spec) {
  return _isWorld2InitiativePressurePolicyFamilySourceV1(spec) &&
      spec.pressureOwnerV1 != null &&
      spec.expected.actionId != null &&
      kWorld2InitiativePressurePolicyOwnersV1.contains(spec.pressureOwnerV1) &&
      kWorld2InitiativePressurePolicyOwnersV1.contains(spec.expected.actionId);
}

List<String> _validateInitiativePressureCopyConsistencyV1({
  required String source,
  required String pressureOwner,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  if ((RegExp(
            r'\bhero[^.]*\b(more likely to continue pressure|keep the pressure|keeps pressure|continue pressure)\b',
          ).hasMatch(lowerText) ||
          RegExp(
            r'\bpressure[^.]*\bhero\b',
          ).hasMatch(lowerText)) &&
      pressureOwner != 'hero') {
    issues.add(
      '$source: hero pressure copy contradicts pressure_owner_v1 $pressureOwner',
    );
  }
  if ((RegExp(
            r'\bvillain[^.]*\b(more likely to continue pressure|keep the pressure|keeps pressure|continue pressure)\b',
          ).hasMatch(lowerText) ||
          RegExp(
            r'\bpressure[^.]*\bvillain\b',
          ).hasMatch(lowerText)) &&
      pressureOwner != 'villain') {
    issues.add(
      '$source: villain pressure copy contradicts pressure_owner_v1 $pressureOwner',
    );
  }
  return issues;
}

import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

enum World2InitiativeTruthQuestionV1 {
  lastAggressor,
  hasInitiative,
  pressureOwner,
}

class World2InitiativeTruthSnapshotV1 {
  const World2InitiativeTruthSnapshotV1({
    required this.lastAggressor,
    required this.initiativeOwner,
    required this.pressureOwner,
    required this.question,
  });

  final String lastAggressor;
  final String initiativeOwner;
  final String pressureOwner;
  final World2InitiativeTruthQuestionV1 question;
}

class World2InitiativeTruthValidationReportV1 {
  const World2InitiativeTruthValidationReportV1({
    required this.familySources,
    required this.checkedCount,
    required this.skippedCount,
    required this.checkedSources,
    required this.skippedSources,
    required this.skippedReasons,
    required this.issues,
  });

  final List<String> familySources;
  final int checkedCount;
  final int skippedCount;
  final List<String> checkedSources;
  final List<String> skippedSources;
  final Map<String, String> skippedReasons;
  final List<String> issues;
}

World2InitiativeTruthSnapshotV1 deriveWorld2InitiativeTruthV1(
  DrillSpecV1 spec,
) {
  if (!_isSupportedWorld2InitiativeTruthCandidateV1(spec)) {
    throw StateError(
      'World 2 initiative truth requires initiative_aggressor_choice_v1 with last_aggressor_v1, initiative_owner_v1, exactly 2 active seats, and a supported exact initiative question.',
    );
  }
  return World2InitiativeTruthSnapshotV1(
    lastAggressor: spec.lastAggressorV1 ?? spec.pressureOwnerV1!,
    initiativeOwner: spec.initiativeOwnerV1 ?? spec.pressureOwnerV1!,
    pressureOwner: spec.pressureOwnerV1 ?? spec.initiativeOwnerV1!,
    question: _deriveQuestionV1(spec),
  );
}

List<String> validateWorld2InitiativeTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2InitiativeTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2InitiativeTruthV1(spec);
  final issues = <String>[];
  final expectedActor = _expectedActorForQuestionV1(truth);
  if (spec.expected.actionId != expectedActor) {
    issues.add(
      '$source: expected actor ${spec.expected.actionId} contradicts initiative truth $expectedActor',
    );
  }
  if (truth.question != World2InitiativeTruthQuestionV1.pressureOwner &&
      truth.initiativeOwner != truth.lastAggressor) {
    issues.add(
      '$source: initiative_owner_v1 ${truth.initiativeOwner} contradicts last_aggressor_v1 ${truth.lastAggressor} for initiative truth v1',
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
    _validateInitiativeCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

World2InitiativeTruthValidationReportV1
validateWorld2InitiativeTruthDirectoryV1(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 initiative truth validator root not found: $rootPath',
    );
  }
  final issues = <String>[];
  var checkedCount = 0;
  var skippedCount = 0;
  final familySources = <String>[];
  final checkedSources = <String>[];
  final skippedSources = <String>[];
  final skippedReasons = <String, String>{};
  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final raw = file.readAsStringSync();
    final spec = DrillSpecV1.fromJsonString(raw);
    if (spec.kind != DrillKindV1.initiativeAggressorChoice) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2InitiativeTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: initiative truth v1 supports only explicit last-aggressor / initiative-owner question shapes with last_aggressor_v1, initiative_owner_v1, and exactly 2 active_seats_v1';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2InitiativeTruthSpecV1(spec: spec, source: file.path),
    );
  }
  return World2InitiativeTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isSupportedWorld2InitiativeTruthCandidateV1(DrillSpecV1 spec) {
  if (spec.kind != DrillKindV1.initiativeAggressorChoice ||
      spec.streetV1 == null ||
      spec.streetV1 == 'preflop') {
    return false;
  }
  final question = _tryDeriveQuestionV1(spec);
  if (question == null) {
    return false;
  }
  switch (question) {
    case World2InitiativeTruthQuestionV1.lastAggressor:
    case World2InitiativeTruthQuestionV1.hasInitiative:
      return spec.lastAggressorV1 != null &&
          spec.initiativeOwnerV1 != null &&
          spec.activeSeatsV1 != null &&
          spec.activeSeatsV1!.length == 2;
    case World2InitiativeTruthQuestionV1.pressureOwner:
      return spec.pressureOwnerV1 != null &&
          spec.initiativePolicyShapeV1 == 'pressure_owner';
  }
}

List<String> _validateInitiativeCopyConsistencyV1({
  required String source,
  required World2InitiativeTruthSnapshotV1 truth,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  if (RegExp(r'\bhero[^.]*\b(last aggressor)\b').hasMatch(lowerText) &&
      truth.lastAggressor != 'hero') {
    issues.add(
      '$source: hero last-aggressor copy contradicts initiative truth',
    );
  }
  if (RegExp(r'\bvillain[^.]*\b(last aggressor)\b').hasMatch(lowerText) &&
      truth.lastAggressor != 'villain') {
    issues.add(
      '$source: villain last-aggressor copy contradicts initiative truth',
    );
  }
  if ((RegExp(r'\bhero[^.]*\bhas initiative\b').hasMatch(lowerText) ||
          RegExp(r'\bhero[^.]*\bkeeps initiative\b').hasMatch(lowerText)) &&
      truth.initiativeOwner != 'hero') {
    issues.add('$source: hero initiative copy contradicts initiative truth');
  }
  if ((RegExp(r'\bvillain[^.]*\bhas initiative\b').hasMatch(lowerText) ||
          RegExp(r'\bvillain[^.]*\bkeeps initiative\b').hasMatch(lowerText)) &&
      truth.initiativeOwner != 'villain') {
    issues.add('$source: villain initiative copy contradicts initiative truth');
  }
  if ((RegExp(r'\bhero[^.]*\bcontinue pressure\b').hasMatch(lowerText) ||
          RegExp(r'\bhero[^.]*\bkeep pressure\b').hasMatch(lowerText) ||
          RegExp(r'\bhero[^.]*\bapply pressure first\b').hasMatch(lowerText) ||
          RegExp(
            r'\bhero[^.]*\bmore likely to (?:continue|keep) (?:the )?pressure\b',
          ).hasMatch(lowerText)) &&
      truth.pressureOwner != 'hero') {
    issues.add(
      '$source: hero pressure-owner copy contradicts initiative truth',
    );
  }
  if ((RegExp(r'\bvillain[^.]*\bcontinue pressure\b').hasMatch(lowerText) ||
          RegExp(r'\bvillain[^.]*\bkeep pressure\b').hasMatch(lowerText) ||
          RegExp(
            r'\bvillain[^.]*\bapply pressure first\b',
          ).hasMatch(lowerText) ||
          RegExp(
            r'\bvillain[^.]*\bmore likely to (?:continue|keep) (?:the )?pressure\b',
          ).hasMatch(lowerText)) &&
      truth.pressureOwner != 'villain') {
    issues.add(
      '$source: villain pressure-owner copy contradicts initiative truth',
    );
  }
  return issues;
}

String _expectedActorForQuestionV1(World2InitiativeTruthSnapshotV1 truth) {
  switch (truth.question) {
    case World2InitiativeTruthQuestionV1.lastAggressor:
      return truth.lastAggressor;
    case World2InitiativeTruthQuestionV1.hasInitiative:
      return truth.initiativeOwner;
    case World2InitiativeTruthQuestionV1.pressureOwner:
      return truth.pressureOwner;
  }
}

World2InitiativeTruthQuestionV1 _deriveQuestionV1(DrillSpecV1 spec) {
  final question = _tryDeriveQuestionV1(spec);
  if (question == null) {
    throw StateError(
      'Unsupported initiative truth question shape: ${spec.questionShapeV1 ?? spec.prompt}',
    );
  }
  return question;
}

World2InitiativeTruthQuestionV1? _tryDeriveQuestionV1(DrillSpecV1 spec) {
  if (spec.initiativePolicyShapeV1 == 'pressure_owner' &&
      spec.pressureOwnerV1 != null) {
    return World2InitiativeTruthQuestionV1.pressureOwner;
  }
  final lower = spec.prompt.toLowerCase();
  if (lower.contains('who was the last aggressor')) {
    return World2InitiativeTruthQuestionV1.lastAggressor;
  }
  if (lower.contains('who has initiative')) {
    return World2InitiativeTruthQuestionV1.hasInitiative;
  }
  return null;
}

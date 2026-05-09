import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

enum World2PositionTruthQuestionV1 { inPosition, outOfPosition, actsLater }

class World2PositionTruthSnapshotV1 {
  const World2PositionTruthSnapshotV1({
    required this.laterActor,
    required this.earlierActor,
    required this.question,
  });

  final String laterActor;
  final String earlierActor;
  final World2PositionTruthQuestionV1 question;
}

class World2PositionTruthValidationReportV1 {
  const World2PositionTruthValidationReportV1({
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

World2PositionTruthSnapshotV1 deriveWorld2PositionTruthV1(DrillSpecV1 spec) {
  if (!_isSupportedWorld2PositionTruthCandidateV1(spec)) {
    throw StateError(
      'World 2 position truth requires position_thinking_choice_v1 with hero/villain seats, exactly 2 active seats, and a supported position question shape.',
    );
  }
  final heroSeat = spec.heroSeatV1!;
  final villainSeat = spec.villainSeatV1!;
  final heroActsLater =
      _seatOrderValueV1(heroSeat) > _seatOrderValueV1(villainSeat);
  final question = _deriveQuestionV1(spec);
  return World2PositionTruthSnapshotV1(
    laterActor: heroActsLater ? 'hero' : 'villain',
    earlierActor: heroActsLater ? 'villain' : 'hero',
    question: question,
  );
}

List<String> validateWorld2PositionTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2PositionTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2PositionTruthV1(spec);
  final issues = <String>[];
  final expectedActor = _expectedActorForQuestionV1(truth);
  if (spec.expected.actionId != expectedActor) {
    issues.add(
      '$source: expected actor ${spec.expected.actionId} contradicts position truth $expectedActor',
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
    _validatePositionCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

World2PositionTruthValidationReportV1 validateWorld2PositionTruthDirectoryV1(
  String rootPath,
) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 position truth validator root not found: $rootPath',
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
    if (spec.kind != DrillKindV1.positionThinkingChoice) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2PositionTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: position truth validator requires hero_seat_v1, villain_seat_v1, exactly 2 active_seats_v1, and a supported position question shape';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2PositionTruthSpecV1(spec: spec, source: file.path),
    );
  }
  return World2PositionTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isSupportedWorld2PositionTruthCandidateV1(DrillSpecV1 spec) {
  if (spec.kind != DrillKindV1.positionThinkingChoice ||
      spec.heroSeatV1 == null ||
      spec.villainSeatV1 == null ||
      spec.activeSeatsV1 == null ||
      spec.activeSeatsV1!.length != 2 ||
      spec.streetV1 == null) {
    return false;
  }
  final active = spec.activeSeatsV1!.map((seat) => seat.toLowerCase()).toSet();
  if (!active.contains(spec.heroSeatV1!.toLowerCase()) ||
      !active.contains(spec.villainSeatV1!.toLowerCase())) {
    return false;
  }
  final question = _tryDeriveQuestionV1(spec);
  if (question == null) {
    return false;
  }
  if (spec.streetV1 == 'preflop' &&
      question == World2PositionTruthQuestionV1.actsLater) {
    return false;
  }
  return true;
}

List<String> _validatePositionCopyConsistencyV1({
  required String source,
  required World2PositionTruthSnapshotV1 truth,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  if (RegExp(r'\bhero[^.]*\bin position\b').hasMatch(lowerText) &&
      truth.laterActor != 'hero') {
    issues.add('$source: hero in-position copy contradicts position truth');
  }
  if (RegExp(r'\bhero[^.]*\bout of position\b').hasMatch(lowerText) &&
      truth.earlierActor != 'hero') {
    issues.add('$source: hero out-of-position copy contradicts position truth');
  }
  if (RegExp(r'\bhero[^.]*\bacts later\b').hasMatch(lowerText) &&
      truth.laterActor != 'hero') {
    issues.add('$source: hero acts-later copy contradicts position truth');
  }
  if (RegExp(r'\bvillain[^.]*\bin position\b').hasMatch(lowerText) &&
      truth.laterActor != 'villain') {
    issues.add('$source: villain in-position copy contradicts position truth');
  }
  if (RegExp(r'\bvillain[^.]*\bout of position\b').hasMatch(lowerText) &&
      truth.earlierActor != 'villain') {
    issues.add(
      '$source: villain out-of-position copy contradicts position truth',
    );
  }
  if (RegExp(r'\bvillain[^.]*\bacts later\b').hasMatch(lowerText) &&
      truth.laterActor != 'villain') {
    issues.add('$source: villain acts-later copy contradicts position truth');
  }
  return issues;
}

String _expectedActorForQuestionV1(World2PositionTruthSnapshotV1 truth) {
  switch (truth.question) {
    case World2PositionTruthQuestionV1.inPosition:
      return truth.laterActor;
    case World2PositionTruthQuestionV1.outOfPosition:
      return truth.earlierActor;
    case World2PositionTruthQuestionV1.actsLater:
      return truth.laterActor;
  }
}

World2PositionTruthQuestionV1 _deriveQuestionV1(DrillSpecV1 spec) {
  final question = _tryDeriveQuestionV1(spec);
  if (question == null) {
    throw StateError(
      'Unsupported position truth question shape: ${spec.questionShapeV1 ?? spec.prompt}',
    );
  }
  return question;
}

World2PositionTruthQuestionV1? _tryDeriveQuestionV1(DrillSpecV1 spec) {
  switch (spec.questionShapeV1) {
    case 'in_position':
      return World2PositionTruthQuestionV1.inPosition;
    case 'out_of_position':
      return World2PositionTruthQuestionV1.outOfPosition;
    case 'acts_later':
      return World2PositionTruthQuestionV1.actsLater;
  }
  final lower = spec.prompt.toLowerCase();
  if (lower.contains('who is in position')) {
    return World2PositionTruthQuestionV1.inPosition;
  }
  if (lower.contains('who is out of position')) {
    return World2PositionTruthQuestionV1.outOfPosition;
  }
  if (lower.contains('who acts later')) {
    return World2PositionTruthQuestionV1.actsLater;
  }
  return null;
}

int _seatOrderValueV1(String seat) {
  switch (seat.toLowerCase()) {
    case 'sb':
      return 1;
    case 'bb':
      return 2;
    case 'utg':
      return 3;
    case 'lj':
      return 4;
    case 'hj':
      return 5;
    case 'co':
      return 6;
    case 'btn':
      return 7;
  }
  throw StateError('Unsupported seat for position truth: $seat');
}

import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

class World2SeatTapTruthSnapshotV1 {
  const World2SeatTapTruthSnapshotV1({this.role, this.seatId});

  final String? role;
  final String? seatId;
}

class World2SeatTapTruthValidationReportV1 {
  const World2SeatTapTruthValidationReportV1({
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

World2SeatTapTruthSnapshotV1 deriveWorld2SeatTapTruthV1(DrillSpecV1 spec) {
  if (!_isSupportedWorld2SeatTapTruthCandidateV1(spec)) {
    throw StateError(
      'World 2 seat-tap truth requires seat_tap with expected.role or expected.seatId and a supported explicit seat-anchor prompt.',
    );
  }
  return World2SeatTapTruthSnapshotV1(
    role: _tryDeriveRoleV1(spec.prompt),
    seatId: _tryDeriveSeatIdV1(spec.prompt),
  );
}

List<String> validateWorld2SeatTapTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2SeatTapTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2SeatTapTruthV1(spec);
  final issues = <String>[];
  if (truth.role != null && spec.expected.role != truth.role) {
    issues.add(
      '$source: expected role ${spec.expected.role} contradicts seat-tap truth ${truth.role}',
    );
  }
  if (truth.seatId != null && spec.expected.seatId != truth.seatId) {
    issues.add(
      '$source: expected seatId ${spec.expected.seatId} contradicts seat-tap truth ${truth.seatId}',
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
    _validateSeatTapCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

World2SeatTapTruthValidationReportV1 validateWorld2SeatTapTruthDirectoryV1(
  String rootPath,
) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 seat-tap truth validator root not found: $rootPath',
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
    if (spec.kind != DrillKindV1.seatTap) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2SeatTapTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: seat-tap truth v1 supports only explicit role/seatId prompts that resolve to btn, sb, bb, or seat S* anchors';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2SeatTapTruthSpecV1(spec: spec, source: file.path),
    );
  }
  return World2SeatTapTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isSupportedWorld2SeatTapTruthCandidateV1(DrillSpecV1 spec) {
  if (spec.kind != DrillKindV1.seatTap ||
      (spec.expected.role == null && spec.expected.seatId == null)) {
    return false;
  }
  final role = _tryDeriveRoleV1(spec.prompt);
  final seatId = _tryDeriveSeatIdV1(spec.prompt);
  return role != null || seatId != null;
}

List<String> _validateSeatTapCopyConsistencyV1({
  required String source,
  required World2SeatTapTruthSnapshotV1 truth,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  if ((lowerText.contains('button seat') ||
          lowerText.contains('button anchor') ||
          lowerText.contains('button context')) &&
      truth.role != 'btn') {
    issues.add('$source: button-seat copy contradicts seat-tap truth');
  }
  if ((lowerText.contains('small blind seat') ||
          lowerText.contains('small blind anchor') ||
          lowerText.contains('small blind context')) &&
      truth.role != 'sb') {
    issues.add('$source: small-blind copy contradicts seat-tap truth');
  }
  if ((lowerText.contains('big blind seat') ||
          lowerText.contains('big blind anchor') ||
          lowerText.contains('big blind context')) &&
      truth.role != 'bb') {
    issues.add('$source: big-blind copy contradicts seat-tap truth');
  }
  final seatIdMatch = RegExp(r'\bseat\s+(s\d+)\b').firstMatch(lowerText);
  if (seatIdMatch != null) {
    final seatId = seatIdMatch.group(1)!.toUpperCase();
    if (truth.seatId != seatId) {
      issues.add('$source: seat-id copy contradicts seat-tap truth');
    }
  }
  return issues;
}

String? _tryDeriveRoleV1(String prompt) {
  final lower = prompt.toLowerCase();
  if (lower.contains('button seat') || lower.contains('tap button anchor')) {
    return 'btn';
  }
  if (lower.contains('small blind seat')) {
    return 'sb';
  }
  if (lower.contains('big blind seat') ||
      lower.contains('tap big blind anchor')) {
    return 'bb';
  }
  return null;
}

String? _tryDeriveSeatIdV1(String prompt) {
  final match = RegExp(
    r'\bseat\s+(S\d+)\b',
    caseSensitive: false,
  ).firstMatch(prompt);
  return match?.group(1)?.toUpperCase();
}

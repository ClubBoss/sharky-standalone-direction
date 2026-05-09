import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

class World2BoardTapTruthSnapshotV1 {
  const World2BoardTapTruthSnapshotV1({required this.boardSlot});

  final String boardSlot;
}

class World2BoardTapTruthValidationReportV1 {
  const World2BoardTapTruthValidationReportV1({
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

World2BoardTapTruthSnapshotV1 deriveWorld2BoardTapTruthV1(DrillSpecV1 spec) {
  if (!_isSupportedWorld2BoardTapTruthCandidateV1(spec)) {
    throw StateError(
      'World 2 board-tap truth requires board_tap with expected.boardSlot and a supported explicit board-anchor prompt.',
    );
  }
  return World2BoardTapTruthSnapshotV1(
    boardSlot: _deriveBoardSlotV1(spec.prompt),
  );
}

List<String> validateWorld2BoardTapTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2BoardTapTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2BoardTapTruthV1(spec);
  final issues = <String>[];
  if (spec.expected.boardSlot != truth.boardSlot) {
    issues.add(
      '$source: expected boardSlot ${spec.expected.boardSlot} contradicts board-tap truth ${truth.boardSlot}',
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
    _validateBoardTapCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

World2BoardTapTruthValidationReportV1 validateWorld2BoardTapTruthDirectoryV1(
  String rootPath,
) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 board-tap truth validator root not found: $rootPath',
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
    if (spec.kind != DrillKindV1.boardTap) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2BoardTapTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: board-tap truth v1 supports only explicit boardSlot prompts that resolve to flop_left, flop_mid, flop_right, turn, or river';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2BoardTapTruthSpecV1(spec: spec, source: file.path),
    );
  }
  return World2BoardTapTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isSupportedWorld2BoardTapTruthCandidateV1(DrillSpecV1 spec) {
  if (spec.kind != DrillKindV1.boardTap || spec.expected.boardSlot == null) {
    return false;
  }
  final derived = _tryDeriveBoardSlotV1(spec.prompt);
  if (derived == null) {
    return false;
  }
  return _isSupportedBoardSlotV1(derived);
}

List<String> _validateBoardTapCopyConsistencyV1({
  required String source,
  required World2BoardTapTruthSnapshotV1 truth,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  if ((lowerText.contains('flop-right') || lowerText.contains('right flop')) &&
      truth.boardSlot != 'flop_right') {
    issues.add('$source: flop-right copy contradicts board-tap truth');
  }
  if ((lowerText.contains('flop-mid') ||
          lowerText.contains('middle flop') ||
          lowerText.contains('flop middle')) &&
      truth.boardSlot != 'flop_mid') {
    issues.add('$source: flop-mid copy contradicts board-tap truth');
  }
  if ((lowerText.contains('flop-left') ||
          lowerText.contains('left flop') ||
          lowerText.contains('flop anchor')) &&
      truth.boardSlot != 'flop_left') {
    issues.add('$source: flop-left copy contradicts board-tap truth');
  }
  if ((lowerText.contains('turn slot') ||
          lowerText.contains('turn anchor') ||
          lowerText.contains('turn context')) &&
      truth.boardSlot != 'turn') {
    issues.add('$source: turn copy contradicts board-tap truth');
  }
  if ((lowerText.contains('river slot') ||
          lowerText.contains('river anchor') ||
          lowerText.contains('river context')) &&
      truth.boardSlot != 'river') {
    issues.add('$source: river copy contradicts board-tap truth');
  }
  return issues;
}

String _deriveBoardSlotV1(String prompt) {
  final boardSlot = _tryDeriveBoardSlotV1(prompt);
  if (boardSlot == null) {
    throw StateError('Unsupported board-tap prompt shape: $prompt');
  }
  return boardSlot;
}

String? _tryDeriveBoardSlotV1(String prompt) {
  final lower = prompt.toLowerCase();
  if (lower.contains('left flop slot') || lower.contains('flop-left')) {
    return 'flop_left';
  }
  if (lower.contains('right flop slot') || lower.contains('flop-right')) {
    return 'flop_right';
  }
  if (lower.contains('middle flop slot') ||
      lower.contains('middle flop') ||
      lower.contains('flop-mid')) {
    return 'flop_mid';
  }
  if (lower.contains('flop anchor')) {
    return 'flop_left';
  }
  if (lower.contains('turn slot') || lower.contains('turn anchor')) {
    return 'turn';
  }
  if (lower.contains('river slot') || lower.contains('river anchor')) {
    return 'river';
  }
  return null;
}

bool _isSupportedBoardSlotV1(String boardSlot) {
  return switch (boardSlot) {
    'flop_left' || 'flop_mid' || 'flop_right' || 'turn' || 'river' => true,
    _ => false,
  };
}

import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

enum World2BoardTextureTruthPatternV1 { paired, connectedRun3, dryRainbowCalmer }

class World2BoardTextureTruthSnapshotV1 {
  const World2BoardTextureTruthSnapshotV1({
    required this.pattern,
    required this.isRainbow,
    required this.isTwoTone,
    required this.isMonotone,
  });

  final World2BoardTextureTruthPatternV1 pattern;
  final bool isRainbow;
  final bool isTwoTone;
  final bool isMonotone;
}

class World2BoardTextureTruthValidationReportV1 {
  const World2BoardTextureTruthValidationReportV1({
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

World2BoardTextureTruthSnapshotV1 deriveWorld2BoardTextureTruthV1(
  DrillSpecV1 spec,
) {
  if (!_isSupportedWorld2BoardTextureTruthCandidateV1(spec)) {
    throw StateError(
      'World 2 board-texture truth requires board_texture_classifier_v1 with exactly 3 board_cards_v1 and a supported paired/connected/dry contract label.',
    );
  }
  final boardCards = spec.boardCardsV1!;
  final pattern = _deriveBoardTexturePatternV1(boardCards);
  return World2BoardTextureTruthSnapshotV1(
    pattern: pattern,
    isRainbow: _suitTextureV1(boardCards) == _SuitTextureV1.rainbow,
    isTwoTone: _suitTextureV1(boardCards) == _SuitTextureV1.twoTone,
    isMonotone: _suitTextureV1(boardCards) == _SuitTextureV1.monotone,
  );
}

List<String> validateWorld2BoardTextureTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2BoardTextureTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2BoardTextureTruthV1(spec);
  final issues = <String>[];
  final authoredTexture = spec.boardTextureV1?.trim().toLowerCase();
  final expectedTexture = _patternLabelV1(truth.pattern);
  if (authoredTexture != expectedTexture) {
    issues.add(
      '$source: board_texture_v1 says $authoredTexture but board truth resolves to $expectedTexture',
    );
  }
  if (truth.pattern == World2BoardTextureTruthPatternV1.dryRainbowCalmer) {
    if (spec.boardTexturePolicyShapeV1 != 'pressure_level') {
      issues.add(
        '$source: dry board-texture truth requires board_texture_policy_shape_v1 pressure_level',
      );
    }
    if (spec.boardTexturePolicyTargetV1 != 'calmer') {
      issues.add(
        '$source: dry board-texture truth requires board_texture_policy_target_v1 calmer',
      );
    }
    if ((spec.expected.actionId ?? spec.expectedActionV1) != 'call') {
      issues.add(
        '$source: dry board-texture truth requires expected action call for the calmer-board contract',
      );
    }
  }
  final combinedText = [
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
    if (spec.recapV1 != null) spec.recapV1!,
  ].join(' ');
  issues.addAll(
    _validateBoardTextureCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

World2BoardTextureTruthValidationReportV1
validateWorld2BoardTextureTruthDirectoryV1(String rootPath) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError(
      'World 2 board-texture truth validator root not found: $rootPath',
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
    if (spec.kind != DrillKindV1.boardTextureClassifier) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2BoardTextureTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: board-texture truth v1 supports only exact paired/connected board-shape labels with exactly 3 board_cards_v1';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2BoardTextureTruthSpecV1(spec: spec, source: file.path),
    );
  }
  return World2BoardTextureTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isSupportedWorld2BoardTextureTruthCandidateV1(DrillSpecV1 spec) {
  if (spec.kind != DrillKindV1.boardTextureClassifier ||
      spec.boardCardsV1?.length != 3) {
    return false;
  }
  final authoredTexture = spec.boardTextureV1?.trim().toLowerCase();
  if (authoredTexture != 'paired' &&
      authoredTexture != 'connected' &&
      authoredTexture != 'dry') {
    return false;
  }
  final pattern = _deriveBoardTexturePatternOrNullV1(spec.boardCardsV1!);
  if (pattern == null) {
    return false;
  }
  if (_patternLabelV1(pattern) != authoredTexture) {
    return false;
  }
  if (pattern == World2BoardTextureTruthPatternV1.dryRainbowCalmer) {
    return spec.boardTexturePolicyShapeV1 == 'pressure_level' &&
        spec.boardTexturePolicyTargetV1 == 'calmer';
  }
  return true;
}

List<String> _validateBoardTextureCopyConsistencyV1({
  required String source,
  required World2BoardTextureTruthSnapshotV1 truth,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  if (RegExp(r'\bthis [^.]*\bpaired\b').hasMatch(lowerText) &&
      truth.pattern != World2BoardTextureTruthPatternV1.paired) {
    issues.add('$source: paired-texture copy contradicts board truth');
  }
  if ((RegExp(r'\bthis [^.]*\bconnected\b').hasMatch(lowerText) ||
          RegExp(r'\bthis [^.]*\bcoordinated\b').hasMatch(lowerText)) &&
      truth.pattern != World2BoardTextureTruthPatternV1.connectedRun3) {
    issues.add('$source: connected-texture copy contradicts board truth');
  }
  if ((RegExp(r'\bthis [^.]*\bdry\b').hasMatch(lowerText) ||
          RegExp(r'\btexture stays dry\b').hasMatch(lowerText)) &&
      truth.pattern != World2BoardTextureTruthPatternV1.dryRainbowCalmer) {
    issues.add('$source: dry-texture copy contradicts board truth');
  }
  return issues;
}

World2BoardTextureTruthPatternV1 _deriveBoardTexturePatternV1(
  List<String> boardCards,
) {
  final pattern = _deriveBoardTexturePatternOrNullV1(boardCards);
  if (pattern == null) {
    throw StateError('Unsupported board-texture truth board shape');
  }
  return pattern;
}

World2BoardTextureTruthPatternV1? _deriveBoardTexturePatternOrNullV1(
  List<String> boardCards,
) {
  if (_isPairedBoardV1(boardCards)) {
    return World2BoardTextureTruthPatternV1.paired;
  }
  if (_isConnectedRun3BoardV1(boardCards)) {
    return World2BoardTextureTruthPatternV1.connectedRun3;
  }
  if (_isDryRainbowBoardV1(boardCards)) {
    return World2BoardTextureTruthPatternV1.dryRainbowCalmer;
  }
  return null;
}

bool _isPairedBoardV1(List<String> boardCards) {
  final counts = <int, int>{};
  for (final card in boardCards) {
    final rank = _rankValueV1(card);
    counts.update(rank, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts.values.any((count) => count >= 2);
}

bool _isConnectedRun3BoardV1(List<String> boardCards) {
  final ranks = <int>{for (final card in boardCards) _rankValueV1(card)};
  if (ranks.length != 3) {
    return false;
  }
  final sorted = ranks.toList()..sort();
  if (sorted[1] == sorted[0] + 1 && sorted[2] == sorted[1] + 1) {
    return true;
  }
  if (ranks.contains(14)) {
    final aceLow = ranks.map((rank) => rank == 14 ? 1 : rank).toList()..sort();
    return aceLow[1] == aceLow[0] + 1 && aceLow[2] == aceLow[1] + 1;
  }
  return false;
}

String _patternLabelV1(World2BoardTextureTruthPatternV1 pattern) {
  switch (pattern) {
    case World2BoardTextureTruthPatternV1.paired:
      return 'paired';
    case World2BoardTextureTruthPatternV1.connectedRun3:
      return 'connected';
    case World2BoardTextureTruthPatternV1.dryRainbowCalmer:
      return 'dry';
  }
}

bool _isDryRainbowBoardV1(List<String> boardCards) {
  return !_isPairedBoardV1(boardCards) &&
      !_isConnectedRun3BoardV1(boardCards) &&
      _suitTextureV1(boardCards) == _SuitTextureV1.rainbow;
}

enum _SuitTextureV1 { rainbow, twoTone, monotone }

_SuitTextureV1 _suitTextureV1(List<String> boardCards) {
  final suitCounts = <String, int>{};
  for (final card in boardCards) {
    final suit = card.substring(card.length - 1).toLowerCase();
    suitCounts.update(suit, (value) => value + 1, ifAbsent: () => 1);
  }
  final counts = suitCounts.values.toList()..sort();
  if (counts.length == 1) {
    return _SuitTextureV1.monotone;
  }
  if (counts.length == 2) {
    return _SuitTextureV1.twoTone;
  }
  return _SuitTextureV1.rainbow;
}

int _rankValueV1(String card) {
  final rank = card.substring(0, card.length - 1).toUpperCase();
  switch (rank) {
    case '2':
      return 2;
    case '3':
      return 3;
    case '4':
      return 4;
    case '5':
      return 5;
    case '6':
      return 6;
    case '7':
      return 7;
    case '8':
      return 8;
    case '9':
      return 9;
    case 'T':
      return 10;
    case 'J':
      return 11;
    case 'Q':
      return 12;
    case 'K':
      return 13;
    case 'A':
      return 14;
  }
  throw StateError('Unsupported card rank: $card');
}

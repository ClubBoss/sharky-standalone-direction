import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';

enum World2OutsTruthPatternV1 {
  flushDrawNine,
  openEndedStraightEight,
  gutshotStraightFour,
}

class World2OutsTruthSnapshotV1 {
  const World2OutsTruthSnapshotV1({
    required this.pattern,
    required this.outsCount,
  });

  final World2OutsTruthPatternV1 pattern;
  final int outsCount;
}

class World2OutsTruthValidationReportV1 {
  const World2OutsTruthValidationReportV1({
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

World2OutsTruthSnapshotV1 deriveWorld2OutsTruthV1(DrillSpecV1 spec) {
  if (!_isSupportedWorld2OutsTruthCandidateV1(spec)) {
    throw StateError(
      'World 2 outs truth requires outs_count_choice_v1 with hero_hole_cards_v1, exactly 3 board_cards_v1, and a supported canonical outs pattern.',
    );
  }
  final heroCards = spec.heroHoleCardsV1!;
  final boardCards = spec.boardCardsV1!;
  final flushOuts = _countFlushOutsV1(
    heroCards: heroCards,
    boardCards: boardCards,
  );
  final straightOuts = _countStraightOutsV1(
    heroCards: heroCards,
    boardCards: boardCards,
  );
  if (flushOuts == 9) {
    return const World2OutsTruthSnapshotV1(
      pattern: World2OutsTruthPatternV1.flushDrawNine,
      outsCount: 9,
    );
  }
  if (straightOuts == 8) {
    return const World2OutsTruthSnapshotV1(
      pattern: World2OutsTruthPatternV1.openEndedStraightEight,
      outsCount: 8,
    );
  }
  if (straightOuts == 4) {
    return const World2OutsTruthSnapshotV1(
      pattern: World2OutsTruthPatternV1.gutshotStraightFour,
      outsCount: 4,
    );
  }
  throw StateError(
    'World 2 outs truth candidate does not resolve to a supported canonical 9/8/4 outs pattern.',
  );
}

World2OutsTruthSnapshotV1 deriveWorld2OutsTruthChainStepV1(
  DrillChainStepV1 step,
) {
  if (!_isSupportedWorld2OutsTruthChainStepV1(step)) {
    throw StateError(
      'World 2 outs truth chain step requires hero_hole_cards_v1, exactly 3 board_cards_v1, numeric expected_action, and a supported canonical outs pattern.',
    );
  }
  return _deriveWorld2OutsTruthSnapshotFromCardsV1(
    heroCards: step.heroHoleCardsV1!,
    boardCards: step.boardCardsV1!,
  );
}

List<String> validateWorld2OutsTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isSupportedWorld2OutsTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2OutsTruthV1(spec);
  final issues = <String>[];
  final expectedOuts = int.tryParse(spec.expected.actionId ?? '');
  if (expectedOuts != truth.outsCount) {
    issues.add(
      '$source: expected outs ${spec.expected.actionId} contradict visible-card outs truth ${truth.outsCount}',
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
    _validateOutsCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

List<String> validateWorld2OutsTruthChainStepV1({
  required DrillChainStepV1 step,
  required String source,
}) {
  if (!_isSupportedWorld2OutsTruthChainStepV1(step)) {
    return const <String>[];
  }
  final truth = deriveWorld2OutsTruthChainStepV1(step);
  final issues = <String>[];
  final expectedOuts = int.tryParse(step.expectedActionV1 ?? '');
  if (expectedOuts != truth.outsCount) {
    issues.add(
      '$source: expected outs ${step.expectedActionV1} contradict visible-card outs truth ${truth.outsCount}',
    );
  }
  final combinedText = [
    step.prompt,
    if (step.whyV1 != null) step.whyV1!,
    if (step.feedbackCorrectV1 != null) step.feedbackCorrectV1!,
    if (step.feedbackIncorrectV1 != null) step.feedbackIncorrectV1!,
  ].join(' ');
  issues.addAll(
    _validateOutsCopyConsistencyV1(
      source: source,
      truth: truth,
      text: combinedText,
    ),
  );
  return issues;
}

World2OutsTruthValidationReportV1 validateWorld2OutsTruthDirectoryV1(
  String rootPath,
) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError('World 2 outs truth validator root not found: $rootPath');
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
    if (spec.kind != DrillKindV1.outsCountChoice) {
      continue;
    }
    familySources.add(file.path);
    if (!_isSupportedWorld2OutsTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: outs truth validator requires hero_hole_cards_v1, exactly 3 board_cards_v1, and a canonical 9/8/4 outs pattern';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(validateWorld2OutsTruthSpecV1(spec: spec, source: file.path));
  }
  return World2OutsTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isSupportedWorld2OutsTruthCandidateV1(DrillSpecV1 spec) {
  if (spec.kind != DrillKindV1.outsCountChoice ||
      spec.heroHoleCardsV1?.length != 2 ||
      spec.boardCardsV1?.length != 3) {
    return false;
  }
  return _supportsCanonicalOutsPatternV1(
    heroCards: spec.heroHoleCardsV1!,
    boardCards: spec.boardCardsV1!,
  );
}

bool _isSupportedWorld2OutsTruthChainStepV1(DrillChainStepV1 step) {
  if (step.heroHoleCardsV1?.length != 2 ||
      step.boardCardsV1?.length != 3 ||
      int.tryParse(step.expectedActionV1 ?? '') == null) {
    return false;
  }
  final availableActions = step.availableActionsV1;
  if (availableActions == null ||
      availableActions.length != 4 ||
      availableActions.toSet().length != 4) {
    return false;
  }
  const allowed = <String>{'4', '8', '9', '15'};
  if (!availableActions.every(allowed.contains)) {
    return false;
  }
  return _supportsCanonicalOutsPatternV1(
    heroCards: step.heroHoleCardsV1!,
    boardCards: step.boardCardsV1!,
  );
}

bool _supportsCanonicalOutsPatternV1({
  required List<String> heroCards,
  required List<String> boardCards,
}) {
  final flushOuts = _countFlushOutsV1(
    heroCards: heroCards,
    boardCards: boardCards,
  );
  final straightOuts = _countStraightOutsV1(
    heroCards: heroCards,
    boardCards: boardCards,
  );
  return flushOuts == 9 || straightOuts == 8 || straightOuts == 4;
}

World2OutsTruthSnapshotV1 _deriveWorld2OutsTruthSnapshotFromCardsV1({
  required List<String> heroCards,
  required List<String> boardCards,
}) {
  final flushOuts = _countFlushOutsV1(
    heroCards: heroCards,
    boardCards: boardCards,
  );
  final straightOuts = _countStraightOutsV1(
    heroCards: heroCards,
    boardCards: boardCards,
  );
  if (flushOuts == 9) {
    return const World2OutsTruthSnapshotV1(
      pattern: World2OutsTruthPatternV1.flushDrawNine,
      outsCount: 9,
    );
  }
  if (straightOuts == 8) {
    return const World2OutsTruthSnapshotV1(
      pattern: World2OutsTruthPatternV1.openEndedStraightEight,
      outsCount: 8,
    );
  }
  if (straightOuts == 4) {
    return const World2OutsTruthSnapshotV1(
      pattern: World2OutsTruthPatternV1.gutshotStraightFour,
      outsCount: 4,
    );
  }
  throw StateError(
    'World 2 outs truth candidate does not resolve to a supported canonical 9/8/4 outs pattern.',
  );
}

List<String> _validateOutsCopyConsistencyV1({
  required String source,
  required World2OutsTruthSnapshotV1 truth,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  final outsMatch = RegExp(r'\b(4|8|9|15)\s+outs\b').firstMatch(lowerText);
  if (outsMatch != null) {
    final statedOuts = int.parse(outsMatch.group(1)!);
    if (statedOuts != truth.outsCount) {
      issues.add(
        '$source: outs copy says $statedOuts but visible cards resolve to ${truth.outsCount}',
      );
    }
  }

  final mentionsFlushDraw = RegExp(
    r'\b(this|a)\s+flush draw\b',
  ).hasMatch(lowerText);
  if (mentionsFlushDraw &&
      truth.pattern != World2OutsTruthPatternV1.flushDrawNine) {
    issues.add('$source: flush-draw copy contradicts visible cards');
  }

  final mentionsOpenEnded = RegExp(
    r'\b(this|an)\s+open(?:-| )ended(?: straight draw)?\b',
  ).hasMatch(lowerText);
  if (mentionsOpenEnded &&
      truth.pattern != World2OutsTruthPatternV1.openEndedStraightEight) {
    issues.add('$source: open-ended copy contradicts visible cards');
  }

  if (RegExp(r'\bthis gutshot\b').hasMatch(lowerText) &&
      truth.pattern != World2OutsTruthPatternV1.gutshotStraightFour) {
    issues.add('$source: gutshot copy contradicts visible cards');
  }

  return issues;
}

int _countFlushOutsV1({
  required List<String> heroCards,
  required List<String> boardCards,
}) {
  var count = 0;
  for (final candidate in _remainingDeckV1(<String>[
    ...heroCards,
    ...boardCards,
  ])) {
    if (_hasFlushV1(<String>[...heroCards, ...boardCards, candidate])) {
      count += 1;
    }
  }
  return count;
}

int _countStraightOutsV1({
  required List<String> heroCards,
  required List<String> boardCards,
}) {
  var count = 0;
  for (final candidate in _remainingDeckV1(<String>[
    ...heroCards,
    ...boardCards,
  ])) {
    if (_hasStraightV1(<String>[...heroCards, ...boardCards, candidate])) {
      count += 1;
    }
  }
  return count;
}

Iterable<String> _remainingDeckV1(List<String> seenCards) sync* {
  const ranks = <String>[
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'T',
    'J',
    'Q',
    'K',
    'A',
  ];
  const suits = <String>['c', 'd', 'h', 's'];
  final seen = seenCards.map((card) => card.toLowerCase()).toSet();
  for (final rank in ranks) {
    for (final suit in suits) {
      final card = '$rank$suit'.toLowerCase();
      if (!seen.contains(card)) {
        yield card;
      }
    }
  }
}

bool _hasFlushV1(List<String> cards) {
  final suitCounts = <String, int>{};
  for (final card in cards) {
    final suit = card.substring(card.length - 1).toLowerCase();
    suitCounts.update(suit, (value) => value + 1, ifAbsent: () => 1);
  }
  return suitCounts.values.any((count) => count >= 5);
}

bool _hasStraightV1(List<String> cards) {
  final ranks = <int>{for (final card in cards) _rankValueV1(card)};
  if (ranks.contains(14)) {
    ranks.add(1);
  }
  final sorted = ranks.toList()..sort();
  var streak = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == sorted[i - 1] + 1) {
      streak += 1;
      if (streak >= 5) {
        return true;
      }
    } else {
      streak = 1;
    }
  }
  return false;
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

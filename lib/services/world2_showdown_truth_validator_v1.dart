import 'dart:io';

import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_solver/poker_solver.dart';

enum World2ShowdownWinnerTruthV1 { hero, villain, boardPlays, unsupportedTie }

enum World2PairSemanticsTruthV1 {
  none,
  topPair,
  secondPair,
  bottomPair,
  overpair,
  underpair,
  twoPair,
  trips,
  set,
}

class World2ShowdownTruthSnapshotV1 {
  const World2ShowdownTruthSnapshotV1({
    required this.winner,
    required this.heroPairSemantics,
    required this.villainPairSemantics,
    required this.heroMadeHand,
    required this.villainMadeHand,
    required this.boardHasStraight,
  });

  final World2ShowdownWinnerTruthV1 winner;
  final World2PairSemanticsTruthV1 heroPairSemantics;
  final World2PairSemanticsTruthV1 villainPairSemantics;
  final World2MadeHandTruthV1 heroMadeHand;
  final World2MadeHandTruthV1 villainMadeHand;
  final bool boardHasStraight;
}

class World2ShowdownTruthValidationReportV1 {
  const World2ShowdownTruthValidationReportV1({
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

enum World2MadeHandCategoryV1 {
  highCard,
  onePair,
  twoPair,
  trips,
  set,
  straight,
  flush,
  fullHouse,
  quads,
  straightFlush,
}

class World2MadeHandTruthV1 {
  const World2MadeHandTruthV1({
    required this.category,
    required this.pairRanksDesc,
  });

  final World2MadeHandCategoryV1 category;
  final List<int> pairRanksDesc;
}

World2ShowdownTruthSnapshotV1 deriveWorld2ShowdownTruthV1(DrillSpecV1 spec) {
  if (!_isVisibleWorld2ShowdownTruthCandidateV1(spec)) {
    throw StateError(
      'Visible-card showdown truth requires showdown_winner_choice_v1 with hero, villain, and 5 board cards.',
    );
  }
  final heroCards = spec.heroHoleCardsV1!;
  final villainCards = spec.villainHoleCardsV1!;
  final boardCards = spec.boardCardsV1!;
  return World2ShowdownTruthSnapshotV1(
    winner: _deriveWinnerTruthV1(
      heroCards: heroCards,
      villainCards: villainCards,
      boardCards: boardCards,
    ),
    heroPairSemantics: _derivePairSemanticsTruthV1(
      holeCards: heroCards,
      boardCards: boardCards,
    ),
    villainPairSemantics: _derivePairSemanticsTruthV1(
      holeCards: villainCards,
      boardCards: boardCards,
    ),
    heroMadeHand: _deriveMadeHandTruthV1(
      holeCards: heroCards,
      boardCards: boardCards,
    ),
    villainMadeHand: _deriveMadeHandTruthV1(
      holeCards: villainCards,
      boardCards: boardCards,
    ),
    boardHasStraight: _hasStraightV1(
      holeCards: const <String>[],
      boardCards: boardCards,
    ),
  );
}

List<String> validateWorld2ShowdownTruthSpecV1({
  required DrillSpecV1 spec,
  required String source,
}) {
  if (!_isVisibleWorld2ShowdownTruthCandidateV1(spec)) {
    return const <String>[];
  }
  final truth = deriveWorld2ShowdownTruthV1(spec);
  final issues = <String>[];
  final expectedWinner = _winnerTruthFromActionIdV1(spec.expected.actionId);
  if (expectedWinner != truth.winner) {
    issues.add(
      '$source: expected winner ${spec.expected.actionId} contradicts visible showdown truth ${_winnerTruthActionIdV1(truth.winner)}',
    );
  }
  if (truth.winner == World2ShowdownWinnerTruthV1.unsupportedTie) {
    issues.add(
      '$source: visible-card showdown resolves to a non-board tie outside the first validator slice',
    );
  }

  issues.addAll(
    _validateWinnerCopyConsistencyV1(
      source: source,
      winner: truth.winner,
      prompt: spec.prompt,
      why: spec.whyV1,
      feedbackCorrect: spec.feedbackCorrectV1,
      feedbackIncorrect: spec.feedbackIncorrectV1,
    ),
  );
  issues.addAll(
    _validatePairCopyConsistencyV1(
      source: source,
      actor: 'hero',
      expected: truth.heroPairSemantics,
      text: [
        spec.prompt,
        if (spec.whyV1 != null) spec.whyV1!,
        if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
        if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
      ].join(' '),
    ),
  );
  issues.addAll(
    _validatePairCopyConsistencyV1(
      source: source,
      actor: 'villain',
      expected: truth.villainPairSemantics,
      text: [
        spec.prompt,
        if (spec.whyV1 != null) spec.whyV1!,
        if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
        if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
      ].join(' '),
    ),
  );
  final combinedText = [
    spec.prompt,
    if (spec.whyV1 != null) spec.whyV1!,
    if (spec.feedbackCorrectV1 != null) spec.feedbackCorrectV1!,
    if (spec.feedbackIncorrectV1 != null) spec.feedbackIncorrectV1!,
    if (spec.recapV1 != null) spec.recapV1!,
  ].join(' ');
  issues.addAll(
    _validateStraightCopyConsistencyV1(
      source: source,
      winner: truth.winner,
      heroMadeHand: truth.heroMadeHand,
      villainMadeHand: truth.villainMadeHand,
      boardHasStraight: truth.boardHasStraight,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validateTwoPairCopyConsistencyV1(
      source: source,
      heroMadeHand: truth.heroMadeHand,
      villainMadeHand: truth.villainMadeHand,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validateGenericUnderpairCopyConsistencyV1(
      source: source,
      heroPairSemantics: truth.heroPairSemantics,
      villainPairSemantics: truth.villainPairSemantics,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validateBoardPlaysCopyConsistencyV1(
      source: source,
      winner: truth.winner,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validateBoardPlaysPositiveSemanticsV1(
      source: source,
      winner: truth.winner,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validatePairRankNamingConsistencyV1(
      source: source,
      actor: 'hero',
      madeHand: truth.heroMadeHand,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validatePairRankNamingConsistencyV1(
      source: source,
      actor: 'villain',
      madeHand: truth.villainMadeHand,
      text: combinedText,
    ),
  );
  issues.addAll(
    _validateStrongerPairCopyConsistencyV1(
      source: source,
      winner: truth.winner,
      heroMadeHand: truth.heroMadeHand,
      villainMadeHand: truth.villainMadeHand,
      text: combinedText,
    ),
  );
  return issues;
}

World2ShowdownTruthValidationReportV1 validateWorld2ShowdownTruthDirectoryV1(
  String rootPath,
) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError('World 2 truth validator root not found: $rootPath');
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
    if (spec.kind != DrillKindV1.showdownWinnerChoice) {
      continue;
    }
    familySources.add(file.path);
    if (!_isVisibleWorld2ShowdownTruthCandidateV1(spec)) {
      skippedCount += 1;
      skippedSources.add(file.path);
      skippedReasons[file.path] =
          'excluded: visible-card showdown validator requires hero_hole_cards_v1, villain_hole_cards_v1, and exactly 5 board_cards_v1';
      continue;
    }
    checkedCount += 1;
    checkedSources.add(file.path);
    issues.addAll(
      validateWorld2ShowdownTruthSpecV1(spec: spec, source: file.path),
    );
  }
  return World2ShowdownTruthValidationReportV1(
    familySources: List<String>.unmodifiable(familySources),
    checkedCount: checkedCount,
    skippedCount: skippedCount,
    checkedSources: List<String>.unmodifiable(checkedSources),
    skippedSources: List<String>.unmodifiable(skippedSources),
    skippedReasons: Map<String, String>.unmodifiable(skippedReasons),
    issues: List<String>.unmodifiable(issues),
  );
}

bool _isVisibleWorld2ShowdownTruthCandidateV1(DrillSpecV1 spec) {
  return spec.kind == DrillKindV1.showdownWinnerChoice &&
      spec.heroHoleCardsV1?.length == 2 &&
      spec.villainHoleCardsV1?.length == 2 &&
      spec.boardCardsV1?.length == 5;
}

World2ShowdownWinnerTruthV1 _winnerTruthFromActionIdV1(String? actionId) {
  switch (actionId) {
    case 'hero':
      return World2ShowdownWinnerTruthV1.hero;
    case 'villain':
      return World2ShowdownWinnerTruthV1.villain;
    case 'board_plays':
      return World2ShowdownWinnerTruthV1.boardPlays;
  }
  throw StateError('Unsupported showdown winner actionId: $actionId');
}

String _winnerTruthActionIdV1(World2ShowdownWinnerTruthV1 winner) {
  switch (winner) {
    case World2ShowdownWinnerTruthV1.hero:
      return 'hero';
    case World2ShowdownWinnerTruthV1.villain:
      return 'villain';
    case World2ShowdownWinnerTruthV1.boardPlays:
      return 'board_plays';
    case World2ShowdownWinnerTruthV1.unsupportedTie:
      return 'unsupported_tie';
  }
}

World2ShowdownWinnerTruthV1 _deriveWinnerTruthV1({
  required List<String> heroCards,
  required List<String> villainCards,
  required List<String> boardCards,
}) {
  final heroHand = Hand.solveHand(<String>[...boardCards, ...heroCards]);
  final villainHand = Hand.solveHand(<String>[...boardCards, ...villainCards]);
  final winners = Hand.winners(<Hand>[heroHand, villainHand]);
  if (winners.length == 1) {
    return identical(winners.single, heroHand)
        ? World2ShowdownWinnerTruthV1.hero
        : World2ShowdownWinnerTruthV1.villain;
  }
  final boardHand = Hand.solveHand(boardCards);
  final boardInclusiveWinners = Hand.winners(<Hand>[
    heroHand,
    villainHand,
    boardHand,
  ]);
  if (boardInclusiveWinners.contains(boardHand)) {
    return World2ShowdownWinnerTruthV1.boardPlays;
  }
  return World2ShowdownWinnerTruthV1.unsupportedTie;
}

World2PairSemanticsTruthV1 _derivePairSemanticsTruthV1({
  required List<String> holeCards,
  required List<String> boardCards,
}) {
  final holeRanks = holeCards.map(_rankValueV1).toList();
  final boardRanks = boardCards.map(_rankValueV1).toList();
  final rankCounts = _rankCountsV1(<int>[...holeRanks, ...boardRanks]);
  final countValues = rankCounts.values.toList()
    ..sort((a, b) => b.compareTo(a));
  final pairRanks = _ranksWithCountV1(rankCounts, 2);
  final tripRanks = _ranksWithCountV1(rankCounts, 3);
  final boardIsPaired = _boardHasPairV1(boardRanks);

  if (_hasStraightFlushV1(holeCards: holeCards, boardCards: boardCards) ||
      countValues.contains(4) ||
      (tripRanks.isNotEmpty && pairRanks.isNotEmpty) ||
      tripRanks.length >= 2 ||
      _hasFlushV1(holeCards: holeCards, boardCards: boardCards) ||
      _hasStraightV1(holeCards: holeCards, boardCards: boardCards)) {
    return World2PairSemanticsTruthV1.none;
  }
  if (tripRanks.isNotEmpty) {
    final tripRank = tripRanks.first;
    final isPocketPair =
        holeRanks[0] == holeRanks[1] && holeRanks[0] == tripRank;
    return isPocketPair
        ? World2PairSemanticsTruthV1.set
        : World2PairSemanticsTruthV1.trips;
  }
  if (pairRanks.length >= 2) {
    return World2PairSemanticsTruthV1.twoPair;
  }
  if (pairRanks.length != 1) {
    return World2PairSemanticsTruthV1.none;
  }
  if (boardIsPaired) {
    return World2PairSemanticsTruthV1.none;
  }

  final pairRank = pairRanks.single;
  final isPocketPair = holeRanks[0] == holeRanks[1] && holeRanks[0] == pairRank;
  final sortedBoardRanks = boardRanks.toList()..sort((a, b) => b.compareTo(a));
  if (isPocketPair && !boardRanks.contains(pairRank)) {
    if (pairRank > sortedBoardRanks.first) {
      return World2PairSemanticsTruthV1.overpair;
    }
    return World2PairSemanticsTruthV1.underpair;
  }
  if (pairRank == sortedBoardRanks.first) {
    return World2PairSemanticsTruthV1.topPair;
  }
  if (sortedBoardRanks.length > 1 && pairRank == sortedBoardRanks[1]) {
    return World2PairSemanticsTruthV1.secondPair;
  }
  if (pairRank == sortedBoardRanks.last) {
    return World2PairSemanticsTruthV1.bottomPair;
  }
  return World2PairSemanticsTruthV1.none;
}

List<String> _validateWinnerCopyConsistencyV1({
  required String source,
  required World2ShowdownWinnerTruthV1 winner,
  required String prompt,
  required String? why,
  required String? feedbackCorrect,
  required String? feedbackIncorrect,
}) {
  final issues = <String>[];
  final combined = [
    prompt,
    if (why != null) why,
    if (feedbackCorrect != null) feedbackCorrect,
    if (feedbackIncorrect != null) feedbackIncorrect,
  ].join(' ').toLowerCase();
  switch (winner) {
    case World2ShowdownWinnerTruthV1.hero:
      if (combined.contains('villain wins') ||
          combined.contains('board plays') ||
          combined.contains('both players tie')) {
        issues.add('$source: copy contradicts visible hero winner truth');
      }
    case World2ShowdownWinnerTruthV1.villain:
      if (combined.contains('hero wins') ||
          combined.contains('board plays') ||
          combined.contains('both players tie')) {
        issues.add('$source: copy contradicts visible villain winner truth');
      }
    case World2ShowdownWinnerTruthV1.boardPlays:
      if (combined.contains('hero wins') || combined.contains('villain wins')) {
        issues.add('$source: copy contradicts visible board-plays truth');
      }
    case World2ShowdownWinnerTruthV1.unsupportedTie:
      break;
  }
  return issues;
}

List<String> _validateBoardPlaysCopyConsistencyV1({
  required String source,
  required World2ShowdownWinnerTruthV1 winner,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final mentionsBoardPlays =
      lowerText.contains('board plays') ||
      lowerText.contains('both players tie') ||
      lowerText.contains('best hand for everyone') ||
      lowerText.contains('best five-card hand') ||
      lowerText.contains('best hand for both players');
  if (!mentionsBoardPlays) {
    return const <String>[];
  }
  if (winner == World2ShowdownWinnerTruthV1.boardPlays) {
    return const <String>[];
  }
  return <String>[
    '$source: board-plays copy contradicts visible showdown truth',
  ];
}

List<String> _validateBoardPlaysPositiveSemanticsV1({
  required String source,
  required World2ShowdownWinnerTruthV1 winner,
  required String text,
}) {
  if (winner != World2ShowdownWinnerTruthV1.boardPlays) {
    return const <String>[];
  }
  final lowerText = text.toLowerCase();
  final hasBoardPlaysSemantics =
      lowerText.contains('board plays') ||
      lowerText.contains('both players tie') ||
      lowerText.contains('best hand for everyone') ||
      lowerText.contains('best hand for both players') ||
      lowerText.contains('best five-card hand');
  if (hasBoardPlaysSemantics) {
    return const <String>[];
  }
  return <String>[
    '$source: board-plays winner truth requires explicit board-plays or split-pot copy',
  ];
}

List<String> _validatePairRankNamingConsistencyV1({
  required String source,
  required String actor,
  required World2MadeHandTruthV1 madeHand,
  required String text,
}) {
  final detectedRank = _detectExplicitActorPairRankV1(
    actor: actor,
    text: text.toLowerCase(),
  );
  if (detectedRank == null) {
    return const <String>[];
  }
  if (madeHand.category != World2MadeHandCategoryV1.onePair ||
      madeHand.pairRanksDesc.isEmpty) {
    return <String>[
      '$source: $actor pair naming copy says pair of ${_rankLabelPluralV1(detectedRank)} but visible cards resolve to ${madeHand.category.name}',
    ];
  }
  final actualRank = madeHand.pairRanksDesc.first;
  if (actualRank == detectedRank) {
    return const <String>[];
  }
  return <String>[
    '$source: $actor pair naming copy says pair of ${_rankLabelPluralV1(detectedRank)} but visible cards resolve to pair of ${_rankLabelPluralV1(actualRank)}',
  ];
}

List<String> _validateStrongerPairCopyConsistencyV1({
  required String source,
  required World2ShowdownWinnerTruthV1 winner,
  required World2MadeHandTruthV1 heroMadeHand,
  required World2MadeHandTruthV1 villainMadeHand,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  if (!lowerText.contains('stronger pair')) {
    return const <String>[];
  }
  if (winner == World2ShowdownWinnerTruthV1.boardPlays ||
      winner == World2ShowdownWinnerTruthV1.unsupportedTie) {
    return <String>[
      '$source: stronger pair copy contradicts a non-player showdown result',
    ];
  }
  if (heroMadeHand.category != World2MadeHandCategoryV1.onePair ||
      villainMadeHand.category != World2MadeHandCategoryV1.onePair ||
      heroMadeHand.pairRanksDesc.isEmpty ||
      villainMadeHand.pairRanksDesc.isEmpty) {
    return <String>[
      '$source: stronger pair copy requires both players to resolve to onePair',
    ];
  }
  if (heroMadeHand.pairRanksDesc.first == villainMadeHand.pairRanksDesc.first) {
    return <String>[
      '$source: stronger pair copy contradicts visible cards because the pair ranks are tied and kicker decides',
    ];
  }
  final strongerWinner =
      heroMadeHand.pairRanksDesc.first > villainMadeHand.pairRanksDesc.first
      ? World2ShowdownWinnerTruthV1.hero
      : World2ShowdownWinnerTruthV1.villain;
  if (winner == strongerWinner) {
    return const <String>[];
  }
  return <String>[
    '$source: stronger pair copy contradicts visible showdown truth',
  ];
}

List<String> _validateStraightCopyConsistencyV1({
  required String source,
  required World2ShowdownWinnerTruthV1 winner,
  required World2MadeHandTruthV1 heroMadeHand,
  required World2MadeHandTruthV1 villainMadeHand,
  required bool boardHasStraight,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  final issues = <String>[];
  final heroHasStraight = _madeHandHasStraightV1(heroMadeHand);
  final villainHasStraight = _madeHandHasStraightV1(villainMadeHand);

  final heroStraightClaim = RegExp(
    r'hero[^.]*\bstraight\b',
  ).hasMatch(lowerText);
  if (heroStraightClaim && !heroHasStraight) {
    issues.add('$source: hero straight copy contradicts visible cards');
  }

  final villainStraightClaim = RegExp(
    r'villain[^.]*\bstraight\b',
  ).hasMatch(lowerText);
  if (villainStraightClaim && !villainHasStraight) {
    issues.add('$source: villain straight copy contradicts visible cards');
  }

  final boardStraightClaim = RegExp(
    r'\bboard[^.]*\bbest straight\b',
  ).hasMatch(lowerText);
  if (boardStraightClaim &&
      !(boardHasStraight && winner == World2ShowdownWinnerTruthV1.boardPlays)) {
    issues.add(
      '$source: board straight copy contradicts visible showdown truth',
    );
  }

  final genericStraightClaim =
      lowerText.contains('straight beats') ||
      lowerText.contains('straight outranks');
  if (genericStraightClaim &&
      !(heroHasStraight || villainHasStraight || boardHasStraight)) {
    issues.add('$source: straight-hand copy contradicts visible cards');
  }

  return issues;
}

List<String> _validateTwoPairCopyConsistencyV1({
  required String source,
  required World2MadeHandTruthV1 heroMadeHand,
  required World2MadeHandTruthV1 villainMadeHand,
  required String text,
}) {
  if (!text.toLowerCase().contains('two pair')) {
    return const <String>[];
  }
  final heroHasTwoPair = heroMadeHand.category == World2MadeHandCategoryV1.twoPair;
  final villainHasTwoPair =
      villainMadeHand.category == World2MadeHandCategoryV1.twoPair;
  if (heroHasTwoPair || villainHasTwoPair) {
    return const <String>[];
  }
  return <String>[
    '$source: two-pair copy contradicts visible cards',
  ];
}

List<String> _validateGenericUnderpairCopyConsistencyV1({
  required String source,
  required World2PairSemanticsTruthV1 heroPairSemantics,
  required World2PairSemanticsTruthV1 villainPairSemantics,
  required String text,
}) {
  final lowerText = text.toLowerCase();
  if (!lowerText.contains('underpair')) {
    return const <String>[];
  }
  final actorSpecificUnderpair = RegExp(
    r'(hero|villain)[^.]*\bunderpair\b',
  ).hasMatch(lowerText);
  if (actorSpecificUnderpair) {
    return const <String>[];
  }
  final hasVisibleUnderpair =
      heroPairSemantics == World2PairSemanticsTruthV1.underpair ||
      villainPairSemantics == World2PairSemanticsTruthV1.underpair;
  if (hasVisibleUnderpair) {
    return const <String>[];
  }
  return <String>[
    '$source: generic underpair copy contradicts visible cards',
  ];
}

List<String> _validatePairCopyConsistencyV1({
  required String source,
  required String actor,
  required World2PairSemanticsTruthV1 expected,
  required String text,
}) {
  final detected = _detectExplicitActorPairSemanticsV1(
    actor: actor,
    text: text.toLowerCase(),
  );
  if (detected == null || detected == expected) {
    return const <String>[];
  }
  return <String>[
    '$source: $actor pair semantics copy says ${detected.name} but visible cards resolve to ${expected.name}',
  ];
}

World2PairSemanticsTruthV1? _detectExplicitActorPairSemanticsV1({
  required String actor,
  required String text,
}) {
  final patterns = <World2PairSemanticsTruthV1, RegExp>{
    World2PairSemanticsTruthV1.topPair: RegExp('$actor[^.]*\\btop pair\\b'),
    World2PairSemanticsTruthV1.secondPair: RegExp(
      '$actor[^.]*\\bsecond pair\\b',
    ),
    World2PairSemanticsTruthV1.bottomPair: RegExp(
      '$actor[^.]*\\bbottom pair\\b',
    ),
    World2PairSemanticsTruthV1.overpair: RegExp('$actor[^.]*\\boverpair\\b'),
    World2PairSemanticsTruthV1.underpair: RegExp('$actor[^.]*\\bunderpair\\b'),
    World2PairSemanticsTruthV1.twoPair: RegExp('$actor[^.]*\\btwo pair\\b'),
    World2PairSemanticsTruthV1.trips: RegExp('$actor[^.]*\\btrips\\b'),
    World2PairSemanticsTruthV1.set: RegExp('$actor[^.]*\\bset\\b'),
  };
  for (final entry in patterns.entries) {
    if (entry.value.hasMatch(text)) {
      return entry.key;
    }
  }
  return null;
}

int? _detectExplicitActorPairRankV1({
  required String actor,
  required String text,
}) {
  final match = RegExp(
    '$actor[^.]*\\bpair of (twos|threes|fours|fives|sixes|sevens|eights|nines|tens|jacks|queens|kings|aces)\\b',
  ).firstMatch(text);
  if (match == null) {
    return null;
  }
  return _rankLabelToValueV1(match.group(1)!);
}

World2MadeHandTruthV1 _deriveMadeHandTruthV1({
  required List<String> holeCards,
  required List<String> boardCards,
}) {
  final holeRanks = holeCards.map(_rankValueV1).toList();
  final boardRanks = boardCards.map(_rankValueV1).toList();
  final rankCounts = _rankCountsV1(<int>[...holeRanks, ...boardRanks]);
  final pairRanks = _ranksWithCountV1(rankCounts, 2);
  final tripRanks = _ranksWithCountV1(rankCounts, 3);
  final hasStraightFlush = _hasStraightFlushV1(
    holeCards: holeCards,
    boardCards: boardCards,
  );
  final hasFlush = _hasFlushV1(holeCards: holeCards, boardCards: boardCards);
  final hasStraight = _hasStraightV1(
    holeCards: holeCards,
    boardCards: boardCards,
  );
  if (hasStraightFlush) {
    return const World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.straightFlush,
      pairRanksDesc: <int>[],
    );
  }
  if (rankCounts.values.contains(4)) {
    return World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.quads,
      pairRanksDesc: _ranksWithMinimumCountV1(rankCounts, 2),
    );
  }
  if ((tripRanks.isNotEmpty && pairRanks.isNotEmpty) || tripRanks.length >= 2) {
    return World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.fullHouse,
      pairRanksDesc: <int>[
        if (tripRanks.isNotEmpty) tripRanks.first,
        if (tripRanks.length >= 2)
          tripRanks[1]
        else if (pairRanks.isNotEmpty)
          pairRanks.first,
      ],
    );
  }
  if (hasFlush) {
    return const World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.flush,
      pairRanksDesc: <int>[],
    );
  }
  if (hasStraight) {
    return const World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.straight,
      pairRanksDesc: <int>[],
    );
  }
  if (tripRanks.isNotEmpty) {
    final tripRank = tripRanks.first;
    final isPocketPair =
        holeRanks[0] == holeRanks[1] && holeRanks[0] == tripRank;
    return World2MadeHandTruthV1(
      category: isPocketPair
          ? World2MadeHandCategoryV1.set
          : World2MadeHandCategoryV1.trips,
      pairRanksDesc: <int>[tripRank],
    );
  }
  if (pairRanks.length >= 2) {
    return World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.twoPair,
      pairRanksDesc: pairRanks.take(2).toList(growable: false),
    );
  }
  if (pairRanks.length == 1) {
    return World2MadeHandTruthV1(
      category: World2MadeHandCategoryV1.onePair,
      pairRanksDesc: pairRanks,
    );
  }
  return const World2MadeHandTruthV1(
    category: World2MadeHandCategoryV1.highCard,
    pairRanksDesc: <int>[],
  );
}

Map<int, int> _rankCountsV1(List<int> ranks) {
  final rankCounts = <int, int>{};
  for (final rank in ranks) {
    rankCounts.update(rank, (value) => value + 1, ifAbsent: () => 1);
  }
  return rankCounts;
}

List<int> _ranksWithCountV1(Map<int, int> rankCounts, int count) {
  return rankCounts.entries
      .where((entry) => entry.value == count)
      .map((entry) => entry.key)
      .toList()
    ..sort((a, b) => b.compareTo(a));
}

List<int> _ranksWithMinimumCountV1(Map<int, int> rankCounts, int count) {
  return rankCounts.entries
      .where((entry) => entry.value >= count)
      .map((entry) => entry.key)
      .toList()
    ..sort((a, b) => b.compareTo(a));
}

bool _boardHasPairV1(List<int> boardRanks) {
  return _rankCountsV1(boardRanks).values.any((count) => count >= 2);
}

bool _madeHandHasStraightV1(World2MadeHandTruthV1 madeHand) {
  return madeHand.category == World2MadeHandCategoryV1.straight ||
      madeHand.category == World2MadeHandCategoryV1.straightFlush;
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

int _rankLabelToValueV1(String label) {
  switch (label) {
    case 'twos':
      return 2;
    case 'threes':
      return 3;
    case 'fours':
      return 4;
    case 'fives':
      return 5;
    case 'sixes':
      return 6;
    case 'sevens':
      return 7;
    case 'eights':
      return 8;
    case 'nines':
      return 9;
    case 'tens':
      return 10;
    case 'jacks':
      return 11;
    case 'queens':
      return 12;
    case 'kings':
      return 13;
    case 'aces':
      return 14;
  }
  throw StateError('Unsupported rank label: $label');
}

String _rankLabelPluralV1(int rank) {
  switch (rank) {
    case 2:
      return 'twos';
    case 3:
      return 'threes';
    case 4:
      return 'fours';
    case 5:
      return 'fives';
    case 6:
      return 'sixes';
    case 7:
      return 'sevens';
    case 8:
      return 'eights';
    case 9:
      return 'nines';
    case 10:
      return 'tens';
    case 11:
      return 'jacks';
    case 12:
      return 'queens';
    case 13:
      return 'kings';
    case 14:
      return 'aces';
  }
  throw StateError('Unsupported rank value: $rank');
}

bool _hasFlushV1({
  required List<String> holeCards,
  required List<String> boardCards,
}) {
  final suitCounts = <String, int>{};
  for (final card in <String>[...holeCards, ...boardCards]) {
    final suit = card.substring(card.length - 1).toLowerCase();
    suitCounts.update(suit, (value) => value + 1, ifAbsent: () => 1);
  }
  return suitCounts.values.any((count) => count >= 5);
}

bool _hasStraightV1({
  required List<String> holeCards,
  required List<String> boardCards,
}) {
  final ranks = <int>{
    for (final card in <String>[...holeCards, ...boardCards])
      _rankValueV1(card),
  };
  if (ranks.contains(14)) {
    ranks.add(1);
  }
  final sorted = ranks.toList()..sort();
  var streak = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == sorted[i - 1] + 1) {
      streak += 1;
      if (streak >= 5) return true;
    } else {
      streak = 1;
    }
  }
  return false;
}

bool _hasStraightFlushV1({
  required List<String> holeCards,
  required List<String> boardCards,
}) {
  final bySuit = <String, List<int>>{};
  for (final card in <String>[...holeCards, ...boardCards]) {
    final suit = card.substring(card.length - 1).toLowerCase();
    bySuit.putIfAbsent(suit, () => <int>[]).add(_rankValueV1(card));
  }
  for (final suitRanks in bySuit.values) {
    if (suitRanks.length < 5) continue;
    final rankSet = suitRanks.toSet();
    if (rankSet.contains(14)) {
      rankSet.add(1);
    }
    final sorted = rankSet.toList()..sort();
    var streak = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        streak += 1;
        if (streak >= 5) return true;
      } else {
        streak = 1;
      }
    }
  }
  return false;
}

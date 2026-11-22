import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_decision_v1.dart';
import 'act0_catalog_snapshot_v1.dart';

final _cause = RegExp(
  r'\b(?:because|so|which|lets?|makes?|keeps?|folds|calls|denies|loses|saves|wins|gives)\b',
  caseSensitive: false,
);
final _response = RegExp(
  r'\b(?:opponents?|players?|caller|bettor|raiser|blinds?|villain|they|he|she|BB|SB|BTN|CO|HJ|UTG|hands?)\b'
  r'[^.!?]{0,55}\b(?:call|fold|raise|continue|pay|check|bet|shove|give up|draw)\w*\b',
  caseSensitive: false,
);
final _loss = RegExp(
  r'\b(?:loses?|lost|costs?|gives? up|giving up|miss(?:es)?|free card|cheap flop|wastes?|'
  r'pays? (?:more|too)|risks? (?:more|too|chips)|surrenders?|fold(?:s|ing)? out|forfeits?)\b',
  caseSensitive: false,
);
final _bbMention = RegExp(r'\b(\d+(?:\.\d+)?)\s*BB\b', caseSensitive: false);

String _withoutBbAmounts(String text) => text.replaceAll(_bbMention, ' ');
final _card = RegExp(r'(?<![a-zA-Z0-9])(?:[2-9TJQKA][cdhs]){2}(?![a-zA-Z0-9])');
final _attributedHand = RegExp(
  r'\b(?:opponent|villain|bettor|raiser|caller|they|he|she|BB|SB|BTN|CO|HJ|UTG)\s+'
  r'(?:has|holds|shows|checks with|calls with|raises with|bets with|shoves with)\s+'
  r'(?:(?:exactly|a hand like)\s+)?([2-9TJQKA][ -][2-9TJQKA]|[2-9TJQKA]{2}[os])\b',
  caseSensitive: false,
);

String _normalized(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

bool _saysAction(String text, String? action) {
  final words = switch (action) {
    'raise' =>
      r'rais(?:e[sd]?|ing)|open(?:s|ing|ed)?|re-?rais(?:e[sd]?|ing)|[345]-bet(?:s|ting)?',
    'call' => r'call(?:s|ed|ing)?|limp(?:s|ed|ing)?',
    'fold' => r'fold(?:s|ed|ing)?',
    'check' => r'check(?:s|ed|ing)?',
    'bet' => r'bet(?:s|ting)?',
    'shove' => r'shov(?:e[sd]?|ing)|all[ -]in',
    _ => null,
  };
  return words != null &&
      RegExp('\\b(?:$words)\\b', caseSensitive: false).hasMatch(text);
}

bool _mentionsOption(
  String text,
  Act0RunnerOptionV1 option, {
  Act0RunnerOptionV1? contrast,
}) {
  final action = catalogActionV1(option.label);
  final label = _normalized(option.label);
  final exactLabel =
      label.isNotEmpty && ' ${_normalized(text)} '.contains(' $label ');
  if (action == null) return exactLabel;
  if (!_saysAction(text, action)) return false;
  if (contrast == null || catalogActionV1(contrast.label) != action)
    return true;

  final size = _bbMention
      .firstMatch('${option.label} ${option.amountLabel}')
      ?.group(1);
  if (size == null) return exactLabel && label != _normalized(contrast.label);
  return text
      .split(RegExp(r'[!?]|(?<!\d)\.|\.(?!\d)'))
      .any(
        (clause) =>
            _saysAction(clause, action) &&
            _bbMention
                .allMatches(clause)
                .any(
                  (match) =>
                      double.parse(match.group(1)!) == double.parse(size),
                ),
      );
}

bool _hasTableFact(String text, CatalogDecisionLedgerV1 decision) {
  final table = decision.table;
  final seats = [
    for (final seat in table.seats)
      if (seat.isOccupied) RegExp.escape(seat.seatLabel),
    if (table.seats.any((seat) => seat.isDealerButton)) 'button',
    if (table.seats.any((seat) => seat.isSmallBlind)) 'small blind',
    if (table.seats.any((seat) => seat.isBigBlind)) 'big blind',
  ];
  if (seats.isNotEmpty &&
      RegExp(
        '\\b(?:${seats.join('|')})\\b',
        caseSensitive: false,
      ).hasMatch(_withoutBbAmounts(text))) {
    return true;
  }
  final cards = [...table.heroCards, ...table.boardCards];
  for (final card in cards) {
    if (RegExp(
      '\\b${RegExp.escape('${card.rank}${card.suit}')}\\b',
      caseSensitive: false,
    ).hasMatch(text)) {
      return true;
    }
  }
  if (table.heroCards.length == 2) {
    final first = table.heroCards.first;
    final second = table.heroCards.last;
    final suffix = first.rank == second.rank
        ? ''
        : first.suit == second.suit
        ? 's'
        : 'o';
    final hand = '${first.rank}${second.rank}$suffix';
    if (RegExp(
      '\\b${RegExp.escape(hand)}\\b',
      caseSensitive: false,
    ).hasMatch(text))
      return true;
  }
  final ledger = decision.ledger;
  if (ledger == null) return false;
  final amounts = ledger.amounts(
    seatIds: decision.occupiedSeatIds,
    actorSeatId: table.heroSeat.seatId,
  );
  final numbers = {
    if (ledger.fromStreet.name == 'preflop') amounts.potBb,
    if (amounts.toCallBb case final amount?) amount,
    for (final entry in ledger.entries) entry.amountBb,
    ...decision.effectiveStacks.values,
  };
  return RegExp(r'\b(\d+(?:\.\d+)?)\s*BB\b', caseSensitive: false)
      .allMatches(text)
      .any((match) => numbers.contains(double.parse(match.group(1)!)));
}

bool _preChoiceContains(String assumption, Iterable<String> texts) {
  final needle = _normalized(assumption);
  if (needle.isEmpty) return false;
  if (texts.any((text) => ' ${_normalized(text)} '.contains(' $needle ')))
    return true;
  const fillers = {
    'a',
    'an',
    'the',
    'in',
    'on',
    'of',
    'and',
    'is',
    'are',
    'that',
    'this',
    'example',
    'assume',
  };
  final keywords = needle
      .split(' ')
      .where((word) => !fillers.contains(word))
      .toSet();
  return keywords.length >= 2 &&
      texts.any(
        (text) => _normalized(text).split(' ').toSet().containsAll(keywords),
      );
}

String _handKey(String text) =>
    text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();

Set<String> _shownOpponentHands(Act0TableStateV1 table) {
  return {
    for (final seat in table.seats)
      if (!seat.isHero &&
          seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp &&
          seat.holeCards.length == 2) ...[
        seat.holeCards
            .map((card) => _handKey('${card.rank}${card.suit}'))
            .join(),
        seat.holeCards.reversed
            .map((card) => _handKey('${card.rank}${card.suit}'))
            .join(),
        seat.holeCards.map((card) => card.rank.toUpperCase()).join(),
        seat.holeCards.reversed.map((card) => card.rank.toUpperCase()).join(),
      ],
  };
}

bool _claimsHiddenHand(
  String text,
  Act0TableStateV1 table,
  Iterable<String> disclosed,
) {
  final shown = _shownOpponentHands(table);
  final hero = table.heroCards;
  final heroKeys = {
    if (hero.length == 2)
      hero.map((card) => _handKey('${card.rank}${card.suit}')).join(),
    if (hero.length == 2)
      hero.reversed.map((card) => _handKey('${card.rank}${card.suit}')).join(),
  };
  for (final match in _card.allMatches(text)) {
    final key = _handKey(match[0]!);
    if (!shown.contains(key) &&
        !heroKeys.contains(key) &&
        !disclosed.any((line) => _handKey(line).contains(key)))
      return true;
  }
  for (final match in _attributedHand.allMatches(text)) {
    final key = _handKey(match[1]!);
    final rankKey = key.length == 3 ? key.substring(0, 2) : key;
    if (!shown.contains(rankKey) &&
        !disclosed.any((line) => _handKey(line).contains(key)))
      return true;
  }
  return false;
}

class CatalogReasoningResultV1 {
  const CatalogReasoningResultV1(
    this.kind,
    this.findings,
    this.eligibleShortStack,
    this.stackMatters,
  );

  final Act0DecisionKindV1? kind;
  final Map<int, Set<String>> findings;
  final bool eligibleShortStack;
  final bool stackMatters;
}

CatalogReasoningResultV1? auditCatalogReasoningV1(
  CatalogTask row, {
  Map<String, Act0DecisionReasoningV1> reasoning = act0DecisionReasoningV1,
}) {
  final task = row.task;
  final runner = task.runner;
  final kind = catalogDecisionKindV1(task, row.world.worldNumber);
  final entry = reasoning[task.taskId];
  final findings = <int, Set<String>>{};
  void flag(int rule, [String? option]) {
    findings.putIfAbsent(rule, () => {}).add(option ?? task.taskId);
  }

  final correct = runner.options.where(act0RunnerOptionIsPreferredV1).toList();
  for (final option in runner.options) {
    final text = '${option.feedbackTitle} ${option.feedbackReason}';
    if (option.quality == Act0FeedbackQualityV1.suboptimal &&
        entry?.suboptimalKinds[option.id] == null) {
      flag(36, option.id);
    }
    if (option.quality == Act0FeedbackQualityV1.acceptable &&
        (!RegExp(
              r'\balso (?:playable|works)\b',
              caseSensitive: false,
            ).hasMatch(text) ||
            !correct.any(
              (better) => _mentionsOption(text, better, contrast: option),
            ))) {
      flag(37, option.id);
    }
    if (option.quality == Act0FeedbackQualityV1.coCorrect &&
        !correct.any(
          (other) =>
              other.id != option.id &&
              other.quality == Act0FeedbackQualityV1.coCorrect &&
              _mentionsOption(text, other, contrast: option),
        )) {
      flag(37, option.id);
    }
  }
  if (kind == null) {
    return findings.isEmpty
        ? null
        : CatalogReasoningResultV1(null, findings, false, false);
  }
  bool knownPrinciple(String id) =>
      (act0PrinciplesV1[id] ?? 99) <= row.world.worldNumber;
  if (entry == null ||
      entry.taskId != task.taskId ||
      entry.kind != kind ||
      !knownPrinciple(entry.principleId) ||
      !entry.secondaryPrincipleIds.every(knownPrinciple)) {
    flag(26);
  }
  final alternatives = runner.options.where(
    (option) => option.id == entry?.bestAlternativeOptionId,
  );
  final alternative = alternatives.singleOrNull;
  if (alternative == null ||
      alternative.quality == Act0FeedbackQualityV1.correct)
    flag(27);

  final beforeChoice = [
    runner.caption,
    catalogQuestion(task),
    for (final step in runner.teachingSteps) '${step.title} ${step.body}',
  ];
  final assumption = entry?.preChoiceAssumption;
  if (assumption != null && !_preChoiceContains(assumption, beforeChoice))
    flag(32);
  if (entry?.edgeBb == 0 &&
      (alternative?.quality == Act0FeedbackQualityV1.wrong ||
          alternative?.quality == Act0FeedbackQualityV1.suboptimal)) {
    flag(33, alternative!.id);
  }
  if (kind == Act0DecisionKindV1.process) {
    return CatalogReasoningResultV1(kind, findings, false, false);
  }

  final decision = CatalogDecisionLedgerV1(runner.table);
  for (final option in correct) {
    final text = option.feedbackReason;
    if (!_cause.hasMatch(text) || !_hasTableFact(text, decision))
      flag(28, option.id);
    final compared = alternative?.id == option.id
        ? correct.where((other) => other.id != option.id).singleOrNull
        : alternative;
    if (compared == null ||
        !_mentionsOption(text, compared, contrast: option)) {
      flag(29, option.id);
    }
    if (decision.facingWager &&
        ((entry?.opponentRead?.trim().isEmpty ?? true) ||
            !_response.hasMatch(_withoutBbAmounts(text)))) {
      flag(30, option.id);
    }
  }
  for (final option in runner.options) {
    final text = option.feedbackReason;
    if ((option.quality == Act0FeedbackQualityV1.wrong ||
            option.quality == Act0FeedbackQualityV1.suboptimal) &&
        !correct.any(
          (better) => _mentionsOption(text, better, contrast: option),
        ) &&
        !_loss.hasMatch(text)) {
      flag(31, option.id);
    }
    if (_claimsHiddenHand(text, runner.table, [
      runner.caption,
      if (assumption != null) assumption,
    ])) {
      flag(34, option.id);
    }
  }
  final shortStack = decision.effectiveStacks.values.any((bb) => bb < 50);
  return CatalogReasoningResultV1(
    kind,
    findings,
    shortStack,
    shortStack && entry?.stackMatters == true,
  );
}

final reasoningCatalogRowsV1 = <CatalogTask>[
  ...catalogTasks,
  ...rulesCheckCatalogTasks,
  ...day7CatalogTasks,
];

Map<String, Object> catalogReasoningBaselineV1() {
  final byWorld = <String, Map<String, List<String>>>{};
  final shortStack = <String, List<String>>{};
  final stackSensitive = <String, List<String>>{};
  for (final row in reasoningCatalogRowsV1) {
    final result = auditCatalogReasoningV1(row);
    if (result == null) continue;
    final world = row.world.worldId;
    final task = row.task.taskId;
    final worldRules = byWorld.putIfAbsent(world, () => {});
    for (final rule in result.findings.entries) {
      worldRules.putIfAbsent('${rule.key}', () => []).addAll([
        for (final id in rule.value) id == task ? task : '$task|$id',
      ]);
    }
    if (result.eligibleShortStack)
      shortStack.putIfAbsent(world, () => []).add(task);
    if (result.stackMatters)
      stackSensitive.putIfAbsent(world, () => []).add(task);
  }
  return {
    'findings_by_world': {
      for (final world in byWorld.entries)
        world.key: {
          for (final rule in [26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37])
            if (world.value['$rule'] case final ids?)
              '$rule': ids.toSet().toList()..sort(),
        },
    },
    'short_stacks_by_world': {
      for (final world in shortStack.entries)
        world.key: world.value.toSet().toList()..sort(),
    },
    'stack_matters_by_world': {
      for (final world in stackSensitive.entries)
        world.key: world.value.toSet().toList()..sort(),
    },
  };
}

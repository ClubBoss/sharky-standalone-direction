import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';

final _beforeYou = RegExp(r'\bthe player before you\b', caseSensitive: false);
final _worldCode = RegExp(r'\bW\d+\b');
final _streetPrefix = RegExp(
  r'^(preflop|flop|turn|river)(?::\s*|\s+)',
  caseSensitive: false,
);

Iterable<(String, String)> _learnerCopy(Act0LessonTaskV1 task) sync* {
  final runner = task.runner;
  yield ('caption', runner.caption);
  yield ('question', runner.question);
  yield ('displayed question', catalogQuestion(task));
  yield ('feedback title', runner.feedbackTitle);
  yield ('feedback', runner.feedbackReason);
  for (final (index, step) in runner.teachingSteps.indexed) {
    yield ('teach $index title', step.title);
    yield ('teach $index', step.body);
    for (final label in step.focusLabels) {
      yield ('teach $index focus', label);
    }
  }
  for (final option in runner.options) {
    yield ('option ${option.id}', option.label);
    yield ('preferred ${option.id}', option.betterAnswerLabel);
    yield ('feedback ${option.id} title', option.feedbackTitle);
    yield ('feedback ${option.id}', option.feedbackReason);
  }
}

List<String> catalogWorldCodeFindingsV1(Act0LessonTaskV1 task) => [
  for (final (surface, copy) in _learnerCopy(task))
    if (_worldCode.hasMatch(copy)) '${task.taskId}: $surface: $copy',
];

const _bankrollAmount = r'(\d+(?:\.\d+)?|one hundred|[a-z]+(?:-[a-z]+)?)';
const _buyInUnit = r'[-\s]+(?:full[-\s]+)?buy[-\s]?ins?\b';
const _moveDirection = r'mov(?:e|ing)[-\s]+(up|down)';
final _bankrollThresholdPatterns = [
  (
    RegExp(
      r'\b' +
          _moveDirection +
          r'\s+(?:(?:line|floor|threshold|trigger)\s+(?:is|of|at)\s+|'
              r'(?:at|below|under|with|when you (?:have|fall below))\s+)' +
          _bankrollAmount +
          '(?:$_buyInUnit' +
          r'|(?=\s+(?:at|for)\s+(?:the |your )?(?:current|next|this) stake\b))',
      caseSensitive: false,
    ),
    2,
  ),
  (
    RegExp(
      r'\b(?:keep|maintain|set aside|at least|requires?|needs?|'
              r'(?:buffer|floor|minimum|threshold|requirement|rule) (?:of|is|at))\s+' +
          _bankrollAmount +
          _buyInUnit +
          r'(?!\s+(?:more|less|short|above|below)\b)',
      caseSensitive: false,
    ),
    1,
  ),
  (
    RegExp(
      r'\b' +
          _bankrollAmount +
          _buyInUnit +
          r'\s+(?:(?:course|cash-game|bankroll)\s+)?(?:rule|plan|floor|minimum|'
              r'buffer|threshold|requirement|needs?|(?:is|are) (?:required|needed))\b',
      caseSensitive: false,
    ),
    1,
  ),
];
final _personalBankrollRule = RegExp(
  r'\bpersonal (?:cash(?:-game)? )?(?:bankroll )?(?:rule|policy|plan)\b',
  caseSensitive: false,
);
final _standardBankrollRule = RegExp(
  r'\b(?:sharky|course|standard|default)\b',
  caseSensitive: false,
);
final _sentenceBreak = RegExp(r'(?<=[.!?])\s+');

const _bankrollNumberWords = {
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'eleven': 11,
  'twelve': 12,
  'thirteen': 13,
  'fourteen': 14,
  'fifteen': 15,
  'sixteen': 16,
  'seventeen': 17,
  'eighteen': 18,
  'nineteen': 19,
  'twenty': 20,
  'thirty': 30,
  'forty': 40,
  'fifty': 50,
  'sixty': 60,
  'seventy': 70,
  'eighty': 80,
  'ninety': 90,
  'one hundred': 100,
};

num? _readBankrollAmount(String amount) {
  final numeric = num.tryParse(amount);
  if (numeric != null) return numeric;
  final parts = amount.toLowerCase().split('-');
  if (!parts.every(_bankrollNumberWords.containsKey)) return null;
  return parts.fold<int>(0, (sum, word) => sum + _bankrollNumberWords[word]!);
}

typedef BankrollThresholdV1 = ({String surface, num buyIns, bool isPersonal});

Iterable<({String? direction, num buyIns})> _bankrollThresholdsInText(
  String text,
) sync* {
  for (final (pattern, amountGroup) in _bankrollThresholdPatterns) {
    for (final match in pattern.allMatches(text)) {
      if (_readBankrollAmount(match[amountGroup]!) case final buyIns?) {
        yield (
          direction: amountGroup == 2 ? match[1]!.toLowerCase() : null,
          buyIns: buyIns,
        );
      }
    }
  }
}

/// Checks policy thresholds rather than balances or shortfalls. An explicit
/// custom rule applies only to the amount and direction stated before choice.
Iterable<BankrollThresholdV1> bankrollThresholdsInCopyV1({
  required Iterable<(String, String)> copy,
  required Iterable<String> preChoice,
}) sync* {
  final personal = {
    for (final text in preChoice)
      for (final sentence in text.split(_sentenceBreak))
        if (_personalBankrollRule.hasMatch(sentence) &&
            !_standardBankrollRule.hasMatch(sentence))
          ..._bankrollThresholdsInText(sentence),
  };
  for (final (surface, text) in copy) {
    for (final sentence in text.split(_sentenceBreak)) {
      for (final threshold in _bankrollThresholdsInText(sentence)) {
        yield (
          surface: surface,
          buyIns: threshold.buyIns,
          isPersonal:
              !_standardBankrollRule.hasMatch(sentence) &&
              personal.contains(threshold),
        );
      }
    }
  }
}

Iterable<BankrollThresholdV1> catalogBankrollThresholdsV1(
  Act0LessonTaskV1 task,
) => bankrollThresholdsInCopyV1(
  copy: [
    ('title', task.title),
    ('summary', task.summary ?? ''),
    ('lesson title', task.runner.lessonTitle),
    ('lesson subtitle', task.runner.lessonSubtitle),
    ('hint', task.runner.hint),
    ..._learnerCopy(task),
  ],
  preChoice: [task.runner.caption, catalogQuestion(task)],
);

typedef _Action = ({int index, String seat, String verb});

List<String> _relativeTrailFindings(
  Act0TableStateV1 table, {
  bool hasCopyClaim = false,
}) {
  final trail = table.actionTrail;
  if (!hasCopyClaim &&
      !trail.any((item) => _beforeYou.hasMatch(item.learnerLabel))) {
    return [];
  }
  final occupied = {
    for (final seat in table.seats)
      if (seat.isOccupied) seat.seatLabel.trim().toUpperCase(),
  };
  final hero = table.seats
      .where((seat) => seat.seatId == table.heroSeatId || seat.isHero)
      .firstOrNull
      ?.seatLabel
      .trim()
      .toUpperCase();
  final order = table.canonicalSeatOrder.where(occupied.contains).toList();
  final button = order.indexOf('BTN');
  final rounds = <String, List<_Action>>{};
  var street = 'preflop';
  for (final (index, item) in trail.indexed) {
    if (item.isNote) continue;
    final source = item.label.trim();
    final prefix = _streetPrefix.firstMatch(source);
    street = prefix?[1]?.toLowerCase() ?? street;
    final words = source.substring(prefix?.end ?? 0).split(RegExp(r'\s+'));
    final token = words.first.toUpperCase();
    final seat = token == 'HERO' ? hero : token;
    // Keep unrecognized actors as intervening actions, so sparse trails
    // cannot make an unproved adjacency pass.
    final verb = words.length >= 2 ? words[1].toLowerCase() : '';
    if (const {'blind', 'ante'}.contains(verb)) continue;
    rounds.putIfAbsent(street, () => []).add((
      index: index,
      seat: seat ?? '',
      verb: verb,
    ));
  }
  final unavailable = <String>{};
  final valid = <int>{};
  for (final (street, actions) in rounds.entries.map((e) => (e.key, e.value))) {
    final streetOrder = (street == 'preflop' || button < 0)
        ? order
        : [...order.skip(button + 1), ...order.take(button + 1)];
    final eligible = streetOrder
        .where((seat) => !unavailable.contains(seat))
        .toList();
    final heroIndex = eligible.indexOf(hero ?? '');
    if (heroIndex > 0 && (street == 'preflop' || button >= 0)) {
      for (final (index, action) in actions.indexed) {
        if (action.seat != eligible[heroIndex - 1]) continue;
        final after = actions.skip(index + 1);
        final intervening = after.takeWhile((next) => next.seat != hero);
        if (intervening.isEmpty) valid.add(action.index);
      }
    }
    unavailable.addAll([
      for (final action in actions)
        if (const {
          'fold',
          'folds',
          'all-in',
          'shove',
          'shoves',
          'jam',
          'jams',
        }.contains(action.verb))
          action.seat,
    ]);
  }
  final lastAction = rounds[street]?.lastOrNull;
  return [
    for (final (index, item) in trail.indexed)
      if (_beforeYou.hasMatch(item.learnerLabel) && !valid.contains(index))
        'trail $index: ${item.learnerLabel}',
    if (hasCopyClaim &&
        (lastAction == null ||
            !valid.contains(lastAction.index) ||
            street != table.streetLabel.trim().toLowerCase()))
      'decision copy lacks an adjacent preceding actor on this street',
  ];
}

List<String> catalogRelativeSeatFindingsV1(Act0LessonTaskV1 task) {
  final runner = task.runner;
  return [
    ..._relativeTrailFindings(
      runner.table,
      hasCopyClaim: _learnerCopy(task).any(
        (entry) =>
            !entry.$1.startsWith('teach ') && _beforeYou.hasMatch(entry.$2),
      ),
    ),
    for (final (index, step) in runner.teachingSteps.indexed)
      for (final finding in _relativeTrailFindings(
        step.table ?? runner.table,
        hasCopyClaim: [
          step.title,
          step.body,
          ...step.focusLabels,
        ].any(_beforeYou.hasMatch),
      ))
        'teach $index: $finding',
  ].map((finding) => '${task.taskId}: $finding').toList();
}

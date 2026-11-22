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

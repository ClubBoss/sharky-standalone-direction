import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _ranks = 'AKQJT98765432';
const _openingSeats = ['UTG', 'HJ', 'CO', 'BTN'];
const _groups = {'premium', 'strong', 'medium', 'trash'};
const _actions = {'raise', 'fold', 'call', 'trash_fold'};

final _tasks = [
  for (final world in Act0ShellStateV1.sample.worlds)
    if (world.worldNumber == 2 || world.worldNumber == 3)
      for (final lesson in world.lessons) ...lesson.taskList,
];

Set<String> _handCodes(String entry) {
  final pairs = RegExp(r'^([AKQJT2-9])\1–([AKQJT2-9])\2$').firstMatch(entry);
  if (pairs != null) {
    return {
      for (final rank
          in _ranks
              .substring(
                _ranks.indexOf(pairs[1]!),
                _ranks.indexOf(pairs[2]!) + 1,
              )
              .split(''))
        '$rank$rank',
    };
  }

  final hand = RegExp(
    r'^([AKQJT2-9]{2})(?: (suited|offsuit))?$',
  ).firstMatch(entry);
  if (hand == null) throw FormatException('Unknown chart hand: $entry');
  final ranks = hand[1]!;
  if (ranks[0] == ranks[1]) return {ranks};
  return switch (hand[2]) {
    'suited' => {'${ranks}s'},
    'offsuit' => {'${ranks}o'},
    _ => {'${ranks}s', '${ranks}o'},
  };
}

String _tableHand(Act0TableStateV1 table) {
  final cards = table.heroCards;
  expect(cards, hasLength(2));
  final ranks = [for (final card in cards) card.rank == '10' ? 'T' : card.rank]
    ..sort((a, b) => _ranks.indexOf(a).compareTo(_ranks.indexOf(b)));
  expect(ranks.every(_ranks.contains), isTrue);
  if (ranks[0] == ranks[1]) return ranks.join();
  return '${ranks.join()}${cards[0].suit == cards[1].suit ? 's' : 'o'}';
}

typedef _ChartRow = ({String group, List<String> seats});

void main() {
  final steps = _tasks
      .singleWhere((task) => task.taskId == 'hand_discipline_buckets_intro')
      .runner
      .teachingSteps;
  final opening = <String, _ChartRow>{};
  final openingText = steps
      .singleWhere((step) => step.body.startsWith('Sharky starting chart'))
      .body;
  // Read the rows that are shown to the learner, so changing a grade and
  // separately changing the lesson cannot accidentally drift apart.
  final rows = openingText.split('\n').where((line) => line.contains(' | '));
  final [weakGroup, otherHands, weakRule] = rows.last.split(' | ');
  if (weakGroup != 'Weak' ||
      !otherHands.startsWith('Other hands') ||
      weakRule != 'Fold.') {
    throw FormatException('Unknown fallback rule: ${rows.last}');
  }
  for (final row in rows.take(rows.length - 1)) {
    final [group, hands, rule] = row.split(' | ');
    final start = RegExp(
      r'^Open from (UTG|HJ|CO|BTN) through BTN\.$',
    ).firstMatch(rule);
    if (start == null) throw FormatException('Unknown opening rule: $rule');
    final seats = _openingSeats.skip(_openingSeats.indexOf(start[1]!)).toList();
    for (final entry in hands.split(', ')) {
      for (final hand in _handCodes(entry)) {
        if (opening.containsKey(hand)) {
          throw FormatException('Overlapping rows for $hand');
        }
        opening[hand] = (group: group, seats: seats);
      }
    }
  }

  final facingRaiseText = steps
      .singleWhere((step) => step.title == 'On BTN after a raise.')
      .body;
  final facingRaise = RegExp(
    r'^Against one (\w+) or (\w+) raise, this chart calls on (\w+) with ([^.]+)\. It folds Weak hands',
  ).firstMatch(facingRaiseText);
  if (facingRaise == null) {
    throw FormatException('Unknown facing-raise rule: $facingRaiseText');
  }
  final callHands = facingRaise[4]!.split(RegExp(r', | or ')).toSet();
  final openers = {facingRaise[1]!, facingRaise[2]!};

  test('starting chart has the intended AJ and KJ opening boundaries', () {
    for (final code in ['AJo', 'ATo']) {
      expect(opening[code]?.group, 'Medium');
      expect(opening[code]?.seats, ['HJ', 'CO', 'BTN']);
    }
    for (final code in ['KJs', 'KJo']) {
      expect(opening[code]?.group, 'Medium');
      expect(opening[code]?.seats, ['CO', 'BTN']);
    }
    expect(callHands, contains('KJs'));
  });

  test('W2–W3 chart decisions match the teaching rows and the table', () {
    final problems = <String>[];
    var checked = 0;
    for (final task in _tasks) {
      final runner = task.runner;
      if (runner.options.isEmpty) continue;
      final correct = runner.options.singleWhere(
        act0RunnerOptionIsAuthoredCorrectV1,
      );
      final refersToChart = [
        runner.question,
        runner.feedbackReason,
        ...runner.options.map((option) => option.feedbackReason),
      ].any((text) => text.toLowerCase().contains('starting chart'));
      final isChartAnswer =
          _groups.contains(correct.id) || _actions.contains(correct.id);
      if (!refersToChart &&
          !(isChartAnswer && runner.table.streetLabel == 'Preflop'))
        continue;
      checked++;

      final hand = _tableHand(runner.table);
      final openingRow = opening[hand];
      final group = openingRow?.group ?? weakGroup;
      final seat = runner.table.heroSeat.seatId.toUpperCase();
      final raisers = runner.table.seats
          .where((s) => s.bet?.kind == Act0SeatBetKindV1.raise)
          .map((s) => s.seatId.toUpperCase())
          .toList();
      final String? expected;
      final String actual;
      if (_groups.contains(correct.id)) {
        expected = group;
        actual = correct.label;
      } else {
        if (raisers.isEmpty) {
          expected = (openingRow?.seats.contains(seat) ?? false)
              ? 'raise'
              : 'fold';
        } else if (raisers.length == 1 &&
            openers.contains(raisers.single) &&
            seat == facingRaise[3]) {
          expected = callHands.contains(hand)
              ? 'call'
              : group == weakGroup
              ? 'fold'
              : null;
        } else {
          expected = null;
        }
        actual = correct.id == 'trash_fold' && group == weakGroup
            ? 'fold'
            : correct.id;
      }
      if (actual != expected) {
        problems.add(
          '${task.taskId}: $hand ($group) on $seat, raisers $raisers. '
          'Chart says ${expected ?? 'no rule'} but catalog grades $actual.',
        );
      }
    }
    expect(checked, greaterThan(30), reason: 'Chart assessment coverage');
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}

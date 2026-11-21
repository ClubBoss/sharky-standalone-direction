import 'dart:math' as math;

import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';
import 'act0_pot_showdown_truth_v1.dart';

const _epsilon = 1e-9;
final _betInto = RegExp(
  r'(?<![-\w])(?:bets?\s+(\d+(?:\.\d+)?)(?:\s*BB)?|(\d+(?:\.\d+)?)\s*BB\s+bet)'
  r'\s+into\s+(?:an?\s+)?(\d+(?:\.\d+)?)\b',
  caseSensitive: false,
);
final _potNow = RegExp(
  r'\b(?:pot\s+(?:is\s+)?now|brings?\s+the\s+pot\s+to)\s+(\d+(?:\.\d+)?)\s*BB\b',
  caseSensitive: false,
);
final _callEquity = RegExp(
  r'\b(?:needs?\s+(?:(?:about|roughly|at least)\s+)?(\d+(?:\.\d+)?)%'
  r'|(?:about|roughly)\s+(\d+(?:\.\d+)?)%\s+(?:equity|(?:immediate\s+)?pot odds)\b'
  r'|(?:immediate\s+)?threshold\s+of\s+(?:about\s+)?(\d+(?:\.\d+)?)%)',
  caseSensitive: false,
);
final _effectiveStack = RegExp(
  r'\beffective stack (?:is|of) (\d+(?:\.\d+)?)\s*BB\b'
  r'|\b(\d+(?:\.\d+)?)\s*BB is the effective stack\b',
  caseSensitive: false,
);
final _afterChoice = RegExp(
  r'\b(?:both players then have|leaves both players)\s*$',
  caseSensitive: false,
);
final _stack = RegExp(
  r'\b(?:(UTG\+1|UTG\+2|UTG|LJ|HJ|CO|BTN|SB|BB)[’\x27]s\s+'
  r'|(both)\s+started\s+the\s+(preflop|flop|turn|river)\s+with\s+'
  r'|(\d+(?:\.\d+)?)\s*BB\s+and\s+)?'
  r'(\d+(?:\.\d+)?)\s*BB\s+(effective|behind)\b',
  caseSensitive: false,
);

typedef _Copy = ({String field, String text, Act0TableStateV1 table});

Iterable<_Copy> _numericCopy(CatalogTask row) sync* {
  final runner = row.task.runner;
  final table = runner.table;
  yield (field: 'caption', text: runner.caption, table: table);
  yield (field: 'hint', text: runner.hint, table: table);
  yield (field: 'question', text: catalogQuestion(row.task), table: table);
  yield (field: 'feedbackTitle', text: runner.feedbackTitle, table: table);
  yield (field: 'feedbackReason', text: runner.feedbackReason, table: table);
  for (final (index, step) in runner.teachingSteps.indexed) {
    final stepTable = step.table ?? table;
    yield (field: 'theory[$index].title', text: step.title, table: stepTable);
    yield (field: 'theory[$index].body', text: step.body, table: stepTable);
  }
  for (final option in runner.options) {
    yield (
      field: 'option[${option.id}].title',
      text: option.feedbackTitle,
      table: table,
    );
    yield (
      field: 'option[${option.id}].reason',
      text: option.feedbackReason,
      table: table,
    );
  }
}

double _net(Act0ContributionV1 entry) =>
    entry.kind == Act0ContributionKindV1.uncalledReturn
    ? -entry.amountBb
    : entry.amountBb;

class _DecisionAmounts {
  _DecisionAmounts(this.table);

  final Act0TableStateV1 table;
  late final ledger = table.handContributions;
  late final hero =
      table.heroSeatId ??
      table.seats.where((seat) => seat.isHero).firstOrNull?.seatId;
  late final actor = table.decisionSeatId ?? table.activeSeatId ?? hero;
  late final _seats = {
    for (final seat in table.seats)
      if (seat.isOccupied) seat.seatId,
  };
  late final _amounts = ledger?.amounts(seatIds: _seats, actorSeatId: actor);
  late final shownPot = potTruthBbV1(table.potLabel.replaceFirst('Pot ', ''));
  late final shownCall = potTruthBbV1(
    table.toCallLabel.replaceFirst('To call ', ''),
  );
  // A street-only ledger gives the delta, with the collected pot carried
  // forward from the table. C1 separately checks the ledger and shown price.
  late final pot = ledger?.fromStreet == PokerStreet.preflop
      ? _amounts?.potBb
      : shownPot;
  late final call = _amounts?.toCallBb;
  late final _entries = ledger?.entries ?? const <Act0ContributionV1>[];
  late final _wagerIndex = _entries.lastIndexWhere(
    (entry) =>
        entry.street == ledger!.throughStreet &&
        entry.kind == Act0ContributionKindV1.wager,
  );
  Act0ContributionV1? get wager =>
      _wagerIndex < 0 ? null : _entries[_wagerIndex];
  double? get potBeforeWager => pot == null || _wagerIndex < 0
      ? null
      : pot! - _entries.skip(_wagerIndex).map(_net).fold(0.0, (a, b) => a + b);

  double? stack(
    String? seat, {
    PokerStreet? startOf,
    bool beforeWager = false,
  }) {
    final start = ledger?.startingStackBbBySeat[seat];
    if (start != null) {
      if (startOf != null && startOf.index < ledger!.fromStreet.index) {
        return null;
      }
      final entries = beforeWager && _wagerIndex >= 0
          ? _entries.take(_wagerIndex)
          : _entries;
      return start -
          entries
              .where(
                (entry) =>
                    entry.seatId == seat &&
                    (startOf == null || entry.street.index < startOf.index),
              )
              .map(_net)
              .fold(0.0, (a, b) => a + b);
    }
    final label = potTruthBbV1(
      table.seats.where((s) => s.seatId == seat).firstOrNull?.stackLabel ?? '',
    );
    if (label == null ||
        ledger != null && beforeWager && seat == wager?.seatId) {
      return null;
    }
    if (startOf == null) return label;
    if (table.streetLabel != pokerStreetToString(startOf)) return null;
    // A label is a decision-frame stack, so add back known street chips
    // before comparing it with copy about the start of that street.
    return label +
        _entries
            .where((entry) => entry.street == startOf && entry.seatId == seat)
            .map(_net)
            .fold(0.0, (a, b) => a + b);
  }

  double? get effectiveStack {
    final own = stack(hero, beforeWager: true);
    final other = stack(opponent, beforeWager: true);
    return own == null || other == null ? null : math.min(own, other);
  }

  String? get opponent => wager?.seatId != null && wager!.seatId != hero
      ? wager!.seatId
      : table.seats
            .where((seat) => seat.isOccupied && seat.isInHand && !seat.isHero)
            .singleOrNull
            ?.seatId;
}

void auditCatalogNumericCopy(
  CatalogTask row, {
  required void Function(String rule) count,
  required Set<String> findings,
}) {
  final amountsByTable = <Act0TableStateV1, _DecisionAmounts>{};
  for (final copy in _numericCopy(row)) {
    if (copy.table.seats.isEmpty) continue;
    final amounts = amountsByTable.putIfAbsent(
      copy.table,
      () => _DecisionAmounts(copy.table),
    );
    void compare(
      String rule,
      RegExpMatch match,
      double actual,
      double? expected, {
      double tolerance = _epsilon,
      String part = '',
    }) {
      count(rule);
      if (expected != null &&
          (actual - expected).abs() <= tolerance + _epsilon) {
        return;
      }
      final detail = expected == null
          ? 'no source amount'
          : 'expected $expected';
      findings.add(
        '$rule|${row.world.worldId}|${row.task.taskId}|${copy.field}|'
        '${match[0]}|$part$detail',
      );
    }

    for (final match in _betInto.allMatches(copy.text)) {
      compare(
        '22.bet_into_pot',
        match,
        double.parse((match[1] ?? match[2])!),
        amounts.wager?.amountBb,
        part: 'bet ',
      );
      compare(
        '22.bet_into_pot',
        match,
        double.parse(match[3]!),
        amounts.potBeforeWager,
        part: 'before bet ',
      );
    }
    for (final match in _potNow.allMatches(copy.text)) {
      compare('23.pot_with_bet', match, double.parse(match[1]!), amounts.pot);
    }
    for (final match in _callEquity.allMatches(copy.text)) {
      final call = amounts.call;
      // The percentage is a price claim only in a frame facing a price.
      if ((call ?? amounts.shownCall ?? 0) <= 0) continue;
      final pot = amounts.pot;
      compare(
        '24.call_equity',
        match,
        double.parse((match[1] ?? match[2] ?? match[3])!),
        call == null || pot == null ? null : 100 * call / (pot + call),
        tolerance: 1,
      );
    }
    for (final match in _effectiveStack.allMatches(copy.text)) {
      compare(
        '25.street_stack',
        match,
        double.parse((match[1] ?? match[2])!),
        amounts.effectiveStack,
      );
    }
    for (final match in _stack.allMatches(copy.text)) {
      // Explicit consequences of choosing a line describe a different frame.
      if (_afterChoice.hasMatch(copy.text.substring(0, match.start))) continue;
      final seat = match[1]?.toLowerCase() ?? amounts.hero;
      final both = match[2] != null;
      final street = match[3];
      final paired = match[4];
      final value = double.parse(match[5]!);
      final effective = match[6]!.toLowerCase() == 'effective';
      final startOf = street == null ? null : pokerStreetFromString(street);
      final stack = amounts.stack(seat, startOf: startOf);
      if (effective) {
        compare('25.street_stack', match, value, amounts.effectiveStack);
      } else if (paired != null || both) {
        final other = amounts.stack(amounts.opponent, startOf: startOf);
        if (paired != null) {
          compare(
            '25.street_stack',
            match,
            double.parse(paired),
            stack,
            part: 'first stack ',
          );
          compare(
            '25.street_stack',
            match,
            value,
            other,
            part: 'second stack ',
          );
        } else {
          compare('25.street_stack', match, value, stack, part: 'hero ');
          compare('25.street_stack', match, value, other, part: 'opponent ');
        }
      } else {
        compare('25.street_stack', match, value, stack);
      }
    }
  }
}

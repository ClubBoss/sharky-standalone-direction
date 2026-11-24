import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_betting_ledger_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';

// Only histories claiming complete coverage are required to replay from
// blinds. Partial drills and missing histories are counted separately.
const _baseline = <({String taskId, String reason})>[];

String? _check(Act0HandTimelinePrefixV1 history, {String? actor}) {
  final seats = history.startingStacks.keys.toList();
  final ledger = Act0HandBettingLedgerV1(
    [
      for (final (index, seat) in seats.indexed)
        (number: index + 1, stackCents: history.startingStacks[seat]!),
    ],
    seats.length,
    seats.indexOf(history.button) + 1,
    history.smallBlind,
    history.bigBlind,
    allowShortRaises: true,
  );
  final actions = history.events.whereType<Act0HandActionV1>().toList();
  // Antes may precede the blinds, but voluntary actions may not.
  final posts = actions.where((a) => a.verb != Act0HandVerbV1.ante);
  if (posts.length < 2 ||
      posts.first.verb != Act0HandVerbV1.smallBlind ||
      posts.elementAt(1).verb != Act0HandVerbV1.bigBlind) {
    return 'Missing or misordered blind posts';
  }

  var pot = 0;
  final remaining = Map.of(history.startingStacks);
  final wagers = <String, int>{};
  for (final (index, event) in history.events.indexed) {
    final location = 'event ${index + 1}';
    switch (event) {
      case Act0HandDealV1():
        if (!ledger.advance()) return 'Unsettled betting at $location';
        wagers.clear();
      case Act0HandActionV1():
        final seat = seats.indexOf(event.seat) + 1;
        if (!ledger.add((
          street: event.street,
          seat: seat,
          kind: event.verb,
          cents: event.chipsAdded.abs(),
        ))) {
          return 'Illegal action at $location';
        }
        pot += event.chipsAdded;
        remaining[event.seat] = remaining[event.seat]! - event.chipsAdded;
        if (event.verb != Act0HandVerbV1.ante) {
          wagers.update(
            event.seat,
            (value) => value + event.chipsAdded,
            ifAbsent: () => event.chipsAdded,
          );
        }
        if ((wagers[event.seat] ?? 0) != event.streetTotal) {
          return 'Incorrect street total at $location';
        }
    }

    if (pot < 0 || ledger.potCents != pot) {
      return 'Incorrect pot at $location';
    }
    final highest = wagers.values.fold(0, max);
    final prefix = history.takeEvents(index + 1);
    for (final (seatIndex, seat) in seats.indexed) {
      final stack = remaining[seat]!;
      if (stack < 0 || ledger.remaining[seatIndex + 1] != stack) {
        return 'Incorrect remaining stack at $location for $seat';
      }
      final expectedPrice = min(stack, highest - (wagers[seat] ?? 0));
      final amounts = prefix.contributions.amounts(
        seatIds: history.startingStacks.keys.toSet(),
        actorSeatId: seat,
      );
      if ((amounts.potBb * history.bigBlind - pot).abs() > 1e-7 ||
          (amounts.toCallBb! * history.bigBlind - expectedPrice).abs() > 1e-7 ||
          ledger.highest - ledger.contributed(seatIndex + 1) !=
              highest - (wagers[seat] ?? 0)) {
        return 'Incorrect pot or call price at $location for $seat';
      }
    }
  }
  if (actor != null && ledger.nextActor != seats.indexOf(actor) + 1) {
    return 'Incorrect decision actor';
  }
  return null;
}

Act0HandTimelinePrefixV1 _fixture(
  List<({PokerStreet street, String seat, Act0HandVerbV1 verb, int chipsAdded})>
  actions,
) => Act0HandTimelineV1.fromDeltas(
  coverage: Act0HandHistoryCoverageV1.complete,
  startingStacks: const {'BTN': 2000, 'SB': 350, 'BB': 2000},
  button: 'BTN',
  smallBlind: 50,
  bigBlind: 100,
  board: const [],
  actions: actions,
).beforeDecision;

Act0HandDeltaV1 _action(String seat, Act0HandVerbV1 verb, int chips) =>
    (street: PokerStreet.preflop, seat: seat, verb: verb, chipsAdded: chips);

void main() {
  test('E40: W1–W12 history coverage and complete-history ratchet', () {
    final coverage = {
      for (final value in Act0HandHistoryCoverageV1.values) value: <String>[],
    };
    final violations = <({String taskId, String reason})>[];
    final rows = catalogTasks.where(
      (row) => row.world.worldNumber >= 1 && row.world.worldNumber <= 12,
    );
    expect(rows.map((row) => row.world.worldNumber).toSet(), {
      for (var world = 1; world <= 12; world++) world,
    });

    for (final row in rows) {
      final task = row.task;
      final table = task.runner.table;
      coverage[table.handHistoryCoverage]!.add(task.taskId);
      if (table.handHistoryCoverage != Act0HandHistoryCoverageV1.complete) {
        continue;
      }
      final history = table.handTimelinePrefix!;
      final reason = _check(
        history,
        actor: table.decisionSeatId ?? table.activeSeatId,
      );
      if (reason != null) {
        violations.add((taskId: task.taskId, reason: reason));
      }
    }
    for (final entry in coverage.entries) {
      print(
        '${entry.key.name}: ${entry.value.length} ${entry.value.join(", ")}',
      );
    }
    expect(coverage[Act0HandHistoryCoverageV1.complete], isNotEmpty);
    expect(
      violations,
      unorderedEquals(_baseline),
      reason: 'New violations or fixed baseline entries: update the ratchet.',
    );
  });

  final blinds = [
    _action('SB', Act0HandVerbV1.smallBlind, 50),
    _action('BB', Act0HandVerbV1.bigBlind, 100),
  ];
  final open = _action('BTN', Act0HandVerbV1.raise, 300);
  final shortAllIn = _action('SB', Act0HandVerbV1.raise, 300);
  final call = _action('BB', Act0HandVerbV1.call, 250);

  test('missing blind fails completeness', () {
    expect(
      _check(_fixture([blinds.last, open])),
      'Missing or misordered blind posts',
    );
  });
  test('out-of-turn action fails at the third event', () {
    expect(
      _check(_fixture([...blinds, shortAllIn])),
      'Illegal action at event 3',
    );
  });
  test('short all-in does not reopen a previous actor’s right to raise', () {
    final legal = [...blinds, open, shortAllIn, call];
    expect(_check(_fixture(legal), actor: 'BTN'), isNull);
    expect(
      _check(_fixture([...legal, _action('BTN', Act0HandVerbV1.raise, 250)])),
      'Illegal action at event 6',
    );
  });
}

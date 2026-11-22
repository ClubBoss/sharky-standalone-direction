import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_snapshot_v1.dart';
import 'act0_pot_showdown_truth_v1.dart';

typedef Act0ChipLabelFindingV1 = ({
  String task,
  String frame,
  String rule,
  String anchor,
  bool? passes,
  String detail,
});

bool _same(double? shown, double expected) =>
    shown != null && (shown - expected).abs() < 1e-9;

final _street = RegExp(
  r'^(Preflop|Flop|Turn|River)(?=:| dealt\b)',
  caseSensitive: false,
);
final _amount = RegExp(
  r'(\d+(?:\.\d+)?)\s*(?:BB\s*)?(more|total|BB\b)',
  caseSensitive: false,
);

// Source trail labels use street totals for raises, calls and all-ins.
// A learner label can additionally state the new chips as an explicit "more".
PotTruthActionV1? _action(Act0TableStateV1 table, String label) =>
    potTruthParseActionV1(
      table,
      label.replaceFirstMapped(
        RegExp(r'\b(opens|raises)(?! to\b)\s+(?=\d)', caseSensitive: false),
        (_) => 'raises to ',
      ),
    );

Iterable<Act0ChipLabelFindingV1> auditAct0TableChipLabelsV1(
  String task,
  String frame,
  Act0TableStateV1 table,
) sync* {
  Act0ChipLabelFindingV1 finding(
    String rule,
    String anchor,
    bool? passes,
    String detail,
  ) => (
    task: task,
    frame: frame,
    rule: rule,
    anchor: anchor,
    passes: passes,
    detail: detail,
  );

  if (!PokerStreet.values.any(
    (street) => pokerStreetToString(street) == table.streetLabel,
  ))
    return;

  final ledger = table.handContributions;
  final visibleStreet = pokerStreetFromString(table.streetLabel);
  // Chip labels are checked where the frame displays a stack or wager.
  // Some teaching frames intentionally omit seat labels to keep the clue local.
  final liveStakes = <String, double>{};
  final invested = <String, double>{};
  final steps =
      <
        (PokerStreet, String, Act0ContributionKindV1),
        List<({double delta, double total})>
      >{};
  final streetTotals = <(PokerStreet, String), double>{};
  for (final entry in ledger?.entries ?? const <Act0ContributionV1>[]) {
    final key = (entry.street, entry.seatId);
    final delta = entry.kind == Act0ContributionKindV1.uncalledReturn
        ? -entry.amountBb
        : entry.amountBb;
    invested.update(
      entry.seatId,
      (previous) => previous + delta,
      ifAbsent: () => delta,
    );
    if (entry.kind == Act0ContributionKindV1.ante) continue;
    final total = streetTotals.update(
      key,
      (previous) => previous + delta,
      ifAbsent: () => delta,
    );
    if (entry.street == visibleStreet) liveStakes[entry.seatId] = total;
    steps.putIfAbsent((entry.street, entry.seatId, entry.kind), () => []).add((
      delta: delta,
      total: total,
    ));
  }

  final seats = {
    for (final seat in table.seats.where((seat) => seat.isOccupied))
      seat.seatLabel.trim().toUpperCase(): seat,
  };
  final folds = <String, PokerStreet>{};
  final allIns = <String>{};
  final stepIndex = <(PokerStreet, String, Act0ContributionKindV1), int>{};
  var trailStreet = PokerStreet.preflop;
  for (final (i, item) in table.actionTrail.indexed) {
    if (_street.firstMatch(item.label.trim()) case final boundary?) {
      trailStreet = pokerStreetFromString(boundary[1]!);
    }
    final action = _action(table, item.label);
    final seat = seats[action?.actor];
    if (action == null || seat == null) continue;
    final id = seat.seatId;
    if (action.verb == 'fold') folds.putIfAbsent(id, () => trailStreet);
    if (action.chipVerb == 'all_in') allIns.add(id);
    if (!potTruthContributionVerbsV1.contains(action.chipVerb)) continue;
    final kind = action.chipVerb == 'post'
        ? (item.label.toLowerCase().contains('ante')
              ? Act0ContributionKindV1.ante
              : Act0ContributionKindV1.blind)
        : Act0ContributionKindV1.wager;
    final key = (trailStreet, id, kind);
    final index = stepIndex.update(
      key,
      (previous) => previous + 1,
      ifAbsent: () => 0,
    );
    final matching = steps[key];
    for (final (channel, label) in [
      ('label', item.label),
      if (item.displayLabel case final display?) ('displayLabel', display),
    ]) {
      final amounts = _amount.allMatches(label).toList();
      if (amounts.isEmpty) continue;
      final withinLedger =
          ledger != null &&
          trailStreet.index >= ledger.fromStreet.index &&
          trailStreet.index <= ledger.throughStreet.index;
      final step = matching?.elementAtOrNull(index);
      final valid =
          step != null &&
          amounts.every((match) {
            final purpose = match[2]!.toLowerCase();
            final isDelta =
                purpose == 'more' ||
                (purpose != 'total' &&
                    (action.chipVerb == 'bet' || action.chipVerb == 'post'));
            return _same(
              double.parse(match[1]!),
              isDelta ? step.delta : step.total,
            );
          });
      yield finding(
        '22.action_amount',
        '$i/$channel',
        withinLedger ? valid : null,
        "${trailStreet.name}/$id '$label' vs ledger increment/total ${step?.delta}/${step?.total} BB",
      );
    }
  }

  for (final seat in seats.values) {
    final id = seat.seatId;
    final chip = seat.bet;
    final folded = folds[id];
    final start = ledger?.startingStackBbBySeat[id];
    final remaining = start == null ? null : start - (invested[id] ?? 0);
    if (seat.stackLabel != null) {
      yield finding(
        '22.stack',
        id,
        remaining == null
            ? null
            : _same(potTruthBbV1(seat.stackLabel), remaining),
        '$id shows ${seat.stackLabel}, ledger has $remaining BB behind',
      );
    }
    final wager = liveStakes[id] ?? 0;
    if (chip != null || seat.currentBetLabel != null) {
      final labels = [
        if (chip != null) chip.amountLabel,
        if (seat.currentBetLabel != null) seat.currentBetLabel,
      ];
      final aligned = ledger?.throughStreet == visibleStreet;
      yield finding(
        '22.seat_wager',
        id,
        aligned
            ? labels.isNotEmpty &&
                  (chip == null || wager > 0) &&
                  labels.every((text) => _same(potTruthBbV1(text), wager))
            : null,
        '$id shows $labels, ledger has $wager BB on ${visibleStreet.name}',
      );
    }
    if (folded != null ||
        seat.isFolded && (chip != null || seat.currentBetLabel != null)) {
      yield finding(
        '22.folded_wager',
        id,
        folded == null
            ? null
            : visibleStreet.index <= folded.index ||
                  (chip == null &&
                      (seat.currentBetLabel == null ||
                          _same(potTruthBbV1(seat.currentBetLabel), 0)) &&
                      wager == 0),
        '$id folded on ${folded?.name}, visible street ${visibleStreet.name}, chips ${chip?.amountLabel ?? seat.currentBetLabel}',
      );
    }
    if (chip?.kind == Act0SeatBetKindV1.allIn || allIns.contains(id)) {
      yield finding(
        '22.all_in',
        id,
        allIns.contains(id) &&
            _same(potTruthBbV1(seat.stackLabel), 0) &&
            (remaining == null || _same(remaining, 0)),
        '$id all-in action=${allIns.contains(id)}, stack=${seat.stackLabel}, ledger behind=$remaining',
      );
    }
  }
}

Iterable<Act0ChipLabelFindingV1> auditAct0CatalogChipLabelsV1() sync* {
  for (final row in [
    ...catalogTasks,
    ...rulesCheckCatalogTasks,
    ...day7CatalogTasks,
  ]) {
    final task = row.task;
    final runner = task.runner;
    final tables = {
      'question': runner.table,
      for (final (index, step) in runner.teachingSteps.indexed)
        'teach/$index': act0TeachingTableForRunnerV1(runner.table, step),
      for (final option in runner.options)
        'feedback/${option.id}': act0FeedbackTableForRunnerV1(
          runner: runner.copyWith(
            phase: Act0LessonPhaseV1.review,
            selectedOptionId: option.id,
            teachingStepIndex: runner.teachingSteps.length,
          ),
          taskFamily: task.resolvedTaskFamily,
        ),
    };
    for (final entry in tables.entries) {
      yield* auditAct0TableChipLabelsV1(task.taskId, entry.key, entry.value);
    }
  }
}

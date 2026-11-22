import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_chart_v1.dart';

import 'act0_catalog_decision_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_poker_facts_v1.dart';
import 'act0_pot_showdown_truth_v1.dart';

typedef ChartFindingV1 = ({String rule, String id, String detail});

final _chartReference = RegExp(
  r'\b(?:chart|opening row|bucket)\b',
  caseSensitive: false,
);
final _groupReference = RegExp(r'\b(?:Premium|Strong|Medium|Weak)\b');
final _adaptation = RegExp(
  r'\b(?:short.stack|tournament|bubble|ICM)\b',
  caseSensitive: false,
);
final _rank = '[$act0ChartRanksV1]';
final _handText = '$_rank$_rank[so]?';
final _handPattern = RegExp('\\b($_handText)(?:[–-]($_handText))?\\b');
const _seatText = '(?:UTG|HJ|CO|BTN|SB|BB)';
final _seatPattern = RegExp('\\b$_seatText\\b');
final _preflopPrefix = RegExp(r'^preflop:\s*', caseSensitive: false);

Act0ChartSeatV1? _seat(String label) =>
    Act0ChartSeatV1.values.asNameMap()[label.trim().toLowerCase()];

String? _heroHand(Act0TableStateV1 table) =>
    startingHandCode(physicalCards(table.heroCards));

Act0ChartPrefixV1 chartPrefixV1(CatalogTask row) {
  const unsupported = Act0ChartPrefixV1.notCovered;
  final runner = row.task.runner;
  final table = runner.table;
  final ledger = table.handContributions;
  if (table.tableFormat != Act0TableFormatV1.sixMax ||
      table.scope != Act0TableScopeV1.playedHand ||
      row.world.worldNumber == 10 ||
      _adaptation.hasMatch('${runner.question} ${runner.caption}') ||
      (ledger?.entries.any((e) => e.kind == Act0ContributionKindV1.ante) ??
          false) ||
      (ledger?.startingStackBbBySeat.values.any((stack) => stack <= 20) ??
          false)) {
    return unsupported;
  }

  final openerBySeat = {
    Act0ChartSeatV1.utg: Act0ChartPrefixV1.utgOpen,
    Act0ChartSeatV1.hj: Act0ChartPrefixV1.hjOpen,
    Act0ChartSeatV1.co: Act0ChartPrefixV1.coOpen,
    Act0ChartSeatV1.btn: Act0ChartPrefixV1.btnOpen,
    Act0ChartSeatV1.sb: Act0ChartPrefixV1.sbOpen,
  };
  final trail = table.actionTrail.where((item) => !item.isNote);
  if (trail.isEmpty) return unsupported;
  final hero = _seat(table.heroSeat.seatLabel);
  final folded = <Act0ChartSeatV1>{};
  Act0ChartSeatV1? opener;
  for (final item in trail) {
    final label = item.label.replaceFirst(_preflopPrefix, '');
    if (RegExp(
      r'^(?:UTG|HJ|CO|BTN|SB|BB|Hero) acts$',
      caseSensitive: false,
    ).hasMatch(label)) {
      final marker = label.split(' ').first;
      if (marker.toLowerCase() != 'hero' && _seat(marker) != hero)
        return unsupported;
      continue;
    }
    final action = potTruthParseActionV1(
      table,
      label.replaceFirst(
        RegExp(r' opens(?: to)? ', caseSensitive: false),
        ' raises to ',
      ),
    );
    final actor = _seat(action?.actor ?? '');
    if (action == null || actor == null) return unsupported;
    switch (action.chipVerb ?? action.verb) {
      case 'post':
        if (action.verb == 'fold') folded.add(actor);
      case 'fold':
        folded.add(actor);
      case 'raise_to':
        if (opener != null || actor == hero || action.verb == 'fold') {
          return unsupported;
        }
        opener = actor;
      default:
        return unsupported;
    }
  }
  if (hero == null || (opener != null && opener.index >= hero.index)) {
    return unsupported;
  }
  if (ledger != null) {
    final wagers = ledger.entries.where(
      (e) => e.kind == Act0ContributionKindV1.wager,
    );
    if (wagers.length != (opener == null ? 0 : 1) ||
        wagers.any((e) => e.seatId.toLowerCase() != opener?.name)) {
      return unsupported;
    }
  }
  // An omitted fold can be corroborated by the source seat state; an omitted
  // live entrant cannot be treated as a fold.
  for (final seat in table.seats) {
    final position = _seat(seat.seatLabel);
    if (position != null &&
        position.index < hero.index &&
        position != opener &&
        !seat.isFolded &&
        seat.isInHand &&
        !folded.contains(position)) {
      return unsupported;
    }
  }
  if (opener == null) {
    return Act0ChartPrefixV1.unopened;
  }
  return openerBySeat[opener] ?? unsupported;
}

List<String> _copy(Act0RunnerStateV1 runner) => [
  runner.question,
  runner.caption,
  runner.feedbackReason,
  for (final step in runner.teachingSteps) step.body,
  for (final option in runner.options) option.feedbackReason,
];

Act0ChartActionV1 chartDecisionV1(CatalogTask row) {
  final task = row.task;
  final table = task.runner.table;
  if (decisionStreetV1(table) != PokerStreet.preflop ||
      table.heroCards.length != 2 ||
      table.seats.where((seat) => seat.isHero).length != 1 ||
      task.runner.options
              .where((o) => catalogActionV1(o.label) != null)
              .length <
          2) {
    return Act0ChartActionV1.notCovered;
  }
  final seat = _seat(table.heroSeat.seatLabel);
  final hand = _heroHand(table);
  return seat == null || hand == null
      ? Act0ChartActionV1.notCovered
      : act0ChartActionV1(hand, seat, chartPrefixV1(row));
}

bool chartGradesAgreeV1(String required, Set<String?> actual) =>
    actual.length == 1 && actual.contains(required);

ChartFindingV1? chartGradeFindingV1(CatalogTask row) {
  final runner = row.task.runner;
  if (!_copy(runner).any(
    (copy) => _chartReference.hasMatch(copy) || _groupReference.hasMatch(copy),
  )) {
    return null;
  }
  final chart = chartDecisionV1(row);
  if (chart == Act0ChartActionV1.notCovered) return null;
  final actions = runner.options
      .where(act0RunnerOptionIsAuthoredCorrectV1)
      .map((o) => catalogActionV1(o.label))
      .toSet();
  final hand = _heroHand(runner.table);
  final seat = runner.table.heroSeat.seatLabel;
  final prefix = chartPrefixV1(row);
  var required = chart.name;
  if (chart == Act0ChartActionV1.priceDecision) {
    final ledger = runner.table.handContributions;
    final equity = RegExp(
      r'\bassume\b[^.!?]{0,75}?([0-9]+(?:\.[0-9]+)?)\s*%',
      caseSensitive: false,
    ).firstMatch('${runner.caption} ${runner.question}');
    if (ledger == null ||
        equity == null ||
        runner.options.any(
          (o) => !{'call', 'fold'}.contains(catalogActionV1(o.label)),
        )) {
      return null;
    }
    final amounts = ledger.amounts(
      seatIds: runner.table.seats
          .where((s) => s.isOccupied)
          .map((s) => s.seatId)
          .toSet(),
      actorSeatId: runner.table.heroSeat.seatId,
    );
    final call = amounts.toCallBb ?? 0;
    if (call <= 0) return null;
    final difference =
        double.parse(equity[1]!) / 100 - call / (amounts.potBb + call);
    if (difference.abs() < 1e-9) return null;
    required = difference > 0 ? 'call' : 'fold';
  }
  if (chartGradesAgreeV1(required, actions)) return null;
  return (
    rule: '41',
    id: row.task.taskId,
    detail:
        '$hand $seat ${prefix.name}: correct=${actions.join("/")}; chart=$required',
  );
}

Set<String> _hands(String text) {
  final normalized = text.replaceAllMapped(
    RegExp(r'\b([AKQJT2-9]{2}) (offsuit|suited)\b'),
    (match) => '${match[1]}${match[2] == 'suited' ? 's' : 'o'}',
  );
  final hands = <String>{};
  for (final match in _handPattern.allMatches(normalized)) {
    final start = match[1]!;
    final end = match[2];
    if (end != null) {
      final first = act0ChartRanksV1.indexOf(start[0]);
      final last = act0ChartRanksV1.indexOf(end[0]);
      if (first <= last) {
        for (var index = first; index <= last; index++) {
          final rank = act0ChartRanksV1[index];
          hands.add('$rank$rank');
        }
      }
    } else if (start.length == 2 && start[0] != start[1]) {
      hands.addAll(['${start}s', '${start}o']);
    } else {
      hands.add(start);
    }
  }
  return hands;
}

List<ChartFindingV1> chartCopyFindingsV1(String id, String copy) {
  final result = <ChartFindingV1>[];
  void bad(String detail) => result.add((rule: '42', id: id, detail: detail));
  void check(
    String hand,
    String seat,
    Act0ChartPrefixV1 prefix,
    Act0ChartActionV1 action,
    String quote,
  ) {
    final position = _seat(seat)!;
    final actual = act0ChartActionV1(hand, position, prefix);
    if (actual != action && actual != Act0ChartActionV1.notCovered) {
      bad('$quote → $hand/$seat: ${actual.name}');
    }
  }

  for (final line in copy.split(RegExp(r'[.!?]\s+|\n'))) {
    final group = RegExp(
      r'^\s*(Premium|Strong|Medium):\s*(.+)',
      caseSensitive: false,
    ).firstMatch(line);
    if (group != null && _seatPattern.hasMatch(group[2]!)) {
      final seat = _seatPattern.firstMatch(group[2]!)![0]!;
      final expectedGroup = switch (group[1]!.toLowerCase()) {
        'premium' => Act0ChartGroupV1.premium,
        'strong' => Act0ChartGroupV1.strong,
        _ =>
          seat == 'HJ' ? Act0ChartGroupV1.mediumHj : Act0ChartGroupV1.mediumCo,
      };
      final actual = _hands(group[2]!.replaceAll('QJ suited', 'QJs'));
      final expected = act0ChartGroupsV1[expectedGroup]!;
      if (actual.difference(expected).isNotEmpty ||
          expected.difference(actual).isNotEmpty) {
        bad('${line.trim()} → ${expectedGroup.name}: ${expected.join(", ")}');
      }
      continue;
    }
    if (RegExp(r'\breraise\b', caseSensitive: false).hasMatch(line) &&
        RegExp(r'\bPremium\b', caseSensitive: false).hasMatch(line) &&
        RegExp(r'\bSB\b').hasMatch(line) &&
        RegExp(r'\bBTN\b').hasMatch(line) &&
        !RegExp(r'\bStrong\b', caseSensitive: false).hasMatch(line)) {
      bad('${line.trim()} → SB vs BTN reraises Premium, Strong and Medium-HJ');
    }
    final completeRow =
        RegExp(
          r'(?:first-in|starting) chart',
          caseSensitive: false,
        ).hasMatch(line) &&
        line.contains('Premium') &&
        line.contains('UTG') &&
        line.contains('open');
    if (completeRow && !line.contains('Strong')) {
      bad('${line.trim()} → first-in UTG–BTN includes both Premium and Strong');
    }
    final proseGroup = RegExp(
      r'\bMedium(?: hands)?[ (:]+([0-9AKQJT][^.!?]+?)\s+(?:open from|from)\s+(HJ|CO)\b',
    ).firstMatch(line);
    if (proseGroup != null) {
      final group = proseGroup[2] == 'HJ'
          ? Act0ChartGroupV1.mediumHj
          : Act0ChartGroupV1.mediumCo;
      final expected = act0ChartGroupsV1[group]!;
      final listed = _hands(proseGroup[1]!);
      if (expected.difference(listed).isNotEmpty ||
          listed.difference(expected).isNotEmpty) {
        bad('${proseGroup[0]} → ${group.name}: ${expected.join(", ")}');
      }
    }
    final opening = RegExp(
      '(?:chart opens? ($_handText)|($_handText) (?:can )?opens?(?: first in)?|chart folds? ($_handText))'
      '(?: here)?(?: first in)? (?:from|in|on) ($_seatText)(?: (?:or|through|to|and) ($_seatText|later))?',
    );
    for (final match in opening.allMatches(line)) {
      final seats = <String>{match[4]!};
      final end = match[5];
      if (end != null) {
        final i = _seat(match[4]!)!.index;
        final j = end == 'later'
            ? Act0ChartSeatV1.btn.index
            : _seat(end)!.index;
        seats.addAll(
          Act0ChartSeatV1.values
              .where((s) => s.index >= i && s.index <= j)
              .map((s) => s.name.toUpperCase()),
        );
      }
      for (final hand in _hands(match[1] ?? match[2] ?? match[3]!)) {
        for (final seat in seats) {
          check(
            hand,
            seat,
            Act0ChartPrefixV1.unopened,
            match[3] == null ? Act0ChartActionV1.raise : Act0ChartActionV1.fold,
            match[0]!,
          );
        }
      }
    }
    final explicitFold = RegExp(
      '(?:^|; )\\s*[Ff]old ($_handText) (?:first in )?from ($_seatText)'
      '(?: (?:against|after) (?:one |an? )?($_seatText) (?:open|raise))?'
      r'(?=[.;,]|$)',
    ).firstMatch(line);
    if (explicitFold != null) {
      final prefix = switch (explicitFold[3]) {
        'UTG' => Act0ChartPrefixV1.utgOpen,
        'HJ' => Act0ChartPrefixV1.hjOpen,
        'CO' => Act0ChartPrefixV1.coOpen,
        'BTN' => Act0ChartPrefixV1.btnOpen,
        'SB' => Act0ChartPrefixV1.sbOpen,
        _ => Act0ChartPrefixV1.unopened,
      };
      for (final hand in _hands(explicitFold[1]!)) {
        check(
          hand,
          explicitFold[2]!,
          prefix,
          Act0ChartActionV1.fold,
          explicitFold[0]!,
        );
      }
    }
    final callList = RegExp(
      r'(?:[Cc]all from BTN with |BTN calls with )(.+?)(?=\band folds\b|\.|$)',
    ).firstMatch(line);
    if (callList != null) {
      final hands = _hands(callList[1]!);
      for (final hand in hands) {
        check(
          hand,
          'BTN',
          Act0ChartPrefixV1.hjOpen,
          Act0ChartActionV1.call,
          callList[0]!,
        );
      }
      if (hands.length >= 3 &&
          act0ChartButtonCallsV1.difference(hands).isNotEmpty) {
        bad(
          '${callList[0]} → BTN Medium calls: ${act0ChartButtonCallsV1.join(", ")}',
        );
      }
    }
    final singleCall = RegExp(
      'chart calls? (?:one )?(HJ|CO) (?:raise|open) with ($_handText) (?:from|on) (CO|BTN)',
    ).firstMatch(line);
    if (singleCall != null) {
      for (final hand in _hands(singleCall[2]!)) {
        check(
          hand,
          singleCall[3]!,
          singleCall[1] == 'HJ'
              ? Act0ChartPrefixV1.hjOpen
              : Act0ChartPrefixV1.coOpen,
          Act0ChartActionV1.call,
          singleCall[0]!,
        );
      }
    }
    final weak = RegExp(
      '($_handText) is Weak in the [^.]*chart',
      caseSensitive: false,
    ).firstMatch(line);
    if (weak != null) {
      for (final hand in _hands(weak[1]!)) {
        final actual = act0ChartGroupV1(hand);
        if (actual != Act0ChartGroupV1.weak)
          bad('${weak[0]} → $hand: ${actual.name}');
      }
    }
  }
  return result;
}

Set<ChartFindingV1> chartCatalogFindingsV1(Iterable<CatalogTask> catalog) => {
  for (final row in catalog) ...[
    if (chartGradeFindingV1(row) case final finding?) finding,
    for (final text in _copy(row.task.runner))
      ...chartCopyFindingsV1(row.task.taskId, text),
  ],
};

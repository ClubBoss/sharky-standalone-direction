import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_chart_v1.dart';

import 'act0_catalog_poker_facts_v1.dart';

const _openingSeats = ['UTG', 'HJ', 'CO', 'BTN'];
const startingChartGroups = {'premium', 'strong', 'medium', 'trash'};
const startingChartActions = {'raise', 'fold', 'call', 'trash_fold'};

enum _OpeningGroup { premium, strong, medium }

const _openingRules =
    <({_OpeningGroup group, List<String> entries, String firstSeat})>[
      (
        group: _OpeningGroup.premium,
        entries: ['AA–QQ', 'AK suited'],
        firstSeat: 'UTG',
      ),
      (
        group: _OpeningGroup.strong,
        entries: ['JJ–TT', 'AK offsuit', 'AQ suited', 'AJ suited'],
        firstSeat: 'UTG',
      ),
      (
        group: _OpeningGroup.medium,
        entries: ['AQ offsuit', 'AJ offsuit', 'KQ', 'AT'],
        firstSeat: 'HJ',
      ),
      (
        group: _OpeningGroup.medium,
        entries: ['99–22', 'KJ', 'QJ suited', 'KT', 'QT'],
        firstSeat: 'CO',
      ),
    ];
const _openerSeats = ['HJ', 'CO'];
const _callerSeat = 'BTN';
const _callHands = ['KQo', 'KJs', 'QJs'];
const _weakGroup = 'Weak';

String _groupName(_OpeningGroup group) =>
    group.name[0].toUpperCase() + group.name.substring(1);

String renderStartingChartOpening() => [
  'Sharky 6-max starting chart. Open means the first raise preflop.',
  for (final rule in _openingRules)
    '${_groupName(rule.group)}: ${rule.entries.join(', ')} (${rule.firstSeat}–BTN).',
  '$_weakGroup: other hands (Fold).',
].join('\n\n');

String renderStartingChartFacingRaise() =>
    'Facing one ${_openerSeats.join(' or ')} raise, $_callerSeat calls with '
    '${_callHands.take(_callHands.length - 1).join(', ')} or ${_callHands.last} '
    'and folds $_weakGroup hands (A7o, J8o).';

typedef StartingChartRow = ({String group, List<String> seats});

class CatalogStartingChart {
  const CatalogStartingChart(
    this.opening,
    this.openers,
    this.callHands,
    this.caller,
    this.weakGroup,
  );

  final Map<String, StartingChartRow> opening;
  final Set<String> openers;
  final Set<String> callHands;
  final String caller;
  final String weakGroup;

  factory CatalogStartingChart.foundation() {
    final opening = <String, StartingChartRow>{
      for (final group in act0ChartGroupsV1.entries)
        for (final hand in group.value)
          hand: (
            group: switch (group.key) {
              Act0ChartGroupV1.premium => 'Premium',
              Act0ChartGroupV1.strong => 'Strong',
              _ => 'Medium',
            },
            seats: [
              for (final seat in Act0ChartSeatV1.values)
                if (act0ChartActionV1(hand, seat, Act0ChartPrefixV1.unopened) ==
                    Act0ChartActionV1.raise)
                  seat.name.toUpperCase(),
            ],
          ),
    };
    return CatalogStartingChart(
      opening,
      _openerSeats.toSet(),
      act0ChartButtonCallsV1,
      _callerSeat,
      _weakGroup,
    );
  }

  String? expected(
    Act0TableStateV1 table, {
    required bool groupOnly,
    bool narrowThreeBet = false,
  }) {
    final code = startingHandCode(physicalCards(table.heroCards));
    if (code == null) return null;
    final row = opening[code];
    final group = row?.group ?? weakGroup;
    if (groupOnly) return group;

    final seat = table.heroSeat.seatId.toUpperCase();
    final raisers = chartRaisers(table);
    if (narrowThreeBet) {
      if (raisers.length != 1 ||
          !openers.contains(raisers.single) ||
          _openingSeats.indexOf(seat) <=
              _openingSeats.indexOf(raisers.single)) {
        return null;
      }
      return act0ChartActionV1(
        code,
        Act0ChartSeatV1.values.byName(seat.toLowerCase()),
        raisers.single == 'HJ'
            ? Act0ChartPrefixV1.hjOpen
            : Act0ChartPrefixV1.coOpen,
      ).name;
    }
    if (raisers.isEmpty && _openingSeats.contains(seat)) {
      return (row?.seats.contains(seat) ?? false) ? 'raise' : 'fold';
    }
    if (raisers.length == 1 &&
        raisers.single == 'HJ' &&
        seat == 'CO' &&
        group == weakGroup) {
      return 'fold';
    }
    if (raisers.length == 1 &&
        openers.contains(raisers.single) &&
        seat == caller) {
      if (callHands.contains(code)) return 'call';
      if (group == weakGroup) return 'fold';
    }
    return null;
  }

  String? smallBlindVsButton(Act0TableStateV1 table) {
    final code = startingHandCode(physicalCards(table.heroCards));
    if (code == null) return null;
    return act0ChartActionV1(
      code,
      Act0ChartSeatV1.sb,
      Act0ChartPrefixV1.btnOpen,
    ).name;
  }
}

List<String> chartRaisers(Act0TableStateV1 table) => [
  for (final seat in table.seats)
    if (seat.bet?.kind == Act0SeatBetKindV1.raise) seat.seatId.toUpperCase(),
];

bool referencesStartingChart(Act0RunnerStateV1 runner) => [
  runner.question,
  runner.feedbackReason,
  ...runner.options.map((option) => option.feedbackReason),
].any((text) => text.toLowerCase().contains('starting chart'));

String startingChartActual(Act0RunnerOptionV1 result, String? expected) {
  if (startingChartGroups.contains(result.id)) return result.label;
  if (result.id == 'trash_fold' && expected == 'fold') return 'fold';
  return result.id;
}

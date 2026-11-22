import 'act0_preflop_equity_table_v1.g.dart';
import 'act0_starting_chart_v1.dart';

const act0DefendOpeningSeatsV1 = [Act0ChartSeatV1.co, Act0ChartSeatV1.btn];

final _handIndices = {
  for (final (index, hand) in act0ChartHandsV1.indexed) hand: index,
};

final _equityBySeat = {
  for (final seat in act0DefendOpeningSeatsV1)
    seat:
        act0PreflopEquityByOpeningRangeV1[act0ChartHandsV1
            .where(
              (hand) =>
                  act0ChartActionV1(hand, seat, Act0ChartPrefixV1.unopened) ==
                  Act0ChartActionV1.raise,
            )
            .join(',')],
};

/// Equity in tenths of a percentage point. A changed chart range must be
/// regenerated before it is used to grade a defense.
int? act0PreflopEquityTenthsV1(String hand, Act0ChartSeatV1 opener) {
  final index = _handIndices[hand];
  return index == null ? null : _equityBySeat[opener]?[index];
}

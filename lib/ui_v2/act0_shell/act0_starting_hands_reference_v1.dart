import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_shell_state_v1.dart';
import 'act0_starting_chart_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'skin/act0_skin_tokens_v1.dart';

/// No task currently declares that its chart is safe before answering.
/// Fail closed until a source-owned exemption exists; never infer one from copy.
Act0ChartSeatV1? act0StartingHandsSeatForResultV1(Act0RunnerStateV1 runner) {
  final table = runner.table;
  if (runner.phase != Act0LessonPhaseV1.review ||
      (runner.selectedOptionId?.trim().isEmpty ?? true) ||
      runner.hideTable ||
      table.tableFormat != Act0TableFormatV1.sixMax ||
      table.playerCount != 6 ||
      table.seats.length != 6 ||
      table.streetLabel.trim().toLowerCase() != 'preflop' ||
      table.boardCards.isNotEmpty ||
      (table.handTimelinePrefix != null &&
          table.handTimelinePrefix!.street != PokerStreet.preflop)) {
    return null;
  }
  final heroes = table.seats.where((seat) => seat.isHero && seat.isOccupied);
  if (heroes.length != 1) return null;
  final hero = heroes.single;
  return Act0ChartSeatV1.values
      .where((seat) => seat.name == hero.seatLabel.trim().toLowerCase())
      .firstOrNull;
}

Future<void> showAct0StartingHandsReferenceV1(
  BuildContext context, {
  Act0ChartSeatV1? taskSeat,
}) => showModalBottomSheet<void>(
  context: context,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : null,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Act0SkinTokensV1.surface,
  builder: (_) => Act0StartingHandsReferenceV1(taskSeat: taskSeat),
);

class Act0StartingHandsReferenceV1 extends StatefulWidget {
  const Act0StartingHandsReferenceV1({super.key, this.taskSeat});

  /// In Help the position is fixed to Hero; Learn allows browsing positions.
  final Act0ChartSeatV1? taskSeat;

  @override
  State<Act0StartingHandsReferenceV1> createState() =>
      _Act0StartingHandsReferenceV1State();
}

class _Act0StartingHandsReferenceV1State
    extends State<Act0StartingHandsReferenceV1> {
  late Act0ChartSeatV1 _seat = widget.taskSeat ?? Act0ChartSeatV1.utg;

  Act0ChartActionV1 _action(String hand) =>
      act0ChartActionV1(hand, _seat, Act0ChartPrefixV1.unopened);

  @override
  Widget build(BuildContext context) {
    final covered = _action('AA') != Act0ChartActionV1.notCovered;
    final ranks = act0ChartRanksV1;
    final seatLabel = _seat.name.toUpperCase();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Act0SkinTokensV1.screenGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Act0SkinSheetHeaderV1(
              title: 'Starting hands',
              subtitle: '6-max · $seatLabel · First in',
              trailing: IconButton(
                key: const Key('act0_starting_hands_close'),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: Act0SkinTokensV1.muted,
              ),
            ),
            if (widget.taskSeat == null)
              Wrap(
                spacing: Act0SkinTokensV1.gapSm,
                children: [
                  for (final seat in Act0ChartSeatV1.values)
                    Act0SkinChipV1(
                      key: Key('act0_starting_hands_seat_${seat.name}'),
                      label: seat.name.toUpperCase(),
                      selected: seat == _seat,
                      tone: seat == _seat
                          ? Act0SkinChipToneV1.brass
                          : Act0SkinChipToneV1.neutral,
                      onPressed: () => setState(() => _seat = seat),
                    ),
                ],
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Sharky course chart: only when everyone before you folds. '
                    'Not a response to a raise, limp or short-stack situation.',
                    style: Act0SkinTokensV1.secondary,
                  ),
                  if (!covered)
                    const Text(
                      'The first-in chart does not cover this blind position.',
                      style: Act0SkinTokensV1.body,
                    )
                  else ...[
                    const Text(
                      's = suited · o = offsuit. Scroll sideways for all hands.',
                      style: Act0SkinTokensV1.secondary,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        defaultColumnWidth: const FixedColumnWidth(
                          Act0SkinTokensV1.controlHeight,
                        ),
                        children: [
                          for (var row = 0; row < ranks.length; row++)
                            TableRow(
                              children: [
                                for (var col = 0; col < ranks.length; col++)
                                  _cell(act0StartingHandsCellV1(row, col)),
                              ],
                            ),
                        ],
                      ),
                    ),
                    for (final action in [
                      Act0ChartActionV1.raise,
                      Act0ChartActionV1.fold,
                    ]) ...[
                      Semantics(
                        header: true,
                        child: Text(
                          action.name.toUpperCase(),
                          style: Act0SkinTokensV1.sectionLabel,
                        ),
                      ),
                      Text(
                        act0ChartHandsV1
                            .where((hand) => _action(hand) == action)
                            .join(', '),
                        key: Key('act0_starting_hands_${action.name}'),
                        style: Act0SkinTokensV1.body,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String hand) {
    final action = _action(hand);
    return Semantics(
      label: '$hand, ${action.name}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(Act0SkinTokensV1.gapXs),
        child: Text(
          '$hand\n${action.name}',
          key: Key('act0_starting_hand_$hand'),
          style: Act0SkinTokensV1.captionStyle.copyWith(
            color: action == Act0ChartActionV1.raise
                ? Act0SkinTokensV1.ok
                : Act0SkinTokensV1.muted,
          ),
        ),
      ),
    );
  }
}

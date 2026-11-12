import 'package:flutter/material.dart';
import 'package:poker_analyzer/widgets/hero_range_grid_widget.dart';
import 'package:poker_analyzer/theme/app_colors.dart';

import 'act0_hlp02_math_core_v1.dart';
import 'act0_hlp02_source_price_v1.dart';
import 'act0_hlp02_tool_math_v1.dart';
import 'act0_shell_state_v1.dart';

/// Local teaching controls inside the existing, policy-gated Learn reference.
/// No learning callbacks, persistence, telemetry, exposure ACK or answer oracle.
class Act0Hlp02ToolsV1 extends StatelessWidget {
  const Act0Hlp02ToolsV1({
    super.key,
    required this.lessonId,
    required this.taskId,
    this.sourceTask,
  });

  final String lessonId;
  final String taskId;
  final Act0LessonTaskV1? sourceTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lessonId == 'call_price')
          _ToolSection(
            id: 'price',
            title: 'Price Bar',
            child: _PriceTool(sourceTask: sourceTask, taskId: taskId),
          ),
        if (lessonId == 'blinds_action_order' || lessonId == 'call_price')
          const _ToolSection(
            id: 'units',
            title: 'BB / chips converter',
            child: _UnitsTool(),
          ),
        if (lessonId == 'outs_improvement')
          const _ToolSection(
            id: 'outs',
            title: 'Odds / outs calculator',
            child: _OutsTool(),
          ),
        if (lessonId == 'range_combo_counts')
          const _ToolSection(
            id: 'range',
            title: '13 x 13 range view',
            child: _RangeTool(),
          ),
      ],
    );
  }
}

class _ToolSection extends StatelessWidget {
  const _ToolSection({
    required this.id,
    required this.title,
    required this.child,
  });
  final String id;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    key: Key('hlp02_tool_$id'),
    title: Text(title),
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 16),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: [child],
  );
}

// Bound the teaching UI; the reused pure API retains its own wider validation.
// No exponent, NaN, infinity, sign, grouping or partial parse is accepted.
double? _amount(String raw, {bool positive = false}) {
  if (!RegExp(r'^[0-9]{1,10}(?:\.[0-9]{1,6})?$').hasMatch(raw.trim())) {
    return null;
  }
  final value = double.tryParse(raw.trim());
  if (value == null ||
      !value.isFinite ||
      value > 1000000000 ||
      value < 0 ||
      (positive && value == 0))
    return null;
  return value;
}

String _number(double value) {
  if (value > 0 && value < 0.000001) return '<0.000001';
  final fixed = value.toStringAsFixed(6);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

// Beginner wording per canonical source status. Every unavailable form keeps
// the 'Lesson price unavailable:' prefix; no number is shown unless proven.
String _sourcePriceText(Hlp02SourcePriceReadV1 read) {
  final price = read.price;
  final pot = read.potBeforeCallBb;
  return switch (read.status) {
    Hlp02SourcePriceStatusV1.verified =>
      'Current lesson: ${_number(price!.potBeforeCallChips)} BB before, '
          '${_number(price.additionalCallChips)} BB to call, '
          '${_number(price.potAfterCallChips)} BB after.',
    Hlp02SourcePriceStatusV1.noCallPrice =>
      'Current lesson: ${_number(pot!)} BB in the pot and nothing to call. '
          'No call threshold.',
    Hlp02SourcePriceStatusV1.sidePotUnmodelled =>
      'Lesson price unavailable: an all-in or a call limited by your stack '
          'may create a side pot or return part of a bet, which this '
          'reference does not model.',
    Hlp02SourcePriceStatusV1.contradiction =>
      'Lesson price unavailable: this lesson\'s table labels disagree with '
          'its recorded actions.',
    Hlp02SourcePriceStatusV1.unavailable =>
      'Lesson price unavailable: this lesson does not provide a verified '
          'call and contestable pot. Displayed table labels are not enough.',
  };
}

Widget _field(
  String key,
  String label,
  TextEditingController controller,
  VoidCallback changed, {
  String? hint,
}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: TextField(
    key: Key(key),
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    ),
    onChanged: (_) => changed(),
  ),
);

Widget _result(String key, String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Semantics(liveRegion: true, child: Text(text, key: Key(key))),
);

const _inputHelp =
    'Use numbers from 0 to 1,000,000,000, with up to 6 decimals. '
    'Displayed results are rounded; calculations keep the unrounded value.';

class _UnitsTool extends StatefulWidget {
  const _UnitsTool();
  @override
  State<_UnitsTool> createState() => _UnitsToolState();
}

class _UnitsToolState extends State<_UnitsTool> {
  final _blind = TextEditingController();
  final _value = TextEditingController();
  bool _fromBb = true;
  @override
  void dispose() {
    _blind.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blind = _amount(_blind.text, positive: true);
    final input = _amount(_value.text);
    double? output;
    if (blind != null && input != null) {
      try {
        output = _fromBb
            ? hlp02BbToChipsV1(amountBb: input, bigBlindChips: blind)
            : hlp02ChipsToBbV1(amountChips: input, bigBlindChips: blind);
        // Keep displayed educational quantities inside the declared range.
        // Do not print a large rounded integer as exact chip settlement.
        if (output > 1000000000) output = null;
      } on ArgumentError {
        output = null;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your example. One BB is the size of the big blind, '
          'not a seat or a currency.',
        ),
        DropdownButtonFormField<bool>(
          key: const Key('hlp02_units_direction'),
          value: _fromBb,
          decoration: const InputDecoration(labelText: 'Convert'),
          items: const [
            DropdownMenuItem(value: true, child: Text('BB to chips')),
            DropdownMenuItem(value: false, child: Text('Chips to BB')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _fromBb = value;
              _value.clear();
            });
          },
        ),
        _field(
          'hlp02_units_blind',
          'Big blind (chips)',
          _blind,
          () => setState(() {}),
          hint: 'For example, 200',
        ),
        _field(
          'hlp02_units_amount',
          _fromBb ? 'Amount (BB)' : 'Amount (chips)',
          _value,
          () => setState(() {}),
        ),
        _result(
          'hlp02_units_result',
          output == null
              ? 'Enter a valid amount and a big blind greater than zero. '
                    'The result must not exceed 1,000,000,000.'
              : '${_number(output)} ${_fromBb ? 'chips' : 'BB'}',
        ),
        const Text(
          'Formula: chips = BB x big blind; BB = chips / big blind. '
          'Fractional chips are retained for study. This does not settle a pot.',
        ),
        const Text(_inputHelp),
      ],
    );
  }
}

class _PriceTool extends StatefulWidget {
  const _PriceTool({required this.sourceTask, required this.taskId});
  final Act0LessonTaskV1? sourceTask;
  final String taskId;
  @override
  State<_PriceTool> createState() => _PriceToolState();
}

class _PriceToolState extends State<_PriceTool> {
  final _pot = TextEditingController();
  final _call = TextEditingController();
  String _unit = 'BB';
  @override
  void dispose() {
    _pot.dispose();
    _call.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourceRead = hlp02SourcePriceReadV1(
      sourceTask: widget.sourceTask,
      taskId: widget.taskId,
    );
    final source = sourceRead.price;
    final pot = _amount(_pot.text);
    final call = _amount(_call.text);
    Hlp02CallPriceV1? result;
    var valid = pot != null && call != null;
    if (pot != null && call != null) {
      try {
        result = hlp02CallPriceV1(
          potBeforeCallChips: pot,
          additionalCallChips: call,
        );
      } on ArgumentError {
        valid = false;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _sourcePriceText(sourceRead),
          key: const Key('hlp02_source_price'),
        ),
        if (source != null)
          _PriceResult(price: source, unit: 'BB', id: 'source'),
        if (source != null ||
            sourceRead.status == Hlp02SourcePriceStatusV1.noCallPrice)
          const Text(
            'Source: this hand\'s recorded blinds and actions. The table\'s '
            'pot and to-call labels are only checked against them. Amounts '
            'in BB; no antes, rake or side pots.',
            key: Key('hlp02_source_provenance'),
          ),
        const SizedBox(height: 12),
        const Text('Your own example (separate from the lesson)'),
        DropdownButtonFormField<String>(
          key: const Key('hlp02_price_unit'),
          value: _unit,
          decoration: const InputDecoration(
            labelText: 'Same unit for both amounts',
          ),
          items: const [
            DropdownMenuItem(value: 'BB', child: Text('BB')),
            DropdownMenuItem(value: 'chips', child: Text('Chips')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _unit = value;
              _pot.clear();
              _call.clear();
            });
          },
        ),
        _field(
          'hlp02_price_pot',
          'Pot before call ($_unit)',
          _pot,
          () => setState(() {}),
        ),
        const Text(
          'Include the opponent\'s bet already in the pot. '
          'Exclude your new call; count only the pot you can win.',
        ),
        _field(
          'hlp02_price_call',
          'Additional call cost ($_unit)',
          _call,
          () => setState(() {}),
        ),
        if (!valid)
          _result('hlp02_price_result', 'Enter valid pot and call amounts.')
        else if (result == null)
          _result(
            'hlp02_price_result',
            'No additional call cost. No call threshold.',
          )
        else
          _PriceResult(price: result, unit: _unit, id: 'example'),
        const Text(
          'Formula: call / (pot before call + call). This is a break-even '
          'win-rate threshold for an ordinary pot with no rake, splits, refunds '
          'or future betting. It is not your hand\'s equity or advice to call. '
          'A split awards only your share. Actual equity needs an opponent '
          'range and a model of remaining cards.',
        ),
        const Text(_inputHelp),
      ],
    );
  }
}

class _PriceResult extends StatelessWidget {
  const _PriceResult({
    required this.price,
    required this.unit,
    required this.id,
  });
  final Hlp02CallPriceV1 price;
  final String unit;
  final String id;
  @override
  Widget build(BuildContext context) {
    final pct = price.requiredWinRatePercent.toStringAsFixed(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _result(
          id == 'example' ? 'hlp02_price_result' : 'hlp02_source_result',
          'Before: ${_number(price.potBeforeCallChips)} $unit\n'
          'Call: ${_number(price.additionalCallChips)} $unit\n'
          'After: ${_number(price.potAfterCallChips)} $unit\n'
          'Break-even threshold: $pct%',
        ),
        Semantics(
          label: 'Call is $pct percent of the pot after calling',
          child: ExcludeSemantics(
            child: LinearProgressIndicator(
              key: Key('hlp02_price_bar_$id'),
              value: price.requiredWinRateFraction,
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}

class _OutsTool extends StatefulWidget {
  const _OutsTool();
  @override
  State<_OutsTool> createState() => _OutsToolState();
}

class _OutsToolState extends State<_OutsTool> {
  final _outs = TextEditingController();
  final _dirty = TextEditingController(text: '0');
  Hlp02OutsStreetV1 _street = Hlp02OutsStreetV1.flop;
  int _draws = 1;
  @override
  void dispose() {
    _outs.dispose();
    _dirty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outs = RegExp(r'^[0-9]{1,2}$').hasMatch(_outs.text.trim())
        ? int.tryParse(_outs.text.trim())
        : null;
    final dirty = RegExp(r'^[0-9]{1,2}$').hasMatch(_dirty.text.trim())
        ? int.tryParse(_dirty.text.trim())
        : null;
    Hlp02OutsChanceV1? chance;
    if (outs != null && dirty != null) {
      try {
        chance = hlp02OutsChanceV1(
          street: _street,
          outs: outs,
          dirtyOuts: dirty,
          cardsToCome: _draws,
        );
      } on ArgumentError {
        chance = null;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Chance to hit at least one clean improving card. '
          'Improvement is not a win and is not equity.',
        ),
        DropdownButtonFormField<Hlp02OutsStreetV1>(
          key: const Key('hlp02_outs_street'),
          value: _street,
          decoration: const InputDecoration(labelText: 'Current street'),
          items: const [
            DropdownMenuItem(
              value: Hlp02OutsStreetV1.flop,
              child: Text('Flop'),
            ),
            DropdownMenuItem(
              value: Hlp02OutsStreetV1.turn,
              child: Text('Turn'),
            ),
            DropdownMenuItem(
              value: Hlp02OutsStreetV1.river,
              child: Text('River'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _street = value;
              _draws = value == Hlp02OutsStreetV1.river ? 0 : 1;
            });
          },
        ),
        if (_street == Hlp02OutsStreetV1.flop)
          DropdownButtonFormField<int>(
            key: const Key('hlp02_outs_draws'),
            value: _draws,
            decoration: const InputDecoration(labelText: 'Cards still to see'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Next card only')),
              DropdownMenuItem(value: 2, child: Text('Turn and river')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _draws = value);
            },
          ),
        _field(
          'hlp02_outs_count',
          'Candidate outs (whole cards)',
          _outs,
          () => setState(() {}),
        ),
        _field(
          'hlp02_outs_dirty',
          'Dirty outs to exclude (whole cards)',
          _dirty,
          () => setState(() {}),
        ),
        _result(
          'hlp02_outs_result',
          _street == Hlp02OutsStreetV1.river
              ? 'No cards remain after the river. Improvement chance is unavailable.'
              : chance == null
              ? 'Enter whole-card counts. Dirty outs cannot exceed candidate '
                    'outs; candidate outs cannot exceed unseen cards.'
              : '${chance.cleanOuts} clean outs among ${chance.unseenCards} '
                    'unseen cards\nImprovement chance: ${chance.percent.toStringAsFixed(2)}%\n'
                    'Odds against: ${chance.oddsAgainst == null ? 'no hit possible' : '${chance.oddsAgainst!.toStringAsFixed(2)} to 1'}',
        ),
        const Text(
          'Model: one 52-card deck, two known hole cards and the board. '
          '47 unseen cards on the flop; 46 on the turn. One draw: clean / unseen. '
          'Two draws: 1 - ((47-clean)/47) x ((46-clean)/46), with a certain hit '
          'when fewer than two misses remain. Outs must be a fixed set of '
          'distinct cards. Exclude double-counted and dirty outs yourself; '
          'the calculator does not inspect a hand or identify them. '
          'Extra known dead cards and runner-runner draws need another model. '
          'The rule of 2 and 4 is only an approximation; this tool uses the '
          'exact fixed-set model. Seeing both cards assumes you reach the river.',
        ),
      ],
    );
  }
}

class _RangeTool extends StatefulWidget {
  const _RangeTool();
  @override
  State<_RangeTool> createState() => _RangeToolState();
}

class _RangeToolState extends State<_RangeTool> {
  final _classes = TextEditingController();
  final _blockers = TextEditingController();
  @override
  void dispose() {
    _classes.dispose();
    _blockers.dispose();
    super.dispose();
  }

  List<String> _tokens(String input) =>
      input.trim().isEmpty ? <String>[] : input.trim().split(RegExp(r'[\s,]+'));

  @override
  Widget build(BuildContext context) {
    Hlp02RangeSummaryV1? range;
    try {
      range = hlp02RangeSummaryV1(
        classes: _tokens(_classes.text),
        knownCards: _tokens(_blockers.text),
      );
    } on ArgumentError {
      range = null;
    }
    final selected = range == null
        ? <String>{}
        : _tokens(_classes.text).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '169 hand classes, not 1,326 equally sized cells. '
          'Pairs: 6 combos; suited: 4; offsuit: 12 before blockers.',
        ),
        TextField(
          key: const Key('hlp02_range_classes'),
          controller: _classes,
          decoration: const InputDecoration(
            labelText: 'Selected classes',
            hintText: 'AA, AKs, AKo',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('hlp02_range_blockers'),
          controller: _blockers,
          decoration: const InputDecoration(
            labelText: 'Known cards (blockers)',
            hintText: 'As, Kh',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const Text(
          'Use A K Q J T 9...2 and suits s h d c. Leave blockers empty '
          'when none are known. Duplicate entries count once.',
        ),
        if (range != null) ...[
          const SizedBox(height: 12),
          Semantics(
            label:
                '13 by 13 hand class grid. Pairs on the diagonal, '
                'suited above, offsuit below. The complete selected-class counts '
                'are also written below.',
            child: ExcludeSemantics(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ColoredBox(
                  color: AppColors.darkBackground,
                  child: HeroRangeGridWidget(
                    key: const Key('hlp02_range_grid'),
                    rangeMatrix: [
                      for (var row = 0; row < 13; row++)
                        [
                          for (var column = 0; column < 13; column++)
                            selected.contains(
                                  hlp02RangeClassAtV1(row: row, column: column),
                                )
                                ? 1.0
                                : 0.0,
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          _result(
            'hlp02_range_result',
            '${range.classCount} selected classes / ${range.comboCount} '
                'available selected combos\n${range.availableCombos} total combos '
                'remain after blockers\n'
                '${range.fraction == null ? 'Percentage unavailable: fewer than two cards remain.' : 'Selected share: ${(range.fraction! * 100).toStringAsFixed(2)}%'}',
          ),
          if (range.combosByClass.isNotEmpty)
            Text(
              range.combosByClass.entries
                  .map((entry) => '${entry.key}: ${entry.value} combos')
                  .join('; '),
              key: const Key('hlp02_range_text_alternative'),
            ),
        ] else
          _result(
            'hlp02_range_result',
            'Range unavailable. Use classes such as AA, AKs, AKo and cards '
                'such as As. Each physical card must be possible.',
          ),
        const Text(
          'Source: choose 2 distinct cards from a standard 52-card deck. '
          '13 pair classes x 6 + 78 suited x 4 + 78 offsuit x 12 = 1,326. '
          'Known cards remove every containing combo. Counts use unique '
          'physical pairs, never a sum with duplicates. Cells show your '
          'selected classes; counts below account for blockers. Every selected '
          'available combo has equal weight. This is not an opponent model '
          'or a recommended strategy. Use the text fields and counts as the '
          'accessible alternative to the grid.',
        ),
      ],
    );
  }
}

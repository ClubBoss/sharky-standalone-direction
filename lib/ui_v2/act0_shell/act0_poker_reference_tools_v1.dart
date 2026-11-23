import 'package:flutter/material.dart';

import 'act0_poker_reference_math_v1.dart';
import 'act0_shell_tokens_v1.dart';

class Act0PokerReferenceToolsV1 extends StatefulWidget {
  const Act0PokerReferenceToolsV1({super.key});

  @override
  State<Act0PokerReferenceToolsV1> createState() =>
      _Act0PokerReferenceToolsV1State();
}

class _Act0PokerReferenceToolsV1State extends State<Act0PokerReferenceToolsV1> {
  double? _pot;
  double? _call;
  double? _amount;
  double? _chipsPerBlind;
  int? _outs;
  bool _toChips = true;
  bool _fromFlop = true;

  String _percent(double ratio) => '${(ratio * 100).toStringAsFixed(2)}%';

  String _number(double amount) {
    if (amount != 0 && (amount.abs() < 0.01 || amount.abs() >= 1e7)) {
      return amount.toStringAsPrecision(4);
    }
    return amount.toStringAsFixed(2);
  }

  Widget _input(
    String key,
    String label,
    ValueChanged<String> onChanged, {
    bool integer = false,
  }) => TextField(
    key: Key(key),
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    onChanged: (value) => setState(() => onChanged(value.trim())),
  );

  @override
  Widget build(BuildContext context) {
    final price = act0CallPriceV1(_pot ?? double.nan, _call ?? double.nan);
    final conversion = act0ConvertBlindUnitsV1(
      _amount ?? double.nan,
      _chipsPerBlind ?? double.nan,
      toChips: _toChips,
    );
    final unseen = _fromFlop ? 47 : 46;
    final nextCard = act0OneCardOutsV1(_outs ?? -1, unseen);
    final byRiver = _fromFlop ? act0TwoCardOutsV1(_outs ?? -1, unseen) : null;
    final inputUnit = _toChips ? 'BB' : 'chips';
    final outputUnit = _toChips ? 'chips' : 'BB';
    return Padding(
      padding: const EdgeInsets.only(bottom: Act0ShellTokensV1.gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
            maintainState: true,
            tilePadding: EdgeInsets.zero,
            title: const Text('Price Bar and pot odds'),
            children: [
              const Text(
                'Include the opposing bet in the current pot. Enter both amounts in BB or both in chips. The call can be zero up to the current pot.',
              ),
              _input(
                'act0_tool_pot',
                'Current pot',
                (v) => _pot = double.tryParse(v),
              ),
              _input(
                'act0_tool_call',
                'Amount to call',
                (v) => _call = double.tryParse(v),
              ),
              const Text('Break-even equity = call ÷ (current pot + call).'),
              if (price != null) ...[
                LinearProgressIndicator(
                  value: price.equity,
                  semanticsLabel: 'Break-even equity',
                  semanticsValue: _percent(price.equity),
                ),
                Text(
                  'Pot after call ${_number(price.potAfterCall)} · Break-even equity ${_percent(price.equity)}',
                ),
                if (price.oddsToOne case final odds?)
                  Text('Pot odds ${_number(odds)} to 1')
                else if (_call == 0)
                  const Text('No call required.')
                else
                  const Text('Pot odds exceed the displayable range.'),
              ] else
                const Text('Enter a positive pot and a valid call amount.'),
            ],
          ),
          ExpansionTile(
            maintainState: true,
            tilePadding: EdgeInsets.zero,
            title: const Text('BB and chips'),
            children: [
              DropdownButton<bool>(
                value: _toChips,
                items: const [
                  DropdownMenuItem(value: true, child: Text('BB to chips')),
                  DropdownMenuItem(value: false, child: Text('Chips to BB')),
                ],
                onChanged: (value) => setState(() => _toChips = value!),
              ),
              _input(
                'act0_tool_blind_amount',
                'Amount in $inputUnit',
                (v) => _amount = double.tryParse(v),
              ),
              _input(
                'act0_tool_blind_rate',
                'Chips per 1 BB',
                (v) => _chipsPerBlind = double.tryParse(v),
              ),
              Text(
                _toChips
                    ? 'Chips = BB × chips per BB.'
                    : 'BB = chips ÷ chips per BB.',
              ),
              Text(
                conversion == null
                    ? 'Enter an amount of zero or more and a positive chips-per-BB rate.'
                    : '${_number(conversion)} $outputUnit',
              ),
            ],
          ),
          ExpansionTile(
            maintainState: true,
            tilePadding: EdgeInsets.zero,
            title: const Text('Outs to percentage'),
            children: [
              DropdownButton<bool>(
                value: _fromFlop,
                items: const [
                  DropdownMenuItem(value: true, child: Text('From the flop')),
                  DropdownMenuItem(value: false, child: Text('From the turn')),
                ],
                onChanged: (value) => setState(() => _fromFlop = value!),
              ),
              Text(
                'Count only clean outs. With only your two hole cards and the board known, $unseen cards are unseen. Next-card chance = outs ÷ unseen cards.',
              ),
              if (_fromFlop)
                const Text(
                  'By the river, subtract the chance of missing both draws from 100%. This assumes the same outs stay clean on both draws.',
                ),
              _input(
                'act0_tool_outs',
                'Clean outs (0–$unseen)',
                (v) => _outs = int.tryParse(v),
                integer: true,
              ),
              Text(
                nextCard == null
                    ? 'Enter a whole number from 0 to $unseen.'
                    : 'Next card ${_percent(nextCard)}',
              ),
              if (byRiver != null) Text('By the river ${_percent(byRiver)}'),
            ],
          ),
        ],
      ),
    );
  }
}

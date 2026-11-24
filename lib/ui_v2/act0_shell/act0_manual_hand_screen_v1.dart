import 'act0_shell_chrome_v1.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_club_night_components_v1.dart';
import 'act0_club_night_tokens_v1.dart';
import 'act0_imported_hand_v1.dart';

class Act0ManualHandScreenV1 extends StatefulWidget {
  const Act0ManualHandScreenV1({super.key, this.previous});

  final Act0ImportedHandV1? previous;

  @override
  State<Act0ManualHandScreenV1> createState() => _Act0ManualHandScreenV1State();
}

class _Act0ManualHandScreenV1State extends State<Act0ManualHandScreenV1> {
  int _step = 0;
  int _size = 2;
  final _fields = <String, String>{};
  final _actions = <Act0ImportedActionV1>[];
  List<Act0ImportedSeatV1> _seats = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    final hand = widget.previous;
    if (hand == null) return;
    _size = hand.tableSize;
    _fields.addAll({
      'Button seat': '${hand.buttonSeat}',
      'Your seat': '${hand.heroSeat}',
      'Small blind': '${hand.smallBlindCents}',
      'Big blind': '${hand.bigBlindCents}',
      for (final seat in hand.seats)
        'Seat ${seat.number} stack': '${seat.stackCents}',
      'Your cards': hand.heroCards.join(' '),
      'Flop': hand.board.take(3).join(' '),
      if (hand.board.length >= 4) 'Turn': hand.board[3],
      if (hand.board.length == 5) 'River': hand.board[4],
      for (final entry in hand.shownCards.entries)
        'Seat ${entry.key} shown cards': entry.value.join(' '),
      for (final entry in hand.payouts.entries)
        'Seat ${entry.key} collected': '${entry.value}',
      'Rake': '${hand.rakeCents}',
    });
    _actions.addAll(hand.actions);
  }

  String _value(String field) => _fields[field]?.trim() ?? '';

  int _number(String field, {bool optional = false}) {
    final text = _value(field);
    if (optional && text.isEmpty) return 0;
    final value = int.tryParse(text);
    if (value == null || value < 0 || value > 999999999) {
      throw FormatException(
        'Enter a valid whole number for ${field.toLowerCase()}.',
      );
    }
    return value;
  }

  List<String> _cards(String field) {
    final text = _value(field);
    return text.isEmpty ? [] : text.split(RegExp(r'\s+'));
  }

  List<String> _board() {
    final board = <String>[];
    for (final (index, field) in ['Flop', 'Turn', 'River'].indexed) {
      final cards = _cards(field);
      if (cards.isEmpty) continue;
      final expectedBefore = [0, 3, 4][index];
      if (board.length != expectedBefore ||
          cards.length != (index == 0 ? 3 : 1)) {
        throw FormatException(
          'Enter ${field.toLowerCase()} cards in street order.',
        );
      }
      board.addAll(cards);
    }
    return board;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    try {
      switch (_step) {
        case 0:
          _seats = [
            for (var seat = 1; seat <= _size; seat++)
              if (_value('Seat $seat stack').isNotEmpty)
                (number: seat, stackCents: _number('Seat $seat stack')),
          ];
          final occupied = _seats.map((seat) => seat.number).toSet();
          if (_seats.length < 2 ||
              _seats.any((seat) => seat.stackCents == 0) ||
              !occupied.contains(_number('Button seat')) ||
              !occupied.contains(_number('Your seat'))) {
            throw const FormatException(
              'Enter positive stacks for at least two seats and choose an occupied button and your seat.',
            );
          }
          if (_number('Small blind') <= 0 ||
              _number('Big blind') <= _number('Small blind')) {
            throw const FormatException(
              'The big blind must exceed the positive small blind.',
            );
          }
        case 1:
          if (_cards('Your cards').length != 2) {
            throw const FormatException('Enter two hole cards.');
          }
          _board();
        case 2:
          if (_actions.isEmpty) {
            throw const FormatException(
              'Record the blinds and betting actions.',
            );
          }
        case 3:
          final hand = Act0ImportedHandV1.manual(
            previous: widget.previous,
            tableSize: _size,
            buttonSeat: _number('Button seat'),
            heroSeat: _number('Your seat'),
            smallBlindCents: _number('Small blind'),
            bigBlindCents: _number('Big blind'),
            seats: _seats,
            heroCards: _cards('Your cards'),
            board: _board(),
            actions: _actions,
            shownCards: {
              for (final seat in _seats)
                if (_value('Seat ${seat.number} shown cards').isNotEmpty)
                  seat.number: _cards('Seat ${seat.number} shown cards'),
            },
            payouts: {
              for (final seat in _seats)
                if (_value('Seat ${seat.number} collected').isNotEmpty)
                  seat.number: _number('Seat ${seat.number} collected'),
            },
            rakeCents: _number('Rake'),
          );
          Navigator.of(context).pop(hand);
          return;
      }
      setState(() {
        _step++;
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    }
  }

  Widget _field(String name, {bool cards = false}) => TextFormField(
    key: ValueKey(name),
    initialValue: _fields[name],
    style: Act0ClubNightTokensV1.body,
    decoration: InputDecoration(labelText: name),
    keyboardType: cards ? TextInputType.text : TextInputType.number,
    autocorrect: false,
    enableSuggestions: false,
    onChanged: (value) => _fields[name] = value,
  );

  Future<void> _editAction(PokerStreet street, {int? index}) async {
    final action = await showDialog<Act0ImportedActionV1>(
      context: context,
      builder: (_) => _ActionEditor(
        street: street,
        seats: _seats.map((seat) => seat.number).toList(),
        action: index == null ? null : _actions[index],
      ),
    );
    if (!mounted || action == null) return;
    setState(() {
      if (index == null) {
        final nextStreet = _actions.indexWhere(
          (row) => row.street.index > street.index,
        );
        _actions.insert(nextStreet < 0 ? _actions.length : nextStreet, action);
      } else {
        _actions[index] = action;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final streets = _step == 2 ? _board().length : 0;
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Act0ClubNightTokensV1.wall,
        appBar: AppBar(
          backgroundColor: Act0ClubNightTokensV1.wall,
          automaticallyImplyLeading: false,
          title: Act0ShellRouteHeaderV1(
            title: widget.previous == null ? 'Enter own hand' : 'Edit own hand',
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          key: ValueKey(_step),
          padding: const EdgeInsets.all(Act0ClubNightTokensV1.screenGutter),
          children: [
            Text(
              [
                'Seats and blinds',
                'Cards',
                'Actions by street',
                'Payouts and showdown',
              ][_step],
              style: Act0ClubNightTokensV1.title,
            ),
            if (_step == 0) ...[
              const Text(
                'Enter a complete single-pot NLHE hand. Use USD cents and leave empty seats blank. '
                'Side pots are unsupported. Return any uncalled chips after a short all-in call.',
              ),
              DropdownButtonFormField<int>(
                initialValue: _size,
                decoration: const InputDecoration(labelText: 'Table size'),
                items: [
                  for (var size = 2; size <= 9; size++)
                    DropdownMenuItem(value: size, child: Text('$size seats')),
                ],
                onChanged: (size) => setState(() => _size = size!),
              ),
              for (var seat = 1; seat <= _size; seat++)
                _field('Seat $seat stack'),
              for (final name in [
                'Button seat',
                'Your seat',
                'Small blind',
                'Big blind',
              ])
                _field(name),
            ],
            if (_step == 1) ...[
              const Text(
                'Use rank and suit, for example As Kd. Leave undealt streets blank.',
              ),
              for (final name in ['Your cards', 'Flop', 'Turn', 'River'])
                _field(name, cards: true),
            ],
            if (_step == 2) ...[
              const Text(
                'Include both blind posts. Enter only the cents added or returned on each action.',
              ),
              for (final (index, street) in PokerStreet.values.indexed)
                if (streets >= [0, 3, 4, 5][index]) ...[
                  Text(
                    pokerStreetToString(street),
                    style: Act0ClubNightTokensV1.body,
                  ),
                  for (final (index, action) in _actions.indexed)
                    if (action.street == street)
                      ListTile(
                        title: Text(
                          'Seat ${action.seat} · ${action.kind.label} · ${action.cents}¢',
                        ),
                        onTap: () => _editAction(street, index: index),
                        trailing: IconButton(
                          tooltip: 'Remove action',
                          onPressed: () =>
                              setState(() => _actions.removeAt(index)),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ),
                  TextButton(
                    onPressed: () => _editAction(street),
                    child: Text('Add ${street.name} action'),
                  ),
                ],
              for (final (index, action) in _actions.indexed)
                if (streets < [0, 3, 4, 5][action.street.index])
                  ListTile(
                    title: Text(
                      '${action.street.name}: seat ${action.seat} · ${action.kind.label} (no board cards)',
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove action',
                      onPressed: () => setState(() => _actions.removeAt(index)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ),
            ],
            if (_step == 3) ...[
              const Text(
                'Enter only recorded payouts and known showdown cards. Enter 0 if there was no rake.',
              ),
              for (final seat in _seats) ...[
                _field('Seat ${seat.number} collected'),
                _field('Seat ${seat.number} shown cards', cards: true),
              ],
              _field('Rake'),
            ],
            if (_error case final error?)
              Semantics(
                liveRegion: true,
                child: Text(error, style: Act0ClubNightTokensV1.body),
              ),
            Wrap(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: () => setState(() {
                      _step--;
                      _error = null;
                    }),
                    child: const Text('Previous'),
                  ),
                Act0ClubButtonsV1.primary(
                  onPressed: _next,
                  label: _step == 3 ? 'Save hand' : 'Next',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionEditor extends StatefulWidget {
  const _ActionEditor({required this.street, required this.seats, this.action});

  final PokerStreet street;
  final List<int> seats;
  final Act0ImportedActionV1? action;

  @override
  State<_ActionEditor> createState() => _ActionEditorState();
}

class _ActionEditorState extends State<_ActionEditor> {
  late int? _seat = widget.seats.contains(widget.action?.seat)
      ? widget.action!.seat
      : null;
  late var _kind = widget.action?.kind;
  late String _amount = widget.action?.cents.toString() ?? '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    final needsAmount =
        _kind != null &&
        _kind != Act0ImportedActionKindV1.fold &&
        _kind != Act0ImportedActionKindV1.check;
    return AlertDialog(
      title: Text('${pokerStreetToString(widget.street)} action'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _seat,
            decoration: const InputDecoration(labelText: 'Seat'),
            items: [
              for (final seat in widget.seats)
                DropdownMenuItem(value: seat, child: Text('Seat $seat')),
            ],
            onChanged: (seat) => setState(() => _seat = seat),
          ),
          DropdownButtonFormField<Act0ImportedActionKindV1>(
            isExpanded: true,
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Action'),
            items: [
              for (final kind in Act0ImportedActionKindV1.values)
                DropdownMenuItem(value: kind, child: Text(kind.label)),
            ],
            onChanged: (kind) => setState(() => _kind = kind),
          ),
          if (needsAmount)
            TextFormField(
              initialValue: _amount,
              decoration: const InputDecoration(labelText: 'Amount in cents'),
              keyboardType: TextInputType.number,
              onChanged: (amount) => _amount = amount,
            ),
          if (_error case final error?) Text(error),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final cents = needsAmount ? int.tryParse(_amount.trim()) : 0;
            if (_seat == null ||
                _kind == null ||
                cents == null ||
                (needsAmount && cents <= 0) ||
                cents > 999999999) {
              setState(
                () => _error =
                    'Choose a seat and action, and enter a positive whole amount when required.',
              );
              return;
            }
            Navigator.of(context).pop((
              street: widget.street,
              seat: _seat!,
              kind: _kind!,
              cents: cents,
            ));
          },
          child: const Text('Save action'),
        ),
      ],
    );
  }
}

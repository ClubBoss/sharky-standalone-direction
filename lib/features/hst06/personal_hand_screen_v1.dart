import 'package:flutter/material.dart';

import 'personal_hand_v1.dart';
import 'pokerstars_text_v1.dart';

/// An existing authored repair chosen by the learner, never inferred from a hand.
class Hst06LearningTarget {
  final String taskId;
  final String lessonId;
  final String worldId;
  final String title;
  const Hst06LearningTarget({
    required this.taskId,
    required this.lessonId,
    required this.worldId,
    required this.title,
  });
}

class _SeatInput {
  final seat = TextEditingController();
  final name = TextEditingController();
  final stack = TextEditingController();
  void dispose() {
    seat.dispose();
    name.dispose();
    stack.dispose();
  }
}

class _ActionInput {
  int? street;
  String? kind;
  final actorSeat = TextEditingController();
  final amount = TextEditingController();
  void dispose() {
    actorSeat.dispose();
    amount.dispose();
  }
}

/// Isolated personal workflow; an integrator must admit its app navigation.
class Hst06PersonalHandScreen extends StatefulWidget {
  final Hst06PersonalStore? store;
  final List<Hst06LearningTarget> learningTargets;
  const Hst06PersonalHandScreen({
    super.key,
    this.store,
    this.learningTargets = const [],
  });
  @override
  State<Hst06PersonalHandScreen> createState() =>
      _Hst06PersonalHandScreenState();
}

class _Hst06PersonalHandScreenState extends State<Hst06PersonalHandScreen> {
  final _raw = TextEditingController();
  final _title = TextEditingController();
  final _hero = TextEditingController();
  final _button = TextEditingController();
  final _hole = TextEditingController();
  final _board = TextEditingController();
  final _pot = TextEditingController();
  final _seats = <_SeatInput>[_SeatInput(), _SeatInput()];
  final _actions = <_ActionInput>[];
  late final Hst06PersonalStore _store;
  final _parser = Hst06PokerStarsPreview();
  String _mode = 'import';
  String? _unit;
  List<Hst06Preview> _previews = [];
  List<Hst06Hand> _saved = [];
  String? _storageError;
  bool _saving = false;
  bool _choosingLearning = false;

  Future<void> _chooseLearning() async {
    if (_choosingLearning || widget.learningTargets.isEmpty) return;
    setState(() => _choosingLearning = true);
    try {
      final selected = await showDialog<Hst06LearningTarget>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Choose a learning repair'),
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Your choice, not an assessment of this hand. '
                'Opens an existing learning task; this hand earns no XP.',
              ),
            ),
            for (final target in widget.learningTargets)
              SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(target),
                child: Text(target.title),
              ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      if (!mounted || selected == null) return;
      // Close the private route before the adapter opens authored learning.
      Navigator.of(context).pop<Hst06LearningTarget>(selected);
    } finally {
      if (mounted) setState(() => _choosingLearning = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Hst06PersonalStore();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final hands = await _store.load();
      if (mounted)
        setState(() {
          _saved = hands;
          _storageError = null;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _storageError =
              'Cannot read local storage; old data preserved: ' + e.toString();
        });
    }
  }

  void _invalidate() {
    if (_previews.isNotEmpty) setState(() => _previews = []);
  }

  @override
  void dispose() {
    for (final c in [_raw, _title, _hero, _button, _hole, _board, _pot]) {
      c.dispose();
    }
    for (final p in _seats) {
      p.dispose();
    }
    for (final a in _actions) {
      a.dispose();
    }
    super.dispose();
  }

  Hst06Preview _readManual() {
    final extra = <String>[];
    int? seatOrNull(String text, String field) {
      if (text.trim().isEmpty) return null;
      final value = int.tryParse(text.trim());
      if (value == null) extra.add(field + ' must be a seat number.');
      return value;
    }

    final players = [
      for (final p in _seats)
        Hst06Player(
          int.tryParse(p.seat.text.trim()) ?? 0,
          p.name.text.trim(),
          p.stack.text.trim().isEmpty ? null : p.stack.text.trim(),
        ),
    ];
    final actions = [
      for (final a in _actions)
        Hst06Action(
          a.street ?? -1,
          int.tryParse(a.actorSeat.text.trim()) ?? 0,
          a.kind ?? '',
          amount: a.amount.text.trim().isEmpty ? null : a.amount.text.trim(),
          meaning: a.kind == 'raise' ? 'to' : 'additional',
        ),
    ];
    final preview = hst06Manual(
      title: _title.text,
      players: players,
      unit: _unit,
      heroSeat: seatOrNull(_hero.text, 'Hero'),
      buttonSeat: seatOrNull(_button.text, 'Button'),
      hole: _hole.text,
      board: _board.text,
      pot: _pot.text,
      actions: actions,
    );
    return Hst06Preview(preview.hand, [
      ...extra,
      ...preview.errors,
    ], preview.warnings);
  }

  void _preview() {
    setState(() {
      _previews = _mode == 'import'
          ? _parser.parse(_raw.text)
          : [_readManual()];
    });
  }

  Future<void> _confirm(Hst06Preview preview) async {
    if (_saving || _storageError != null || !preview.canSave) return;
    setState(() => _saving = true);
    try {
      final result = await _store.confirm(preview);
      await _reload();
      if (!mounted) return;
      final text = switch (result.kind) {
        Hst06SaveKind.saved => 'Personal hand saved; no XP or task created.',
        Hst06SaveKind.duplicate => 'Duplicate already saved; no new entry.',
        Hst06SaveKind.conflict =>
          'Same source ID, different facts; saved version retained.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      setState(() => _previews = []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: ' + e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _input(
    String label,
    TextEditingController c, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => _invalidate(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Widget _manual() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _input('Hand title', _title),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _unit,
        decoration: const InputDecoration(labelText: 'Explicit amount unit'),
        items: const [
          DropdownMenuItem<String>(value: null, child: Text('Unknown')),
          DropdownMenuItem(value: 'USD', child: Text('USD')),
          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
          DropdownMenuItem(value: 'GBP', child: Text('GBP')),
          DropdownMenuItem(value: 'chips', child: Text('chips')),
          DropdownMenuItem(
            value: 'BB',
            child: Text('BB (already in big blinds)'),
          ),
        ],
        onChanged: (v) => setState(() {
          _unit = v;
          _previews = [];
        }),
      ),
      const Text(
        'Leave a stack blank when unknown. Do not enter zero as a placeholder.',
      ),
      for (var i = 0; i < _seats.length; i++)
        Card(
          key: ValueKey('hst06-seat-' + i.toString()),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text('Player ' + (i + 1).toString()),
                _input(
                  'Seat number',
                  _seats[i].seat,
                  keyboardType: TextInputType.number,
                ),
                _input('Name', _seats[i].name),
                _input(
                  'Stack in source units (optional)',
                  _seats[i].stack,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (_seats.length > 2)
                  TextButton(
                    onPressed: () => setState(() {
                      _seats.removeAt(i).dispose();
                      _previews = [];
                    }),
                    child: const Text('Remove player'),
                  ),
              ],
            ),
          ),
        ),
      TextButton.icon(
        onPressed: _seats.length >= 10
            ? null
            : () => setState(() {
                _seats.add(_SeatInput());
                _previews = [];
              }),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add player'),
      ),
      _input('Hero seat (optional)', _hero, keyboardType: TextInputType.number),
      _input(
        'Button seat (optional)',
        _button,
        keyboardType: TextInputType.number,
      ),
      _input('Hero cards (optional)', _hole, hint: 'Ah Kh'),
      _input('Board (optional)', _board, hint: '2s 8d Tc'),
      _input(
        'Explicit pot (optional)',
        _pot,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const Text('Observed actions only'),
      for (var i = 0; i < _actions.length; i++)
        Card(
          key: ValueKey('hst06-action-' + i.toString()),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _actions[i].street,
                  decoration: const InputDecoration(labelText: 'Street'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Preflop')),
                    DropdownMenuItem(value: 1, child: Text('Flop')),
                    DropdownMenuItem(value: 2, child: Text('Turn')),
                    DropdownMenuItem(value: 3, child: Text('River')),
                  ],
                  onChanged: (v) => setState(() {
                    _actions[i].street = v;
                    _previews = [];
                  }),
                ),
                _input(
                  'Actor seat',
                  _actions[i].actorSeat,
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _actions[i].kind,
                  decoration: const InputDecoration(
                    labelText: 'Observed action',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'fold', child: Text('Fold')),
                    DropdownMenuItem(value: 'check', child: Text('Check')),
                    DropdownMenuItem(value: 'call', child: Text('Call')),
                    DropdownMenuItem(value: 'bet', child: Text('Bet')),
                    DropdownMenuItem(value: 'raise', child: Text('Raise to')),
                  ],
                  onChanged: (v) => setState(() {
                    _actions[i].kind = v;
                    _previews = [];
                  }),
                ),
                _input(
                  'Wager in source units (optional)',
                  _actions[i].amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _actions.removeAt(i).dispose();
                    _previews = [];
                  }),
                  child: const Text('Remove action'),
                ),
              ],
            ),
          ),
        ),
      TextButton.icon(
        onPressed: () => setState(() {
          _actions.add(_ActionInput());
          _previews = [];
        }),
        icon: const Icon(Icons.add),
        label: const Text('Add action'),
      ),
    ],
  );

  Widget _inspection(Hst06Preview preview, int index) {
    final hand = preview.hand;
    Hst06Hand? previous;
    if (hand != null) {
      for (final saved in _saved) {
        if (saved.identity == hand.identity ||
            saved.contentDigest == hand.contentDigest) {
          previous = saved;
          break;
        }
      }
    }
    final isDuplicate =
        previous != null && previous.contentDigest == hand?.contentDigest;
    String actor(int seat) {
      if (hand == null) return 'unknown';
      for (final p in hand.players) {
        if (p.seat == seat) return p.name;
      }
      return 'seat ' + seat.toString();
    }

    return Card(
      key: ValueKey('hst06-preview-' + index.toString()),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hand?.title ?? 'Unreadable source',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (hand != null) ...[
              Text(
                'Origin: ' +
                    hand.origin +
                    ', ID: ' +
                    (hand.roomHandId ?? 'manual') +
                    ', revision on save: 1',
              ),
              Text('Unit: ' + (hand.unit ?? 'unknown') + '; no BB conversion'),
              for (final p in hand.players)
                Text(
                  'Seat ' +
                      p.seat.toString() +
                      ': ' +
                      p.name +
                      ', stack ' +
                      (p.stack ?? 'unknown'),
                ),
              Text(
                'Button: ' +
                    (hand.buttonSeat == null
                        ? 'unknown'
                        : actor(hand.buttonSeat!)),
              ),
              Text(
                'Hero: ' +
                    (hand.heroSeat == null ? 'unknown' : actor(hand.heroSeat!)),
              ),
              Text('Hero cards: ' + (hand.heroCards?.join(' ') ?? 'unknown')),
              Text('Board: ' + (hand.boardCards?.join(' ') ?? 'unknown')),
              Text('Pot: ' + (hand.totalPot ?? 'unknown')),
              Text(
                'Collectors: ' +
                    (hand.collectors?.map(actor).join(', ') ?? 'unknown'),
              ),
              for (final a in hand.actions)
                Text(
                  'Street ' +
                      a.street.toString() +
                      ': ' +
                      actor(a.seat) +
                      ' ' +
                      a.kind +
                      ' ' +
                      (a.amount ?? '(unknown amount)') +
                      (a.meaning == null ? '' : ' (' + a.meaning! + ')'),
                ),
              const Text(
                'Personal record only. No automatic task, mastery, or XP.',
              ),
            ],
            for (final error in preview.errors)
              Text(
                'ERROR: ' + error,
                style: const TextStyle(color: Colors.red),
              ),
            for (final warning in preview.warnings) Text('NOTE: ' + warning),
            if (previous != null)
              Text(
                isDuplicate
                    ? 'Already saved: this identical hand will not be added again.'
                    : 'Conflict: a saved hand has this ID with different facts.',
              ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  key: ValueKey('hst06-cancel-' + index.toString()),
                  onPressed: () => setState(() => _previews = []),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  key: ValueKey('hst06-confirm-' + index.toString()),
                  onPressed:
                      preview.canSave &&
                          previous == null &&
                          !_saving &&
                          _storageError == null
                      ? () => _confirm(preview)
                      : null,
                  child: const Text('Confirm personal save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My hands - private import')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Supported: manual NL Holdem and PokerStars English NL Holdem text. Other rooms and damaged records are not silently converted.',
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Import text'),
              selected: _mode == 'import',
              onSelected: (_) => setState(() {
                _mode = 'import';
                _previews = [];
              }),
            ),
            ChoiceChip(
              label: const Text('Manual entry'),
              selected: _mode == 'manual',
              onSelected: (_) => setState(() {
                _mode = 'manual';
                _previews = [];
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_mode == 'import')
          _input(
            'PokerStars plain-text history',
            _raw,
            maxLines: 9,
            hint: 'PokerStars Hand #...',
          ),
        if (_mode == 'manual') _manual(),
        ElevatedButton(
          key: const Key('hst06-preview-button'),
          onPressed: _saving ? null : _preview,
          child: const Text('Review known facts and errors'),
        ),
        if (_storageError != null)
          Text(_storageError!, style: const TextStyle(color: Colors.red)),
        for (var i = 0; i < _previews.length; i++) _inspection(_previews[i], i),
        const Divider(),
        Text('Saved personal hands: ' + _saved.length.toString()),
        for (final h in _saved)
          ListTile(
            title: Text(h.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.origin +
                      ' / revision ' +
                      h.revision.toString() +
                      ' / Hero seat ' +
                      (h.heroSeat?.toString() ?? 'unknown'),
                ),
                widget.learningTargets.isEmpty
                    ? const Text('No learning repair available')
                    : TextButton(
                        key: Key('hst06-learning-' + h.localId),
                        onPressed: _choosingLearning ? null : _chooseLearning,
                        child: const Text('Choose learning repair'),
                      ),
              ],
            ),
          ),
      ],
    ),
  );
}

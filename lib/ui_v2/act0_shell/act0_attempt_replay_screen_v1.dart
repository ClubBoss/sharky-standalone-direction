import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_attempt_archive_v1.dart';
import 'act0_attempt_replay_table_v1.dart';
import 'act0_imported_hand_v1.dart';
import 'act0_lesson_runner_shell_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_table_presentation_config_v1.dart';
import 'act0_street_summary_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'skin/act0_skin_tokens_v1.dart';

typedef _T = Act0SkinTokensV1;

class Act0AttemptReplayScreenV1 extends StatefulWidget {
  const Act0AttemptReplayScreenV1({
    super.key,
    required this.attempt,
    required this.onClose,
  }) : hand = null,
       practice = null;

  const Act0AttemptReplayScreenV1.ownHand({
    super.key,
    required Act0ImportedHandV1 this.hand,
    required this.onClose,
    this.practice,
  }) : attempt = null;

  final Act0ArchivedAttemptV1? attempt;
  final Act0ImportedHandV1? hand;
  final Widget? practice;
  final VoidCallback onClose;

  Act0StreetSummaryV1? get streetSummary {
    final ownHand = hand;
    final prefix =
        ownHand?.timeline.beforeDecision ?? attempt?.timelineSnapshot;
    if (prefix == null) return null;
    return Act0StreetSummaryV1(prefix, completedHand: ownHand != null);
  }

  @override
  State<Act0AttemptReplayScreenV1> createState() =>
      _Act0AttemptReplayScreenV1State();
}

class _Act0AttemptReplayScreenV1State extends State<Act0AttemptReplayScreenV1>
    with WidgetsBindingObserver {
  late var _table = _buildReplayTable();
  late var _own = widget.hand == null ? null : _OwnHandReplay(widget.hand!);
  late var _replay = Act0AttemptReplayV1.events(
    widget.attempt?.events ?? _own!.events,
  );
  Timer? _timer;

  bool _visible = true;

  Act0AttemptReplayTableV1? _buildReplayTable() {
    final attempt = widget.attempt;
    return attempt == null
        ? null
        : Act0AttemptReplayTableV1.fromAttempt(attempt);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible =
        TickerMode.of(context) && (ModalRoute.isCurrentOf(context) ?? true);
    if (!_visible && _replay.isPlaying) {
      _timer?.cancel();
      _timer = null;
      _replay = _replay.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(Act0AttemptReplayScreenV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attempt != widget.attempt || oldWidget.hand != widget.hand) {
      _timer?.cancel();
      _timer = null;
      _own = widget.hand == null ? null : _OwnHandReplay(widget.hand!);
      _replay = Act0AttemptReplayV1.events(
        widget.attempt?.events ?? _own!.events,
      );
      _table = _buildReplayTable();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _replay.isPlaying) {
      _update(_replay.pause());
    }
  }

  void _update(Act0AttemptReplayV1 replay) {
    setState(() => _replay = replay);
    if (!replay.isPlaying) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _togglePlayback() {
    if (_replay.isPlaying) {
      _update(_replay.pause());
    } else {
      _update(_replay.play());
      if (_replay.isPlaying) {
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => _update(_replay.tick()),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    final total = _replay.events.length;
    final history = _replay.textAlternative;
    final position = _replay.position;
    final frame = _table?.atPosition(position);
    final table = frame?.table ?? _own?.frames[position];
    final tableAvailable = table?.supportsLearnerTable ?? false;
    final streets =
        _table?.streetPositions ??
        _own?.streetPositions ??
        const <String, int>{};
    final summary = widget.streetSummary;
    final status = position == 0
        ? 'Start · 1 of $total'
        : 'Step $position of $total';
    return Act0SkinDarkAreaV1(
      maxContentWidth: _T.historyMaxWidth,
      child: ListView(
        key: const Key('act0_attempt_replay_screen'),
        padding: const EdgeInsets.fromLTRB(
          _T.historyGutter,
          _T.gapMd,
          _T.historyGutter,
          _T.gapXl,
        ),
        children: [
          Act0SkinScreenHeaderV1(
            backKey: const Key('act0_attempt_replay_back_to_archive'),
            onBack: widget.onClose,
            title: attempt == null
                ? 'Own hand · ${widget.hand!.isManual ? 'Manual entry' : 'PokerStars'}'
                : attempt.taskLabel ?? attempt.evidence.taskId,
          ),
          const SizedBox(height: _T.gapMd),
          if (widget.practice case final practice?) practice,
          if (total == 0)
            const Text(
              'No event history was saved for this attempt.',
              style: _T.secondary,
            )
          else ...[
            Semantics(
              liveRegion: true,
              child: Text(
                status,
                semanticsLabel: history.isEmpty
                    ? status
                    : '$status. ${history.last}',
                style: _T.secondary,
              ),
            ),
            Wrap(
              spacing: _T.gapXs,
              children: [
                TextButton(
                  key: const Key('act0_attempt_replay_previous'),
                  onPressed: _replay.position == 0
                      ? null
                      : () => _update(_replay.back()),
                  child: const Text('Previous'),
                ),
                TextButton(
                  key: const Key('act0_attempt_replay_next'),
                  onPressed: _replay.atEnd
                      ? null
                      : () => _update(_replay.pause().forward()),
                  child: const Text('Next'),
                ),
                TextButton(
                  key: const Key('act0_attempt_replay_play_pause'),
                  onPressed: _replay.atEnd ? null : _togglePlayback,
                  child: Text(_replay.isPlaying ? 'Pause' : 'Play'),
                ),
                TextButton(
                  key: const Key('act0_attempt_replay_reset'),
                  onPressed: _replay.position == 0 && !_replay.isPlaying
                      ? null
                      : () => _update(_replay.reset()),
                  child: const Text('Reset'),
                ),
              ],
            ),
            if (streets.length > 1 || summary != null)
              Act0SkinStreetSummaryStripV1(
                jumps: streets,
                position: position,
                onJump: (step) => _update(_replay.seek(step)),
                lines: _summaryLines(
                  summary,
                  streets,
                  position,
                  table?.boardCards.length ?? 0,
                  atEnd: _replay.atEnd,
                ),
              ),
            if (table != null && tableAvailable)
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Act0TableSceneV1(
                  key: const Key('act0_attempt_replay_table'),
                  table: table,
                  config: Act0TablePresentationConfigV1(
                    animateActiveCommitment:
                        (frame?.newCommitment ?? false) && _visible,
                  ),
                ),
              )
            else
              const Text(
                'Table playback is unavailable for this attempt.',
                style: _T.secondary,
              ),
            if (history.isNotEmpty) ...[
              Text(
                history.last,
                key: const Key('act0_attempt_replay_current_event'),
                style: _T.body,
              ),
              if (history.length > 1)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Earlier steps'),
                  collapsedTextColor: _T.onSurface,
                  textColor: _T.onSurface,
                  children: [
                    for (final event in history.take(history.length - 1))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(event, style: _T.body),
                      ),
                  ],
                ),
            ],
          ],
        ],
      ),
    );
  }
}

List<String> _summaryLines(
  Act0StreetSummaryV1? summary,
  Map<String, int> jumps,
  int position,
  int visibleBoardCount, {
  required bool atEnd,
}) {
  if (summary == null) return const [];
  if (summary.frameAt(PokerStreet.preflop)?.potBb case final pot?
      when atEnd && summary.streets.isEmpty) {
    return ['Preflop · Pot $pot BB'];
  }
  final lines = <String>[];
  for (final row in summary.streets) {
    final label = pokerStreetToString(row.name);
    final start = jumps[label];
    if (start == null ||
        start > position ||
        row.boardOnStreet.length > visibleBoardCount) {
      continue;
    }
    final complete =
        atEnd || jumps.values.any((step) => step > start && step <= position);
    lines.add(
      label +
          (row.boardOnStreet.isEmpty
              ? ''
              : ' · ${row.boardOnStreet.join(' ')}') +
          (complete && row.potAfterBb != null
              ? ' · Pot ${row.potAfterBb} BB'
              : ''),
    );
  }
  return lines;
}

/// The journal and frames advance together from the normalized saved hand.
class _OwnHandReplay {
  _OwnHandReplay(this.hand) {
    frames.add(_frame());
    _build();
  }

  final Act0ImportedHandV1 hand;
  final events = <Act0ActionTrailItemV1>[];
  final frames = <Act0TableStateV1>[];
  final streetPositions = <String, int>{'Preflop': 0};
  final _folded = <int>{};
  final _shown = <int, List<String>>{};
  final _deltas = <int, int>{};
  PokerStreet _street = PokerStreet.preflop;
  int _boardCount = 0;
  bool _heroVisible = false;
  int _pot = 0;

  static String _usd(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  static List<Act0CardStateV1> _cards(Iterable<String> cards) => [
    for (final card in cards)
      Act0CardStateV1(
        rank: card.substring(0, card.length - 1),
        suit: card[card.length - 1],
      ),
  ];

  Act0TableStateV1 _frame() => Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: hand.seats.length > 6
        ? Act0TableFormatV1.nineMax
        : Act0TableFormatV1.sixMax,
    playerCount: hand.seats.length,
    seats: [
      for (final seat in hand.seats)
        Act0SeatStateV1(
          seatId: '${seat.number}',
          seatLabel: 'Seat ${seat.number}',
          displayName: seat.number == hand.heroSeat
              ? 'You'
              : 'Seat ${seat.number}',
          isHero: seat.number == hand.heroSeat,
          isDealerButton: seat.number == hand.buttonSeat,
          isFolded: _folded.contains(seat.number),
          isInHand: !_folded.contains(seat.number),
          stackLabel: _usd(seat.stackCents + (_deltas[seat.number] ?? 0)),
          holeCards: _cards(_shown[seat.number] ?? const []),
          cardsVisibleMode: _shown.containsKey(seat.number)
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
        ),
    ],
    heroSeatId: '${hand.heroSeat}',
    heroCards: _heroVisible ? _cards(hand.heroCards) : const [],
    boardCards: _cards(hand.board.take(_boardCount)),
    streetLabel: pokerStreetToString(_street),
    potLabel: 'Pot ${_usd(_pot)}',
    toCallLabel: '',
    centerLabel: '',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
  );

  void _note(String label) {
    events.add(Act0ActionTrailItemV1.note(label: label));
    frames.add(_frame());
  }

  void _build() {
    _note(
      'Button: seat ${hand.buttonSeat}. Starting stacks: '
      '${hand.seats.map((seat) => 'seat ${seat.number} ${_usd(seat.stackCents)}').join(', ')}.',
    );
    var revealed = 0;
    for (final (index, street) in PokerStreet.values.indexed) {
      final count = [0, 3, 4, 5][index];
      if (hand.board.length < count) break;
      _street = street;
      final label = pokerStreetToString(street);
      if (count > 0) {
        _boardCount = count;
        _note('$label: ${hand.board.take(count).join(' ')}');
        streetPositions[label] = events.length;
      }
      while (revealed < hand.actions.length &&
          hand.actions[revealed].street == street) {
        final action = hand.actions[revealed++];
        final delta = action.kind == Act0ImportedActionKindV1.uncalledReturn
            ? -action.cents
            : action.cents;
        _pot += delta;
        _deltas.update(
          action.seat,
          (value) => value - delta,
          ifAbsent: () => -delta,
        );
        if (action.kind == Act0ImportedActionKindV1.fold)
          _folded.add(action.seat);
        _note(
          '$label: seat ${action.seat} · ${action.kind.label}'
          '${action.cents == 0 ? '' : ' ${_usd(action.cents)}'} · Pot ${_usd(_pot)}',
        );
        if (action.kind == Act0ImportedActionKindV1.bigBlind) {
          _heroVisible = true;
          _shown[hand.heroSeat] = hand.heroCards;
          _note(
            'Your cards (seat ${hand.heroSeat}): ${hand.heroCards.join(' ')}',
          );
        }
      }
    }
    for (final entry in hand.shownCards.entries) {
      _shown[entry.key] = entry.value;
      _note('Showdown: seat ${entry.key} · ${entry.value.join(' ')}');
    }
    for (final entry in hand.payouts.entries) {
      _pot -= entry.value;
      _deltas.update(
        entry.key,
        (value) => value + entry.value,
        ifAbsent: () => entry.value,
      );
      _note('Seat ${entry.key} collected ${_usd(entry.value)}');
    }
    _pot -= hand.rakeCents;
    _note('Total pot ${_usd(hand.potCents)} · Rake ${_usd(hand.rakeCents)}');
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_attempt_archive_v1.dart';
import 'act0_attempt_replay_table_v1.dart';
import 'act0_imported_hand_v1.dart';
import 'act0_replay_playback_v1.dart';
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
    this.onPracticeSpot,
  }) : hand = null,
       practice = null,
       taskHistory = null;

  const Act0AttemptReplayScreenV1.ownHand({
    super.key,
    required Act0ImportedHandV1 this.hand,
    required this.onClose,
    this.practice,
  }) : attempt = null,
       onPracticeSpot = null,
       taskHistory = null;

  const Act0AttemptReplayScreenV1.task({
    super.key,
    required Act0TaskStreetReplayV1 this.taskHistory,
    required this.onClose,
  }) : attempt = null,
       hand = null,
       practice = null,
       onPracticeSpot = null;

  final Act0TaskStreetReplayV1? taskHistory;
  final Act0ArchivedAttemptV1? attempt;
  final Act0ImportedHandV1? hand;
  final Widget? practice;
  final VoidCallback onClose;
  final VoidCallback? onPracticeSpot;

  Act0StreetSummaryV1? get streetSummary {
    if (taskHistory case final history?) return history.summary;
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
  List<Act0ActionTrailItemV1> get _events =>
      widget.attempt?.events ??
      _own?.events ??
      [
        for (final label in widget.taskHistory!.labels)
          Act0ActionTrailItemV1.note(label: label),
      ];
  late Act0ReplayPlaybackV1 _playback;
  Timer? _timer;
  bool _visible = true;
  bool _reduceMotion = false;
  bool _initialized = false;

  Act0AttemptReplayTableV1? _buildReplayTable() {
    final attempt = widget.attempt;
    return attempt == null
        ? null
        : Act0AttemptReplayTableV1.fromAttempt(attempt);
  }

  void _configure({required int position, required double speed}) {
    _timer?.cancel();
    _timer = null;
    // Index zero is the unconsumed journal; index n consumes n events.
    _playback =
        Act0ReplayPlaybackV1(
            stepCount: _events.length + 1,
            reduceMotion: _reduceMotion,
          )
          ..seekTo(position)
          ..setSpeed(speed);
    _initialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible =
        TickerMode.of(context) && (ModalRoute.isCurrentOf(context) ?? true);
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (!_initialized || reduce != _reduceMotion) {
      _reduceMotion = reduce;
      _configure(
        position: _initialized
            ? _playback.currentIndex
            : (widget.taskHistory == null ? 0 : _events.length),
        speed: _initialized ? _playback.speed : 1,
      );
    }
    if (!_visible) _pause();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(Act0AttemptReplayScreenV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attempt != widget.attempt ||
        oldWidget.hand != widget.hand ||
        oldWidget.taskHistory != widget.taskHistory) {
      _own = widget.hand == null ? null : _OwnHandReplay(widget.hand!);
      _table = _buildReplayTable();
      _configure(
        position: widget.taskHistory == null ? 0 : _events.length,
        speed: 1,
      );
    }
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    _playback.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _initialized) {
      setState(_pause);
    }
  }

  void _seek(int position) {
    setState(() {
      _pause();
      _playback.seekTo(position);
    });
  }

  void _togglePlayback() {
    if (_reduceMotion || !_visible) return;
    setState(() {
      if (_playback.isPlaying) {
        _pause();
      } else {
        _playback.play();
        _startTimer();
      }
    });
  }

  Duration get _interval => Duration(
    microseconds: (_playback.baseStepDuration.inMicroseconds / _playback.speed)
        .round(),
  );

  void _startTimer() {
    _timer?.cancel();
    if (!_playback.isPlaying) return;
    final interval = _interval;
    _timer = Timer.periodic(interval, (_) {
      if (!mounted) return;
      setState(() {
        _playback.tick(interval);
        if (!_playback.isPlaying) _pause();
      });
    });
  }

  void _setSpeed(double speed) {
    setState(() {
      _playback.setSpeed(speed);
      if (_playback.isPlaying) _startTimer();
    });
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
    final total = _events.length;
    final position = _playback.currentIndex;
    final history = _events
        .take(position)
        .map((event) => event.learnerLabel)
        .toList();
    final atEnd = position == total;
    final frame = _table?.atPosition(position);
    final table = frame?.table ?? _own?.frames[position];
    final tableAvailable = table?.supportsLearnerTable ?? false;
    final streets =
        _table?.streetPositions ??
        _own?.streetPositions ??
        widget.taskHistory?.streetPositions ??
        const <String, int>{};
    final summary = widget.streetSummary;
    final speedLabel = _playback.speed == 0.5
        ? '0.5'
        : _playback.speed.toInt().toString();
    final playbackStatus =
        'Speed $speedLabel× · ${_playback.isPlaying ? 'Playing' : 'Paused'}';
    final status = position == 0
        ? 'Start · 1 of $total'
        : 'Step $position of $total';
    return Act0SkinDarkAreaV1(
      maxContentWidth: _T.historyMaxWidth,
      child: SingleChildScrollView(
        key: const Key('act0_attempt_replay_screen'),
        padding: const EdgeInsets.fromLTRB(
          _T.historyGutter,
          _T.gapMd,
          _T.historyGutter,
          _T.gapXl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Act0SkinScreenHeaderV1(
              backKey: const Key('act0_attempt_replay_back_to_archive'),
              onBack: widget.onClose,
              title: widget.taskHistory != null
                  ? 'Task history · ${pokerStreetToString(widget.taskHistory!.decisionStreet)}'
                  : attempt == null
                  ? 'Own hand · ${widget.hand!.isManual ? 'Manual entry' : 'PokerStars'}'
                  : attempt.taskLabel ?? attempt.evidence.taskId,
            ),
            const SizedBox(height: _T.gapMd),
            if (widget.practice case final practice?) practice,
            if (widget.onPracticeSpot case final onPractice?)
              Act0SkinPrimaryButtonV1(
                controlKey: const Key('act0_attempt_replay_practise_spot'),
                label: 'Practise this spot',
                onPressed: onPractice,
              ),
            if (total == 0)
              Text(
                widget.taskHistory == null
                    ? 'No event history was saved for this attempt.'
                    : 'No authored history is available for this decision.',
                style: _T.secondary,
              )
            else ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  status,
                  semanticsLabel: history.isEmpty
                      ? '$status. $playbackStatus'
                      : '$status. $playbackStatus. ${history.last}',
                  style: _T.secondary,
                ),
              ),
              Wrap(
                spacing: _T.gapXs,
                children: [
                  for (final (id, label, action)
                      in <(String, String, VoidCallback?)>[
                        (
                          'previous',
                          'Previous',
                          position == 0 ? null : () => _seek(position - 1),
                        ),
                        (
                          'next',
                          'Next',
                          atEnd ? null : () => _seek(position + 1),
                        ),
                        (
                          'play_pause',
                          _playback.isPlaying ? 'Pause' : 'Play',
                          atEnd || _reduceMotion ? null : _togglePlayback,
                        ),
                        (
                          'reset',
                          'Reset',
                          position == 0 ? null : () => _seek(0),
                        ),
                      ])
                    IntrinsicWidth(
                      child: Act0SkinPrimaryButtonV1(
                        compact: true,
                        controlKey: Key('act0_attempt_replay_$id'),
                        label: label,
                        onPressed: action,
                      ),
                    ),
                ],
              ),
              Wrap(
                spacing: _T.gapXs,
                children: [
                  for (final speed in [0.5, 1.0, 2.0])
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: _T.minTouch),
                      child: Act0SkinChipV1(
                        label: '${speed == 0.5 ? '0.5' : speed.toInt()}×',
                        selected: _playback.speed == speed,
                        onPressed: () => _setSpeed(speed),
                      ),
                    ),
                ],
              ),
              if (streets.length > 1 || summary != null)
                Act0SkinStreetSummaryStripV1(
                  jumps: streets,
                  position: position,
                  onJump: _seek,
                  lines: _summaryLines(
                    summary,
                    streets,
                    position,
                    table?.boardCards.length ??
                        widget.taskHistory?.boardAt(position).length ??
                        0,
                    atEnd: atEnd,
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
                          (frame?.newCommitment ?? false) &&
                          _visible &&
                          _playback.shouldAnimate,
                    ),
                  ),
                )
              else if (widget.taskHistory case final task?)
                Text(
                  'Board: ${task.boardAt(position).join(' ')}',
                  key: const Key('act0_task_replay_board'),
                  style: _T.body,
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

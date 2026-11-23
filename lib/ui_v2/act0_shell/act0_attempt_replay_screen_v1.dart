import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_academy_reading_style_v1.dart';
import 'act0_attempt_archive_v1.dart';
import 'act0_attempt_replay_table_v1.dart';
import 'act0_club_night_tokens_v1.dart';
import 'act0_imported_hand_v1.dart';
import 'act0_lesson_runner_shell_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_shell_tokens_v1.dart';
import 'act0_table_presentation_config_v1.dart';

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

  @override
  State<Act0AttemptReplayScreenV1> createState() =>
      _Act0AttemptReplayScreenV1State();
}

class _Act0AttemptReplayScreenV1State extends State<Act0AttemptReplayScreenV1>
    with WidgetsBindingObserver {
  late var _table = _buildReplayTable();
  late var _replay = Act0AttemptReplayV1.events(
    widget.attempt?.events ?? _ownHandEvents(widget.hand!),
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
      _replay = Act0AttemptReplayV1.events(
        widget.attempt?.events ?? _ownHandEvents(widget.hand!),
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
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final history = _replay.textAlternative;
    final ownHand = attempt == null;
    final bodyStyle = ownHand
        ? Act0ClubNightTokensV1.body
        : Act0AcademyReadingStyleV1.body;
    final mutedStyle = ownHand
        ? Act0ClubNightTokensV1.secondary
        : Act0AcademyReadingStyleV1.muted;
    final frame = _table?.atPosition(_replay.position);
    final list = ListView(
      key: const Key('act0_attempt_replay_screen'),
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        Act0ShellTokensV1.gapMd,
        pagePadding,
        Act0ShellTokensV1.gapXl,
      ),
      children: [
        Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 860,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                key: const Key('act0_attempt_replay_back_to_archive'),
                onPressed: widget.onClose,
                child: Text(
                  attempt == null
                      ? 'Back to own hands'
                      : 'Back to attempt archive',
                ),
              ),
              Text(
                attempt == null
                    ? 'Own hand · ${widget.hand!.isManual ? 'Manual entry' : 'PokerStars'}'
                    : attempt.taskLabel ?? attempt.evidence.taskId,
                style: ownHand
                    ? Act0ClubNightTokensV1.title
                    : Act0AcademyReadingStyleV1.sectionTitle,
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              if (widget.practice case final practice?) practice,
              if (total == 0)
                const Text(
                  'No event history was saved for this attempt.',
                  style: Act0AcademyReadingStyleV1.muted,
                )
              else ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Step ${_replay.position} of $total',
                    semanticsLabel: history.isEmpty
                        ? 'Step 0 of $total'
                        : 'Step ${_replay.position} of $total. ${history.last}',
                    style: mutedStyle,
                  ),
                ),
                Wrap(
                  spacing: Act0ShellTokensV1.gapXs,
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
                if (frame != null)
                  Act0TableSceneV1(
                    key: const Key('act0_attempt_replay_table'),
                    table: frame.table,
                    config: Act0TablePresentationConfigV1(
                      animateActiveCommitment: frame.newCommitment && _visible,
                    ),
                  )
                else if (!ownHand && _table == null)
                  const Text(
                    'Table playback is unavailable for this attempt.',
                    style: Act0AcademyReadingStyleV1.muted,
                  ),
                if (history.isNotEmpty) ...[
                  Text(
                    history.last,
                    key: const Key('act0_attempt_replay_current_event'),
                    style: bodyStyle,
                  ),
                  if (history.length > 1)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('Earlier steps'),
                      collapsedTextColor: bodyStyle.color,
                      textColor: bodyStyle.color,
                      children: [
                        for (final event in history.take(history.length - 1))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(event, style: bodyStyle),
                          ),
                      ],
                    ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
    return ownHand
        ? ColoredBox(color: Act0ClubNightTokensV1.wall, child: list)
        : list;
  }
}

List<Act0ActionTrailItemV1> _ownHandEvents(Act0ImportedHandV1 hand) {
  String usd(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
  final events = <Act0ActionTrailItemV1>[];
  void note(String label) =>
      events.add(Act0ActionTrailItemV1.note(label: label));
  note(
    'Button: seat ${hand.buttonSeat}. Starting stacks: '
    '${hand.seats.map((seat) => 'seat ${seat.number} ${usd(seat.stackCents)}').join(', ')}.',
  );
  var revealed = 0;
  final seatIds = hand.seatIds;
  for (final (index, street) in PokerStreet.values.indexed) {
    final count = [0, 3, 4, 5][index];
    if (hand.board.length < count) break;
    if (count > 0)
      note(
        '${pokerStreetToString(street)}: ${hand.board.take(count).join(' ')}',
      );
    while (revealed < hand.actions.length &&
        hand.actions[revealed].street == street) {
      final action = hand.actions[revealed++];
      final pot = hand
          .contributions(
            street,
            hand.actions.take(revealed),
            includeStackLimits: false,
          )
          .amounts(seatIds: seatIds)
          .potBb;
      note(
        '${pokerStreetToString(street)}: seat ${action.seat} · ${action.kind.label}'
        '${action.cents == 0 ? '' : ' ${usd(action.cents)}'} · '
        'Pot ${usd((pot * hand.bigBlindCents).round())}',
      );
      if (action.kind == Act0ImportedActionKindV1.bigBlind) {
        note('Your cards (seat ${hand.heroSeat}): ${hand.heroCards.join(' ')}');
      }
    }
  }
  for (final entry in hand.shownCards.entries) {
    note('Showdown: seat ${entry.key} · ${entry.value.join(' ')}');
  }
  for (final entry in hand.payouts.entries) {
    note('Seat ${entry.key} collected ${usd(entry.value)}');
  }
  note('Total pot ${usd(hand.potCents)} · Rake ${usd(hand.rakeCents)}');
  return events;
}

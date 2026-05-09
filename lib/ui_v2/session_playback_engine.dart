import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui_v2/hand_analyzer_mode.dart';
import 'package:poker_analyzer/services/session_export_service_v2.dart';
import 'package:poker_analyzer/ui_v2/table_betting_layer.dart';
import 'package:poker_analyzer/ui_v2/table_visualization_prototype.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

enum PlaybackActionType { none, check, bet, call, raise, fold, win }

class PlaybackAction {
  const PlaybackAction({
    required this.seat,
    required this.type,
    this.amount = 0,
    this.description,
  });

  final int seat;
  final PlaybackActionType type;
  final int amount;
  final String? description;
}

class PlaybackState {
  const PlaybackState({
    required this.currentIndex,
    required this.currentAction,
    required this.pot,
    required this.stacks,
    required this.isPlaying,
  });

  final int currentIndex;
  final PlaybackAction? currentAction;
  final int pot;
  final List<int> stacks;
  final bool isPlaying;
}

class SessionPlaybackEngine {
  SessionPlaybackEngine({
    required this.actions,
    required this.playerCount,
    List<int>? initialStacks,
    List<int>? potHistory,
    Duration stepDuration = const Duration(seconds: 2),
  }) : assert(playerCount >= 2 && playerCount <= 10),
       _initialStacks = List<int>.of(
         initialStacks ??
             List<int>.generate(playerCount, (index) => 1500 + index * 50),
       ),
       _potHistory = potHistory ?? const [],
       _stepDuration = stepDuration;

  final List<PlaybackAction> actions;
  final int playerCount;
  final List<int> _initialStacks;
  final List<int> _potHistory;

  // Optional: prefetch data for the next hand in parallel near the end of this one.
  Future<void> Function(int currentIndex)? _prefetchNext;
  // Optional: invoked when a round/session of actions completes (for UX timing hooks).
  VoidCallback? _onRoundComplete;

  Duration _stepDuration;
  Duration get stepDuration => _stepDuration;

  set stepDuration(Duration value) {
    _stepDuration = value;
    if (_isPlaying) {
      _startTimer();
    }
  }

  /// Configure a prefetcher to run in parallel as we near the end of the
  /// current action list, so the next hand loads instantly.
  void configurePrefetcher(
    Future<void> Function(int currentIndex)? prefetcher,
  ) {
    _prefetchNext = prefetcher;
  }

  /// Hook fired when a round of actions completes. Useful for UX timing.
  void setOnRoundComplete(VoidCallback? callback) {
    _onRoundComplete = callback;
  }

  final StreamController<PlaybackState> _controller =
      StreamController<PlaybackState>.broadcast();

  Stream<PlaybackState> get states => _controller.stream;

  Timer? _timer;
  bool _isPlaying = false;
  int _currentIndex = -1;
  late List<int> _stacks = List<int>.of(_initialStacks);
  late int _pot = _initialPot;
  DateTime? _sessionStart;
  PlaybackState _currentState = const PlaybackState(
    currentIndex: -1,
    currentAction: null,
    pot: 0,
    stacks: <int>[],
    isPlaying: false,
  );

  PlaybackState get currentState => _currentState;

  int get _initialPot => _potHistory.isNotEmpty ? _potHistory.first : 0;

  void play() {
    if (_isPlaying) return;
    if (_currentIndex >= actions.length - 1) {
      reset();
    }
    if (_sessionStart == null) {
      _sessionStart = DateTime.now();
      unawaited(FirebaseLiteTelemetryService.instance.logSessionStart());
    }
    _isPlaying = true;
    _advance();
    _startTimer();
  }

  void pause() {
    if (!_isPlaying) return;
    _timer?.cancel();
    _isPlaying = false;
    _emitState();
  }

  void toggle() => _isPlaying ? pause() : play();

  void stepForward() {
    pause();
    _advance();
  }

  void reset() {
    _closeSession(completed: false);
    _timer?.cancel();
    _isPlaying = false;
    _currentIndex = -1;
    _stacks = List<int>.of(_initialStacks);
    _pot = _initialPot;
    _emitState();
  }

  void dispose() {
    _closeSession(completed: false);
    _timer?.cancel();
    _controller.close();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_isPlaying || actions.isEmpty) return;
    _timer = Timer.periodic(_stepDuration, (_) {
      if (!_advance()) {
        pause();
      }
    });
  }

  bool _advance() {
    if (actions.isEmpty) {
      _emitState();
      return false;
    }
    if (_currentIndex >= actions.length - 1) {
      _emitState();
      return false;
    }
    _currentIndex++;
    // If we're within one action of the end, proactively prefetch the next hand.
    if (_currentIndex >= actions.length - 2) {
      unawaited(_prefetchNext?.call(_currentIndex));
    }
    final action = actions[_currentIndex];
    _applyAction(action);
    _emitState();
    if (_currentIndex >= actions.length - 1) {
      // Signal completion for UX timing (e.g., to coordinate transitions).
      _onRoundComplete?.call();
      _closeSession(completed: true);
      return false;
    }
    return true;
  }

  void _applyAction(PlaybackAction action) {
    final seat = action.seat.clamp(0, playerCount - 1);
    switch (action.type) {
      case PlaybackActionType.bet:
      case PlaybackActionType.call:
      case PlaybackActionType.raise:
        _stacks[seat] = max(0, _stacks[seat] - action.amount);
        _pot += action.amount;
        break;
      case PlaybackActionType.win:
        _stacks[seat] += action.amount;
        _pot = max(0, _pot - action.amount);
        break;
      case PlaybackActionType.check:
      case PlaybackActionType.fold:
      case PlaybackActionType.none:
        break;
    }

    if (_potHistory.isNotEmpty &&
        _currentIndex + 1 < _potHistory.length &&
        _potHistory[_currentIndex + 1] >= 0) {
      _pot = _potHistory[_currentIndex + 1];
    }
  }

  void _emitState() {
    _currentState = PlaybackState(
      currentIndex: _currentIndex,
      currentAction: _currentIndex >= 0 && _currentIndex < actions.length
          ? actions[_currentIndex]
          : null,
      pot: _pot,
      stacks: List<int>.unmodifiable(_stacks),
      isPlaying: _isPlaying,
    );
    if (!_controller.isClosed) {
      _controller.add(_currentState);
    }
  }

  void _closeSession({required bool completed}) {
    if (_sessionStart == null) {
      return;
    }
    final duration = DateTime.now().difference(_sessionStart!);
    final actionsPlayed = _currentIndex >= 0 ? _currentIndex + 1 : 0;
    _sessionStart = null;
    unawaited(
      FirebaseLiteTelemetryService.instance.logSessionEnd(
        duration: duration,
        actions: actionsPlayed,
        completed: completed,
      ),
    );
  }
}

class PokerSessionPlaybackWidget extends StatefulWidget {
  const PokerSessionPlaybackWidget({
    super.key,
    required this.actions,
    required this.board,
    required this.potHistory,
    required this.positions,
    this.playerCount = 6,
    this.initialStacks,
    this.stepDuration = const Duration(seconds: 2),
    this.difficultyMultiplier = 1.0,
    this.repetitionRate = 0.25,
    this.analysisEntries = const [],
    this.enableExport = true,
  }) : assert(playerCount >= 2 && playerCount <= 10);

  final List<PlaybackAction> actions;
  final List<String> board;
  final List<int> potHistory;
  final List<String> positions;
  final int playerCount;
  final List<int>? initialStacks;
  final Duration stepDuration;
  final double difficultyMultiplier;
  final double repetitionRate;
  final List<HandAnalyzerEntry> analysisEntries;
  final bool enableExport;

  @override
  State<PokerSessionPlaybackWidget> createState() =>
      _PokerSessionPlaybackWidgetState();
}

class _PokerSessionPlaybackWidgetState
    extends State<PokerSessionPlaybackWidget> {
  late final SessionPlaybackEngine _engine;
  late PlaybackState _state;
  StreamSubscription<PlaybackState>? _subscription;
  HandAnalyzerEngine? _analyzer;
  HandAnalyzerResult? _analysisResult;
  StreamSubscription<HandAnalyzerResult?>? _analyzerSubscription;
  bool _showAnalysis = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _engine = SessionPlaybackEngine(
      actions: widget.actions,
      playerCount: widget.playerCount,
      initialStacks: widget.initialStacks,
      potHistory: widget.potHistory,
      stepDuration: widget.stepDuration,
    );
    _state = _engine.currentState;
    _subscription = _engine.states.listen((event) {
      if (mounted) {
        setState(() => _state = event);
        _analyzer?.updateIndex(event.currentIndex);
      }
    });
    if (widget.analysisEntries.isNotEmpty) {
      _analyzer = HandAnalyzerEngine(widget.analysisEntries);
      _analyzerSubscription = _analyzer!.results.listen((result) {
        if (mounted) {
          setState(() => _analysisResult = result);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _analyzerSubscription?.cancel();
    _analyzer?.dispose();
    _engine.dispose();
    super.dispose();
  }

  List<String> get _positions {
    if (widget.positions.length >= widget.playerCount) {
      return widget.positions.take(widget.playerCount).toList();
    }
    final fallback = [
      'Hero BTN (40bb)',
      'SB (35bb)',
      'BB (45bb)',
      'UTG (30bb)',
      'MP (42bb)',
      'CO (38bb)',
      'HJ (33bb)',
      'LJ (37bb)',
      'UTG+1 (31bb)',
      'BTN+1 (36bb)',
    ];
    final buffer = List<String>.from(widget.positions);
    if (buffer.length < widget.playerCount) {
      buffer.addAll(fallback.skip(buffer.length));
    }
    return buffer.take(widget.playerCount).toList();
  }

  PlaybackAction? get _currentAction => _state.currentAction;

  BettingAction get _bettingAction {
    final action = _currentAction;
    if (action == null) return BettingAction.none;
    switch (action.type) {
      case PlaybackActionType.bet:
        return BettingAction.bet;
      case PlaybackActionType.raise:
        return BettingAction.raise;
      case PlaybackActionType.call:
        return BettingAction.call;
      case PlaybackActionType.fold:
        return BettingAction.fold;
      case PlaybackActionType.check:
        return BettingAction.check;
      case PlaybackActionType.win:
      case PlaybackActionType.none:
        return BettingAction.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = _currentAction;
    final currentSeat = action?.seat ?? 0;
    final amount = action?.amount ?? 0;
    final board = widget.board;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PokerTableVisualizer(
                spotKind: action?.type == PlaybackActionType.win
                    ? SpotKind.l3_river_jam_vs_raise
                    : SpotKind.l3_flop_jam_vs_raise,
                heroAction: action?.description ?? action?.type.name ?? '---',
                villainAction: _villainDescription(action),
                board: board,
                pot: '${_state.pot} BB',
                positions: _positions,
                playerCount: widget.playerCount,
                difficultyMultiplier: widget.difficultyMultiplier,
                repetitionRate: widget.repetitionRate,
              ),
              IgnorePointer(
                child: PokerTableBettingLayer(
                  playerCount: widget.playerCount,
                  heroSeat: currentSeat.clamp(0, widget.playerCount - 1),
                  potSize: _state.pot,
                  action: _bettingAction,
                  amount: amount,
                ),
              ),
              if (_showAnalysis && _analysisResult != null)
                HandAnalyzerOverlay(result: _analysisResult!),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildControls(action),
      ],
    );
  }

  Widget _buildControls(PlaybackAction? action) {
    final isPlaying = _state.isPlaying;
    final label = action?.description ?? 'Ready';
    final index = _state.currentIndex >= 0
        ? '${_state.currentIndex + 1}/${widget.actions.length}'
        : '0/${widget.actions.length}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(index, style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Restart',
          onPressed: _engine.reset,
          icon: const Icon(Icons.replay_rounded),
        ),
        IconButton(
          tooltip: isPlaying ? 'Pause' : 'Play',
          onPressed: _engine.toggle,
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Step',
          onPressed: _engine.stepForward,
          icon: const Icon(Icons.skip_next_rounded),
        ),
        const SizedBox(width: 8),
        if (_analyzer != null)
          Row(
            children: [
              const Text('Analysis', style: TextStyle(fontSize: 12)),
              Switch(
                value: _showAnalysis,
                onChanged: (value) {
                  setState(() => _showAnalysis = value);
                },
              ),
            ],
          ),
        if (widget.enableExport) ...[
          const SizedBox(width: 12),
          _ExportButton(exporting: _exporting, onPressed: _handleExport),
        ],
      ],
    );
  }

  Future<void> _handleExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final summary = await exportAnalyzedSession(
        actions: widget.actions,
        analysis: widget.analysisEntries,
        positions: _positions,
        board: widget.board,
        potHistory: widget.potHistory,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session saved to ${summary.pathOriginal}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  String _villainDescription(PlaybackAction? action) {
    if (action == null) return 'Awaiting action';
    switch (action.type) {
      case PlaybackActionType.bet:
        return 'Seat ${action.seat + 1} bets ${action.amount} BB';
      case PlaybackActionType.raise:
        return 'Seat ${action.seat + 1} raises ${action.amount} BB';
      case PlaybackActionType.call:
        return 'Seat ${action.seat + 1} calls ${action.amount} BB';
      case PlaybackActionType.check:
        return 'Seat ${action.seat + 1} checks';
      case PlaybackActionType.fold:
        return 'Seat ${action.seat + 1} folds';
      case PlaybackActionType.win:
        return 'Seat ${action.seat + 1} drags the pot';
      case PlaybackActionType.none:
        return 'Idle';
    }
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.exporting, required this.onPressed});

  final bool exporting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: exporting ? null : onPressed,
      icon: Icon(exporting ? Icons.hourglass_top : Icons.save_alt),
      label: Text(exporting ? 'Saving…' : 'Save Session'),
    );
  }
}

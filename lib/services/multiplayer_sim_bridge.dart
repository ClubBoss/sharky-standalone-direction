import 'dart:async';
import 'dart:math';

import 'package:poker_analyzer/ui_v2/session_playback_engine.dart';

class SimTableSnapshot {
  const SimTableSnapshot({
    required this.tableId,
    required this.playerCount,
    required this.positions,
    required this.board,
    required this.pot,
    required this.currentAction,
    required this.stacks,
    required this.actionIndex,
  });

  final int tableId;
  final int playerCount;
  final List<String> positions;
  final List<String> board;
  final int pot;
  final PlaybackAction? currentAction;
  final List<int> stacks;
  final int actionIndex;
}

class MultiplayerSimBridge {
  MultiplayerSimBridge({
    required this.tableCount,
    required this.playersPerTable,
    Duration tick = const Duration(seconds: 2),
  }) : assert(tableCount >= 2 && tableCount <= 6),
       assert(playersPerTable >= 2 && playersPerTable <= 6),
       _tick = tick {
    _tables = List<_SimulatedTable>.generate(tableCount, (index) {
      final engine = SimulatedPlayerEngine(
        tableId: index,
        playerCount: playersPerTable,
      );
      return _SimulatedTable(
        tableId: index,
        playerCount: playersPerTable,
        engine: engine,
      );
    });
  }

  final int tableCount;
  final int playersPerTable;
  final Duration _tick;

  final StreamController<List<SimTableSnapshot>> _controller =
      StreamController<List<SimTableSnapshot>>.broadcast();
  late final List<_SimulatedTable> _tables;
  Timer? _timer;
  int _broadcastIndex = -1;

  static final List<PlaybackAction> _broadcastScript = <PlaybackAction>[
    const PlaybackAction(
      seat: 0,
      type: PlaybackActionType.bet,
      amount: 10,
      description: 'Global open',
    ),
    const PlaybackAction(
      seat: 1,
      type: PlaybackActionType.call,
      amount: 10,
      description: 'Global defend',
    ),
    const PlaybackAction(
      seat: 2,
      type: PlaybackActionType.fold,
      description: 'Global fold',
    ),
    const PlaybackAction(
      seat: 0,
      type: PlaybackActionType.bet,
      amount: 18,
      description: 'Global c-bet',
    ),
    const PlaybackAction(
      seat: 1,
      type: PlaybackActionType.fold,
      description: 'Global fold turn',
    ),
    const PlaybackAction(
      seat: 0,
      type: PlaybackActionType.win,
      amount: 0,
      description: 'Global pot awarded',
    ),
  ];

  Stream<List<SimTableSnapshot>> get snapshots => _controller.stream;

  List<SimTableSnapshot> get currentSnapshots =>
      _tables.map((table) => table.snapshot()).toList(growable: false);

  void start() {
    if (_timer != null) return;
    _emit();
    _timer = Timer.periodic(_tick, (_) => _step());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _step() {
    if (_broadcastScript.isEmpty) return;
    _broadcastIndex = (_broadcastIndex + 1) % _broadcastScript.length;
    final broadcast = _broadcastScript[_broadcastIndex];
    for (final table in _tables) {
      table.advance(broadcast);
    }
    _emit();
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(currentSnapshots);
  }
}

class _SimulatedTable {
  _SimulatedTable({
    required this.tableId,
    required this.playerCount,
    required this.engine,
  }) : stacks = List<int>.generate(
         playerCount,
         (index) => 1400 + tableId * 60 + index * 40,
       ),
       _baseSeatNames = List<String>.generate(
         playerCount,
         (index) => 'Seat ${index + 1}',
       );

  final int tableId;
  final int playerCount;
  final SimulatedPlayerEngine engine;

  final List<int> stacks;
  final List<String> _baseSeatNames;
  final List<String> board = <String>[];
  final List<String> _fullBoard = const ['Ah', '7c', '2d', 'Kd', '2s'];
  final Set<int> _foldedSeats = <int>{};
  final List<PlaybackAction> _history = <PlaybackAction>[];

  int pot = 0;
  int actionIndex = -1;
  PlaybackAction? currentAction;

  void advance(PlaybackAction broadcast) {
    final stepIndex = actionIndex + 1;
    final action = engine.onBroadcast(broadcast, this, stepIndex);
    actionIndex = stepIndex;
    currentAction = action;
    _history.add(action);
    _apply(action);
  }

  void _apply(PlaybackAction action) {
    final seat = action.seat.clamp(0, playerCount - 1);
    switch (action.type) {
      case PlaybackActionType.bet:
      case PlaybackActionType.raise:
      case PlaybackActionType.call:
        final amount = action.amount;
        pot += amount;
        stacks[seat] = max(0, stacks[seat] - amount);
        _foldedSeats.remove(seat);
        break;
      case PlaybackActionType.fold:
        _foldedSeats.add(seat);
        break;
      case PlaybackActionType.check:
      case PlaybackActionType.none:
        break;
      case PlaybackActionType.win:
        stacks[seat] += pot;
        pot = 0;
        _foldedSeats.clear();
        break;
    }

    if (actionIndex == 1) {
      board
        ..clear()
        ..addAll(_fullBoard.take(3));
    } else if (actionIndex == 3) {
      board
        ..clear()
        ..addAll(_fullBoard.take(4));
    } else if (actionIndex == 4) {
      board
        ..clear()
        ..addAll(_fullBoard);
    }
  }

  List<String> _seatLabels() {
    return List<String>.generate(playerCount, (index) {
      final base = _baseSeatNames[index];
      final stack = stacks[index];
      final folded = _foldedSeats.contains(index) ? ' (fold)' : '';
      return '$base ($stack bb)$folded';
    });
  }

  SimTableSnapshot snapshot() {
    return SimTableSnapshot(
      tableId: tableId,
      playerCount: playerCount,
      positions: _seatLabels(),
      board: List<String>.from(board),
      pot: pot,
      currentAction: currentAction,
      stacks: List<int>.from(stacks),
      actionIndex: actionIndex,
    );
  }
}

class SimulatedPlayerEngine {
  SimulatedPlayerEngine({required this.tableId, required this.playerCount})
    : seatOffset = tableId % playerCount;

  final int tableId;
  final int playerCount;
  final int seatOffset;
  final List<PlaybackActionType> _policy = const <PlaybackActionType>[
    PlaybackActionType.bet,
    PlaybackActionType.call,
    PlaybackActionType.raise,
    PlaybackActionType.fold,
    PlaybackActionType.bet,
    PlaybackActionType.win,
  ];

  PlaybackAction onBroadcast(
    PlaybackAction broadcast,
    _SimulatedTable table,
    int stepIndex,
  ) {
    final policyType = _policy[stepIndex % _policy.length];
    final seat = (broadcast.seat + seatOffset + stepIndex) % playerCount;
    final baseAmount = 8 + seat * 4 + tableId * 3;
    final amount =
        policyType == PlaybackActionType.bet ||
            policyType == PlaybackActionType.raise
        ? baseAmount
        : policyType == PlaybackActionType.call
        ? max(4, baseAmount ~/ 2)
        : 0;

    return PlaybackAction(
      seat: seat,
      type: policyType,
      amount: amount,
      description: _describe(policyType, seat, amount),
    );
  }

  String _describe(PlaybackActionType type, int seat, int amount) {
    final label = 'Seat ${seat + 1}';
    switch (type) {
      case PlaybackActionType.bet:
        return '$label bets $amount BB';
      case PlaybackActionType.raise:
        return '$label raises to $amount BB';
      case PlaybackActionType.call:
        return '$label calls $amount BB';
      case PlaybackActionType.fold:
        return '$label folds';
      case PlaybackActionType.check:
        return '$label checks';
      case PlaybackActionType.win:
        return '$label collects the pot';
      case PlaybackActionType.none:
        return '$label waits';
    }
  }
}

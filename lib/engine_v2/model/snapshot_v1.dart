import 'action_v1.dart';
import 'money_state_v1.dart';

class EngineSnapshotV1 {
  const EngineSnapshotV1({
    required this.handStarted,
    required this.actionCount,
    required this.players,
    required this.seatByPlayer,
    required this.stacksState,
    required this.foldedByPlayer,
    required this.street,
    required this.actingPlayer,
    required this.currentBet,
    required this.lastBetSize,
    this.lastAction,
  });

  final bool handStarted;
  final int actionCount;
  final List<PlayerIdV1> players;
  final Map<PlayerIdV1, SeatIdV1> seatByPlayer;
  final StacksStateV1 stacksState;
  final Map<PlayerIdV1, bool> foldedByPlayer;
  final StreetV1 street;
  final PlayerIdV1 actingPlayer;
  final ChipsV1 currentBet;
  final ChipsV1 lastBetSize;
  final ActionV1? lastAction;

  factory EngineSnapshotV1.initial({
    required List<PlayerIdV1> players,
    required ChipsV1 startingStack,
  }) {
    if (players.length < 2) {
      throw ArgumentError('At least 2 players are required');
    }
    final seatByPlayer = <PlayerIdV1, SeatIdV1>{
      for (var i = 0; i < players.length; i++) players[i]: SeatIdV1(i),
    };
    return EngineSnapshotV1(
      handStarted: false,
      actionCount: 0,
      players: List<PlayerIdV1>.unmodifiable(players),
      seatByPlayer: seatByPlayer,
      stacksState: StacksStateV1.initial(
        players: players,
        startingStack: startingStack,
      ),
      foldedByPlayer: <PlayerIdV1, bool>{for (final p in players) p: false},
      street: StreetV1.preflop,
      actingPlayer: players.first,
      currentBet: const ChipsV1(0),
      lastBetSize: const ChipsV1(0),
    );
  }

  int toCallFor(PlayerIdV1 player) {
    final committed = stacksState.committedFor(player).value;
    final toCall = currentBet.value - committed;
    return toCall > 0 ? toCall : 0;
  }

  bool isFolded(PlayerIdV1 player) => foldedByPlayer[player] ?? false;

  EngineSnapshotV1 copyWith({
    bool? handStarted,
    int? actionCount,
    List<PlayerIdV1>? players,
    Map<PlayerIdV1, SeatIdV1>? seatByPlayer,
    StacksStateV1? stacksState,
    Map<PlayerIdV1, bool>? foldedByPlayer,
    StreetV1? street,
    PlayerIdV1? actingPlayer,
    ChipsV1? currentBet,
    ChipsV1? lastBetSize,
    ActionV1? lastAction,
    bool clearLastAction = false,
  }) {
    return EngineSnapshotV1(
      handStarted: handStarted ?? this.handStarted,
      actionCount: actionCount ?? this.actionCount,
      players: players ?? this.players,
      seatByPlayer: seatByPlayer ?? this.seatByPlayer,
      stacksState: stacksState ?? this.stacksState,
      foldedByPlayer: foldedByPlayer ?? this.foldedByPlayer,
      street: street ?? this.street,
      actingPlayer: actingPlayer ?? this.actingPlayer,
      currentBet: currentBet ?? this.currentBet,
      lastBetSize: lastBetSize ?? this.lastBetSize,
      lastAction: clearLastAction ? null : (lastAction ?? this.lastAction),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! EngineSnapshotV1) {
      return false;
    }
    return handStarted == other.handStarted &&
        actionCount == other.actionCount &&
        _listEquals(players, other.players) &&
        _mapEquals(seatByPlayer, other.seatByPlayer) &&
        stacksState == other.stacksState &&
        _mapEquals(foldedByPlayer, other.foldedByPlayer) &&
        street == other.street &&
        actingPlayer == other.actingPlayer &&
        currentBet == other.currentBet &&
        lastBetSize == other.lastBetSize &&
        lastAction == other.lastAction;
  }

  @override
  int get hashCode => Object.hash(
    handStarted,
    actionCount,
    Object.hashAll(players),
    _mapHash(seatByPlayer),
    stacksState,
    _mapHash(foldedByPlayer),
    street,
    actingPlayer,
    currentBet,
    lastBetSize,
    lastAction,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

int _mapHash<K, V>(Map<K, V> map) {
  final keys = map.keys.toList()
    ..sort((a, b) => a.toString().compareTo(b.toString()));
  var hash = 17;
  for (final key in keys) {
    hash = 37 * hash + Object.hash(key, map[key]);
  }
  return hash;
}

enum StreetV1 { preflop, flop, turn, river }

class ChipsV1 {
  const ChipsV1(this.value) : assert(value >= 0, 'Chips must be non-negative');

  final int value;

  ChipsV1 operator +(ChipsV1 other) => ChipsV1(value + other.value);

  ChipsV1 operator -(ChipsV1 other) {
    final next = value - other.value;
    if (next < 0) {
      throw StateError('Chips cannot go negative');
    }
    return ChipsV1(next);
  }

  @override
  bool operator ==(Object other) => other is ChipsV1 && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ChipsV1($value)';
}

class PlayerIdV1 {
  const PlayerIdV1(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is PlayerIdV1 && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class SeatIdV1 {
  const SeatIdV1(this.value) : assert(value >= 0, 'Seat index must be >= 0');

  final int value;

  @override
  bool operator ==(Object other) => other is SeatIdV1 && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class StacksStateV1 {
  const StacksStateV1({
    required this.stackByPlayer,
    required this.committedByPlayer,
    required this.pot,
  });

  final Map<PlayerIdV1, ChipsV1> stackByPlayer;
  final Map<PlayerIdV1, ChipsV1> committedByPlayer;
  final ChipsV1 pot;

  factory StacksStateV1.initial({
    required List<PlayerIdV1> players,
    required ChipsV1 startingStack,
  }) {
    final stackByPlayer = <PlayerIdV1, ChipsV1>{
      for (final player in players) player: startingStack,
    };
    final committedByPlayer = <PlayerIdV1, ChipsV1>{
      for (final player in players) player: const ChipsV1(0),
    };
    return StacksStateV1(
      stackByPlayer: stackByPlayer,
      committedByPlayer: committedByPlayer,
      pot: const ChipsV1(0),
    );
  }

  ChipsV1 stackFor(PlayerIdV1 player) {
    return stackByPlayer[player] ?? const ChipsV1(0);
  }

  ChipsV1 committedFor(PlayerIdV1 player) {
    return committedByPlayer[player] ?? const ChipsV1(0);
  }

  int totalCommitted() {
    return committedByPlayer.values.fold<int>(
      0,
      (sum, chips) => sum + chips.value,
    );
  }

  StacksStateV1 copyWith({
    Map<PlayerIdV1, ChipsV1>? stackByPlayer,
    Map<PlayerIdV1, ChipsV1>? committedByPlayer,
    ChipsV1? pot,
  }) {
    return StacksStateV1(
      stackByPlayer: stackByPlayer ?? this.stackByPlayer,
      committedByPlayer: committedByPlayer ?? this.committedByPlayer,
      pot: pot ?? this.pot,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! StacksStateV1) {
      return false;
    }
    return _mapEquals(stackByPlayer, other.stackByPlayer) &&
        _mapEquals(committedByPlayer, other.committedByPlayer) &&
        pot == other.pot;
  }

  @override
  int get hashCode =>
      Object.hash(_mapHash(stackByPlayer), _mapHash(committedByPlayer), pot);
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

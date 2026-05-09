class SimulationState {
  SimulationState({required this.players, List<String>? board})
    : pot = 0,
      board = board ?? <String>[],
      actions = <Map<String, Object?>>[],
      currentIndex = 0;

  final List<String> players;
  final List<String> board;
  final List<Map<String, Object?>> actions;
  int pot;
  int currentIndex;

  /// Applies an action to the state, updating pot and advancing the index.
  void applyAction(Map<String, Object?> action) {
    final player = action['player']?.toString();
    if (player == null) {
      throw ArgumentError('Action must include a player');
    }
    if (!players.contains(player)) {
      throw ArgumentError('Unknown player: $player');
    }
    final type = action['type']?.toString() ?? 'unknown';
    final amount = (action['amount'] as num?)?.toInt() ?? 0;

    if (_countsTowardPot(type)) {
      pot += amount;
    }

    actions.add({'player': player, 'type': type, 'amount': amount});

    currentIndex = (currentIndex + 1) % players.length;
  }

  /// Resets the state to initial conditions.
  void reset() {
    pot = 0;
    actions.clear();
    board.clear();
    currentIndex = 0;
  }

  /// Returns an ASCII summary of the current state.
  String summary() {
    final nextPlayer = players.isEmpty ? 'N/A' : players[currentIndex];
    final boardString = board.isEmpty ? '-' : board.join(' ');
    return 'Pot: $pot | Board: $boardString | Next to act: $nextPlayer';
  }

  bool _countsTowardPot(String type) {
    switch (type) {
      case 'bet':
      case 'call':
      case 'raise':
        return true;
      default:
        return false;
    }
  }
}

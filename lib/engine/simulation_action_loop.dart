import 'simulation_state_engine.dart';

class ActionQueue {
  ActionQueue(List<Map<String, Object?>> actions)
    : _actions = List<Map<String, Object?>>.from(actions);

  final List<Map<String, Object?>> _actions;
  int _index = 0;

  Map<String, Object?>? peek() {
    if (_index >= _actions.length) {
      return null;
    }
    return _actions[_index];
  }

  void consume() {
    if (_index < _actions.length) {
      _index += 1;
    }
  }

  bool get isEmpty => _index >= _actions.length;
}

class ActionLoop {
  ActionLoop(this.queue, this.state)
    : _foldedPlayers = <String>{},
      _actedPlayers = <String>{} {
    _alignCurrentIndex();
  }

  final ActionQueue queue;
  final SimulationState state;

  final Set<String> _foldedPlayers;
  final Set<String> _actedPlayers;

  Map<String, Object> nextAction() {
    _alignCurrentIndex();
    final player = state.players.isEmpty
        ? 'N/A'
        : state.players[state.currentIndex];
    return <String, Object>{'player': player, 'allowed_moves': _allowedMoves()};
  }

  void resolve(Map<String, Object?> action) {
    final player = action['player']?.toString();
    if (player == null) {
      throw ArgumentError('Action must include player');
    }
    final type = action['type']?.toString() ?? 'unknown';

    final queued = queue.peek();
    if (queued != null &&
        queued['player']?.toString() == player &&
        queued['type']?.toString() == type) {
      queue.consume();
    }

    state.applyAction(action);

    if (type == 'fold') {
      _foldedPlayers.add(player);
      _actedPlayers.remove(player);
    } else {
      _actedPlayers.add(player);
    }

    _alignCurrentIndex();
  }

  bool get isRoundComplete {
    final activePlayers = state.players
        .where((player) => !_foldedPlayers.contains(player))
        .toList();
    if (activePlayers.length <= 1) {
      return true;
    }
    if (activePlayers.isEmpty) {
      return true;
    }
    for (final player in activePlayers) {
      if (!_actedPlayers.contains(player)) {
        return false;
      }
    }
    return true;
  }

  List<String> _allowedMoves() {
    if (state.pot <= 0) {
      return const ['check', 'bet', 'fold'];
    }
    return const ['call', 'bet', 'fold', 'check'];
  }

  void _alignCurrentIndex() {
    if (state.players.isEmpty) {
      return;
    }
    var attempts = 0;
    final total = state.players.length;
    while (_foldedPlayers.contains(state.players[state.currentIndex]) &&
        attempts < total) {
      state.currentIndex = (state.currentIndex + 1) % total;
      attempts += 1;
    }
  }
}

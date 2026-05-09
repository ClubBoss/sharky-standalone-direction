class SimulationReplayEngine {
  SimulationReplayEngine();

  final List<Map<String, Object?>> _history = <Map<String, Object?>>[];
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  int get totalActions => _history.length;
  bool get hasHistory => _history.isNotEmpty;

  void recordAction(Map<String, Object?> action) {
    if (_currentIndex < _history.length) {
      _history.removeRange(_currentIndex, _history.length);
    }
    _history.add(Map<String, Object?>.from(action));
    _currentIndex = _history.length;
  }

  bool stepBack() {
    if (_currentIndex == 0) {
      return false;
    }
    _currentIndex -= 1;
    return true;
  }

  bool stepForward() {
    if (_currentIndex >= _history.length) {
      return false;
    }
    _currentIndex += 1;
    return true;
  }

  void resetReplay() {
    _currentIndex = 0;
  }

  List<Map<String, Object?>> get appliedActions => _history
      .take(_currentIndex)
      .map(Map<String, Object?>.from)
      .toList(growable: false);

  String summary(String label) {
    return '$_currentIndex / ${_history.length} $label';
  }
}

import 'dart:async';

typedef SimulationCallback = void Function();

class SimulationTimingEngine {
  SimulationTimingEngine({this.delayMs = 1200});

  final int delayMs;
  bool _paused = false;
  Timer? _timer;

  final StreamController<void> _aiActionController =
      StreamController<void>.broadcast();
  final StreamController<void> _roundCompleteController =
      StreamController<void>.broadcast();

  Stream<void> get onAiActionReady => _aiActionController.stream;
  Stream<void> get onRoundComplete => _roundCompleteController.stream;

  void scheduleNextAction(SimulationCallback callback) {
    _timer?.cancel();
    if (_paused) {
      return;
    }
    _timer = Timer(Duration(milliseconds: delayMs), () {
      callback();
      _aiActionController.add(null);
    });
  }

  void signalRoundComplete() {
    _roundCompleteController.add(null);
  }

  void pause() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    _paused = false;
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _aiActionController.add(null);
  }

  void dispose() {
    _timer?.cancel();
    _aiActionController.close();
    _roundCompleteController.close();
  }
}

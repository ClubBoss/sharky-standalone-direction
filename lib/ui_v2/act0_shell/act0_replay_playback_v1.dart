/// Playback cursor over the steps in a saved replay, driven by elapsed deltas.
class Act0ReplayPlaybackV1 {
  Act0ReplayPlaybackV1({
    required this.stepCount,
    this.baseStepDuration = const Duration(seconds: 1),
    this.reduceMotion = false,
  }) {
    RangeError.checkNotNegative(stepCount, 'stepCount');
    // Even at 2×, a step must have a positive duration in microseconds.
    if (baseStepDuration.inMicroseconds < 2) {
      throw ArgumentError.value(baseStepDuration, 'baseStepDuration');
    }
  }

  final int stepCount;
  final Duration baseStepDuration;
  final bool reduceMotion;

  int _currentIndex = 0;
  bool _isPlaying = false;
  double _speed = 1;
  int _elapsedMicroseconds = 0;

  /// Zero-based event index, or zero when the replay is empty.
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  double get speed => _speed;
  bool get shouldAnimate => !reduceMotion;

  String get semanticsLabel {
    final step = stepCount == 0 ? 0 : currentIndex + 1;
    final speedText = speed == 0.5 ? '0.5' : speed.toInt().toString();
    final state = isPlaying ? 'Playing' : 'Paused';
    return 'Step $step of $stepCount · speed $speedText×, $state';
  }

  void play() {
    if (currentIndex < stepCount - 1) _isPlaying = true;
  }

  void pause() {
    _isPlaying = false;
  }

  void toggle() => isPlaying ? pause() : play();

  void stepForward() => seekTo(currentIndex + 1);
  void stepBack() => seekTo(currentIndex - 1);

  /// Manual navigation pauses playback and clears time toward the next step.
  void seekTo(int index) {
    if (stepCount == 0) return;
    pause();
    _currentIndex = index.clamp(0, stepCount - 1);
    _elapsedMicroseconds = 0;
  }

  /// Returns to the first step and keeps the selected speed.
  void reset() => seekTo(0);

  void setSpeed(double speed) {
    if (speed != 0.5 && speed != 1 && speed != 2) {
      throw ArgumentError.value(speed, 'speed', 'Use 0.5, 1 or 2');
    }
    if (stepCount == 0 || speed == _speed) return;
    _speed = speed;
    _elapsedMicroseconds = 0;
  }

  void tick(Duration elapsed) {
    if (!isPlaying || elapsed <= Duration.zero) return;
    final stepMicros = (baseStepDuration.inMicroseconds / speed).round();
    final untilNextStep = stepMicros - _elapsedMicroseconds;
    if (elapsed.inMicroseconds < untilNextStep) {
      _elapsedMicroseconds += elapsed.inMicroseconds;
      return;
    }
    final afterNextStep = elapsed.inMicroseconds - untilNextStep;
    final steps = 1 + afterNextStep ~/ stepMicros;
    final remainingSteps = stepCount - 1 - currentIndex;
    if (steps >= remainingSteps) {
      seekTo(stepCount - 1);
      return;
    }
    _currentIndex += steps;
    _elapsedMicroseconds = afterNextStep % stepMicros;
  }
}

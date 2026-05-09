import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

class PotMotionController extends ChangeNotifier {
  PotMotionController({this.threshold = 16, this.fadeMs = 300});

  final double threshold;
  final double fadeMs;
  double _count = 0.0;
  double _intensity = 0.0;
  Timer? _fadeTimer;

  double get intensity => _intensity;

  void onChipArrived() {
    _fadeTimer?.cancel();
    _count = math.min(threshold, _count + 1);
    _intensity = (_count / threshold).clamp(0.0, 1.0);
    notifyListeners();
  }

  void startFadeSequence() {
    _fadeTimer?.cancel();
    if (_intensity <= 0) {
      _count = 0;
      return;
    }
    final steps = 12;
    final stepDuration = Duration(milliseconds: (fadeMs / steps).ceil());
    var currentStep = 0;
    final startIntensity = _intensity;
    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      final progress = (currentStep / steps).clamp(0.0, 1.0);
      _intensity = (startIntensity * (1.0 - progress)).clamp(0.0, 1.0);
      notifyListeners();
      if (currentStep >= steps) {
        timer.cancel();
        _fadeTimer = null;
        _count = 0;
        _intensity = 0;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }
}

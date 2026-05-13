import 'dart:async';

import 'package:flutter/foundation.dart';

enum MascotPose { idle, celebrate, thinking }

/// Controls the Poker Shark mascot state for the V3 simulation UI.
class MascotController extends ChangeNotifier {
  MascotController();

  static const Map<MascotPose, String> _assetMap = <MascotPose, String>{
    MascotPose.idle: 'assets/mascot/poker_shark_idle.svg',
    MascotPose.celebrate: 'assets/mascot/poker_shark_celebrate.svg',
    MascotPose.thinking: 'assets/mascot/poker_shark_thinking.svg',
  };

  MascotPose _pose = MascotPose.idle;
  double _opacity = 0.0;
  Timer? _revertTimer;
  StreamSubscription<String>? _successSub;

  MascotPose get pose => _pose;
  double get opacity => _opacity;
  String get assetName => _assetMap[_pose]!;

  String get poseLabel {
    final name = _pose.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  void setIdle({double opacity = 0.6}) {
    _setPose(MascotPose.idle, opacity);
  }

  void setThinking() {
    _setPose(MascotPose.thinking, 1.0);
  }

  void celebrate({Duration duration = const Duration(seconds: 2)}) {
    _setPose(MascotPose.celebrate, 1.0);
    _revertTimer?.cancel();
    _revertTimer = Timer(duration, setIdle);
  }

  void hide() {
    _revertTimer?.cancel();
    _opacity = 0.0;
    notifyListeners();
  }

  /// Bind a success events stream (e.g., telemetry) to trigger celebrate().
  /// Expects ASCII event names; default event key: 'user_success'.
  void bindSuccessEvents(
    Stream<String> events, {
    String successEvent = 'user_success',
  }) {
    _successSub?.cancel();
    _successSub = events.listen((evt) {
      if (evt == successEvent) {
        celebrate();
      }
    });
  }

  void _setPose(MascotPose next, double opacity) {
    _revertTimer?.cancel();
    final normalized = opacity.clamp(0.0, 1.0);
    if (_pose == next && (_opacity - normalized).abs() < 0.001) {
      return;
    }
    _pose = next;
    _opacity = normalized;
    notifyListeners();
  }

  @override
  void dispose() {
    _revertTimer?.cancel();
    _successSub?.cancel();
    super.dispose();
  }
}

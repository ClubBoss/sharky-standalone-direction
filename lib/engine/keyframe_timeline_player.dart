import 'dart:ui';

import 'keyframe_model.dart';
import 'keyframe_timeline_resolver.dart';

class KeyframeTimelinePlayer {
  final KeyframeTrack track;
  final KeyframeTimelineResolver resolver;
  double _time = 0.0;
  final Map<double, VoidCallback> eventMap = {};

  KeyframeTimelinePlayer({required this.track, required this.resolver});

  void advance(double dt) {
    if (dt < 0.0) return;
    final prevTime = _time;
    _time += dt;
    if (eventMap.isEmpty) return;
    for (final entry in eventMap.entries) {
      final eventTime = entry.key;
      if (prevTime < eventTime && _time >= eventTime) {
        entry.value();
      }
    }
  }

  double value() => resolver.sample(track, _time);

  void reset() {
    _time = 0.0;
  }

  void registerEvent(double time, VoidCallback callback) {
    eventMap[time] = callback;
  }
}

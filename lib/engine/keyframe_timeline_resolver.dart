import 'interpolation_utils.dart';
import 'keyframe_model.dart';

class KeyframeTimelineResolver {
  const KeyframeTimelineResolver();

  double sample(KeyframeTrack track, double t) {
    assert(t >= 0);
    final frames = track.frames;
    if (frames.isEmpty) return 0.0;
    final first = frames.first;
    if (t <= first.time) return first.value;
    final last = frames.last;
    if (t >= last.time) return last.value;

    for (var i = 0; i < frames.length - 1; i++) {
      final current = frames[i];
      final next = frames[i + 1];
      if (t < next.time) {
        final span = next.time - current.time;
        if (span <= 0.0) return current.value;
        final ratio = InterpolationUtils.clamp01((t - current.time) / span);
        return InterpolationUtils.lerp(current.value, next.value, ratio);
      }
    }

    return last.value;
  }
}

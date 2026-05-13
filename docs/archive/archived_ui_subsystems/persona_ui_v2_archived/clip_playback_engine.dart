import 'clip_frame_spec.dart';
import 'clip_sequence_spec.dart';

class ClipPlaybackEngine {
  ClipPlaybackEngine(this.sequence);

  final ClipSequenceSpec sequence;
  double _t = 0.0;

  void reset() {
    _t = 0.0;
  }

  void advance(double dt) {
    _t += dt;
    if (_t > 1.0) {
      _t = 1.0;
    }
  }

  ClipFrameSpec current() {
    final frames = sequence.frames;
    if (frames.length == 1) {
      return frames.first;
    }
    final scaled = _t * (frames.length - 1);
    final idx = scaled.floor().clamp(0, frames.length - 2);
    final frac = scaled - idx;
    final a = frames[idx];
    final b = frames[idx + 1];
    return ClipFrameSpec(
      t: _t,
      scale: a.scale + (b.scale - a.scale) * frac,
      yLift: a.yLift + (b.yLift - a.yLift) * frac,
      opacity: a.opacity + (b.opacity - a.opacity) * frac,
    );
  }
}

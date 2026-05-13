import 'clip_frame_spec.dart';
import 'clip_playback_engine.dart';
import 'clip_registry.dart';
import 'clip_sequence_spec.dart';

class ClipOrchestrator {
  ClipOrchestrator(this.registry);

  final ClipRegistry registry;
  ClipPlaybackEngine? _engine;
  ClipSequenceSpec? _active;
  ClipSequenceSpec? get activeSequence => _active;

  void startClip(String key) {
    final seq = registry.getClip(key);
    if (seq == null) return;
    _active = seq;
    _engine = ClipPlaybackEngine(seq)..reset();
  }

  void stopClip() {
    _active = null;
    _engine = null;
  }

  void tick(double dt) => _engine?.advance(dt);

  ClipFrameSpec? currentFrame() => _engine?.current();
}

class Keyframe {
  final double time;
  final double value;

  const Keyframe({required this.time, required this.value});
}

class KeyframeTrack {
  final List<Keyframe> frames;

  const KeyframeTrack(this.frames);
}

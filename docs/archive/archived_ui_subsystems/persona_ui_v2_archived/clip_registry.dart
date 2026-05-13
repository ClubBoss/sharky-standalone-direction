import 'clip_frame_spec.dart';
import 'clip_sequence_spec.dart';

class ClipRegistry {
  const ClipRegistry(this.clips);

  final Map<String, ClipSequenceSpec> clips;

  static final ClipRegistry empty = ClipRegistry({
    'blink': ClipSequenceSpec(id: 'blink', frames: [const ClipFrameSpec(t: 0)]),
    'nod': ClipSequenceSpec(id: 'nod', frames: [const ClipFrameSpec(t: 0)]),
    'tilt_recover': ClipSequenceSpec(
      id: 'tilt_recover',
      frames: [const ClipFrameSpec(t: 0)],
    ),
    'foldSmall': ClipSequenceSpec(
      id: 'foldSmall',
      frames: [const ClipFrameSpec(t: 0)],
    ),
    'callSmall': ClipSequenceSpec(
      id: 'callSmall',
      frames: [const ClipFrameSpec(t: 0)],
    ),
    'raiseStrong': ClipSequenceSpec(
      id: 'raiseStrong',
      frames: [const ClipFrameSpec(t: 0)],
    ),
    'winnerBurst': ClipSequenceSpec(
      id: 'winnerBurst',
      frames: [const ClipFrameSpec(t: 0)],
    ),
  });

  ClipSequenceSpec? getClip(String key) => clips[key];
}

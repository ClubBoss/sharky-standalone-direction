import 'clip_frame_spec.dart';

class ClipSequenceSpec {
  ClipSequenceSpec({required this.id, required List<ClipFrameSpec> frames})
    : assert(frames.isNotEmpty),
      frames = List.unmodifiable(frames);

  final String id;
  final List<ClipFrameSpec> frames;
}

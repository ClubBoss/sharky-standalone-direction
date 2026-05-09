import 'animation_surface_timeline_mux.dart';
import 'animation_surface_timeline_stream.dart';

class AnimationSurfaceTimelineCompactor {
  AnimationSurfaceTimelineCompactor(this.input);

  final AnimationSurfaceTimelineMuxResult input;

  List<AnimationSurfaceTimelineStreamEntry> build() => [
    ...input.even,
    ...input.odd,
  ];
}

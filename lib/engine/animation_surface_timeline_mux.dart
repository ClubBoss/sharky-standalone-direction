import 'animation_surface_timeline_stream.dart';

class AnimationSurfaceTimelineMuxResult {
  const AnimationSurfaceTimelineMuxResult(this.even, this.odd);

  final List<AnimationSurfaceTimelineStreamEntry> even;
  final List<AnimationSurfaceTimelineStreamEntry> odd;
}

class AnimationSurfaceTimelineMux {
  AnimationSurfaceTimelineMux(List<AnimationSurfaceTimelineStreamEntry> entries)
    : even = entries.where((entry) => entry.index % 2 == 0).toList(),
      odd = entries.where((entry) => entry.index % 2 == 1).toList();

  final List<AnimationSurfaceTimelineStreamEntry> even;
  final List<AnimationSurfaceTimelineStreamEntry> odd;

  AnimationSurfaceTimelineMuxResult build() =>
      AnimationSurfaceTimelineMuxResult(even, odd);
}

import 'animation_surface_timeline_stream.dart';

class AnimationSurfaceTimelineIndexMap {
  const AnimationSurfaceTimelineIndexMap(this.map);

  final Map<int, AnimationSurfaceTimelineStreamEntry> map;
}

class AnimationSurfaceTimelineIndexMapBuilder {
  AnimationSurfaceTimelineIndexMapBuilder(this.entries);

  final List<AnimationSurfaceTimelineStreamEntry> entries;

  AnimationSurfaceTimelineIndexMap build() {
    final m = <int, AnimationSurfaceTimelineStreamEntry>{};
    for (var i = 0; i < entries.length; i++) {
      m[i] = entries[i];
    }
    return AnimationSurfaceTimelineIndexMap(m);
  }
}

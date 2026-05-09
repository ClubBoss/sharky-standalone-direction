import 'animation_surface_timeline_builder.dart';

class AnimationSurfaceTimelineStreamEntry {
  const AnimationSurfaceTimelineStreamEntry(
    this.index,
    this.timestamp,
    this.labels,
  );

  final int index;
  final int timestamp;
  final List<String> labels;
}

class AnimationSurfaceTimelineStream {
  AnimationSurfaceTimelineStream(this.entries);

  final List<AnimationSurfaceTimelineEntry> entries;

  List<AnimationSurfaceTimelineStreamEntry> build() {
    return entries
        .map(
          (entry) => AnimationSurfaceTimelineStreamEntry(
            entry.index,
            entry.timestamp,
            entry.labels,
          ),
        )
        .toList();
  }
}

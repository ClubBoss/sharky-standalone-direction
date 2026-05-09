import 'animation_surface_timeline_builder.dart';

class AnimationSurfaceTimelineRange {
  const AnimationSurfaceTimelineRange(this.minTs, this.maxTs);

  final int minTs;
  final int maxTs;
}

class AnimationSurfaceTimelineRangeBuilder {
  AnimationSurfaceTimelineRangeBuilder(this.entries);

  final List<AnimationSurfaceTimelineEntry> entries;

  AnimationSurfaceTimelineRange build() {
    if (entries.isEmpty) {
      return const AnimationSurfaceTimelineRange(0, 0);
    }
    var minTs = entries.first.timestamp;
    var maxTs = entries.first.timestamp;
    for (final entry in entries) {
      if (entry.timestamp < minTs) {
        minTs = entry.timestamp;
      }
      if (entry.timestamp > maxTs) {
        maxTs = entry.timestamp;
      }
    }
    return AnimationSurfaceTimelineRange(minTs, maxTs);
  }
}

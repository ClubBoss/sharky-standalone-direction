import 'animation_surface_timeline_stream.dart';

class AnimationSurfaceTimelineMeta {
  const AnimationSurfaceTimelineMeta(
    this.count,
    this.firstTimestamp,
    this.lastTimestamp,
  );

  final int count;
  final int firstTimestamp;
  final int lastTimestamp;
}

class AnimationSurfaceTimelineMetaBuilder {
  AnimationSurfaceTimelineMetaBuilder(this.entries);

  final List<AnimationSurfaceTimelineStreamEntry> entries;

  AnimationSurfaceTimelineMeta build() {
    if (entries.isEmpty) {
      return const AnimationSurfaceTimelineMeta(0, 0, 0);
    }
    return AnimationSurfaceTimelineMeta(
      entries.length,
      entries.first.timestamp,
      entries.last.timestamp,
    );
  }
}

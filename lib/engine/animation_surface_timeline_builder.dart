import 'animation_surface_kernel_binder.dart';

class AnimationSurfaceTimelineEntry {
  const AnimationSurfaceTimelineEntry(this.index, this.timestamp, this.labels);

  final int index;
  final int timestamp;
  final List<String> labels;
}

class AnimationSurfaceTimelineBuilder {
  AnimationSurfaceTimelineBuilder(this.frames);

  final List<UiSurfaceFrame> frames;

  List<AnimationSurfaceTimelineEntry> build() {
    final out = <AnimationSurfaceTimelineEntry>[];
    for (final frame in frames) {
      out.add(
        AnimationSurfaceTimelineEntry(
          frame.index,
          frame.timestamp,
          frame.labels,
        ),
      );
    }
    return out;
  }
}

import 'motion_ui_binder.dart';

class TimelineFrame {
  const TimelineFrame(this.index, this.atMs, this.label);

  final int index;
  final int atMs;
  final String label;
}

class MotionTimelineMapper {
  MotionTimelineMapper(this.binder);

  final MotionUiBinder binder;

  List<TimelineFrame> buildTimeline() {
    final frames = binder.buildUiFrames();
    return frames
        .map(
          (frame) => TimelineFrame(
            frame.index,
            frame.atMs,
            '${frame.kind}:${frame.id}',
          ),
        )
        .toList();
  }
}

import 'motion_timeline_mapper.dart';

class UiFrameStreamEntry {
  const UiFrameStreamEntry(this.index, this.atMs, this.label);

  final int index;
  final int atMs;
  final String label;
}

class MotionFrameStreamEngine {
  MotionFrameStreamEngine(this.mapper);

  final MotionTimelineMapper mapper;

  List<UiFrameStreamEntry> buildStream() {
    final frames = mapper.buildTimeline();
    return frames
        .map(
          (frame) => UiFrameStreamEntry(frame.index, frame.atMs, frame.label),
        )
        .toList();
  }
}

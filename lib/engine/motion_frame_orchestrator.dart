import 'ui_motion_timeline_binder.dart';

class UiFrameBatch {
  const UiFrameBatch(this.batchIndex, this.labels);

  final int batchIndex;
  final List<String> labels;
}

class MotionFrameOrchestrator {
  MotionFrameOrchestrator(this.binder);

  final UiMotionTimelineBinder binder;

  List<UiFrameBatch> buildBatches() {
    final timeline = binder.buildTimeline();
    return timeline
        .map((entry) => UiFrameBatch(entry.index, [entry.label]))
        .toList();
  }
}

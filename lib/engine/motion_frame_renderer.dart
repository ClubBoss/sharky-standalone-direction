import 'motion_frame_scheduler.dart';

class RenderFrame {
  const RenderFrame(this.index, this.timestamp, this.label);

  final int index;
  final int timestamp;
  final String label;
}

class MotionFrameRenderer {
  MotionFrameRenderer(this.scheduler);

  final MotionFrameScheduler scheduler;

  List<RenderFrame> buildRenderFrames() {
    final scheduled = scheduler.buildSchedule();
    return scheduled
        .map(
          (frame) => RenderFrame(
            frame.index,
            frame.timestamp,
            'render_${frame.label}',
          ),
        )
        .toList();
  }
}

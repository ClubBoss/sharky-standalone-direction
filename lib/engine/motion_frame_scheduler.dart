import 'motion_frame_animator.dart';

class ScheduledFrame {
  const ScheduledFrame(this.index, this.timestamp, this.label);

  final int index;
  final int timestamp;
  final String label;
}

class MotionFrameScheduler {
  MotionFrameScheduler(this.animator);

  final MotionFrameAnimator animator;

  List<ScheduledFrame> buildSchedule() {
    final animated = animator.buildAnimatedFrames();
    return animated
        .map(
          (frame) =>
              ScheduledFrame(frame.index, frame.timestamp + 50, frame.label),
        )
        .toList();
  }
}

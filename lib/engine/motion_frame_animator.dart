import 'animation_sync_channel.dart';

class AnimatedFrame {
  const AnimatedFrame(this.index, this.timestamp, this.label);

  final int index;
  final int timestamp;
  final String label;
}

class MotionFrameAnimator {
  MotionFrameAnimator(this.syncChannel);

  final AnimationSyncChannel syncChannel;

  List<AnimatedFrame> buildAnimatedFrames() {
    final frames = syncChannel.buildSyncFrames();
    return frames
        .map(
          (frame) => AnimatedFrame(frame.index, frame.index * 100, frame.label),
        )
        .toList();
  }
}

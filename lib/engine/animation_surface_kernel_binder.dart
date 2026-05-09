import '../engine/motion_surface_player.dart';

class UiSurfaceFrame {
  const UiSurfaceFrame(this.index, this.timestamp, this.labels);

  final int index;
  final int timestamp;
  final List<String> labels;
}

class AnimationSurfaceKernelBinder {
  AnimationSurfaceKernelBinder(this.player);

  final MotionSurfacePlayer player;

  List<UiSurfaceFrame> build() {
    final flow = player.flow();
    final result = <UiSurfaceFrame>[];
    for (var i = 0; i < flow.length; i++) {
      final entry = flow[i];
      final timestamp = (entry['timestamp'] as num).toInt();
      final labels = List<String>.from(entry['frames'] as List<Object?>);
      result.add(UiSurfaceFrame(i, timestamp, labels));
    }
    return result;
  }
}

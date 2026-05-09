import 'motion_frame_stream_engine.dart';

class UiSurfaceFrame {
  const UiSurfaceFrame(this.index, this.atMs, this.label);

  final int index;
  final int atMs;
  final String label;
}

class MotionSurfaceBinder {
  MotionSurfaceBinder(this.engine);

  final MotionFrameStreamEngine engine;

  List<UiSurfaceFrame> buildSurfaceFrames() {
    final stream = engine.buildStream();
    return stream
        .map((entry) => UiSurfaceFrame(entry.index, entry.atMs, entry.label))
        .toList();
  }
}

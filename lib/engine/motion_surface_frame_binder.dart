import 'motion_surface_kernel.dart';

class UiSurfaceFrame {
  const UiSurfaceFrame(this.index, this.timestamp, this.label);

  final int index;
  final int timestamp;
  final String label;
}

class MotionSurfaceFrameBinder {
  MotionSurfaceFrameBinder(this.surface);

  final MotionSurfaceKernel surface;

  List<UiSurfaceFrame> bind() {
    return surface.frames().map((frame) {
      return UiSurfaceFrame(
        frame.index,
        frame.timestamp,
        frame.labels.join(','),
      );
    }).toList();
  }
}

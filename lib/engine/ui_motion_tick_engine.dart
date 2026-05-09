import 'motion_surface_binder.dart';

class UiMotionTick {
  const UiMotionTick(this.tick, this.atMs, this.frames);

  final int tick;
  final int atMs;
  final List<UiSurfaceFrame> frames;
}

class UiMotionTickEngine {
  UiMotionTickEngine(this.binder);

  final MotionSurfaceBinder binder;

  List<UiMotionTick> buildTicks() {
    final frames = binder.buildSurfaceFrames();
    if (frames.isEmpty) return const [];
    final maxMs = frames
        .map((frame) => frame.atMs)
        .reduce((a, b) => a > b ? a : b);
    final ticks = <UiMotionTick>[];
    var tickIndex = 0;
    for (var t = 0; t <= maxMs; t += 16) {
      final matching = frames.where((frame) => frame.atMs == t).toList();
      ticks.add(UiMotionTick(tickIndex, t, matching));
      tickIndex += 1;
    }
    return ticks;
  }
}

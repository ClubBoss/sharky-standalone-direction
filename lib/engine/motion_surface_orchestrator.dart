import 'motion_surface_frame_binder.dart';

class MotionSurfaceOrchestrator {
  MotionSurfaceOrchestrator(this.binder);

  final MotionSurfaceFrameBinder binder;

  List<Map<String, Object>> buildFlow() {
    final frames = binder.bind();
    final grouped = <int, List<UiSurfaceFrame>>{};
    for (final frame in frames) {
      grouped.putIfAbsent(frame.timestamp, () => []).add(frame);
    }
    return grouped.entries
        .map(
          (entry) => {
            'timestamp': entry.key,
            'frames': entry.value
                .map((frame) => '${frame.index}:${frame.label}')
                .toList(),
          },
        )
        .toList();
  }
}

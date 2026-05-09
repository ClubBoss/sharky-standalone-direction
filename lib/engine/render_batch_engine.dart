import 'motion_frame_renderer.dart';

class RenderFrameBatch {
  const RenderFrameBatch(this.timestamp, this.frames);

  final int timestamp;
  final List<RenderFrame> frames;
}

class RenderBatchEngine {
  RenderBatchEngine(this.renderer);

  final MotionFrameRenderer renderer;

  List<RenderFrameBatch> buildBatches() {
    final frames = renderer.buildRenderFrames();
    final grouped = <int, List<RenderFrame>>{};
    for (final frame in frames) {
      grouped.putIfAbsent(frame.timestamp, () => []).add(frame);
    }
    final batches = grouped.entries
        .map((entry) => RenderFrameBatch(entry.key, entry.value))
        .toList();
    return batches;
  }
}

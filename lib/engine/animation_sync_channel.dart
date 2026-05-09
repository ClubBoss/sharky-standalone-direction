import 'motion_frame_orchestrator.dart';

class SyncFrame {
  const SyncFrame(this.index, this.label);

  final int index;
  final String label;
}

class AnimationSyncChannel {
  AnimationSyncChannel(this.orchestrator);

  final MotionFrameOrchestrator orchestrator;

  List<SyncFrame> buildSyncFrames() {
    final batches = orchestrator.buildBatches();
    final frames = <SyncFrame>[];
    for (final batch in batches) {
      for (final label in batch.labels) {
        frames.add(
          SyncFrame(batch.batchIndex, 'sync_${batch.batchIndex}:$label'),
        );
      }
    }
    return frames;
  }
}

import 'render_batch_engine.dart';

class UiRenderStreamEntry {
  const UiRenderStreamEntry(this.timestamp, this.labels);

  final int timestamp;
  final List<String> labels;
}

class UiRenderStreamBinder {
  UiRenderStreamBinder(this.batchesEngine);

  final RenderBatchEngine batchesEngine;

  List<UiRenderStreamEntry> buildStream() {
    final batches = batchesEngine.buildBatches();
    return batches
        .map(
          (batch) => UiRenderStreamEntry(
            batch.timestamp,
            batch.frames.map((frame) => frame.label).toList(),
          ),
        )
        .toList();
  }
}

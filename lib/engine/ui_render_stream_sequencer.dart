import 'ui_render_stream_binder.dart';

class SequencedUiStreamFrame {
  const SequencedUiStreamFrame(this.index, this.timestamp, this.labels);

  final int index;
  final int timestamp;
  final List<String> labels;
}

class UiRenderStreamSequencer {
  UiRenderStreamSequencer(this.binder);

  final UiRenderStreamBinder binder;

  List<SequencedUiStreamFrame> buildSequenced() {
    final entries = binder.buildStream();
    final frames = <SequencedUiStreamFrame>[];
    for (var i = 0; i < entries.length; i++) {
      frames.add(
        SequencedUiStreamFrame(i, entries[i].timestamp, entries[i].labels),
      );
    }
    return frames;
  }
}

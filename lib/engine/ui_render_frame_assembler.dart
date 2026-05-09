import 'ui_render_stream_sequencer.dart';

class UiRenderFrame {
  const UiRenderFrame(this.index, this.timestamp, this.labels);

  final int index;
  final int timestamp;
  final List<String> labels;
}

class UiRenderFrameAssembler {
  UiRenderFrameAssembler(this.sequencer);

  final UiRenderStreamSequencer sequencer;

  List<UiRenderFrame> buildFrames() {
    final frames = sequencer.buildSequenced();
    return frames
        .map(
          (frame) => UiRenderFrame(frame.index, frame.timestamp, frame.labels),
        )
        .toList();
  }
}

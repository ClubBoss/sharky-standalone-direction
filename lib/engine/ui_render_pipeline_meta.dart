import 'ui_render_frame_assembler.dart';

class UiRenderPipelineMeta {
  const UiRenderPipelineMeta(
    this.count,
    this.firstTimestamp,
    this.lastTimestamp,
  );

  final int count;
  final int firstTimestamp;
  final int lastTimestamp;
}

class UiRenderPipelineMetaBuilder {
  UiRenderPipelineMetaBuilder(List<UiRenderFrame> frames) : _frames = frames;

  final List<UiRenderFrame> _frames;

  UiRenderPipelineMeta build() {
    if (_frames.isEmpty) {
      return const UiRenderPipelineMeta(0, 0, 0);
    }
    return UiRenderPipelineMeta(
      _frames.length,
      _frames.first.timestamp,
      _frames.last.timestamp,
    );
  }
}

import 'ui_render_frame_assembler.dart';

class UiRenderFrameMuxer {
  UiRenderFrameMuxer(List<UiRenderFrame> frames)
    : evenFrames = frames.where((frame) => frame.index % 2 == 0).toList(),
      oddFrames = frames.where((frame) => frame.index % 2 == 1).toList();

  final List<UiRenderFrame> evenFrames;
  final List<UiRenderFrame> oddFrames;
}

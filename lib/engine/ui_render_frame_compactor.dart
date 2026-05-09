import 'ui_render_frame_muxer.dart';
import 'ui_render_frame_assembler.dart';

class UiRenderFrameCompactor {
  UiRenderFrameCompactor(this.mux);

  final UiRenderFrameMuxer mux;

  List<UiRenderFrame> buildCompacted() {
    return [...mux.evenFrames, ...mux.oddFrames];
  }
}

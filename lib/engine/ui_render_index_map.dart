import 'ui_render_frame_assembler.dart';

class UiRenderIndexMapBuilder {
  UiRenderIndexMapBuilder(this.frames);

  final List<UiRenderFrame> frames;

  Map<int, UiRenderFrame> build() {
    final map = <int, UiRenderFrame>{};
    for (final frame in frames) {
      map[frame.index] = frame;
    }
    return map;
  }
}

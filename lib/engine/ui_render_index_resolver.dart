import 'ui_render_frame_assembler.dart';

class UiRenderIndexResolver {
  UiRenderIndexResolver(this.indexMap);

  final Map<int, UiRenderFrame> indexMap;

  UiRenderFrame? resolve(int index) => indexMap[index];
}

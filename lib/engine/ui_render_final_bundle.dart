import 'ui_render_frame_assembler.dart';
import 'ui_render_pipeline_meta.dart';
import 'ui_render_index_resolver.dart';

class UiRenderFinalBundle {
  const UiRenderFinalBundle(
    this.frames,
    this.meta,
    this.indexMap,
    this.resolver,
  );

  final List<UiRenderFrame> frames;
  final UiRenderPipelineMeta meta;
  final Map<int, UiRenderFrame> indexMap;
  final UiRenderIndexResolver resolver;
}

import 'ui_render_final_bundle.dart';
import 'ui_render_frame_assembler.dart';

class MotionSurfaceKernel {
  const MotionSurfaceKernel(this.bundle);

  final UiRenderFinalBundle bundle;

  List<UiRenderFrame> frames() => bundle.frames;

  UiRenderFrame? byIndex(int i) => bundle.resolver.resolve(i);

  int count() => bundle.frames.length;
}

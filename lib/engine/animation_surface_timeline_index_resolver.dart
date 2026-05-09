import 'animation_orchestrator_context.dart';
import 'animation_surface_timeline_stream.dart';

class AnimationSurfaceTimelineIndexResolver {
  const AnimationSurfaceTimelineIndexResolver(this.ctx);

  final AnimationOrchestratorContext ctx;

  AnimationSurfaceTimelineStreamEntry? resolve(int index) =>
      ctx.indexMap.map[index];
}

import 'animation_surface_timeline_index_map.dart';
import 'animation_surface_timeline_meta_builder.dart';
import 'keyframe_timeline_player.dart';
import 'motion_surface_player.dart';

class AnimationOrchestratorContext {
  final AnimationSurfaceTimelineMeta meta;
  final AnimationSurfaceTimelineIndexMap indexMap;
  final MotionSurfacePlayer player;
  final KeyframeTimelinePlayer? timelinePlayer;

  const AnimationOrchestratorContext(
    this.meta,
    this.indexMap,
    this.player, {
    this.timelinePlayer,
  });

  void advanceFrame({required double dt}) {
    assert(dt >= 0);
    player.advance(dt);
    timelinePlayer?.advance(dt);
  }

  double get timelineValue => timelinePlayer?.value() ?? 0.0;
}

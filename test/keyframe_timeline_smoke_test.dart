import 'package:test/test.dart';
import 'package:poker_analyzer/engine/animation_orchestrator_context.dart';
import 'package:poker_analyzer/engine/animation_surface_timeline_index_map.dart';
import 'package:poker_analyzer/engine/animation_surface_timeline_meta_builder.dart';
import 'package:poker_analyzer/engine/keyframe_model.dart';
import 'package:poker_analyzer/engine/keyframe_timeline_player.dart';
import 'package:poker_analyzer/engine/keyframe_timeline_resolver.dart';
import 'package:poker_analyzer/engine/motion_surface_frame_binder.dart';
import 'package:poker_analyzer/engine/motion_surface_kernel.dart';
import 'package:poker_analyzer/engine/motion_surface_orchestrator.dart';
import 'package:poker_analyzer/engine/motion_surface_player.dart';
import 'package:poker_analyzer/engine/ui_render_final_bundle.dart';
import 'package:poker_analyzer/engine/ui_render_frame_assembler.dart';
import 'package:poker_analyzer/engine/ui_render_index_resolver.dart';
import 'package:poker_analyzer/engine/ui_render_pipeline_meta.dart';
import 'package:poker_analyzer/engine/animation_surface_timeline_stream.dart';

void main() {
  group('Keyframe timeline smoke', () {
    final track = KeyframeTrack(const [
      Keyframe(time: 0.0, value: 0.0),
      Keyframe(time: 1.0, value: 10.0),
    ]);
    final resolver = KeyframeTimelineResolver();

    test('resolver samples edges and midpoints', () {
      expect(resolver.sample(track, 0.0), equals(0.0));
      expect(resolver.sample(track, 0.5), closeTo(5.0, 1e-9));
      expect(resolver.sample(track, 2.0), equals(10.0));
    });

    test('player accumulates time and exposes interpolated value', () {
      final player = KeyframeTimelinePlayer(track: track, resolver: resolver);
      player.advance(0.25);
      expect(player.value(), closeTo(2.5, 1e-9));
      player.advance(0.75);
      expect(player.value(), closeTo(10.0, 1e-9));
      player.reset();
      expect(player.value(), equals(0.0));
    });

    test('context exposes timelineValue via timeline player', () {
      final frames = [
        const UiRenderFrame(0, 0, ['a']),
      ];
      final meta = UiRenderPipelineMeta(
        frames.length,
        frames.first.timestamp,
        frames.last.timestamp,
      );
      final indexMap = <int, UiRenderFrame>{
        for (var frame in frames) frame.index: frame,
      };
      final bundle = UiRenderFinalBundle(
        frames,
        meta,
        indexMap,
        UiRenderIndexResolver(indexMap),
      );
      final motionSurfaceKernel = MotionSurfaceKernel(bundle);
      final binder = MotionSurfaceFrameBinder(motionSurfaceKernel);
      final orchestrator = MotionSurfaceOrchestrator(binder);
      final player = MotionSurfacePlayer(orchestrator);
      final timelinePlayer = KeyframeTimelinePlayer(
        track: track,
        resolver: resolver,
      );
      final context = AnimationOrchestratorContext(
        const AnimationSurfaceTimelineMeta(1, 0, 0),
        AnimationSurfaceTimelineIndexMap(
          <int, AnimationSurfaceTimelineStreamEntry>{},
        ),
        player,
        timelinePlayer: timelinePlayer,
      );

      expect(context.timelineValue, equals(0.0));
      context.advanceFrame(dt: 0.5);
      expect(context.timelineValue, closeTo(5.0, 1e-9));
    });
  });
}

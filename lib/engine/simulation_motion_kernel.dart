import 'package:meta/meta.dart';

import 'simulation_chip_travel_blueprint.dart';
import 'simulation_dealing_blueprint.dart';
import 'simulation_gesture_flow_blueprint.dart';
import 'simulation_motion_blueprint.dart';
import 'simulation_motion_resolver.dart';
import 'simulation_motion_events.dart';
import 'simulation_motion_event_merger.dart';
import 'simulation_motion_timing_kernel.dart';
import 'simulation_motion_timing_sequencer.dart';
import 'simulation_motion_state_stream.dart';
import 'motion_ui_binder.dart';
import 'motion_timeline_mapper.dart';
import 'motion_frame_stream_engine.dart';
import 'motion_surface_binder.dart';
import 'ui_motion_tick_engine.dart';
import 'ui_motion_timeline_binder.dart';
import 'motion_frame_orchestrator.dart';
import 'animation_sync_channel.dart';
import 'motion_frame_animator.dart';
import 'motion_frame_scheduler.dart';
import 'motion_frame_renderer.dart';
import 'render_batch_engine.dart';
import 'ui_render_stream_binder.dart';
import 'ui_render_stream_sequencer.dart';
import 'ui_render_frame_assembler.dart';
import 'ui_render_frame_muxer.dart';
import 'ui_render_frame_compactor.dart';
import 'ui_render_pipeline_meta.dart';
import 'ui_render_index_map.dart';
import 'ui_render_index_resolver.dart';
import 'ui_render_final_bundle.dart';
import 'motion_surface_kernel.dart';
import 'motion_surface_frame_binder.dart';
import 'animation_surface_kernel_binder.dart';
import 'animation_surface_timeline_builder.dart';
import 'animation_orchestrator_context.dart';
import 'animation_surface_timeline_stream.dart';
import 'animation_surface_timeline_mux.dart';
import 'animation_surface_timeline_compactor.dart';
import 'animation_surface_timeline_meta_builder.dart';
import 'animation_surface_timeline_index_map.dart';
import 'animation_surface_timeline_index_resolver.dart';
import 'animation_surface_timeline_range_builder.dart';
import 'motion_surface_orchestrator.dart';
import 'motion_channel_playback_resolver.dart';
import 'motion_frame_composer.dart';
import 'motion_kernel_binding.dart';
import 'motion_playback_adapter.dart';
import 'motion_surface_player.dart';
import 'card_motion_spec.dart';
import 'simulation_motion_mesh_vector_v1.dart';
import 'simulation_motion_mesh_fusion_v1.dart';
import 'simulation_motion_mesh_consistency_v1.dart';
import 'simulation_motion_mesh_descriptor_v1.dart';

class SimulationMotionKernel {
  late final SimulationDealingBlueprint dealing;
  late final SimulationChipTravelBlueprint chipTravel;
  late final SimulationGestureFlowBlueprint gesture;
  late final SimulationMotionBlueprint motion;
  late final SimulationMotionResolver resolver;
  late final SimulationMotionEvents events;
  late final SimulationMotionEventMerger unified;
  late final SimulationMotionTimingKernel timing;
  late final SimulationMotionTimingSequencer sequencer;
  late final MotionStateStream stateStream;
  late final MotionUiBinder uiBinder;
  late final MotionTimelineMapper timelineMapper;
  late final MotionFrameStreamEngine frameStream;
  late final MotionSurfaceBinder surfaceBinder;
  late final UiMotionTickEngine tickEngine;
  late final UiMotionTimelineBinder timelineBinder;
  late final MotionFrameOrchestrator orchestrator;
  late final AnimationSyncChannel syncChannel;
  late final MotionFrameAnimator animator;
  late final MotionFrameScheduler scheduler;
  late final MotionFrameRenderer renderer;
  late final RenderBatchEngine renderBatches;
  late final UiRenderStreamBinder uiRenderStream;
  late final UiRenderStreamSequencer uiRenderSequencer;
  late final UiRenderFrameAssembler uiRenderFrames;
  late final UiRenderFrameMuxer uiRenderMux;
  late final UiRenderFrameCompactor uiRenderCompacted;
  late final UiRenderPipelineMetaBuilder uiRenderMeta;
  late final UiRenderIndexMapBuilder uiRenderIndexMap;
  late final UiRenderIndexResolver uiRenderIndexResolver;
  late final UiRenderFinalBundle uiRenderFinalBundle;
  late final MotionSurfaceKernel motionSurface;
  late final MotionSurfaceFrameBinder motionSurfaceFrames;
  late final AnimationSurfaceKernelBinder animationSurfaceKernelBinder;
  late final AnimationSurfaceTimelineBuilder animationSurfaceTimeline;
  late final AnimationSurfaceTimelineRange animationSurfaceTimelineRange;
  late final AnimationSurfaceTimelineStream animationSurfaceTimelineStream;
  late final AnimationSurfaceTimelineMux animationSurfaceTimelineMux;
  late final AnimationSurfaceTimelineCompactor
  animationSurfaceTimelineCompacted;
  late final AnimationSurfaceTimelineMetaBuilder animationSurfaceTimelineMeta;
  late final AnimationSurfaceTimelineIndexMapBuilder
  animationSurfaceTimelineIndexMap;
  late final MotionSurfaceOrchestrator motionSurfaceOrchestrator;
  late final MotionSurfacePlayer motionSurfacePlayer;
  late final AnimationOrchestratorContext animationOrchestratorContext;
  late final AnimationSurfaceTimelineIndexResolver
  animationSurfaceTimelineIndexResolver;
  static SimulationMotionKernel? _current;
  static SimulationMotionKernel? get current => _current;

  Map<String, Object?>? _v4SurfaceMetadata;
  double? _v4RadiusWeight;
  double? _v4ElevationWeight;
  double? _v4SpacingWeight;
  MotionMeshDescriptorV1? _motionMeshDescriptorV1;
  MotionMeshVectorV1? _motionMeshVectorV1;
  MotionMeshFusionV1? _motionMeshFusionV1;
  MotionMeshConsistencyV1? _motionMeshConsistencyV1;
  Map<String, Object?>? _emotionFusionV4;

  void acceptV4SurfaceMetadata(Map<String, Object?>? metadata) {
    _v4SurfaceMetadata = metadata;
  }

  void acceptV4CohesionWeights(
    double? radiusWeight,
    double? elevationWeight,
    double? spacingWeight,
  ) {
    _v4RadiusWeight = radiusWeight;
    _v4ElevationWeight = elevationWeight;
    _v4SpacingWeight = spacingWeight;
  }

  void acceptMotionMeshDescriptor(MotionMeshDescriptorV1? descriptor) {
    _motionMeshDescriptorV1 = descriptor;
  }

  void acceptMotionMeshVector(MotionMeshVectorV1? vector) {
    _motionMeshVectorV1 = vector;
  }

  void acceptMotionMeshFusion(MotionMeshFusionV1? fusion) {
    _motionMeshFusionV1 = fusion;
  }

  void acceptMotionMeshConsistency(MotionMeshConsistencyV1? consistency) {
    _motionMeshConsistencyV1 = consistency;
  }

  void acceptEmotionFusionV4(Map<String, Object?>? fusion) {
    _emotionFusionV4 = fusion;
  }

  Map<String, double>? get v4SurfaceSyncTripleOrNull {
    final metadata = _v4SurfaceMetadata;
    if (metadata == null) return null;
    final map = <String, double>{};
    metadata.forEach((key, value) {
      if (value is double) {
        map[key] = value;
      } else if (value is num) {
        map[key] = value.toDouble();
      }
    });
    return map.isEmpty ? null : map;
  }

  (double? radius, double? elevation, double? spacing)?
  get v4SurfaceTripleOrNull {
    final metadata = _v4SurfaceMetadata;
    if (metadata == null) return null;
    final radius = (metadata['radius'] is num)
        ? (metadata['radius'] as num).toDouble()
        : null;
    final elevation = (metadata['elevation'] is num)
        ? (metadata['elevation'] as num).toDouble()
        : null;
    final spacing = (metadata['spacing'] is num)
        ? (metadata['spacing'] as num).toDouble()
        : null;
    if (radius == null && elevation == null && spacing == null) return null;
    return (radius, elevation, spacing);
  }

  Map<String, Object?>? get v4SurfaceMetadata => _v4SurfaceMetadata;

  MotionMeshDescriptorV1? get motionMeshDescriptorOrNull =>
      _motionMeshDescriptorV1;

  MotionMeshVectorV1? get motionMeshVectorOrNull => _motionMeshVectorV1;
  MotionMeshFusionV1? get motionMeshFusionOrNull => _motionMeshFusionV1;
  MotionMeshConsistencyV1? get motionMeshConsistencyOrNull =>
      _motionMeshConsistencyV1;

  Map<String, Object?>? get emotionFusionV4OrNull => _emotionFusionV4;

  Map<String, double>? get v4CohesionWeightsOrNull {
    if (_v4RadiusWeight == null &&
        _v4ElevationWeight == null &&
        _v4SpacingWeight == null) {
      return null;
    }
    final map = <String, double>{};
    if (_v4RadiusWeight != null) map['radiusWeight'] = _v4RadiusWeight!;
    if (_v4ElevationWeight != null)
      map['elevationWeight'] = _v4ElevationWeight!;
    if (_v4SpacingWeight != null) map['spacingWeight'] = _v4SpacingWeight!;
    return map;
  }

  Map<String, Object?>? _emotionV4;

  void acceptEmotionV4(Map<String, Object?>? emotion) {
    _emotionV4 = emotion;
  }

  Map<String, Object?>? get emotionV4OrNull => _emotionV4;

  MotionKernelBinding? motionBinding;
  MotionPlaybackAdapter? motionPlayback;
  MotionChannelPlaybackResolver? channelResolver;
  MotionFrameComposer? frameComposer;
  MotionFrameComposer? get motionFrameComposer => frameComposer;

  SimulationMotionKernel() {
    _current = this;
    dealing = SimulationDealingBlueprint();
    chipTravel = SimulationChipTravelBlueprint();
    gesture = SimulationGestureFlowBlueprint();
    motion = SimulationMotionBlueprint(dealing, chipTravel, gesture);
    resolver = SimulationMotionResolver(motion);
    events = SimulationMotionEvents(resolver);
    unified = SimulationMotionEventMerger(events);
    timing = SimulationMotionTimingKernel(unified);
    sequencer = SimulationMotionTimingSequencer(timing);
    stateStream = MotionStateStream(sequencer);
    uiBinder = MotionUiBinder(stateStream);
    timelineMapper = MotionTimelineMapper(uiBinder);
    frameStream = MotionFrameStreamEngine(timelineMapper);
    surfaceBinder = MotionSurfaceBinder(frameStream);
    tickEngine = UiMotionTickEngine(surfaceBinder);
    timelineBinder = UiMotionTimelineBinder(tickEngine);
    orchestrator = MotionFrameOrchestrator(timelineBinder);
    syncChannel = AnimationSyncChannel(orchestrator);
    animator = MotionFrameAnimator(syncChannel);
    scheduler = MotionFrameScheduler(animator);
    renderer = MotionFrameRenderer(scheduler);
    renderBatches = RenderBatchEngine(renderer);
    uiRenderStream = UiRenderStreamBinder(renderBatches);
    uiRenderSequencer = UiRenderStreamSequencer(uiRenderStream);
    uiRenderFrames = UiRenderFrameAssembler(uiRenderSequencer);
    uiRenderMux = UiRenderFrameMuxer(uiRenderFrames.buildFrames());
    uiRenderCompacted = UiRenderFrameCompactor(uiRenderMux);
    uiRenderMeta = UiRenderPipelineMetaBuilder(
      uiRenderCompacted.buildCompacted(),
    );
    uiRenderIndexMap = UiRenderIndexMapBuilder(
      uiRenderCompacted.buildCompacted(),
    );
    uiRenderIndexResolver = UiRenderIndexResolver(uiRenderIndexMap.build());
    uiRenderFinalBundle = UiRenderFinalBundle(
      uiRenderCompacted.buildCompacted(),
      uiRenderMeta.build(),
      uiRenderIndexMap.build(),
      uiRenderIndexResolver,
    );
    motionSurface = MotionSurfaceKernel(uiRenderFinalBundle);
    motionSurfaceFrames = MotionSurfaceFrameBinder(motionSurface);
    motionSurfaceOrchestrator = MotionSurfaceOrchestrator(motionSurfaceFrames);
    motionSurfacePlayer = MotionSurfacePlayer(motionSurfaceOrchestrator);
    animationSurfaceKernelBinder = AnimationSurfaceKernelBinder(
      motionSurfacePlayer,
    );
    animationSurfaceTimeline = AnimationSurfaceTimelineBuilder(
      animationSurfaceKernelBinder.build(),
    );
    animationSurfaceTimelineRange = AnimationSurfaceTimelineRangeBuilder(
      animationSurfaceTimeline.build(),
    ).build();
    animationSurfaceTimelineStream = AnimationSurfaceTimelineStream(
      animationSurfaceTimeline.build(),
    );
    animationSurfaceTimelineMux = AnimationSurfaceTimelineMux(
      animationSurfaceTimelineStream.build(),
    );
    animationSurfaceTimelineCompacted = AnimationSurfaceTimelineCompactor(
      animationSurfaceTimelineMux.build(),
    );
    animationSurfaceTimelineMeta = AnimationSurfaceTimelineMetaBuilder(
      animationSurfaceTimelineCompacted.build(),
    );
    animationSurfaceTimelineIndexMap = AnimationSurfaceTimelineIndexMapBuilder(
      animationSurfaceTimelineCompacted.build(),
    );
    animationOrchestratorContext = AnimationOrchestratorContext(
      animationSurfaceTimelineMeta.build(),
      animationSurfaceTimelineIndexMap.build(),
      motionSurfacePlayer,
    );
    animationSurfaceTimelineIndexResolver =
        AnimationSurfaceTimelineIndexResolver(animationOrchestratorContext);
  }

  void advanceAnimationFrame(double dt) =>
      animationOrchestratorContext.advanceFrame(dt: dt);

  void loadMotionBinding(MotionKernelBinding binding) {
    motionBinding = binding;
  }

  void bindMotionPlayback(MotionPlaybackAdapter adapter) {
    motionPlayback = adapter;
  }

  void bindMotionChannelResolver(MotionChannelPlaybackResolver resolver) {
    channelResolver = resolver;
  }

  void bindMotionFrameComposer(MotionFrameComposer composer) {
    frameComposer = composer;
  }

  void bindMotionScript(List<CardMotionSequence> script) {
    final binding = MotionKernelBinding.fromSequences(script);
    motionBinding = binding;
    final adapter = MotionPlaybackAdapter(binding.input);
    bindMotionPlayback(adapter);
    final resolver = MotionChannelPlaybackResolver(adapter, binding.input);
    bindMotionChannelResolver(resolver);
    final composer = MotionFrameComposer(
      resolver,
      animationOrchestratorContext,
    );
    bindMotionFrameComposer(composer);
  }

  double _lastDt = -1.0;
  double _smoothedDt = 0.0;

  double _smoothDt(double rawDt) {
    var clamped = rawDt.clamp(0.0, 0.05);
    if (clamped < 0.001) {
      clamped = 0.0;
    }
    final smoothed = _lastDt < 0
        ? clamped
        : 0.85 * _smoothedDt + 0.15 * clamped;
    _lastDt = rawDt;
    _smoothedDt = smoothed;
    return smoothed;
  }

  @visibleForTesting
  double smoothDtForTesting(double rawDt) => _smoothDt(rawDt);

  void tick(double dt) => advanceAnimationFrame(_smoothDt(dt));

  List<String> prepareDealingPath() => const [
    'dealer → center',
    'center → seat1',
    'center → seat2',
  ];

  List<String> prepareChipTravelPath() => const [
    'pot → seat1',
    'pot → seat3',
    'pot → seat2',
  ];

  List<String> prepareGestureFlow() => const [
    'tap → select',
    'swipe → move',
    'hold → release',
  ];
}

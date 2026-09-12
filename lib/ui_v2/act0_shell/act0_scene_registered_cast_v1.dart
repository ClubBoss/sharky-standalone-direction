import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_character_asset_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';

/// One authored V3 opponent registration in the 941x1672 V4 source canvas.
///
/// This contract owns visual composition only. Seat anchors, cards, chips,
/// labels, action state, and every other poker semantic remain outside it.
@immutable
class Act0SceneRegisteredSeatV1 {
  const Act0SceneRegisteredSeatV1({
    required this.identity,
    required this.sourceRect,
    required this.plane,
    required this.seatActiveAsset,
    required this.playerEffectMaskAsset,
  });

  final Act0SceneCharacterIdentityV1 identity;
  final Rect sourceRect;
  final Act0SceneTieredPlaneV1 plane;
  final String seatActiveAsset;
  final String playerEffectMaskAsset;

  String get seatActivePath =>
      '${Act0SceneRegisteredCastRegistryV1.assetRoot}/$seatActiveAsset';

  String get playerEffectMaskPath =>
      '${Act0SceneRegisteredCastRegistryV1.assetRoot}/'
      '$playerEffectMaskAsset';
}

/// Canonical, deterministic V3 cast registration copied from
/// `assets/act0_characters/registration_v3.json`.
class Act0SceneRegisteredCastRegistryV1 {
  const Act0SceneRegisteredCastRegistryV1._();

  static const String assetRoot = 'assets/act0_characters';
  static const String registrationSourcePath =
      '$assetRoot/registration_v3.json';
  static const Size sourceCanvasSize = Size(941, 1672);

  static const List<Act0SceneCharacterIdentityV1> compositionOrder =
      <Act0SceneCharacterIdentityV1>[
        Act0SceneCharacterIdentityV1.utg,
        Act0SceneCharacterIdentityV1.bb,
        Act0SceneCharacterIdentityV1.hj,
        Act0SceneCharacterIdentityV1.sb,
        Act0SceneCharacterIdentityV1.co,
      ];

  static const Map<Act0SceneCharacterIdentityV1, Act0SceneRegisteredSeatV1>
  registrations = <Act0SceneCharacterIdentityV1, Act0SceneRegisteredSeatV1>{
    Act0SceneCharacterIdentityV1.utg: Act0SceneRegisteredSeatV1(
      identity: Act0SceneCharacterIdentityV1.utg,
      sourceRect: Rect.fromLTWH(298, 281, 250, 182),
      plane: Act0SceneTieredPlaneV1.back,
      seatActiveAsset: 'UTG_SEAT_ACTIVE.png',
      playerEffectMaskAsset: 'UTG_PLAYER_EFFECT_MASK.png',
    ),
    Act0SceneCharacterIdentityV1.bb: Act0SceneRegisteredSeatV1(
      identity: Act0SceneCharacterIdentityV1.bb,
      sourceRect: Rect.fromLTWH(19, 334, 238, 281),
      plane: Act0SceneTieredPlaneV1.back,
      seatActiveAsset: 'BB_SEAT_ACTIVE.png',
      playerEffectMaskAsset: 'BB_PLAYER_EFFECT_MASK.png',
    ),
    Act0SceneCharacterIdentityV1.hj: Act0SceneRegisteredSeatV1(
      identity: Act0SceneCharacterIdentityV1.hj,
      sourceRect: Rect.fromLTWH(609, 333, 246, 318),
      plane: Act0SceneTieredPlaneV1.back,
      seatActiveAsset: 'HJ_SEAT_ACTIVE.png',
      playerEffectMaskAsset: 'HJ_PLAYER_EFFECT_MASK.png',
    ),
    Act0SceneCharacterIdentityV1.sb: Act0SceneRegisteredSeatV1(
      identity: Act0SceneCharacterIdentityV1.sb,
      sourceRect: Rect.fromLTWH(0, 476, 200, 430),
      plane: Act0SceneTieredPlaneV1.front,
      seatActiveAsset: 'SB_SEAT_ACTIVE.png',
      playerEffectMaskAsset: 'SB_PLAYER_EFFECT_MASK.png',
    ),
    Act0SceneCharacterIdentityV1.co: Act0SceneRegisteredSeatV1(
      identity: Act0SceneCharacterIdentityV1.co,
      sourceRect: Rect.fromLTWH(686, 448, 255, 475),
      plane: Act0SceneTieredPlaneV1.front,
      seatActiveAsset: 'CO_SEAT_ACTIVE.png',
      playerEffectMaskAsset: 'CO_PLAYER_EFFECT_MASK.png',
    ),
  };

  static Act0SceneRegisteredSeatV1 registrationFor(
    Act0SceneCharacterIdentityV1 identity,
  ) => registrations[identity]!;
}

/// Maps authored V4 source-canvas coordinates into the frozen camera stage.
///
/// The mapping is derived once from the existing camera and hybrid-shell
/// footprint. It never consults seat envelopes or [Act0SceneCharacterArtFitV1],
/// so all five seats retain their authored relative scale and offset at every
/// viewport width.
@immutable
class Act0SceneRegisteredCastMapperV1 {
  const Act0SceneRegisteredCastMapperV1({
    this.camera = Act0SceneCameraV1.canonical,
    this.perspective = Act0ScenePerspectiveV1.canonical,
    this.shellFootprint = Act0SceneHybridShellFootprintV1.production,
  });

  final Act0SceneCameraV1 camera;
  final Act0ScenePerspectiveV1 perspective;
  final Act0SceneHybridShellFootprintV1 shellFootprint;

  Size sceneSizeForStage(Size stageSize) => Size(
    stageSize.width *
        perspective.nearWidthFactor /
        camera.outerTableWidthFraction,
    stageSize.height / camera.projectedTableHeightFraction,
  );

  Rect shellRectInStageFor(Size stageSize) {
    final sceneSize = sceneSizeForStage(stageSize);
    final stageOrigin = Offset(
      (sceneSize.width - stageSize.width) / 2,
      sceneSize.height * camera.farRailFraction,
    );
    return shellFootprint
        .destinationRectFor(
          sceneSize,
          Act0SceneRegisteredCastRegistryV1.sourceCanvasSize.aspectRatio,
        )
        .shift(-stageOrigin);
  }

  Rect destinationRectFor(Size stageSize, Rect sourceRect) {
    final shellRect = shellRectInStageFor(stageSize);
    final sourceCanvas = Act0SceneRegisteredCastRegistryV1.sourceCanvasSize;
    return Rect.fromLTWH(
      shellRect.left + (sourceRect.left / sourceCanvas.width) * shellRect.width,
      shellRect.top + (sourceRect.top / sourceCanvas.height) * shellRect.height,
      (sourceRect.width / sourceCanvas.width) * shellRect.width,
      (sourceRect.height / sourceCanvas.height) * shellRect.height,
    );
  }
}

/// Readiness of the production registered cast.
enum Act0SceneRegisteredCastPhaseV1 {
  /// Required assets are still loading; no opponent identity is presented.
  pending,

  /// The hybrid shell and every registered seat PNG and mask are decoded.
  ready,

  /// At least one required asset is missing or failed to decode.
  unavailable,
}

/// The one readiness contract for the V4 registered cast.
///
/// The hybrid shell plus all five seat composites and five human masks load
/// together. Nothing registered becomes visible until the whole set is decoded,
/// so ordinary decode never presents generic opponents that are later swapped
/// for their V3 identities. A missing or corrupt asset resolves to
/// [Act0SceneRegisteredCastPhaseV1.unavailable], the bounded fallback.
class Act0SceneRegisteredCastReadinessV1 extends ChangeNotifier {
  Act0SceneRegisteredCastReadinessV1({
    required this.store,
    required this.shellStore,
  });

  static final Act0SceneRegisteredCastReadinessV1 shared =
      Act0SceneRegisteredCastReadinessV1(
        store: Act0SceneCharacterImageStoreV1.shared,
        shellStore: Act0SceneHybridShellRegistryV1.shellStore,
      );

  final Act0SceneCharacterImageStoreV1 store;
  final Act0SceneSinglePlateImageStoreV1 shellStore;

  Future<Act0SceneRegisteredCastPhaseV1>? _pending;
  bool _unavailable = false;

  static Iterable<String> get requiredCastPaths sync* {
    for (final registration
        in Act0SceneRegisteredCastRegistryV1.registrations.values) {
      yield registration.seatActivePath;
      yield registration.playerEffectMaskPath;
    }
  }

  Act0SceneRegisteredCastPhaseV1 get phase {
    if (shellStore.isReady && requiredCastPaths.every(store.isReady)) {
      return Act0SceneRegisteredCastPhaseV1.ready;
    }
    return _unavailable
        ? Act0SceneRegisteredCastPhaseV1.unavailable
        : Act0SceneRegisteredCastPhaseV1.pending;
  }

  /// Starts (or joins) the single load of every required asset. Idempotent.
  Future<Act0SceneRegisteredCastPhaseV1> warmUp({AssetBundle? bundle}) {
    final current = phase;
    if (current != Act0SceneRegisteredCastPhaseV1.pending) {
      return SynchronousFuture<Act0SceneRegisteredCastPhaseV1>(current);
    }
    return _pending ??= _load(bundle);
  }

  Future<Act0SceneRegisteredCastPhaseV1> _load(AssetBundle? bundle) async {
    final images = await Future.wait<ui.Image?>(<Future<ui.Image?>>[
      shellStore.warmUp(bundle: bundle),
      for (final path in requiredCastPaths) store.load(path, bundle: bundle),
    ]);
    _pending = null;
    _unavailable = images.any((image) => image == null);
    // Always notify: the gate re-reads [phase], which is derived from the
    // stores, so an unchanged phase is a harmless rebuild.
    notifyListeners();
    return phase;
  }

  @visibleForTesting
  void reset() {
    _pending = null;
    _unavailable = false;
    notifyListeners();
  }
}

/// Starts the shared registered-cast load and rebuilds on its resolution.
class Act0SceneRegisteredCastGateV1 extends StatefulWidget {
  const Act0SceneRegisteredCastGateV1({
    super.key,
    required this.builder,
    this.readiness,
  });

  final Widget Function(
    BuildContext context,
    Act0SceneRegisteredCastPhaseV1 phase,
  )
  builder;
  final Act0SceneRegisteredCastReadinessV1? readiness;

  @override
  State<Act0SceneRegisteredCastGateV1> createState() =>
      _Act0SceneRegisteredCastGateV1State();
}

class _Act0SceneRegisteredCastGateV1State
    extends State<Act0SceneRegisteredCastGateV1> {
  Act0SceneRegisteredCastReadinessV1 get _readiness =>
      widget.readiness ?? Act0SceneRegisteredCastReadinessV1.shared;

  @override
  void initState() {
    super.initState();
    unawaited(_readiness.warmUp());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _readiness,
      builder: (context, _) => widget.builder(context, _readiness.phase),
    );
  }
}

/// Registered V3 opponents for one existing scene depth plane.
///
/// The live semantic table remains between the back and front instances of
/// this layer. The layer is atomic: every seat paints its registered composite
/// only when all registered seat PNGs and masks are decoded; otherwise every
/// seat shows the generic fallback figure, so V3 and generic identities never
/// mix. The front plane also yields to live opponent card rows (see
/// [Act0SceneSemanticClearanceClipV1]).
class Act0SceneRegisteredCastLayerV1 extends StatelessWidget {
  const Act0SceneRegisteredCastLayerV1({
    super.key,
    required this.slots,
    required this.plane,
    this.foldedSeatIds = const <String>{},
    this.store,
    this.mapper = const Act0SceneRegisteredCastMapperV1(),
  });

  final List<Act0SceneSeatSlotV1> slots;
  final Act0SceneTieredPlaneV1 plane;
  final Set<String> foldedSeatIds;
  final Act0SceneCharacterImageStoreV1? store;
  final Act0SceneRegisteredCastMapperV1 mapper;

  @override
  Widget build(BuildContext context) {
    final store = this.store ?? Act0SceneCharacterImageStoreV1.shared;
    final castReady = Act0SceneRegisteredCastReadinessV1.requiredCastPaths
        .every(store.isReady);
    final layer = LayoutBuilder(
      builder: (context, constraints) {
        final stageSize = constraints.biggest;
        if (stageSize.isEmpty || !stageSize.isFinite) {
          return const SizedBox.shrink();
        }
        final slotsByIdentity =
            <Act0SceneCharacterIdentityV1, Act0SceneSeatSlotV1>{};
        for (final slot in slots.where((candidate) => !candidate.isHero)) {
          final identity = Act0SceneCharacterIdentityResolverV1.resolve(slot);
          if (identity != null) slotsByIdentity[identity] = slot;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final identity
                in Act0SceneRegisteredCastRegistryV1.compositionOrder)
              if (Act0SceneRegisteredCastRegistryV1.registrationFor(
                        identity,
                      ).plane ==
                      plane &&
                  slotsByIdentity[identity] != null)
                _registeredSeat(
                  identity: identity,
                  slot: slotsByIdentity[identity]!,
                  stageSize: stageSize,
                  store: store,
                  castReady: castReady,
                ),
          ],
        );
      },
    );
    return plane == Act0SceneTieredPlaneV1.front
        ? Act0SceneSemanticClearanceClipV1(child: layer)
        : layer;
  }

  Widget _registeredSeat({
    required Act0SceneCharacterIdentityV1 identity,
    required Act0SceneSeatSlotV1 slot,
    required Size stageSize,
    required Act0SceneCharacterImageStoreV1 store,
    required bool castReady,
  }) {
    final registration = Act0SceneRegisteredCastRegistryV1.registrationFor(
      identity,
    );
    final destination = mapper.destinationRectFor(
      stageSize,
      registration.sourceRect,
    );
    final folded = foldedSeatIds.contains(slot.seatId);
    return Positioned.fromRect(
      rect: destination,
      child: SizedBox(
        key: Key('act0_scene_player_figure_${slot.seatId}'),
        child: Act0SceneRegisteredSeatCompositeV1(
          key: Key('act0_scene_registered_seat_${identity.name}'),
          registration: registration,
          folded: folded,
          size: destination.size,
          seatImage: castReady
              ? store.readyImageFor(registration.seatActivePath)
              : null,
          playerEffectMask: castReady
              ? store.readyImageFor(registration.playerEffectMaskPath)
              : null,
          fallback: Act0ScenePlayerFigureV1(
            slot: slot,
            size: destination.size,
            posture: folded
                ? Act0ScenePlayerPostureV1.folded
                : Act0ScenePlayerPostureV1.inHand,
          ),
        ),
      ),
    );
  }
}

/// Paints one registered seat composite plus its human-only mask, or the
/// supplied fallback when the atomic cast set is not ready.
class Act0SceneRegisteredSeatCompositeV1 extends StatelessWidget {
  const Act0SceneRegisteredSeatCompositeV1({
    super.key,
    required this.registration,
    required this.folded,
    required this.size,
    required this.fallback,
    this.seatImage,
    this.playerEffectMask,
  });

  final Act0SceneRegisteredSeatV1 registration;
  final bool folded;
  final Size size;
  final Widget fallback;
  final ui.Image? seatImage;
  final ui.Image? playerEffectMask;

  @override
  Widget build(BuildContext context) {
    final seatImage = this.seatImage;
    if (seatImage == null || playerEffectMask == null) {
      return KeyedSubtree(
        key: Key(
          'act0_scene_registered_${registration.identity.name}_fallback',
        ),
        child: fallback,
      );
    }
    return CustomPaint(
      key: Key('act0_scene_registered_${registration.identity.name}_ready'),
      size: size,
      painter: Act0SceneRegisteredSeatPainterV1(
        seatImage: seatImage,
        playerEffectMask: playerEffectMask,
        folded: folded,
      ),
    );
  }
}

/// Live semantic objects that registered front-plane art must never cover.
///
/// Front-plane composites carry baked rail and chair pixels at full alpha. The
/// CO composite's rail fragment otherwise paints over the HJ hole cards, which
/// sit on that rail in the live table. Sources register their paint bounds;
/// [Act0SceneSemanticClearanceClipV1] clips its child around them. No seat,
/// card, camera, or table geometry is read for placement or changed.
class Act0SceneSemanticClearanceScopeV1 extends StatefulWidget {
  const Act0SceneSemanticClearanceScopeV1({super.key, required this.child});

  final Widget child;

  static Act0SceneSemanticClearanceRegistryV1? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_Act0SceneSemanticClearanceV1>()
          ?.registry;

  @override
  State<Act0SceneSemanticClearanceScopeV1> createState() =>
      _Act0SceneSemanticClearanceScopeV1State();
}

class _Act0SceneSemanticClearanceScopeV1State
    extends State<Act0SceneSemanticClearanceScopeV1> {
  final Act0SceneSemanticClearanceRegistryV1 _registry =
      Act0SceneSemanticClearanceRegistryV1();

  @override
  Widget build(BuildContext context) =>
      _Act0SceneSemanticClearanceV1(registry: _registry, child: widget.child);
}

class _Act0SceneSemanticClearanceV1 extends InheritedWidget {
  const _Act0SceneSemanticClearanceV1({
    required this.registry,
    required super.child,
  });

  final Act0SceneSemanticClearanceRegistryV1 registry;

  @override
  bool updateShouldNotify(_Act0SceneSemanticClearanceV1 oldWidget) =>
      !identical(oldWidget.registry, registry);
}

/// Tracks clearance sources and the clips that must repaint when they move.
class Act0SceneSemanticClearanceRegistryV1 {
  /// Sources are registered inside their own rotation, so the hole is the
  /// exact card quad; this only covers the card edge's antialiasing.
  static const double sourceInflation = 0.5;

  final Set<RenderBox> _sources = <RenderBox>{};
  final Set<RenderObject> _clips = <RenderObject>{};

  void _invalidate() {
    for (final clip in _clips) {
      if (clip.attached) clip.markNeedsPaint();
    }
  }

  /// Clearance outlines in [target]'s local coordinates, or null if none.
  Path? clearancePathIn(RenderBox target) {
    Path? path;
    for (final source in _sources) {
      if (!source.attached || !source.hasSize || source.size.isEmpty) {
        continue;
      }
      final transform = source.getTransformTo(target);
      (path ??= Path()).addPath(
        Path()..addRect((Offset.zero & source.size).inflate(sourceInflation)),
        Offset.zero,
        matrix4: transform.storage,
      );
    }
    return path;
  }
}

/// Marks its child's paint bounds as live semantic content in the nearest
/// [Act0SceneSemanticClearanceScopeV1]. Layout and paint are unchanged.
class Act0SceneSemanticClearanceSourceV1 extends SingleChildRenderObjectWidget {
  const Act0SceneSemanticClearanceSourceV1({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSemanticClearanceSourceV1(
        Act0SceneSemanticClearanceScopeV1.maybeOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSemanticClearanceSourceV1 renderObject,
  ) {
    renderObject.registry = Act0SceneSemanticClearanceScopeV1.maybeOf(context);
  }
}

class _RenderSemanticClearanceSourceV1 extends RenderProxyBox {
  _RenderSemanticClearanceSourceV1(this._registry);

  Act0SceneSemanticClearanceRegistryV1? _registry;

  set registry(Act0SceneSemanticClearanceRegistryV1? value) {
    if (identical(value, _registry)) return;
    if (attached) _unregister();
    _registry = value;
    if (attached) _register();
  }

  void _register() {
    _registry?._sources.add(this);
    _registry?._invalidate();
  }

  void _unregister() {
    _registry?._sources.remove(this);
    _registry?._invalidate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _register();
  }

  @override
  void detach() {
    _unregister();
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    _registry?._invalidate();
  }
}

/// Paints its child everywhere except over registered clearance sources.
class Act0SceneSemanticClearanceClipV1 extends SingleChildRenderObjectWidget {
  const Act0SceneSemanticClearanceClipV1({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSemanticClearanceClipV1(
        Act0SceneSemanticClearanceScopeV1.maybeOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSemanticClearanceClipV1 renderObject,
  ) {
    renderObject.registry = Act0SceneSemanticClearanceScopeV1.maybeOf(context);
  }
}

class _RenderSemanticClearanceClipV1 extends RenderProxyBox {
  _RenderSemanticClearanceClipV1(this._registry);

  Act0SceneSemanticClearanceRegistryV1? _registry;
  final LayerHandle<ClipPathLayer> _clipLayer = LayerHandle<ClipPathLayer>();

  set registry(Act0SceneSemanticClearanceRegistryV1? value) {
    if (identical(value, _registry)) return;
    if (attached) _registry?._clips.remove(this);
    _registry = value;
    if (attached) _registry?._clips.add(this);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _registry?._clips.add(this);
  }

  @override
  void detach() {
    _registry?._clips.remove(this);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final holes = _registry?.clearancePathIn(this);
    if (child == null || holes == null) {
      _clipLayer.layer = null;
      super.paint(context, offset);
      return;
    }
    // Registered art may overflow the stage box; never clip anything except
    // the clearance holes themselves.
    final bounds = (Offset.zero & size).inflate(size.longestSide);
    _clipLayer.layer = context.pushClipPath(
      needsCompositing,
      offset,
      bounds,
      Path.combine(PathOperation.difference, Path()..addRect(bounds), holes),
      super.paint,
      oldLayer: _clipLayer.layer,
    );
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }
}

/// Whole-source registered paint with human-only folded attenuation.
///
/// The base composite is always painted at full opacity. The mask then clips a
/// restrained room-tone overlay to human pixels, leaving the chair/support
/// pixels untouched.
class Act0SceneRegisteredSeatPainterV1 extends CustomPainter {
  const Act0SceneRegisteredSeatPainterV1({
    required this.seatImage,
    required this.playerEffectMask,
    required this.folded,
  });

  final ui.Image seatImage;
  final ui.Image? playerEffectMask;
  final bool folded;

  static const Color _foldedRoomTone = Color(0xFF0B1928);
  static const ColorFilter _luminanceToAlpha = ColorFilter.matrix(<double>[
    0,
    0,
    0,
    0,
    255,
    0,
    0,
    0,
    0,
    255,
    0,
    0,
    0,
    0,
    255,
    1,
    0,
    0,
    0,
    0,
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    final destination = Offset.zero & size;
    canvas.drawImageRect(
      seatImage,
      Offset.zero &
          Size(seatImage.width.toDouble(), seatImage.height.toDouble()),
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );

    final mask = playerEffectMask;
    if (!folded || mask == null) return;
    canvas.saveLayer(destination, Paint());
    canvas.drawImageRect(
      mask,
      Offset.zero & Size(mask.width.toDouble(), mask.height.toDouble()),
      destination,
      Paint()
        ..filterQuality = FilterQuality.high
        // Supplied masks encode human coverage as white luminance on black,
        // so promote the red/grey channel to alpha before clipping the tint.
        ..colorFilter = _luminanceToAlpha,
    );
    canvas.drawRect(
      destination,
      Paint()
        ..color = _foldedRoomTone.withValues(alpha: 0.48)
        ..blendMode = BlendMode.srcIn,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Act0SceneRegisteredSeatPainterV1 oldDelegate) =>
      !identical(oldDelegate.seatImage, seatImage) ||
      !identical(oldDelegate.playerEffectMask, playerEffectMask) ||
      oldDelegate.folded != folded;
}

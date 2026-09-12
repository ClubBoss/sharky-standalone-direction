import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

/// Registered V3 opponents for one existing scene depth plane.
///
/// The live semantic table remains between the back and front instances of
/// this layer. Generic character fitting is used only while a registered PNG
/// (or a folded seat's mask) is unavailable.
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
    return LayoutBuilder(
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
                ),
          ],
        );
      },
    );
  }

  Widget _registeredSeat({
    required Act0SceneCharacterIdentityV1 identity,
    required Act0SceneSeatSlotV1 slot,
    required Size stageSize,
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
          store: store,
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

/// Loads and paints one registered seat composite plus its human-only mask.
class Act0SceneRegisteredSeatCompositeV1 extends StatefulWidget {
  const Act0SceneRegisteredSeatCompositeV1({
    super.key,
    required this.registration,
    required this.folded,
    required this.size,
    required this.fallback,
    this.store,
  });

  final Act0SceneRegisteredSeatV1 registration;
  final bool folded;
  final Size size;
  final Widget fallback;
  final Act0SceneCharacterImageStoreV1? store;

  @override
  State<Act0SceneRegisteredSeatCompositeV1> createState() =>
      _Act0SceneRegisteredSeatCompositeV1State();
}

class _Act0SceneRegisteredSeatCompositeV1State
    extends State<Act0SceneRegisteredSeatCompositeV1> {
  ui.Image? _seatImage;
  ui.Image? _maskImage;
  Object? _pendingToken;

  Act0SceneCharacterImageStoreV1 get _store =>
      widget.store ?? Act0SceneCharacterImageStoreV1.shared;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant Act0SceneRegisteredSeatCompositeV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registration != widget.registration ||
        oldWidget.store != widget.store) {
      _seatImage = null;
      _maskImage = null;
      _resolve();
    }
  }

  void _resolve() {
    final seatPath = widget.registration.seatActivePath;
    final maskPath = widget.registration.playerEffectMaskPath;
    _seatImage = _store.readyImageFor(seatPath);
    _maskImage = _store.readyImageFor(maskPath);
    if (_seatImage != null && _maskImage != null) return;

    final token = Object();
    _pendingToken = token;
    unawaited(
      Future.wait<ui.Image?>(<Future<ui.Image?>>[
        _store.load(seatPath),
        _store.load(maskPath),
      ]).then((images) {
        if (!mounted || _pendingToken != token) return;
        setState(() {
          _seatImage = images[0];
          _maskImage = images[1];
        });
      }),
    );
  }

  @override
  void dispose() {
    _pendingToken = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seatImage =
        _seatImage ?? _store.readyImageFor(widget.registration.seatActivePath);
    final maskImage =
        _maskImage ??
        _store.readyImageFor(widget.registration.playerEffectMaskPath);
    if (seatImage == null || (widget.folded && maskImage == null)) {
      return KeyedSubtree(
        key: Key(
          'act0_scene_registered_${widget.registration.identity.name}_fallback',
        ),
        child: widget.fallback,
      );
    }
    return CustomPaint(
      key: Key(
        'act0_scene_registered_${widget.registration.identity.name}_ready',
      ),
      size: widget.size,
      painter: Act0SceneRegisteredSeatPainterV1(
        seatImage: seatImage,
        playerEffectMask: maskImage,
        folded: widget.folded,
      ),
    );
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

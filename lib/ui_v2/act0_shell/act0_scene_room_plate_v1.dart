import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';

/// Stable owner path for the approved production members-room backplate.
class Act0SceneRoomPlateRegistryV1 {
  const Act0SceneRoomPlateRegistryV1._();

  static const String productionPath = 'assets/act0_room/room_plate_v1.png';
}

/// Decode-once store for the production room plate.
///
/// Missing assets are a supported state and keep the procedural B2 room
/// visible. Invalid bytes are reported because they indicate a broken bundled
/// asset rather than a normal warm-up frame.
class Act0SceneRoomPlateImageStoreV1 {
  Act0SceneRoomPlateImageStoreV1();

  static final shared = Act0SceneRoomPlateImageStoreV1();

  ui.Image? _ready;
  Future<ui.Image?>? _pending;
  bool _missing = false;

  ui.Image? get readyImage => _ready;
  bool get isReady => _ready != null;
  bool get isPending => _pending != null;
  bool get isMissing => _missing;

  Future<ui.Image?> warmUp({AssetBundle? bundle}) {
    final ready = _ready;
    if (ready != null) return SynchronousFuture<ui.Image?>(ready);
    if (_missing) return SynchronousFuture<ui.Image?>(null);
    final inFlight = _pending;
    if (inFlight != null) return inFlight;

    final future = _load(bundle ?? rootBundle);
    _pending = future;
    unawaited(
      future.whenComplete(() {
        if (identical(_pending, future)) _pending = null;
      }),
    );
    return future;
  }

  Future<ui.Image?> _load(AssetBundle bundle) async {
    final ByteData data;
    try {
      data = await bundle.load(Act0SceneRoomPlateRegistryV1.productionPath);
    } on FlutterError {
      _missing = true;
      return null;
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Sharky production room plate',
          context: ErrorDescription('while loading the room plate'),
        ),
      );
      return null;
    }

    try {
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      try {
        final frame = await codec.getNextFrame();
        _ready = frame.image;
        return frame.image;
      } finally {
        codec.dispose();
      }
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Sharky production room plate',
          context: ErrorDescription('while decoding the room plate'),
        ),
      );
      return null;
    }
  }

  @visibleForTesting
  void clear() {
    _ready?.dispose();
    _ready = null;
    _pending = null;
    _missing = false;
  }
}

/// Owns asynchronous warm-up while exposing a synchronous paint path.
///
/// Until the owner plate is ready, the exact procedural room painter remains
/// visible, so the scene never flashes blank or crashes on a missing asset.
class Act0SceneRoomPlaneV1 extends StatefulWidget {
  const Act0SceneRoomPlaneV1({
    super.key,
    this.light = Act0SceneLightV1.canonical,
    this.horizon = 0.17,
    this.fit = Act0SceneRoomPlateFitV1.production,
    this.store,
  });

  final Act0SceneLightV1 light;
  final double horizon;
  final Act0SceneRoomPlateFitV1 fit;
  final Act0SceneRoomPlateImageStoreV1? store;

  @override
  State<Act0SceneRoomPlaneV1> createState() => _Act0SceneRoomPlaneV1State();
}

class _Act0SceneRoomPlaneV1State extends State<Act0SceneRoomPlaneV1> {
  ui.Image? _image;
  Object? _pendingToken;

  Act0SceneRoomPlateImageStoreV1 get _store =>
      widget.store ?? Act0SceneRoomPlateImageStoreV1.shared;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant Act0SceneRoomPlaneV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      _image = null;
      _resolve();
    }
  }

  void _resolve() {
    final ready = _store.readyImage;
    if (ready != null) {
      _image = ready;
      return;
    }
    if (_store.isPending || _store.isMissing) return;
    final token = Object();
    _pendingToken = token;
    unawaited(
      _store.warmUp().then((image) {
        if (!mounted || _pendingToken != token || image == null) return;
        setState(() => _image = image);
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
    final image = _image ?? _store.readyImage;
    return CustomPaint(
      key: Key(
        image == null
            ? 'act0_scene_room_plate_fallback'
            : 'act0_scene_room_plate_ready',
      ),
      painter: Act0SceneRoomPainterV1(
        light: widget.light,
        horizon: widget.horizon,
        plate: image,
        plateFit: widget.fit,
      ),
    );
  }
}

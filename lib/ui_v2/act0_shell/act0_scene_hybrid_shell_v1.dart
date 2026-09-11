import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_room_plate_v1.dart';

/// RENDER_CLASS_HYBRID_INTEGRATION_V1 — the baked room+table scene shell and
/// the authored Hero POV foreground.
///
/// Both are one fixed-path production PNG with the same decode-once,
/// missing-is-a-supported-state contract already proven by the room plate and
/// character stores. This module owns only asset loading and painting; V2
/// camera, table geometry, seat anchors and poker/learning semantics are
/// never read or mutated here.

/// Decode-once store for a single fixed-path production PNG, shared by the
/// hybrid scene shell and the Hero POV foreground.
class Act0SceneSinglePlateImageStoreV1 {
  Act0SceneSinglePlateImageStoreV1(this.assetPath, {required this.library});

  final String assetPath;
  final String library;

  ui.Image? _ready;
  Future<ui.Image?>? _pending;
  bool _missing = false;

  /// Flips once after a successful decode, so sibling widgets that cannot
  /// observe this store's own async load (the procedural table material
  /// painters) can react without polling.
  final ValueNotifier<bool> readyNotifier = ValueNotifier<bool>(false);

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
      data = await bundle.load(assetPath);
    } on FlutterError {
      // Keep the procedural fallback visible if the bundled asset is
      // unavailable; this is a supported rollback state, not an error.
      _missing = true;
      return null;
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: library,
          context: ErrorDescription('while loading $assetPath'),
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
        readyNotifier.value = true;
        return frame.image;
      } finally {
        codec.dispose();
      }
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: library,
          context: ErrorDescription('while decoding $assetPath'),
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
    readyNotifier.value = false;
  }
}

/// Stable owner paths and shared stores for the render-class hybrid assets.
class Act0SceneHybridShellRegistryV1 {
  const Act0SceneHybridShellRegistryV1._();

  static const String shellPath =
      'assets/act0_render_class/hybrid_scene_shell_v2.png';
  static const String heroPath =
      'assets/act0_render_class/hero_pov_foreground_v3.png';

  static final Act0SceneSinglePlateImageStoreV1 shellStore =
      Act0SceneSinglePlateImageStoreV1(
        shellPath,
        library: 'Sharky render-class hybrid shell',
      );

  static final Act0SceneSinglePlateImageStoreV1 heroStore =
      Act0SceneSinglePlateImageStoreV1(
        heroPath,
        library: 'Sharky render-class Hero POV foreground',
      );
}

/// Full-bleed cover-crop paint of the hybrid scene shell into the canonical
/// scene box, using the same normalized fit contract as the room plate.
class Act0SceneHybridShellPainterV1 extends CustomPainter {
  const Act0SceneHybridShellPainterV1({
    required this.image,
    this.fit = Act0SceneRoomPlateFitV1.hybridShellV1,
  });

  final ui.Image image;
  final Act0SceneRoomPlateFitV1 fit;

  @override
  void paint(Canvas canvas, Size size) {
    final source = fit.sourceRectFor(
      Size(image.width.toDouble(), image.height.toDouble()),
      size,
    );
    canvas.drawImageRect(
      image,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant Act0SceneHybridShellPainterV1 oldDelegate) =>
      !identical(oldDelegate.image, image) || oldDelegate.fit != fit;
}

/// Renders the baked render-class hybrid scene shell (room + table) across
/// the whole canonical scene box when the authored asset is available.
///
/// Missing/invalid bytes are a supported rollback state: this widget keeps
/// the existing [Act0SceneRoomPlaneV1] (procedural room, or the production
/// room plate) fully intact as the deterministic fallback, exactly as before
/// this integration. The table stage listens to
/// [Act0SceneHybridShellRegistryV1.shellStore]'s `readyNotifier` separately
/// to suppress its own procedural rail/felt material once the shell is ready,
/// so the two never double-paint.
class Act0SceneHybridShellPlaneV1 extends StatefulWidget {
  const Act0SceneHybridShellPlaneV1({super.key, required this.horizon});

  final double horizon;

  @override
  State<Act0SceneHybridShellPlaneV1> createState() =>
      _Act0SceneHybridShellPlaneV1State();
}

class _Act0SceneHybridShellPlaneV1State
    extends State<Act0SceneHybridShellPlaneV1> {
  ui.Image? _image;
  Object? _pendingToken;

  Act0SceneSinglePlateImageStoreV1 get _store =>
      Act0SceneHybridShellRegistryV1.shellStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
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
    if (image == null) {
      return Act0SceneRoomPlaneV1(horizon: widget.horizon);
    }
    return CustomPaint(
      key: const Key('act0_scene_hybrid_shell_ready'),
      painter: Act0SceneHybridShellPainterV1(image: image),
    );
  }
}

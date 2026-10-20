import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_room_plate_v1.dart';

/// Owner-admitted S12.V T2 Stage A one-seat visual falsifier only.
///
/// This is a build-time opt-in, never a production-path or release default.
/// The other four baked opponents intentionally cannot change visual posture:
/// therefore no full five-seat parity or S12.V PASS can be claimed.
class Act0SceneT2CanaryV1 {
  const Act0SceneT2CanaryV1._();

  static const enabled = bool.fromEnvironment(
    'SHARKY_T2_SB_CANARY',
    defaultValue: false,
  );

  static const engagedPath =
      'assets/act0_t2_canary/t2_sb_engaged_1093x1844.png';
  static const relaxedPath =
      'assets/act0_t2_canary/t2_sb_relaxed_1093x1844.png';

  static final engagedStore = Act0SceneSinglePlateImageStoreV1(
    engagedPath,
    library: 'Sharky T2 isolated Engaged candidate',
  );
  static final relaxedStore = Act0SceneSinglePlateImageStoreV1(
    relaxedPath,
    library: 'Sharky T2 isolated Folded candidate',
  );

  static const sourceSize = Size(1093, 1844);

  // Measured source-edit candidate, NOT adopted cross-seat production geometry.
  // Single projection shared by the image and game object stage.
  static const tableOuterSourceRect = Rect.fromLTWH(248, 550, 654, 967);

  static Rect sceneImageRect(Size viewport) {
    final scale = (viewport.width / sourceSize.width).clamp(
      0.0,
      viewport.height / sourceSize.height,
    );
    final width = sourceSize.width * scale;
    final height = sourceSize.height * scale;
    return Rect.fromLTWH(
      (viewport.width - width) / 2,
      (viewport.height - height) / 2,
      width,
      height,
    );
  }

  static Rect tableStageRect(Size viewport) {
    final image = sceneImageRect(viewport);
    final scale = image.width / sourceSize.width;
    // Native T2 first-table screenshots 2026-10-20: the unchanged V4 table
    // stage puts Hero hole cards underneath the scene-attached action shelf.
    // Keep the far cards/rail anchor, compress ONLY the dynamic poker overlay
    // toward the readable felt. The source scene stays undistorted.
    final shortPhone = viewport.height / viewport.width < 2.0;
    final overlayHeightFactor = shortPhone ? 0.80 : 0.88;
    return Rect.fromLTWH(
      image.left + tableOuterSourceRect.left * scale,
      image.top + tableOuterSourceRect.top * scale,
      tableOuterSourceRect.width * scale,
      tableOuterSourceRect.height * scale * overlayHeightFactor,
    );
  }
}

class Act0SceneT2CanaryPlaneV1 extends StatelessWidget {
  const Act0SceneT2CanaryPlaneV1({
    super.key,
    required this.horizon,
    required this.sbFolded,
  });

  final double horizon;
  final bool sbFolded;

  @override
  Widget build(BuildContext context) {
    final selected = sbFolded
        ? Act0SceneT2CanaryV1.relaxedStore
        : Act0SceneT2CanaryV1.engagedStore;
    return Stack(
      fit: StackFit.expand,
      children: [
        Act0SceneRoomPlaneV1(horizon: horizon),
        FutureBuilder<ui.Image?>(
          future: selected.warmUp(),
          builder: (context, state) {
            final image =
                state.data ??
                selected.readyImage ??
                Act0SceneT2CanaryV1.engagedStore.readyImage;
            if (image == null) return const SizedBox.shrink();
            return CustomPaint(
              key: Key(
                sbFolded
                    ? 'act0_scene_t2_sb_relaxed_ready'
                    : 'act0_scene_t2_sb_engaged_ready',
              ),
              painter: _T2SceneImagePainterV1(image),
            );
          },
        ),
      ],
    );
  }
}

class _T2SceneImagePainterV1 extends CustomPainter {
  const _T2SceneImagePainterV1(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final destination = Act0SceneT2CanaryV1.sceneImageRect(size);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _T2SceneImagePainterV1 oldDelegate) =>
      !identical(image, oldDelegate.image);
}

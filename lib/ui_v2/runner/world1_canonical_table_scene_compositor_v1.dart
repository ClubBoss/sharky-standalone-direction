import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_action_token_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_visual_cluster_v1.dart';

class World1CanonicalTableSceneCompositorInputV1 {
  const World1CanonicalTableSceneCompositorInputV1({
    required this.showBoardGlow,
    required this.boardRect,
    required this.showPotGlow,
    required this.potRect,
    required this.showActingSeatGlow,
    required this.actingSeatCenter,
    required this.seatVisualRadius,
    required this.compactPhone,
    required this.handVisualCluster,
    required this.potChild,
    required this.heroCardsChild,
    required this.actionTokenContract,
    required this.seatQuizCueBodies,
    required this.handLoopChipCueBodies,
    required this.instructionSurface,
    required this.feltCaption,
    required this.feltCaptionLeft,
    required this.feltCaptionRight,
    required this.feltCaptionTop,
    required this.portraitOverlay,
    required this.portraitOverlayLeft,
    required this.portraitOverlayRight,
    required this.portraitOverlayTop,
  });

  final bool showBoardGlow;
  final Rect boardRect;
  final bool showPotGlow;
  final Rect potRect;
  final bool showActingSeatGlow;
  final Offset? actingSeatCenter;
  final double seatVisualRadius;
  final bool compactPhone;
  final World1CanonicalHandVisualClusterContractV1 handVisualCluster;
  final Widget potChild;
  final Widget heroCardsChild;
  final World1CanonicalActionTokenContractResolvedV1 actionTokenContract;
  final List<Widget> seatQuizCueBodies;
  final List<Widget> handLoopChipCueBodies;
  final Widget? instructionSurface;
  final Widget? feltCaption;
  final double feltCaptionLeft;
  final double feltCaptionRight;
  final double feltCaptionTop;
  final Widget? portraitOverlay;
  final double portraitOverlayLeft;
  final double portraitOverlayRight;
  final double portraitOverlayTop;
}

List<Widget> buildWorld1CanonicalTableSceneCompositorV1({
  required World1CanonicalTableSceneCompositorInputV1 input,
}) {
  return <Widget>[
    if (input.showBoardGlow)
      _buildFocusGlowRectV1(
        rect: input.boardRect,
        color: SharkyTokensV1.semanticInfo,
        inflateX: input.compactPhone ? 10 : 12,
        inflateY: input.compactPhone ? 6 : 8,
        borderRadius: 16,
        opacity: input.compactPhone ? 0.12 : 0.10,
        blur: input.compactPhone ? 18 : 22,
      ),
    if (input.showPotGlow)
      _buildFocusGlowRectV1(
        rect: input.potRect,
        color: SharkyTokensV1.brandPrimary,
        inflateX: input.compactPhone ? 8 : 10,
        inflateY: input.compactPhone ? 5 : 6,
        borderRadius: 16,
        opacity: input.compactPhone ? 0.11 : 0.09,
        blur: input.compactPhone ? 16 : 20,
      ),
    if (input.showActingSeatGlow && input.actingSeatCenter != null)
      _buildFocusGlowCircleV1(
        center: input.actingSeatCenter!,
        radius: input.seatVisualRadius * (input.compactPhone ? 2.05 : 2.2),
        color: SharkyTokensV1.brandGlow,
        opacity: input.compactPhone ? 0.13 : 0.11,
        blur: input.compactPhone ? 20 : 24,
      ),
    ...buildWorld1CanonicalHandVisualClusterV1(
      contract: input.handVisualCluster,
      boardChild: const SizedBox.shrink(),
      potChild: input.potChild,
      heroCardsChild: input.heroCardsChild,
    ),
    if (input.actionTokenContract.glowCenter != null)
      _buildFocusGlowCircleV1(
        center: input.actionTokenContract.glowCenter!,
        radius: input.actionTokenContract.glowRadius,
        color: SharkyTokensV1.brandPrimary,
        opacity: 0.10,
        blur: input.compactPhone ? 14 : 18,
      ),
    ...buildWorld1CanonicalActionTokenBodiesV1(
      contract: input.actionTokenContract,
    ),
    ...input.seatQuizCueBodies,
    ...input.handLoopChipCueBodies,
    if (input.instructionSurface != null) input.instructionSurface!,
    if (input.feltCaption != null)
      Positioned(
        left: input.feltCaptionLeft,
        right: input.feltCaptionRight,
        top: input.feltCaptionTop,
        child: input.feltCaption!,
      ),
    if (input.portraitOverlay != null)
      Positioned(
        left: input.portraitOverlayLeft,
        right: input.portraitOverlayRight,
        top: input.portraitOverlayTop,
        child: input.portraitOverlay!,
      ),
  ];
}

Widget _buildFocusGlowRectV1({
  required Rect rect,
  required Color color,
  required double inflateX,
  required double inflateY,
  required double borderRadius,
  required double opacity,
  required double blur,
}) {
  return Positioned.fromRect(
    rect: rect.inflate(inflateX).inflate(inflateY / 2),
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: blur,
              spreadRadius: 0.6,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFocusGlowCircleV1({
  required Offset center,
  required double radius,
  required Color color,
  required double opacity,
  required double blur,
}) {
  return Positioned(
    left: center.dx - radius,
    top: center.dy - radius,
    child: IgnorePointer(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: blur,
              spreadRadius: 0.8,
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_action_token_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_visual_cluster_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_scene_compositor_v1.dart';

void main() {
  testWidgets(
    'world1 canonical table scene compositor mounts major scene layers',
    (tester) async {
      final handVisualCluster =
          resolveWorld1CanonicalHandVisualClusterContractV1(
            showCampaignHandVisuals: true,
            boardVisible: true,
            heroVisible: true,
            boardAlignment: Alignment.topCenter,
            potAlignment: Alignment.center,
            heroAlignment: Alignment.bottomCenter,
          );

      const actionTokenContract = World1CanonicalActionTokenContractResolvedV1(
        bodyKind: World1CanonicalActionTokenBodyKindV1.hidden,
        glowCenter: null,
        glowRadius: 0,
        betCenter: null,
        demoRowLeft: 0,
        demoRowTop: 0,
        markerContract: null,
        demoChipSize: 0,
        demoRowKey: Key('microtask_demo_token_row_v1'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: buildWorld1CanonicalTableSceneCompositorV1(
                input: World1CanonicalTableSceneCompositorInputV1(
                  showBoardGlow: true,
                  boardRect: const Rect.fromLTWH(40, 40, 120, 30),
                  showPotGlow: true,
                  potRect: const Rect.fromLTWH(80, 90, 60, 24),
                  showActingSeatGlow: true,
                  actingSeatCenter: const Offset(120, 160),
                  seatVisualRadius: 24,
                  compactPhone: false,
                  handVisualCluster: handVisualCluster,
                  potChild: const Text('POT'),
                  heroCardsChild: const Text('HERO'),
                  actionTokenContract: actionTokenContract,
                  seatQuizCueBodies: const <Widget>[Text('SEAT_QUIZ_CUE')],
                  handLoopChipCueBodies: const <Widget>[Text('HAND_LOOP_CUE')],
                  instructionSurface: const Text('INSTRUCTION'),
                  feltCaption: const Text('CAPTION'),
                  feltCaptionLeft: 10,
                  feltCaptionRight: 10,
                  feltCaptionTop: 12,
                  portraitOverlay: const Text('OVERLAY'),
                  portraitOverlayLeft: 12,
                  portraitOverlayRight: 12,
                  portraitOverlayTop: 60,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('POT'), findsOneWidget);
      expect(find.text('HERO'), findsOneWidget);
      expect(find.text('SEAT_QUIZ_CUE'), findsOneWidget);
      expect(find.text('HAND_LOOP_CUE'), findsOneWidget);
      expect(find.text('INSTRUCTION'), findsOneWidget);
      expect(find.text('CAPTION'), findsOneWidget);
      expect(find.text('OVERLAY'), findsOneWidget);
    },
  );
}

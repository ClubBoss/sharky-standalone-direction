import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_visual_cluster_v1.dart';

void main() {
  test('world1 canonical hand visual cluster resolves visibility', () {
    final resolved = resolveWorld1CanonicalHandVisualClusterContractV1(
      showCampaignHandVisuals: true,
      boardVisible: true,
      heroVisible: false,
      boardAlignment: Alignment.topCenter,
      potAlignment: Alignment.center,
      heroAlignment: Alignment.bottomCenter,
    );

    expect(resolved.showBoard, isTrue);
    expect(resolved.showPot, isTrue);
    expect(resolved.showHeroCards, isFalse);
    expect(resolved.boardAlignment, Alignment.topCenter);
  });

  testWidgets(
    'world1 canonical hand visual cluster renders board and pot bodies',
    (tester) async {
      final resolved = resolveWorld1CanonicalHandVisualClusterContractV1(
        showCampaignHandVisuals: true,
        boardVisible: true,
        heroVisible: true,
        boardAlignment: Alignment.topCenter,
        potAlignment: Alignment.center,
        heroAlignment: Alignment.bottomCenter,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: buildWorld1CanonicalHandVisualClusterV1(
                contract: resolved,
                boardChild: const Text('BOARD'),
                potChild: const Text('POT'),
                heroCardsChild: buildWorld1CanonicalHeroCardsBodyV1(
                  cardsRow: const Text('HERO'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('BOARD'), findsOneWidget);
      expect(find.text('POT'), findsOneWidget);
      expect(find.text('HERO'), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_demo_hero_cards_box_v1')),
        findsOneWidget,
      );
    },
  );
}

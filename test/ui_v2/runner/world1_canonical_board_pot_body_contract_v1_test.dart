import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine_v2/model/money_state_v1.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_board_pot_body_contract_v1.dart';

void main() {
  test(
    'world1 canonical board/pot contract resolves demo board placeholders',
    () {
      final resolved = resolveWorld1CanonicalBoardPotBodyContractV1(
        effectiveStreet: StreetV1.turn,
        boardCardsCount: 5,
        demoHandLoopVisualStep: true,
        demoHandLoopSession: false,
        displayedPotChips: 12,
        compactPotBadge: true,
        inlinePotBadge: true,
        potPulse: false,
      );

      expect(resolved.visibleBoardCount, 4);
      expect(resolved.renderHiddenBoardPlaceholders, isTrue);
      expect(resolved.renderedBoardCount, 5);
      expect(resolved.displayedPotChips, 12);
    },
  );

  testWidgets('world1 canonical board body renders hidden placeholders', (
    tester,
  ) async {
    final resolved = resolveWorld1CanonicalBoardPotBodyContractV1(
      effectiveStreet: StreetV1.flop,
      boardCardsCount: 5,
      demoHandLoopVisualStep: true,
      demoHandLoopSession: false,
      displayedPotChips: 8,
      compactPotBadge: false,
      inlinePotBadge: true,
      potPulse: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildWorld1CanonicalBoardRevealBodyV1(
            contract: resolved,
            boardCards: <CardModel>[
              CardModel(rank: 'A', suit: 's'),
              CardModel(rank: 'K', suit: 'h'),
              CardModel(rank: 'Q', suit: 'd'),
              CardModel(rank: 'J', suit: 'c'),
              CardModel(rank: 'T', suit: 's'),
            ],
            cardScale: 1.0,
            buildFaceDownCard: (scale) => const SizedBox(width: 10, height: 14),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('microtask_engine_board_strip')),
      findsOneWidget,
    );
  });

  testWidgets('world1 canonical pot badge renders amount key', (tester) async {
    const resolved = World1CanonicalBoardPotBodyContractV1(
      visibleBoardCount: 0,
      renderedBoardCount: 0,
      renderHiddenBoardPlaceholders: false,
      displayedPotChips: 16,
      compactPotBadge: true,
      inlinePotBadge: false,
      potPulse: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildWorld1CanonicalPotBadgeBodyV1(
            contract: resolved,
            chipBadgeChild: const Text('POT'),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('microtask_engine_pot_feedback')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('microtask_pot_value_v1')), findsOneWidget);
    expect(find.text('POT'), findsOneWidget);
  });
}

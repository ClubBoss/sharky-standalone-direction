import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_action_token_contract_v1.dart';

void main() {
  test('world1 canonical action token contract resolves demo row body', () {
    final resolved = resolveWorld1CanonicalActionTokenContractV1(
      World1CanonicalActionTokenContractInputV1(
        handLoopVisualMode: true,
        demoHandLoopVisualStep: true,
        compactPhone: true,
        tableCenter: const Offset(200, 160),
        stadiumSafeRect: const Rect.fromLTWH(20, 20, 360, 260),
        actingSeatCenter: const Offset(120, 220),
        betOwnerSeatCenter: const Offset(120, 220),
        boardRect: const Rect.fromLTWH(120, 80, 120, 40),
        potRect: const Rect.fromLTWH(150, 60, 80, 30),
        heroCardsRect: const Rect.fromLTWH(130, 240, 100, 40),
        heroCenterPoint: const Offset(180, 220),
        overlayLaneBottom: 300,
        demoHeroToTokenGap: 18,
        currentBet: 6,
      ),
    );

    expect(resolved.bodyKind, World1CanonicalActionTokenBodyKindV1.demoRow);
    expect(resolved.glowCenter, isNotNull);
    expect(resolved.markerContract, isNotNull);
    expect(resolved.markerContract!.amount, 6);
  });

  testWidgets('world1 canonical action token bodies render placed marker', (
    tester,
  ) async {
    final resolved = resolveWorld1CanonicalActionTokenContractV1(
      World1CanonicalActionTokenContractInputV1(
        handLoopVisualMode: true,
        demoHandLoopVisualStep: false,
        compactPhone: false,
        tableCenter: const Offset(240, 180),
        stadiumSafeRect: const Rect.fromLTWH(20, 20, 440, 320),
        actingSeatCenter: const Offset(100, 250),
        betOwnerSeatCenter: const Offset(100, 250),
        boardRect: const Rect.fromLTWH(170, 110, 140, 46),
        potRect: const Rect.fromLTWH(200, 85, 80, 30),
        heroCardsRect: const Rect.fromLTWH(180, 280, 120, 46),
        heroCenterPoint: const Offset(240, 300),
        overlayLaneBottom: 330,
        demoHeroToTokenGap: 20,
        currentBet: 8,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: buildWorld1CanonicalActionTokenBodiesV1(
              contract: resolved,
            ),
          ),
        ),
      ),
    );

    expect(find.text('BET'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });
}

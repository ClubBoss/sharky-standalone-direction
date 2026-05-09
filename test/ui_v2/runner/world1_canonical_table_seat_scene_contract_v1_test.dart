import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_seat_scene_contract_v1.dart';

void main() {
  test('world1 canonical table seat scene resolves acting seat semantics', () {
    final resolved = resolveWorld1CanonicalTableSeatSceneV1(
      const World1CanonicalTableSeatSceneInputV1(
        displaySeatId: 'btn',
        logicalSeatId: 'btn',
        seatLabel: 'BTN',
        displayLabelText: 'BTN',
        canonicalOrderBadgeText: '1',
        seatCenter: Offset(100, 120),
        seatSize: 48,
        seatColor: Colors.blue,
        textColor: Colors.white,
        defaultBorderColor: Colors.grey,
        seatIsInteractable: true,
        seatQuizVisualMode: false,
        handLoopVisualMode: true,
        seatInHand: true,
        foldedBySeatId: false,
        handLoopActionRequired: true,
        targetSeatId: null,
        activeSeatGlowId: null,
        actingSeatId: 'btn',
        rotatingHeroSeatId: 'btn',
        canRotateSeatDisplay: true,
        tablePracticeSession: false,
        compactPortrait: false,
        handLoopOutcomeFocusDeemphasis: false,
        selectionActive: true,
      ),
    );

    expect(resolved.left, 76);
    expect(resolved.top, 96);
    expect(resolved.semanticLabel, 'Seat BTN');
    expect(resolved.semanticValue, 'selected');
    expect(resolved.bodyContract.showActBadge, isTrue);
    expect(resolved.bodyContract.showHeroBadge, isTrue);
  });

  testWidgets('world1 canonical table seat scene builds positioned seat body', (
    tester,
  ) async {
    final resolved = resolveWorld1CanonicalTableSeatSceneV1(
      const World1CanonicalTableSeatSceneInputV1(
        displaySeatId: 'sb',
        logicalSeatId: 'sb',
        seatLabel: 'SB',
        displayLabelText: 'SB',
        canonicalOrderBadgeText: '2',
        seatCenter: Offset(80, 90),
        seatSize: 44,
        seatColor: Colors.green,
        textColor: Colors.white,
        defaultBorderColor: Colors.black,
        seatIsInteractable: true,
        seatQuizVisualMode: true,
        handLoopVisualMode: false,
        seatInHand: true,
        foldedBySeatId: false,
        handLoopActionRequired: false,
        targetSeatId: 'sb',
        activeSeatGlowId: null,
        actingSeatId: null,
        rotatingHeroSeatId: null,
        canRotateSeatDisplay: false,
        tablePracticeSession: false,
        compactPortrait: true,
        handLoopOutcomeFocusDeemphasis: false,
        selectionActive: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              buildWorld1CanonicalTableSeatSceneBodyV1(
                contract: resolved,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('SB'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      find.byKey(const Key('microtask_seat_order_badge_sb_v1')),
      findsOneWidget,
    );
    expect(find.byType(Positioned), findsAtLeastNWidgets(2));
  });
}

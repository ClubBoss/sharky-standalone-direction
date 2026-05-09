import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_seat_state_v1.dart';

void main() {
  test('world1 canonical seat state resolves seat-quiz target highlight', () {
    final state = buildWorld1CanonicalTableSeatStateV1(
      seatIsInteractable: true,
      seatQuizVisualMode: true,
      handLoopVisualMode: false,
      seatInHand: true,
      foldedBySeatId: false,
      handLoopActionRequired: false,
      logicalSeatId: 'btn',
      targetSeatId: 'btn',
      activeSeatGlowId: null,
      actingSeatId: null,
      rotatingHeroSeatId: null,
    );

    expect(state.seatTapEnabled, isTrue);
    expect(state.isSeatQuizTargetHighlightActive, isTrue);
    expect(state.isSeatQuizTargetSeat, isTrue);
    expect(state.isActiveSeatGlow, isTrue);
    expect(state.visualRole, World1CanonicalSeatVisualRoleV1.target);
    expect(state.seatOpacity, 1.0);
  });

  test(
    'world1 canonical seat state resolves acting and folded hand-loop seat',
    () {
      final state = buildWorld1CanonicalTableSeatStateV1(
        seatIsInteractable: true,
        seatQuizVisualMode: false,
        handLoopVisualMode: true,
        seatInHand: true,
        foldedBySeatId: true,
        handLoopActionRequired: true,
        logicalSeatId: 'co',
        targetSeatId: null,
        activeSeatGlowId: 'co',
        actingSeatId: 'co',
        rotatingHeroSeatId: 'co',
      );

      expect(state.seatTapEnabled, isFalse);
      expect(state.isDecisionActingSeat, isTrue);
      expect(state.visualRole, World1CanonicalSeatVisualRoleV1.acting);
      expect(state.showHeroBadge, isTrue);
      expect(state.showActBadge, isTrue);
      expect(state.showFoldBadge, isTrue);
      expect(state.showOutBadge, isFalse);
      expect(state.availability, World1CanonicalSeatAvailabilityV1.folded);
      expect(state.seatOpacity, 0.5);
    },
  );
}

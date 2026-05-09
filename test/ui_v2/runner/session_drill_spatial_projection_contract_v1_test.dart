import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_spatial_projection_contract_v1.dart';

void main() {
  test('seat tap contract separates host gate from payload readiness', () {
    const spec = DrillSpecV1(
      id: 'find_btn',
      kind: DrillKindV1.seatTap,
      prompt: 'Tap BTN.',
      expected: DrillExpectedV1(role: 'btn'),
      errorClass: 'mismatch',
      playerCountV1: 6,
      heroSeatV1: 'sb',
      villainSeatV1: 'btn',
      activeSeatsV1: <String>['sb', 'bb', 'btn', 'co', 'hj', 'lj'],
    );

    final evaluation = SessionDrillSpatialProjectionContractV1.evaluate(
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: 'text_action_stack',
      drill: spec,
    );

    expect(evaluation.applies, isTrue);
    expect(evaluation.tableRequired, isTrue);
    expect(evaluation.payloadFamily, 'seat_anchor_scene');
    expect(evaluation.hostGateSatisfied, isFalse);
    expect(evaluation.hasRequiredScenePayload, isTrue);
    expect(
      evaluation.hostGateReasonCode,
      kSessionDrillSpatialProjectionHostGateReasonCodeV1,
    );
    expect(evaluation.payloadReasonCode, isNull);
    expect(evaluation.requiredSceneFields, <String>[
      'player_count_v1',
      'hero_seat_v1',
      'villain_seat_v1',
      'active_seats_v1',
    ]);
  });

  test('board tap contract requires board cards for projected scene', () {
    const spec = DrillSpecV1(
      id: 'tap_flop_left',
      kind: DrillKindV1.boardTap,
      prompt: 'Tap flop left.',
      expected: DrillExpectedV1(boardSlot: 'flop_left'),
      errorClass: 'mismatch',
      heroHoleCardsV1: <String>['Ah', 'Kd'],
    );

    final evaluation = SessionDrillSpatialProjectionContractV1.evaluate(
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
      drill: spec,
    );

    expect(evaluation.applies, isTrue);
    expect(evaluation.hostGateSatisfied, isTrue);
    expect(evaluation.hasRequiredScenePayload, isFalse);
    expect(
      evaluation.payloadReasonCode,
      kSessionDrillSpatialProjectionMissingSceneReasonCodeV1,
    );
    expect(evaluation.requiredSceneFields, <String>['board_cards_v1']);
    expect(evaluation.optionalSceneFields, <String>['hero_hole_cards_v1']);
  });

  test(
    'hole cards tap contract allows hero hole cards without board cards',
    () {
      const spec = DrillSpecV1(
        id: 'tap_hero_cards',
        kind: DrillKindV1.holeCardsTap,
        prompt: 'Tap your cards.',
        expected: DrillExpectedV1(actionId: 'hero_hole_cards'),
        errorClass: 'mismatch',
        heroHoleCardsV1: <String>['Ah', 'Kd'],
      );

      final evaluation = SessionDrillSpatialProjectionContractV1.evaluate(
        hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
        layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
        drill: spec,
      );

      expect(evaluation.applies, isTrue);
      expect(evaluation.hostGateSatisfied, isTrue);
      expect(evaluation.hasRequiredScenePayload, isTrue);
      expect(evaluation.payloadReasonCode, isNull);
      expect(evaluation.requiredSceneFields, <String>['hero_hole_cards_v1']);
      expect(evaluation.optionalSceneFields, <String>['board_cards_v1']);
    },
  );

  test('non spatial drill does not enter the spatial projection contract', () {
    const spec = DrillSpecV1(
      id: 'choose_call',
      kind: DrillKindV1.actionChoice,
      prompt: 'Choose call.',
      expected: DrillExpectedV1(actionId: 'call'),
      errorClass: 'mismatch',
    );

    final evaluation = SessionDrillSpatialProjectionContractV1.evaluate(
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: 'text_action_stack',
      drill: spec,
    );

    expect(evaluation.applies, isFalse);
    expect(evaluation.tableRequired, isFalse);
    expect(evaluation.hostGateSatisfied, isTrue);
    expect(evaluation.hasRequiredScenePayload, isTrue);
  });

  test('world1 foundations host stays outside the session drill contract', () {
    const spec = DrillSpecV1(
      id: 'find_btn',
      kind: DrillKindV1.seatTap,
      prompt: 'Tap BTN.',
      expected: DrillExpectedV1(role: 'btn'),
      errorClass: 'mismatch',
      playerCountV1: 6,
      heroSeatV1: 'sb',
      villainSeatV1: 'btn',
      activeSeatsV1: <String>['sb', 'bb', 'btn', 'co', 'hj', 'lj'],
    );

    final evaluation = SessionDrillSpatialProjectionContractV1.evaluate(
      hostSurface: 'world1FoundationsRunner',
      layoutFamily: 'table_canvas_runner',
      drill: spec,
    );

    expect(evaluation.applies, isFalse);
    expect(evaluation.tableRequired, isFalse);
  });
}

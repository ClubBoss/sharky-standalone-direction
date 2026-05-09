import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_spatial_projection_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_world9_seat_id_projection_contract_v1.dart';

void main() {
  test('world9 seatId contract requires one-based seat anchors', () {
    const spec = DrillSpecV1(
      id: 'find_seat_s4',
      kind: DrillKindV1.seatTap,
      prompt: 'Tap seat S4.',
      expected: DrillExpectedV1(seatId: 'S4'),
      errorClass: 'mismatch',
      playerCountV1: 7,
      heroSeatV1: 'btn',
      villainSeatV1: 'bb',
      activeSeatsV1: <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb'],
    );

    final evaluation = SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
      sessionId: 'w9.s02',
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: 'text_action_stack',
      drill: spec,
    );

    expect(evaluation.applies, isTrue);
    expect(evaluation.requiresSeatIdAnchors, isTrue);
    expect(
      evaluation.payloadFamily,
      kSessionDrillWorld9SeatIdProjectionPayloadFamilyV1,
    );
    expect(
      evaluation.materializedSeatIds,
      containsAll(const <String>['S1', 'S4', 'S7']),
    );
    expect(evaluation.hasMaterializedSeatIdAnchor, isTrue);
    expect(evaluation.hostGateSatisfied, isFalse);
    expect(
      evaluation.hostGateReasonCode,
      kSessionDrillSpatialProjectionHostGateReasonCodeV1,
    );
    expect(evaluation.hasRequiredScenePayload, isTrue);
  });

  test(
    'world9 seatId contract fails when expected anchor is not materializable',
    () {
      const spec = DrillSpecV1(
        id: 'find_seat_s8',
        kind: DrillKindV1.seatTap,
        prompt: 'Tap seat S8.',
        expected: DrillExpectedV1(seatId: 'S8'),
        errorClass: 'mismatch',
        playerCountV1: 7,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb'],
      );

      final evaluation = SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
        sessionId: 'w9.s02',
        hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
        layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
        drill: spec,
      );

      expect(evaluation.applies, isTrue);
      expect(evaluation.requiresSeatIdAnchors, isTrue);
      expect(evaluation.hasMaterializedSeatIdAnchor, isFalse);
      expect(evaluation.hasRequiredScenePayload, isFalse);
      expect(
        evaluation.payloadReasonCode,
        kSessionDrillSpatialProjectionMissingSceneReasonCodeV1,
      );
    },
  );

  test(
    'world4 seatId contract reuses one-based seat anchors on the canonical spatial path',
    () {
      const spec = DrillSpecV1(
        id: 'find_seat_s3',
        kind: DrillKindV1.seatTap,
        prompt: 'Tap seat S3.',
        expected: DrillExpectedV1(seatId: 'S3'),
        errorClass: 'mismatch',
        playerCountV1: 7,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb'],
      );

      final evaluation = SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
        sessionId: 'w4.s03',
        hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
        layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
        drill: spec,
      );

      expect(evaluation.applies, isTrue);
      expect(evaluation.requiresSeatIdAnchors, isTrue);
      expect(
        evaluation.payloadFamily,
        kSessionDrillWorld9SeatIdProjectionPayloadFamilyV1,
      );
      expect(
        evaluation.materializedSeatIds,
        containsAll(const <String>['S1', 'S3', 'S7']),
      );
      expect(evaluation.hasMaterializedSeatIdAnchor, isTrue);
      expect(evaluation.hasRequiredScenePayload, isTrue);
    },
  );

  test(
    'world9 role-only spatial drill stays on the base spatial payload family',
    () {
      const spec = DrillSpecV1(
        id: 'find_btn_profile',
        kind: DrillKindV1.seatTap,
        prompt: 'Tap BTN.',
        expected: DrillExpectedV1(role: 'btn'),
        errorClass: 'mismatch',
        playerCountV1: 7,
        heroSeatV1: 'btn',
        villainSeatV1: 'bb',
        activeSeatsV1: <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb'],
      );

      final evaluation = SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
        sessionId: 'w9.s01',
        hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
        layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
        drill: spec,
      );

      expect(evaluation.applies, isTrue);
      expect(evaluation.requiresSeatIdAnchors, isFalse);
      expect(evaluation.payloadFamily, 'seat_anchor_scene');
      expect(evaluation.hasRequiredScenePayload, isTrue);
    },
  );

  test('non-world4-world9 sessions stay outside the seatId contract', () {
    const spec = DrillSpecV1(
      id: 'find_btn',
      kind: DrillKindV1.seatTap,
      prompt: 'Tap BTN.',
      expected: DrillExpectedV1(role: 'btn'),
      errorClass: 'mismatch',
      playerCountV1: 7,
      heroSeatV1: 'btn',
      villainSeatV1: 'bb',
      activeSeatsV1: <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb'],
    );

    final evaluation = SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
      sessionId: 'w8.s01',
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
      drill: spec,
    );

    expect(evaluation.applies, isFalse);
    expect(evaluation.tableRequired, isFalse);
  });
}

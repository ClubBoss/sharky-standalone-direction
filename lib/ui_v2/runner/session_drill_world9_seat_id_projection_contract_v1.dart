import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_spatial_projection_contract_v1.dart';

const String kSessionDrillWorld9SeatIdProjectionPayloadFamilyV1 =
    'seat_id_anchor_scene';

class SessionDrillWorld9SeatIdProjectionContractEvaluationV1 {
  const SessionDrillWorld9SeatIdProjectionContractEvaluationV1({
    required this.applies,
    required this.tableRequired,
    required this.payloadFamily,
    required this.requiredSceneFields,
    required this.optionalSceneFields,
    required this.requiredLayoutFamily,
    required this.hostGateSatisfied,
    required this.hasRequiredScenePayload,
    required this.requiresSeatIdAnchors,
    required this.hasMaterializedSeatIdAnchor,
    required this.materializedSeatIds,
    this.hostGateReasonCode,
    this.payloadReasonCode,
  });

  final bool applies;
  final bool tableRequired;
  final String payloadFamily;
  final List<String> requiredSceneFields;
  final List<String> optionalSceneFields;
  final String requiredLayoutFamily;
  final bool hostGateSatisfied;
  final bool hasRequiredScenePayload;
  final bool requiresSeatIdAnchors;
  final bool hasMaterializedSeatIdAnchor;
  final List<String> materializedSeatIds;
  final String? hostGateReasonCode;
  final String? payloadReasonCode;
}

class SessionDrillWorld9SeatIdProjectionContractV1 {
  const SessionDrillWorld9SeatIdProjectionContractV1._();

  static SessionDrillWorld9SeatIdProjectionContractEvaluationV1 evaluate({
    required String sessionId,
    required String hostSurface,
    required String layoutFamily,
    required DrillSpecV1 drill,
  }) {
    final base = SessionDrillSpatialProjectionContractV1.evaluate(
      hostSurface: hostSurface,
      layoutFamily: layoutFamily,
      drill: drill,
    );
    if (!_supportsSessionIdV1(sessionId) || !base.applies) {
      return SessionDrillWorld9SeatIdProjectionContractEvaluationV1(
        applies: false,
        tableRequired: false,
        payloadFamily: 'not_applicable',
        requiredSceneFields: const <String>[],
        optionalSceneFields: const <String>[],
        requiredLayoutFamily:
            kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
        hostGateSatisfied: true,
        hasRequiredScenePayload: true,
        requiresSeatIdAnchors: false,
        hasMaterializedSeatIdAnchor: true,
        materializedSeatIds: const <String>[],
      );
    }

    final requiresSeatIdAnchors =
        drill.kind == DrillKindV1.seatTap && drill.expected.seatId != null;
    final materializedSeatIds = _materializedSeatIdsV1(drill);
    final hasMaterializedSeatIdAnchor =
        !requiresSeatIdAnchors ||
        materializedSeatIds.contains(drill.expected.seatId);
    final hasRequiredScenePayload =
        base.hasRequiredScenePayload && hasMaterializedSeatIdAnchor;

    return SessionDrillWorld9SeatIdProjectionContractEvaluationV1(
      applies: true,
      tableRequired: true,
      payloadFamily: requiresSeatIdAnchors
          ? kSessionDrillWorld9SeatIdProjectionPayloadFamilyV1
          : base.payloadFamily,
      requiredSceneFields: requiresSeatIdAnchors
          ? <String>[
              ...base.requiredSceneFields,
              'derived_one_based_seat_ids_v1',
            ]
          : base.requiredSceneFields,
      optionalSceneFields: base.optionalSceneFields,
      requiredLayoutFamily: base.requiredLayoutFamily,
      hostGateSatisfied: base.hostGateSatisfied,
      hasRequiredScenePayload: hasRequiredScenePayload,
      requiresSeatIdAnchors: requiresSeatIdAnchors,
      hasMaterializedSeatIdAnchor: hasMaterializedSeatIdAnchor,
      materializedSeatIds: materializedSeatIds,
      hostGateReasonCode: base.hostGateReasonCode,
      payloadReasonCode: hasRequiredScenePayload
          ? null
          : kSessionDrillSpatialProjectionMissingSceneReasonCodeV1,
    );
  }

  static List<String> materializedSeatIdsForDrillV1(DrillSpecV1 drill) {
    return _materializedSeatIdsV1(drill);
  }

  static bool _supportsSessionIdV1(String sessionId) {
    return sessionId.startsWith('w4.s') || sessionId.startsWith('w9.s');
  }

  static List<String> _materializedSeatIdsV1(DrillSpecV1 drill) {
    final seatContext = drill.scenarioSeatContextV1;
    if (seatContext == null) {
      return const <String>[];
    }
    final seatCount = [
      ...seatContext.activeSeatsV1,
      ...?seatContext.foldedSeatsV1,
      ...?seatContext.emptySeatsV1,
    ].length;
    if (seatCount <= 0) {
      return const <String>[];
    }
    return List<String>.generate(seatCount, (index) => 'S${index + 1}');
  }
}

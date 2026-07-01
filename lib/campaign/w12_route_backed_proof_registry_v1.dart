import 'package:poker_analyzer/campaign/w12_route_admission_contract_v1.dart';

const String kW12SourceRouteProofIdV1 = 'w12_source_route_proof_v1';

/// W12 route-backed proof descriptor.
///
/// The descriptor gives W12 a stable proof identity while preserving source
/// admission beats for the learner route. It does not imply W13, commercial
/// readiness, or public learning-effect readiness.
class W12RouteBackedProofV1 {
  const W12RouteBackedProofV1({
    required this.routeId,
    required this.worldId,
    required this.sessionId,
    required this.beats,
    required this.learnerVisible,
    required this.w11HandoffEnabled,
  });

  final String routeId;
  final String worldId;
  final String sessionId;
  final List<W12RouteAdmissionBeatV1> beats;
  final bool learnerVisible;
  final bool w11HandoffEnabled;
}

W12RouteBackedProofV1 buildW12RouteBackedProofV1(
  Iterable<W12RouteAdmissionBeatV1> beats,
) {
  final materializedBeats = List<W12RouteAdmissionBeatV1>.unmodifiable(beats);
  return W12RouteBackedProofV1(
    routeId: kW12SourceRouteProofIdV1,
    worldId: 'world12',
    sessionId: 'w12.s01',
    beats: materializedBeats,
    learnerVisible: true,
    w11HandoffEnabled: true,
  );
}

import 'dart:convert';

class Phase2CanonicalResolvedHostLaunchV1 {
  const Phase2CanonicalResolvedHostLaunchV1({
    required this.runId,
    required this.sessionStartLogged,
  });

  final String runId;
  final bool sessionStartLogged;
}

String generatePhase2CanonicalRunIdV1(DateTime now) {
  return now.toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
}

String buildPhase2CanonicalSessionStartPayloadV1(String runId, DateTime now) {
  return 'PHASE2_SESSION_START: ${jsonEncode(<String, String>{'run_id': runId, 'timestamp': now.toUtc().toIso8601String()})}';
}

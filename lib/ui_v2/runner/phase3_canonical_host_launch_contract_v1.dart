import 'dart:convert';

class Phase3CanonicalResolvedHostLaunchV1 {
  const Phase3CanonicalResolvedHostLaunchV1({
    required this.runId,
  });

  final String runId;
}

String generatePhase3CanonicalRunIdV1(DateTime now) {
  return now.toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
}

String buildPhase3CanonicalReturnSignalPayloadV1(String runId, DateTime now) {
  return 'PHASE3_RETURN_SIGNAL: ${jsonEncode(<String, String>{'run_id': runId, 'signal_type': 'engagement_return', 'timestamp': now.toUtc().toIso8601String()})}';
}

String buildPhase3CanonicalFlowEndPayloadV1(
  String runId,
  String result,
  DateTime now,
) {
  return 'PHASE3_FLOW_END: ${jsonEncode(<String, String>{'run_id': runId, 'result': result, 'timestamp': now.toUtc().toIso8601String()})}';
}

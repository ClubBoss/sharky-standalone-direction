class Phase1CanonicalResolvedHostLaunchV1 {
  const Phase1CanonicalResolvedHostLaunchV1({required this.runId});

  final String runId;
}

String generatePhase1CanonicalRunIdV1(DateTime now) {
  return now.toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
}

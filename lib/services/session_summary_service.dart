class SessionMetrics {
  const SessionMetrics({
    required this.accuracy,
    required this.averagePotEv,
    required this.timeSpentSeconds,
  });

  final double accuracy;
  final double averagePotEv;
  final int timeSpentSeconds;
}

/// Placeholder service for Stage Φ5-2.
class SessionSummaryService {
  SessionSummaryService._();

  static final SessionSummaryService instance = SessionSummaryService._();

  Future<SessionMetrics> fetchLastSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const SessionMetrics(
      accuracy: 0.82,
      averagePotEv: 3.4,
      timeSpentSeconds: 410,
    );
  }
}

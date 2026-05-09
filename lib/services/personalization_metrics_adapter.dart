import 'personalization_context.dart';

class PersonalizationMetricsAdapter {
  PersonalizationMetricsAdapter({
    this.rawDecisionMs,
    this.rawAccuracy,
    this.recentErrors,
    this.timestamp,
  });

  final double? rawDecisionMs;
  final double? rawAccuracy;
  final int? recentErrors;
  final DateTime? timestamp;

  UserSessionMetrics toSessionMetrics() {
    return UserSessionMetrics(
      decisionMs: rawDecisionMs,
      accuracy: rawAccuracy,
      errorBurst: recentErrors != null && recentErrors! > 3,
      styleHint: null,
    );
  }
}

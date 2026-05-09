class UserSessionMetrics {
  const UserSessionMetrics({
    this.decisionMs,
    this.accuracy,
    this.errorBurst,
    this.styleHint,
  });

  final double? decisionMs;
  final double? accuracy;
  final bool? errorBurst;
  final String? styleHint;
}

class PersonalizationContext {
  const PersonalizationContext({
    this.decisionSpeed,
    this.accuracyTrend,
    this.errorBurstFlag,
    this.styleTag,
  });

  final double? decisionSpeed;
  final double? accuracyTrend;
  final bool? errorBurstFlag;
  final String? styleTag;
}

class PersonalizationContextProvider {
  const PersonalizationContextProvider._();

  static PersonalizationContext build({required UserSessionMetrics metrics}) {
    final normalizedAccuracy = metrics.accuracy?.clamp(0.0, 1.0);
    return PersonalizationContext(
      decisionSpeed: metrics.decisionMs,
      accuracyTrend: normalizedAccuracy == null
          ? null
          : (normalizedAccuracy * 2.0) - 1.0,
      errorBurstFlag: metrics.errorBurst,
      styleTag: metrics.styleHint,
    );
  }
}

class PersonalizationRules {
  /// Placeholder values so analyzer sees initialized state.
  final Object statePlaceholder;
  final String profilePlaceholder;

  const PersonalizationRules({
    this.statePlaceholder = const Object(),
    this.profilePlaceholder = '',
  });

  // rule evaluation API (placeholders only)
  String evaluateProfileRule() => '';
  String evaluateAdjustmentRule() => '';
  String evaluateReinforcementRule() => '';
  String evaluateTimingRule() => '';

  // application API (placeholders only)
  void applyProfileRule() {}
  void applyAdjustmentRule() {}
  void applyReinforcementRule() {}
  void applyTimingRule() {}
}

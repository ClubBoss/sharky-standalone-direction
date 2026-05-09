import '../persona/profile/persona_profile_model_v1.dart';

String? buildSRPromptOrNull(PersonaProfileModelV1? model) {
  if (model == null) return null;
  if (model.shortSummary.contains('ICM') ||
      model.shortSummary.contains('bubble')) {
    return 'risk_premium_alert';
  }
  if (model.shortSummary.contains('range') ||
      model.staticTraits.values.any((t) => t.contains('focus'))) {
    return 'focus_leak';
  }
  return 'stack_pressure';
}

String? buildSRHintOrNull(PersonaProfileModelV1? model) {
  if (model == null) return null;
  if (model.aiInsights.values.any((insight) => insight.contains('tight'))) {
    return 'loosen_vs_pressure';
  }
  if (model.staticTraits.values.any((trait) => trait.contains('aggressive'))) {
    return 'hold_tight';
  }
  return 'watch_stack';
}

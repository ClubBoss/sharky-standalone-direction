enum PersonalizationNextAction { repeat_phase1, run_phase2, run_phase3, idle }

class PersonalizationRecommendation {
  final PersonalizationNextAction action;
  final String reason;

  const PersonalizationRecommendation({
    required this.action,
    required this.reason,
  });
}

PersonalizationRecommendation recommend({
  Map<String, Object?>? phase1,
  Map<String, Object?>? phase2,
  Map<String, Object?>? phase3,
}) {
  bool _isOk(Map<String, Object?>? payload) => payload?['ok'] == true;

  if (phase1 != null && phase1['ok'] == false) {
    return const PersonalizationRecommendation(
      action: PersonalizationNextAction.repeat_phase1,
      reason: 'phase1_summary_v1 reported ok=false',
    );
  }
  if (phase2 != null && phase2['ok'] == false) {
    return const PersonalizationRecommendation(
      action: PersonalizationNextAction.run_phase2,
      reason: 'phase2_summary_v1 reported ok=false',
    );
  }
  if (phase3 != null && phase3['ok'] == false) {
    return const PersonalizationRecommendation(
      action: PersonalizationNextAction.run_phase3,
      reason: 'phase3_summary_v1 reported ok=false',
    );
  }
  if (phase1 == null) {
    return const PersonalizationRecommendation(
      action: PersonalizationNextAction.idle,
      reason: 'phase1_summary_v1 missing',
    );
  }
  if (phase2 == null) {
    return const PersonalizationRecommendation(
      action: PersonalizationNextAction.run_phase2,
      reason: 'phase2_summary_v1 missing',
    );
  }
  if (phase3 == null) {
    return const PersonalizationRecommendation(
      action: PersonalizationNextAction.run_phase3,
      reason: 'phase3_summary_v1 missing',
    );
  }
  return const PersonalizationRecommendation(
    action: PersonalizationNextAction.idle,
    reason: 'all available phases reported ok',
  );
}

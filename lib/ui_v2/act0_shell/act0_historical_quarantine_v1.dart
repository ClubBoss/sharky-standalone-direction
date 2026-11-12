// Quarantined historical cohort: restored source identity is not poker admission.
// No private vocabulary migration or W4 registry is production-bound here.
bool act0IsUnresolvedHistoricalW1TaskV1(String taskId) => const <String>{
  'actions_theory',
  'actions_fold_drill',
  'actions_call_drill',
  'actions_raise_drill',
  'actions_review',
}.contains(taskId);

/// Display-only summary for a pending hand-ranking assessment.
///
/// Authored captions may contain the winning hand. Preserve them for source
/// provenance and post-decision teaching; never mutate the underlying task.
const String act0NeutralHandRankingSummaryV1 =
    'Study the cards and make your choice before seeing the explanation.';

String act0PrechoiceTaskSummaryCopyV1({
  required String taskId,
  required String authoredSummary,
  required bool isAssessment,
  required bool hasSubmittedCurrentDecision,
}) {
  if (isAssessment &&
      !hasSubmittedCurrentDecision &&
      taskId.startsWith('hand_rankings_')) {
    return act0NeutralHandRankingSummaryV1;
  }
  return authoredSummary;
}

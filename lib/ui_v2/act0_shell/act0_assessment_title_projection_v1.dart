/// A presentation-only title for a pending hand-ranking decision.
///
/// Keep authored task titles intact for source IDs, receipts, history and
/// post-decision teaching. Apply this only to the current assessment display
/// (Academy entry and Runner), not to the source model or any fingerprint.
const String act0NeutralHandRankingTitleV1 = 'Hand ranking question';

String act0PrechoiceTaskTitleV1({
  required String taskId,
  required String authoredTitle,
  required bool isAssessment,
  required bool hasSubmittedCurrentDecision,
}) {
  if (isAssessment &&
      !hasSubmittedCurrentDecision &&
      taskId.startsWith('hand_rankings_')) {
    return act0NeutralHandRankingTitleV1;
  }
  return authoredTitle;
}

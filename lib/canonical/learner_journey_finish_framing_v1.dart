String learnerJourneyReviewSurfaceTitleV1() => 'Review target';

String learnerJourneyReviewTargetReasonLineV1({
  required String weaknessLabel,
  required String reviewGoal,
}) {
  return 'Review target: $weaknessLabel. Goal: $reviewGoal';
}

String learnerJourneyReviewQueueValueTextV1({required bool reviewRequired}) {
  return reviewRequired
      ? 'Review missed spots before the next lesson.'
      : 'Quick review: refresh missed spots before the next lesson.';
}

String learnerJourneyReviewQueueHeadlineTextV1({required bool reviewRequired}) {
  return reviewRequired
      ? 'Up next: Review missed spots'
      : 'Quick review before the next lesson';
}

String learnerJourneyReviewQueueWhyLineV1({required bool reviewRequired}) {
  return 'Why: ${learnerJourneyReviewQueueValueTextV1(reviewRequired: reviewRequired)}';
}

String learnerJourneyReviewQueueSummaryTextV1({required bool reviewRequired}) {
  return reviewRequired
      ? 'Review before the next lesson'
      : 'Quick review before the next lesson';
}

String learnerJourneyNextLessonReadyTextV1(String nextProgressLabel) {
  return 'Next lesson ready: $nextProgressLabel.';
}

String learnerJourneyBackToMapForNextLessonTextV1() {
  return 'Back to the map when you are ready for the next lesson.';
}

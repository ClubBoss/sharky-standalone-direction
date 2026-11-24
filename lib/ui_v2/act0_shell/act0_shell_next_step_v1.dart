enum Act0ShellNextStepV1 {
  repair,
  dueReview,
  resumeLesson,
  requiredPractice,
  lesson,
  courseComplete;

  static Act0ShellNextStepV1 resolve({
    required int repairs,
    required int dueReviews,
    required bool hasResume,
    required bool requiresPractice,
    required bool courseComplete,
  }) {
    if (repairs > 0) return repair;
    if (dueReviews > 0) return dueReview;
    if (hasResume) return resumeLesson;
    if (requiresPractice) return requiredPractice;
    return courseComplete ? Act0ShellNextStepV1.courseComplete : lesson;
  }
}

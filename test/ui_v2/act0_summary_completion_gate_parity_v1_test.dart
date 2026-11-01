import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

// These are ordinary English iPhone 14 Pro learning-route semantics.
// Completing the curriculum is not the same claim as 80% independent accuracy.
Act0BlockCompletionSummaryV1 _receipt({
  required bool lessonCompleted,
  int correct = 3,
  int errors = 1,
  bool provenanceKnown = true,
  bool safeReview = false,
  int deepLeaks = 0,
}) => Act0BlockCompletionSummaryV1(
  lessonTitle: 'First Table Guide',
  xpEarned: 0,
  errorCount: errors,
  taskCount: 4,
  correctCount: correct,
  independentProvenanceKnown: provenanceKnown,
  curriculumLessonCompleted: lessonCompleted,
  startLevel: 1,
  endLevel: 1,
  startXp: 0,
  endXp: 0,
  xpTarget: 100,
  nextLessonTitle: 'Blinds and actions',
  hasSafeReviewTarget: safeReview,
  deepLeakCount: deepLeaks,
);

void main() {
  test('all authored tasks completed, 75% first-read: next path stays open', () {
    final result = _receipt(lessonCompleted: true);
    expect(result.accuracyPercent, 75);
    expect(result.hasScoredPracticeGap, isTrue);
    expect(result.qualifiesForNextLesson, isTrue);
    expect(result.milestoneTitle, 'Lesson complete');
    expect(result.masteryStatus, Act0MasteryStatusV1.needsReview);
    expect(result.masteryStatus, isNot(Act0MasteryStatusV1.cleanPass));
    expect(result.primaryCtaKind, Act0MilestoneCtaKindV1.continueForward);
    expect(result.primaryCtaLabel, 'Open next lesson');
    expect(result.gateMessage, contains('first answers still need practice'));
    expect(result.gateMessage, contains('is available'));
    expect(result.suggestedNextAction, contains('replay this lesson'));
  });

  test('incomplete lesson below threshold does not get free completion', () {
    final result = _receipt(lessonCompleted: false);
    expect(result.accuracyPercent, 75);
    expect(result.qualifiesForNextLesson, isFalse);
    expect(result.milestoneTitle, 'Almost there - replay to unlock');
    expect(result.primaryCtaKind, Act0MilestoneCtaKindV1.replayForPerfect);
    expect(result.masteryStatus, isNot(Act0MasteryStatusV1.cleanPass));
  });

  test('source-backed open repair is preferred, without locking forward', () {
    final result = _receipt(
      lessonCompleted: true,
      safeReview: true,
      deepLeaks: 1,
    );
    expect(result.qualifiesForNextLesson, isTrue);
    expect(result.primaryCtaKind, Act0MilestoneCtaKindV1.reviewFirst);
    expect(result.primaryCtaLabel, 'Review first');
    expect(result.secondaryCtaKind, Act0MilestoneCtaKindV1.continueForward);
    expect(result.secondaryCtaLabel, 'Open next lesson');
    expect(result.gateMessage, contains('Review'));
    expect(result.gateMessage, contains('unlocked'));
  });

  test('legacy completed with no surviving scored evidence stays unverified', () {
    final result = _receipt(
      lessonCompleted: true,
      correct: 0,
      errors: 0,
      provenanceKnown: false,
    );
    expect(result.qualifiesForNextLesson, isTrue);
    expect(result.hasScoredPracticeGap, isFalse);
    expect(result.milestoneTitle, 'Lesson complete');
    expect(result.masteryStatus, Act0MasteryStatusV1.learning);
    expect(result.gateMessage, contains('evidence is unavailable'));
    expect(result.gateMessage, isNot(contains('Clean finish')));
    expect(result.primaryCtaLabel, 'Open next lesson');
  });

  test('clean first pass remains independently proven, without changed XP', () {
    final result = _receipt(
      lessonCompleted: true,
      correct: 4,
      errors: 0,
    );
    expect(result.accuracyPercent, 100);
    expect(result.hasScoredPracticeGap, isFalse);
    expect(result.qualifiesForNextLesson, isTrue);
    expect(result.masteryStatus, Act0MasteryStatusV1.cleanPass);
    expect(result.milestoneTitle, 'Lesson complete');
    expect(result.xpEarned, 0);
    expect(result.primaryCtaLabel, 'Open next lesson');
  });
}

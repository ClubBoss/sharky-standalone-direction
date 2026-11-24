import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_next_step_v1.dart';
import 'package:test/test.dart';

void main() {
  test('repairs lead when spaced reviews and a saved lesson are also due', () {
    expect(
      Act0ShellNextStepV1.resolve(
        repairs: 1,
        dueReviews: 2,
        hasResume: true,
        requiresPractice: true,
        courseComplete: false,
      ),
      Act0ShellNextStepV1.repair,
    );
  });

  test('spaced review takes priority after course completion', () {
    expect(
      Act0ShellNextStepV1.resolve(
        repairs: 0,
        dueReviews: 1,
        hasResume: false,
        requiresPractice: false,
        courseComplete: true,
      ),
      Act0ShellNextStepV1.dueReview,
    );
  });

  for (final (resume, practice, complete, expected) in [
    (true, true, false, Act0ShellNextStepV1.resumeLesson),
    (false, true, false, Act0ShellNextStepV1.requiredPractice),
    (false, false, false, Act0ShellNextStepV1.lesson),
    (false, false, true, Act0ShellNextStepV1.courseComplete),
  ]) {
    test('resolves $expected with no due work', () {
      expect(
        Act0ShellNextStepV1.resolve(
          repairs: 0,
          dueReviews: 0,
          hasResume: resume,
          requiresPractice: practice,
          courseComplete: complete,
        ),
        expected,
      );
    });
  }
}

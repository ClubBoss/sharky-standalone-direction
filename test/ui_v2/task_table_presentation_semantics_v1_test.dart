import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test(
    'only the two source-owned Action tasks opt into table presentation',
    () {
      final lesson = Act0ShellStateV1.sample.lessonById(
        'fold_check_call_raise',
      );
      final byId = {for (final task in lesson.taskList) task.taskId: task};
      expect(
        byId['actions_theory']!.tablePresentation,
        Act0TaskTablePresentationV1.spatialTheory,
      );
      expect(
        byId['actions_check_drill']!.tablePresentation,
        Act0TaskTablePresentationV1.stablePractice,
      );
      expect(
        byId['actions_legal_context']!.tablePresentation,
        Act0TaskTablePresentationV1.legacy,
      );
    },
  );

  test('presentation semantics reach the active runner owner', () {
    final task = Act0ShellStateV1.sample
        .lessonById('fold_check_call_raise')
        .taskList
        .firstWhere((candidate) => candidate.taskId == 'actions_theory');
    final runner = Act0LessonRunnerShellV1(
      runner: task.runner,
      tablePresentation: task.tablePresentation,
      onBack: () {},
      onContinueTheory: () {},
      onChooseOption: (_) {},
      onContinueReview: () {},
    );

    expect(runner.tablePresentation, Act0TaskTablePresentationV1.spatialTheory);
  });
}

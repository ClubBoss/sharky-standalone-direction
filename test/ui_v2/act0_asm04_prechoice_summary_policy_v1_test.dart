import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_assessment_summary_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  final lesson = Act0ShellStateV1.sample.lessons.singleWhere(
    (lesson) => lesson.lessonId == 'hand_rankings_table',
  );
  final tasks = lesson.taskList;

  test('hand-ranking Academy summaries are neutral before the decision', () {
    const knownLeadingIds = <String>{
      'hand_rankings_pair_drill',
      'hand_rankings_trips_drill',
      'hand_rankings_straight_drill',
      'hand_rankings_flush_drill',
      'hand_rankings_full_house_drill',
      'hand_rankings_quads_drill',
      'hand_rankings_royal_flush_drill',
      'hand_rankings_full_house_vs_flush_drill',
      'hand_rankings_quads_vs_full_house_drill',
      'hand_rankings_royal_vs_flush_drill',
    };
    final assessed = tasks.where((task) => task.runner.options.isNotEmpty);
    expect(
      assessed.map((task) => task.taskId).toSet(),
      containsAll(knownLeadingIds),
    );

    for (final task in assessed) {
      final original = task.summary ?? task.runner.caption;
      expect(
        act0PrechoiceTaskSummaryCopyV1(
          taskId: task.taskId,
          authoredSummary: original,
          isAssessment: true,
          hasSubmittedCurrentDecision: false,
        ),
        act0NeutralHandRankingSummaryV1,
        reason: task.taskId,
      );
      expect(
        act0PrechoiceTaskSummaryCopyV1(
          taskId: task.taskId,
          authoredSummary: original,
          isAssessment: true,
          hasSubmittedCurrentDecision: true,
        ),
        original,
        reason: 'post-choice source: ${task.taskId}',
      );
      expect(task.summary ?? task.runner.caption, original);
    }
  });

  test('unassessed theory and unrelated tasks retain authored copy', () {
    final theory = tasks.singleWhere(
      (task) => task.taskId == 'hand_rankings_theory',
    );
    final original = theory.summary ?? theory.runner.caption;
    expect(
      act0PrechoiceTaskSummaryCopyV1(
        taskId: theory.taskId,
        authoredSummary: original,
        isAssessment: false,
        hasSubmittedCurrentDecision: false,
      ),
      original,
    );
    expect(
      act0PrechoiceTaskSummaryCopyV1(
        taskId: 'actions_facing_bet',
        authoredSummary: 'Choose a legal action.',
        isAssessment: true,
        hasSubmittedCurrentDecision: false,
      ),
      'Choose a legal action.',
    );
  });
}

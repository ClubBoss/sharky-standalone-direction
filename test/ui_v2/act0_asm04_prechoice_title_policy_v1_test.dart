import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_assessment_title_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  final lesson = Act0ShellStateV1.sample.lessons.singleWhere(
    (lesson) => lesson.lessonId == 'hand_rankings_table',
  );
  final tasks = lesson.taskList;

  test('all authored hand-ranking choices have neutral pending titles', () {
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
    final assessedTasks = tasks
        .where((task) => task.runner.options.isNotEmpty)
        .toList();
    expect(
      assessedTasks.map((task) => task.taskId).toSet(),
      containsAll(knownLeadingIds),
    );
    for (final task in assessedTasks) {
      expect(
        act0PrechoiceTaskTitleV1(
          taskId: task.taskId,
          authoredTitle: task.title,
          isAssessment: true,
          hasSubmittedCurrentDecision: false,
        ),
        act0NeutralHandRankingTitleV1,
        reason: task.taskId,
      );
    }
  });

  test('display projection leaves sources and post-choice teaching intact', () {
    final pair = tasks.singleWhere(
      (task) => task.taskId == 'hand_rankings_pair_drill',
    );
    expect(pair.title, 'Find the pair');
    expect(
      pair.runner.options.map((option) => option.label),
      containsAll(<String>['Pair', 'High card']),
    );
    expect(
      act0PrechoiceTaskTitleV1(
        taskId: pair.taskId,
        authoredTitle: pair.title,
        isAssessment: true,
        hasSubmittedCurrentDecision: true,
      ),
      pair.title,
    );
    expect(
      act0PrechoiceTaskTitleV1(
        taskId: 'hand_rankings_theory',
        authoredTitle: 'Hands use five cards',
        isAssessment: false,
        hasSubmittedCurrentDecision: false,
      ),
      'Hands use five cards',
    );
    expect(
      act0PrechoiceTaskTitleV1(
        taskId: 'actions_facing_bet',
        authoredTitle: 'Call or raise',
        isAssessment: true,
        hasSubmittedCurrentDecision: false,
      ),
      'Call or raise',
    );
  });
}

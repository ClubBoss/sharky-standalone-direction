import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  const cases = <({String worldId, String lessonId, String taskId, String expectedHint})>[
    (
      worldId: 'world_1',
      lessonId: 'cards_ranks_suits',
      taskId: 'cards_ranks_suits_rank_drill',
      expectedHint: 'Compare the ranks on the named cards in deck order.',
    ),
    (
      worldId: 'world_1',
      lessonId: 'cards_ranks_suits',
      taskId: 'cards_ranks_suits_suit_drill',
      expectedHint:
          'Match the suit symbol or letter on the named card to the suit key.',
    ),
    (
      worldId: 'world_2',
      lessonId: 'hand_discipline_buckets',
      taskId: 'hand_discipline_buckets_premium',
      expectedHint:
          'Read your two cards first. Match the ranks and suits to the chart.',
    ),
    (
      worldId: 'world_4',
      lessonId: 'call_price',
      taskId: 'w4_good_price_call',
      expectedHint:
          'Use the visible pot and the amount you would add to find the required chance.',
    ),
    (
      worldId: 'world_4',
      lessonId: 'small_half_pot',
      taskId: 'w4_pot_bet',
      expectedHint: 'Count only chips that are actually in the pot or matched.',
    ),
    (
      worldId: 'world_1',
      lessonId: 'blinds_action_order',
      taskId: 'positions_button',
      expectedHint: 'Start from the button, then follow seat order.',
    ),
    (
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_check_drill',
      expectedHint: 'Name the action before choosing what it means.',
    ),
  ];
  for (final scenario in cases) {
    testWidgets(
      'representative ' + scenario.taskId + ' hint follows task subject',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final task = Act0ShellStateV1.sample
            .worldById(scenario.worldId)
            .lessons
            .firstWhere((lesson) => lesson.lessonId == scenario.lessonId)
            .taskList
            .firstWhere((task) => task.taskId == scenario.taskId);
        await tester.pumpWidget(
          MaterialApp(
            home: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                // Drive the real position prompt through the answer-list hint
                // surface; the original position task uses seat targeting.
                options: scenario.taskId == 'positions_button'
                    ? Act0ShellStateV1.sample
                          .worldById('world_1')
                          .lessons
                          .firstWhere(
                            (lesson) =>
                                lesson.lessonId == 'fold_check_call_raise',
                          )
                          .taskList
                          .firstWhere(
                            (task) => task.taskId == 'actions_check_drill',
                          )
                          .runner
                          .options
                    : task.runner.options,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedWorldId: scenario.worldId,
              selectedLessonId: scenario.lessonId,
              selectedTaskId: scenario.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              theoryRecallStep: const Act0TeachingStepV1(
                title: 'Recall the principle',
                body: 'Read the visible table information.',
              ),
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
        expect(hint, findsOneWidget);
        await tester.ensureVisible(hint);
        final hintTapTarget = tester.getSize(hint);
        expect(
          hintTapTarget.width,
          greaterThanOrEqualTo(44),
          reason: 'hint must have a finger-safe tap target',
        );
        expect(
          hintTapTarget.height,
          greaterThanOrEqualTo(44),
          reason: 'hint must have a finger-safe tap target',
        );
        await tester.tap(hint);
        await tester.pumpAndSettle();
        expect(find.text(scenario.expectedHint), findsOneWidget);
        final close = find.byKey(
          const Key('act0_shell_theory_recall_close_cta'),
        );
        expect(close, findsOneWidget);
        expect(
          tester.getSize(close).height,
          greaterThanOrEqualTo(44),
          reason: 'hint sheet must provide a usable way back',
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _miss = Act0MistakeCardV1(
  taskId: 'actions_check_drill',
  lessonId: 'fold_check_call_raise',
  title: 'No bet yet',
  weaknessLabel: 'Action read',
  selectedOptionId: 'bet',
  selectedLabel: 'Bet',
  betterLabel: 'Check',
  reason: 'No prior bet meant checking was allowed.',
  attempts: 1,
);

Act0DueReviewItemV1 _due(String taskId, {int lapses = 0}) =>
    Act0DueReviewItemV1(
      conceptFamilyId: 'action_read',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: taskId,
      nextDueAtUtc: DateTime.utc(2026, 10, 11),
      repeatedMissCount: 1,
      lapseCount: lapses,
    );

Future<List<Act0DueReviewItemV1>> _pump(
  WidgetTester tester, {
  required List<Act0MistakeCardV1> mistakes,
  required Act0DueReviewItemV1 due,
}) async {
  final started = <Act0DueReviewItemV1>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0ReviewShellV1(
          review: Act0ReviewStateV1(
            title: 'Review',
            subtitle: '',
            weaknessLabel: 'Action read',
            reason: '',
            stats: const <Act0ReviewStatV1>[],
            chosenLabel: 'Bet',
            betterLabel: 'Check',
            mistakes: mistakes,
          ),
          selected: null,
          onSelected: (_) {},
          onFixMistake: (_) {},
          dueReviewItems: <Act0DueReviewItemV1>[due],
          onStartDueReview: started.add,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return started;
}

void main() {
  testWidgets(
    'due recheck stays reachable beside an open mistake (same task)',
    (tester) async {
      final started = await _pump(
        tester,
        mistakes: const [_miss],
        due: _due('actions_check_drill'),
      );
      expect(
        find.text('Scheduled recheck · mistake still open'),
        findsOneWidget,
      );
      expect(
        find.text('A repaired clue is due for a spaced review.'),
        findsNothing,
      );
      expect(find.text('Repair with guidance'), findsOneWidget);
      await tester.tap(find.text('Check independently now'));
      expect(started.single.taskId, 'actions_check_drill');
    },
  );

  testWidgets('due recheck for another task is not called the open mistake', (
    tester,
  ) async {
    await _pump(
      tester,
      mistakes: const [_miss],
      due: _due('actions_call_drill'),
    );
    expect(
      find.text(
        'This scheduled recheck is for another task, separate from the open mistake below.',
      ),
      findsOneWidget,
    );
    expect(find.text('Practice this spot'), findsOneWidget);
  });

  testWidgets('no open mistake keeps the original due copy', (tester) async {
    await _pump(tester, mistakes: const [], due: _due('actions_check_drill'));
    expect(find.text('Ready to recheck'), findsOneWidget);
    expect(find.text('Review now'), findsOneWidget);
  });
}

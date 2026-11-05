import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  for (final scenario in <({String task, String selected, String expected})>[
    (
      task: 'actions_fold_drill',
      selected: 'call',
      expected: 'You chose Call 2 BB; better was Fold.',
    ),
    (
      task: 'actions_fold_drill',
      selected: 'raise',
      expected: 'You chose Raise 6 BB; better was Fold.',
    ),
    (
      task: 'actions_call_drill',
      selected: 'raise',
      expected: 'You chose Raise 4 BB; better was Call 1 BB.',
    ),
    (
      task: 'actions_call_drill',
      selected: 'fold',
      expected: 'You chose Fold; better was Call 1 BB.',
    ),
  ]) {
    test(
      'saved ${scenario.task}/${scenario.selected} retains authored amounts',
      () {
        final history = _mistake(scenario.task, scenario.selected);
        final saved = history.toStorageString();
        final restored = Act0ReviewMistakeHistoryV1.tryParseStorageString(
          saved,
        )!;
        final item = _consume(restored).items.single;

        expect(item.decisionLine, scenario.expected);
        expect(restored.toStorageString(), saved);
        expect(item.stableKey, history.records.single.recordId);
        expect(item.sourceTaskId, scenario.task);
      },
    );
  }

  test(
    'amounts require the exact authored task, never the action ID alone',
    () {
      final history = _mistake('actions_fold_drill', 'call');
      expect(
        Act0ReviewMistakeHistoryConsumerV1.fromHistory(
          history,
        ).items.single.decisionLine,
        'You chose call; better was fold.',
      );
      final record = history.records.single;
      final unknown = Act0ReviewMistakeRecordV1.tryParse({
        ...record.toPayload(),
        'decisionTaskId': 'missing_authored_task',
      })!;
      expect(
        _consume(
          Act0ReviewMistakeHistoryV1(records: [unknown]),
        ).items.single.decisionLine,
        'You chose call; better was fold.',
      );
    },
  );

  test('plain seat labels stay unchanged', () {
    final history = _mistake('positions_button', 'co', lesson: 'positions');
    expect(
      _consume(history).items.single.decisionLine,
      'You chose CO; better was BTN.',
    );
  });

  testWidgets(
    'Review renders restored wager amounts on the EN 14 Pro surface',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final restored = Act0ReviewMistakeHistoryV1.tryParseStorageString(
        _mistake('actions_call_drill', 'raise').toStorageString(),
      )!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ReviewShellV1(
              review: Act0ShellStateV1.sample.review,
              selected: null,
              onSelected: (_) {},
              mistakeHistoryItems: _consume(restored).items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final line = find.text('You chose Raise 4 BB; better was Call 1 BB.');
      await tester.scrollUntilVisible(line, 300);
      expect(line, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Act0ReviewMistakeHistoryConsumerV1 _consume(
  Act0ReviewMistakeHistoryV1 history,
) => Act0ReviewMistakeHistoryConsumerV1.fromHistory(
  history,
  sourceState: Act0ShellStateV1.sample,
);

Act0ReviewMistakeHistoryV1 _mistake(
  String taskId,
  String selectedId, {
  String lesson = 'fold_check_call_raise',
}) {
  final task = Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .firstWhere((value) => value.lessonId == lesson)
      .taskList
      .firstWhere((value) => value.taskId == taskId);
  final selected = task.runner.options.firstWhere(
    (value) => value.id == selectedId,
  );
  final expected = task.runner.options.singleWhere(
    act0RunnerOptionIsAuthoredCorrectV1,
  );
  expect(selected.isCorrect, isFalse);
  return const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
    Act0CompletedDecisionV1(
      attemptKey: 'history-amount|$taskId|$selectedId',
      worldId: 'world_1',
      lessonId: lesson,
      taskId: taskId,
      sourceTaskId: taskId,
      decisionKind: lesson == 'positions'
          ? Act0CompletedDecisionKindV1.seat
          : Act0CompletedDecisionKindV1.actionList,
      selectedId: selected.id,
      expectedId: expected.id,
      isCorrect: false,
      decisionTimeBucket: 'under_3s',
      taskFamily: task.resolvedTaskFamily,
      resultKind: 'incorrect',
      errorType: 'missed_action_read',
      skillAtomId: 'action_read',
      repairFocusId: 'no_bet_yet',
    ),
  );
}

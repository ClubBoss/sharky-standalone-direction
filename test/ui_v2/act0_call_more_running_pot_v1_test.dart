import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0LessonTaskV1 get _authoredTask => Act0ShellStateV1.sample
    .lessonById('your_first_hand')
    .taskList
    .singleWhere((task) => task.taskId == 'your_first_hand_action_trail');

void main() {
  test('authored BB call adds two more to the posted one, for pot 7.5', () {
    final table = _authoredTask.runner.table;
    expect(table.actionTrail[1].label, 'BB blind 1 BB');
    expect(table.actionTrail[5].label, 'BTN raises to 3 BB');
    expect(table.actionTrail[7].label, 'BB calls 2 BB more');
    expect(table.potLabel, 'Pot 7.5 BB');
    expect(act0CalcTableTrailPotV1(table, 6).potBb, 5.5);
    expect(act0CalcTableTrailPotV1(table, 7).potBb, 7.5);
    expect(act0CalcTableTrailPotV1(table, 9).potBb, 7.5);
  });

  test(
    'all eight unchanged authored first-hand trails reconcile to pot 7.5',
    () {
      final tasks = Act0ShellStateV1.sample
          .lessonById('your_first_hand')
          .taskList;
      expect(tasks, hasLength(8));
      for (final task in tasks) {
        final table = task.runner.table;
        expect(
          act0CalcTableTrailPotV1(table, table.actionTrail.length - 1).potBb,
          7.5,
          reason: task.taskId,
        );
      }
    },
  );

  test(
    'explicit call, calls and called more forms add to the prior commitment',
    () {
      final prefix = _authoredTask.runner.table.actionTrail
          .take(7)
          .map((i) => i.label)
          .toList();
      for (final verb in ['call', 'calls', 'called']) {
        final trail = [...prefix, 'BB $verb 2 BB more'];
        expect(
          act0CalcTrailPotV1(trail, trail.length - 1).potBb,
          7.5,
          reason: verb,
        );
      }
    },
  );

  test(
    'unqualified call totals and raise-to totals retain their semantics',
    () {
      final prefix = _authoredTask.runner.table.actionTrail
          .take(7)
          .map((i) => i.label)
          .toList();
      expect(act0CalcTrailPotV1([...prefix, 'BB calls 2 BB'], 7).potBb, 6.5);
      expect(act0CalcTrailPotV1([...prefix, 'BB calls 3 BB'], 7).potBb, 7.5);
      expect(
        act0CalcTrailPotV1([...prefix, 'BB raises to 6 BB'], 7).potBb,
        10.5,
      );
    },
  );

  test('a later-street call-more starts from that street commitment only', () {
    final preflop = _authoredTask.runner.table.actionTrail
        .take(9)
        .map((i) => i.label)
        .toList();
    final trail = [
      ...preflop,
      'Flop: BB bets 2 BB',
      'BTN raises to 6 BB',
      'BB calls 4 BB more',
      'Turn: BB checks',
    ];
    final result = act0CalcTrailPotV1(trail, trail.length - 1);
    expect(result.potBb, 19.5);
    expect(result.street, 'Turn');
  });

  test(
    'typed notes and original cutoffs never create an extra contribution',
    () {
      final source = _authoredTask.runner.table;
      final trail = [...source.actionTrail];
      trail.insert(
        7,
        const Act0ActionTrailItemV1.note(label: 'BB calls 900 BB more'),
      );
      final table = source.copyWith(actionTrail: trail);
      expect(act0CalcTableTrailPotV1(table, 7).potBb, 5.5);
      expect(act0CalcTableTrailPotV1(table, 8).potBb, 7.5);
    },
  );

  test('missing opening small blind still fails closed', () {
    final result = act0CalcTrailPotV1([
      'BB blind 1 BB',
      'BB calls 2 BB more',
    ], 1);
    expect(result.potBb, -1);
    expect(result.street, isEmpty);
  });
}

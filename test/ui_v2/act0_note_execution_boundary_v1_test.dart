import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

Act0LessonTaskV1 _task(String id) => [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons) ...lesson.taskList,
].singleWhere((task) => task.taskId == id);

Act0TableStateV1 _table(List<Act0ActionTrailItemV1> trail) =>
    _task('w4_bluff_pressure').runner.table.copyWith(actionTrail: trail);

void main() {
  test('ordinary blind and raise trail keeps its computed pot', () {
    const trail = [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'CO raises 2.5 BB'),
    ];

    final result = act0CalcTableTrailPotV1(_table(trail), trail.length - 1);

    expect(result.potBb, 4.0);
    expect(result.street, 'Preflop');
  });

  test('leading and mid-trail notes do not alter pot or source indexes', () {
    const trail = [
      Act0ActionTrailItemV1.note(label: 'Blinds: 1.5 BB'),
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1.note(label: 'Hero shoves 999 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'CO raises 2.5 BB'),
    ];
    final result = act0CalcTableTrailPotV1(_table(trail), 4);

    expect(result.potBb, 4.0);
    expect(result.street, 'Preflop');
    // Cutoff remains the original actionTrail index despite two note slots.
    expect(act0CalcTableTrailPotV1(_table(trail), 3).potBb, 1.5);
  });

  test('note with River bet wording cannot create an action or street', () {
    const trail = [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'CO raises 2.5 BB'),
      Act0ActionTrailItemV1(label: 'BTN calls 2.5 BB'),
      Act0ActionTrailItemV1(label: 'Flop: BB checks'),
      Act0ActionTrailItemV1.note(label: 'River: BB bets 999 BB'),
    ];
    final result = act0CalcTableTrailPotV1(_table(trail), 5);

    expect(result.potBb, 6.5);
    expect(result.street, 'Flop');
  });

  test('an actually missing small blind still fails closed', () {
    final result = act0CalcTrailPotV1(const ['BB blind 1 BB'], 0);

    expect(result.potBb, -1.0);
    expect(result.street, isEmpty);

    // A later SB must not leak past a source-index cutoff before that action.
    const trail = [
      Act0ActionTrailItemV1.note(label: 'A note before the blinds'),
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
    ];
    final beforeSmallBlind = act0CalcTableTrailPotV1(_table(trail), 0);
    expect(beforeSmallBlind.potBb, -1.0);
  });

  test('untyped leading or mid-trail blanks fail closed', () {
    final leadingBlank = act0CalcTrailPotV1(const [
      '',
      'SB blind 0.5 BB',
      'BB blind 1 BB',
    ], 2);
    final midTrailBlank = act0CalcTrailPotV1(const [
      'SB blind 0.5 BB',
      '',
      'BB blind 1 BB',
    ], 2);

    expect(leadingBlank.potBb, -1.0);
    expect(midTrailBlank.potBb, -1.0);
  });

  test(
    'authored explanation notes remain non-played visible teaching text',
    () {
      final explanation = _task('what_poker_is_all_in_meaning').runner.table;
      final orientation = _task('blinds_first_actor').runner.table;

      expect(explanation.actionTrail.every((item) => item.isNote), isTrue);
      expect(act0StreetReplayFromTableV1(explanation), isNull);
      expect(act0StreetReplayFromTableV1(orientation), isNull);
      expect(act0TableChoreographyPlanForTableV1(explanation), isNull);
    },
  );
}

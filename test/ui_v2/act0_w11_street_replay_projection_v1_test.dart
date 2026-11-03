import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

const _flopTrail = <Act0ActionTrailItemV1>[
  Act0ActionTrailItemV1(label: 'CO raises 2.5 BB'),
  Act0ActionTrailItemV1(label: 'BTN calls'),
  Act0ActionTrailItemV1(label: 'Flop: CO bets 2 BB'),
];
const _turnTrail = <Act0ActionTrailItemV1>[
  ..._flopTrail,
  Act0ActionTrailItemV1(label: 'BTN calls 2 BB'),
  Act0ActionTrailItemV1(label: 'Turn: CO bets 12 BB'),
];

void _expectProjection(Act0TableStateV1 table, bool turn) {
  final replay = act0StreetReplayFromTableV1(table)!;
  expect(replay.isConsumerSafe, isTrue);
  expect(
    replay.currentStreet,
    turn ? Act0StreetReplayStreetV1.turn : Act0StreetReplayStreetV1.flop,
  );
  expect(
    replay.steps.map((s) => s.actorLabel),
    turn ? ['CO', 'BTN', 'CO', 'BTN', 'CO'] : ['CO', 'BTN', 'CO'],
  );
  expect(
    replay.steps.map((s) => s.actionTypeLabel),
    turn
        ? ['raises', 'calls', 'bets', 'calls', 'bets']
        : ['raises', 'calls', 'bets'],
  );
  expect(
    replay.steps.map((s) => s.amountLabel),
    turn ? ['2.5 BB', '', '2 BB', '2 BB', '12 BB'] : ['2.5 BB', '', '2 BB'],
  );
  expect(replay.steps.map((s) => s.street), [
    Act0StreetReplayStreetV1.preflop,
    Act0StreetReplayStreetV1.preflop,
    Act0StreetReplayStreetV1.flop,
    if (turn) Act0StreetReplayStreetV1.flop,
    if (turn) Act0StreetReplayStreetV1.turn,
  ]);
  expect(
    replay.steps.map((s) => s.boardCardsAtStreet.length),
    turn ? [0, 0, 3, 3, 4] : [0, 0, 3],
  );
  expect(replay.steps.last.potAtStreet, turn ? 'Pot 12 BB' : 'Pot 8 BB');
  expect(replay.steps.last.isCurrentStreet, isTrue);
}

void main() {
  final lesson = Act0ShellStateV1.sample
      .worldById('world_11')
      .lessons
      .firstWhere((l) => l.lessonId == 'table_trigger_reads');
  for (final turn in [false, true]) {
    final id = turn
        ? 'w11_trigger_bad_price_fold'
        : 'w11_trigger_small_price_continue';
    final task = lesson.taskList.firstWhere((t) => t.taskId == id);
    testWidgets('$id real newly enabled replay paints authored context only', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: task.runner.teachingSteps.length,
              ),
              worldNumber: 11,
              selectedWorldId: 'world_11',
              selectedLessonId: lesson.lessonId,
              selectedTaskId: id,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final subtree = find.byKey(const Key('act0_shell_street_replay_inline'));
      expect(subtree, findsOneWidget);
      final texts = tester
          .widgetList<Text>(
            find.descendant(of: subtree, matching: find.byType(Text)),
          )
          .map((t) => t.data ?? '')
          .toList();
      expect(texts, contains(turn ? 'CO bets 12 BB' : 'CO bets 2 BB'));
      expect(texts, contains(turn ? 'Turn - Jh 7c 4d 2s' : 'Flop - Jh 7c 4d'));
      expect(texts, contains(turn ? 'Pot 12 BB' : 'Pot 8 BB'));
      expect(texts, contains('You are here'));
      final text = texts.join(' ');
      expect(text, isNot(contains('UTG')));
      expect(text.toLowerCase(), isNot(contains('winner')));
      expect(text.toLowerCase(), isNot(contains('complete hand')));
      expect(text.toLowerCase(), isNot(contains('stack')));
      expect(text, isNot(contains('?')));
      expect(tester.takeException(), isNull);
    });
    test('$id incomplete trail retains source pot fallback at every index', () {
      final labels = task.runner.table.actionTrail.map((a) => a.label).toList();
      for (var index = 0; index < labels.length; index++) {
        expect(act0CalcTrailPotV1(labels, index), (potBb: -1.0, street: ''));
      }
    });
    test('$id authored source exposes correct street projection', () {
      _expectProjection(task.runner.table, turn);
    });
    test('$id source-preserving trail feasibility without parser changes', () {
      // Only explicit authored actions: no forced folds/checks, terminal result,
      // missing cards or opponent hand are supplied to make the parser pass.
      _expectProjection(
        task.runner.table.copyWith(actionTrail: turn ? _turnTrail : _flopTrail),
        turn,
      );
      expect(task.runner.table.heroCards.map((c) => c.label), ['Qs', 'Js']);
      expect(task.runner.table.boardCards.map((c) => c.label), [
        'Jh',
        '7c',
        '4d',
        if (turn) '2s',
      ]);
    });
  }
}

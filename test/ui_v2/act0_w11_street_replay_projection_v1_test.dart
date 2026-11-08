import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

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

// PKR-03 option B: the full authored hand from the antes and blinds.
void _expectProjection(Act0TableStateV1 table, bool turn) {
  final replay = act0StreetReplayFromTableV1(table)!;
  expect(replay.isConsumerSafe, isTrue);
  expect(replay.completeness, Act0StreetReplayCompletenessV1.complete);
  expect(
    replay.currentStreet,
    turn ? Act0StreetReplayStreetV1.turn : Act0StreetReplayStreetV1.flop,
  );
  expect(replay.steps.map((s) => s.actorLabel), [
    'SB',
    'BB',
    'UTG',
    'HJ',
    'CO',
    'BTN',
    'SB',
    'BB',
    'CO',
    if (turn) ...['BTN', 'CO'],
  ]);
  expect(replay.steps.map((s) => s.actionTypeLabel), [
    'blind',
    'blind',
    'folds',
    'folds',
    'raises',
    'calls',
    'folds',
    'folds',
    'bets',
    if (turn) ...['calls', 'bets'],
  ]);
  expect(replay.steps.map((s) => s.amountLabel), [
    '0.5 BB',
    '1 BB',
    '',
    '',
    '2.5 BB',
    '2.5 BB',
    '',
    '',
    '2 BB',
    if (turn) ...['2 BB', '12 BB'],
  ]);
  expect(replay.steps.map((s) => s.boardCardsAtStreet.length), [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    3,
    if (turn) ...[3, 4],
  ]);
  expect(replay.steps.last.potAtStreet, turn ? 'Pot 12 BB' : 'Pot 8 BB');
  expect(replay.steps.last.isCurrentStreet, isTrue);
}

void _expectPreOptionBProjection(Act0TableStateV1 table, bool turn) {
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
              tableChoreographyMode: Act0TableChoreographyModeV1.settled,
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
    test('$id full trail computes the playback pot at every index', () {
      // Option B starts from the ante note and SB blind, so playback no longer
      // falls back to the static label; the exact values are pinned in
      // act0_pkr03_w11_option_b_history_v1_test.dart against a ledger.
      final table = task.runner.table;
      for (var index = 0; index < table.actionTrail.length; index++) {
        expect(act0CalcTableTrailPotV1(table, index).potBb, greaterThan(0));
      }
      expect(act0TableChoreographyPlanForTableV1(table), isNotNull);
    });
    test('$id authored source exposes correct street projection', () {
      _expectProjection(task.runner.table, turn);
    });
    test('$id pre-option-B authored trail still projects safely', () {
      // The earlier authored trail alone (no antes, blinds or folds).
      _expectPreOptionBProjection(
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

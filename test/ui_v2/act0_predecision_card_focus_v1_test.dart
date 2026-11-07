import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_predecision_card_focus_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

final _catalog = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

void main() {
  test('projection covers every source task without changing table facts', () {
    var assessed = 0;
    var suppressed = 0;
    var revised = 0;
    for (final row in _catalog) {
      final task = row.task;
      final source = task.runner.table;
      final active =
          task.entryPhase == Act0LessonPhaseV1.drill &&
          task.runner.options.isNotEmpty;
      final projected = act0PredecisionCardFocusV1(
        source,
        isActiveAssessment: active,
      );
      if (active) assessed++;
      if (active && source.highlightedCardIds.isNotEmpty) suppressed++;
      if (act0PredecisionCardFocusSourceRevisionV1(task) != null) revised++;
      expect(
        projected.highlightedCardIds,
        active ? isEmpty : source.highlightedCardIds,
        reason: task.taskId,
      );
      expect(projected.heroCards, source.heroCards);
      expect(projected.boardCards, source.boardCards);
      expect(projected.seats, source.seats);
      expect(projected.actionTrail, source.actionTrail);
      expect(projected.potLabel, source.potLabel);
      expect(projected.toCallLabel, source.toCallLabel);
      expect(projected.streetLabel, source.streetLabel);
      expect(projected.activeSeatId, source.activeSeatId);
      expect(projected.highlightedSeatIds, source.highlightedSeatIds);
      expect(projected.selectableSeatIds, source.selectableSeatIds);
      expect(projected.centerLabel, source.centerLabel);
      expect(projected.focusCalloutLabel, source.focusCalloutLabel);
      expect(
        act0PredecisionCardFocusV1(source, isActiveAssessment: false),
        same(source),
      );
      expect(
        act0PredecisionCardFocusV1(projected, isActiveAssessment: active),
        same(projected),
      );
    }
    expect(_catalog, hasLength(367));
    expect(assessed, 275);
    expect(suppressed, 221);
    expect(revised, 220);
  });

  test(
    'actual pair source and grade have an independent card-pattern witness',
    () {
      final task = _catalog
          .singleWhere((r) => r.task.taskId == 'hand_rankings_pair_drill')
          .task;
      final table = task.runner.table;
      final cards = [...table.heroCards, ...table.boardCards];
      // Literal authored cards and rule witness, independent of isCorrect.
      expect(cards.map((c) => '${c.rank}${c.suit}'), [
        'As',
        'Kd',
        'Ah',
        '7c',
        '2d',
      ]);
      expect(
        Hand.solveHand(cards.map((c) => '${c.rank}${c.suit}').toList()).name,
        'Pair',
      );
      final pair = task.runner.options.singleWhere((o) => o.id == 'pair');
      expect(pair.label, 'Pair');
      expect(pair.isCorrect, isTrue);
      expect(table.highlightedCardIds, ['hero_0', 'board_0']);
      expect(table.heroCards.first.rank, table.boardCards.first.rank);
      expect(
        act0PredecisionCardFocusV1(
          table,
          isActiveAssessment: true,
        ).highlightedCardIds,
        isEmpty,
      );
      // Even an injected focus on a different card is suppressed. A projection
      // must not silently rely on the answer flags to identify the unsafe cue.
      final wrongCue = table.copyWith(highlightedCardIds: ['board_2']);
      expect(
        act0PredecisionCardFocusV1(
          wrongCue,
          isActiveAssessment: true,
        ).highlightedCardIds,
        isEmpty,
      );
    },
  );

  test('capture exact source fingerprints for serial compatibility checks', () {
    final manifest = [
      for (final row in _catalog)
        {
          'worldId': row.world.worldId,
          'lessonId': row.lesson.lessonId,
          'taskId': row.task.taskId,
          'revision': act0PredecisionCardFocusSourceRevisionV1(row.task),
          'fingerprint': act0AuthoredSourceFingerprintV1(
            worldId: row.world.worldId,
            lessonId: row.lesson.lessonId,
            task: row.task,
          ),
        },
    ];
    final file = File('output/asm04/source-fingerprints.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
    );
    expect(manifest, hasLength(367));
    expect(manifest.every((r) => r['fingerprint'] != null), isTrue);
  });
}

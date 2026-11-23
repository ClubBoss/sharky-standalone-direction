// Exports the learner-visible task catalog to JSON for review and analysis.
// Not a CI test: run it on demand.
//   flutter test tools/export_catalog_v1_test.dart \
//     --dart-define=OUT=/tmp/catalog.json --dart-define=WORLDS=1-4
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'export_answer_positions_v1.dart' as answer_positions;

void main() {
  if (const bool.fromEnvironment('ANSWER_POSITIONS')) {
    test(
      'export answer positions for the pure-Dart audit',
      answer_positions.main,
    );
    return;
  }

  test('export catalog', () {
    const out = String.fromEnvironment('OUT', defaultValue: 'catalog.json');
    const worlds = String.fromEnvironment('WORLDS', defaultValue: '1-12');
    final bounds = worlds.split('-').map(int.parse).toList();
    final tasks = <Object>[];
    for (final w in Act0ShellStateV1.sample.worlds.where(
      (w) => w.worldNumber >= bounds.first && w.worldNumber <= bounds.last,
    )) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final r = t.runner;
          final table = r.table;
          tasks.add({
            'world': w.worldNumber,
            'lesson': l.lessonId,
            'task': t.taskId,
            'phase': t.phase.name,
            'repairOnly': t.repairOnly,
            'family': t.resolvedTaskFamily.name,
            'composition': t.resolvedCompositionFamily.name,
            'tableScope': r.table.scope.name,
            'title': t.title,
            'caption': r.caption,
            'question': r.question,
            'hint': r.hint,
            'teaching': [
              for (final s in r.teachingSteps)
                {'title': s.title, 'body': s.body},
            ],
            'table': {
              'street': table.streetLabel,
              'pot': table.potLabel,
              'toCall': table.toCallLabel,
              'hero': [for (final c in table.heroCards) '${c.rank}${c.suit}'],
              'board': [for (final c in table.boardCards) '${c.rank}${c.suit}'],
            },
            'options': [
              for (final o in r.options)
                {
                  'id': o.id,
                  'label': o.label,
                  'seat': o.seatId,
                  'correct': o.isCorrect,
                  'quality': o.quality.name,
                  'reason': o.feedbackReason,
                },
            ],
          });
        }
      }
    }
    File(
      out,
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(tasks));
    // ignore: avoid_print
    print('exported ${tasks.length} tasks to $out');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_path_progress_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Catalog-wide checks for two learner-trust classes:
// - every graded task has one right answer, and every option's grade, "better
//   answer" pointer and explanation agree with it (ASM-02.a, ASM-03.a);
// - a lesson opens only after everything before it is done (CUR-08.a).

final _worlds = Act0ShellStateV1.sample.worlds;

void main() {
  test('every graded task has one right answer that all options agree on', () {
    final problems = <String>[];
    var graded = 0;
    for (final w in _worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final options = t.runner.options;
          if (options.isEmpty) continue;
          graded++;
          final id = 'W${w.worldNumber} ${t.taskId}';
          final correct = options.where((o) => o.isCorrect).toList();
          if (correct.length != 1) {
            problems.add('$id: ${correct.length} correct options');
            continue;
          }
          final right = correct.single;
          final ids = options.map((o) => o.id).toList();
          if (ids.toSet().length != ids.length) {
            problems.add('$id: repeated option ids $ids');
          }
          final labels = options.map((o) => '${o.label}|${o.seatId}').toList();
          if (labels.toSet().length != labels.length) {
            problems.add('$id: repeated option labels $labels');
          }
          for (final o in options) {
            final at = '$id/${o.id}';
            if (o.isCorrect != (o.quality == Act0FeedbackQualityV1.correct)) {
              problems.add(
                '$at: correct flag disagrees with ${o.quality.name}',
              );
            }
            if (o.feedbackTitle.trim().isEmpty ||
                o.feedbackReason.trim().isEmpty) {
              problems.add('$at: no feedback title or explanation');
            }
            if (!o.isCorrect && o.betterAnswerLabel != right.label) {
              problems.add(
                '$at: better answer "${o.betterAnswerLabel}" is not the '
                'right answer "${right.label}"',
              );
            }
          }
        }
      }
    }
    expect(graded, greaterThan(250), reason: 'catalog went missing');
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('a lesson opens only after every task before it is closed', () {
    final route = [
      for (final w in _worlds)
        for (final l in w.lessons) (world: w.worldId, lesson: l),
    ];
    Map<String, Act0LessonCardV1> project(Set<String> closed) => {
      for (final w in act0ProgressWorldsV1(
        _worlds,
        pathClosedTaskIds: closed,
        earnedTaskIds: closed,
      ))
        for (final l in w.lessons) l.lessonId: l,
    };
    final problems = <String>[];
    final before = <String>[];
    for (var k = 0; k < route.length; k++) {
      final target = route[k].lesson;
      final lessons = project(before.toSet());
      for (var j = 0; j < route.length; j++) {
        final l = lessons[route[j].lesson.lessonId]!;
        final open = l.isSelectable && !l.isLocked;
        final expected = j <= k;
        if (open != expected) {
          problems.add(
            'with lessons before ${target.lessonId} closed, '
            '${l.lessonId} is ${open ? 'open' : 'locked'}',
          );
        }
      }
      // Negative cases: missing any single earlier task keeps the lesson shut.
      for (final missing in before) {
        final l = project(before.toSet()..remove(missing))[target.lessonId]!;
        if (l.isSelectable || !l.isLocked) {
          problems.add('${target.lessonId} opens without $missing');
        }
      }
      before.addAll(target.taskList.map((t) => t.taskId));
    }
    expect(route.length, greaterThan(50), reason: 'catalog went missing');
    expect(problems, isEmpty, reason: problems.take(40).join('\n'));
  });
}

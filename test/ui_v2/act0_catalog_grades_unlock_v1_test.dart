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

  test('a lesson opens only after every course task before it is closed', () {
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
      before.addAll(target.courseTaskList.map((t) => t.taskId));
    }
    expect(route.length, greaterThan(50), reason: 'catalog went missing');
    expect(problems, isEmpty, reason: problems.take(40).join('\n'));
  });

  group('Q15 world checkpoint weak-spot gate', () {
    test(
      'checkpoint stays locked with Clear weak spots when world has open mistakes',
      () {
        final w1 = _worlds.firstWhere((w) => w.worldId == 'world_1');
        final checkpoint = w1.lessons.last;
        expect(act0LessonIsWorldCheckpointV1(w1, checkpoint), isTrue);

        final preCheckpointTaskIds = {
          for (final lesson in w1.lessons.take(w1.lessons.length - 1))
            for (final task in lesson.courseTaskList) task.taskId,
        };

        final gated = act0ProgressWorldsV1(
          _worlds,
          pathClosedTaskIds: preCheckpointTaskIds,
          earnedTaskIds: preCheckpointTaskIds,
          worldsWithOpenMistakes: const {'world_1'},
        ).firstWhere((w) => w.worldId == 'world_1');

        final gatedCheckpoint = gated.lessons.last;
        expect(gatedCheckpoint.lessonId, checkpoint.lessonId);
        expect(gatedCheckpoint.state, Act0LessonStateV1.locked);
        expect(gatedCheckpoint.primaryCtaLabel, 'Clear weak spots');
        expect(gatedCheckpoint.isSelectable, isFalse);
        expect(gatedCheckpoint.isLocked, isTrue);

        final cleared = act0ProgressWorldsV1(
          _worlds,
          pathClosedTaskIds: preCheckpointTaskIds,
          earnedTaskIds: preCheckpointTaskIds,
          worldsWithOpenMistakes: const <String>{},
        ).firstWhere((w) => w.worldId == 'world_1');

        final openCheckpoint = cleared.lessons.last;
        expect(openCheckpoint.state, Act0LessonStateV1.current);
        expect(openCheckpoint.primaryCtaLabel, 'Start');
        expect(openCheckpoint.isSelectable, isTrue);
        expect(openCheckpoint.isLocked, isFalse);
      },
    );

    test(
      'already-completed checkpoint stays completed and selectable despite open mistakes',
      () {
        final w1 = _worlds.firstWhere((w) => w.worldId == 'world_1');
        final allW1Tasks = {
          for (final lesson in w1.lessons)
            for (final task in lesson.courseTaskList) task.taskId,
        };

        final progressed = act0ProgressWorldsV1(
          _worlds,
          pathClosedTaskIds: allW1Tasks,
          earnedTaskIds: allW1Tasks,
          worldsWithOpenMistakes: const {'world_1'},
        ).firstWhere((w) => w.worldId == 'world_1');

        final checkpoint = progressed.lessons.last;
        expect(checkpoint.state, Act0LessonStateV1.completed);
        expect(checkpoint.primaryCtaLabel, 'Replay');
        expect(checkpoint.isSelectable, isTrue);
        expect(checkpoint.isLocked, isFalse);
      },
    );

    test('act0LessonIsWorldCheckpointV1 excludes non-checkpoint worlds', () {
      final w5 = _worlds.firstWhere((w) => w.worldId == 'world_5');
      final w8 = _worlds.firstWhere((w) => w.worldId == 'world_8');
      expect(act0LessonIsWorldCheckpointV1(w5, w5.lessons.last), isFalse);
      expect(act0LessonIsWorldCheckpointV1(w8, w8.lessons.last), isFalse);
    });
  });
}

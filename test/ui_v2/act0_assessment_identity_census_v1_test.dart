import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Assessment identity and grading consistency for all 367 W1-W12 tasks.
///
/// Stable task ids and choice ids are what saved receipts, repair debt and
/// XP refer to; grading flags, answer quality, preferred answers and feedback
/// must agree with each other so the learner sees one truthful verdict.
void main() {
  final tasks = <Act0LessonTaskV1>[
    for (final w in Act0ShellStateV1.sample.worlds)
      for (final l in w.lessons) ...l.taskList,
  ];

  test('task ids and choice ids are unique and stable in shape', () {
    expect(tasks, hasLength(367));
    expect(tasks.map((t) => t.taskId).toSet(), hasLength(367));
    final problems = <String>[];
    for (final t in tasks) {
      final ids = t.runner.options.map((o) => o.id).toList();
      if (ids.toSet().length != ids.length) problems.add('${t.taskId} dup');
      for (final id in [t.taskId, ...ids]) {
        if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) problems.add('$id shape');
      }
    }
    expect(problems, isEmpty);
  });

  test('graded answers, quality, preferred answer and feedback agree', () {
    final problems = <String>[];
    var graded = 0;
    for (final t in tasks) {
      final options = t.runner.options;
      if (t.phase == Act0LessonPhaseV1.theory || options.isEmpty) continue;
      graded += 1;
      final labels = options.map((o) => o.label).toSet();
      final correct = options.where((o) => o.isCorrect).toList();
      if (correct.isEmpty) problems.add('${t.taskId}: no correct option');
      for (final o in options) {
        final id = '${t.taskId}/${o.id}';
        if (o.isCorrect != (o.quality == Act0FeedbackQualityV1.correct)) {
          problems.add('$id: correct=${o.isCorrect} quality=${o.quality}');
        }
        if (!labels.contains(o.preferredLabel)) {
          problems.add('$id: preferred "${o.preferredLabel}" is no option');
        }
        if (!o.isCorrect && !correct.any((c) => c.label == o.preferredLabel)) {
          problems.add('$id: preferred answer is not a correct option');
        }
        if (o.feedbackReason.trim().isEmpty) problems.add('$id: no feedback');
      }
    }
    expect(graded, greaterThan(250));
    expect(problems, isEmpty);
  });
}

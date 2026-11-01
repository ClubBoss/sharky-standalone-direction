import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
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

  test('frozen source task and choice identity contract', () {
    final entries = <List<Object?>>[
      for (final world in Act0ShellStateV1.sample.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList)
            <Object?>[
              world.worldId,
              lesson.lessonId,
              task.taskId,
              task.phase.name,
              task.stepKind.name,
              <List<Object?>>[
                for (final option in task.runner.options)
                  <Object?>[
                    option.id,
                    option.label,
                    option.isCorrect,
                    option.quality.name,
                    option.preferredLabel,
                  ],
              ],
            ],
    ]..sort((a, b) => (a[2] as String).compareTo(b[2] as String));
    expect(entries, hasLength(367));
    final encoded = jsonEncode(entries);
    final fingerprint = sha256.convert(utf8.encode(encoded)).toString();
    // Fingerprint covers task identity, authored lesson ownership, source
    // choice text, correct/quality semantics, and option order. Changing any
    // of these requires an explicit learner-record compatibility disposition.
    const acceptedMainFingerprint =
        '26c8c2d76a89ba00adfb482b2130e758f7b8e32699ef85f75e15abf189e57bb4';
    print('ASM01_SOURCE_FINGERPRINT=$fingerprint');
    expect(fingerprint, acceptedMainFingerprint);
    final tampered = jsonDecode(encoded) as List<dynamic>;
    final withChoice = tampered.cast<List<dynamic>>().firstWhere(
      (row) => (row[5] as List<dynamic>).isNotEmpty,
    );
    ((withChoice[5] as List<dynamic>).first as List<dynamic>)[0] =
        'renamed_choice_invalidates_history';
    expect(
      sha256.convert(utf8.encode(jsonEncode(tampered))).toString(),
      isNot(acceptedMainFingerprint),
      reason: 'A source choice rename must invalidate the accepted snapshot.',
    );
  });

  test('source-owned choice identities survive legacy persisted evidence', () {
    final taskIndex = <String, (String, String, Act0LessonTaskV1)>{
      for (final world in Act0ShellStateV1.sample.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList)
            task.taskId: (world.worldId, lesson.lessonId, task),
    };
    expect(taskIndex, hasLength(367));
    var validated = 0;
    for (final entry in taskIndex.entries) {
      final (worldId, lessonId, task) = entry.value;
      final choices = task.runner.options;
      if (choices.isEmpty) continue;
      final expected = choices.where((choice) => choice.isCorrect).toList();
      expect(expected, isNotEmpty, reason: entry.key);
      for (final choice in choices) {
        final evidence = Act0LearningEvidenceRecordV1(
          recordId: 'legacy:$worldId:$lessonId:${task.taskId}:${choice.id}',
          createdOrder: validated,
          worldId: worldId,
          lessonId: lessonId,
          taskId: task.taskId,
          choiceId: choice.id,
          expectedChoiceId: expected.first.id,
          isCorrect: choice.isCorrect,
          errorType: choice.isCorrect ? 'none' : 'missed_action_read',
          repairFocusId: '',
          skillAtomId: task.taskId,
          decisionTimeBucket: '3_to_10s',
          resultKind: choice.isCorrect ? 'correct' : 'incorrect',
        );
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          evidence.toPayload(),
        );
        expect(restored, evidence, reason: evidence.recordId);
        expect(restored!.taskId, task.taskId);
        expect(restored.choiceId, choice.id);
        expect(restored.expectedChoiceId, expected.first.id);
        expect(restored.isCorrect, choice.isCorrect);
        validated++;
      }
    }
    print('ASM01_EVIDENCE_ROUNDTRIPS=$validated');
    expect(validated, greaterThan(500));
    // A renamed task/choice is not silently mapped to a different skill.
    final first = taskIndex.values.first.$3;
    expect(taskIndex.containsKey('${first.taskId}_renamed'), isFalse);
    expect(
      first.runner.options.any(
        (choice) => choice.id == 'nonexistent_choice_migration',
      ),
      isFalse,
    );
  });

  test('accepted-main legacy payload retains exact source meaning', () {
    // Literal v1 fixture frozen from accepted-main 130a1da4 source test
    // test/ui_v2/act0_learning_evidence_contract_v1_test.dart, combined
    // with that commit's Act0LearningEvidenceRecordV1.toPayload fields.
    // It was NOT generated by this candidate's toPayload and does NOT
    // represent a real user's persisted record.
    const acceptedMainPayload = <String, Object?>{
      'schemaVersion': 1,
      'recordId': '1:world_1:actions_legal_context:fold',
      'createdOrder': 1,
      'worldId': 'world_1',
      'lessonId': 'fold_check_call_raise',
      'taskId': 'actions_legal_context',
      'choiceId': 'fold',
      'expectedChoiceId': 'check',
      'isCorrect': false,
      'errorType': 'missed_action_read',
      'conceptFamilyId': '',
      'repairFocusId': 'no_bet_yet',
      'skillAtomId': 'action_read',
      'decisionTimeBucket': '3_to_10s',
      'resultKind': 'incorrect',
    };
    final restored = Act0LearningEvidenceRecordV1.tryParse(acceptedMainPayload);
    expect(restored, isNotNull);
    expect(restored!.toPayload(), acceptedMainPayload);
    final world = Act0ShellStateV1.sample.worlds.singleWhere(
      (world) => world.worldId == restored.worldId,
    );
    final lesson = world.lessons.singleWhere(
      (lesson) => lesson.lessonId == restored.lessonId,
    );
    final task = lesson.taskList.singleWhere(
      (task) => task.taskId == restored.taskId,
    );
    final selected = task.runner.options.singleWhere(
      (choice) => choice.id == restored.choiceId,
    );
    final originalExpected = task.runner.options.singleWhere(
      (choice) => choice.id == restored.expectedChoiceId,
    );
    expect(selected.isCorrect, isFalse);
    expect(originalExpected.isCorrect, isTrue);
    expect(restored.errorType, 'missed_action_read');
    expect(restored.repairFocusId, 'no_bet_yet');
    // A differently named source choice cannot match this old record.
    expect(
      task.runner.options.any(
        (choice) => choice.id == 'fold_renamed_during_patch',
      ),
      isFalse,
    );
  });
}

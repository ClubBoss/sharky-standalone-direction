import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w14_skill_state_v1.dart';

final _worlds = Act0ShellStateV1.sample.worlds;
final _tasks = [
  for (final world in _worlds.where(
    (w) => w.worldNumber >= 1 && w.worldNumber <= 6,
  ))
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

Act0LearningEvidenceRecordV1 _answer(
  int index,
  int order, {
  bool correct = true,
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  String runKind = 'lesson',
  String? fingerprint,
}) {
  final source = _tasks[index];
  return Act0LearningEvidenceRecordV1(
    recordId: 'answer_$order',
    createdOrder: order,
    worldId: source.world.worldId,
    lessonId: source.lesson.lessonId,
    taskId: source.task.taskId,
    choiceId: correct ? 'correct' : 'wrong',
    expectedChoiceId: 'correct',
    isCorrect: correct,
    errorType: correct ? 'none' : 'miss',
    repairFocusId: 'table_read',
    skillAtomId: 'table_read',
    decisionTimeBucket: 'under_3s',
    resultKind: correct ? 'correct' : 'incorrect',
    assistanceKind: assistance,
    runKind: runKind,
    authoredSourceFingerprint:
        fingerprint ??
        act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: source.world.worldId,
          lessonId: source.lesson.lessonId,
          taskId: source.task.taskId,
        )!,
  );
}

List<Act0W14SkillStateV1> _states(
  List<Act0LearningEvidenceRecordV1> records, {
  List<Act0WorldCardV1>? worlds,
}) => act0W14SkillStatesV1(
  worlds: worlds ?? _worlds,
  history: Act0LearningEvidenceHistoryV1(records: records),
);

List<Object> _snapshot(List<Act0W14SkillStateV1> states) => [
  for (final s in states)
    [s.label, s.stateLabel, s.explanation, s.lessonCount, s.taskCount],
];

void main() {
  test(
    'first-fact anchors preserve practice but never reopen an old miss as current',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: [_answer(1, 300)],
        sourceAnchors: [_answer(0, 1), _answer(0, 2, correct: false)],
      );
      final state = act0W14SkillStatesV1(
        worlds: _worlds,
        history: history,
      ).first;
      expect(state.independentTasks, 2);
      expect(state.tasksToRevisit, 0);
      expect(state.stateLabel, 'Answers without help');
    },
  );

  test(
    'all 182 W1-W4 tasks have explicit curriculum topics and independent evidence',
    () {
      final foundationWorlds = _worlds
          .where((w) => w.worldNumber <= 4)
          .toList();
      final tasks = _tasks
          .where((item) => item.world.worldNumber <= 4)
          .toList();
      expect(tasks.length, 182);
      expect(
        tasks.map((s) => s.lesson.lessonId).toSet(),
        act0W14LessonSkillsV1.keys.toSet(),
      );
      final records = <Act0LearningEvidenceRecordV1>[];
      for (var i = 0; i < tasks.length; i++) {
        final source = tasks[i];
        final labels =
            const {
              'positions_theory',
              'positions_button',
              'positions_utg',
              'positions_cutoff',
            }.contains(source.task.taskId)
            ? const ['Position play']
            : act0W14LessonSkillsV1[source.lesson.lessonId]!;
        expect(labels, isNotEmpty, reason: source.task.taskId);
        final states = _states([_answer(i, i)], worlds: foundationWorlds);
        expect(
          states
              .where((s) => s.independentTasks > 0)
              .map((s) => s.label)
              .toSet(),
          labels.toSet(),
          reason: source.task.taskId,
        );
        records.add(_answer(i, i));
      }
      final states = _states(records, worlds: foundationWorlds);
      expect(states.length, 6);
      for (final state in states) {
        expect(state.stateLabel, 'Answers without help');
        expect(state.independentTasks, state.taskCount);
        expect(state.tasksToRevisit, 0);
      }
      expect(act0W14LessonSkillsV1['weak_ace_warning'], ['Hand reading']);
      expect(act0W14LessonSkillsV1['position_six_seats'], ['Position play']);
      expect(act0W14LessonSkillsV1['call_price'], ['Betting decisions']);
    },
  );

  test(
    'miss stays open after help or another task; its independent retry clears it',
    () {
      final missed = _answer(0, 1, correct: false);
      final helped = _answer(
        0,
        2,
        assistance: Act0DecisionAssistanceV1.quickHint,
      );
      final other = _answer(1, 3);
      final before = _states([
        other,
        helped,
        missed,
      ]).firstWhere((s) => s.label == 'Table sense');
      expect(before.stateLabel, 'Needs practice');
      expect(before.tasksToRevisit, 1);
      expect(before.helpedOrUnverifiedTasks, 1);
      expect(before.independentTasks, 1);
      final after = _states([
        missed,
        helped,
        other,
        _answer(0, 4),
      ]).firstWhere((s) => s.label == 'Table sense');
      expect(after.stateLabel, 'Answers without help');
      expect(after.tasksToRevisit, 0);
      expect(after.independentTasks, 2);
      expect(
        _states([
          _answer(0, 1),
          _answer(0, 2, correct: false),
        ]).first.stateLabel,
        'Needs practice',
      );
    },
  );

  test('every W5–W6 task projects to its authored topic', () {
    const boardLessons = {
      'board_texture_basics',
      'connected_boards',
      'flush_draws',
      'straight_draws',
      'outs_improvement',
      'turn_river_changes',
    };
    const rangeLessons = {
      'range_bucket_basics',
      'range_board_fit',
      'range_pressure_lines',
      'range_combo_counts',
      'range_thinking_checkpoint',
    };
    const pricedOuts = {
      'outs_improvement_w5_table_outs_flush_transfer',
      'outs_improvement_w5_table_outs_straight_transfer',
    };
    final lessons = <String>{};
    for (final (i, source) in _tasks.indexed) {
      if (source.world.worldNumber < 5) continue;
      lessons.add(source.lesson.lessonId);
      expect(
        _states([_answer(i, i + 1)])
            .where((state) => state.independentTasks > 0)
            .map((state) => state.label)
            .toSet(),
        {
          if (boardLessons.contains(source.lesson.lessonId)) 'Board reading',
          if (rangeLessons.contains(source.lesson.lessonId)) 'Range reading',
          if (pricedOuts.contains(source.task.taskId)) 'Betting decisions',
        },
        reason: source.task.taskId,
      );
    }
    expect(lessons, {...boardLessons, ...rangeLessons});
  });

  test('saved W6 help and stale answers cannot clear a miss', () {
    final index = _tasks.indexWhere(
      (item) => item.task.taskId == 'w6_ak_combos',
    );
    expect(index, isNonNegative);
    final history = Act0LearningEvidenceHistoryV1(
      records: [
        _answer(index, 1, correct: false),
        _answer(index, 2, assistance: Act0DecisionAssistanceV1.quickHint),
        _answer(index, 3, fingerprint: 'older-content'),
      ],
    );
    final restored = Act0LearningEvidenceHistoryV1.tryParseStorageString(
      history.toStorageString(),
    )!;
    Act0W14SkillStateV1 range(List<Act0LearningEvidenceRecordV1> records) =>
        _states(records).singleWhere((state) => state.label == 'Range reading');
    final helped = range(restored.records);
    expect(helped.answeredTasks, 1);
    expect(helped.independentTasks, 0);
    expect(helped.helpedOrUnverifiedTasks, 1);
    expect(helped.tasksToRevisit, 1);
    final retried = range([...restored.records, _answer(index, 4)]);
    expect(retried.answeredTasks, 1);
    expect(retried.independentTasks, 1);
    expect(retried.tasksToRevisit, 0);
  });

  test(
    'legacy, changed-source and helped answers never become independent proof',
    () {
      for (final record in [
        _answer(0, 1, assistance: Act0DecisionAssistanceV1.quickHint),
        _answer(0, 1, assistance: Act0DecisionAssistanceV1.theoryRecall),
        _answer(0, 1, assistance: Act0DecisionAssistanceV1.legacyUnknown),
        _answer(0, 1, fingerprint: ''),
        _answer(0, 1, fingerprint: 'older-content'),
      ]) {
        final state = _states([record]).first;
        expect(state.stateLabel, 'Practice recorded');
        expect(state.independentTasks, 0);
        expect(state.helpedOrUnverifiedTasks, 1);
      }
    },
  );

  test('placement, teaching demo, and a wrong world cannot start a skill', () {
    for (final kind in [
      act0PlacementAssessmentRunKindV1,
      act0DiagnosticLearningEntryRunKindV1,
    ]) {
      expect(
        _states([
          _answer(0, 1, runKind: kind),
        ]).every((s) => s.stateLabel == 'Not started'),
        isTrue,
      );
    }
    final payload = _answer(0, 1).toPayload()..['worldId'] = 'world_12';
    expect(
      _states([
        Act0LearningEvidenceRecordV1.tryParse(payload)!,
      ]).every((s) => s.stateLabel == 'Not started'),
      isTrue,
    );
  });

  test(
    'saved journal roundtrip preserves states across all worlds without double counting anchors',
    () {
      final records = [
        for (final (i, task) in _tasks.indexed)
          if (task.world.worldNumber <= 4)
            _answer(
              i,
              i,
              correct: i % 3 != 0,
              assistance: i % 3 == 1
                  ? Act0DecisionAssistanceV1.quickHint
                  : Act0DecisionAssistanceV1.none,
            ),
      ];
      final original = Act0LearningEvidenceHistoryV1(
        records: records,
        sourceAnchors: records.take(20).toList(),
      );
      final restored = Act0LearningEvidenceHistoryV1.tryParseStorageString(
        original.toStorageString(),
      )!;
      expect(
        _snapshot(act0W14SkillStatesV1(worlds: _worlds, history: restored)),
        _snapshot(act0W14SkillStatesV1(worlds: _worlds, history: original)),
      );
      expect(_states([records[0], records[0]]).first.answeredTasks, 1);
    },
  );
}

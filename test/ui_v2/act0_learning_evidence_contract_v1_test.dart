import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('serializes a deterministic learning evidence record', () {
    const record = Act0LearningEvidenceRecordV1(
      recordId: '1:world_1:actions_legal_context:fold',
      createdOrder: 1,
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_legal_context',
      choiceId: 'fold',
      expectedChoiceId: 'check',
      isCorrect: false,
      errorType: 'missed_action_read',
      repairFocusId: 'no_bet_yet',
      skillAtomId: 'action_read',
      decisionTimeBucket: '3_to_10s',
      resultKind: 'incorrect',
    );

    expect(Act0LearningEvidenceRecordV1.tryParse(record.toPayload()), record);
    expect(record.toPayload(), isNot(containsPair('mastery', anything)));
    expect(record.toPayload(), isNot(containsPair('leak', anything)));
  });

  test(
    'history keeps latest records in deterministic order and answers queries',
    () {
      var history = const Act0LearningEvidenceHistoryV1();
      history = history.append(_record(order: 1, skillAtomId: 'action_read'));
      history = history.append(
        _record(
          order: 2,
          skillAtomId: 'action_read',
          repairFocusId: 'no_bet_yet',
        ),
      );
      history = history.append(
        _record(
          order: 3,
          skillAtomId: 'position_read',
          resultKind: 'correct',
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
        ),
      );

      expect(history.lastN(2).map((record) => record.createdOrder), <int>[
        2,
        3,
      ]);
      expect(history.bySkillAtom('action_read'), hasLength(2));
      expect(history.byRepairFocus('no_bet_yet'), hasLength(2));
      expect(history.mistakes(), hasLength(2));
    },
  );

  test('history ignores malformed records and bounds retained evidence', () {
    final records = <Map<String, Object?>>[
      _record(order: 1).toPayload(),
      <String, Object?>{'schemaVersion': 1},
    ];
    final decoded = Act0LearningEvidenceHistoryV1.tryParse(records);

    expect(decoded?.records, hasLength(1));

    var history = const Act0LearningEvidenceHistoryV1();
    for (
      var order = 1;
      order <= Act0LearningEvidenceHistoryV1.maxRecords + 1;
      order++
    ) {
      history = history.append(_record(order: order));
    }
    expect(
      history.records,
      hasLength(Act0LearningEvidenceHistoryV1.maxRecords),
    );
    expect(history.records.first.createdOrder, 2);
  });

  test('completed decision converts once into fact-only durable evidence', () {
    const decision = Act0CompletedDecisionV1(
      attemptKey:
          'v1|world_1|fold_check_call_raise|actions_raise_drill|actionList|fold|1',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_raise_drill',
      sourceTaskId: 'actions_raise_drill',
      decisionKind: Act0CompletedDecisionKindV1.actionList,
      selectedId: 'fold',
      expectedId: 'check',
      isCorrect: false,
      decisionTimeBucket: 'under_3s',
      taskFamily: Act0TaskFamilyV1.decision,
      resultKind: 'incorrect',
      errorType: 'missed_action_read',
      skillAtomId: 'action_read',
      repairFocusId: 'no_bet_yet',
      missedSignalId: 'no_bet_yet',
    );

    final record = act0LearningEvidenceRecordFromCompletedDecisionV1(
      decision,
      createdOrder: 7,
    );

    expect(record, isNotNull);
    expect(record!.recordId, decision.attemptKey);
    expect(record.createdOrder, 7);
    expect(record.skillAtomId, 'action_read');
    expect(record.repairFocusId, 'no_bet_yet');
    expect(record.toPayload(), isNot(containsPair('label', anything)));
  });

  test('incomplete completed decision does not create durable evidence', () {
    const decision = Act0CompletedDecisionV1(
      attemptKey: 'v1|world_1|lesson|task|seat|co|1',
      worldId: 'world_1',
      lessonId: 'lesson',
      taskId: 'task',
      sourceTaskId: 'task',
      decisionKind: Act0CompletedDecisionKindV1.seat,
      selectedId: 'co',
      expectedId: 'utg',
      isCorrect: false,
      decisionTimeBucket: 'unknown',
      taskFamily: Act0TaskFamilyV1.decision,
      resultKind: 'incorrect',
    );

    expect(
      act0LearningEvidenceRecordFromCompletedDecisionV1(
        decision,
        createdOrder: 1,
      ),
      isNull,
    );
  });

  test('completed decisions append idempotently and retain the latest 200', () {
    var history = const Act0LearningEvidenceHistoryV1();
    final first = _completedDecision(attempt: 1);
    history = history.appendCompletedDecision(first);
    history = history.appendCompletedDecision(first);

    expect(history.records, hasLength(1));
    expect(history.records.single.recordId, first.attemptKey);

    for (
      var attempt = 2;
      attempt <= Act0LearningEvidenceHistoryV1.maxRecords + 1;
      attempt++
    ) {
      history = history.appendCompletedDecision(
        _completedDecision(attempt: attempt),
      );
    }
    expect(
      history.records,
      hasLength(Act0LearningEvidenceHistoryV1.maxRecords),
    );
    expect(history.records.first.createdOrder, 2);
    expect(
      history.records.last.recordId,
      contains('|${Act0LearningEvidenceHistoryV1.maxRecords + 1}'),
    );
  });

  test(
    'action, seat, and sizing completed decisions share one append policy',
    () {
      var history = const Act0LearningEvidenceHistoryV1();
      for (final kind in Act0CompletedDecisionKindV1.values) {
        history = history.appendCompletedDecision(
          _completedDecision(attempt: kind.index + 1, kind: kind),
        );
      }

      expect(history.records, hasLength(3));
      expect(
        history.records.map((record) => record.recordId),
        everyElement(contains('v1|world_1|')),
      );
    },
  );

  test('run key serializes as stable non-telemetry identity', () {
    const key = Act0EvidenceRunKeyV1(
      runId: 'run_v1|world_1|fold_check_call_raise|3',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      runOrdinal: 3,
      runKind: 'lesson',
      startedBy: 'learn_route',
    );

    expect(Act0EvidenceRunKeyV1.tryParse(key.toPayload()), key);
    expect(key.toPayload(), isNot(containsPair('eventId', anything)));
    expect(key.toPayload(), isNot(containsPair('telemetryKey', anything)));
  });

  test(
    'old ungrouped records remain parse-safe and excluded from run queries',
    () {
      final oldPayload = _record(order: 1).toPayload();
      final parsed = Act0LearningEvidenceRecordV1.tryParse(oldPayload);

      expect(parsed, isNotNull);
      expect(parsed!.runId, isEmpty);

      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          parsed,
          _record(
            order: 2,
            runId: 'run_v1|world_1|fold_check_call_raise|1',
            runKind: 'lesson',
            runOrdinal: 1,
          ),
        ],
      );

      expect(
        history.byRunId('run_v1|world_1|fold_check_call_raise|1'),
        hasLength(1),
      );
      expect(history.byRunId(''), isEmpty);
    },
  );

  test('latest run summary uses only grouped current-run records', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(order: 1, runId: 'old-run', runKind: 'lesson', runOrdinal: 1),
        _record(
          order: 2,
          runId: 'current-run',
          runKind: 'lesson',
          runOrdinal: 2,
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
          resultKind: 'correct',
        ),
        _record(
          order: 3,
          runId: 'current-run',
          runKind: 'lesson',
          runOrdinal: 2,
          errorType: 'missed_position_read',
          repairFocusId: 'position_clue',
          skillAtomId: 'position_read',
        ),
        _record(
          order: 4,
          runId: '',
          runKind: '',
          runOrdinal: null,
          errorType: 'missed_action_read',
        ),
      ],
    );

    final summary = history.latestRunSummary();

    expect(summary, isNotNull);
    expect(summary!.runId, 'current-run');
    expect(summary.currentSessionOnly, isTrue);
    expect(summary.spotsPlayed, 2);
    expect(summary.correctCount, 1);
    expect(summary.incorrectCount, 1);
    expect(summary.distinctErrorTypes, <String>['missed_position_read']);
    expect(summary.topRepairFocusId, 'position_clue');
  });

  test('completed decisions append with shell-owned run key', () {
    const runKey = Act0EvidenceRunKeyV1(
      runId: 'run_v1|world_1|fold_check_call_raise|1',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      runOrdinal: 1,
      runKind: 'lesson',
      startedBy: 'learn_route',
    );

    final history = const Act0LearningEvidenceHistoryV1()
        .appendCompletedDecision(_completedDecision(attempt: 1), runKey: runKey)
        .appendCompletedDecision(
          _completedDecision(attempt: 2),
          runKey: runKey,
        );

    expect(history.records, hasLength(2));
    expect(history.records.map((record) => record.runId).toSet(), <String>{
      runKey.runId,
    });
    expect(history.latestRunSummary()?.spotsPlayed, 2);
  });

  test(
    'session summary evidence adapter reads only grouped latest-run records',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            runId: 'old-run',
            runKind: 'lesson',
            runOrdinal: 1,
            isCorrect: true,
            errorType: 'none',
            repairFocusId: '',
            resultKind: 'correct',
          ),
          _record(
            order: 2,
            runId: '',
            runKind: '',
            runOrdinal: null,
            errorType: 'missed_action_read',
            repairFocusId: 'no_bet_yet',
          ),
          _record(
            order: 3,
            runId: 'current-run',
            runKind: 'lesson',
            runOrdinal: 2,
            isCorrect: true,
            errorType: 'none',
            repairFocusId: '',
            resultKind: 'correct',
          ),
          _record(
            order: 4,
            runId: 'current-run',
            runKind: 'lesson',
            runOrdinal: 2,
            errorType: 'missed_position_read',
            repairFocusId: 'position_clue',
            skillAtomId: 'position_read',
          ),
        ],
      );

      final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
        history,
        repairFocusLabelsById: const <String, String>{
          'position_clue': 'position clue',
        },
      );

      expect(viewModel.hasEvidence, isTrue);
      expect(viewModel.title, 'This run');
      expect(viewModel.spotsLine, 'You played 2 spots.');
      expect(viewModel.resultLine, '1 correct / 1 to review.');
      expect(viewModel.repairFocusLine, isNull);
      expect(viewModel.repairCandidateLine, isNull);
      expect(viewModel.currentSessionOnly, isTrue);
      expect(viewModel.claimLines.join(' '), isNot(contains('leak')));
      expect(viewModel.claimLines.join(' '), isNot(contains('Mastered')));
      expect(viewModel.claimLines.join(' '), isNot(contains('AI')));
      expect(viewModel.claimLines.join(' '), isNot(contains('GTO')));
      expect(viewModel.claimLines.join(' '), isNot(contains('solver')));
    },
  );

  test(
    'session summary evidence adapter keeps practice and repair runs separate',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            runId: 'practice-run',
            runKind: 'practice',
            runOrdinal: 1,
            isCorrect: true,
            errorType: 'none',
            repairFocusId: '',
            resultKind: 'correct',
          ),
          _record(
            order: 2,
            runId: 'repair-run',
            runKind: 'repair',
            runOrdinal: 2,
            errorType: 'missed_action_read',
            repairFocusId: 'no_bet_yet',
          ),
        ],
      );

      final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
        history,
        repairFocusLabelsById: const <String, String>{
          'no_bet_yet': 'no-bet-yet clue',
        },
      );

      expect(viewModel.runId, 'repair-run');
      expect(viewModel.runKind, 'repair');
      expect(viewModel.spotsLine, 'You played 1 spot.');
      expect(viewModel.resultLine, '0 correct / 1 to review.');
      expect(viewModel.repairFocusLine, 'You missed Action reads recently.');
      expect(
        viewModel.repairCandidateLine,
        'Suggested focus: Action reads. Worth practicing next.',
      );
      expect(viewModel.practiceLaunchRequest?.targetWorldId, 'world_1');
      expect(
        viewModel.practiceLaunchRequest?.targetLessonId,
        'fold_check_call_raise',
      );
      expect(
        viewModel.practiceLaunchRequest?.targetTaskId,
        'actions_check_drill',
      );
      expect(viewModel.claimLines.join(' '), isNot(contains('no_bet_yet')));
      expect(viewModel.claimLines.join(' '), isNot(contains('action_read')));
      expect(
        viewModel.claimLines.join(' '),
        isNot(contains('Recommended repair')),
      );
    },
  );

  test('session summary repair focus copy uses explicit display allowlist', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(
          order: 1,
          runId: 'current-run',
          runKind: 'lesson',
          runOrdinal: 1,
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          errorType: 'missed_action_read',
        ),
      ],
    );

    final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
      history,
      repairFocusLabelsById: const <String, String>{
        'no_bet_yet': 'no_bet_yet',
        'action_read': 'action_read',
        'missed_action_read': 'missed_action_read',
      },
    );

    expect(viewModel.repairFocusLine, 'You missed Action reads recently.');
    expect(
      viewModel.repairCandidateLine,
      'Suggested focus: Action reads. Worth practicing next.',
    );
    expect(
      viewModel.practiceLaunchRequest?.targetTaskId,
      'actions_check_drill',
    );
    expect(viewModel.claimLines.join(' '), isNot(contains('no_bet_yet')));
    expect(viewModel.claimLines.join(' '), isNot(contains('action_read')));
    expect(
      viewModel.claimLines.join(' '),
      isNot(contains('missed_action_read')),
    );
  });

  test('session summary lifecycle copy distinguishes still-active focus', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(
          order: 1,
          runId: 'previous-run',
          runKind: 'lesson',
          runOrdinal: 1,
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
        ),
        _record(
          order: 2,
          runId: 'current-run',
          runKind: 'lesson',
          runOrdinal: 2,
          repairFocusId: 'position_clue',
          skillAtomId: 'position_read',
          isCorrect: true,
          errorType: 'none',
          resultKind: 'correct',
        ),
      ],
    );

    final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
      history,
    );

    expect(viewModel.repairFocusLine, isNull);
    expect(
      viewModel.repairCandidateLine,
      'Still worth practicing: Action reads.',
    );
    expect(
      viewModel.repairLifecycleState,
      act0SessionSummaryRepairLifecycleStillActiveV1,
    );
    expect(
      viewModel.practiceLaunchRequest?.targetTaskId,
      'actions_check_drill',
    );
  });

  test(
    'session summary lifecycle copy marks repeated miss without overclaiming',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            runId: 'previous-run',
            runKind: 'lesson',
            runOrdinal: 1,
            repairFocusId: 'no_bet_yet',
          ),
          _record(
            order: 2,
            runId: 'current-run',
            runKind: 'lesson',
            runOrdinal: 2,
            repairFocusId: 'no_bet_yet',
          ),
        ],
      );

      final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
        history,
      );

      expect(viewModel.repairFocusLine, 'You missed Action reads recently.');
      expect(
        viewModel.repairCandidateLine,
        'You missed this again: Action reads.',
      );
      expect(
        viewModel.repairLifecycleState,
        act0SessionSummaryRepairLifecycleRepeatedMissV1,
      );
      final copy = viewModel.claimLines.join(' ').toLowerCase();
      expect(copy, isNot(contains('fixed')));
      expect(copy, isNot(contains('mastered')));
      expect(copy, isNot(contains('leak')));
    },
  );

  test('session summary repair candidate copy is claim-safe', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(
          order: 1,
          runId: 'current-run',
          runKind: 'lesson',
          runOrdinal: 1,
          repairFocusId: 'bad_claim',
        ),
      ],
    );

    final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
      history,
      repairFocusLabelsById: const <String, String>{
        'bad_claim': 'AI found your leak',
      },
    );

    expect(viewModel.repairFocusLine, isNull);
    expect(viewModel.repairCandidateLine, isNull);
    expect(viewModel.practiceLaunchRequest, isNull);
    expect(viewModel.claimLines.join(' '), isNot(contains('AI')));
    expect(viewModel.claimLines.join(' '), isNot(contains('leak')));
  });

  test(
    'session summary candidate clears after same-concept correct evidence',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            runId: 'current-run',
            runKind: 'lesson',
            runOrdinal: 1,
            repairFocusId: 'no_bet_yet',
          ),
          _record(
            order: 2,
            runId: 'current-run',
            runKind: 'lesson',
            runOrdinal: 1,
            repairFocusId: 'no_bet_yet',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      );

      final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
        history,
        repairFocusLabelsById: const <String, String>{
          'no_bet_yet': 'no-bet-yet clue',
        },
      );

      expect(viewModel.repairCandidateLine, isNull);
      expect(
        viewModel.repairLifecycleState,
        act0SessionSummaryRepairLifecycleQuietAfterCorrectV1,
      );
      expect(viewModel.practiceLaunchRequest, isNull);
      expect(viewModel.claimLines.join(' '), isNot(contains('quiet')));
      expect(viewModel.claimLines.join(' '), isNot(contains('fixed')));
      expect(viewModel.claimLines.join(' '), isNot(contains('mastered')));
    },
  );

  test(
    'session summary evidence adapter falls back safely without evidence',
    () {
      final viewModel = Act0SessionSummaryEvidenceViewModelV1.fromHistory(
        const Act0LearningEvidenceHistoryV1(),
      );

      expect(viewModel.hasEvidence, isFalse);
      expect(viewModel.claimLines, isEmpty);
      expect(viewModel.title, 'This run');
      expect(viewModel.spotsLine, isEmpty);
      expect(viewModel.resultLine, isEmpty);
      expect(viewModel.repairFocusLine, isNull);
      expect(viewModel.repairCandidateLine, isNull);
    },
  );
}

Act0CompletedDecisionV1 _completedDecision({
  required int attempt,
  Act0CompletedDecisionKindV1 kind = Act0CompletedDecisionKindV1.actionList,
}) => Act0CompletedDecisionV1(
  attemptKey:
      'v1|world_1|fold_check_call_raise|actions_raise_drill|${kind.name}|fold|$attempt',
  worldId: 'world_1',
  lessonId: 'fold_check_call_raise',
  taskId: 'actions_raise_drill',
  sourceTaskId: 'actions_raise_drill',
  decisionKind: kind,
  selectedId: 'fold',
  expectedId: 'check',
  isCorrect: false,
  decisionTimeBucket: 'under_3s',
  taskFamily: Act0TaskFamilyV1.decision,
  resultKind: 'incorrect',
  errorType: 'missed_action_read',
  skillAtomId: 'action_read',
  repairFocusId: 'no_bet_yet',
  missedSignalId: 'no_bet_yet',
);

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String skillAtomId = 'action_read',
  String repairFocusId = 'no_bet_yet',
  String resultKind = 'incorrect',
  bool isCorrect = false,
  String errorType = 'missed_action_read',
  String runId = '',
  String runKind = '',
  int? runOrdinal,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: '$order:world_1:actions_legal_context:fold',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    choiceId: 'fold',
    expectedChoiceId: isCorrect ? 'fold' : 'check',
    isCorrect: isCorrect,
    errorType: errorType,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    decisionTimeBucket: 'under_3s',
    resultKind: resultKind,
    runId: runId,
    runKind: runKind,
    runOrdinal: runOrdinal,
  );
}

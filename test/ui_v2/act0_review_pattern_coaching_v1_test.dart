import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('one-session repeated misses do not create multi-session pattern', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: 'session_a'),
          _record(
            order: 2,
            taskId: 'actions_check_drill',
            sessionId: 'session_a',
          ),
        ],
      ),
    );

    expect(projection.hasPrimaryPattern, isFalse);
    expect(projection.copyLine, isNull);
  });

  test('same-family misses in two sessions create two-session pattern', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: 'session_a'),
          _record(
            order: 4,
            taskId: 'actions_check_drill',
            sessionId: 'session_b',
          ),
        ],
      ),
    );

    final pattern = projection.primaryPattern!;
    expect(
      pattern.patternType,
      act0ReviewPatternTypeRepeatedMissAcrossSessionsV1,
    );
    expect(pattern.patternState, act0ReviewPatternStateActiveV1);
    expect(
      pattern.evidenceStrength,
      act0ReviewPatternStrengthTwoSessionSignalV1,
    );
    expect(pattern.sessionCount, 2);
    expect(pattern.evidenceCount, 2);
    expect(pattern.exactTaskRepeat, isFalse);
    expect(pattern.sameFamilyDifferentTasks, isTrue);
    expect(
      projection.copyLine,
      'This table-reading mistake showed up in more than one session.',
    );
  });

  test('same-family misses in three sessions create repeated signal', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: 'session_a'),
          _record(
            order: 3,
            taskId: 'actions_check_drill',
            sessionId: 'session_b',
          ),
          _record(
            order: 5,
            taskId: 'actions_call_drill',
            sessionId: 'session_c',
          ),
        ],
      ),
    );

    expect(
      projection.primaryPattern!.evidenceStrength,
      act0ReviewPatternStrengthRepeatedMultiSessionSignalV1,
    );
    expect(projection.primaryPattern!.sessionCount, 3);
  });

  test('different families do not combine', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            conceptFamilyId: 'no_bet_yet',
            sessionId: 'session_a',
          ),
          _record(
            order: 2,
            conceptFamilyId: 'pot_to_call',
            sessionId: 'session_b',
          ),
        ],
      ),
    );

    expect(projection.hasPrimaryPattern, isFalse);
  });

  test('same exact task across sessions remains identifiable', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            taskId: 'actions_legal_context',
            sessionId: 'session_a',
          ),
          _record(
            order: 2,
            taskId: 'actions_legal_context',
            sessionId: 'session_b',
          ),
        ],
      ),
    );

    expect(projection.primaryPattern!.exactTaskRepeat, isTrue);
    expect(projection.primaryPattern!.sameFamilyDifferentTasks, isFalse);
  });

  test('failed repair pattern outranks generic repeated miss', () {
    final intent = _repairIntent();
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: 'session_a'),
          _record(
            order: 2,
            taskId: 'actions_check_drill',
            sessionId: 'session_b',
          ),
        ],
      ),
      activeRepairIntents: <Act0RepairIntentV1>[intent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _repairOutcome(intent, sequence: 1, sessionId: 'session_b'),
          _repairOutcome(intent, sequence: 2, sessionId: 'session_c'),
        ],
      ),
    );

    expect(
      projection.primaryPattern!.patternType,
      act0ReviewPatternTypeRepeatedUnsuccessfulRepairV1,
    );
    expect(
      projection.copyLine,
      'This repair has not landed yet across your recent attempts.',
    );
  });

  test('later improved transfer creates conservative improvement pattern', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(
          order: 1,
          taskId: 'actions_legal_context',
          sessionId: 'session_a',
        ),
        _record(
          order: 3,
          taskId: 'actions_check_drill',
          sessionId: 'session_b',
          isCorrect: true,
          resultKind: 'correct',
          errorType: 'none',
        ),
      ],
    );
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: history,
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history),
    );

    expect(
      projection.primaryPattern!.patternType,
      act0ReviewPatternTypeMissThenLaterImprovementV1,
    );
    expect(
      projection.primaryPattern!.patternState,
      act0ReviewPatternStateImprovingV1,
    );
    expect(
      projection.primaryPattern!.evidenceStrength,
      act0ReviewPatternStrengthImprovementObservedV1,
    );
    expect(
      projection.copyLine,
      'You missed this earlier, then handled it correctly on a later hand.',
    );
  });

  test('held transfer does not create mastery language', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(
          order: 1,
          taskId: 'actions_legal_context',
          sessionId: 'session_a',
          isCorrect: true,
          resultKind: 'correct',
          errorType: 'none',
        ),
        _record(
          order: 3,
          taskId: 'actions_check_drill',
          sessionId: 'session_b',
          isCorrect: true,
          resultKind: 'correct',
          errorType: 'none',
        ),
      ],
    );
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: history,
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history),
    );
    final text = projection.toPayload().toString();

    expect(projection.hasPrimaryPattern, isFalse);
    expect(text, isNot(contains('master')));
    expect(text, isNot(contains('weakest')));
    expect(text, isNot(contains('%')));
  });

  test('malformed or missing session ids fail closed', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: ''),
          _record(order: 2, sessionId: 'session_b'),
        ],
      ),
    );

    expect(projection.hasPrimaryPattern, isFalse);
  });

  test(
    'deterministic selection among two patterns uses latest order then family id',
    () {
      final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
        learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _record(
              order: 1,
              conceptFamilyId: 'z_family',
              sessionId: 'session_a',
            ),
            _record(
              order: 2,
              conceptFamilyId: 'z_family',
              sessionId: 'session_b',
            ),
            _record(
              order: 3,
              conceptFamilyId: 'a_family',
              sessionId: 'session_c',
            ),
            _record(
              order: 4,
              conceptFamilyId: 'a_family',
              sessionId: 'session_d',
            ),
          ],
        ),
      );

      expect(projection.primaryPattern!.conceptFamilyId, 'a_family');
    },
  );

  test(
    'resolved historical evidence does not resurrect active Review card',
    () {
      final history = const Act0ReviewMistakeHistoryV1()
          .appendCompletedDecision(_decision(attempt: 1));
      final reviewState = Act0ReviewResolutionStateV1.fromSources(
        reviewMistakeHistory: history,
        activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
        repairOutcomeProjection: const Act0RepairOutcomeProjectionV1(
          outcomes: <Act0RepairOutcomeV1>[_successfulOutcome],
        ),
      );
      final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
        learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _record(order: 1, sessionId: 'session_a'),
            _record(order: 2, sessionId: 'session_b'),
          ],
        ),
        reviewMistakeHistory: history,
        reviewResolutionState: reviewState,
      );

      expect(reviewState.visibleReviewItemIds, isEmpty);
      expect(
        projection.primaryPattern!.patternState,
        act0ReviewPatternStateHistoricalV1,
      );
    },
  );

  test('active pattern does not create or reorder queue items', () {
    final intent = _repairIntent();
    final before = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: <Act0RepairIntentV1>[intent],
    ).toPayload();

    Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: 'session_a'),
          _record(order: 2, sessionId: 'session_b'),
        ],
      ),
      activeRepairIntents: <Act0RepairIntentV1>[intent],
    );
    final after = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: <Act0RepairIntentV1>[intent],
    ).toPayload();

    expect(after, before);
  });

  test('projection is deterministic across reload', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(order: 2, sessionId: 'session_b'),
        _record(order: 1, sessionId: 'session_a'),
      ],
    );

    final first = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: history,
    );
    final second = Act0ReviewPatternCoachingProjectionV1.tryParse(
      first.toPayload(),
    );

    expect(second.toPayload(), first.toPayload());
  });

  test('copy is claim safe', () {
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: 'session_a'),
          _record(order: 2, sessionId: 'session_b'),
        ],
      ),
    );
    final text = projection.toPayload().toString();

    for (final forbidden in <String>[
      'biggest leak',
      'always',
      'master',
      '%',
      'AI',
      'weakest',
      'score',
      'solver',
    ]) {
      expect(text, isNot(contains(forbidden)));
    }
  });

  test('source has no Flutter telemetry persistence or dashboard owner', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('dashboard')));
    expect(source, isNot(contains('radar')));
    expect(source, isNot(contains('percentage')));
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String conceptFamilyId = 'no_bet_yet',
  String taskId = 'actions_legal_context',
  String sessionId = 'session_a',
  bool isCorrect = false,
  String resultKind = 'incorrect',
  String errorType = 'missed_action_read',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: taskId,
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: errorType,
    conceptFamilyId: conceptFamilyId,
    repairFocusId: conceptFamilyId,
    skillAtomId: 'action_read',
    decisionTimeBucket: '3_to_10s',
    resultKind: resultKind,
    sessionId: sessionId,
  );
}

Act0CompletedDecisionV1 _decision({required int attempt}) {
  return Act0CompletedDecisionV1(
    attemptKey: 'attempt_$attempt',
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    sourceTaskId: 'actions_legal_context',
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
}

Act0RepairIntentV1 _repairIntent() => _activeRepairIntent;

const Act0RepairIntentV1 _activeRepairIntent = Act0RepairIntentV1(
  sourceWorldId: 'world_1',
  sourceLessonId: 'fold_check_call_raise',
  sourceTaskId: 'actions_legal_context',
  choiceId: 'fold',
  result: 'incorrect',
  errorType: 'missed_action_read',
  missedSignalId: 'no_bet_yet',
  missedSignalLabel: 'No bet yet',
  skillAtomId: 'action_read',
  skillLabel: 'Action read',
  targetWorldId: 'world_1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_check_drill',
  mappingType: 'repair',
  reasonCode: 'same_signal_action_read_no_bet_yet',
);

const Act0RepairOutcomeV1 _successfulOutcome = Act0RepairOutcomeV1(
  sourceTaskId: 'actions_legal_context',
  repairTaskId: 'actions_check_drill',
  repairFocusKey:
      '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
  queueItemId:
      'practice_repair_queue_v1|active|75:21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
  targetWorldId: 'world_1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_check_drill',
  selectedChoiceId: 'check',
  correctChoiceId: 'check',
  isCorrect: true,
  outcomeState: act0RepairOutcomeStateCorrectV1,
  sequence: 3,
  sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
);

Act0RepairOutcomeV1 _repairOutcome(
  Act0RepairIntentV1 intent, {
  required int sequence,
  required String sessionId,
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: intent.sourceTaskId,
    repairTaskId: intent.targetTaskId,
    repairFocusKey: repairQueueIdentityKeyForAct0RepairIntentV1(intent),
    queueItemId: queueItemIdForAct0RepairIntentV1(intent),
    targetWorldId: intent.targetWorldId,
    targetLessonId: intent.targetLessonId,
    targetTaskId: intent.targetTaskId,
    selectedChoiceId: 'fold',
    correctChoiceId: 'check',
    isCorrect: false,
    outcomeState: act0RepairOutcomeStateStillNeedsRepV1,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
    sessionId: sessionId,
  );
}

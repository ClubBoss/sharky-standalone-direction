import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

void main() {
  test('memory groups decisions by repair focus with stable fallbacks', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(order: 1, repairFocusId: 'no_bet_yet'),
        _record(
          order: 2,
          repairFocusId: 'no_bet_yet',
          isCorrect: true,
          errorType: 'none',
          resultKind: 'correct',
        ),
        _record(
          order: 3,
          repairFocusId: '',
          skillAtomId: 'position_read',
          errorType: 'missed_position_read',
        ),
      ],
    );

    final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      history,
    );

    expect(memory.families.map((family) => family.conceptFamilyId), <String>[
      'no_bet_yet',
      'position_read',
    ]);
    expect(memory.families.first.correctCount, 1);
    expect(memory.families.first.incorrectCount, 1);
    expect(memory.families.first.latestDecisionTimeBucket, 'under_3s');
    expect(memory.families.last.repairFocusId, isEmpty);
    expect(memory.families.last.skillAtomId, 'position_read');
  });

  test(
    'candidate prefers latest incorrect families before repaired families',
    () {
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'repeat_focus'),
          _record(order: 2, repairFocusId: 'repeat_focus'),
          _record(
            order: 3,
            repairFocusId: 'repeat_focus',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
          _record(order: 4, repairFocusId: 'fresh_focus'),
        ],
      );

      final candidate = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      ).nextRepairCandidate;

      expect(candidate, isNotNull);
      expect(candidate!.conceptFamilyId, 'fresh_focus');
      expect(candidate.selectionReasonCode, 'latest_incorrect_family');
      expect(candidate.incorrectCount, 1);
    },
  );

  test('candidate prefers repeated misses and resolves ties by id', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _record(order: 1, repairFocusId: 'z_focus'),
        _record(order: 2, repairFocusId: 'a_focus'),
        _record(order: 3, repairFocusId: 'z_focus'),
        _record(order: 4, repairFocusId: 'b_focus'),
      ],
    );

    var candidate = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      history,
    ).nextRepairCandidate;
    expect(candidate?.conceptFamilyId, 'z_focus');
    expect(candidate?.selectionReasonCode, 'repeated_incorrect_family');

    candidate = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'z_focus'),
          _record(order: 2, repairFocusId: 'a_focus'),
        ],
      ),
    ).nextRepairCandidate;
    expect(candidate?.conceptFamilyId, 'a_focus');
    expect(candidate?.selectionReasonCode, 'latest_incorrect_family');
  });

  test('correct-only history does not invent a repair candidate', () {
    final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(memory.families.single.correctCount, 1);
    expect(memory.nextRepairCandidate, isNull);
  });

  test('latest correct evidence on the same concept clears candidate', () {
    final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'no_bet_yet'),
          _record(
            order: 2,
            repairFocusId: 'no_bet_yet',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(
      memory.families.single.resolutionState,
      act0RepairCandidateResolutionClearedV1,
    );
    expect(memory.nextRepairCandidate, isNull);
  });

  test('unrelated correct evidence does not clear active candidate', () {
    final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'no_bet_yet'),
          _record(
            order: 2,
            repairFocusId: 'position_clue',
            skillAtomId: 'position_read',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    final candidate = memory.nextRepairCandidate;

    expect(candidate, isNotNull);
    expect(candidate!.conceptFamilyId, 'no_bet_yet');
    expect(
      memory.families
          .singleWhere((family) => family.conceptFamilyId == 'no_bet_yet')
          .resolutionState,
      act0RepairCandidateResolutionActiveV1,
    );
  });

  test('repeated miss stays active until same concept correct evidence', () {
    final activeMemory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'no_bet_yet'),
          _record(order: 2, repairFocusId: 'no_bet_yet'),
        ],
      ),
    );

    expect(activeMemory.nextRepairCandidate?.conceptFamilyId, 'no_bet_yet');
    expect(
      activeMemory.nextRepairCandidate?.selectionReasonCode,
      'repeated_incorrect_family',
    );

    final clearedMemory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'no_bet_yet'),
          _record(order: 2, repairFocusId: 'no_bet_yet'),
          _record(
            order: 3,
            repairFocusId: 'no_bet_yet',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(
      clearedMemory.families.single.resolutionState,
      act0RepairCandidateResolutionClearedV1,
    );
    expect(clearedMemory.nextRepairCandidate, isNull);
  });

  test('candidate tie break uses stable id when active scores match', () {
    const memory = Act0ConceptFamilyRepairMemoryV1(
      families: <Act0ConceptFamilyRepairSummaryV1>[
        Act0ConceptFamilyRepairSummaryV1(
          conceptFamilyId: 'z_focus',
          repairFocusId: 'z_focus',
          skillAtomId: 'action_read',
          correctCount: 0,
          incorrectCount: 1,
          latestOrder: 7,
          latestIncorrectOrder: 7,
          latestWasIncorrect: true,
          latestErrorType: 'missed_action_read',
          latestDecisionTimeBucket: 'under_3s',
          slowDecisionCount: 0,
          resolutionState: act0RepairCandidateResolutionActiveV1,
        ),
        Act0ConceptFamilyRepairSummaryV1(
          conceptFamilyId: 'a_focus',
          repairFocusId: 'a_focus',
          skillAtomId: 'action_read',
          correctCount: 0,
          incorrectCount: 1,
          latestOrder: 7,
          latestIncorrectOrder: 7,
          latestWasIncorrect: true,
          latestErrorType: 'missed_action_read',
          latestDecisionTimeBucket: 'under_3s',
          slowDecisionCount: 0,
          resolutionState: act0RepairCandidateResolutionActiveV1,
        ),
      ],
    );

    expect(memory.nextRepairCandidate?.conceptFamilyId, 'a_focus');
  });

  test('repair memory source has no UI, AI, solver, or route dependency', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('lib/ai')));
    expect(source, isNot(contains('solver')));
    expect(source, isNot(contains('GTO')));
    expect(source, isNot(contains('Navigator')));
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String repairFocusId = 'no_bet_yet',
  String skillAtomId = 'action_read',
  String errorType = 'missed_action_read',
  String decisionTimeBucket = 'under_3s',
  bool isCorrect = false,
  String resultKind = 'incorrect',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: errorType,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    decisionTimeBucket: decisionTimeBucket,
    resultKind: resultKind,
  );
}

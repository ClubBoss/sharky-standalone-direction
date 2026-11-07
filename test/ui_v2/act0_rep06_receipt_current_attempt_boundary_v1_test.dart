import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_receipt_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

// REP-06 source-level falsifier, not a native/route/persistence test.
// onChooseOption captures the receipt before onCompletedDecision appends the
// current repair record. An older retained success must not survive a new miss
// as proof that the current repair has already held on a later check.
void main() {
  test(
    'a new miss prevents old recheck proof from upgrading current repair',
    () {
      final receipt = _receipt(currentCorrect: true);
      expect(receipt.level, Act0LearningReceiptLevelV1.sameClueRepaired);
      expect(receipt.sessionSummaryLines, <String>[
        'The same clue was repaired.',
        'Pass a later recheck.',
      ]);
    },
  );

  test('a current failed repair still caps the old successful recheck', () {
    final receipt = _receipt(currentCorrect: false);
    expect(receipt.level, Act0LearningReceiptLevelV1.attempted);
    expect(receipt.remainingStatus, 'Repair remains unresolved.');
  });

  test('fresh independent repair and later recheck prove the new attempt', () {
    final receipt = _receipt(
      currentCorrect: true,
      afterMiss: <Act0LearningEvidenceRecordV1>[
        _record(4, Act0ReviewKindV1.immediateRepair, true),
        _record(5, Act0ReviewKindV1.originalSourceRecheck, true),
      ],
    );
    expect(receipt.level, Act0LearningReceiptLevelV1.laterRecheckHeld);
    expect(receipt.latestOutcome, 'A later recheck was correct.');
  });

  test('a recheck alone cannot reuse a repair anchor before the new miss', () {
    final receipt = _receipt(
      currentCorrect: true,
      afterMiss: <Act0LearningEvidenceRecordV1>[
        _record(4, Act0ReviewKindV1.originalSourceRecheck, true),
      ],
    );
    expect(receipt.level, Act0LearningReceiptLevelV1.sameClueRepaired);
    expect(receipt.nextEvidenceRequirement, 'Pass a later recheck.');
  });
}

Act0LearningReceiptV1 _receipt({
  required bool currentCorrect,
  List<Act0LearningEvidenceRecordV1> afterMiss = const [],
}) => Act0LearningReceiptV1.fromEvidence(
  focusLabel: 'No bet yet',
  sourceTaskId: 'source',
  repairOutcomes: <Act0RepairOutcomeV1>[
    _outcome(1, true),
    _outcome(2, currentCorrect),
  ],
  learningEvidence: Act0LearningEvidenceHistoryV1(
    records: <Act0LearningEvidenceRecordV1>[
      _record(1, Act0ReviewKindV1.immediateRepair, true),
      _record(2, Act0ReviewKindV1.originalSourceRecheck, true),
      _record(3, Act0ReviewKindV1.initialAssessment, false),
      ...afterMiss,
    ],
  ),
);

Act0RepairOutcomeV1 _outcome(int sequence, bool correct) => Act0RepairOutcomeV1(
  sourceTaskId: 'source',
  repairTaskId: 'repair',
  repairFocusKey: 'no_bet_yet',
  queueItemId: 'q$sequence',
  targetWorldId: 'world_1',
  targetLessonId: 'lesson',
  targetTaskId: 'repair',
  selectedChoiceId: correct ? 'check' : 'call',
  correctChoiceId: 'check',
  isCorrect: correct,
  outcomeState: correct
      ? act0RepairOutcomeStateCorrectV1
      : act0RepairOutcomeStateStillNeedsRepV1,
  sequence: sequence,
  sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
);

Act0LearningEvidenceRecordV1 _record(
  int order,
  Act0ReviewKindV1 kind,
  bool correct,
) => Act0LearningEvidenceRecordV1(
  recordId: 'r$order',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: 'lesson',
  taskId: order == 1 ? 'repair' : 'source',
  sourceTaskId: 'source',
  choiceId: correct ? 'check' : 'call',
  expectedChoiceId: 'check',
  isCorrect: correct,
  errorType: correct ? 'none' : 'missed_action_read',
  repairFocusId: 'no_bet_yet',
  skillAtomId: 'action_read',
  decisionTimeBucket: '3_to_10s',
  resultKind: correct ? 'correct' : 'incorrect',
  recordedAtUtc: DateTime.utc(2026, 11, order),
  sessionId: 'session_$order',
  reviewKind: kind,
  assistanceKind: Act0DecisionAssistanceV1.none,
);

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_receipt_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

// Reducer fixtures: these prove assistance provenance, not native traversal,
// current-authored transfer, elapsed due time, XP, or persistence.
void main() {
  for (final repairKind in <Act0ReviewKindV1>[
    Act0ReviewKindV1.immediateRepair,
    Act0ReviewKindV1.alternateSameSignal,
  ]) {
    for (final assistance in Act0DecisionAssistanceV1.values) {
      test(
        '${repairKind.name}: ${assistance.name} recheck requires independent evidence',
        () {
          final receipt = _receipt(
            repairKind: repairKind,
            recheckAssistance: assistance,
          );
          final independent = assistance == Act0DecisionAssistanceV1.none;
          expect(
            receipt.level,
            independent
                ? Act0LearningReceiptLevelV1.laterRecheckHeld
                : Act0LearningReceiptLevelV1.sameClueRepaired,
          );
          if (!independent) {
            expect(
              receipt.sessionSummaryLines,
              isNot(contains('A later recheck was correct.')),
            );
            expect(receipt.nextEvidenceRequirement, 'Pass a later recheck.');
          }
        },
      );

      test(
        '${repairKind.name}: ${assistance.name} repair cannot anchor proof',
        () {
          final receipt = _receipt(
            repairKind: repairKind,
            repairAssistance: assistance,
          );
          expect(
            receipt.level,
            assistance == Act0DecisionAssistanceV1.none
                ? Act0LearningReceiptLevelV1.laterRecheckHeld
                : Act0LearningReceiptLevelV1.sameClueRepaired,
          );
        },
      );
    }
  }

  test('serialized assisted recheck stays insufficient after restore', () {
    final history = Act0LearningEvidenceHistoryV1(
      records:
          <Act0LearningEvidenceRecordV1>[
                _record(
                  1,
                  Act0ReviewKindV1.immediateRepair,
                  Act0DecisionAssistanceV1.none,
                ),
                _record(
                  2,
                  Act0ReviewKindV1.originalSourceRecheck,
                  Act0DecisionAssistanceV1.quickHint,
                ),
              ]
              .map(
                (record) =>
                    Act0LearningEvidenceRecordV1.tryParse(record.toPayload())!,
              )
              .toList(),
    );
    final receipt = _fromHistory(history);
    expect(receipt.level, Act0LearningReceiptLevelV1.sameClueRepaired);
    expect(receipt.nextEvidenceRequirement, 'Pass a later recheck.');
  });

  test(
    'same-session independent recheck still does not prove later recall',
    () {
      final receipt = _fromHistory(
        Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _record(
              1,
              Act0ReviewKindV1.immediateRepair,
              Act0DecisionAssistanceV1.none,
            ),
            _record(
              2,
              Act0ReviewKindV1.originalSourceRecheck,
              Act0DecisionAssistanceV1.none,
              sessionId: 'session_1',
            ),
          ],
        ),
      );
      expect(receipt.level, Act0LearningReceiptLevelV1.sameClueRepaired);
    },
  );
}

Act0LearningReceiptV1 _receipt({
  required Act0ReviewKindV1 repairKind,
  Act0DecisionAssistanceV1 repairAssistance = Act0DecisionAssistanceV1.none,
  Act0DecisionAssistanceV1 recheckAssistance = Act0DecisionAssistanceV1.none,
}) => _fromHistory(
  Act0LearningEvidenceHistoryV1(
    records: <Act0LearningEvidenceRecordV1>[
      _record(1, repairKind, repairAssistance),
      _record(2, Act0ReviewKindV1.originalSourceRecheck, recheckAssistance),
    ],
  ),
);

Act0LearningReceiptV1 _fromHistory(Act0LearningEvidenceHistoryV1 history) =>
    Act0LearningReceiptV1.fromEvidence(
      focusLabel: 'No bet yet',
      sourceTaskId: 'source',
      repairOutcomes: const <Act0RepairOutcomeV1>[
        Act0RepairOutcomeV1(
          sourceTaskId: 'source',
          repairTaskId: 'repair',
          repairFocusKey: 'no_bet_yet',
          queueItemId: 'q',
          targetWorldId: 'world_1',
          targetLessonId: 'lesson',
          targetTaskId: 'repair',
          selectedChoiceId: 'check',
          correctChoiceId: 'check',
          isCorrect: true,
          outcomeState: act0RepairOutcomeStateCorrectV1,
          sequence: 1,
          sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        ),
      ],
      learningEvidence: history,
    );

Act0LearningEvidenceRecordV1 _record(
  int order,
  Act0ReviewKindV1 kind,
  Act0DecisionAssistanceV1 assistance, {
  String? sessionId,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'r$order',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: 'lesson',
  taskId: order == 1 ? 'repair' : 'source',
  sourceTaskId: 'source',
  choiceId: 'check',
  expectedChoiceId: 'check',
  isCorrect: true,
  errorType: 'none',
  repairFocusId: 'no_bet_yet',
  skillAtomId: 'action_read',
  decisionTimeBucket: '3_to_10s',
  resultKind: 'correct',
  recordedAtUtc: DateTime.utc(2026, 11, order),
  sessionId: sessionId ?? 'session_$order',
  reviewKind: kind,
  assistanceKind: assistance,
);

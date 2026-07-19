import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_causal_feedback_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_receipt_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('Act0 causal feedback contract', () {
    test('uses authored reason and a structured clue without mind-reading', () {
      final feedback = Act0CausalFeedbackV1.fromStructured(
        quality: Act0FeedbackQualityV1.wrong,
        authoredReason:
            'No bet faces Hero yet, so checking keeps the hand moving.',
        chosenAction: 'Call',
        preferredAction: 'Check',
        betterAction: 'Check',
        structuredClue: 'No bet yet',
      );

      expect(feedback.classification, 'incorrect');
      expect(feedback.betterAction, 'Check');
      expect(feedback.whyChosen, contains('No bet faces Hero'));
      expect(feedback.nextHandInstruction, contains('No bet yet'));
      expect(feedback.whyChosen.toLowerCase(), isNot(contains('understood')));
    });

    test('falls back safely when authored evidence is absent', () {
      final feedback = Act0CausalFeedbackV1.fromStructured(
        quality: Act0FeedbackQualityV1.correct,
        authoredReason: '',
        chosenAction: 'Check',
        preferredAction: 'Check',
        betterAction: '',
      );
      expect(feedback.whyChosen, 'Check the visible spot before choosing.');
      expect(feedback.hasCounterfactual, isFalse);
    });
  });

  group('Act0 learning receipt ladder', () {
    test('does not upgrade same-clue repair from event order alone', () {
      final receipt = Act0LearningReceiptV1.fromEvidence(
        focusLabel: 'No bet yet',
        sourceTaskId: 'source',
        repairOutcomes: <Act0RepairOutcomeV1>[_repair(true)],
        learningEvidence: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _evidence(
              50,
              taskId: 'source',
              sourceTaskId: 'source',
              kind: Act0ReviewKindV1.exactReplay,
            ),
          ],
        ),
      );
      expect(receipt.level, Act0LearningReceiptLevelV1.sameClueRepaired);
      expect(receipt.visibleCopy, contains('later check'));
    });

    test('requires a valid later recheck then a different transfer spot', () {
      final held = Act0LearningReceiptV1.fromEvidence(
        focusLabel: 'No bet yet',
        sourceTaskId: 'source',
        repairOutcomes: <Act0RepairOutcomeV1>[_repair(true)],
        learningEvidence: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _evidence(
              2,
              taskId: 'source',
              sourceTaskId: 'source',
              kind: Act0ReviewKindV1.originalSourceRecheck,
            ),
          ],
        ),
      );
      expect(held.level, Act0LearningReceiptLevelV1.sameClueRepaired);

      final transferred = Act0LearningReceiptV1.fromEvidence(
        focusLabel: 'No bet yet',
        sourceTaskId: 'source',
        repairOutcomes: <Act0RepairOutcomeV1>[_repair(true)],
        learningEvidence: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _evidence(
              2,
              taskId: 'source',
              sourceTaskId: 'source',
              kind: Act0ReviewKindV1.originalSourceRecheck,
            ),
            _evidence(
              3,
              taskId: 'transfer',
              sourceTaskId: 'source',
              kind: Act0ReviewKindV1.unseenTransfer,
            ),
          ],
        ),
      );
      expect(transferred.level, Act0LearningReceiptLevelV1.sameClueRepaired);
    });

    test('keeps failed and malformed evidence at attempted', () {
      final receipt = Act0LearningReceiptV1.fromEvidence(
        focusLabel: '',
        sourceTaskId: 'source',
        repairOutcomes: <Act0RepairOutcomeV1>[_repair(false)],
        learningEvidence: const Act0LearningEvidenceHistoryV1(),
      );
      expect(receipt.level, Act0LearningReceiptLevelV1.attempted);
      expect(receipt.focusLabel, 'This clue');
    });
  });
}

Act0RepairOutcomeV1 _repair(bool correct) => Act0RepairOutcomeV1(
  sourceTaskId: 'source',
  repairTaskId: 'repair',
  repairFocusKey: 'no_bet_yet',
  queueItemId: 'q',
  targetWorldId: 'world_1',
  targetLessonId: 'lesson',
  targetTaskId: 'repair',
  selectedChoiceId: correct ? 'check' : 'call',
  correctChoiceId: 'check',
  isCorrect: correct,
  outcomeState: correct
      ? act0RepairOutcomeStateCorrectV1
      : act0RepairOutcomeStateStillNeedsRepV1,
  sequence: 1,
  sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
);

Act0LearningEvidenceRecordV1 _evidence(
  int order, {
  required String taskId,
  required String sourceTaskId,
  required Act0ReviewKindV1 kind,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'r$order',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: 'lesson',
  taskId: taskId,
  sourceTaskId: sourceTaskId,
  choiceId: 'check',
  expectedChoiceId: 'check',
  isCorrect: true,
  errorType: 'none',
  conceptFamilyId: 'action_read',
  repairFocusId: 'no_bet_yet',
  skillAtomId: 'action_read',
  decisionTimeBucket: '3_to_10s',
  resultKind: 'correct',
  recordedAtUtc: DateTime.utc(2026, 7, order),
  reviewKind: kind,
);

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';

void main() {
  test('projection groups evidence by skill atom and computes counts', () {
    final projection =
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          Act0LearningEvidenceHistoryV1(
            records: <Act0LearningEvidenceRecordV1>[
              _record(order: 1, skillAtomId: 'position_read', isCorrect: true),
              _record(order: 2, skillAtomId: 'action_read', isCorrect: true),
              _record(order: 3, skillAtomId: 'action_read'),
              _record(order: 4, skillAtomId: 'action_read', isCorrect: true),
            ],
          ),
        );

    expect(projection.signals.map((signal) => signal.skillAtomId), <String>[
      'action_read',
      'position_read',
    ]);
    final actionRead = projection.signals.first;
    expect(actionRead.attemptCount, 3);
    expect(actionRead.correctCount, 2);
    expect(actionRead.incorrectCount, 1);
    expect(actionRead.accuracyPercent, 67);
    expect(actionRead.worldIds, <String>['world_1']);
    expect(actionRead.lessonIds, <String>['fold_check_call_raise']);
    expect(actionRead.latestOrder, 4);
  });

  test('minimum attempt threshold blocks eligibility', () {
    final projection =
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          Act0LearningEvidenceHistoryV1(
            records: <Act0LearningEvidenceRecordV1>[
              _record(order: 1, isCorrect: true),
              _record(order: 2, isCorrect: true),
              _record(order: 3),
              _record(order: 4, isCorrect: true),
            ],
          ),
        );

    final signal = projection.signals.single;
    expect(signal.sampleThreshold, act0ProfileEvidenceMinimumAttemptsV1);
    expect(signal.sampleThresholdMet, isFalse);
    expect(signal.isCapabilityEligible, isFalse);
    expect(
      signal.eligibilityState,
      act0ProfileEvidenceStateInsufficientSampleV1,
    );
  });

  test(
    'eligible signal appears only after threshold and minimum correct count',
    () {
      final projection =
          Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
            Act0LearningEvidenceHistoryV1(
              records: <Act0LearningEvidenceRecordV1>[
                _record(order: 1, isCorrect: true),
                _record(order: 2, isCorrect: true),
                _record(order: 3),
                _record(order: 4, isCorrect: true),
                _record(order: 5),
              ],
            ),
          );

      final signal = projection.signals.single;
      expect(signal.attemptCount, 5);
      expect(signal.correctCount, 3);
      expect(signal.sampleThresholdMet, isTrue);
      expect(signal.positiveSignalThresholdMet, isTrue);
      expect(signal.isCapabilityEligible, isTrue);
      expect(signal.eligibilityState, act0ProfileEvidenceStateEligibleSignalV1);
    },
  );

  test(
    'needs more practice state requires sample but not positive threshold',
    () {
      final projection =
          Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
            Act0LearningEvidenceHistoryV1(
              records: <Act0LearningEvidenceRecordV1>[
                _record(order: 1, isCorrect: true),
                _record(order: 2),
                _record(order: 3),
                _record(order: 4),
                _record(order: 5),
              ],
            ),
          );

      final signal = projection.signals.single;
      expect(signal.sampleThresholdMet, isTrue);
      expect(signal.positiveSignalThresholdMet, isFalse);
      expect(signal.isCapabilityEligible, isFalse);
      expect(
        signal.eligibilityState,
        act0ProfileEvidenceStateNeedsMorePracticeV1,
      );
    },
  );

  test(
    'projection does not use review mistake history as capability source',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart',
      ).readAsStringSync();

      expect(source, contains('act0_learning_evidence_contract_v1.dart'));
      expect(source, isNot(contains('act0_review_mistake_history')));
      expect(source, isNot(contains('ReviewMistakeHistory')));
    },
  );

  test('signals expose no mastery leak AI GTO solver fields or copy', () {
    final projection =
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          Act0LearningEvidenceHistoryV1(
            records: <Act0LearningEvidenceRecordV1>[
              _record(order: 1, isCorrect: true),
              _record(order: 2, isCorrect: true),
              _record(order: 3, isCorrect: true),
              _record(order: 4, isCorrect: true),
              _record(order: 5, isCorrect: true),
            ],
          ),
        );

    final payloadText = projection.toPayload().toString().toLowerCase();
    expect(payloadText, isNot(contains('master')));
    expect(payloadText, isNot(contains('leak')));
    expect(payloadText, isNot(contains('ai detected')));
    expect(payloadText, isNot(contains('gto')));
    expect(payloadText, isNot(contains('solver')));
    expect(payloadText, isNot(contains('strongest')));
    expect(payloadText, isNot(contains('based on your last')));
  });

  test('projection ordering is deterministic and not accuracy ranked', () {
    final projection =
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          Act0LearningEvidenceHistoryV1(
            records: <Act0LearningEvidenceRecordV1>[
              _record(order: 1, skillAtomId: 'position_read', isCorrect: true),
              _record(order: 2, skillAtomId: 'action_read'),
              _record(order: 3, skillAtomId: 'position_read', isCorrect: true),
              _record(order: 4, skillAtomId: 'action_read'),
              _record(order: 5, skillAtomId: 'position_read', isCorrect: true),
              _record(order: 6, skillAtomId: 'action_read'),
              _record(order: 7, skillAtomId: 'position_read', isCorrect: true),
              _record(order: 8, skillAtomId: 'action_read'),
              _record(order: 9, skillAtomId: 'position_read', isCorrect: true),
              _record(order: 10, skillAtomId: 'action_read'),
            ],
          ),
        );

    expect(projection.signals.map((signal) => signal.skillAtomId), <String>[
      'action_read',
      'position_read',
    ]);
    expect(projection.signals.first.accuracyPercent, 0);
    expect(projection.signals.last.accuracyPercent, 100);
  });

  test('serializer and parser roundtrip projection payload', () {
    final projection =
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          Act0LearningEvidenceHistoryV1(
            records: <Act0LearningEvidenceRecordV1>[
              _record(order: 1, isCorrect: true),
              _record(order: 2, isCorrect: true),
              _record(order: 3),
              _record(order: 4, isCorrect: true),
              _record(order: 5),
            ],
          ),
        );

    final parsed = Act0ProfileEvidenceProjectionV1.tryParse(
      projection.toPayload(),
    );

    expect(parsed, isNotNull);
    expect(parsed!.signals, projection.signals);
    expect(
      Act0ProfileEvidenceProjectionV1.tryParse(<Map<String, Object?>>[
        <String, Object?>{
          ...projection.toPayload().single,
          'eligibilityState': 'mastered_v1',
        },
      ])!.signals,
      isEmpty,
    );
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String skillAtomId = 'action_read',
  bool isCorrect = false,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: '$order:world_1:fold_check_call_raise:$skillAtomId',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: '${skillAtomId}_task',
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    repairFocusId: isCorrect ? '' : 'no_bet_yet',
    skillAtomId: skillAtomId,
    decisionTimeBucket: 'under_3s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
  );
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

void main() {
  test('unresolved repair wins priority over every other source', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      activeRepairIntents: <Act0RepairIntentV1>[_repairIntent()],
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(
            conceptFamilyId: 'transfer_focus',
            lastOutcome: act0ConceptFamilyOutcomeRepairSucceededV1,
            lastSeenAt: 8,
          ),
        ],
      ),
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(
            conceptFamilyId: 'transfer_focus',
            verdict: act0LearningTransferImprovedV1,
          ),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonContinueUnresolvedRepairV1);
    expect(reason.conceptFamilyId, 'no_bet_yet');
    expect(reason.sourceTaskId, 'actions_legal_context');
    expect(reason.evidenceKind, act0ReturnReasonEvidenceActiveRepairV1);
    expect(reason.messageKey, act0ReturnReasonMessageContinueRepairV1);
    expect(reason.priorityClass, 0);
    expect(
      reason.copyLine,
      'You missed this clue last time. One more clean rep will keep it visible.',
    );
  });

  test('unsuccessful repair beats generic recent focus', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(
            conceptFamilyId: 'recent_focus',
            lastOutcome: act0ConceptFamilyOutcomeMissedV1,
            lastSeenAt: 12,
          ),
          _family(
            conceptFamilyId: 'repair_focus',
            lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
            lastAttemptAt: 7,
            lastSeenAt: 7,
          ),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonRetryNotYetSucceededV1);
    expect(reason.conceptFamilyId, 'repair_focus');
    expect(reason.evidenceKind, act0ReturnReasonEvidenceConceptFamilyStateV1);
    expect(reason.priorityClass, 1);
    expect(reason.copyLine, 'Your last repair did not land yet. Start there.');
  });

  test('improved transfer creates conservative reinforcement reason', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(verdict: act0LearningTransferImprovedV1),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonReinforceRecentImprovementV1);
    expect(reason.evidenceKind, act0ReturnReasonEvidenceTransferMeasurementV1);
    expect(reason.sourceTaskId, 'actions_check_transfer');
    expect(reason.sourceSessionId, 'session_v1|2');
    expect(
      reason.copyLine,
      'You handled this clue better on a later hand. Reinforce it once more.',
    );
    expect(reason.copyLine, isNot(contains('master')));
    expect(reason.copyLine, isNot(contains('%')));
  });

  test('held transfer reinforces without mastery claim', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(verdict: act0LearningTransferHeldV1),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonReinforceRecentImprovementV1);
    expect(reason.copyLine, isNot(contains('mastered')));
    expect(reason.copyLine, isNot(contains('fixed forever')));
  });

  test('insufficient transfer evidence is ignored', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(verdict: act0LearningTransferInsufficientEvidenceV1),
        ],
      ),
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(conceptFamilyId: 'recent_focus', lastSeenAt: 3),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
    expect(reason.conceptFamilyId, 'recent_focus');
  });

  test('most recent valid family becomes fallback personal focus', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(conceptFamilyId: 'older_focus', lastSeenAt: 2),
          _family(conceptFamilyId: 'newer_focus', lastSeenAt: 5),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
    expect(reason.conceptFamilyId, 'newer_focus');
    expect(reason.copyLine, 'Resume your most recent table read.');
  });

  test('missing or malformed evidence falls back safely', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(conceptFamilyId: '', lastSeenAt: 5),
          _family(conceptFamilyId: 'none', lastSeenAt: 6),
        ],
      ),
    );

    expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
    expect(reason.conceptFamilyId, '');
    expect(reason.copyLine, isNull);
  });

  test('selection is deterministic and stable across rebuild reads', () {
    final first = Act0PersonalizedReturnReasonV1.fromSources(
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(conceptFamilyId: 'b_focus', lastSeenAt: 4),
          _family(conceptFamilyId: 'a_focus', lastSeenAt: 4),
        ],
      ),
    );
    final second = Act0PersonalizedReturnReasonV1.fromSources(
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(conceptFamilyId: 'a_focus', lastSeenAt: 4),
          _family(conceptFamilyId: 'b_focus', lastSeenAt: 4),
        ],
      ),
    );

    expect(first.toPayload(), second.toPayload());
    expect(first.conceptFamilyId, 'a_focus');
  });

  test('payload stores message key and evidence references, not copy', () {
    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      activeRepairIntents: <Act0RepairIntentV1>[_repairIntent()],
    );

    expect(reason.toPayload().keys, isNot(contains('copyLine')));
    expect(reason.toPayload()['messageKey'], reason.messageKey);
    expect(reason.toPayload()['rawEvidenceRef'], contains('active_repair'));
  });

  test('source contains no persistence, UI parsing, ranking, or telemetry', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('weakest')));
    expect(source, isNot(contains('rank')));
    expect(source, isNot(contains('score')));
    expect(source, isNot(contains('DateTime.now')));
    expect(source, isNot(contains('Random')));
  });
}

Act0ConceptFamilyStateV1 _family({
  required String conceptFamilyId,
  int lastSeenAt = 1,
  int? lastAttemptAt,
  String lastOutcome = act0ConceptFamilyOutcomeMissedV1,
}) {
  return Act0ConceptFamilyStateV1(
    conceptFamilyId: conceptFamilyId,
    worldId: 'world_1',
    lastSeenAt: lastSeenAt,
    lastAttemptAt: lastAttemptAt,
    missCount: lastOutcome == act0ConceptFamilyOutcomeMissedV1 ? 1 : 0,
    repairAttemptCount:
        lastAttemptAt != null ||
            lastOutcome == act0ConceptFamilyOutcomeRepairNotYetSucceededV1
        ? 1
        : 0,
    successfulRepairCount:
        lastOutcome == act0ConceptFamilyOutcomeRepairSucceededV1 ? 1 : 0,
    lastOutcome: lastOutcome,
    lastTaskId: '${conceptFamilyId}_task',
    lastSessionId: 'session_v1|1',
  );
}

Act0LearningTransferSignalV1 _transferSignal({
  String conceptFamilyId = 'transfer_focus',
  required String verdict,
}) {
  return Act0LearningTransferSignalV1(
    conceptFamilyId: conceptFamilyId,
    relationship: act0LearningTransferSameFamilyTransferV1,
    verdict: verdict,
    baselineOrder: 1,
    comparisonOrder: 4,
    baselineTaskId: 'actions_open_intro',
    comparisonTaskId: 'actions_check_transfer',
    baselineSessionId: 'session_v1|1',
    comparisonSessionId: 'session_v1|2',
    baselineDecisionTimeBucket: '3_to_10s',
    comparisonDecisionTimeBucket: 'under_3s',
  );
}

Act0RepairIntentV1 _repairIntent() {
  return const Act0RepairIntentV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'fold_check_call_raise',
    sourceTaskId: 'actions_legal_context',
    choiceId: 'fold',
    result: 'incorrect',
    errorType: 'missed_action_read',
    missedSignalId: 'no_bet_yet',
    missedSignalLabel: 'Nobody has bet yet',
    skillAtomId: 'action_read',
    skillLabel: 'Action read',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    mappingType: 'same_signal',
    reasonCode: 'same_signal_action_read_no_bet_yet',
  );
}

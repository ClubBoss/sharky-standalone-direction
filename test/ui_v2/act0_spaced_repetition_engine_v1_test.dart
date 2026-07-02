import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_spaced_repetition_engine_v1.dart';

void main() {
  test('unresolved active repair is due now', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      activeRepairIntents: <Act0RepairIntentV1>[_repairIntent()],
    );

    final family = schedule.scheduleForConceptFamily('no_bet_yet');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateDueNowV1);
    expect(family.dueReason, act0SpacedRepReasonUnresolvedMissV1);
    expect(family.dueAfterSessionOrdinal, 4);
    expect(schedule.nextDueFamily, family);
  });

  test('failed repair is due now', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(
            conceptFamilyId: 'repair_focus',
            lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
            lastAttemptAt: 12,
            lastSessionId: 'session_v1|3',
          ),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('repair_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateDueNowV1);
    expect(family.dueReason, act0SpacedRepReasonRepairNotYetSucceededV1);
  });

  test('successful repair without transfer is due next session', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(
            conceptFamilyId: 'success_focus',
            lastOutcome: act0ConceptFamilyOutcomeRepairSucceededV1,
            lastAttemptAt: 12,
            lastProofAt: 12,
            lastSessionId: 'session_v1|4',
          ),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('success_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateDueNextSessionV1);
    expect(family.dueReason, act0SpacedRepReasonRepairSucceededV1);
    expect(family.dueAfterSessionOrdinal, 5);
  });

  test('improved transfer schedules one-session reinforcement', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(
            conceptFamilyId: 'transfer_focus',
            verdict: act0LearningTransferImprovedV1,
            comparisonSessionId: 'session_v1|4',
          ),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('transfer_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateDueNextSessionV1);
    expect(
      family.dueReason,
      act0SpacedRepReasonRecentImprovementReinforcementV1,
    );
    expect(family.dueAfterSessionOrdinal, 5);
  });

  test('held transfer schedules two-session interval', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(
            conceptFamilyId: 'held_focus',
            verdict: act0LearningTransferHeldV1,
            comparisonSessionId: 'session_v1|4',
          ),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('held_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateNotDueV1);
    expect(family.dueReason, act0SpacedRepReasonStableCorrectEvidenceV1);
    expect(family.dueAfterSessionOrdinal, 6);
  });

  test('not-due family is excluded from due selector', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(
            conceptFamilyId: 'held_focus',
            verdict: act0LearningTransferHeldV1,
            comparisonSessionId: 'session_v1|4',
          ),
        ],
      ),
    );

    expect(schedule.dueFamilies, isEmpty);
    expect(schedule.nextDueFamily, isNull);
  });

  test('insufficient evidence is not due', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          Act0LearningTransferSignalV1.insufficient('thin_focus'),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('thin_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateInsufficientEvidenceV1);
    expect(family.isDueNow, isFalse);
  });

  test('same-session transfer does not advance cross-session spacing', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(
            verdict: act0LearningTransferImprovedV1,
            baselineSessionId: 'session_v1|4',
            comparisonSessionId: 'session_v1|4',
          ),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('transfer_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateInsufficientEvidenceV1);
    expect(family.dueAfterSessionOrdinal, isNull);
  });

  test('session ordinal advancement makes family due', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 5,
      transferMeasurement: Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _transferSignal(
            verdict: act0LearningTransferImprovedV1,
            comparisonSessionId: 'session_v1|4',
          ),
        ],
      ),
    );

    final family = schedule.scheduleForConceptFamily('transfer_focus');
    expect(family, isNotNull);
    expect(family!.scheduleState, act0SpacedRepStateDueNowV1);
    expect(schedule.nextDueFamily, family);
  });

  test('due-family selector uses deterministic priority ordering', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 7,
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(
            conceptFamilyId: 'b_success',
            lastOutcome: act0ConceptFamilyOutcomeRepairSucceededV1,
            lastSessionId: 'session_v1|4',
          ),
          _family(
            conceptFamilyId: 'a_failed',
            lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
            lastSessionId: 'session_v1|6',
          ),
        ],
      ),
    );

    expect(schedule.nextDueFamily!.conceptFamilyId, 'a_failed');
  });

  test('lexical fallback resolves final tie', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 7,
      conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
        families: <Act0ConceptFamilyStateV1>[
          _family(
            conceptFamilyId: 'b_focus',
            lastOutcome: act0ConceptFamilyOutcomeRepairSucceededV1,
            lastSeenAt: 12,
            lastSessionId: 'session_v1|5',
          ),
          _family(
            conceptFamilyId: 'a_focus',
            lastOutcome: act0ConceptFamilyOutcomeRepairSucceededV1,
            lastSeenAt: 12,
            lastSessionId: 'session_v1|5',
          ),
        ],
      ),
    );

    expect(schedule.nextDueFamily!.conceptFamilyId, 'a_focus');
  });

  test('read model is stable across rebuilds', () {
    final first = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 5,
      activeRepairIntents: <Act0RepairIntentV1>[_repairIntent()],
    );
    final second = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 5,
      activeRepairIntents: <Act0RepairIntentV1>[_repairIntent()],
    );

    expect(first.toPayload(), second.toPayload());
  });

  test('parsed payload is stable and skips old or malformed entries', () {
    final parsed = Act0SpacedRepetitionScheduleV1.tryParse(<Object?>[
      <String, Object?>{
        'schemaVersion': 0,
        'conceptFamilyId': 'old_focus',
        'scheduleState': act0SpacedRepStateDueNowV1,
      },
      'bad',
      <String, Object?>{
        'schemaVersion': 1,
        'conceptFamilyId': 'due_focus',
        'scheduleState': act0SpacedRepStateDueNowV1,
        'dueReason': act0SpacedRepReasonRepairSucceededV1,
        'dueAfterSessionOrdinal': 4,
        'priorityClass': 2,
        'lastEvidenceOrder': 10,
      },
    ]);

    expect(parsed.schedules, hasLength(1));
    expect(parsed.schedules.single.conceptFamilyId, 'due_focus');
    expect(parsed.schedules.single.toPayload(), parsed.toPayload().single);
  });

  test('malformed optional schedule state fails safely', () {
    final parsed = Act0SpacedRepetitionScheduleV1.tryParse(<Object?>[
      <String, Object?>{
        'schemaVersion': 1,
        'conceptFamilyId': '',
        'scheduleState': act0SpacedRepStateDueNowV1,
        'dueReason': act0SpacedRepReasonRepairSucceededV1,
        'dueAfterSessionOrdinal': -1,
        'priorityClass': -1,
      },
      <String, Object?>{
        'schemaVersion': 1,
        'conceptFamilyId': 'bad_state',
        'scheduleState': 'unknown',
        'dueReason': act0SpacedRepReasonRepairSucceededV1,
      },
    ]);

    expect(parsed.schedules, isEmpty);
    expect(Act0SpacedRepetitionScheduleV1.tryParse(null).schedules, isEmpty);
  });

  test('return reason and schedule do not contradict each other', () {
    final activeRepair = _repairIntent();
    final state = Act0ConceptFamilyStateHistoryV1(
      families: <Act0ConceptFamilyStateV1>[
        _family(
          conceptFamilyId: 'repair_focus',
          lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
          lastSessionId: 'session_v1|3',
        ),
      ],
    );
    final transfer = Act0LearningTransferMeasurementV1(
      signals: <Act0LearningTransferSignalV1>[
        _transferSignal(
          conceptFamilyId: 'transfer_focus',
          verdict: act0LearningTransferImprovedV1,
          comparisonSessionId: 'session_v1|4',
        ),
      ],
    );

    final reason = Act0PersonalizedReturnReasonV1.fromSources(
      activeRepairIntents: <Act0RepairIntentV1>[activeRepair],
      conceptFamilyStateHistory: state,
      transferMeasurement: transfer,
    );
    final schedule = Act0SpacedRepetitionScheduleV1.fromSources(
      currentSessionOrdinal: 4,
      activeRepairIntents: <Act0RepairIntentV1>[activeRepair],
      conceptFamilyStateHistory: state,
      transferMeasurement: transfer,
    );

    expect(reason.conceptFamilyId, 'no_bet_yet');
    expect(
      schedule.scheduleForConceptFamily(reason.conceptFamilyId)!.scheduleState,
      act0SpacedRepStateDueNowV1,
    );
  });

  test(
    'source contains no rating, wall-clock, persistence, or telemetry inputs',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_spaced_repetition_engine_v1.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('SharedPreferences')));
      expect(source, isNot(contains('package:flutter/')));
      expect(source, isNot(contains('Telemetry')));
      expect(source, isNot(contains('weakest')));
      expect(source, isNot(contains('mastery')));
      expect(source, isNot(contains('score')));
      expect(source, isNot(contains('DateTime')));
      expect(source, isNot(contains('Random')));
      expect(source, isNot(contains('FSRS')));
      expect(source, isNot(contains('SM-2')));
    },
  );
}

Act0ConceptFamilyStateV1 _family({
  required String conceptFamilyId,
  int lastSeenAt = 10,
  int? lastAttemptAt,
  int? lastProofAt,
  String lastOutcome = act0ConceptFamilyOutcomeMissedV1,
  String lastSessionId = 'session_v1|3',
}) {
  return Act0ConceptFamilyStateV1(
    conceptFamilyId: conceptFamilyId,
    worldId: 'world_1',
    lastSeenAt: lastSeenAt,
    lastAttemptAt: lastAttemptAt,
    lastProofAt: lastProofAt,
    missCount: lastOutcome == act0ConceptFamilyOutcomeMissedV1 ? 1 : 0,
    repairAttemptCount:
        lastAttemptAt != null ||
            lastOutcome == act0ConceptFamilyOutcomeRepairNotYetSucceededV1 ||
            lastOutcome == act0ConceptFamilyOutcomeRepairSucceededV1
        ? 1
        : 0,
    successfulRepairCount:
        lastOutcome == act0ConceptFamilyOutcomeRepairSucceededV1 ? 1 : 0,
    lastOutcome: lastOutcome,
    lastTaskId: '${conceptFamilyId}_task',
    lastSessionId: lastSessionId,
  );
}

Act0LearningTransferSignalV1 _transferSignal({
  String conceptFamilyId = 'transfer_focus',
  required String verdict,
  String baselineSessionId = 'session_v1|1',
  String comparisonSessionId = 'session_v1|2',
}) {
  return Act0LearningTransferSignalV1(
    conceptFamilyId: conceptFamilyId,
    relationship: baselineSessionId == comparisonSessionId
        ? act0LearningTransferInsufficientEvidenceV1
        : act0LearningTransferSameFamilyTransferV1,
    verdict: verdict,
    baselineOrder: 1,
    comparisonOrder: 4,
    baselineTaskId: 'actions_open_intro',
    comparisonTaskId: 'actions_check_transfer',
    baselineSessionId: baselineSessionId,
    comparisonSessionId: comparisonSessionId,
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

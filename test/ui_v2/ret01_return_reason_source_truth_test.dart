// RET-01 technical package: source truth of the personalized return reason.
// MACHINE-only deterministic checks of the Preview -> fromSources -> copyLine
// contract. Not Human return-behaviour proof and not full RET-01 acceptance.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_last_session_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

const String _retryLine = 'Your last repair did not land yet. Start there.';
const String _resumeLine = 'Resume your most recent table read.';
const String _dueLine = 'Review this clue now. It is ready for a spaced check.';
const String _continueLine =
    'You missed this clue last time. One more clean rep will keep it visible.';

void main() {
  group('RET-01 source priority on the Preview input shape', () {
    test('empty sources fall back without a personal claim', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources();

      expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
      expect(reason.evidenceKind, act0ReturnReasonEvidenceFallbackV1);
      expect(reason.conceptFamilyId, isEmpty);
      expect(reason.sourceTaskId, isEmpty);
      expect(reason.copyLine, isNull);
      expect(reason.toTelemetryPayload(), <String, Object?>{
        'reason_type': act0ReturnReasonNoPersonalReasonAvailableV1,
        'evidence_kind': act0ReturnReasonEvidenceFallbackV1,
        'priority_class': 5,
        'destination': 'learn',
        'action': 'continue',
      });
    });

    test('empty real recent measurement also falls back to no reason', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory:
            Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(
              const Act0LearningEvidenceHistoryV1(),
            ),
        transferMeasurement:
            Act0LearningTransferMeasurementV1.fromLearningEvidence(
              const Act0LearningEvidenceHistoryV1(),
              nowUtc: DateTime.utc(2026, 11, 12),
            ),
        dueReviewItems: const Act0DurableRetentionHistoryV1().dueItemsAt(
          DateTime.utc(2026, 11, 12),
        ),
      );

      expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
      expect(reason.copyLine, isNull);
    });

    test('existing source priority ladder is preserved step by step', () {
      final intent = _intent();
      final retryFamily = _family(
        'retry_focus',
        lastSeenAt: 5,
        lastAttemptAt: 5,
        attempts: 1,
        successes: 0,
        lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
      );
      final recentFamily = _family('recent_focus', lastSeenAt: 9);
      final due = _dueItem('due_focus', DateTime.utc(2026, 11, 1));
      final arithmetic = Act0LearningTransferMeasurementV1(
        signals: <Act0LearningTransferSignalV1>[
          _signal('transfer_focus', act0LearningTransferImprovedV1),
        ],
      );
      final recent = Act0LearningTransferMeasurementV1(
        isRecentEvidence: true,
        signals: <Act0LearningTransferSignalV1>[
          _signal(
            'recent_evidence_focus',
            act0RecentEvidenceConfirmationNeededV1,
            confirmationLine:
                'Confirmation needed — complete 5 independent responses.',
          ),
        ],
      );

      String pick({
        bool withIntent = true,
        bool withRetry = true,
        bool withDue = true,
        bool withTransfer = true,
        bool withRecent = true,
      }) => Act0PersonalizedReturnReasonV1.fromSources(
        activeRepairIntents: withIntent
            ? <Act0RepairIntentV1>[intent]
            : const <Act0RepairIntentV1>[],
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[
            if (withRetry) retryFamily,
            if (withRecent) recentFamily,
          ],
        ),
        transferMeasurement: withTransfer ? arithmetic : recent,
        dueReviewItems: withDue
            ? <Act0DueReviewItemV1>[due]
            : const <Act0DueReviewItemV1>[],
      ).reasonType;

      expect(pick(), act0ReturnReasonContinueUnresolvedRepairV1);
      expect(pick(withIntent: false), act0ReturnReasonRetryNotYetSucceededV1);
      expect(
        pick(withIntent: false, withRetry: false),
        act0ReturnReasonDueReviewV1,
      );
      expect(
        pick(withIntent: false, withRetry: false, withDue: false),
        act0ReturnReasonReinforceRecentImprovementV1,
      );
      expect(
        pick(
          withIntent: false,
          withRetry: false,
          withDue: false,
          withTransfer: false,
        ),
        act0ReturnReasonResumeRecentFocusV1,
      );
      expect(
        pick(
          withIntent: false,
          withRetry: false,
          withDue: false,
          withTransfer: false,
          withRecent: false,
        ),
        act0RecentEvidenceConfirmationNeededV1,
      );
    });

    test('input order permutations select the same reason', () {
      final intents = <Act0RepairIntentV1>[
        _intent(sourceTaskId: 'task_b', missedSignalId: 'signal_b'),
        _intent(sourceTaskId: 'task_a', missedSignalId: 'signal_z'),
        _intent(sourceTaskId: 'task_a', missedSignalId: 'signal_a'),
      ];
      final families = <Act0ConceptFamilyStateV1>[
        _family('family_c', lastSeenAt: 4),
        _family('family_a', lastSeenAt: 7),
        _family('family_b', lastSeenAt: 7),
      ];
      final retries = <Act0ConceptFamilyStateV1>[
        _retryFamily('retry_b', lastAttemptAt: 6),
        _retryFamily('retry_a', lastAttemptAt: 6),
        _retryFamily('retry_c', lastAttemptAt: 2),
      ];
      final dueItems = <Act0DueReviewItemV1>[
        _dueItem('due_b', DateTime.utc(2026, 11, 2), taskId: 'due_task_b'),
        _dueItem(
          'due_a',
          DateTime.utc(2026, 11, 2),
          taskId: 'due_task_a',
          misses: 3,
        ),
        _dueItem('due_c', DateTime.utc(2026, 11, 3), taskId: 'due_task_c'),
      ];
      final signals = <Act0LearningTransferSignalV1>[
        _signal('transfer_b', act0LearningTransferHeldV1, order: 9),
        _signal('transfer_a', act0LearningTransferImprovedV1, order: 9),
        _signal('transfer_c', act0LearningTransferImprovedV1, order: 3),
      ];

      void expectStable(
        Act0PersonalizedReturnReasonV1 Function(bool reversed) build,
        String expectedFamily,
      ) {
        final forward = build(false);
        final reversed = build(true);
        expect(forward.toPayload(), reversed.toPayload());
        expect(forward.copyLine, reversed.copyLine);
        expect(forward.conceptFamilyId, expectedFamily);
      }

      List<T> order<T>(List<T> items, bool reversed) =>
          reversed ? items.reversed.toList() : items;

      expectStable(
        (r) => Act0PersonalizedReturnReasonV1.fromSources(
          activeRepairIntents: order(intents, r),
        ),
        'signal_a',
      );
      expectStable(
        (r) => Act0PersonalizedReturnReasonV1.fromSources(
          conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
            families: order(retries, r),
          ),
        ),
        'retry_a',
      );
      expectStable(
        (r) => Act0PersonalizedReturnReasonV1.fromSources(
          dueReviewItems: order(dueItems, r),
        ),
        'due_a',
      );
      expectStable(
        (r) => Act0PersonalizedReturnReasonV1.fromSources(
          transferMeasurement: Act0LearningTransferMeasurementV1(
            signals: order(signals, r),
          ),
        ),
        'transfer_a',
      );
      expectStable(
        (r) => Act0PersonalizedReturnReasonV1.fromSources(
          conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
            families: order(families, r),
          ),
        ),
        'family_a',
      );
    });
  });

  group('RET-01 completed versus unfinished repair (reducer evidence)', () {
    test('a failed repair that is still unresolved asks for one retry', () {
      final reason = _fromEvidence(<Act0LearningEvidenceRecordV1>[
        _evidence(1, correct: false, taskId: 'actions_legal_context'),
        _evidence(2, correct: false, repair: true),
      ]);

      expect(reason.reasonType, act0ReturnReasonRetryNotYetSucceededV1);
      expect(reason.copyLine, _retryLine);
    });

    test('a failed then landed repair is not reported as not landed', () {
      final reason = _fromEvidence(<Act0LearningEvidenceRecordV1>[
        _evidence(1, correct: false, taskId: 'actions_legal_context'),
        _evidence(2, correct: false, repair: true),
        _evidence(3, correct: true, repair: true),
      ]);

      expect(reason.reasonType, isNot(act0ReturnReasonRetryNotYetSucceededV1));
      expect(reason.copyLine, isNot(_retryLine));
      expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
      expect(reason.copyLine, _resumeLine);
    });

    test('a later ordinary miss after a landed repair is not a failed '
        'repair', () {
      final reason = _fromEvidence(<Act0LearningEvidenceRecordV1>[
        _evidence(1, correct: false, taskId: 'actions_legal_context'),
        _evidence(2, correct: false, repair: true),
        _evidence(3, correct: true, repair: true),
        _evidence(4, correct: false, taskId: 'actions_legal_context'),
      ]);

      expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
      expect(reason.copyLine, _resumeLine);
    });

    test('an ordinary miss after an unlanded repair keeps the retry', () {
      final reason = _fromEvidence(<Act0LearningEvidenceRecordV1>[
        _evidence(1, correct: false, taskId: 'actions_legal_context'),
        _evidence(2, correct: false, repair: true),
        _evidence(3, correct: false, taskId: 'actions_legal_context'),
      ]);

      expect(reason.reasonType, act0ReturnReasonRetryNotYetSucceededV1);
      expect(reason.copyLine, _retryLine);
    });

    test('a hint-assisted correct repair is not independent proof', () {
      final assisted = <Act0LearningEvidenceRecordV1>[
        _evidence(1, correct: false, taskId: 'actions_legal_context'),
        _evidence(2, correct: false, repair: true),
        _evidence(
          3,
          correct: true,
          repair: true,
          help: Act0DecisionAssistanceV1.quickHint,
        ),
      ];
      expect(
        _fromEvidence(assisted).reasonType,
        act0ReturnReasonRetryNotYetSucceededV1,
      );

      final independent = <Act0LearningEvidenceRecordV1>[
        ...assisted,
        _evidence(4, correct: true, repair: true),
      ];
      expect(
        _fromEvidence(independent).reasonType,
        act0ReturnReasonResumeRecentFocusV1,
      );
    });

    test('a persisted landed repair without lastProofAt stays landed', () {
      final family = Act0ConceptFamilyStateV1.tryParse(<String, Object?>{
        'schemaVersion': 1,
        'conceptFamilyId': 'no_bet_yet',
        'worldId': 'world_1',
        'lastSeenAt': 3,
        'lastAttemptAt': 3,
        'missCount': 2,
        'repairAttemptCount': 2,
        'successfulRepairCount': 1,
        'lastOutcome': act0ConceptFamilyOutcomeRepairSucceededV1,
        'lastTaskId': 'actions_check_drill',
      });
      expect(family, isNotNull);

      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[family!],
        ),
      );
      expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
    });

    test('an unproven attempt after an older proof still asks to retry', () {
      // Guards against weakening the counting rule: an older proof does not
      // cover a newer attempt whose result is unknown.
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[
            _family(
              'no_bet_yet',
              lastSeenAt: 5,
              lastAttemptAt: 5,
              lastProofAt: 3,
              attempts: 2,
              successes: 1,
              lastOutcome: act0ConceptFamilyOutcomeRepairAttemptedV1,
            ),
          ],
        ),
      );
      expect(reason.reasonType, act0ReturnReasonRetryNotYetSucceededV1);
    });

    test('an explicit not-yet outcome is never hidden by counts', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[
            _family(
              'no_bet_yet',
              lastSeenAt: 5,
              lastAttemptAt: 5,
              lastProofAt: 3,
              attempts: 2,
              successes: 1,
              lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
            ),
          ],
        ),
      );
      expect(reason.reasonType, act0ReturnReasonRetryNotYetSucceededV1);
    });
  });

  group('RET-01 due / not-due boundary through dueItemsAt(now)', () {
    final dueAt = DateTime.utc(2026, 11, 12, 9);
    final retention = Act0DurableRetentionHistoryV1(
      families: <Act0DurableRetentionFamilyV1>[_retentionFamily(dueAt)],
    );

    test('one microsecond before due is not a due review', () {
      final items = retention.dueItemsAt(
        dueAt.subtract(const Duration(microseconds: 1)),
      );
      expect(items, isEmpty);
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        dueReviewItems: items,
      );
      expect(reason.reasonType, isNot(act0ReturnReasonDueReviewV1));
      expect(reason.copyLine, isNot(_dueLine));
    });

    test('exactly at due time the spaced review is offered', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        dueReviewItems: retention.dueItemsAt(dueAt),
      );
      expect(reason.reasonType, act0ReturnReasonDueReviewV1);
      expect(reason.sourceTaskId, 'actions_check_drill');
      expect(reason.recommendedAction, 'spaced_review');
      expect(reason.copyLine, _dueLine);
    });

    test('an unfinished repair still outranks a due review', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        activeRepairIntents: <Act0RepairIntentV1>[_intent()],
        dueReviewItems: retention.dueItemsAt(dueAt),
      );
      expect(reason.reasonType, act0ReturnReasonContinueUnresolvedRepairV1);
      expect(reason.copyLine, _continueLine);
    });
  });

  group('RET-01 stale and incomplete inputs', () {
    test('due items missing any identity field are skipped', () {
      final base = _dueItem('due_focus', DateTime.utc(2026, 11, 1));
      final broken = <Act0DueReviewItemV1>[
        _copyDue(base, conceptFamilyId: ' '),
        _copyDue(base, worldId: ''),
        _copyDue(base, lessonId: '  '),
        _copyDue(base, taskId: ''),
      ];
      for (final item in broken) {
        final reason = Act0PersonalizedReturnReasonV1.fromSources(
          dueReviewItems: <Act0DueReviewItemV1>[item],
        );
        expect(
          reason.reasonType,
          act0ReturnReasonNoPersonalReasonAvailableV1,
          reason: 'blank due identity must not become a due claim',
        );
      }
    });

    test('repair intents without any concept identity are skipped', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        activeRepairIntents: <Act0RepairIntentV1>[
          _intent(missedSignalId: ' ', skillAtomId: '', errorType: '  '),
        ],
      );
      expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
    });

    test('blank and none concept families never become a reason', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[
            _family('none', lastSeenAt: 9),
            _retryFamily('none', lastAttemptAt: 9),
          ],
        ),
      );
      expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
    });

    test('non-transfer or unproven signals never reinforce improvement', () {
      for (final signal in <Act0LearningTransferSignalV1>[
        _signal(
          'focus',
          act0LearningTransferImprovedV1,
          relationship: act0LearningTransferSameTaskRepeatV1,
        ),
        _signal(
          'focus',
          act0LearningTransferImprovedV1,
          relationship: act0LearningTransferInsufficientEvidenceV1,
        ),
        _signal('focus', act0LearningTransferMixedV1),
        _signal('focus', act0LearningTransferRegressingV1),
        _signal('focus', act0LearningTransferRecoveredNotDurableV1),
        _signal('none', act0LearningTransferImprovedV1),
        _signal(' ', act0LearningTransferImprovedV1),
      ]) {
        final reason = Act0PersonalizedReturnReasonV1.fromSources(
          transferMeasurement: Act0LearningTransferMeasurementV1(
            signals: <Act0LearningTransferSignalV1>[signal],
          ),
        );
        expect(
          reason.reasonType,
          act0ReturnReasonNoPersonalReasonAvailableV1,
          reason: '${signal.relationship}/${signal.verdict}',
        );
      }
    });

    test('a historical (non-recent) measurement never uses the recent '
        'confirmation line', () {
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        transferMeasurement: Act0LearningTransferMeasurementV1(
          signals: <Act0LearningTransferSignalV1>[
            _signal(
              'focus',
              act0RecentEvidenceVerifiedV1,
              confirmationLine: 'Recent verified responses',
            ),
          ],
        ),
      );
      expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
      expect(reason.copyLine, isNull);
    });
  });

  group('RET-01 invalid persisted state fails closed', () {
    Map<String, Object?> valid() => <String, Object?>{
      'schemaVersion': 1,
      'conceptFamilyId': 'no_bet_yet',
      'worldId': 'world_1',
      'lastSeenAt': 4,
      'missCount': 1,
      'repairAttemptCount': 0,
      'successfulRepairCount': 0,
      'lastOutcome': act0ConceptFamilyOutcomeMissedV1,
    };

    test('invalid family records are rejected one by one', () {
      final invalid = <String, Map<String, Object?>>{
        'unknown outcome': valid()..['lastOutcome'] = 'repair_mastered',
        'unknown schema revision': valid()..['schemaVersion'] = 2,
        'missing schema revision': valid()..remove('schemaVersion'),
        'blank concept id': valid()..['conceptFamilyId'] = '  ',
        'blank world id': valid()..['worldId'] = '',
        'negative order': valid()..['lastSeenAt'] = -1,
        'non-numeric count': valid()..['missCount'] = 'many',
        'more successes than attempts': valid()
          ..['repairAttemptCount'] = 1
          ..['successfulRepairCount'] = 2,
      };
      for (final entry in invalid.entries) {
        expect(
          Act0ConceptFamilyStateV1.tryParse(entry.value),
          isNull,
          reason: entry.key,
        );
      }
      expect(Act0ConceptFamilyStateV1.tryParse('garbage'), isNull);
      expect(Act0ConceptFamilyStateV1.tryParse(null), isNull);
    });

    test('a corrupt record does not delete the valid history', () {
      final history = Act0ConceptFamilyStateHistoryV1.tryParse(<Object?>[
        valid()..['conceptFamilyId'] = 'kept_focus',
        valid()..['lastOutcome'] = 'invented_success',
        'garbage',
        null,
        valid()..['schemaVersion'] = 99,
      ]);

      expect(history.knownFamilyIds, <String>['kept_focus']);
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: history,
      );
      expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
      expect(reason.conceptFamilyId, 'kept_focus');
    });

    test('unreadable storage degrades to empty history without success', () {
      for (final raw in <String>['{not json', '{}', '[1, 2]', '"x"']) {
        final history = Act0ConceptFamilyStateHistoryV1.tryParseStorageString(
          raw,
        );
        expect(history.families, isEmpty, reason: raw);
        final reason = Act0PersonalizedReturnReasonV1.fromSources(
          conceptFamilyStateHistory: history,
        );
        expect(reason.reasonType, act0ReturnReasonNoPersonalReasonAvailableV1);
        expect(reason.copyLine, isNull);
      }
    });

    test('duplicate persisted family keeps the newest observation', () {
      final history = Act0ConceptFamilyStateHistoryV1.tryParse(<Object?>[
        valid()
          ..['lastSeenAt'] = 9
          ..['lastOutcome'] = act0ConceptFamilyOutcomeRepairNotYetSucceededV1
          ..['repairAttemptCount'] = 1
          ..['lastAttemptAt'] = 9,
        valid()..['lastSeenAt'] = 2,
      ]);
      expect(history.families.single.lastSeenAt, 9);
      expect(
        Act0PersonalizedReturnReasonV1.fromSources(
          conceptFamilyStateHistory: history,
        ).reasonType,
        act0ReturnReasonRetryNotYetSucceededV1,
      );
    });

    test('last-session state rejects unknown or incomplete values', () {
      Map<String, Object?> session() => <String, Object?>{
        'last_session_repair_focus_id': 'no_bet_yet',
        'last_session_proof_result': act0LastSessionProofFixLandedV1,
        'last_session_date': '2026-11-11',
        'last_session_world_id': 'world_1',
      };
      final invalid = <String, Object?>{
        'unknown proof value': session()
          ..['last_session_proof_result'] = 'fix_probably_landed',
        'blank proof': session()..['last_session_proof_result'] = '  ',
        'missing date': session()..remove('last_session_date'),
        'blank world': session()..['last_session_world_id'] = '',
        'not a map': 'fix_landed',
        'list payload': <Object?>[session()],
        'null': null,
      };
      for (final entry in invalid.entries) {
        expect(
          Act0LastSessionLearnerStateV1.tryParse(entry.value),
          isNull,
          reason: entry.key,
        );
      }
      final parsed = Act0LastSessionLearnerStateV1.tryParse(session());
      expect(parsed, isNotNull);
      expect(Act0LastSessionLearnerStateV1.tryParse(parsed!.toJson()), parsed);
    });

    test('hand-built reasons with unknown keys render no copy', () {
      const unknown = Act0PersonalizedReturnReasonV1(
        reasonType: 'future_reason_v9',
        conceptFamilyId: 'no_bet_yet',
        evidenceKind: 'future_evidence',
        messageKey: 'future_message',
        priorityClass: 0,
      );
      expect(unknown.copyLine, isNull);
    });
  });

  group('RET-01 inputs are never mutated', () {
    test('selection reads unmodifiable inputs and leaves them unchanged', () {
      final intents = List<Act0RepairIntentV1>.unmodifiable(
        <Act0RepairIntentV1>[
          _intent(sourceTaskId: 'task_b', missedSignalId: 'signal_b'),
          _intent(sourceTaskId: 'task_a', missedSignalId: 'signal_a'),
        ],
      );
      final families = List<Act0ConceptFamilyStateV1>.unmodifiable(
        <Act0ConceptFamilyStateV1>[
          _retryFamily('retry_b', lastAttemptAt: 2),
          _family('family_a', lastSeenAt: 7),
          _retryFamily('retry_a', lastAttemptAt: 6),
        ],
      );
      final dueItems = List<Act0DueReviewItemV1>.unmodifiable(
        <Act0DueReviewItemV1>[
          _dueItem('due_b', DateTime.utc(2026, 11, 3), taskId: 'due_b_task'),
          _dueItem('due_a', DateTime.utc(2026, 11, 2), taskId: 'due_a_task'),
        ],
      );
      final signals = List<Act0LearningTransferSignalV1>.unmodifiable(
        <Act0LearningTransferSignalV1>[
          _signal('transfer_c', act0LearningTransferImprovedV1, order: 3),
          _signal('transfer_a', act0LearningTransferHeldV1, order: 9),
        ],
      );
      final history = Act0ConceptFamilyStateHistoryV1(
        families: families,
        appliedSourceIds: List<String>.unmodifiable(<String>['learning:1']),
      );
      final familyPayloadBefore = history.toPayload();
      final intentPayloadBefore = intents.map((i) => i.toPayload()).toList();
      final dueOrderBefore = dueItems.map((i) => i.taskId).toList();
      final signalOrderBefore = signals.map((s) => s.conceptFamilyId).toList();

      for (var pass = 0; pass < 6; pass++) {
        Act0PersonalizedReturnReasonV1.fromSources(
          activeRepairIntents: pass == 0
              ? intents
              : const <Act0RepairIntentV1>[],
          conceptFamilyStateHistory: pass <= 1
              ? history
              : pass == 4
              ? Act0ConceptFamilyStateHistoryV1(
                  families: <Act0ConceptFamilyStateV1>[families[1]],
                )
              : const Act0ConceptFamilyStateHistoryV1(),
          transferMeasurement: Act0LearningTransferMeasurementV1(
            signals: signals,
            isRecentEvidence: pass == 5,
          ),
          dueReviewItems: pass <= 2 ? dueItems : const <Act0DueReviewItemV1>[],
        );
      }

      expect(history.toPayload(), familyPayloadBefore);
      expect(history.appliedSourceIds, <String>['learning:1']);
      expect(intents.map((i) => i.toPayload()).toList(), intentPayloadBefore);
      expect(dueItems.map((i) => i.taskId).toList(), dueOrderBefore);
      expect(signals.map((s) => s.conceptFamilyId).toList(), signalOrderBefore);
    });
  });
}

Act0PersonalizedReturnReasonV1 _fromEvidence(
  List<Act0LearningEvidenceRecordV1> records,
) => Act0PersonalizedReturnReasonV1.fromSources(
  conceptFamilyStateHistory:
      Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(
        Act0LearningEvidenceHistoryV1(records: records),
      ),
);

Act0LearningEvidenceRecordV1 _evidence(
  int order, {
  required bool correct,
  bool repair = false,
  String taskId = 'actions_check_drill',
  Act0DecisionAssistanceV1 help = Act0DecisionAssistanceV1.none,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'ret01|$order',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: 'fold_check_call_raise',
  taskId: taskId,
  sourceTaskId: repair ? 'actions_legal_context' : taskId,
  choiceId: correct ? 'check' : 'fold',
  expectedChoiceId: 'check',
  isCorrect: correct,
  errorType: correct ? 'none' : 'misread_action_legality',
  conceptFamilyId: 'no_bet_yet',
  repairFocusId: 'no_bet_yet',
  skillAtomId: 'action_read',
  decisionTimeBucket: '3_to_10s',
  resultKind: correct ? 'correct' : 'incorrect',
  runKind: repair ? 'repair' : '',
  sessionId: 'ret01_session_$order',
  assistanceKind: help,
);

Act0ConceptFamilyStateV1 _family(
  String id, {
  int lastSeenAt = 1,
  int? lastAttemptAt,
  int? lastProofAt,
  int attempts = 0,
  int successes = 0,
  int misses = 1,
  String lastOutcome = act0ConceptFamilyOutcomeMissedV1,
}) => Act0ConceptFamilyStateV1(
  conceptFamilyId: id,
  worldId: 'world_1',
  lastSeenAt: lastSeenAt,
  lastAttemptAt: lastAttemptAt,
  lastProofAt: lastProofAt,
  missCount: misses,
  repairAttemptCount: attempts,
  successfulRepairCount: successes,
  lastOutcome: lastOutcome,
  lastTaskId: '${id}_task',
  lastSessionId: 'ret01_session',
);

Act0ConceptFamilyStateV1 _retryFamily(String id, {required int lastAttemptAt}) =>
    _family(
      id,
      lastSeenAt: lastAttemptAt,
      lastAttemptAt: lastAttemptAt,
      attempts: 1,
      lastOutcome: act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
    );

Act0DueReviewItemV1 _dueItem(
  String family,
  DateTime dueAt, {
  String taskId = 'actions_check_drill',
  int misses = 1,
}) => Act0DueReviewItemV1(
  conceptFamilyId: family,
  worldId: 'world_1',
  lessonId: 'fold_check_call_raise',
  taskId: taskId,
  nextDueAtUtc: dueAt,
  repeatedMissCount: misses,
  lapseCount: 0,
);

Act0DueReviewItemV1 _copyDue(
  Act0DueReviewItemV1 item, {
  String? conceptFamilyId,
  String? worldId,
  String? lessonId,
  String? taskId,
}) => Act0DueReviewItemV1(
  conceptFamilyId: conceptFamilyId ?? item.conceptFamilyId,
  worldId: worldId ?? item.worldId,
  lessonId: lessonId ?? item.lessonId,
  taskId: taskId ?? item.taskId,
  nextDueAtUtc: item.nextDueAtUtc,
  repeatedMissCount: item.repeatedMissCount,
  lapseCount: item.lapseCount,
);

Act0DurableRetentionFamilyV1 _retentionFamily(DateTime dueAt) =>
    Act0DurableRetentionFamilyV1(
      conceptFamilyId: 'no_bet_yet',
      worldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_check_drill',
      retentionState: Act0RetentionStateV1.recoveredPendingSpacedReview,
      nextDueAtUtc: dueAt,
      lastSpacedReviewAtUtc: null,
      spacedSuccessStage: 0,
      lapseCount: 0,
      incorrectCount: 1,
      correctCount: 1,
      lastRecordedAtUtc: dueAt.subtract(const Duration(days: 1)),
      lastCreatedOrder: 2,
      lastSessionId: 'ret01_session_2',
      lastReviewKind: Act0ReviewKindV1.alternateSameSignal,
      hasLegacyUnspacedEvidence: false,
    );

Act0LearningTransferSignalV1 _signal(
  String family,
  String verdict, {
  String relationship = act0LearningTransferSameFamilyTransferV1,
  int order = 4,
  String confirmationLine = '',
}) => Act0LearningTransferSignalV1(
  conceptFamilyId: family,
  relationship: relationship,
  verdict: verdict,
  baselineOrder: 1,
  comparisonOrder: order,
  baselineTaskId: 'actions_legal_context',
  comparisonTaskId: 'actions_check_drill',
  baselineSessionId: 'ret01_session_1',
  comparisonSessionId: 'ret01_session_2',
  baselineDecisionTimeBucket: '3_to_10s',
  comparisonDecisionTimeBucket: '3_to_10s',
  confirmationLine: confirmationLine,
);

Act0RepairIntentV1 _intent({
  String sourceTaskId = 'actions_legal_context',
  String missedSignalId = 'no_bet_yet',
  String skillAtomId = 'action_read',
  String errorType = 'misread_action_legality',
}) => Act0RepairIntentV1(
  sourceWorldId: 'world_1',
  sourceLessonId: 'fold_check_call_raise',
  sourceTaskId: sourceTaskId,
  choiceId: 'fold',
  result: 'incorrect',
  errorType: errorType,
  missedSignalId: missedSignalId,
  missedSignalLabel: 'Nobody has bet yet',
  skillAtomId: skillAtomId,
  skillLabel: 'Action read',
  targetWorldId: 'world_1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_check_drill',
  mappingType: 'same_signal',
  reasonCode: 'same_signal_action_read_no_bet_yet',
);

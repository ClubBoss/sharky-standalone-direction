import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  test('valid intent with no outcome is unresolved', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
    );

    final item = state.resolutionForQueueItemId(_activeQueueItemId);
    expect(item, isNotNull);
    expect(item!.resolutionState, act0QueueResolutionStateUnresolvedV1);
    expect(item.resolutionReason, act0QueueResolutionReasonNoOutcomeYetV1);
    expect(item.isActionable, isTrue);
    expect(item.repairIntentId, _activeRepairIntent.reasonCode);
    expect(item.conceptFamilyId, 'no_bet_yet');
  });

  test('successful matching repair resolves the item', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: true, sequence: 3)],
      ),
    );

    final item = state.resolutionForQueueItemId(_activeQueueItemId);
    expect(item!.resolutionState, act0QueueResolutionStateResolvedV1);
    expect(item.resolutionReason, act0QueueResolutionReasonRepairSucceededV1);
    expect(item.outcomeId, 'repair_outcome_v1|3|$_activeQueueItemId');
    expect(item.resolvedAtOrder, 3);
    expect(item.isActionable, isFalse);
  });

  test('failed matching repair remains actionable', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: false, sequence: 4),
        ],
      ),
    );

    final item = state.resolutionForQueueItemId(_activeQueueItemId);
    expect(
      item!.resolutionState,
      act0QueueResolutionStateAttemptedNotResolvedV1,
    );
    expect(item.resolutionReason, act0QueueResolutionReasonRepairFailedV1);
    expect(item.isActionable, isTrue);
  });

  test('unrelated outcome does not resolve the item', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(queueItemId: 'other_queue_item', isCorrect: true),
        ],
      ),
    );

    expect(
      state.resolutionForQueueItemId(_activeQueueItemId)!.resolutionState,
      act0QueueResolutionStateUnresolvedV1,
    );
  });

  test('repeated success is idempotent', () {
    final first = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: true, sequence: 4),
          _outcome(isCorrect: true, sequence: 5),
        ],
      ),
    );
    final second = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: true, sequence: 5),
          _outcome(isCorrect: true, sequence: 4),
        ],
      ),
    );

    expect(first.resolutions, hasLength(1));
    expect(second.toPayload(), first.toPayload());
    expect(first.resolutions.single.resolvedAtOrder, 4);
  });

  test('repeated failed attempts do not duplicate queue items', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: false, sequence: 4),
          _outcome(isCorrect: false, sequence: 5),
        ],
      ),
    );

    expect(state.resolutions, hasLength(1));
    expect(
      state.resolutions.single.resolutionState,
      act0QueueResolutionStateAttemptedNotResolvedV1,
    );
    expect(state.resolutions.single.resolvedAtOrder, 5);
  });

  test('malformed intent fails closed through parser', () {
    final parsed = Act0RepairIntentV1.tryParse(<String, Object?>{
      'schemaVersion': 1,
      'sourceWorldId': 'world_1',
      'sourceLessonId': 'fold_check_call_raise',
      'sourceTaskId': '',
      'choiceId': 'fold',
      'result': 'incorrect',
      'errorType': 'missed_action_read',
      'missedSignalId': 'no_bet_yet',
      'missedSignalLabel': 'No bet yet',
      'skillAtomId': 'action_read',
      'skillLabel': 'Action read',
      'targetWorldId': 'world_1',
      'targetLessonId': 'fold_check_call_raise',
      'targetTaskId': 'actions_check_drill',
      'mappingType': 'repair',
      'reasonCode': 'same_signal_action_read_no_bet_yet',
    });
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: <Act0RepairIntentV1>[if (parsed != null) parsed],
    );

    expect(parsed, isNull);
    expect(state.resolutions, isEmpty);
  });

  test('missing target fails closed as not actionable', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[
        Act0RepairIntentV1(
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
          targetWorldId: '',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'actions_check_drill',
          mappingType: 'repair',
          reasonCode: 'same_signal_action_read_no_bet_yet',
        ),
      ],
    );

    expect(
      state.resolutions.single.resolutionState,
      act0QueueResolutionStateNotActionableV1,
    );
    expect(
      state.resolutions.single.resolutionReason,
      act0QueueResolutionReasonTargetMissingV1,
    );
    expect(state.actionableQueueItemIds, isEmpty);
  });

  test('old state loads safely and skips malformed records', () {
    final parsed = Act0QueueResolutionStateV1.tryParse(<Object?>[
      <String, Object?>{
        'schemaVersion': 0,
        'queueItemId': 'old',
        'repairIntentId': 'intent',
        'conceptFamilyId': 'family',
        'resolutionState': act0QueueResolutionStateResolvedV1,
      },
      <String, Object?>{
        'schemaVersion': 1,
        'queueItemId': _activeQueueItemId,
        'repairIntentId': 'intent',
        'conceptFamilyId': 'no_bet_yet',
        'resolutionState': act0QueueResolutionStateResolvedV1,
        'resolutionReason': act0QueueResolutionReasonRepairSucceededV1,
        'outcomeId': 'outcome',
        'resolvedAtOrder': 1,
      },
    ]);

    expect(parsed.resolutions, hasLength(1));
    expect(parsed.resolutions.single.queueItemId, _activeQueueItemId);
    expect(Act0QueueResolutionStateV1.tryParse(null).resolutions, isEmpty);
  });

  test('rendering-style repeated derivation does not mutate resolution', () {
    final outcomeProjection = Act0RepairOutcomeProjectionV1(
      outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: false)],
    );
    final first = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: outcomeProjection,
    );
    final second = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: outcomeProjection,
    );

    expect(second.toPayload(), first.toPayload());
  });

  test('current launch request remains stable', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
    );
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      queueResolutionState: state,
    );

    expect(projection.items.single.launchRequest!.toPayload(), <String, Object>{
      'targetWorldId': 'world_1',
      'targetLessonId': 'fold_check_call_raise',
      'targetTaskId': 'actions_check_drill',
      'targetType': act0PracticeRepairQueueTargetTypeActiveRepairV1,
      'sourceType': act0PracticeRepairQueueSourceActiveRepairV1,
      'sourceTaskId': 'actions_legal_context',
      'repairTaskId': 'actions_check_drill',
      'repairFocusKey':
          '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
      'queueItemId': _activeQueueItemId,
    });
  });

  test('source contains no UI persistence telemetry or ranking owner', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('score')));
    expect(source, isNot(contains('mastery')));
    expect(source, isNot(contains('XP')));
  });
}

const String _activeQueueItemId =
    'practice_repair_queue_v1|active|75:21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read';

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

Act0RepairOutcomeV1 _outcome({
  String queueItemId = _activeQueueItemId,
  bool? isCorrect = true,
  int sequence = 3,
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey:
        '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
    queueItemId: queueItemId,
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    selectedChoiceId: isCorrect == true ? 'check' : 'fold',
    correctChoiceId: 'check',
    isCorrect: isCorrect,
    outcomeState: isCorrect == true
        ? act0RepairOutcomeStateCorrectV1
        : act0RepairOutcomeStateStillNeedsRepV1,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}

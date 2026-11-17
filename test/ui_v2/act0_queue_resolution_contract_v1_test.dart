// SIMULATED contract controls use current authored no-bet evidence; no application/native proof.
import '../support/act0_authored_repair_goal_fixture_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  test('prior occurrence or unknown success cannot discharge a new miss', () {
    final intent = Act0RepairIntentV1.tryParse({
      ..._activeRepairIntent.toPayload(),
      'repairOccurrenceId': 'source_miss_B',
    })!;
    final oldSuccess = Act0RepairOutcomeV1.tryParse({
      ..._outcome().toPayload(),
      'repairOccurrenceId': 'source_miss_A',
    })!;
    final unknown = Act0RepairOutcomeV1.tryParse({
      ..._outcome().toPayload(),
      'repairOccurrenceId': '',
    })!;
    for (final outcome in [oldSuccess, unknown]) {
      final state = _resolution(
        activeRepairIntents: [intent],
        repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
          outcomes: [outcome],
        ),
      );
      expect(state.resolutions.single.isActionable, isTrue);
      expect(state.resolutions.single.isLaunchable, isTrue);
      expect(
        state.resolutions.single.resolutionState,
        act0QueueResolutionStateUnresolvedV1,
      );
    }
    expect(queueItemIdForAct0RepairIntentV1(intent), _activeQueueItemId);
    expect(intent.toPayload()['repairOccurrenceId'], 'source_miss_B');
  });

  test('valid intent with no outcome is unresolved', () {
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
    );

    final item = state.resolutionForQueueItemId(_activeQueueItemId);
    expect(item, isNotNull);
    expect(item!.resolutionState, act0QueueResolutionStateUnresolvedV1);
    expect(item.resolutionReason, act0QueueResolutionReasonNoOutcomeYetV1);
    expect(item.isActionable, isTrue);
    expect(item.repairIntentId, _activeRepairIntent.reasonCode);
    expect(item.conceptFamilyId, 'no_bet_yet');
  });

  test(
    'launch captures occurrence and duplicate answer preserves one outcome',
    () {
      final intent = Act0RepairIntentV1.tryParse({
        ..._activeRepairIntent.toPayload(),
        'repairOccurrenceId': 'source_miss_B',
      })!;
      final queue = _practiceQueue(activeRepairIntents: [intent]);
      final request = queue.items.single.launchRequest!;
      expect(request.toPayload()['repairOccurrenceId'], 'source_miss_B');
      final first = const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
        launchRequest: request,
        selectedChoiceId: 'check',
        correctChoiceId: 'check',
        isCorrect: true,
        sequence: 1,
        repairAttemptId: 'repair_answer_B',
        repairIntent: intent,
        sessionId: 'repair-session',
      );
      final duplicate = first.appendAnsweredTask(
        launchRequest: request,
        selectedChoiceId: 'check',
        correctChoiceId: 'check',
        isCorrect: true,
        sequence: 100,
        repairAttemptId: 'repair_answer_B',
        repairIntent: intent,
        sessionId: 'repair-session',
      );
      expect(duplicate.toPayload(), first.toPayload());
      final restored = Act0RepairOutcomeProjectionV1.tryParse(
        first.toPayload(),
      );
      expect(restored.toPayload(), first.toPayload());
      final resolved = _resolution(
        activeRepairIntents: [intent],
        repairOutcomeProjection: restored,
      );
      expect(resolved.resolutions.single.isActionable, isFalse);
    },
  );

  test('successful matching repair resolves the item', () {
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
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
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
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
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
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
    final first = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: true, sequence: 4),
          _outcome(isCorrect: true, sequence: 5),
        ],
      ),
    );
    final second = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
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
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
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
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[if (parsed != null) parsed],
    );

    expect(parsed, isNull);
    expect(state.resolutions, isEmpty);
  });

  test(
    'missing target stays held without a launch or discarded obligation',
    () {
      final state = _resolution(
        activeRepairIntents: const <Act0RepairIntentV1>[
          Act0RepairIntentV1(
            repairOccurrenceId: 'source_miss_A',
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
        act0QueueResolutionStateHeldV1,
      );
      expect(state.resolutions.single.isActionable, isTrue);
      expect(state.resolutions.single.isLaunchable, isFalse);
      expect(
        state.resolutions.single.resolutionReason,
        act0QueueResolutionReasonGoalUnconfirmedV1,
      );
      expect(
        state.actionableQueueItemIds,
        contains(state.resolutions.single.queueItemId),
      );
    },
  );

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
    final first = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: outcomeProjection,
    );
    final second = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: outcomeProjection,
    );

    expect(second.toPayload(), first.toPayload());
  });

  test('current launch request remains stable', () {
    final state = _resolution(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
    );
    final projection = _practiceQueue(
      activeRepairIntents: <Act0RepairIntentV1>[_activeRepairIntent],
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
      'repairOccurrenceId': _activeRepairIntent.repairOccurrenceId,
      'repairFocusKey':
          '21:actions_legal_context|10:no_bet_yet|11:action_read|23:misread_action_legality',
      'queueItemId': _activeQueueItemId,
    });
  });

  test('raw boolean success without source-goal context stays held', () {
    final state = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: [_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: [_outcome()],
      ),
    );
    expect(
      state.resolutions.single.resolutionState,
      act0QueueResolutionStateHeldV1,
    );
    expect(state.resolutions.single.isActionable, isTrue);
    expect(state.resolutions.single.isLaunchable, isFalse);
  });

  test('canonical target history rejects assisted or unknown provenance', () {
    final outcome = _outcome();
    final source = act0AuthoredRepairFixtureSourceV1(_activeRepairIntent);
    final attempt = act0AuthoredRepairFixtureAttemptV1(outcome, order: 2);
    for (final assistance in ['quickHint', 'theoryRecall', 'legacyUnknown']) {
      final record = Act0LearningEvidenceRecordV1.tryParse({
        ...attempt.toPayload(),
        'assistanceKind': assistance,
      })!;
      final state = _resolution(
        activeRepairIntents: [_activeRepairIntent],
        repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
          outcomes: [outcome],
        ),
        learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
          records: [source, record],
        ),
      );
      expect(
        state.resolutions.single.resolutionState,
        act0QueueResolutionStateUnresolvedV1,
      );
      expect(state.resolutions.single.isLaunchable, isTrue);
    }
  });

  test(
    'attached old occurrence cannot be relabelled to discharge a new miss',
    () {
      final current = Act0AuthoredRepairGoalFixtureV1.noBet(
        occurrenceId: 'source_miss_B',
      ).intent;
      final captured = _outcome();
      final relabelled = Act0RepairOutcomeV1.tryParse({
        ...captured.toPayload(),
        'repairOccurrenceId': current.repairOccurrenceId,
      })!;
      final state = _resolution(
        activeRepairIntents: [current],
        repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
          outcomes: [relabelled],
        ),
      );
      expect(
        state.resolutions.single.resolutionState,
        act0QueueResolutionStateUnresolvedV1,
      );
      expect(state.resolutions.single.isLaunchable, isTrue);
    },
  );

  test('W24 definition replay resolves only its actual familiar attempt', () {
    final fixture = Act0AuthoredRepairGoalFixtureV1.w24();
    final outcome = fixture.outcome();
    final state = _resolution(
      activeRepairIntents: [fixture.intent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: [outcome],
      ),
    );
    expect(
      state.resolutions.single.resolutionState,
      act0QueueResolutionStateResolvedV1,
    );
    final goal = act0RepairGoalResolutionForIntentV1(
      fixture.intent,
      learningEvidence: act0AuthoredRepairFixtureHistoryV1(
        intents: [fixture.intent],
        outcomes: [outcome],
      ),
      currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
    );
    expect(goal.canClaimIndependentApplication, isFalse);
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

final _fixture = Act0AuthoredRepairGoalFixtureV1.noBet();
final Act0RepairIntentV1 _activeRepairIntent = _fixture.intent;
String get _activeQueueItemId => _fixture.queueItemId;

Act0RepairOutcomeV1 _outcome({
  String? queueItemId,
  bool? isCorrect = true,
  int sequence = 3,
}) {
  final actual = _fixture.outcome(
    sequence: sequence,
    isCorrect: isCorrect == true,
  );
  return Act0RepairOutcomeV1.tryParse({
    ...actual.toPayload(),
    if (queueItemId != null) 'queueItemId': queueItemId,
    if (isCorrect == null) 'isCorrect': null,
    if (isCorrect == null) 'outcomeState': act0RepairOutcomeStateAttemptedV1,
  })!;
}

Act0QueueResolutionStateV1 _resolution({
  List<Act0RepairIntentV1> activeRepairIntents = const [],
  Act0RepairOutcomeProjectionV1 repairOutcomeProjection =
      const Act0RepairOutcomeProjectionV1(),
  Act0LearningEvidenceHistoryV1? learningEvidenceHistory,
}) => Act0QueueResolutionStateV1.fromSources(
  activeRepairIntents: activeRepairIntents,
  repairOutcomeProjection: repairOutcomeProjection,
  learningEvidenceHistory:
      learningEvidenceHistory ??
      act0AuthoredRepairFixtureHistoryV1(
        intents: activeRepairIntents,
        outcomes: repairOutcomeProjection.outcomes,
      ),
  currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
);

Act0PracticeRepairQueueProjectionV1 _practiceQueue({
  List<Act0RepairIntentV1> activeRepairIntents = const [],
  Act0QueueResolutionStateV1? queueResolutionState,
}) => Act0PracticeRepairQueueProjectionV1.fromSources(
  activeRepairIntents: activeRepairIntents,
  queueResolutionState: queueResolutionState,
  learningEvidenceHistory: act0AuthoredRepairFixtureHistoryV1(
    intents: activeRepairIntents,
  ),
  currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
);

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  test('first unresolved repair creates one queue item', () {
    final queue = const Act0MultiRepairQueueV1().upsertIntent(
      _intent('actions_legal_context'),
      order: 1,
    );

    expect(queue.entries, hasLength(1));
    expect(queue.entries.single.attemptCount, 1);
    expect(queue.activeRepairIntents(), hasLength(1));
  });

  test('second and third distinct unresolved repairs are preserved', () {
    final queue = _queueWith(<Act0RepairIntentV1>[
      _intent('actions_legal_context'),
      _intent('actions_check_drill', missedSignalId: 'facing_action'),
      _intent('actions_call_drill', missedSignalId: 'pot_to_call'),
    ]);

    expect(queue.entries, hasLength(3));
    expect(
      queue.activeRepairIntents().map((intent) => intent.sourceTaskId),
      <String>[
        'actions_legal_context',
        'actions_check_drill',
        'actions_call_drill',
      ],
    );
  });

  test('fourth item is rejected when bounded queue is full', () {
    final full = _queueWith(<Act0RepairIntentV1>[
      _intent('actions_legal_context'),
      _intent('actions_check_drill', missedSignalId: 'facing_action'),
      _intent('actions_call_drill', missedSignalId: 'pot_to_call'),
    ]);
    final rejected = full.upsertIntent(
      _intent('your_first_hand_flop', missedSignalId: 'board_cards'),
      order: 4,
    );

    expect(rejected.entries, hasLength(3));
    expect(
      rejected.activeRepairIntents().map((intent) => intent.sourceTaskId),
      isNot(contains('your_first_hand_flop')),
    );
  });

  test(
    'duplicate exact identity updates existing item instead of duplicating',
    () {
      final first = const Act0MultiRepairQueueV1().upsertIntent(
        _intent('actions_legal_context'),
        order: 1,
      );
      final second = first.upsertIntent(
        _intent('actions_legal_context'),
        order: 7,
      );

      expect(second.entries, hasLength(1));
      expect(second.entries.single.attemptCount, 2);
      expect(second.entries.single.createdAtOrder, 1);
      expect(second.entries.single.lastUpdatedAtOrder, 7);
    },
  );

  test('same family with different exact identity remains separate', () {
    final queue = _queueWith(<Act0RepairIntentV1>[
      _intent('actions_legal_context', missedSignalId: 'no_bet_yet'),
      _intent('actions_check_drill', missedSignalId: 'no_bet_yet'),
    ]);

    expect(queue.entries, hasLength(2));
    expect(
      queue.entries.map((entry) => entry.conceptFamilyId).toSet(),
      <String>{'no_bet_yet'},
    );
  });

  test('successful repair removes only matching item', () {
    final first = _intent('actions_legal_context');
    final second = _intent(
      'actions_check_drill',
      missedSignalId: 'facing_action',
    );
    final queue = _queueWith(<Act0RepairIntentV1>[first, second]);
    final resolution = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: queue.activeRepairIntents(),
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcomeFor(first, isCorrect: true)],
      ),
    );
    final pruned = queue.prunedWithResolution(resolution);

    expect(pruned.entries, hasLength(1));
    expect(pruned.entries.single.sourceTaskId, second.sourceTaskId);
  });

  test('failed repair keeps matching item actionable and first in order', () {
    final first = _intent('actions_legal_context');
    final second = _intent(
      'actions_check_drill',
      missedSignalId: 'facing_action',
    );
    final queue = _queueWith(<Act0RepairIntentV1>[first, second]);
    final resolution = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: queue.activeRepairIntents(),
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcomeFor(second, isCorrect: false)],
      ),
    );

    expect(
      queue.activeRepairIntents(resolutionState: resolution).first.sourceTaskId,
      second.sourceTaskId,
    );
    expect(
      resolution
          .resolutionForQueueItemId(queueItemIdForAct0RepairIntentV1(second))!
          .isActionable,
      isTrue,
    );
  });

  test('unrelated success changes nothing', () {
    final first = _intent('actions_legal_context');
    final queue = _queueWith(<Act0RepairIntentV1>[first]);
    final resolution = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: queue.activeRepairIntents(),
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcomeFor(
            _intent('other_task', missedSignalId: 'other_signal'),
            isCorrect: true,
          ),
        ],
      ),
    );

    expect(queue.prunedWithResolution(resolution).entries, hasLength(1));
  });

  test('old single-intent state migrates to one-item queue', () {
    final intent = _intent('actions_legal_context');
    final parsed = Act0MultiRepairQueueV1.tryParse(
      null,
      legacyOpenRepairIntents: <Act0RepairIntentV1>[intent],
    );

    expect(parsed.entries, hasLength(1));
    expect(parsed.entries.single.sourceTaskId, intent.sourceTaskId);
  });

  test('malformed stored item fails safely', () {
    final parsed = Act0MultiRepairQueueV1.tryParse(<String, Object?>{
      'schemaVersion': 1,
      'entries': <Object?>[
        <String, Object?>{'schemaVersion': 1, 'queueItemId': 'bad'},
      ],
    });

    expect(parsed.entries, isEmpty);
  });

  test('duplicate persisted identities collapse deterministically', () {
    final intent = _intent('actions_legal_context');
    final first = const Act0MultiRepairQueueV1()
        .upsertIntent(intent, order: 1)
        .entries
        .single
        .toPayload();
    final second = const Act0MultiRepairQueueV1()
        .upsertIntent(intent, order: 2)
        .entries
        .single
        .toPayload();
    final parsed = Act0MultiRepairQueueV1.tryParse(<String, Object?>{
      'schemaVersion': 1,
      'entries': <Object?>[second, first],
    });

    expect(parsed.entries, hasLength(1));
    expect(parsed.entries.single.createdAtOrder, 1);
  });

  test('queue ordering is deterministic across parse', () {
    final queue = _queueWith(<Act0RepairIntentV1>[
      _intent('actions_call_drill', missedSignalId: 'pot_to_call'),
      _intent('actions_legal_context', missedSignalId: 'no_bet_yet'),
      _intent('actions_check_drill', missedSignalId: 'facing_action'),
    ]);
    final parsed = Act0MultiRepairQueueV1.tryParse(queue.toPayload());

    expect(parsed.toPayload(), queue.toPayload());
  });

  test('top item changes after resolution and non-top item remains', () {
    final first = _intent('actions_legal_context');
    final second = _intent(
      'actions_check_drill',
      missedSignalId: 'facing_action',
    );
    final queue = _queueWith(<Act0RepairIntentV1>[first, second]);
    final resolution = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: queue.activeRepairIntents(),
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcomeFor(first, isCorrect: true)],
      ),
    );
    final pruned = queue.prunedWithResolution(resolution);

    expect(
      pruned.activeRepairIntents().single.sourceTaskId,
      second.sourceTaskId,
    );
  });

  test('no spaced repetition family is fabricated into a target', () {
    final source = Act0MultiRepairQueueV1.tryParse(<String, Object?>{
      'schemaVersion': 1,
      'entries': <Object?>[
        <String, Object?>{
          'schemaVersion': 1,
          'queueItemId': 'scheduled_family_only',
          'sourceRepairIdentity': 'nextDueFamily',
          'conceptFamilyId': 'nextDueFamily',
          'sourceTaskId': 'nextDueFamily',
          'createdAtOrder': 1,
          'lastUpdatedAtOrder': 1,
          'attemptCount': 1,
          'resolutionState': act0MultiRepairQueueStateUnresolvedV1,
        },
      ],
    });

    expect(source.entries, isEmpty);
  });
}

Act0MultiRepairQueueV1 _queueWith(List<Act0RepairIntentV1> intents) {
  var queue = const Act0MultiRepairQueueV1();
  for (var index = 0; index < intents.length; index++) {
    queue = queue.upsertIntent(intents[index], order: index + 1);
  }
  return queue;
}

Act0RepairIntentV1 _intent(
  String sourceTaskId, {
  String missedSignalId = 'no_bet_yet',
}) {
  return Act0RepairIntentV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'fold_check_call_raise',
    sourceTaskId: sourceTaskId,
    choiceId: 'fold',
    result: 'incorrect',
    errorType: 'missed_action_read',
    missedSignalId: missedSignalId,
    missedSignalLabel: missedSignalId,
    skillAtomId: 'action_read',
    skillLabel: 'Action read',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    mappingType: 'repair',
    reasonCode: 'same_signal_action_read_$missedSignalId',
  );
}

Act0RepairOutcomeV1 _outcomeFor(
  Act0RepairIntentV1 intent, {
  required bool isCorrect,
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: intent.sourceTaskId,
    repairTaskId: intent.targetTaskId,
    repairFocusKey: repairQueueIdentityKeyForAct0RepairIntentV1(intent),
    queueItemId: queueItemIdForAct0RepairIntentV1(intent),
    targetWorldId: intent.targetWorldId,
    targetLessonId: intent.targetLessonId,
    targetTaskId: intent.targetTaskId,
    selectedChoiceId: isCorrect ? 'check' : 'fold',
    correctChoiceId: 'check',
    isCorrect: isCorrect,
    outcomeState: isCorrect
        ? act0RepairOutcomeStateCorrectV1
        : act0RepairOutcomeStateStillNeedsRepV1,
    sequence: 1,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}

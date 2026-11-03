import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _worldId = 'world_1';
const _lessonId = 'blinds_action_order';
const _taskId = 'blinds_review';
const _skillAtomId = 'table_read';
final _task = Act0ShellStateV1.sample
    .lessonById(_lessonId)
    .tasks
    .singleWhere((task) => task.taskId == _taskId);

void main() {
  final utgOption = _task.runner.options.singleWhere(
    (option) => option.id == 'utg',
  );

  test(
    'current sample independently confirms UTG and its source skill atom',
    () {
      expect(utgOption.isCorrect, isTrue);
      expect(
        _task.runner.options.where((option) => option.isCorrect),
        hasLength(1),
      );

      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: _task.runner,
        option: utgOption,
        taskFamily: _task.resolvedTaskFamily,
      );
      expect(receipt, isNotNull);
      expect(receipt!.skillAtomId, _skillAtomId);
    },
  );

  test('HG01 synthetic historical BB grades cannot make current proof', () {
    // Synthetic historical regression fixture; not actual user saves or native proof.
    final history = _roundTrippedHistory(
      List<Act0LearningEvidenceRecordV1>.generate(
        5,
        (index) => _record(
          order: index + 1,
          choiceId: 'bb',
          expectedChoiceId: 'bb',
          assistanceKind: Act0DecisionAssistanceV1.none,
        ),
      ),
    );

    final projection =
        Act0ProfileEvidenceProjectionV1.fromCurrentAuthoredEvidenceHistory(
          history,
        );
    final consumer = Act0ProfileEvidenceConsumerV1.fromProjection(projection);

    expect(consumer.hasSignal, isTrue);
    expect(
      consumer.signal!.confirmationState,
      act0RecentEvidenceConfirmationNeededV1,
    );
    final achievement = Act0AchievementSeedProjectionV1.fromSources(
      learningEvidenceHistory: history,
      profileEvidenceProjection: projection,
    );
    expect(
      achievement.seedForId(act0AchievementSeedFirstEvidenceSignalV1).earned,
      isFalse,
    );
  });

  test(
    'HG02 current source records meet shared recent-verification predicate',
    () {
      // Synthetic current-answer control; not actual user saves or native proof.
      final history = _freshCurrentHistory(<String>[
        'utg',
        'btn',
        'utg',
        'btn',
        'utg',
      ]);
      final restored = Act0LearningEvidenceHistoryV1.tryParse(
        jsonDecode(history.toStorageString()),
      )!;
      final projection =
          Act0ProfileEvidenceProjectionV1.fromCurrentAuthoredEvidenceHistory(
            restored,
          );
      final consumer = Act0ProfileEvidenceConsumerV1.fromProjection(projection);

      expect(restored.records, hasLength(5));
      expect(
        restored.records.every(
          (record) => record.authoredSourceFingerprint.isNotEmpty,
        ),
        isTrue,
      );
      expect(projection.signals.single.attemptCount, 5);
      expect(projection.signals.single.correctCount, 3);
      expect(consumer.hasSignal, isTrue);
      expect(consumer.signal!.skillAtomId, _skillAtomId);
      expect(consumer.signal!.confirmationState, act0RecentEvidenceVerifiedV1);
    },
  );

  test(
    'current source recomputes stored grade, expected answer, and skill',
    () {
      final current = _freshCurrentHistory(<String>[
        'utg',
        'btn',
        'utg',
        'btn',
        'utg',
      ]);
      final sourceCorrectWithStaleStoredFields =
          Act0LearningEvidenceRecordV1.tryParse(
            current.records.first.toPayload()
              ..['expectedChoiceId'] = 'btn'
              ..['isCorrect'] = false
              ..['resultKind'] = 'incorrect'
              ..['errorType'] = 'missed_action_read'
              ..['skillAtomId'] = 'wrong_historical_atom',
          )!;
      final history = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          sourceCorrectWithStaleStoredFields,
          ...current.records.skip(1),
        ],
      );
      final projection =
          Act0ProfileEvidenceProjectionV1.fromCurrentAuthoredEvidenceHistory(
            history,
          );

      expect(projection.signals.single.skillAtomId, _skillAtomId);
      expect(projection.signals.single.correctCount, 3);
      expect(projection.signals.single.isCapabilityEligible, isTrue);
    },
  );

  test('current source ignores an old grade for a still-valid choice ID', () {
    final fresh = _freshCurrentHistory(List<String>.filled(5, 'btn'));
    final history = Act0LearningEvidenceHistoryV1(
      records: fresh.records
          .map(
            (r) => Act0LearningEvidenceRecordV1.tryParse(
              r.toPayload()
                ..['isCorrect'] = true
                ..['resultKind'] = 'correct'
                ..['errorType'] = 'none'
                ..['expectedChoiceId'] = 'btn',
            )!,
          )
          .toList(),
    );
    final projection =
        Act0ProfileEvidenceProjectionV1.fromCurrentAuthoredEvidenceHistory(
          history,
        );

    expect(projection.signals, hasLength(1));
    expect(projection.signals.single.attemptCount, 5);
    expect(projection.signals.single.correctCount, 0);
    expect(projection.signals.single.isCapabilityEligible, isFalse);
  });

  test('HG03 assisted correct answers are excluded from independent proof', () {
    // Synthetic current-answer assistance fixture; not actual user saves or native proof.
    final history = _freshCurrentHistory(
      List<String>.filled(5, 'utg'),
      assistance: <Act0DecisionAssistanceV1>[
        Act0DecisionAssistanceV1.none,
        Act0DecisionAssistanceV1.none,
        Act0DecisionAssistanceV1.none,
        Act0DecisionAssistanceV1.quickHint,
        Act0DecisionAssistanceV1.theoryRecall,
      ],
    );

    expect(history.records[3].isAssistedCorrect, isTrue);
    expect(history.records[3].isIndependentCorrect, isFalse);
    expect(history.records[4].isAssistedCorrect, isTrue);
    expect(history.records[4].isIndependentCorrect, isFalse);
    final projection =
        Act0ProfileEvidenceProjectionV1.fromCurrentAuthoredEvidenceHistory(
          history,
        );
    expect(projection.signals.single.attemptCount, 3);
    expect(projection.signals.single.correctCount, 3);
    expect(projection.signals.single.isCapabilityEligible, isFalse);
    expect(
      Act0ProfileEvidenceConsumerV1.fromProjection(
        projection,
      ).signal!.confirmationState,
      act0RecentEvidenceConfirmationNeededV1,
    );
  });

  test(
    'HG04 historical IDs, choices, and grades survive schema1 JSON roundtrip',
    () {
      // Synthetic historical regression fixture; asserts preserved history, not user data.
      final original = List<Act0LearningEvidenceRecordV1>.generate(
        5,
        (index) => _record(
          order: index + 1,
          choiceId: 'bb',
          expectedChoiceId: 'bb',
          assistanceKind: Act0DecisionAssistanceV1.none,
        ),
      );
      final restored = _roundTrippedHistory(original).records;

      expect(
        restored.map((record) => record.recordId),
        original.map((record) => record.recordId),
      );
      expect(restored.map((record) => record.choiceId), everyElement('bb'));
      expect(
        restored.map((record) => record.expectedChoiceId),
        everyElement('bb'),
      );
      expect(restored.map((record) => record.isCorrect), everyElement(isTrue));
    },
  );

  test('legacy sealed lineage bytes survive absent optional fingerprint', () {
    final legacy = _record(
      order: 1,
      choiceId: 'bb',
      expectedChoiceId: 'bb',
      assistanceKind: Act0DecisionAssistanceV1.none,
    );
    final payload = legacy.toPayload();
    expect(payload.containsKey('authoredSourceFingerprint'), isFalse);
    final restored = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[legacy],
    );
    final seal = restored.lineagePayload();
    expect(
      seal['anchorSha256'],
      'd66673706840787e76f29ed57c21102eff61766ed3e392e868e5d1c1c5ecdd5c',
    );
    expect(
      seal['lineageSha256'],
      '2454d42013a1fd4f0addf946bbecacfe7b549ef7f42fb6edda227a20590a71a0',
    );
    expect(
      Act0LearningEvidenceHistoryV1.tryParse(
        jsonDecode(restored.toStorageString()),
      ),
      isNotNull,
    );
  });

  test(
    'condition-only source changes invalidate while option order does not',
    () {
      final fingerprint = act0AuthoredSourceFingerprintV1(
        worldId: _worldId,
        lessonId: _lessonId,
        task: _task,
      )!;
      final reordered = _taskWithRunner(
        _task,
        runner: _task.runner.copyWith(
          options: _task.runner.options.reversed
              .map((option) => _optionWithLabel(option, 'presentation only'))
              .toList(),
        ),
      );
      final conditionChanged = _taskWithRunner(
        _task,
        runner: _task.runner.copyWith(
          question: '${_task.runner.question} revised',
        ),
      );
      expect(
        act0AuthoredSourceFingerprintV1(
          worldId: _worldId,
          lessonId: _lessonId,
          task: reordered,
        ),
        fingerprint,
      );
      expect(
        act0AuthoredSourceFingerprintV1(
          worldId: _worldId,
          lessonId: _lessonId,
          task: conditionChanged,
        ),
        isNot(fingerprint),
      );
      expect(
        conditionChanged.runner.options.map((option) => option.id).toSet(),
        _task.runner.options.map((option) => option.id).toSet(),
      );
      final oldEvidence = _record(
        order: 1,
        choiceId: 'utg',
        expectedChoiceId: 'utg',
        authoredSourceFingerprint: fingerprint,
      );
      expect(
        act0CurrentAuthoredSourceProofForTaskV1(
          record: oldEvidence,
          worldId: _worldId,
          lessonId: _lessonId,
          task: conditionChanged,
        ),
        isNull,
      );
    },
  );

  test('missing source and tampered new lineage metadata fail closed', () {
    final current = _freshCurrentHistory(<String>[
      'utg',
      'btn',
      'utg',
      'btn',
      'utg',
    ]);
    final record = current.records.first;
    final missingSourceRecord = _record(
      order: record.createdOrder,
      choiceId: record.choiceId,
      expectedChoiceId: record.expectedChoiceId,
      assistanceKind: record.assistanceKind,
      worldId: 'unknown_world',
      authoredSourceFingerprint: record.authoredSourceFingerprint,
    );
    expect(act0CurrentAuthoredSourceProofV1(missingSourceRecord), isNull);

    final storage =
        jsonDecode(current.toStorageString()) as Map<String, dynamic>;
    final lineage = storage['lineage'] as Map<String, dynamic>;
    final anchors = lineage['anchors'] as List<dynamic>;
    (anchors.first as Map<String, dynamic>)['authoredSourceFingerprint'] =
        'tampered';
    expect(Act0LearningEvidenceHistoryV1.tryParse(storage), isNull);
  });

  test('mixed legacy and current history needs five compatible attempts', () {
    final legacy = List<Act0LearningEvidenceRecordV1>.generate(
      4,
      (index) => _record(
        order: index + 1,
        choiceId: 'bb',
        expectedChoiceId: 'bb',
        assistanceKind: Act0DecisionAssistanceV1.none,
      ),
    );
    final current = _freshCurrentHistory(<String>['utg']);
    final mixed = _roundTrippedHistory(<Act0LearningEvidenceRecordV1>[
      ...legacy,
      ...current.records.map(
        (record) => Act0LearningEvidenceRecordV1.tryParse(
          record.toPayload()..['createdOrder'] = record.createdOrder + 4,
        )!,
      ),
    ]);
    final projection =
        Act0ProfileEvidenceProjectionV1.fromCurrentAuthoredEvidenceHistory(
          mixed,
        );
    expect(projection.signals, hasLength(1));
    expect(projection.signals.single.attemptCount, 1);
    expect(projection.signals.single.isCapabilityEligible, isFalse);
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  required String choiceId,
  required String expectedChoiceId,
  bool isCorrect = true,
  String worldId = _worldId,
  String authoredSourceFingerprint = '',
  String skillAtomId = _skillAtomId,
  Act0DecisionAssistanceV1 assistanceKind = Act0DecisionAssistanceV1.none,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'synthetic_asm07_v1|$worldId|$_lessonId|$_taskId|$choiceId|$order',
  createdOrder: order,
  worldId: worldId,
  lessonId: _lessonId,
  taskId: _taskId,
  sourceTaskId: _taskId,
  choiceId: choiceId,
  expectedChoiceId: expectedChoiceId,
  isCorrect: isCorrect,
  errorType: isCorrect ? 'none' : 'missed_action_read',
  conceptFamilyId: 'blinds_action_order',
  repairFocusId: '',
  skillAtomId: skillAtomId,
  decisionTimeBucket: '3_to_10s',
  resultKind: isCorrect ? 'correct' : 'incorrect',
  assistanceKind: assistanceKind,
  authoredSourceFingerprint: authoredSourceFingerprint,
);

Act0LearningEvidenceHistoryV1 _freshCurrentHistory(
  List<String> choices, {
  List<Act0DecisionAssistanceV1>? assistance,
}) {
  var history = const Act0LearningEvidenceHistoryV1();
  for (var index = 0; index < choices.length; index++) {
    final source = index.isEven
        ? _task
        : Act0ShellStateV1.sample
              .lessonById(_lessonId)
              .tasks
              .singleWhere((t) => t.taskId == 'blinds_first_actor');
    final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
      worldId: _worldId,
      lessonId: _lessonId,
      taskId: source.taskId,
    )!;
    final choiceId = choices[index];
    final choice = source.runner.options.singleWhere(
      (option) => option.id == choiceId,
    );
    final correct =
        choice.isCorrect && choice.quality == Act0FeedbackQualityV1.correct;
    final decision = Act0CompletedDecisionV1(
      attemptKey: 'synthetic_current_v1|$_worldId|$_lessonId|$_taskId|$index',
      worldId: _worldId,
      lessonId: _lessonId,
      taskId: source.taskId,
      sourceTaskId: source.taskId,
      decisionKind: Act0CompletedDecisionKindV1.seat,
      selectedId: choiceId,
      expectedId: 'utg',
      isCorrect: correct,
      decisionTimeBucket: '3_to_10s',
      taskFamily: source.resolvedTaskFamily,
      resultKind: correct ? 'correct' : 'incorrect',
      errorType: correct ? 'none' : 'missed_action_read',
      skillAtomId: _skillAtomId,
      repairFocusId: act0FirstValueSkillReceiptForRunnerV1(
        runner: source.runner,
        option: choice,
        taskFamily: source.resolvedTaskFamily,
      )!.sourceSignalId,
      assistanceKind: assistance == null
          ? Act0DecisionAssistanceV1.none
          : assistance[index],
    );
    history = history.appendCompletedDecision(
      decision,
      authoredSourceFingerprint: fingerprint,
      sessionId: 'synthetic_session|$index',
      recordedAtUtc: DateTime.utc(2026, 1, 1).add(Duration(days: index)),
      reviewKind: Act0ReviewKindV1.spacedReview,
    );
  }
  return history;
}

Act0LessonTaskV1 _taskWithRunner(
  Act0LessonTaskV1 source, {
  required Act0RunnerStateV1 runner,
}) => Act0LessonTaskV1(
  taskId: source.taskId,
  title: source.title,
  phase: source.phase,
  runner: runner,
  rewardXp: source.rewardXp,
  stepKind: source.stepKind,
  taskFamily: source.taskFamily,
  tablePresentation: source.tablePresentation,
  summary: source.summary,
  lockedSummary: source.lockedSummary,
);

Act0RunnerOptionV1 _optionWithLabel(Act0RunnerOptionV1 option, String label) =>
    Act0RunnerOptionV1(
      id: option.id,
      label: label,
      amountLabel: option.amountLabel,
      seatId: option.seatId,
      isCorrect: option.isCorrect,
      preferredLabel: option.preferredLabel,
      betterAnswerLabel: option.betterAnswerLabel,
      quality: option.quality,
      feedbackTitle: option.feedbackTitle,
      feedbackReason: option.feedbackReason,
      repairFocusSeatIds: option.repairFocusSeatIds,
      repairFocusCardIds: option.repairFocusCardIds,
      repairFocusLabels: option.repairFocusLabels,
    );

Act0LearningEvidenceHistoryV1 _roundTrippedHistory(
  List<Act0LearningEvidenceRecordV1> records,
) {
  final encoded = jsonEncode(
    records.map((record) => record.toPayload()).toList(growable: false),
  );
  final decoded = jsonDecode(encoded);
  return Act0LearningEvidenceHistoryV1.tryParse(decoded)!;
}

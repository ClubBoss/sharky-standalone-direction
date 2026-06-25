import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';

void main() {
  test(
    'empty sources keep available seeds unearned and blocked seeds blocked',
    () {
      final projection = Act0AchievementSeedProjectionV1.fromSources();

      expect(projection.earnedSeeds, isEmpty);
      expect(
        projection.seedForId(act0AchievementSeedFirstCorrectReadV1).earned,
        isFalse,
      );
      expect(
        projection.seedForId(act0AchievementSeedFirstCorrectReadV1).state,
        act0AchievementSeedStateNotEarnedV1,
      );
      expect(
        projection.seedForId(act0AchievementSeedFirstLessonCompleteV1).state,
        act0AchievementSeedStateBlockedMissingSourceV1,
      );
      expect(
        projection.seedForId(act0AchievementSeedFirstCleanMiniDrillV1).earned,
        isFalse,
      );
    },
  );

  test('first correct read is earned from a completed correct decision', () {
    final projection = Act0AchievementSeedProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _evidenceRecord(order: 1),
          _evidenceRecord(order: 2, isCorrect: true),
        ],
      ),
    );

    final seed = projection.seedForId(act0AchievementSeedFirstCorrectReadV1);

    expect(seed.earned, isTrue);
    expect(seed.state, act0AchievementSeedStateEarnedV1);
    expect(seed.sourceOwner, 'Act0LearningEvidenceHistoryV1');
    expect(seed.earnedSequence, 2);
    expect(seed.sourceSummary['completedCorrectDecisions'], 1);
  });

  test('first repair note is earned from a real repair or mistake source', () {
    final fromRepair = Act0AchievementSeedProjectionV1.fromSources(
      repairIntents: const <Act0RepairIntentV1>[_repairIntent],
    );
    final fromMistake = Act0AchievementSeedProjectionV1.fromSources(
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[_mistakeRecord(order: 3)],
      ),
    );

    expect(
      fromRepair.seedForId(act0AchievementSeedFirstRepairNoteV1).earned,
      isTrue,
    );
    expect(
      fromMistake.seedForId(act0AchievementSeedFirstRepairNoteV1).earned,
      isTrue,
    );
    expect(
      fromRepair
          .seedForId(act0AchievementSeedFirstRepairNoteV1)
          .sourceSummary['repairIntentCount'],
      1,
    );
  });

  test('first review history item is earned from unresolved history', () {
    final projection = Act0AchievementSeedProjectionV1.fromSources(
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[_mistakeRecord(order: 4)],
      ),
    );

    final seed = projection.seedForId(
      act0AchievementSeedFirstReviewHistoryItemV1,
    );

    expect(seed.earned, isTrue);
    expect(seed.sourceOwner, 'Act0ReviewMistakeHistoryV1');
    expect(seed.sourceSummary['unresolvedHistoryCount'], 1);
    expect(seed.sourceSummary['firstCreatedOrder'], 4);
  });

  test('first evidence signal is earned from eligible profile evidence', () {
    final projection = Act0AchievementSeedProjectionV1.fromSources(
      profileEvidenceProjection: const Act0ProfileEvidenceProjectionV1(
        signals: <Act0ProfileCapabilitySignalV1>[
          Act0ProfileCapabilitySignalV1(
            signalId: 'profile_evidence_v1|action_read',
            skillAtomId: 'action_read',
            attemptCount: 5,
            correctCount: 3,
            incorrectCount: 2,
            accuracyPercent: 60,
            sampleThreshold: 5,
            sampleThresholdMet: true,
            positiveSignalThresholdMet: true,
            worldIds: <String>['world_1'],
            lessonIds: <String>['fold_check_call_raise'],
            latestOrder: 5,
            eligibilityState: act0ProfileEvidenceStateEligibleSignalV1,
          ),
        ],
      ),
    );

    final seed = projection.seedForId(act0AchievementSeedFirstEvidenceSignalV1);

    expect(seed.earned, isTrue);
    expect(seed.sourceOwner, 'Act0ProfileEvidenceProjectionV1');
    expect(seed.sourceSummary['eligibleSignalCount'], 1);
    expect(seed.earnedSequence, 5);
  });

  test(
    'first session complete is earned only from explicit grouped run summary',
    () {
      final ungrouped = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _evidenceRecord(order: 1, isCorrect: true),
          ],
        ),
      );
      final grouped = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _evidenceRecord(
              order: 1,
              isCorrect: true,
              runId: 'run_v1|world_1|fold_check_call_raise|1',
              runKind: 'lesson',
              runOrdinal: 1,
            ),
          ],
        ),
      );

      expect(
        ungrouped.seedForId(act0AchievementSeedFirstSessionCompleteV1).earned,
        isFalse,
      );
      final seed = grouped.seedForId(act0AchievementSeedFirstSessionCompleteV1);
      expect(seed.earned, isTrue);
      expect(seed.sourceSummary['spotsPlayed'], 1);
      expect(seed.sourceSummary['runKind'], 'lesson');
    },
  );

  test('three-day streak is earned only from owned profile streak count', () {
    final below = Act0AchievementSeedProjectionV1.fromSources(
      profileStreakDays: 2,
    );
    final earned = Act0AchievementSeedProjectionV1.fromSources(
      profileStreakDays: 3,
    );

    expect(
      below.seedForId(act0AchievementSeedThreeDayStreakV1).earned,
      isFalse,
    );
    final seed = earned.seedForId(act0AchievementSeedThreeDayStreakV1);
    expect(seed.earned, isTrue);
    expect(seed.sourceOwner, 'Act0ProfileStateV1.streakDays');
    expect(seed.sourceSummary['streakDays'], 3);
  });

  test('blocked triggers remain blocked and unearned', () {
    final projection = Act0AchievementSeedProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _evidenceRecord(
            order: 1,
            isCorrect: true,
            runId: 'run_v1|world_1|fold_check_call_raise|1',
            runKind: 'lesson',
            runOrdinal: 1,
          ),
        ],
      ),
      repairIntents: const <Act0RepairIntentV1>[_repairIntent],
      reviewMistakeHistory: Act0ReviewMistakeHistoryV1(
        records: <Act0ReviewMistakeRecordV1>[_mistakeRecord(order: 2)],
      ),
      profileEvidenceProjection: const Act0ProfileEvidenceProjectionV1(
        signals: <Act0ProfileCapabilitySignalV1>[
          Act0ProfileCapabilitySignalV1(
            signalId: 'profile_evidence_v1|action_read',
            skillAtomId: 'action_read',
            attemptCount: 5,
            correctCount: 3,
            incorrectCount: 2,
            accuracyPercent: 60,
            sampleThreshold: 5,
            sampleThresholdMet: true,
            positiveSignalThresholdMet: true,
            worldIds: <String>['world_1'],
            lessonIds: <String>['fold_check_call_raise'],
            latestOrder: 5,
            eligibilityState: act0ProfileEvidenceStateEligibleSignalV1,
          ),
        ],
      ),
      profileStreakDays: 3,
    );

    for (final id in <String>[
      act0AchievementSeedFirstLessonCompleteV1,
      act0AchievementSeedFirstCleanMiniDrillV1,
    ]) {
      final seed = projection.seedForId(id);
      expect(seed.earned, isFalse);
      expect(seed.state, act0AchievementSeedStateBlockedMissingSourceV1);
      expect(seed.sourceSummary, isEmpty);
    }
  });

  test(
    'payload and source contain no forbidden claim or reward vocabulary',
    () {
      final projection = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _evidenceRecord(order: 1, isCorrect: true),
          ],
        ),
        profileStreakDays: 3,
      );
      final payloadText = projection.toPayload().toString().toLowerCase();
      final sourceText = File(
        'lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart',
      ).readAsStringSync().toLowerCase();

      for (final forbidden in <String>[
        'mastered',
        'leak fixed',
        'ai found',
        'ai detected',
        'gto',
        'solver',
        'premium',
        'leaderboard',
        'xp',
        'reward',
        'badge',
        'achievement unlocked',
        'fixed',
      ]) {
        expect(payloadText, isNot(contains(forbidden)));
        expect(sourceText, isNot(contains(forbidden)));
      }
    },
  );

  test('projection ordering is deterministic by contract order', () {
    final projection = Act0AchievementSeedProjectionV1.fromSources();

    expect(projection.seeds.map((seed) => seed.id), <String>[
      act0AchievementSeedFirstCorrectReadV1,
      act0AchievementSeedFirstRepairNoteV1,
      act0AchievementSeedFirstReviewHistoryItemV1,
      act0AchievementSeedFirstEvidenceSignalV1,
      act0AchievementSeedFirstSessionCompleteV1,
      act0AchievementSeedThreeDayStreakV1,
      act0AchievementSeedFirstLessonCompleteV1,
      act0AchievementSeedFirstCleanMiniDrillV1,
    ]);
  });
}

const _repairIntent = Act0RepairIntentV1(
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

Act0LearningEvidenceRecordV1 _evidenceRecord({
  required int order,
  bool isCorrect = false,
  String runId = '',
  String runKind = '',
  int? runOrdinal,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: '$order:world_1:fold_check_call_raise:action_read',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    repairFocusId: isCorrect ? '' : 'no_bet_yet',
    skillAtomId: 'action_read',
    decisionTimeBucket: '3_to_10s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
    runId: runId,
    runKind: runKind,
    runOrdinal: runOrdinal,
  );
}

Act0ReviewMistakeRecordV1 _mistakeRecord({required int order}) {
  return Act0ReviewMistakeRecordV1(
    recordId: 'mistake_v1|$order',
    sourceDecisionId: 'decision_v1|$order',
    createdOrder: order,
    updatedOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    decisionTaskId: 'actions_legal_context',
    sourceTaskId: 'actions_legal_context',
    decisionKind: 'actionList',
    selectedId: 'fold',
    expectedId: 'check',
    resultKind: 'incorrect',
    errorType: 'missed_action_read',
    skillAtomId: 'action_read',
    repairFocusId: 'no_bet_yet',
    runId: 'run_v1|world_1|fold_check_call_raise|1',
    runKind: 'lesson',
    runOrdinal: 1,
    attemptRecordIds: <String>['decision_v1|$order'],
    dedupUsesFallback: false,
  );
}

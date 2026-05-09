import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/learning_stats_v1_service.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ProgressService.debugNowOverride = null;
  });

  tearDown(() {
    ProgressService.debugNowOverride = null;
  });

  test(
    'add/get keeps review queue recency-first, deduped, and clearable',
    () async {
      const packId = 'world1_spine_campaign_v1';

      await ProgressService.addReviewRefForPackV1(
        packId,
        const ReviewRefV1(packId: packId, stepIndex: 3),
      );
      await ProgressService.addReviewRefForPackV1(
        packId,
        const ReviewRefV1(packId: packId, stepIndex: 1),
      );
      await ProgressService.addReviewRefForPackV1(
        packId,
        const ReviewRefV1(packId: packId, stepIndex: 3),
      );
      await ProgressService.addReviewRefForPackV1(
        packId,
        const ReviewRefV1(packId: packId, stepIndex: 2),
      );

      expect(await ProgressService.hasReviewQueueForPackV1(packId), isTrue);

      final queue = await ProgressService.getReviewQueueForPackV1(packId);
      expect(queue, hasLength(3));
      expect(
        queue.map((e) => e.stepIndex).toList(),
        <int>[2, 1, 3],
        reason: 'Newest missed spot should be reviewed first.',
      );
      expect(queue.every((e) => e.packId == packId), isTrue);

      await ProgressService.clearReviewQueueForPackV1(packId);
      expect(await ProgressService.hasReviewQueueForPackV1(packId), isFalse);
      expect(await ProgressService.getReviewQueueForPackV1(packId), isEmpty);
    },
  );

  test(
    'read drops out-of-range and malformed refs for known campaign pack',
    () async {
      const packId = 'world1_spine_campaign_v1'; // 12-step campaign pack
      SharedPreferences.setMockInitialValues(<String, Object>{
        'review_queue_v1::$packId':
            '[{"packId":"$packId","stepIndex":2},'
            '{"packId":"$packId","stepIndex":99},'
            '{"packId":"$packId","stepIndex":-1},'
            '{"packId":"other_pack","stepIndex":1},'
            '{"packId":"$packId","stepIndex":"4"},'
            '{"packId":"$packId","stepIndex":2}]',
      });

      final queue = await ProgressService.getReviewQueueForPackV1(packId);
      expect(queue.map((e) => e.stepIndex).toList(), <int>[2, 4]);
    },
  );

  test('checkpoint trigger becomes pending exactly every 4 sessions', () async {
    for (var i = 1; i <= 8; i++) {
      final update = await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s${i.toString().padLeft(2, '0')}',
        worldId: 'world1',
      );
      final shouldTrigger = i % ProgressService.checkpointEverySessionsV1 == 0;
      expect(update.checkpointPending, shouldTrigger);
      expect(
        update.completedSessionsSinceLastCheckpoint,
        shouldTrigger ? 0 : i % ProgressService.checkpointEverySessionsV1,
      );
      if (shouldTrigger) {
        await ProgressService.clearCheckpointPendingV1();
      }
    }
  });

  test(
    'checkpoint top error queue is capped to 3 with deterministic tie-breaks',
    () async {
      Future<void> record(int index, List<String> errorClasses) async {
        await ProgressService.recordSessionForCheckpointV1(
          sessionId: 'w2.s${index.toString().padLeft(2, '0')}',
          worldId: 'world2',
          errorClasses: errorClasses,
        );
      }

      await record(1, <String>['a']);
      await record(2, <String>['b', 'd']);
      await record(3, <String>['c']);
      await record(4, <String>['a']);
      await record(5, <String>['b']);
      await record(6, <String>['c']);

      final top = await ProgressService.getCheckpointTopErrorClassesV1();
      expect(top, <String>['b', 'c', 'a']);
      expect(top, hasLength(3));
    },
  );

  Future<void> _seedWorld1FollowupRoutingV1() async {
    await ProgressService.markSpinePackCompletedV1(
      'world1_act0_table_literacy',
    );
    await ProgressService.markSpinePackCompletedV1(
      'world1_act0_action_literacy',
    );
    await ProgressService.markSpinePackCompletedV1('world1_act0_street_flow');
    await ProgressService.markSpineCalibrationCompletedV1();
    await ProgressService.setSpineCalibrationBandV1(
      ProgressService.spineCalibrationBandBeginner,
    );
  }

  Future<void> _resetLearningStatsMismatchCountersV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('learning_stats_v1_expected_action_mismatch_errors', 0);
    await prefs.setInt('learning_stats_v1_tocall_legality_mismatch_errors', 0);
    await prefs.setInt(
      'learning_stats_v1_unnecessary_fold_when_check_available_errors',
      0,
    );
  }

  test(
    'adaptive followup uses checkpoint top error fallback when learning stats tie',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s01',
        worldId: 'world1',
        errorClasses: const <String>['wrong_action'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'learning stats focus precedence still wins over checkpoint fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s02',
        worldId: 'world1',
        errorClasses: const <String>['wrong_action'],
      );
      await LearningStatsV1Service.instance
          .incrementToCallLegalityMismatchError();

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'learning-stats tie-break fallback uses unnecessary-fold signal on non-zero primary mismatch ties',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await LearningStatsV1Service.instance
          .incrementExpectedActionMismatchError();
      await LearningStatsV1Service.instance
          .incrementToCallLegalityMismatchError();
      await LearningStatsV1Service.instance
          .incrementUnnecessaryFoldWhenCheckAvailableError();

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'to-call mismatch precedence still wins over unnecessary-fold tie-break signal',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await LearningStatsV1Service.instance
          .incrementToCallLegalityMismatchError();
      await LearningStatsV1Service.instance
          .incrementUnnecessaryFoldWhenCheckAvailableError();

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'checkpoint fallback remains deterministic with multiple top-error entries',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s10',
        worldId: 'world1',
        errorClasses: const <String>['wrong_action'],
      );
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s11',
        worldId: 'world1',
        errorClasses: const <String>['to_call_mismatch'],
      );
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s12',
        worldId: 'world1',
        errorClasses: const <String>['to_call_mismatch'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'checkpoint fallback preserves prior followup when top errors do not map',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s20',
        worldId: 'world1',
        errorClasses: const <String>['zzz_unknown_class_v1'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'zero unnecessary-fold tie-break signal preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'focusLabel': 'zzz_unknown_focus_v1',
        'placementScore': 2,
        'skillBand': 'intermediate',
      });

      final baseline = await ProgressService.getNextSpinePackToRunV1();
      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );

  test(
    'unnecessary-fold signal without primary mismatch conflict falls through to prior fallback chain',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.r48.01',
        worldId: 'world1',
        errorClasses: const <String>['to_call_mismatch'],
      );
      await LearningStatsV1Service.instance
          .incrementUnnecessaryFoldWhenCheckAvailableError();

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(
        nextPack,
        'world1_spine_followup_v1_b0',
        reason:
            'Tie-break should not override checkpoint fallback when primary mismatch counters are both zero.',
      );

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'placement-score fallback is used when higher-priority focus signals do not resolve',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(3);

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'higher-priority checkpoint fallback still wins over placement-score fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(0);
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s40',
        worldId: 'world1',
        errorClasses: const <String>['wrong_action'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');
    },
  );

  test(
    'neutral placement-score mapping preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.setPlacementScoreV1(2);

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );

  test(
    'skill-band fallback is used when higher-priority signals do not resolve',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setSkillBandV1('advanced');

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'higher-priority placement-score fallback still wins over skill-band fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(0);
      await ProgressService.setSkillBandV1('advanced');

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'invalid skill-band mapping preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.setSkillBandV1('zzz_unknown_band_v1');

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );

  test(
    'skill-tags fallback is used when higher-priority signals do not resolve',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['range'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'higher-priority skill-band fallback still wins over skill-tags fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('beginner');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['range'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'invalid skill-tags mapping preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'focus-review-due fallback is used when higher-priority focus signals do not resolve',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final now = DateTime.utc(2026, 1, 1, 12);
      ProgressService.debugNowOverride = () => now;
      await ProgressService.setLessonFocusLabel('pot_odds');
      await ProgressService.scheduleFocusReviewIn24h('pot_odds');
      ProgressService.debugNowOverride = () =>
          now.add(const Duration(hours: 25));

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'checkpoint fallback still wins over focus-review-due fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final now = DateTime.utc(2026, 1, 2, 12);
      ProgressService.debugNowOverride = () => now;
      await ProgressService.setLessonFocusLabel('pot_odds');
      await ProgressService.scheduleFocusReviewIn24h('pot_odds');
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: 'w1.s30',
        worldId: 'world1',
        errorClasses: const <String>['wrong_action'],
      );
      ProgressService.debugNowOverride = () =>
          now.add(const Duration(hours: 25));

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');
    },
  );

  test(
    'invalid focus-review-due mapping preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      final now = DateTime.utc(2026, 1, 3, 12);
      ProgressService.debugNowOverride = () => now;
      await ProgressService.setLessonFocusLabel('zzz_unknown_focus_v1');
      await ProgressService.scheduleFocusReviewIn24h('zzz_unknown_focus_v1');
      ProgressService.debugNowOverride = () =>
          now.add(const Duration(hours: 25));

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'learning stats precedence still wins when focus-review-due is active',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final now = DateTime.utc(2026, 1, 4, 12);
      ProgressService.debugNowOverride = () => now;
      await ProgressService.setLessonFocusLabel('range');
      await ProgressService.scheduleFocusReviewIn24h('range');
      await LearningStatsV1Service.instance
          .incrementToCallLegalityMismatchError();
      ProgressService.debugNowOverride = () =>
          now.add(const Duration(hours: 25));

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'absent lesson focus falls through to next deterministic fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.clearLessonFocusLabel();

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'stale focus review falls through to next deterministic fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      final now = DateTime.utc(2026, 1, 5, 12);
      ProgressService.debugNowOverride = () => now;
      await ProgressService.setLessonFocusLabel('range');
      await ProgressService.scheduleFocusReviewIn24h('range');
      ProgressService.debugNowOverride = () =>
          now.add(const Duration(hours: 1));

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'debugNow override does not leak across routing checks for focus-review-due',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();

      final t0 = DateTime.utc(2099, 1, 1, 0);
      ProgressService.debugNowOverride = () => t0;
      await ProgressService.setLessonFocusLabel('range');
      await ProgressService.scheduleFocusReviewIn24h('range');
      ProgressService.debugNowOverride = () =>
          t0.add(const Duration(hours: 25));
      final duePack = await ProgressService.getNextSpinePackToRunV1();
      expect(duePack, 'world1_spine_followup_v1_b2');

      ProgressService.debugNowOverride = null;
      final noLeakPack = await ProgressService.getNextSpinePackToRunV1();
      expect(noLeakPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'world-mastery fallback is used when higher-priority signals do not resolve',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.gold,
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'higher-priority skill-tags fallback still wins over world-mastery fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['pot_odds'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.gold,
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');
    },
  );

  test(
    'neutral world-mastery mapping preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );

  test(
    'intake-profile fallback is used when higher-priority signals do not resolve',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'focusLabel': 'pot_odds',
        'placementScore': 3,
        'skillBand': 'advanced',
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b0');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'higher-priority world-mastery fallback still wins over intake-profile fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.gold,
      );
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'focusLabel': 'pot_odds',
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');
    },
  );

  test(
    'invalid intake-profile mapping preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'focusLabel': 'zzz_unknown_focus_v1',
        'placementScore': 2,
        'skillBand': 'intermediate',
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );

  test(
    'string placement-score intake value is normalized for deterministic fallback routing',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'focusLabel': 'zzz_unknown_focus_v1',
        'placementScore': '3',
        'skillBand': 'intermediate',
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, 'world1_spine_followup_v1_b2');

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, nextPack);
    },
  );

  test(
    'non-integral numeric placement-score intake value preserves prior fallback behavior',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'focusLabel': 'zzz_unknown_focus_v1',
        'placementScore': 2.5,
        'skillBand': 'intermediate',
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );

  test(
    'malformed intake-profile payload falls through to prior deterministic fallback',
    () async {
      await _seedWorld1FollowupRoutingV1();
      await _resetLearningStatsMismatchCountersV1();
      await ProgressService.setPlacementScoreV1(2);
      await ProgressService.setSkillBandV1('intermediate');
      await ProgressService.setSkillTagsForPackV1(
        'world1_spine_followup_v1_b0',
        const <String>['zzz_unknown_skill_tag_v1'],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_followup_v1_b0',
        WorldMasteryLevelV1.silver,
      );
      final baseline = await ProgressService.getNextSpinePackToRunV1();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('intake_profile_v1', '{"version":"v1"');

      final nextPack = await ProgressService.getNextSpinePackToRunV1();
      expect(nextPack, baseline);

      final repeated = await ProgressService.getNextSpinePackToRunV1();
      expect(repeated, baseline);
    },
  );
}

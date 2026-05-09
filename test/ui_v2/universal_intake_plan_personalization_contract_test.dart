import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/learning_continuation_v1.dart';
import 'package:poker_analyzer/personalization/mastery_progress_contract_v1.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_signal_store_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await RecentActivitySignalStoreV1.instance.clearForTesting();
    await ProgressionQualityGateV1.clearForTesting();
    await WeaknessConfidenceLayerV1.clearForTesting();
  });

  testWidgets(
    'today plan applies the same persistent weakness confidence state as session result',
    (tester) async {
      const seededSignals = <RecentTelemetrySignalV1>[
        RecentTelemetrySignalV1(
          name: 'user_choice',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 0,
            'choice': 'bb',
          },
        ),
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 0,
            'correct': false,
            'error_type': 'incorrect_seat',
          },
        ),
        RecentTelemetrySignalV1(
          name: 'user_choice',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 1,
            'choice': 'hj',
          },
        ),
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 1,
            'correct': false,
            'error_type': 'incorrect_seat',
          },
        ),
      ];
      await ProgressionQualityGateV1.saveLatestSessionSnapshot(
        const LatestSessionOutcomeSnapshotV1(
          moduleId: 'world1_spine_campaign_v1',
          correctCount: 2,
          totalCount: 3,
          isCampaignSession: true,
          errorType: 'incorrect_seat',
        ),
      );
      await WeaknessConfidenceLayerV1.saveHistory(
        const <WeaknessConfidenceHistoryEntryV1>[
          WeaknessConfidenceHistoryEntryV1(
            focusId: 'action_order',
            nextAction: PersonalizedNextActionV1.reviewFocus,
            moduleId: 'world1_spine_campaign_v1',
            hadMistake: true,
            recordedAtMs: 1,
          ),
        ],
      );
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'completedAt': DateTime.now().toUtc().toIso8601String(),
        'steps': 7,
        'wrongAttempts': 0,
        'errorClass': 'none',
        'focusLabel': 'baseline',
        'skillBand': 'beginner',
        'placementScore': 0,
      });
      await ProgressService.setLessonFocusLabel('baseline');
      await ProgressService.setSkillBandV1('beginner');
      await ProgressService.setPlacementScoreV1(0);
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_campaign_v1',
        WorldMasteryLevelV1.bronze,
      );
      await RecentActivitySignalStoreV1.instance.appendSignals(seededSignals);

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Readiness: Rebuild first. This weakness is still showing up across recent sessions.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Recovery state: Rebuild · Bronze mastery still needs another clean rep',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'today plan applies the same progression-quality fit as session result',
    (tester) async {
      const seededSignals = <RecentTelemetrySignalV1>[
        RecentTelemetrySignalV1(
          name: 'user_choice',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 0,
            'choice': 'bb',
          },
        ),
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 0,
            'correct': false,
            'error_type': 'incorrect_seat',
          },
        ),
        RecentTelemetrySignalV1(
          name: 'user_choice',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 1,
            'choice': 'hj',
          },
        ),
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'surface': 'universal_intake_plan',
            'step_index': 1,
            'correct': false,
            'error_type': 'incorrect_seat',
          },
        ),
      ];
      final expectedRecommendation = RecentActivityPersonalizationV1.infer(
        const RecentActivityPersonalizationInputV1(
          signals: seededSignals,
          isCampaignSession: false,
        ),
      );
      expect(expectedRecommendation, isNotNull);
      await ProgressionQualityGateV1.saveLatestSessionSnapshot(
        const LatestSessionOutcomeSnapshotV1(
          moduleId: 'world1_spine_campaign_v1',
          correctCount: 2,
          totalCount: 3,
          isCampaignSession: true,
          errorType: 'incorrect_line',
        ),
      );
      final gatedRecommendation = ProgressionQualityGateV1.apply(
        recommendation: expectedRecommendation,
        latestSession: const LatestSessionOutcomeSnapshotV1(
          moduleId: 'world1_spine_campaign_v1',
          correctCount: 2,
          totalCount: 3,
          isCampaignSession: true,
          errorType: 'incorrect_line',
        ),
        recentSignals: seededSignals,
      );
      final expectedContinuation =
          LearningContinuationFactoryV1.fromPersonalizedRecommendation(
            recommendation: gatedRecommendation,
            resolveModuleTitle: recommendedModuleTitleForId,
            recentSignals: seededSignals,
          );
      final expectedMastery = MasteryProgressContractFactoryV1.derive(
        latestSession: const LatestSessionOutcomeSnapshotV1(
          moduleId: 'world1_spine_campaign_v1',
          correctCount: 2,
          totalCount: 3,
          isCampaignSession: true,
          errorType: 'incorrect_line',
        ),
        recommendation: gatedRecommendation,
        worldMasteryLevel: WorldMasteryLevelV1.bronze,
        campaignRankLabel: 'Fish',
      );
      expect(expectedContinuation, isNotNull);
      expect(expectedContinuation!.targetEntryId, actionOrderBtnLastModuleId);
      expect(expectedMastery, isNotNull);

      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'completedAt': DateTime.now().toUtc().toIso8601String(),
        'steps': 7,
        'wrongAttempts': 0,
        'errorClass': 'none',
        'focusLabel': 'baseline',
        'skillBand': 'beginner',
        'placementScore': 0,
      });
      await ProgressService.setLessonFocusLabel('baseline');
      await ProgressService.setSkillBandV1('beginner');
      await ProgressService.setPlacementScoreV1(0);
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_campaign_v1',
        WorldMasteryLevelV1.bronze,
      );
      await RecentActivitySignalStoreV1.instance.appendSignals(seededSignals);

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('today_plan_recent_activity_card_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_recent_activity_target_v1')),
        findsOneWidget,
      );
      expect(find.text('Review target'), findsOneWidget);
      expect(find.text(expectedContinuation.targetLabel), findsOneWidget);
      expect(find.text(expectedMastery!.fitLine), findsOneWidget);
      expect(find.text(expectedMastery.deltaSignal), findsOneWidget);
      expect(
        find.byKey(const Key('today_plan_recent_activity_cta_v1')),
        findsOneWidget,
      );
      expect(find.text(expectedContinuation.ctaLabel), findsOneWidget);
    },
  );
}

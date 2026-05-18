import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/personalization/learning_continuation_v1.dart';
import 'package:poker_analyzer/personalization/mastery_progress_contract_v1.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_signal_store_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_bootstrap_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder sessionResultPrimaryActionFinder() {
    final next = find.byKey(const Key('session_result_next_module_cta'));
    if (next.evaluate().isNotEmpty) {
      return next;
    }
    final review = find.byKey(const Key('session_result_review_missed_cta'));
    if (review.evaluate().isNotEmpty) {
      return review;
    }
    return find.byKey(const Key('session_result_primary_cta_v1'));
  }

  Future<void> pumpUntilAny(
    WidgetTester tester,
    List<Finder> finders, {
    int maxTicks = 180,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      for (final finder in finders) {
        if (finder.evaluate().isNotEmpty) {
          return;
        }
      }
      await tester.pump(step);
    }
  }

  Future<void> pumpUntilTrackChoiceRoutesToRunner(
    WidgetTester tester, {
    int maxTicks = 240,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      if (find.byType(SessionDrillPlayerV1Screen).evaluate().isNotEmpty &&
          find.text('Choose your next track').evaluate().isEmpty) {
        return;
      }
      await tester.pump(step);
    }
  }

  String nextTrackSessionIdV1(String sessionId) {
    final match = RegExp(
      r'^(cash|tournament|mixed)\.s(\d{2})$',
    ).firstMatch(sessionId.trim().toLowerCase());
    if (match == null) {
      throw FormatException('invalid track session id: $sessionId');
    }
    final track = match.group(1)!;
    final index = int.parse(match.group(2)!);
    return '$track.s${(index + 1).toString().padLeft(2, '0')}';
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('session result route preserves entry payload', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  sessionResultRouteV1<void>(
                    correctCount: 5,
                    totalCount: 7,
                    moduleId: 'world1_spine_campaign_v1',
                    campaignSessionDelta: 12,
                    campaignPersonalizationHint: 'Keep pressing edges.',
                    personalizationResultV1: const PersonalizedRecommendationV1(
                      recommendedFocusId: 'initiative',
                      reasonCode: 'slow_action_decisions',
                      shortHintText:
                          'Pause on the initiative cue before you lock in an action.',
                      recommendedNextAction:
                          PersonalizedNextActionV1.reviewFocus,
                      recommendedNextSessionTarget:
                          'core_positions_and_initiative',
                    ),
                  ),
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final screen = tester.widget<SessionResultScreen>(
      find.byType(SessionResultScreen),
    );
    expect(screen.correctCount, 5);
    expect(screen.totalCount, 7);
    expect(screen.moduleId, 'world1_spine_campaign_v1');
    expect(screen.campaignSessionDelta, 12);
    expect(screen.campaignPersonalizationHint, 'Keep pressing edges.');
    expect(screen.personalizationResultV1?.recommendedFocusId, 'initiative');
  });

  testWidgets(
    'session result applies persistent weakness confidence to the next step',
    (tester) async {
      await RecentActivitySignalStoreV1.instance.appendSignals(
        const <RecentTelemetrySignalV1>[
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'correct': false,
              'error_type': 'incorrect_seat',
            },
          ),
        ],
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

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'world1_spine_campaign_v1',
            campaignOutcomeSummary: OutcomeSummaryV1(
              packId: 'world1_spine_campaign_v1',
              worldId: 1,
              beatIndex: 0,
              outcomeKind: OutcomeKindV1.mistake,
              errorType: 'incorrect_seat',
              lines: <String>['Outcome: seat-order miss'],
            ),
            personalizationResultV1: PersonalizedRecommendationV1(
              recommendedFocusId: 'action_order',
              reasonCode: 'continue_campaign',
              shortHintText: 'Keep going.',
              recommendedNextAction: PersonalizedNextActionV1.continueCampaign,
              recommendedNextSessionTarget: 'w2.s03',
            ),
          ),
        ),
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
    'session result applies progression-quality fit to the personalized next step',
    (tester) async {
      const personalizationResult = PersonalizedRecommendationV1(
        recommendedFocusId: 'initiative',
        reasonCode: 'continue_campaign',
        shortHintText: 'Keep going.',
        recommendedNextAction: PersonalizedNextActionV1.continueCampaign,
        recommendedNextSessionTarget: 'world2_spine_campaign_v1',
      );
      await RecentActivitySignalStoreV1.instance.appendSignals(
        const <RecentTelemetrySignalV1>[
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{'correct': false},
          ),
        ],
      );
      await ProgressService.setWorldMasteryForPackV1(
        'world1_spine_campaign_v1',
        WorldMasteryLevelV1.bronze,
      );
      final expectedMastery = MasteryProgressContractFactoryV1.derive(
        latestSession: const LatestSessionOutcomeSnapshotV1(
          moduleId: 'world1_spine_campaign_v1',
          correctCount: 2,
          totalCount: 3,
          isCampaignSession: true,
          outcomeKind: OutcomeKindV1.mistake,
          errorType: 'incorrect_line',
        ),
        recommendation: const PersonalizedRecommendationV1(
          recommendedFocusId: 'initiative',
          reasonCode: 'progression_repeat_fit',
          shortHintText:
              'This last session was still shaky for the current level. Fix this spot once more before moving on.',
          recommendedNextAction: PersonalizedNextActionV1.repeatPack,
          recommendedNextSessionTarget: 'world1_spine_campaign_v1',
        ),
        worldMasteryLevel: WorldMasteryLevelV1.bronze,
        campaignRankLabel: 'Fish',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'world1_spine_campaign_v1',
            campaignOutcomeSummary: OutcomeSummaryV1(
              packId: 'world1_spine_campaign_v1',
              worldId: 1,
              beatIndex: 0,
              outcomeKind: OutcomeKindV1.mistake,
              errorType: 'incorrect_line',
              lines: <String>['Outcome: mistake punished'],
            ),
            personalizationResultV1: personalizationResult,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent focus: World 1'), findsNothing);
      expect(find.text(expectedMastery!.fitLine), findsOneWidget);
      final deltaText = tester.widget<Text>(
        find.byKey(const Key('session_result_continuation_line_v1')),
      );
      expect(deltaText.data, contains('Progress delta:'));
      expect(deltaText.data, contains('Bronze mastery'));
      expect(find.text('REPEAT PACK'), findsOneWidget);
    },
  );

  testWidgets(
    'session result resolves review recommendations through the shared weak-pattern review contract',
    (tester) async {
      const personalizationResult = PersonalizedRecommendationV1(
        recommendedFocusId: 'board_texture',
        reasonCode: 'progression_review_fit',
        shortHintText:
            'Recent misses are still clustering around the same weakness. Review the weak pattern before adding a harder step.',
        recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: 'w2.s01',
      );
      const seededSignals = <RecentTelemetrySignalV1>[
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'correct': false,
            'error_type': 'board_slot_confusion',
          },
        ),
      ];
      await RecentActivitySignalStoreV1.instance.appendSignals(seededSignals);
      final expectedContinuation =
          LearningContinuationFactoryV1.fromPersonalizedRecommendation(
            recommendation: personalizationResult,
            resolveModuleTitle: recommendedModuleTitleForId,
            recentSignals: seededSignals,
          );

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 1,
            totalCount: 3,
            moduleId: 'world2_spine_campaign_v1',
            campaignOutcomeSummary: OutcomeSummaryV1(
              packId: 'world2_spine_campaign_v1',
              worldId: 2,
              beatIndex: 0,
              outcomeKind: OutcomeKindV1.mistake,
              errorType: 'board_slot_confusion',
              lines: <String>['Outcome: board texture miss'],
            ),
            personalizationResultV1: personalizationResult,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(expectedContinuation, isNotNull);
      expect(expectedContinuation!.targetEntryId, 'w2.s04');
      expect(find.text(expectedContinuation.headline), findsOneWidget);
      expect(find.text(expectedContinuation.reasonLine), findsOneWidget);
      expect(find.text(expectedContinuation.ctaLabel), findsOneWidget);
    },
  );

  testWidgets('session result builds on narrow and wide layouts', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<void> pumpWithSize(Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 7,
            totalCount: 10,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_back_to_map_cta')),
        findsOneWidget,
      );
      expect(sessionResultPrimaryActionFinder(), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_action_stack_v1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    await pumpWithSize(const Size(390, 844));
    await pumpWithSize(const Size(1366, 900));
  });

  testWidgets('session result remains stable at textScale 1.15', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.15)),
          child: SessionResultScreen(
            correctCount: 4,
            totalCount: 5,
            moduleId: 'world2_spine_campaign_v1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(
      find.byKey(const Key('session_result_status_header_v1')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('session_result_close_x_cta')), findsOneWidget);
    expect(sessionResultPrimaryActionFinder(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('session result spartan surface remains tokenized', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 4,
          totalCount: 5,
          moduleId: 'intro_welcome',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rewardsSurface = tester.widget<Container>(
      find.byKey(const Key('session_result_spartan_surface_v1')),
    );
    final decoration = rewardsSurface.decoration as BoxDecoration?;
    expect(decoration, isNotNull);
    expect(decoration!.color, isNotNull);
    expect(decoration.border, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'session result shows status and optional why in main reading path',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_status_header_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_continuation_surface_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_action_stack_v1')),
        findsOneWidget,
      );
      expect(sessionResultPrimaryActionFinder(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('session result back to map CTA returns to root map route', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  const Text('MAP_ROOT', key: Key('map_root')),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SessionResultScreen(
                            correctCount: 3,
                            totalCount: 5,
                            moduleId: 'world1_spine_campaign_v1',
                          ),
                        ),
                      );
                    },
                    child: const Text('OPEN'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('session_result_close_x_cta')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('session_result_leave_confirm_dialog')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('session_result_leave_confirm_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('map_root')), findsOneWidget);
    expect(find.byType(SessionResultScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'completed spine result launched from intake returns to intake shell before progress map',
    (tester) async {
      addTearDown(() {
        ProgressService.intakeFlowActiveInSession = false;
      });
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
      });
      ProgressService.intakeFlowActiveInSession = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    const Text('MAP_ROOT', key: Key('map_root')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SessionResultScreen(
                              correctCount: 5,
                              totalCount: 5,
                              moduleId: 'world1_spine_campaign_v1',
                            ),
                          ),
                        );
                      },
                      child: const Text('OPEN'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('session_result_close_x_cta')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_leave_confirm_dialog')),
        findsOneWidget,
      );
      expect(find.text('You will return to the intake plan.'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('session_result_leave_confirm_cta')),
      );
      await tester.pumpAndSettle();
      await pumpUntilAny(tester, <Finder>[
        find.byType(UniversalIntakePlanScreen),
      ]);

      expect(find.byType(UniversalIntakePlanScreen), findsOneWidget);
      expect(find.byKey(const Key('map_root')), findsNothing);
      expect(ProgressService.intakeFlowActiveInSession, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'focus label is persisted on mistake and affects moved details next action',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final valueFinder = find.byKey(const Key('session_result_why_line_v1'));
      expect(valueFinder, findsOneWidget);
      final valueText = tester.widget<Text>(valueFinder).data ?? '';
      expect(valueText.toLowerCase(), contains('focus'));
      expect(await ProgressService.getLessonFocusLabel(), 'range');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'focus_label_applied telemetry is emitted on mistaken session result',
    (tester) async {
      final logged = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        logged.add(<String, dynamic>{'name': name, 'payload': payload ?? {}});
      });
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 1,
            totalCount: 2,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final events = logged
          .where((event) => event['name'] == TelemetryEvents.focusLabelApplied)
          .toList();
      expect(events, isNotEmpty);
      final payload = events.first['payload'] as Map<String, dynamic>;
      expect(payload['focus_label'], 'range');
      expect(payload['source'], 'session_result');
    },
  );

  testWidgets(
    'track choice v1 is one-time, persists cash selection, and routes deterministically',
    (tester) async {
      final completedPacks = <String>[
        'world1_act0_table_literacy',
        'world1_act0_action_literacy',
        'world1_act0_street_flow',
      ];
      for (var world = 1; world <= 9; world++) {
        for (var band = 0; band <= 2; band++) {
          completedPacks.add('world${world}_spine_followup_v1_b$band');
        }
      }
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': completedPacks.join(','),
        'spine_calibration_completed_v1': true,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': true,
        'world8_calibration_completed_v1': true,
        'world9_calibration_completed_v1': true,
        'world10_calibration_completed_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 12,
            totalCount: 12,
            moduleId: 'world10_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder primaryCtaFinder() {
        return sessionResultPrimaryActionFinder();
      }

      await tester.tap(primaryCtaFinder());
      await tester.pumpAndSettle();
      expect(find.text('Choose your next track'), findsOneWidget);
      expect(
        find.textContaining('Your shared core is complete'),
        findsOneWidget,
      );
      expect(
        find.textContaining('later decisions change with context'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'These tracks are policy forks, not cosmetic labels',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('deeper stacks'), findsOneWidget);
      expect(
        find.textContaining('rake-driven value tradeoffs'),
        findsOneWidget,
      );
      expect(
        find.textContaining('blinds, antes, stack depth, and ICM'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('world10_track_choice_recommendation_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Recommended next track: Tournament'),
        findsOneWidget,
      );
      expect(find.textContaining('Mastery 0%'), findsOneWidget);
      expect(find.text('Cash (Recommended)'), findsNothing);
      expect(find.text('Tournament (Recommended)'), findsOneWidget);
      expect(find.text('You can still choose any track.'), findsOneWidget);

      await tester.tap(find.text('Cash'));
      await pumpUntilTrackChoiceRoutesToRunner(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('world10_track_choice_seen_v1'), isTrue);
      expect(prefs.getString('world10_track_choice_v1'), 'cash');

      final runner = tester.widget<SessionDrillPlayerV1Screen>(
        find.byType(SessionDrillPlayerV1Screen),
      );
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      expect(runner.sessionId, 'cash.s01');
      final sessionPath = const DrillRuntimeAdapterV1().debugSessionPathForIdV1(
        runner.sessionId,
      );
      expect(
        sessionPath,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01',
      );
      expect(sessionPath.contains('/tracks/cash/sessions/cash.s01'), isTrue);
      expect(find.byType(SessionDrillPlayerV1Screen), findsOneWidget);
    },
  );

  testWidgets(
    'track choice v1 seen flag skips chooser and routes directly to tournament root',
    (tester) async {
      final completedPacks = <String>[
        'world1_act0_table_literacy',
        'world1_act0_action_literacy',
        'world1_act0_street_flow',
      ];
      for (var world = 1; world <= 9; world++) {
        for (var band = 0; band <= 2; band++) {
          completedPacks.add('world${world}_spine_followup_v1_b$band');
        }
      }
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': completedPacks.join(','),
        'spine_calibration_completed_v1': true,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': true,
        'world8_calibration_completed_v1': true,
        'world9_calibration_completed_v1': true,
        'world10_calibration_completed_v1': true,
        'world10_track_choice_seen_v1': true,
        'world10_track_choice_v1': 'tournament',
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 12,
            totalCount: 12,
            moduleId: 'world10_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(sessionResultPrimaryActionFinder());
      await pumpUntilAny(tester, <Finder>[
        find.byType(SessionDrillPlayerV1Screen),
      ], maxTicks: 240);

      expect(find.text('Choose your next track'), findsNothing);
      final runner = tester.widget<SessionDrillPlayerV1Screen>(
        find.byType(SessionDrillPlayerV1Screen),
      );
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      expect(runner.sessionId, 'tournament.s01');
      final sessionPath = const DrillRuntimeAdapterV1().debugSessionPathForIdV1(
        runner.sessionId,
      );
      expect(
        sessionPath,
        'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s01',
      );
      expect(
        sessionPath.contains('/tracks/tournament/sessions/tournament.s01'),
        isTrue,
      );
    },
  );

  testWidgets('track choice v1 dismiss defaults to mixed and routes to b2', (
    tester,
  ) async {
    final completedPacks = <String>[
      'world1_act0_table_literacy',
      'world1_act0_action_literacy',
      'world1_act0_street_flow',
    ];
    for (var world = 1; world <= 9; world++) {
      for (var band = 0; band <= 2; band++) {
        completedPacks.add('world${world}_spine_followup_v1_b$band');
      }
    }
    SharedPreferences.setMockInitialValues(<String, Object>{
      'chips_balance_v1': 20,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1': completedPacks.join(','),
      'spine_calibration_completed_v1': true,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': true,
      'world8_calibration_completed_v1': true,
      'world9_calibration_completed_v1': true,
      'world10_calibration_completed_v1': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 12,
          totalCount: 12,
          moduleId: 'world10_spine_campaign_v1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(sessionResultPrimaryActionFinder());
    await tester.pumpAndSettle();
    expect(find.text('Choose your next track'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await pumpUntilAny(tester, <Finder>[
      find.byType(SessionDrillPlayerV1Screen),
    ], maxTicks: 240);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('world10_track_choice_seen_v1'), isTrue);
    expect(prefs.getString('world10_track_choice_v1'), 'mixed');

    final runner = tester.widget<SessionDrillPlayerV1Screen>(
      find.byType(SessionDrillPlayerV1Screen),
    );
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
    expect(runner.sessionId, 'mixed.s01');
  });

  testWidgets(
    'r17 checkpoint pending routes to checkpoint pack and clears after checkpoint completion',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
      });

      await tester.runAsync(() async {
        await ProgressService.recordSessionForCheckpointV1(
          sessionId: 'w2.s01',
          worldId: 'world2',
          errorClasses: const <String>['range', 'timing'],
        );
        await ProgressService.recordSessionForCheckpointV1(
          sessionId: 'w2.s02',
          worldId: 'world2',
          errorClasses: const <String>['range', 'sizing'],
        );
        await ProgressService.recordSessionForCheckpointV1(
          sessionId: 'w2.s03',
          worldId: 'world2',
          errorClasses: const <String>['timing'],
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            key: ValueKey<String>('checkpoint-seed-result'),
            correctCount: 5,
            totalCount: 5,
            moduleId: 'world2_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Why: Review required.'), findsOneWidget);

      await tester.tap(sessionResultPrimaryActionFinder());
      await tester.pumpAndSettle();

      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.moduleId, ProgressService.checkpointPackIdV1);

      final seeded = await tester.runAsync(
        () => ProgressService.getCheckpointSeedForPackV1(
          ProgressService.checkpointPackIdV1,
        ),
      );
      expect(seeded, <String>['range', 'timing', 'sizing']);

      await tester.pumpWidget(
        const MaterialApp(
          key: ValueKey<String>('checkpoint-result-app'),
          home: SessionResultScreen(
            key: ValueKey<String>('checkpoint-result'),
            correctCount: 6,
            totalCount: 6,
            moduleId: ProgressService.checkpointPackIdV1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final stateAfterCheckpoint = await tester.runAsync(
        ProgressService.getCheckpointProgressStateV1,
      );
      expect(stateAfterCheckpoint!.checkpointPending, isFalse);

      final nextPackAfterCheckpoint = await tester.runAsync(
        () => ProgressService.getNextPackConsideringCheckpointV1(
          ProgressService.checkpointPackIdV1,
        ),
      );
      expect(
        nextPackAfterCheckpoint,
        isNot(ProgressService.checkpointPackIdV1),
      );
    },
  );

  testWidgets('r17 checkpoint runner consumes seed top-3 deterministically', (
    tester,
  ) async {
    const seedTopErrors = <String>['timing', 'range', 'sizing'];
    await tester.runAsync(
      () => ProgressService.setCheckpointSeedForPackV1(
        ProgressService.checkpointPackIdV1,
        seedTopErrors,
      ),
    );
    final seededOrder = buildCheckpointSeededDrillsV1(
      steps: world1MicroTaskPackFor(ProgressService.checkpointPackIdV1),
      seed: const CheckpointSeedV1(topErrorClasses: seedTopErrors),
      targetCount: 6,
    );
    expect(seededOrder.length, 6);
    expect(seededOrder[0].errorClass, 'timing');
    expect(seededOrder[1].errorClass, 'range');
    expect(seededOrder[2].errorClass, 'sizing');

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: ProgressService.checkpointPackIdV1,
          moduleTitle: 'Checkpoint',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('Practice your toughest spots again.'), findsWidgets);
  });

  testWidgets(
    'r19 p0.2 checkpoint selection is idempotent for identical seed input',
    (tester) async {
      const seedTopErrors = <String>['timing', 'range', 'sizing'];
      final steps = world1MicroTaskPackFor(ProgressService.checkpointPackIdV1);

      final firstRun = buildCheckpointSeededDrillsV1(
        steps: steps,
        seed: const CheckpointSeedV1(topErrorClasses: seedTopErrors),
        targetCount: 6,
      );
      final secondRun = buildCheckpointSeededDrillsV1(
        steps: steps,
        seed: const CheckpointSeedV1(topErrorClasses: seedTopErrors),
        targetCount: 6,
      );

      expect(firstRun.length, 6);
      expect(secondRun.length, 6);
      expect(
        firstRun.map((entry) => entry.drillId).toList(growable: false),
        secondRun.map((entry) => entry.drillId).toList(growable: false),
      );
      expect(
        firstRun.map((entry) => entry.errorClass).toList(growable: false),
        secondRun.map((entry) => entry.errorClass).toList(growable: false),
      );
    },
  );

  testWidgets(
    'r19 p0.2 checkpoint empty or unknown seed falls back deterministically',
    (tester) async {
      final steps = world1MicroTaskPackFor(ProgressService.checkpointPackIdV1);

      final emptySeedRunA = buildCheckpointSeededDrillsV1(
        steps: steps,
        seed: const CheckpointSeedV1(topErrorClasses: <String>[]),
        targetCount: 6,
      );
      final emptySeedRunB = buildCheckpointSeededDrillsV1(
        steps: steps,
        seed: const CheckpointSeedV1(topErrorClasses: <String>[]),
        targetCount: 6,
      );
      final unknownSeedRun = buildCheckpointSeededDrillsV1(
        steps: steps,
        seed: const CheckpointSeedV1(
          topErrorClasses: <String>['unknown_class', 'none', ''],
        ),
        targetCount: 6,
      );

      expect(emptySeedRunA.length, 6);
      expect(emptySeedRunB.length, 6);
      expect(unknownSeedRun.length, 6);

      final emptyIdsA = emptySeedRunA
          .map((entry) => entry.drillId)
          .toList(growable: false);
      final emptyIdsB = emptySeedRunB
          .map((entry) => entry.drillId)
          .toList(growable: false);
      final unknownIds = unknownSeedRun
          .map((entry) => entry.drillId)
          .toList(growable: false);

      expect(emptyIdsA, emptyIdsB);
      expect(unknownIds, emptyIdsA);
      expect(emptyIdsA, <String>[
        'checkpoint_01',
        'checkpoint_02',
        'checkpoint_03',
        'checkpoint_04',
        'checkpoint_05',
        'checkpoint_06',
      ]);
    },
  );

  testWidgets(
    'r8 track sessions chain deterministically from s01 to s03 for all tracks',
    (tester) async {
      final adapter = const DrillRuntimeAdapterV1();
      final trackToPack = <String, String>{
        'cash': 'world10_spine_followup_v1_b0',
        'tournament': 'world10_spine_followup_v1_b1',
        'mixed': 'world10_spine_followup_v1_b2',
      };

      for (final entry in trackToPack.entries) {
        final track = entry.key;
        final packId = entry.value;
        final session01 = '$track.s01';
        final session02 = nextTrackSessionIdV1(session01);
        final session03 = nextTrackSessionIdV1(session02);

        expect(session02, '$track.s02');
        expect(session03, '$track.s03');

        final packRootPath = adapter.debugSessionPathForIdV1(packId);
        expect(
          packRootPath.contains('/tracks/$track/sessions/$track.s01'),
          isTrue,
        );
        final path02 = adapter.debugSessionPathForIdV1(session02);
        final path03 = adapter.debugSessionPathForIdV1(session03);
        expect(path02.contains('/tracks/$track/sessions/$track.s02'), isTrue);
        expect(path03.contains('/tracks/$track/sessions/$track.s03'), isTrue);

        final sessionFile01 = File('$packRootPath/session.md');
        final sessionFile02 = File('$path02/session.md');
        final sessionFile03 = File('$path03/session.md');
        expect(sessionFile01.existsSync(), isTrue);
        expect(sessionFile02.existsSync(), isTrue);
        expect(sessionFile03.existsSync(), isTrue);
      }
    },
  );

  testWidgets(
    'r9 p0.1 e2e no-dead-end: world10 result -> track route -> s01..s03 chain -> result return path',
    (tester) async {
      final completedPacks = <String>[
        'world1_act0_table_literacy',
        'world1_act0_action_literacy',
        'world1_act0_street_flow',
      ];
      for (var world = 1; world <= 9; world++) {
        for (var band = 0; band <= 2; band++) {
          completedPacks.add('world${world}_spine_followup_v1_b$band');
        }
      }
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': completedPacks.join(','),
        'spine_calibration_completed_v1': true,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': true,
        'world8_calibration_completed_v1': true,
        'world9_calibration_completed_v1': true,
        'world10_calibration_completed_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 12,
            totalCount: 12,
            moduleId: 'world10_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('session_result_next_module_cta')));
      await tester.pumpAndSettle();
      expect(find.text('Choose your next track'), findsOneWidget);

      await tester.tap(find.text('Cash'));
      await pumpUntilTrackChoiceRoutesToRunner(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('world10_track_choice_seen_v1'), isTrue);
      expect(prefs.getString('world10_track_choice_v1'), 'cash');

      final runner = tester.widget<SessionDrillPlayerV1Screen>(
        find.byType(SessionDrillPlayerV1Screen),
      );
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      expect(runner.sessionId, 'cash.s01');

      final adapter = const DrillRuntimeAdapterV1();
      const session01 = 'cash.s01';
      final session02 = nextTrackSessionIdV1(session01);
      final session03 = nextTrackSessionIdV1(session02);

      expect(
        adapter.debugSessionPathForIdV1(session01),
        contains('/tracks/cash/sessions/cash.s01'),
      );
      expect(
        adapter.debugSessionPathForIdV1(session02),
        contains('/tracks/cash/sessions/cash.s02'),
      );
      expect(
        adapter.debugSessionPathForIdV1(session03),
        contains('/tracks/cash/sessions/cash.s03'),
      );

      final drillPresence = await tester.runAsync(() async {
        final has01 = await adapter.hasSessionDrills(session01);
        final has02 = await adapter.hasSessionDrills(session02);
        final has03 = await adapter.hasSessionDrills(session03);
        return <bool>[has01, has02, has03];
      });
      expect(drillPresence, isNotNull);
      expect(drillPresence![0], isTrue);
      expect(drillPresence[1], isTrue);
      expect(drillPresence[2], isTrue);
    },
  );

  testWidgets(
    'r9 p0.5: after cash s03 result, back-to-map return path is deterministic',
    (tester) async {
      final completedPacks = <String>[
        'world1_act0_table_literacy',
        'world1_act0_action_literacy',
        'world1_act0_street_flow',
      ];
      for (var world = 1; world <= 9; world++) {
        for (var band = 0; band <= 2; band++) {
          completedPacks.add('world${world}_spine_followup_v1_b$band');
        }
      }
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': completedPacks.join(','),
        'spine_calibration_completed_v1': true,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': true,
        'world8_calibration_completed_v1': true,
        'world9_calibration_completed_v1': true,
        'world10_calibration_completed_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 12,
            totalCount: 12,
            moduleId: 'world10_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('session_result_next_module_cta')));
      await tester.pumpAndSettle();
      expect(find.text('Choose your next track'), findsOneWidget);

      await tester.tap(find.text('Cash'));
      await pumpUntilTrackChoiceRoutesToRunner(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('world10_track_choice_seen_v1'), isTrue);
      expect(prefs.getString('world10_track_choice_v1'), 'cash');

      expect(find.byType(SessionDrillPlayerV1Screen), findsOneWidget);
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      expect(find.text('Choose your next track'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    const Text('MAP_ROOT', key: Key('map_root')),
                    ElevatedButton(
                      key: const Key('open_cash_s03_result_cta'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SessionResultScreen(
                              correctCount: 8,
                              totalCount: 8,
                              moduleId: 'cash.s03',
                            ),
                          ),
                        );
                      },
                      child: const Text('OPEN'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('open_cash_s03_result_cta')), findsOneWidget);
      await tester.tap(find.byKey(const Key('open_cash_s03_result_cta')));
      await tester.pumpAndSettle();

      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_back_to_map_cta')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('session_result_back_to_map_cta')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map_root')), findsOneWidget);
      expect(find.byType(SessionResultScreen), findsNothing);
      expect(find.text('Choose your next track'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'campaign result can reuse shared recent top mistake for review recommendation',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await RecentActivitySignalStoreV1.instance.clearForTesting();
      await RecentActivitySignalStoreV1.instance.appendSignals(
        const <RecentTelemetrySignalV1>[
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'surface': 'universal_intake_plan',
              'correct': false,
              'error_type': 'incorrect_seat',
            },
          ),
          RecentTelemetrySignalV1(
            name: 'correct',
            payload: <String, Object?>{
              'module_id': 'world1_spine_campaign_v1',
              'mode': 'campaign_spine',
              'correct': false,
              'error_type': 'seat_role_confusion',
            },
          ),
        ],
      );
      addTearDown(() async {
        await RecentActivitySignalStoreV1.instance.clearForTesting();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 4,
            totalCount: 4,
            moduleId: 'world2_spine_campaign_v1',
            campaignSessionDelta: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final whyFinder = find.byKey(const Key('session_result_why_line_v1'));
      expect(whyFinder, findsOneWidget);
      final whyText = (tester.widget<Text>(whyFinder).data ?? '').trim();
      expect(whyText, 'Back to map: Top leak: Positions and Initiati');
    },
  );

  testWidgets(
    'campaign result emits top-leak recommendation impression once and selected on primary CTA',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'learning_stats_v1_timing_errors': 3,
        'learning_stats_v1_total_decisions': 3,
        'learning_stats_v1_correct_decisions': 1,
      });

      final logged = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        logged.add(<String, dynamic>{'name': name, 'payload': payload ?? {}});
      });
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 3,
            totalCount: 3,
            moduleId: 'world2_spine_campaign_v1',
            campaignSessionDelta: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('session_result_focus_strip')), findsNothing);
      final whyFinder = find.byKey(const Key('session_result_why_line_v1'));
      expect(whyFinder, findsOneWidget);
      final whyText = (tester.widget<Text>(whyFinder).data ?? '').trim();
      expect(whyText, 'Back to map: Top leak: Timing');
      expect(find.text('BACK TO MAP'), findsOneWidget);

      await tester.pump();

      final impressionEvents = logged
          .where(
            (event) =>
                event['name'] == TelemetryEvents.recommendationImpressionV1,
          )
          .toList();
      expect(impressionEvents, hasLength(1));
      final impressionPayload =
          impressionEvents.single['payload'] as Map<String, dynamic>;
      expect(impressionPayload['kind'], 'reviewFocus');
      expect(impressionPayload['reason'], 'Top leak: Timing');
      expect(impressionPayload['source'], 'result');
      expect(impressionPayload['has_campaign'], true);

      await tester.ensureVisible(sessionResultPrimaryActionFinder());
      await tester.tap(sessionResultPrimaryActionFinder(), warnIfMissed: false);
      await tester.pumpAndSettle();

      final selectedEvents = logged
          .where(
            (event) =>
                event['name'] == TelemetryEvents.recommendationSelectedV1,
          )
          .toList();
      expect(selectedEvents, hasLength(1));
      final selectedPayload =
          selectedEvents.single['payload'] as Map<String, dynamic>;
      expect(selectedPayload['kind'], 'reviewFocus');
      expect(selectedPayload['source'], 'result');

      expect(
        logged
            .where(
              (event) =>
                  event['name'] == TelemetryEvents.recommendationImpressionV1,
            )
            .length,
        1,
      );
    },
  );

  testWidgets(
    'non-campaign result suppresses top-leak wording and keeps neutral recommendation',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'learning_stats_v1_timing_errors': 3,
        'learning_stats_v1_total_decisions': 3,
        'learning_stats_v1_correct_decisions': 1,
      });

      final logged = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        logged.add(<String, dynamic>{'name': name, 'payload': payload ?? {}});
      });
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump();

      final impressionEvents = logged
          .where(
            (event) =>
                event['name'] == TelemetryEvents.recommendationImpressionV1,
          )
          .toList();
      expect(impressionEvents, hasLength(1));
      final impressionPayload =
          impressionEvents.single['payload'] as Map<String, dynamic>;
      expect(impressionPayload['kind'], 'nextModule');
      expect(impressionPayload['reason'], 'Continue');
      expect(impressionPayload['has_campaign'], false);
    },
  );

  testWidgets('review queue state remains visible via why line', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'review_queue_v1::world1_spine_campaign_v1':
          '[{"packId":"world1_spine_campaign_v1","stepIndex":2}]',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 4,
          totalCount: 5,
          moduleId: 'world1_spine_campaign_v1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final why = tester.widget<Text>(
      find.byKey(const Key('session_result_why_line_v1')),
    );
    expect((why.data ?? '').trim().isNotEmpty, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('review queue result surface uses unified finish framing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'review_queue_v1::world1_spine_campaign_v1':
          '[{"packId":"world1_spine_campaign_v1","stepIndex":2}]',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 4,
          totalCount: 5,
          moduleId: 'world1_spine_campaign_v1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Up next: Review missed spots'), findsOneWidget);
    expect(find.text('Clear.'), findsOneWidget);
    expect(
      find.text('Review the missed spot, then replay for perfect when ready.'),
      findsOneWidget,
    );
    final why = tester.widget<Text>(
      find.byKey(const Key('session_result_why_line_v1')),
    );
    expect((why.data ?? '').trim().isNotEmpty, isTrue);
    expect(find.text('Review before the next lesson'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'session result primary CTA label is REVIEW when review queue is present',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'review_queue_v1::world1_spine_campaign_v1':
            '[{"packId":"world1_spine_campaign_v1","stepIndex":2}]',
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 4,
            totalCount: 5,
            moduleId: 'world1_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_review_missed_cta')),
        findsOneWidget,
      );
      expect(find.text('REVIEW'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'session result primary CTA label is NEXT LESSON when no review queue is present',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 4,
            totalCount: 5,
            moduleId: 'world1_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_next_module_cta')),
        findsOneWidget,
      );
      expect(find.text('NEXT LESSON'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'spine-pack result surface adds canonical continuation framing and visible back-to-map secondary CTA',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 4,
            totalCount: 12,
            moduleId: 'world1_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final continuationFinder = find.byKey(
        const Key('session_result_continuation_line_v1'),
      );
      expect(continuationFinder, findsOneWidget);
      final continuationText =
          (tester.widget<Text>(continuationFinder).data ?? '').trim();
      expect(continuationText, 'Next lesson ready: World 1 · Pack 5 of 7.');

      final upNextHeadlineFinder = find.byKey(
        const Key('session_result_up_next_headline_v1'),
      );
      expect(upNextHeadlineFinder, findsOneWidget);
      final upNextHeadline =
          (tester.widget<Text>(upNextHeadlineFinder).data ?? '').trim();
      expect(upNextHeadline, 'Next up: Campaign spine');

      final summaryLineFinder = find.byKey(
        const Key('session_result_summary_line_secondary_v1'),
      );
      expect(summaryLineFinder, findsOneWidget);
      final summaryLine = (tester.widget<Text>(summaryLineFinder).data ?? '')
          .trim();
      expect(summaryLine, 'Next lesson ready: World 1 · Pack 5 of 7.');

      expect(
        find.byKey(const Key('session_result_secondary_back_to_map_cta_v1')),
        findsOneWidget,
      );
      expect(find.text('BACK TO MAP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact early-arc result keeps why-line meaning readable and CTA visible',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b0,world1_spine_followup_v1_b1,world1_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': false,
      });

      const expectedWhyLine =
          'Why: World 1 gave you position, action order, and simple preflop discipline. '
          'World 2 now asks you to read visible table truth before you choose.';

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.15)),
            child: SessionResultScreen(
              correctCount: 12,
              totalCount: 12,
              moduleId: 'world1_spine_followup_v1_b2',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final whyFinder = find.byKey(const Key('session_result_why_line_v1'));
      final ctaFinder = find.byKey(const Key('session_result_next_module_cta'));
      final whatsNextBlock = find.byKey(
        const Key('session_result_whats_next_block'),
      );

      expect(whyFinder, findsOneWidget);
      expect(ctaFinder, findsOneWidget);
      expect(whatsNextBlock, findsOneWidget);

      final whyText = tester.widget<Text>(whyFinder);
      expect(whyText.data, expectedWhyLine);
      expect(whyText.maxLines, isNull);
      expect(whyText.softWrap, isTrue);
      expect(whyText.overflow, TextOverflow.clip);

      final whyParagraph = tester.renderObject<RenderParagraph>(whyFinder);
      expect(whyParagraph.didExceedMaxLines, isFalse);

      final whyRect = tester.getRect(whyFinder);
      final ctaRect = tester.getRect(ctaFinder);
      final blockRect = tester.getRect(whatsNextBlock);
      expect(whyRect.top >= blockRect.top, isTrue);
      expect(whyRect.bottom <= ctaRect.top, isTrue);
      expect(ctaRect.bottom <= 640, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'result framing keeps one coherent status/why/primary CTA family on terminal non-spine session',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 3,
            totalCount: 5,
            moduleId: 'cash.s03',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final statusFinder = find.byKey(
        const Key('session_result_status_header_v1'),
      );
      expect(statusFinder, findsOneWidget);
      final statusText = (tester.widget<Text>(statusFinder).data ?? '').trim();
      expect(statusText, 'Clear.');

      final whyFinder = find.byKey(const Key('session_result_why_line_v1'));
      expect(whyFinder, findsOneWidget);
      final whyText = (tester.widget<Text>(whyFinder).data ?? '').trim();
      expect(whyText, isNotEmpty);
      final normalizedWhy = whyText.toLowerCase();
      expect(
        normalizedWhy.contains('focus:') || normalizedWhy.contains('map'),
        isTrue,
      );
      expect(find.text('Perfect path open'), findsOneWidget);
      expect(find.textContaining('Accuracy:'), findsNothing);
      expect(find.textContaining('mistake'), findsNothing);
      expect(find.textContaining('failed'), findsNothing);
      expect(find.textContaining('repaired'), findsNothing);
      expect(find.textContaining('cleared with error'), findsNothing);

      expect(find.text('BACK TO MAP'), findsOneWidget);
      expect(find.text('NEXT LESSON'), findsNothing);
      expect(find.text('REVIEW'), findsNothing);
      expect(find.text('FINISH'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'perfect result shows perfect clear payoff without grade framing',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 5,
            totalCount: 5,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final statusFinder = find.byKey(
        const Key('session_result_status_header_v1'),
      );
      expect(statusFinder, findsOneWidget);
      final statusText = (tester.widget<Text>(statusFinder).data ?? '').trim();
      expect(statusText, 'Perfect clear complete.');
      expect(find.textContaining('Accuracy:'), findsNothing);
      expect(find.textContaining('mistake'), findsNothing);
      expect(find.textContaining('failed'), findsNothing);
      expect(find.textContaining('repaired'), findsNothing);
      expect(find.textContaining('cleared with error'), findsNothing);
    },
  );

  testWidgets(
    'primary CTA handoff is deterministic for terminal non-spine session and returns to map root',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    const Text('MAP_ROOT', key: Key('map_root')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SessionResultScreen(
                              correctCount: 3,
                              totalCount: 5,
                              moduleId: 'cash.s03',
                            ),
                          ),
                        );
                      },
                      child: const Text('OPEN'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(find.text('BACK TO MAP'), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_primary_cta_v1')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('session_result_primary_cta_v1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map_root')), findsOneWidget);
      expect(find.byType(SessionResultScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'module completion write and world1 progression revision are idempotent across duplicate result mounts',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final baseRevision = ProgressService.world1ProgressRevision.value;

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();
      final revisionAfterFirst = ProgressService.world1ProgressRevision.value;
      expect(revisionAfterFirst, baseRevision + 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 2,
            totalCount: 3,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();
      final revisionAfterSecond = ProgressService.world1ProgressRevision.value;
      expect(revisionAfterSecond, revisionAfterFirst);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool('${ProgressService.completedPrefix}intro_welcome'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('campaign result summarizes and persists world mastery', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ProgressService.debugReset();

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 5,
          totalCount: 5,
          moduleId: 'world2_spine_campaign_v1',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final persisted = await ProgressService.getWorldMasteryForPackV1(
      'world2_spine_campaign_v1',
    );
    expect(persisted?.name, 'gold');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'table context is collapsed by default and expands deterministically',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 3,
            totalCount: 5,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_table_context_panel_v1')),
        findsNothing,
      );
      await tester.tap(
        find.byKey(const Key('session_result_table_context_toggle_v1')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('session_result_table_context_panel_v1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('session result continue path spends one chip', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'chips_balance_v1': 5,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 3,
          totalCount: 4,
          moduleId: 'world1_spine_campaign_v1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('chips_spent_total_v1'), isNull);

    await tester.ensureVisible(sessionResultPrimaryActionFinder());
    await tester.tap(sessionResultPrimaryActionFinder(), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 120));

    expect(prefs.getInt('chips_spent_total_v1'), 1);
    await tester.pump(const Duration(milliseconds: 240));
    expect(prefs.getInt('chips_spent_total_v1'), 1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 240,
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

List<String> _completedPacksThroughWorld10CampaignV1() {
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
  completedPacks.add('world10_spine_campaign_v1');
  return completedPacks;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'early-arc today plan surfaces stage-shift summary before world2 entry',
    (tester) async {
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

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntilAny(tester, <Finder>[
        find.byKey(const Key('today_plan_top_leak_title')),
        find.byKey(const Key('today_plan_top_leak_value')),
        find.byKey(const Key('today_plan_routing_reason_v1')),
      ]);

      final summaryLabel = tester.widget<Text>(
        find.byKey(const Key('today_plan_top_leak_title')),
      );
      final summaryValue = tester.widget<Text>(
        find.byKey(const Key('today_plan_top_leak_value')),
      );
      final routingReason = tester.widget<Text>(
        find.byKey(const Key('today_plan_routing_reason_v1')),
      );

      expect(summaryLabel.data, 'What changes now');
      expect(summaryValue.data, 'Read visible table truth');
      expect(
        routingReason.data,
        'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now asks you to read visible table truth before you choose.',
      );
    },
  );

  testWidgets(
    'early-arc result surface carries world1-to-world2 progression reason',
    (tester) async {
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

      final nextPack = await tester.runAsync(
        () => ProgressService.getNextPackConsideringCheckpointV1(
          'world1_spine_followup_v1_b2',
        ),
      );
      expect(nextPack, 'world2_spine_campaign_v1');

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 12,
            totalCount: 12,
            moduleId: 'world1_spine_followup_v1_b2',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_next_module_cta')),
        findsOneWidget,
      );
      expect(find.text('OPEN WORLD 2'), findsOneWidget);
      final whyFinder = find.byKey(const Key('session_result_why_line_v1'));
      expect(whyFinder, findsOneWidget);
      final whyText = (tester.widget<Text>(whyFinder).data ?? '').trim();
      expect(
        whyText,
        'Why: World 1 gave you position, action order, and simple preflop discipline. World 2 now asks you to read visible table truth before you choose.',
      );
    },
  );

  testWidgets(
    'session-backed world continuation parity stays aligned across intake and result',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': false,
      });

      final nextPack = await tester.runAsync(
        () => ProgressService.getNextPackConsideringCheckpointV1(
          'world5_spine_followup_v1_b2',
        ),
      );
      expect(nextPack, 'world6_spine_campaign_v1');

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntilAny(tester, <Finder>[
        find.byKey(const Key('today_plan_top_leak_value')),
        find.byKey(const Key('today_plan_routing_reason_v1')),
      ]);

      final summaryValue = tester.widget<Text>(
        find.byKey(const Key('today_plan_top_leak_value')),
      );
      final routingReason = tester.widget<Text>(
        find.byKey(const Key('today_plan_routing_reason_v1')),
      );
      expect(summaryValue.data, 'World 6 sessions');
      expect(
        routingReason.data,
        'Why: Your next learning route is World 6 sessions.',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 12,
            totalCount: 12,
            moduleId: 'world5_spine_followup_v1_b2',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_result_next_module_cta')),
        findsOneWidget,
      );
      expect(find.text('OPEN WORLD 6'), findsOneWidget);

      await tester.tap(find.byKey(const Key('session_result_next_module_cta')));
      await tester.pump();
      await _pumpUntilAny(tester, <Finder>[
        find.byType(CanonicalLaunchBoundaryRunnerSurfaceV1),
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      ]);

      expect(
        find.byType(CanonicalLaunchBoundaryRunnerSurfaceV1),
        findsOneWidget,
      );
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      final launcher = tester.widget<CanonicalLaunchBoundaryRunnerSurfaceV1>(
        find.byType(CanonicalLaunchBoundaryRunnerSurfaceV1),
      );
      expect(
        launcher
            .resolvedHostLaunchV1
            .terminalResolvedHostLaunchV1
            .sessionDrillSurfacedPayloadV1
            .sessionId,
        'w6.s01',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world10 tournament-track continuation parity stays aligned across intake and result',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 20,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            _completedPacksThroughWorld10CampaignV1().join(','),
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
        'world10_track_choice_v1':
            ProgressService.world10TrackChoiceTournamentV1,
      });

      final nextPack = await tester.runAsync(
        () => ProgressService.getNextPackConsideringCheckpointV1(
          'world10_spine_campaign_v1',
        ),
      );
      expect(nextPack, 'world10_spine_followup_v1_b1');

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntilAny(tester, <Finder>[
        find.byKey(const Key('today_plan_top_leak_value')),
        find.byKey(const Key('today_plan_routing_reason_v1')),
      ]);

      final summaryValue = tester.widget<Text>(
        find.byKey(const Key('today_plan_top_leak_value')),
      );
      final routingReason = tester.widget<Text>(
        find.byKey(const Key('today_plan_routing_reason_v1')),
      );
      expect(summaryValue.data, 'Tournament track');
      expect(
        routingReason.data,
        'Why: Your next learning route is the Tournament track.',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

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

      expect(
        find.byKey(const Key('session_result_next_module_cta')),
        findsOneWidget,
      );
      expect(find.text('OPEN TOURNAMENT TRACK'), findsOneWidget);

      await tester.tap(find.byKey(const Key('session_result_next_module_cta')));
      await tester.pump();
      await _pumpUntilAny(tester, <Finder>[
        find.byType(CanonicalLaunchBoundaryRunnerSurfaceV1),
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      ]);

      expect(
        find.byType(CanonicalLaunchBoundaryRunnerSurfaceV1),
        findsOneWidget,
      );
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
      final launcher = tester.widget<CanonicalLaunchBoundaryRunnerSurfaceV1>(
        find.byType(CanonicalLaunchBoundaryRunnerSurfaceV1),
      );
      expect(
        launcher
            .resolvedHostLaunchV1
            .terminalResolvedHostLaunchV1
            .sessionDrillSurfacedPayloadV1
            .sessionId,
        'tournament.s01',
      );
      expect(find.text('Choose your next track'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

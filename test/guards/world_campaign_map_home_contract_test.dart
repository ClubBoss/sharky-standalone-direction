import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import '_harness/canonical_direct_session_launch_contract_harness_v1.dart';
import 'package:poker_analyzer/services/mastery_progress_v1.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/today_router_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 80,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _completeCurrentRunnerToResultV1(WidgetTester tester) async {
  for (var i = 0; i < 220; i++) {
    if (find.byType(SessionResultScreen).evaluate().isNotEmpty) {
      return;
    }
    final requiresContinueFinder = find.byKey(
      const Key('spine_contract_requires_continue'),
      skipOffstage: false,
    );
    final targetFinder = find.byKey(
      const Key('spine_contract_expected_target'),
      skipOffstage: false,
    );
    final requiresContinue =
        requiresContinueFinder.evaluate().isNotEmpty &&
        (tester.widget<Text>(requiresContinueFinder.first).data ?? '').trim() ==
            'continue=1';
    if (requiresContinue) {
      final continueTarget = find.byKey(
        const Key('spine_contract_target_continue'),
      );
      if (continueTarget.evaluate().isNotEmpty) {
        await tester.tap(continueTarget.first, warnIfMissed: false);
      }
      await tester.pump(const Duration(milliseconds: 140));
      continue;
    }

    var targetToken = '';
    if (targetFinder.evaluate().isNotEmpty) {
      final raw = tester.widget<Text>(targetFinder.first).data ?? '';
      final match = RegExp(r'^target=(.+)$').firstMatch(raw.trim());
      targetToken = (match?.group(1) ?? '').trim();
    }
    if (targetToken.isNotEmpty) {
      final target = find.byKey(Key('spine_contract_target_$targetToken'));
      if (target.evaluate().isNotEmpty) {
        await tester.tap(target.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 70));
      }
    }

    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
      continue;
    }

    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<String> _continueFromResultToPlayableRunnerModuleIdV1(
  WidgetTester tester,
  String previousModuleId,
) async {
  expect(find.byType(SessionResultScreen), findsOneWidget);
  expect(find.byKey(const Key('session_result_up_next_v1')), findsOneWidget);
  expect(
    find.byKey(const Key('session_result_next_module_cta')),
    findsOneWidget,
  );

  await tester.tap(find.byKey(const Key('session_result_next_module_cta')));
  await tester.pump();
  for (var i = 0; i < 260; i++) {
    final summaryVisible = find
        .byKey(const Key('module_summary_start_theory_cta'))
        .evaluate()
        .isNotEmpty;
    if (summaryVisible) {
      break;
    }
    final runnerFinder = find.byType(World1FoundationsMicroTaskRunnerScreen);
    if (runnerFinder.evaluate().isNotEmpty) {
      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        runnerFinder.first,
      );
      if (runner.moduleId.trim().isNotEmpty &&
          runner.moduleId.trim() != previousModuleId.trim()) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 100));
  }

  final landedOnSummary = find
      .byKey(const Key('module_summary_start_theory_cta'))
      .evaluate()
      .isNotEmpty;
  final landedOnRunner = find
      .byType(World1FoundationsMicroTaskRunnerScreen)
      .evaluate()
      .isNotEmpty;
  expect(landedOnSummary || landedOnRunner, isTrue);

  if (landedOnSummary) {
    expect(
      find.byKey(const Key('module_summary_next_action_strip')),
      findsOneWidget,
    );
    final foundationsCheck = find.byKey(
      const Key('module_summary_foundations_check_cta'),
    );
    if (foundationsCheck.evaluate().isNotEmpty) {
      await tester.tap(foundationsCheck.first);
    } else {
      await tester.tap(
        find.byKey(const Key('module_summary_start_theory_cta')),
      );
    }
    await tester.pump();
  }
  for (var i = 0; i < 260; i++) {
    final runnerFinder = find.byType(World1FoundationsMicroTaskRunnerScreen);
    if (runnerFinder.evaluate().isNotEmpty) {
      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        runnerFinder.first,
      );
      if (runner.moduleId.trim().isNotEmpty &&
          runner.moduleId.trim() != previousModuleId.trim()) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
  final nextRunner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
    find.byType(World1FoundationsMicroTaskRunnerScreen),
  );
  final nextModuleId = nextRunner.moduleId.trim();
  expect(nextModuleId, isNotEmpty);
  return nextModuleId;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ProgressService.debugReset();
    await PremiumService().clear();
    Telemetry.overrideLogHandler(null);
  });

  testWidgets('campaign complete cold boot lands on map', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'spine_campaign_active_pack_id_v1': 'world1_spine_campaign_v1',
      'spine_campaign_next_hand_index_v1': 1,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': true,
      'world3_calibration_completed_v1': true,
      'world4_calibration_completed_v1': true,
      'world5_calibration_completed_v1': true,
      'world6_calibration_completed_v1': true,
      'world7_calibration_completed_v1': true,
      'world8_calibration_completed_v1': true,
      'world9_calibration_completed_v1': true,
      'world10_calibration_completed_v1': true,
      'chips_balance_v1': 12,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await _pumpUntil(
      tester,
      find.byKey(const Key('map_shell_v1')),
      maxTicks: 240,
    );
    await _pumpUntil(
      tester,
      find.byKey(const Key('world_campaign_section')),
      maxTicks: 240,
    );

    expect(find.byKey(const Key('map_shell_v1')), findsOneWidget);
    expect(find.byKey(const Key('world_campaign_section')), findsOneWidget);
    expect(find.byKey(const Key('map_chips_badge_v1')), findsOneWidget);
    expect(find.byKey(const Key('legacy_path_rhythm_strip_v1')), findsNothing);
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is! ValueKey<String>) return false;
        return key.value.startsWith('inline_pack_node_');
      }),
      findsWidgets,
    );
    expect(find.textContaining('Act 0:'), findsNothing);
    expect(
      find.byKey(const Key('world_campaign_next_pack_cta')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map_levels_button_v1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('map_levels_button_v1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('map_levels_sheet_v1')), findsOneWidget);
    expect(find.byKey(const Key('map_levels_tile_0_v1')), findsOneWidget);
    expect(find.byKey(const Key('map_levels_tile_1_v1')), findsOneWidget);
    expect(find.text('Level 0'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.textContaining('world1_'), findsNothing);
    expect(find.textContaining('spine_followup'), findsNothing);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('map_header_meta_v1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('map_levels_sheet_v1')), findsOneWidget);
    expect(find.byKey(const Key('map_levels_tile_0_v1')), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.textContaining('spine_followup'), findsNothing);
    expect(find.text('Unavailable slot'), findsNothing);
    expect(find.byKey(const Key('world_detail_sheet_v1')), findsNothing);
    final inlineNodeFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      if (key is! ValueKey<String>) return false;
      return key.value.startsWith('inline_pack_node_');
    });
    await tester.tap(inlineNodeFinder.first);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('map_node_preview_overlay_v1')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map_node_preview_sheet_v1')), findsNothing);
    expect(
      find.byKey(const Key('map_node_preview_primary_cta_v1')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('map_node_preview_primary_cta_v1')),
        matching: find.text('REVIEW'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('spine_followup'), findsNothing);
    expect(find.textContaining('world1_'), findsNothing);
    await tester.drag(
      find.byKey(const Key('world_campaign_section')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('map_node_preview_overlay_v1')), findsNothing);
    final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
    (state as dynamic).debugShowLockedNodePreviewForTestV1(
      subtitle: 'Complete previous lessons to unlock this. Up next: Practice 1',
    );
    await _pumpUntil(
      tester,
      find.byKey(const Key('map_node_preview_overlay_v1')),
    );
    expect(
      find.byKey(const Key('map_node_preview_overlay_v1')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('map_node_preview_primary_cta_v1')),
        matching: find.text('LOCKED'),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Complete previous lessons to unlock this.'),
      findsOneWidget,
    );
    final FilledButton lockedCta = tester.widget(
      find.byKey(const Key('map_node_preview_primary_cta_v1')),
    );
    expect(lockedCta.onPressed, isNull);
    expect(
      find.byKey(const Key('map_node_preview_close_cta_v1')),
      findsNothing,
    );
    await tester.drag(
      find.byKey(const Key('world_campaign_section')),
      const Offset(0, -120),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('map_node_preview_overlay_v1')), findsNothing);
    final visibleHeaderMetricCount = <Key>[
      const Key('map_chips_badge_v1'),
      const Key('map_world_mastery_badge'),
      const Key('map_world_skill_tags_summary'),
    ].where((key) => find.byKey(key).evaluate().isNotEmpty).length;
    expect(visibleHeaderMetricCount, lessThanOrEqualTo(2));
  });

  testWidgets('campaign map keeps learning stats in details only', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'learning_stats_v1_total_decisions': 10,
      'learning_stats_v1_correct_decisions': 7,
      'learning_stats_v1_timing_errors': 3,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'world2_calibration_completed_v1': false,
      'world3_calibration_completed_v1': false,
      'world4_calibration_completed_v1': false,
      'world5_calibration_completed_v1': false,
      'world6_calibration_completed_v1': false,
      'world7_calibration_completed_v1': false,
      'world8_calibration_completed_v1': false,
      'world9_calibration_completed_v1': false,
      'world10_calibration_completed_v1': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
    await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));
    expect(find.byKey(const Key('map_shell_v1')), findsOneWidget);
    expect(find.byKey(const Key('map_learning_hint_strip')), findsNothing);
    expect(find.textContaining('Accuracy:'), findsNothing);
    expect(find.textContaining('Top leak:'), findsNothing);
    expect(find.text('Cash'), findsNothing);
    expect(find.text('MTT'), findsNothing);
  });

  testWidgets('level completion transition sheet appears once with next/replay', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 12,
      'spine_campaign_active_pack_id_v1': 'world1_spine_followup_v1_b2',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b0,world1_spine_followup_v1_b1',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
    expect(find.byKey(const Key('map_level_complete_sheet_v1')), findsNothing);

    await ProgressService.markSpinePackCompletedV1(
      'world1_spine_followup_v1_b2',
    );
    final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
    await (state as dynamic).debugRefreshCampaignForTestV1();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const Key('map_level_complete_sheet_v1')),
      findsOneWidget,
    );
    expect(find.textContaining('You learned: Focus:'), findsOneWidget);
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.textContaining('Focus:'), findsWidgets);
    expect(find.textContaining('spine_followup'), findsNothing);
    expect(
      find.byKey(const Key('map_level_complete_next_cta_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('map_level_complete_replay_cta_v1')),
      findsOneWidget,
    );
  });

  testWidgets('entry world detail or buy-in start spends one chip', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('chips_spent_total_v1'), isNull);

    final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
    (state as dynamic).debugStartCampaignPackForTestV1(
      'world1_spine_campaign_v1',
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(prefs.getInt('chips_spent_total_v1'), 1);
    await tester.pump(const Duration(milliseconds: 240));
    expect(prefs.getInt('chips_spent_total_v1'), 1);
  });

  testWidgets('campaign map START NOW path spends one chip', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('chips_spent_total_v1'), isNull);

    final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
    (state as dynamic).debugHandleCampaignStartNowForTestV1();
    await tester.pump(const Duration(milliseconds: 120));

    expect(prefs.getInt('chips_spent_total_v1'), 1);
    await tester.pump(const Duration(milliseconds: 240));
    expect(prefs.getInt('chips_spent_total_v1'), 1);
  });

  testWidgets('campaign START NOW launches earliest incomplete world1 node', (
    tester,
  ) async {
    Future<void> runCase({
      required String completedPacksCsv,
      required String expectedModuleId,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': 'world1_act0_street_flow',
        'spine_campaign_next_hand_index_v1': 4,
        'spine_campaign_completed_packs_v1': completedPacksCsv,
        'spine_calibration_completed_v1': false,
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));

      final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
      (state as dynamic).debugHandleCampaignStartNowForTestV1();
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 120,
      );
      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.mode, kWorld1RunnerModeCampaignSpine);
      expect(runner.moduleId, expectedModuleId);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }

    await runCase(
      completedPacksCsv: '',
      expectedModuleId: 'world1_act0_table_literacy',
    );
    await runCase(
      completedPacksCsv: 'world1_act0_table_literacy',
      expectedModuleId: 'world1_act0_action_literacy',
    );
    await runCase(
      completedPacksCsv:
          'world1_act0_table_literacy,world1_act0_action_literacy',
      expectedModuleId: 'world1_act0_street_flow',
    );
    await runCase(
      completedPacksCsv:
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      expectedModuleId: 'world1_spine_campaign_v1',
    );
  });

  testWidgets(
    'fresh World1 visible first node matches canonical order and launches same pack as Start Now',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(
        tester,
        find.byKey(const Key('world_campaign_section')),
        maxTicks: 240,
      );
      final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
      (state as dynamic).debugSelectInlineWorldForTestV1(
        world: 1,
        nextPackId: kWorld1CanonicalModuleOrder.first,
      );
      await tester.pump();
      final visiblePackOrder =
          (state as dynamic).debugVisiblePackOrderForWorldForTestV1(1)
              as List<String>;
      final firstVisibleTitle =
          (state as dynamic).debugInlineNodeTitleForTestV1(
                packId: visiblePackOrder.first,
                inlineWorld: 1,
                lessonNumber: 1,
              )
              as String;
      final firstVisibleNextPackId =
          (state as dynamic).debugNextPackIdForWorldForTestV1(
                world: 1,
                completedPackIds: <String>{},
              )
              as String?;
      expect(kWorld1CanonicalModuleOrder.first, 'world1_act0_table_literacy');
      expect(visiblePackOrder, isNotEmpty);
      expect(visiblePackOrder.first, kWorld1CanonicalModuleOrder.first);
      expect(firstVisibleTitle, 'Table Basics');
      expect(firstVisibleNextPackId, kWorld1CanonicalModuleOrder.first);

      (state as dynamic).debugLaunchCampaignPackForTestV1(
        visiblePackOrder.first,
      );
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 120,
      );

      final tappedRunner = tester
          .widget<World1FoundationsMicroTaskRunnerScreen>(
            find.byType(World1FoundationsMicroTaskRunnerScreen),
          );
      expect(tappedRunner.mode, kWorld1RunnerModeCampaignSpine);
      expect(tappedRunner.moduleId, kWorld1CanonicalModuleOrder.first);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));

      final restartedState = tester.state(find.byType(UiV2ProgressMapScreenV2));
      (restartedState as dynamic).debugHandleCampaignStartNowForTestV1();
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 120,
      );

      final startNowRunner = tester
          .widget<World1FoundationsMicroTaskRunnerScreen>(
            find.byType(World1FoundationsMicroTaskRunnerScreen),
          );
      expect(startNowRunner.moduleId, tappedRunner.moduleId);
      expect(startNowRunner.moduleId, kWorld1CanonicalModuleOrder.first);
    },
  );

  testWidgets(
    'reset spine progress clears Start-Now read state and routes fresh to act0 table first',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': 'world1_act0_action_literacy',
        'spine_campaign_next_hand_index_v1': 3,
        'spine_campaign_completed_packs_v1': 'world1_act0_table_literacy',
        '${ProgressService.completedPrefix}world1_act0_table_literacy': true,
      });
      final prefs = await SharedPreferences.getInstance();

      await ProgressService.resetSpineProgressV1();

      expect(
        prefs.getString('spine_campaign_completed_packs_v1'),
        anyOf(isNull, isEmpty),
      );
      expect(prefs.getString('spine_campaign_active_pack_id_v1'), isNull);
      expect(prefs.getInt('spine_campaign_next_hand_index_v1'), isNull);
      expect(
        prefs.getBool(
          '${ProgressService.completedPrefix}world1_act0_table_literacy',
        ),
        isNull,
        reason:
            'Reset must clear legacy completion bit to avoid reset/read divergence.',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));

      final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
      (state as dynamic).debugHandleCampaignStartNowForTestV1();
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 120,
      );

      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.mode, kWorld1RunnerModeCampaignSpine);
      expect(runner.moduleId, 'world1_act0_table_literacy');
    },
  );

  testWidgets('review queue start path spends one chip', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_calibration_completed_v1': true,
      'spine_calibration_band_v1': 2,
      'review_queue_v1::world1_spine_campaign_v1':
          '[{"packId":"world1_spine_campaign_v1","stepIndex":2}]',
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('chips_spent_total_v1'), isNull);

    final state = tester.state(find.byType(UiV2ProgressMapScreenV2));
    (state as dynamic).debugOpenReviewQueueForPackForTestV1(
      'world1_spine_campaign_v1',
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(prefs.getInt('chips_spent_total_v1'), 1);
    await tester.pump(const Duration(milliseconds: 240));
    expect(prefs.getInt('chips_spent_total_v1'), 1);
  });

  testWidgets(
    'map shell exposes a single dominant primary CTA in default state',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });
      ProgressService.world1DailyCompletionInSession.value = false;
      ProgressService.intakeFlowActiveInSession = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      expect(find.byKey(const Key('world_detail_sheet_v1')), findsNothing);
      expect(find.byType(FilledButton).evaluate().length, lessThanOrEqualTo(1));
      expect(find.textContaining('Act 0:'), findsNothing);
      expect(
        find.byKey(const Key('legacy_path_rhythm_strip_v1')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today router is deterministic, gauntlet steps are isolated, and today plan keeps one primary CTA',
    (tester) async {
      final schedule = File(
        'content/schedules/daily/v1/schedule.md',
      ).readAsStringSync();
      final world1Gauntlet = File(
        'content/gauntlets/world1_onramp_playlist_v1/v1/gauntlet.md',
      ).readAsStringSync();
      final decision = TodayRouterV1.resolveDeterministic(
        utcDayKey: '2026-02-24',
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
      );
      expect(decision.kind, TodayRouteKindV1.gauntlet);
      expect(decision.gauntletId, 'world1_onramp_playlist_v1');
      expect(decision.firstStepType, 'module');
      expect(decision.firstStepRef, 'world1_act0_table_literacy');
      final steps = TodayRouterV1.parseAllStepsFromGauntletMarkdown(
        world1Gauntlet,
      );
      expect(steps.length, greaterThanOrEqualTo(2));
      final isolation = GauntletStepIsolationCoordinatorV1();
      final step1Token = isolation.beginFreshStepLaunch(
        gauntletId: decision.gauntletId!,
        stepIndex: 0,
        stepType: steps[0].type,
        stepRef: steps[0].ref,
      );
      isolation.debugWriteStepScratchForTest('selected_seat', 'btn');
      expect(isolation.debugReadStepScratchForTest('selected_seat'), 'btn');
      final step2Token = isolation.beginFreshStepLaunch(
        gauntletId: decision.gauntletId!,
        stepIndex: 1,
        stepType: steps[1].type,
        stepRef: steps[1].ref,
      );
      expect(step2Token.sessionBoundaryId, isNot(step1Token.sessionBoundaryId));
      expect(step2Token.stepIndex, 1);
      expect(isolation.debugActiveStepIndexForTest, 1);
      expect(isolation.debugReadStepScratchForTest('selected_seat'), isNull);
      expect(step2Token.stepRef, isNot(step1Token.stepRef));

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UniversalIntakePlanScreen(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));

      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(find.byType(FilledButton).evaluate().length, lessThanOrEqualTo(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'leaks v1-lite queue ordering/cap is deterministic and router returns leaks when due after gauntlet',
    (tester) async {
      await ProgressService.debugReset();
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 23, 10, 0).millisecondsSinceEpoch,
        source: 'today_gauntlet',
        packId: 'world1_spine_campaign_v1',
        errorType: 'timing',
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 23, 9, 0).millisecondsSinceEpoch,
        source: 'runner_error',
        moduleId: 'world1_act0_table_literacy',
        errorType: 'seat',
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 23, 9, 0).millisecondsSinceEpoch,
        source: 'runner_error',
        moduleId: 'world1_act0_action_literacy',
        errorType: 'seat',
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 24, 1, 0).millisecondsSinceEpoch,
        source: 'today_gauntlet',
        packId: 'world1_act0_street_flow',
        errorType: 'timing',
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 24, 2, 0).millisecondsSinceEpoch,
        source: 'today_gauntlet',
        packId: 'world1_streets_demo_v1',
        errorType: 'timing',
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 24, 3, 0).millisecondsSinceEpoch,
        source: 'today_gauntlet',
        packId: 'world1_spine_followup_v1_b0',
        errorType: 'timing',
      );

      final queue = await ProgressService.getLeaksQueueForDayV1(
        utcDayKey: '2026-02-24',
      );
      expect(ProgressService.leaksQueueAlgoVersionV1, 'leaks_queue_v1');
      expect(queue.length, ProgressService.leaksDailyCapV1);
      for (var i = 1; i < queue.length; i++) {
        final prev = queue[i - 1];
        final next = queue[i];
        final ordered =
            prev.utcTsMs < next.utcTsMs ||
            (prev.utcTsMs == next.utcTsMs &&
                prev.leakId.compareTo(next.leakId) <= 0);
        expect(ordered, isTrue);
      }
      final due = await ProgressService.isLeaksDueForDayV1(
        utcDayKey: '2026-02-24',
      );
      expect(due, isTrue);

      final schedule = File(
        'content/schedules/daily/v1/schedule.md',
      ).readAsStringSync();
      final world1Gauntlet = File(
        'content/gauntlets/world1_onramp_playlist_v1/v1/gauntlet.md',
      ).readAsStringSync();

      final leaksDecision = TodayRouterV1.resolveDeterministic(
        utcDayKey: '2026-02-24',
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
        progress: const TodayProgressStateV1(
          gauntletPlayedToday: true,
          leaksEnabled: true,
          leaksDue: true,
        ),
      );
      expect(leaksDecision.kind, TodayRouteKindV1.leaks);

      final gauntletDecision = TodayRouterV1.resolveDeterministic(
        utcDayKey: '2026-02-24',
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
        progress: const TodayProgressStateV1(
          gauntletPlayedToday: false,
          leaksEnabled: true,
          leaksDue: true,
        ),
      );
      expect(gauntletDecision.kind, TodayRouteKindV1.gauntlet);
    },
  );

  testWidgets(
    'leaks resolution log deterministically suppresses resolved leaks without mutating base log',
    (tester) async {
      await ProgressService.debugReset();
      final leakATs = DateTime.utc(2026, 2, 24, 9, 0).millisecondsSinceEpoch;
      final leakBTs = DateTime.utc(2026, 2, 24, 10, 0).millisecondsSinceEpoch;
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: leakATs,
        source: 'today_gauntlet',
        packId: 'world1_spine_campaign_v1',
        errorType: 'timing',
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: leakBTs,
        source: 'today_gauntlet',
        packId: 'world1_streets_demo_v1',
        errorType: 'timing',
      );

      final allLeaksBefore = await ProgressService.getLeakLogEntriesV1();
      expect(allLeaksBefore.length, 2);
      final leakA = allLeaksBefore.firstWhere((e) => e.utcTsMs == leakATs);
      final leakB = allLeaksBefore.firstWhere((e) => e.utcTsMs == leakBTs);

      await ProgressService.appendLeakResolutionEntryV1(
        leakId: leakA.leakId,
        resolvedUtcTsMs: DateTime.utc(
          2026,
          2,
          24,
          12,
          0,
        ).millisecondsSinceEpoch,
      );

      final allLeaksAfter = await ProgressService.getLeakLogEntriesV1();
      expect(
        allLeaksAfter.length,
        2,
        reason: 'base leaks log remains append-only',
      );
      expect(allLeaksAfter.any((e) => e.leakId == leakA.leakId), isTrue);
      expect(allLeaksAfter.any((e) => e.leakId == leakB.leakId), isTrue);

      final resolutions = await ProgressService.getLeakResolutionLogEntriesV1();
      expect(resolutions.length, 1);
      expect(resolutions.single.leakId, leakA.leakId);

      final queue = await ProgressService.getLeaksQueueForDayV1(
        utcDayKey: '2026-02-24',
      );
      expect(queue.length, 1);
      expect(queue.single.leakId, leakB.leakId);
      expect(queue.single.utcTsMs, leakBTs);
      expect(queue.any((e) => e.leakId == leakA.leakId), isFalse);

      final queueAgain = await ProgressService.getLeaksQueueForDayV1(
        utcDayKey: '2026-02-24',
      );
      expect(
        queueAgain.map((e) => e.leakId).toList(),
        queue.map((e) => e.leakId).toList(),
      );
      final due = await ProgressService.isLeaksDueForDayV1(
        utcDayKey: '2026-02-24',
      );
      expect(due, isTrue);
    },
  );

  testWidgets(
    'today router ladder priority/exclusivity invariant is deterministic',
    (tester) async {
      final schedule = File(
        'content/schedules/daily/v1/schedule.md',
      ).readAsStringSync();
      final world1Gauntlet = File(
        'content/gauntlets/world1_onramp_playlist_v1/v1/gauntlet.md',
      ).readAsStringSync();

      final cases =
          <
            ({
              String label,
              TodayProgressStateV1 progress,
              TodayRouteKindV1 expectedKind,
            })
          >[
            (
              label: 'not played + leaks due/enabled => gauntlet',
              progress: const TodayProgressStateV1(
                gauntletPlayedToday: false,
                leaksDue: true,
                leaksEnabled: true,
              ),
              expectedKind: TodayRouteKindV1.gauntlet,
            ),
            (
              label: 'not played + leaks not due => gauntlet',
              progress: const TodayProgressStateV1(
                gauntletPlayedToday: false,
                leaksDue: false,
                leaksEnabled: true,
              ),
              expectedKind: TodayRouteKindV1.gauntlet,
            ),
            (
              label: 'played + due + enabled => leaks',
              progress: const TodayProgressStateV1(
                gauntletPlayedToday: true,
                leaksDue: true,
                leaksEnabled: true,
              ),
              expectedKind: TodayRouteKindV1.leaks,
            ),
            (
              label: 'played + not due => practice',
              progress: const TodayProgressStateV1(
                gauntletPlayedToday: true,
                leaksDue: false,
                leaksEnabled: true,
              ),
              expectedKind: TodayRouteKindV1.practice,
            ),
            (
              label: 'played + due + leaks disabled => practice',
              progress: const TodayProgressStateV1(
                gauntletPlayedToday: true,
                leaksDue: true,
                leaksEnabled: false,
              ),
              expectedKind: TodayRouteKindV1.practice,
            ),
          ];

      for (final testCase in cases) {
        final decision = TodayRouterV1.resolveDeterministic(
          utcDayKey: '2026-02-24',
          cohort: TodayRouterCohortV1.beginner,
          scheduleMarkdown: schedule,
          gauntletMarkdownById: <String, String>{
            'world1_onramp_playlist_v1': world1Gauntlet,
          },
          progress: testCase.progress,
        );

        expect(decision.kind, testCase.expectedKind, reason: testCase.label);
        expect(
          TodayRouteKindV1.values.contains(decision.kind),
          isTrue,
          reason: testCase.label,
        );

        if (decision.kind == TodayRouteKindV1.gauntlet) {
          expect(decision.gauntletId, isNotNull, reason: testCase.label);
          expect(decision.firstStepType, isNotNull, reason: testCase.label);
          expect(decision.firstStepRef, isNotNull, reason: testCase.label);
        } else {
          expect(decision.gauntletId, isNull, reason: testCase.label);
          expect(decision.firstStepType, isNull, reason: testCase.label);
          expect(decision.firstStepRef, isNull, reason: testCase.label);
        }
      }
    },
  );

  testWidgets(
    'explicit gauntlet completion marker replaces txn proxy for today router deterministically',
    (tester) async {
      await ProgressService.debugReset();
      final schedule = File(
        'content/schedules/daily/v1/schedule.md',
      ).readAsStringSync();
      final world1Gauntlet = File(
        'content/gauntlets/world1_onramp_playlist_v1/v1/gauntlet.md',
      ).readAsStringSync();

      const dayKey = '2026-01-01';
      const cohort = 'beginner';
      final leaksDueBefore = await ProgressService.isLeaksDueForDayV1(
        utcDayKey: dayKey,
      );
      expect(leaksDueBefore, isFalse);
      final completedBefore = await ProgressService.isGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
      );
      expect(completedBefore, isFalse);

      final beforeDecision = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedBefore,
          leaksEnabled: true,
          leaksDue: leaksDueBefore,
        ),
      );
      expect(beforeDecision.kind, TodayRouteKindV1.gauntlet);
      final routedGauntletId = beforeDecision.gauntletId;
      expect(routedGauntletId, isNotNull);

      await ProgressService.markGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
        gauntletId: routedGauntletId!,
      );
      final completionLog =
          await ProgressService.getGauntletCompletionLogEntriesV1();
      expect(completionLog.length, 1);
      expect(completionLog.single.utcDayKey, dayKey);
      expect(completionLog.single.cohort, cohort);
      expect(completionLog.single.gauntletId, routedGauntletId);

      final leakTs = DateTime.utc(2026, 1, 1, 9, 0).millisecondsSinceEpoch;
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: leakTs,
        source: 'today_gauntlet',
        packId: 'world1_spine_campaign_v1',
        errorType: 'timing',
      );

      final completedAfter1 = await ProgressService.isGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
      );
      final completedAfter2 = await ProgressService.isGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
      );
      expect(completedAfter1, isTrue);
      expect(completedAfter2, isTrue);

      final leaksDueAfter = await ProgressService.isLeaksDueForDayV1(
        utcDayKey: dayKey,
      );
      expect(leaksDueAfter, isTrue);

      final afterDecisionLeaks = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedAfter1,
          leaksEnabled: true,
          leaksDue: leaksDueAfter,
        ),
      );
      final afterDecisionLeaksAgain = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedAfter2,
          leaksEnabled: true,
          leaksDue: leaksDueAfter,
        ),
      );
      expect(afterDecisionLeaks.kind, TodayRouteKindV1.leaks);
      expect(afterDecisionLeaksAgain.kind, TodayRouteKindV1.leaks);

      final afterDecisionPractice = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{
          'world1_onramp_playlist_v1': world1Gauntlet,
        },
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedAfter1,
          leaksEnabled: true,
          leaksDue: false,
        ),
      );
      expect(afterDecisionPractice.kind, TodayRouteKindV1.practice);
    },
  );

  testWidgets(
    'gauntlet step progression is deterministic and completion only marks after last step',
    (tester) async {
      await ProgressService.debugReset();
      const dayKey = '2026-01-01';
      const cohort = 'beginner';
      const gauntletId = 'world1_onramp_playlist_v1';
      final schedule = File(
        'content/schedules/daily/v1/schedule.md',
      ).readAsStringSync();
      final gauntletMarkdown = File(
        'content/gauntlets/world1_onramp_playlist_v1/v1/gauntlet.md',
      ).readAsStringSync();
      final steps = TodayRouterV1.parseAllStepsFromGauntletMarkdown(
        gauntletMarkdown,
      );
      expect(steps.length >= 2, isTrue);

      final stepIndex0 = await ProgressService.getGauntletStepIndexV1(
        utcDayKey: dayKey,
        cohort: cohort,
        gauntletId: gauntletId,
      );
      expect(stepIndex0, 0);
      expect(steps[stepIndex0].ref, isNotEmpty);

      final completedBefore = await ProgressService.isGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
      );
      expect(completedBefore, isFalse);
      final beforeDecision = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{gauntletId: gauntletMarkdown},
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedBefore,
          leaksEnabled: true,
          leaksDue: false,
        ),
      );
      expect(beforeDecision.kind, TodayRouteKindV1.gauntlet);

      await ProgressService.advanceGauntletStepV1(
        utcDayKey: dayKey,
        cohort: cohort,
        gauntletId: gauntletId,
        currentStepIndex: stepIndex0,
      );
      final stepIndex1 = await ProgressService.getGauntletStepIndexV1(
        utcDayKey: dayKey,
        cohort: cohort,
        gauntletId: gauntletId,
      );
      expect(stepIndex1, 1, reason: 'step 0 completion advances to step 1');

      final completedMid = await ProgressService.isGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
      );
      expect(completedMid, isFalse, reason: 'not completed until last step');
      final midDecision = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{gauntletId: gauntletMarkdown},
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedMid,
          leaksEnabled: true,
          leaksDue: false,
        ),
      );
      expect(midDecision.kind, TodayRouteKindV1.gauntlet);

      for (var i = stepIndex1; i < steps.length; i++) {
        final isLast = i == steps.length - 1;
        if (isLast) {
          await ProgressService.markGauntletCompletedV1(
            utcDayKey: dayKey,
            cohort: cohort,
            gauntletId: gauntletId,
          );
          await ProgressService.resetGauntletStepV1(
            utcDayKey: dayKey,
            cohort: cohort,
            gauntletId: gauntletId,
          );
        } else {
          await ProgressService.advanceGauntletStepV1(
            utcDayKey: dayKey,
            cohort: cohort,
            gauntletId: gauntletId,
            currentStepIndex: i,
          );
        }
      }

      final completedAfter = await ProgressService.isGauntletCompletedV1(
        utcDayKey: dayKey,
        cohort: cohort,
      );
      expect(completedAfter, isTrue);
      final resetStepIndex = await ProgressService.getGauntletStepIndexV1(
        utcDayKey: dayKey,
        cohort: cohort,
        gauntletId: gauntletId,
      );
      expect(resetStepIndex, 0, reason: 'last-step completion resets progress');

      final afterDecision = TodayRouterV1.resolveDeterministic(
        utcDayKey: dayKey,
        cohort: TodayRouterCohortV1.beginner,
        scheduleMarkdown: schedule,
        gauntletMarkdownById: <String, String>{gauntletId: gauntletMarkdown},
        progress: TodayProgressStateV1(
          gauntletPlayedToday: completedAfter,
          leaksEnabled: true,
          leaksDue: false,
        ),
      );
      expect(afterDecision.kind, TodayRouteKindV1.practice);
    },
  );

  testWidgets(
    'cohort promotion is deterministic and today router schedule resolution uses persisted cohort',
    (tester) async {
      await ProgressService.debugReset();
      final schedule = File(
        'content/schedules/daily/v1/schedule.md',
      ).readAsStringSync();

      final defaultCohort1 = await ProgressService.getCurrentCohortV1();
      final defaultCohort2 = await ProgressService.getCurrentCohortV1();
      expect(defaultCohort1, 'beginner');
      expect(defaultCohort2, 'beginner');

      final beginnerGauntlet =
          TodayRouterV1.resolveGauntletIdFromScheduleMarkdown(
            schedule,
            utcDayKey: '2026-01-01',
            cohort: TodayRouterCohortV1.beginner,
          );
      final intermediateGauntlet =
          TodayRouterV1.resolveGauntletIdFromScheduleMarkdown(
            schedule,
            utcDayKey: '2026-01-01',
            cohort: TodayRouterCohortV1.intermediate,
          );
      expect(beginnerGauntlet, isNotNull);
      expect(intermediateGauntlet, isNotNull);
      expect(beginnerGauntlet, isNot(equals(intermediateGauntlet)));

      for (var i = 0; i < 4; i++) {
        await ProgressService.markGauntletCompletedV1(
          utcDayKey: '2026-01-0${i + 1}',
          cohort: 'beginner',
          gauntletId: 'world1_onramp_playlist_v1',
        );
      }
      expect(await ProgressService.getCurrentCohortV1(), 'beginner');

      await ProgressService.markGauntletCompletedV1(
        utcDayKey: '2026-01-05',
        cohort: 'beginner',
        gauntletId: 'world2_streets_challenge_v1',
      );
      final promotedCohort1 = await ProgressService.getCurrentCohortV1();
      final promotedCohort2 = await ProgressService.getCurrentCohortV1();
      expect(promotedCohort1, 'intermediate');
      expect(promotedCohort2, 'intermediate');

      final currentCohort = await ProgressService.getCurrentCohortV1();
      final routedForCurrent =
          TodayRouterV1.resolveGauntletIdFromScheduleMarkdown(
            schedule,
            utcDayKey: '2026-01-01',
            cohort: currentCohort == 'intermediate'
                ? TodayRouterCohortV1.intermediate
                : TodayRouterCohortV1.beginner,
          );
      final routedForCurrentAgain =
          TodayRouterV1.resolveGauntletIdFromScheduleMarkdown(
            schedule,
            utcDayKey: '2026-01-01',
            cohort: currentCohort == 'intermediate'
                ? TodayRouterCohortV1.intermediate
                : TodayRouterCohortV1.beginner,
          );
      expect(routedForCurrent, intermediateGauntlet);
      expect(routedForCurrentAgain, intermediateGauntlet);
    },
  );

  testWidgets(
    'cohort promotion event is deterministic, consumed once, and today banner is shown once',
    (tester) async {
      Future<void> seedTodayPrefs() async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'onboardingCompleted': true,
          'intake_completed_v1': true,
          'chips_balance_v1': 5,
          'spine_campaign_active_pack_id_v1': '',
          'spine_campaign_next_hand_index_v1': 0,
          'spine_campaign_completed_packs_v1': '',
        });
      }

      // Service-level proof: event written at threshold and consumed once.
      await ProgressService.debugReset();
      await seedTodayPrefs();
      for (var i = 0; i < 5; i++) {
        await ProgressService.markGauntletCompletedV1(
          utcDayKey: '2026-01-05',
          cohort: 'beginner',
          gauntletId: i.isEven
              ? 'world1_onramp_playlist_v1'
              : 'world2_streets_challenge_v1',
        );
      }
      final events = await ProgressService.getCohortPromotionEventEntriesV1();
      expect(events.length, 1);
      expect(events.single.utcDayKey, '2026-01-05');
      expect(events.single.fromCohort, 'beginner');
      expect(events.single.toCohort, 'intermediate');

      final consumed1 = await ProgressService.consumeLatestPromotionEventV1(
        utcDayKey: '2026-01-05',
      );
      final consumed2 = await ProgressService.consumeLatestPromotionEventV1(
        utcDayKey: '2026-01-05',
      );
      expect(consumed1, isNotNull);
      expect(consumed1!.toCohort, 'intermediate');
      expect(consumed2, isNull);

      // UI-level proof: bootstrap consumes event once; rebuild does not re-show.
      await ProgressService.debugReset();
      await seedTodayPrefs();
      for (var i = 0; i < 5; i++) {
        await ProgressService.markGauntletCompletedV1(
          utcDayKey: '2026-01-05',
          cohort: 'beginner',
          gauntletId: i.isEven
              ? 'world1_onramp_playlist_v1'
              : 'world2_streets_challenge_v1',
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UniversalIntakePlanScreen(
            debugUtcDayKeyOverrideV1: '2026-01-05',
          ),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      expect(
        find.byKey(const Key('today_plan_cohort_promotion_banner_v1')),
        findsOneWidget,
      );
      expect(find.text('Promoted to INTERMEDIATE'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UniversalIntakePlanScreen(
            debugUtcDayKeyOverrideV1: '2026-01-05',
          ),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      expect(
        find.byKey(const Key('today_plan_cohort_promotion_banner_v1')),
        findsNothing,
      );

      final consumedAfterUi =
          await ProgressService.consumeLatestPromotionEventV1(
            utcDayKey: '2026-01-05',
          );
      expect(consumedAfterUi, isNull);
    },
  );

  testWidgets(
    'today CTA routes to review queue surface when leaks are due after gauntlet',
    (tester) async {
      await ProgressService.debugReset();
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 24, 9, 0).millisecondsSinceEpoch,
        source: 'today_gauntlet',
        packId: 'world1_spine_campaign_v1',
        errorType: 'timing',
      );
      await ProgressService.markGauntletCompletedV1(
        utcDayKey: '2026-02-24',
        cohort: 'beginner',
        gauntletId: 'world1_onramp_playlist_v1',
      );

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });

      // Re-append after setMockInitialValues reset to keep leaks/completion deterministic.
      final nextPackId = await ProgressService.getNextSpinePackToRunV1();
      await ProgressService.addReviewRefForPackV1(
        nextPackId,
        ReviewRefV1(packId: nextPackId, stepIndex: 2),
      );
      await ProgressService.appendLeakLogEntryV1(
        utcTsMs: DateTime.utc(2026, 2, 24, 9, 0).millisecondsSinceEpoch,
        source: 'today_gauntlet',
        packId: 'world1_spine_campaign_v1',
        errorType: 'timing',
      );
      await ProgressService.markGauntletCompletedV1(
        utcDayKey: '2026-02-24',
        cohort: 'beginner',
        gauntletId: 'world1_onramp_playlist_v1',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UniversalIntakePlanScreen(
            debugUtcDayKeyOverrideV1: '2026-02-24',
          ),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 32));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan shows review entry and routes to review queue when next-pack queue exists',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
        'review_queue_v1::world1_spine_campaign_v1':
            '[{"packId":"world1_spine_campaign_v1","stepIndex":1}]',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      await _pumpUntil(tester, find.byKey(const Key('today_plan_start_cta')));

      expect(find.text('REVIEW MISSED'), findsOneWidget);

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 160,
      );
      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );

      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.mode, kWorld1RunnerModeReviewQueue);
      expect(runner.moduleId, 'world1_spine_campaign_v1');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan placement route (w0) opens world1 session and up-next continues to next world1 module',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'placement_route_v1':
            '{"schemaVersion":1,"bucket":"beginner","startTargetSessionId":"w0.s01","repairSessionId":null,"reasonCodes":["target_w0_s01"]}',
        'placement_route_progress_v1':
            '{"schemaVersion":1,"repairPending":false,"targetPending":true}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
      await _pumpUntil(tester, find.byKey(const Key('today_plan_start_cta')));
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 220,
      );
      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      final initialRunner = tester
          .widget<World1FoundationsMicroTaskRunnerScreen>(
            find.byType(World1FoundationsMicroTaskRunnerScreen),
          );
      expect(initialRunner.moduleId, 'world1_act0_table_literacy');
      expect(tester.takeException(), isNull);

      await _completeCurrentRunnerToResultV1(tester);
      final nextModuleId = await _continueFromResultToPlayableRunnerModuleIdV1(
        tester,
        initialRunner.moduleId,
      );
      expect(nextModuleId, isNot(initialRunner.moduleId));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan placement route active world seeds keep up-next traversal reachable and non-dead-end',
    (tester) async {
      const placementTargets = <String>[
        'w0.s01',
        'w1.s01',
        'w2.s01',
        'w3.s01',
        'w4.s01',
        'w5.s01',
      ];

      for (final targetSessionId in placementTargets) {
        final worldMatch = RegExp(
          r'^w([0-9]+)\.s[0-9]{2}$',
        ).firstMatch(targetSessionId);
        final worldIndex = int.tryParse(worldMatch?.group(1) ?? '') ?? 0;
        final launchesAsDirectSession =
            canonicalTruthPlayableSessionEntriesForWorldV1(
              worldIndex,
            ).any((entry) => entry.sessionId == targetSessionId);
        final premiumActive = worldIndex >= 5;
        await ProgressService.debugReset();
        SharedPreferences.setMockInitialValues(<String, Object>{
          'onboardingCompleted': true,
          'intake_completed_v1': true,
          'chips_balance_v1': 5,
          'premium_is_active': false,
          'placement_route_v1':
              '{"schemaVersion":1,"bucket":"beginner","startTargetSessionId":"$targetSessionId","repairSessionId":null,"reasonCodes":["target_$targetSessionId"]}',
          'placement_route_progress_v1':
              '{"schemaVersion":1,"repairPending":false,"targetPending":true}',
          'spine_campaign_active_pack_id_v1': '',
          'spine_campaign_next_hand_index_v1': 0,
          'spine_campaign_completed_packs_v1': '',
        });

        await tester.pumpWidget(
          const MaterialApp(home: UniversalIntakePlanScreen()),
        );
        await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
        await _pumpUntil(
          tester,
          find.byKey(const Key('today_plan_start_cta')),
          maxTicks: 220,
        );
        expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
        if (premiumActive) {
          await PaymentService.syncCanonicalEntitlementForProductV1(
            PaymentService.productPremiumPack,
          );
        }

        await tester.tap(find.byKey(const Key('today_plan_start_cta')));
        await tester.pump();
        if (launchesAsDirectSession) {
          await _pumpUntil(
            tester,
            findCanonicalDirectSessionSurfaceV1(),
            maxTicks: 220,
          );
          expectCanonicalDirectSessionLaunchV1(tester, targetSessionId);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(milliseconds: 16));
          continue;
        }
        await _pumpUntil(
          tester,
          find.byType(World1FoundationsMicroTaskRunnerScreen),
          maxTicks: 220,
        );
        expect(
          find.byType(World1FoundationsMicroTaskRunnerScreen),
          findsOneWidget,
        );
        final initialRunner = tester
            .widget<World1FoundationsMicroTaskRunnerScreen>(
              find.byType(World1FoundationsMicroTaskRunnerScreen),
            );
        final initialModuleId = initialRunner.moduleId.trim();
        expect(initialModuleId, isNotEmpty);

        await _completeCurrentRunnerToResultV1(tester);
        var nextModuleId = await _continueFromResultToPlayableRunnerModuleIdV1(
          tester,
          initialModuleId,
        );
        if (nextModuleId == initialModuleId) {
          await _completeCurrentRunnerToResultV1(tester);
          nextModuleId = await _continueFromResultToPlayableRunnerModuleIdV1(
            tester,
            initialModuleId,
          );
        }
        expect(
          nextModuleId,
          isNot(initialModuleId),
          reason:
              'up-next did not advance for seed $targetSessionId after bounded retry: stayed at $initialModuleId',
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan gates world5 placement behind premium preview and restore unblocks next attempt',
    (tester) async {
      await ProgressService.debugReset();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'placement_route_v1':
            '{"schemaVersion":1,"bucket":"beginner","startTargetSessionId":"w5.s01","repairSessionId":null,"reasonCodes":["target_w5.s01"]}',
        'placement_route_progress_v1':
            '{"schemaVersion":1,"repairPending":false,"targetPending":true}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      await _pumpUntil(tester, find.byKey(const Key('today_plan_start_cta')));
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('today_plan_premium_preview_title_v1')),
        findsOneWidget,
      );
      expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      await PaymentService.syncCanonicalEntitlementForProductV1(
        PaymentService.productPremiumPack,
      );

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await _pumpUntil(
        tester,
        findCanonicalDirectSessionSurfaceV1(),
        maxTicks: 220,
      );
      expectCanonicalDirectSessionLaunchV1(tester, 'w5.s01');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today plan allows trial-active entitlement to open premium-target placement deterministically',
    (tester) async {
      await ProgressService.debugReset();
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
        'placement_route_v1':
            '{"schemaVersion":1,"bucket":"beginner","startTargetSessionId":"w5.s01","repairSessionId":null,"reasonCodes":["target_w5.s01"]}',
        'placement_route_progress_v1':
            '{"schemaVersion":1,"repairPending":false,"targetPending":true}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      await _pumpUntil(tester, find.byKey(const Key('today_plan_start_cta')));
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await _pumpUntil(
        tester,
        findCanonicalDirectSessionSurfaceV1(),
        maxTicks: 220,
      );
      expectCanonicalDirectSessionLaunchV1(tester, 'w5.s01');
      expect(
        find.byKey(const Key('today_plan_premium_preview_title_v1')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'today completed state deterministically flips primary CTA to practice after gauntlet completion and no leaks',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      Future<void> pumpToday() async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UniversalIntakePlanScreen(
              debugUtcDayKeyOverrideV1: '2026-01-01',
            ),
          ),
        );
        await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      }

      await ProgressService.debugReset();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await pumpToday();
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(find.text('PRACTICE'), findsNothing);
      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 180,
      );
      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await ProgressService.debugReset();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });
      await ProgressService.markGauntletCompletedV1(
        utcDayKey: '2026-01-01',
        cohort: 'beginner',
        gauntletId: 'world1_onramp_playlist_v1',
      );

      await pumpToday();
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(find.text('PRACTICE'), findsOneWidget);

      await tester.tap(find.byKey(const Key('today_plan_start_cta')));
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(UiV2ProgressMapScreenV2),
        maxTicks: 180,
      );
      expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpToday();
      expect(find.text('PRACTICE'), findsOneWidget);
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
    },
  );

  testWidgets(
    'high tier long-press confirm applies deterministic no-hints config to today launch',
    (tester) async {
      final highConfig = masteryTierConfigForSessionV1(
        sessionId: 'w0.s01',
        progressForWorld: const MasteryProgressV1(
          worldId: 'world0',
          totalSessions: 1,
          completedSessions: 1,
          rollingAccuracy: 1.0,
        ),
      );
      expect(highConfig.hintsOff, isTrue);
      expect(highConfig.lives, 1);
      expect(highConfig.timerHintMs, 8000);
      expect(highConfig.tierConfigVersion, 1);

      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UniversalIntakePlanScreen(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));

      final start = find.byKey(const Key('today_plan_start_cta'));
      expect(start, findsOneWidget);
      await tester.longPress(start);
      await tester.pumpAndSettle();
      expect(find.text('Enable High Tier?'), findsOneWidget);
      await tester.tap(find.text('Enable'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(start, warnIfMissed: false);
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );

      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.hintsEnabledV1, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('campaign map in-progress seed renders current shell', (
    tester,
  ) async {
    final events = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(<String, dynamic>{'name': name, 'payload': payload});
    });
    try {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
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
      final expectedPackId = await ProgressService.getNextSpinePackToRunV1();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      expect(find.byKey(const Key('map_shell_v1')), findsOneWidget);
      expect(expectedPackId.trim().isNotEmpty, isTrue);
      final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
      if (nextPackCta.evaluate().isNotEmpty) {
        await tester.tap(nextPackCta, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
        final startEvents = events
            .where(
              (event) =>
                  event['name'] == TelemetryEvents.campaignPackStart &&
                  (event['payload'] as Map?)?['pack_id'] == expectedPackId,
            )
            .length;
        expect(startEvents, greaterThanOrEqualTo(1));
      }
      expect(tester.takeException(), isNull);
    } finally {
      Telemetry.overrideLogHandler(null);
    }
  });

  testWidgets('campaign map renders across viewport sizes', (tester) async {
    final events = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(<String, dynamic>{'name': name, 'payload': payload});
    });
    try {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': false,
        'world6_calibration_completed_v1': false,
        'world7_calibration_completed_v1': false,
        'world8_calibration_completed_v1': false,
        'world9_calibration_completed_v1': false,
        'world10_calibration_completed_v1': false,
      });
      final expectedPackId = await ProgressService.getNextSpinePackToRunV1();

      const viewports = <Size>[Size(800, 600), Size(900, 700)];
      var sawNextPackCta = false;
      for (final size in viewports) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UiV2ProgressMapScreenV2(),
          ),
        );
        await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
        await _pumpUntil(
          tester,
          find.byKey(const Key('world_campaign_next_pack_cta')),
        );
        expect(find.byKey(const Key('map_shell_v1')), findsOneWidget);

        final nextPackCta = find.byKey(
          const Key('world_campaign_next_pack_cta'),
        );
        if (nextPackCta.evaluate().isNotEmpty) {
          sawNextPackCta = true;
          await tester.ensureVisible(nextPackCta);
          await tester.tap(nextPackCta, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
          if (find.byType(Scaffold).evaluate().isNotEmpty) {
            Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
            await tester.pump(const Duration(milliseconds: 200));
            await tester.pump(const Duration(milliseconds: 200));
          }
        }

        expect(tester.takeException(), isNull);
      }

      final starts = events
          .where(
            (event) =>
                event['name'] == TelemetryEvents.campaignPackStart &&
                (event['payload'] as Map?)?['pack_id'] == expectedPackId,
          )
          .length;
      if (sawNextPackCta) {
        expect(starts, greaterThanOrEqualTo(1));
      } else {
        expect(starts, 0);
      }
    } finally {
      Telemetry.overrideLogHandler(null);
    }
  });

  testWidgets('today plan bust panel uses backer deterministically', (
    tester,
  ) async {
    final events = <Map<String, dynamic>>[];
    Telemetry.overrideLogHandler((name, payload) async {
      events.add(<String, dynamic>{'name': name, 'payload': payload});
    });
    try {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'campaign_bankroll_balance_v1': 0,
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UniversalIntakePlanScreen(),
        ),
      );

      await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
      await _pumpUntil(
        tester,
        find.byKey(const Key('world_campaign_rank_value')),
      );
      expect(
        find.byKey(const Key('world_campaign_rank_value')),
        findsOneWidget,
      );
      await _pumpUntil(
        tester,
        find.byKey(const Key('world_campaign_bust_panel')),
      );
      expect(
        find.byKey(const Key('world_campaign_bust_panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('world_campaign_bust_reason')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('world_campaign_backer_cta')),
        findsOneWidget,
      );

      final startButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('today_plan_start_cta')),
      );
      expect(startButton.onPressed, isNull);

      await tester.tap(find.byKey(const Key('world_campaign_backer_cta')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await _pumpUntil(
        tester,
        find.byKey(const Key('today_plan_start_cta')),
        maxTicks: 120,
      );

      expect(find.byKey(const Key('world_campaign_bust_panel')), findsNothing);
      final enabledStartButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('today_plan_start_cta')),
      );
      expect(enabledStartButton.onPressed, isNotNull);

      final backerEvents = events
          .where((event) => event['name'] == TelemetryEvents.campaignBackerUsed)
          .length;
      expect(backerEvents, 1);
      expect(tester.takeException(), isNull);
    } finally {
      Telemetry.overrideLogHandler(null);
    }
  });

  testWidgets('campaign rank label increases with seeded progression', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UniversalIntakePlanScreen(key: ValueKey('early_plan')),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
    await _pumpUntil(
      tester,
      find.byKey(const Key('world_campaign_rank_value')),
    );
    final earlyRank =
        (tester
                    .widget<Text>(
                      find.byKey(const Key('world_campaign_rank_value')),
                    )
                    .data ??
                '')
            .trim();
    expect(earlyRank.isNotEmpty, isTrue);
    expect(earlyRank, equals('Fish'));
    expect(find.byKey(const Key('world_campaign_rank_hint')), findsOneWidget);
    final earlyHint =
        (tester
                    .widget<Text>(
                      find.byKey(const Key('world_campaign_rank_hint')),
                    )
                    .data ??
                '')
            .trim();
    expect(earlyHint, contains('Next: Minnow'));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'spine_campaign_completed_packs_v1',
      'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2',
    );
    await prefs.setBool('spine_calibration_completed_v1', true);
    await prefs.setInt('spine_calibration_band_v1', 2);
    await prefs.setBool('world2_calibration_completed_v1', true);
    await prefs.setBool('world3_calibration_completed_v1', true);
    await prefs.setString('spine_campaign_active_pack_id_v1', '');
    await prefs.setInt('spine_campaign_next_hand_index_v1', 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UniversalIntakePlanScreen(key: ValueKey('late_plan')),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
    await _pumpUntil(
      tester,
      find.byKey(const Key('world_campaign_rank_value')),
    );
    final lateRank =
        (tester
                    .widget<Text>(
                      find.byKey(const Key('world_campaign_rank_value')),
                    )
                    .data ??
                '')
            .trim();
    expect(lateRank.isNotEmpty, isTrue);
    expect(lateRank, equals('Angler'));
    final lateHint =
        (tester
                    .widget<Text>(
                      find.byKey(const Key('world_campaign_rank_hint')),
                    )
                    .data ??
                '')
            .trim();
    expect(lateHint, contains('Next: Regular'));

    await prefs.setString(
      'spine_campaign_completed_packs_v1',
      'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b2,world3_spine_campaign_v1,world3_spine_followup_v1_b2,world4_spine_campaign_v1,world4_spine_followup_v1_b2,world5_spine_campaign_v1,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2,world7_spine_campaign_v1,world7_spine_followup_v1_b2,world8_spine_campaign_v1,world8_spine_followup_v1_b2,world9_spine_campaign_v1,world9_spine_followup_v1_b2,world10_spine_campaign_v1,world10_spine_followup_v1_b2',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UniversalIntakePlanScreen(key: ValueKey('max_plan')),
      ),
    );
    await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
    await _pumpUntil(
      tester,
      find.byKey(const Key('world_campaign_rank_value')),
    );
    final maxRank =
        (tester
                    .widget<Text>(
                      find.byKey(const Key('world_campaign_rank_value')),
                    )
                    .data ??
                '')
            .trim();
    expect(maxRank, equals('Shark'));
    expect(find.byKey(const Key('world_campaign_rank_hint')), findsNothing);
  });

  testWidgets(
    'map review strip uses REVIEW when review is available but not required',
    (tester) async {
      final labels = mapReviewQueueStripLabelsV1(reviewRequired: false);

      expect(labels.title, 'REVIEW');
      expect(
        labels.value,
        'Quick review: refresh missed spots before the next lesson.',
      );
      expect(labels.cta, 'REVIEW');
    },
  );

  testWidgets(
    'early-arc map review strip explains the quick-review beat before world2 continues',
    (tester) async {
      final labels = mapReviewQueueStripLabelsV1(
        reviewRequired: false,
        normalizedNextPackId: 'world2_spine_campaign_v1',
      );

      expect(labels.title, 'REVIEW');
      expect(
        labels.value,
        'Quick review: refresh the World 1 foundations before the next World 2 session.',
      );
      expect(labels.cta, 'REVIEW');
    },
  );

  testWidgets(
    'checkpoint pending map strip stays hidden when no modern review queue target exists',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('onboardingCompleted', true);
      await prefs.setBool('intake_completed_v1', true);
      await prefs.setString(
        'spine_campaign_active_pack_id_v1',
        'world1_spine_campaign_v1',
      );
      await prefs.setInt('spine_campaign_next_hand_index_v1', 1);
      await prefs.setString(
        'spine_campaign_completed_packs_v1',
        'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
      );
      await prefs.setBool('spine_calibration_completed_v1', true);
      await prefs.setInt('spine_calibration_band_v1', 2);
      await prefs.setBool('checkpoint_pending_v1', true);
      final checkpointBefore =
          await ProgressService.getCheckpointProgressStateV1();
      expect(checkpointBefore.checkpointPending, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));
      final checkpointStripFinder = find.byKey(
        const Key('map_checkpoint_pending_strip'),
        skipOffstage: false,
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(checkpointStripFinder, findsNothing);
      expect(find.text('Review required.'), findsNothing);
    },
  );

  testWidgets(
    'checkpoint pending map strip routes to review queue when next-pack queue exists',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('onboardingCompleted', true);
      await prefs.setBool('intake_completed_v1', true);
      await prefs.setString('spine_campaign_active_pack_id_v1', '');
      await prefs.setInt('spine_campaign_next_hand_index_v1', 0);
      await prefs.setString(
        'spine_campaign_completed_packs_v1',
        'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      );
      await prefs.setBool('spine_calibration_completed_v1', true);
      await prefs.setInt('spine_calibration_band_v1', 2);
      await prefs.setBool('checkpoint_pending_v1', true);
      await prefs.setString(
        'review_queue_v1::world1_spine_campaign_v1',
        '[{"packId":"world1_spine_campaign_v1","stepIndex":1}]',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));
      final checkpointStripFinder = find.byKey(
        const Key('map_checkpoint_pending_strip'),
        skipOffstage: false,
      );
      final checkpointCtaFinder = find.byKey(
        const Key('checkpoint_entry_cta_v1'),
        skipOffstage: false,
      );
      await _pumpUntil(tester, checkpointStripFinder, maxTicks: 240);

      expect(checkpointStripFinder, findsOneWidget);
      expect(find.text('Review required.'), findsOneWidget);
      expect(find.text('REVIEW'), findsOneWidget);
      await tester.ensureVisible(checkpointCtaFinder.first);
      await tester.tap(checkpointCtaFinder.first, warnIfMissed: false);
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        maxTicks: 160,
      );

      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.mode, kWorld1RunnerModeReviewQueue);
      expect(runner.moduleId, 'world1_spine_campaign_v1');
    },
  );

  testWidgets(
    'campaign map next-pack CTA uses continue semantics when resuming active pack',
    (tester) async {
      expect(
        mapNextPackCtaLabelV1(
          reviewRequired: false,
          nextPackId: 'world1_spine_campaign_v1',
          activePackId: 'world1_spine_campaign_v1',
          nextHandIndex: 1,
        ),
        'CONTINUE CAMPAIGN',
      );
    },
  );

  testWidgets(
    'campaign map next-pack CTA exposes session-world route semantics',
    (tester) async {
      expect(
        mapNextPackCtaLabelV1(
          reviewRequired: false,
          nextPackId: 'world6_spine_campaign_v1',
          activePackId: '',
          nextHandIndex: 0,
        ),
        'OPEN WORLD 6',
      );
      expect(
        mapNextPackCtaSemanticsLabelV1(
          reviewRequired: false,
          nextPackId: 'world6_spine_campaign_v1',
          activePackId: '',
          nextHandIndex: 0,
        ),
        'Open World 6 session route',
      );
      expect(
        todayPlanRoutingReasonLineV1(
          normalizedNextPackId: 'world6_spine_campaign_v1',
          reviewDueForNextPack: false,
          mapRhythmReason: '',
        ),
        'Why: Your next learning route is World 6 sessions.',
      );
    },
  );

  testWidgets(
    'checkpoint pending strip is hidden when checkpoint is not pending',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('onboardingCompleted', true);
      await prefs.setBool('intake_completed_v1', true);
      await prefs.setString(
        'spine_campaign_active_pack_id_v1',
        'world1_spine_campaign_v1',
      );
      await prefs.setInt('spine_campaign_next_hand_index_v1', 1);
      await prefs.setString(
        'spine_campaign_completed_packs_v1',
        'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
      );
      await prefs.setBool('spine_calibration_completed_v1', true);
      await prefs.setInt('spine_calibration_band_v1', 2);
      await prefs.setBool('checkpoint_pending_v1', false);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      );
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));

      expect(
        find.byKey(
          const Key('map_checkpoint_pending_strip'),
          skipOffstage: false,
        ),
        findsNothing,
      );
      expect(
        find.byKey(const Key('checkpoint_entry_cta_v1'), skipOffstage: false),
        findsNothing,
      );
    },
  );

  testWidgets(
    'today plan emits monetization surface telemetry events for impression preview and trial cta',
    (tester) async {
      final events = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        events.add(<String, dynamic>{'name': name, 'payload': payload});
      });
      try {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'onboardingCompleted': true,
          'intake_completed_v1': true,
          'trial_placement_completed_v1': true,
          'trial_status_day_key_v1': -1,
          'premium_is_active': false,
          'spine_campaign_active_pack_id_v1': '',
          'spine_campaign_next_hand_index_v1': 0,
          'spine_campaign_completed_packs_v1': '',
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UniversalIntakePlanScreen(),
          ),
        );

        await _pumpUntil(tester, find.byKey(const Key('today_plan_screen')));
        await _pumpUntil(
          tester,
          find.byKey(const Key('today_plan_trial_start_cta_v1')),
        );
        await _pumpUntil(
          tester,
          find.byKey(const Key('today_plan_premium_preview_cta_v1')),
        );

        await tester.tap(
          find.byKey(const Key('today_plan_premium_preview_cta_v1')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        final previewEvents = events
            .where((event) => event['name'] == 'premium_preview_opened_v1')
            .toList(growable: false);
        expect(previewEvents, isNotEmpty);
        final previewPayload = Map<String, dynamic>.from(
          previewEvents.last['payload'] as Map,
        );
        expect(previewPayload.containsKey('schemaVersion'), isTrue);
        expect(previewPayload.containsKey('status'), isTrue);

        final closePreview = find.byTooltip('Close');
        if (closePreview.evaluate().isNotEmpty) {
          await tester.tap(closePreview, warnIfMissed: false);
        } else {
          Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
        }
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('trial_status_day_key_v1', -1);

        await tester.tap(
          find.byKey(const Key('today_plan_trial_start_cta_v1')),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 300));

        final impressionEvents = events
            .where((event) => event['name'] == 'premium_surface_impression_v1')
            .toList(growable: false);
        expect(impressionEvents, isNotEmpty);
        final impressionPayload = Map<String, dynamic>.from(
          impressionEvents.last['payload'] as Map,
        );
        expect(impressionPayload.containsKey('schemaVersion'), isTrue);
        expect(impressionPayload.containsKey('status'), isTrue);
        expect(impressionPayload.containsKey('remainingDays'), isTrue);

        final trialClickEvents = events
            .where((event) => event['name'] == 'trial_cta_clicked_v1')
            .toList(growable: false);
        expect(trialClickEvents, isNotEmpty);
        final trialClickPayload = Map<String, dynamic>.from(
          trialClickEvents.last['payload'] as Map,
        );
        expect(trialClickPayload.containsKey('schemaVersion'), isTrue);
        expect(trialClickPayload.containsKey('eligible'), isTrue);
        expect(trialClickPayload.containsKey('reason'), isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        Telemetry.overrideLogHandler(null);
      }
    },
  );
}

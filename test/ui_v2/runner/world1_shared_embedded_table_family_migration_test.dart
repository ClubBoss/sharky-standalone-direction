import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 80),
  int maxTicks = 120,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for ${finder.description}');
}

Future<void> _dismissIntroChromeV1(WidgetTester tester) async {
  for (var i = 0; i < 24; i++) {
    final preludeContinue = find.byKey(
      const Key('microtask_prelude_continue_cta_v1'),
    );
    if (preludeContinue.evaluate().isNotEmpty) {
      await tester.tap(preludeContinue.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    final introContinue = find.byKey(
      const Key('microtask_intro_continue_cta_v1'),
    );
    if (introContinue.evaluate().isNotEmpty) {
      await tester.tap(introContinue.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
      continue;
    }
    break;
  }
}

Future<void> _advanceToCampaignActionBarV1(WidgetTester tester) async {
  final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
  final seatFallbacks = <Finder>[
    find.byKey(const Key('microtask_seat_btn')),
    find.byKey(const Key('microtask_seat_sb')),
    find.byKey(const Key('microtask_seat_bb')),
    find.byKey(const Key('microtask_seat_utg')),
    find.byKey(const Key('microtask_seat_hj')),
    find.byKey(const Key('microtask_seat_co')),
  ];

  Future<bool> tapIfEnabled(Key key) async {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) return false;
    final widget = tester.widget<Widget>(finder.first);
    final enabled = switch (widget) {
      ElevatedButton button => button.onPressed != null,
      FilledButton button => button.onPressed != null,
      OutlinedButton button => button.onPressed != null,
      TextButton button => button.onPressed != null,
      _ => true,
    };
    if (!enabled) return false;
    await tester.tap(finder.first, warnIfMissed: false);
    await tester.pump();
    return true;
  }

  Finder? seatFromPrompt() {
    final promptFinder = find.byKey(const Key('microtask_step_prompt'));
    if (promptFinder.evaluate().isEmpty) return null;
    final widget = tester.widget<Widget>(promptFinder.first);
    if (widget is! Text) return null;
    final text = (widget.data ?? '').toLowerCase();
    if (text.contains('button')) {
      return find.byKey(const Key('microtask_seat_btn'));
    }
    if (text.contains('small blind')) {
      return find.byKey(const Key('microtask_seat_sb'));
    }
    if (text.contains('big blind')) {
      return find.byKey(const Key('microtask_seat_bb'));
    }
    if (text.contains('hijack')) {
      return find.byKey(const Key('microtask_seat_hj'));
    }
    if (text.contains('cutoff') || text.contains('cut off')) {
      return find.byKey(const Key('microtask_seat_co'));
    }
    if (text.contains('utg')) {
      return find.byKey(const Key('microtask_seat_utg'));
    }
    return null;
  }

  for (var i = 0; i < 260; i++) {
    if (actionBar.evaluate().isNotEmpty) return;
    await _dismissIntroChromeV1(tester);
    if (await tapIfEnabled(const Key('microtask_continue_cta'))) {
      continue;
    }
    final seatFinder =
        seatFromPrompt() ?? seatFallbacks[i % seatFallbacks.length];
    if (seatFinder.evaluate().isNotEmpty) {
      await tester.tap(seatFinder.first, warnIfMissed: false);
      await tester.pump();
    }
    await tapIfEnabled(const Key('microtask_check_cta'));
    await tester.pump(const Duration(milliseconds: 60));
  }
  fail('Unable to reach campaign action bar deterministically.');
}

Future<void> _ensureCampaignActionBarVisibleV1(WidgetTester tester) async {
  final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 80));
    if (actionBar.evaluate().isNotEmpty) {
      return;
    }
  }
  await _advanceToCampaignActionBarV1(tester);
}

Future<void> _waitForStableSharedTableV1(WidgetTester tester) async {
  await _pumpUntil(tester, find.byType(ModernTableScreenV1), maxTicks: 180);
  await _pumpUntil(
    tester,
    find.byKey(const Key('modern_table_scene')),
    maxTicks: 180,
  );
  await tester.pump(const Duration(milliseconds: 240));
}

int _firstActionableStepIndexV1(String packId) {
  final pack = kCampaignPacksV1[packId];
  expect(pack, isNotNull, reason: 'Missing pack=$packId');
  final steps = pack!;
  for (var i = 0; i < steps.length; i++) {
    final step = steps[i];
    if ((step.allowedActions?.isNotEmpty ?? false) ||
        world1SpineExpectedActionKindV1(step) != null) {
      return i;
    }
  }
  fail('No actionable step found for $packId');
}

Future<void> _pumpWorld1SurfaceV1(
  WidgetTester tester, {
  required String moduleId,
  required String mode,
  int? startHandIndex,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  SharedPreferences.setMockInitialValues(<String, Object>{
    'app_settings_engine_v2_backend_enabled_v1': true,
    'app_settings_checkpoint_mode_override_v1': true,
    'global_training_intro_seen_v1': true,
    'world1_intro_seen_v1': true,
    'world1_action_intro_seen_v1': true,
    'world1_street_flow_intro_seen_v1': true,
  });
  await tester.pumpWidget(
    MaterialApp(
      home: World1FoundationsMicroTaskRunnerScreen(
        moduleId: moduleId,
        moduleTitle: 'World 1',
        mode: mode,
        startHandIndex: startHandIndex,
      ),
    ),
  );
  await tester.pump();
  await _dismissIntroChromeV1(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDisableRunnerMicroAnimationsV1 = true;
    debugDisableRunnerSessionStartEmotionHooksV1 = true;
  });

  tearDown(() {
    debugDisableRunnerMicroAnimationsV1 = false;
    debugDisableRunnerSessionStartEmotionHooksV1 = false;
  });

  test(
    'compatible World1 seat-quiz families resolve to shared embedded route',
    () {
      expect(
        resolveWorld1EmbeddedTableRouteV1(
          handLoopVisualMode: false,
          seatQuizVisualMode: true,
          isCampaignSpineSession: false,
          isReviewQueueSession: false,
          isTablePracticeSession: true,
          isDailyRunSession: false,
          showSeatQuizPrelude: false,
          showIntroSequence: false,
          showLegacyOverlaySurface: false,
          showConceptPreludeCard: false,
          showActionLiteracyPreludeCard: false,
          showStreetFlowPreludeCard: false,
        ),
        World1EmbeddedTableRouteV1.sharedEmbedded,
      );
      expect(
        resolveWorld1EmbeddedTableRouteV1(
          handLoopVisualMode: false,
          seatQuizVisualMode: true,
          isCampaignSpineSession: false,
          isReviewQueueSession: false,
          isTablePracticeSession: false,
          isDailyRunSession: true,
          showSeatQuizPrelude: false,
          showIntroSequence: false,
          showLegacyOverlaySurface: false,
          showConceptPreludeCard: false,
          showActionLiteracyPreludeCard: false,
          showStreetFlowPreludeCard: false,
        ),
        World1EmbeddedTableRouteV1.sharedEmbedded,
      );
      expect(
        resolveWorld1EmbeddedTableRouteV1(
          handLoopVisualMode: false,
          seatQuizVisualMode: true,
          isCampaignSpineSession: true,
          isReviewQueueSession: false,
          isTablePracticeSession: false,
          isDailyRunSession: false,
          showSeatQuizPrelude: true,
          showIntroSequence: false,
          showLegacyOverlaySurface: false,
          showConceptPreludeCard: false,
          showActionLiteracyPreludeCard: false,
          showStreetFlowPreludeCard: false,
        ),
        World1EmbeddedTableRouteV1.localLegacy,
      );
    },
  );

  test('world1 spine campaign contains no seat-quiz compatible beats', () {
    final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
    expect(pack, isNotNull);
    final steps = pack!;
    final seatQuizIndexes = <int>[];
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final isSeatQuizCompatible =
          (step.allowedActions?.isEmpty ?? true) &&
          world1SpineExpectedActionKindV1(step) == null;
      if (isSeatQuizCompatible) {
        seatQuizIndexes.add(i);
      }
    }
    expect(seatQuizIndexes, isEmpty);
  });

  testWidgets(
    'compatible World1 seat-quiz surfaces use shared embedded table instead of local stadium shell',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const representativeCases =
          <({String moduleId, String mode, int? startHandIndex})>[
            (
              moduleId: 'world1_act0_table_literacy',
              mode: kWorld1RunnerModeTablePractice,
              startHandIndex: null,
            ),
            (
              moduleId: 'world1_act0_table_literacy',
              mode: kWorld1RunnerModeDailyRun,
              startHandIndex: null,
            ),
            (
              moduleId: 'world1_spine_campaign_v1',
              mode: kWorld1RunnerModeCampaignSpine,
              startHandIndex: 0,
            ),
          ];

      for (final testCase in representativeCases) {
        await _pumpWorld1SurfaceV1(
          tester,
          moduleId: testCase.moduleId,
          mode: testCase.mode,
          startHandIndex: testCase.startHandIndex,
        );
        await _pumpUntil(
          tester,
          find.byType(ModernTableScreenV1),
          maxTicks: 180,
        );
        expect(
          find.byType(ModernTableScreenV1),
          findsOneWidget,
          reason:
              '${testCase.moduleId}/${testCase.mode} should use the shared embedded table.',
        );
        expect(
          find.byKey(const Key('microtask_table_stadium_shell_v1')),
          findsNothing,
          reason:
              '${testCase.moduleId}/${testCase.mode} should no longer fall through the old local table family.',
        );
        expect(find.byKey(const Key('modern_table_scene')), findsOneWidget);
      }
    },
  );

  testWidgets(
    'world1 compatible family migration renders normalized shared table screenshots',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final actionLiteracyIndex = _firstActionableStepIndexV1(
        'world1_act0_action_literacy',
      );
      final spineActionIndex = _firstActionableStepIndexV1(
        'world1_spine_campaign_v1',
      );
      final followupActionIndex = _firstActionableStepIndexV1(
        'world1_spine_followup_v1_b0',
      );

      await _pumpWorld1SurfaceV1(
        tester,
        moduleId: 'world1_act0_table_literacy',
        mode: kWorld1RunnerModeTablePractice,
      );
      await _waitForStableSharedTableV1(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/world1_act0_table_literacy_shared_family.png',
        ),
      );

      await _pumpWorld1SurfaceV1(
        tester,
        moduleId: 'world1_act0_action_literacy',
        mode: kWorld1RunnerModeCampaignSpine,
        startHandIndex: actionLiteracyIndex,
      );
      await _waitForStableSharedTableV1(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/world1_act0_action_literacy_shared_family.png',
        ),
      );

      await _pumpWorld1SurfaceV1(
        tester,
        moduleId: 'world1_spine_campaign_v1',
        mode: kWorld1RunnerModeCampaignSpine,
        startHandIndex: spineActionIndex,
      );
      await _waitForStableSharedTableV1(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/world1_spine_campaign_shared_family.png'),
      );

      await _pumpWorld1SurfaceV1(
        tester,
        moduleId: 'world1_spine_followup_v1_b0',
        mode: kWorld1RunnerModeCampaignSpine,
        startHandIndex: followupActionIndex,
      );
      await _waitForStableSharedTableV1(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/world1_spine_followup_b0_shared_family.png'),
      );
    },
  );
}

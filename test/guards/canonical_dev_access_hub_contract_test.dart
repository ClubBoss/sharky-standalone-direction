import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/module_launcher_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dev hub world1 entries use canonical production order', () {
    final worlds = debugCanonicalDevHubWorldEntriesV1();
    final world1 = worlds.firstWhere((entry) => entry.world == 1);

    expect(
      world1.nodes.map((node) => node.packId).toList(growable: false),
      equals(kWorld1CanonicalModuleOrder),
    );
    expect(world1.nodes.first.nodeTitle, 'Table Basics');
    expect(
      world1.nodes.first.status,
      CanonicalTruthStatusV1.productionLiveModernized,
    );
    expect(
      world1.nodes[1].status,
      CanonicalTruthStatusV1.productionLiveModernized,
    );
    expect(
      world1.nodes[2].status,
      CanonicalTruthStatusV1.productionLiveModernized,
    );
    expect(world1.nodes.first.modeFamily, 'seat_quiz');
    expect(
      world1.nodes.first.skeletonReadiness,
      CanonicalTruthSkeletonReadinessV1.representedReady,
    );
  });

  testWidgets('dev hub launches real campaign runner target for first node', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ModuleLauncherScreen()));
    await tester.pumpAndSettle();

    final hubTile = find.byKey(const Key('canonical_dev_hub_entry_tile_v1'));
    await tester.ensureVisible(hubTile);
    await tester.tap(hubTile, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('canonical_dev_hub_step_target_input_v1')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('canonical_dev_hub_step_target_input_v1')),
      '2',
    );
    await tester.pump();

    final firstNodeKey = Key(
      'canonical_dev_hub_launch_${kWorld1CanonicalModuleOrder.first}_v1',
    );
    expect(find.byKey(firstNodeKey), findsOneWidget);

    await tester.ensureVisible(find.byKey(firstNodeKey));
    await tester.tap(find.byKey(firstNodeKey), warnIfMissed: false);
    await tester.pumpAndSettle();

    final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
      find.byType(World1FoundationsMicroTaskRunnerScreen),
    );
    expect(runner.moduleId, kWorld1CanonicalModuleOrder.first);
    expect(runner.mode, kWorld1RunnerModeCampaignSpine);
    expect(runner.startHandIndex, 2);
  });

  testWidgets(
    'dev hub state console shows truth-map-backed status and summary',
    (tester) async {
      final truthWorld1 = canonicalTruthWorldEntriesV1().firstWhere(
        (entry) => entry.world == 1,
      );

      await tester.pumpWidget(const MaterialApp(home: ModuleLauncherScreen()));
      await tester.pumpAndSettle();

      final hubTile = find.byKey(const Key('canonical_dev_hub_entry_tile_v1'));
      await tester.ensureVisible(hubTile);
      await tester.tap(hubTile, warnIfMissed: false);
      await tester.pumpAndSettle();

      final world1Summary = find.byKey(
        const Key('canonical_dev_hub_world_summary_1_v1'),
        skipOffstage: false,
      );
      expect(world1Summary, findsOneWidget);
      expect(
        tester.widget<Text>(world1Summary).data,
        '4 production_live · 3 production_live_modernized',
      );
      final world1GapSummary = find.byKey(
        const Key('canonical_dev_hub_world_gap_summary_1_v1'),
        skipOffstage: false,
      );
      expect(world1GapSummary, findsOneWidget);
      expect(
        tester.widget<Text>(world1GapSummary).data,
        '${truthWorld1.nodes.length} represented_ready',
      );

      final firstPackId = kWorld1CanonicalModuleOrder.first;
      expect(
        find.byKey(Key('canonical_dev_hub_status_${firstPackId}_v1')),
        findsOneWidget,
      );
      expect(find.text('production_live_modernized'), findsWidgets);
      expect(
        tester
            .widget<Text>(
              find.byKey(Key('canonical_dev_hub_mode_${firstPackId}_v1')),
            )
            .data,
        'seat_quiz',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(Key('canonical_dev_hub_host_${firstPackId}_v1')),
            )
            .data,
        'Campaign Runner',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(Key('canonical_dev_hub_gap_${firstPackId}_v1')),
            )
            .data,
        'represented_ready',
      );
      expect(
        find.descendant(
          of: find.byKey(
            Key(
              'canonical_dev_hub_status_${kWorld1CanonicalModuleOrder[1]}_v1',
            ),
          ),
          matching: find.text('production_live_modernized'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('map debug flow exposes direct canonical dev hub entry', (
    tester,
  ) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('map_dev_hub_button_v1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Canonical Dev Hub'), findsOneWidget);
    expect(
      find.byKey(
        Key('canonical_dev_hub_launch_${kWorld1CanonicalModuleOrder.first}_v1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'dev hub surfaces current playable world2 and world3 sessions and launches session player',
    (tester) async {
      final worlds = debugCanonicalDevHubWorldEntriesV1();
      final world2 = worlds.firstWhere((entry) => entry.world == 2);
      final world3 = worlds.firstWhere((entry) => entry.world == 3);

      expect(world2.nodes.every((node) => node.launchesSessionDrill), isTrue);
      expect(
        world2.nodes.any(
          (node) => node.packId == 'w2.s12' && node.launchesSessionDrill,
        ),
        isTrue,
      );
      expect(
        world3.nodes.any(
          (node) => node.packId == 'w3.s11' && node.launchesSessionDrill,
        ),
        isTrue,
      );
      expect(
        world3.nodes.any(
          (node) => node.packId == 'w3.s12' && node.launchesSessionDrill,
        ),
        isTrue,
      );
      expect(
        world3.nodes.any(
          (node) => node.packId == 'w3.s13' && node.launchesSessionDrill,
        ),
        isTrue,
      );
      expect(
        world3.nodes.any(
          (node) => node.packId == 'w3.s14' && node.launchesSessionDrill,
        ),
        isTrue,
      );

      await tester.pumpWidget(const MaterialApp(home: ModuleLauncherScreen()));
      await tester.pumpAndSettle();

      final hubTile = find.byKey(const Key('canonical_dev_hub_entry_tile_v1'));
      await tester.ensureVisible(hubTile);
      await tester.tap(hubTile, warnIfMissed: false);
      await tester.pumpAndSettle();

      final world2SessionKey = find.byKey(
        const Key('canonical_dev_hub_launch_w2.s01_v1'),
      );
      await tester.scrollUntilVisible(
        world2SessionKey,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(world2SessionKey, findsOneWidget);

      final world2SecondSessionKey = find.byKey(
        const Key('canonical_dev_hub_launch_w2.s02_v1'),
      );
      await tester.scrollUntilVisible(
        world2SecondSessionKey,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(world2SecondSessionKey, findsOneWidget);

      final world3SessionKey = find.byKey(
        const Key('canonical_dev_hub_launch_w3.s11_v1'),
      );
      await tester.scrollUntilVisible(
        world3SessionKey,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(world3SessionKey, findsOneWidget);

      final world3SecondSessionKey = find.byKey(
        const Key('canonical_dev_hub_launch_w3.s12_v1'),
      );
      await tester.scrollUntilVisible(
        world3SecondSessionKey,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(world3SecondSessionKey, findsOneWidget);

      final world3ThirdSessionKey = find.byKey(
        const Key('canonical_dev_hub_launch_w3.s13_v1'),
      );
      await tester.scrollUntilVisible(
        world3ThirdSessionKey,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(world3ThirdSessionKey, findsOneWidget);

      final world3FourthSessionKey = find.byKey(
        const Key('canonical_dev_hub_launch_w3.s14_v1'),
      );
      await tester.scrollUntilVisible(
        world3FourthSessionKey,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(world3FourthSessionKey, findsOneWidget);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 80,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _canonicalReviewTargetPackIdV1() {
  final world1 = canonicalTruthWorldEntriesV1().firstWhere(
    (entry) => entry.world == 1,
  );
  return world1.nodes
      .firstWhere(
        (node) =>
            node.status == CanonicalTruthStatusV1.productionLive &&
            node.modeFamily == CanonicalTruthModeFamilyV1.campaignSpine,
      )
      .packId;
}

Widget _buildMapShellV1() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const UiV2ProgressMapScreenV2(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('legacy rhythm strip stays hidden on canonical map shell', (
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

    await tester.pumpWidget(_buildMapShellV1());
    await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));

    expect(find.byKey(const Key('legacy_path_rhythm_strip_v1')), findsNothing);
  });

  testWidgets(
    'checkpoint pending strip stays hidden when canonical review target has no queue',
    (tester) async {
      final reviewTargetPackId = _canonicalReviewTargetPackIdV1();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('onboardingCompleted', true);
      await prefs.setBool('intake_completed_v1', true);
      await prefs.setString(
        'spine_campaign_active_pack_id_v1',
        reviewTargetPackId,
      );
      await prefs.setInt('spine_campaign_next_hand_index_v1', 1);
      await prefs.setString(
        'spine_campaign_completed_packs_v1',
        'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,'
            '$reviewTargetPackId',
      );
      await prefs.setBool('spine_calibration_completed_v1', true);
      await prefs.setInt('spine_calibration_band_v1', 2);
      await prefs.setBool('checkpoint_pending_v1', true);

      await tester.pumpWidget(_buildMapShellV1());
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.byKey(
          const Key('map_checkpoint_pending_strip'),
          skipOffstage: false,
        ),
        findsNothing,
      );
      expect(find.text('Review required.'), findsNothing);
    },
  );

  testWidgets(
    'checkpoint pending strip routes to canonical review queue target instead of legacy checkpoint fallback',
    (tester) async {
      final reviewTargetPackId = _canonicalReviewTargetPackIdV1();
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
        'review_queue_v1::$reviewTargetPackId',
        '[{"packId":"$reviewTargetPackId","stepIndex":1}]',
      );

      await tester.pumpWidget(_buildMapShellV1());
      await _pumpUntil(tester, find.byKey(const Key('map_shell_v1')));
      await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));
      await _pumpUntil(
        tester,
        find.byKey(
          const Key('map_checkpoint_pending_strip'),
          skipOffstage: false,
        ),
        maxTicks: 240,
      );

      expect(
        find.byKey(
          const Key('map_checkpoint_pending_strip'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('Review required.'), findsOneWidget);

      final cta = find.byKey(
        const Key('checkpoint_entry_cta_v1'),
        skipOffstage: false,
      );
      await tester.ensureVisible(cta.first);
      await tester.tap(cta.first, warnIfMissed: false);
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
      expect(runner.moduleId, reviewTargetPackId);
      expect(runner.mode, isNot(kWorld1RunnerModeCheckpoint));
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boot release smoke stays non-throwing', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    final planFinder = find.byType(UniversalIntakePlanScreen);
    final mapFinder = find.byType(UiV2ProgressMapScreenV2);
    expect(
      planFinder.evaluate().isNotEmpty || mapFinder.evaluate().isNotEmpty,
      isTrue,
    );

    final primaryCta = find.byKey(const Key('today_plan_start_cta'));
    final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
    if (primaryCta.evaluate().isNotEmpty) {
      await tester.tap(primaryCta.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
    } else if (nextPackCta.evaluate().isNotEmpty) {
      await tester.tap(nextPackCta.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(tester.takeException(), isNull);
  });
}

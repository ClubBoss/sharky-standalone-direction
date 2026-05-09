import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app root lands on map and map tap path does not crash', (
    tester,
  ) async {
    await pumpToMap(tester, seed: seedWorld1CampaignComplete());

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);

    final openWorld1 = find.byKey(const Key('world_campaign_open_1'));
    if (openWorld1.evaluate().isNotEmpty) {
      await tester.tap(openWorld1.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(tester.takeException(), isNull);
  });
}

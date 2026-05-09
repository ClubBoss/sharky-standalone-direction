import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('today chip is stable on ultra-narrow short layout', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await pumpToMap(tester, seed: seedWorld1CampaignComplete());

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    expect(find.byKey(const Key('world1_today_chip_label')), findsOneWidget);
    expect(find.byKey(const Key('world1_today_chip_state')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

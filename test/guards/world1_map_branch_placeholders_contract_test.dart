import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('world1 branch placeholders are visible and non-tappable', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1.0;

    await pumpToMap(tester, seed: seedWorld1CampaignComplete());

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    expect(find.byKey(const Key('world1_foundations_label')), findsOneWidget);

    final cash = find.byKey(const Key('world1_branch_cash_locked'));
    final mtt = find.byKey(const Key('world1_branch_mtt_locked'));
    expect(cash, findsOneWidget);
    expect(mtt, findsOneWidget);
    expect(
      find.byKey(const Key('world1_branch_cash_requirements')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('world1_branch_mtt_requirements')),
      findsOneWidget,
    );

    await tester.tap(cash, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(ModuleSummaryScreen), findsNothing);
    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

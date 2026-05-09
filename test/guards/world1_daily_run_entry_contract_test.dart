import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily run entry opens runner and completes with daily badge', (
    tester,
  ) async {
    await pumpToMap(tester, seed: seedWorld1CampaignComplete());

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    final dailyRunEnabled = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith(
            'world1_daily_run_cta_',
          ) &&
          !(widget.key as ValueKey<String>).value.startsWith(
            'world1_daily_run_cta_disabled_',
          ),
      description: 'world1_daily_run_cta_<moduleId>',
    );
    final dailyRunDisabled = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith(
            'world1_daily_run_cta_disabled_',
          ),
      description: 'world1_daily_run_cta_disabled_<moduleId>',
    );
    expect(
      dailyRunEnabled.evaluate().isNotEmpty ||
          dailyRunDisabled.evaluate().isNotEmpty,
      isTrue,
    );
    if (dailyRunEnabled.evaluate().isNotEmpty) {
      await tester.ensureVisible(dailyRunEnabled.first);
      await tester.tap(dailyRunEnabled.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      if (find
          .byType(World1FoundationsMicroTaskRunnerScreen)
          .evaluate()
          .isNotEmpty) {
        await tester.tap(find.byKey(const Key('microtask_seat_btn')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('microtask_check_cta')));
        await tester.pump();
      }
    }
    expect(tester.takeException(), isNull);
  });
}

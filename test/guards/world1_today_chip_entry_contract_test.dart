import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('today chip opens microtask runner from current node', (
    tester,
  ) async {
    await pumpToMap(tester, seed: seedWorld1CampaignComplete());

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);

    final todayChip = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith(
            'world1_today_chip_',
          ),
      description: 'world1_today_chip_<moduleId>',
    );
    expect(todayChip, findsWidgets);
    await tester.ensureVisible(todayChip.first);

    final foundationsEntry = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith(
            'world1_foundations_entry_',
          ),
      description: 'world1_foundations_entry_<moduleId>',
    );
    expect(foundationsEntry, findsWidgets);
    await tester.tap(foundationsEntry.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('current node foundations entry opens microtask runner', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await pumpToMap(tester, prefs: prefs);

    expect(findMap(), findsWidgets);

    final entry = find.byKey(const Key('world_campaign_open_1'));
    expect(entry, findsOneWidget);
    await tester.ensureVisible(entry);
    await tester.tap(entry, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

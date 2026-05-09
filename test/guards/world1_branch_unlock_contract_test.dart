import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cash and mtt stay locked before foundations completion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await pumpToMap(tester, prefs: prefs);
    for (var i = 0; i < 40; i++) {
      if (find
          .byKey(const Key('world1_branch_cash_locked'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('world1_branch_cash_locked')), findsOneWidget);
    expect(find.byKey(const Key('world1_branch_mtt_locked')), findsOneWidget);
    expect(find.byKey(const Key('world1_branch_cash_unlocked')), findsNothing);
    expect(find.byKey(const Key('world1_branch_mtt_unlocked')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

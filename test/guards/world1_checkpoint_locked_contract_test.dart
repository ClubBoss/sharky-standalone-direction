import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('locked checkpoint shows disabled entry and does not navigate', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await pumpToMap(tester, prefs: prefs);

    expect(findMap(), findsWidgets);
    for (var i = 0; i < 40; i++) {
      if (find
          .byKey(const Key('world1_checkpoint_open_disabled_3'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    final disabled3 = find.byKey(
      const Key('world1_checkpoint_open_disabled_3'),
    );
    final disabled6 = find.byKey(
      const Key('world1_checkpoint_open_disabled_6'),
    );
    expect(disabled3, findsOneWidget);
    expect(disabled6, findsOneWidget);

    await tester.tap(disabled3, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('checkpoint_runner')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

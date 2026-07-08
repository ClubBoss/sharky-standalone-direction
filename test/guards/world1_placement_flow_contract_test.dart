import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'first-open route starts in active Act0 placement without legacy intake ids',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(const AppRoot());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 280));

      expect(
        find.byKey(const Key('act0_shell_placement_screen')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_placement_intro_cta')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('intake_runner')), findsNothing);
      expect(find.byKey(const Key('today_plan_screen')), findsNothing);
      expect(find.textContaining('world1_act0_table_literacy'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('foundations check CTA is visible for packed world1 module', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ModuleSummaryScreen(
          moduleData: <String, dynamic>{
            'id': kWorld1CanonicalModuleOrder.first,
            'title': 'Welcome to Poker',
            'description': 'Why poker is a game of skill.',
            'tier': 'Free',
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('module_summary_foundations_check_cta')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('foundations check CTA is hidden for unpacked module', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ModuleSummaryScreen(
          moduleData: <String, dynamic>{
            'id': 'non_world1_module',
            'title': 'Custom module',
            'description': 'Custom flow.',
            'tier': 'Free',
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('module_summary_foundations_check_cta')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

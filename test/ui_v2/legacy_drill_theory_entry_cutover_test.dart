import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'non-world1 theory practice enters through canonical legacy drill adapter',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheorySessionScreen(
            moduleId: 'non_world1_module',
            moduleTitle: 'Legacy Drill Module',
            debugTheoryMarkdownOverrideV1: '# Test theory',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('theory_start_practice_cta')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(LegacyDrillCanonicalHostAdapterV1), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

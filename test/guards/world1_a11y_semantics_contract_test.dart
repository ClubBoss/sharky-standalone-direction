import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'world1 semantics stay stable across summary/theory ownership seam',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: ModuleSummaryScreen(
              moduleData: <String, dynamic>{
                'id': kWorld1CanonicalModuleOrder.first,
                'title': 'Welcome to Poker',
                'description': 'Intro module',
                'tier': 'Free',
                'isAvailable': true,
                'isUnlocked': true,
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('module_summary_next_action_strip')),
          findsNothing,
        );
        final summaryStartTheorySemantics = tester.getSemantics(
          find.byKey(const Key('module_summary_start_theory_cta')),
        );
        expect(summaryStartTheorySemantics.label, contains('START THEORY'));

        await tester.pumpWidget(
          MaterialApp(
            home: TheorySessionScreen(
              moduleId: kWorld1CanonicalModuleOrder.first,
              moduleTitle: 'Welcome to Poker',
            ),
          ),
        );
        await tester.pumpAndSettle();
        final theorySemantics = tester.getSemantics(
          find.byKey(const Key('theory_next_action_strip')),
        );
        expect(theorySemantics.label, contains('Theory next action'));
        expect(theorySemantics.label, contains('Start practice'));
        expect(theorySemantics.hint, contains('double tap start practice'));
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}

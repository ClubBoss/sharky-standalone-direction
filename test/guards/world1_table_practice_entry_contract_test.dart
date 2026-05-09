import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'world1 L1 opens table-native practice runner and stays non-throwing',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        MaterialApp(
          home: TheorySessionScreen(
            moduleId: kWorld1CanonicalModuleOrder.first,
            moduleTitle: 'Welcome to Poker',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(TheorySessionScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('theory_start_practice_cta')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);
      expect(find.byKey(const Key('table_practice_table')), findsOneWidget);

      await tester.tap(find.byKey(const Key('table_practice_seat_btn')));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(find.byKey(const Key('table_practice_check_cta')));
      await tester.pump(const Duration(milliseconds: 240));

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'theory directive markdown override feeds intro coach text into runner',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        MaterialApp(
          home: const TheorySessionScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            debugTheoryMarkdownOverrideV1:
                '@meta v=1 module_id=world1_spine_campaign_v1 world=1 kind=theory_runner title=\"World 1\"\\n'
                '@runner pack_id=world1_spine_campaign_v1\\n'
                '@runner intro=\"OVR_INTRO_MARK_TEST_V1\"\\n'
                '@runner step=\"OVR_STEP_MARK_TEST_V1\"\\n'
                '@runner outcome=\"OVR_OUTCOME_MARK_TEST_V1\"\\n'
                '# Title\\n'
                'FALLBACK_LINE_SHOULD_NOT_WIN\\n'
                '## Practice\\n'
                '- Step: FALLBACK_STEP_SHOULD_NOT_WIN\\n'
                '## Feedback\\n'
                '- feedback: FALLBACK_OUTCOME_SHOULD_NOT_WIN\\n',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byKey(const Key('theory_start_practice_cta')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      final runnerState =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      runnerState.debugForceCoachIntroStateForTestV1();
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('table_practice_runner')), findsOneWidget);
      expect(find.textContaining('OVR_INTRO_MARK_TEST_V1'), findsOneWidget);
      final coachStrip = find.byKey(const Key('microtask_coach_strip_v1'));
      expect(
        find.descendant(
          of: coachStrip,
          matching: find.textContaining('FALLBACK_LINE_SHOULD_NOT_WIN'),
        ),
        findsNothing,
      );
    },
  );
}

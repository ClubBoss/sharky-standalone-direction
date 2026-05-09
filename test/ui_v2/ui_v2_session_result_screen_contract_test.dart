import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/legacy/ui_v2_session_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'legacy ui v2 session result screen keeps detached continue semantics and stays outside canonical session result grammar',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'player_xp_total': 125,
        'player_level': 1,
        'player_achievements': <String>[],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('open_legacy_ui_v2_result_screen'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const UiV2SessionResultScreen(
                            xpGained: 12,
                            chipsEarned: 4,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(
        find.byKey(const Key('open_legacy_ui_v2_result_screen')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session Complete'), findsOneWidget);
      expect(find.text('Session Complete!'), findsOneWidget);
      expect(find.text('XP Gained'), findsOneWidget);
      expect(find.text('+12'), findsOneWidget);
      expect(find.text('Chips Earned'), findsOneWidget);
      expect(find.text('+4'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      expect(find.text('BACK TO MAP'), findsNothing);
      expect(find.text('NEXT LESSON'), findsNothing);
      expect(
        find.byKey(const Key('session_result_back_to_map_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_result_secondary_back_to_map_cta_v1')),
        findsNothing,
      );

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('open_legacy_ui_v2_result_screen')),
        findsOneWidget,
      );
      expect(find.text('Session Complete!'), findsNothing);
    },
  );
}

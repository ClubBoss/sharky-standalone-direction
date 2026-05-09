import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';
import 'package:poker_analyzer/ui_v2/training_pack_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TrainingPackTemplate buildTemplate() {
    return TrainingPackTemplate(
      id: 'pack_v1',
      name: 'Result Boundary Pack',
      spots: <TrainingPackSpot>[
        TrainingPackSpot(id: 'spot_1'),
        TrainingPackSpot(id: 'spot_2'),
      ],
    );
  }

  testWidgets(
    'training pack result screen keeps single back-to-list CTA and stays outside canonical session result shell',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'player_xp_total': 0,
        'player_level': 1,
        'player_achievements': <String>[],
      });

      final template = buildTemplate();

      await tester.pumpWidget(
        MaterialApp(
          home: TrainingPackResultScreenV2(
            template: template,
            original: template,
            results: const <String, String>{'spot_1': 'correct'},
            xpGained: 12,
            chipsEarned: 4,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Result Boundary Pack'), findsOneWidget);
      expect(find.text('Back to List'), findsOneWidget);
      expect(find.text('BACK TO MAP'), findsNothing);
      expect(
        find.byKey(const Key('session_result_back_to_map_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_result_secondary_back_to_map_cta_v1')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'training pack result screen keeps result hierarchy and terminal return semantics while remaining separate from canonical session result CTA grammar',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'player_xp_total': 125,
        'player_level': 1,
        'player_achievements': <String>[],
      });

      final template = buildTemplate();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('open_training_pack_result_v2'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TrainingPackResultScreenV2(
                            template: template,
                            original: template,
                            results: const <String, String>{
                              'spot_1': 'correct',
                              'spot_2': 'fold',
                            },
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

      await tester.tap(find.byKey(const Key('open_training_pack_result_v2')));
      await tester.pumpAndSettle();

      expect(find.text('Result Boundary Pack'), findsOneWidget);
      expect(find.text('Spots: 2 • Answered: 2'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('XP reward: +12 XP'), findsOneWidget);
      expect(find.text('Spot #1'), findsOneWidget);
      expect(find.text('Answer: correct'), findsOneWidget);
      expect(find.text('Spot #2'), findsOneWidget);
      expect(find.text('Answer: fold'), findsOneWidget);

      expect(find.text('Back to List'), findsOneWidget);
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

      await tester.tap(find.text('Back to List'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('open_training_pack_result_v2')),
        findsOneWidget,
      );
      expect(find.text('Result Boundary Pack'), findsNothing);
    },
  );
}

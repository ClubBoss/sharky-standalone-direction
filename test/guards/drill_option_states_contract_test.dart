import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'drill runner exposes stable option/reveal states without crashes',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Who acts last?',
          'options': <String>['Button', 'Big Blind'],
          'answer_index': 0,
          'rationale': 'Button closes the action.',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: kWorld1CanonicalModuleOrder.first,
            debugItemsOverrideV1: items,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final hasQuizOptions = find
          .byKey(const ValueKey<String>('drill_option_0'))
          .evaluate()
          .isNotEmpty;
      final hasReveal = find.text('REVEAL ANSWER').evaluate().isNotEmpty;

      expect(hasQuizOptions || hasReveal, isTrue);
      if (hasQuizOptions) {
        final optionSemantics = tester.getSemantics(
          find.byKey(const ValueKey<String>('drill_option_0')),
        );
        expect(optionSemantics.label, isNotEmpty);
      }
      expect(tester.takeException(), isNull);
    },
  );
}

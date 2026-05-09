import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('theory and drill cohort expose branded loading and progress surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TheorySessionScreen(
          moduleId: 'missing_theory_module',
          moduleTitle: 'Theory Cohesion',
        ),
      ),
    );

    expect(find.byKey(const Key('theory_loading_surface_v1')), findsOneWidget);

    final items = <Map<String, dynamic>>[
      <String, dynamic>{
        'question': 'Who acts last preflop?',
        'options': <String>['Button', 'Big Blind'],
        'answer_index': 0,
        'rationale': 'Button closes the action.',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: DrillRunnerScreen(
          moduleId: 'visual_cohesion_v1',
          debugItemsOverrideV1: items,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('drill_runner_inline_progress_surface_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('drill_runner_inline_progress_bar_v1')),
      findsOneWidget,
    );
    expect(find.text('Step 1 of 1'), findsOneWidget);
  });
}

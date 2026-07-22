import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

void main() {
  const question = Act0PlacementQuestionV1(
    questionId: 'experience',
    title: 'Where are you starting from?',
    subtitle: 'This is not a test. It only sets your pace.',
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'friends',
        label: 'I have played casually',
        score: 0,
        profileTag: 'beginner',
      ),
    ],
  );

  testWidgets('fresh placement keeps one promise and one primary CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0PlacementShellV1(
            questions: const <Act0PlacementQuestionV1>[],
            showIntro: true,
            currentQuestionIndex: 0,
            selectedOptionIds: const <String, Set<String>>{},
            result: null,
            onSelectOption: (_, _) {},
            onStartPlacement: () {},
            onBack: () {},
            onNext: () {},
            onStartDiagnostic: () {},
            onStartRecommended: () {},
            onStartFromZero: () {},
          ),
        ),
      ),
    );

    expect(find.text('No exam. Just your starting point.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_intro_cta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_placement_launch_path')),
      findsNothing,
    );
    expect(find.text('Beginner-safe'), findsNothing);
  });

  testWidgets(
    'placement questions lead with progress and welcome is free of process chips',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: Scaffold(
              body: Act0PlacementShellV1(
                questions: const <Act0PlacementQuestionV1>[question],
                showIntro: false,
                currentQuestionIndex: 0,
                selectedOptionIds: const <String, Set<String>>{},
                result: null,
                onSelectOption: (_, _) {},
                onStartPlacement: () {},
                onBack: () {},
                onNext: () {},
                onStartDiagnostic: () {},
                onStartRecommended: () {},
                onStartFromZero: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('1/1'), findsOneWidget);
      expect(find.text('Where are you starting from?'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_placement_route_check_frame')),
        findsNothing,
      );
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_placement_next_cta')),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        const MaterialApp(
          home: Act0WelcomeShellV1(replayMode: false, onCompleted: _noop),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Try one table read'), findsNWidgets(2));
      expect(find.text('Read'), findsNothing);
      expect(find.text('Answer'), findsNothing);
      expect(find.text('Reason'), findsNothing);
      expect(find.text('Move on'), findsNothing);
    },
  );
}

void _noop() {}

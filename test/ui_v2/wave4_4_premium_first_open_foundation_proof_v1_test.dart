import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('first-open placement starts with premium Sharky brand beat', (
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

    expect(
      find.byKey(const Key('act0_shell_placement_brand_beat')),
      findsOneWidget,
    );
    expect(find.text('Sharky Poker'), findsOneWidget);
    expect(find.text('Read the table from your first hand.'), findsOneWidget);
    expect(find.text('One clue. One decision. One proof.'), findsOneWidget);
    expect(find.text('Your table coach is ready.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_brand_sharky')),
      findsOneWidget,
    );
    expect(find.textContaining('AI'), findsNothing);
    expect(find.textContaining('GTO'), findsNothing);
    expect(find.textContaining('solver'), findsNothing);
    expect(find.textContaining('premium'), findsNothing);
    expect(find.textContaining('trial'), findsNothing);
    expect(find.textContaining('purchase'), findsNothing);
  });

  testWidgets('Learn shows W1-W4 Foundation proof without W5-W36 claims', (
    tester,
  ) async {
    final state = Act0ShellStateV1.sample;
    final world = state.selectedWorld;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LearnPathShellV1(
            moduleTitle: state.courseTitle,
            moduleProgressLabel: state.pathProgressLabel,
            worlds: state.worlds,
            selectedWorldId: world.worldId,
            showWorldMenu: false,
            worldDetailId: null,
            lessons: world.lessons,
            selectedLessonId: state.currentLesson.lessonId,
            selectedTaskId: state.currentLesson.taskList.first.taskId,
            activePopupTaskId: null,
            completedTaskIds: const <String>{},
            perfectTaskIds: const <String>{},
            skippedTaskIds: const <String>{},
            pathClosedTaskIds: const <String>{},
            detailLessonId: null,
            lessonOutcomeLabels: const <String, String>{},
            onSelectWorld: (_) {},
            onOpenWorldMenu: () {},
            onCloseWorldMenu: () {},
            onDismissWorldDetail: () {},
            onPreviewPremiumWorld: (_) {},
            onSelectLesson: (_) => true,
            onOpenLessonAfterScroll: (_) {},
            onDismissDetail: () {},
            onSelectTask: (_, _) {},
            onDismissTaskPopup: () {},
            onStartTask: (_, _) {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_foundation_proof')),
      findsOneWidget,
    );
    expect(find.text('Foundation path'), findsOneWidget);
    expect(
      find.text('World 1-4 build your first table reads.'),
      findsOneWidget,
    );
    expect(find.text('Four worlds. One foundation.'), findsOneWidget);
    expect(find.text('W1 · Table Basics'), findsOneWidget);
    expect(find.text('W2 · Hand Discipline'), findsOneWidget);
    expect(find.text('W3 · Position Thinking'), findsOneWidget);
    expect(find.text('W4 \u00B7 Bet Purpose / Price'), findsOneWidget);
    expect(find.text('The 36-world path starts here.'), findsOneWidget);
    expect(find.textContaining('World 5'), findsNothing);
    expect(find.textContaining('W5'), findsNothing);
    expect(find.textContaining('built'), findsNothing);
    expect(find.textContaining('complete course'), findsNothing);
    expect(find.textContaining('premium'), findsNothing);
    expect(find.textContaining('paywall'), findsNothing);
  });
}

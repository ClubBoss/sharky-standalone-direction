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

  testWidgets('Learn keeps Worlds as the map and centers the current mission', (
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

    expect(find.byKey(const Key('act0_shell_foundation_proof')), findsNothing);
    expect(find.text('Foundation map'), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_levels_menu_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_current_mission_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_current_mission_cta')),
      findsOneWidget,
    );
    expect(find.text('Up next'), findsOneWidget);
    expect(find.text('All lessons'), findsOneWidget);
    expect(find.textContaining('36-world'), findsNothing);
    expect(find.textContaining('36 worlds'), findsNothing);
    expect(find.textContaining('World 5'), findsNothing);
    expect(find.textContaining('W5'), findsNothing);
    expect(find.textContaining('built'), findsNothing);
    expect(find.textContaining('complete course'), findsNothing);
    expect(find.textContaining('premium'), findsNothing);
    expect(find.textContaining('paywall'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets(
    'Worlds on 14 Pro describes actual open and locked worlds without promising 36',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      final state = Act0ShellStateV1.sample;
      final world = state.selectedWorld;
      final openCount = state.worlds.where((world) => !world.isLocked).length;
      final lockedCount = state.worlds.where((world) => world.isLocked).length;
      var closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LearnPathShellV1(
              moduleTitle: state.courseTitle,
              moduleProgressLabel: state.pathProgressLabel,
              worlds: state.worlds,
              selectedWorldId: world.worldId,
              showWorldMenu: true,
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
              onCloseWorldMenu: () {
                closed = true;
              },
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
      await tester.pumpAndSettle();
      expect(openCount, 1);
      expect(lockedCount, greaterThan(0));
      expect(find.byKey(const Key('act0_shell_levels_menu')), findsOneWidget);
      expect(find.text('Your learning map'), findsOneWidget);
      expect(
        find.text('$openCount open · $lockedCount locked'),
        findsOneWidget,
      );
      expect(find.text('3 volumes · 36 worlds'), findsNothing);
      expect(find.textContaining('W1-W6 available'), findsNothing);
      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_close')));
      await tester.pump();
      expect(closed, isTrue);
      expect(tester.takeException(), isNull);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}

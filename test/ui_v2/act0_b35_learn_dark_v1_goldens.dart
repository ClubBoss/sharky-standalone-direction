// Run explicitly. Local PNG baselines live under ignored output/b35_learn/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

enum _LearnState { firstRun, inProgress, worldDone, worldMenu }

void main() {
  final worlds = Act0ShellStateV1.sample.worlds;
  final firstWorld = worlds.firstWhere((world) => world.worldId == 'world_1');
  const capture = Key('b35_learn_capture');
  for (final state in _LearnState.values) {
    for (final (scale, suffix) in [(1.0, '100'), (1.3, '130')]) {
      testWidgets('${state.name} at $scale× text', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(393, 852);
        addTearDown(tester.view.reset);
        final done = state == _LearnState.worldDone;
        final firstLesson = firstWorld.lessons.first;
        final lessons = [
          for (final lesson in firstWorld.lessons)
            lesson.copyWith(
              state: done
                  ? Act0LessonStateV1.completed
                  : lesson == firstLesson
                  ? Act0LessonStateV1.current
                  : Act0LessonStateV1.locked,
              isSelectable: done || lesson == firstLesson,
              isLocked: !done && lesson != firstLesson,
            ),
        ];
        final world = firstWorld.copyWith(
          status: done ? Act0WorldStateV1.completed : Act0WorldStateV1.current,
          progressLabel: done
              ? '${lessons.length} of ${lessons.length} complete'
              : '0 of ${lessons.length} complete',
          lessons: lessons,
        );
        final completed = {
          if (done)
            for (final lesson in lessons)
              for (final task in lesson.courseTaskList) task.taskId,
          if (state == _LearnState.inProgress)
            firstLesson.courseTaskList.first.taskId,
        };
        var showWorldMenu = false;
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.dark(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: RepaintBoundary(
              key: capture,
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => Act0LearnPathShellV1(
                    moduleTitle: world.title,
                    moduleProgressLabel: world.progressLabel,
                    worlds: [
                      world,
                      ...worlds.where(
                        (entry) => entry.worldId != world.worldId,
                      ),
                    ],
                    selectedWorldId: world.worldId,
                    showWorldMenu: showWorldMenu,
                    worldDetailId: null,
                    lessons: lessons,
                    selectedLessonId: firstLesson.lessonId,
                    selectedTaskId: firstLesson.courseTaskList.first.taskId,
                    activePopupTaskId: null,
                    completedTaskIds: completed,
                    perfectTaskIds: completed,
                    skippedTaskIds: const {},
                    pathClosedTaskIds: completed,
                    detailLessonId: null,
                    lessonOutcomeLabels: const {},
                    onSelectWorld: (_) {},
                    onOpenWorldMenu: () => setState(() => showWorldMenu = true),
                    onCloseWorldMenu: () =>
                        setState(() => showWorldMenu = false),
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
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_shell_learn_screen')),
          findsOneWidget,
        );
        if (state == _LearnState.worldMenu) {
          await tester.tap(
            find.byKey(const Key('act0_shell_levels_menu_button')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('act0_shell_levels_menu')),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(capture),
          matchesGoldenFile('../../output/b35_learn/${state.name}_$suffix.png'),
        );
      });
    }
  }
}

// One real Learn world-menu leaf, synthetic public sample curriculum.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  for (final disabled in [false, true]) {
    testWidgets(
      'world node motion disabled=$disabled preserves selectable content',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final worlds = Act0ShellStateV1.sample.worlds;
        final world = worlds.first;
        var selected = world.worldId;
        var selectedCalls = 0;
        var reduceMotion = disabled;
        late StateSetter rebuild;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: reduceMotion),
                  child: Scaffold(
                    body: Act0LearnPathShellV1(
                      moduleTitle: 'Learn',
                      moduleProgressLabel: 'Sample',
                      worlds: worlds,
                      selectedWorldId: selected,
                      showWorldMenu: true,
                      worldDetailId: null,
                      lessons: world.lessons,
                      selectedLessonId: world.lessons.first.lessonId,
                      selectedTaskId: world.lessons.first.taskList.first.taskId,
                      activePopupTaskId: null,
                      completedTaskIds: const {},
                      perfectTaskIds: const {},
                      skippedTaskIds: const {},
                      pathClosedTaskIds: const {},
                      detailLessonId: null,
                      lessonOutcomeLabels: const {},
                      onSelectWorld: (_) {
                        selectedCalls++;
                      },
                      onOpenWorldMenu: () {},
                      onCloseWorldMenu: () {},
                      onDismissWorldDetail: () {},
                      onPreviewPremiumWorld: (_) {},
                      onSelectLesson: (_) => true,
                      onOpenLessonAfterScroll: (_) {},
                      onDismissDetail: () {},
                      onSelectTask: (_, __) {},
                      onDismissTaskPopup: () {},
                      onStartTask: (_, __) {},
                    ),
                  ),
                );
              },
            ),
          ),
        );
        final node = find.byKey(Key('act0_shell_world_${world.worldNumber}'));
        expect(node, findsOneWidget);
        AnimationController controller() {
          final builders = tester.widgetList<AnimatedBuilder>(
            find.ancestor(of: node, matching: find.byType(AnimatedBuilder)),
          );
          return builders
              .map((x) => x.animation)
              .whereType<AnimationController>()
              .singleWhere(
                (c) => c.duration == const Duration(milliseconds: 250),
              );
        }

        final animation = controller();
        expect(animation.isAnimating, !disabled);
        if (disabled) expect(animation.value, 1);
        await tester.pump(const Duration(milliseconds: 80));
        if (!disabled)
          expect(animation.value, inExclusiveRange(0, 1));
        else
          expect(animation.value, 1);
        // The OS setting changes on the same State while motion is in flight.
        rebuild(() => reduceMotion = true);
        await tester.pump();
        expect(controller(), same(animation));
        expect(animation.isAnimating, isFalse);
        expect(animation.value, 1);
        rebuild(() => selected = worlds[1].worldId);
        await tester.pump();
        expect(animation.isAnimating, isFalse);
        expect(animation.value, 1);
        await tester.ensureVisible(node);
        await tester.pumpAndSettle();
        expect(node.hitTestable(), findsOneWidget);
        await tester.tap(node);
        expect(selectedCalls, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

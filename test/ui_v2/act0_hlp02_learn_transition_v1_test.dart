// Bounded source-connected widget probe. Uses the actual Act0 Learn consumer,
// authored task objects, and the production Runner, not a duplicate scoring
// engine or a fabricated answer oracle. Full persisted app E2E remains a gate.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_reference_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

class _LearnRunnerRouteProbe extends StatefulWidget {
  const _LearnRunnerRouteProbe({super.key});

  @override
  State<_LearnRunnerRouteProbe> createState() => _LearnRunnerRouteProbeState();
}

class _LearnRunnerRouteProbeState extends State<_LearnRunnerRouteProbe> {
  final Set<String> completed = <String>{};
  bool inRunner = false;
  int choiceCallbacks = 0;
  int assistanceCallbacks = 0;

  late final Act0LessonCardV1 lesson = Act0ShellStateV1.sample
      .lessonById('hand_rankings_table')
      .copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
      );

  late final Act0WorldCardV1 world = Act0ShellStateV1.sample
      .worldById('world_1')
      .copyWith(
        status: Act0WorldStateV1.current,
        isSelectable: true,
        isLocked: false,
        lessons: <Act0LessonCardV1>[lesson],
      );

  Act0LessonTaskV1 get currentTask => lesson.taskList.firstWhere(
    (task) => !completed.contains(task.taskId),
    orElse: () => lesson.taskList.first,
  );

  // Drives the exact callback ownership boundary used by the live route.
  // An accepted E2E must additionally tap the real continue control and prove
  // graded outcomes plus persisted assistance in Act0ShellPreviewScreenV1.
  void sourceTheoryContinued() {
    setState(() {
      completed.add('hand_rankings_theory');
      inRunner = false;
    });
  }

  void returnToLearn() => setState(() => inRunner = false);

  void reenterTheory() => setState(() {
    completed.remove('hand_rankings_theory');
    inRunner = false;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: inRunner
          ? Act0LessonRunnerShellV1(
              runner: currentTask.runner,
              worldNumber: 1,
              selectedWorldId: world.worldId,
              selectedLessonId: lesson.lessonId,
              selectedTaskId: currentTask.taskId,
              onBack: returnToLearn,
              onContinueTheory: sourceTheoryContinued,
              onChooseOption: (_) {
                choiceCallbacks++;
              },
              onChoiceAssistance: (_) {
                assistanceCallbacks++;
              },
              onContinueReview: returnToLearn,
            )
          : Act0LearnPathShellV1(
              moduleTitle: world.title,
              moduleProgressLabel: world.progressLabel,
              worlds: <Act0WorldCardV1>[world],
              selectedWorldId: world.worldId,
              showWorldMenu: false,
              worldDetailId: null,
              lessons: <Act0LessonCardV1>[lesson],
              selectedLessonId: lesson.lessonId,
              selectedTaskId: currentTask.taskId,
              activePopupTaskId: null,
              completedTaskIds: completed,
              perfectTaskIds: const <String>{},
              skippedTaskIds: const <String>{},
              pathClosedTaskIds: completed,
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
              onSelectTask: (_, __) {},
              onDismissTaskPopup: () {},
              onStartTask: (_, __) => setState(() => inRunner = true),
            ),
    );
  }
}

// Await the Future owned by the rendered panel, not a separate prefetch.
// Start its asset read in the real async zone; keep every UI assertion below.
Future<void> _openRealReference(WidgetTester tester) async {
  final open = find.byKey(const Key('act0_hlp02_open_theory_reference'));
  expect(open, findsOneWidget);
  await tester.ensureVisible(open);
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await tester.tap(open);
    await tester.pump();
    final loader = find.descendant(
      of: find.byKey(const Key('act0_hlp02_inline_reference_region')),
      matching: find.byType(FutureBuilder<Act0Hlp02ReferenceCatalogV1>),
    );
    expect(loader, findsOneWidget);
    final future = tester
        .widget<FutureBuilder<Act0Hlp02ReferenceCatalogV1>>(loader)
        .future;
    expect(future, isNotNull);
    final catalog = await future!;
    expect(catalog.rankings, hasLength(9));
  });
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'real Learn -> theory Runner -> Back -> re-entry has no leaked reference',
    (tester) async {
      final key = GlobalKey<_LearnRunnerRouteProbeState>();
      await tester.pumpWidget(
        MaterialApp(home: _LearnRunnerRouteProbe(key: key)),
      );
      await tester.pumpAndSettle();

      const openKey = Key('act0_hlp02_open_theory_reference');
      const panelKey = Key('act0_hlp02_theory_reference_panel');
      expect(find.byKey(openKey), findsOneWidget);
      await _openRealReference(tester);
      expect(find.byKey(panelKey), findsOneWidget);
      expect(key.currentState!.assistanceCallbacks, 0);
      expect(key.currentState!.choiceCallbacks, 0);

      // Click the existing real Learn mission CTA, not a fabricated entry link.
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_current_mission_cta')),
      );
      await tester.tap(find.byKey(const Key('act0_shell_current_mission_cta')));
      await tester.pumpAndSettle();
      expect(key.currentState!.inRunner, isTrue);
      expect(find.byKey(openKey), findsNothing);
      expect(find.byKey(panelKey), findsNothing);
      expect(key.currentState!.assistanceCallbacks, 0);

      // Source-owned Back callback returns to Learn; the disclosure is closed.
      key.currentState!.returnToLearn();
      await tester.pumpAndSettle();
      expect(find.byKey(openKey), findsOneWidget);
      expect(find.byKey(panelKey), findsNothing);
      expect(key.currentState!.assistanceCallbacks, 0);
    },
  );

  testWidgets(
    'actual Act0 task object advances theory -> scored drill, reference disappears',
    (tester) async {
      final key = GlobalKey<_LearnRunnerRouteProbeState>();
      await tester.pumpWidget(
        MaterialApp(home: _LearnRunnerRouteProbe(key: key)),
      );
      await tester.pumpAndSettle();
      const openKey = Key('act0_hlp02_open_theory_reference');
      const panelKey = Key('act0_hlp02_theory_reference_panel');
      await _openRealReference(tester);
      expect(find.byKey(panelKey), findsOneWidget);

      key.currentState!.sourceTheoryContinued();
      await tester.pumpAndSettle();
      expect(key.currentState!.currentTask.taskId, 'hand_rankings_pair_drill');
      expect(key.currentState!.currentTask.phase, Act0LessonPhaseV1.drill);
      expect(find.byKey(openKey), findsNothing);
      expect(find.byKey(panelKey), findsNothing);

      // Enter the real Runner from the drill's existing mission CTA.
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_current_mission_cta')),
      );
      await tester.tap(find.byKey(const Key('act0_shell_current_mission_cta')));
      await tester.pumpAndSettle();
      expect(key.currentState!.inRunner, isTrue);
      expect(find.byKey(openKey), findsNothing);
      expect(key.currentState!.assistanceCallbacks, 0);
      expect(key.currentState!.choiceCallbacks, 0);

      // Even after moving back and reopening theory, old panel state is gone.
      key.currentState!.reenterTheory();
      await tester.pumpAndSettle();
      expect(find.byKey(openKey), findsOneWidget);
      expect(find.byKey(panelKey), findsNothing);
      expect(key.currentState!.assistanceCallbacks, 0);
    },
  );
}

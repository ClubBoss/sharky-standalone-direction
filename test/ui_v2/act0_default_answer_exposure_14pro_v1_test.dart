import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Exact source tasks behind the prior native private-card / repair decisions.
// This is fixture-render evidence; the resulting candidate still needs native QA.
void main() {
  testWidgets('CO393 remains actionable with preserved choices and teaching', (
    tester,
  ) async {
    final row = [
      for (final w in Act0ShellStateV1.sample.worlds)
        for (final l in w.lessons)
          for (final t in l.taskList)
            if (t.taskId == 'positions_cutoff') (world: w, lesson: l, task: t),
    ].single;
    final decisions = <Act0CompletedDecisionV1>[];
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: row.task.runner.copyWith(
              phase: row.task.entryPhase,
              teachingStepIndex: row.task.runner.teachingSteps.length,
            ),
            worldNumber: row.world.worldNumber,
            selectedWorldId: row.world.worldId,
            selectedLessonId: row.lesson.lessonId,
            selectedTaskId: row.task.taskId,
            selectedTaskTitle: row.task.title,
            selectedTaskFamily: row.task.resolvedTaskFamily,
            compositionFamily: row.task.resolvedCompositionFamily,
            tablePresentation: row.task.tablePresentation,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
            onCompletedDecision: decisions.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final correct = row.task.runner.options.singleWhere((o) => o.isCorrect);
    final control = find.byKey(Key('act0_shell_seat_tap_${correct.seatId}'));
    expect(control, findsOneWidget);
    expect(
      control.hitTestable(),
      findsOneWidget,
      reason: 'CO must receive a real pointer at its visible seat control',
    );
    await tester.tap(control);
    await tester.pump();
    expect(decisions, hasLength(1));
    expect(decisions.single.selectedId, correct.id);
    expect(decisions.single.assistanceKind, Act0DecisionAssistanceV1.none);
    expect(row.task.runner.table.highlightedSeatIds, isEmpty);
    expect(row.task.runner.table.activeSeatId, '');
    expect(row.task.runner.teachingSteps.first.table!.activeSeatId, 'co');
    const priorFingerprint =
        '9cd3753c3b5cff482177ec108ea0dc7e5647f1921751d256b7926292bef55d7e';
    final currentFingerprint = act0AuthoredSourceFingerprintV1(
      worldId: row.world.worldId,
      lessonId: row.lesson.lessonId,
      task: row.task,
    )!;
    expect(currentFingerprint, isNot(priorFingerprint));
    final prior = act0LearningEvidenceRecordFromCompletedDecisionV1(
      decisions.single,
      createdOrder: 1,
      authoredSourceFingerprint: priorFingerprint,
    )!;
    final restored = Act0LearningEvidenceRecordV1.tryParse(
      jsonDecode(jsonEncode(prior.toPayload())),
    )!;
    expect(restored.toPayload(), prior.toPayload());
    expect(restored.isCorrect, isTrue);
    expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
    final fresh = act0LearningEvidenceRecordFromCompletedDecisionV1(
      decisions.single,
      createdOrder: 2,
      authoredSourceFingerprint: currentFingerprint,
    )!;
    expect(act0CurrentAuthoredSourceProofV1(fresh)!.isCurrentlyCorrect, isTrue);
    expect(tester.takeException(), isNull);
  });
  for (final taskId in [
    'your_first_hand_private_cards_recheck',
    'what_poker_is_table_read_recheck',
  ]) {
    testWidgets('all initial answer meanings are exposed at EN14Pro: $taskId', (
      tester,
    ) async {
      final row = [
        for (final w in Act0ShellStateV1.sample.worlds)
          for (final l in w.lessons)
            for (final t in l.taskList)
              if (t.taskId == taskId) (world: w, lesson: l, task: t),
      ].single;
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: row.world.worldId,
              lessonId: row.lesson.lessonId,
              taskId: taskId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(
        runner.runner.options.map((o) => o.id),
        row.task.runner.options.map((o) => o.id),
      );
      final safe = const Rect.fromLTRB(0, 59, 393, 818);
      for (final option in runner.runner.options) {
        final control = find.byKey(Key('act0_shell_option_${option.id}'));
        expect(control, findsOneWidget);
        final controlRect = tester.getRect(control);
        final labels = find.descendant(
          of: control,
          matching: find.byType(RichText),
        );
        final paragraphs = tester.renderObjectList<RenderParagraph>(labels);
        final label = paragraphs.singleWhere(
          (p) => p.text.toPlainText().contains(option.label),
        );
        final boxes = label.getBoxesForSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: label.text.toPlainText().length,
          ),
        );
        expect(boxes, isNotEmpty);
        final origin = label.localToGlobal(Offset.zero);
        final painted = boxes
            .map((b) => b.toRect().shift(origin))
            .reduce((a, b) => a.expandToInclude(b));
        var visible = safe.intersect(controlRect);
        RenderObject? ancestor = label.parent;
        while (ancestor != null) {
          if (ancestor is RenderAbstractViewport && ancestor is RenderBox) {
            final viewport = ancestor as RenderBox;
            visible = visible.intersect(
              viewport.localToGlobal(Offset.zero) & viewport.size,
            );
          }
          ancestor = ancestor.parent;
        }
        expect(
          visible.inflate(0.5).contains(painted.topLeft) &&
              visible.inflate(0.5).contains(painted.bottomRight),
          isTrue,
          reason:
              '$taskId / ${option.id}: full meaning $painted must be inside default visible region $visible; control $controlRect',
        );
        expect(controlRect.height, greaterThanOrEqualTo(44));
        expect(control.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_truth_audit_v1.dart';
import 'act0_source_choreography_test_wait_v1.dart';

Future<CatalogAudit> auditRenderedCatalogSeatCuesV1(
  WidgetTester tester,
  Iterable<CatalogTask> rows,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final audit = CatalogAudit();
  for (final row in rows) {
    final task = row.task;
    final r = task.runner;
    final correct = r.options
        .where(act0RunnerOptionIsAuthoredCorrectV1)
        .firstOrNull;
    if (correct == null || correct.seatId == null) continue;
    final answer = correct.seatId!;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        key: ValueKey(task.taskId),
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: r.copyWith(
              phase: task.entryPhase,
              teachingStepIndex: r.teachingSteps.length,
            ),
            worldNumber: row.world.worldNumber,
            selectedWorldId: row.world.worldId,
            selectedLessonId: row.lesson.lessonId,
            selectedTaskId: task.taskId,
            selectedTaskTitle: task.title,
            selectedTaskFamily: task.resolvedTaskFamily,
            compositionFamily: task.resolvedCompositionFamily,
            tablePresentation: task.tablePresentation,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await pumpSourceChoreographyToDecisionV1(tester, r.table);
    final focus = [
      'act0_shell_seat_state_' + answer + '_activeFocus',
      'act0_shell_seat_state_' + answer + '_targetFocus',
    ].where((key) => find.byKey(Key(key)).evaluate().isNotEmpty).toList();
    audit.check(
      '6.rendered_seat_cue',
      row,
      answer,
      focus.isEmpty,
      'The pre-choice Runner marks the answer seat: $focus.',
    );
    final support = find.byKey(const Key('act0_learning_scene_v3_support'));
    final captions = tester
        .widgetList<Text>(support)
        .map((text) => text.data ?? '');
    if (task.taskId == 'button_advantage_button_vs_cutoff') {
      final question = find.byKey(const Key('act0_integrated_scene_prompt'));
      expect(question, findsOneWidget);
      final bounds = tester.getRect(question);
      expect(bounds.height, greaterThan(0));
      expect((Offset.zero & const Size(393, 852)).overlaps(bounds), isTrue);
    }
    audit.check(
      '6.rendered_seat_order_copy',
      row,
      'caption',
      !captions.any((caption) => revealsComparativeSeatOrder(row, caption)),
      'The visible pre-choice caption discloses the seat order: $captions.',
    );
    final tapIds = [
      for (final seat in r.table.seats)
        if (find
            .byKey(Key('act0_shell_seat_tap_' + seat.seatId))
            .evaluate()
            .isNotEmpty)
          seat.seatId,
    ].toSet();
    if (tapIds.isNotEmpty && r.options.every((o) => o.seatId != null)) {
      final expected = r.options.map((o) => o.seatId!).toSet();
      audit.check(
        '6.rendered_seat_controls',
        row,
        'table',
        tapIds.length == expected.length && tapIds.containsAll(expected),
        'Rendered tap targets $tapIds differ from choices $expected.',
      );
    }
    expect(tester.takeException(), isNull, reason: task.taskId);
  }
  return audit;
}

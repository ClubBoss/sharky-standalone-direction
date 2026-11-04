import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _cta = Key('act0_academy_review_leaf_next_step_cta');

Act0PersonalizedReturnReasonV1 _target(
  String action, {
  String taskId = 'source-task',
}) => Act0PersonalizedReturnReasonV1(
  reasonType: act0ReturnReasonResumeRecentFocusV1,
  conceptFamilyId: 'source-family',
  sourceTaskId: taskId,
  evidenceKind: act0ReturnReasonEvidenceConceptFamilyStateV1,
  messageKey: act0ReturnReasonMessageResumeFocusV1,
  priorityClass: 4,
  recommendedAction: action,
);

Future<void> _pump(
  WidgetTester tester,
  Act0AcademyReviewLeafInputV1 input,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Act0AcademyReviewLeafV1(input: input)),
    ),
  );
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.scrollUntilVisible(
    finder,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  for (final entry in {
    'reinforce': 'Reinforce this read',
    'resume_focus': 'Resume this focus',
  }.entries) {
    testWidgets('${entry.key} forwards the source callback once per tap', (
      tester,
    ) async {
      var opened = 0;
      final target = _target(entry.key);
      final before = target.toPayload();
      final input = Act0AcademyReviewLeafInputV1(
        nextStep: target,
        onOpenRecommendedAction: () => opened++,
      );
      await _pump(tester, input);
      expect(opened, 0);
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('No saved mistakes yet'), findsNothing);
      expect(find.text('All caught up'), findsNothing);
      await _tap(tester, _cta);
      expect(opened, 1);
      await tester.pump();
      expect(opened, 1);
      expect(identical(input.nextStep, target), isTrue);
      expect(target.toPayload(), before);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('absent, unlaunchable and unrelated targets have no CTA', (
    tester,
  ) async {
    var opened = 0;
    final inputs = [
      const Act0AcademyReviewLeafInputV1(),
      Act0AcademyReviewLeafInputV1(onOpenRecommendedAction: () => opened++),
      Act0AcademyReviewLeafInputV1(nextStep: _target('resume_focus')),
      for (final id in ['', '  '])
        Act0AcademyReviewLeafInputV1(
          nextStep: _target('reinforce', taskId: id),
          onOpenRecommendedAction: () => opened++,
        ),
      for (final action in [
        'continue',
        'repair',
        'retry_repair',
        'spaced_review',
      ])
        Act0AcademyReviewLeafInputV1(
          nextStep: _target(action),
          onOpenRecommendedAction: () => opened++,
        ),
    ];
    for (final input in inputs) {
      await _pump(tester, input);
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(find.byKey(_cta), findsNothing);
      expect(opened, 0);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'focus stays separate from repair, due, saved and past sections',
    (tester) async {
      final mistake = Act0MistakeCardV1(
        taskId: 'mistake-task',
        lessonId: 'l1',
        worldId: 'w1',
        title: 'Table clue',
        weaknessLabel: 'Actions',
        selectedOptionId: 'fold',
        selectedLabel: 'Fold',
        betterLabel: 'Call',
        reason: 'r',
        attempts: 1,
      );
      final due = Act0DueReviewItemV1(
        conceptFamilyId: 'cf',
        worldId: 'w1',
        lessonId: 'l1',
        taskId: 'due-task',
        nextDueAtUtc: DateTime.utc(2026, 11, 1),
        repeatedMissCount: 0,
        lapseCount: 0,
      );
      const saved = Act0AcademyReviewSavedCheckV1(checkId: 'saved-job');
      var focused = 0;
      final repairs = <Act0MistakeCardV1>[];
      final dues = <Act0DueReviewItemV1>[];
      final saves = <Act0AcademyReviewSavedCheckV1>[];
      await _pump(
        tester,
        Act0AcademyReviewLeafInputV1(
          nextStep: _target('resume_focus'),
          onOpenRecommendedAction: () => focused++,
          openMistakes: [mistake],
          pastRepairs: [mistake],
          dueItems: [due],
          savedChecks: [saved],
          onRepairMistake: repairs.add,
          onStartDueReview: dues.add,
          onStartSavedCheck: saves.add,
        ),
      );
      await _tap(tester, const Key('act0_academy_review_leaf_repair_cta'));
      await _tap(tester, _cta);
      expect(focused, 1);
      expect(repairs.single, same(mistake));
      expect(dues, isEmpty);
      expect(saves, isEmpty);
      await _tap(tester, const Key('act0_academy_review_leaf_start_due'));
      await _tap(tester, const Key('act0_academy_review_leaf_saved_saved-job'));
      expect(dues.single, same(due));
      expect(saves.single, same(saved));
      expect(focused, 1);
      expect(repairs, [mistake]);
      expect(find.text('Past repair notes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

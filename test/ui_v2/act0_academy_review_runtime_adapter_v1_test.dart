import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';

const _review = Act0ReviewStateV1(
  title: 'Review',
  subtitle: '',
  weaknessLabel: '',
  reason: '',
  stats: [],
  chosenLabel: '',
  betterLabel: '',
);

Future<void> _mount(
  WidgetTester tester, {
  required Act0PersonalizedReturnReasonV1? reason,
  required bool Function() isCurrent,
  VoidCallback? onOpen,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => act0AcademyReviewRuntimeV1(
            context,
            legacy: Act0ReviewShellV1(
              review: _review,
              selected: null,
              onSelected: (_) {},
              nextStep: reason,
              onOpenRecommendedAction: onOpen,
            ),
            isCurrent: isCurrent,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0PersonalizedReturnReasonV1 _reason(String action) =>
    Act0PersonalizedReturnReasonV1(
      reasonType: action == 'reinforce'
          ? act0ReturnReasonReinforceRecentImprovementV1
          : act0ReturnReasonResumeRecentFocusV1,
      conceptFamilyId: 'table_position_read',
      sourceTaskId: 'first_table_guide_one_clear_choice',
      evidenceKind: act0ReturnReasonEvidenceConceptFamilyStateV1,
      messageKey: action,
      priorityClass: action == 'reinforce' ? 3 : 4,
      recommendedDestination: 'learn',
      recommendedAction: action,
    );

void main() {
  if (!act0AcademyReviewPreviewV1) {
    testWidgets('default OFF retains the existing Review shell', (
      tester,
    ) async {
      await _mount(tester, reason: _reason('reinforce'), isCurrent: () => true);
      expect(find.byType(Act0ReviewShellV1), findsOneWidget);
      expect(find.byType(Act0AcademyReviewLeafV1), findsNothing);
    });
    return;
  }

  for (final action in ['reinforce', 'resume_focus']) {
    testWidgets('$action preserves source input and recovery callback fence', (
      tester,
    ) async {
      final reason = _reason(action);
      var current = true;
      var opened = 0;
      await _mount(
        tester,
        reason: reason,
        isCurrent: () => current,
        onOpen: () => opened++,
      );
      final input = tester
          .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
          .input;
      expect(input.nextStep, same(reason));
      expect(input.nextStep!.sourceTaskId, reason.sourceTaskId);
      final cta = find.byKey(
        const Key('act0_academy_review_leaf_next_step_cta'),
      );
      await tester.scrollUntilVisible(cta, 200);
      await tester.tap(cta);
      expect(opened, 1);
      final retainedCallback = input.onOpenRecommendedAction!;
      current = false;
      retainedCallback();
      expect(opened, 1, reason: 'A stale retained callback must not launch.');
      current = true;
      retainedCallback();
      expect(opened, 2);
    });
  }

  testWidgets('focus, repair, due and saved callbacks stay distinct', (
    tester,
  ) async {
    const mistake = Act0MistakeCardV1(
      taskId: 'repair', lessonId: 'lesson', title: 'Spot',
      weaknessLabel: 'Read', selectedOptionId: 'a', selectedLabel: 'A',
      betterLabel: 'B', reason: 'Reason', attempts: 1,
    );
    const saved = SessionDrillRecheckLaunchQueueItemV1(
      queueKind: 'check', jobId: 'saved', launchSessionId: 'launch',
      sourceWorldId: 'world', sourceSessionId: 'source', sourceDrillId: 'drill',
      drillFamilyId: 'family', missedSignalId: 'signal', missedSignalLabel: 'Signal',
      chosenActionId: 'a', expectedActionId: 'b', targetSessionId: 'target',
      targetDrillId: 'target_drill', targetKind: 'drill', errorClass: 'error',
    );
    final due = Act0DueReviewItemV1(
      conceptFamilyId: 'due', worldId: 'world', lessonId: 'lesson',
      taskId: 'due', nextDueAtUtc: DateTime.utc(2026),
      repeatedMissCount: 0, lapseCount: 0,
    );
    final calls = <String>[];
    var current = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => act0AcademyReviewRuntimeV1(
              context,
              isCurrent: () => current,
              legacy: Act0ReviewShellV1(
                review: _review,
                selected: null,
                onSelected: (_) {},
                nextStep: _reason('reinforce'),
                onOpenRecommendedAction: () => calls.add('focus'),
                onFixMistake: (item) => calls.add(item.taskId),
                dueReviewItems: [due],
                onStartDueReview: (item) => calls.add(item.taskId),
                sessionDrillRecheckQueueItems: const [saved],
                onStartSessionDrillRecheck: (item) => calls.add(item.jobId),
              ),
            ),
          ),
        ),
      ),
    );
    final input = tester
        .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
        .input;
    input.onOpenRecommendedAction!();
    input.onRepairMistake!(mistake);
    input.onStartDueReview!(due);
    input.onStartSavedCheck!(input.savedChecks.single);
    expect(calls, ['focus', 'repair', 'due', 'saved']);
    current = false;
    input.onOpenRecommendedAction!();
    input.onRepairMistake!(mistake);
    input.onStartDueReview!(due);
    input.onStartSavedCheck!(input.savedChecks.single);
    expect(calls, ['focus', 'repair', 'due', 'saved']);
  });

  testWidgets('null source reason stays absent', (tester) async {
    await _mount(tester, reason: null, isCurrent: () => true, onOpen: () {});
    final input = tester
        .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
        .input;
    expect(input.nextStep, isNull);
    expect(find.byKey(const Key('act0_academy_review_leaf_next_step_cta')), findsNothing);
  });

  testWidgets('missing source callback stays absent', (tester) async {
    await _mount(tester, reason: _reason('reinforce'), isCurrent: () => true);
    final input = tester
        .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
        .input;
    expect(input.onOpenRecommendedAction, isNull);
    expect(
      find.byKey(const Key('act0_academy_review_leaf_next_step_cta')),
      findsNothing,
    );
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

Act0BlockCompletionSummaryV1 receipt({
  required int tasks,
  required int correct,
  required int errors,
  required bool evidenceKnown,
  bool completed = false,
  int assisted = 0,
  int xp = 0,
}) {
  return Act0BlockCompletionSummaryV1(
    lessonTitle: 'Actions',
    nextLessonTitle: 'Next lesson',
    curriculumCompleted: completed,
    xpEarned: xp,
    errorCount: errors,
    assistedCount: assisted,
    independentProvenanceKnown: evidenceKnown,
    taskCount: tasks,
    correctCount: correct,
    startLevel: 1,
    endLevel: 1,
    startXp: 0,
    endXp: xp,
    xpTarget: 100,
  );
}

Future<void> showReceipt(
  WidgetTester tester,
  Act0BlockCompletionSummaryV1 summary,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Act0BlockCompletionShellV1(
            summary: summary,
            firstCorrectEarnedThisRun: false,
            onContinue: () {},
            onReplay: () {},
            onOpenReview: () {},
            onBackToMap: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 2200));
}

void main() {
  test(
    'REP-06: no scored tasks cannot claim Solid with default provenance',
    () {
      final summary = receipt(
        tasks: 0,
        correct: 0,
        errors: 0,
        evidenceKnown: true,
        completed: true,
      );
      expect(summary.masteryStatus.name, 'learning');
    },
  );

  test('REP-06: unknown evidence cannot claim a clean run', () {
    final summary = receipt(
      tasks: 4,
      correct: 0,
      errors: 0,
      evidenceKnown: false,
      completed: true,
    );
    expect(summary.habitRewardLabel, isNot('Clean read'));
    expect(summary.habitRewardDetail, isNot(contains('Clean run')));
  });

  test('REP-06: teaching-only cannot manufacture a score-based unlock', () {
    final summary = receipt(
      tasks: 0,
      correct: 0,
      errors: 0,
      evidenceKnown: false,
    );
    expect(summary.qualifiesForNextLesson, isFalse);
    expect(summary.masteryStatus.name, 'learning');
  });

  test('REP-06: unknown graded history is not classified as a poor score', () {
    final summary = receipt(
      tasks: 4,
      correct: 0,
      errors: 0,
      evidenceKnown: false,
      completed: true,
    );
    expect(summary.qualifiesForNextLesson, isTrue);
    expect(summary.masteryStatus.name, 'learning');
  });

  testWidgets('REP-06: missing score has no invented 0/4 assessment', (
    tester,
  ) async {
    await showReceipt(
      tester,
      receipt(
        tasks: 4,
        correct: 0,
        errors: 0,
        evidenceKnown: false,
        completed: true,
        xp: 5,
      ),
    );
    final line = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_accuracy')),
        )
        .data!;
    expect(line, contains('Assessment not verified'));
    expect(line, isNot(contains('0/4 assessed correct')));
    expect(find.text('Assessed accuracy'), findsNothing);
    expect(find.text('One clean read'), findsNothing);
  });

  testWidgets('REP-06: teaching-only completion has no measured score', (
    tester,
  ) async {
    await showReceipt(
      tester,
      receipt(
        tasks: 0,
        correct: 0,
        errors: 0,
        evidenceKnown: false,
        completed: true,
        xp: 5,
      ),
    );
    final line = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_accuracy')),
        )
        .data!;
    expect(line, contains('Assessment not verified'));
    expect(line, isNot(contains('0/0')));
    expect(find.text('One clean read'), findsNothing);
  });

  testWidgets('REP-06: assessed help remains distinct from clean proof', (
    tester,
  ) async {
    final summary = receipt(
      tasks: 2,
      correct: 2,
      errors: 0,
      evidenceKnown: true,
      assisted: 1,
      completed: true,
      xp: 5,
    );
    expect(summary.masteryStatus.name, isNot('cleanPass'));
    await showReceipt(tester, summary);
    final line = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_accuracy')),
        )
        .data!;
    expect(line, contains('1 with help'));
    expect(find.text('One clean read'), findsNothing);
  });

  testWidgets('REP-06: authentic clean assessment keeps truthful receipt', (
    tester,
  ) async {
    final summary = receipt(
      tasks: 2,
      correct: 2,
      errors: 0,
      evidenceKnown: true,
      completed: true,
    );
    expect(summary.masteryStatus.name, 'cleanPass');
    await showReceipt(tester, summary);
    final line = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_accuracy')),
        )
        .data!;
    expect(line, contains('100% accuracy (assessed)'));
    expect(find.text('One clean read'), findsOneWidget);
  });
}

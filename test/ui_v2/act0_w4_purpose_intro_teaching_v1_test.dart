// SIMULATED direct existing renderer, not a normal unlocked learner traversal,
// first-use exposure, native or Human learning proof.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('old study remains readable but cannot prove the revised explanation', () {
    final task = Act0ShellStateV1.sample
        .lessonById('why_bets_happen')
        .taskList
        .first;
    // Exact prior D22 task/donor teaching data, not a claimed learner event.
    final prior = Act0LessonTaskV1(
      taskId: task.taskId,
      title: task.title,
      phase: task.phase,
      rewardXp: task.rewardXp,
      stepKind: task.stepKind,
      runner: task.runner.copyWith(
        teachingSteps: const [
          Act0TeachingStepV1(
            title: 'Purpose first.',
            body:
                'Name the bet purpose first. Value gets calls, bluff gets folds, '
                'protection makes the next card cost money.',
            focusLabels: ['Value', 'Bluff', 'Protection'],
          ),
        ],
      ),
    );
    String revision(Act0LessonTaskV1 item) => act0AuthoredStudyRevisionV1(
      worldId: 'world_4',
      lessonId: 'why_bets_happen',
      task: item,
    )!;
    final oldRevision = revision(prior);
    final newRevision = revision(task);
    expect(oldRevision, isNot(newRevision));
    Act0StudyObservationV1 synthetic(String sourceRevision) =>
        Act0StudyObservationV1(
          worldId: 'world_4',
          lessonId: 'why_bets_happen',
          taskId: task.taskId,
          sourceRevision: sourceRevision,
          sessionId: 'SIMULATED-study-compatibility-only',
          recordedAtUtc: DateTime.utc(2026, 1, 1),
        );
    final oldPayload = synthetic(oldRevision).toPayload();
    final restored = Act0StudyObservationV1.tryParse(oldPayload)!;
    expect(restored.toPayload(), oldPayload);
    expect(act0CurrentStudyTopicV1(restored), isNull);
    expect(act0CurrentStudyTopicV1(synthetic(newRevision)), 'Bet purpose');
  });
  setUpAll(() async {
    // Same legible platform-font harness as existing W01 render evidence.
    final font = [
      File('/System/Library/Fonts/Supplemental/Arial.ttf'),
      File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),
    ].firstWhere((file) => file.existsSync());
    final bytes = await font.readAsBytes();
    for (final name in ['Roboto', 'Ahem']) {
      await (FontLoader(
        name,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
  });
  testWidgets('complete purpose definitions are readable before continuing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = Act0ShellStateV1.sample;
    final world = state.worldById('world_4');
    final lesson = state.lessonById('why_bets_happen');
    final task = lesson.taskList.first;
    // Do not manufacture an unlocked normal route or progress/exposure record.
    expect(world.isLocked, isTrue);
    expect(lesson.isLocked, isTrue);
    expect(task.taskId, 'w4_purpose_intro');
    expect(task.runner.options, isEmpty);
    expect(task.rewardXp, 5);
    expect(
      act0AuthoredSourceFingerprintV1(
        worldId: 'world_4',
        lessonId: lesson.lessonId,
        task: task,
      ),
      '69e5da7553f0077e9a9f313f132dc7ab3fe76c2884f915913dd3a092d31c8893',
      reason:
          'Teaching copy does not change the unchanged assessment identity; '
          'old records do not prove exposure to the new wording.',
    );
    var decisions = 0;
    var continued = 0;
    final assistance = <Object>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('w4-purpose-intro-capture'),
            child: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: 0,
              ),
              worldNumber: 4,
              selectedWorldId: 'world_4',
              selectedLessonId: lesson.lessonId,
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () => continued++,
              onChooseOption: (_) => decisions++,
              onChooseSeat: (_) => decisions++,
              onContinueReview: () {},
              onChoiceAssistance: assistance.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    const body =
        'Name the bet purpose first. '
        'Value means worse hands can still call. '
        'A bluff tries to make better hands fold. '
        'Protection makes the next card cost money.';
    final rendered = find.textContaining(body);
    expect(rendered, findsOneWidget);
    await tester.ensureVisible(rendered);
    await tester.pumpAndSettle();
    final paragraph = tester.renderObject<RenderParagraph>(rendered);
    expect(paragraph.didExceedMaxLines, isFalse);
    final rect = tester.getRect(rendered);
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(852));
    expect(decisions, 0);
    expect(continued, 0);
    expect(assistance, isEmpty);
    Future<void> capture(String suffix) => tester.runAsync(() async {
      final output = Platform.environment['W4_PURPOSE_CAPTURE'];
      if (output == null) return;
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('w4-purpose-intro-capture')),
      );
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$output.$suffix.png')
        ..parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });
    await capture('start');
    final support = find.byKey(
      const Key('act0_learning_scene_v3_theory_support_scroll'),
    );
    expect(support, findsOneWidget);
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: support, matching: find.byType(Scrollable)),
    );
    if (scroll.position.maxScrollExtent > 0) {
      await tester.drag(support, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(scroll.position.extentAfter, lessThan(1));
    expect(
      tester.getRect(rendered).bottom,
      lessThanOrEqualTo(tester.getRect(support).bottom + 1),
      reason:
          'The final protection clause must be reachable inside the rail, '
          'not merely present in a clipped widget.',
    );
    expect(decisions, 0);
    expect(continued, 0);
    expect(assistance, isEmpty);
    await capture('end');
  });
}

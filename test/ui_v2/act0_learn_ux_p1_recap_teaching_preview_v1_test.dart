// LEARN.UX.P1 (#331): an answer-free recap presents its authored teaching step
// through the real preview flow, then its takeaway, and completes exactly as
// before (same XP once, no decision evidence).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_teaching_integrity_harness_v1.dart';

const _progressKey = 'act0_shell_progress_v1';

void main() {
  setUpAll(act0LoadRealTextFontsV1);

  testWidgets(
    'w4_value_recap teaches, then shows its takeaway, then completes',
    (tester) async {
      tester.view.physicalSize = act0TeachingReferenceViewportV1;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.systemFontFamily = 'Roboto';
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.resetSystemFontFamily);
      final ref = act0TeachingTaskByIdV1('w4_value_recap');
      final step = ref.task.runner.teachingSteps.single;
      // Test-only resume seed: the catalog before this recap is complete.
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _progressKey: jsonEncode(<String, Object>{
          'schemaVersion': 18,
          'completedTaskIds': act0TeachingCatalogV1()
              .takeWhile((r) => r.task.taskId != ref.task.taskId)
              .map((r) => r.task.taskId)
              .toList(),
          'completedLessonIds': <String>[],
          'selectedWorldId': ref.worldId,
          'selectedLessonId': ref.lessonId,
          'selectedTaskId': ref.task.taskId,
          'earnedXp': 100,
          'resumeInRunner': true,
          'resumePhase': 'review',
          'resumeTeachingStepIndex': 0,
        }),
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            showPlacementOnStart: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, ref.task.taskId);
      expect(act0CopyPresentedV1(tester, step.title), isTrue);
      expect(act0CopyPresentedV1(tester, step.body), isTrue);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );

      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();
      // One Continue reaches the takeaway, which is neutral: no answer was
      // made, so nothing may read as a correct graded answer.
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
      expect(
        act0TextByKeyV1(tester, 'act0_integrated_scene_purpose'),
        'KEY TAKEAWAY',
      );
      expect(find.text('CORRECT READ'), findsNothing);
      expect(_evaluativeTexts(tester), isEmpty);
      expect(act0CopyPresentedV1(tester, ref.task.runner.reviewTitle), isTrue);
      expect(act0CopyPresentedV1(tester, ref.task.runner.reviewReason), isTrue);
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> saved() =>
          jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
      expect(saved()['completedTaskIds'], isNot(contains(ref.task.taskId)));

      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      expect(saved()['completedTaskIds'], contains(ref.task.taskId));
      expect(saved()['earnedXp'], 100 + ref.task.rewardXp);
      expect(saved()['learningEvidenceHistory'], isEmpty);
    },
  );

  testWidgets('every answer-free recap takeaway is neutral, never graded', (
    tester,
  ) async {
    final recaps = act0TeachingCatalogV1()
        .where(
          (ref) =>
              ref.task.entryPhase == Act0LessonPhaseV1.review &&
              ref.task.runner.options.isEmpty,
        )
        .toList();
    expect(recaps, hasLength(32));
    for (final ref in recaps) {
      final events = <String>[];
      // Fresh runner state per recap.
      await tester.pumpWidget(const SizedBox());
      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      for (var i = 0; i < ref.task.runner.teachingSteps.length; i++) {
        await act0TapTeachingContinueV1(tester);
      }
      expect(events.last, 'teaching_done', reason: ref.task.taskId);
      expect(
        act0TextByKeyV1(tester, 'act0_integrated_scene_purpose'),
        'KEY TAKEAWAY',
        reason: ref.task.taskId,
      );
      expect(_evaluativeTexts(tester), isEmpty, reason: ref.task.taskId);
      expect(
        act0CopyPresentedV1(tester, ref.task.runner.reviewTitle),
        isTrue,
        reason: ref.task.taskId,
      );
    }
  });

  testWidgets('control: a genuinely graded correct answer keeps its feedback', (
    tester,
  ) async {
    final ref = act0TeachingTaskByIdV1('cards_ranks_suits_rank_drill');
    final events = <String>[];
    await act0PumpTeachingHarnessV1(tester, ref, events: events);
    for (var i = 0; i < ref.task.runner.teachingSteps.length; i++) {
      await act0TapTeachingContinueV1(tester);
    }
    final correct = ref.task.runner.options.firstWhere((o) => o.isCorrect);
    await tester.tap(find.byKey(Key('act0_shell_option_${correct.id}')));
    await act0SettleTeachingV1(tester);
    expect(events.last, 'choose:${correct.id}');
    expect(
      act0TextByKeyV1(tester, 'act0_integrated_scene_purpose'),
      'CORRECT READ',
    );
    expect(find.textContaining('was right'), findsWidgets);
  });
}

/// On-screen copy that would claim a graded result.
List<String> _evaluativeTexts(WidgetTester tester) =>
    act0PresentedTextsV1(
      tester,
    ).where((t) => t.onScreen).map((t) => t.text).where((text) {
      final lower = text.toLowerCase();
      return lower.contains('correct') ||
          lower.contains('was right') ||
          lower.contains('right with help') ||
          lower.contains('exact clue is marked') ||
          lower.contains('missed clue');
    }).toList();

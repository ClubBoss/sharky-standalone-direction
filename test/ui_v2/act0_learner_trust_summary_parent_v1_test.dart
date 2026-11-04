import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
const _guideLessonId = 'what_poker_is';

final _guideLesson = Act0ShellStateV1.sample
    .worldById('world_1')
    .lessons
    .firstWhere((lesson) => lesson.lessonId == _guideLessonId);
Future<void> _pumpGuide(
  WidgetTester tester, {
  List<String> completedTaskIds = const <String>[],
  List<Map<String, Object?>> history = const <Map<String, Object?>>[],
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _progressKey: jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': completedTaskIds,
      'completedLessonIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': _guideLessonId,
      'selectedTaskId': _guideLesson.taskList.first.taskId,
      'earnedXp': 0,
      if (history.isNotEmpty) 'learningEvidenceHistory': history,
    }),
  });
  await _mountRoot(tester);
}

Future<void> _mountRoot(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.theory,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Plays the real lesson route with each task's authored correct choice
/// (independent: no hint or theory recall) until the Session Summary.
Future<List<String>> _answerGuideToSummary(WidgetTester tester) async {
  final answered = <String>[];
  for (var step = 0; step < 80; step++) {
    if (find
        .byKey(const Key('act0_shell_block_summary_title'))
        .evaluate()
        .isNotEmpty) {
      return answered;
    }
    final runners = find.byType(Act0LessonRunnerShellV1);
    if (runners.evaluate().isNotEmpty) {
      final runner = tester.widget<Act0LessonRunnerShellV1>(runners);
      final correct = runner.runner.options.where(
        (o) => answered.isEmpty ? !o.isCorrect : o.isCorrect,
      );
      if (correct.isNotEmpty &&
          runner.runner.phase == Act0LessonPhaseV1.drill &&
          runner.runner.selectedOptionId == null) {
        final choice = correct.first;
        final seat = find.byKey(Key('act0_shell_seat_tap_${choice.seatId}'));
        final option = find.byKey(Key('act0_shell_option_${choice.id}'));
        final target = seat.evaluate().isNotEmpty ? seat : option;
        if (target.evaluate().isNotEmpty) {
          answered.add(runner.selectedTaskId ?? '');
          await tester.ensureVisible(target.first);
          await tester.tap(target.first);
          await tester.pumpAndSettle();
          continue;
        }
      }
    }
    final forward = <String>[
      'act0_shell_theory_continue_cta',
      'act0_shell_continue_cta',
      'act0_shell_feedback_continue_cta',
    ].map((key) => find.byKey(Key(key))).where((f) => f.evaluate().isNotEmpty);
    expect(forward, isNotEmpty, reason: 'no forward route at step $step');
    await tester.ensureVisible(forward.first.first);
    await tester.tap(forward.first.first);
    await tester.pumpAndSettle();
  }
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  fail(
    'Session Summary not reached: ${runner.selectedTaskId} ${runner.runner.phase} selected=${runner.runner.selectedOptionId} answered=$answered',
  );
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data ?? '';

Future<Map<String, dynamic>> _persisted() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> _leaveSummary(WidgetTester tester) async {
  final map = find.byKey(const Key('act0_shell_block_summary_map_cta'));
  if (map.evaluate().isNotEmpty) {
    await tester.ensureVisible(map);
    await tester.tap(map);
    await tester.pumpAndSettle();
  }
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'real miss and independent repair earn completion without rewriting first assessment',
    (t) async {
      await _pumpGuide(t);
      await _answerGuideToSummary(t);
      expect(_text(t, 'act0_shell_block_summary_title'), 'Lesson complete');
      expect(_text(t, 'act0_shell_block_summary_accuracy'), contains('75%'));
      expect(find.text('Clean pass'), findsNothing);
      expect(find.text('Replay before next lesson'), findsNothing);
      final saved = await _persisted();
      expect(
        saved['completedTaskIds'],
        containsAll(_guideLesson.taskList.map((task) => task.taskId)),
      );
      expect(saved['completedLessonIds'], contains(_guideLessonId));
      final earnedXp = saved['earnedXp'];
      await _leaveSummary(t);
      await _openTab(t, 'Home');
      final home = t.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.currentLesson!.lessonId, isNot(_guideLessonId));
      expect((await _persisted())['earnedXp'], earnedXp);
    },
  );
}

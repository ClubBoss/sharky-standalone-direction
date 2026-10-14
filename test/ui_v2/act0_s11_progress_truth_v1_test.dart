import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S11 progress truth: Placement may CLEAR lessons so the path opens at the
// right place, but a cleared lesson is not an earned completion. Home/Learn
// "N of 9 lessons complete" must count earned lessons; cleared ones are named
// honestly and never counted as earned. Routing, skips, XP and evidence are
// unchanged. Real casual first-install route; no seeded learner state.
const _progressKey = 'act0_shell_progress_v1';
const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: key);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  (tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
      .debugPersistProgressV1();
  await tester.pump(const Duration(milliseconds: 250));
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _mount(WidgetTester tester, {required bool fresh}) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: fresh,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _homeLabel(WidgetTester tester) =>
    tester
        .widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1))
        .pathProgressLabel ??
    '';

int _earnedLessons(Map<String, dynamic> saved) {
  final done = (saved['completedTaskIds'] as List).cast<String>().toSet();
  return Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .where((l) => l.taskList.every((t) => done.contains(t.taskId)))
      .length;
}

void main() {
  testWidgets('Placement-cleared lessons are not shown as earned lesson '
      'completions on Home; You agrees', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _mount(tester, fresh: true);
    await _tapKey(tester, 'act0_shell_placement_intro_cta');
    for (final option in const ['friends', 'rules']) {
      await _tapKey(tester, 'act0_shell_placement_option_$option');
      await _tapKey(tester, 'act0_shell_placement_next_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
    for (var i = 0; i < 3; i++) {
      final o = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
      await _tapKey(
        tester,
        o.seatId == null
            ? 'act0_shell_option_${o.id}'
            : 'act0_shell_seat_tap_${o.seatId}',
      );
      await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_recommended');
    await _tapKey(tester, 'act0_shell_welcome_primary_cta');
    final welcomeAnswer = _runner(
      tester,
    ).runner.options.firstWhere((o) => o.isCorrect);
    await _tapKey(tester, 'act0_shell_option_${welcomeAnswer.id}');
    await _tapKey(tester, 'act0_shell_welcome_primary_cta');
    final saved = await _saved(tester);
    final skipped = (saved['skippedTaskIds'] as List).cast<String>();
    expect(skipped, isNotEmpty, reason: 'Placement cleared part of the path');
    expect(saved['completedTaskIds'], isEmpty);
    expect(saved['earnedXp'], 0);

    // In-session (no restart): leave the runner for Home, as the learner does.
    await _tapKey(tester, 'act0_shell_runner_back');
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    final label = _homeLabel(tester);
    expect(
      label,
      '0 of 9 lessons complete',
      reason: 'cleared lessons must not be counted as earned completions',
    );
    // The Home "route proof is active" receipt is only for a source-earned
    // lesson; Placement clearance alone must not trigger it.
    expect(
      find.byKey(const Key('act0_shell_home_proof_momentum_line')),
      findsNothing,
    );
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('0 tasks complete'), findsWidgets);

    // Skips/navigation/XP are preserved by the correction.
    final after = await _saved(tester);
    expect(after['skippedTaskIds'], saved['skippedTaskIds']);
    expect(after['completedTaskIds'], saved['completedTaskIds']);
    expect(after['earnedXp'], saved['earnedXp']);

    // After a cold restart Home still counts exactly the canonical earned
    // lessons (whatever restore holds), never the cleared ones on top.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await _mount(tester, fresh: false);
    final restored = await _saved(tester);
    expect(
      _homeLabel(tester),
      startsWith('${_earnedLessons(restored)} of 9 lessons complete'),
    );
    expect(restored['skippedTaskIds'], saved['skippedTaskIds']);
    expect(restored['earnedXp'], 0);
  });

  testWidgets('earned lessons still count and no placement wording appears '
      'when nothing was cleared by placement', (tester) async {
    final raw =
        jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
    final progress =
        jsonDecode(
              raw['flutter.$_progressKey'] as String? ??
                  raw[_progressKey] as String,
            )
            as Map<String, dynamic>;
    SharedPreferences.setMockInitialValues(<String, Object>{
      for (final e in raw.entries) e.key: e.value as Object,
    });
    await _mount(tester, fresh: false);
    final saved = await _saved(tester);
    final label = _homeLabel(tester);
    expect(label, '${_earnedLessons(saved)} of 9 lessons complete');
  });
}

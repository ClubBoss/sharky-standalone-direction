import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S11 P1-A / P1-B: placement-routed assessed decisions must carry a real,
// source-owned run/session identity, and placement diagnostic answers must be
// explicit assessment evidence that never masquerades as lesson learning,
// unseen transfer, durable retention or a moved lesson-run boundary.
// Every assertion is made through the real first-install / retake routes; no
// learner evidence is injected. The retake fixture is a native-captured state.
const _progressKey = 'act0_shell_progress_v1';
const _retakeFixture =
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

Future<void> _mount(
  WidgetTester tester, {
  required bool fresh,
  Act0InMemoryTelemetrySinkV1? sink,
}) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: fresh,
        telemetrySink: sink,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Casual route: "I played casually" -> "Try one quick check" -> 3 correct
/// diagnostic answers. Stops on the Placement result screen.
Future<void> _diagnosticToResult(WidgetTester tester) async {
  await _tapKey(tester, 'act0_shell_placement_intro_cta');
  for (final option in const ['friends', 'rules']) {
    await _tapKey(tester, 'act0_shell_placement_option_$option');
    await _tapKey(tester, 'act0_shell_placement_next_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
  for (var i = 0; i < 3; i++) {
    final correct = _runner(
      tester,
    ).runner.options.firstWhere((o) => o.isCorrect);
    await _tapKey(
      tester,
      correct.seatId == null
          ? 'act0_shell_option_${correct.id}'
          : 'act0_shell_seat_tap_${correct.seatId}',
    );
    await _tapKey(tester, 'act0_shell_feedback_continue_cta');
  }
}

Future<void> _welcomeToRecommendedRunner(WidgetTester tester) async {
  await _tapKey(tester, 'act0_shell_placement_start_recommended');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  final answer = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
  await _tapKey(tester, 'act0_shell_option_${answer.id}');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
}

/// Plays the currently selected W1 tasks with their authored correct answers
/// until [stopAfter] tasks are completed or the completion summary appears.
Future<void> _playW1(WidgetTester tester, {int? stopAfter}) async {
  final lesson = Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .firstWhere((l) => l.lessonId == 'what_poker_is');
  var done = 0;
  for (var guard = 0; guard < 12; guard++) {
    if (find.byType(Act0BlockCompletionShellV1).evaluate().isNotEmpty) return;
    if (stopAfter != null && done >= stopAfter) return;
    final task = lesson.taskList.firstWhere(
      (t) => t.taskId == _runner(tester).selectedTaskId,
    );
    if (task.phase == Act0LessonPhaseV1.theory) {
      for (
        var i = 0;
        i < 12 && _runner(tester).selectedTaskId == task.taskId;
        i++
      ) {
        final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
        await _tapKey(
          tester,
          theory.evaluate().isNotEmpty
              ? 'act0_shell_theory_continue_cta'
              : 'act0_shell_continue_cta',
        );
      }
    } else {
      final answer = task.runner.options.firstWhere((o) => o.isCorrect);
      for (var i = 0; i < 14; i++) {
        final option = find.byKey(Key('act0_shell_option_${answer.id}'));
        final seat = find.byKey(Key('act0_shell_seat_tap_${answer.seatId}'));
        if (option.evaluate().isNotEmpty || seat.evaluate().isNotEmpty) {
          await _tapKey(
            tester,
            seat.evaluate().isNotEmpty
                ? 'act0_shell_seat_tap_${answer.seatId}'
                : 'act0_shell_option_${answer.id}',
          );
          break;
        }
        final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
        await _tapKey(
          tester,
          theory.evaluate().isNotEmpty
              ? 'act0_shell_theory_continue_cta'
              : 'act0_shell_continue_cta',
        );
      }
      await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    }
    done += 1;
  }
}

Future<void> _openRetake(WidgetTester tester) async {
  await tester.tap(find.text('You').last);
  await tester.pumpAndSettle();
  final tools = find.byKey(
    const Key('act0_shell_profile_first_start_tools_button'),
    skipOffstage: false,
  );
  await tester.scrollUntilVisible(
    tools,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(tools);
  await tester.pumpAndSettle();
  await tester.tap(tools);
  await tester.pumpAndSettle();
  await _tapKey(tester, 'act0_shell_profile_retake_placement');
}

void main() {
  Future<Map<String, Object?>> casualFirstDecision(
    WidgetTester tester,
    Act0InMemoryTelemetrySinkV1 sink,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _mount(tester, fresh: true, sink: sink);
    await _diagnosticToResult(tester);
    final afterDiagnostic = await _saved(tester);
    await _welcomeToRecommendedRunner(tester);
    expect(_runner(tester).selectedTaskId, 'actions_legal_context');
    final wrong = _runner(
      tester,
    ).runner.options.firstWhere((o) => !o.isCorrect);
    for (var i = 0; i < 12; i++) {
      if (find
          .byKey(Key('act0_shell_option_${wrong.id}'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
      await _tapKey(
        tester,
        theory.evaluate().isNotEmpty
            ? 'act0_shell_theory_continue_cta'
            : 'act0_shell_continue_cta',
      );
    }
    await _tapKey(tester, 'act0_shell_option_${wrong.id}');
    return {'afterDiagnostic': afterDiagnostic, 'saved': await _saved(tester)};
  }

  testWidgets('P1-B: placement diagnostic answers are explicit assessment '
      'evidence (own run + session), not lesson completion or retention', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _mount(tester, fresh: true);
    final atMount = await _saved(tester);
    await _diagnosticToResult(tester);
    final afterDiagnostic = await _saved(tester);
    final diagnostic = (afterDiagnostic['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>();
    expect(diagnostic, hasLength(3));
    for (final r in diagnostic) {
      expect(r['runKind'], 'placement', reason: 'assessment provenance');
      expect(r['runId'], isNotEmpty);
      expect(r['runId'], startsWith('run_v1|world_1|'));
      expect(r['sessionId'], isNotEmpty);
      expect(r['startedBy'], 'placement_diagnostic');
    }
    expect(
      diagnostic.map((r) => r['runId']).toSet(),
      hasLength(1),
      reason: 'one placement assessment run for the three diagnostic answers',
    );
    for (final key in const [
      'completedTaskIds',
      'completedLessonIds',
      'earnedXp',
    ]) {
      expect(
        afterDiagnostic[key],
        atMount[key],
        reason: 'diagnostic answers must not change $key',
      );
    }
    expect(afterDiagnostic['earnedXp'], 0);
    final history = Act0LearningEvidenceHistoryV1.tryParse(
      afterDiagnostic['learningEvidenceHistory'],
    )!;
    expect(
      history.latestRunRecords(),
      isEmpty,
      reason:
          'a placement assessment run is not the latest learning run: it must '
          'not drive a run summary or earn "First session complete"',
    );
    expect(history.latestRunSummary(), isNull);
    expect(
      jsonEncode(afterDiagnostic['durableRetentionHistory'] ?? const []),
      isNot(contains('what_poker_is_table_read_transfer')),
      reason: 'a placement answer must not seed durable retention / due review',
    );
  });

  testWidgets('P1-A: recommended first lesson opens a real lesson run and '
      'session before its first assessed decision', (tester) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    final out = await casualFirstDecision(tester, sink);
    final saved = out['saved']! as Map<String, dynamic>;
    final records = (saved['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>();
    expect(records, hasLength(4));
    final first = records.last;
    expect(first['taskId'], 'actions_legal_context');
    expect(first['isCorrect'], false);
    expect(first['runKind'], 'lesson');
    expect(first['startedBy'], 'placement_recommendation');
    expect(first['runId'], isNotEmpty);
    expect(first['runId'], isNot(records.first['runId']));
    expect(first['sessionId'], isNotEmpty);
    expect(first['assistanceKind'], 'none');
    expect(first['errorType'], 'misread_action_legality');
    // No duplicate lifecycle events; joined trace once per attempt.
    expect(sink.events.where((e) => e.name == 'session_start'), hasLength(1));
    expect(sink.events.where((e) => e.name == 'lesson_started'), hasLength(1));
    for (final r in records) {
      for (final name in const [
        'user_choice',
        'decision_made',
        'task_result',
      ]) {
        expect(
          sink.events
              .where(
                (e) =>
                    e.name == name && e.fields['attempt_id'] == r['recordId'],
              )
              .toList(),
          hasLength(1),
          reason: '$name for ${r['recordId']}',
        );
      }
    }
    // Restart preserves exactly what was recorded; nothing is backfilled.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await _mount(tester, fresh: false);
    final restarted = await _saved(tester);
    expect(
      restarted['learningEvidenceHistory'],
      saved['learningEvidenceHistory'],
    );
  });

  testWidgets('P1-B: first actual actions_legal_context decision is initial '
      'assessment, not unseen transfer from a diagnostic answer', (
    tester,
  ) async {
    final out = await casualFirstDecision(
      tester,
      Act0InMemoryTelemetrySinkV1(),
    );
    final records =
        ((out['saved']! as Map<String, dynamic>)['learningEvidenceHistory']
                as List)
            .cast<Map<String, dynamic>>();
    expect(records.last['taskId'], 'actions_legal_context');
    expect(records.last['reviewKind'], 'initialAssessment');
  });

  testWidgets('a wrong diagnostic answer keeps its repair intent and the '
      'Placement recommendation; only provenance is added', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _mount(tester, fresh: true);
    await _tapKey(tester, 'act0_shell_placement_intro_cta');
    for (final option in const ['friends', 'rules']) {
      await _tapKey(tester, 'act0_shell_placement_option_$option');
      await _tapKey(tester, 'act0_shell_placement_next_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
    for (var i = 0; i < 3; i++) {
      final o = _runner(
        tester,
      ).runner.options.firstWhere((o) => i == 0 ? !o.isCorrect : o.isCorrect);
      await _tapKey(
        tester,
        o.seatId == null
            ? 'act0_shell_option_${o.id}'
            : 'act0_shell_seat_tap_${o.seatId}',
      );
      await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_recommended');
    final m = await _saved(tester);
    final intents = (m['openRepairIntents'] as List).cast<Map>();
    expect(intents, hasLength(1));
    expect(intents.single['sourceTaskId'], 'what_poker_is_table_read_transfer');
    expect(intents.single['errorType'], 'confused_table_identity');
    expect(((m['multiRepairQueue'] as Map)['entries'] as List), hasLength(1));
    // Same recommendation as before the provenance correction (frozen 179105da).
    expect(m['selectedTaskId'], 'your_first_hand_preflop');
    expect(m['earnedXp'], 0);
    final records = (m['learningEvidenceHistory'] as List).cast<Map>();
    expect(records.first['isCorrect'], false);
    expect(records.every((r) => r['runKind'] == 'placement'), isTrue);
  });

  testWidgets('retake diagnostic keeps lesson-run boundaries, XP and earned '
      'work; new diagnostic answers are explicit assessment evidence', (
    tester,
  ) async {
    final raw =
        jsonDecode(File(_retakeFixture).readAsStringSync())
            as Map<String, dynamic>;
    SharedPreferences.setMockInitialValues(<String, Object>{
      for (final e in raw.entries) e.key: e.value as Object,
    });
    await _mount(tester, fresh: false);
    final before = await _saved(tester);
    final beforeRecords = (before['learningEvidenceHistory'] as List).length;

    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    final tools = find.byKey(
      const Key('act0_shell_profile_first_start_tools_button'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      tools,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(tools);
    await tester.pumpAndSettle();
    await tester.tap(tools);
    await tester.pumpAndSettle();
    await _tapKey(tester, 'act0_shell_profile_retake_placement');
    await _diagnosticToResult(tester);
    await _tapKey(tester, 'act0_shell_placement_start_recommended');
    final after = await _saved(tester);

    expect(
      after['lessonRunEvidenceBoundaries'],
      before['lessonRunEvidenceBoundaries'],
      reason: 'a placement retake is not a lesson replay',
    );
    for (final key in const [
      'earnedXp',
      'completedTaskIds',
      'completedLessonIds',
      'openRepairIntents',
    ]) {
      expect(after[key], before[key], reason: '$key changed by retake');
    }
    final records = (after['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>();
    expect(records.length, beforeRecords + 3);
    for (final r in records.skip(beforeRecords)) {
      expect(r['runKind'], 'placement');
      expect(r['runId'], isNotEmpty);
      expect(r['sessionId'], isNotEmpty);
      expect(
        r['reviewKind'],
        'initialAssessment',
        reason:
            'a retake diagnostic answer is assessment, never unseenTransfer',
      );
    }
    expect(
      (before['learningEvidenceHistory'] as List),
      records.take(beforeRecords).toList(),
      reason: 'historical records are never rewritten or backfilled',
    );
  });

  testWidgets('D1: a retake diagnostic MISS inside a partly played lesson '
      'never becomes that lesson\'s completion-summary error', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await _mount(tester, fresh: true);
    for (final key in const [
      'act0_shell_placement_intro_cta',
      'act0_shell_placement_option_new',
      'act0_shell_placement_next_cta',
      'act0_shell_welcome_primary_cta',
    ]) {
      await _tapKey(tester, key);
    }
    final welcome = _runner(
      tester,
    ).runner.options.firstWhere((o) => o.isCorrect);
    await _tapKey(tester, 'act0_shell_option_${welcome.id}');
    await _tapKey(tester, 'act0_shell_welcome_primary_cta');
    await _tapKey(tester, 'act0_shell_main_cta');
    await _playW1(tester, stopAfter: 3); // genuinely partly played lesson
    expect(find.byType(Act0BlockCompletionShellV1), findsNothing);
    await _saved(tester);
    // Real cold restart, then a placement retake whose FIRST answer is wrong.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await _mount(tester, fresh: false);
    await _openRetake(tester);
    await _tapKey(tester, 'act0_shell_placement_intro_cta');
    for (final option in const ['friends', 'rules']) {
      await _tapKey(tester, 'act0_shell_placement_option_$option');
      await _tapKey(tester, 'act0_shell_placement_next_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
    for (var i = 0; i < 3; i++) {
      final o = _runner(
        tester,
      ).runner.options.firstWhere((o) => i == 0 ? !o.isCorrect : o.isCorrect);
      await _tapKey(
        tester,
        o.seatId == null
            ? 'act0_shell_option_${o.id}'
            : 'act0_shell_seat_tap_${o.seatId}',
      );
      await _tapKey(tester, 'act0_shell_feedback_continue_cta');
    }
    await _tapKey(tester, 'act0_shell_placement_start_recommended');
    final saved = await _saved(tester);
    expect(saved['selectedLessonId'], 'what_poker_is');
    final diagnostic = (saved['learningEvidenceHistory'] as List)
        .cast<Map>()
        .where((r) => r['runKind'] == 'placement')
        .toList();
    expect(diagnostic, hasLength(3));
    expect(diagnostic.first['isCorrect'], false);
    if (find
        .byKey(const Key('act0_shell_welcome_primary_cta'))
        .evaluate()
        .isNotEmpty) {
      await _tapKey(tester, 'act0_shell_welcome_primary_cta');
      final answer = _runner(
        tester,
      ).runner.options.firstWhere((o) => o.isCorrect);
      await _tapKey(tester, 'act0_shell_option_${answer.id}');
      await _tapKey(tester, 'act0_shell_welcome_primary_cta');
    }
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
      await _tapKey(tester, 'act0_shell_main_cta'); // Home primary CTA
    }
    expect(_runner(tester).selectedLessonId, 'what_poker_is');
    await _playW1(tester); // finish every remaining task correctly
    final shell = tester.widget<Act0BlockCompletionShellV1>(
      find.byType(Act0BlockCompletionShellV1),
    );
    expect(
      shell.summary.errorCount,
      0,
      reason: 'placement answers are not lesson-run assessment evidence',
    );
    expect(shell.summary.correctCount, shell.summary.taskCount);
  });
}

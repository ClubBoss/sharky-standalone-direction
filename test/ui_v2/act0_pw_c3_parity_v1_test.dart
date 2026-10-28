import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

const preview = bool.fromEnvironment('SHARKY_PW_C3_PREVIEW');
const settingsFamily =
    bool.fromEnvironment('SHARKY_YOU_V23_PREVIEW') &&
    bool.fromEnvironment('SHARKY_SETTINGS_QUIET_CONTROL_PREVIEW');
final receipts = <String, Object?>{};
final clock = Act0FixedUtcClockV1(DateTime.utc(2026, 10, 28, 12));

Future<void> tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: key);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  if (preview) {
    final rect = t.getRect(f);
    expect(rect.width, greaterThan(0), reason: key);
    expect(rect.height, greaterThan(0), reason: key);
    expect(
      const Rect.fromLTRB(0, 59, 393, 818).contains(rect.center),
      true,
      reason: key,
    );
    if (key.startsWith('act0_shell_placement_option_'))
      expect(rect.height, greaterThanOrEqualTo(44));
  }
  await t.tap(f);
  await t.pumpAndSettle();
  expect(t.takeException(), isNull, reason: key);
}

Future<void> mount(
  WidgetTester t, {
  bool fresh = true,
  bool reset = true,
  Map<String, Object>? initial,
  Act0InMemoryTelemetrySinkV1? sink,
  Act0ShellTabV1 tab = Act0ShellTabV1.home,
}) async {
  if (reset) SharedPreferences.setMockInitialValues(initial ?? {});
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: fresh,
        clock: clock,
        initialTab: tab,
        telemetrySink: sink,
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> saved(WidgetTester t) async {
  final dynamic shell = t.state(find.byType(Act0ShellPreviewScreenV1));
  shell.debugPersistProgressV1();
  await t.pump(const Duration(milliseconds: 300));
  final p = await SharedPreferences.getInstance();
  return jsonDecode(p.getString('act0_shell_progress_v1')!);
}

Map<String, Object?> runnerReceipt(Act0LessonRunnerShellV1 r) => {
  'lesson': r.selectedLessonId,
  'task': r.selectedTaskId,
  'question': r.runner.question,
  'phase': r.runner.phase.name,
  'options': [
    for (final o in r.runner.options)
      {'id': o.id, 'label': o.label, 'seat': o.seatId, 'correct': o.isCorrect},
  ],
};
Future<void> experience(WidgetTester t, String id) async {
  await tap(t, 'act0_shell_placement_intro_cta');
  for (final id in ['new', 'friends', 'watching', 'online'])
    expect(find.byKey(Key('act0_shell_placement_option_$id')), findsOneWidget);
  await tap(t, 'act0_shell_placement_option_$id');
  await tap(t, 'act0_shell_placement_next_cta');
}

Future<List<Object?>> checks(WidgetTester t, String pattern) async {
  final trace = <Object?>[];
  await tap(t, 'act0_shell_placement_start_diagnostic');
  for (var i = 0; i < 3; i++) {
    final r = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    trace.add(runnerReceipt(r));
    final o = r.runner.options.firstWhere(
      (o) => pattern[i] == 'u'
          ? o.id == 'not_sure_yet'
          : pattern[i] == '1'
          ? o.isCorrect
          : !o.isCorrect && o.id != 'not_sure_yet',
    );
    await tap(
      t,
      o.seatId == null
          ? 'act0_shell_option_${o.id}'
          : 'act0_shell_seat_tap_${o.seatId}',
    );
    await tap(t, 'act0_shell_feedback_continue_cta');
  }
  return trace;
}

Future<void> welcome(WidgetTester t, {bool wrong = true}) async {
  expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
  await tap(t, 'act0_shell_welcome_primary_cta');
  final r = t.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  expect(find.byKey(const Key('act0_shell_welcome_demo_spot')), findsOneWidget);
  final o = r.runner.options.firstWhere(
    (o) => wrong ? !o.isCorrect : o.isCorrect,
  );
  await tap(t, 'act0_shell_option_${o.id}');
  expect(
    find.byKey(const Key('act0_shell_feedback_continue_cta')),
    findsNothing,
  );
  expect(
    find.byKey(const Key('act0_shell_welcome_next_step_line')),
    findsOneWidget,
  );
  await tap(t, 'act0_shell_welcome_primary_cta');
}

void main() {
  tearDownAll(() {
    final out = Directory('output/pw_c3_20261028')..createSync(recursive: true);
    File(
      '${out.path}/parity_${preview ? 'on' : 'off'}.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(receipts));
  });
  testWidgets(
    'novice bypass, ungraded Welcome, Back, completion and ordinary restart',
    (t) async {
      await mount(t);
      final before = await saved(t);
      await experience(t, 'new');
      expect(find.byType(Act0PlacementShellV1), findsNothing);
      final bypass = await saved(t);
      expect(bypass['earnedXp'], 0);
      expect(bypass['learningEvidenceHistory'], isEmpty);
      await tap(t, 'act0_shell_welcome_primary_cta');
      final r = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      final trace = runnerReceipt(r);
      r.onBack();
      await t.pumpAndSettle();
      expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
      await welcome(t);
      final completed = await saved(t);
      expect(completed['earnedXp'], before['earnedXp']);
      expect(completed['learningEvidenceHistory'], isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('act0_welcome_completed_v1'), true);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      await mount(t, reset: false);
      final restarted = await saved(t);
      expect(find.byType(Act0WelcomeShellV1), findsNothing);
      expect(restarted['completedTaskIds'], completed['completedTaskIds']);
      receipts['novice'] = {
        'bypass': bypass,
        'demo': trace,
        'completed': completed,
        'restarted': restarted,
      };
    },
  );
  for (final option in ['rules', 'cards', 'decisions', 'board']) {
    testWidgets(
      'confidence $option preserves its real quick-check route and Back',
      (t) async {
        await mount(t);
        await experience(t, 'friends');
        expect(find.text('How should Sharky start?'), findsOneWidget);
        for (final id in ['rules', 'cards', 'decisions', 'board'])
          expect(
            find.byKey(Key('act0_shell_placement_option_$id')),
            findsOneWidget,
          );
        expect(
          find.byKey(const Key('act0_shell_placement_option_pressure')),
          findsNothing,
        );
        await tap(t, 'act0_shell_placement_option_$option');
        await tap(t, 'act0_shell_placement_next_cta');
        expect(
          find.byKey(const Key('act0_shell_placement_diagnostic_ready')),
          findsOneWidget,
        );
        expect(find.byType(Act0WelcomeShellV1), findsNothing);
        await tap(t, 'act0_shell_placement_back_arrow');
        final p = t.widget<Act0PlacementShellV1>(
          find.byType(Act0PlacementShellV1),
        );
        expect(p.currentQuestionIndex, 1);
        expect(p.selectedOptionIds['confidence'], {option});
        receipts['confidence_$option'] = await saved(t);
      },
    );
  }
  for (final pattern in ['000', '110', '111', 'uuu']) {
    for (final startZero in [false, true]) {
      testWidgets(
        'diagnostic $pattern result and ${startZero ? 'zero' : 'recommendation'} preserve evidence',
        (t) async {
          final sink = Act0InMemoryTelemetrySinkV1();
          await mount(t, sink: sink);
          final before = await saved(t);
          await experience(t, 'friends');
          await tap(t, 'act0_shell_placement_option_rules');
          await tap(t, 'act0_shell_placement_next_cta');
          final trace = await checks(t, pattern);
          final p = t.widget<Act0PlacementShellV1>(
            find.byType(Act0PlacementShellV1),
          );
          final r = p.result!;
          final result = {
            'level': r.level.name,
            'correct': r.diagnosticCorrect,
            'total': r.diagnosticTotal,
            'lesson': r.recommendedLessonId,
            'task': r.recommendedTaskId,
            'title': r.recommendedTitle,
            'reason': r.recommendedReason,
          };
          expect(r.diagnosticTotal, 3);
          expect(
            r.diagnosticCorrect,
            pattern.split('').where((c) => c == '1').length,
          );
          final assessed = await saved(t);
          expect(assessed['earnedXp'], 0);
          expect(assessed['completedTaskIds'], before['completedTaskIds']);
          final records = (assessed['learningEvidenceHistory'] as List)
              .cast<Map>();
          expect(records.length, 3);
          expect(
            records.every(
              (r) =>
                  r['runKind'] == 'placement' &&
                  (r['runId'] as String).isNotEmpty &&
                  (r['sessionId'] as String).isNotEmpty,
            ),
            true,
          );
          await tap(
            t,
            startZero
                ? 'act0_shell_placement_start_zero'
                : 'act0_shell_placement_start_recommended',
          );
          expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
          final routed = await saved(t);
          await welcome(t, wrong: pattern != '111');
          final completed = await saved(t);
          expect(completed['earnedXp'], 0);
          expect(
            completed['learningEvidenceHistory'],
            assessed['learningEvidenceHistory'],
          );
          receipts['${pattern}_${startZero ? 'zero' : 'recommended'}'] = {
            'result': result,
            'runners': trace,
            'assessed': assessed,
            'routed': routed,
            'completed': completed,
            'eventNames': [for (final e in sink.events) e.name],
          };
        },
      );
    }
  }
  testWidgets(
    'Settings replay and retake preserve already earned progress',
    (t) async {
      final raw =
          jsonDecode(
                File(
                  'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      await mount(
        t,
        fresh: false,
        initial: raw.cast<String, Object>(),
        tab: Act0ShellTabV1.profile,
      );
      final before = await saved(t);
      await tap(t, 'you_settings');
      await t.ensureVisible(find.text('Replay Welcome'));
      await t.tap(find.text('Replay Welcome'));
      await t.pumpAndSettle();
      await tap(t, 'act0_shell_welcome_close');
      expect(find.byKey(const Key('you_settings')), findsOneWidget);
      final replay = await saved(t);
      expect(replay['earnedXp'], before['earnedXp']);
      expect(replay['completedTaskIds'], before['completedTaskIds']);
      await tap(t, 'you_settings');
      await t.ensureVisible(find.text('Retake Placement'));
      await t.tap(find.text('Retake Placement'));
      await t.pumpAndSettle();
      await experience(t, 'friends');
      await tap(t, 'act0_shell_placement_option_rules');
      await tap(t, 'act0_shell_placement_next_cta');
      final trace = await checks(t, '111');
      await tap(t, 'act0_shell_placement_start_recommended');
      final after = await saved(t);
      for (final key in [
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'lessonRunEvidenceBoundaries',
        'openRepairIntents',
      ])
        expect(after[key], before[key], reason: key);
      receipts['retake'] = {
        'before': before,
        'replay': replay,
        'after': after,
        'runners': trace,
      };
    },
    skip: !settingsFamily,
  );
}

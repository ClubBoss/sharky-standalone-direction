import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S10 P1: Profile -> Intro & placement -> Retake -> diagnostic -> final route
// must never erase earned completion, XP, evidence or repair/review debt.
// State: exact native QA learner C (W1 complete, mapped W3 repair owed).
const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';
const _progressKey = 'act0_shell_progress_v1';
const _preserved = <String>[
  'completedTaskIds',
  'completedLessonIds',
  'earnedXp',
  'multiRepairQueue',
  'openRepairIntents',
  'retentionMemory',
  'reviewMistakeHistory',
  'reviewResolutionReceipts',
  'repairOutcomeProjection',
];

Object? _norm(Object? v) {
  if (v is List) {
    final items = v.map(_norm).toList();
    items.sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
    return items;
  }
  if (v is Map) {
    return {for (final k in v.keys.toList()..sort()) k: _norm(v[k])};
  }
  return v;
}

Future<Map<String, dynamic>> _saved() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _mount(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _retake(WidgetTester tester, {required bool fromZero}) async {
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
  await tester.tap(
    find.byKey(const Key('act0_shell_profile_retake_placement')),
  );
  await tester.pumpAndSettle();
  await _diagnosticToRoute(tester, fromZero: fromZero);
}

Future<void> _diagnosticToRoute(
  WidgetTester tester, {
  required bool fromZero,
}) async {
  await tester.tap(find.byKey(const Key('act0_shell_placement_intro_cta')));
  await tester.pumpAndSettle();
  for (final option in const ['friends', 'rules']) {
    final f = find.byKey(Key('act0_shell_placement_option_$option'));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
    final next = find.byKey(const Key('act0_shell_placement_next_cta'));
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  await tester.tap(
    find.byKey(const Key('act0_shell_placement_start_diagnostic')),
  );
  await tester.pumpAndSettle();
  for (var i = 0; i < 3; i++) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final correct = runner.runner.options.firstWhere((o) => o.isCorrect);
    final answer = correct.seatId == null
        ? Key('act0_shell_option_${correct.id}')
        : Key('act0_shell_seat_tap_${correct.seatId}');
    await tester.tap(find.byKey(answer));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
  }
  final route = find.byKey(
    Key(
      fromZero
          ? 'act0_shell_placement_start_zero'
          : 'act0_shell_placement_start_recommended',
    ),
  );
  await tester.ensureVisible(route);
  await tester.pumpAndSettle();
  await tester.tap(route);
  await tester.pumpAndSettle();
}

void main() {
  for (final fromZero in [false, true]) {
    testWidgets(
      'retake -> ${fromZero ? "start from zero" : "start recommended"} '
      'keeps earned completion, XP, evidence and repair debt',
      (tester) async {
        final raw =
            jsonDecode(File(_fixture).readAsStringSync())
                as Map<String, dynamic>;
        SharedPreferences.setMockInitialValues(<String, Object>{
          for (final e in raw.entries) e.key: e.value as Object,
        });
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _mount(tester);
        (tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
            .debugPersistProgressV1();
        await tester.pump(const Duration(milliseconds: 250));
        final before = await _saved();
        expect(before['completedTaskIds'] as List, isNotEmpty);
        expect(before['openRepairIntents'] as List, isNotEmpty);

        await _retake(tester, fromZero: fromZero);
        (tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
            .debugPersistProgressV1();
        await tester.pump(const Duration(milliseconds: 250));

        // Cold remount: dispose persists, then a fresh screen restores.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await _mount(tester);
        (tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
            .debugPersistProgressV1();
        await tester.pump(const Duration(milliseconds: 250));
        final after = await _saved();

        for (final key in _preserved) {
          expect(
            _norm(after[key]),
            _norm(before[key]),
            reason: '$key changed by retake',
          );
        }
        // Evidence is append-only: every earned record survives; the retake
        // diagnostic may only add its own new attempts.
        final evidenceBefore = (before['learningEvidenceHistory'] as List)
            .map(jsonEncode)
            .toSet();
        final evidenceAfter = (after['learningEvidenceHistory'] as List)
            .map(jsonEncode)
            .toSet();
        expect(evidenceAfter.containsAll(evidenceBefore), isTrue);
        // Never relaunch already-earned work as the next step.
        expect(
          (after['completedTaskIds'] as List),
          isNot(contains(after['selectedTaskId'])),
        );
        // Remeasured skills come from the new diagnostic only.
        expect(after['recentSkillGains'], isEmpty);
        // No duplicate earned credit.
        final ids = (after['completedTaskIds'] as List).cast<String>();
        expect(ids.toSet().length, ids.length);
      },
    );
  }

  testWidgets('genuine first install: placement still starts from an empty '
      'path (sample demo completion is cleared)', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _diagnosticToRoute(tester, fromZero: false);
    (tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
        .debugPersistProgressV1();
    await tester.pump(const Duration(milliseconds: 250));
    final saved = await _saved();
    expect(saved['completedTaskIds'], isEmpty);
    expect(saved['completedLessonIds'], isEmpty);
    expect(saved['earnedXp'], 0);
  });
}

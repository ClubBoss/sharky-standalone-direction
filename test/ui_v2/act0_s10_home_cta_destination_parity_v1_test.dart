import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S10 P1: the Home primary card must say what its CTA opens. State is native
// QA learner C's saved record. "Due" uses a fixed clock past the saved
// nextDueAtUtc: source-level eligibility evidence, NOT natural-time proof.
const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';
final _beforeDue = DateTime.utc(2026, 10, 12, 13);
final _afterDue = DateTime.utc(2026, 10, 14, 12);

Future<void> _pump(
  WidgetTester tester, {
  required DateTime now,
  required bool mappedRepairOwed,
}) async {
  final raw =
      jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
  final progress =
      jsonDecode(raw['act0_shell_progress_v1'] as String)
          as Map<String, dynamic>;
  if (!mappedRepairOwed) {
    progress['openRepairIntents'] = <Object>[];
    (progress['multiRepairQueue'] as Map<String, dynamic>)['entries'] =
        <Object>[];
  }
  raw['act0_shell_progress_v1'] = jsonEncode(progress);
  SharedPreferences.setMockInitialValues(<String, Object>{
    for (final e in raw.entries) e.key: e.value as Object,
  });
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: false,
        clock: Act0FixedUtcClockV1(now),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _ctaLabel(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byKey(const Key('act0_shell_main_cta')),
        matching: find.byType(Text),
      ),
    )
    .data!;

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

void main() {
  testWidgets('legitimately due recheck: card says review and opens it', (
    tester,
  ) async {
    await _pump(tester, now: _afterDue, mappedRepairOwed: false);
    expect(_ctaLabel(tester), 'Review now');
    expect(find.text('First Table Guide'), findsWidgets);
    expect(find.textContaining('ready for a spaced check'), findsWidgets);
    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();
    final runner = _runner(tester);
    expect(runner.selectedTaskId, 'first_table_guide_one_clear_choice');
    expect(runner.reviewKindId, 'spacedReview');
  });

  testWidgets('not due: card says continue and opens the Learn route', (
    tester,
  ) async {
    await _pump(tester, now: _beforeDue, mappedRepairOwed: false);
    expect(_ctaLabel(tester), 'Continue');
    expect(find.text('Review now'), findsNothing);
    await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
    await tester.pumpAndSettle();
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(find.text('Learn route'), findsOneWidget);
  });

  for (final due in [false, true]) {
    testWidgets(
      'pending mapped repair (${due ? "also due" : "not due"}): card says '
      'practice this spot and opens the mapped task',
      (tester) async {
        await _pump(
          tester,
          now: due ? _afterDue : _beforeDue,
          mappedRepairOwed: true,
        );
        expect(_ctaLabel(tester), 'Practice this spot');
        expect(find.text('Review now'), findsNothing);
        await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
        await tester.pumpAndSettle();
        expect(
          _runner(tester).selectedTaskId,
          'position_checkpoint_position_checkpoint_table_notice',
        );
      },
    );
  }
}

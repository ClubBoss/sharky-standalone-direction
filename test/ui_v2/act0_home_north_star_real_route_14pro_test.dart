import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';
final _beforeDue = DateTime.utc(2026, 10, 12, 13);
final _afterDue = DateTime.utc(2026, 10, 14, 12);

Future<void> _pump(
  WidgetTester tester, {
  required DateTime now,
  required bool repairOwed,
}) async {
  final raw =
      jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
  final progress =
      jsonDecode(raw['act0_shell_progress_v1'] as String)
          as Map<String, dynamic>;
  if (!repairOwed) {
    progress['openRepairIntents'] = <Object>[];
    (progress['multiRepairQueue'] as Map<String, dynamic>)['entries'] =
        <Object>[];
  }
  raw['act0_shell_progress_v1'] = jsonEncode(progress);
  SharedPreferences.setMockInitialValues(<String, Object>{
    for (final e in raw.entries) e.key: e.value as Object,
  });
  tester.view.physicalSize = const Size(393, 852);
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
  expect(
    find.byKey(const Key('act0_home_north_star_world_title')),
    findsOneWidget,
  );
}

String _ctaLabel(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byKey(const Key('act0_shell_main_cta')),
        matching: find.byType(Text),
      ),
    )
    .data!;

void main() {
  testWidgets(
    'actual due review CTA opens source-owned review task',
    (tester) async {
      await _pump(tester, now: _afterDue, repairOwed: false);
      expect(_ctaLabel(tester), 'Review now');
      expect(
        find.byKey(const Key('act0_home_north_star_active_stage_1')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, 'first_table_guide_one_clear_choice');
      expect(runner.reviewKindId, 'spacedReview');
    },
    skip: !kAct0HomeNorthStarPreviewV1,
  );

  testWidgets(
    'not due CTA opens Learn, not a fabricated review',
    (tester) async {
      await _pump(tester, now: _beforeDue, repairOwed: false);
      expect(_ctaLabel(tester), 'Continue');
      expect(
        find.byKey(const Key('act0_home_north_star_active_stage_2')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      expect(find.text('Learn route'), findsOneWidget);
    },
    skip: !kAct0HomeNorthStarPreviewV1,
  );

  for (final due in <bool>[false, true]) {
    testWidgets(
      'mapped repair CTA routes to original task; due is ' + due.toString(),
      (tester) async {
        await _pump(
          tester,
          now: due ? _afterDue : _beforeDue,
          repairOwed: true,
        );
        expect(_ctaLabel(tester), 'Practice this spot');
        expect(
          find.byKey(const Key('act0_home_north_star_active_stage_1')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
        await tester.pumpAndSettle();
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(
          runner.selectedTaskId,
          'position_checkpoint_position_checkpoint_table_notice',
        );
      },
      skip: !kAct0HomeNorthStarPreviewV1,
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_hybrid_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_v4.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_review_v4_test.dart' as review_fixtures;

Future<void> _mount(WidgetTester t, Act0ShellTabV1 tab) async {
  SharedPreferences.setMockInitialValues(
    review_fixtures.reviewV4Fixture('single'),
  );
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: tab,
        showPlacementOnStart: false,
        clock: Act0FixedUtcClockV1(review_fixtures.reviewV4Now),
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Future<void> _nav(WidgetTester t, String label) async {
  await t.tap(
    find.descendant(
      of: find.byKey(const Key('act0_shell_bottom_nav')),
      matching: find.text(label),
    ),
  );
  await t.pumpAndSettle();
}

Future<String?> _progress() async =>
    (await SharedPreferences.getInstance()).getString('act0_shell_progress_v1');

Future<void> _leaveRunner(WidgetTester t) async {
  final runner = find.byType(Act0LessonRunnerShellV1);
  expect(runner, findsOneWidget);
  t.widget<Act0LessonRunnerShellV1>(runner).onBack();
  await t.pumpAndSettle();
  expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
}

void main() {
  // Documented contract (act0_practice_hybrid_v1_test): leaving an unfinished
  // repair returns to Review, which owns the open repair, from any origin.
  testWidgets(
    'repair opened from Practice keeps the Review-owned return and item',
    (t) async {
      await _mount(t, Act0ShellTabV1.home);
      await _nav(t, 'Practice');
      final hub = t.widget<Act0PracticeHybridV1>(
        find.byType(Act0PracticeHybridV1),
      );
      expect(hub.recommendedGroupId, 'weak_spots');
      final before = await _progress();
      await t.tap(find.text('Practice this spot'));
      await t.pumpAndSettle();
      await _leaveRunner(t);
      expect(find.byType(Act0ReviewV4), findsOneWidget);
      // Abandoning the repair keeps the same open repair item, which Review
      // and Practice both offer with the same action label.
      expect(find.byKey(const Key('act0_shell_review_practice_cta')), findsOne);
      await _nav(t, 'Practice');
      expect(find.text('Practice this spot'), findsOneWidget);
      Object? intents(String? raw) =>
          (jsonDecode(raw!) as Map)['openRepairIntents'];
      expect(
        jsonEncode(intents(await _progress())),
        jsonEncode(intents(before)),
      );
    },
    skip: !kAct0PracticeHybridV1 || !kAct0ReviewV4Preview,
  );

  testWidgets(
    'repair opened from Review still returns to Review on back',
    (t) async {
      await _mount(t, Act0ShellTabV1.review);
      final cta = find.byKey(const Key('act0_shell_review_practice_cta'));
      expect(
        find.descendant(of: cta, matching: find.text('Practice this spot')),
        findsOneWidget,
      );
      await t.tap(cta);
      await t.pumpAndSettle();
      await _leaveRunner(t);
      expect(find.byType(Act0ReviewV4), findsOneWidget);
      expect(find.byKey(const Key('act0_shell_review_practice_cta')), findsOne);
    },
    skip: !kAct0ReviewV4Preview,
  );
}

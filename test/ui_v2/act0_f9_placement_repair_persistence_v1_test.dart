import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'act0_pw_c3_parity_v1_test.dart' as route;

const previewYou = bool.fromEnvironment('SHARKY_YOU_V23_PREVIEW');
const previewSettings = bool.fromEnvironment(
  'SHARKY_SETTINGS_QUIET_CONTROL_PREVIEW',
);
const sourceTask = 'what_poker_is_table_read_transfer';
final receipts = <String, Object?>{};
Map<String, Object> nativePrefs() => Map<String, Object>.from(
  jsonDecode(
        File(
          'test/ui_v2/fixtures/en_v1_f1_native_wrong_unsure_correct_prefs_v1.json',
        ).readAsStringSync(),
      )
      as Map,
);
Map<String, dynamic> progress(Map<String, Object> p) =>
    jsonDecode(p['act0_shell_progress_v1'] as String);
Map<String, Object> changed(void Function(Map<String, dynamic>) edit) {
  final prefs = nativePrefs();
  final p = progress(prefs);
  edit(p);
  prefs['act0_shell_progress_v1'] = jsonEncode(p);
  return prefs;
}

Future<void> mount(
  WidgetTester t, {
  Map<String, Object>? prefs,
  bool fresh = false,
}) async {
  if (prefs != null) SharedPreferences.setMockInitialValues(prefs);
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
        initialTab: Act0ShellTabV1.profile,
        showPlacementOnStart: fresh,
        clock: Act0FixedUtcClockV1(DateTime.utc(2026, 10, 29, 12)),
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Future<void> tab(WidgetTester t, String name) async {
  await t.tap(find.text(name).last);
  await t.pumpAndSettle();
}

Act0ReviewShellV1 review(WidgetTester t) =>
    t.widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1));
int youCount(WidgetTester t) => t
    .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
    .youRepairCount;
Future<Map<String, dynamic>> saved(WidgetTester t) async => route.saved(t);
Future<void> cold(WidgetTester t) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = <String, Object>{
    for (final k in prefs.getKeys()) k: prefs.get(k)!,
  };
  await t.pumpWidget(const SizedBox());
  await t.pumpAndSettle();
  SharedPreferences.setMockInitialValues(raw);
  await mount(t);
}

Future<void> expectOne(WidgetTester t) async {
  await tab(t, 'You');
  expect(youCount(t), 1);
  await tab(t, 'Review');
  expect(review(t).review.mistakes.map((m) => m.taskId), [sourceTask]);
  expect(review(t).dueReviewItems, isEmpty);
}

Future<void> live(WidgetTester t, String pattern) async {
  await mount(t, prefs: {}, fresh: true);
  await route.experience(t, 'friends');
  await route.tap(t, 'act0_shell_placement_option_rules');
  await route.tap(t, 'act0_shell_placement_next_cta');
  await route.checks(t, pattern);
  await route.tap(t, 'act0_shell_placement_start_zero');
  await route.welcome(t);
}

void sameTruth(Map<String, dynamic> before, Map<String, dynamic> after) {
  for (final k in [
    'schemaVersion',
    'earnedXp',
    'completedTaskIds',
    'completedLessonIds',
    'skippedTaskIds',
    'learningEvidenceHistory',
    'reviewMistakeHistory',
    'openRepairIntents',
    'multiRepairQueue',
    'repairOutcomeProjection',
    'reviewResolutionReceipts',
    'retentionMemory',
    'durableRetentionHistory',
    'lessonRunEvidenceBoundaries',
  ]) {
    expect(after[k], before[k], reason: k);
  }
}

void main() {
  testWidgets(
    'Replay and Placement retake retain repair identity without XP or record duplication',
    (t) async {
      await mount(t, prefs: nativePrefs());
      final before = await saved(t);
      await route.tap(t, 'you_settings');
      await t.ensureVisible(find.text('Replay Welcome'));
      await t.tap(find.text('Replay Welcome'));
      await t.pumpAndSettle();
      await route.tap(t, 'act0_shell_welcome_close');
      sameTruth(before, await saved(t));
      await route.tap(t, 'you_settings');
      await t.ensureVisible(find.text('Retake Placement'));
      await t.tap(find.text('Retake Placement'));
      await t.pumpAndSettle();
      await route.experience(t, 'friends');
      await route.tap(t, 'act0_shell_placement_option_rules');
      await route.tap(t, 'act0_shell_placement_next_cta');
      await route.checks(t, '111');
      await route.tap(t, 'act0_shell_placement_start_recommended');
      final after = await saved(t);
      for (final k in [
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'multiRepairQueue',
        'openRepairIntents',
      ]) {
        expect(after[k], before[k], reason: k);
      }
      final records = (after['learningEvidenceHistory'] as List).cast<Map>();
      expect(
        records.length,
        (before['learningEvidenceHistory'] as List).length + 3,
      );
      expect(records.map((r) => r['recordId']).toSet().length, records.length);
      await cold(t);
      await expectOne(t);
      sameTruth(after, await saved(t));
      receipts['retake'] = {
        'before': before,
        'after': after,
        'cold': await saved(t),
      };
    },
    skip: !previewYou || !previewSettings,
  );
  tearDownAll(() {
    final o = Directory('output/f9_20261029')..createSync(recursive: true);
    File(
      '${o.path}/test_receipts.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(receipts));
  });
  testWidgets(
    'cold native fixture restores the same unresolved Placement repair',
    (t) async {
      await mount(t, prefs: nativePrefs());
      await expectOne(t);
      final first = await saved(t);
      for (var i = 0; i < 2; i++) {
        await cold(t);
        await expectOne(t);
        sameTruth(first, await saved(t));
      }
      expect(find.text('No open repairs'), findsNothing);
      await tab(t, 'You');
      expect(find.text('1 earned'), findsOneWidget);
    },
    skip: !previewYou,
  );
  for (final entry in {
    'wrong': '011',
    'unsure': '1u1',
    'mixed': '0u1',
  }.entries) {
    testWidgets(
      'live ${entry.key} repair survives serialization and repeated cold state',
      (t) async {
        await live(t, entry.value);
        await expectOne(t);
        final before = await saved(t);
        expect(before['retentionMemory'], isEmpty);
        await tab(t, 'Review');
        final selected = review(t).review.mistakes.single.selectedLabel;
        await cold(t);
        final after = await saved(t);
        receipts[entry.key] = {
          'before': before,
          'after': after,
          'coldYouRepairCount': youCount(t),
        };
        await expectOne(t);
        expect(review(t).review.mistakes.single.selectedLabel, selected);
        sameTruth(before, after);
        await cold(t);
        await expectOne(t);
        sameTruth(before, await saved(t));
      },
      skip: !previewYou,
    );
  }
  testWidgets('history alone cannot invent debt when no active intent exists', (
    t,
  ) async {
    await mount(
      t,
      prefs: changed((p) {
        p['openRepairIntents'] = [];
        p['multiRepairQueue'] = {
          'schemaVersion': 1,
          'maxActiveItems': 3,
          'entries': [],
        };
      }),
    );
    expect(youCount(t), 0);
    await tab(t, 'Review');
    expect(review(t).review.mistakes, isEmpty);
    expect(review(t).dueReviewItems, isEmpty);
  });
  testWidgets(
    'active serialized intent remains authoritative without optional evidence history',
    (t) async {
      await mount(
        t,
        prefs: changed((p) {
          p['learningEvidenceHistory'] = [];
          p['reviewMistakeHistory'] = [];
        }),
      );
      await expectOne(t);
    },
  );
  testWidgets(
    'invalid diagnostic choice does not create a repair during hydration',
    (t) async {
      await mount(
        t,
        prefs: changed((p) {
          for (final x in p['openRepairIntents'] as List) {
            x['choiceId'] = 'not_a_source_choice';
          }
          for (final x in (p['multiRepairQueue'] as Map)['entries'] as List) {
            x['repairIntent']['choiceId'] = 'not_a_source_choice';
          }
        }),
      );
      expect(youCount(t), 0);
      await tab(t, 'Review');
      expect(review(t).review.mistakes, isEmpty);
      expect(review(t).dueReviewItems, isEmpty);
    },
  );
  testWidgets('correct Placement and ungraded Welcome create no repair or XP', (
    t,
  ) async {
    await live(t, '111');
    await tab(t, 'You');
    expect(youCount(t), 0);
    final p = await saved(t);
    expect(p['earnedXp'], 0);
    expect(p['retentionMemory'], isEmpty);
    await cold(t);
    expect(youCount(t), 0);
    sameTruth(p, await saved(t));
  });
  testWidgets('completed source repair does not reopen after restart', (
    t,
  ) async {
    // One actual persisted Placement miss; repair is then completed through the
    // existing source callbacks, never by toggling a completion flag.
    await live(t, '011');
    await tab(t, 'Review');
    final s = review(t);
    s.onFixMistake!(s.review.mistakes.single);
    await t.pumpAndSettle();
    for (
      var i = 0;
      i < 12 && find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty;
      i++
    ) {
      final r = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      switch (r.runner.phase) {
        case Act0LessonPhaseV1.theory:
          r.onContinueTheory();
        case Act0LessonPhaseV1.drill:
          r.onChooseOption(r.runner.options.firstWhere((o) => o.isCorrect));
        case Act0LessonPhaseV1.review:
          r.onContinueReview();
      }
      await t.pumpAndSettle();
      final dynamic shell = t.state(find.byType(Act0ShellPreviewScreenV1));
      if (shell.debugOpenRepairIntentCountV1() == 0) break;
    }
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
      t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .onBack();
      await t.pumpAndSettle();
    }
    await tab(t, 'Review');
    expect(review(t).review.mistakes, isEmpty);
    final before = await saved(t);
    await cold(t);
    expect(youCount(t), 0);
    await tab(t, 'Review');
    expect(review(t).review.mistakes, isEmpty);
    expect(review(t).dueReviewItems, isEmpty);
    sameTruth(before, await saved(t));
    receipts['completedRepair'] = {'before': before, 'after': await saved(t)};
  });
}

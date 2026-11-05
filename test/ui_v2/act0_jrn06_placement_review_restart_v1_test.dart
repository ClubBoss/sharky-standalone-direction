// PREPARATION ONLY / NOT RUN. No product, native or original-DoD PASS claimed.
// Prepared against main 198fefc7ab7c75eeacb87d6fffee0f6aee1d82a4.
// Reuses the ordinary first-install route from
// act0_s11_placement_provenance_v1_test.dart. This is a widget host remount,
// not an application-process restart or native persistence proof.
// After the assigned writer places this file in test/ui_v2/, run separately:
// flutter test test/ui_v2/act0_jrn06_placement_review_restart_v1_test.dart
// flutter test --dart-define=SHARKY_ACADEMY_REVIEW_PREVIEW=true
//   test/ui_v2/act0_jrn06_placement_review_restart_v1_test.dart
// Expected source-derived RED: retained placement debt loses its Review CTA
// on remount. Actual outcome, including setup failures, must be recorded.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
const _sourceTask = 'what_poker_is_table_read_transfer';
const _preservedKeys = <String>[
  'openRepairIntents',
  'multiRepairQueue',
  'multiRepairQueueOrder',
  'learningEvidenceHistory',
  'learningEvidenceLineage',
  'reviewMistakeHistory',
  'reviewResolutionReceipts',
  'repairOutcomeProjection',
  'completedTaskIds',
  'completedLessonIds',
  'skippedTaskIds',
  'earnedXp',
  'retentionMemory',
  'durableRetentionHistory',
];

String get _repairCtaKey => act0AcademyReviewPreviewV1
    ? 'act0_academy_review_leaf_repair_cta'
    : 'act0_shell_review_practice_cta';

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

dynamic _host(WidgetTester tester) =>
    tester.state(find.byType(Act0ShellPreviewScreenV1));

Map<String, Object?> _liveContracts(WidgetTester tester) => {
  // Existing observation-only APIs: never reload, persist or mutate state.
  'intent': _host(tester).debugOpenRepairIntentPayloadForSourceTaskV1(_sourceTask),
  'intentCount': _host(tester).debugOpenRepairIntentCountV1(),
  'outcomes': _host(tester).debugRepairOutcomeProjectionPayloadV1(),
  'retention': _host(tester).debugDurableRetentionPayloadV1(),
};

Future<void> _tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget, reason: key);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _mount(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(key: UniqueKey()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openReview(WidgetTester tester) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Review'),
  );
  expect(tab, findsOneWidget);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  // Observe the ordinary save; do not call a debug persist/state hook.
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 250));
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_progressKey);
  expect(raw, isNotNull, reason: 'The ordinary route must persist itself.');
  return jsonDecode(raw!) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _rows(Map<String, dynamic> saved, String key) =>
    (saved[key] as List).cast<Map<String, dynamic>>();

Future<void> _placementToReview(
  WidgetTester tester,
  List<String> choices,
) async {
  await _tapKey(tester, 'act0_shell_placement_intro_cta');
  for (final option in const ['friends', 'rules']) {
    await _tapKey(tester, 'act0_shell_placement_option_$option');
    await _tapKey(tester, 'act0_shell_placement_next_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_diagnostic');
  for (final choice in choices) {
    expect(_runner(tester).selectedTaskId, _sourceTask);
    await _tapKey(tester, 'act0_shell_option_$choice');
    await _tapKey(tester, 'act0_shell_feedback_continue_cta');
  }
  await _tapKey(tester, 'act0_shell_placement_start_recommended');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  // Same source-owned Welcome option lookup as the existing provenance test;
  // selection still occurs by tapping its rendered button, not a callback.
  final answer = _runner(tester).runner.options.firstWhere((o) => o.isCorrect);
  await _tapKey(tester, 'act0_shell_option_${answer.id}');
  await _tapKey(tester, 'act0_shell_welcome_primary_cta');
  await _tapKey(tester, 'act0_shell_runner_back');
  await _openReview(tester);
}

List<Act0MistakeCardV1> _reviewMistakes(WidgetTester tester) {
  if (act0AcademyReviewPreviewV1) {
    expect(find.byType(Act0AcademyReviewLeafV1), findsOneWidget);
    final input = tester
        .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
        .input;
    expect(input.dueItems, isEmpty, reason: 'Placement is not elapsed review.');
    return input.openMistakes;
  }
  expect(find.byType(Act0ReviewShellV1), findsOneWidget);
  final review = tester.widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1));
  expect(review.dueReviewItems, isEmpty);
  return review.review.mistakes;
}

Future<void> _expectRepairCta(
  WidgetTester tester, {
  required String? choice,
}) async {
  final mistakes = _reviewMistakes(tester);
  final cta = find.byKey(Key(_repairCtaKey));
  if (choice == null) {
    expect(mistakes, isEmpty);
    expect(cta, findsNothing, reason: 'No miss must not invent repair debt.');
    return;
  }
  expect(mistakes, hasLength(1), reason: 'The saved placement miss is open.');
  expect(mistakes.single.taskId, _sourceTask);
  expect(mistakes.single.selectedOptionId, choice);
  expect(
    mistakes.single.betterLabel,
    choice == 'hero_private_cards' ? 'Board cards' : 'Check',
    reason: 'Keep the diagnostic answer context, not a different task answer.',
  );
  expect(cta, findsOneWidget);
  await tester.ensureVisible(cta);
  await tester.pumpAndSettle();
  expect(tester.widget<FilledButton>(cta).onPressed, isNotNull);
  expect(cta.hitTestable(), findsOneWidget);
}

Future<void> _launchAndCancelRepair(
  WidgetTester tester,
  Map<String, dynamic> intent,
  String choice,
) async {
  // Authored mappings in act0FirstValueSameSignalRepMappingV1: board_cards
  // -> board_count; No bet yet -> no_bet_yet/action_read -> check_drill.
  final boardMiss = choice == 'hero_private_cards';
  final target = <String, String>{
    'targetWorldId': 'world_1',
    'targetLessonId': boardMiss ? 'cards_ranks_suits' : 'fold_check_call_raise',
    'targetTaskId': boardMiss
        ? 'cards_ranks_suits_board_count'
        : 'actions_check_drill',
  };
  expect(intent['sourceWorldId'], 'world_1');
  expect(intent['sourceLessonId'], 'what_poker_is');
  expect(intent['sourceTaskId'], _sourceTask);
  for (final field in target.keys) {
    expect(intent[field], target[field], reason: 'Authored $field mapping.');
  }
  await _tapKey(tester, _repairCtaKey);
  final runner = _runner(tester);
  expect(runner.selectedWorldId, intent['targetWorldId']);
  expect(runner.selectedLessonId, intent['targetLessonId']);
  expect(runner.selectedTaskId, intent['targetTaskId']);
  final active = _host(tester).debugActiveRepairContextPayloadV1();
  expect(active['sourceTaskId'], intent['sourceTaskId']);
  expect(active['repairTaskId'], intent['targetTaskId']);
  await _tapKey(tester, 'act0_shell_runner_back');
  await _expectRepairCta(tester, choice: choice);
  expect(
    _host(tester).debugOpenRepairIntentPayloadForSourceTaskV1(_sourceTask),
    equals(intent),
    reason: 'Back without an answer preserves the same unresolved occurrence.',
  );
}

void main() {
  setUp(() {
    // The only storage initialization. All later state comes from UI actions.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  for (final miss in const <String?>[
    'hero_private_cards',
    'not_sure_yet',
    null,
  ]) {
    final label = miss ?? 'all_correct_negative_control';
    testWidgets('JRN-06 placement $label remains truthful after host remount', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      await _mount(tester);
      final choices = <String>[
        'two_three_six',
        miss == 'hero_private_cards' ? 'hero_private_cards' : 'board_cards',
        miss == 'not_sure_yet' ? 'not_sure_yet' : 'check',
      ];
      await _placementToReview(tester, choices);
      final before = await _saved(tester);
      final liveBefore = _liveContracts(tester);
      await _expectRepairCta(tester, choice: miss);

      final diagnostic = _rows(before, 'learningEvidenceHistory')
          .where((record) => record['runKind'] == 'placement')
          .toList(growable: false);
      expect(diagnostic, hasLength(3));
      expect(diagnostic.map((record) => record['choiceId']), choices);
      expect(
        diagnostic.where((record) => record['isCorrect'] == false),
        hasLength(miss == null ? 0 : 1),
      );
      final intents = _rows(before, 'openRepairIntents');
      final history = _rows(before, 'reviewMistakeHistory');
      expect(intents, hasLength(miss == null ? 0 : 1));
      if (miss == null) {
        expect(history, isEmpty);
      } else {
        expect(intents.single['sourceTaskId'], _sourceTask);
        expect(intents.single['choiceId'], miss);
        final occurrence = history.singleWhere(
          (record) => record['selectedId'] == miss,
        );
        expect(occurrence['sourceTaskId'], _sourceTask);
        expect(intents.single['repairOccurrenceId'], isNotEmpty);
        expect(occurrence['sourceDecisionId'], intents.single['repairOccurrenceId']);
        expect(
          occurrence['expectedId'],
          miss == 'hero_private_cards' ? 'board_cards' : 'check',
        );
      }
      expect(before['earnedXp'], 0);
      expect(before['completedTaskIds'], isEmpty);
      expect(before['completedLessonIds'], isEmpty);
      expect(
        _rows(before, 'retentionMemory').where((r) => r['taskId'] == _sourceTask),
        isEmpty,
        reason: 'Placement debt is valid without a retention-memory row.',
      );
      expect(
        jsonEncode(before['durableRetentionHistory']),
        isNot(contains(_sourceTask)),
        reason: 'An assessment alone must not create retention proof or due.',
      );

      // Dispose the real host, preserving the exact same preferences. No
      // state, route, curriculum, grade, elapsed-time or progress injection.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _mount(tester);
      await _openReview(tester);
      expect(_liveContracts(tester), equals(liveBefore));
      // Inspect the restored UI, not unchanged pre-remount preference bytes.
      await _expectRepairCta(tester, choice: miss);
      if (miss != null) {
        await _launchAndCancelRepair(tester, intents.single, miss);
        expect(_liveContracts(tester), equals(liveBefore));
      }
      // A second ordinary dispose calls the host's production save. Read only
      // after that flush, so discarded in-memory data cannot hide in old bytes.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final after = await _saved(tester);
      for (final key in _preservedKeys) {
        expect(after[key], equals(before[key]), reason: 'Preserve $key.');
      }
      expect(tester.takeException(), isNull);
    });
  }
}

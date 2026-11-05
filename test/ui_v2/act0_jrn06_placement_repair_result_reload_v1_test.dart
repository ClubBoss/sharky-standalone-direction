// Guards Placement-directed repair result/return and host-reload truth.
// Uses fresh real UI choices; host remount is not native process restart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(
  key: _progressKey,
  isValidPayload: (_) => true,
);
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
  'intent': _host(
    tester,
  ).debugOpenRepairIntentPayloadForSourceTaskV1(_sourceTask),
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
  final review = tester.widget<Act0ReviewShellV1>(
    find.byType(Act0ReviewShellV1),
  );
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

Future<void> _advanceToAnswer(WidgetTester tester) async {
  for (var n = 0; n < 16; n++) {
    final buttons = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('act0_shell_option_'),
    );
    if (buttons.evaluate().isNotEmpty) return;
    var advanced = false;
    for (final key in const [
      'act0_shell_runner_primary_cta',
      'act0_shell_continue_cta',
      'act0_shell_theory_continue_cta',
    ]) {
      if (find.byKey(Key(key)).evaluate().isNotEmpty) {
        await _tapKey(tester, key);
        advanced = true;
        break;
      }
    }
    expect(
      advanced,
      isTrue,
      reason: 'Actual repair route must reach an answer.',
    );
  }
  fail('No answer after bounded teaching navigation.');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));
  for (final miss in ['hero_private_cards', 'not_sure_yet']) {
    for (final mode in ['independent', 'wrong', 'assisted']) {
      testWidgets('Placement Review $miss $mode result return and host reload', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
        addTearDown(tester.view.reset);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await _store.flush();
        });
        await _mount(tester);
        await _placementToReview(tester, [
          'two_three_six',
          miss == 'hero_private_cards' ? miss : 'board_cards',
          miss == 'not_sure_yet' ? miss : 'check',
        ]);
        final initial = await _saved(tester);
        final intent = _rows(initial, 'openRepairIntents').single;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _store.flush();
        await _mount(tester);
        await _openReview(tester);
        await _expectRepairCta(tester, choice: miss);
        await _launchAndCancelRepair(tester, intent, miss);
        await _tapKey(tester, _repairCtaKey);
        final target = intent['targetTaskId'];
        expect(_runner(tester).selectedTaskId, target);
        await _advanceToAnswer(tester);
        if (mode == 'assisted') {
          await _tapKey(tester, 'act0_shell_theory_recall_cta');
          await _tapKey(tester, 'act0_shell_theory_recall_close_cta');
        }
        final option = _runner(tester).runner.options.firstWhere(
          (o) => mode == 'wrong' ? !o.isCorrect : o.isCorrect,
        );
        await _tapKey(tester, 'act0_shell_option_${option.id}');
        expect(
          find.byKey(const Key('act0_shell_feedback_card')),
          findsOneWidget,
        );
        await _tapKey(tester, 'act0_shell_feedback_continue_cta');
        var returnKind = 'feedback_continue_to_review';
        if (mode == 'wrong' &&
            target == 'actions_check_drill' &&
            find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
          // This authored action sequence deliberately enters inline repair
          // after a wrong decision. Back is cancellation, not successful proof.
          expect(_runner(tester).selectedTaskId, target);
          expect(_host(tester).debugPhaseV1(), 'drill');
          await _tapKey(tester, 'act0_shell_runner_back');
          returnKind = 'cancel_from_inline_action_repair';
        }
        _reviewMistakes(tester);
        final after = await _saved(tester);
        final records = _rows(after, 'learningEvidenceHistory');
        final repair = records
            .where((r) => r['taskId'] == target && r['runKind'] != 'placement')
            .last;
        expect(
          records,
          hasLength(_rows(initial, 'learningEvidenceHistory').length + 1),
          reason: 'Exactly one real repair answer was submitted.',
        );
        expect(repair['runKind'], 'repair');
        expect(repair['choiceId'], option.id);
        final observations = {
          'miss': miss,
          'mode': mode,
          'returnKind': returnKind,
          'academy': act0AcademyReviewPreviewV1,
          'intent': intent,
          'initial': initial,
          'repair': repair,
          'after': after,
        };
        final folder = Directory('output/reviewvis/captured-v3');
        folder.createSync(recursive: true);
        File(
          '${folder.path}/${act0AcademyReviewPreviewV1 ? "on" : "off"}_${miss}_$mode.json',
        ).writeAsStringSync(jsonEncode(observations));
        print(
          'REVIEWVIS_OBSERVATION ${jsonEncode({'miss': miss, 'mode': mode, 'repair': repair, 'intents': after['openRepairIntents'], 'outcomes': after['repairOutcomeProjection'], 'receipts': after['reviewResolutionReceipts'], 'xp': after['earnedXp'], 'completed': after['completedTaskIds']})}',
        );
        expect(repair['isCorrect'], mode != 'wrong');
        expect(
          repair['assistanceKind'],
          mode == 'assisted' ? 'quickHint' : 'none',
        );
        for (final record in _rows(initial, 'learningEvidenceHistory')) {
          expect(
            records.singleWhere((r) => r['recordId'] == record['recordId']),
            equals(record),
            reason: 'Original Placement provenance must survive repair.',
          );
        }
        final completedBefore = (initial['completedTaskIds'] as List)
            .cast<String>();
        final completedAfter = (after['completedTaskIds'] as List)
            .cast<String>();
        final newlyCompleted = completedAfter.toSet().difference(
          completedBefore.toSet(),
        );
        expect(completedAfter, containsAll(completedBefore));
        expect(
          newlyCompleted,
          everyElement(target),
          reason:
              'A repair may only complete its actual target, never the Placement source or another task.',
        );
        final deltaXp =
            (after['earnedXp'] as int) - (initial['earnedXp'] as int);
        if (mode != 'independent') {
          expect(
            newlyCompleted,
            isEmpty,
            reason:
                'Wrong or helped directed repair cannot grant independent completion.',
          );
          expect(deltaXp, 0);
        } else {
          // This checks award identity and once-only amount, not independent
          // verification of ordinary curriculum availability.
          expect(
            deltaXp,
            newlyCompleted.isEmpty ? 0 : (miss == 'hero_private_cards' ? 6 : 5),
          );
        }
        expect(completedAfter, isNot(contains(_sourceTask)));
        expect(
          after['completedLessonIds'],
          equals(initial['completedLessonIds']),
          reason: 'One directed repair must not fabricate lesson completion.',
        );
        final sourceDebt = _host(
          tester,
        ).debugOpenRepairIntentPayloadForSourceTaskV1(_sourceTask);
        expect(
          sourceDebt == null,
          mode == 'independent',
          reason: 'Only independent correct repair resolves the source debt.',
        );
        final live = _liveContracts(tester);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _store.flush();
        await _mount(tester);
        await _openReview(tester);
        expect(_liveContracts(tester), equals(live));
        if (mode != 'independent') {
          expect(
            _reviewMistakes(tester).any((m) => m.taskId == _sourceTask),
            isTrue,
            reason:
                'Failed or helped source debt remains visible after restore.',
          );
          expect(find.byKey(Key(_repairCtaKey)), findsOneWidget);
        } else {
          expect(
            _reviewMistakes(tester).where((m) => m.taskId == _sourceTask),
            isEmpty,
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _store.flush();
        final restored = await _saved(tester);
        for (final key in _preservedKeys) {
          expect(
            restored[key],
            equals(after[key]),
            reason: 'Post-result restore preserves $key.',
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

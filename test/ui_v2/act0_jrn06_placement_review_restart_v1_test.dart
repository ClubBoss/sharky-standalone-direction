// SIMULATED placement -> typed teaching entry -> Review -> widget host remount.
// Two current diagnostic goals may navigate to existing teaching tasks. Their
// original miss stays open; guided answers retain actual grades but grant no
// repair, curriculum, XP, skill, due, retention or independent proof credit.
// Widget remount is not native restart, independent application or elapsed proof.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/act0_shell_presentation_finders_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
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
      home: Act0ShellPreviewScreenV1(
        debugLegacyPlacementOnStart: true,
        key: UniqueKey(),
      ),
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
  for (var index = 0; index < choices.length; index++) {
    final choice = choices[index];
    if (index > 0) {
      final source = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .singleWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .singleWhere((task) => task.taskId == _sourceTask);
      final rendered = act0PlacementDiagnosticFingerprintV1(
        worldId: 'world_1',
        lessonId: 'what_poker_is',
        diagnosticVariantId: index == 1
            ? 'board_private_cards'
            : 'action_basics',
        sourceTask: source,
        diagnosticRunner: _runner(tester).runner,
      );
      expect(rendered, isNotNull);
      expect(
        rendered,
        _host(tester).debugCurrentDiagnosticVariantFingerprintV1(),
        reason: 'Capture the actual displayed prechoice variant.',
      );
    }
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

Future<void> _launchAndCancelPlacementTeaching(
  WidgetTester tester,
  Map<String, dynamic> intent,
  String choice,
) async {
  final board = choice == 'hero_private_cards';
  final target = board
      ? 'cards_ranks_suits_private_board'
      : 'actions_check_drill';
  final lesson = board ? 'cards_ranks_suits' : 'fold_check_call_raise';
  expect(intent['sourceWorldId'], 'world_1');
  expect(intent['sourceLessonId'], 'what_poker_is');
  expect(intent['sourceTaskId'], _sourceTask);
  expect(intent['choiceId'], choice);
  expect(intent['targetWorldId'], 'world_1');
  expect(intent['targetLessonId'], lesson);
  expect(intent['targetTaskId'], target);
  for (final key in [
    'goalId',
    'relationId',
    'sourceFingerprint',
    'targetFingerprint',
  ]) {
    expect(intent[key], isNotEmpty, reason: 'Fresh miss captures $key.');
  }
  expect(intent['relationRevision'], greaterThan(0));
  final before = _liveContracts(tester);
  await _tapKey(tester, _repairCtaKey);
  expect(_runner(tester).selectedWorldId, 'world_1');
  expect(_runner(tester).selectedLessonId, lesson);
  expect(_runner(tester).selectedTaskId, target);
  expect(intent['relationRevision'], board ? 1 : 2);
  if (!board) {
    final table = _runner(tester).runner.table;
    expect(table.heroCards.map((c) => c.label), ['9c', '8d']);
    expect(table.boardCards.map((c) => c.label), ['Ah', '7c', '2d']);
    expect(table.potLabel, 'Pot 4.5 BB');
    expect(table.toCallLabel, isEmpty);
    expect(table.decisionSeatId, 'btn');
  }

  expect(_host(tester).debugDiagnosticLearningEntryPayloadV1(), {
    'sourceOccurrenceId': intent['repairOccurrenceId'],
    'sourceTaskId': _sourceTask,
    'targetWorldId': 'world_1',
    'targetLessonId': lesson,
    'targetTaskId': target,
    'goalId': intent['goalId'],
    'evidenceClass': act0DiagnosticLearningEntryRunKindV1,
  });
  expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
  await _tapKey(tester, 'act0_shell_runner_back');
  expect(_host(tester).debugDiagnosticLearningEntryPayloadV1(), isEmpty);
  expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
  expect(_liveContracts(tester), before);
  await _expectRepairCta(tester, choice: choice);
  expect(
    _host(tester).debugOpenRepairIntentPayloadForSourceTaskV1(_sourceTask),
    equals(intent),
    reason: 'Cancel preserves the same unresolved source occurrence.',
  );
}

void _referenceSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(_store.flush);
  });
}

Future<Map<String, dynamic>> _durable(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.runAsync(_store.flush);
  final raw = await _store.load();
  expect(raw, isNotNull);
  return jsonDecode(raw!) as Map<String, dynamic>;
}

Future<void> _advanceTeachingAnswer(WidgetTester tester) async {
  for (var step = 0; step < 16; step++) {
    final value = _runner(tester);
    final visible = value.runner.options.any(
      (option) => find
          .byKey(Key('act0_shell_option_${option.id}'))
          .evaluate()
          .isNotEmpty,
    );
    if (visible) {
      // Reuse the admitted Foundation route's source-plan/public-ready wait.
      final plan = act0TableChoreographyPlanForTableV1(value.runner.table);
      final replay = act0StreetReplayFromTableV1(value.runner.table);
      if (plan != null && replay?.isConsumerSafe == true) {
        final ready = find.byKey(const Key('act0_shell_street_replay_inline'));
        for (
          var beat = 0;
          beat < plan.beats.length + 2 && ready.evaluate().isEmpty;
          beat++
        ) {
          expect(_runner(tester).runner.selectedOptionId, isNull);
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(ready, findsOneWidget);
      }
      expect(_runner(tester).runner.selectedOptionId, isNull);
      await tester.pumpAndSettle();
      return;
    }
    final keys = [
      'act0_shell_runner_primary_cta',
      'act0_shell_continue_cta',
      'act0_shell_theory_continue_cta',
    ];
    final available = keys
        .where((key) => find.byKey(Key(key)).evaluate().isNotEmpty)
        .toList();
    expect(
      available,
      isNotEmpty,
      reason: 'Existing teaching route must reach an answer.',
    );
    await _tapKey(tester, available.first);
  }
  fail('No authored teaching decision after 16 ordinary steps.');
}

void _expectNoCredit(
  Map<String, dynamic> before,
  Map<String, dynamic> after, {
  required Map<String, String> normalSelection,
}) {
  final keys = <String>{
    ..._preservedKeys,
    'profileSkillValues',
    'recentSkillGains',
    'retentionSequence',
    'conceptFamilyStateHistory',
    'lastSessionLearnerState',
    'firstValueReturnCarry',
  }..removeAll({'learningEvidenceHistory', 'learningEvidenceLineage'});
  for (final key in keys) {
    expect(after[key], before[key], reason: 'Teaching must preserve $key.');
  }
  for (final key in ['selectedWorldId', 'selectedLessonId', 'selectedTaskId']) {
    expect(
      after[key],
      normalSelection[key],
      reason: 'Persist the live normal return $key.',
    );
  }
  expect(after['resumeInRunner'], isFalse);
  final oldRecords = _rows(before, 'learningEvidenceHistory');
  final current = _rows(after, 'learningEvidenceHistory');
  for (final row in oldRecords) {
    expect(
      current.singleWhere((r) => r['recordId'] == row['recordId']),
      row,
      reason: 'Preserve original record ${row['recordId']}.',
    );
  }
  expect(
    current.where((r) => r['runKind'] == 'placement').toList(),
    oldRecords.where((r) => r['runKind'] == 'placement').toList(),
  );
}

Future<void> _openNormalLearnTask(WidgetTester tester) async {
  final learn = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Learn'),
  );
  expect(learn, findsOneWidget);
  await tester.tap(learn);
  await tester.pumpAndSettle();
  await _tapKey(tester, 'act0_shell_current_mission_cta');
  expect(_host(tester).debugDiagnosticLearningEntryPayloadV1(), isEmpty);
  expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
}

Map<String, Object?> _runnerObservation(WidgetTester tester) {
  final value = _runner(tester);
  return {
    'world': value.selectedWorldId,
    'lesson': value.selectedLessonId,
    'task': value.selectedTaskId,
    'phase': value.runner.phase.name,
    'teachingStep': value.runner.teachingStepIndex,
    'choice': value.runner.selectedOptionId,
    'run': value.evidenceRunId,
    'nextOrder': value.evidenceNextOrder,
    'initialAssistance': value.initialChoiceAssistance.name,
  };
}

void main() {
  setUp(() {
    // The only storage initialization. All later state comes from UI actions.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  for (final miss in ['hero_private_cards', 'not_sure_yet']) {
    for (final mode in ['correct', 'wrong', 'quickHint']) {
      testWidgets(
        'JRN-06 $miss guided $mode keeps source debt and remounts without credit',
        (tester) async {
          _referenceSurface(tester);
          await _mount(tester);
          await _placementToReview(tester, [
            'two_three_six',
            miss == 'hero_private_cards' ? miss : 'board_cards',
            miss == 'not_sure_yet' ? miss : 'check',
          ]);
          final before = await _durable(tester);
          final originalLive = _liveContracts(tester);
          final intent = _rows(before, 'openRepairIntents').single;
          final originalRecords = _rows(before, 'learningEvidenceHistory');
          final oldIds = originalRecords.map((r) => r['recordId']).toSet();
          expect(
            originalRecords.where((r) => r['runKind'] == 'placement'),
            hasLength(3),
          );
          await _expectRepairCta(tester, choice: miss);
          final normalSelection = <String, String>{
            'selectedWorldId': _host(tester).debugSelectedWorldIdV1() as String,
            'selectedLessonId':
                _host(tester).debugSelectedLessonIdV1() as String,
            'selectedTaskId': _host(tester).debugSelectedTaskIdV1() as String,
          };
          await _tapKey(tester, _repairCtaKey);
          final target = miss == 'hero_private_cards'
              ? 'cards_ranks_suits_private_board'
              : 'actions_check_drill';
          final lesson = miss == 'hero_private_cards'
              ? 'cards_ranks_suits'
              : 'fold_check_call_raise';
          final expected = miss == 'hero_private_cards' ? 'board' : 'check';
          expect(_runner(tester).selectedTaskId, target);
          if (target == 'actions_check_drill') {
            expect(intent['relationRevision'], 2);
            final table = _runner(tester).runner.table;
            expect(table.heroCards.map((c) => c.label), ['9c', '8d']);
            expect(table.boardCards.map((c) => c.label), ['Ah', '7c', '2d']);
            expect(table.potLabel, 'Pot 4.5 BB');
            expect(table.toCallLabel, isEmpty);
            expect(table.decisionSeatId, 'btn');
          }

          expect(_host(tester).debugDiagnosticLearningEntryPayloadV1(), {
            'sourceOccurrenceId': intent['repairOccurrenceId'],
            'sourceTaskId': _sourceTask,
            'targetWorldId': 'world_1',
            'targetLessonId': lesson,
            'targetTaskId': target,
            'goalId': intent['goalId'],
            'evidenceClass': act0DiagnosticLearningEntryRunKindV1,
          });
          expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
          final entered = await _durable(tester);
          _expectNoCredit(before, entered, normalSelection: normalSelection);
          expect(
            entered['learningEvidenceHistory'],
            before['learningEvidenceHistory'],
          );
          await _advanceTeachingAnswer(tester);
          if (mode == 'quickHint') {
            expect(_runner(tester).theoryRecallStep, isNotNull);
            await _tapKey(tester, 'act0_shell_theory_recall_cta');
            expect(
              find.byKey(const Key('act0_shell_hint_body')),
              findsOneWidget,
            );
            await _tapKey(tester, 'act0_shell_theory_recall_close_cta');
          }
          final option = _runner(tester).runner.options.firstWhere(
            (o) => mode == 'wrong' ? !o.isCorrect : o.isCorrect,
          );
          final correct = _runner(
            tester,
          ).runner.options.singleWhere((o) => o.isCorrect);
          expect(correct.id, expected);
          await _tapKey(tester, 'act0_shell_option_${option.id}');
          expect(_runner(tester).runner.selectedOptionId, option.id);
          expect(
            find.byKey(const Key('act0_shell_feedback_card')),
            findsOneWidget,
          );
          final answered = await _durable(tester);
          _expectNoCredit(before, answered, normalSelection: normalSelection);
          final newRows = _rows(
            answered,
            'learningEvidenceHistory',
          ).where((r) => !oldIds.contains(r['recordId'])).toList();
          expect(newRows, hasLength(1));
          final raw = newRows.single;
          expect(
            _rows(answered, 'learningEvidenceHistory'),
            hasLength(originalRecords.length + 1),
          );
          expect(raw['worldId'], 'world_1');
          expect(raw['lessonId'], lesson);
          expect(raw['taskId'], target);
          expect(raw['sourceTaskId'], target);
          expect(raw['choiceId'], option.id);
          expect(raw['expectedChoiceId'], expected);
          expect(raw['isCorrect'], option.isCorrect);
          expect(
            raw['resultKind'],
            option.isCorrect
                ? 'correct'
                : option.quality == Act0FeedbackQualityV1.suboptimal
                ? 'suboptimal'
                : 'incorrect',
          );
          expect(
            raw['assistanceKind'],
            mode == 'quickHint' ? 'quickHint' : 'none',
          );
          expect(raw['runKind'], act0DiagnosticLearningEntryRunKindV1);
          expect(raw['startedBy'], 'placement_learning_entry');
          expect(raw['runId'], isNotEmpty);
          expect(raw['sessionId'], isNotEmpty);
          expect(
            raw['authoredSourceFingerprint'],
            act0CurrentAuthoredSourceFingerprintForIdentityV1(
              worldId: 'world_1',
              lessonId: lesson,
              taskId: target,
            ),
          );
          final parsed = Act0LearningEvidenceRecordV1.tryParse(raw)!;
          expect(parsed.isIndependentCorrect, isFalse);
          expect(parsed.isPlacementAssessment, isFalse);
          expect(parsed.isDiagnosticLearningEntry, isTrue);
          expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
          await _tapKey(tester, 'act0_shell_feedback_continue_cta');
          expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
          expect(
            _host(tester).debugDiagnosticLearningEntryPayloadV1(),
            isEmpty,
          );
          expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
          await _expectRepairCta(tester, choice: miss);
          expect(_liveContracts(tester), originalLive);
          final returned = await _durable(tester);
          _expectNoCredit(before, returned, normalSelection: normalSelection);
          expect(
            returned['learningEvidenceHistory'],
            answered['learningEvidenceHistory'],
          );
          expect(
            returned['pendingDecisionAssistance'],
            before['pendingDecisionAssistance'],
          );

          // Same durable store, ordinary dispose and Home-first remount.
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.runAsync(_store.flush);
          await _mount(tester);
          expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
          expect(
            act0ShellPresentationFinderV1('act0_shell_home_screen'),
            findsOneWidget,
          );
          expect(
            _host(tester).debugDiagnosticLearningEntryPayloadV1(),
            isEmpty,
          );
          final restored = await _durable(tester);
          _expectNoCredit(before, restored, normalSelection: normalSelection);
          expect(
            restored['learningEvidenceHistory'],
            returned['learningEvidenceHistory'],
          );
          expect(
            restored['learningEvidenceLineage'],
            returned['learningEvidenceLineage'],
          );
          await _openReview(tester);
          await _expectRepairCta(tester, choice: miss);
          expect(_liveContracts(tester), originalLive);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'JRN-06 old guided callbacks cannot mutate a later normal lesson run',
    (tester) async {
      _referenceSurface(tester);
      await _mount(tester);
      await _placementToReview(tester, [
        'two_three_six',
        'board_cards',
        'not_sure_yet',
      ]);
      await _expectRepairCta(tester, choice: 'not_sure_yet');
      await _tapKey(tester, _repairCtaKey);
      await _advanceTeachingAnswer(tester);
      final old = _runner(tester);
      expect(old.selectedTaskId, 'actions_check_drill');
      expect(old.evidenceRunId, isNotEmpty);
      expect(old.evidenceNextOrder, greaterThan(0));
      final option = old.runner.options.singleWhere((o) => o.isCorrect);
      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: old.runner,
        option: option,
        taskFamily: old.selectedTaskFamily,
      );
      expect(receipt, isNotNull);
      final validatedReceipt = receipt!;
      // Source-valid unique v3 completion for the old unanswered runner. It
      // cannot be rejected merely as an already recorded duplicate/incomplete ID.
      final staleId =
          'v3|${old.evidenceRunId}|${old.evidenceNextOrder}|'
          '${old.selectedWorldId}|${old.selectedLessonId}|${old.selectedTaskId}|actionList|${option.id}|1';
      final staleDecision = Act0CompletedDecisionV1(
        attemptKey: staleId,
        worldId: old.selectedWorldId,
        lessonId: old.selectedLessonId!,
        taskId: old.selectedTaskId!,
        sourceTaskId: old.selectedTaskId!,
        decisionKind: Act0CompletedDecisionKindV1.actionList,
        selectedId: option.id,
        expectedId: option.id,
        isCorrect: option.isCorrect,
        decisionTimeBucket: '3_to_10s',
        taskFamily: old.selectedTaskFamily,
        resultKind: 'correct',
        errorType: 'none',
        skillAtomId: validatedReceipt.skillAtomId,
        repairFocusId: validatedReceipt.sourceSignalId,
        missedSignalId: validatedReceipt.sourceSignalId,
        assistanceKind: Act0DecisionAssistanceV1.none,
      );
      expect(old.onCompletedDecision, isNotNull);
      expect(old.onChoiceAssistance, isNotNull);
      expect(old.onAssistanceExposureRequested, isNotNull);
      await _tapKey(tester, 'act0_shell_runner_back');
      expect(_host(tester).debugDiagnosticLearningEntryPayloadV1(), isEmpty);
      await _openNormalLearnTask(tester);
      expect(_runner(tester).evidenceRunId, isNot(old.evidenceRunId));
      final currentRunner = _runnerObservation(tester);
      final currentBytes = await _durable(tester);
      expect(
        _rows(
          currentBytes,
          'learningEvidenceHistory',
        ).where((r) => r['recordId'] == staleId),
        isEmpty,
      );
      Future<void> unchanged(String label, void Function() callback) async {
        callback();
        await tester.pumpAndSettle();
        expect(
          _runnerObservation(tester),
          currentRunner,
          reason: '$label current runner',
        );
        expect(_host(tester).debugDiagnosticLearningEntryPayloadV1(), isEmpty);
        expect(_host(tester).debugActiveRepairContextPayloadV1(), isEmpty);
        expect(
          await _durable(tester),
          currentBytes,
          reason: '$label durable payload',
        );
        expect(tester.takeException(), isNull);
      }

      await unchanged('late choose', () => old.onChooseOption(option));
      await unchanged(
        'late assistance',
        () => old.onChoiceAssistance!(Act0DecisionAssistanceV1.quickHint),
      );
      final exposure = await old.onAssistanceExposureRequested!(
        Act0DecisionAssistanceV1.quickHint,
      );
      expect(exposure, isFalse);
      await unchanged('late assistance exposure', () {});
      await unchanged(
        'late completion',
        () => old.onCompletedDecision!(staleDecision),
      );
      await unchanged('late theory continue', old.onContinueTheory);
      await unchanged('late feedback continue', old.onContinueReview);
    },
  );

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
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _store.flush();
      });
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
      expect(
        diagnostic.length,
        3,
        reason:
            'Distinct record IDs: ${diagnostic.map((r) => r['recordId']).toSet().length}; distinct run IDs: ${diagnostic.map((r) => r['runId']).toSet().length}',
      );
      expect(
        diagnostic.map((record) => record['taskId']),
        everyElement(_sourceTask),
      );
      final recordIds = diagnostic.map((record) => record['recordId']).toList();
      expect(recordIds, everyElement(isA<String>()));
      expect(recordIds.toSet(), hasLength(3));
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
        expect(
          occurrence['sourceDecisionId'],
          intents.single['repairOccurrenceId'],
        );
        expect(
          occurrence['expectedId'],
          miss == 'hero_private_cards' ? 'board_cards' : 'check',
        );
      }
      expect(before['earnedXp'], 0);
      expect(before['completedTaskIds'], isEmpty);
      expect(before['completedLessonIds'], isEmpty);
      expect(
        _rows(
          before,
          'retentionMemory',
        ).where((r) => r['taskId'] == _sourceTask),
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
        await _launchAndCancelPlacementTeaching(tester, intents.single, miss);
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

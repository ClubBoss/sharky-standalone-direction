import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Current, genuinely UI-earned vocabulary misses on the reviewed r2 private
// composition. Only preceding prerequisites are synthetic. No target attempt,
// historical hand, debt or evidence is seeded; no reseed occurs after boot.
// Vocabulary evidence is not poker repair/mastery; native/old-save proof is
// separate. Repeated feedback is not a new attempt; a fresh Learn entry is.
const _world = 'world_1';
const _lessonId = 'fold_check_call_raise';
const _key = 'act0_shell_progress_v1';
const _unavailable = 'act0_w1_historical_repair_unavailable';
const _protected = <String>[
  'earnedXp',
  'completedTaskIds',
  'completedLessonIds',
  'skippedTaskIds',
  'retentionSequence',
  'retentionMemory',
  'durableRetentionHistory',
  'reviewMistakeHistory',
  'reviewResolutionReceipts',
  'openRepairIntents',
  'multiRepairQueue',
  'multiRepairQueueOrder',
  'conceptFamilyStateHistory',
  'repairOutcomeProjection',
];

Act0LessonCardV1 get _lesson => Act0ShellStateV1.sample.lessonById(_lessonId);

List<Map<String, dynamic>> _records(
  Map<String, dynamic> saved,
  String taskId,
) => (saved['learningEvidenceHistory'] as List)
    .cast<Map<String, dynamic>>()
    .where((record) => record['taskId'] == taskId)
    .toList();

List<Map<String, Object?>> _canonicalRecords(Map<String, dynamic> saved) {
  expect(saved, contains('learningEvidenceLineage'));
  expect(saved['learningEvidenceLineage'], isNotNull);
  final history = Act0LearningEvidenceHistoryV1.restore(
    saved['learningEvidenceHistory'],
    saved['learningEvidenceLineage'],
  );
  expect(
    history,
    isNotNull,
    reason: 'Actual sealed recent + lineage must parse',
  );
  return history!.provenanceRecords
      .map((record) => record.toPayload())
      .toList();
}

void _diagnose(
  WidgetTester tester,
  String stage, {
  Map<String, dynamic>? saved,
}) {
  debugPrint(
    'PKR_WRONG_MATRIX ${jsonEncode(<String, Object?>{
      'stage': stage,
      'runners': tester.widgetList<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1)).map((widget) => <String, Object?>{'world': widget.selectedWorldId, 'lesson': widget.selectedLessonId, 'task': widget.selectedTaskId, 'phase': widget.runner.phase.name, 'choice': widget.runner.selectedOptionId, 'question': widget.runner.question, 'activeSeatId': widget.runner.table.activeSeatId}).toList(),
      'keys': tester.allWidgets.map((widget) => widget.key).whereType<ValueKey<String>>().map((key) => key.value).toList(),
      if (saved != null) 'saved': saved,
    })}',
  );
}

Act0LessonRunnerShellV1 _expectTask(
  WidgetTester tester,
  String taskId,
  Act0LessonPhaseV1 phase,
) {
  _diagnose(tester, '$taskId:expect-${phase.name}');
  final finder = find.byType(Act0LessonRunnerShellV1);
  expect(finder, findsOneWidget);
  final widget = tester.widget<Act0LessonRunnerShellV1>(finder);
  expect(widget.selectedWorldId, _world);
  expect(widget.selectedLessonId, _lessonId);
  expect(widget.selectedTaskId, taskId);
  expect(widget.runner.phase, phase);
  return widget;
}

Future<void> _tap(
  WidgetTester tester,
  String key, {
  String? taskId,
  Act0LessonPhaseV1? phase,
}) async {
  _diagnose(tester, 'before:$key');
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  _diagnose(tester, 'hit-test:$key');
  expect(finder.hitTestable(), findsOneWidget);
  if (taskId != null && phase != null) _expectTask(tester, taskId, phase);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester tester, String stage) async {
  // Observe the product's normal writes. Never force persistence or completion.
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
  final raw = (await SharedPreferences.getInstance()).getString(_key);
  _diagnose(tester, 'read:$stage');
  expect(raw, isNotNull);
  final data = jsonDecode(raw!) as Map<String, dynamic>;
  _diagnose(tester, stage, saved: data);
  return data;
}

void _expectNoProgressOrPokerRepair(
  Map<String, dynamic> saved,
  Map<String, dynamic> baseline,
  String taskId,
) {
  for (final key in _protected) {
    expect(
      baseline,
      contains(key),
      reason: 'Source-owned baseline field: $key',
    );
    expect(saved, contains(key), reason: 'Persisted field must remain: $key');
    expect(
      saved[key],
      equals(baseline[key]),
      reason: 'No vocabulary repair: $key',
    );
  }
  expect(saved['earnedXp'], 0);
  expect(saved['completedTaskIds'], isNot(contains(taskId)));
  expect(saved['completedLessonIds'], isNot(contains(_lessonId)));
  expect(saved['openRepairIntents'], isEmpty);
}

void _expectIncorrectRecord(
  Map<String, dynamic> record,
  String taskId,
  String wrongId,
  String correctId,
  String fingerprint,
) {
  expect(record['worldId'], _world);
  expect(record['lessonId'], _lessonId);
  expect(record['taskId'], taskId);
  expect(record['sourceTaskId'], taskId);
  expect(record['choiceId'], wrongId);
  expect(record['expectedChoiceId'], correctId);
  expect(record['isCorrect'], isFalse);
  expect(record['resultKind'], 'incorrect');
  expect(record['assistanceKind'], 'none');
  expect(record['authoredSourceFingerprint'], fingerprint);
  expect(record['errorType'], isNot(anyOf(isNull, '', 'none')));
  expect(record['recordId'], isNotEmpty);
}

Future<void> _openMission(WidgetTester tester, String taskId) async {
  await _tap(tester, 'act0_shell_current_mission_cta');
  // The source preamble may still render Continue before the drill options.
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  _expectTask(tester, taskId, runner.runner.phase);
}

Future<Map<String, dynamic>> _mount(WidgetTester tester, String taskId) async {
  await tester.binding.setSurfaceSize(const Size(393, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final completed = <String>{
    ...Act0ShellStateV1.sample
        .worldById(_world)
        .lessons
        .takeWhile((lesson) => lesson.lessonId != _lessonId)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId),
    ..._lesson.taskList
        .takeWhile((task) => task.taskId != taskId)
        .map((task) => task.taskId),
  }.toList()..sort();
  expect(completed, isNot(contains(taskId)));
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _key: jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': completed,
      'skippedTaskIds': <String>[],
      'completedLessonIds': <String>[],
      'selectedWorldId': _world,
      'selectedLessonId': _lessonId,
      'selectedTaskId': taskId,
      'earnedXp': 0,
      'learningEvidenceHistory': <Object>[],
      'reviewMistakeHistory': <Object>[],
      'reviewResolutionReceipts': <Object>[],
      'openRepairIntents': <Object>[],
    }),
  });
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.learn,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  final before = await _saved(tester, '$taskId:initial-no-target');
  expect(_records(before, taskId), isEmpty);
  // This is still the deliberately minimal synthetic schema18 seed.
  final initialHistory = Act0LearningEvidenceHistoryV1.restore(
    before['learningEvidenceHistory'],
    before['learningEvidenceLineage'],
  );
  expect(initialHistory, isNotNull);
  expect(initialHistory!.provenanceRecords, isEmpty);
  expect(before['completedTaskIds'], isNot(contains(taskId)));
  expect(before['earnedXp'], 0);
  expect(before['openRepairIntents'], isEmpty);
  // Normal Learn mission entry does not save. Prime through ordinary app
  // lifecycle persistence, then remount the same data without any reseed.
  // This is widget lifecycle evidence, not a native cold-restart claim.
  await tester.pumpWidget(const SizedBox.shrink());
  final persisted = await _saved(tester, '$taskId:ordinary-dispose-save');
  expect(persisted['schemaVersion'], 19);
  expect(_canonicalRecords(persisted), isEmpty);
  expect(persisted['completedTaskIds'], before['completedTaskIds']);
  expect(persisted['earnedXp'], 0);
  expect(persisted['openRepairIntents'], isEmpty);
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.learn,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _openMission(tester, taskId);
  final ready = await _saved(tester, '$taskId:before-first-choice');
  // Require the actual product-written snapshot before any wrong choice.
  expect(ready['schemaVersion'], 19);
  expect(ready, contains('learningEvidenceLineage'));
  expect(_canonicalRecords(ready), isEmpty);
  expect(_records(ready, taskId), isEmpty);
  expect(ready['completedTaskIds'], isNot(contains(taskId)));
  expect(ready['earnedXp'], 0);
  return ready;
}

Future<Map<String, dynamic>> _chooseWrong(
  WidgetTester tester,
  String taskId,
  String wrongId,
  String stage,
) async {
  final key = 'act0_shell_option_$wrongId';
  for (
    var step = 0;
    step < 12 && find.byKey(Key(key)).evaluate().isEmpty;
    step++
  ) {
    await _tap(
      tester,
      'act0_shell_continue_cta',
      taskId: taskId,
      phase: Act0LessonPhaseV1.drill,
    );
  }
  final runner = _expectTask(tester, taskId, Act0LessonPhaseV1.drill);
  final option = runner.runner.options.singleWhere(
    (option) => option.id == wrongId,
  );
  expect(option.isCorrect, isFalse);
  expect(option.quality, Act0FeedbackQualityV1.wrong);
  expect(runner.runner.selectedOptionId, isNull);
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  _diagnose(tester, '$stage:before-rapid-wrong-taps');
  expect(finder.hitTestable(), findsOneWidget);
  _expectTask(tester, taskId, Act0LessonPhaseV1.drill);
  // Two rapid UI taps before the feedback frame are one committed attempt.
  // The runner's submitted-attempt guard must ignore the second physical tap.
  await tester.tap(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  final saved = await _saved(tester, stage);
  final feedback = _expectTask(tester, taskId, Act0LessonPhaseV1.review);
  expect(feedback.runner.selectedOptionId, wrongId);
  expect(feedback.runner.selectedOption?.isCorrect, isFalse);
  return saved;
}

Future<void> _followUpTwice(
  WidgetTester tester,
  String taskId,
  String wrongId,
  Map<String, dynamic> baseline,
  Map<String, dynamic> committed,
  String stage,
) async {
  for (var tap = 1; tap <= 2; tap++) {
    await _tap(
      tester,
      'act0_shell_feedback_continue_cta',
      taskId: taskId,
      phase: Act0LessonPhaseV1.review,
    );
    final saved = await _saved(tester, '$stage:unavailable-$tap');
    final feedback = _expectTask(tester, taskId, Act0LessonPhaseV1.review);
    expect(feedback.runner.selectedOptionId, wrongId);
    expect(find.byKey(const Key(_unavailable)), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key(_unavailable))).data,
      contains('unavailable'),
    );
    _expectNoProgressOrPokerRepair(saved, baseline, taskId);
    expect(
      saved['learningEvidenceHistory'],
      committed['learningEvidenceHistory'],
    );
    expect(
      saved['learningEvidenceLineage'],
      committed['learningEvidenceLineage'],
    );
    expect(_canonicalRecords(saved), _canonicalRecords(committed));
    // Let the ordinary snackbar expire before the next real CTA tap.
    // This is animation/timer pumping, not elapsed retention evidence.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final target in <({String id, String correct, List<String> wrong})>[
    (id: 'actions_fold_drill', correct: 'fold', wrong: ['call', 'raise']),
    (id: 'actions_call_drill', correct: 'call', wrong: ['fold', 'raise']),
    (id: 'actions_raise_drill', correct: 'raise', wrong: ['fold', 'call']),
    (id: 'actions_review', correct: 'raise', wrong: ['fold', 'call']),
  ]) {
    for (final wrongId in target.wrong) {
      testWidgets('${target.id}/$wrongId: current miss stays unearned and '
          'unavailable; one record per real attempt', (tester) async {
        final task = _lesson.taskList.singleWhere(
          (task) => task.taskId == target.id,
        );
        expect(task.rewardXp, 5);
        expect(task.entryPhase, Act0LessonPhaseV1.drill);
        expect(
          task.runner.options.singleWhere((o) => o.isCorrect).id,
          target.correct,
        );
        expect(
          task.runner.options.singleWhere((o) => o.id == wrongId).quality,
          Act0FeedbackQualityV1.wrong,
        );
        final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: _world,
          lessonId: _lessonId,
          taskId: target.id,
        );
        expect(fingerprint, isNotNull);
        final expectedFingerprint = fingerprint!;
        final baseline = await _mount(tester, target.id);
        final first = await _chooseWrong(
          tester,
          target.id,
          wrongId,
          '${target.id}/$wrongId:first-wrong',
        );
        _expectNoProgressOrPokerRepair(first, baseline, target.id);
        final firstRecords = _records(first, target.id);
        expect(firstRecords, hasLength(1));
        final original = Map<String, dynamic>.from(firstRecords.single);
        expect(_canonicalRecords(first), <Object>[original]);
        _expectIncorrectRecord(
          original,
          target.id,
          wrongId,
          target.correct,
          expectedFingerprint,
        );
        await _followUpTwice(
          tester,
          target.id,
          wrongId,
          baseline,
          first,
          '${target.id}/$wrongId:first',
        );

        // A new normal Learn visit is a genuinely distinct accepted attempt,
        // unlike repeated taps on the already committed feedback above.
        await _tap(tester, 'act0_shell_runner_back');
        _diagnose(tester, '${target.id}/$wrongId:back-to-learn');
        final learn = find.text('Learn').last;
        expect(learn.hitTestable(), findsOneWidget);
        await tester.tap(learn);
        await tester.pumpAndSettle();
        await _openMission(tester, target.id);
        final reentered = await _saved(
          tester,
          '${target.id}/$wrongId:real-reentry',
        );
        _expectNoProgressOrPokerRepair(reentered, baseline, target.id);
        expect(_records(reentered, target.id), <Object>[original]);
        expect(
          reentered['learningEvidenceLineage'],
          first['learningEvidenceLineage'],
        );
        expect(_canonicalRecords(reentered), <Object>[original]);
        final second = await _chooseWrong(
          tester,
          target.id,
          wrongId,
          '${target.id}/$wrongId:second-wrong',
        );
        _expectNoProgressOrPokerRepair(second, baseline, target.id);
        final records = _records(second, target.id);
        expect(records, hasLength(2));
        expect(records.first, original);
        expect(records.last['recordId'], isNot(original['recordId']));
        // Lineage compacts first-fact anchors; a second same-kind wrong answer
        // does not create a fictitious second anchor. The canonical union must
        // contain exactly the two real attempts and no unrelated record.
        expect(
          second['learningEvidenceLineage'],
          first['learningEvidenceLineage'],
        );
        expect(_canonicalRecords(second), records);
        _expectIncorrectRecord(
          records.last,
          target.id,
          wrongId,
          target.correct,
          expectedFingerprint,
        );
        await _followUpTwice(
          tester,
          target.id,
          wrongId,
          baseline,
          second,
          '${target.id}/$wrongId:second',
        );
        final finalSaved = await _saved(tester, '${target.id}/$wrongId:final');
        _expectNoProgressOrPokerRepair(finalSaved, baseline, target.id);
        expect(_records(finalSaved, target.id), records);
        expect(
          finalSaved['learningEvidenceLineage'],
          second['learningEvidenceLineage'],
        );
        expect(_canonicalRecords(finalSaved), records);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

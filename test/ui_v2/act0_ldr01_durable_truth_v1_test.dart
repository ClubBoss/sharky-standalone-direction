import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';

final _store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);
const _key = 'act0_shell_progress_v1';
const _lesson = 'fold_check_call_raise';
const _target = 'actions_check_drill';

// Deterministic platform fault injector: durable values are separate from the
// plugin's RAM cache. These are machine fixtures, never native/user evidence.
class _Disk extends SharedPreferencesStorePlatform {
  _Disk(Map<String, Object> initial)
    : values = {for (final e in initial.entries) 'flutter.${e.key}': e.value};
  final Map<String, Object> values;
  bool holdNext = false;
  Completer<void>? held;
  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (holdNext && key.contains(_key)) {
      holdNext = false;
      held = Completer<void>();
      await held!.future;
    }
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }
}

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample
    .worldById('world_1')
    .lessons
    .firstWhere((l) => l.lessonId == _lesson)
    .taskList
    .singleWhere((t) => t.taskId == id);
Act0CompletedDecisionV1 _decision(String id, int n, {bool correct = true}) {
  final task = _task(id);
  final option = task.runner.options.firstWhere((o) => o.isCorrect == correct);
  return Act0CompletedDecisionV1(
    attemptKey: 'machine_source|$id|$n',
    worldId: 'world_1',
    lessonId: _lesson,
    taskId: id,
    sourceTaskId: id,
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: option.id,
    expectedId: task.runner.options.firstWhere((o) => o.isCorrect).id,
    isCorrect: option.isCorrect,
    decisionTimeBucket: '3_to_10s',
    taskFamily: task.resolvedTaskFamily,
    resultKind: option.isCorrect ? 'correct' : 'incorrect',
    errorType: option.isCorrect ? 'none' : 'missed_action_read',
    conceptFamilyId: 'action_read',
    skillAtomId: 'action_read',
    repairFocusId: 'no_bet_yet',
  );
}

Act0LearningEvidenceRecordV1 _record(String id, int n, {bool correct = true}) =>
    act0LearningEvidenceRecordFromCompletedDecisionV1(
      _decision(id, n, correct: correct),
      createdOrder: n,
      sessionId: 'machine_regression',
      runKey: Act0EvidenceRunKeyV1(
        runId: 'machine_run|$n',
        worldId: 'world_1',
        lessonId: _lesson,
        runOrdinal: n,
        runKind: 'lesson',
        startedBy: 'machine_regression',
      ),
    )!;

Map<String, Object?> _snapshot({
  List<Map<String, Object?>> evidence = const [],
  bool completed = false,
}) {
  final world = Act0ShellStateV1.sample.worldById('world_1');
  return {
    'schemaVersion': 18,
    'completedTaskIds': [
      for (final l in world.lessons.takeWhile((l) => l.lessonId != _lesson))
        for (final t in l.taskList) t.taskId,
      'actions_theory',
      'actions_legal_context',
      if (completed) _target,
    ],
    'skippedTaskIds': <String>[],
    'completedLessonIds': <String>[],
    'selectedWorldId': 'world_1',
    'selectedLessonId': _lesson,
    'selectedTaskId': _target,
    'earnedXp': 20,
    'learningEvidenceHistory': evidence,
  };
}

Future<_Disk> _mount(
  WidgetTester tester,
  Map<String, Object?> snapshot, {
  Act0ShellTabV1 tab = Act0ShellTabV1.play,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await _store.flush();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await _store.flush();
  });
  SharedPreferences.setMockInitialValues({});
  final disk = _Disk({
    _key: jsonEncode(snapshot),
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
  });
  SharedPreferencesStorePlatform.instance = disk;
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: false,
        initialTab: tab,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return disk;
}

Future<void> _flush(WidgetTester tester) async {
  final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
  state.debugPersistProgressV1();
  await tester.pump(const Duration(milliseconds: 300));
  // Fault-race callers deliberately keep the barrier blocked until release.
}

Future<void> _drain() => _store.flush();
Map<String, dynamic> _durable(_Disk disk) =>
    jsonDecode(disk.values['flutter.$_key']! as String) as Map<String, dynamic>;

void main() {
  testWidgets('an older in-flight save cannot erase a later source decision', (
    tester,
  ) async {
    final disk = await _mount(tester, _snapshot());
    disk.holdNext = true;
    await _flush(tester);
    expect(disk.held, isNotNull);
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    runner.onCompletedDecision!(_decision(_target, 900, correct: false));
    await tester.pump(const Duration(milliseconds: 300));
    disk.held!.complete();
    await tester.pumpAndSettle();
    await _drain();
    final records = _durable(disk)['learningEvidenceHistory'] as List;
    expect(
      records.any(
        (r) => (r as Map)['recordId'] == 'machine_source|$_target|900',
      ),
      isTrue,
    );
  });

  testWidgets(
    'a corrupt primary reward value recovers the acknowledged snapshot',
    (tester) async {
      final disk = await _mount(tester, _snapshot());
      await _flush(tester);
      await _drain();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final corrupt = _durable(disk)..['earnedXp'] = 999999;
      disk.values['flutter.$_key'] = jsonEncode(corrupt);
      await (await SharedPreferences.getInstance()).reload();
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
        ),
      );
      await tester.pumpAndSettle();
      await _flush(tester);
      await _drain();
      expect(_durable(disk)['earnedXp'], 20);
    },
  );

  for (final completed in [false, true]) {
    testWidgets(
      '200+ records cannot turn an old ${completed ? 'completed' : 'wrong'} source into unseen transfer',
      (tester) async {
        final evidence = [_record(_target, 1, correct: completed).toPayload()];
        final disk = await _mount(
          tester,
          _snapshot(evidence: evidence, completed: completed),
          tab: Act0ShellTabV1.learn,
        );
        final learn = tester.widget<Act0LearnPathShellV1>(
          find.byType(Act0LearnPathShellV1),
        );
        learn.onStartTask(_lesson, _target);
        await tester.pumpAndSettle();
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        // 202 later source-owned completions actually pass through the real
        // shell callback and its bounded history, not a pre-truncated mock list.
        for (var n = 2; n <= 203; n++)
          runner.onCompletedDecision!(_decision('actions_legal_context', n));
        await tester.pumpAndSettle();
        await _flush(tester);
        await _drain();
        expect(
          (_durable(disk)['learningEvidenceHistory'] as List),
          hasLength(200),
        );
        runner.onCompletedDecision!(_decision(_target, 999));
        await tester.pumpAndSettle();
        await _flush(tester);
        await _drain();
        final last =
            (_durable(disk)['learningEvidenceHistory'] as List).last as Map;
        expect(last['taskId'], _target);
        expect(
          last['reviewKind'],
          isNot(anyOf('initialAssessment', 'unseenTransfer')),
        );
        expect(last['assistanceKind'], 'none');
        expect(
          last['choiceId'],
          _task(_target).runner.options.firstWhere((o) => o.isCorrect).id,
        );
      },
    );
  }

  test('reset outranks conflicting same-revision copies', () async {
    SharedPreferences.setMockInitialValues({});
    final store = Act0ProgressStoreV1(
      key: 'k_conflict',
      isValidPayload: (_) => true,
    );
    expect(await store.save('a'), isTrue);
    final prefs = await SharedPreferences.getInstance();
    final raw =
        jsonDecode(prefs.getString('k_conflict_recovery')!)
            as Map<String, dynamic>;
    // Forge a same-revision, different-payload copy with a valid digest.
    final other = Act0ProgressStoreV1(
      key: 'k_other',
      isValidPayload: (_) => true,
    );
    SharedPreferences.setMockInitialValues({});
    await other.save('b');
    final p2 = await SharedPreferences.getInstance();
    await p2.setString('k_conflict_recovery', jsonEncode(raw));
    await p2.setString('k_conflict_backup', p2.getString('k_other_backup')!);
    expect(store.load(), throwsA(isA<FormatException>()));
    expect(await store.clear(), isTrue);
    expect(await store.load(), isNull);
  });
}

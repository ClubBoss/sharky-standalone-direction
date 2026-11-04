import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';

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
  bool holdNextLoad = false;
  bool failNextLoad = false;
  Completer<void>? heldLoad;
  final Set<String> failWriteKeys = <String>{};
  final Set<String> failRemoveKeys = <String>{};
  final Set<String> falseButLandedKeys = <String>{};
  final Set<String> throwButLandedKeys = <String>{};
  final Set<String> trueButMissingKeys = <String>{};
  final Set<String> falseButRemovedKeys = <String>{};
  final Set<String> trueButNotRemovedKeys = <String>{};
  // key -> 1-based write ordinal from which setValue fails (0 = never).
  final Map<String, int> failWritesFrom = <String, int>{};
  final Map<String, int> writeCounts = <String, int>{};
  @override
  Future<Map<String, Object>> getAll() async {
    if (failNextLoad) {
      failNextLoad = false;
      throw StateError('synthetic transient read failure');
    }
    if (holdNextLoad) {
      holdNextLoad = false;
      heldLoad = Completer<void>();
      await heldLoad!.future;
    }
    return Map.of(values);
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (failWriteKeys.contains(key)) return false;
    if (throwButLandedKeys.contains(key)) {
      values[key] = value;
      throw StateError('synthetic landed write failure');
    }
    if (trueButMissingKeys.contains(key)) return true;
    if (falseButLandedKeys.contains(key)) {
      values[key] = value;
      return false;
    }
    final n = writeCounts[key] = (writeCounts[key] ?? 0) + 1;
    final from = failWritesFrom[key] ?? 0;
    if (from > 0 && n >= from) return false;
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
    if (failRemoveKeys.contains(key)) return false;
    if (trueButNotRemovedKeys.contains(key)) return true;
    if (falseButRemovedKeys.contains(key)) {
      values.remove(key);
      return false;
    }
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
Act0CompletedDecisionV1 _decision(
  String id,
  int n, {
  bool correct = true,
  Act0DecisionAssistanceV1 assistanceKind = Act0DecisionAssistanceV1.none,
}) {
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
    assistanceKind: assistanceKind,
  );
}

Act0LearningEvidenceRecordV1 _record(
  String id,
  int n, {
  bool correct = true,
  Act0DecisionAssistanceV1 assistanceKind = Act0DecisionAssistanceV1.none,
}) => act0LearningEvidenceRecordFromCompletedDecisionV1(
  _decision(id, n, correct: correct, assistanceKind: assistanceKind),
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

Map<String, Object?> _schema19Snapshot(
  Act0LearningEvidenceHistoryV1 history, {
  required String selectedTaskId,
  required List<String> completedTaskIds,
  required Map<String, int?> lessonRunEvidenceBoundaries,
}) => _snapshot()
  ..['schemaVersion'] = 19
  ..['selectedTaskId'] = selectedTaskId
  ..['completedTaskIds'] = completedTaskIds
  ..['learningEvidenceHistory'] = history.toPayload()
  ..['learningEvidenceLineage'] = history.lineagePayload()
  ..['lessonRunEvidenceBoundaries'] = lessonRunEvidenceBoundaries;

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

Future<({_Disk disk, Act0ProgressStoreV1 store})> _dat06Fixture(
  String tag, {
  Future<void> Function(String, _Disk, String)? boundary,
}) async {
  final key = 'dat06_$tag';
  SharedPreferences.setMockInitialValues({});
  final disk = _Disk({
    key: 'synthetic damaged original',
    '${key}_head': '{invalid',
    '${key}_recovery': false,
    '${key}_backup': 41,
    'unrelated': 'keep',
    'intake_completed_v1': true,
  });
  SharedPreferencesStorePlatform.instance = disk;
  return (
    disk: disk,
    store: Act0ProgressStoreV1(
      key: key,
      isValidPayload: (_) => true,
      debugRecoveryBoundary: boundary == null
          ? null
          : (stage) => boundary(stage, disk, key),
    ),
  );
}

Map<String, Object?> _dat06Canonical(_Disk disk, Act0ProgressStoreV1 store) => {
  for (final k in [
    store.key,
    store.headKey,
    store.recoveryKey,
    store.backupKey,
  ])
    k: disk.values.containsKey('flutter.$k')
        ? disk.values['flutter.$k']
        : '<absent fixture key>',
};
Act0ProgressStoreV1 _dat06Restart(Act0ProgressStoreV1 store) =>
    Act0ProgressStoreV1(key: store.key, isValidPayload: (_) => true);

void main() {
  test(
    'DAT378 transient read failure cannot authorize resetting readable progress',
    () async {
      final f = await _dat06Fixture('transient_read');
      final raw = Act0ProgressStoreV1.debugEnvelopeV1(7, '{"xp":50}');
      for (final k in [
        f.store.headKey,
        f.store.recoveryKey,
        f.store.backupKey,
      ]) {
        f.disk.values['flutter.$k'] = raw;
      }
      final before = Map.of(f.disk.values);
      f.disk.failNextLoad = true;
      await expectLater(f.store.load(), throwsStateError);
      await expectLater(
        f.store.inspectRecovery(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, before);
      expect(await f.store.load(), '{"xp":50}');
    },
  );

  test(
    'DAT378 unchanged bytes becoming valid invalidate consent before archive',
    () async {
      SharedPreferences.setMockInitialValues({});
      const k = 'dat378_validation';
      final raw = Act0ProgressStoreV1.debugEnvelopeV1(4, 'progress');
      final disk = _Disk({
        k: 'progress',
        '${k}_head': raw,
        '${k}_recovery': raw,
        '${k}_backup': raw,
      });
      SharedPreferencesStorePlatform.instance = disk;
      var valid = false;
      final store = Act0ProgressStoreV1(key: k, isValidPayload: (_) => valid);
      final proposal = await store.inspectRecovery();
      final before = Map.of(disk.values);
      valid = true;
      expect(await store.confirmRecovery(proposal), isFalse);
      expect(disk.values, before);
      expect(await store.load(), 'progress');
    },
  );

  for (final shape in [
    'legacy',
    'empty',
    'head_single',
    'single',
    'unequal',
    'tombstone',
  ]) {
    test('DAT378 readable $shape inspection never heals or resets', () async {
      final f = await _dat06Fixture('readable_$shape');
      for (final k in [
        f.store.key,
        f.store.headKey,
        f.store.recoveryKey,
        f.store.backupKey,
      ]) {
        f.disk.values.remove('flutter.$k');
      }
      final raw = Act0ProgressStoreV1.debugEnvelopeV1(
        7,
        shape == 'tombstone' ? null : 'progress',
      );
      if (shape == 'legacy')
        f.disk.values['flutter.${f.store.key}'] = 'progress';
      if (shape == 'head_single')
        f.disk.values['flutter.${f.store.headKey}'] = raw;
      if (['head_single', 'single', 'unequal', 'tombstone'].contains(shape)) {
        f.disk.values['flutter.${f.store.recoveryKey}'] = raw;
      }
      if (shape == 'unequal') {
        f.disk.values['flutter.${f.store.backupKey}'] =
            Act0ProgressStoreV1.debugEnvelopeV1(6, 'older');
      }
      final before = Map.of(f.disk.values);
      await expectLater(
        f.store.inspectRecovery(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, before);
      expect(f.disk.writeCounts, isEmpty);
    });
  }

  for (final stage in [
    'before_consent',
    'archive_verified',
    'intent_verified',
    'head_verified',
  ]) {
    test('DAT378 valid canonical drift at $stage fails closed', () async {
      late Map<String, Object> restored;
      final f = await _dat06Fixture(
        'drift_$stage',
        boundary: (seen, disk, key) async {
          if (seen != stage) return;
          final raw = Act0ProgressStoreV1.debugEnvelopeV1(12, 'restored');
          for (final k in ['${key}_head', '${key}_recovery', '${key}_backup']) {
            disk.values['flutter.$k'] = raw;
          }
          restored = Map.of(disk.values);
        },
      );
      final proposal = await f.store.inspectRecovery();
      if (stage == 'before_consent') {
        final raw = Act0ProgressStoreV1.debugEnvelopeV1(12, 'restored');
        for (final k in [
          f.store.headKey,
          f.store.recoveryKey,
          f.store.backupKey,
        ]) {
          f.disk.values['flutter.$k'] = raw;
        }
        restored = Map.of(f.disk.values);
      }
      expect(await f.store.confirmRecovery(proposal), isFalse);
      expect(f.disk.values, restored);
      if (stage == 'intent_verified' || stage == 'head_verified') {
        await expectLater(
          _dat06Restart(f.store).load(),
          throwsA(isA<Act0RecoveryHoldV1>()),
        );
        expect(f.disk.values, restored);
      }
    });
  }

  for (final cut in ['archive_verified', 'intent_verified', 'head_verified']) {
    test(
      'DAT378 original snapshot becoming readable at $cut blocks destructive continuation',
      () async {
        SharedPreferences.setMockInitialValues({});
        final k = 'dat378_eligibility_$cut';
        final raw = Act0ProgressStoreV1.debugEnvelopeV1(4, 'progress');
        final disk = _Disk({
          k: 'progress',
          '${k}_head': raw,
          '${k}_recovery': raw,
          '${k}_backup': raw,
        });
        SharedPreferencesStorePlatform.instance = disk;
        var valid = false;
        final store = Act0ProgressStoreV1(
          key: k,
          isValidPayload: (_) => valid,
          debugRecoveryBoundary: (stage) async {
            if (stage == cut) valid = true;
          },
        );
        final proposal = await store.inspectRecovery();
        expect(await store.confirmRecovery(proposal), isFalse);
        // A completed prefix may exist, but the remaining original bytes survive.
        expect(disk.values['flutter.$k'], 'progress');
        expect(disk.values['flutter.${k}_backup'], raw);
        final beforeRestart = Map.of(disk.values);
        final restart = Act0ProgressStoreV1(
          key: k,
          isValidPayload: (_) => true,
        );
        if (cut != 'archive_verified') {
          await expectLater(restart.load(), throwsA(isA<Act0RecoveryHoldV1>()));
          expect(disk.values, beforeRestart);
        }
      },
    );
  }

  testWidgets(
    'DAT378 recovered progress offers no-write retry instead of replacement',
    (tester) async {
      final disk = await _mount(
        tester,
        _snapshot(evidence: [_record(_target, 1).toPayload()]),
      );
      await _drain();
      final saved = Map.of(disk.values);
      disk.values['flutter.${_key}_head'] = '{invalid';
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      await state.debugReloadProgressV1();
      await tester.pumpAndSettle();
      expect(
        find.text('Your saved progress could not be read.'),
        findsOneWidget,
      );
      disk.values
        ..clear()
        ..addAll(saved);
      final before = Map.of(disk.values);
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      final confirm = tester.widget<TextButton>(
        find.byKey(const Key('act0_recovery_confirm')),
      );
      expect(confirm.onPressed, isNull);
      expect(find.textContaining('Try again'), findsWidgets);
      expect(disk.values, before);
      await tester.tap(find.byKey(const Key('act0_recovery_cancel')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_retry')));
      await tester.pumpAndSettle();
      expect(find.text('Your saved progress could not be read.'), findsNothing);
      expect(_durable(disk)['earnedXp'], 20);
      expect(_durable(disk)['learningEvidenceHistory'], isNotEmpty);
    },
  );

  testWidgets(
    'DAT378 confirmation after canonical recovery preserves XP evidence and preferences',
    (tester) async {
      final disk = await _mount(
        tester,
        _snapshot(evidence: [_record(_target, 1).toPayload()]),
      );
      await _drain();
      final saved = Map.of(disk.values);
      disk.values['flutter.${_key}_head'] = '{invalid';
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      await state.debugReloadProgressV1();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      final confirm = find.byKey(const Key('act0_recovery_confirm'));
      expect(tester.widget<TextButton>(confirm).onPressed, isNotNull);
      disk.values
        ..clear()
        ..addAll(saved);
      final before = Map.of(disk.values);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(disk.values, before);
      expect(_durable(disk)['earnedXp'], 20);
      expect(_durable(disk)['learningEvidenceHistory'], isNotEmpty);
      await tester.tap(find.byKey(const Key('act0_recovery_retry')));
      await tester.pumpAndSettle();
      expect(find.text('Your saved progress could not be read.'), findsNothing);
      expect(_durable(disk)['earnedXp'], 20);
    },
  );

  test(
    'DAT378 transient confirmation read failure performs no writes',
    () async {
      final f = await _dat06Fixture('confirm_io');
      final proposal = await f.store.inspectRecovery();
      final before = Map.of(f.disk.values);
      f.disk.failNextLoad = true;
      expect(await f.store.confirmRecovery(proposal), isFalse);
      expect(f.disk.values, before);
    },
  );

  test(
    'DAT378 concurrent consent tokens cannot reset twice or reuse stale lease',
    () async {
      final f = await _dat06Fixture('concurrent');
      final other = _dat06Restart(f.store);
      final proposal = await f.store.inspectRecovery();
      final second = await other.inspectRecovery();
      final results = await Future.wait([
        f.store.confirmRecovery(proposal),
        other.confirmRecovery(second),
      ]);
      expect(results, [true, false]);
      final after = Map.of(f.disk.values);
      await expectLater(
        other.inspectRecovery(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, after);
      expect((await _dat06Restart(f.store).loadState()).isReset, isTrue);
    },
  );

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

  testWidgets('a saved schema 19 decision survives a cold remount', (
    tester,
  ) async {
    final disk = await _mount(tester, _snapshot());
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    runner.onCompletedDecision!(_decision(_target, 901, correct: false));
    await tester.pumpAndSettle();
    await _flush(tester);
    await _drain();
    expect(_durable(disk)['schemaVersion'], 19);
    expect(_durable(disk)['learningEvidenceLineage'], isA<Map>());
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      const MaterialApp(
        home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your saved progress could not be read.'), findsNothing);
    await _flush(tester);
    await _drain();
    final records = _durable(disk)['learningEvidenceHistory'] as List;
    expect(
      records.any(
        (r) => (r as Map)['recordId'] == 'machine_source|$_target|901',
      ),
      isTrue,
    );
  });

  group('schema 19 evidence lineage round trip', () {
    Act0LearningEvidenceHistoryV1 roundTrip(Act0LearningEvidenceHistoryV1 h) =>
        Act0LearningEvidenceHistoryV1.tryParse(
          jsonDecode(h.toStorageString()),
        )!;

    test('one saved record overlaps anchor and recent list and restores', () {
      final h = const Act0LearningEvidenceHistoryV1().append(
        _record(_target, 1, correct: false),
      );
      final r = roundTrip(h);
      expect(r.records.single.recordId, h.records.single.recordId);
      expect(r.sourceAnchors, isNotEmpty);
      expect(r.records.single.toPayload(), h.records.single.toPayload());
    });

    test('200+ records keep truncated source anchors across restore', () {
      var h = const Act0LearningEvidenceHistoryV1().append(
        _record(_target, 1, correct: false),
      );
      for (var n = 2; n <= 203; n++) {
        h = h.append(_record('actions_legal_context', n));
      }
      final r = roundTrip(h);
      expect(r.records, hasLength(200));
      expect(
        r.provenanceRecords.any(
          (x) => x.recordId == 'machine_source|$_target|1',
        ),
        isTrue,
      );
      expect(r.toStorageString(), h.toStorageString());
    });

    test('200+ records preserve an authentic assisted correction', () {
      var h = const Act0LearningEvidenceHistoryV1()
          .append(_record(_target, 1, correct: false))
          .append(
            _record(
              _target,
              2,
              assistanceKind: Act0DecisionAssistanceV1.quickHint,
            ),
          );
      for (var n = 3; n <= 202; n++) {
        h = h.append(_record('actions_legal_context', n));
      }

      final r = roundTrip(h);
      final target = r.provenanceRecords
          .where((record) => record.taskId == _target)
          .toList();
      expect(r.records, hasLength(200));
      expect(
        target.map((record) => record.createdOrder),
        containsAll(<int>[1, 2]),
      );
      expect(
        target.any(
          (record) =>
              record.recordId == 'machine_source|$_target|2' &&
              record.isAssistedCorrect &&
              record.assistanceKind == Act0DecisionAssistanceV1.quickHint,
        ),
        isTrue,
      );
    });

    test('200+ records preserve the first independent correct sequence', () {
      var h = const Act0LearningEvidenceHistoryV1().append(_record(_target, 1));
      for (var n = 2; n <= 201; n++) {
        h = h.append(_record('actions_legal_context', n));
      }

      final projection = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: roundTrip(h),
      );
      final firstCorrect = projection.seedForId(
        act0AchievementSeedFirstCorrectReadV1,
      );
      expect(firstCorrect.earnedSequence, 1);
      expect(firstCorrect.sourceSummary['firstCreatedOrder'], 1);
    });

    test('unsealed schema 19 never claims complete historical lineage', () {
      var history = const Act0LearningEvidenceHistoryV1().append(
        _record(_target, 1, correct: false),
      );
      for (var order = 2; order <= 203; order++) {
        history = history.append(_record('actions_legal_context', order));
      }
      final payload =
          jsonDecode(history.toStorageString()) as Map<String, dynamic>;
      final lineage = payload['lineage'] as Map<String, dynamic>;
      lineage.remove('anchorCount');
      lineage.remove('anchorSha256');
      lineage.remove('lineageSha256');
      final restored = Act0LearningEvidenceHistoryV1.tryParse(payload)!;
      expect(restored.hasCompleteLineage, isFalse);
      expect(restored.records, hasLength(200));
      expect(
        restored.provenanceRecords.any(
          (record) => record.recordId == 'machine_source|$_target|1',
        ),
        isTrue,
      );

      // A new checksum over an already-incomplete recovered history must
      // never upgrade completeness, even after later genuine source events.
      final appended = restored.append(_record('actions_legal_context', 204));
      final resealed = jsonDecode(appended.toStorageString()) as Map;
      final resealedLineage = resealed['lineage'] as Map;
      expect(resealedLineage['anchorSha256'], isA<String>());
      expect(resealedLineage['anchorCount'], isA<int>());
      expect(resealedLineage['complete'], isFalse);
      expect(
        Act0LearningEvidenceHistoryV1.tryParse(resealed)!.hasCompleteLineage,
        isFalse,
      );
    });

    test('incomplete lineage cannot become complete by flipping metadata', () {
      final incomplete = Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(_target, 1, correct: false),
        ],
        hasCompleteLineage: false,
      );
      final raw = jsonDecode(incomplete.toStorageString()) as Map;
      final lineage = raw['lineage'] as Map;
      expect(lineage['complete'], isFalse);
      lineage['complete'] = true;
      // A digest covering only anchors is not evidence that earlier facts
      // were never lost. Metadata integrity must include completeness.
      final tampered = Act0LearningEvidenceHistoryV1.tryParse(raw);
      expect(tampered == null || !tampered.hasCompleteLineage, isTrue);
    });

    test('truncated or altered sealed source anchors fail closed', () {
      var history = const Act0LearningEvidenceHistoryV1().append(
        _record(_target, 1, correct: false),
      );
      for (var order = 2; order <= 202; order++) {
        history = history.append(_record('actions_legal_context', order));
      }
      final unmodified = jsonDecode(history.toStorageString());
      expect(
        Act0LearningEvidenceHistoryV1.tryParse(unmodified)!.hasCompleteLineage,
        isTrue,
      );
      final trimmed =
          jsonDecode(history.toStorageString()) as Map<String, dynamic>;
      ((trimmed['lineage'] as Map)['anchors'] as List).removeAt(0);
      expect(Act0LearningEvidenceHistoryV1.tryParse(trimmed), isNull);

      final modified =
          jsonDecode(history.toStorageString()) as Map<String, dynamic>;
      (((modified['lineage'] as Map)['anchors'] as List).first
              as Map)['choiceId'] =
          'forged_choice';
      expect(Act0LearningEvidenceHistoryV1.tryParse(modified), isNull);
    });

    test(
      'conflicting duplicate event IDs in schema 19 restore fail closed',
      () {
        final first = _record(_target, 1, correct: false);
        final original = const Act0LearningEvidenceHistoryV1().append(first);
        final payload = jsonDecode(original.toStorageString()) as Map;
        (payload['records'] as List).add(
          _record(_target, 1, correct: true).toPayload(),
        );
        expect(Act0LearningEvidenceHistoryV1.tryParse(payload), isNull);
      },
    );

    test('duplicate source record id never overwrites earned provenance', () {
      final original = _record(_target, 1, correct: false);
      final history = const Act0LearningEvidenceHistoryV1().append(original);
      final replay = history.append(_record(_target, 1, correct: true));
      expect(replay.provenanceRecords, hasLength(1));
      expect(replay.provenanceRecords.single.toPayload(), original.toPayload());
    });

    test('assistance attribution survives restore', () {
      final base = _record(_target, 1).toPayload();
      final h = const Act0LearningEvidenceHistoryV1().append(
        _record(_target, 1),
      );
      final r = roundTrip(h);
      expect(
        r.records.single.toPayload()['assistanceKind'],
        base['assistanceKind'],
      );
    });

    test('same record id with conflicting content is rejected', () {
      final h = const Act0LearningEvidenceHistoryV1().append(
        _record(_target, 1, correct: false),
      );
      final saved = jsonDecode(h.toStorageString()) as Map<String, dynamic>;
      final anchors = (saved['lineage'] as Map)['anchors'] as List;
      (anchors.first as Map)['isCorrect'] = true;
      expect(Act0LearningEvidenceHistoryV1.tryParse(saved), isNull);
    });

    test('schema 18 list migrates to incomplete lineage', () {
      final legacy = [_record(_target, 1).toPayload()];
      final r = Act0LearningEvidenceHistoryV1.tryParse(legacy)!;
      expect(r.hasCompleteLineage, isFalse);
      expect(roundTrip(r).hasCompleteLineage, isFalse);
      expect(
        roundTrip(r).provenanceRecords.any(
          (record) => record.assistanceKind != Act0DecisionAssistanceV1.none,
        ),
        isFalse,
      );
    });
  });

  testWidgets(
    'block summary retains known assisted evidence outside recent 200',
    (tester) async {
      var history = const Act0LearningEvidenceHistoryV1()
          .append(
            _record(
              'actions_legal_context',
              1,
              assistanceKind: Act0DecisionAssistanceV1.quickHint,
            ),
          )
          .append(_record(_target, 2))
          .append(_record('actions_fold_drill', 3))
          .append(_record('actions_call_drill', 4))
          .append(_record('actions_raise_drill', 5));
      for (var n = 6; n <= 205; n++) {
        history = history.append(_record('actions_raise_drill', n));
      }

      final world = Act0ShellStateV1.sample.worldById('world_1');
      final completedTaskIds = <String>[
        for (final lesson in world.lessons.takeWhile(
          (lesson) => lesson.lessonId != _lesson,
        ))
          for (final task in lesson.taskList) task.taskId,
        'actions_theory',
        'actions_legal_context',
        _target,
        'actions_fold_drill',
        'actions_call_drill',
        'actions_raise_drill',
      ];
      await _mount(
        tester,
        _schema19Snapshot(
          history,
          selectedTaskId: 'actions_review',
          completedTaskIds: completedTaskIds,
          lessonRunEvidenceBoundaries: const <String, int?>{_lesson: 0},
        ),
      );

      final reviewTask = _task('actions_review');
      final answer = reviewTask.runner.options.firstWhere(
        (option) => option.isCorrect,
      );
      final option = find.byKey(Key('act0_shell_option_${answer.id}'));
      final feedback = find.byKey(
        const Key('act0_shell_feedback_continue_cta'),
      );
      for (
        var step = 0;
        step < 12 && option.evaluate().isEmpty && feedback.evaluate().isEmpty;
        step++
      ) {
        final next =
            find
                .byKey(const Key('act0_shell_theory_continue_cta'))
                .evaluate()
                .isNotEmpty
            ? find.byKey(const Key('act0_shell_theory_continue_cta'))
            : find.byKey(const Key('act0_shell_continue_cta'));
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      await tester.tap(option);
      await tester.pumpAndSettle();
      await tester.tap(feedback);
      await tester.pumpAndSettle();

      final summary = tester
          .widget<Act0BlockCompletionShellV1>(
            find.byType(Act0BlockCompletionShellV1),
          )
          .summary;
      expect(summary.assistedCount, greaterThanOrEqualTo(1));
      expect(summary.independentProvenanceKnown, isFalse);
    },
  );

  group('P0 startup integrity', () {
    Future<_Disk> mountHeld(
      WidgetTester tester,
      Map<String, Object?> snap,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _store.flush();
      SharedPreferences.setMockInitialValues({});
      final disk = _Disk({
        _key: jsonEncode(snap),
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
      })..holdNextLoad = true;
      SharedPreferencesStorePlatform.instance = disk;
      return disk;
    }

    Future<void> seedAcknowledged(_Disk disk, Map<String, Object?> snap) async {
      // Make the fixture an acknowledged protected store rather than legacy bytes.
      final s = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);
      expect(await s.save(jsonEncode(snap)), isTrue);
    }

    testWidgets('dispose before the load completes never overwrites saved XP', (
      tester,
    ) async {
      final snap = _snapshot(evidence: [_record(_target, 1).toPayload()]);
      final disk = await mountHeld(tester, snap);
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
        ),
      );
      await tester.pump();
      expect(disk.heldLoad, isNotNull);
      await tester.pumpWidget(const SizedBox.shrink());
      disk.heldLoad!.complete();
      await tester.pumpAndSettle();
      await _store.flush();
      expect(_durable(disk)['earnedXp'], 20);
      expect(_durable(disk)['learningEvidenceHistory'], isNotEmpty);
      expect(
        disk.values.keys.where((k) => k.endsWith('_recovery')),
        isEmpty,
        reason: 'an unrestored widget must not write any checkpoint',
      );
    });

    testWidgets(
      'failed load, dispose, retry and second cold remount keep progress',
      (tester) async {
        final snap = _snapshot(evidence: [_record(_target, 1).toPayload()]);
        final disk = await mountHeld(tester, snap);
        disk.holdNextLoad = false;
        await seedAcknowledged(disk, snap);
        final good = disk.values['flutter.${_key}_recovery']! as String;
        disk.values['flutter.${_key}_recovery'] = '{bad';
        disk.values['flutter.${_key}_backup'] = '{bad';
        await tester.pumpWidget(
          const MaterialApp(
            home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Your saved progress could not be read.'),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _store.flush();
        expect(
          disk.values['flutter.${_key}_recovery'],
          '{bad',
          reason: 'failed load never writes',
        );
        disk.values['flutter.${_key}_recovery'] = good;
        disk.values['flutter.${_key}_backup'] = good;
        await tester.pumpWidget(
          const MaterialApp(
            home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Your saved progress could not be read.'),
          findsNothing,
        );
        await _flush(tester);
        await _drain();
        expect(_durable(disk)['earnedXp'], 20);
        for (var i = 0; i < 2; i++) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            const MaterialApp(
              home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
            ),
          );
          await tester.pumpAndSettle();
          await _flush(tester);
          await _drain();
          expect(_durable(disk)['earnedXp'], 20);
          expect(_durable(disk)['learningEvidenceHistory'], hasLength(1));
        }
      },
    );

    testWidgets('fresh install still persists its first snapshot', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _store.flush();
      SharedPreferences.setMockInitialValues({});
      final disk = _Disk({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
      });
      SharedPreferencesStorePlatform.instance = disk;
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
        ),
      );
      await tester.pumpAndSettle();
      await _flush(tester);
      await _drain();
      expect(_durable(disk)['schemaVersion'], 19);
    });
  });

  group('commit authority (approved revised invariant)', () {
    const k = 'k_ck';
    String rk(String s) => 'flutter.${k}_$s';
    String env(int rev, String? payload) =>
        Act0ProgressStoreV1.debugEnvelopeV1(rev, payload);
    String shape(_Disk d) {
      String one(String n) {
        final raw = d.values[rk(n)];
        if (raw == null) return '-';
        try {
          final m = jsonDecode(raw as String) as Map;
          return 'r${m['revision']}:${m['payload']}';
        } catch (_) {
          return 'BAD';
        }
      }

      return '[recovery=${one('recovery')} backup=${one('backup')}]';
    }

    Act0ProgressStoreV1 fresh() =>
        Act0ProgressStoreV1(key: k, isValidPayload: (_) => true);
    Future<Object?> load(Act0ProgressStoreV1 st) =>
        st.load().then<Object?>((v) => v, onError: (Object e) => e);
    void chain(
      String name,
      String prior,
      Object? write,
      _Disk d,
      Object? freshLoad,
      String verdict,
    ) {
      // ignore: avoid_print
      print(
        'CHAIN $name | prior=$prior | write=$write | disk=${shape(d)} | fresh-load=${freshLoad is Exception ? 'FormatException' : freshLoad} | $verdict',
      );
    }

    Future<({_Disk disk, Act0ProgressStoreV1 store})> seeded() async {
      SharedPreferences.setMockInitialValues({});
      final disk = _Disk({});
      SharedPreferencesStorePlatform.instance = disk;
      final store = fresh();
      expect(await store.save('{"xp":50}'), isTrue);
      expect(await store.load(), '{"xp":50}');
      return (disk: disk, store: store);
    }

    Future<_Disk> raw({String? rec, String? bak, String? legacy}) async {
      SharedPreferences.setMockInitialValues({});
      final disk = _Disk({if (legacy != null) k: legacy});
      if (rec != null) disk.values[rk('recovery')] = rec;
      if (bak != null) disk.values[rk('backup')] = bak;
      SharedPreferencesStorePlatform.instance = disk;
      return disk;
    }

    test(
      'R1 failed reset + failed rollback: fresh process heals tombstone, no resurrection',
      () async {
        final f = await seeded();
        f.disk.failWriteKeys.add(rk('backup'));
        f.disk.failRemoveKeys.add(rk('backup'));
        final ack = await f.store.clear();
        expect(ack, isFalse);
        expect(shape(f.disk), '[recovery=r2:null backup=r1:{"xp":50}]');
        // heal blocked: fail closed, never the stale 50 and never a half state
        expect(await load(fresh()), isA<FormatException>());
        f.disk.failWriteKeys.clear();
        f.disk.failRemoveKeys.clear();
        final healed = await load(fresh());
        expect(healed, isNull);
        expect(shape(f.disk), '[recovery=r2:null backup=r2:null]');
        f.disk.values[rk('recovery')] = '{corrupt';
        final afterCorruption = await load(fresh());
        expect(afterCorruption, isNull);
        chain(
          'R1',
          'xp50@r1',
          ack,
          f.disk,
          afterCorruption,
          'tombstone survives, no resurrection',
        );
      },
    );

    test(
      'failed reset heal followed by newer-copy corruption never resurrects stale XP',
      () async {
        final f = await seeded();
        f.disk.failWriteKeys.add(rk('backup'));
        f.disk.failRemoveKeys.add(rk('backup'));
        expect(await f.store.clear(), isFalse);
        expect(shape(f.disk), '[recovery=r2:null backup=r1:{"xp":50}]');

        // The reset tombstone is observed, but its backup cannot be healed.
        expect(await load(fresh()), isA<FormatException>());
        f.disk.values[rk('recovery')] = '{corrupt';

        // A cold load must not mistake the older backup for the current state.
        expect(await load(fresh()), isA<FormatException>());
        expect(shape(f.disk), '[recovery=BAD backup=r1:{"xp":50}]');
      },
    );

    test(
      'failed head rollback removal makes a cold load fail closed',
      () async {
        final d = await raw(legacy: '{"xp":50}');
        d.failWriteKeys.add(rk('recovery'));
        d.failRemoveKeys.add(rk('head'));

        expect(await fresh().save('{"xp":70}'), isFalse);
        expect(d.values[rk('head')], isNotNull);
        expect(d.values[rk('recovery')], isNull);
        expect(d.values[rk('backup')], isNull);
        expect(await load(fresh()), isA<FormatException>());
      },
    );

    test(
      'failed save: indeterminate, fresh process heals forward, never mixed',
      () async {
        final f = await seeded();
        f.disk.failWriteKeys.add(rk('backup'));
        final ack = await f.store.save('{"xp":99}');
        expect(ack, isFalse);
        expect(shape(f.disk), '[recovery=r2:{"xp":99} backup=r1:{"xp":50}]');
        f.disk.failWriteKeys.clear();
        final v = await load(fresh());
        expect(v, '{"xp":99}');
        expect(shape(f.disk), '[recovery=r2:{"xp":99} backup=r2:{"xp":99}]');
        chain(
          'failed-save',
          'xp50@r1',
          ack,
          f.disk,
          v,
          'indeterminate -> healed to new',
        );
      },
    );

    test(
      'recovery write that returns false but landed is acknowledged only after both copies verify',
      () async {
        final f = await seeded();
        f.disk.falseButLandedKeys.addAll({rk('recovery'), rk('backup')});
        final ack = await f.store.save('{"xp":70}');
        f.disk.falseButLandedKeys.clear();
        final v = await load(fresh());
        expect(ack, isTrue);
        expect(v, '{"xp":70}');
        chain(
          'false-but-landed',
          'xp50@r1',
          ack,
          f.disk,
          v,
          'verified both -> ack true',
        );
      },
    );

    test(
      'recovery write failing before any landing is not acknowledged and changes nothing',
      () async {
        final f = await seeded();
        f.disk.failWriteKeys.add(rk('recovery'));
        expect(await f.store.save('{"xp":70}'), isFalse);
        f.disk.failWriteKeys.clear();
        expect(await load(fresh()), '{"xp":50}');
        expect(shape(f.disk), '[recovery=r1:{"xp":50} backup=r1:{"xp":50}]');
      },
    );

    test(
      'failed mandatory healing fails closed for load, save and nothing changes',
      () async {
        final d = await raw(rec: env(2, 'new'), bak: env(1, 'old'));
        d.failWriteKeys.add(rk('backup'));
        final st = fresh();
        expect(await load(st), isA<FormatException>());
        expect(await st.save('x'), isFalse);
        expect(await st.clear(), isFalse);
        expect(shape(d), '[recovery=r2:new backup=r1:old]');
      },
    );

    test(
      'recovery corruption before healing yields only the acked copy; after healing it is safe',
      () async {
        var d = await raw(rec: env(2, 'new'), bak: env(1, 'old'));
        d.values[rk('recovery')] = '{corrupt';
        expect(
          await load(fresh()),
          'old',
          reason: 'R2: unhealed partial, never exposed before',
        );
        d = await raw(rec: env(2, 'new'), bak: env(1, 'old'));
        expect(await load(fresh()), 'new');
        d.values[rk('recovery')] = '{corrupt';
        expect(await load(fresh()), 'new');
      },
    );

    test(
      'successful save and reset acknowledge with both copies equal',
      () async {
        final f = await seeded();
        expect(shape(f.disk), '[recovery=r1:{"xp":50} backup=r1:{"xp":50}]');
        expect(await f.store.clear(), isTrue);
        expect(shape(f.disk), '[recovery=r2:null backup=r2:null]');
        expect(await load(fresh()), isNull);
      },
    );

    test(
      'single-copy corruption after acknowledgement recovers and re-heals',
      () async {
        for (final name in ['recovery', 'backup']) {
          final f = await seeded();
          f.disk.values[rk(name)] = '{corrupt';
          expect(await load(fresh()), '{"xp":50}');
          expect(shape(f.disk), '[recovery=r1:{"xp":50} backup=r1:{"xp":50}]');
        }
      },
    );

    test(
      'corrupt present head fails closed and preserves valid matching checkpoints',
      () async {
        final f = await seeded();
        final head = f.disk.values[rk('head')]! as String;
        final recovery = f.disk.values[rk('recovery')]! as String;
        final backup = f.disk.values[rk('backup')]! as String;
        final legacy = f.disk.values['flutter.$k']! as String;
        expect(head, recovery);
        expect(recovery, backup);
        expect(await f.store.load(), '{"xp":50}');

        f.disk.values[rk('head')] = '{corrupt';
        expect(await load(fresh()), isA<FormatException>());
        expect(f.disk.values[rk('head')], '{corrupt');
        expect(f.disk.values[rk('recovery')], recovery);
        expect(f.disk.values[rk('backup')], backup);
        expect(f.disk.values['flutter.$k'], legacy);
      },
    );

    test(
      'both copies corrupt fail closed and ignore the legacy mirror',
      () async {
        final d = await raw(rec: '{x', bak: '{y', legacy: '{"legacy":1}');
        final st = fresh();
        expect(await load(st), isA<FormatException>());
        expect(await st.save('z'), isFalse);
        expect(d.values[rk('recovery')], '{x');
        expect(
          await st.clear(),
          isTrue,
          reason: 'explicit reset outranks unreadable copies',
        );
        expect(await load(fresh()), isNull);
      },
    );

    test(
      'legacy migration: first save creates protected copies; invalid legacy fails closed',
      () async {
        var d = await raw(legacy: '{"legacy":1}');
        final st = fresh();
        expect(await st.load(), '{"legacy":1}');
        expect(await st.save('{"xp":5}'), isTrue);
        expect(shape(d), '[recovery=r1:{"xp":5} backup=r1:{"xp":5}]');
        Act0ProgressStoreV1 strict() =>
            Act0ProgressStoreV1(key: k, isValidPayload: (p) => p != 'bad');
        d = await raw(legacy: 'bad');
        expect(await load(strict()), isA<FormatException>());
      },
    );
  });

  Future<Object?> runReset(WidgetTester tester) async {
    final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
    Object? error;
    await tester.runAsync(() async {
      try {
        await state.debugInvalidatePersistedProgressWritesV1();
      } catch (e) {
        error = e;
      }
    });
    return error;
  }

  testWidgets(
    'reset with clear() failing before anything landed aborts and keeps progress',
    (tester) async {
      final disk = await _mount(tester, _snapshot(), tab: Act0ShellTabV1.home);
      disk.failWriteKeys.add('flutter.${_key}_recovery');
      final error = await runReset(tester);
      disk.failWriteKeys.clear();
      expect(error, isA<StateError>());
      expect((error as StateError).message, contains('not saved'));
      await _drain();
      expect(_durable(disk)['earnedXp'], 20);
    },
  );

  testWidgets(
    'reset with tombstone landed but backup unhealable blocks writes and reports',
    (tester) async {
      final disk = await _mount(tester, _snapshot(), tab: Act0ShellTabV1.home);
      await tester.runAsync(() => _store.save(jsonEncode(_snapshot())));
      disk.failWriteKeys.add('flutter.${_key}_backup');
      final error = await runReset(tester);
      await tester.pumpAndSettle();
      expect(error, isA<StateError>());
      expect((error as StateError).message, contains('could not be verified'));
      expect(
        find.text('Your saved progress could not be read.'),
        findsOneWidget,
      );
      final before = disk.values['flutter.${_key}_recovery'];
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 300));
      await _drain();
      expect(disk.values['flutter.${_key}_recovery'], before);
    },
  );

  testWidgets(
    'reset whose tombstone is durable completes even when clear() reported false',
    (tester) async {
      final disk = await _mount(tester, _snapshot(), tab: Act0ShellTabV1.home);
      disk.falseButLandedKeys.addAll({
        'flutter.${_key}_recovery',
        'flutter.${_key}_backup',
      });
      final error = await runReset(tester);
      disk.falseButLandedKeys.clear();
      expect(error, isNull);
    },
  );

  test('malformed schema 19 recent record is rejected, not filtered', () {
    final h = const Act0LearningEvidenceHistoryV1().append(_record(_target, 1));
    final saved = jsonDecode(h.toStorageString()) as Map<String, dynamic>;
    (saved['records'] as List).add({'recordId': 'broken'});
    expect(Act0LearningEvidenceHistoryV1.tryParse(saved), isNull);
  });

  testWidgets(
    'user reset clears durable retention and does not re-persist it',
    (tester) async {
      final rec = act0LearningEvidenceRecordFromCompletedDecisionV1(
        _decision(_target, 1, correct: false),
        createdOrder: 1,
        sessionId: 'machine_regression',
        runKey: const Act0EvidenceRunKeyV1(
          runId: 'machine_run|1',
          worldId: 'world_1',
          lessonId: _lesson,
          runOrdinal: 1,
          runKind: 'lesson',
          startedBy: 'machine_regression',
        ),
        recordedAtUtc: DateTime.utc(2026, 10, 20, 12),
      )!;
      final history = const Act0LearningEvidenceHistoryV1().append(rec);
      final retention = Act0DurableRetentionHistoryV1.fromLearningEvidence(
        history,
      );
      expect(retention.families, isNotEmpty);
      final snap = _snapshot()
        ..['schemaVersion'] = 19
        ..['learningEvidenceHistory'] = history.toPayload()
        ..['learningEvidenceLineage'] = history.lineagePayload()
        ..['durableRetentionHistory'] = retention.toPayload();
      final disk = await _mount(tester, snap, tab: Act0ShellTabV1.home);
      await tester.tap(
        find.byKey(const Key('act0_shell_home_dev_menu_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_dev_menu_reset_progress')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('act0_shell_dev_menu_reset_confirm')),
      );
      await tester.pumpAndSettle();
      await _drain();
      final raw = disk.values['flutter.$_key'];
      if (raw != null) {
        final after = jsonDecode(raw as String) as Map<String, dynamic>;
        expect(after['earnedXp'], 0);
        expect(after['learningEvidenceHistory'], isEmpty);
        expect(after['durableRetentionHistory'], isEmpty);
      }
      await _flush(tester);
      await _drain();
      final again = disk.values['flutter.$_key'];
      if (again != null) {
        expect(
          (jsonDecode(again as String) as Map)['durableRetentionHistory'],
          isEmpty,
        );
      }
    },
  );
  for (final tamper in ['archive', 'intent']) {
    test(
      'DAT06 $tamper drift after backup must preserve original legacy',
      () async {
        final key = 'dat06_boundary_$tamper';
        SharedPreferences.setMockInitialValues({});
        final disk = _Disk({
          key: 'synthetic damaged original',
          '${key}_head': '{invalid',
          '${key}_recovery': false,
          '${key}_backup': 41,
        });
        SharedPreferencesStorePlatform.instance = disk;
        final store = Act0ProgressStoreV1(
          key: key,
          isValidPayload: (_) => false,
          debugRecoveryBoundary: (stage) async {
            if (stage == 'backup_verified') {
              disk.values['flutter.${key}_${tamper == 'archive' ? 'damaged_copy_v1' : 'recovery_intent_v1'}'] =
                  'tampered';
            }
          },
        );
        final proposal = await store.inspectRecovery();
        expect(await store.confirmRecovery(proposal), isFalse);
        expect(disk.values['flutter.$key'], 'synthetic damaged original');
      },
    );
  }
  test(
    'DAT06 inspection cancel and drift perform no canonical writes',
    () async {
      final f = await _dat06Fixture('inspect');
      final before = Map.of(f.disk.values);
      final proposal = await f.store.inspectRecovery();
      expect(f.disk.values, before);
      f.disk.values['flutter.${f.store.key}'] = 'newer synthetic value';
      final drifted = Map.of(f.disk.values);
      expect(await f.store.confirmRecovery(proposal), isFalse);
      expect(f.disk.values, drifted);
      expect(
        f.disk.values.containsKey('flutter.${f.store.damagedCopyKey}'),
        isFalse,
      );
    },
  );

  final typedCases = <Object>[
    'string \u0000 \ud800',
    false,
    9223372036854775807,
    -0.0,
    double.nan,
    <String>['x', '', '♠'],
  ];
  for (var i = 0; i < typedCases.length; i++) {
    test('DAT06 lossless typed archive and absent keys case$i', () async {
      final f = await _dat06Fixture('typed$i');
      final k = f.store.key;
      final v = typedCases[i];
      f.disk.values['flutter.$k'] = v;
      f.disk.values.remove('flutter.${f.store.backupKey}');
      expect(
        await f.store.confirmRecovery(await f.store.inspectRecovery()),
        isTrue,
      );
      final archive =
          jsonDecode(
                f.disk.values['flutter.${f.store.damagedCopyKey}'] as String,
              )
              as Map;
      final snapshot = archive['snapshot'] as List;
      final entry = (snapshot.first as List)[1] as Map;
      if (v is double) {
        final bytes = ByteData(8)..setFloat64(0, v, Endian.big);
        final bits = bytes.buffer
            .asUint8List()
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join();
        expect(entry, {'t': 'double', 'v': bits});
      } else if (v is int) {
        expect(entry, {'t': 'int', 'v': v.toString()});
      } else {
        expect(entry['v'], v);
      }
      expect((snapshot.last as List)[1], {'t': 'absent'});
      expect(f.disk.values['flutter.unrelated'], 'keep');
      expect(f.disk.values['flutter.intake_completed_v1'], true);
      final state = await _dat06Restart(f.store).loadState();
      expect(state.isReset, isTrue);
      expect(state.payload, isNull);
    });
  }

  for (final cut in [
    'archive_verified',
    'intent_verified',
    'head_verified',
    'recovery_verified',
    'backup_verified',
    'legacy_removed',
    'intent_removed',
  ]) {
    test('DAT06 process cut at $cut resumes idempotently', () async {
      final f = await _dat06Fixture(
        'cut_$cut',
        boundary: (stage, d, k) async {
          if (stage == cut) throw StateError('synthetic process cut');
        },
      );
      final proposal = await f.store.inspectRecovery();
      expect(await f.store.confirmRecovery(proposal), isFalse);
      final archive = f.disk.values['flutter.${f.store.damagedCopyKey}'];
      final restart = _dat06Restart(f.store);
      if (cut == 'archive_verified') {
        expect(
          f.disk.values['flutter.${f.store.key}'],
          'synthetic damaged original',
        );
        await expectLater(restart.load(), throwsFormatException);
        expect(
          await restart.confirmRecovery(await restart.inspectRecovery()),
          isTrue,
        );
      } else {
        expect((await restart.loadState()).isReset, isTrue);
      }
      final after = Map.of(f.disk.values);
      expect((await _dat06Restart(f.store).loadState()).isReset, isTrue);
      expect(f.disk.values, after);
      expect(f.disk.values['flutter.${f.store.damagedCopyKey}'], archive);
      expect(
        f.disk.values.containsKey('flutter.${f.store.recoveryIntentKey}'),
        isFalse,
      );
      expect(f.disk.values['flutter.unrelated'], 'keep');
    });
  }

  for (final behavior in ['false_landed', 'throw_landed', 'true_missing']) {
    for (final target in ['copy', 'intent', 'head', 'recovery', 'backup']) {
      test('DAT06 $behavior at $target uses durable readback', () async {
        final f = await _dat06Fixture('${behavior}_$target');
        final proposal = await f.store.inspectRecovery();
        final key = switch (target) {
          'copy' => f.store.damagedCopyKey,
          'intent' => f.store.recoveryIntentKey,
          'head' => f.store.headKey,
          'recovery' => f.store.recoveryKey,
          _ => f.store.backupKey,
        };
        final set = switch (behavior) {
          'false_landed' => f.disk.falseButLandedKeys,
          'throw_landed' => f.disk.throwButLandedKeys,
          _ => f.disk.trueButMissingKeys,
        };
        set.add('flutter.$key');
        expect(
          await f.store.confirmRecovery(proposal),
          behavior != 'true_missing',
        );
        set.clear();
        if (behavior == 'true_missing') {
          if (target == 'copy' || target == 'intent') {
            expect(
              f.disk.values['flutter.${f.store.key}'],
              'synthetic damaged original',
            );
            final restart = _dat06Restart(f.store);
            expect(
              await restart.confirmRecovery(await restart.inspectRecovery()),
              isTrue,
            );
          } else {
            expect((await _dat06Restart(f.store).loadState()).isReset, isTrue);
          }
        }
        expect((await _dat06Restart(f.store).loadState()).isReset, isTrue);
      });
    }
  }

  for (final target in ['copy', 'intent']) {
    test(
      'DAT06 invalid $target pending data holds without checkpoint mutation',
      () async {
        final f = await _dat06Fixture(
          'tamper_$target',
          boundary: (stage, d, k) async {
            if (stage == 'intent_verified') throw StateError('cut');
          },
        );
        expect(
          await f.store.confirmRecovery(await f.store.inspectRecovery()),
          isFalse,
        );
        final badKey = target == 'copy'
            ? f.store.damagedCopyKey
            : f.store.recoveryIntentKey;
        f.disk.values['flutter.$badKey'] = 'invalid';
        final before = Map.of(f.disk.values);
        await expectLater(
          _dat06Restart(f.store).load(),
          throwsA(isA<Act0RecoveryHoldV1>()),
        );
        expect(f.disk.values, before);
        final copy = await f.store.inspectRecoveryCopy();
        expect(await f.store.deleteRecoveryCopy(copy), isFalse);
        expect(f.disk.values, before);
      },
    );
  }

  test(
    'DAT06 unexpected newer state under bound intent is preserved and held',
    () async {
      final f = await _dat06Fixture(
        'newer',
        boundary: (stage, d, k) async {
          if (stage == 'intent_verified') {
            for (final key in ['${k}_head', '${k}_recovery', '${k}_backup']) {
              d.values['flutter.$key'] = Act0ProgressStoreV1.debugEnvelopeV1(
                90,
                'newer',
              );
            }
            d.values['flutter.$k'] = 'newer';
          }
        },
      );
      expect(
        await f.store.confirmRecovery(await f.store.inspectRecovery()),
        isFalse,
      );
      final before = Map.of(f.disk.values);
      await expectLater(
        _dat06Restart(f.store).load(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, before);
      expect(f.disk.values['flutter.${f.store.key}'], 'newer');
    },
  );

  test(
    'DAT06 revision overflow and unsupported types hold before preservation',
    () async {
      final f = await _dat06Fixture('overflow');
      f.disk.values['flutter.${f.store.headKey}'] = jsonEncode({
        'revision': 9007199254740991,
      });
      final before = Map.of(f.disk.values);
      await expectLater(
        f.store.inspectRecovery(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, before);
      f.disk.values['flutter.${f.store.headKey}'] = <String, int>{
        'unsupported': 1,
      };
      final unsupported = Map.of(f.disk.values);
      await expectLater(
        f.store.inspectRecovery(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, unsupported);
    },
  );

  test(
    'DAT06 existing different copy never evicted; separate deletion is verified and drift-bound',
    () async {
      final f = await _dat06Fixture('delete');
      expect(
        await f.store.confirmRecovery(await f.store.inspectRecovery()),
        isTrue,
      );
      final copy = await f.store.inspectRecoveryCopy();
      final canonical = _dat06Canonical(f.disk, f.store);
      f.disk.values['flutter.${f.store.damagedCopyKey}'] = 'changed copy';
      expect(await f.store.deleteRecoveryCopy(copy), isFalse);
      final changed = await f.store.inspectRecoveryCopy();
      f.disk.trueButNotRemovedKeys.add('flutter.${f.store.damagedCopyKey}');
      expect(await f.store.deleteRecoveryCopy(changed), isFalse);
      f.disk.trueButNotRemovedKeys.clear();
      f.disk.falseButRemovedKeys.add('flutter.${f.store.damagedCopyKey}');
      expect(await f.store.deleteRecoveryCopy(changed), isTrue);
      expect(_dat06Canonical(f.disk, f.store), canonical);
      expect(f.disk.values['flutter.unrelated'], 'keep');
      expect((await _dat06Restart(f.store).loadState()).isReset, isTrue);
    },
  );

  test(
    'DAT06 old instance and queued saves cannot restore state after reset',
    () async {
      final entered = Completer<void>(), release = Completer<void>();
      final f = await _dat06Fixture(
        'old_writer',
        boundary: (stage, d, k) async {
          if (stage == 'intent_verified') {
            entered.complete();
            await release.future;
          }
        },
      );
      final oldOther = _dat06Restart(f.store);
      final recovery = f.store.confirmRecovery(await f.store.inspectRecovery());
      await entered.future;
      final queued = oldOther.save('stale');
      release.complete();
      expect(await recovery, isTrue);
      expect(await queued, isFalse);
      expect(await f.store.save('stale'), isFalse);
      final fresh = _dat06Restart(f.store);
      expect((await fresh.loadState()).isReset, isTrue);
      expect(await fresh.save('fresh earned snapshot'), isTrue);
      expect(await _dat06Restart(fresh).load(), 'fresh earned snapshot');
    },
  );
  testWidgets(
    'DAT06 recovery fences old runner callbacks dispose and cold sample seeds',
    (tester) async {
      final disk = await _mount(tester, _snapshot());
      final oldRunner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      final dynamic runtime = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      disk.values['flutter.$_key'] = 'damaged';
      disk.values['flutter.${_key}_head'] = '{invalid';
      disk.values['flutter.${_key}_recovery'] = false;
      disk.values['flutter.${_key}_backup'] = 41;
      await tester.runAsync(
        () => runtime.debugReloadProgressV1() as Future<void>,
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Your saved progress could not be read.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Your saved progress could not be read.'), findsNothing);
      oldRunner.onChoiceAssistance?.call(Act0DecisionAssistanceV1.none);
      oldRunner.onChooseOption(
        oldRunner.runner.options.firstWhere((o) => o.isCorrect),
      );
      oldRunner.onCompletedDecision?.call(_decision(_target, 999));
      await tester.pumpAndSettle();
      runtime.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 300));
      await _drain();
      final raw = await _store.load();
      final saved = jsonDecode(raw!) as Map;
      expect(saved['earnedXp'], 0);
      expect(saved['completedTaskIds'], isEmpty);
      expect(saved['completedLessonIds'], isEmpty);
      expect(saved['openRepairIntents'], isEmpty);
      expect(saved['learningEvidenceHistory'], isEmpty);
      expect(saved['suppressLegacyRecheckAfterRecovery'], true);
      expect(disk.values['flutter.intake_completed_v1'], true);
      expect(disk.values['flutter.act0_welcome_completed_v1'], true);
      final activeStore = Act0ProgressStoreV1(
        key: _key,
        isValidPayload: (_) => true,
      );
      expect(
        await activeStore.deleteRecoveryCopy(
          await activeStore.inspectRecoveryCopy(),
        ),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _drain();
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
        ),
      );
      await tester.pumpAndSettle();
      final dynamic fresh = tester.state(find.byType(Act0ShellPreviewScreenV1));
      fresh.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 300));
      await _drain();
      final cold = jsonDecode((await _store.load())!) as Map;
      expect(cold['earnedXp'], 0);
      expect(cold['completedTaskIds'], isEmpty);
      expect(cold['learningEvidenceHistory'], isEmpty);
      expect(cold['openRepairIntents'], isEmpty);
      expect(cold['suppressLegacyRecheckAfterRecovery'], true);
    },
  );
  testWidgets(
    'DAT06 a genuinely new first-world decision earns once across cold restart',
    (tester) async {
      final disk = await _mount(tester, _snapshot());
      final dynamic runtime = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      disk.values['flutter.$_key'] = 'damaged';
      disk.values['flutter.${_key}_head'] = '{invalid';
      disk.values['flutter.${_key}_recovery'] = false;
      disk.values['flutter.${_key}_backup'] = 41;
      await tester.runAsync(
        () => runtime.debugReloadProgressV1() as Future<void>,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_confirm')));
      await tester.pumpAndSettle();
      Future<Act0LessonRunnerShellV1> reachDecision() async {
        for (var step = 0; step < 30; step++) {
          if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
            final runner = tester.widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            );
            if (runner.runner.phase == Act0LessonPhaseV1.drill &&
                runner.runner.selectedOptionId == null) {
              final answer = runner.runner.options.firstWhere(
                (o) => o.isCorrect,
              );
              final target = find.byKey(Key('act0_shell_option_${answer.id}'));
              final seat = answer.seatId == null
                  ? find.byKey(const Key('no-seat-choice'))
                  : find.byKey(Key('act0_shell_seat_tap_${answer.seatId}'));
              if (seat.evaluate().isNotEmpty) {
                await tester.ensureVisible(seat);
                if (seat.hitTestable().evaluate().isNotEmpty) return runner;
              }
              if (target.evaluate().isNotEmpty) {
                await tester.ensureVisible(target);
                if (target.hitTestable().evaluate().isNotEmpty) return runner;
              } else {}
            }
            final candidates = [
              find.byKey(const Key('act0_shell_theory_continue_cta')),
              find.byKey(const Key('act0_shell_continue_cta')),
              find.byKey(const Key('act0_shell_feedback_continue_cta')),
            ];
            final next = candidates.firstWhere((f) => f.evaluate().isNotEmpty);
            await tester.ensureVisible(next);
            await tester.tap(next);
            await tester.pumpAndSettle();
          } else if (find.byType(Act0LearnPathShellV1).evaluate().isNotEmpty) {
            final start = find.byKey(
              const Key('act0_shell_current_mission_cta'),
            );
            await tester.ensureVisible(start);
            await tester.tap(start);
            await tester.pumpAndSettle();
          } else {
            final nav = find.byKey(const Key('act0_shell_bottom_nav'));
            await tester.tap(
              find.descendant(of: nav, matching: find.text('Learn')),
            );
            await tester.pumpAndSettle();
          }
        }
        throw StateError(
          'First-world independent decision not reached through source controls',
        );
      }

      final runner = await reachDecision();
      final answer = runner.runner.options.firstWhere((o) => o.isCorrect);
      final taskId = runner.selectedTaskId!;
      print(
        'DAT06_NEW_NATIVE_TARGET task=$taskId choice=${answer.id} label=${answer.label}',
      );
      await _flush(tester);
      await _drain();
      final beforeXp =
          (jsonDecode((await _store.load())!) as Map)['earnedXp'] as int;
      final sourceTask = Act0ShellStateV1.sample.worlds.first.lessons
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == taskId);
      await tester.tap(
        answer.seatId != null &&
                find
                    .byKey(Key('act0_shell_seat_tap_${answer.seatId}'))
                    .evaluate()
                    .isNotEmpty
            ? find.byKey(Key('act0_shell_seat_tap_${answer.seatId}'))
            : find.byKey(Key('act0_shell_option_${answer.id}')),
      );
      await tester.pumpAndSettle();
      final finish = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      await tester.ensureVisible(finish);
      await tester.tap(finish);
      await tester.pumpAndSettle();
      await _flush(tester);
      await _drain();
      final earned = jsonDecode((await _store.load())!) as Map;
      final xp = earned['earnedXp'] as int;
      expect(xp, beforeXp + sourceTask.rewardXp);
      expect(sourceTask.rewardXp, greaterThan(0));
      expect(earned['completedTaskIds'], contains(taskId));
      final history = Act0LearningEvidenceHistoryV1.tryParse(
        earned['learningEvidenceHistory'],
      );
      expect(history, isNotNull);
      expect(
        history!.records.last.assistanceKind,
        Act0DecisionAssistanceV1.none,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _drain();
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            showPlacementOnStart: false,
            initialTab: Act0ShellTabV1.learn,
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .onBack();
        await tester.pumpAndSettle();
      }
      final learn = tester.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      final world = Act0ShellStateV1.sample.worlds.first;
      final lesson = world.lessons.firstWhere(
        (l) => l.taskList.any((t) => t.taskId == taskId),
      );
      learn.onStartTask(lesson.lessonId, taskId);
      await tester.pumpAndSettle();
      final replay = await reachDecision();
      final replayAnswer = replay.runner.options.firstWhere((o) => o.isCorrect);
      expect(replay.selectedTaskId, taskId);
      await tester.tap(
        replayAnswer.seatId != null &&
                find
                    .byKey(Key('act0_shell_seat_tap_${replayAnswer.seatId}'))
                    .evaluate()
                    .isNotEmpty
            ? find.byKey(Key('act0_shell_seat_tap_${replayAnswer.seatId}'))
            : find.byKey(Key('act0_shell_option_${replayAnswer.id}')),
      );
      await tester.pumpAndSettle();
      final finishReplay = find.byKey(
        const Key('act0_shell_feedback_continue_cta'),
      );
      await tester.ensureVisible(finishReplay);
      await tester.tap(finishReplay);
      await tester.pumpAndSettle();
      await _flush(tester);
      await _drain();
      final cold = jsonDecode((await _store.load())!) as Map;
      expect(cold['earnedXp'], xp);
      expect(cold['suppressLegacyRecheckAfterRecovery'], true);
    },
  );
  test(
    'DAT06 an existing different archive is never evicted on another reset',
    () async {
      final f = await _dat06Fixture('copy_never_evict');
      expect(
        await f.store.confirmRecovery(await f.store.inspectRecovery()),
        true,
      );
      final next = _dat06Restart(f.store);
      // A valid tombstone is no longer reset-eligible. Reproduce a genuinely
      // damaged later snapshot to keep testing the separate no-eviction rule.
      f.disk.values['flutter.${f.store.headKey}'] = '{new damage';
      final proposal = await next.inspectRecovery();
      final before = Map.of(f.disk.values);
      expect(await next.confirmRecovery(proposal), false);
      expect(f.disk.values, before);
    },
  );
  test(
    'DAT06 a consistently hashed forged target still fails the original consent binding',
    () async {
      final f = await _dat06Fixture(
        'forged_target',
        boundary: (stage, d, k) async {
          if (stage == 'intent_verified') throw StateError('cut');
        },
      );
      expect(
        await f.store.confirmRecovery(await f.store.inspectRecovery()),
        false,
      );
      final intent =
          jsonDecode(
                f.disk.values['flutter.${f.store.recoveryIntentKey}'] as String,
              )
              as Map<String, dynamic>;
      intent['target'] = Act0ProgressStoreV1.debugEnvelopeV1(90, null);
      intent['digest'] = sha256
          .convert(
            utf8.encode(
              jsonEncode([
                1,
                f.store.key,
                intent['archiveDigest'],
                intent['snapshotDigest'],
                intent['target'],
              ]),
            ),
          )
          .toString();
      f.disk.values['flutter.${f.store.recoveryIntentKey}'] = jsonEncode(
        intent,
      );
      final before = Map.of(f.disk.values);
      await expectLater(
        _dat06Restart(f.store).load(),
        throwsA(isA<Act0RecoveryHoldV1>()),
      );
      expect(f.disk.values, before);
    },
  );
  testWidgets(
    'DAT06 failed first fresh save and archive deletion cannot re-seed sample on cold boot',
    (tester) async {
      final disk = await _mount(tester, _snapshot());
      final dynamic runtime = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      disk.values['flutter.$_key'] = 'damaged';
      disk.values['flutter.${_key}_head'] = '{invalid';
      disk.values['flutter.${_key}_recovery'] = false;
      disk.values['flutter.${_key}_backup'] = 41;
      await tester.runAsync(
        () => runtime.debugReloadProgressV1() as Future<void>,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_confirm')));
      await tester.pumpAndSettle();
      disk.failWriteKeys.add('flutter.${_key}_head');
      runtime.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 300));
      await _drain();
      expect((await _store.loadState()).isReset, true);
      final freshStore = _dat06Restart(_store);
      expect(
        await freshStore.deleteRecoveryCopy(
          await freshStore.inspectRecoveryCopy(),
        ),
        true,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _drain();
      disk.failWriteKeys.clear();
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
        ),
      );
      await tester.pumpAndSettle();
      final dynamic cold = tester.state(find.byType(Act0ShellPreviewScreenV1));
      cold.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 300));
      await _drain();
      final saved = jsonDecode((await _store.load())!) as Map;
      expect(saved['earnedXp'], 0);
      expect(saved['completedTaskIds'], isEmpty);
      expect(saved['learningEvidenceHistory'], isEmpty);
      expect(saved['suppressLegacyRecheckAfterRecovery'], true);
      expect(disk.values.containsKey('flutter.${_key}_damaged_copy_v1'), false);
    },
  );
  testWidgets(
    'DAT06 active-runtime recovery clears an existing first-value carry',
    (tester) async {
      final snapshot = _snapshot()
        ..['firstValueReturnCarry'] = <String, Object>{
          'skillReceiptId': 'action_read_learned_no_bet_yet',
          'skillAtomId': 'action_read',
          'skillLabel': 'Action reading',
          'sourceSignalId': 'no_bet_yet',
          'sourceSignalLabel': 'No bet yet',
          'outcomeId': 'learned',
          'nextRepId': 'repeat_action_read',
          'nextRepLabel': 'One more action-reading rep',
          'sourceWorldId': 'world_1',
          'sourceLessonId': _lesson,
          'sourceTaskId': _target,
        };
      final disk = await _mount(tester, snapshot, tab: Act0ShellTabV1.home);
      await _flush(tester);
      await _drain();
      expect(
        _durable(disk)['firstValueReturnCarry'],
        snapshot['firstValueReturnCarry'],
        reason: 'Positive control: source restored a launchable old receipt',
      );
      final dynamic runtime = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      disk.values['flutter.$_key'] = 'damaged';
      disk.values['flutter.${_key}_head'] = '{invalid';
      disk.values['flutter.${_key}_recovery'] = false;
      disk.values['flutter.${_key}_backup'] = 41;
      await tester.runAsync(
        () => runtime.debugReloadProgressV1() as Future<void>,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_confirm')));
      await tester.pumpAndSettle();
      await _flush(tester);
      await _drain();
      final fresh = _durable(disk);
      expect(fresh['earnedXp'], 0);
      expect(fresh['completedTaskIds'], isEmpty);
      expect(
        fresh['firstValueReturnCarry'],
        isNull,
        reason: 'Pre-reset receipt must not become fresh proof',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _drain();
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            showPlacementOnStart: false,
            initialTab: Act0ShellTabV1.home,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _flush(tester);
      await _drain();
      expect(_durable(disk)['firstValueReturnCarry'], isNull);
    },
  );
}

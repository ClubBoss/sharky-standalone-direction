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
  Completer<void>? heldLoad;
  final Set<String> failWriteKeys = <String>{};
  final Set<String> failRemoveKeys = <String>{};
  final Set<String> falseButLandedKeys = <String>{};
  // key -> 1-based write ordinal from which setValue fails (0 = never).
  final Map<String, int> failWritesFrom = <String, int>{};
  final Map<String, int> writeCounts = <String, int>{};
  @override
  Future<Map<String, Object>> getAll() async {
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
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_identity_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

const _key = 'act0_shell_progress_v1';
const _task = 'actions_check_drill';
const _lesson = 'fold_check_call_raise';
final _store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);

// Same durable/cache separation and deterministic fault seam as LDR01.
class _Disk extends SharedPreferencesStorePlatform {
  _Disk(Map<String, Object> initial)
    : values = {for (final e in initial.entries) 'flutter.${e.key}': e.value};
  final Map<String, Object> values;
  bool failRecovery = false;
  bool holdNext = false;
  Completer<void>? held;
  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (holdNext) {
      holdNext = false;
      held = Completer<void>();
      await held!.future;
    }
    if (failRecovery && key == 'flutter.${_key}_recovery') return false;
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

class _Sink extends Act0InMemoryTelemetrySinkV1 {
  bool throwAfterRecord = false;
  @override
  void record(Act0TelemetryEventV1 event) {
    super.record(event);
    if (throwAfterRecord) throw StateError('synthetic sink unavailable');
  }
}

// Bounded test-only evidence interpretation, not a product diagnosis engine.
String _diagnose(
  List<Act0TelemetryEventV1> events, {
  required bool exactSourceKnown,
}) {
  final decisions = events.where((e) => e.name == 'decision_made').toList();
  final saves = events
      .where((e) => e.name == 'progress_persist_result')
      .toList();
  if (!exactSourceKnown || decisions.length != 1 || saves.isEmpty)
    return 'insufficient';
  final d = decisions.single.fields;
  final session = d['session_id'];
  if (session is! String || session.isEmpty) return 'insufficient';
  final matching = saves
      .where(
        (e) =>
            e.fields['session_id'] == session &&
            e.fields['task_id'] == d['task_id'],
      )
      .toList();
  if (matching.isEmpty ||
      matching.any(
        (e) => !const {
          'acknowledged',
          'indeterminate',
        }.contains(e.fields['outcome']),
      ))
    return 'insufficient';
  if (matching.any((e) => e.fields['outcome'] == 'indeterminate'))
    return 'save_acknowledgement_indeterminate';
  return d['correct'] == false
      ? 'learner_error_observed'
      : 'correct_decision_observed';
}

Future<_Disk> _mount(WidgetTester tester, _Sink sink) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final session = const Act0SessionIdentityStateV1()
      .startOrResume(
        startedAtOrder: 1,
        startedWorldId: 'world_1',
        startedLessonId: _lesson,
      )
      .state;
  SharedPreferences.setMockInitialValues({});
  final disk = _Disk({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _key: jsonEncode({
      'schemaVersion': 18,
      'completedTaskIds': [
        for (final l in world.lessons.takeWhile((l) => l.lessonId != _lesson))
          for (final t in l.taskList) t.taskId,
        'actions_theory',
        'actions_legal_context',
      ],
      'skippedTaskIds': <String>[],
      'completedLessonIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': _lesson,
      'selectedTaskId': _task,
      'earnedXp': 20,
      'learningEvidenceHistory': <Object>[],
      'sessionIdentityState': session.toPayload(),
    }),
  });
  SharedPreferencesStorePlatform.instance = disk;
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: false,
        initialTab: Act0ShellTabV1.play,
        telemetrySink: sink,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _store.flush();
  addTearDown(() async {
    disk.failRecovery = false;
    disk.holdNext = false;
    if (disk.held != null && !disk.held!.isCompleted) disk.held!.complete();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _store.flush();
  });
  for (
    var i = 0;
    i < 12 &&
        find.byKey(const Key('act0_shell_option_check')).evaluate().isEmpty;
    i++
  ) {
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    final next = theory.evaluate().isNotEmpty
        ? theory
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  expect(find.byKey(const Key('act0_shell_option_check')), findsOneWidget);
  await _store.flush();
  sink.events.clear();
  return disk;
}

Future<void> _answer(WidgetTester tester, bool correct) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere(
    (o) => o.isCorrect == correct,
  );
  final target = find.byKey(Key('act0_shell_option_${option.id}'));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'OBS04 wrong answer with acknowledged save is not storage failure',
    (tester) async {
      final sink = _Sink();
      await _mount(tester, sink);
      sink.throwAfterRecord = true;
      await _answer(tester, false);
      await _store.flush();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        _diagnose(sink.events, exactSourceKnown: true),
        'learner_error_observed',
      );
      expect(_diagnose(sink.events, exactSourceKnown: false), 'insufficient');
      final withoutSave = sink.events
          .where((e) => e.name != 'progress_persist_result')
          .toList();
      expect(_diagnose(withoutSave, exactSourceKnown: true), 'insufficient');
      final saves = sink.events.where(
        (e) => e.name == 'progress_persist_result',
      );
      expect(saves, isNotEmpty);
      expect(
        saves.map((e) => e.fields['outcome']),
        everyElement('acknowledged'),
      );
      List<Act0TelemetryEventV1> withSaveField(String key, Object? value) => [
        for (final event in sink.events)
          if (event.name == 'progress_persist_result')
            Act0TelemetryEventV1(
              name: event.name,
              fields: {...event.fields, key: value},
            )
          else
            event,
      ];
      for (final entry in <String, Object?>{
        'session_id': '',
        'task_id': 'different_task',
        'outcome': 'unknown',
      }.entries) {
        expect(
          _diagnose(
            withSaveField(entry.key, entry.value),
            exactSourceKnown: true,
          ),
          'insufficient',
        );
      }
      final noDecisionSession = [
        for (final event in sink.events)
          if (event.name == 'decision_made')
            Act0TelemetryEventV1(
              name: event.name,
              fields: {...event.fields, 'session_id': ''},
            )
          else
            event,
      ];
      expect(
        _diagnose(noDecisionSession, exactSourceKnown: true),
        'insufficient',
      );

      // Two synchronous scheduled writes coalesce to one invoked save/result.
      sink.events.clear();
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      state.debugPersistProgressV1();
      await tester.pumpAndSettle();
      await _store.flush();
      expect(
        sink.events.where((e) => e.name == 'progress_persist_result'),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'OBS04 correct answer with controlled nonlanding save remains indeterminate',
    (tester) async {
      final sink = _Sink();
      final disk = await _mount(tester, sink);
      final before = await _store.load();
      disk.failRecovery = true;
      disk.holdNext = true;
      await _answer(tester, true);
      expect(disk.held, isNotNull);
      expect(
        sink.events.where((e) => e.name == 'progress_persist_result'),
        isEmpty,
      );
      expect(_diagnose(sink.events, exactSourceKnown: true), 'insufficient');
      // Change the live route while the older save is pending. Its diagnostic
      // must still identify the scheduled source task, not this newer task.
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      expect(state.debugSelectedTaskIdV1(), isNot(_task));
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      final liveSession = Act0SessionIdentityStateV1.tryParse(
        state.debugSessionIdentityStatePayloadV1(),
      );
      expect(liveSession.currentActiveSessionId, isEmpty);
      disk.held!.complete();
      await tester.pumpAndSettle();
      await _store.flush();
      expect(
        _diagnose(sink.events, exactSourceKnown: true),
        'save_acknowledgement_indeterminate',
      );
      expect(
        sink.events
            .singleWhere((e) => e.name == 'decision_made')
            .fields['correct'],
        isTrue,
      );
      disk.failRecovery = false;
      expect(await _store.load(), before);
      final result = sink.events
          .firstWhere((e) => e.name == 'progress_persist_result')
          .fields;
      expect(result.keys.toSet(), {
        'schemaVersion',
        'operation',
        'outcome',
        'request_generation',
        'world_id',
        'lesson_id',
        'task_id',
        'session_id',
        'source_surface',
      });
      expect(result['schemaVersion'], 1);
      expect(result['task_id'], _task);
      expect(result['operation'], 'save');
      expect(result['outcome'], 'indeterminate');
      expect(result['request_generation'], isA<int>());
      expect(jsonEncode(result), isNot(contains('synthetic sink')));
    },
  );
}

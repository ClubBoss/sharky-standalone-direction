import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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

String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

// Test-owned capture of actual producer/backend arguments. No product state is
// supplied by this observer, and no raw preference payload leaves the process.
class _Capture {
  final windows = <Map<String, Object?>>[];
  List<Map<String, Object?>>? _entries;
  Set<String> _baselineIds = {};

  static const _recordFields = {
    'schemaVersion',
    'recordId',
    'createdOrder',
    'worldId',
    'lessonId',
    'taskId',
    'sourceTaskId',
    'choiceId',
    'expectedChoiceId',
    'isCorrect',
    'errorType',
    'resultKind',
    'assistanceKind',
    'runId',
    'runKind',
    'runOrdinal',
    'sessionId',
    'authoredSourceFingerprint',
    'reviewKind',
  };
  static const _eventFields = {
    'schemaVersion',
    'world_id',
    'lesson_id',
    'task_id',
    'session_id',
    'choiceId',
    'correct',
    'is_correct',
    'error_type',
    'assistance_kind',
    'attempt_id',
    'review_kind',
    'request_generation',
    'operation',
    'outcome',
    'source_surface',
  };

  List<Map<String, Object?>> _records(String payload) {
    final map = jsonDecode(payload) as Map;
    final raw = map['learningEvidenceHistory'];
    final records = raw is Map ? raw['records'] as List : raw as List;
    return [
      for (final record in records.cast<Map>())
        {
          for (final key in _recordFields)
            if (record.containsKey(key)) key: record[key],
        },
    ];
  }

  int _add(Map<String, Object?> entry) {
    final entries = _entries;
    if (entries == null) return 0;
    final seq = entries.length + 1;
    entries.add({'seq': seq, ...entry});
    return seq;
  }

  void begin(String name, String baseline) {
    if (_entries != null) throw StateError('capture window already open');
    _baselineIds = _records(
      baseline,
    ).map((record) => record['recordId']! as String).toSet();
    _entries = <Map<String, Object?>>[];
    windows.add({
      'name': name,
      'baseline_payload_sha256': _hash(baseline),
      'baseline_record_ids': _baselineIds.toList()..sort(),
      'entries': _entries,
    });
    _add({'kind': 'window_start', 'store_drained': true});
  }

  void event(Act0TelemetryEventV1 event) {
    if (!const {
      'decision_made',
      'progress_persist_result',
    }.contains(event.name))
      return;
    _add({
      'kind': 'event',
      'name': event.name,
      'fields': {
        for (final key in _eventFields)
          if (event.fields.containsKey(key)) key: event.fields[key],
      },
    });
  }

  int write(String key, Object value, {required bool held}) {
    if (_entries == null) return 0;
    final aliases = {
      'flutter.${_store.headKey}': 'head',
      'flutter.${_store.recoveryKey}': 'recovery',
      'flutter.${_store.backupKey}': 'backup',
      'flutter.$_key': 'mirror',
    };
    final alias = aliases[key];
    if (alias == null || value is! String)
      throw StateError('unclassified write in OBS04 window');
    final envelope = jsonDecode(value) as Map;
    final payload = alias == 'mirror' ? value : envelope['payload'] as String;
    final records = _records(payload);
    return _add({
      'kind': 'write_start',
      'key': alias,
      'held': held,
      'value_sha256': _hash(value),
      'payload_sha256': _hash(payload),
      if (alias != 'mirror') ...{
        'revision': envelope['revision'],
        'digest': envelope['digest'],
      },
      'records': records,
      'new_record_ids': [
        for (final record in records)
          if (!_baselineIds.contains(record['recordId'])) record['recordId'],
      ],
    });
  }

  void returned(int attempt, bool value) {
    if (attempt != 0)
      _add({'kind': 'write_result', 'attempt_seq': attempt, 'returned': value});
  }

  void coalescing(int previousGeneration) => _add({
    'kind': 'coalescing_control',
    'scheduled_requests': 2,
    'previous_result_generation': previousGeneration,
  });

  void close(String persistedAfter) {
    _add({
      'kind': 'window_end',
      'store_drained': true,
      'persisted_payload_sha256': _hash(persistedAfter),
    });
    _entries = null;
  }

  void save(String caseId) {
    final path = Platform.environment['OBS04_RECEIPT_DIR'];
    if (path == null || path.isEmpty) return;
    if (_entries != null) throw StateError('capture window not closed');
    final directory = Directory(path)..createSync(recursive: true);
    final file = File('${directory.path}/$caseId.json');
    if (file.existsSync())
      throw StateError('duplicate OBS04 execution capture');
    file.writeAsStringSync(
      '${jsonEncode({
        'format': 1,
        'case_id': caseId,
        'test_data_only': true,
        'unexercised': ['repair', 'transfer', 'elapsed_retention', 'native_restart'],
        'windows': windows,
      })}\n',
      flush: true,
    );
  }
}

// Same durable/cache separation and deterministic fault seam as LDR01.
class _Disk extends SharedPreferencesStorePlatform {
  _Disk(Map<String, Object> initial, this.capture)
    : values = {for (final e in initial.entries) 'flutter.${e.key}': e.value};
  final Map<String, Object> values;
  final _Capture capture;
  bool failRecovery = false;
  bool holdNext = false;
  Completer<void>? held;
  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    final attempt = capture.write(key, value, held: holdNext);
    if (holdNext) {
      holdNext = false;
      held = Completer<void>();
      await held!.future;
    }
    if (failRecovery && key == 'flutter.${_key}_recovery') {
      capture.returned(attempt, false);
      return false;
    }
    values[key] = value;
    capture.returned(attempt, true);
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
  final capture = _Capture();
  bool throwAfterRecord = false;
  @override
  void record(Act0TelemetryEventV1 event) {
    super.record(event);
    capture.event(event);
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
  }, sink.capture);
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
  sink.capture.begin('diagnostic', (await _store.load())!);
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
      sink.capture.close((await _store.load())!);
      final previousGeneration = saves.last.fields['request_generation'] as int;
      sink.capture.begin('coalescing', (await _store.load())!);
      sink.capture.coalescing(previousGeneration);
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
      final generation = sink.events
          .singleWhere((event) => event.name == 'progress_persist_result')
          .fields['request_generation'];
      expect(generation, previousGeneration + 2);
      sink.capture.close((await _store.load())!);
      sink.capture.save('wrong_acknowledged');
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
      sink.capture.close((await _store.load())!);
      sink.capture.save('correct_indeterminate');
    },
  );
}

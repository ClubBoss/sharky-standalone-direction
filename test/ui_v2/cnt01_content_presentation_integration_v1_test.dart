import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_presentation_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_canonical_store_port_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_learning_sequence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_settings_leaf_v1.dart';

const _key = 'act0_shell_progress_v1';
Act0ProgressStoreV1 _store() => Act0ProgressStoreV1(
  key: _key,
  isValidPayload: act0CanonicalProgressIsValidV1,
);
const _codec = Act0Dat07CodecV1(
  isValidProgress: act0CanonicalProgressIsValidV1,
  supportedProgressSchema: act0CanonicalProgressSchemaV1,
);
Act0Dat07TransferV1 _transfer() => Act0Dat07TransferV1(
  codec: _codec,
  port: Act0Dat07CanonicalStorePortV1(
    store: _store(),
    supportedProgressSchema: act0CanonicalProgressSchemaV1,
  ),
);

class _Files implements Act0Dat07FileBridgeV1 {
  @override
  Future<Uint8List?> selectBackup() async => null;
  @override
  Future<void> shareBackup(Uint8List bytes) async {}
}

/// Changes only disk timing/availability. Payloads, checksums, revisions and
/// exposure IDs are produced by the actual canonical writer, not a fake store.
class _Disk extends SharedPreferencesStorePlatform {
  final values = <String, Object>{};
  bool pauseNextExposure = false;
  bool landBeforePause = false;
  bool failNextExposure = false;
  bool readsUnavailable = false;
  Completer<void>? started;
  Completer<void>? release;

  bool _hasExposure(String key, Object value) {
    if (key != 'flutter.${_key}_head' || value is! String) return false;
    final envelope = jsonDecode(value) as Map;
    final payload = envelope['payload'];
    if (payload is! String) return false;
    final progress = jsonDecode(payload) as Map;
    final exposure = progress['contentExposureHistory'];
    return exposure is Map &&
        exposure['presentedTaskIds'] is List &&
        (exposure['presentedTaskIds'] as List).isNotEmpty;
  }

  void pause({bool afterLanding = false}) {
    pauseNextExposure = true;
    landBeforePause = afterLanding;
    started = Completer<void>();
    release = Completer<void>();
  }

  void resume() {
    final pending = release;
    if (pending != null && !pending.isCompleted) pending.complete();
    readsUnavailable = false;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    if (readsUnavailable) throw StateError('Test disk unavailable');
    return Map<String, Object>.of(values);
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    final exposure = _hasExposure(key, value);
    if (exposure && pauseNextExposure) {
      pauseNextExposure = false;
      if (landBeforePause) values[key] = value;
      started!.complete();
      await release!.future;
    }
    values[key] = value;
    if (exposure && failNextExposure) {
      failNextExposure = false;
      readsUnavailable = true;
      return false;
    }
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

Widget _app({bool firstStart = false}) => MaterialApp(
  locale: const Locale('en'),
  home: Act0Dat07ShellHostV1(
    shell: Act0ShellPreviewScreenV1(showPlacementOnStart: firstStart),
    fileBridge: _Files(),
  ),
);

dynamic _state(WidgetTester tester) =>
    tester.state(find.byType(Act0ShellPreviewScreenV1));

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _tap(WidgetTester tester, String key, {bool settle = true}) async {
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _tab(WidgetTester tester, String label) async {
  final target = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _startLesson(WidgetTester tester, {bool settle = true}) async {
  await _tab(tester, 'Learn');
  await _tap(tester, 'act0_shell_current_mission_cta', settle: settle);
}

Future<Act0LessonRunnerShellV1> _reachAssessment(WidgetTester tester) async {
  for (var step = 0; step < 24; step++) {
    final runners = find.byType(Act0LessonRunnerShellV1);
    if (runners.evaluate().isNotEmpty) {
      final runner = tester.widget<Act0LessonRunnerShellV1>(runners);
      if (runner.runner.phase == Act0LessonPhaseV1.drill &&
          runner.selectedTaskFamily != Act0TaskFamilyV1.learn &&
          runner.runner.options.any((option) => find.byKey(
            Key('act0_shell_option_${option.id}'),
          ).evaluate().isNotEmpty)) return runner;
    }
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    final feedback = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    final next = theory.evaluate().isNotEmpty
        ? theory
        : feedback.evaluate().isNotEmpty
        ? feedback
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  throw StateError('Live lesson did not reach an assessment');
}

Future<Map<String, dynamic>> _saved() async {
  await _store().flush();
  final raw = (await _store().readDurableSnapshot()).payload!;
  expect(act0CanonicalProgressIsValidV1(raw), isTrue);
  return jsonDecode(raw) as Map<String, dynamic>;
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await _store().flush();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  for (final landed in [false, true]) {
    testWidgets('CNT content waits for canonical ACK, landed=$landed',
        (tester) async {
      _phone(tester);
      final disk = _Disk();
      SharedPreferencesStorePlatform.instance = disk;
      addTearDown(disk.resume);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(_state(tester).debugContentExposurePayloadV1()['presentedTaskIds'],
          isEmpty);
      await _tab(tester, 'Learn');
      expect(_state(tester).debugContentExposurePayloadV1()['presentedTaskIds'],
          isEmpty, reason: 'Planning/selection is not presentation');
      disk.pause(afterLanding: landed);
      await _tap(tester, 'act0_shell_current_mission_cta', settle: false);
      await tester.pump();
      expect(disk.started!.isCompleted, isTrue);
      expect(find.byType(Act0ContentPresentationGateV1), findsOneWidget);
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      final taskId = _state(tester).debugSelectedTaskIdV1() as String;
      expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
          isFalse);
      disk.resume();
      await tester.pumpAndSettle();
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
      final saved = await _saved();
      expect(saved['schemaVersion'], 19);
      expect(saved['contentExposureHistory']['presentedTaskIds'], contains(taskId));
      expect(saved['earnedXp'], 0);
      expect(saved['learningEvidenceHistory'], isEmpty);
      expect(saved['completedTaskIds'], isEmpty);
      await _unmount(tester);
    });
  }

  testWidgets('CNT indeterminate save stays hidden and retry retains prior view',
      (tester) async {
    _phone(tester);
    final disk = _Disk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(disk.resume);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    disk.failNextExposure = true;
    await _startLesson(tester);
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(find.byKey(const Key('act0_content_presentation_retry')), findsOneWidget);
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
        isFalse);
    disk.resume();
    await _tap(tester, 'act0_content_presentation_retry');
    expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
        isFalse, reason: 'Retry is not a second learner presentation');
    final id = _state(tester).debugSelectedTaskIdV1();
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    expect((await _saved())['contentExposureHistory']['presentedTaskIds'],
        contains(id), reason: 'Ordinary snapshots retain the reservation');
    await _unmount(tester);
  });

  testWidgets('CNT coalesced reservation is not ACK and retries without recapture',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _tab(tester, 'Learn');
    final state = _state(tester);
    tester.binding.addPostFrameCallback((_) => state.debugPersistProgressV1());
    await _tap(tester, 'act0_shell_current_mission_cta');
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(find.byKey(const Key('act0_content_presentation_retry')), findsOneWidget);
    expect(state.debugContentReservationV1()['acknowledged'], isFalse);
    expect(state.debugContentReservationV1()['wasPreviouslyPresented'], isFalse);
    await _tap(tester, 'act0_content_presentation_retry');
    expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
    expect(state.debugContentReservationV1()['wasPreviouslyPresented'], isFalse);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(identical(state, _state(tester)), isTrue);
    expect(state.debugContentReservationV1()['wasPreviouslyPresented'], isFalse,
        reason: 'Same-attempt parent rebuild does not reserve again');
    await _unmount(tester);
  });

  testWidgets('CNT Review excludes later locked checks from availability',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    // The untouched canonical first lesson starts at teaching. Its later
    // assessments are present in the catalog but not yet launchable.
    expect(_state(tester).debugUnshownTaskIdsV1(), isEmpty);
    await _tab(tester, 'Review');
    expect(find.byKey(const Key('act0_content_availability_notice')), findsOneWidget);
    expect(find.textContaining('No new checks available'), findsOneWidget);
    expect(find.textContaining('will not count as an unseen check'), findsOneWidget);
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing,
        reason: 'Exhaustion does not substitute a familiar runner');
    await _unmount(tester);
  });

  testWidgets(
      'CNT presented available pool stays exhausted after durable restart',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);

    List<String>? availableBeforePresentation;
    // Advance actual teaching CTAs, observing the synchronous unlock BEFORE
    // the next frame reserves the newly available assessment's exposure.
    for (var step = 0; step < 24; step++) {
      final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
      final next = theory.evaluate().isNotEmpty
          ? theory
          : find.byKey(const Key('act0_shell_continue_cta'));
      expect(next, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.ensureVisible(next);
      await tester.tap(next); // Deliberately no pump before the pool read.
      final ids = List<String>.from(_state(tester).debugUnshownTaskIdsV1());
      if (ids.isNotEmpty) {
        availableBeforePresentation = ids;
        break;
      }
      await tester.pumpAndSettle();
    }
    expect(availableBeforePresentation, isNotNull,
        reason: 'Must consume a genuinely nonempty pool, not a locked catalog');
    final available = availableBeforePresentation!;
    expect(available, hasLength(1),
        reason: 'The real first-incomplete route currently unlocks one check');
    final taskId = available.single;
    expect(_state(tester).debugContentExposurePayloadV1()['presentedTaskIds'],
        isNot(contains(taskId)));

    // The Action journey deliberately selects its same-signal decision rather
    // than the generic first-incomplete node. Open the captured available node
    // through Learn's actual guarded callback instead of assuming both match.
    await tester.pumpAndSettle();
    final activeRunner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    activeRunner.onBack();
    await tester.pumpAndSettle();
    await _tab(tester, 'Learn');
    final learn = tester.widget<Act0LearnPathShellV1>(
      find.byType(Act0LearnPathShellV1),
    );
    final lesson = learn.lessons.singleWhere(
      (lesson) => lesson.taskList.any((task) => task.taskId == taskId),
    );
    expect(_state(tester).debugUnshownTaskIdsV1(), available);
    expect(_state(tester).debugContentExposurePayloadV1()['presentedTaskIds'],
        isNot(contains(taskId)));
    final beforePresentation = await _saved();
    learn.onStartTask(lesson.lessonId, taskId);
    await tester.pumpAndSettle();
    final runner = await _reachAssessment(tester);
    expect(_state(tester).debugSelectedTaskIdV1(), taskId);
    expect(_state(tester).debugContentReservationV1()['acknowledged'], isTrue);
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
        isFalse);
    expect(_state(tester).debugUnshownTaskIdsV1(), isEmpty);
    final presented = await _saved();
    expect(presented['earnedXp'], beforePresentation['earnedXp']);
    expect(presented['completedTaskIds'], beforePresentation['completedTaskIds']);
    expect(presented['learningEvidenceHistory'],
        beforePresentation['learningEvidenceHistory']);
    expect(presented['contentExposureHistory']['presentedTaskIds'],
        contains(taskId));
    expect(presented['completedTaskIds'], isNot(contains(taskId)));
    expect(
        (presented['learningEvidenceHistory'] as List)
            .whereType<Map>()
            .where((record) => record['taskId'] == taskId),
        isEmpty,
        reason: 'Presentation consumes novelty without completing an answer');

    // Leave the unanswered assessment using its real source-owned callback.
    runner.onBack();
    await tester.pumpAndSettle();
    await _tab(tester, 'Review');
    expect(find.byKey(const Key('act0_content_availability_notice')),
        findsOneWidget);
    expect(find.textContaining('No new checks available'), findsOneWidget);
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    final beforeRestart = await _saved();
    await _unmount(tester);

    // Preserve canonical durable storage; no progress/catalog injection.
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final restoredRunner = find.byType(Act0LessonRunnerShellV1);
    if (restoredRunner.evaluate().isNotEmpty) {
      tester.widget<Act0LessonRunnerShellV1>(restoredRunner).onBack();
      await tester.pumpAndSettle();
    }
    expect(_state(tester).debugUnshownTaskIdsV1(), isEmpty);
    await _tab(tester, 'Review');
    expect(find.byKey(const Key('act0_content_availability_notice')),
        findsOneWidget);
    expect(find.textContaining('No new checks available'), findsOneWidget);
    expect(find.textContaining('will not count as an unseen check'),
        findsOneWidget);
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    final afterRestart = await _saved();
    expect(afterRestart['earnedXp'], beforeRestart['earnedXp']);
    expect(afterRestart['completedTaskIds'], beforeRestart['completedTaskIds']);
    expect(afterRestart['learningEvidenceHistory'],
        beforeRestart['learningEvidenceHistory']);
    expect(afterRestart['contentExposureHistory']['presentedTaskIds'],
        contains(taskId));

    // An explicit familiar revisit must not replenish the exhausted pool.
    await _tab(tester, 'Learn');
    tester.widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
        .onStartTask(lesson.lessonId, taskId);
    await tester.pumpAndSettle();
    await _reachAssessment(tester);
    expect(_state(tester).debugSelectedTaskIdV1(), taskId);
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
        isTrue);
    expect(_state(tester).debugUnshownTaskIdsV1(), isEmpty);
    await _unmount(tester);
  });

  testWidgets('CNT abandoned pending presentation cannot reopen on late ACK',
      (tester) async {
    _phone(tester);
    final disk = _Disk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(disk.resume);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    disk.pause();
    await _startLesson(tester, settle: false);
    await tester.pump();
    expect(disk.started!.isCompleted, isTrue);
    final id = _state(tester).debugSelectedTaskIdV1();
    await _tap(tester, 'act0_content_presentation_exit');
    disk.resume();
    await tester.pumpAndSettle();
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    await _startLesson(tester);
    expect(_state(tester).debugSelectedTaskIdV1(), id);
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
        isTrue, reason: 'A new entry cannot reuse the old unshown entitlement');
    await _unmount(tester);
  });

  testWidgets('CNT unmount while save pending never exposes disposed content',
      (tester) async {
    _phone(tester);
    final disk = _Disk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(disk.resume);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    disk.pause(afterLanding: true);
    await _startLesson(tester, settle: false);
    await tester.pump();
    final id = _state(tester).debugSelectedTaskIdV1();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    disk.resume();
    await tester.pumpAndSettle();
    await _store().flush();
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(_state(tester).debugContentExposurePayloadV1()['presentedTaskIds'],
        contains(id));
    await _unmount(tester);
  });

  testWidgets('CNT unanswered presentation survives restart without XP/evidence',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);
    final id = _state(tester).debugSelectedTaskIdV1();
    await _unmount(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
      await _startLesson(tester);
    }
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'],
        isTrue);
    expect(_state(tester).debugSelectedTaskIdV1(), id);
    final saved = await _saved();
    expect(saved['earnedXp'], 0);
    expect(saved['learningEvidenceHistory'], isEmpty);
    expect(saved['contentExposureHistory']['presentedTaskIds'], contains(id));
    await _unmount(tester);
  });

  testWidgets('CNT first-view control and v3 attempt identities survive sequence/replay/restart',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);
    final first = await _reachAssessment(tester);
    final firstId = _state(tester).debugSelectedTaskIdV1();
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'], isFalse);
    final firstOption = first.runner.options.firstWhere((option) => option.isCorrect);
    await _tap(tester, 'act0_shell_option_${firstOption.id}');
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    final firstRecords = (await _saved())['learningEvidenceHistory'] as List;
    final firstRecord = firstRecords.whereType<Map>()
        .lastWhere((record) => record['taskId'] == firstId);
    expect(firstRecord['reviewKind'], 'initialAssessment',
        reason: 'The gate must not downgrade every genuine first presentation');
    final second = await _reachAssessment(tester);
    final secondId = _state(tester).debugSelectedTaskIdV1();
    expect(secondId, isNot(firstId));
    final secondOption = second.runner.options.firstWhere((option) => option.isCorrect);
    await _tap(tester, 'act0_shell_option_${secondOption.id}');
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    // Replay through the source-owned Undo while the feedback runner still
    // owns this task. Cold restore deliberately selects the next incomplete
    // task, so it must not be used as a synthetic replay route.
    final feedback = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(feedback.runner.phase, Act0LessonPhaseV1.review);
    feedback.onUndoInteraction!();
    await tester.pumpAndSettle();
    final replay = await _reachAssessment(tester);
    expect(_state(tester).debugSelectedTaskIdV1(), secondId);
    final replayOption = replay.runner.options.firstWhere((option) => option.isCorrect);
    await _tap(tester, 'act0_shell_option_${replayOption.id}');
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    final before = (await _saved())['learningEvidenceHistory'] as List;
    expect((before.last as Map)['reviewKind'], 'exactReplay');
    final retained = <String, String>{
      for (final record in before.whereType<Map>())
        record['recordId'] as String: jsonEncode(record),
    };
    await _unmount(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
      await _startLesson(tester);
    }
    final next = await _reachAssessment(tester);
    expect(_state(tester).debugSelectedTaskIdV1(), isNot(secondId));
    final nextOption = next.runner.options.firstWhere((option) => option.isCorrect);
    await _tap(tester, 'act0_shell_option_${nextOption.id}');
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    final after = (await _saved())['learningEvidenceHistory'] as List;
    final records = after.whereType<Map>().toList();
    expect(records.length, greaterThan(before.length));
    final ids = records.map((record) => record['recordId'] as String).toList();
    expect(ids.every((id) => id.startsWith('v3|')), isTrue);
    expect(ids.toSet().length, ids.length);
    expect(ids.toSet(), containsAll(retained.keys));
    final orders = records.map((record) => record['createdOrder'] as int).toList();
    for (var i = 1; i < orders.length; i++) {
      expect(orders[i], greaterThan(orders[i - 1]));
    }
    for (final record in records) {
      final id = record['recordId'] as String;
      final prefix = 'v3|${record['runId']}|';
      expect(id.startsWith(prefix), isTrue);
      expect(int.parse(id.substring(prefix.length).split('|').first),
          record['createdOrder']);
      final original = retained[id];
      if (original != null) expect(jsonEncode(record), original);
    }
    await _unmount(tester);
  });

  testWidgets('CNT unanswered assessment is never unseen after restart',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);
    final firstRunner = await _reachAssessment(tester);
    final lessonId = firstRunner.selectedLessonId!;
    final taskId = _state(tester).debugSelectedTaskIdV1();
    await _unmount(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    // Restore can select the earlier generic first-incomplete node. Replay
    // the actual source-owned theory-to-decision sequence, not a bypass of
    // Learn's availability guard for the unanswered decision itself.
    expect(_state(tester).debugContentExposurePayloadV1()['presentedTaskIds'],
        contains(taskId));
    final restored = find.byType(Act0LessonRunnerShellV1);
    if (restored.evaluate().isNotEmpty) {
      tester.widget<Act0LessonRunnerShellV1>(restored).onBack();
      await tester.pumpAndSettle();
    }
    await _tab(tester, 'Learn');
    final learn = tester.widget<Act0LearnPathShellV1>(
      find.byType(Act0LearnPathShellV1),
    );
    final sequence = act0ActionLearningSequenceForTaskV1(taskId as String);
    expect(sequence, isNotNull,
        reason: 'This case follows the real initial Action sequence');
    expect(sequence!.practiceTaskId, taskId);
    expect(learn.completedTaskIds, contains(sequence.theoryTaskId));
    learn.onStartTask(lessonId, sequence.theoryTaskId);
    await tester.pumpAndSettle();
    expect(_state(tester).debugSelectedTaskIdV1(), sequence.theoryTaskId);
    final runner = await _reachAssessment(tester);
    expect(_state(tester).debugSelectedTaskIdV1(), taskId);
    expect(_state(tester).debugContentReservationV1()['wasPreviouslyPresented'], isTrue);
    final option = runner.runner.options.firstWhere((option) => option.isCorrect);
    await _tap(tester, 'act0_shell_option_${option.id}');
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    final saved = await _saved();
    final records = (saved['learningEvidenceHistory'] as List)
        .whereType<Map>().where((record) => record['taskId'] == taskId);
    expect(records, isNotEmpty);
    expect(records.every((record) => record['reviewKind'] != 'unseenTransfer'), isTrue);
    await _unmount(tester);
  });

  testWidgets('CNT older complete backup cannot replace newer nonempty exposure',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);
    final backup = await _transfer().export(exportedAtUtc: DateTime.utc(2026, 11, 10));
    final older = _codec.inspectBytes(backup).payload;
    await _reachAssessment(tester);
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    await _unmount(tester);
    final before = await _store().readDurableSnapshot();
    expect(before.payload, isNot(older));
    final transfer = _transfer();
    final proposal = await transfer.inspect(backup);
    expect(proposal.conflict, isTrue);
    expect(await transfer.confirm(proposal), Act0Dat07RestoreOutcomeV1.conflict);
    expect(await _store().readDurableSnapshot(), before);
  });

  for (final malformed in [false, true]) {
    testWidgets('CNT schema19 ${malformed ? 'malformed' : 'missing'} history stays incomplete',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      _state(tester).debugPersistProgressV1();
      await tester.pumpAndSettle();
      await _unmount(tester);
      final data = await _saved();
      if (malformed) {
        // Fault fixture changes only the optional field, never learner evidence.
        data['contentExposureHistory'] = {
          'schemaVersion': 1,
          'hasCompleteLineage': true,
          'presentedTaskIds': ['retired-source-id', 7],
        };
      } else {
        data.remove('contentExposureHistory');
      }
      expect(await _store().save(jsonEncode(data)), isTrue);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(_state(tester).debugContentExposurePayloadV1()['hasCompleteLineage'],
          isFalse);
      await _tab(tester, 'Review');
      expect(find.byKey(const Key('act0_content_availability_notice')), findsOneWidget);
      expect(find.textContaining('history is unavailable'), findsOneWidget);
      _state(tester).debugPersistProgressV1();
      await tester.pumpAndSettle();
      final saved = await _saved();
      expect(saved['contentExposureHistory']['hasCompleteLineage'], isFalse);
      if (malformed) {
        expect(saved['contentExposureHistory']['presentedTaskIds'],
            contains('retired-source-id'), reason: 'Do not filter old catalog IDs');
      }
      await _unmount(tester);
    });
  }

  testWidgets('CNT DAT export/import retains exact exposure bytes and later saves',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);
    final id = _state(tester).debugSelectedTaskIdV1();
    await _unmount(tester);
    final original = await _store().readDurableSnapshot();
    final backup = await _transfer().export(exportedAtUtc: DateTime.utc(2026, 11, 10));
    expect(_codec.inspectBytes(backup).payload, original.payload);
    // A different installation, not a fabricated progress fixture.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final transfer = _transfer();
    final proposal = await transfer.inspect(backup);
    expect(await transfer.confirm(proposal), Act0Dat07RestoreOutcomeV1.restored);
    expect((await _store().readDurableSnapshot()).payload, original.payload);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    _state(tester).debugPersistProgressV1();
    await tester.pumpAndSettle();
    expect((await _saved())['contentExposureHistory']['presentedTaskIds'], contains(id));
    await _unmount(tester);
  });

  testWidgets('CNT failed Placement presentation Back uses canonical diagnostic exit',
      (tester) async {
    _phone(tester);
    final disk = _Disk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(disk.resume);
    await tester.pumpWidget(_app(firstStart: true));
    await tester.pumpAndSettle();
    await _tap(tester, 'act0_shell_placement_intro_cta');
    final online = find.byKey(const Key('act0_shell_placement_option_online'));
    expect(online, findsOneWidget);
    await Scrollable.ensureVisible(tester.element(online), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(online.hitTestable(), findsOneWidget);
    await tester.tap(online);
    await tester.pumpAndSettle();
    await _tap(tester, 'act0_shell_placement_next_cta');
    await _tap(tester, 'act0_shell_placement_option_decisions');
    await _tap(tester, 'act0_shell_placement_next_cta');
    disk.failNextExposure = true;
    await _tap(tester, 'act0_shell_placement_start_diagnostic');
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(find.byKey(const Key('act0_content_presentation_retry')), findsOneWidget);
    disk.resume();
    await _tap(tester, 'act0_content_presentation_exit');
    expect(find.byType(Act0PlacementShellV1), findsOneWidget,
        reason: 'Back must clear diagnostic mode, not merely switch tabs');
    expect(find.byType(Act0ContentPresentationGateV1), findsNothing);
    // Invoke the actual placement widget's source-owned normal-start action;
    // no learner record, route flag or attempt identity is injected by the test.
    tester.widget<Act0PlacementShellV1>(find.byType(Act0PlacementShellV1))
        .onStartFromZero();
    await tester.pumpAndSettle();
    for (var step = 0; step < 8; step++) {
      final welcome = find.byKey(const Key('act0_shell_welcome_primary_cta'));
      if (welcome.evaluate().isEmpty) break;
      await _tap(tester, 'act0_shell_welcome_primary_cta');
    }
    if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
      await _startLesson(tester);
    }
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.preserveSourceOwnedQuestion, isFalse);
    await _unmount(tester);
  });

  testWidgets('CNT failed repair presentation Back clears canonical repair context',
      (tester) async {
    _phone(tester);
    final disk = _Disk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(disk.resume);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _startLesson(tester);
    final runner = await _reachAssessment(tester);
    final wrong = runner.runner.options.firstWhere((option) => !option.isCorrect);
    await _tap(tester, 'act0_shell_option_${wrong.id}');
    await _tap(tester, 'act0_shell_runner_back');
    await _tab(tester, 'Review');
    disk.failNextExposure = true;
    await _tap(tester, 'act0_academy_review_leaf_repair_cta');
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(find.byKey(const Key('act0_content_presentation_retry')), findsOneWidget);
    expect(_state(tester).debugActiveRepairContextPayloadV1(), isNotEmpty);
    disk.resume();
    await _tap(tester, 'act0_content_presentation_exit');
    expect(_state(tester).debugActiveRepairContextPayloadV1(), isEmpty);
    expect(find.byType(Act0ContentPresentationGateV1), findsNothing);
    await _startLesson(tester);
    expect(_state(tester).debugActiveRepairContextPayloadV1(), isEmpty);
    await _unmount(tester);
  });

  testWidgets('CNT DAT freeze rejects late presentation ACK before verified remount',
      (tester) async {
    _phone(tester);
    final disk = _Disk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(disk.resume);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    // Establish a genuinely launchable task using the normal mission route.
    await _startLesson(tester);
    final initialRunner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final lessonId = initialRunner.selectedLessonId!;
    final taskId = initialRunner.selectedTaskId!;
    final old = _state(tester);
    initialRunner.onBack();
    await tester.pumpAndSettle();
    await _tab(tester, 'Learn');
    final learn = tester.widget<Act0LearnPathShellV1>(
      find.byType(Act0LearnPathShellV1),
    );
    final delayedStart = learn.onStartTask;
    expect(learn.selectedTaskId, taskId);
    await _tab(tester, 'You');
    await _tap(tester, 'act0_academy_you_leaf_settings');
    await _store().flush();

    // Delayed shell-owned callback while Settings is still mounted. This is
    // an overlap/lifetime test, not a tap through an obscuring settings route.
    // The shell remains mounted beneath Navigator; no stale Settings closure
    // or private route mutation is used to enter DAT.
    disk.pause();
    delayedStart(lessonId, taskId);
    await tester.pump();
    await tester.pump();
    expect(disk.started!.isCompleted, isTrue);
    expect(old.debugSelectedTaskIdV1(), taskId);
    expect(old.debugContentReservationV1()['acknowledged'], isFalse);
    expect(find.byType(Act0ContentPresentationGateV1, skipOffstage: false),
        findsOneWidget);
    final liveSettings = tester.widget<Act0AcademySettingsLeafV1>(
      find.byType(Act0AcademySettingsLeafV1),
    );
    expect(liveSettings.input.onBackupRestore, isNotNull);
    liveSettings.input.onBackupRestore!();
    await tester.pump();
    disk.resume();
    await tester.pumpAndSettle();
    expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
    expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    expect(old.debugContentReservationV1()['acknowledged'], isFalse);
    final before = await _store().readDurableSnapshot();
    old.debugPersistProgressV1();
    await tester.pumpAndSettle();
    expect(await _store().readDurableSnapshot(), before);
    await _tap(tester, 'dat07_back');
    expect(identical(old, _state(tester)), isFalse);
    await _unmount(tester);
  });
}

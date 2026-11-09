import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_canonical_store_port_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

const _key = 'act0_shell_progress_v1';
const _codec = Act0Dat07CodecV1(
  isValidProgress: act0CanonicalProgressIsValidV1,
  supportedProgressSchema: act0CanonicalProgressSchemaV1,
);

Act0ProgressStoreV1 _store() => Act0ProgressStoreV1(
  key: _key,
  isValidPayload: act0CanonicalProgressIsValidV1,
);

Act0Dat07TransferV1 _transfer(Act0ProgressStoreV1 store) =>
    Act0Dat07TransferV1(
      codec: _codec,
      port: Act0Dat07CanonicalStorePortV1(
        store: store,
        supportedProgressSchema: act0CanonicalProgressSchemaV1,
      ),
    );

class _Files implements Act0Dat07FileBridgeV1 {
  Uint8List? selected;
  Uint8List? shared;
  int selections = 0;

  @override
  Future<Uint8List?> selectBackup() async {
    selections++;
    return selected;
  }

  @override
  Future<void> shareBackup(Uint8List bytes) async {
    shared = Uint8List.fromList(bytes);
  }
}

/// A real preferences protocol backend. It changes acknowledgement/read
/// availability only; every progress byte originates in the canonical writer.
class _FaultDisk extends SharedPreferencesStorePlatform {
  final values = <String, Object>{};
  bool failAfterBackup = false;
  bool readsUnavailable = false;
  int uncertainBackups = 0;
  int headWrites = 0;
  int clearCalls = 0;
  Completer<void>? clearStarted;
  Completer<void>? clearRelease;

  @override
  Future<Map<String, Object>> getAll() async {
    if (readsUnavailable) throw StateError('Test storage read unavailable');
    return Map<String, Object>.of(values);
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key == 'flutter.${_key}_head') headWrites++;
    values[key] = value;
    if (failAfterBackup && key == 'flutter.${_key}_backup') {
      failAfterBackup = false;
      uncertainBackups++;
      readsUnavailable = true;
      return false; // Landed bytes, indeterminate acknowledgement.
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
    clearCalls++;
    final started = clearStarted;
    if (started != null && !started.isCompleted) started.complete();
    final release = clearRelease;
    if (release != null) await release.future;
    values.clear();
    return true;
  }
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app(_Files files, {bool firstStart = false}) => MaterialApp(
  locale: const Locale('en'),
  home: Act0Dat07ShellHostV1(
    shell: Act0ShellPreviewScreenV1(showPlacementOnStart: firstStart),
    fileBridge: files,
  ),
);

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _tab(WidgetTester tester, String label) async {
  final target = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  expect(target, findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

/// Starts with no progress fixture. The live lesson owns the selected answer,
/// evidence IDs, award calculation and complete schema-19 serialization.
Future<String> _earnAndSerialize(WidgetTester tester, _Files files) async {
  await tester.pumpWidget(_app(files));
  await tester.pumpAndSettle();
  await _tab(tester, 'Learn');
  await _tap(tester, 'act0_shell_current_mission_cta');
  var answered = false;
  for (var step = 0; step < 24; step++) {
    final runners = find.byType(Act0LessonRunnerShellV1);
    if (runners.evaluate().isNotEmpty) {
      final runner = tester.widget<Act0LessonRunnerShellV1>(runners);
      for (final option in runner.runner.options.where((o) => o.isCorrect)) {
        final choice = find.byKey(Key('act0_shell_option_${option.id}'));
        if (choice.evaluate().isEmpty) continue;
        expect(runner.evidenceRunId, isNotEmpty);
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        await tester.tap(choice);
        await tester.pumpAndSettle();
        answered = true;
        break;
      }
    }
    if (answered) break;
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    final next = theory.evaluate().isNotEmpty
        ? theory
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget, reason: 'Live lesson must expose its next step');
    await tester.pump(const Duration(milliseconds: 900));
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  expect(answered, isTrue, reason: 'A real rendered learner choice is required');
  final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
  state.debugPersistProgressV1(); // Existing serializer only, no injected data.
  await tester.pumpAndSettle();
  final store = _store();
  await store.flush();
  final raw = (await store.readDurableSnapshot()).payload!;
  expect(act0CanonicalProgressIsValidV1(raw), isTrue);
  final data = jsonDecode(raw) as Map<String, dynamic>;
  expect(data['schemaVersion'], act0CanonicalProgressSchemaV1);
  expect(data['learningEvidenceHistory'], isNotEmpty);
  expect(data['earnedXp'], greaterThan(0));
  return raw;
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await _store().flush();
}

Future<void> _openSettingsBackup(WidgetTester tester) async {
  final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
  if (runnerBack.evaluate().isNotEmpty) {
    await tester.tap(runnerBack);
    await tester.pumpAndSettle();
  }
  await _tab(tester, 'You');
  await _tap(tester, 'act0_academy_you_leaf_settings');
  await _tap(tester, 'act0_academy_settings_leaf_backup');
  expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('DAT07 serialized fresh defaults do not bypass first start',
      (tester) async {
    _phone(tester);
    final files = _Files();
    await tester.pumpWidget(_app(files));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
    state.debugPersistProgressV1();
    await tester.pumpAndSettle();
    await _store().flush();
    final raw = (await _store().readDurableSnapshot()).payload!;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    expect(act0CanonicalProgressIsValidV1(raw), isTrue);
    expect(data['completedTaskIds'], isEmpty);
    expect(data['completedLessonIds'], isEmpty);
    expect(data['skippedTaskIds'], isEmpty);
    expect(data['earnedXp'], 0);
    await _unmount(tester);
    await tester.pumpWidget(_app(files, firstStart: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing,
        reason: 'A valid but untouched default snapshot is not a learner path');
    expect(find.byType(Act0PlacementShellV1), findsOneWidget);
    expect(find.byType(Act0ShellPreviewScreenV1), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });

  for (final tombstone in [false, true]) {
    testWidgets('DAT07 real learner bytes restore into '
        '${tombstone ? 'a durable tombstone' : 'an absent store'}', (tester) async {
      _phone(tester);
      final files = _Files();
      await _earnAndSerialize(tester, files);
      await _unmount(tester);
      final source = _store();
      final original = await source.readDurableSnapshot();
      final bytes = await _transfer(source).export(
        exportedAtUtc: DateTime.utc(2026, 11, 10),
      );
      expect(_codec.inspectBytes(bytes).payload, original.payload);
      if (tombstone) {
        expect(await source.clear(), isTrue);
      } else {
        // Simulates a different installation, never constructs learner JSON.
        SharedPreferences.setMockInitialValues(<String, Object>{});
      }
      final target = _store();
      final before = await target.readDurableSnapshot();
      expect(before.payload, isNull);
      expect(before.revision, tombstone ? greaterThan(original.revision) : 0);
      final controller = _transfer(target);
      final preview = await controller.inspect(bytes);
      expect(preview.mayRestore, isTrue);
      expect(await controller.confirm(preview), Act0Dat07RestoreOutcomeV1.restored);
      final after = await _store().readDurableSnapshot();
      expect(after.payload, original.payload);
      expect(after.revision, greaterThan(before.revision));
      expect(await target.save(original.payload!), isFalse,
          reason: 'The committing port must fence its own old lease');
      final freshController = _transfer(_store());
      expect(await freshController.confirm(await freshController.inspect(bytes)),
          Act0Dat07RestoreOutcomeV1.alreadyPresent);
      expect(await _store().readDurableSnapshot(), after,
          reason: 'Repeated import must not award XP or advance the revision');
    });
  }

  testWidgets('DAT07 malformed file preserves complete real learner state',
      (tester) async {
    _phone(tester);
    await _earnAndSerialize(tester, _Files());
    await _unmount(tester);
    final before = await _store().readDurableSnapshot();
    final controller = _transfer(_store());
    await expectLater(controller.inspect(Uint8List.fromList(utf8.encode('{'))),
        throwsA(isA<Act0Dat07ErrorV1>()));
    expect(await _store().readDurableSnapshot(), before);
  });

  testWidgets('DAT07 Settings export fences old state and Back remounts it',
      (tester) async {
    _phone(tester);
    final files = _Files();
    await _earnAndSerialize(tester, files);
    final dynamic old = tester.state(find.byType(Act0ShellPreviewScreenV1));
    await _openSettingsBackup(tester);
    final before = await _store().readDurableSnapshot();
    old.debugPersistProgressV1();
    await tester.pumpAndSettle();
    await _store().flush();
    expect(await _store().readDurableSnapshot(), before);
    await _tap(tester, 'dat07_export');
    expect(_codec.inspectBytes(files.shared!).payload, before.payload);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
    await _tap(tester, 'dat07_back');
    expect(find.byType(Act0Dat07TransferScreenV1), findsNothing);
    final dynamic fresh = tester.state(find.byType(Act0ShellPreviewScreenV1));
    expect(identical(old, fresh), isFalse);
    expect(await _store().readDurableSnapshot(), before,
        reason: 'Frozen old dispose and hidden bootstrap must not save');
    fresh.debugPersistProgressV1();
    await tester.pumpAndSettle();
    await _store().flush();
    final after = await _store().readDurableSnapshot();
    expect(after.revision, greaterThan(before.revision));
    final a = jsonDecode(after.payload!) as Map<String, dynamic>;
    final b = jsonDecode(before.payload!) as Map<String, dynamic>;
    expect(a['earnedXp'], b['earnedXp']);
    expect(a['learningEvidenceHistory'], b['learningEvidenceHistory']);
    await _unmount(tester);
  });

  testWidgets('DAT07 first-start restore reloads hidden shell without reimport',
      (tester) async {
    _phone(tester);
    final files = _Files();
    await _earnAndSerialize(tester, files);
    await _unmount(tester);
    final original = await _store().readDurableSnapshot();
    files.selected = await _transfer(_store()).export(
      exportedAtUtc: DateTime.utc(2026, 11, 10),
    );
    expect(await _store().clear(), isTrue);
    final empty = await _store().readDurableSnapshot();
    await tester.pumpWidget(_app(files, firstStart: true));
    await tester.pumpAndSettle();
    final dynamic old = tester.state(find.byType(Act0ShellPreviewScreenV1));
    await _tap(tester, 'dat07_first_start_restore');
    await _tap(tester, 'dat07_select_file');
    expect(await _store().readDurableSnapshot(), empty);
    await _tap(tester, 'dat07_confirm');
    expect(find.text('Saved progress restored and reloaded.'), findsOneWidget);
    final restored = await _store().readDurableSnapshot();
    expect(restored.payload, original.payload);
    expect(restored.revision, greaterThan(empty.revision));
    final dynamic hidden = tester.state(
      find.byType(Act0ShellPreviewScreenV1, skipOffstage: false),
    );
    expect(identical(old, hidden), isFalse);
    hidden.debugPersistProgressV1();
    await tester.pumpAndSettle();
    await _store().flush();
    expect(await _store().readDurableSnapshot(), restored);
    await _tap(tester, 'dat07_select_file');
    expect(find.byKey(const Key('dat07_already_present')), findsOneWidget);
    expect(await _store().readDurableSnapshot(), restored);
    await _tap(tester, 'dat07_cancel');
    await _tap(tester, 'dat07_back');
    expect(find.byType(Act0Dat07TransferScreenV1), findsNothing);
    expect(files.selections, 2);
    expect(find.byType(Act0PlacementShellV1), findsNothing,
        reason: 'Imported learner must not enter first-install placement, '
            'which can clear earned task and lesson completions');
    expect(await _store().readDurableSnapshot(), restored);
    await _unmount(tester);
    await tester.pumpWidget(_app(files, firstStart: true));
    await tester.pumpAndSettle();
    expect(find.byType(Act0PlacementShellV1), findsNothing,
        reason: 'Restore routing must survive restart without device-local '
            'intake or welcome preference fixtures');
    final dynamic restarted = tester.state(find.byType(Act0ShellPreviewScreenV1));
    restarted.debugPersistProgressV1();
    await tester.pumpAndSettle();
    await _store().flush();
    final restartData = jsonDecode((await _store().load())!) as Map<String, dynamic>;
    final originalData = jsonDecode(original.payload!) as Map<String, dynamic>;
    expect(restartData['earnedXp'], originalData['earnedXp']);
    expect(restartData['learningEvidenceHistory'], originalData['learningEvidenceHistory']);
    await _unmount(tester);
  });

  testWidgets('DAT07 waits for an already-started dev preferences clear',
      (tester) async {
    _phone(tester);
    final disk = _FaultDisk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(() {
      final release = disk.clearRelease;
      if (release != null && !release.isCompleted) release.complete();
    });
    final files = _Files();
    await _earnAndSerialize(tester, files);
    // Finish the first source session so its ordinary disposal is included in
    // the actual exported payload. No hand-authored progress JSON is used.
    await _unmount(tester);
    final original = await _store().readDurableSnapshot();
    files.selected = await _transfer(_store()).export(
      exportedAtUtc: DateTime.utc(2026, 11, 10),
    );
    await tester.pumpWidget(_app(files));
    await tester.pumpAndSettle();
    final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
    if (runnerBack.evaluate().isNotEmpty) {
      await tester.tap(runnerBack);
      await tester.pumpAndSettle();
    }
    await _tab(tester, 'Home');
    await _tap(tester, 'act0_academy_home_leaf_dev_menu');
    await _tap(tester, 'act0_shell_dev_menu_reset_progress');
    disk.clearStarted = Completer<void>();
    disk.clearRelease = Completer<void>();
    await _tap(tester, 'act0_shell_dev_menu_reset_confirm');
    expect(disk.clearStarted!.isCompleted, isTrue,
        reason: 'The real ProgressService.debugReset must reach prefs.clear');
    expect(disk.clearCalls, 1);

    // The resetter disappears while its OS preferences operation is pending.
    // A fresh host has a current Store lease and would be able to import into
    // the reset tombstone without the process-wide destructive-I/O barrier.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(_app(files, firstStart: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('dat07_first_start_restore')), findsNothing,
        reason: 'No new learner or restore route may escape a pending clear');
    expect(find.byType(Act0Dat07TransferScreenV1), findsNothing);
    expect(files.selections, 0);

    disk.clearRelease!.complete();
    await tester.pumpAndSettle();
    expect(disk.clearCalls, 1);
    expect((await _store().readDurableSnapshot()).payload, isNull);
    await _tap(tester, 'dat07_first_start_restore');
    await _tap(tester, 'dat07_select_file');
    await _tap(tester, 'dat07_confirm');
    final restored = await _store().readDurableSnapshot();
    expect(restored.payload, original.payload);
    expect(restored.revision, 1);
    await _tap(tester, 'dat07_back');
    await tester.pump(const Duration(milliseconds: 200));
    expect(await _store().readDurableSnapshot(), restored,
        reason: 'An earlier clear must not land after restored learner truth');
    expect(disk.clearCalls, 1);
    expect(files.selections, 1);
    await _unmount(tester);
  });

  testWidgets('DAT07 uncertain durable commit stays locked until reload retry',
      (tester) async {
    _phone(tester);
    final files = _Files();
    await _earnAndSerialize(tester, files);
    await _unmount(tester);
    final original = await _store().readDurableSnapshot();
    files.selected = await _transfer(_store()).export(
      exportedAtUtc: DateTime.utc(2026, 11, 10),
    );
    // A new installation with a faulting real preferences backend, not a fake
    // transfer controller or a synthesized progress fixture.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final disk = _FaultDisk();
    SharedPreferencesStorePlatform.instance = disk;
    addTearDown(() {
      disk.readsUnavailable = false;
      disk.failAfterBackup = false;
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });
    await tester.pumpWidget(_app(files, firstStart: true));
    await tester.pumpAndSettle();
    await _tap(tester, 'dat07_first_start_restore');
    await _tap(tester, 'dat07_select_file');
    disk.failAfterBackup = true;
    await _tap(tester, 'dat07_confirm');
    expect(disk.uncertainBackups, 1);
    expect(disk.headWrites, 1);
    expect(files.selections, 1);
    expect(find.byKey(const Key('dat07_retry_reload')), findsOneWidget);
    expect(find.textContaining('Restore and navigation remain locked.'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
    await _tap(tester, 'dat07_back');
    expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget,
        reason: 'Back cannot revive the old shell after an uncertain write');
    // A second failed read must not re-enter import or advance the head.
    await _tap(tester, 'dat07_retry_reload');
    expect(find.byKey(const Key('dat07_retry_reload')), findsOneWidget);
    expect(disk.headWrites, 1);
    expect(files.selections, 1);
    disk.readsUnavailable = false;
    await _tap(tester, 'dat07_retry_reload');
    expect(find.byKey(const Key('dat07_retry_reload')), findsNothing);
    expect(find.textContaining('Saved progress reloaded.'), findsOneWidget);
    expect(disk.headWrites, 1, reason: 'Reconciliation is read, not reimport');
    expect(files.selections, 1);
    final recovered = await _store().readDurableSnapshot();
    expect(recovered.payload, original.payload);
    expect(recovered.revision, 1);
    await _tap(tester, 'dat07_back');
    expect(find.byType(Act0Dat07TransferScreenV1), findsNothing);
    expect(find.byType(Act0PlacementShellV1), findsNothing);
    expect(await _store().readDurableSnapshot(), recovered);
    expect(disk.headWrites, 1);
    await _unmount(tester);
  });
}

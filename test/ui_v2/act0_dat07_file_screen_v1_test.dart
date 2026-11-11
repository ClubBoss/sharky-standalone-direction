import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';

class _FixturePort implements Act0Dat07ProgressPortV1 {
  _FixturePort([this.value]) : revision = value == null ? 0 : 1;
  String? value;
  int revision;
  int writes = 0;
  bool unverifiedAfterWrite = false;
  bool throwAfterWrite = false;

  @override
  Future<Act0Dat07DurableStateV1> readDurableSnapshot() async =>
      (revision: revision, payload: value);

  @override
  Future<Act0Dat07WriteResultV1> restoreIfUnchanged({
    required Act0Dat07DurableStateV1 expected,
    required String incomingPayload,
  }) async {
    if (value != expected.payload || revision != expected.revision) {
      return Act0Dat07WriteResultV1.changed;
    }
    value = incomingPayload;
    revision++;
    writes++;
    if (throwAfterWrite) throw StateError('synthetic post-write failure');
    if (unverifiedAfterWrite) return Act0Dat07WriteResultV1.unverified;
    return Act0Dat07WriteResultV1.committed;
  }
}

class _FakeFiles implements Act0Dat07FileBridgeV1 {
  _FakeFiles(this.selected);
  Uint8List? selected;
  Uint8List? shared;
  int pickerCalls = 0;

  @override
  Future<Uint8List?> selectBackup() async {
    pickerCalls++;
    return selected;
  }

  @override
  Future<void> shareBackup(Uint8List bytes) async => shared = bytes;
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  const saved = '{"schemaVersion":19,"earnedXp":7,'
      '"completedTaskIds":["task-1"],'
      '"completedLessonIds":["lesson-1"],'
      '"learningEvidenceHistory":[{"recordId":"a","assistanceKind":"none"}]}';
  const codec = Act0Dat07CodecV1(
    supportedProgressSchema: 19,
    isValidProgress: _valid,
  );

  Uint8List file() => codec.exportPayload(
    saved,
    exportedAtUtc: DateTime.utc(2026, 11, 9),
  );

  Widget screen(
    _FixturePort port,
    _FakeFiles files, {
    Future<void> Function()? reload,
  }) => MaterialApp(
    home: Act0Dat07TransferScreenV1(
      controller: Act0Dat07TransferV1(codec: codec, port: port),
      fileBridge: files,
      onRestored: reload ?? () async {},
      onReconcileRestore: reload ?? () async {},
    ),
  );

  testWidgets('DAT07 selection -> visible preview -> cancel -> no write', (tester) async {
    _phone(tester);
    final port = _FixturePort();
    final files = _FakeFiles(file());
    await tester.pumpWidget(screen(port, files));
    await tester.tap(find.byKey(const Key('dat07_select_file')));
    await tester.pumpAndSettle();
    expect(files.pickerCalls, 1);
    expect(find.byKey(const Key('dat07_preview_title')), findsOneWidget);
    expect(find.text('Earned XP: 7'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('dat07_cancel')), 120);
    expect(find.byKey(const Key('dat07_confirm')), findsOneWidget);
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const Key('dat07_cancel'))), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dat07_cancel')).hitTestable(), findsOneWidget);
    await tester.tap(find.byKey(const Key('dat07_cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dat07_preview_title')), findsNothing);
    expect(port.value, isNull);
    expect(port.writes, 0);
  });

  testWidgets('DAT07 selected file is confirmed only after preview', (tester) async {
    _phone(tester);
    final port = _FixturePort();
    final files = _FakeFiles(file());
    await tester.pumpWidget(screen(port, files));
    expect(port.writes, 0);
    await tester.tap(find.byKey(const Key('dat07_select_file')));
    await tester.pumpAndSettle();
    expect(port.writes, 0);
    await tester.scrollUntilVisible(find.byKey(const Key('dat07_confirm')), 120);
    await tester.tap(find.byKey(const Key('dat07_confirm')));
    await tester.pumpAndSettle();
    expect(port.value, saved);
    expect(port.writes, 1);
    expect(find.byKey(const Key('dat07_status')), findsOneWidget);
  });

  testWidgets('DAT07 conflicting local state disables confirmation', (tester) async {
    _phone(tester);
    final port = _FixturePort('different-local-state');
    final files = _FakeFiles(file());
    await tester.pumpWidget(screen(port, files));
    await tester.tap(find.byKey(const Key('dat07_select_file')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('dat07_conflict')),
      120,
    );
    expect(find.byKey(const Key('dat07_conflict')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('dat07_confirm')),
      120,
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('dat07_confirm')),
    );
    expect(button.onPressed, isNull);
    expect(port.writes, 0);
  });

  testWidgets('DAT07 backup uses share action, never overwrites progress', (tester) async {
    _phone(tester);
    final port = _FixturePort(saved);
    final files = _FakeFiles(null);
    await tester.pumpWidget(screen(port, files));
    await tester.tap(find.byKey(const Key('dat07_export')));
    await tester.pumpAndSettle();
    expect(files.shared, isNotNull);
    expect(codec.inspectBytes(files.shared!).earnedXp, 7);
    expect(port.writes, 0);
  });

  testWidgets('DAT07 successful restore waits for shell remount', (tester) async {
    _phone(tester);
    final port = _FixturePort();
    final files = _FakeFiles(file());
    final restart = Completer<void>();
    var callbackStarted = false;
    await tester.pumpWidget(screen(
      port,
      files,
      reload: () {
        callbackStarted = true;
        return restart.future;
      },
    ));
    await tester.tap(find.byKey(const Key('dat07_select_file')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('dat07_confirm')),
      120,
    );
    await tester.tap(find.byKey(const Key('dat07_confirm')));
    await tester.pump();
    expect(callbackStarted, true);
    expect(port.writes, 1);
    expect(
      tester.widget<FilledButton>(
        find.byKey(const Key('dat07_confirm')),
      ).onPressed,
      isNull,
    );
    restart.complete();
    await tester.pumpAndSettle();
    expect(find.text('Saved progress restored and reloaded.'), findsOneWidget);
  });

  testWidgets('DAT07 OS picker cancel yields no import or misleading success', (tester) async {
    _phone(tester);
    final port = _FixturePort();
    final files = _FakeFiles(null);
    await tester.pumpWidget(screen(port, files));
    await tester.tap(find.byKey(const Key('dat07_select_file')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dat07_preview_title')), findsNothing);
    expect(port.value, isNull);
    expect(port.writes, 0);
  });
  for (final mode in ['unverified', 'throw', 'success callback failure']) {
    testWidgets('DAT07 $mode locks exit and retries only reconciliation',
        (tester) async {
      _phone(tester);
      final port = _FixturePort()
        ..unverifiedAfterWrite = mode == 'unverified'
        ..throwAfterWrite = mode == 'throw';
      final files = _FakeFiles(file());
      final navigator = GlobalKey<NavigatorState>();
      final pendingReload = Completer<void>();
      var reloadCalls = 0;
      var failReload = true;
      var restoredCalls = 0;
      var backCalls = 0;
      Future<void> reconcile() {
        reloadCalls++;
        return failReload ? pendingReload.future : Future<void>.value();
      }

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: Text('Underlying learner route')),
      ));
      unawaited(navigator.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => Act0Dat07TransferScreenV1(
          controller: Act0Dat07TransferV1(codec: codec, port: port),
          fileBridge: files,
          onBack: () {
            backCalls++;
            navigator.currentState!.maybePop();
          },
          onRestored: () {
            restoredCalls++;
            return mode == 'success callback failure'
                ? pendingReload.future
                : Future<void>.value();
          },
          onReconcileRestore: reconcile,
        ),
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dat07_select_file')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('dat07_confirm')), 120,
      );
      final confirm = tester.widget<FilledButton>(
        find.byKey(const Key('dat07_confirm')),
      ).onPressed!;
      final staleBack = tester.widget<IconButton>(
        find.byKey(const Key('dat07_back')),
      ).onPressed!;
      final staleCancel = tester.widget<TextButton>(
        find.byKey(const Key('dat07_cancel')),
      ).onPressed!;
      confirm();
      staleBack();
      staleCancel();
      confirm(); // Same-frame callbacks must respect the synchronous lock.
      expect(backCalls, 0);
      await tester.pump();
      expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
      expect(find.byKey(const Key('dat07_preview_title')), findsOneWidget);
      expect(find.text('Import cancelled. Progress was not changed.'),
          findsNothing);
      expect(port.writes, 1);
      expect(restoredCalls, mode == 'success callback failure' ? 1 : 0);
      expect(reloadCalls, mode == 'success callback failure' ? 0 : 1);
      expect(tester.widget<PopScope>(
        find.byType(PopScope).last,
      ).canPop, isFalse);
      expect(tester.widget<IconButton>(
        find.byKey(const Key('dat07_back')),
      ).onPressed, isNull);
      expect(tester.widget<TextButton>(
        find.byKey(const Key('dat07_cancel')),
      ).onPressed, isNull);
      expect(await navigator.currentState!.maybePop(), isTrue);
      await tester.pump();
      expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
      expect(backCalls, 0);

      pendingReload.completeError(StateError('synthetic reload failure'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dat07_preview_title')), findsNothing);
      expect(tester.widget<OutlinedButton>(
        find.byKey(const Key('dat07_select_file')),
      ).onPressed, isNull);
      expect(tester.widget<FilledButton>(
        find.byKey(const Key('dat07_export')),
      ).onPressed, isNull);
      expect(await navigator.currentState!.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(Act0Dat07TransferScreenV1), findsOneWidget);
      expect(find.text('Saved progress restored and reloaded.'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('dat07_retry_reload')), -120,
      );
      failReload = false;
      await tester.tap(find.byKey(const Key('dat07_retry_reload')));
      await tester.pumpAndSettle();
      expect(reloadCalls, mode == 'success callback failure' ? 1 : 2);
      expect(port.writes, 1);
      expect(files.pickerCalls, 1);
      expect(find.byKey(const Key('dat07_retry_reload')), findsNothing);
      expect(find.text('Saved progress restored and reloaded.'), findsNothing);
      expect(tester.widget<PopScope>(
        find.byType(PopScope).last,
      ).canPop, isTrue);
      expect(await navigator.currentState!.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(Act0Dat07TransferScreenV1), findsNothing);
    });
  }

}

bool _valid(String payload) => payload.contains('"schemaVersion":19');

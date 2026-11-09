import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';

class _FixturePort implements Act0Dat07ProgressPortV1 {
  _FixturePort([this.value]);
  String? value;
  int writes = 0;

  @override
  Future<String?> readDurablePayload() async => value;

  @override
  Future<Act0Dat07WriteResultV1> restoreIfUnchanged({
    required String? expectedPayload,
    required String incomingPayload,
  }) async {
    if (value != expectedPayload) return Act0Dat07WriteResultV1.changed;
    value = incomingPayload;
    writes++;
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
}

bool _valid(String payload) => payload.contains('"schemaVersion":19');

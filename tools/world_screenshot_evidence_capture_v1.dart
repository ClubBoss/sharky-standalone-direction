import 'dart:convert';
import 'dart:io';

const _world0OutputDirPathV1 =
    'assets/audit_hub_v1/world_screenshot_evidence_v1/world0';
const _world10OutputDirPathV1 =
    'assets/audit_hub_v1/world_screenshot_evidence_v1/world10';

void main(List<String> args) async {
  int? world;
  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      _printUsageV1();
      exit(0);
    }
    if (arg.startsWith('--world=')) {
      world = int.tryParse(arg.substring('--world='.length));
      continue;
    }
    stderr.writeln('Unknown option: $arg');
    _printUsageV1();
    exit(64);
  }

  if (world == null || world < 0) {
    stderr.writeln('Provide --world=<non-negative integer>.');
    _printUsageV1();
    exit(64);
  }
  if (world != 0 && world != 10) {
    stderr.writeln('Only --world=0 and --world=10 are currently supported.');
    exit(64);
  }

  final outputDir = Directory(
    world == 0 ? _world0OutputDirPathV1 : _world10OutputDirPathV1,
  );
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync(
    'world_screenshot_evidence_capture_',
  );
  final testFile = File(
    '${tempDir.path}${Platform.pathSeparator}world${world}_screenshot_evidence_test.dart',
  );
  testFile.writeAsStringSync(_flutterTestSource(outputDir.path, world));

  final result = await Process.start(
    'flutter',
    <String>['test', testFile.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  stdout.addStream(result.stdout);
  stderr.addStream(result.stderr);
  final exitCode = await result.exitCode;

  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {
    // Best-effort cleanup.
  }

  if (exitCode != 0) {
    throw ProcessException(
      'flutter',
      <String>['test', testFile.path],
      'Screenshot capture test failed. See output above.',
      exitCode,
    );
  }

  final sessionIds = world == 0
      ? const <String>['w0.s01', 'w0.s05', 'w0.s10']
      : const <String>['cash.s01', 'tournament.s05', 'mixed.s10'];
  final entries = <Map<String, Object?>>[];
  for (final sessionId in sessionIds) {
    final file = File(
      '${outputDir.path}${Platform.pathSeparator}$sessionId.png',
    );
    if (!file.existsSync()) {
      throw StateError('Missing screenshot evidence artifact `${file.path}`.');
    }
    entries.add(<String, Object?>{
      'session_id': sessionId,
      'path': file.path.replaceAll(
        '${Directory.current.path}${Platform.pathSeparator}',
        '',
      ),
      'bytes': file.lengthSync(),
    });
  }

  final manifestFile = File(
    '${outputDir.path}${Platform.pathSeparator}manifest.json',
  );
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'world_id': 'W$world', 'artifact_dir': outputDir.path.replaceAll('${Directory.current.path}${Platform.pathSeparator}', ''), 'entries': entries})}\n',
  );
}

String _flutterTestSource(String outputDirPath, int world) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  final sessionIdsLiteral = world == 0
      ? "const sessions = <String>['w0.s01', 'w0.s05', 'w0.s10'];"
      : "const sessions = <String>['cash.s01', 'tournament.s05', 'mixed.s10'];";
  return '''
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 60,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    throw StateError('Timed out waiting for \${finder.description}');
  }

  testWidgets('capture representative W0 screenshot evidence', (tester) async {
    const outputDirPath = $escapedOutputDir;
    final outputDir = Directory(outputDirPath)..createSync(recursive: true);
    $sessionIdsLiteral

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final sessionId in sessions) {
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills(sessionId),
      ))!;
      final boundaryKey = Key('capture_' + sessionId);
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: boundaryKey,
            child: SessionDrillPlayerV1Screen(
              sessionId: sessionId,
              debugDrillsOverrideV1: drills,
            ),
          ),
        ),
      );
      await pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );
      await tester.pump(const Duration(milliseconds: 160));

      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      final byteData = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.5);
        return image.toByteData(format: ui.ImageByteFormat.png);
      });
      if (byteData == null) {
        throw StateError('Failed to capture screenshot for ' + sessionId);
      }
      final file = File('\${outputDir.path}/' + sessionId + '.png');
      file.writeAsBytesSync(Uint8List.view(byteData.buffer));
    }
  });
}
''';
}

void _printUsageV1() {
  stderr.writeln(
    'Usage: dart run tools/world_screenshot_evidence_capture_v1.dart --world=<n>',
  );
}

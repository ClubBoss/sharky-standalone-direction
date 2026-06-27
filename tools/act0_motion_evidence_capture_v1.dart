import 'dart:convert';
import 'dart:io';

const _outputRootPathV1 = 'output/motion_evidence/current';

const _momentsV1 = <_MotionMomentV1>[
  _MotionMomentV1(
    id: 'decision_feedback_reveal',
    surface: 'runnerFirstWrongFeedback',
    frameTimesMs: <int>[0, 80, 180, 320],
  ),
  _MotionMomentV1(
    id: 'repair_result_fix_landed',
    surface: 'repairResult',
    frameTimesMs: <int>[0, 80, 180, 320],
  ),
  _MotionMomentV1(
    id: 'session_summary_proof_hero',
    surface: 'sessionSummary',
    frameTimesMs: <int>[0, 80, 180, 320],
  ),
];

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsageV1();
    exit(0);
  }
  if (args.isNotEmpty) {
    _printUsageV1();
    exit(64);
  }

  final outputDir = Directory(_outputRootPathV1);
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  final tempDir = Directory.systemTemp.createTempSync(
    'act0_motion_evidence_capture_',
  );
  final testFile = File(
    '${tempDir.path}/act0_motion_evidence_capture_test.dart',
  );
  testFile.writeAsStringSync(_flutterTestSourceV1(outputDir.path));

  final result = await Process.start(
    'flutter',
    <String>['test', testFile.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  await stdout.addStream(result.stdout);
  await stderr.addStream(result.stderr);
  final exitCode = await result.exitCode.timeout(
    const Duration(minutes: 3),
    onTimeout: () {
      result.kill(ProcessSignal.sigterm);
      stderr.writeln(
        'act0_motion_evidence_capture_v1: flutter test timed out.',
      );
      return 124;
    },
  );
  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {
    // Best-effort cleanup.
  }
  if (exitCode != 0) {
    exit(exitCode);
  }

  final entries = <Map<String, Object?>>[];
  for (final moment in _momentsV1) {
    for (final frameMs in moment.frameTimesMs) {
      final path =
          '$_outputRootPathV1/${moment.id}_frame_${frameMs.toString().padLeft(3, '0')}ms.png';
      final file = File(path);
      if (!file.existsSync() || file.lengthSync() == 0) {
        stderr.writeln('Missing or empty motion evidence frame `$path`.');
        exit(1);
      }
      entries.add(<String, Object?>{
        'moment': moment.id,
        'surface': moment.surface,
        'frame_ms': frameMs,
        'path': path,
        'bytes': file.lengthSync(),
      });
    }
  }
  File('$_outputRootPathV1/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': 'act0_motion_evidence_v1', 'render_kind': 'flutter_widget_test_frame_sequence', 'generated_at': DateTime.now().toUtc().toIso8601String(), 'entries': entries, 'note': 'Generated motion evidence is local-only and uncommitted.'})}\n',
  );
  stdout.writeln(_outputRootPathV1);
}

String _flutterTestSourceV1(String outputDirPath) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  final statements = _momentsV1
      .map(
        (moment) =>
            '''
    await captureMoment(
      tester,
      '${moment.id}',
      Act0ControlledDemoCaptureSurfaceV1.${moment.surface},
      <int>${jsonEncode(moment.frameTimesMs)},
    );''',
      )
      .join();
  return '''
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDirPath = $escapedOutputDir;
  const compactSize = Size(375, 812);

  Widget host(Act0ControlledDemoCaptureSurfaceV1 surface) {
    final realTextButtonStyle = ButtonStyle(
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'Roboto'),
      ),
    );
    return MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData(
        fontFamily: 'Roboto',
        filledButtonTheme: FilledButtonThemeData(style: realTextButtonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: realTextButtonStyle,
        ),
        textButtonTheme: TextButtonThemeData(style: realTextButtonStyle),
      ),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: RepaintBoundary(
        key: const Key('act0_motion_capture_boundary'),
        child: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: surface,
          ),
        ),
      ),
    );
  }

  Future<void> loadFontFamily(String family, Uint8List bytes) async {
    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load().timeout(const Duration(seconds: 10));
  }

  Future<void> loadIconFonts() async {
    const iconFonts = <(String, String)>[
      ('MaterialIcons', 'build/unit_test_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('MaterialIcons', 'build/flutter_assets/fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      ('packages/cupertino_icons/CupertinoIcons', 'build/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ];
    final loaded = <String>{};
    for (final (family, path) in iconFonts) {
      if (loaded.contains(family)) {
        continue;
      }
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      await loadFontFamily(family, await file.readAsBytes());
      loaded.add(family);
    }
    if (!loaded.contains('MaterialIcons')) {
      throw StateError('No local MaterialIcons font found for motion capture.');
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUpAll(() async {
    final file = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
    }
    await loadIconFonts();
  });

  Future<void> captureFrame(WidgetTester tester, String path) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('act0_motion_capture_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) {
      throw StateError('Failed to capture motion frame ' + path);
    }
    File(path).writeAsBytesSync(Uint8List.view(byteData.buffer));
  }

  Future<void> captureMoment(
    WidgetTester tester,
    String momentId,
    Act0ControlledDemoCaptureSurfaceV1 surface,
    List<int> frameTimesMs,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    tester.view.physicalSize = compactSize;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(host(surface));
    var elapsedMs = 0;
    for (final frameMs in frameTimesMs) {
      final delta = frameMs - elapsedMs;
      if (delta > 0) {
        await tester.pump(Duration(milliseconds: delta));
        elapsedMs = frameMs;
      } else {
        await tester.pump();
      }
      final fileName = '\${momentId}_frame_\${frameMs.toString().padLeft(3, '0')}ms.png';
      await captureFrame(tester, '\$outputDirPath/\$fileName');
    }
  }

  testWidgets('capture Act0 motion evidence frame sequences', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.resetSystemFontFamily();
    });
$statements
  });
}
''';
}

void _printUsageV1() {
  stderr.writeln('Usage: dart run tools/act0_motion_evidence_capture_v1.dart');
}

class _MotionMomentV1 {
  const _MotionMomentV1({
    required this.id,
    required this.surface,
    required this.frameTimesMs,
  });

  final String id;
  final String surface;
  final List<int> frameTimesMs;
}

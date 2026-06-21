import 'dart:convert';
import 'dart:io';

const _outputRootPathV1 = 'output/screen_review/current';
const _schemaV1 = 'screen_review_fast_v1';

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    _printUsageV1();
    exit(0);
  }

  if (args.length != 2 || args[0] != 'core' || args[1] != 'compact') {
    _printUsageV1();
    exit(64);
  }

  final group = args[0];
  final device = args[1];
  final outputDir = Directory('$_outputRootPathV1/${group}_fast');
  final stagingRoot = Directory('output/screen_review/.staging')
    ..createSync(recursive: true);
  final stagingDir = Directory(
    '${stagingRoot.path}/${group}_fast.${DateTime.now().toUtc().toIso8601String().replaceAll(':', '').replaceAll('.', '_')}.$pid',
  )..createSync(recursive: true);

  final tempDir = Directory(
    Directory.systemTemp.createTempSync('act0_real_text_surface_capture_').path,
  );
  final testFile = File(
    '${tempDir.path}${Platform.pathSeparator}act0_real_text_surface_capture_test.dart',
  );
  testFile.writeAsStringSync(_flutterTestSource(stagingDir.path));

  final stopwatch = Stopwatch()..start();
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
      stderr.writeln('screen_review_fast_v1: flutter test timed out.');
      return 124;
    },
  );
  stopwatch.stop();

  try {
    tempDir.deleteSync(recursive: true);
  } catch (_) {
    // Best-effort cleanup.
  }

  if (exitCode != 0) {
    stderr.writeln(
      'screen_review_fast_v1: capture failed; previous output preserved at ${outputDir.path}',
    );
    stderr.writeln(
      'screen_review_fast_v1: failed staging output left at ${stagingDir.path}',
    );
    exit(exitCode);
  }

  const surfaces = <String>['home', 'learn', 'practice', 'review', 'profile'];
  final entries = <Map<String, Object?>>[];
  for (final surface in surfaces) {
    final file = File(
      '${stagingDir.path}${Platform.pathSeparator}$device.$surface.png',
    );
    if (!file.existsSync() || file.lengthSync() == 0) {
      stderr.writeln('Missing or empty screenshot artifact `${file.path}`.');
      stderr.writeln(
        'screen_review_fast_v1: previous output preserved at ${outputDir.path}',
      );
      exit(1);
    }
    entries.add(<String, Object?>{
      'device': device,
      'surface': surface,
      'path': 'output/screen_review/current/${group}_fast/$device.$surface.png',
      'bytes': file.lengthSync(),
    });
  }

  final manifestFile = File(
    '${stagingDir.path}${Platform.pathSeparator}manifest.json',
  );
  manifestFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schema': _schemaV1, 'group': group, 'packet': '${group}_fast', 'device': device, 'render_kind': 'flutter_widget_test_real_text', 'captured_at': DateTime.now().toUtc().toIso8601String(), 'runtime_seconds': stopwatch.elapsedMilliseconds / 1000.0, 'surfaces': surfaces, 'entries': entries, 'note': 'Generated screenshots are local-only and uncommitted.'})}\n',
  );

  final previousDir = Directory('${outputDir.path}.previous');
  if (previousDir.existsSync()) {
    previousDir.deleteSync(recursive: true);
  }
  if (outputDir.existsSync()) {
    outputDir.renameSync(previousDir.path);
  }
  stagingDir.renameSync(outputDir.path);
  if (previousDir.existsSync()) {
    previousDir.deleteSync(recursive: true);
  }

  stdout.writeln(outputDir.path);
}

String _flutterTestSource(String outputDirPath) {
  final escapedOutputDir = jsonEncode(outputDirPath);
  return '''
import 'dart:io';
import 'dart:convert';
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
  final outputDir = Directory(outputDirPath)..createSync(recursive: true);
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
        key: const Key('act0_real_text_capture_boundary'),
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

  Future<void> loadRealTextFont() async {
    const candidates = <String>[
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      '/System/Library/Fonts/SFNS.ttf',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final bytes = await file.readAsBytes();
      await loadFontFamily('Roboto', bytes);
      await loadFontFamily('Ahem', bytes);
      return;
    }
    throw StateError('No local real-text font found for screen capture.');
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
      final bytes = await file.readAsBytes();
      await loadFontFamily(family, bytes);
      loaded.add(family);
    }
    if (!loaded.contains('MaterialIcons')) {
      throw StateError('No local MaterialIcons font found for screen capture.');
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUpAll(() async {
    await loadRealTextFont();
    await loadIconFonts();
  });

  Future<void> pumpCompact(
    WidgetTester tester,
    Act0ControlledDemoCaptureSurfaceV1 surface,
  ) async {
    tester.view.physicalSize = compactSize;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(host(surface));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
  }

  String colorToHex(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255);
    final red = (color.r * 255).round().clamp(0, 255);
    final green = (color.g * 255).round().clamp(0, 255);
    final blue = (color.b * 255).round().clamp(0, 255);
    return '#'
        '\${alpha.toRadixString(16).padLeft(2, '0')}'
        '\${red.toRadixString(16).padLeft(2, '0')}'
        '\${green.toRadixString(16).padLeft(2, '0')}'
        '\${blue.toRadixString(16).padLeft(2, '0')}';
  }

  void writeTextRepairOverlays(WidgetTester tester, String fileName) {
    final overlays = <Map<String, Object?>>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget;
      if (widget is! Text) {
        continue;
      }
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.trim().isEmpty) {
        continue;
      }
      final defaultStyle = DefaultTextStyle.of(element).style;
      final explicitStyle = widget.style;
      if (defaultStyle.fontFamily != null || explicitStyle?.fontFamily != null) {
        continue;
      }
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (size.width <= 0 || size.height <= 0) {
        continue;
      }
      overlays.add(<String, Object?>{
        'text': text,
        'left': topLeft.dx,
        'top': topLeft.dy,
        'width': size.width,
        'height': size.height,
        'fontSize': (explicitStyle?.fontSize ?? defaultStyle.fontSize ?? 14),
        'fontWeight': (explicitStyle?.fontWeight ?? defaultStyle.fontWeight ?? FontWeight.w400).value,
        'color': colorToHex(explicitStyle?.color ?? defaultStyle.color ?? Colors.white),
      });
    }
    final overlayFile = File('\${outputDir.path}/' + fileName + '.text_overlays.json');
    overlayFile.writeAsStringSync(jsonEncode(overlays));
  }

  Future<void> captureSurface(
    WidgetTester tester,
    String fileName,
    Act0ControlledDemoCaptureSurfaceV1 surface,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpCompact(tester, surface);
    writeTextRepairOverlays(tester, fileName);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('act0_real_text_capture_boundary')),
    );
    final byteData = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    if (byteData == null) {
      throw StateError('Failed to capture screenshot for ' + fileName);
    }
    final file = File('\${outputDir.path}/' + fileName);
    file.writeAsBytesSync(Uint8List.view(byteData.buffer));
  }

  testWidgets('capture real-text Act0 core review surfaces', (tester) async {
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.resetSystemFontFamily();
    });

    await captureSurface(
      tester,
      'compact.home.png',
      Act0ControlledDemoCaptureSurfaceV1.firstWeekHome,
    );
    await captureSurface(
      tester,
      'compact.learn.png',
      Act0ControlledDemoCaptureSurfaceV1.firstWeekLearn,
    );
    await captureSurface(
      tester,
      'compact.practice.png',
      Act0ControlledDemoCaptureSurfaceV1.practice,
    );
    await captureSurface(
      tester,
      'compact.review.png',
      Act0ControlledDemoCaptureSurfaceV1.firstWeekReview,
    );
    await captureSurface(
      tester,
      'compact.profile.png',
      Act0ControlledDemoCaptureSurfaceV1.firstWeekProfile,
    );
  });
}
''';
}

void _printUsageV1() {
  stderr.writeln(
    'Usage: dart run tools/act0_real_text_surface_capture_v1.dart core compact',
  );
}

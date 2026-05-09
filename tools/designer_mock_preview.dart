// Flutter CLI tool: tools/designer_mock_preview.dart
// Renders each V3 widget in a static preview canvas and saves PNGs for designer review.
// ASCII-only logs. Telemetry event: designer_mock_preview_completed

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_svg/flutter_svg.dart';
// Needed domain models
import '../lib/services/adaptive_progression_service.dart';
import '../lib/services/session_summary_service.dart';

// Import all widgets to preview
import '../lib/ui_v3/widgets/adaptive_feedback_banner.dart';
import '../lib/ui_v3/widgets/daily_goal_xp_bar.dart';
import '../lib/ui_v3/widgets/micro_win_feedback.dart';
import '../lib/ui_v3/widgets/reward_popup.dart';
import '../lib/ui_v3/widgets/session_summary_card.dart';
import '../lib/ui_v3/widgets/streak_bar.dart';

// Consolidated dummy stubs (after imports, before main)
final dummyNotifier = ValueNotifier<AdaptiveFeedbackSignal?>(null);
final dummySessionMetrics = SessionMetrics(
  accuracy: 0.8,
  averagePotEv: 0.0,
  timeSpentSeconds: 0,
);

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previewDir = Directory('release/_previews');
  if (!previewDir.existsSync()) previewDir.createSync(recursive: true);
  final widgets = <String, WidgetBuilder>{
    'adaptive_feedback_banner': (_) =>
        AdaptiveFeedbackBanner(notifier: dummyNotifier),
    'daily_goal_xp_bar': (_) => const DailyGoalXpBar(),
    'micro_win_feedback': (_) => const MicroWinFeedback(),
    'reward_popup': (_) =>
        RewardPopup(bonusXp: 10, streakLength: 2, onDismiss: () {}),
    'session_summary_card': (_) =>
        SessionSummaryCard(metrics: dummySessionMetrics, onContinue: () {}),
    'streak_bar': (_) => const StreakBar(currentStreak: 1, nextMilestone: 2),
  };
  final missing = <String>[];
  final images = <String, int>{};
  final stopwatch = Stopwatch()..start();
  for (final entry in widgets.entries) {
    final name = entry.key;
    try {
      await _renderWidgetToPng(entry.value, (bytes) async {
        final outPath = p.join(previewDir.path, '$name.png');
        await File(outPath).writeAsBytes(bytes);
        images[name] = bytes.length;
        print('Rendered $name.png (${bytes.length} bytes)');
      });
    } catch (e) {
      print('FAILED: $name ($e)');
      missing.add(name);
    }
  }
  // SVGs (brand + mascot)
  final svgDirs = [
    Directory('assets/brand'),
    Directory('assets/brand/icons'),
    Directory('assets/mascot'),
  ];
  for (final dir in svgDirs) {
    if (!dir.existsSync()) continue;
    for (final file in dir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.svg')) continue;
      final name = p.basenameWithoutExtension(file.path);
      try {
        await _renderSvgToPng(file.path, (bytes) async {
          final outPath = p.join(previewDir.path, '$name.png');
          await File(outPath).writeAsBytes(bytes);
          images[name] = bytes.length;
          print('Rendered $name.png (${bytes.length} bytes)');
        });
      } catch (e) {
        print('FAILED: $name.svg ($e)');
        missing.add(name);
      }
    }
  }
  final totalSize = images.values.fold(0, (a, b) => a + b);
  final summary = StringBuffer()
    ..writeln('Designer Mock Preview Summary')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Images: ${images.length}')
    ..writeln('Total Size: $totalSize bytes')
    ..writeln('Missing: ${missing.length}')
    ..writeln('Missing List: ${missing.join(', ')}');
  var summaryPath = 'release/_reports/designer_mock_preview_summary.txt';
  try {
    await File(summaryPath).writeAsString(summary.toString());
  } catch (_) {
    // Fallback to exports if reports directory is not writable
    summaryPath = 'release/_exports/designer_mock_preview_summary.txt';
    await File(summaryPath).writeAsString(summary.toString());
  }
  // Telemetry
  final telemetry = {
    'event': 'designer_mock_preview_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'images': images.length,
    'total_size': totalSize,
    'missing': missing.length,
    'duration_ms': stopwatch.elapsedMilliseconds,
  };
  final telemetryPath =
      'release/_exports/designer_mock_preview_telemetry.jsonl';
  await File(
    telemetryPath,
  ).writeAsString(jsonEncode(telemetry) + '\n', mode: FileMode.append);
  print('+------------------------------+');
  print('| Designer Mock Preview READY! |');
  print('+------------------------------+');
  print('Images: ${images.length}');
  print('Total Size: $totalSize bytes');
  print('Missing: ${missing.length}');
  print('Summary: $summaryPath');
  print('Telemetry: $telemetryPath');
}

Future<void> _renderWidgetToPng(
  WidgetBuilder builder,
  Future<void> Function(Uint8List) onBytes,
) async {
  testWidgets('Render widget to PNG', (tester) async {
    final testWidget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: const Key('preview'),
            child: Builder(builder: builder),
          ),
        ),
      ),
    );
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const Key('preview')));
    final boundary = context.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    await onBytes(byteData!.buffer.asUint8List());
  });
}

Future<void> _renderSvgToPng(
  String svgPath,
  Future<void> Function(Uint8List) onBytes,
) async {
  testWidgets('Render SVG to PNG', (tester) async {
    final svgWidget = SvgPicture.asset(
      svgPath,
      width: 256,
      height: 256,
      key: const Key('svgpreview'),
    );
    final testWidget = MaterialApp(
      home: Scaffold(body: Center(child: svgWidget)),
    );
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const Key('svgpreview')));
    final boundary = context.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    await onBytes(byteData!.buffer.asUint8List());
  });
}

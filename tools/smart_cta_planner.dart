import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/smart_cta_planner_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/smart_cta_planner.txt';
const String _summaryJsonPath = '$_reportsDir/smart_cta_planner.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = SmartCtaPlannerService();
  SmartCtaBundle bundle;

  try {
    bundle = await service.run();
  } on SmartCtaPlannerException catch (error) {
    stderr.writeln('smart_cta_planner: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('smart_cta_planner: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(bundle);
  final summaryJson = bundle.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(bundle);
    });
    stdout.writeln('smart_cta_planner: CTA map recorded.');
  } catch (error) {
    stderr.writeln('smart_cta_planner: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(SmartCtaBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('SMART CTA PLANNER')
    ..writeln('=================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Primary CTA: ${bundle.primaryCta}')
    ..writeln('Secondary CTA: ${bundle.secondaryCta}')
    ..writeln('Micro CTA: ${bundle.microCta}')
    ..writeln('CTA route hint: ${bundle.ctaRouteHint}')
    ..writeln('CTA score: ${bundle.ctaScore.toStringAsFixed(2)}');
  return buffer.toString();
}

Future<void> _appendTelemetry(SmartCtaBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'smart_cta_planner_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'cta_score': bundle.ctaScore,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  await _setPermissions(dir.path, true);
  try {
    await action();
  } finally {
    await _setPermissions(dir.path, false);
  }
}

Future<void> _setPermissions(String path, bool writable) async {
  final mode = writable ? 'u+w' : 'u-w';
  try {
    await Process.run('chmod', ['-R', mode, path]);
  } catch (_) {}
}

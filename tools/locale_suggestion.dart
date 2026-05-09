import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/locale_suggestion_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/locale_suggestion_summary.txt';
const String _summaryJsonPath = '$_reportsDir/locale_suggestion_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LocaleSuggestionService();
  late final LocaleSuggestionBundle bundle;

  try {
    bundle = await service.run();
  } on LocaleSuggestionException catch (error) {
    stderr.writeln('locale_suggestion: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('locale_suggestion: unexpected error: $error');
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
    stdout.writeln('locale_suggestion: summary recorded.');
    exitCode = 0;
  } catch (error) {
    stderr.writeln('locale_suggestion: report write failed: $error');
    exitCode = 2;
    return;
  }
}

String _buildSummary(LocaleSuggestionBundle bundle) {
  final stats = bundle.pseudoStats;
  final avgRatio = (stats['avg_length_ratio'] as num?)?.toDouble() ?? 0.0;
  final maxRatio = (stats['max_length_ratio'] as num?)?.toDouble() ?? 0.0;
  final entryCount = (stats['entry_count'] as num?)?.toInt() ?? 0;
  final highRiskCount = (stats['high_risk_entries'] as num?)?.toInt() ?? 0;
  final buffer = StringBuffer()
    ..writeln('LOCALE SUGGESTION ENGINE')
    ..writeln('========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Risk score: ${bundle.riskScore.toStringAsFixed(2)}')
    ..writeln('Priority: ${bundle.priority}')
    ..writeln('Missing keys: ${bundle.missingKeys.length}')
    ..writeln('Pseudo entries: $entryCount')
    ..writeln('Avg pseudo ratio: ${avgRatio.toStringAsFixed(2)}')
    ..writeln('Max pseudo ratio: ${maxRatio.toStringAsFixed(2)}')
    ..writeln('High-risk pseudo entries: $highRiskCount');
  return buffer.toString();
}

Future<void> _appendTelemetry(LocaleSuggestionBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'locale_suggestion_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'risk_score': bundle.riskScore,
    'priority': bundle.priority,
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

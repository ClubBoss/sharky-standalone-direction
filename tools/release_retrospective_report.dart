import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now();

  final sources = <String, String>{
    'final': 'release/_reports/final_release_summary.txt',
    'stability': 'release/_reports/stability_scaling_plan.txt',
    'brand': 'release/_reports/brand_asset_report.txt',
    'telemetry': 'release/_reports/telemetry_dashboard.txt',
    'governance': 'release/_reports/governance_log.txt',
  };

  final contents = <String, String>{};
  for (final entry in sources.entries) {
    contents[entry.key] = await _readFile(entry.value);
  }

  final stabilityScore = _extractNumber(
    contents['stability']!,
    'Stability Score',
  );
  final qualityMetrics = _extractQualityMetrics(contents['final']!);
  final telemetryMetrics = _extractTelemetryMetrics(contents['telemetry']!);
  final governanceSummary = _extractGovernanceSummary(contents['governance']!);

  final report = _buildReport(
    version: 'v1.0',
    qualityMetrics: qualityMetrics,
    telemetryMetrics: telemetryMetrics,
    stabilityScore: stabilityScore,
    brandNotes: contents['brand']!,
    governanceSummary: governanceSummary,
  );

  final output = File('release/_reports/release_retrospective_v1.txt');
  await output.parent.create(recursive: true);
  await output.writeAsString(report);

  final duration = DateTime.now().difference(start);
  stdout.writeln(
    jsonEncode({
      'event': 'release_retrospective_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'sections': 6,
      'duration_ms': duration.inMilliseconds,
      'score': stabilityScore,
    }),
  );
}

Future<String> _readFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
}

double _extractNumber(String content, String label) {
  final regex = RegExp('$label[: ]+([0-9]+\\.?[0-9]*)');
  final match = regex.firstMatch(content);
  if (match != null) {
    return double.tryParse(match.group(1)!) ?? 0.0;
  }
  return 0.0;
}

Map<String, String> _extractQualityMetrics(String content) {
  final sections = <String, String>{
    'Analyzer': _extractLine(content, 'format='),
    'Tests': _extractLine(content, 'tests_failed='),
    'QA': _extractLine(content, 'sim_ok='),
  };
  return sections;
}

Map<String, String> _extractTelemetryMetrics(String content) {
  final lines = content
      .split('\n')
      .where((line) => line.contains(':'))
      .map((line) => line.trim())
      .take(5)
      .toList();
  return {'Top Metrics': lines.join(' | ')};
}

String _extractGovernanceSummary(String content) {
  final entries = content
      .split('\n\n')
      .where((chunk) => chunk.trim().isNotEmpty);
  return entries.isEmpty ? 'No entries' : entries.last.trim();
}

String _extractLine(String content, String pattern) {
  final regex = RegExp('($pattern.+)');
  final match = regex.firstMatch(content);
  return match?.group(1) ?? 'N/A';
}

String _buildReport({
  required String version,
  required Map<String, String> qualityMetrics,
  required Map<String, String> telemetryMetrics,
  required double stabilityScore,
  required String brandNotes,
  required String governanceSummary,
}) {
  final buffer = StringBuffer()
    ..writeln('Poker Analyzer Release Retrospective')
    ..writeln('Version Overview: $version')
    ..writeln('')
    ..writeln('Quality Metrics')
    ..writeln(' - Analyzer: ${qualityMetrics['Analyzer']}')
    ..writeln(' - Tests: ${qualityMetrics['Tests']}')
    ..writeln(' - QA: ${qualityMetrics['QA']}')
    ..writeln('')
    ..writeln('AI & Telemetry Performance')
    ..writeln('   ${telemetryMetrics['Top Metrics']}')
    ..writeln('')
    ..writeln('Monetization & Growth')
    ..writeln(' - Refer to telemetry dashboard for detailed KPIs.')
    ..writeln('')
    ..writeln('Stability & Scaling Score')
    ..writeln(' - Score: ${stabilityScore.toStringAsFixed(2)} / 100')
    ..writeln('')
    ..writeln('Brand & Asset Summary')
    ..writeln(brandNotes.isEmpty ? ' - No brand report available.' : brandNotes)
    ..writeln('')
    ..writeln('Governance and Archival Summary')
    ..writeln(governanceSummary)
    ..writeln('');
  return buffer.toString();
}

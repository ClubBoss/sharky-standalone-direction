import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final uxPath = 'release/_reports/ux_stress_recovery_summary.txt';
  final designerPath = 'release/_reports/designer_handoff_manifest.md';
  final marketingPath = 'release/_reports/marketing_analytics_summary.txt';
  final outPath = 'release/_exports/public_showcase_audit.txt';
  final telemetryPath = 'release/_exports/public_showcase_telemetry.jsonl';

  // Read sources
  final ux = await _safeRead(uxPath);
  final designer = await _safeRead(designerPath);
  final marketing = await _safeRead(marketingPath);

  // Parse and aggregate
  final visualHealth = _parseVisualHealth(ux, designer);
  final uxRetention = _parseUxRetention(ux);
  final marketingSignals = _parseMarketingSignals(marketing);

  // Compose report
  final report = StringBuffer()
    ..writeln('Public Showcase & Marketing Audit')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}\n')
    ..writeln(_asciiBox('Visual Health', visualHealth))
    ..writeln(_asciiBox('UX Retention', uxRetention))
    ..writeln(_asciiBox('Marketing Signals', marketingSignals));

  await File(outPath).writeAsString(report.toString());

  // Emit telemetry
  final telemetry = {
    'event': 'public_showcase_audit_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'visual_health': visualHealth.length,
    'ux_retention': uxRetention.length,
    'marketing_signals': marketingSignals.length,
  };
  try {
    await File(
      telemetryPath,
    ).writeAsString(jsonEncode(telemetry) + '\n', mode: FileMode.append);
  } catch (_) {}

  print(
    '''\n+------------------------------+\n| Public Showcase Audit READY! |\n+------------------------------+\nReport: $outPath\nTelemetry: $telemetryPath\n''',
  );
}

Future<String> _safeRead(String path) async {
  try {
    return await File(path).readAsString();
  } catch (_) {
    return '';
  }
}

List<String> _parseVisualHealth(String ux, String designer) {
  final lines = <String>[];
  // UX metrics
  final summary = RegExp(
    r'Summary Metrics[\s\S]+?Telemetry Snapshot',
    multiLine: true,
  ).firstMatch(ux);
  if (summary != null) {
    lines.addAll(
      summary.group(0)!.split('\n').where((l) => l.trim().isNotEmpty),
    );
  }
  // Visual events from designer
  final events = RegExp(
    r'## Section 3[\s\S]+?\n##',
    multiLine: true,
  ).firstMatch(designer);
  if (events != null) {
    lines.addAll(
      events.group(0)!.split('\n').where((l) => l.contains('visual_')),
    );
  }
  return lines;
}

List<String> _parseUxRetention(String ux) {
  final lines = <String>[];
  // Session metrics table
  final session = RegExp(
    r'Session Metrics[\s\S]+?Summary Metrics',
    multiLine: true,
  ).firstMatch(ux);
  if (session != null) {
    lines.addAll(session.group(0)!.split('\n').where((l) => l.contains('|')));
  }
  // Telemetry snapshot
  final snap = RegExp(
    r'Telemetry Snapshot[\s\S]+',
    multiLine: true,
  ).firstMatch(ux);
  if (snap != null) {
    lines.addAll(snap.group(0)!.split('\n').where((l) => l.trim().isNotEmpty));
  }
  return lines;
}

List<String> _parseMarketingSignals(String marketing) {
  final lines = <String>[];
  for (final l in marketing.split('\n')) {
    if (l.contains(':') || l.contains('PASS') || l.contains('FAIL')) {
      lines.add(l);
    }
  }
  return lines;
}

String _asciiBox(String title, List<String> lines) {
  final width =
      (lines.isEmpty
              ? title.length
              : lines.map((l) => l.length).reduce((a, b) => a > b ? a : b))
          .clamp(title.length, 60);
  final bar = '┌${'─' * (width + 2)}┐\n';
  final mid = '│ ${title.padRight(width)} │\n';
  final content = lines.isEmpty
      ? '│ ${'(no data)'.padRight(width)} │\n'
      : lines.map((l) => '│ ${l.padRight(width)} │\n').join();
  final end = '└${'─' * (width + 2)}┘\n';
  return bar + mid + content + end;
}

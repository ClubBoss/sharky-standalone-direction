import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> arguments) async {
  try {
    final enableV2 = arguments.contains('--metrics-v2');
    final readiness = await _readJsonFile(
      'tools/_reports/full_readiness_summary.json',
    );
    final version = await _readJsonFile('release/version.json');
    final advisor = await _readOptionalJsonFile(
      'tools/_reports/ai_advisor_summary.json',
    );
    final simulation = await _readOptionalJsonFile(
      'tools/_reports/simulation_metrics.json',
    );
    final uiPerf = await _readOptionalJsonFile(
      'tools/_reports/ui_perf_metrics.json',
    );
    final feedback = await _readOptionalJsonFile(
      'tools/_reports/public_beta_feedback_summary.json',
    );
    final buildSize = await _readBuildSizeBytes(
      'release/poker_analyzer_beta.zip',
    );

    final metrics = LandingMetrics.fromData(
      readiness,
      version,
      advisor: advisor,
      simulation: simulation,
      uiPerformance: uiPerf,
      buildSizeBytes: buildSize,
    );
    Map<String, Object?>? v2;
    if (enableV2) {
      v2 = _buildMetricsV2(
        readiness: readiness,
        version: version,
        advisor: advisor,
        feedback: feedback,
        simulation: simulation,
      );
    }

    await _writeHtml(metrics, metricsV2: v2);
    await _writeMetadata(metrics);
    if (v2 != null) {
      await _writeMetricsV2Json(v2);
    }

    _printAscii(metrics);
    if (enableV2) {
      stdout.writeln('  metrics_v2 : release/landing/metrics_v2.json');
    }
    final result = <String, Object?>{
      'pass': true,
      'readiness_score': metrics.readinessScore,
      'modules': metrics.totalModules,
      'average_performance': metrics.averagePerformance,
      'test_coverage': metrics.testCoverage,
      'index': metrics.indexPath,
      'metadata': metrics.metadataPath,
      if (enableV2) 'metrics_v2': 'release/landing/metrics_v2.json',
    };
    print(jsonEncode(result));
  } catch (e, st) {
    stderr.writeln('Landing page generation failed: $e');
    stderr.writeln(st);
    print(jsonEncode({'pass': false, 'error': e.toString()}));
    exitCode = 1;
  }
}

Future<Map<String, dynamic>> _readJsonFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw StateError('Missing required file: $path');
  }
  final raw = await file.readAsString();
  final data = jsonDecode(raw);
  if (data is! Map<String, dynamic>) {
    throw StateError('Expected JSON object in $path');
  }
  return data;
}

Future<Map<String, dynamic>?> _readOptionalJsonFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return null;
  }
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      return data;
    }
  } catch (_) {}
  return null;
}

Future<int> _readBuildSizeBytes(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return 0;
  }
  try {
    return await file.length();
  } catch (_) {
    return 0;
  }
}

Future<void> _writeHtml(
  LandingMetrics metrics, {
  Map<String, Object?>? metricsV2,
}) async {
  final dir = Directory(metrics.directory);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final buffer = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="en">')
    ..writeln('<head>')
    ..writeln('  <meta charset="utf-8" />')
    ..writeln('  <meta http-equiv="X-UA-Compatible" content="IE=edge" />')
    ..writeln(
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
    )
    ..writeln('  <title>Poker Analyzer Beta Release</title>')
    ..writeln('  <style>')
    ..writeln('    :root {')
    ..writeln('      --brand-teal: #26a69a;')
    ..writeln('      --brand-dark: #1f2933;')
    ..writeln('      --brand-light: #ffffff;')
    ..writeln('      --brand-muted: #4b5563;')
    ..writeln('    }')
    ..writeln('    body {')
    ..writeln('      font-family: "Helvetica Neue", Arial, sans-serif;')
    ..writeln('      margin: 0;')
    ..writeln('      padding: 0;')
    ..writeln('      background: var(--brand-dark);')
    ..writeln('      color: var(--brand-light);')
    ..writeln('      line-height: 1.6;')
    ..writeln('    }')
    ..writeln('    .container {')
    ..writeln('      max-width: 960px;')
    ..writeln('      margin: 0 auto;')
    ..writeln('      padding: 32px 16px 64px;')
    ..writeln('    }')
    ..writeln('    header {')
    ..writeln('      text-align: center;')
    ..writeln('      padding: 32px 16px;')
    ..writeln('      border-radius: 12px;')
    ..writeln(
      '      background: linear-gradient(135deg, rgba(38,166,154,0.95), rgba(31,41,51,0.95));',
    )
    ..writeln('      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.35);')
    ..writeln('    }')
    ..writeln('    header h1 {')
    ..writeln('      margin: 0;')
    ..writeln('      font-size: 2.4rem;')
    ..writeln('      letter-spacing: 0.05em;')
    ..writeln('    }')
    ..writeln('    header p {')
    ..writeln('      margin-top: 12px;')
    ..writeln('      font-size: 1.1rem;')
    ..writeln('      color: rgba(255, 255, 255, 0.85);')
    ..writeln('    }')
    ..writeln('    .metrics {')
    ..writeln('      display: grid;')
    ..writeln(
      '      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));',
    )
    ..writeln('      gap: 16px;')
    ..writeln('      margin: 40px 0;')
    ..writeln('    }')
    ..writeln('    .metric-card {')
    ..writeln('      background: rgba(31, 41, 51, 0.8);')
    ..writeln('      border-radius: 12px;')
    ..writeln('      padding: 20px;')
    ..writeln('      border: 1px solid rgba(38, 166, 154, 0.25);')
    ..writeln('      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.25);')
    ..writeln('    }')
    ..writeln('    .metric-card h2 {')
    ..writeln('      margin: 0 0 8px;')
    ..writeln('      font-size: 1rem;')
    ..writeln('      text-transform: uppercase;')
    ..writeln('      color: rgba(255, 255, 255, 0.72);')
    ..writeln('      letter-spacing: 0.08em;')
    ..writeln('    }')
    ..writeln('    .metric-card p {')
    ..writeln('      margin: 0;')
    ..writeln('      font-size: 1.8rem;')
    ..writeln('      font-weight: 600;')
    ..writeln('      color: var(--brand-teal);')
    ..writeln('    }')
    ..writeln('    .links {')
    ..writeln('      display: flex;')
    ..writeln('      flex-wrap: wrap;')
    ..writeln('      gap: 16px;')
    ..writeln('    }')
    ..writeln('    .link-card {')
    ..writeln('      flex: 1 1 240px;')
    ..writeln('      background: rgba(38, 166, 154, 0.1);')
    ..writeln('      border: 1px solid rgba(38, 166, 154, 0.35);')
    ..writeln('      border-radius: 12px;')
    ..writeln('      padding: 20px;')
    ..writeln('      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);')
    ..writeln('      transition: transform 160ms ease, box-shadow 160ms ease;')
    ..writeln('    }')
    ..writeln('    .link-card:hover {')
    ..writeln('      transform: translateY(-4px);')
    ..writeln('      box-shadow: 0 16px 36px rgba(0, 0, 0, 0.32);')
    ..writeln('    }')
    ..writeln('    .link-card h3 {')
    ..writeln('      margin: 0 0 8px;')
    ..writeln('      font-size: 1.1rem;')
    ..writeln('      color: var(--brand-light);')
    ..writeln('    }')
    ..writeln('    .link-card a {')
    ..writeln('      color: var(--brand-teal);')
    ..writeln('      text-decoration: none;')
    ..writeln('      font-weight: 600;')
    ..writeln('    }')
    ..writeln('    .coverage {')
    ..writeln('      margin-top: 32px;')
    ..writeln('      background: rgba(31, 41, 51, 0.72);')
    ..writeln('      border-radius: 12px;')
    ..writeln('      padding: 24px;')
    ..writeln('      border: 1px solid rgba(38, 166, 154, 0.2);')
    ..writeln('    }')
    ..writeln('    .coverage h3 {')
    ..writeln('      margin: 0 0 12px;')
    ..writeln('      text-transform: uppercase;')
    ..writeln('      letter-spacing: 0.06em;')
    ..writeln('      color: rgba(255, 255, 255, 0.72);')
    ..writeln('      font-size: 0.9rem;')
    ..writeln('    }')
    ..writeln('    .coverage ul {')
    ..writeln('      margin: 0;')
    ..writeln('      padding-left: 20px;')
    ..writeln('    }')
    ..writeln('    .coverage li {')
    ..writeln('      margin-bottom: 4px;')
    ..writeln('      color: rgba(255, 255, 255, 0.78);')
    ..writeln('    }')
    ..writeln('    .insights {')
    ..writeln('      margin-top: 32px;')
    ..writeln('      display: grid;')
    ..writeln(
      '      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));',
    )
    ..writeln('      gap: 16px;')
    ..writeln('    }')
    ..writeln('    .insight-card {')
    ..writeln('      background: rgba(31, 41, 51, 0.78);')
    ..writeln('      border-radius: 12px;')
    ..writeln('      padding: 20px;')
    ..writeln('      border: 1px solid rgba(38, 166, 154, 0.25);')
    ..writeln('      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.28);')
    ..writeln('    }')
    ..writeln('    .insight-card h3 {')
    ..writeln('      margin: 0 0 8px;')
    ..writeln('      text-transform: uppercase;')
    ..writeln('      letter-spacing: 0.06em;')
    ..writeln('      font-size: 0.95rem;')
    ..writeln('      color: rgba(255, 255, 255, 0.76);')
    ..writeln('    }')
    ..writeln('    .insight-card ul {')
    ..writeln('      margin: 0;')
    ..writeln('      padding-left: 18px;')
    ..writeln('      color: rgba(255, 255, 255, 0.82);')
    ..writeln('    }')
    ..writeln('    .insight-card li {')
    ..writeln('      margin-bottom: 6px;')
    ..writeln('    }')
    ..writeln('    footer {')
    ..writeln('      margin-top: 48px;')
    ..writeln('      text-align: center;')
    ..writeln('      color: rgba(255, 255, 255, 0.52);')
    ..writeln('      font-size: 0.85rem;')
    ..writeln('    }')
    ..writeln('    @media (max-width: 640px) {')
    ..writeln('      header h1 { font-size: 2rem; }')
    ..writeln('      .metric-card p { font-size: 1.4rem; }')
    ..writeln('    }')
    ..writeln('  </style>')
    ..writeln('</head>')
    ..writeln('<body>')
    ..writeln('  <div class="container">')
    ..writeln('    <header>')
    ..writeln('      <h1>Poker Analyzer Beta Release</h1>')
    ..writeln(
      '      <p>Adaptive Poker Training System - Stage ${metrics.stage}</p>',
    )
    ..writeln('    </header>')
    ..writeln('    <section class="metrics">')
    ..writeln('      <article class="metric-card">')
    ..writeln('        <h2>Readiness Score</h2>')
    ..writeln('        <p>${metrics.readinessScore.toStringAsFixed(1)}%</p>')
    ..writeln('      </article>')
    ..writeln('      <article class="metric-card">')
    ..writeln('        <h2>Total Modules</h2>')
    ..writeln('        <p>${metrics.totalModules}</p>')
    ..writeln('      </article>')
    ..writeln('      <article class="metric-card">')
    ..writeln('        <h2>Avg Performance</h2>')
    ..writeln('        <p>${metrics.averagePerformanceLabel}</p>')
    ..writeln('      </article>')
    ..writeln('      <article class="metric-card">')
    ..writeln('        <h2>Test Coverage</h2>')
    ..writeln('        <p>${metrics.testCoverageLabel}</p>')
    ..writeln('      </article>')
    ..writeln('      <article class="metric-card">')
    ..writeln('        <h2>Build Size</h2>')
    ..writeln('        <p>${metrics.buildSizeLabel}</p>')
    ..writeln('      </article>')
    ..writeln('    </section>')
    ..writeln('    <section class="links">')
    ..writeln('      <article class="link-card">')
    ..writeln('        <h3>Download Beta Build</h3>')
    ..writeln(
      '        <p>Grab the latest ZIP package and start testing right away.</p>',
    )
    ..writeln('        <a href="${metrics.downloadLink}">Download package</a>')
    ..writeln('      </article>')
    ..writeln('      <article class="link-card">')
    ..writeln('        <h3>Documentation</h3>')
    ..writeln(
      '        <p>Read the stage history and new capabilities in this release.</p>',
    )
    ..writeln(
      '        <a href="${metrics.documentationLink}">Release notes</a>',
    )
    ..writeln('      </article>')
    ..writeln('      <article class="link-card">')
    ..writeln('        <h3>Feedback</h3>')
    ..writeln(
      '        <p>Share findings, hand histories, or improvement ideas with the team.</p>',
    )
    ..writeln('        <a href="${metrics.feedbackLink}">Send feedback</a>')
    ..writeln('      </article>')
    ..writeln('    </section>')
    ..writeln('    <section class="coverage">')
    ..writeln('      <h3>Content Coverage Snapshot</h3>')
    ..writeln('      <ul>');
  for (final entry in metrics.coverageBreakdown.entries) {
    buffer.writeln(
      '        <li>${entry.key} - ${entry.value.toStringAsFixed(1)}%</li>',
    );
  }
  buffer
    ..writeln('      </ul>')
    ..writeln('    </section>')
    ..writeln(
      metricsV2 == null ? '' : _renderMetricsV2Section(metricsV2).trim(),
    )
    ..writeln('    <section class="insights">')
    ..writeln('      <article class="insight-card">')
    ..writeln('        <h3>AI Advisor Insights</h3>')
    ..writeln('        <ul>');
  for (final line in metrics.advisorHighlights) {
    buffer.writeln('          <li>$line</li>');
  }
  buffer
    ..writeln('        </ul>')
    ..writeln('      </article>')
    ..writeln('      <article class="insight-card">')
    ..writeln('        <h3>Adaptive Metrics</h3>')
    ..writeln('        <ul>');
  for (final line in metrics.adaptiveHighlights) {
    buffer.writeln('          <li>$line</li>');
  }
  buffer
    ..writeln('        </ul>')
    ..writeln('      </article>')
    ..writeln('      <article class="insight-card">')
    ..writeln('        <h3>Simulation Summary</h3>')
    ..writeln('        <ul>');
  for (final line in metrics.simulationHighlights) {
    buffer.writeln('          <li>$line</li>');
  }
  buffer
    ..writeln('        </ul>')
    ..writeln('      </article>')
    ..writeln('    </section>')
    ..writeln('    <footer>')
    ..writeln(
      '      Build ${metrics.commit} | ${metrics.buildDateIso} | ${metrics.packsCount} packs exported',
    )
    ..writeln('    </footer>')
    ..writeln('  </div>')
    ..writeln('</body>')
    ..writeln('</html>');

  await File(metrics.indexPath).writeAsString(buffer.toString());
}

String _renderMetricsV2Section(Map<String, Object?> v2) {
  final readiness = (v2['readinessPercent'] as num?)?.toDouble() ?? 0.0;
  final advisorTrend =
      (v2['advisorTrend'] as List?)
          ?.whereType<num>()
          .map((e) => e.toDouble())
          .toList() ??
      const <double>[];
  final latency =
      (v2['feedbackLatencyHistogram'] as Map?)?.map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
      ) ??
      const <String, int>{};
  final rounds = (v2['simulationRoundCount'] as num?)?.toInt() ?? 0;
  final lastSyncUtc = v2['lastSyncUtc']?.toString() ?? 'unknown';
  final buildVersion = v2['buildVersion']?.toString() ?? 'n/a';
  final topIssues =
      (v2['topUserIssues'] as List?)?.whereType<String>().toList() ??
      const <String>[];

  final svgReadiness = _svgBar(readiness.clamp(0, 100), 420, 20);
  final svgAdvisor = _svgLineChart(advisorTrend, 420, 120);
  final svgLatency = _svgHistogram(latency, 420, 120);
  final svgRounds = _svgKpiBar(rounds, 420, 60);

  final issuesHtml = topIssues.isEmpty
      ? '<li>No issues reported</li>'
      : topIssues.take(5).map((e) => '<li>${_escapeHtml(e)}</li>').join();

  return '''
    <section class="coverage" id="metrics-v2">
      <h3>Beta Metrics Dashboard V2</h3>
      <div class="insights">
        <article class="insight-card">
          <h3>Readiness</h3>
          <div>$svgReadiness</div>
          <p>${readiness.toStringAsFixed(1)}%</p>
        </article>
        <article class="insight-card">
          <h3>AI Advisor Trend</h3>
          <div>$svgAdvisor</div>
        </article>
        <article class="insight-card">
          <h3>Feedback Latency Histogram</h3>
          <div>$svgLatency</div>
        </article>
        <article class="insight-card">
          <h3>Simulation Rounds</h3>
          <div>$svgRounds</div>
          <p>Total rounds: $rounds</p>
        </article>
      </div>
      <div class="insights">
        <article class="insight-card">
          <h3>Last Sync UTC</h3>
          <p>$lastSyncUtc</p>
        </article>
        <article class="insight-card">
          <h3>Build Version</h3>
          <p>$buildVersion</p>
        </article>
        <article class="insight-card">
          <h3>Top User Issues</h3>
          <ul>$issuesHtml</ul>
        </article>
      </div>
    </section>
  ''';
}

String _escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

Future<void> _writeMetricsV2Json(Map<String, Object?> v2) async {
  final file = File('release/landing/metrics_v2.json');
  file.parent.createSync(recursive: true);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(v2));
}

Map<String, Object?> _buildMetricsV2({
  required Map<String, dynamic> readiness,
  required Map<String, dynamic> version,
  Map<String, dynamic>? advisor,
  Map<String, dynamic>? feedback,
  Map<String, dynamic>? simulation,
}) {
  final readinessPercent =
      (readiness['readiness_score'] as num?)?.toDouble() ?? 0.0;
  final advisorTrend = _selectAdvisorTrend(advisor);
  final latencyHist = _computeLatencyHistogram(feedback);
  final simRounds = (simulation?['round_count'] as num?)?.toInt() ?? 0;
  final lastSync = _computeLastSyncUtc(
    version: version,
    advisor: advisor,
    feedback: feedback,
  );
  final buildVersion =
      version['version_label']?.toString() ??
      (_readPubspecVersionSync() ?? 'unknown');
  final topIssues = <String>[];
  final agg = (feedback?['aggregates'] as Map?)?.cast<String, dynamic>();
  final issues = agg?['top_issues'];
  if (issues is List) {
    topIssues.addAll(issues.whereType<String>());
  }
  return {
    'readinessPercent': double.parse(readinessPercent.toStringAsFixed(1)),
    'advisorTrend': advisorTrend,
    'feedbackLatencyHistogram': latencyHist,
    'simulationRoundCount': simRounds,
    'lastSyncUtc': lastSync,
    'buildVersion': buildVersion,
    'topUserIssues': topIssues,
  };
}

String _computeLastSyncUtc({
  required Map<String, dynamic> version,
  Map<String, dynamic>? advisor,
  Map<String, dynamic>? feedback,
}) {
  final cand = <DateTime>[];
  final vts = version['timestamp_utc']?.toString();
  if (vts != null) {
    final dt = DateTime.tryParse(vts);
    if (dt != null) cand.add(dt);
  }
  final ats = advisor?['generated_at']?.toString();
  if (ats != null) {
    final dt = DateTime.tryParse(ats);
    if (dt != null) cand.add(dt);
  }
  final fts = feedback?['generated_at']?.toString();
  if (fts != null) {
    final dt = DateTime.tryParse(fts);
    if (dt != null) cand.add(dt);
  }
  if (cand.isEmpty) return DateTime.now().toUtc().toIso8601String();
  cand.sort();
  return cand.last.toUtc().toIso8601String();
}

List<double> _selectAdvisorTrend(Map<String, dynamic>? advisor) {
  if (advisor == null) return const <double>[];
  final metrics = advisor['metrics'];
  if (metrics is! Map) return const <double>[];
  List<double>? _seriesFor(String key) {
    final bucket = metrics[key];
    if (bucket is Map) {
      final series = bucket['seven_day'];
      if (series is List) {
        final vals = series.whereType<num>().map((e) => e.toDouble()).toList();
        return vals;
      }
    }
    return null;
  }

  return _seriesFor('correct_ratio') ??
      _seriesFor('confidence') ??
      _seriesFor('ev_diff') ??
      const <double>[];
}

Map<String, int> _computeLatencyHistogram(Map<String, dynamic>? feedback) {
  // Try to build histogram from individual records' latency_ms.
  final bins = <String, int>{};
  void inc(String k) => bins.update(k, (v) => v + 1, ifAbsent: () => 1);
  final records = feedback?['records'];
  if (records is List && records.isNotEmpty) {
    for (final r in records) {
      if (r is Map) {
        final ms = (r['latency_ms'] as num?)?.toDouble();
        if (ms != null) {
          final s = ms / 1000.0;
          final bucket = (s < 0.5)
              ? '<0.5s'
              : (s < 1.0)
              ? '0.5-1s'
              : (s < 2.0)
              ? '1-2s'
              : (s < 5.0)
              ? '2-5s'
              : '>=5s';
          inc(bucket);
        }
      }
    }
    if (bins.isNotEmpty) return _orderBuckets(bins);
  }
  // Fallback: represent averages as a pseudo-histogram with two bars.
  final avgUx =
      ((feedback?['aggregates'] as Map?)?['avg_ux_latency_ms'] as num?)
          ?.toDouble() ??
      0.0;
  final avgSim =
      ((feedback?['aggregates'] as Map?)?['avg_sim_latency_ms'] as num?)
          ?.toDouble() ??
      0.0;
  return {'UX(ms)': avgUx.round(), 'SIM(ms)': avgSim.round()};
}

Map<String, int> _orderBuckets(Map<String, int> bins) {
  const order = ['<0.5s', '0.5-1s', '1-2s', '2-5s', '>=5s'];
  final out = <String, int>{};
  for (final k in order) {
    if (bins.containsKey(k)) out[k] = bins[k]!;
  }
  // include any unexpected keys at end
  for (final e in bins.entries) {
    if (!out.containsKey(e.key)) out[e.key] = e.value;
  }
  return out;
}

String? _readPubspecVersionSync() {
  try {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) return null;
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('version:')) {
        final v = trimmed.substring('version:'.length).trim();
        return v;
      }
    }
  } catch (_) {}
  return null;
}

String _svgBar(double percent, int width, int height) {
  final p = percent.clamp(0, 100);
  final w = (width - 2);
  final fill = (w * p / 100).round();
  return '<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">'
      '<rect x="1" y="1" width="$w" height="${height - 2}" fill="none" stroke="#26a69a" stroke-width="1" />'
      '<rect x="1" y="1" width="$fill" height="${height - 2}" fill="#26a69a" />'
      '</svg>';
}

String _svgLineChart(List<double> values, int width, int height) {
  if (values.isEmpty) {
    return '<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">'
        '<text x="8" y="${(height / 2).round()}" fill="#cccccc" font-size="12">No data</text>'
        '</svg>';
  }
  final minV = values.reduce((a, b) => a < b ? a : b);
  final maxV = values.reduce((a, b) => a > b ? a : b);
  final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
  final n = values.length;
  final innerW = width - 2;
  final innerH = height - 2;
  final pts = <String>[];
  for (var i = 0; i < n; i++) {
    final x = 1 + (innerW * (i / (n - 1)));
    final yn = (values[i] - minV) / span;
    final y = 1 + (innerH - (yn * innerH));
    pts.add('${x.toStringAsFixed(1)},${y.toStringAsFixed(1)}');
  }
  return '<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">'
      '<polyline fill="none" stroke="#26a69a" stroke-width="2" points="${pts.join(' ')}" />'
      '</svg>';
}

String _svgHistogram(Map<String, int> bins, int width, int height) {
  if (bins.isEmpty) {
    return '<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">'
        '<text x="8" y="${(height / 2).round()}" fill="#cccccc" font-size="12">No data</text>'
        '</svg>';
  }
  final keys = bins.keys.toList();
  final values = bins.values.toList();
  final maxVal = values.fold<int>(0, (a, b) => a > b ? a : b);
  final innerW = width - 2;
  final innerH = height - 2;
  final barW = (innerW / (keys.length * 1.5)).floor().clamp(4, 60);
  final gap = (innerW - (barW * keys.length)) ~/ (keys.length + 1);
  final elems = StringBuffer();
  var x = 1 + gap;
  for (var i = 0; i < keys.length; i++) {
    final v = values[i];
    final h = maxVal == 0 ? 0 : ((v / maxVal) * innerH).round();
    final y = 1 + (innerH - h);
    elems
      ..write('<rect x="$x" y="$y" width="$barW" height="$h" fill="#26a69a" />')
      ..write(
        '<text x="$x" y="${height - 4}" fill="#cccccc" font-size="10">${_escapeHtml(keys[i])}</text>',
      );
    x += barW + gap;
  }
  return '<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">'
      '${elems.toString()}'
      '</svg>';
}

String _svgKpiBar(int value, int width, int height) {
  final label = value.toString();
  final pct = (value <= 0) ? 0.0 : (min(value / 1000.0, 1.0) * 100);
  final bar = _svgBar(pct, width, 14);
  return '<div style="font-size:18px;color:#26a69a;">$label</div>'
      '$bar';
}

Future<void> _writeMetadata(LandingMetrics metrics) async {
  final file = File(metrics.metadataPath);
  file.parent.createSync(recursive: true);
  final payload = <String, Object?>{
    'title': 'Poker Analyzer Beta Release',
    'tagline': 'Adaptive Poker Training System',
    'stage': metrics.stage,
    'readiness_score': metrics.readinessScore,
    'modules': metrics.totalModules,
    'average_performance': metrics.averagePerformance,
    'test_coverage': metrics.testCoverage,
    'build_date': metrics.buildDateIso,
    'commit': metrics.commit,
    'packs_count': metrics.packsCount,
    'download': metrics.downloadLink,
    'documentation': metrics.documentationLink,
    'feedback': metrics.feedbackLink,
    'coverage_breakdown': metrics.coverageBreakdown,
    'build_size_bytes': metrics.buildSizeBytes,
    if (metrics.advisorSummary.isNotEmpty) 'ai_advisor': metrics.advisorSummary,
    if (metrics.simulationSummary.isNotEmpty)
      'simulation_summary': metrics.simulationSummary,
    if (metrics.adaptiveSummary.isNotEmpty)
      'adaptive_summary': metrics.adaptiveSummary,
    if (metrics.uiPerformance.isNotEmpty)
      'ui_performance': metrics.uiPerformance,
    'advisor_highlights': metrics.advisorHighlights,
    'adaptive_highlights': metrics.adaptiveHighlights,
    'simulation_highlights': metrics.simulationHighlights,
  };
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
}

void _printAscii(LandingMetrics metrics) {
  stdout.writeln('Landing Page:');
  stdout.writeln(
    '  readiness ${metrics.readinessScore.toStringAsFixed(1)}% | modules ${metrics.totalModules}',
  );
  stdout.writeln(
    '  performance ${metrics.averagePerformanceLabel} | coverage ${metrics.testCoverageLabel}',
  );
  stdout.writeln('  html : ${metrics.indexPath}');
  stdout.writeln('  meta : ${metrics.metadataPath}');
}

class LandingMetrics {
  LandingMetrics({
    required this.readinessScore,
    required this.totalModules,
    required this.averagePerformance,
    required this.testCoverage,
    required this.stage,
    required this.buildDateIso,
    required this.commit,
    required this.packsCount,
    required this.coverageBreakdown,
    required this.downloadLink,
    required this.documentationLink,
    required this.feedbackLink,
    required this.directory,
    required this.indexPath,
    required this.metadataPath,
    required this.advisorSummary,
    required this.simulationSummary,
    required this.adaptiveSummary,
    required this.uiPerformance,
    required this.buildSizeBytes,
  });

  static LandingMetrics fromData(
    Map<String, dynamic> readiness,
    Map<String, dynamic> version, {
    Map<String, dynamic>? advisor,
    Map<String, dynamic>? simulation,
    Map<String, dynamic>? uiPerformance,
    int? buildSizeBytes,
  }) {
    final readinessScore =
        (readiness['readiness_score'] as num?)?.toDouble() ?? 0.0;
    final contentFlow =
        (readiness['content_flow'] as Map<String, dynamic>?) ?? const {};
    final modules = (contentFlow['modules'] as num?)?.toInt() ?? 0;
    final coverageRaw =
        (contentFlow['coverage'] as Map<String, dynamic>?) ?? const {};
    final coverage = <String, double>{};
    double totalCoverage = 0;
    coverageRaw.forEach((key, value) {
      final val = (value as num?)?.toDouble() ?? 0;
      coverage[key] = val;
      totalCoverage += val;
    });
    if (totalCoverage > 0) {
      coverage.updateAll((key, value) => (value / totalCoverage) * 100);
    }

    final adaptive =
        (readiness['adaptive'] as Map<String, dynamic>?) ?? const {};
    final base = (adaptive['base'] as Map<String, dynamic>?) ?? const {};
    final perf =
        (base['performanceSummary'] as Map<String, dynamic>?) ?? const {};
    final errorRate = (perf['errorRate'] as num?)?.toDouble();
    final avgPerformance = errorRate != null
        ? max(0.0, 100.0 - errorRate * 100.0)
        : null;

    final testsPass = readiness['test_status'] == true;
    final testCoverage = testsPass ? 100.0 : 0.0;

    final buildDate = version['build_date']?.toString() ?? 'unknown';
    final commit = version['commit']?.toString() ?? 'unknown';
    final stage =
        (version['stage'] as num?)?.toInt() ??
        (readiness['stage'] as num?)?.toInt() ??
        0;
    final packs = (version['packs_count'] as num?)?.toInt() ?? 0;
    final advisorSummary = advisor != null
        ? Map<String, dynamic>.from(advisor)
        : <String, dynamic>{};
    final simulationSummary = simulation != null
        ? Map<String, dynamic>.from(simulation)
        : <String, dynamic>{};
    final uiPerfSummary = uiPerformance != null
        ? Map<String, dynamic>.from(uiPerformance)
        : <String, dynamic>{};

    final adaptiveSection =
        (readiness['adaptive'] as Map<String, dynamic>?) ?? const {};
    final baseAdaptive =
        (adaptiveSection['base'] as Map<String, dynamic>?) ?? const {};
    final plannerWeights =
        (baseAdaptive['plannerWeights'] as Map<String, dynamic>?) ?? const {};
    final performanceSummary =
        (baseAdaptive['performanceSummary'] as Map<String, dynamic>?) ??
        const {};
    final adaptiveSummary = <String, dynamic>{
      if (adaptiveSection['difficultyMultiplier'] is num)
        'difficulty_multiplier':
            (adaptiveSection['difficultyMultiplier'] as num).toDouble(),
      if (adaptiveSection['topicRepetitionRate'] is num)
        'topic_repetition_rate': (adaptiveSection['topicRepetitionRate'] as num)
            .toDouble(),
      if (adaptiveSection['meta_feedback_score'] is num)
        'meta_feedback_score': (adaptiveSection['meta_feedback_score'] as num)
            .toDouble(),
      if (performanceSummary['errorRate'] is num)
        'error_rate': (performanceSummary['errorRate'] as num).toDouble(),
      if (plannerWeights['retry'] is num)
        'planner_retry': (plannerWeights['retry'] as num).toDouble(),
      if (plannerWeights['checkpoint'] is num)
        'planner_checkpoint': (plannerWeights['checkpoint'] as num).toDouble(),
    };

    return LandingMetrics(
      readinessScore: readinessScore,
      totalModules: modules,
      averagePerformance: avgPerformance,
      testCoverage: testCoverage,
      stage: stage,
      buildDateIso: buildDate,
      commit: commit,
      packsCount: packs,
      coverageBreakdown: coverage.isEmpty
          ? const {'n/a': 100.0}
          : Map<String, double>.unmodifiable(coverage),
      downloadLink: '../poker_analyzer_beta.zip',
      documentationLink: '../../docs/RELEASE_NOTES.md',
      feedbackLink: 'mailto:poker-beta@pokeranalyzer.dev',
      directory: 'release/landing',
      indexPath: 'release/landing/index.html',
      metadataPath: 'release/landing/metadata.json',
      advisorSummary: advisorSummary,
      simulationSummary: simulationSummary,
      adaptiveSummary: adaptiveSummary,
      uiPerformance: uiPerfSummary,
      buildSizeBytes: buildSizeBytes ?? 0,
    );
  }

  final double readinessScore;
  final int totalModules;
  final double? averagePerformance;
  final double? testCoverage;
  final int stage;
  final String buildDateIso;
  final String commit;
  final int packsCount;
  final Map<String, double> coverageBreakdown;
  final String downloadLink;
  final String documentationLink;
  final String feedbackLink;
  final String directory;
  final String indexPath;
  final String metadataPath;
  final Map<String, dynamic> advisorSummary;
  final Map<String, dynamic> simulationSummary;
  final Map<String, dynamic> adaptiveSummary;
  final Map<String, dynamic> uiPerformance;
  final int buildSizeBytes;

  double get safeAveragePerformance => averagePerformance ?? 0.0;
  double get safeTestCoverage => testCoverage ?? 0.0;

  String get averagePerformanceLabel => averagePerformance != null
      ? '${averagePerformance!.toStringAsFixed(1)}%'
      : 'N/A';

  String get testCoverageLabel =>
      testCoverage != null ? '${testCoverage!.toStringAsFixed(1)}%' : 'N/A';

  String get buildSizeLabel {
    if (buildSizeBytes <= 0) return 'N/A';
    final mb = buildSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }

  List<String> get advisorHighlights {
    if (advisorSummary.isEmpty) {
      return const ['Advisor metrics pending refresh.'];
    }
    final status = advisorSummary['status']?.toString() ?? 'unknown';
    final passFlag = advisorSummary['pass'] == true ? 'pass' : 'review';
    final metrics = advisorSummary['metrics'];
    final weaknesses = advisorSummary['weakness_tags'];
    final lines = <String>['Status: $status ($passFlag)'];
    if (metrics is Map) {
      void addMetric(String key, String label, {bool percent = false}) {
        final bucket = metrics[key];
        if (bucket is Map) {
          final current = bucket['current'];
          final delta = bucket['delta'];
          final currentStr = _formatNumber(current, percent: percent);
          final deltaStr = _formatNumber(delta, percent: percent, signed: true);
          lines.add('$label: $currentStr (Δ $deltaStr)');
        }
      }

      addMetric('ev_diff', 'EV diff', percent: false);
      addMetric('confidence', 'Confidence', percent: false);
      addMetric('correct_ratio', 'Correct', percent: true);
    }
    if (weaknesses is List && weaknesses.isNotEmpty) {
      final top = weaknesses
          .whereType<Map>()
          .map((e) => e['tag']?.toString() ?? '')
          .where((tag) => tag.isNotEmpty)
          .take(3)
          .toList();
      if (top.isNotEmpty) {
        lines.add('Focus tags: ${top.join(', ')}');
      }
    }
    return lines;
  }

  List<String> get adaptiveHighlights {
    if (adaptiveSummary.isEmpty) {
      return const ['Adaptive planner metrics not available.'];
    }
    final lines = <String>[];
    void add(String label, String key, {bool percent = false}) {
      final value = adaptiveSummary[key];
      if (value is num) {
        lines.add('$label: ${_formatNumber(value, percent: percent)}');
      }
    }

    add('Difficulty multiplier', 'difficulty_multiplier');
    add('Topic repetition', 'topic_repetition_rate');
    add('Meta feedback', 'meta_feedback_score', percent: true);
    add('Error rate', 'error_rate', percent: true);
    return lines.isEmpty
        ? const ['Adaptive planner metrics not available.']
        : lines;
  }

  List<String> get simulationHighlights {
    if (simulationSummary.isEmpty) {
      return const ['Simulation metrics not captured this build.'];
    }
    final lines = <String>[];
    void addValue(String label, Object? value, {bool percent = false}) {
      if (value is num) {
        lines.add('$label: ${_formatNumber(value, percent: percent)}');
      }
    }

    addValue('Rounds', simulationSummary['round_count']);
    addValue('Avg round ms', simulationSummary['avg_simulation_round_ms']);
    addValue(
      'AI aggression',
      simulationSummary['ai_aggression_factor'],
      percent: true,
    );
    addValue(
      'AI accuracy',
      simulationSummary['ai_decision_accuracy'],
      percent: true,
    );

    return lines.isEmpty
        ? const ['Simulation metrics not captured this build.']
        : lines;
  }

  static String _formatNumber(
    Object? value, {
    bool percent = false,
    bool signed = false,
  }) {
    if (value is num) {
      final scaled = percent ? value * 100.0 : value.toDouble();
      final formatted = scaled.toStringAsFixed(percent ? 1 : 2);
      if (signed && scaled > 0) {
        return '+$formatted${percent ? '%' : ''}';
      }
      if (signed && scaled == 0) {
        return '$formatted${percent ? '%' : ''}';
      }
      return '$formatted${percent ? '%' : ''}';
    }
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return 'n/a';
  }
}

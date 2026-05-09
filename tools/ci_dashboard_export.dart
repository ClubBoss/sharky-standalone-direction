import 'dart:convert';
import 'dart:io';

/// CI Dashboard Export - Generates HTML quality metrics dashboard
/// Reads health_dashboard.json and creates /docs/index.html
Future<void> main(List<String> args) async {
  final summaryOnly = args.contains('--summary');
  final updateHistory = args.contains('--update-history');
  final resetHistory = args.contains('--reset-history');

  // Read health dashboard JSON
  final jsonFile = File('health_dashboard.json');
  if (!await jsonFile.exists()) {
    stderr.writeln('Error: health_dashboard.json not found');
    stderr.writeln('Run: dart run tools/health_dashboard.dart --ci');
    exitCode = 1;
    return;
  }

  final jsonContent = await jsonFile.readAsString();
  final data = jsonDecode(jsonContent) as Map<String, dynamic>;

  // Get git commit SHA
  String commitSha = 'unknown';
  try {
    final result = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
    if (result.exitCode == 0) {
      commitSha = (result.stdout as String).trim();
    }
  } catch (e) {
    // Git not available, use unknown
  }

  if (summaryOnly) {
    _printSummary(data, commitSha);
    return;
  }

  // Reset or update history if requested
  final docsDir = Directory('docs');
  if (!await docsDir.exists()) {
    await docsDir.create(recursive: true);
  }
  final historyPath = 'docs/history.json';
  if (resetHistory) {
    await File(historyPath).writeAsString('[]');
  }
  List<Map<String, dynamic>> history = await _readHistory(historyPath);
  if (updateHistory) {
    history = await _appendHistory(historyPath, data);
  }

  // Read UI metrics (for drift trend)
  final Map<String, dynamic> uiMetrics = await _readUiMetricsJson();

  // Generate HTML dashboard
  final html = _generateHtml(
    data,
    commitSha,
    history,
    Map<String, dynamic>.from(uiMetrics),
  );

  // Ensure docs directory exists (already ensured above)

  // Write HTML file
  final htmlFile = File('docs/index.html');
  await htmlFile.writeAsString(html);

  stdout.writeln('✅ CI Dashboard exported to docs/index.html');
  stdout.writeln('Commit: $commitSha');
  stdout.writeln('Timestamp: ${data['timestamp']}');
}

void _printSummary(Map<String, dynamic> data, String commitSha) {
  final baseline = data['baseline_status'] as Map? ?? {};

  stdout.writeln('CI Quality Dashboard Summary');
  stdout.writeln('============================');
  stdout.writeln('Commit: $commitSha');
  stdout.writeln('Timestamp: ${data['timestamp']}');
  stdout.writeln('');
  stdout.writeln('Gates:');
  stdout.writeln(
    '  Analyzer: ${baseline['analyzer'] == true ? 'PASS' : 'FAIL'}',
  );
  stdout.writeln('  Tests: ${baseline['tests'] == true ? 'PASS' : 'FAIL'}');
  stdout.writeln(
    '  Export: ${baseline['export_validation'] == true ? 'PASS' : 'FAIL'}',
  );
  stdout.writeln(
    '  Content: ${baseline['content_validation'] == true ? 'PASS' : 'FAIL'}',
  );
  stdout.writeln('');

  final passCount = [
    baseline['analyzer'],
    baseline['tests'],
    baseline['export_validation'],
    baseline['content_validation'],
  ].where((x) => x == true).length;

  stdout.writeln('Overall: $passCount/4 gates passing');
}

String _generateHtml(
  Map<String, dynamic> data,
  String commitSha,
  List<Map<String, dynamic>> history,
  Map uiMetrics,
) {
  final baseline = data['baseline_status'] as Map? ?? {};
  final analyze = data['analyze'] as Map? ?? {};
  final tests = data['tests'] as Map? ?? {};
  final coverage = data['coverage'] as Map? ?? {};
  final content = data['content_validation'] as Map? ?? {};
  final export = data['export_validation'] as Map? ?? {};
  final sdks = data['sdks'] as Map? ?? {};
  final Map<String, dynamic> revenue = (data['revenue_metrics'] is Map)
      ? Map<String, dynamic>.from(data['revenue_metrics'] as Map)
      : <String, dynamic>{};
  final timestamp = data['timestamp'] ?? 'unknown';
  final avgFps = _extractAvgFps(data);
  final quality = data['quality'] as Map? ?? {};
  final qScore = (quality['score'] is num)
      ? (quality['score'] as num).toDouble()
      : null;
  final qGrade = (quality['grade'] as String?) ?? '';

  // Compute recent deltas vs previous in history (if present)
  final prev = history.length >= 2 ? history[history.length - 2] : null;
  final covNow = (coverage['percent'] is num)
      ? (coverage['percent'] as num).toDouble()
      : null;
  final covPrev = prev != null && prev['coverage'] is num
      ? (prev['coverage'] as num).toDouble()
      : null;
  final covDeltaStr = (covNow != null && covPrev != null)
      ? _formatSigned((covNow - covPrev), suffix: '%')
      : '';
  final fpsPrev = prev != null && prev['fps'] is num
      ? (prev['fps'] as num).toDouble()
      : null;
  final fpsDeltaStr = (avgFps != null && fpsPrev != null)
      ? _formatSigned((avgFps - fpsPrev))
      : '';
  final qPrev = prev != null && prev['quality'] is num
      ? (prev['quality'] as num).toDouble()
      : null;
  final qDeltaStr = (qScore != null && qPrev != null)
      ? _formatSigned(qScore - qPrev)
      : '';

  // Calculate overall status
  final passCount = [
    baseline['analyzer'],
    baseline['tests'],
    baseline['export_validation'],
    baseline['content_validation'],
  ].where((x) => x == true).length;
  final overallPass = passCount == 4;

  return '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Poker Analyzer - CI Quality Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .header h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
        }
        .header .meta {
            color: #666;
            font-size: 14px;
        }
        .grade-badge {
            display: inline-block;
            background: #111827;
            color: #f9fafb;
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 700;
            margin-top: 8px;
        }
        .delta-chip {
            display: inline-block;
            background: #eef2ff;
            color: #4f46e5;
            padding: 4px 8px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            margin-left: 8px;
        }
        .overall-status {
            background: ${overallPass ? '#10b981' : '#ef4444'};
            color: white;
            padding: 20px 30px;
            border-radius: 12px;
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .gates-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .gate-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            border-left: 5px solid #ccc;
        }
        .gate-card.pass {
            border-left-color: #10b981;
        }
        .gate-card.fail {
            border-left-color: #ef4444;
        }
        .gate-card h2 {
            font-size: 18px;
            margin-bottom: 15px;
            color: #333;
        }
        .gate-card .status {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .gate-card.pass .status {
            color: #10b981;
        }
        .gate-card.fail .status {
            color: #ef4444;
        }
        .gate-card .details {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }
        .gate-card .metric {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
        }
        .gate-card .metric-label {
            color: #888;
        }
        .gate-card .metric-value {
            font-weight: 600;
            color: #333;
        }
        .info-section {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .info-section h3 {
            font-size: 16px;
            color: #667eea;
            margin-bottom: 15px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .info-item {
            padding: 10px;
            background: #f9fafb;
            border-radius: 8px;
        }
        .info-item .label {
            font-size: 12px;
            color: #888;
            margin-bottom: 5px;
        }
        .info-item .value {
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }
        .docs-section {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-top: 30px;
        }
        .docs-section h3 {
            font-size: 16px;
            color: #4f46e5;
            margin-bottom: 12px;
        }
        .docs-links {
            list-style: none;
            padding-left: 0;
        }
        .docs-links li {
            margin-bottom: 8px;
        }
        .docs-links a {
            color: #1d4ed8;
            text-decoration: none;
            font-weight: 600;
        }
        .docs-links a:hover {
            text-decoration: underline;
        }
        footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            font-size: 14px;
            opacity: 0.9;
        }
                .trend-section {
                    margin: 30px 0;
                }
                .trend-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                    gap: 20px;
                }
                .trend-card {
                    background: white;
                    padding: 20px;
                    border-radius: 12px;
                    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                }
                .trend-card h3 {
                    font-size: 16px;
                    color: #333;
                    margin-bottom: 10px;
                }
                .delta {
                    color: #666;
                    font-size: 13px;
                    margin-bottom: 10px;
                }
                .chart caption {
                    font-size: 12px;
                    color: #888;
                    display: block;
                    margin-top: 6px;
                    text-align: center;
                }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🃏 Poker Analyzer - CI Quality Dashboard</h1>
            <div class="meta">
                <strong>Commit:</strong> $commitSha &nbsp;|&nbsp;
                <strong>Updated:</strong> ${_formatTimestamp(timestamp)} &nbsp;|&nbsp;
                <strong>SDKs:</strong> Dart ${sdks['dart']} / Flutter ${sdks['flutter']}
            </div>
            ${qScore != null && qGrade.isNotEmpty ? '<div class="grade-badge">Grade ' + qGrade + ' • ' + qScore.toStringAsFixed(1) + '/100' + (qDeltaStr.isNotEmpty ? '<span class="delta-chip">Δ ' + qDeltaStr + '</span>' : '') + '</div>' : ''}
        </div>

        <div class="overall-status">
            ${overallPass ? '✅ CI Gate PASS ($passCount/4)' : '❌ CI Gate FAIL ($passCount/4)'}
        </div>

                <div class="gates-grid">
            ${_gateCard('Analyzer', baseline['analyzer'] == true, {'Errors': '${analyze['errors'] ?? 0}', 'Warnings': '${analyze['warnings'] ?? 0}'})}
            
            ${_gateCard('Tests', baseline['tests'] == true, {'Total': '${tests['total'] ?? 0}', 'Passed': '${tests['passed'] ?? 0}', 'Failed': '${tests['failed'] ?? 0}'})}
            
            ${_gateCard('Export Validation', baseline['export_validation'] == true, {'Files': '${export['count'] ?? 0}', 'Total Size': '${export['totalBytes'] ?? 0} bytes', 'Min Size': '${export['minBytes'] ?? 0} bytes'})}
            
            ${_gateCard('Content Validation', baseline['content_validation'] == true, {'Valid Files': '${content['valid'] ?? 0}/${content['total'] ?? 0}', 'Issues': '${(content['errors'] as List?)?.length ?? 0}'})}
        </div>

    ${_trendSection(history, covDeltaStr, fpsDeltaStr, Map<String, dynamic>.from(uiMetrics))}

    ${_revenueSection(revenue, history)}

        <div class="info-section">
            <h3>Additional Metrics</h3>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Coverage</div>
                    <div class="value">${coverage['percent'] ?? 0}%</div>
                </div>
                <div class="info-item">
                    <div class="label">Lines Tested</div>
                    <div class="value">${coverage['linesHit'] ?? 0}/${coverage['linesFound'] ?? 0}</div>
                </div>
                <div class="info-item">
                    <div class="label">Build Status</div>
                    <div class="value">${baseline['tests'] == true && baseline['analyzer'] == true ? 'Passing' : 'Failing'}</div>
                </div>
                <div class="info-item">
                    <div class="label">Quality Score</div>
                    <div class="value">${qScore?.toStringAsFixed(1) ?? '-'}${qGrade.isNotEmpty ? ' (' + qGrade + ')' : ''}</div>
                </div>
            </div>
        </div>

        <div class="docs-section">
            <h3>Docs → Roadmap</h3>
            <ul class="docs-links">
                <li><a href="ROADMAP_v2.3.md">Project Roadmap v2.3</a></li>
            </ul>
        </div>

        <footer>
            Generated by Poker Analyzer CI Pipeline<br>
            Auto-updated on every commit to main branch<br>
            <a href="ROADMAP_v2.3.md">Project Roadmap v2.3</a>
        </footer>
    </div>
</body>
</html>''';
}

String _gateCard(String title, bool pass, Map<String, String> metrics) {
  final statusClass = pass ? 'pass' : 'fail';
  final statusText = pass ? 'PASS' : 'FAIL';
  final metricsHtml = metrics.entries
      .map(
        (e) =>
            '''
                <div class="metric">
                    <span class="metric-label">${e.key}:</span>
                    <span class="metric-value">${e.value}</span>
                </div>''',
      )
      .join('\n');

  return '''
            <div class="gate-card $statusClass">
                <h2>$title</h2>
                <div class="status">$statusText</div>
                <div class="details">
$metricsHtml
                </div>
            </div>''';
}

// ----- History & Trends -----
Future<List<Map<String, dynamic>>> _readHistory(String path) async {
  final f = File(path);
  if (!await f.exists()) return <Map<String, dynamic>>[];
  try {
    final content = await f.readAsString();
    final list = jsonDecode(content);
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList()
          .cast<Map<String, dynamic>>();
    }
  } catch (_) {}
  return <Map<String, dynamic>>[];
}

Future<List<Map<String, dynamic>>> _appendHistory(
  String path,
  Map<String, dynamic> data,
) async {
  final history = await _readHistory(path);
  final cov = (data['coverage'] is Map && (data['coverage']['percent'] is num))
      ? (data['coverage']['percent'] as num).toDouble()
      : null;
  final fps = _extractAvgFps(data);
  final tests = (data['tests'] is Map) ? data['tests'] as Map : const {};
  final q = (data['quality'] is Map && (data['quality']['score'] is num))
      ? (data['quality']['score'] as num).toDouble()
      : null;
  final rev = (data['revenue_metrics'] is Map)
      ? data['revenue_metrics'] as Map
      : const {};
  final arpu = (rev['arpu'] is num) ? (rev['arpu'] as num).toDouble() : null;
  final conv = (rev['conversionRate'] is num)
      ? (rev['conversionRate'] as num).toDouble()
      : null;
  final entry = <String, dynamic>{
    'timestamp': data['timestamp'] ?? DateTime.now().toUtc().toIso8601String(),
    'coverage': cov,
    'fps': fps,
    'quality': q,
    'arpu': arpu,
    'conversion': conv,
    'tests_passed': tests['passed'] ?? 0,
    'tests_failed': tests['failed'] ?? 0,
  };
  history.add(entry);
  // Keep last 20
  final trimmed = history.length > 20
      ? history.sublist(history.length - 20)
      : history;
  await File(path).writeAsString(jsonEncode(trimmed));
  return trimmed;
}

double? _extractAvgFps(Map<String, dynamic> data) {
  final perf = data['ui_performance'];
  if (perf is Map) {
    final direct = perf['avgFps'];
    if (direct is num) return direct.toDouble();
    final screens = perf['screens'];
    if (screens is Map) {
      var sum = 0.0;
      var count = 0;
      for (final v in screens.values) {
        if (v is Map) {
          final f = v['avgFps'];
          if (f is num) {
            sum += f.toDouble();
            count++;
          }
        }
      }
      if (count > 0) return sum / count;
    }
  }
  return null;
}

String _trendSection(
  List<Map<String, dynamic>> history,
  String covDeltaStr,
  String fpsDeltaStr,
  Map uiMetrics,
) {
  if (history.isEmpty) {
    return '';
  }
  final covValues = history
      .map(
        (e) =>
            (e['coverage'] is num) ? (e['coverage'] as num).toDouble() : null,
      )
      .whereType<double>()
      .toList();
  final fpsValues = history
      .map((e) => (e['fps'] is num) ? (e['fps'] as num).toDouble() : null)
      .whereType<double>()
      .toList();
  final covChart = covValues.isNotEmpty
      ? _svgLineChart(covValues, height: 140, width: 520, color: '#667eea')
      : '<em>No coverage data yet</em>';
  final fpsChart = fpsValues.isNotEmpty
      ? _svgLineChart(fpsValues, height: 140, width: 520, color: '#10b981')
      : '<em>No FPS data yet</em>';
  final driftHistory = (uiMetrics['adaptive_drift_history'] is List)
      ? (uiMetrics['adaptive_drift_history'] as List)
            .whereType<num>()
            .map((e) => e.toDouble())
            .toList()
      : const <double>[];
  final driftChart = driftHistory.isNotEmpty
      ? _svgLineChart(driftHistory, height: 140, width: 520, color: '#ef4444')
      : '<em>No adaptive drift data yet</em>';
  return '''
                <div class="trend-section">
                        <div class="trend-grid">
                                <div class="trend-card">
                                        <h3>Coverage Trend (last ${covValues.length.clamp(0, 20)})</h3>
                                        <div class="delta">${covDeltaStr.isEmpty ? '' : covDeltaStr + ' vs previous'}</div>
                                        <div class="chart">$covChart<caption>Percent over recent runs</caption></div>
                                </div>
                                <div class="trend-card">
                                        <h3>FPS Trend (last ${fpsValues.length.clamp(0, 20)})</h3>
                                        <div class="delta">${fpsDeltaStr.isEmpty ? '' : fpsDeltaStr + ' vs previous'}</div>
                                        <div class="chart">$fpsChart<caption>Average frames per second</caption></div>
                                </div>
                                <div class="trend-card">
                                        <h3>Adaptive Drift Trend (last ${driftHistory.length.clamp(0, 10)})</h3>
                                        <div class="delta"></div>
                                        <div class="chart">$driftChart<caption>Avg drift ± % (recent exports)</caption></div>
                                </div>
                        </div>
                </div>
    ''';
}

String _revenueSection(
  Map<String, dynamic> revenue,
  List<Map<String, dynamic>> history,
) {
  final totalRevenue = (revenue['totalRevenue'] is num)
      ? (revenue['totalRevenue'] as num).toDouble()
      : 0.0;
  final arpu = (revenue['arpu'] is num)
      ? (revenue['arpu'] as num).toDouble()
      : 0.0;
  final conv = (revenue['conversionRate'] is num)
      ? (revenue['conversionRate'] as num).toDouble()
      : 0.0;
  final convValues = history
      .map(
        (e) => (e['conversion'] is num)
            ? (e['conversion'] as num).toDouble()
            : null,
      )
      .whereType<double>()
      .toList();
  final convChart = convValues.isNotEmpty
      ? _svgLineChart(convValues, height: 140, width: 520, color: '#f59e0b')
      : '<em>No conversion data yet</em>';
  return '''
        <div class="info-section">
            <h3>Revenue Overview</h3>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Total Revenue</div>
                        <div class="value">
                            \$${totalRevenue.toStringAsFixed(2)}
                        </div>
                </div>
                <div class="info-item">
                    <div class="label">ARPU</div>
                        <div class="value">
                            \$${arpu.toStringAsFixed(2)}
                        </div>
                </div>
                <div class="info-item">
                    <div class="label">Conversion Rate</div>
                    <div class="value">${(conv * 100).toStringAsFixed(1)}%</div>
                </div>
            </div>
            <div class="trend-section">
                <div class="trend-card">
                    <h3>Conversion Trend (last ${convValues.length.clamp(0, 20)})</h3>
                    <div class="chart">$convChart<caption>Share of users with premium</caption></div>
                </div>
            </div>
        </div>
  ''';
}

String _svgLineChart(
  List<double> values, {
  int width = 520,
  int height = 140,
  String color = '#667eea',
}) {
  if (values.isEmpty) return '';
  final minV = values.reduce((a, b) => a < b ? a : b);
  final maxV = values.reduce((a, b) => a > b ? a : b);
  final pad = 8.0;
  final w = width.toDouble();
  final h = height.toDouble();
  final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
  final stepX = (w - 2 * pad) / (values.length - 1).clamp(1, 999999);
  final pts = <String>[];
  for (var i = 0; i < values.length; i++) {
    final x = pad + stepX * i;
    final norm = (values[i] - minV) / span; // 0..1
    final y = h - pad - norm * (h - 2 * pad); // invert y axis
    pts.add('${x.toStringAsFixed(1)},${y.toStringAsFixed(1)}');
  }
  final minLabel = minV.toStringAsFixed(1);
  final maxLabel = maxV.toStringAsFixed(1);
  return '''
<svg width="$width" height="$height" viewBox="0 0 $width $height" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="trend chart">
    <rect x="0" y="0" width="$width" height="$height" fill="#ffffff"/>
    <polyline fill="none" stroke="$color" stroke-width="3" points="${pts.join(' ')}"/>
    <text x="4" y="${(height - 4)}" font-size="10" fill="#888">$minLabel</text>
    <text x="4" y="12" font-size="10" fill="#888">$maxLabel</text>
</svg>
''';
}

String _formatSigned(double v, {String suffix = ''}) {
  final s = v >= 0 ? '+${v.toStringAsFixed(1)}' : v.toStringAsFixed(1);
  return '$s$suffix';
}

String _formatTimestamp(String timestamp) {
  try {
    final dt = DateTime.parse(timestamp);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} UTC';
  } catch (e) {
    return timestamp;
  }
}

Future<Map<String, dynamic>> _readUiMetricsJson() async {
  final file = File('ui_metrics.json');
  if (!await file.exists()) return const {};
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      return data;
    }
  } catch (_) {}
  return const {};
}

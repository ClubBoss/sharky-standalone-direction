import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final options = _Options.parse(args);
  final summary = _readSummary();

  final readiness = summary.readiness;
  final advisor = summary.advisor;
  final feedback = summary.feedback;
  final status = summary.status;

  if (options.summary) {
    final emoji = status == 'PASS' ? '✅' : '❌';
    stdout.writeln(
      'QA Dashboard: $status $emoji '
      '(readiness ${readiness.toStringAsFixed(1)}%, '
      'advisor ${advisor.toStringAsFixed(1)}%, '
      'feedback ${feedback.toStringAsFixed(1)}%)',
    );
    if (summary.trendSummary.isNotEmpty) {
      stdout.writeln(summary.trendSummary);
    }
    if (summary.unifiedTelemetryLine.isNotEmpty) {
      stdout.writeln(summary.unifiedTelemetryLine);
    }
  }

  if (options.generate) {
    await _writeHtml(summary);
    await _writeMetadata(summary);
  }
}

class _Options {
  _Options({required this.summary, required this.generate});

  final bool summary;
  final bool generate;

  static _Options parse(List<String> args) {
    var summary = false;
    var generate = true;
    for (final arg in args) {
      switch (arg) {
        case '--summary':
          summary = true;
          break;
        case '--generate':
          generate = true;
          break;
        case '--no-generate':
          generate = false;
          break;
      }
    }
    return _Options(summary: summary, generate: generate);
  }
}

class _DashboardModel {
  _DashboardModel({
    required this.readiness,
    required this.advisor,
    required this.feedback,
    required this.timestampUtc,
    required this.status,
    required this.trendSummary,
    required this.unifiedTelemetryLine,
  });

  final double readiness;
  final double advisor;
  final double feedback;
  final String timestampUtc;
  final String status;
  final String trendSummary;
  final String unifiedTelemetryLine;
}

_DashboardModel _readSummary() {
  final file = File('tools/_reports/qa_release_summary.json');
  if (!file.existsSync()) {
    return _DashboardModel(
      readiness: 0.0,
      advisor: 0.0,
      feedback: 0.0,
      timestampUtc: '',
      status: 'FAIL',
      trendSummary: '',
      unifiedTelemetryLine: '',
    );
  }
  try {
    final raw = jsonDecode(file.readAsStringSync());
    if (raw is Map<String, dynamic>) {
      final readiness =
          (raw['readiness'] is Map ? raw['readiness']['score'] : null)
              as num? ??
          0;
      final advisor =
          (raw['advisor'] is Map ? raw['advisor']['confidence_score'] : null)
              as num? ??
          0;
      final feedback =
          (raw['feedback'] is Map ? raw['feedback']['records_analyzed'] : null)
              as num? ??
          0;
      final stamp = raw['generated_at']?.toString() ?? '';
      final status = readiness >= 60 && stamp.isNotEmpty ? 'PASS' : 'FAIL';
      return _DashboardModel(
        readiness: readiness.toDouble(),
        advisor: advisor.toDouble(),
        feedback: feedback.toDouble(),
        timestampUtc: stamp,
        status: status,
        trendSummary: _readTrendSummary(),
        unifiedTelemetryLine: _buildUnifiedTelemetryLine(
          raw['unified_telemetry'],
        ),
      );
    }
  } catch (e) {
    stderr.writeln('[WARN] Failed to parse qa_release_summary.json: $e');
  }
  return _DashboardModel(
    readiness: 0.0,
    advisor: 0.0,
    feedback: 0.0,
    timestampUtc: '',
    status: 'FAIL',
    trendSummary: '',
    unifiedTelemetryLine: '',
  );
}

String _readTrendSummary() {
  final metadataFile = File('release/public_beta_v2/metadata.json');
  if (!metadataFile.existsSync()) {
    return '';
  }
  try {
    final raw = jsonDecode(metadataFile.readAsStringSync());
    if (raw is Map<String, dynamic>) {
      final trends = raw['trends'] as Map<String, dynamic>? ?? const {};
      final history = trends['trend_history'] as List<dynamic>? ?? const [];
      if (history.isEmpty) {
        return '';
      }
      final streaks = trends['streaks'] as Map<String, dynamic>? ?? const {};
      final segments = <String>[];
      segments.add(_formatTrendSegment(streaks['readiness'], 'Readiness'));
      segments.add(_formatTrendSegment(streaks['advisor'], 'Advisor'));
      segments.add(_formatTrendSegment(streaks['feedback'], 'Feedback'));
      final filtered = segments.where((segment) => segment.isNotEmpty).toList();
      if (filtered.isEmpty) {
        return '';
      }
      return '7-Day Trend -> ${filtered.join(' | ')}';
    }
  } catch (e) {
    stderr.writeln('[WARN] Failed to read trend history: $e');
  }
  return '';
}

String _formatTrendSegment(Object? raw, String label) {
  if (raw is! Map) {
    return '';
  }
  final data = raw.cast<String, dynamic>();
  final direction = (data['direction'] as String?) ?? 'stable';
  final change = (data['change'] as num?)?.toDouble() ?? 0.0;

  final arrow = direction == 'improving'
      ? '^'
      : direction == 'declining'
      ? 'v'
      : '-';
  final descriptor = direction == 'improving'
      ? 'Improving'
      : direction == 'declining'
      ? 'Declining'
      : 'Stable';
  final magnitude = change.abs().toStringAsFixed(1);
  final formattedChange = direction == 'stable'
      ? '+/-$magnitude%'
      : '${change >= 0 ? '+' : '-'}$magnitude%';

  return '$label: $arrow $descriptor ($formattedChange)';
}

String _buildUnifiedTelemetryLine(Object? raw) {
  if (raw is! Map) {
    return '';
  }
  final data = raw.cast<String, dynamic>();
  final feeds = (data['feeds_merged'] as num?)?.toInt() ?? 0;
  final derived = data['derived_metrics'] as Map<String, dynamic>? ?? const {};
  final status = (derived['status'] as String?) ?? 'WARN [PARTIAL]';
  final normalizedStatus = status.contains('PASS') ? 'PASS [OK]' : status;
  return 'Unified Telemetry -> $normalizedStatus ($feeds feeds merged)';
}

Future<void> _writeHtml(_DashboardModel model) async {
  final emoji = model.status == 'PASS' ? '✅' : '❌';
  final readinessEmoji = model.readiness >= 60 ? '✅' : '❌';
  final advisorEmoji = model.advisor > 0 ? '✅' : '❌';
  final feedbackEmoji = model.feedback > 0 ? '✅' : '❌';

  final html = [
    '<!DOCTYPE html>',
    '<html lang="en">',
    '<head>',
    '  <meta charset="utf-8" />',
    '  <title>QA Release Dashboard</title>',
    '  <style>',
    '    body { font-family: Arial, sans-serif; background: #101820; ',
    '      color: #f4f4f4; margin: 0; padding: 40px; }',
    '    h1 { text-align: center; margin-bottom: 32px; }',
    '    .status { text-align: center; margin-bottom: 24px; font-size: 18px; }',
    '    .grid { display: flex; gap: 16px; justify-content: center; }',
    '    .card { background: #172733; border-radius: 12px; padding: 24px; ',
    '      min-width: 180px; text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.4); }',
    '    .label { font-size: 16px; margin-bottom: 12px; text-transform: uppercase; }',
    '    .value { font-size: 32px; font-weight: bold; }',
    '    .footer { text-align: center; margin-top: 32px; font-size: 14px; color: #cccccc; }',
    '  </style>',
    '</head>',
    '<body>',
    '  <h1>QA Release Dashboard</h1>',
    '  <div class="status">Overall Status: ${model.status} $emoji</div>',
    '  <div class="grid">',
    '    <div class="card">',
    '      <div class="label">Readiness</div>',
    '      <div class="value">${model.readiness.toStringAsFixed(1)}% $readinessEmoji</div>',
    '    </div>',
    '    <div class="card">',
    '      <div class="label">Advisor</div>',
    '      <div class="value">${model.advisor.toStringAsFixed(1)}% $advisorEmoji</div>',
    '    </div>',
    '    <div class="card">',
    '      <div class="label">Feedback</div>',
    '      <div class="value">${model.feedback.toStringAsFixed(0)} $feedbackEmoji</div>',
    '    </div>',
    '  </div>',
    '  <div class="footer">Last Updated: ${model.timestampUtc}</div>',
    '</body>',
    '</html>',
  ].join('\n');

  final file = File('release/qa_dashboard/index.html');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('$html\n');
}

Future<void> _writeMetadata(_DashboardModel model) async {
  final metadata = <String, dynamic>{
    'readiness': model.readiness,
    'advisor': model.advisor,
    'feedback': model.feedback,
    'timestamp_utc': model.timestampUtc,
    'status': model.status,
  };
  final encoder = JsonEncoder.withIndent('  ');
  final file = File('release/qa_dashboard/metadata.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('${encoder.convert(metadata)}\n');
}

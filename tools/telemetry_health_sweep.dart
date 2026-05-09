import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/telemetry_health_sweep_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/telemetry_health_sweep_summary.json';

const double _minCoverage = 95.0;
const double _maxMalformedPercent = 1.0;

const List<String> _expectedCompletedEvents = [
  'rsi_auto_recovery_completed',
  'regression_health_forecast_completed',
  'stability_qa_bridge_completed',
  'visual_qa_final_completed',
  'visual_cohesion_final_completed',
  'content_evolution_qa_completed',
  'marketing_onboarding_completed',
  'release_inventory_cleaner_completed',
  'automation_maintenance_completed',
  'retention_campaign_completed',
  'telemetry_health_sweep_completed',
];

Future<void> main(List<String> args) async {
  final sweep = TelemetryHealthSweep();
  final ok = await sweep.run();
  if (!ok) {
    exitCode = 2;
  }
}

class TelemetryHealthSweep {
  Future<bool> run() async {
    final telemetryLines = await _readTelemetry();
    final evaluation = _evaluateTelemetry(telemetryLines);

    final summaryText = _buildTextSummary(evaluation);
    final summaryJson = _buildJsonSummary(evaluation);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(evaluation);
    });

    final pass =
        evaluation.coverageRatio >= _minCoverage &&
        evaluation.malformedPercent <= _maxMalformedPercent;

    if (!pass) {
      stderr.writeln(
        'Telemetry health failed: coverage=${evaluation.coverageRatio.toStringAsFixed(2)}%, '
        'malformed=${evaluation.malformedPercent.toStringAsFixed(2)}%',
      );
    }

    return pass;
  }

  Future<List<String>> _readTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return const [];
    return file.readAsLines();
  }

  _TelemetryEvaluation _evaluateTelemetry(List<String> lines) {
    final seenEvents = <String>{};
    final duplicates = <String>{};
    final malformedLines = <int>[];
    final missingFields = <int>[];
    final orderViolations = <int>[];

    DateTime? lastTimestamp;

    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty) continue;
      Map<String, Object?>? parsed;
      try {
        final dynamic decoded = json.decode(raw);
        if (decoded is Map<String, Object?>) {
          parsed = decoded;
        } else {
          malformedLines.add(i + 1);
        }
      } catch (_) {
        malformedLines.add(i + 1);
      }
      if (parsed == null) {
        continue;
      }
      final event = parsed['event']?.toString();
      final timestampStr = parsed['timestamp']?.toString();
      if (event == null || event.isEmpty || timestampStr == null) {
        missingFields.add(i + 1);
        continue;
      }
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(timestampStr);
      } catch (_) {
        malformedLines.add(i + 1);
        continue;
      }
      if (lastTimestamp != null && timestamp.isBefore(lastTimestamp)) {
        orderViolations.add(i + 1);
      }
      lastTimestamp = timestamp;
      if (_expectedCompletedEvents.contains(event)) {
        if (!seenEvents.add(event)) {
          duplicates.add(event);
        }
      }
    }

    final coverage =
        seenEvents.length / _expectedCompletedEvents.length * 100.0;
    final malformedPercent = lines.isEmpty
        ? 0.0
        : (malformedLines.length / lines.length) * 100.0;
    final missingEvents = _expectedCompletedEvents
        .where((event) => !seenEvents.contains(event))
        .toList();

    return _TelemetryEvaluation(
      coverageRatio: coverage,
      malformedPercent: malformedPercent,
      missingEvents: missingEvents,
      duplicateEvents: duplicates.toList(),
      malformedLines: malformedLines,
      missingFieldLines: missingFields,
      orderViolationLines: orderViolations,
      totalLines: lines.length,
    );
  }

  String _buildTextSummary(_TelemetryEvaluation eval) {
    final buffer = StringBuffer()
      ..writeln('TELEMETRY HEALTH SWEEP SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Coverage ratio: ${eval.coverageRatio.toStringAsFixed(2)}%')
      ..writeln(
        'Malformed payloads: ${eval.malformedPercent.toStringAsFixed(2)}%',
      )
      ..writeln('Missing events: ${eval.missingEvents.length}')
      ..writeln('Duplicate events: ${eval.duplicateEvents.length}')
      ..writeln('Out-of-order timestamps: ${eval.orderViolationLines.length}')
      ..writeln();
    if (eval.missingEvents.isNotEmpty) {
      buffer.writeln('Missing *_completed events:');
      for (final event in eval.missingEvents) {
        buffer.writeln('  - $event');
      }
      buffer.writeln();
    }
    if (eval.duplicateEvents.isNotEmpty) {
      buffer.writeln('Duplicate events observed:');
      for (final event in eval.duplicateEvents) {
        buffer.writeln('  - $event');
      }
      buffer.writeln();
    }
    if (eval.malformedLines.isNotEmpty) {
      buffer.writeln(
        'Malformed lines: ${eval.malformedLines.take(20).join(', ')}'
        '${eval.malformedLines.length > 20 ? ' ...' : ''}',
      );
    }
    if (eval.missingFieldLines.isNotEmpty) {
      buffer.writeln(
        'Missing field lines: ${eval.missingFieldLines.join(', ')}',
      );
    }
    if (eval.orderViolationLines.isNotEmpty) {
      buffer.writeln(
        'Order violations at lines: ${eval.orderViolationLines.join(', ')}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(_TelemetryEvaluation eval) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'coverage_ratio': eval.coverageRatio,
      'malformed_percent': eval.malformedPercent,
      'missing_events': eval.missingEvents,
      'duplicate_events': eval.duplicateEvents,
      'malformed_lines': eval.malformedLines,
      'missing_field_lines': eval.missingFieldLines,
      'order_violation_lines': eval.orderViolationLines,
      'total_lines': eval.totalLines,
      'thresholds': {
        'coverage_min': _minCoverage,
        'malformed_max': _maxMalformedPercent,
      },
    };
  }

  Future<void> _appendTelemetry(_TelemetryEvaluation eval) async {
    final payload = <String, Object?>{
      'event': 'telemetry_health_sweep_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'coverage_ratio': eval.coverageRatio,
      'malformed_percent': eval.malformedPercent,
      'missing_events': eval.missingEvents,
      'duplicate_events': eval.duplicateEvents,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _TelemetryEvaluation {
  _TelemetryEvaluation({
    required this.coverageRatio,
    required this.malformedPercent,
    required this.missingEvents,
    required this.duplicateEvents,
    required this.malformedLines,
    required this.missingFieldLines,
    required this.orderViolationLines,
    required this.totalLines,
  });

  final double coverageRatio;
  final double malformedPercent;
  final List<String> missingEvents;
  final List<String> duplicateEvents;
  final List<int> malformedLines;
  final List<int> missingFieldLines;
  final List<int> orderViolationLines;
  final int totalLines;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}

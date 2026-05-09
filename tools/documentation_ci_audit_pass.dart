import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/docs_audit_summary.txt';
const String _summaryJsonPath = '$_reportsDir/docs_audit_summary.json';
const double _maxMissingDocsRatio = 0.05;
const double _maxTelemetryMismatchRatio = 0.02;

const Map<String, String> _eventSummaryMap = {
  'rsi_auto_recovery_completed': 'rsi_auto_recovery_summary.txt',
  'regression_health_forecast_completed':
      'regression_health_forecast_summary.txt',
  'stability_qa_bridge_completed': 'stability_qa_bridge_summary.txt',
  'visual_qa_final_completed': 'visual_qa_final_summary.txt',
  'visual_cohesion_final_completed': 'visual_cohesion_final_summary.txt',
  'content_evolution_qa_completed': 'content_evolution_qa_summary.txt',
  'marketing_onboarding_completed': 'marketing_onboarding_summary.txt',
  'release_inventory_cleaner_completed': 'release_inventory_summary.txt',
  'automation_maintenance_completed': 'automation_maintenance_summary.txt',
  'retention_campaign_completed': 'retention_campaign_summary.txt',
  'telemetry_health_sweep_completed': 'telemetry_health_sweep_summary.txt',
  'localization_glossary_completed': 'glossary_summary.txt',
  'documentation_ci_audit_completed': 'docs_audit_summary.txt',
};

Future<void> main(List<String> args) async {
  final audit = DocumentationCiAuditPass();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class DocumentationCiAuditPass {
  Future<bool> run() async {
    final docStats = await _scanDocumentation();
    final telemetryStats = await _checkTelemetrySummaries();

    final docRatio = docStats.totalFiles == 0
        ? 0
        : docStats.missingHeaders / docStats.totalFiles;
    final telemetryRatio = telemetryStats.totalEvents == 0
        ? 0
        : telemetryStats.missingSummaries / telemetryStats.totalEvents;
    final pass =
        docRatio <= _maxMissingDocsRatio &&
        telemetryRatio <= _maxTelemetryMismatchRatio;

    final summaryText = _buildTextSummary(docStats, telemetryStats, pass);
    final summaryJson = _buildJsonSummary(docStats, telemetryStats, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(docStats, telemetryStats, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Documentation/CI audit failed: missing docs ratio '
        '${(docRatio * 100).toStringAsFixed(2)}%, telemetry mismatch '
        '${(telemetryRatio * 100).toStringAsFixed(2)}%',
      );
    }

    return pass;
  }

  Future<_DocStats> _scanDocumentation() async {
    final targets = [
      Directory('tools'),
      Directory('lib/services'),
      Directory('lib/ui'),
    ];
    int total = 0;
    int missing = 0;
    final filesChecked = <String>[];

    for (final dir in targets) {
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        total++;
        filesChecked.add(entity.path);
        final ok = await _fileHasDocHeader(entity);
        if (!ok) {
          missing++;
        }
      }
    }
    return _DocStats(
      totalFiles: total,
      missingHeaders: missing,
      sampledFiles: filesChecked,
    );
  }

  Future<bool> _fileHasDocHeader(File file) async {
    try {
      final lines = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .take(20)
          .toList();
      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;
        if (line.startsWith('//') ||
            line.startsWith('///') ||
            line.startsWith('/*')) {
          return true;
        }
        return false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<_TelemetryStats> _checkTelemetrySummaries() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      return const _TelemetryStats(
        totalEvents: 0,
        missingSummaries: 0,
        missingEventNames: [],
      );
    }
    final missing = <String>{};
    int total = 0;
    try {
      final lines = await file.readAsLines();
      for (final raw in lines) {
        final line = raw.trim();
        if (line.isEmpty) continue;
        Map<String, Object?>? parsed;
        try {
          parsed = json.decode(line) as Map<String, Object?>?;
        } catch (_) {
          continue;
        }
        if (parsed == null) continue;
        final event = parsed['event']?.toString();
        if (event == null || !_eventSummaryMap.containsKey(event)) continue;
        total++;
        final summary = _eventSummaryMap[event];
        if (summary == null) continue;
        final path = '$_reportsDir/$summary';
        if (!File(path).existsSync()) {
          missing.add(event);
        }
      }
    } catch (_) {}
    return _TelemetryStats(
      totalEvents: total,
      missingSummaries: missing.length,
      missingEventNames: missing.toList(),
    );
  }

  String _buildTextSummary(
    _DocStats doc,
    _TelemetryStats telemetry,
    bool pass,
  ) {
    final docPct = doc.totalFiles == 0
        ? 0
        : (doc.missingHeaders / doc.totalFiles) * 100;
    final telPct = telemetry.totalEvents == 0
        ? 0
        : (telemetry.missingSummaries / telemetry.totalEvents) * 100;
    final buffer = StringBuffer()
      ..writeln('DOCUMENTATION & CI AUDIT SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Files checked: ${doc.totalFiles}')
      ..writeln(
        'Missing doc headers: ${doc.missingHeaders} (${docPct.toStringAsFixed(2)}%)',
      )
      ..writeln('Telemetry events checked: ${telemetry.totalEvents}')
      ..writeln(
        'Telemetry mismatches: ${telemetry.missingSummaries} (${telPct.toStringAsFixed(2)}%)',
      )
      ..writeln(
        'Thresholds: docs <= ${(_maxMissingDocsRatio * 100).toStringAsFixed(2)}%, '
        'telemetry <= ${(_maxTelemetryMismatchRatio * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    if (telemetry.missingEventNames.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Missing summary for events:');
      for (final event in telemetry.missingEventNames.take(20)) {
        buffer.writeln('  - $event');
      }
      if (telemetry.missingEventNames.length > 20) {
        buffer.writeln(
          '  ... +${telemetry.missingEventNames.length - 20} more',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    _DocStats doc,
    _TelemetryStats telemetry,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'doc_files_checked': doc.totalFiles,
      'doc_missing_headers': doc.missingHeaders,
      'doc_missing_ratio': doc.totalFiles == 0
          ? 0
          : doc.missingHeaders / doc.totalFiles,
      'telemetry_events_checked': telemetry.totalEvents,
      'telemetry_missing': telemetry.missingSummaries,
      'telemetry_missing_ratio': telemetry.totalEvents == 0
          ? 0
          : telemetry.missingSummaries / telemetry.totalEvents,
      'missing_events': telemetry.missingEventNames,
      'thresholds': {
        'doc_max_missing_ratio': _maxMissingDocsRatio,
        'telemetry_max_missing_ratio': _maxTelemetryMismatchRatio,
      },
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    _DocStats doc,
    _TelemetryStats telemetry,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'documentation_ci_audit_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'doc_files_checked': doc.totalFiles,
      'doc_missing_headers': doc.missingHeaders,
      'telemetry_events_checked': telemetry.totalEvents,
      'telemetry_missing': telemetry.missingSummaries,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _DocStats {
  const _DocStats({
    required this.totalFiles,
    required this.missingHeaders,
    required this.sampledFiles,
  });

  final int totalFiles;
  final int missingHeaders;
  final List<String> sampledFiles;
}

class _TelemetryStats {
  const _TelemetryStats({
    required this.totalEvents,
    required this.missingSummaries,
    required this.missingEventNames,
  });

  final int totalEvents;
  final int missingSummaries;
  final List<String> missingEventNames;
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

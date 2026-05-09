import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _summaryPath =
    '$_reportsDir/automated_stability_ledger_summary.txt';
const String _historyPath =
    '$_reportsDir/_automated_stability_ledger_history.json';
const String _guardianLedgerPath =
    '$_reportsDir/_continuous_regression_ledger.json';
const String _maintenanceHistoryPath =
    '$_reportsDir/_regression_maintenance_history.json';
const String _consolidationStatePath =
    '$_reportsDir/_regression_consolidation_state.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const int _rollingWindow = 7;
const double _rsiThreshold = 90.0;
const double _fsHealthThreshold = 95.0;

Future<void> main(List<String> args) async {
  final ledger = AutomatedStabilityLedger();
  final ok = await ledger.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AutomatedStabilityLedger {
  Future<bool> run() async {
    final now = DateTime.now().toIso8601String();
    final guardianEntries = await _readLedger();
    final maintenanceHistory = await _readJsonList(_maintenanceHistoryPath);
    final consolidationState = await _readJsonMap(_consolidationStatePath);
    final verdictStats = await _scanSummaryVerdicts();
    final telemetryStats = await _readGuardianTelemetry();

    final latestRsi = guardianEntries.isNotEmpty
        ? (guardianEntries.last['rsi'] as num?)?.toDouble() ?? 0
        : 0.0;
    final latestRdi = guardianEntries.isNotEmpty
        ? (guardianEntries.last['rdi'] as num?)?.toDouble() ?? 0
        : 0.0;
    final maintenanceTrend = _computeMaintenanceTrend(maintenanceHistory);

    final currentEntry = {
      'timestamp': now,
      'latest_rsi': latestRsi,
      'latest_rdi': latestRdi,
      'pass_ratio': verdictStats.passRatio,
      'warn_ratio': verdictStats.warnRatio,
      'fail_ratio': verdictStats.failRatio,
      'fs_health': telemetryStats.fsHealth,
      'telemetry_volume': telemetryStats.sampleSize,
    };

    final history = await _readHistory();
    final updatedHistory = [...history, currentEntry];
    while (updatedHistory.length > 50) {
      updatedHistory.removeAt(0);
    }
    final rollingWindow = _takeLastMaps(updatedHistory, _rollingWindow);

    double avg(String key) {
      if (rollingWindow.isEmpty) return 0;
      final total = rollingWindow
          .map((entry) => (entry[key] as num?)?.toDouble() ?? 0)
          .fold<double>(0, (a, b) => a + b);
      return total / rollingWindow.length;
    }

    final rollingRsi = avg('latest_rsi');
    final rollingRdi = avg('latest_rdi');
    final rollingPass = avg('pass_ratio');
    final rollingWarn = avg('warn_ratio');
    final rollingFail = avg('fail_ratio');
    final rollingFsHealth = avg('fs_health');
    final rollingTelemetry = avg('telemetry_volume');

    final success =
        rollingRsi >= _rsiThreshold && rollingFsHealth >= _fsHealthThreshold;

    final summary = _buildSummary(
      generatedAt: now,
      latestRsi: latestRsi,
      latestRdi: latestRdi,
      rollingRsi: rollingRsi,
      rollingRdi: rollingRdi,
      passRatio: verdictStats.passRatio,
      warnRatio: verdictStats.warnRatio,
      failRatio: verdictStats.failRatio,
      rollingPass: rollingPass,
      rollingWarn: rollingWarn,
      rollingFail: rollingFail,
      fsHealth: telemetryStats.fsHealth,
      rollingFsHealth: rollingFsHealth,
      telemetryVolume: telemetryStats.sampleSize.toDouble(),
      rollingTelemetry: rollingTelemetry,
      maintenanceTrend: maintenanceTrend,
      consolidationState: consolidationState,
      success: success,
    );

    await _withReportsWritable(() async {
      await _writeString(_summaryPath, summary);
      await _writeJson(_historyPath, updatedHistory);
      await _appendTelemetry({
        'event': 'automated_stability_ledger_completed',
        'timestamp': now,
        'rolling_rsi': rollingRsi,
        'rolling_rdi': rollingRdi,
        'rolling_pass_ratio': rollingPass,
        'rolling_warn_ratio': rollingWarn,
        'rolling_fail_ratio': rollingFail,
        'rolling_fs_health': rollingFsHealth,
        'rolling_telemetry_volume': rollingTelemetry,
        'verdict': success ? 'PASS' : 'FAIL',
      });
    });

    return success;
  }

  Future<List<Map<String, Object?>>> _readLedger() async {
    final file = File(_guardianLedgerPath);
    if (!await file.exists()) return [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => m.cast<String, Object?>())
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, Object?>>> _readHistory() async {
    final file = File(_historyPath);
    if (!await file.exists()) return [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => m.cast<String, Object?>())
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, Object?>>> _readJsonList(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => m.cast<String, Object?>())
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, Object?>> _readJsonMap(String path) async {
    final file = File(path);
    if (!await file.exists()) return {};
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map) {
        return decoded.cast<String, Object?>();
      }
    } catch (_) {}
    return {};
  }

  Future<_VerdictStats> _scanSummaryVerdicts() async {
    final dir = Directory(_reportsDir);
    if (!await dir.exists()) {
      return _VerdictStats.empty();
    }
    final counts = <String, int>{'PASS': 0, 'WARN': 0, 'FAIL': 0};
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.endsWith('_summary.txt')) continue;
      final verdict = await _extractVerdict(entity);
      if (counts.containsKey(verdict)) {
        counts[verdict] = counts[verdict]! + 1;
      }
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return _VerdictStats.empty();
    }
    return _VerdictStats(
      passRatio: counts['PASS']! * 100 / total,
      warnRatio: counts['WARN']! * 100 / total,
      failRatio: counts['FAIL']! * 100 / total,
    );
  }

  Future<String> _extractVerdict(File file) async {
    try {
      final lines = await file.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.toLowerCase().startsWith('verdict')) {
          final verdict = trimmed.split(':').last.trim().toUpperCase();
          if (verdict.contains('PASS')) return 'PASS';
          if (verdict.contains('WARN')) return 'WARN';
          if (verdict.contains('FAIL')) return 'FAIL';
        }
      }
    } catch (_) {}
    return 'FAIL';
  }

  Future<_TelemetryStats> _readGuardianTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      return _TelemetryStats(fsHealth: 0, sampleSize: 0);
    }
    final lines = await file.readAsLines();
    final events = <Map<String, Object?>>[];
    for (final line in lines.reversed) {
      try {
        final decoded = json.decode(line);
        if (decoded is Map &&
            decoded['event'] == 'continuous_regression_guardian_completed') {
          events.add(decoded.cast<String, Object?>());
          if (events.length >= _rollingWindow) break;
        }
      } catch (_) {}
    }
    if (events.isEmpty) {
      return _TelemetryStats(fsHealth: 0, sampleSize: 0);
    }
    final okCount = events
        .where((event) => (event['fs_write_status'] ?? 'warn') == 'ok')
        .length;
    final fsHealth = okCount * 100 / events.length;
    return _TelemetryStats(fsHealth: fsHealth, sampleSize: events.length);
  }
}

String _buildSummary({
  required String generatedAt,
  required double latestRsi,
  required double latestRdi,
  required double rollingRsi,
  required double rollingRdi,
  required double passRatio,
  required double warnRatio,
  required double failRatio,
  required double rollingPass,
  required double rollingWarn,
  required double rollingFail,
  required double fsHealth,
  required double rollingFsHealth,
  required double telemetryVolume,
  required double rollingTelemetry,
  required Map<String, Object?> maintenanceTrend,
  required Map<String, Object?> consolidationState,
  required bool success,
}) {
  final buffer = StringBuffer()
    ..writeln('AUTOMATED STABILITY LEDGER')
    ..writeln('===========================')
    ..writeln('Generated: $generatedAt')
    ..writeln('Latest RSI: ${latestRsi.toStringAsFixed(2)}%')
    ..writeln('Latest RDI: ${latestRdi.toStringAsFixed(2)}%')
    ..writeln('Rolling RSI (7): ${rollingRsi.toStringAsFixed(2)}%')
    ..writeln('Rolling RDI (7): ${rollingRdi.toStringAsFixed(2)}%')
    ..writeln(
      'QA verdict ratios (current): PASS ${passRatio.toStringAsFixed(2)}% | WARN ${warnRatio.toStringAsFixed(2)}% | FAIL ${failRatio.toStringAsFixed(2)}%',
    )
    ..writeln(
      'QA verdict ratios (7-run avg): PASS ${rollingPass.toStringAsFixed(2)}% | WARN ${rollingWarn.toStringAsFixed(2)}% | FAIL ${rollingFail.toStringAsFixed(2)}%',
    )
    ..writeln(
      'FS health (current 7 guardian runs): ${fsHealth.toStringAsFixed(2)}%',
    )
    ..writeln('FS health (7-run avg): ${rollingFsHealth.toStringAsFixed(2)}%')
    ..writeln(
      'Telemetry volume (current sample): ${telemetryVolume.toStringAsFixed(2)}',
    )
    ..writeln(
      'Telemetry volume (7-run avg): ${rollingTelemetry.toStringAsFixed(2)}',
    )
    ..writeln('Maintenance trend snapshot: ${jsonEncode(maintenanceTrend)}')
    ..writeln('Consolidation state snapshot: ${jsonEncode(consolidationState)}')
    ..writeln('Verdict: ${success ? 'PASS' : 'FAIL'}');
  return buffer.toString();
}

Map<String, Object?> _computeMaintenanceTrend(
  List<Map<String, Object?>> history,
) {
  if (history.isEmpty) {
    return {'entries': 0};
  }
  final take = _takeLastMaps(history, _rollingWindow);
  double avgField(String key) {
    final total = take
        .map((entry) => (entry[key] as num?)?.toDouble() ?? 0)
        .fold<double>(0, (a, b) => a + b);
    return total / take.length;
  }

  return {
    'entries': take.length,
    'avg_rsi': avgField('rsi'),
    'avg_rsi_delta': avgField('rsi_delta'),
  };
}

List<Map<String, Object?>> _takeLastMaps(
  List<Map<String, Object?>> list,
  int count,
) {
  if (list.length <= count) {
    return List<Map<String, Object?>>.from(list);
  }
  return List<Map<String, Object?>>.from(list.sublist(list.length - count));
}

Future<void> _writeString(String path, String contents) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(contents);
}

Future<void> _writeJson(String path, Object data) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}

Future<void> _appendTelemetry(Map<String, Object?> payload) async {
  final file = File(_telemetryPath);
  await file.parent.create(recursive: true);
  final sink = file.openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}

class _VerdictStats {
  const _VerdictStats({
    required this.passRatio,
    required this.warnRatio,
    required this.failRatio,
  });

  final double passRatio;
  final double warnRatio;
  final double failRatio;

  static _VerdictStats empty() =>
      const _VerdictStats(passRatio: 0, warnRatio: 0, failRatio: 0);
}

class _TelemetryStats {
  const _TelemetryStats({required this.fsHealth, required this.sampleSize});

  final double fsHealth;
  final int sampleSize;
}

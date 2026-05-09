import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/smart_pack_store_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/smart_pack_store_summary.txt';
const String _summaryJsonPath = '$_reportsDir/smart_pack_store_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _minCoverage = 0.8;
const double _minEv = 1.09;

Future<void> main(List<String> args) async {
  final dashboard = SmartPackStoreDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SmartPackStoreDashboard {
  final SmartPackStoreService _service = SmartPackStoreService();

  Future<bool> run() async {
    final result = await _service.buildStorefront();
    final pass =
        result.coverageRatio >= _minCoverage && result.averageEv >= _minEv;

    final summaryText = _buildTextSummary(result, pass);
    final summaryJson = _buildJsonSummary(result, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Smart pack store failed: coverage '
        '${(result.coverageRatio * 100).toStringAsFixed(2)}%, '
        'avg EV ${result.averageEv.toStringAsFixed(4)}.',
      );
    }

    return pass;
  }

  String _buildTextSummary(SmartPackStoreResult result, bool pass) {
    final buffer = StringBuffer()
      ..writeln('SMART PACK STORE SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Cluster coverage: ${(result.coverageRatio * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Average EV uplift: ${result.averageEv.toStringAsFixed(4)}')
      ..writeln(
        'Thresholds: coverage >= ${(_minCoverage * 100).toStringAsFixed(0)}%, '
        'EV >= ${_minEv.toStringAsFixed(2)}',
      )
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    for (final cluster in result.clusters) {
      buffer.writeln(
        'Cluster ${cluster.clusterName} (${cluster.persona}) packs:',
      );
      if (cluster.packs.isEmpty) {
        buffer.writeln('  - No eligible packs');
        continue;
      }
      for (final pack in cluster.packs) {
        buffer.writeln(
          '  - ${pack.topic}: EV ${pack.evUplift.toStringAsFixed(4)}, '
          'difficulty ${pack.difficulty.toStringAsFixed(2)}',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    SmartPackStoreResult result,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'coverage_ratio': result.coverageRatio,
      'average_ev': result.averageEv,
      'clusters': result.clusters
          .map(
            (cluster) => {
              'cluster': cluster.clusterName,
              'persona': cluster.persona,
              'pack_count': cluster.packs.length,
              'packs': cluster.packs
                  .map(
                    (pack) => {
                      'topic': pack.topic,
                      'ev_uplift': pack.evUplift,
                      'difficulty': pack.difficulty,
                      'resonance': pack.resonance,
                      'path': pack.path,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(SmartPackStoreResult result, bool pass) async {
    final payload = <String, Object?>{
      'event': 'smart_pack_store_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'coverage_ratio': result.coverageRatio,
      'average_ev': result.averageEv,
      'cluster_count': result.clusters.length,
      'pack_count': result.totalPacks,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
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

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/final_stability_verification_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/final_stability_verification_summary.json';

const double _threshold = 0.90;

const List<_SnapshotTarget> _targets = <_SnapshotTarget>[
  _SnapshotTarget(
    label: 'Stability QA Consolidator v2',
    jsonPath: '$_reportsDir/stability_qa_consolidator_v2_summary.json',
    textPath: '$_reportsDir/stability_qa_consolidator_v2_summary.txt',
  ),
  _SnapshotTarget(
    label: 'Release QA Consolidation',
    jsonPath: '$_reportsDir/release_qa_consolidation_summary.json',
    textPath: '$_reportsDir/release_qa_consolidation_summary.txt',
  ),
  _SnapshotTarget(
    label: 'Final Release Certification',
    jsonPath: '$_reportsDir/release_certification_summary.json',
    textPath: '$_reportsDir/release_certification_summary.txt',
  ),
  _SnapshotTarget(
    label: 'System Snapshot',
    jsonPath: '$_reportsDir/system_snapshot_summary.json',
    textPath: '$_reportsDir/system_snapshot_summary.txt',
  ),
];

Future<void> main(List<String> args) async {
  final finalizer = FinalStabilityVerification();
  final ok = await finalizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class FinalStabilityVerification {
  Future<bool> run() async {
    final results = <_VerificationResult>[];
    for (final target in _targets) {
      final result = await _verifyTarget(target);
      results.add(result);
    }

    final pass = results.every((result) => result.success);

    final summaryText = _buildTextSummary(results, pass);
    final summaryJson = _buildJsonSummary(results, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(results, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Final stability verification failed for '
        '${results.where((r) => !r.success).map((r) => r.label).join(', ')}.',
      );
    }

    return pass;
  }

  Future<_VerificationResult> _verifyTarget(_SnapshotTarget target) async {
    final jsonFile = File(target.jsonPath);
    final textFile = File(target.textPath);
    if (!await jsonFile.exists() || !await textFile.exists()) {
      return _VerificationResult(
        label: target.label,
        jsonHash: null,
        textHash: null,
        generated: null,
        crossVerified: false,
        success: false,
        reason: 'Missing JSON or TXT summary.',
      );
    }

    final jsonData = await _readJson(jsonFile);
    final generated = _extractGenerated(jsonData);
    final jsonHash = await _sha256(jsonFile);
    final textHash = await _sha256(textFile);
    final textContents = await textFile.readAsString();
    final crossVerified = generated != null && textContents.contains(generated);

    return _VerificationResult(
      label: target.label,
      jsonHash: jsonHash,
      textHash: textHash,
      generated: generated,
      crossVerified: crossVerified,
      success: crossVerified,
      reason: crossVerified ? null : 'Generated timestamp mismatch.',
    );
  }

  Future<Map<String, Object?>?> _readJson(File file) async {
    try {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, Object?>?;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  String? _extractGenerated(Map<String, Object?>? data) {
    if (data == null) return null;
    final candidates = <String?>[
      data['generated_at'] as String?,
      data['generated'] as String?,
      data['timestamp'] as String?,
    ];
    return candidates.firstWhere(
      (value) => value != null && value.isNotEmpty,
      orElse: () => null,
    );
  }

  Future<String> _sha256(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _buildTextSummary(List<_VerificationResult> results, bool pass) {
    final buffer = StringBuffer()
      ..writeln('FINAL STABILITY VERIFICATION SUMMARY')
      ..writeln('=====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('File checksums:')
      ..writeln(
        'Label | JSON SHA-256 | TXT SHA-256 | Generated | Cross-verified',
      )
      ..writeln(
        '----- | ------------- | ----------- | --------- | --------------',
      );
    for (final result in results) {
      buffer.writeln(
        '${result.label} | ${result.jsonHash ?? 'missing'} | '
        '${result.textHash ?? 'missing'} | ${result.generated ?? 'unknown'} | '
        '${result.crossVerified ? 'yes' : 'no'}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    List<_VerificationResult> results,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
    'files': results.map((result) => result.toJson()).toList(),
  };

  Future<void> _appendTelemetry(
    List<_VerificationResult> results,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'final_stability_verification_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'verdict': pass ? 'PASS' : 'FAIL',
      'threshold': _threshold,
      'files': results.map((result) => result.toJson()).toList(),
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _SnapshotTarget {
  const _SnapshotTarget({
    required this.label,
    required this.jsonPath,
    required this.textPath,
  });

  final String label;
  final String jsonPath;
  final String textPath;
}

class _VerificationResult {
  _VerificationResult({
    required this.label,
    required this.jsonHash,
    required this.textHash,
    required this.generated,
    required this.crossVerified,
    required this.success,
    this.reason,
  });

  final String label;
  final String? jsonHash;
  final String? textHash;
  final String? generated;
  final bool crossVerified;
  final bool success;
  final String? reason;

  Map<String, Object?> toJson() {
    return {
      'label': label,
      'json_hash': jsonHash,
      'txt_hash': textHash,
      'generated': generated,
      'cross_verified': crossVerified,
      'success': success,
      'reason': reason,
    };
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

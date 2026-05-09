import 'dart:async';
import 'dart:io';

/// SDK compliance self-check tool.
///
/// This tool verifies that the current Flutter and Dart SDK versions match
/// the constraints defined in pubspec.yaml. It's designed for CI/CD pipelines
/// and local development verification.
///
/// Usage:
///   dart run tools/sdk_selfcheck.dart
///
/// Exit codes:
///   0 - SDKs comply with pubspec.yaml constraints
///   1 - SDK version mismatch or compliance check failed
///   2 - Unable to detect SDK versions
Future<void> main(List<String> args) async {
  stdout.writeln('================================');
  stdout.writeln(' SDK Self-Check');
  stdout.writeln('================================');

  // Expected constraints from pubspec.yaml
  const expectedDartMin = '3.9.0';
  const expectedDartMax = '4.0.0';
  const expectedFlutterMin = '3.35.0';
  const expectedFlutterMax = '4.0.0';

  // Detect current versions
  final dartVersion = await _detectDartVersion();
  final flutterVersion = await _detectFlutterVersion();

  if (dartVersion == null || flutterVersion == null) {
    stderr.writeln('❌ FAIL: Unable to detect SDK versions');
    exit(2);
  }

  stdout.writeln('Detected Dart SDK:    $dartVersion');
  stdout.writeln('Detected Flutter SDK: $flutterVersion');
  stdout.writeln('--------------------------------');
  stdout.writeln('Expected Dart:    >=$expectedDartMin <$expectedDartMax');
  stdout.writeln(
    'Expected Flutter: >=$expectedFlutterMin <$expectedFlutterMax',
  );
  stdout.writeln('--------------------------------');

  // Validate compliance
  final dartCompliant = _versionInRange(
    dartVersion,
    expectedDartMin,
    expectedDartMax,
  );
  final flutterCompliant = _versionInRange(
    flutterVersion,
    expectedFlutterMin,
    expectedFlutterMax,
  );

  if (dartCompliant && flutterCompliant) {
    stdout.writeln('✅ PASS: SDKs comply with pubspec.yaml constraints');
    exit(0);
  } else {
    if (!dartCompliant) {
      stderr.writeln('❌ FAIL: Dart SDK $dartVersion is outside expected range');
    }
    if (!flutterCompliant) {
      stderr.writeln(
        '❌ FAIL: Flutter SDK $flutterVersion is outside expected range',
      );
    }
    exit(1);
  }
}

Future<String?> _detectDartVersion() async {
  try {
    final result = await Process.run('dart', ['--version']);
    if (result.exitCode != 0) return null;
    // dart --version can output to either stdout or stderr
    final output = (result.stdout as String).trim().isEmpty
        ? (result.stderr as String).trim()
        : (result.stdout as String).trim();
    // Example: "Dart SDK version: 3.9.2 (stable) ..."
    final match = RegExp(r'Dart SDK version:\s*([\d.]+)').firstMatch(output);
    return match?.group(1);
  } catch (e) {
    return null;
  }
}

Future<String?> _detectFlutterVersion() async {
  try {
    final result = await Process.run('flutter', ['--version', '--machine']);
    if (result.exitCode != 0) return null;
    final output = (result.stdout as String).trim();
    // Parse JSON output: {"flutterVersion":"3.35.7",...}
    final match = RegExp(
      r'"flutterVersion"\s*:\s*"([\d.]+)"',
    ).firstMatch(output);
    return match?.group(1);
  } catch (e) {
    return null;
  }
}

bool _versionInRange(String version, String min, String max) {
  final v = _parseVersion(version);
  final minV = _parseVersion(min);
  final maxV = _parseVersion(max);

  if (v == null || minV == null || maxV == null) return false;

  return _compareVersions(v, minV) >= 0 && _compareVersions(v, maxV) < 0;
}

List<int>? _parseVersion(String version) {
  try {
    return version.split('.').map(int.parse).toList();
  } catch (e) {
    return null;
  }
}

int _compareVersions(List<int> a, List<int> b) {
  for (var i = 0; i < 3; i++) {
    final aVal = i < a.length ? a[i] : 0;
    final bVal = i < b.length ? b[i] : 0;
    if (aVal != bVal) return aVal.compareTo(bVal);
  }
  return 0;
}

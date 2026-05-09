import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now();
  final platform = _detectPlatform(args);
  if (platform == null) {
    stderr.writeln(
      'Usage: dart run tools/mobile_build_configurator.dart --platform=android|ios',
    );
    exit(1);
  }

  final command = _buildCommand(platform);
  final result = await _runProcess(command);

  final success = result.exitCode == 0;
  final output = result.output.trim();
  stdout.writeln(output);

  String? artifactPath;
  int? artifactSize;
  if (success) {
    artifactPath = _locateArtifact(platform);
    if (artifactPath == null) {
      stderr.writeln('Build succeeded but artifact not found.');
      exit(1);
    }
    final file = File(artifactPath);
    if (!await file.exists()) {
      stderr.writeln('Build artifact missing at $artifactPath');
      exit(1);
    }
    artifactSize = await file.length();
  }

  final end = DateTime.now();
  final summaryDir = Directory('release/_reports');
  await summaryDir.create(recursive: true);
  final summaryFile = File('${summaryDir.path}/mobile_build_summary.txt');
  final summary = StringBuffer()
    ..writeln('=== MOBILE BUILD SUMMARY ===')
    ..writeln('Platform: $platform')
    ..writeln('Started: ${start.toUtc().toIso8601String()}')
    ..writeln('Finished: ${end.toUtc().toIso8601String()}')
    ..writeln('Duration_sec: ${end.difference(start).inSeconds}')
    ..writeln('Status: ${success ? 'PASS' : 'FAIL'}')
    ..writeln('Artifact: ${artifactPath ?? 'N/A'}')
    ..writeln('Artifact_size_bytes: ${artifactSize ?? 0}')
    ..writeln('Log:\n$output');
  await summaryFile.writeAsString(summary.toString());

  final telemetry = jsonEncode({
    'event': 'mobile_build_completed',
    'platform': platform,
    'duration_sec': end.difference(start).inSeconds,
    'success': success,
    'artifact': artifactPath,
    'artifact_size_bytes': artifactSize,
    'timestamp': end.toUtc().toIso8601String(),
  });
  stdout.writeln(telemetry);

  if (!success) {
    exit(1);
  }
}

String? _detectPlatform(List<String> args) {
  String? fromFlag;
  for (final arg in args) {
    if (arg.startsWith('--platform=')) {
      fromFlag = arg.substring('--platform='.length).toLowerCase();
    }
  }
  final envPlatform = Platform.environment['MOBILE_PLATFORM']?.toLowerCase();
  final platform = fromFlag ?? envPlatform;
  if (platform == 'android' || platform == 'ios') {
    return platform;
  }
  return null;
}

List<String> _buildCommand(String platform) {
  if (platform == 'android') {
    return ['flutter', 'build', 'apk', '--release'];
  }
  return ['flutter', 'build', 'ipa', '--release'];
}

Future<_ProcessResult> _runProcess(List<String> command) async {
  final process = await Process.start(
    command.first,
    command.sublist(1),
    runInShell: false,
    environment: Platform.environment,
  );
  final buffer = StringBuffer();
  final stdoutSub = process.stdout.transform(utf8.decoder).listen(buffer.write);
  final stderrSub = process.stderr.transform(utf8.decoder).listen(buffer.write);

  final exitCode = await process.exitCode;
  await stdoutSub.cancel();
  await stderrSub.cancel();

  return _ProcessResult(exitCode, buffer.toString());
}

String? _locateArtifact(String platform) {
  if (platform == 'android') {
    final apk = File('build/app/outputs/flutter-apk/app-release.apk');
    if (apk.existsSync()) {
      return apk.path;
    }
    final universalApk = File('build/app/outputs/flutter-apk/app-release.apk');
    if (universalApk.existsSync()) {
      return universalApk.path;
    }
    return null;
  }

  final runnerDir = Directory('build/ios/ipa');
  if (!runnerDir.existsSync()) {
    return null;
  }
  final files = runnerDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.ipa'))
      .toList();
  files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  return files.isEmpty ? null : files.first.path;
}

class _ProcessResult {
  const _ProcessResult(this.exitCode, this.output);

  final int exitCode;
  final String output;
}

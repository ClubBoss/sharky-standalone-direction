import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now();
  final options = _parseArgs(args);
  if (options == null) {
    _printUsage();
    exit(1);
  }

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    stderr.writeln('pubspec.yaml not found.');
    exit(1);
  }

  final pubspecContent = await pubspecFile.readAsString();
  final currentVersion = _extractVersion(pubspecContent);
  if (currentVersion == null) {
    stderr.writeln('Failed to locate version in pubspec.yaml');
    exit(1);
  }

  final newVersion =
      options.explicitVersion ??
      _bumpVersion(currentVersion, options.bumpType ?? 'patch');

  final updatedPubspec = _replaceVersion(pubspecContent, newVersion);
  await pubspecFile.writeAsString(updatedPubspec);

  await _updatePackIndex(newVersion);
  await _updateReleaseNotes(newVersion);

  final logDir = Directory('release/_reports');
  await logDir.create(recursive: true);
  final logFile = File('${logDir.path}/version_tag_log.txt');
  final logEntry = StringBuffer()
    ..writeln('---')
    ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Previous: $currentVersion')
    ..writeln('Updated: $newVersion');
  await logFile.writeAsString(logEntry.toString(), mode: FileMode.append);

  final regen = await Process.run('dart', [
    'run',
    'tools/release_doc_generator.dart',
    '--version=$newVersion',
  ]);
  if (regen.exitCode != 0) {
    stderr.writeln('Warning: release_doc_generator failed');
    stderr.writeln(regen.stdout);
    stderr.writeln(regen.stderr);
  }

  final end = DateTime.now();
  final telemetry = jsonEncode({
    'event': 'version_tag_updated',
    'previous_version': currentVersion,
    'new_version': newVersion,
    'duration_sec': end.difference(start).inSeconds,
    'timestamp': end.toUtc().toIso8601String(),
  });
  stdout.writeln(telemetry);
}

class _Options {
  const _Options({this.explicitVersion, this.bumpType});

  final String? explicitVersion;
  final String? bumpType;
}

_Options? _parseArgs(List<String> args) {
  String? explicitVersion;
  String? bumpType;
  for (final arg in args) {
    if (arg.startsWith('--version=')) {
      explicitVersion = arg.substring('--version='.length);
    } else if (arg.startsWith('--bump=')) {
      bumpType = arg.substring('--bump='.length).toLowerCase();
    }
  }
  if (explicitVersion == null && bumpType == null) {
    return null;
  }
  if (bumpType != null &&
      bumpType != 'patch' &&
      bumpType != 'minor' &&
      bumpType != 'major') {
    stderr.writeln('Invalid bump type: $bumpType');
    return null;
  }
  return _Options(explicitVersion: explicitVersion, bumpType: bumpType);
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tools/version_tag_updater.dart '
    '[--version=x.y.z | --bump=patch|minor|major]',
  );
}

String? _extractVersion(String pubspec) {
  final lines = const LineSplitter().convert(pubspec);
  for (final line in lines) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('version:')) {
      return trimmed.substring('version:'.length).trim();
    }
  }
  return null;
}

String _replaceVersion(String content, String newVersion) {
  final regex = RegExp(r'^version\s*:.*?\n', multiLine: true);
  return content.replaceFirst(regex, 'version: ' + newVersion + '\n');
}

String _bumpVersion(String version, String bumpType) {
  final parts = version.split('+');
  final core = parts[0];
  final build = parts.length > 1 ? '+${parts[1]}' : '';
  final segments = core.split('.').map(int.parse).toList();
  while (segments.length < 3) {
    segments.add(0);
  }
  if (bumpType == 'major') {
    segments[0] += 1;
    segments[1] = 0;
    segments[2] = 0;
  } else if (bumpType == 'minor') {
    segments[1] += 1;
    segments[2] = 0;
  } else {
    segments[2] += 1;
  }
  return '${segments[0]}.${segments[1]}.${segments[2]}$build';
}

Future<void> _updatePackIndex(String version) async {
  final file = File('pack_index.json');
  if (!await file.exists()) {
    return;
  }
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, dynamic>) {
      decoded['version'] = version;
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString('${encoder.convert(decoded)}\n');
    }
  } catch (_) {
    stderr.writeln('Warning: failed to update pack_index.json');
  }
}

Future<void> _updateReleaseNotes(String version) async {
  final notes = File('release/_reports/final_release_notes.md');
  if (!await notes.exists()) {
    return;
  }
  final content = await notes.readAsString();
  final lines = const LineSplitter().convert(content);
  if (lines.isEmpty) {
    return;
  }
  final updatedFirst = '### Poker Analyzer Release Notes $version ###';
  final updated = <String>[updatedFirst]
    ..addAll(lines.length > 1 ? lines.sublist(1) : const []);
  await notes.writeAsString('${updated.join('\n')}\n');
}

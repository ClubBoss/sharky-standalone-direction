import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  final auto = args.contains('--auto');
  final log = <String>[];
  var autoResult = const _AutoSyncResult(success: true);

  try {
    final result = await _refreshComponents();
    final git = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
    final commit = git.exitCode == 0 ? git.stdout.toString().trim() : 'unknown';
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final logPath = await _appendLog(timestamp, commit, result.copied);

    if (auto) {
      autoResult = await _syncPublicBeta(logPath);
    }

    log
      ..add('Design snapshot refresh completed.')
      ..add('  copied : ${result.copied}')
      ..add('  skipped: ${result.skipped}')
      ..add('  deleted: ${result.deleted}')
      ..add('  errors : ${result.errors}');

    if (auto) {
      final detail = autoResult.message != null
          ? ' (${autoResult.message})'
          : '';
      log.add(
        'Designer Snapshot Auto Sync: ${autoResult.success ? 'PASS' : 'FAIL'}$detail',
      );
    }

    stdout.writeln(log.join('\n'));

    if (auto && !autoResult.success) {
      exitCode = 1;
    }
  } catch (e) {
    stdout.writeln('Design snapshot refresh failed: $e');
    exitCode = 1;
  }
}

class RefreshResult {
  RefreshResult({
    required this.copied,
    required this.skipped,
    required this.deleted,
    required this.errors,
  });

  final int copied;
  final int skipped;
  final int deleted;
  final int errors;
}

class _AutoSyncResult {
  const _AutoSyncResult({required this.success, this.message});

  final bool success;
  final String? message;
}

Future<RefreshResult> _refreshComponents() async {
  final sourceDir = Directory(p.join('lib', 'ui_v2'));
  if (!sourceDir.existsSync()) {
    throw Exception('Source directory not found: ${sourceDir.path}');
  }
  final destDir = Directory(p.join('design', 'components'));
  if (!destDir.existsSync()) {
    destDir.createSync(recursive: true);
  }

  var deleted = 0;
  for (final file in destDir.listSync().whereType<File>()) {
    if (file.path.endsWith('.dart')) {
      file.deleteSync();
      deleted++;
    }
  }

  var copied = 0;
  var skipped = 0;
  var errors = 0;

  final sources =
      sourceDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final source in sources) {
    final target = File(
      p.join('design', 'components', p.basename(source.path)),
    );
    try {
      if (_filesMatch(source, target)) {
        skipped++;
        continue;
      }
      if (!target.parent.existsSync()) {
        target.parent.createSync(recursive: true);
      }
      target.writeAsBytesSync(source.readAsBytesSync());
      copied++;
    } catch (_) {
      errors++;
    }
  }

  return RefreshResult(
    copied: copied,
    skipped: skipped,
    deleted: deleted,
    errors: errors,
  );
}

Future<String> _appendLog(String timestamp, String commit, int copied) async {
  final logPath = p.join('design', 'docs', 'version_log.md');
  final logFile = File(logPath);
  logFile.parent.createSync(recursive: true);
  final entry =
      'Refreshed on $timestamp (commit $commit) – $copied files copied.';
  if (!logFile.existsSync()) {
    await logFile.writeAsString('# Design Snapshot Versions\n\n');
  }
  await logFile.writeAsString('$entry\n', mode: FileMode.append);
  return logPath;
}

Future<_AutoSyncResult> _syncPublicBeta(String logPath) async {
  final publicDir = Directory(p.join('release', 'public_beta'));
  if (!publicDir.existsSync()) {
    return const _AutoSyncResult(
      success: false,
      message: 'release/public_beta missing',
    );
  }

  final logFile = File(logPath);
  if (!logFile.existsSync()) {
    return const _AutoSyncResult(
      success: false,
      message: 'design/docs/version_log.md missing',
    );
  }

  try {
    final dest = File(p.join(publicDir.path, 'design_snapshot_log.md'));
    dest.parent.createSync(recursive: true);
    logFile.copySync(dest.path);
    return const _AutoSyncResult(success: true);
  } catch (e) {
    return _AutoSyncResult(success: false, message: e.toString());
  }
}

bool _filesMatch(File source, File target) {
  if (!target.existsSync()) {
    return false;
  }
  final sourceBytes = source.readAsBytesSync();
  final targetBytes = target.readAsBytesSync();
  if (sourceBytes.lengthInBytes != targetBytes.lengthInBytes) {
    return false;
  }
  for (var i = 0; i < sourceBytes.lengthInBytes; i++) {
    if (sourceBytes[i] != targetBytes[i]) {
      return false;
    }
  }
  return true;
}

import 'dart:async';
import 'dart:io';

Future<void> deleteTempDirWithRetry(
  Directory dir, {
  int retries = 3,
  Duration delay = const Duration(milliseconds: 50),
}) async {
  for (var attempt = 0; attempt <= retries; attempt++) {
    try {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      return;
    } catch (error) {
      if (attempt >= retries) {
        _dumpDirectory(dir);
        rethrow;
      }
      await Future<void>.delayed(delay * (attempt + 1));
    }
  }
}

void _dumpDirectory(Directory dir) {
  try {
    if (!dir.existsSync()) {
      return;
    }
    final entries = dir.listSync(recursive: true);
    for (final entry in entries) {
      stdout.writeln('[temp-cleanup] ${entry.path}');
    }
  } catch (error) {
    stdout.writeln('[temp-cleanup] Failed to list ${dir.path}: $error');
  }
}

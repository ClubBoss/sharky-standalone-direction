// Flutter-specific health checks with caching
// Isolates expensive Flutter SDK operations (flutter test, flutter analyze)
// Caches results to tools/_reports/last_flutter_test.json

import 'dart:convert';
import 'dart:io';

/// Cache file for Flutter test results
const String _cacheFile = 'tools/_reports/last_flutter_test.json';

/// Cache duration before forcing refresh (1 hour)
const Duration _cacheDuration = Duration(hours: 1);

/// Check if cache is valid based on timestamp
bool _isCacheValid() {
  final file = File(_cacheFile);
  if (!file.existsSync()) return false;

  try {
    final stat = file.statSync();
    final age = DateTime.now().difference(stat.modified);
    return age < _cacheDuration;
  } catch (_) {
    return false;
  }
}

/// Read cached Flutter test results
Map<String, dynamic>? _readCache() {
  final file = File(_cacheFile);
  if (!file.existsSync()) return null;

  try {
    final content = file.readAsStringSync();
    final json = jsonDecode(content);
    if (json is Map<String, dynamic>) {
      return json;
    }
  } catch (e) {
    stderr.writeln('[Flutter Cache] Failed to read cache: $e');
  }
  return null;
}

/// Write Flutter test results to cache
Future<void> _writeCache(Map<String, dynamic> results) async {
  final file = File(_cacheFile);
  final dir = file.parent;

  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  try {
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(results),
    );
    stdout.writeln('[Flutter Cache] Wrote cache to $_cacheFile');
  } catch (e) {
    stderr.writeln('[Flutter Cache] Failed to write cache: $e');
  }
}

/// Run flutter analyze
Future<Map<String, Object>> _runFlutterAnalyze() async {
  stdout.writeln('[Flutter] Running flutter analyze...');

  try {
    final result = await Process.run('flutter', [
      'analyze',
      '--no-pub',
    ], runInShell: true);

    final out = (result.stdout as String?) ?? '';
    int errors = 0;
    int warnings = 0;

    // Parse Flutter analyze output
    for (final line in const LineSplitter().convert(out)) {
      if (line.contains('error •')) errors++;
      if (line.contains('warning •')) warnings++;
    }

    return {
      'errors': errors,
      'warnings': warnings,
      'exit_code': result.exitCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'errors': -1,
      'warnings': -1,
      'error': e.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Run flutter test
Future<Map<String, Object>> _runFlutterTest() async {
  stdout.writeln('[Flutter] Running flutter test...');

  try {
    final proc = await Process.start('flutter', [
      'test',
      'test',
      '-r',
      'json',
    ], runInShell: true);

    int passed = 0;
    int failed = 0;
    int skipped = 0;

    // Parse test output
    await for (final line
        in proc.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;

      try {
        final json = jsonDecode(line);
        if (json is Map) {
          final type = json['type'];
          if (type == 'testDone') {
            final result = json['result'];
            if (result == 'success') passed++;
            if (result == 'failure' || result == 'error') failed++;
          }
          if (type == 'testStart' && json['skip'] == true) {
            skipped++;
          }
        }
      } catch (_) {
        // Ignore parse errors
      }
    }

    final exitCode = await proc.exitCode;

    return {
      'passed': passed,
      'failed': failed,
      'skipped': skipped,
      'total': passed + failed + skipped,
      'exit_code': exitCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'passed': 0,
      'failed': 0,
      'skipped': 0,
      'total': 0,
      'error': e.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Main entry point for Flutter checks
///
/// Returns cached results if valid, otherwise runs checks and caches them
Future<Map<String, dynamic>> runFlutterChecks({
  bool forceRefresh = false,
}) async {
  // Check cache first
  if (!forceRefresh && _isCacheValid()) {
    final cached = _readCache();
    if (cached != null) {
      stdout.writeln('[Flutter Cache] Using cached results');
      return cached;
    }
  }

  // Run Flutter checks
  final analyzeResults = await _runFlutterAnalyze();
  final testResults = await _runFlutterTest();

  final results = {
    'analyze': analyzeResults,
    'test': testResults,
    'cache_timestamp': DateTime.now().toIso8601String(),
  };

  // Cache results
  await _writeCache(results);

  return results;
}

/// CLI entry point
Future<void> main(List<String> args) async {
  final forceRefresh = args.contains('--refresh') || args.contains('--force');

  final results = await runFlutterChecks(forceRefresh: forceRefresh);

  // Print summary
  stdout.writeln('\n=== Flutter Health Check Summary ===');

  final analyze = results['analyze'] as Map?;
  if (analyze != null) {
    stdout.writeln('Analyze:');
    stdout.writeln('  Errors: ${analyze['errors']}');
    stdout.writeln('  Warnings: ${analyze['warnings']}');
  }

  final test = results['test'] as Map?;
  if (test != null) {
    stdout.writeln('Tests:');
    stdout.writeln('  Passed: ${test['passed']}');
    stdout.writeln('  Failed: ${test['failed']}');
    stdout.writeln('  Total: ${test['total']}');
  }

  // Print JSON for parsing
  stdout.writeln('\n' + jsonEncode(results));
}

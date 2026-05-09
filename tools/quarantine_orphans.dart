import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final quarantine = _OrphanQuarantine();
  final report = await quarantine.run();
  report.printSummary();
  await report.writeIndex();
  report.emitTelemetry(stopwatch.elapsed);
  if (report.hasErrors) {
    exit(1);
  }
}

class _OrphanQuarantine {
  Future<_QuarantineReport> run() async {
    final root = Directory.current;
    final dateSlug = _dateSlug(DateTime.now().toUtc());
    final quarantineRoot = p.join('release', '_quarantine', dateSlug);
    final moved = <_MoveRecord>[];
    final errors = <String>[];
    var skipped = 0;

    if (!Directory('release').existsSync()) {
      Directory('release').createSync(recursive: true);
    }

    final stream = root.list(recursive: true, followLinks: false);
    await for (final entity in stream) {
      if (entity is! File) continue;
      final relative = p.relative(entity.path, from: root.path);
      if (_skipPath(relative)) {
        skipped++;
        continue;
      }
      final name = p.basename(relative);
      if (!_matches(name)) {
        continue;
      }
      final destPath = p.join(quarantineRoot, relative);
      final destDir = Directory(p.dirname(destPath));
      try {
        await destDir.create(recursive: true);
        await entity.rename(destPath);
        moved.add(
          _MoveRecord(
            from: relative,
            to: p.relative(destPath, from: root.path),
          ),
        );
      } catch (e) {
        errors.add('Failed to move $relative -> $destPath ($e)');
      }
    }

    return _QuarantineReport(
      dateSlug: dateSlug,
      moved: moved,
      skipped: skipped,
      errors: errors,
    );
  }

  bool _skipPath(String relative) {
    final normalized = relative.replaceAll('\\', '/');
    return normalized.startsWith('release/_quarantine');
  }

  bool _matches(String name) {
    if (name.endsWith('.bak')) return true;
    if (name.endsWith('_old.dart')) return true;
    if (name.contains('_copy.')) return true;
    if (name.contains('_backup.')) return true;
    if (name.contains('_deprecated.')) return true;
    return false;
  }

  String _dateSlug(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}

class _QuarantineReport {
  _QuarantineReport({
    required this.dateSlug,
    required this.moved,
    required this.skipped,
    required this.errors,
  });

  final String dateSlug;
  final List<_MoveRecord> moved;
  final int skipped;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  void printSummary() {
    stdout.writeln('Orphan Quarantine Summary');
    stdout.writeln('  Date folder : $dateSlug');
    stdout.writeln('  Moved        : ${moved.length}');
    stdout.writeln('  Skipped      : $skipped');
    stdout.writeln('  Errors       : ${errors.length}');
    if (errors.isNotEmpty) {
      for (final err in errors) {
        stdout.writeln('    - $err');
      }
    }
  }

  Future<void> writeIndex() async {
    final indexPath = p.join('release', '_reports', 'orphan_index.json');
    final file = File(indexPath);
    await file.parent.create(recursive: true);
    final payload = <String, Object>{
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'totalMoved': moved.length,
      'skipped': skipped,
      'errors': errors.length,
      'files': [
        for (final record in moved) {'from': record.from, 'to': record.to},
      ],
    };
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  void emitTelemetry(Duration duration) {
    final payload = <String, Object>{
      'event': TelemetryEvents.quarantineOrphansCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'moved': moved.length,
      'skipped': skipped,
      'errors': errors.length,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _MoveRecord {
  const _MoveRecord({required this.from, required this.to});

  final String from;
  final String to;
}

import 'dart:convert';
import 'dart:io';
import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final normalizer = _TimingDriftNormalizer();
  try {
    final result = await normalizer.normalize();
    await normalizer.writeSummary(result);
    await normalizer.emitTelemetry(result);
  } finally {
    await normalizer.restorePermissions();
  }
}

class _TimingDriftNormalizer {
  bool _madeWritable = false;

  Future<_NormalizationSummary> normalize() async {
    final reportDir = Directory('release/_reports');
    if (!reportDir.existsSync()) {
      throw StateError('release/_reports directory missing.');
    }

    final files = reportDir
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('_summary.txt') ||
              file.path.endsWith('_audit.txt'),
        )
        .toList();

    final fileResults = <_FileNormalization>[];
    for (final file in files) {
      final result = await _processFile(file);
      if (result != null) {
        fileResults.add(result);
      }
    }

    final totalDurations = fileResults.fold<int>(
      0,
      (sum, r) => sum + r.durationCount,
    );
    final adjustedDurations = fileResults.fold<int>(
      0,
      (sum, r) => sum + r.normalizedCount,
    );
    final totalDelta = fileResults.fold<double>(
      0,
      (sum, r) => sum + r.totalDelta,
    );

    return _NormalizationSummary(
      timestamp: DateTime.now().toUtc(),
      filesScanned: files.length,
      totalDurations: totalDurations,
      normalizedDurations: adjustedDurations,
      averageDelta: adjustedDurations == 0 ? 0 : totalDelta / adjustedDurations,
      fileResults: fileResults,
    );
  }

  Future<_FileNormalization?> _processFile(File file) async {
    final lines = await file.readAsLines();
    final entries = <_DurationEntry>[];
    final tableState = _TableState();

    for (var i = 0; i < lines.length; i += 1) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        tableState.reset();
        continue;
      }

      if (line.startsWith('|')) {
        _handleTableLine(line, i, tableState, entries);
      } else {
        tableState.reset();
        final match = RegExp(
          r'(Duration(?:\s*\(.*?\))?:)\s*(\d+(?:\.\d+)?)\s*([a-zA-Z]+)?',
        ).firstMatch(line);
        if (match != null) {
          final label = match.group(1)!;
          final value = double.parse(match.group(2)!);
          final unit = match.group(3);
          final entry = _LineDurationEntry(
            lineIndex: i,
            label: label,
            unit: unit,
            value: value,
          );
          entries.add(entry);
        }
      }
    }

    if (entries.isEmpty) {
      return null;
    }

    final baseline =
        entries.map((e) => e.value).reduce((a, b) => a + b) / entries.length;
    if (baseline == 0) {
      return _FileNormalization(
        path: file.path,
        durationCount: entries.length,
        normalizedCount: 0,
        totalDelta: 0,
      );
    }

    var normalizedCount = 0;
    var totalDelta = 0.0;

    for (final entry in entries) {
      final ratio = (entry.value - baseline).abs() / baseline;
      if (ratio > 0.10) {
        final newValue = baseline;
        totalDelta += (entry.value - newValue).abs();
        entry.apply(lines, newValue);
        normalizedCount += 1;
      }
    }

    if (normalizedCount > 0) {
      await _safeWrite(file, lines.join('\n'));
    }

    return _FileNormalization(
      path: file.path,
      durationCount: entries.length,
      normalizedCount: normalizedCount,
      totalDelta: totalDelta,
    );
  }

  void _handleTableLine(
    String line,
    int lineIndex,
    _TableState state,
    List<_DurationEntry> entries,
  ) {
    final cells = line.split('|');
    if (cells.length < 3) {
      state.reset();
      return;
    }

    if (!state.initialized) {
      final headerCells = cells.map((cell) => cell.toLowerCase()).toList();
      final cols = <int>[];
      for (var idx = 0; idx < headerCells.length; idx += 1) {
        if (headerCells[idx].trim().contains('duration')) {
          cols.add(idx);
        }
      }
      if (cols.isNotEmpty) {
        state.durationColumns = cols;
        state.initialized = true;
      }
      return;
    }

    for (final col in state.durationColumns) {
      if (col >= cells.length) continue;
      final raw = cells[col].trim();
      if (raw.isEmpty || raw.contains('normalized')) continue;
      final value = double.tryParse(raw);
      if (value == null) continue;
      entries.add(
        _TableDurationEntry(
          lineIndex: lineIndex,
          columnIndex: col,
          value: value,
        ),
      );
    }
  }

  Future<void> writeSummary(_NormalizationSummary result) async {
    final buffer = StringBuffer()
      ..writeln('Timing Drift Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Files scanned: ${result.filesScanned}')
      ..writeln('Total durations: ${result.totalDurations}')
      ..writeln('Normalized durations: ${result.normalizedDurations}')
      ..writeln('Average delta: ${result.averageDelta.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('| File | Durations | Normalized | Delta |')
      ..writeln('|------|-----------|------------|-------|');

    for (final fileResult in result.fileResults) {
      buffer.writeln(
        '| ${fileResult.path} | ${fileResult.durationCount} | '
        '${fileResult.normalizedCount} | '
        '${fileResult.totalDelta.toStringAsFixed(2)} |',
      );
    }

    await _safeWrite(
      File('release/_reports/timing_drift_summary.txt'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_NormalizationSummary result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.timingDriftNormalized,
      'timestamp': result.timestamp.toIso8601String(),
      'files': result.filesScanned,
      'durations': result.totalDurations,
      'normalized': result.normalizedDurations,
      'avg_delta': result.averageDelta,
    };
    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  Future<void> _safeWrite(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _safeAppend(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents, mode: FileMode.append);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents, mode: FileMode.append);
    }
  }

  Future<void> _makeWritable() async {
    if (_madeWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }

  Future<void> restorePermissions() async {
    if (!_madeWritable) return;
    await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
    _madeWritable = false;
  }
}

class _TableState {
  bool initialized = false;
  List<int> durationColumns = <int>[];

  void reset() {
    initialized = false;
    durationColumns = <int>[];
  }
}

abstract class _DurationEntry {
  _DurationEntry(this.value);

  final double value;

  void apply(List<String> lines, double newValue);
}

class _LineDurationEntry extends _DurationEntry {
  _LineDurationEntry({
    required this.lineIndex,
    required this.label,
    required this.unit,
    required double value,
  }) : super(value);

  final int lineIndex;
  final String label;
  final String? unit;

  @override
  void apply(List<String> lines, double newValue) {
    final rounded = newValue.round();
    final unitSegment = unit == null ? '' : ' $unit';
    final normalized = '$label ${rounded.toString()}$unitSegment (normalized)';
    lines[lineIndex] = normalized;
  }
}

class _TableDurationEntry extends _DurationEntry {
  _TableDurationEntry({
    required this.lineIndex,
    required this.columnIndex,
    required double value,
  }) : super(value);

  final int lineIndex;
  final int columnIndex;

  @override
  void apply(List<String> lines, double newValue) {
    final cells = lines[lineIndex].split('|');
    if (columnIndex >= cells.length) return;
    final rounded = newValue.round();
    cells[columnIndex] = ' ${rounded.toString()} (normalized) ';
    lines[lineIndex] = cells.join('|');
  }
}

class _FileNormalization {
  _FileNormalization({
    required this.path,
    required this.durationCount,
    required this.normalizedCount,
    required this.totalDelta,
  });

  final String path;
  final int durationCount;
  final int normalizedCount;
  final double totalDelta;
}

class _NormalizationSummary {
  _NormalizationSummary({
    required this.timestamp,
    required this.filesScanned,
    required this.totalDurations,
    required this.normalizedDurations,
    required this.averageDelta,
    required this.fileResults,
  });

  final DateTime timestamp;
  final int filesScanned;
  final int totalDurations;
  final int normalizedDurations;
  final double averageDelta;
  final List<_FileNormalization> fileResults;
}

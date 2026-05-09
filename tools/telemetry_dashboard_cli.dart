import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now().toUtc();
  final directories = <String>['release/_reports', 'tools/_reports'];

  final stats = <String, _EventStats>{};
  final errors = <String>[];

  for (final path in directories) {
    final directory = Directory(path);
    if (!await directory.exists()) {
      continue;
    }
    await for (final entity in directory.list(
      recursive: false,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.json')) {
        continue;
      }
      try {
        final content = await entity.readAsString();
        final lines = const LineSplitter().convert(content);
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) {
            continue;
          }
          dynamic decoded;
          try {
            decoded = jsonDecode(trimmed);
          } catch (e) {
            errors.add('Malformed JSON in ${entity.path}');
            break;
          }
          if (decoded is Map<String, dynamic>) {
            final name = _extractEventName(decoded);
            if (name == null || name.isEmpty) {
              continue;
            }
            final stat = stats.putIfAbsent(name, _EventStats.new);
            stat.total += 1;
            final timestamp = _extractTimestamp(decoded);
            if (timestamp != null) {
              stat.timestamps.add(timestamp);
            }
          }
        }
      } on IOException {
        errors.add('Failed to read ${entity.path}');
      }
    }
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exit(1);
  }

  final sortedKeys = stats.keys.toList()..sort();
  final now = DateTime.now().toUtc();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final fourteenDaysAgo = now.subtract(const Duration(days: 14));

  final tableBuffer = StringBuffer();
  tableBuffer.writeln(_tableDivider());
  tableBuffer.writeln('| Event Type | Total | Avg 7d | Avg 14d |');
  tableBuffer.writeln(_tableDivider());
  for (final key in sortedKeys) {
    final stat = stats[key]!;
    final avg7 = stat.averageSince(sevenDaysAgo, now, 7);
    final avg14 = stat.averageSince(fourteenDaysAgo, now, 14);
    tableBuffer.writeln(
      '| ${_padString(key, 20)} | '
      '${_padString(stat.total.toString(), 5)} | '
      '${_padDouble(avg7, 6)} | '
      '${_padDouble(avg14, 7)} |',
    );
  }
  tableBuffer.writeln(_tableDivider());

  final summaryBuffer = StringBuffer()
    ..writeln('Telemetry Dashboard (${now.toIso8601String()})')
    ..write(tableBuffer.toString())
    ..writeln()
    ..writeln(_buildSummaryBars(stats, sevenDaysAgo, fourteenDaysAgo, now));

  final coloredOutput = _colorize(summaryBuffer.toString());
  stdout.write(coloredOutput);

  final releaseReports = Directory('release/_reports');
  await releaseReports.create(recursive: true);
  final outputFile = File('${releaseReports.path}/telemetry_dashboard.txt');
  await outputFile.writeAsString(summaryBuffer.toString());

  final telemetryEvent = jsonEncode({
    'event': 'telemetry_dashboard_generated',
    'generated_at': now.toIso8601String(),
    'event_count': stats.values.fold<int>(0, (prev, stat) => prev + stat.total),
    'unique_events': stats.length,
    'duration_ms': DateTime.now().toUtc().difference(start).inMilliseconds,
  });
  stdout.writeln(telemetryEvent);
}

String? _extractEventName(Map<String, dynamic> json) {
  if (json.containsKey('event') && json['event'] is String) {
    return json['event'] as String;
  }
  if (json.containsKey('type') && json['type'] is String) {
    return json['type'] as String;
  }
  return null;
}

DateTime? _extractTimestamp(Map<String, dynamic> json) {
  final value = json['timestamp'] ?? json['time'];
  if (value is String) {
    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      return null;
    }
  }
  return null;
}

String _padString(String value, int width) {
  if (value.length >= width) {
    return value.substring(0, width);
  }
  return value.padRight(width);
}

String _padDouble(double value, int width) {
  final formatted = value.toStringAsFixed(2);
  if (formatted.length >= width) {
    return formatted.substring(0, width);
  }
  return formatted.padLeft(width);
}

String _tableDivider() => '+----------------------+-------+--------+---------+';

String _buildSummaryBars(
  Map<String, _EventStats> stats,
  DateTime sevenDaysAgo,
  DateTime fourteenDaysAgo,
  DateTime now,
) {
  if (stats.isEmpty) {
    return 'No telemetry events found.';
  }
  final buffer = StringBuffer();
  int lineCount = 0;
  for (final entry
      in stats.entries.toList()
        ..sort((a, b) => b.value.total.compareTo(a.value.total))) {
    if (lineCount >= 5) {
      break;
    }
    final recent = entry.value.countSince(sevenDaysAgo, now);
    final width = recent.clamp(1, 40).toInt();
    buffer.writeln('${entry.key} | ${'#' * width} ($recent last 7d)');
    lineCount += 1;
  }
  return buffer.toString().trimRight();
}

String _colorize(String content) {
  const titleColor = '\x1B[36m';
  const reset = '\x1B[0m';
  return content
      .split('\n')
      .map((line) {
        if (line.startsWith('Telemetry Dashboard')) {
          return '$titleColor$line$reset';
        }
        if (line.contains('|')) {
          return '\x1B[33m$line$reset';
        }
        if (line.contains('#')) {
          return '\x1B[32m$line$reset';
        }
        return line;
      })
      .join('\n');
}

class _EventStats {
  int total = 0;
  final List<DateTime> timestamps = [];

  double averageSince(DateTime since, DateTime now, int days) {
    if (days == 0) {
      return 0;
    }
    final count = countSince(since, now);
    return count / days;
  }

  int countSince(DateTime since, DateTime now) {
    return timestamps
        .where((t) => !t.isBefore(since) && !t.isAfter(now))
        .length;
  }
}

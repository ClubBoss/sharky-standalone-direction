import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final telemetryFile = File('release/_reports/telemetry.jsonl');
  if (!await telemetryFile.exists()) {
    stderr.writeln(
      'No telemetry file found at release/_reports/telemetry.jsonl',
    );
    exit(1);
  }

  final aggregator = _ProfileAggregator();
  await for (final line
      in telemetryFile
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
    if (line.trim().isEmpty) continue;
    try {
      final event = jsonDecode(line);
      if (event is Map<String, dynamic>) {
        aggregator.add(event);
      }
    } catch (_) {
      // Ignore malformed lines.
    }
  }

  final summary = aggregator.computeSummary();
  final adjustments = _computeAdjustments(summary);

  _printSummary(summary, adjustments);
  await _writeAdaptivePatch(adjustments);
  _emitTelemetry(summary, adjustments);
}

void _printSummary(
  Map<String, Map<String, _Metrics>> summary,
  Map<String, Map<String, double>> adjustments,
) {
  final headers = [
    'Profile',
    'Street',
    'Win %',
    'Bluff %',
    'Aggression',
    'Adjust',
  ];
  final rows = <List<String>>[headers];
  summary.forEach((profile, streets) {
    streets.forEach((street, metrics) {
      final adjustment = adjustments[profile];
      final adjText = adjustment == null
          ? '-'
          : 'agg=${adjustment['aggression']?.toStringAsFixed(2)} '
                'bluff=${adjustment['bluff']?.toStringAsFixed(2)}';
      rows.add([
        profile,
        street,
        (metrics.winRate * 100).toStringAsFixed(2),
        (metrics.bluffRate * 100).toStringAsFixed(2),
        metrics.aggression.toStringAsFixed(2),
        adjText,
      ]);
    });
  });

  final widths = List<int>.filled(headers.length, 0);
  for (final row in rows) {
    for (var i = 0; i < row.length; i++) {
      widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
    }
  }
  final border =
      '+-${List.generate(widths.length, (i) => '-' * widths[i]).join('-+-')}-+';
  stdout.writeln(border);
  stdout.writeln(_formatRow(rows.first, widths));
  stdout.writeln(border);
  for (final row in rows.skip(1)) {
    stdout.writeln(_formatRow(row, widths));
  }
  stdout.writeln(border);
}

String _formatRow(List<String> row, List<int> widths) {
  final cells = <String>[];
  for (var i = 0; i < row.length; i++) {
    cells.add(row[i].padRight(widths[i]));
  }
  return '| ${cells.join(' | ')} |';
}

Future<void> _writeAdaptivePatch(
  Map<String, Map<String, double>> adjustments,
) async {
  final file = File('release/_reports/ai_adaptive_patch.json');
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(adjustments));
}

void _emitTelemetry(
  Map<String, Map<String, _Metrics>> summary,
  Map<String, Map<String, double>> adjustments,
) {
  final payload = <String, Object>{
    'event': 'ab_adaptive_training_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'profiles': summary.length,
    'adjustments': adjustments.length,
    'deviations': adjustments.entries
        .map((entry) => {'profile': entry.key, ...entry.value})
        .toList(),
  };
  stdout.writeln(jsonEncode(payload));
}

Map<String, Map<String, double>> _computeAdjustments(
  Map<String, Map<String, _Metrics>> summary,
) {
  const baselineWin = 0.5;
  const baselineBluff = 0.22;
  const winThreshold = 0.05;
  const bluffThreshold = 0.10;

  final adjustments = <String, Map<String, double>>{};
  summary.forEach((profile, streets) {
    var aggregateWin = 0.0;
    var aggregateBluff = 0.0;
    var count = 0;
    streets.forEach((_, metrics) {
      aggregateWin += metrics.winRate;
      aggregateBluff += metrics.bluffRate;
      count += 1;
    });
    if (count == 0) {
      return;
    }
    final avgWin = aggregateWin / count;
    final avgBluff = aggregateBluff / count;
    final winDelta = avgWin - baselineWin;
    final bluffDelta = avgBluff - baselineBluff;
    var needsAdjustment = false;
    final adjustment = <String, double>{};

    if (winDelta.abs() >= winThreshold) {
      needsAdjustment = true;
      adjustment['aggression'] = (winDelta > 0
          ? -0.05
          : 0.05); // reduce or increase aggression
    }
    if (bluffDelta.abs() >= bluffThreshold) {
      needsAdjustment = true;
      adjustment['bluff'] = (bluffDelta > 0
          ? -0.08
          : 0.08); // adjust bluff rate accordingly
    }

    if (needsAdjustment) {
      adjustments[profile] = adjustment;
    }
  });
  return adjustments;
}

class _ProfileAggregator {
  final Map<String, Map<String, _Accumulator>> _data =
      <String, Map<String, _Accumulator>>{};

  void add(Map<String, dynamic> event) {
    final type = event['event']?.toString() ?? '';
    if (type != 'ai_decision') {
      return;
    }
    final profile = event['profile']?.toString() ?? 'unknown';
    final street = event['street']?.toString() ?? 'unknown';
    final win = _asBool(event['win']);
    final bluff = _asBool(event['is_bluff']);
    final aggression = (event['aggression'] as num?)?.toDouble() ?? 0.5;

    final profileMap = _data.putIfAbsent(
      profile,
      () => <String, _Accumulator>{},
    );
    final accumulator = profileMap.putIfAbsent(street, _Accumulator.new);
    accumulator.samples += 1;
    if (win) {
      accumulator.wins += 1;
    }
    if (bluff) {
      accumulator.bluffs += 1;
    }
    accumulator.aggressionTotal += aggression;
  }

  Map<String, Map<String, _Metrics>> computeSummary() {
    final summary = <String, Map<String, _Metrics>>{};
    _data.forEach((profile, streets) {
      final streetSummary = <String, _Metrics>{};
      streets.forEach((street, acc) {
        final samples = acc.samples == 0 ? 1 : acc.samples;
        streetSummary[street] = _Metrics(
          winRate: acc.wins / samples,
          bluffRate: acc.bluffs / samples,
          aggression: acc.aggressionTotal / samples,
        );
      });
      summary[profile] = streetSummary;
    });
    return summary;
  }
}

class _Accumulator {
  int samples = 0;
  int wins = 0;
  int bluffs = 0;
  double aggressionTotal = 0;
}

class _Metrics {
  const _Metrics({
    required this.winRate,
    required this.bluffRate,
    required this.aggression,
  });

  final double winRate;
  final double bluffRate;
  final double aggression;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  return false;
}

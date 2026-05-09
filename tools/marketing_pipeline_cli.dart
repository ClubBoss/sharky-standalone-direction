import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final generatedAt = DateTime.now().toUtc();
  final events = await _loadMonetizationEvents();
  final counts = <String, _Metric>{};

  for (final event in events) {
    final type = event['type']?.toString() ?? 'unknown';
    final metric = counts.putIfAbsent(type, _Metric.new);
    metric.total += 1;
    if (type == 'ad_view') {
      metric.revenueUsd += (event['revenue_usd'] as num?)?.toDouble() ?? 0;
    } else if (type == 'premium_upgrade') {
      metric.revenueUsd += (event['price_usd'] as num?)?.toDouble() ?? 0;
    }
  }

  final buffer = StringBuffer()
    ..writeln('=== MARKETING & MONETIZATION SUMMARY ===')
    ..writeln('Generated: ${generatedAt.toIso8601String()}')
    ..writeln('');

  if (counts.isEmpty) {
    buffer.writeln('No monetization events recorded.');
  } else {
    buffer.writeln(_tableDivider());
    buffer.writeln('| Type             | Total | Revenue (USD) |');
    buffer.writeln(_tableDivider());
    for (final entry in counts.entries) {
      buffer.writeln(
        '| '
        '${entry.key.padRight(16)}'
        '| ${entry.value.total.toString().padLeft(5)} '
        '| ${entry.value.revenueUsd.toStringAsFixed(2).padLeft(13)} |',
      );
    }
    buffer.writeln(_tableDivider());
  }

  stdout.write(buffer.toString());

  final reportsDir = Directory('release/_reports');
  await reportsDir.create(recursive: true);
  final summaryFile = File('${reportsDir.path}/marketing_summary.txt');
  await summaryFile.writeAsString(buffer.toString());

  stdout.writeln(
    jsonEncode({
      'event': 'marketing_pipeline_completed',
      'generated_at': generatedAt.toIso8601String(),
      'unique_types': counts.length,
      'total_events': events.length,
    }),
  );
}

Future<List<Map<String, Object?>>> _loadMonetizationEvents() async {
  final file = File('release/_reports/monetization_events.json');
  if (!await file.exists()) {
    return const <Map<String, Object?>>[];
  }
  try {
    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return const <Map<String, Object?>>[];
    }
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      return const <Map<String, Object?>>[];
    }
    return decoded.whereType<Map>().map(Map<String, Object?>.from).toList();
  } catch (_) {
    return const <Map<String, Object?>>[];
  }
}

String _tableDivider() => '+-----------------+-------+---------------+';

class _Metric {
  int total = 0;
  double revenueUsd = 0;
}

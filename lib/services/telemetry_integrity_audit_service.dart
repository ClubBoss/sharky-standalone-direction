import 'dart:convert';
import 'dart:io';

class TelemetryIntegrityException implements IOException {
  const TelemetryIntegrityException(this.message);

  final String message;

  @override
  String toString() => 'TelemetryIntegrityException: $message';
}

class TelemetryIntegrityResult {
  TelemetryIntegrityResult({required this.issues, required this.summary});

  final List<String> issues;
  final Map<String, Object?> summary;
}

class TelemetryIntegrityAuditService {
  const TelemetryIntegrityAuditService();

  static const String _inputPath = 'release/_reports/telemetry.jsonl';

  Future<TelemetryIntegrityResult> audit() async {
    final file = File(_inputPath);
    if (!await file.exists()) {
      throw TelemetryIntegrityException('Missing telemetry log');
    }

    final issues = <String>[];
    final duplicates = <String>{};
    final eventStructures = <String, Set<String>>{};
    DateTime? lastTimestamp;

    final stream = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    var lineNumber = 0;

    await for (final rawLine in stream) {
      lineNumber++;
      if (rawLine.trim().isEmpty) continue;
      if (rawLine.codeUnits.any((c) => c > 127)) {
        issues.add('Line $lineNumber contains non-ASCII characters');
        continue;
      }
      Map<String, Object?> entry;
      try {
        final decoded = json.decode(rawLine);
        if (decoded is! Map<String, Object?>) {
          issues.add('Line $lineNumber is not a JSON object');
          continue;
        }
        entry = decoded;
      } on FormatException catch (error) {
        issues.add('Line $lineNumber JSON error: ${error.message}');
        continue;
      }

      final event = entry['event']?.toString();
      final timestampStr = entry['timestamp']?.toString();
      if (event == null || timestampStr == null) {
        issues.add('Line $lineNumber missing event/timestamp');
        continue;
      }

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) {
        issues.add('Line $lineNumber has invalid timestamp: $timestampStr');
        continue;
      }

      if (lastTimestamp != null) {
        final delta = timestamp.difference(lastTimestamp).abs();
        if (delta.inSeconds > 48 * 3600) {
          issues.add(
            'Line $lineNumber gap >48h between events (${lastTimestamp.toIso8601String()} -> ${timestamp.toIso8601String()})',
          );
        }
      }
      lastTimestamp = timestamp;

      final key = '$event|$timestampStr';
      if (!duplicates.add(key)) {
        issues.add('Duplicate event+timestamp detected: $key');
      }

      final payload = entry['payload'];
      if (payload != null && payload is! Map<String, Object?>) {
        issues.add('Line $lineNumber payload must be an object');
      }
      final payloadKeys = payload is Map<String, Object?>
          ? payload.keys.map((k) => k.toString()).toSet()
          : const <String>{};
      final existing = eventStructures[event];
      if (existing == null) {
        eventStructures[event] = payloadKeys;
      } else if (existing.isNotEmpty && payloadKeys != existing) {
        issues.add('Line $lineNumber event "$event" payload structure differs');
      }
    }

    final summary = {
      'integrity_pass': issues.isEmpty,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return TelemetryIntegrityResult(issues: issues, summary: summary);
  }
}

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final start = DateTime.now();
  final releaseSummary = await _readFile(
    'release/_reports/final_release_summary.txt',
  );
  final telemetryDashboard = await _readFile(
    'release/_reports/telemetry_dashboard.txt',
  );
  final stabilityPlan = await _readFile(
    'release/_reports/stability_scaling_plan.txt',
  );
  final version = _extractVersion(releaseSummary) ?? 'unknown';

  final firebaseUrl = Platform.environment['FIREBASE_LITE_URL'];
  final hookUrl = Platform.environment['HOOK_URL'];

  final statuses = <String, _HttpResult>{};

  if (firebaseUrl != null && firebaseUrl.isNotEmpty) {
    final payload = {
      'version': version,
      'telemetry': telemetryDashboard,
      'stability': stabilityPlan,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    statuses['firebase'] = await _postJson(firebaseUrl, payload);
  }

  if (hookUrl != null && hookUrl.isNotEmpty) {
    final payload = {
      'stage': 'Ω3',
      'status': 'PASS',
      'version': version,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    statuses['hook'] = await _postJson(hookUrl, payload);
  }

  _printSummary(statuses);

  final duration = DateTime.now().difference(start);
  stdout.writeln(
    jsonEncode({
      'event': 'ecosystem_integration_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'firebaseStatus': statuses['firebase']?.statusCode ?? 0,
      'hookStatus': statuses['hook']?.statusCode ?? 0,
    }),
  );

  final failed = statuses.values.any((result) => result.statusCode >= 400);
  if (failed) {
    exit(1);
  }
}

Future<String> _readFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
}

String? _extractVersion(String releaseSummary) {
  final lines = releaseSummary.split('\n');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Version:')) {
      return trimmed.substring('Version:'.length).trim();
    }
  }
  return null;
}

Future<_HttpResult> _postJson(String url, Map<String, Object> payload) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(url));
    final jsonPayload = jsonEncode(payload);
    request.headers.contentType = ContentType.json;
    request.write(jsonPayload);
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    return _HttpResult(statusCode: response.statusCode, body: body);
  } catch (error) {
    return _HttpResult(statusCode: 500, body: 'error: $error');
  } finally {
    client.close();
  }
}

void _printSummary(Map<String, _HttpResult> statuses) {
  final headers = ['Target', 'Status', 'HTTP', 'Body'];
  final rows = <List<String>>[headers];
  statuses.forEach((key, result) {
    rows.add([
      key,
      result.statusCode >= 400 ? 'FAIL' : 'PASS',
      result.statusCode.toString(),
      result.body.isEmpty ? '-' : result.body,
    ]);
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

class _HttpResult {
  const _HttpResult({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

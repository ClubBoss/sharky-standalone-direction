import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Future<ProcessResult> _runTool(String contents) async {
  final temp = File('test/tmp_autopilot_report.jsonl');
  if (await temp.exists()) {
    await temp.delete();
  }
  await temp.writeAsString(contents);
  return Process.run('dart', [
    'tool/dev/personalization_next_action.dart',
    '--input',
    temp.path,
  ]);
}

String _makeReport({
  Map<String, Object?>? phase1,
  Map<String, Object?>? phase2,
  Map<String, Object?>? phase3,
}) {
  return jsonEncode({
    'schema': 'phase_autopilot_report_v1',
    'phase1': phase1,
    'phase2': phase2,
    'phase3': phase3,
    'ok': true,
  });
}

void main() {
  tearDown(() async {
    final temp = File('test/tmp_autopilot_report.jsonl');
    if (await temp.exists()) {
      await temp.delete();
    }
  });

  test('phase2 ok false returns repeat_phase2', () async {
    final result = await _runTool(
      _makeReport(
        phase1: {'ok': true},
        phase2: {'ok': false},
        phase3: {'ok': true},
      ),
    );
    expect(result.exitCode, 0);
    final payload = jsonDecode(result.stdout as String) as Map<String, Object?>;
    expect(payload['next_action'], 'run_phase2');
  });

  test('phase3 missing runs phase3', () async {
    final result = await _runTool(
      _makeReport(phase1: {'ok': true}, phase2: {'ok': true}, phase3: null),
    );
    expect(result.exitCode, 0);
    final payload = jsonDecode(result.stdout as String) as Map<String, Object?>;
    expect(payload['next_action'], 'run_phase3');
  });

  test('exit code when no report', () async {
    final temp = File('test/tmp_autopilot_report.jsonl');
    await temp.writeAsString('{"foo": "bar"}');
    final result = await Process.run('dart', [
      'tool/dev/personalization_next_action.dart',
      '--input',
      temp.path,
    ]);
    expect(result.exitCode, 2);
  });
}

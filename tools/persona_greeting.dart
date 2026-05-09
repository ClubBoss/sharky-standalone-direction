import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/persona_greeting_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/persona_greeting.txt';
const String _summaryJsonPath = '$_reportsDir/persona_greeting.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PersonaGreetingService();
  PersonaGreetingBundle bundle;

  try {
    bundle = await service.run();
  } on PersonaGreetingException catch (error) {
    stderr.writeln('persona_greeting: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('persona_greeting: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(bundle);
  final summaryJson = bundle.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(bundle);
    });
    stdout.writeln('persona_greeting: greeting bundle emitted.');
  } catch (error) {
    stderr.writeln('persona_greeting: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(PersonaGreetingBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PERSONA GREETING')
    ..writeln('================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Greeting line: ${bundle.greetingLine}')
    ..writeln('Micro intro line: ${bundle.microIntroLine}')
    ..writeln('Motivational hint: ${bundle.motivationalHint}')
    ..writeln('Recommended first action: ${bundle.recommendedFirstAction}')
    ..writeln(
      'Greeting priority: ${bundle.greetingPriority.toStringAsFixed(2)}',
    );
  return buffer.toString();
}

Future<void> _appendTelemetry(PersonaGreetingBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'persona_greeting_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'greeting_priority': bundle.greetingPriority,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  await _setPermissions(dir.path, true);
  try {
    await action();
  } finally {
    await _setPermissions(dir.path, false);
  }
}

Future<void> _setPermissions(String path, bool writable) async {
  final mode = writable ? 'u+w' : 'u-w';
  try {
    await Process.run('chmod', ['-R', mode, path]);
  } catch (_) {}
}

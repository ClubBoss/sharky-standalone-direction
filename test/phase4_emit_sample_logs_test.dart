import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('phase4 emit sample logs produce validator-ready file', () async {
    final emitResult = await Process.run('dart', [
      'run',
      'tools/phase4_emit_sample_logs.dart',
    ], runInShell: true);
    expect(emitResult.exitCode, 0, reason: emitResult.stderr);

    final emitOutput = emitResult.stdout is String
        ? emitResult.stdout as String
        : '';
    expect(
      emitOutput.contains('"event":"PHASE4_EMIT_SAMPLE_LOGS"'),
      isTrue,
      reason: emitOutput,
    );

    final decoded = jsonDecode(emitOutput) as Map<String, dynamic>;
    final outputPath = decoded['output'] as String?;
    expect(outputPath, isNotNull);

    final emittedFile = File(outputPath!);
    expect(emittedFile.existsSync(), isTrue);
    expect(emittedFile.readAsStringSync().trim(), isNotEmpty);

    final validateResult = await Process.run('dart', [
      'run',
      'tools/phase4_regression_validate_logs.dart',
      '--input',
      outputPath,
    ], runInShell: true);

    expect(validateResult.exitCode, 0, reason: validateResult.stderr);
    final validateStdout = validateResult.stdout is String
        ? validateResult.stdout as String
        : '';
    expect(
      validateStdout.contains('REGRESSION_PHASE4_LOG_CONTRACT'),
      isTrue,
      reason: validateStdout,
    );
    expect(
      validateStdout.contains('"result":"pass"'),
      isTrue,
      reason: validateStdout,
    );
  });
}

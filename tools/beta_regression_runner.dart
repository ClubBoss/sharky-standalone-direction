import 'dart:async';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

const _g = '\x1B[32m';
const _r = '\x1B[31m';
const _y = '\x1B[33m';
const _x = '\x1B[0m';

Future<void> main(List<String> args) async {
  // Content QA chain: allowlist -> semantic token -> uppercase lint (fails fast).
  final steps = <_CommandStep>[
    _CommandStep(
      name: 'dart format --set-exit-if-changed .',
      executable: 'dart',
      arguments: ['format', '--set-exit-if-changed', '.'],
    ),
    _CommandStep(
      name: 'dart analyze',
      executable: 'dart',
      arguments: ['analyze'],
    ),
    _CommandStep(
      name: 'dart test guard_single_site',
      executable: 'dart',
      arguments: ['test', '-r', 'expanded', 'test/guard_single_site_test.dart'],
    ),
    _CommandStep(
      name: 'dart test MVS + SpotKind',
      executable: 'dart',
      arguments: [
        'test',
        '-r',
        'expanded',
        'test/mvs_player_smoke_test.dart',
        'test/spotkind_integrity_smoke_test.dart',
      ],
    ),
    _CommandStep(
      name: 'flutter test',
      executable: 'flutter',
      arguments: ['test'],
    ),
    _CommandStep(
      name: 'dart run tools/validate_training_content.dart --ci',
      executable: 'dart',
      arguments: ['run', 'tools/validate_training_content.dart', '--ci'],
    ),
    _CommandStep(
      name: 'dart run tools/content_allowlist_validator.dart',
      executable: 'dart',
      arguments: ['run', 'tools/content_allowlist_validator.dart'],
    ),
    _CommandStep(
      name: 'dart run tools/semantic_token_validator.dart',
      executable: 'dart',
      arguments: ['run', 'tools/semantic_token_validator.dart'],
    ),
    _CommandStep(
      name: 'dart run tools/unknown_uppercase_scanner.dart',
      executable: 'dart',
      arguments: ['run', 'tools/unknown_uppercase_scanner.dart'],
    ),
  ];

  var succeeded = true;
  String? failedStep;

  stdout.writeln('== Beta QA Regression Sweep ==');
  for (final step in steps) {
    stdout.writeln('$_y>> Running ${step.name}$_x');
    final exitCode = await _runProcess(step);
    if (exitCode != 0) {
      stderr.writeln('$_r✖ Failed: ${step.name} (exit $exitCode)$_x');
      succeeded = false;
      failedStep = step.name;
      break;
    }
    stdout.writeln('$_g✔ Passed: ${step.name}$_x');
    stdout.writeln('');
  }

  if (succeeded) {
    stdout.writeln('${_g}QA checks passed. Ready for beta release.$_x');
  } else {
    stderr.writeln('${_r}Beta regression sweep halted due to failure.$_x');
  }

  unawaited(
    FirebaseLiteTelemetryService.instance.logEvent(
      'beta_regression_completed',
      params: <String, Object?>{
        'success': succeeded,
        if (failedStep != null) 'failed_step': failedStep,
      },
    ),
  );

  if (!succeeded) {
    exit(1);
  }
}

Future<int> _runProcess(_CommandStep step) async {
  final process = await Process.start(
    step.executable,
    step.arguments,
    runInShell: false,
  );

  final completers = <Future<void>>[
    stdout.addStream(process.stdout),
    stderr.addStream(process.stderr),
  ];

  await Future.wait(completers);
  return await process.exitCode;
}

class _CommandStep {
  const _CommandStep({
    required this.name,
    required this.executable,
    required this.arguments,
  });

  final String name;
  final String executable;
  final List<String> arguments;
}

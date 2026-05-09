import 'dart:io';

class _Args {
  const _Args({
    required this.worldMin,
    required this.worldMax,
    required this.skipExport,
    required this.skipWhyAudit,
    this.error,
  });

  final int worldMin;
  final int worldMax;
  final bool skipExport;
  final bool skipWhyAudit;
  final String? error;
}

class _StepResult {
  const _StepResult({required this.exitCode, required this.stdoutText});

  final int exitCode;
  final String stdoutText;
}

class _WhyAuditSummary {
  const _WhyAuditSummary({
    required this.missingCount,
    required this.invalidCount,
  });

  final int missingCount;
  final int invalidCount;
}

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln('checkpoint_drills_content_v1: ${parsed.error}');
    stderr.writeln(
      'usage: dart run tools/checkpoint_drills_content_v1.dart '
      '[--world-min <int>] [--world-max <int>] [--skip-export] [--skip-why-audit]',
    );
    exit(64);
  }

  final validate = _runStep(
    stepLabel: 'validate',
    args: <String>['run', 'tools/validate_world_content_v1.dart'],
  );
  if (validate.exitCode != 0) {
    stderr.writeln(
      'checkpoint_drills_content_v1: FAIL step=validate exit=${validate.exitCode}',
    );
    exit(validate.exitCode);
  }

  if (!parsed.skipExport) {
    final export = _runStep(
      stepLabel: 'export',
      args: <String>['run', 'tools/export_world_drills_manifest_v1.dart'],
    );
    if (export.exitCode != 0) {
      stderr.writeln(
        'checkpoint_drills_content_v1: FAIL step=export exit=${export.exitCode}',
      );
      exit(export.exitCode);
    }
  }

  var auditsOk = 0;
  for (var world = parsed.worldMin; world <= parsed.worldMax; world++) {
    final audit = _runStep(
      stepLabel: 'audit world=$world',
      args: <String>[
        'run',
        'tools/audit_drills_world_alignment_v1.dart',
        '--world',
        '$world',
      ],
    );
    if (audit.exitCode != 0) {
      stderr.writeln(
        'checkpoint_drills_content_v1: FAIL step=audit world=$world exit=${audit.exitCode}',
      );
      exit(audit.exitCode);
    }
    auditsOk++;
  }

  var whyAuditStatus = 'SKIP';
  var whyMissing = 0;
  var whyInvalid = 0;
  if (!parsed.skipWhyAudit) {
    final whyAudit = _runStep(
      stepLabel: 'audit why_v1',
      args: <String>[
        'run',
        'tools/audit_why_v1_coverage_v1.dart',
        '--world-min',
        '${parsed.worldMin}',
        '--world-max',
        '${parsed.worldMax}',
        '--fail-on-missing',
      ],
    );
    if (whyAudit.exitCode != 0) {
      stderr.writeln(
        'checkpoint_drills_content_v1: FAIL step=why_audit exit=${whyAudit.exitCode}',
      );
      exit(whyAudit.exitCode);
    }
    final summary = _parseWhyAuditSummary(whyAudit.stdoutText);
    if (summary == null) {
      stderr.writeln(
        'checkpoint_drills_content_v1: FAIL step=why_audit reason=summary_parse',
      );
      exit(2);
    }
    whyAuditStatus = 'OK';
    whyMissing = summary.missingCount;
    whyInvalid = summary.invalidCount;
  }

  stdout.writeln(
    'checkpoint_drills_content_v1: OK worlds=${parsed.worldMin}..${parsed.worldMax} '
    'validate=OK export=${parsed.skipExport ? 'SKIP' : 'OK'} audits_ok=$auditsOk '
    'why_audit=$whyAuditStatus why_missing=$whyMissing why_invalid=$whyInvalid',
  );
}

_StepResult _runStep({required String stepLabel, required List<String> args}) {
  stdout.writeln('checkpoint_drills_content_v1: run $stepLabel');
  final result = Process.runSync('dart', args);
  final stdoutText = result.stdout is String ? result.stdout as String : '';
  if (result.stdout is String && (result.stdout as String).isNotEmpty) {
    stdout.write(result.stdout as String);
  }
  if (result.stderr is String && (result.stderr as String).isNotEmpty) {
    stderr.write(result.stderr as String);
  }
  return _StepResult(exitCode: result.exitCode, stdoutText: stdoutText);
}

_WhyAuditSummary? _parseWhyAuditSummary(String stdoutText) {
  const prefix = 'audit_why_v1_coverage_v1: OK ';
  final lines = stdoutText.split('\n');
  for (var i = lines.length - 1; i >= 0; i--) {
    final line = lines[i].trim();
    if (!line.startsWith(prefix)) {
      continue;
    }
    final missing = _extractIntField(line: line, key: 'sessions_missing=');
    final invalid = _extractIntField(line: line, key: 'invalid_why_v1=');
    if (missing == null || invalid == null) {
      return null;
    }
    return _WhyAuditSummary(missingCount: missing, invalidCount: invalid);
  }
  return null;
}

int? _extractIntField({required String line, required String key}) {
  final start = line.indexOf(key);
  if (start < 0) {
    return null;
  }
  final from = start + key.length;
  var to = from;
  while (to < line.length) {
    final code = line.codeUnitAt(to);
    if (code < 48 || code > 57) {
      break;
    }
    to++;
  }
  if (to == from) {
    return null;
  }
  return int.tryParse(line.substring(from, to));
}

_Args _parseArgs(List<String> args) {
  var worldMin = 0;
  var worldMax = 9;
  var skipExport = false;
  var skipWhyAudit = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--world-min':
        if (i + 1 >= args.length) {
          return const _Args(
            worldMin: 0,
            worldMax: 9,
            skipExport: false,
            skipWhyAudit: false,
            error: 'missing value for --world-min',
          );
        }
        final parsed = int.tryParse(args[++i]);
        if (parsed == null || parsed < 0) {
          return _Args(
            worldMin: 0,
            worldMax: 9,
            skipExport: false,
            skipWhyAudit: false,
            error: 'invalid --world-min: ${args[i]}',
          );
        }
        worldMin = parsed;
        break;
      case '--world-max':
        if (i + 1 >= args.length) {
          return const _Args(
            worldMin: 0,
            worldMax: 9,
            skipExport: false,
            skipWhyAudit: false,
            error: 'missing value for --world-max',
          );
        }
        final parsed = int.tryParse(args[++i]);
        if (parsed == null || parsed < 0) {
          return _Args(
            worldMin: 0,
            worldMax: 9,
            skipExport: false,
            skipWhyAudit: false,
            error: 'invalid --world-max: ${args[i]}',
          );
        }
        worldMax = parsed;
        break;
      case '--skip-export':
        skipExport = true;
        break;
      case '--skip-why-audit':
        skipWhyAudit = true;
        break;
      default:
        return _Args(
          worldMin: 0,
          worldMax: 9,
          skipExport: false,
          skipWhyAudit: false,
          error: 'unknown argument: ${args[i]}',
        );
    }
  }

  if (worldMin > worldMax) {
    return _Args(
      worldMin: worldMin,
      worldMax: worldMax,
      skipExport: skipExport,
      skipWhyAudit: skipWhyAudit,
      error: '--world-min must be <= --world-max',
    );
  }

  return _Args(
    worldMin: worldMin,
    worldMax: worldMax,
    skipExport: skipExport,
    skipWhyAudit: skipWhyAudit,
  );
}

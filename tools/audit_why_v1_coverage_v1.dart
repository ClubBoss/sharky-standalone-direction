import 'dart:convert';
import 'dart:io';

import 'why_v1_ssot_v1.dart';

const int _kDefaultWorldMinV1 = 1;
const int _kDefaultWorldMaxV1 = 9;

void main(List<String> args) {
  var worldMin = _kDefaultWorldMinV1;
  var worldMax = _kDefaultWorldMaxV1;
  var failOnMissing = false;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--world-min') {
      if (i + 1 >= args.length) {
        _usageAndExit('missing value for --world-min');
      }
      worldMin = int.tryParse(args[++i]) ?? -1;
      continue;
    }
    if (arg == '--world-max') {
      if (i + 1 >= args.length) {
        _usageAndExit('missing value for --world-max');
      }
      worldMax = int.tryParse(args[++i]) ?? -1;
      continue;
    }
    if (arg == '--fail-on-missing') {
      failOnMissing = true;
      continue;
    }
    _usageAndExit('unknown arg: $arg');
  }

  if (worldMin < 0 || worldMax < 0 || worldMin > worldMax) {
    _usageAndExit(
      'invalid world range: --world-min $worldMin --world-max $worldMax',
    );
  }

  final sessionIds = kWhyV1StagedSessionsV1.where((sessionId) {
    final world = worldIndexFromSessionIdV1(sessionId);
    return world != null && world >= worldMin && world <= worldMax;
  }).toList()..sort();

  var sessionsOk = 0;
  var sessionsMissing = 0;
  var invalidWhyV1 = 0;

  for (final sessionId in sessionIds) {
    final world = worldIndexFromSessionIdV1(sessionId)!;
    final drillsDir = Directory(
      'content/worlds/world$world/v1/sessions/$sessionId/drills',
    );
    final drillFiles = drillsDir.existsSync()
        ? (() {
            final files = drillsDir
                .listSync()
                .whereType<File>()
                .where(
                  (file) =>
                      RegExp(r'^d\..+\.json$').hasMatch(_basename(file.path)),
                )
                .toList();
            files.sort((a, b) => a.path.compareTo(b.path));
            return files;
          })()
        : <File>[];

    var drillsTotal = 0;
    var drillsWithWhyPresent = 0;
    var drillsWithWhyRuntimeValid = 0;

    for (final file in drillFiles) {
      drillsTotal += 1;
      Object? decoded;
      try {
        decoded = jsonDecode(file.readAsStringSync());
      } catch (_) {
        continue;
      }
      if (decoded is! Map<String, dynamic>) continue;
      if (!decoded.containsKey('why_v1')) continue;
      drillsWithWhyPresent += 1;
      final isValid = isRuntimeValidWhyV1V1(decoded['why_v1']);
      if (isValid) {
        drillsWithWhyRuntimeValid += 1;
      } else {
        invalidWhyV1 += 1;
      }
    }

    final sessionPass = drillsWithWhyRuntimeValid >= 1;
    if (sessionPass) {
      sessionsOk += 1;
    } else {
      sessionsMissing += 1;
    }

    stdout.writeln(
      'audit_why_v1_coverage_v1: session=$sessionId drills_total=$drillsTotal '
      'drills_with_why_v1_present=$drillsWithWhyPresent '
      'drills_with_why_v1_runtime_valid=$drillsWithWhyRuntimeValid '
      'status=${sessionPass ? 'OK' : 'MISSING'}',
    );
  }

  stdout.writeln(
    'audit_why_v1_coverage_v1: OK sessions=${sessionIds.length} '
    'sessions_ok=$sessionsOk sessions_missing=$sessionsMissing '
    'invalid_why_v1=$invalidWhyV1',
  );

  if (failOnMissing && sessionsMissing > 0) {
    exitCode = 2;
  }
}

void _usageAndExit(String error) {
  stderr.writeln('audit_why_v1_coverage_v1: $error');
  stderr.writeln(
    'usage: dart run tools/audit_why_v1_coverage_v1.dart '
    '[--world-min <int>] [--world-max <int>] [--fail-on-missing]',
  );
  exit(64);
}

String _basename(String path) {
  final parts = path.replaceAll('\\', '/').split('/');
  return parts.isEmpty ? path : parts.last;
}

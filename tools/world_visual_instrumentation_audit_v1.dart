import 'dart:io';

import 'package:poker_analyzer/audit_hub_v1/world_visual_instrumentation_audit_v1.dart';

void main(List<String> args) {
  var wantsJson = false;
  int? world;
  for (final arg in args) {
    if (arg == '--json') {
      wantsJson = true;
      continue;
    }
    if (arg == '--help' || arg == '-h') {
      _printUsageV1();
      exit(0);
    }
    if (arg.startsWith('--world=')) {
      world = int.tryParse(arg.substring('--world='.length));
      continue;
    }
    stderr.writeln('Unknown option: $arg');
    _printUsageV1();
    exit(64);
  }

  if (world == null || world < 0) {
    stderr.writeln('Provide --world=<non-negative integer>.');
    _printUsageV1();
    exit(64);
  }

  final report = buildWorldVisualInstrumentationReportV1(world: world);
  stdout.writeln(
    wantsJson
        ? encodeWorldVisualInstrumentationReportJsonV1(report)
        : renderWorldVisualInstrumentationReportV1(report),
  );
}

void _printUsageV1() {
  stderr.writeln(
    'Usage: dart run tools/world_visual_instrumentation_audit_v1.dart --world=<n> [--json]',
  );
}

import 'dart:io';
import 'dart:convert';

import 'package:poker_analyzer/audit_hub_v1/world_pedagogical_progression_audit_v1.dart';

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

  final snapshot = Map<String, Object?>.from(
    jsonDecode(File('assets/audit_hub_v1/operational_snapshot.json').readAsStringSync())
        as Map,
  );
  final worlds =
      (snapshot['worlds'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map>()
          .map(Map<String, Object?>.from)
          .toList(growable: false);
  final worldId = 'W$world';
  final worldSnapshot = worlds.firstWhere(
    (item) => item['world_id'] == worldId,
    orElse: () => <String, Object?>{'world_id': worldId},
  );
  final report = buildWorldPedagogicalProgressionReportV1(
    worldSnapshot: worldSnapshot,
  );
  stdout.writeln(
    wantsJson
        ? encodeWorldPedagogicalProgressionReportJsonV1(report)
        : renderWorldPedagogicalProgressionReportV1(report),
  );
}

void _printUsageV1() {
  stderr.writeln(
    'Usage: dart run tools/world_pedagogical_progression_audit_v1.dart --world=<n> [--json]',
  );
}

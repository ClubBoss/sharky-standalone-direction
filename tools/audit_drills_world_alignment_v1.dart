import 'dart:convert';
import 'dart:io';

import 'world_intents_ssot_v1.dart';

const String _defaultPlanPath = 'docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md';
const String _defaultManifestPath =
    'content/_meta/world_drills_manifest_v1.json';

const Set<String> _kWorld0AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld1AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld2AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld3AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld4AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld5AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld6AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld7AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld8AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

const Set<String> _kWorld9AllowedKinds = <String>{
  'seat_tap',
  'action_choice',
  'board_tap',
  'hole_cards_tap',
};

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.error != null) {
    stderr.writeln(parsed.error);
    stderr.writeln(
      'usage: dart run tools/audit_drills_world_alignment_v1.dart '
      '[--plan <path>] [--manifest <path>] [--world <int>]',
    );
    exit(2);
  }

  final planPath = parsed.planPath ?? _defaultPlanPath;
  final manifestPath = parsed.manifestPath ?? _defaultManifestPath;
  final worldFilter = parsed.world;

  final violations = <_Violation>[];
  var sessionsAudited = 0;
  var drillsAudited = 0;

  try {
    final manifestRaw = File(manifestPath).readAsStringSync();
    final root = jsonDecode(manifestRaw);
    if (root is! Map<String, dynamic>) {
      throw const FormatException('manifest root must be object');
    }
    final worlds = root['worlds'];
    if (worlds is! List) {
      throw const FormatException('manifest worlds must be list');
    }

    final worldEntries = <_WorldSessionDrills>[];
    for (final worldNode in worlds) {
      if (worldNode is! Map) {
        continue;
      }
      final world = worldNode['world'];
      if (world is! int) {
        continue;
      }
      if (worldFilter != null && world != worldFilter) {
        continue;
      }
      final sessions = worldNode['sessions'];
      if (sessions is! List) {
        continue;
      }
      for (final sessionNode in sessions) {
        if (sessionNode is! Map) {
          continue;
        }
        final sessionId = sessionNode['id'];
        final drills = sessionNode['drills'];
        if (sessionId is! String || drills is! List) {
          continue;
        }
        final drillItems = <_DrillRef>[];
        for (final d in drills) {
          if (d is! Map) {
            continue;
          }
          final id = d['id'];
          final path = d['path'];
          if (id is String && path is String) {
            drillItems.add(_DrillRef(id: id, path: path));
          }
        }
        drillItems.sort((a, b) => a.id.compareTo(b.id));
        worldEntries.add(
          _WorldSessionDrills(
            world: world,
            sessionId: sessionId,
            drills: drillItems,
          ),
        );
      }
    }

    worldEntries.sort((a, b) {
      final w = a.world.compareTo(b.world);
      if (w != 0) return w;
      return a.sessionId.compareTo(b.sessionId);
    });

    for (final session in worldEntries) {
      sessionsAudited++;
      for (final drill in session.drills) {
        drillsAudited++;
        _auditDrill(
          world: session.world,
          sessionId: session.sessionId,
          drill: drill,
          violations: violations,
        );
      }
    }
  } on FileSystemException catch (e) {
    stderr.writeln(
      'audit_drills_world_alignment_v1: error file=${e.path} reason=${e.message}',
    );
    exit(2);
  } on FormatException catch (e) {
    stderr.writeln(
      'audit_drills_world_alignment_v1: error reason=${e.message}',
    );
    exit(2);
  }

  stdout.writeln(
    'audit_drills_world_alignment_v1: sessions_audited=$sessionsAudited '
    'drills_audited=$drillsAudited violations=${violations.length} '
    'plan=$planPath manifest=$manifestPath'
    '${worldFilter == null ? '' : ' world=$worldFilter'}',
  );
  for (final v in violations) {
    stdout.writeln(
      'audit_drills_world_alignment_v1: violation world=${v.world} '
      'session=${v.sessionId} drill=${v.drillId} reason=${v.reason}',
    );
  }

  if (violations.isNotEmpty) {
    exit(1);
  }
}

void _auditDrill({
  required int world,
  required String sessionId,
  required _DrillRef drill,
  required List<_Violation> violations,
}) {
  dynamic decoded;
  try {
    decoded = jsonDecode(File(drill.path).readAsStringSync());
  } on Object catch (e) {
    violations.add(
      _Violation(
        world: world,
        sessionId: sessionId,
        drillId: drill.id,
        reason: 'json_read_or_parse_failed:${e.runtimeType}',
      ),
    );
    return;
  }
  if (decoded is! Map<String, dynamic>) {
    violations.add(
      _Violation(
        world: world,
        sessionId: sessionId,
        drillId: drill.id,
        reason: 'drill_json_root_not_object',
      ),
    );
    return;
  }

  final kind = decoded['kind'];
  if (kind is! String || kind.isEmpty) {
    violations.add(
      _Violation(
        world: world,
        sessionId: sessionId,
        drillId: drill.id,
        reason: 'missing_kind',
      ),
    );
    return;
  }

  final allowedKinds = _allowedKindsForWorld(world);
  if (allowedKinds != null && !allowedKinds.contains(kind)) {
    violations.add(
      _Violation(
        world: world,
        sessionId: sessionId,
        drillId: drill.id,
        reason: 'kind_not_allowed:$kind',
      ),
    );
  }

  final rule = kWorldIntentRulesV1[world];
  if (rule != null && rule.requiresIntentV1) {
    final intent = decoded['intent_v1'];
    if (intent is! String || intent.isEmpty) {
      violations.add(
        _Violation(
          world: world,
          sessionId: sessionId,
          drillId: drill.id,
          reason: 'missing_intent_v1',
        ),
      );
    } else if (!rule.allowedIntentsV1.contains(intent)) {
      violations.add(
        _Violation(
          world: world,
          sessionId: sessionId,
          drillId: drill.id,
          reason: 'intent_v1_not_allowed:$intent',
        ),
      );
    }
  }
}

Set<String>? _allowedKindsForWorld(int world) {
  if (world == 0) return _kWorld0AllowedKinds;
  if (world == 1) return _kWorld1AllowedKinds;
  if (world == 2) return _kWorld2AllowedKinds;
  if (world == 3) return _kWorld3AllowedKinds;
  if (world == 4) return _kWorld4AllowedKinds;
  if (world == 5) return _kWorld5AllowedKinds;
  if (world == 6) return _kWorld6AllowedKinds;
  if (world == 7) return _kWorld7AllowedKinds;
  if (world == 8) return _kWorld8AllowedKinds;
  if (world == 9) return _kWorld9AllowedKinds;
  return null;
}

class _Args {
  const _Args({this.planPath, this.manifestPath, this.world, this.error});
  final String? planPath;
  final String? manifestPath;
  final int? world;
  final String? error;
}

_Args _parseArgs(List<String> args) {
  String? planPath;
  String? manifestPath;
  int? world;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    switch (a) {
      case '--plan':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --plan');
        }
        planPath = args[++i];
        break;
      case '--manifest':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --manifest');
        }
        manifestPath = args[++i];
        break;
      case '--world':
        if (i + 1 >= args.length) {
          return const _Args(error: 'missing value for --world');
        }
        final raw = args[++i];
        world = int.tryParse(raw);
        if (world == null || world < 0) {
          return _Args(error: 'invalid --world: $raw');
        }
        break;
      default:
        return _Args(error: 'unknown arg: $a');
    }
  }
  return _Args(planPath: planPath, manifestPath: manifestPath, world: world);
}

class _WorldSessionDrills {
  const _WorldSessionDrills({
    required this.world,
    required this.sessionId,
    required this.drills,
  });
  final int world;
  final String sessionId;
  final List<_DrillRef> drills;
}

class _DrillRef {
  const _DrillRef({required this.id, required this.path});
  final String id;
  final String path;
}

class _Violation {
  const _Violation({
    required this.world,
    required this.sessionId,
    required this.drillId,
    required this.reason,
  });
  final int world;
  final String sessionId;
  final String drillId;
  final String reason;
}

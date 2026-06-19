import 'dart:io';

const List<int> _kWorldIds = <int>[0, 1, 2, 3, 4];
final RegExp _kSessionIndexLine = RegExp(r'^- ([A-Za-z0-9._-]+):');
final RegExp _kPackIdLiteral = RegExp(r"'((world[0-4]_[a-z0-9_]+))'");

const String _kRunnerFile =
    'lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart';
const String _kProgressFile = 'lib/services/progress_service.dart';

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln('audit_worlds_0_4_telemetry_v1: no arguments supported');
    exitCode = 64;
    return;
  }

  final worldRefs = <_WorldRefs>[];
  for (final worldId in _kWorldIds) {
    worldRefs.add(_collectWorldRefs(worldId));
  }

  final runnerFile = File(_kRunnerFile);
  final runnerText = runnerFile.existsSync()
      ? runnerFile.readAsStringSync()
      : '';

  final sessionChecks = <_CheckResult>[
    _eventCheck(runnerText, 'session_start'),
    _eventCheck(runnerText, 'session_end'),
    _eventCheck(runnerText, 'session_abort'),
  ];

  final drillChecks = <_CheckResult>[
    _eventCheck(runnerText, 'user_choice'),
    _eventCheck(runnerText, 'correct'),
    _payloadCheck(runnerText, 'error_type'),
    _eventCheck(runnerText, 'time_to_decision'),
    _payloadCheck(runnerText, 'time_to_decision_ms'),
  ];

  final missing = <String>[];
  for (final check in <_CheckResult>[...sessionChecks, ...drillChecks]) {
    if (!check.found) {
      missing.add(check.label);
    }
  }

  final hasMissing = missing.isNotEmpty;

  final out = StringBuffer();
  out.writeln('# Worlds 0-4 Telemetry Audit v1');
  out.writeln();
  out.writeln('- Progression source: `$_kProgressFile`');
  out.writeln('- Session source: `content/worlds/worldN/v1/sessions/index.md`');
  out.writeln('- Emission scan source: `$_kRunnerFile`');
  out.writeln();

  out.writeln('## Progression Scope');
  out.writeln('| world | session_refs | pack_refs |');
  out.writeln('| --- | ---: | ---: |');
  for (final refs in worldRefs) {
    out.writeln(
      '| world${refs.worldId} | ${refs.sessionRefs.length} | ${refs.packRefs.length} |',
    );
  }
  out.writeln();

  out.writeln('## Session-level Events');
  out.writeln('| requirement | found |');
  out.writeln('| --- | --- |');
  for (final check in sessionChecks) {
    out.writeln('| ${check.label} | ${check.found ? 'Y' : 'N'} |');
  }
  out.writeln();

  out.writeln('## Drill-level Events');
  out.writeln('| requirement | found |');
  out.writeln('| --- | --- |');
  for (final check in drillChecks) {
    out.writeln('| ${check.label} | ${check.found ? 'Y' : 'N'} |');
  }
  out.writeln();

  if (hasMissing) {
    out.writeln('MISSING_TELEMETRY');
    out.writeln('- missing: ${missing.join(', ')}');
    stdout.write(out.toString());
    exitCode = 2;
    return;
  }

  out.writeln('TELEMETRY_OK');
  stdout.write(out.toString());
}

_WorldRefs _collectWorldRefs(int worldId) {
  final sessions = _parseSessionRefs(worldId);
  final packs = _parsePackRefs(worldId);
  return _WorldRefs(worldId: worldId, sessionRefs: sessions, packRefs: packs);
}

List<String> _parseSessionRefs(int worldId) {
  final indexFile = File('content/worlds/world$worldId/v1/sessions/index.md');
  if (!indexFile.existsSync()) {
    return const <String>[];
  }

  final ids = <String>{};
  for (final raw in indexFile.readAsLinesSync()) {
    final line = raw.trim();
    final match = _kSessionIndexLine.firstMatch(line);
    if (match == null) {
      continue;
    }
    ids.add(match.group(1)!);
  }

  final sorted = ids.toList()..sort();
  return sorted;
}

List<String> _parsePackRefs(int worldId) {
  final file = File(_kProgressFile);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final text = file.readAsStringSync();
  final ids = <String>{};
  for (final match in _kPackIdLiteral.allMatches(text)) {
    final id = match.group(1)!;
    if (id.startsWith('world${worldId}_') && _looksLikePackId(id)) {
      ids.add(id);
    }
  }

  final sorted = ids.toList()..sort();
  return sorted;
}

bool _looksLikePackId(String id) {
  if (id.endsWith('_')) {
    return false;
  }
  return id.contains('_act0_') ||
      id.contains('_spine_campaign_v1') ||
      id.contains('_spine_followup_v1_b') ||
      id.contains('_streets_demo_v1');
}

_CheckResult _eventCheck(String source, String eventName) {
  final found =
      source.contains("_emitTelemetry('$eventName'") ||
      source.contains('_emitTelemetry("$eventName"');
  return _CheckResult(label: 'event:$eventName', found: found);
}

_CheckResult _payloadCheck(String source, String key) {
  final found = source.contains("'$key':") || source.contains('"$key":');
  return _CheckResult(label: 'payload:$key', found: found);
}

class _WorldRefs {
  const _WorldRefs({
    required this.worldId,
    required this.sessionRefs,
    required this.packRefs,
  });

  final int worldId;
  final List<String> sessionRefs;
  final List<String> packRefs;
}

class _CheckResult {
  const _CheckResult({required this.label, required this.found});

  final String label;
  final bool found;
}

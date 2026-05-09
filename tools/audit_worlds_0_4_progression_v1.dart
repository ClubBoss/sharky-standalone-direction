import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;

const List<int> _kWorldIds = <int>[0, 1, 2, 3, 4];
final RegExp _kSessionIndexLine = RegExp(r'^- ([A-Za-z0-9._-]+):');
final RegExp _kPackIdLiteral = RegExp(r"'((world[0-4]_[a-z0-9_]+))'");

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln('audit_worlds_0_4_progression_v1: no arguments supported');
    exitCode = 64;
    return;
  }

  final worldReports = <_WorldProgressionReport>[];
  for (final worldId in _kWorldIds) {
    worldReports.add(_buildWorldReport(worldId));
  }

  final hasMissing = worldReports.any((report) => report.hasMissing);

  final buffer = StringBuffer();
  buffer.writeln('# Worlds 0-4 Progression Audit v1');
  buffer.writeln();
  buffer.writeln(
    '- Session source: `content/worlds/worldN/v1/sessions/index.md`',
  );
  buffer.writeln(
    '- Pack source: `lib/services/progress_service.dart` string literals',
  );
  buffer.writeln('- Registry source: `campaign_pack_registry_v1.dart`');

  for (final report in worldReports) {
    buffer.writeln();
    buffer.writeln('## World ${report.worldId}');
    buffer.writeln('- session_refs: ${report.sessionRefs.length}');
    buffer.writeln('- pack_refs: ${report.packRefs.length}');

    if (report.missingSessionFolders.isEmpty) {
      buffer.writeln('- missing_session_folders: NONE');
    } else {
      buffer.writeln(
        '- missing_session_folders: ${report.missingSessionFolders.join(', ')}',
      );
    }

    if (report.missingPackRegistryEntries.isEmpty) {
      buffer.writeln('- missing_pack_registry_entries: NONE');
    } else {
      buffer.writeln(
        '- missing_pack_registry_entries: ${report.missingPackRegistryEntries.join(', ')}',
      );
    }

    buffer.writeln();
    buffer.writeln('| reference_type | id | status |');
    buffer.writeln('| --- | --- | --- |');

    if (report.sessionRefs.isEmpty && report.packRefs.isEmpty) {
      buffer.writeln('| NONE | NONE | NO_REFERENCES |');
      continue;
    }

    for (final sessionId in report.sessionRefs) {
      final status = report.missingSessionFolders.contains(sessionId)
          ? 'MISSING_SESSION_FOLDER'
          : 'OK';
      buffer.writeln('| SESSION | $sessionId | $status |');
    }

    for (final packId in report.packRefs) {
      final status = report.missingPackRegistryEntries.contains(packId)
          ? 'MISSING_REGISTRY_ENTRY'
          : 'OK';
      buffer.writeln('| PACK | $packId | $status |');
    }
  }

  buffer.writeln();
  if (hasMissing) {
    buffer.writeln('MISSING_REFERENCES');
  } else {
    buffer.writeln('PROGRESSION_OK');
  }

  stdout.write(buffer.toString());
  exitCode = hasMissing ? 2 : 0;
}

_WorldProgressionReport _buildWorldReport(int worldId) {
  final sessionRefs = _parseSessionRefs(worldId);
  final missingSessionFolders = <String>[];
  for (final sessionId in sessionRefs) {
    final dir = Directory(
      'content/worlds/world$worldId/v1/sessions/$sessionId',
    );
    if (!dir.existsSync()) {
      missingSessionFolders.add(sessionId);
    }
  }

  final packRefs = _parsePackRefsFromProgressService(worldId);
  final registryIds = campaign_registry.kCampaignPackIdsV1.toSet();
  final missingPackRegistryEntries = <String>[];
  for (final packId in packRefs) {
    if (!registryIds.contains(packId)) {
      missingPackRegistryEntries.add(packId);
    }
  }

  return _WorldProgressionReport(
    worldId: worldId,
    sessionRefs: sessionRefs,
    packRefs: packRefs,
    missingSessionFolders: missingSessionFolders,
    missingPackRegistryEntries: missingPackRegistryEntries,
  );
}

List<String> _parseSessionRefs(int worldId) {
  final indexFile = File('content/worlds/world$worldId/v1/sessions/index.md');
  if (!indexFile.existsSync()) {
    return const <String>[];
  }

  final ids = <String>{};
  for (final rawLine in indexFile.readAsLinesSync()) {
    final line = rawLine.trim();
    final match = _kSessionIndexLine.firstMatch(line);
    if (match == null) {
      continue;
    }
    ids.add(match.group(1)!);
  }

  final sorted = ids.toList()..sort();
  return sorted;
}

List<String> _parsePackRefsFromProgressService(int worldId) {
  final file = File('lib/services/progress_service.dart');
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

class _WorldProgressionReport {
  const _WorldProgressionReport({
    required this.worldId,
    required this.sessionRefs,
    required this.packRefs,
    required this.missingSessionFolders,
    required this.missingPackRegistryEntries,
  });

  final int worldId;
  final List<String> sessionRefs;
  final List<String> packRefs;
  final List<String> missingSessionFolders;
  final List<String> missingPackRegistryEntries;

  bool get hasMissing =>
      missingSessionFolders.isNotEmpty || missingPackRegistryEntries.isNotEmpty;
}

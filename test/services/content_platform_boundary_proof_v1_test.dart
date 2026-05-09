import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _readJsonObject(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing file: $path');
  final decoded = jsonDecode(file.readAsStringSync());
  expect(
    decoded is Map<String, dynamic>,
    isTrue,
    reason: 'invalid JSON: $path',
  );
  return Map<String, Object?>.from(decoded as Map<String, dynamic>);
}

List<int> _sortedInts(Iterable<int> values) => (values.toList()..sort());

List<String> _sortedStrings(Iterable<String> values) =>
    (values.toList()..sort());

void main() {
  test('content platform manifests expose deterministic v1 boundaries', () {
    final sessionsManifest = _readJsonObject(
      'content/_meta/world_sessions_manifest_v1.json',
    );
    final drillsManifest = _readJsonObject(
      'content/_meta/world_drills_manifest_v1.json',
    );

    // Required boundary/version fields.
    expect(sessionsManifest['version'], 1);
    expect(drillsManifest['version'], 1);
    expect(
      (sessionsManifest['generated_from'] ?? '').toString().trim().isNotEmpty,
      isTrue,
    );
    expect(
      (drillsManifest['generated_from'] ?? '').toString().trim().isNotEmpty,
      isTrue,
    );

    final sessionsWorlds = (sessionsManifest['worlds'] as List)
        .cast<Map<String, dynamic>>();
    final drillsWorlds = (drillsManifest['worlds'] as List)
        .cast<Map<String, dynamic>>();

    expect(sessionsWorlds, isNotEmpty);
    expect(drillsWorlds, isNotEmpty);

    final sessionWorldIds = sessionsWorlds
        .map((w) => w['world'] as int)
        .toList(growable: false);
    final drillWorldIds = drillsWorlds
        .map((w) => w['world'] as int)
        .toList(growable: false);
    expect(sessionWorldIds, _sortedInts(sessionWorldIds));
    expect(drillWorldIds, _sortedInts(drillWorldIds));
    expect(sessionWorldIds, drillWorldIds);
    expect(sessionWorldIds, List<int>.generate(10, (i) => i));

    final sessionsByWorld = <int, List<Map<String, dynamic>>>{};
    for (final world in sessionsWorlds) {
      final worldId = world['world'] as int;
      final sessions = (world['sessions'] as List).cast<Map<String, dynamic>>();
      expect(sessions, isNotEmpty, reason: 'world$worldId has no sessions');
      final ids = sessions
          .map((s) => (s['id'] ?? '').toString())
          .toList(growable: false);
      expect(ids, _sortedStrings(ids));
      for (final s in sessions) {
        final id = (s['id'] ?? '').toString();
        final path = (s['path'] ?? '').toString();
        expect(id.isNotEmpty, isTrue);
        expect(path.isNotEmpty, isTrue);
        expect(path, contains('/sessions/$id/'));
      }
      sessionsByWorld[worldId] = sessions;
    }

    // Sampled boundary checks requested by DoR proof surface.
    for (final sampleWorld in const <int>[0, 1, 5, 9]) {
      final sessions = sessionsByWorld[sampleWorld];
      expect(sessions, isNotNull, reason: 'missing sample world: $sampleWorld');
      expect(sessions!.isNotEmpty, isTrue);
    }

    for (final world in drillsWorlds) {
      final worldId = world['world'] as int;
      final drillSessions = (world['sessions'] as List)
          .cast<Map<String, dynamic>>();
      final sessionIds = drillSessions
          .map((s) => (s['id'] ?? '').toString())
          .toList(growable: false);
      expect(sessionIds, _sortedStrings(sessionIds));

      final knownSessionIds = sessionsByWorld[worldId]!
          .map((s) => (s['id'] ?? '').toString())
          .toSet();
      expect(sessionIds.every(knownSessionIds.contains), isTrue);

      for (final s in drillSessions) {
        final sessionId = (s['id'] ?? '').toString();
        final path = (s['path'] ?? '').toString();
        expect(sessionId.isNotEmpty, isTrue);
        expect(path, contains('/sessions/$sessionId/'));

        final drills = (s['drills'] as List).cast<Map<String, dynamic>>();
        expect(drills, isNotEmpty, reason: '$sessionId has no drills');
        final drillIds = drills
            .map((d) => (d['id'] ?? '').toString())
            .toList(growable: false);
        expect(drillIds, _sortedStrings(drillIds));
        for (final d in drills) {
          final drillId = (d['id'] ?? '').toString();
          final drillPath = (d['path'] ?? '').toString();
          expect(drillId.isNotEmpty, isTrue);
          expect(drillPath.isNotEmpty, isTrue);
          expect(drillPath, contains('/drills/d.$drillId.json'));
        }
      }
    }
  });
}

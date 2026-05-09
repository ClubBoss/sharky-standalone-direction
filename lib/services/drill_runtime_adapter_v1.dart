import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:poker_analyzer/asset_manifest.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_defaults_v1.dart';

class SessionDrillItemV1 {
  const SessionDrillItemV1({required this.drillId, required this.spec});

  final String drillId;
  final DrillSpecV1 spec;
}

class DrillRuntimeAdapterV1 {
  const DrillRuntimeAdapterV1();

  Future<List<String>> listSessionIdsWithDrillsV1() async {
    try {
      final raw = await _loadText(
        'content/_meta/world_drills_manifest_v1.json',
      );
      return parseSessionIdsWithDrillsManifestV1(raw);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'DrillRuntimeAdapterV1.listSessionIdsWithDrillsV1 error: $e',
        );
      }
      return const <String>[];
    }
  }

  Future<List<SessionDrillItemV1>> loadSessionDrills(String sessionId) async {
    final sessionPath = _sessionPathForId(sessionId);
    final ids = await _loadSessionDrillIdsV1(sessionId, sessionPath);
    final defaultsRaw = await _loadOptionalTextV1(
      sessionDrillProjectionDefaultsPathForSessionPathV1(sessionPath),
    );
    final items = <SessionDrillItemV1>[];
    for (final id in ids) {
      final drillPath = await _resolveSessionDrillPathV1(
        sessionId,
        sessionPath,
        id,
      );
      final drillRaw = await _loadText(drillPath);
      final mergedRaw = mergeSessionDrillProjectionDefaultsIntoDrillJsonV1(
        sessionId: sessionId,
        drillId: id,
        drillRaw: drillRaw,
        defaultsRaw: defaultsRaw,
      );
      final spec = _parseSpec(drillPath, mergedRaw);
      items.add(SessionDrillItemV1(drillId: id, spec: spec));
    }
    return items;
  }

  Future<bool> hasSessionDrills(String sessionId) async {
    final sessionPath = _sessionPathForId(sessionId);
    final ids = await _loadSessionDrillIdsV1(sessionId, sessionPath);
    return ids.isNotEmpty;
  }

  String debugSessionPathForIdV1(String sessionId) {
    return _sessionPathForId(sessionId);
  }

  String seatIdForIndex(int index) => 'S${index + 1}';

  String boardSlotForIndex(int index) {
    switch (index) {
      case 0:
        return 'flop_left';
      case 1:
        return 'flop_mid';
      case 2:
        return 'flop_right';
      case 3:
        return 'turn';
      case 4:
        return 'river';
    }
    throw RangeError.index(index, [0, 1, 2, 3, 4], 'boardSlotIndex');
  }

  DrillSpecV1 _parseSpec(String path, String raw) {
    try {
      return DrillSpecV1.fromJsonString(raw);
    } on FormatException catch (e) {
      throw FormatException('$path: ${e.message}');
    }
  }

  String actionIdForLabel(String label) => label.trim().toLowerCase();

  String holeCardSlotForIndex(int index) {
    switch (index) {
      case 0:
        return 'p0';
      case 1:
        return 'p1';
    }
    throw RangeError.index(index, [0, 1], 'holeCardIndex');
  }

  // Minimal deterministic role map for debug session w0.s01.
  String? roleForSeat(String sessionId, int seatIndex) {
    if (sessionId != 'w0.s01') {
      return null;
    }
    switch (seatIndex) {
      case 1:
        return 'sb';
      case 2:
        return 'bb';
      case 0:
        return 'btn';
      default:
        return null;
    }
  }

  Future<String> _loadText(String path) async {
    final canonicalFile = _canonicalContentFileForPathV1(path);
    if (canonicalFile != null && await canonicalFile.exists()) {
      return canonicalFile.readAsString();
    }
    try {
      return await rootBundle.loadString(path);
    } catch (primaryError) {
      final manifestAssetPath = await _resolveBundledAssetPathV1(path);
      if (manifestAssetPath != null && manifestAssetPath != path) {
        try {
          return await rootBundle.loadString(manifestAssetPath);
        } catch (_) {}
      }
      if (!kIsWeb) {
        final file = File(path);
        if (await file.exists()) {
          return file.readAsString();
        }
      }
      throw primaryError;
    }
  }

  Future<String?> _loadOptionalTextV1(String path) async {
    try {
      return await _loadText(path);
    } catch (_) {
      return null;
    }
  }

  File? _canonicalContentFileForPathV1(String path) {
    if (kIsWeb) {
      return null;
    }
    final normalized = path.trim();
    if (!normalized.startsWith('content/')) {
      return null;
    }
    return File(normalized);
  }

  Future<List<String>> _loadSessionDrillIdsV1(
    String sessionId,
    String sessionPath,
  ) async {
    try {
      final indexRaw = await _loadText('$sessionPath/drills/index.md');
      return parseDrillIdsFromIndexV1(indexRaw);
    } catch (_) {
      final manifestRaw = await _loadText(
        'content/_meta/world_drills_manifest_v1.json',
      );
      final drillIds = parseDrillIdsForSessionFromManifestV1(
        manifestRaw,
        sessionId,
      );
      if (drillIds.isEmpty) {
        rethrow;
      }
      return drillIds;
    }
  }

  Future<String> _resolveSessionDrillPathV1(
    String sessionId,
    String sessionPath,
    String drillId,
  ) async {
    final derivedPath = '$sessionPath/drills/d.$drillId.json';
    try {
      await _loadText(derivedPath);
      return derivedPath;
    } catch (_) {
      final manifestRaw = await _loadText(
        'content/_meta/world_drills_manifest_v1.json',
      );
      final manifestPath = parseDrillAssetPathForSessionFromManifestV1(
        manifestRaw,
        sessionId,
        drillId,
      );
      if (manifestPath == null || manifestPath.isEmpty) {
        rethrow;
      }
      return manifestPath;
    }
  }

  Future<String?> _resolveBundledAssetPathV1(String path) async {
    final manifest = await AssetManifest.instance;
    if (manifest.containsKey(path)) {
      return path;
    }
    final normalized = path.trim();
    for (final key in manifest.keys) {
      if (key == normalized ||
          key.endsWith('/$normalized') ||
          key.endsWith(normalized)) {
        return key;
      }
    }
    return null;
  }

  String _sessionPathForId(String sessionId) {
    final normalized = sessionId.trim().toLowerCase();
    if (normalized == 'world10_spine_followup_v1_b0') {
      return 'content/worlds/world10/v1/tracks/cash/sessions/cash.s01';
    }
    if (normalized == 'world10_spine_followup_v1_b1') {
      return 'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s01';
    }
    if (normalized == 'world10_spine_followup_v1_b2') {
      return 'content/worlds/world10/v1/tracks/mixed/sessions/mixed.s01';
    }
    final trackMatch = RegExp(
      r'^(cash|tournament|mixed)\.s[0-9]+$',
    ).firstMatch(normalized);
    if (trackMatch != null) {
      final track = trackMatch.group(1)!;
      return 'content/worlds/world10/v1/tracks/$track/sessions/$normalized';
    }
    final match = RegExp(r'^w([0-9]+)\.s[0-9]+$').firstMatch(sessionId);
    if (match == null) {
      throw FormatException('Invalid session id: $sessionId');
    }
    final world = int.parse(match.group(1)!);
    return 'content/worlds/world$world/v1/sessions/$sessionId';
  }
}

List<String> parseSessionIdsWithDrillsManifestV1(String raw) {
  final dynamic decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'world_drills_manifest_v1: root must be object',
    );
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    throw const FormatException(
      'world_drills_manifest_v1: worlds must be list',
    );
  }

  final ids = <String>{};
  for (final world in worlds) {
    if (world is! Map) {
      continue;
    }
    final sessions = world['sessions'];
    if (sessions is! List) {
      continue;
    }
    for (final session in sessions) {
      if (session is! Map) {
        continue;
      }
      final drills = session['drills'];
      if (drills is! List || drills.isEmpty) {
        continue;
      }
      final id = session['id'];
      if (id is String && id.isNotEmpty) {
        ids.add(id);
      }
    }
  }
  final out = ids.toList()..sort();
  return out;
}

List<String> parseDrillIdsForSessionFromManifestV1(
  String raw,
  String sessionId,
) {
  final dynamic decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'world_drills_manifest_v1: root must be object',
    );
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    throw const FormatException(
      'world_drills_manifest_v1: worlds must be list',
    );
  }

  final normalized = sessionId.trim().toLowerCase();
  for (final world in worlds) {
    if (world is! Map) {
      continue;
    }
    final sessions = world['sessions'];
    if (sessions is! List) {
      continue;
    }
    for (final session in sessions) {
      if (session is! Map) {
        continue;
      }
      final id = session['id'];
      if (id is! String || id.trim().toLowerCase() != normalized) {
        continue;
      }
      final drills = session['drills'];
      if (drills is! List) {
        return const <String>[];
      }
      final out = <String>[];
      for (final drill in drills) {
        if (drill is! Map) {
          continue;
        }
        final drillId = drill['id'];
        if (drillId is String && drillId.isNotEmpty) {
          out.add(drillId);
        }
      }
      return List<String>.unmodifiable(out);
    }
  }
  return const <String>[];
}

String? parseDrillAssetPathForSessionFromManifestV1(
  String raw,
  String sessionId,
  String drillId,
) {
  final dynamic decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'world_drills_manifest_v1: root must be object',
    );
  }
  final worlds = decoded['worlds'];
  if (worlds is! List) {
    throw const FormatException(
      'world_drills_manifest_v1: worlds must be list',
    );
  }

  final normalizedSessionId = sessionId.trim().toLowerCase();
  final normalizedDrillId = drillId.trim().toLowerCase();
  for (final world in worlds) {
    if (world is! Map) {
      continue;
    }
    final sessions = world['sessions'];
    if (sessions is! List) {
      continue;
    }
    for (final session in sessions) {
      if (session is! Map) {
        continue;
      }
      final id = session['id'];
      if (id is! String || id.trim().toLowerCase() != normalizedSessionId) {
        continue;
      }
      final drills = session['drills'];
      if (drills is! List) {
        return null;
      }
      for (final drill in drills) {
        if (drill is! Map) {
          continue;
        }
        final currentDrillId = drill['id'];
        if (currentDrillId is! String ||
            currentDrillId.trim().toLowerCase() != normalizedDrillId) {
          continue;
        }
        final path = drill['path'];
        if (path is String && path.isNotEmpty) {
          return path;
        }
        return null;
      }
      return null;
    }
  }
  return null;
}

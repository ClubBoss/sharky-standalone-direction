import 'dart:convert';

const String kSessionDrillProjectionDefaultsFileNameV1 =
    'spatial_projection_defaults_v1.json';

String sessionDrillProjectionDefaultsPathForSessionPathV1(String sessionPath) {
  final normalized = sessionPath.replaceFirst(RegExp(r'/$'), '');
  final lastSlash = normalized.lastIndexOf('/');
  if (lastSlash < 0) {
    return '$normalized/$kSessionDrillProjectionDefaultsFileNameV1';
  }
  return normalized.substring(0, lastSlash) +
      '/$kSessionDrillProjectionDefaultsFileNameV1';
}

bool sessionDrillProjectionDefaultsApplyToDrillV1({
  required String sessionId,
  required String drillId,
  required String? defaultsRaw,
}) {
  final entry = _sessionEntryForV1(
    sessionId: sessionId,
    defaultsRaw: defaultsRaw,
  );
  if (entry == null) {
    return false;
  }
  final drillIds = entry['drill_ids'];
  if (drillIds is! List<Object?>) {
    return false;
  }
  final normalizedDrillId = drillId.trim().toLowerCase();
  return drillIds.any(
    (value) =>
        value is String &&
        (value.trim() == '*' ||
            value.trim().toLowerCase() == normalizedDrillId),
  );
}

String mergeSessionDrillProjectionDefaultsIntoDrillJsonV1({
  required String sessionId,
  required String drillId,
  required String drillRaw,
  required String? defaultsRaw,
}) {
  if (!sessionDrillProjectionDefaultsApplyToDrillV1(
    sessionId: sessionId,
    drillId: drillId,
    defaultsRaw: defaultsRaw,
  )) {
    return drillRaw;
  }
  final drillJson = jsonDecode(drillRaw);
  if (drillJson is! Map<String, Object?>) {
    return drillRaw;
  }
  final sessionEntry = _sessionEntryForV1(
    sessionId: sessionId,
    defaultsRaw: defaultsRaw,
  );
  if (sessionEntry == null) {
    return drillRaw;
  }
  final shared = sessionEntry['shared'];
  if (shared is! Map<String, Object?>) {
    return drillRaw;
  }
  final overrides =
      (sessionEntry['drill_overrides'] as Map<String, Object?>?)?[drillId];
  final overrideMap = overrides is Map<String, Object?>
      ? overrides
      : const <String, Object?>{};
  final merged = <String, Object?>{...drillJson, ...shared, ...overrideMap};
  return const JsonEncoder.withIndent('  ').convert(merged);
}

Map<String, Object?>? _sessionEntryForV1({
  required String sessionId,
  required String? defaultsRaw,
}) {
  if (defaultsRaw == null || defaultsRaw.trim().isEmpty) {
    return null;
  }
  final decoded = jsonDecode(defaultsRaw);
  if (decoded is! Map<String, Object?>) {
    return null;
  }
  final sessions = decoded['sessions'];
  if (sessions is! Map<String, Object?>) {
    return null;
  }
  final normalizedSessionId = sessionId.trim().toLowerCase();
  for (final entry in sessions.entries) {
    if (entry.key.trim().toLowerCase() != normalizedSessionId) {
      continue;
    }
    final value = entry.value;
    if (value is Map<String, Object?>) {
      return value;
    }
  }
  return null;
}

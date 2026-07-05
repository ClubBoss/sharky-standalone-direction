import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

const _defaultManifestPaths = <String>[
  'content/worlds/world11/v1/source_proof_manifest_v1.json',
  'content/worlds/world12/v1/source_proof_manifest_v1.json',
];

const _specs = <_WorldProofSpec>[
  _WorldProofSpec(
    worldId: 'world_11',
    packetWorldId: 'world11',
    owner: '_realPlayTransferLessons',
    sourceRoot: 'content/worlds/world11/v1',
    routeProofId: 'w11_source_route_proof_v1',
  ),
  _WorldProofSpec(
    worldId: 'world_12',
    packetWorldId: 'world12',
    owner: '_mindsetBridgeLessons',
    sourceRoot: 'content/worlds/world12/v1',
    routeProofId: 'w12_source_route_proof_v1',
  ),
];

const _forbiddenLearnerCopyKeys = <String>{
  'answer',
  'board_context',
  'correct_feedback',
  'expected_answer',
  'feedback',
  'incorrect_feedback',
  'learner_prompt',
  'learning_purpose',
  'legal_choices',
  'prompt',
  'subtitle',
  'title',
  'visible_state',
};

void main(List<String> args) {
  if (args.isNotEmpty && args.length != 2) {
    stderr.writeln(
      'validate_w11_w12_source_proof_v1: expected zero or two manifest paths',
    );
    exitCode = 64;
    return;
  }

  final paths = args.isEmpty ? _defaultManifestPaths : args;
  final results = <_WorldProofValidationResult>[];
  for (var index = 0; index < _specs.length; index++) {
    results.add(_validateManifest(File(paths[index]), _specs[index]));
  }

  final errors = results.expand((result) => result.errors).toList();
  for (final result in results) {
    stdout.writeln(
      'validate_w11_w12_source_proof_v1: ${result.worldId} '
      'lessons=${result.lessonCount} tasks=${result.taskCount} '
      'reps=${result.repCount} packs=${result.packCount}',
    );
  }
  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln('validate_w11_w12_source_proof_v1: $error');
    }
    exitCode = 2;
    return;
  }
  stdout.writeln('validate_w11_w12_source_proof_v1: OK');
}

_WorldProofValidationResult _validateManifest(File file, _WorldProofSpec spec) {
  final errors = <String>[];
  if (!file.existsSync()) {
    return _WorldProofValidationResult(
      spec.worldId,
      errors: ['${file.path}: manifest not found'],
    );
  }

  Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on FormatException catch (error) {
    return _WorldProofValidationResult(
      spec.worldId,
      errors: ['${file.path}: invalid JSON (${error.message})'],
    );
  }
  if (decoded is! Map) {
    return _WorldProofValidationResult(
      spec.worldId,
      errors: ['${file.path}: root must be an object'],
    );
  }
  final manifest = decoded.cast<String, Object?>();
  _validateNoLearnerCopy(manifest, file.path, errors);

  _expectString(
    manifest,
    'schema_version',
    'w11_w12_source_proof_manifest_v1',
    file.path,
    errors,
  );
  _expectString(
    manifest,
    'validator_classification',
    'metadata_only_source_proof',
    file.path,
    errors,
  );
  _expectString(manifest, 'world_id', spec.worldId, file.path, errors);
  _expectString(
    manifest,
    'packet_world_id',
    spec.packetWorldId,
    file.path,
    errors,
  );
  _expectString(manifest, 'live_owner_symbol', spec.owner, file.path, errors);
  _expectString(manifest, 'source_root', spec.sourceRoot, file.path, errors);
  _expectString(
    manifest,
    'route_proof_id',
    spec.routeProofId,
    file.path,
    errors,
  );

  final lessons = _objectList(manifest, 'lessons', file.path, errors);
  final lessonIds = <String>[];
  final taskIds = <String>[];
  for (var index = 0; index < lessons.length; index++) {
    final lesson = lessons[index];
    final label = '${file.path}: lessons[$index]';
    final lessonId = _string(lesson, 'lesson_id', label, errors);
    if (lessonId != null) lessonIds.add(lessonId);
    taskIds.addAll(_stringList(lesson, 'task_ids', label, errors));
  }
  _validateStableIds(lessonIds, '${file.path}: lesson IDs', errors);
  _validateStableIds(taskIds, '${file.path}: task IDs', errors);
  _validateUnique(lessonIds, '${file.path}: lesson IDs', errors);
  _validateUnique(taskIds, '${file.path}: task IDs', errors);

  final repIds = _stringList(manifest, 'packet_rep_ids', file.path, errors);
  final packIds = _stringList(manifest, 'campaign_pack_ids', file.path, errors);
  _validateStableIds(repIds, '${file.path}: packet rep IDs', errors);
  _validateStableIds(packIds, '${file.path}: campaign pack IDs', errors);
  _validateUnique(repIds, '${file.path}: packet rep IDs', errors);
  _validateUnique(packIds, '${file.path}: campaign pack IDs', errors);

  final runtimePath = _string(
    manifest,
    'runtime_source_path',
    file.path,
    errors,
  );
  if (runtimePath != null) {
    final runtimeFile = File(runtimePath);
    if (!runtimeFile.existsSync()) {
      errors.add('$runtimePath: runtime source not found');
    } else {
      _validateRuntimeSource(
        runtimeFile.readAsStringSync(),
        spec,
        lessonIds,
        taskIds,
        manifest,
        errors,
      );
    }
  }

  final packetPath = _string(manifest, 'packet_path', file.path, errors);
  final fixturePath = _string(
    manifest,
    'campaign_fixture_path',
    file.path,
    errors,
  );
  if (packetPath != null && fixturePath != null) {
    _validatePacketAndFixture(packetPath, fixturePath, spec, repIds, errors);
  }
  _validateCampaignPacks(spec, packIds, errors);
  _validateRouteProof(manifest, spec, errors);
  _validateIndex(manifest, errors);
  _validateCoverage(manifest, taskIds, repIds, errors);
  _validateOwnership(manifest, errors);

  return _WorldProofValidationResult(
    spec.worldId,
    lessonCount: lessonIds.length,
    taskCount: taskIds.length,
    repCount: repIds.length,
    packCount: packIds.length,
    errors: errors,
  );
}

void _validateRuntimeSource(
  String source,
  _WorldProofSpec spec,
  List<String> lessonIds,
  List<String> taskIds,
  Map<String, Object?> manifest,
  List<String> errors,
) {
  final marker = 'final ${spec.owner} = <Act0LessonCardV1>[';
  final start = source.indexOf(marker);
  final end = start < 0 ? -1 : source.indexOf('\n];', start);
  if (start < 0 || end < 0) {
    errors.add('${spec.worldId}: live owner ${spec.owner} not found');
    return;
  }
  final ownerSource = source.substring(start, end);
  final sourceLessons = _captures(ownerSource, RegExp(r"lessonId: '([^']+)'"));
  final sourceTasks = _captures(ownerSource, RegExp(r"taskId: '([^']+)'"));
  _expectSameIds(
    lessonIds,
    sourceLessons,
    '${spec.worldId}: Act0 lesson IDs',
    errors,
  );
  _expectSameIds(
    taskIds,
    sourceTasks,
    '${spec.worldId}: Act0 task IDs',
    errors,
  );
  for (final taskId in taskIds) {
    if (!sourceTasks.contains(taskId)) {
      errors.add('${spec.worldId}: unresolved Act0 task ID $taskId');
    }
  }

  final worldMarker = "worldId: '${spec.worldId}',";
  final worldStart = source.indexOf(worldMarker);
  final nextWorld = worldStart < 0
      ? -1
      : source.indexOf('Act0WorldCardV1(', worldStart + worldMarker.length);
  final worldEnd = nextWorld < 0 ? source.length : nextWorld;
  final worldSource = worldStart < 0
      ? ''
      : source.substring(worldStart, worldEnd);
  for (final required in <String>[
    'lessons: ${spec.owner}',
    'status: Act0WorldStateV1.locked',
    'isSelectable: false',
    'isLocked: true',
  ]) {
    if (!worldSource.contains(required)) {
      errors.add('${spec.worldId}: runtime world card missing $required');
    }
  }

  final coverage = _map(manifest, 'coverage', spec.worldId, errors);
  if (coverage == null) return;
  final transfer = _coverageTaskIds(coverage, 'transfer', errors);
  final review = _coverageTaskIds(coverage, 'review', errors);
  final sourceTransfer = _taskIdsMatching(
    ownerSource,
    'taskFamily: Act0TaskFamilyV1.transfer',
  );
  final sourceReview = _taskIdsMatching(
    ownerSource,
    'phase: Act0LessonPhaseV1.review',
  );
  _expectSameIds(
    transfer,
    sourceTransfer,
    '${spec.worldId}: transfer coverage IDs',
    errors,
  );
  _expectSameIds(
    review,
    sourceReview,
    '${spec.worldId}: review coverage IDs',
    errors,
  );
}

void _validatePacketAndFixture(
  String packetPath,
  String fixturePath,
  _WorldProofSpec spec,
  List<String> repIds,
  List<String> errors,
) {
  final packetFile = File(packetPath);
  final fixtureFile = File(fixturePath);
  if (!packetFile.existsSync()) {
    errors.add('$packetPath: packet source not found');
    return;
  }
  if (!fixtureFile.existsSync()) {
    errors.add('$fixturePath: campaign fixture not found');
    return;
  }
  final packetRepIds = _captures(
    packetFile.readAsStringSync(),
    RegExp(r'^## Rep ([a-z0-9.]+)$', multiLine: true),
  );
  _expectSameIds(
    repIds,
    packetRepIds,
    '${spec.worldId}: packet rep IDs',
    errors,
  );
  for (final repId in repIds) {
    if (!packetRepIds.contains(repId)) {
      errors.add('${spec.worldId}: unresolved packet rep ID $repId');
    }
  }

  final fixture = jsonDecode(fixtureFile.readAsStringSync());
  if (fixture is! Map) {
    errors.add('$fixturePath: fixture root must be an object');
    return;
  }
  final fixtureMap = fixture.cast<String, Object?>();
  if (fixtureMap['world_id'] != spec.packetWorldId) {
    errors.add('$fixturePath: world_id must be ${spec.packetWorldId}');
  }
  final reps = _objectList(fixtureMap, 'reps', fixturePath, errors);
  final fixtureRepIds = <String>[];
  for (var index = 0; index < reps.length; index++) {
    final rep = reps[index];
    final repId = _string(rep, 'rep_id', '$fixturePath: reps[$index]', errors);
    if (repId != null) fixtureRepIds.add(repId);
    if ((rep['repair_cue'] as String?)?.trim().isEmpty ?? true) {
      errors.add('$fixturePath: reps[$index] missing repair_cue');
    }
  }
  _expectSameIds(
    repIds,
    fixtureRepIds,
    '${spec.worldId}: fixture rep IDs',
    errors,
  );
}

void _validateCampaignPacks(
  _WorldProofSpec spec,
  List<String> packIds,
  List<String> errors,
) {
  final registered =
      kCampaignPackIdsV1
          .where((id) => id.startsWith('${spec.packetWorldId}_'))
          .toList()
        ..sort();
  final declared = [...packIds]..sort();
  _expectSameIds(
    declared,
    registered,
    '${spec.worldId}: campaign pack IDs',
    errors,
  );
  for (final packId in packIds) {
    if (!kCampaignPackIdsV1.contains(packId)) {
      errors.add('${spec.worldId}: unresolved campaign pack ID $packId');
    }
  }
  if (kCampaignPackIdsV1.any((id) => id.startsWith('world13_'))) {
    errors.add(
      '${spec.worldId}: W13+ campaign registration must remain absent',
    );
  }
}

void _validateRouteProof(
  Map<String, Object?> manifest,
  _WorldProofSpec spec,
  List<String> errors,
) {
  final path = _string(
    manifest,
    'route_proof_source_path',
    spec.worldId,
    errors,
  );
  if (path == null) return;
  final file = File(path);
  if (!file.existsSync()) {
    errors.add('$path: route-proof source not found');
    return;
  }
  if (!file.readAsStringSync().contains("'${spec.routeProofId}'")) {
    errors.add(
      '${spec.worldId}: route-proof ID ${spec.routeProofId} not found',
    );
  }
}

void _validateIndex(Map<String, Object?> manifest, List<String> errors) {
  final path = _string(manifest, 'index_path', 'manifest', errors);
  if (path == null) return;
  final file = File(path);
  if (!file.existsSync()) {
    errors.add('$path: content index not found');
    return;
  }
  if (!file.readAsStringSync().contains('source_proof_manifest_v1.json')) {
    errors.add('$path: source-proof manifest is not indexed');
  }
}

void _validateCoverage(
  Map<String, Object?> manifest,
  List<String> taskIds,
  List<String> repIds,
  List<String> errors,
) {
  final coverage = _map(manifest, 'coverage', 'manifest', errors);
  if (coverage == null) return;
  for (final name in const <String>['repair', 'transfer', 'review']) {
    final entry = _map(coverage, name, 'coverage', errors);
    if (entry == null) continue;
    final coveredTasks = _stringList(entry, 'act0_task_ids', name, errors);
    final coveredReps = _stringList(entry, 'packet_rep_ids', name, errors);
    if (coveredTasks.isEmpty || coveredReps.isEmpty) {
      errors.add('coverage.$name: task and packet proof must be non-empty');
    }
    for (final id in coveredTasks) {
      if (!taskIds.contains(id)) {
        errors.add('coverage.$name: unresolved Act0 task ID $id');
      }
    }
    for (final id in coveredReps) {
      if (!repIds.contains(id)) {
        errors.add('coverage.$name: unresolved packet rep ID $id');
      }
    }
  }
  final repair = _map(coverage, 'repair', 'coverage', errors);
  if (repair != null) {
    final repairReps = _stringList(repair, 'packet_rep_ids', 'repair', errors);
    _expectSameIds(repairReps, repIds, 'repair packet rep IDs', errors);
  }
}

void _validateOwnership(Map<String, Object?> manifest, List<String> errors) {
  final ownership = _map(manifest, 'ownership', 'manifest', errors);
  if (ownership == null) return;
  if (ownership['runtime_content_owner'] != 'existing_dart_owner') {
    errors.add('ownership.runtime_content_owner must preserve existing Dart');
  }
  if (ownership['packet_content_owner'] != 'existing_deterministic_packet') {
    errors.add('ownership.packet_content_owner must preserve existing packet');
  }
  if (ownership['duplicates_learner_facing_content'] != false) {
    errors.add('ownership must reject duplicated learner-facing content');
  }
}

void _validateNoLearnerCopy(Object? value, String path, List<String> errors) {
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key.toString();
      if (_forbiddenLearnerCopyKeys.contains(key)) {
        errors.add('$path: forbidden learner-facing metadata key $key');
      }
      _validateNoLearnerCopy(entry.value, '$path.$key', errors);
    }
  } else if (value is List) {
    for (var index = 0; index < value.length; index++) {
      _validateNoLearnerCopy(value[index], '$path[$index]', errors);
    }
  }
}

List<String> _taskIdsMatching(String ownerSource, String marker) {
  final matches = RegExp(r"taskId: '([^']+)'").allMatches(ownerSource).toList();
  final ids = <String>[];
  for (var index = 0; index < matches.length; index++) {
    final start = matches[index].start;
    final end = index + 1 < matches.length
        ? matches[index + 1].start
        : ownerSource.length;
    if (ownerSource.substring(start, end).contains(marker)) {
      ids.add(matches[index].group(1)!);
    }
  }
  return ids;
}

List<String> _coverageTaskIds(
  Map<String, Object?> coverage,
  String name,
  List<String> errors,
) {
  final entry = _map(coverage, name, 'coverage', errors);
  return entry == null
      ? <String>[]
      : _stringList(entry, 'act0_task_ids', 'coverage.$name', errors);
}

List<Map<String, Object?>> _objectList(
  Map<String, Object?> map,
  String key,
  String path,
  List<String> errors,
) {
  final value = map[key];
  if (value is! List) {
    errors.add('$path: $key must be a list');
    return <Map<String, Object?>>[];
  }
  final result = <Map<String, Object?>>[];
  for (var index = 0; index < value.length; index++) {
    final item = value[index];
    if (item is! Map) {
      errors.add('$path: $key[$index] must be an object');
      continue;
    }
    result.add(item.cast<String, Object?>());
  }
  return result;
}

Map<String, Object?>? _map(
  Map<String, Object?> map,
  String key,
  String path,
  List<String> errors,
) {
  final value = map[key];
  if (value is! Map) {
    errors.add('$path: $key must be an object');
    return null;
  }
  return value.cast<String, Object?>();
}

String? _string(
  Map<String, Object?> map,
  String key,
  String path,
  List<String> errors,
) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    errors.add('$path: $key must be a non-empty string');
    return null;
  }
  return value;
}

List<String> _stringList(
  Map<String, Object?> map,
  String key,
  String path,
  List<String> errors,
) {
  final value = map[key];
  if (value is! List || value.any((item) => item is! String || item.isEmpty)) {
    errors.add('$path: $key must be a list of non-empty strings');
    return <String>[];
  }
  return value.cast<String>();
}

void _expectString(
  Map<String, Object?> map,
  String key,
  String expected,
  String path,
  List<String> errors,
) {
  if (map[key] != expected) {
    errors.add('$path: $key must be $expected');
  }
}

void _validateStableIds(List<String> ids, String label, List<String> errors) {
  final pattern = RegExp(r'^[a-z0-9_.-]+$');
  for (final id in ids) {
    if (!pattern.hasMatch(id)) errors.add('$label: invalid stable ID $id');
  }
}

void _validateUnique(List<String> ids, String label, List<String> errors) {
  if (ids.toSet().length != ids.length) errors.add('$label: duplicate IDs');
}

void _expectSameIds(
  List<String> actual,
  List<String> expected,
  String label,
  List<String> errors,
) {
  if (actual.length != expected.length || !_listEquals(actual, expected)) {
    errors.add('$label mismatch: declared=$actual source=$expected');
  }
}

bool _listEquals(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

List<String> _captures(String source, RegExp pattern) {
  return pattern
      .allMatches(source)
      .map((match) => match.group(1)!)
      .toList(growable: false);
}

class _WorldProofSpec {
  const _WorldProofSpec({
    required this.worldId,
    required this.packetWorldId,
    required this.owner,
    required this.sourceRoot,
    required this.routeProofId,
  });

  final String worldId;
  final String packetWorldId;
  final String owner;
  final String sourceRoot;
  final String routeProofId;
}

class _WorldProofValidationResult {
  const _WorldProofValidationResult(
    this.worldId, {
    this.lessonCount = 0,
    this.taskCount = 0,
    this.repCount = 0,
    this.packCount = 0,
    required this.errors,
  });

  final String worldId;
  final int lessonCount;
  final int taskCount;
  final int repCount;
  final int packCount;
  final List<String> errors;
}

import 'dart:convert';
import 'dart:io';

import 'content_schema_foundation_validator_v1.dart';

const List<String> defaultContentSchemaL2L3FixturePathsV1 = [
  'test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json',
  'test/fixtures/content_schema_foundation/w1_schema_l1_migrated_sample_v1.json',
  'test/fixtures/content_factory_mvp/w1_import_export_sample_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w2_bridge_or_legacy_import_export_sample_v1.json',
];

const List<String> w1ContentFactoryCoverageFixturePathsV1 = [
  'test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_starting_hand_discipline_migration_batch1_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_seat_role_orientation_migration_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_card_board_orientation_migration_pr2_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_bet_size_vocabulary_preview_migration_pr3_v1.json',
  'test/fixtures/content_factory_mvp/'
      'w1_checkpoint_synthesis_migration_pr3_v1.json',
];

const List<String> _requiredFields = [
  'schema_version',
  'world_id',
  'route_world_id',
  'display_world_title',
  'content_owner_world_id',
  'route_gate_status',
  'lesson_id',
  'task_id',
  'concept_family_id',
  'drill_kind',
  'feedback_reason',
  'validation_status',
  'preview_only',
  'source_truth_status',
];

final RegExp _worldIdPattern = RegExp(r'^world_(\d+)$');

Future<void> main(List<String> args) async {
  final paths = args.isEmpty ? defaultContentSchemaL2L3FixturePathsV1 : args;
  final result = validateContentSchemaL2L3FixturePathsV1(paths);

  stdout.writeln(
    'content_schema_l2_l3_validator_v1: fixtures=${result.fixtureCount} '
    'worlds=${result.worldReports.length} '
    'tasks=${result.totalTasks} '
    'coverage_countable=${result.coverageCountableTasks}',
  );
  for (final world in result.worldReports.values) {
    stdout.writeln(
      'content_schema_l2_l3_validator_v1: ${world.worldId} '
      'tasks=${world.totalTasks} '
      'coverage_countable=${world.coverageCountableTasks} '
      'coverage_ready=${world.coverageReady} '
      'transfer_ready=${world.transferReady} '
      'repair_ready=${world.repairReady} '
      'route_admission=${world.routeAdmissionStatus}',
    );
  }

  for (final warning in result.warnings) {
    stdout.writeln('content_schema_l2_l3_validator_v1: warning: $warning');
  }

  if (result.isValid) {
    stdout.writeln('content_schema_l2_l3_validator_v1: OK');
    return;
  }

  for (final error in [...result.errors, ...result.routeAdmissionErrors]) {
    stderr.writeln('content_schema_l2_l3_validator_v1: $error');
  }
  exitCode = 2;
}

ContentSchemaL2L3ValidationResultV1 validateContentSchemaL2L3FixturePathsV1(
  List<String> paths,
) {
  final fixtures = <Map<String, Object?>>[];
  final fixtureErrors = <String>[];

  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      fixtureErrors.add('fixture not found: $path');
      continue;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      fixtureErrors.add('invalid JSON in $path: ${error.message}');
      continue;
    }
    if (decoded is! Map<String, Object?>) {
      fixtureErrors.add('fixture root must be a JSON object: $path');
      continue;
    }
    fixtures.add(decoded);
  }

  final result = validateContentSchemaL2L3FixturesV1(fixtures);
  return result.copyWith(
    fixtureCount: paths.length,
    errors: [...fixtureErrors, ...result.errors],
  );
}

ContentSchemaL2L3ValidationResultV1 validateContentSchemaL2L3FixturesV1(
  List<Map<String, Object?>> fixtures, {
  String path = '<memory>',
}) {
  final aggregate = <String, Object?>{
    'tasks': [for (final fixture in fixtures) ..._tasksFromFixture(fixture)],
  };
  return validateContentSchemaL2L3MapV1(
    aggregate,
    path: path,
  ).copyWith(fixtureCount: fixtures.length);
}

ContentSchemaL2L3ValidationResultV1 validateContentSchemaL2L3MapV1(
  Map<Object?, Object?> fixture, {
  String path = '<memory>',
}) {
  final l0Result = validateContentSchemaFoundationMapV1(fixture, path: path);
  final errors = <String>[...l0Result.errors];
  final routeAdmissionErrors = <String>[];
  final warnings = <String>[];
  final worldBuilders = <String, _WorldReportBuilderV1>{};
  final transferSurfacesByWorldConcept = <String, Set<String>>{};
  final sameSignalCounts = <String, int>{};
  final bridgeSameSignalKeys = <String>{};
  final bridgeTransferKeys = <String>{};
  final repairMissingConcepts = <String>{};

  final rawTasks = fixture['tasks'];
  if (rawTasks is! List) {
    return ContentSchemaL2L3ValidationResultV1(
      fixtureCount: 1,
      totalTasks: 0,
      coverageCountableTasks: 0,
      worldReports: const {},
      errors: errors,
      routeAdmissionErrors: routeAdmissionErrors,
      warnings: warnings,
    );
  }

  for (final rawTask in rawTasks) {
    if (rawTask is! Map) continue;
    final task = rawTask.cast<String, Object?>();
    final worldId = _stringValue(task['world_id']) ?? 'world_unknown';
    final builder = worldBuilders.putIfAbsent(
      worldId,
      () => _WorldReportBuilderV1(worldId),
    );
    builder.addTask(task);

    final isCoverageCountable = task['preview_only'] == false;
    final conceptFamilyId = _stringValue(task['concept_family_id']);
    final sameSignalGroupId = _stringValue(task['same_signal_group_id']);
    final transferSurfaceId = _stringValue(task['transfer_surface_id']);

    if (isCoverageCountable && sameSignalGroupId != null) {
      final key = '$worldId|$sameSignalGroupId';
      sameSignalCounts[key] = (sameSignalCounts[key] ?? 0) + 1;
      if (task['source_truth_status'] == 'bridge_or_legacy') {
        bridgeSameSignalKeys.add(key);
      }
    }

    if (isCoverageCountable &&
        conceptFamilyId != null &&
        transferSurfaceId != null) {
      final key = '$worldId|$conceptFamilyId';
      transferSurfacesByWorldConcept
          .putIfAbsent(key, () => <String>{})
          .add(transferSurfaceId);
      if (task['source_truth_status'] == 'bridge_or_legacy') {
        bridgeTransferKeys.add(key);
      }
    }

    if (isCoverageCountable &&
        task['repairable'] == true &&
        conceptFamilyId != null &&
        _stringValue(task['repair_focus_id']) == null) {
      repairMissingConcepts.add('$worldId|$conceptFamilyId');
    }

    _validateRouteAdmission(task, routeAdmissionErrors);
    _validateBridgeClaimSafety(task, warnings, routeAdmissionErrors);
    _validateLaunchScopeClaims(task, routeAdmissionErrors);
  }

  for (final entry in sameSignalCounts.entries) {
    if (bridgeSameSignalKeys.contains(entry.key)) continue;
    final parts = entry.key.split('|');
    final count = entry.value;
    if (count < 5) {
      errors.add(
        '${parts[0]} same_signal_group_id ${parts[1]} has $count '
        'coverage_countable tasks; minimum is 5',
      );
    }
  }

  for (final entry in transferSurfacesByWorldConcept.entries) {
    if (bridgeTransferKeys.contains(entry.key)) continue;
    final parts = entry.key.split('|');
    final count = entry.value.length;
    if (count < 2) {
      errors.add(
        '${parts[0]} concept_family_id ${parts[1]} has $count transfer '
        'surface; minimum is 2',
      );
    }
  }

  for (final key in repairMissingConcepts) {
    final parts = key.split('|');
    errors.add(
      '${parts[0]} repairable concept_family_id ${parts[1]} is missing '
      'repair_focus_id',
    );
  }

  final worldReports = <String, ContentSchemaWorldL2L3ReportV1>{};
  var totalTasks = 0;
  var coverageCountableTasks = 0;
  for (final entry in worldBuilders.entries) {
    final worldErrors = errors
        .where((error) => error.startsWith('${entry.key} '))
        .toList();
    final worldRouteErrors = routeAdmissionErrors
        .where((error) => error.startsWith('${entry.key} '))
        .toList();
    final report = entry.value.build(
      hasCoverageErrors: worldErrors.isNotEmpty,
      hasRouteAdmissionErrors: worldRouteErrors.isNotEmpty,
    );
    worldReports[entry.key] = report;
    totalTasks += report.totalTasks;
    coverageCountableTasks += report.coverageCountableTasks;
  }

  return ContentSchemaL2L3ValidationResultV1(
    fixtureCount: 1,
    totalTasks: totalTasks,
    coverageCountableTasks: coverageCountableTasks,
    worldReports: Map.unmodifiable(worldReports),
    errors: errors,
    routeAdmissionErrors: routeAdmissionErrors,
    warnings: warnings.toSet().toList()..sort(),
  );
}

List<Object?> _tasksFromFixture(Map<String, Object?> fixture) {
  final tasks = fixture['tasks'];
  if (tasks is List) return tasks;
  return const [];
}

void _validateRouteAdmission(
  Map<String, Object?> task,
  List<String> routeAdmissionErrors,
) {
  final routeGateStatus = _stringValue(task['route_gate_status']);
  final worldNumbers = [
    _worldNumber(task['world_id']),
    _worldNumber(task['route_world_id']),
    _worldNumber(task['content_owner_world_id']),
  ].whereType<int>().toSet();

  if (routeGateStatus == 'learner_playable') {
    for (final worldNumber in worldNumbers) {
      if (worldNumber >= 7 && worldNumber <= 10) {
        routeAdmissionErrors.add(
          'world_$worldNumber must not be learner_playable before route '
          'admission',
        );
      }
      if (worldNumber >= 11 && worldNumber <= 12 && !_hasRouteAdmission(task)) {
        routeAdmissionErrors.add(
          'world_$worldNumber learner_playable requires explicit route '
          'admission metadata',
        );
      }
    }
  }
}

void _validateBridgeClaimSafety(
  Map<String, Object?> task,
  List<String> warnings,
  List<String> routeAdmissionErrors,
) {
  if (task['source_truth_status'] != 'bridge_or_legacy') return;
  final worldId = _stringValue(task['world_id']) ?? 'world_unknown';
  if (task['safe_claim_status'] != 'limited_bridge') {
    warnings.add(
      '$worldId bridge_or_legacy content is reportable but not canonical '
      'launch coverage',
    );
  }
  if (task['launch_coverage_claimed'] == true) {
    routeAdmissionErrors.add(
      '$worldId bridge_or_legacy content must not claim launch coverage',
    );
  }
}

void _validateLaunchScopeClaims(
  Map<String, Object?> task,
  List<String> routeAdmissionErrors,
) {
  final worldNumbers = [
    _worldNumber(task['world_id']),
    _worldNumber(task['route_world_id']),
    _worldNumber(task['content_owner_world_id']),
  ].whereType<int>().toSet();

  if (!worldNumbers.any((number) => number >= 13 && number <= 36)) return;

  final claimedLaunchAvailable =
      task['launch_available'] == true ||
      task['prelaunch_required'] == true ||
      task['launch_status'] == 'launch_available' ||
      task['launch_status'] == 'prelaunch_required' ||
      task['launch_scope_status'] == 'launch_available' ||
      task['launch_scope_status'] == 'prelaunch_required';

  if (!claimedLaunchAvailable) return;
  final worldNumber = worldNumbers.firstWhere(
    (number) => number >= 13 && number <= 36,
  );
  routeAdmissionErrors.add(
    'world_$worldNumber must not be marked launch_available before launch',
  );
}

bool _hasRouteAdmission(Map<String, Object?> task) {
  final routeAdmission = task['route_admission'];
  if (routeAdmission is! Map) return false;
  return routeAdmission['admission_status'] == 'admitted' &&
      _stringValue(routeAdmission['admission_artifact']) != null;
}

String? _stringValue(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

int? _worldNumber(Object? value) {
  final worldId = _stringValue(value);
  if (worldId == null) return null;
  final match = _worldIdPattern.firstMatch(worldId);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

class ContentSchemaL2L3ValidationResultV1 {
  const ContentSchemaL2L3ValidationResultV1({
    required this.fixtureCount,
    required this.totalTasks,
    required this.coverageCountableTasks,
    required this.worldReports,
    required this.errors,
    required this.routeAdmissionErrors,
    required this.warnings,
  });

  final int fixtureCount;
  final int totalTasks;
  final int coverageCountableTasks;
  final Map<String, ContentSchemaWorldL2L3ReportV1> worldReports;
  final List<String> errors;
  final List<String> routeAdmissionErrors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty && routeAdmissionErrors.isEmpty;

  ContentSchemaL2L3ValidationResultV1 copyWith({
    int? fixtureCount,
    List<String>? errors,
  }) {
    return ContentSchemaL2L3ValidationResultV1(
      fixtureCount: fixtureCount ?? this.fixtureCount,
      totalTasks: totalTasks,
      coverageCountableTasks: coverageCountableTasks,
      worldReports: worldReports,
      errors: errors ?? this.errors,
      routeAdmissionErrors: routeAdmissionErrors,
      warnings: warnings,
    );
  }
}

class ContentSchemaWorldL2L3ReportV1 {
  const ContentSchemaWorldL2L3ReportV1({
    required this.worldId,
    required this.totalTasks,
    required this.coverageCountableTasks,
    required this.previewOnlyTasks,
    required this.conceptFamilyCounts,
    required this.sameSignalGroupCounts,
    required this.transferSurfaceCounts,
    required this.repairFocusCounts,
    required this.sourceTruthStatusCounts,
    required this.validationStatusCounts,
    required this.migrationSourceCount,
    required this.coverageReady,
    required this.transferReady,
    required this.repairReady,
    required this.routeAdmissionStatus,
  });

  final String worldId;
  final int totalTasks;
  final int coverageCountableTasks;
  final int previewOnlyTasks;
  final Map<String, int> conceptFamilyCounts;
  final Map<String, int> sameSignalGroupCounts;
  final Map<String, int> transferSurfaceCounts;
  final Map<String, int> repairFocusCounts;
  final Map<String, int> sourceTruthStatusCounts;
  final Map<String, int> validationStatusCounts;
  final int migrationSourceCount;
  final bool coverageReady;
  final bool transferReady;
  final bool repairReady;
  final String routeAdmissionStatus;
}

class _WorldReportBuilderV1 {
  _WorldReportBuilderV1(this.worldId);

  final String worldId;
  var totalTasks = 0;
  var coverageCountableTasks = 0;
  var previewOnlyTasks = 0;
  var migrationSourceCount = 0;
  final conceptFamilyCounts = <String, int>{};
  final sameSignalGroupCounts = <String, int>{};
  final transferSurfaceCounts = <String, int>{};
  final repairFocusCounts = <String, int>{};
  final sourceTruthStatusCounts = <String, int>{};
  final validationStatusCounts = <String, int>{};
  final sourceTruthStatuses = <String>{};
  final routeGateStatuses = <String>{};

  void addTask(Map<String, Object?> task) {
    totalTasks++;
    final previewOnly = task['preview_only'] == true;
    if (previewOnly) {
      previewOnlyTasks++;
    } else {
      coverageCountableTasks++;
    }

    _incrementIfPresent(conceptFamilyCounts, task['concept_family_id']);
    if (!previewOnly) {
      _incrementIfPresent(sameSignalGroupCounts, task['same_signal_group_id']);
      _incrementIfPresent(transferSurfaceCounts, task['transfer_surface_id']);
      _incrementIfPresent(repairFocusCounts, task['repair_focus_id']);
    }
    _incrementIfPresent(sourceTruthStatusCounts, task['source_truth_status']);
    _incrementIfPresent(validationStatusCounts, task['validation_status']);

    final sourceTruthStatus = _stringValue(task['source_truth_status']);
    if (sourceTruthStatus != null) sourceTruthStatuses.add(sourceTruthStatus);
    final routeGateStatus = _stringValue(task['route_gate_status']);
    if (routeGateStatus != null) routeGateStatuses.add(routeGateStatus);

    final migrationSource = task['migration_source'];
    if (migrationSource is Map &&
        _stringValue(migrationSource['source_path']) != null) {
      migrationSourceCount++;
    }
  }

  ContentSchemaWorldL2L3ReportV1 build({
    required bool hasCoverageErrors,
    required bool hasRouteAdmissionErrors,
  }) {
    final hasBridge = sourceTruthStatuses.contains('bridge_or_legacy');
    final hasLearnerPlayable = routeGateStatuses.contains('learner_playable');
    final hasNonRouteReadyGate = routeGateStatuses.any(
      (status) =>
          status == 'locked_preview' ||
          status == 'internal_only' ||
          status == 'authored_but_not_routed' ||
          status == 'planned_only' ||
          status == 'blocked',
    );

    final coverageReady =
        !hasCoverageErrors &&
        !hasBridge &&
        sameSignalGroupCounts.values.any((count) => count >= 5);
    final transferReady = !hasCoverageErrors && _hasAtLeastTwoTransferSurfaces;
    final repairReady = !hasCoverageErrors && repairFocusCounts.isNotEmpty;

    return ContentSchemaWorldL2L3ReportV1(
      worldId: worldId,
      totalTasks: totalTasks,
      coverageCountableTasks: coverageCountableTasks,
      previewOnlyTasks: previewOnlyTasks,
      conceptFamilyCounts: Map.unmodifiable(conceptFamilyCounts),
      sameSignalGroupCounts: Map.unmodifiable(sameSignalGroupCounts),
      transferSurfaceCounts: Map.unmodifiable(transferSurfaceCounts),
      repairFocusCounts: Map.unmodifiable(repairFocusCounts),
      sourceTruthStatusCounts: Map.unmodifiable(sourceTruthStatusCounts),
      validationStatusCounts: Map.unmodifiable(validationStatusCounts),
      migrationSourceCount: migrationSourceCount,
      coverageReady: coverageReady,
      transferReady: transferReady,
      repairReady: repairReady,
      routeAdmissionStatus: _routeAdmissionStatus(
        hasBridge: hasBridge,
        hasLearnerPlayable: hasLearnerPlayable,
        hasNonRouteReadyGate: hasNonRouteReadyGate,
        hasRouteAdmissionErrors: hasRouteAdmissionErrors,
      ),
    );
  }

  bool get _hasAtLeastTwoTransferSurfaces =>
      transferSurfaceCounts.keys.toSet().length >= 2;

  String _routeAdmissionStatus({
    required bool hasBridge,
    required bool hasLearnerPlayable,
    required bool hasNonRouteReadyGate,
    required bool hasRouteAdmissionErrors,
  }) {
    if (hasRouteAdmissionErrors) return 'route_admission_blocked';
    if (hasBridge) return 'bridge_or_legacy_limited';
    if (hasNonRouteReadyGate) return 'not_route_ready';
    if (hasLearnerPlayable) return 'learner_playable_route_ready';
    return 'internal_report_only';
  }
}

void _incrementIfPresent(Map<String, int> counts, Object? value) {
  final stringValue = _stringValue(value);
  if (stringValue == null) return;
  counts[stringValue] = (counts[stringValue] ?? 0) + 1;
}

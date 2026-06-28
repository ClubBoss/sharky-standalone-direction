import 'dart:convert';
import 'dart:io';

const String defaultContentSchemaFoundationFixturePathV1 =
    'test/fixtures/content_schema_foundation/w1_schema_l0_valid_fixture_v1.json';

const Set<String> _sourceTruthStatuses = {
  'canonical',
  'bridge_or_legacy',
  'preview_only',
  'migrated',
  'blocked_conflict',
};

const Set<String> _routeGateStatuses = {
  'learner_playable',
  'locked_preview',
  'internal_only',
  'authored_but_not_routed',
  'planned_only',
  'blocked',
};

const Set<String> _validationStatuses = {
  'draft',
  'source_validated',
  'runtime_validated',
  'poker_review_needed',
  'poker_reviewed',
  'blocked',
};

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

const List<String> _idFields = [
  'world_id',
  'route_world_id',
  'content_owner_world_id',
  'lesson_id',
  'session_id',
  'pack_id',
  'task_id',
  'chain_id',
  'chain_step_id',
  'concept_family_id',
  'repair_focus_id',
  'same_signal_group_id',
  'transfer_surface_id',
  'misconception_id',
  'drill_kind',
  'locale_key',
  'copy_key',
];

final RegExp _stableIdPattern = RegExp(r'^[a-z0-9_.-]+$');
final RegExp _worldIdPattern = RegExp(r'^world_(\d+)$');

Future<void> main(List<String> args) async {
  final paths = args.isEmpty
      ? [defaultContentSchemaFoundationFixturePathV1]
      : args;
  var hasErrors = false;

  for (final path in paths) {
    final result = validateContentSchemaFoundationFixtureV1(File(path));
    stdout.writeln(
      'content_schema_foundation_validator_v1: ${result.path} '
      'tasks=${result.tasksChecked} coverage_countable=${result.coverageCountableTasks}',
    );
    if (result.errors.isEmpty) {
      stdout.writeln('content_schema_foundation_validator_v1: OK');
      continue;
    }
    hasErrors = true;
    for (final error in result.errors) {
      stderr.writeln('content_schema_foundation_validator_v1: $error');
    }
  }

  if (hasErrors) {
    exitCode = 2;
  }
}

ContentSchemaFoundationValidationResultV1
validateContentSchemaFoundationFixtureV1(File file) {
  if (!file.existsSync()) {
    return ContentSchemaFoundationValidationResultV1(
      path: file.path,
      tasksChecked: 0,
      coverageCountableTasks: 0,
      errors: ['fixture not found: ${file.path}'],
    );
  }

  Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on FormatException catch (error) {
    return ContentSchemaFoundationValidationResultV1(
      path: file.path,
      tasksChecked: 0,
      coverageCountableTasks: 0,
      errors: ['invalid JSON: ${error.message}'],
    );
  }

  if (decoded is! Map<String, Object?>) {
    return ContentSchemaFoundationValidationResultV1(
      path: file.path,
      tasksChecked: 0,
      coverageCountableTasks: 0,
      errors: ['fixture root must be a JSON object'],
    );
  }

  return validateContentSchemaFoundationMapV1(decoded, path: file.path);
}

ContentSchemaFoundationValidationResultV1 validateContentSchemaFoundationMapV1(
  Map<Object?, Object?> fixture, {
  String path = '<memory>',
}) {
  final errors = <String>[];

  if (!_isAscii(jsonEncode(fixture))) {
    errors.add('fixture contains non-ASCII text');
  }

  final rawTasks = fixture['tasks'];
  if (rawTasks is! List) {
    return ContentSchemaFoundationValidationResultV1(
      path: path,
      tasksChecked: 0,
      coverageCountableTasks: 0,
      errors: [...errors, 'fixture missing tasks array'],
    );
  }

  final seenTaskIds = <String>{};
  var checked = 0;
  var coverageCountable = 0;

  for (var index = 0; index < rawTasks.length; index++) {
    final rawTask = rawTasks[index];
    final label = 'tasks[$index]';
    if (rawTask is! Map) {
      errors.add('$label must be a JSON object');
      continue;
    }
    checked++;
    final task = rawTask.cast<String, Object?>();

    if (!_isAscii(jsonEncode(task))) {
      errors.add('$label contains non-ASCII text');
    }

    for (final field in _requiredFields) {
      if (!_hasPresentValue(task[field])) {
        errors.add('$label missing required field $field');
      }
    }

    _validateActionFields(task, label, errors);
    _validateAllowedValue(
      task,
      label,
      errors,
      field: 'source_truth_status',
      allowedValues: _sourceTruthStatuses,
    );
    _validateAllowedValue(
      task,
      label,
      errors,
      field: 'route_gate_status',
      allowedValues: _routeGateStatuses,
    );
    _validateAllowedValue(
      task,
      label,
      errors,
      field: 'validation_status',
      allowedValues: _validationStatuses,
    );
    _validateIdFields(task, label, errors);
    _validateConditionalFields(task, label, errors);
    _validatePreviewOnly(task, label, errors);
    _validateRouteGate(task, label, errors);

    final taskId = task['task_id'];
    if (taskId is String && taskId.isNotEmpty && !seenTaskIds.add(taskId)) {
      errors.add('$label duplicate task_id: $taskId');
    }

    if (task['preview_only'] == false) {
      coverageCountable++;
    }
  }

  return ContentSchemaFoundationValidationResultV1(
    path: path,
    tasksChecked: checked,
    coverageCountableTasks: coverageCountable,
    errors: errors,
  );
}

void _validateActionFields(
  Map<String, Object?> task,
  String label,
  List<String> errors,
) {
  final correctAction = task['correct_action'];
  final acceptableActions = task['acceptable_actions'];
  final hasCorrectAction = correctAction is String && correctAction.isNotEmpty;
  final hasAcceptableAction =
      acceptableActions is List && acceptableActions.isNotEmpty;
  if (!hasCorrectAction && !hasAcceptableAction) {
    errors.add('$label missing correct_action or acceptable_actions');
  }
}

void _validateAllowedValue(
  Map<String, Object?> task,
  String label,
  List<String> errors, {
  required String field,
  required Set<String> allowedValues,
}) {
  final value = task[field];
  if (value is! String || value.isEmpty) return;
  if (!allowedValues.contains(value)) {
    errors.add('$label invalid $field: $value');
  }
}

void _validateIdFields(
  Map<String, Object?> task,
  String label,
  List<String> errors,
) {
  for (final field in _idFields) {
    final value = task[field];
    if (value == null) continue;
    if (value is! String || value.isEmpty) continue;
    if (!_stableIdPattern.hasMatch(value)) {
      errors.add('$label invalid $field format: $value');
    }
  }
}

void _validateConditionalFields(
  Map<String, Object?> task,
  String label,
  List<String> errors,
) {
  if (task['repairable'] == true &&
      !_hasPresentValue(task['repair_focus_id'])) {
    errors.add('$label repairable task missing repair_focus_id');
  }
  if (task['claims_same_signal'] == true &&
      !_hasPresentValue(task['same_signal_group_id'])) {
    errors.add('$label same-signal task missing same_signal_group_id');
  }
  if (task['claims_transfer'] == true &&
      !_hasPresentValue(task['transfer_surface_id'])) {
    errors.add('$label transfer task missing transfer_surface_id');
  }
}

void _validatePreviewOnly(
  Map<String, Object?> task,
  String label,
  List<String> errors,
) {
  final previewOnly = task['preview_only'];
  if (previewOnly is! bool) {
    errors.add('$label preview_only must be boolean');
  }
}

void _validateRouteGate(
  Map<String, Object?> task,
  String label,
  List<String> errors,
) {
  if (task['route_gate_status'] != 'learner_playable') return;

  final worldIds = [
    task['world_id'],
    task['route_world_id'],
    task['content_owner_world_id'],
  ];
  for (final value in worldIds) {
    final worldNumber = _worldNumber(value);
    if (worldNumber != null && worldNumber >= 7 && worldNumber <= 12) {
      errors.add('$label $value cannot use learner_playable route_gate_status');
      return;
    }
  }
}

int? _worldNumber(Object? value) {
  if (value is! String) return null;
  final match = _worldIdPattern.firstMatch(value);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

bool _hasPresentValue(Object? value) {
  if (value == null) return false;
  if (value is String) return value.isNotEmpty;
  if (value is List) return value.isNotEmpty;
  return true;
}

bool _isAscii(String value) => value.codeUnits.every((unit) => unit <= 0x7F);

class ContentSchemaFoundationValidationResultV1 {
  const ContentSchemaFoundationValidationResultV1({
    required this.path,
    required this.tasksChecked,
    required this.coverageCountableTasks,
    required this.errors,
  });

  final String path;
  final int tasksChecked;
  final int coverageCountableTasks;
  final List<String> errors;

  bool get isValid => errors.isEmpty;
}

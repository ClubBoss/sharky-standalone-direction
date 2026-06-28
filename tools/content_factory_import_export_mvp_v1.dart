import 'dart:convert';
import 'dart:io';

import 'content_schema_foundation_validator_v1.dart';

const String _schemaVersion = 'content_schema_foundation_v1';
const String _outputDir = 'test/fixtures/content_factory_mvp';

const JsonEncoder _prettyJson = JsonEncoder.withIndent('  ');

Future<void> main(List<String> args) async {
  final results = exportTinyContentFactorySamplesV1(writeFiles: true);
  var hasErrors = false;

  for (final result in results) {
    final validation = validateContentSchemaFoundationMapV1(
      result.fixture,
      path: result.outputPath,
    );
    stdout.writeln(
      'content_factory_import_export_mvp_v1: wrote ${result.outputPath} '
      'tasks=${validation.tasksChecked} '
      'coverage_countable=${validation.coverageCountableTasks}',
    );
    if (validation.errors.isNotEmpty) {
      hasErrors = true;
      for (final error in validation.errors) {
        stderr.writeln('content_factory_import_export_mvp_v1: $error');
      }
    }
  }

  if (hasErrors) {
    exitCode = 2;
    return;
  }

  stdout.writeln('content_factory_import_export_mvp_v1: OK');
}

List<ContentFactoryImportExportResultV1> exportTinyContentFactorySamplesV1({
  bool writeFiles = false,
}) {
  final samples = [
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json',
      outputPath: '$_outputDir/w1_import_export_sample_v1.json',
      fixtureId: 'w1_import_export_sample_v1',
      fixtureLevel: 'content_factory_import_export_mvp',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l01',
      sessionId: 'w1.s01',
      packId: 'world1_spine_campaign_v1',
      taskId: 'w1.s01.choose_fold.import_export_sample_v1',
      conceptFamilyId: 'starting_hand_discipline',
      repairFocusId: 'release_weak_continue',
      sameSignalGroupId: 'w1.starting_hand_discipline.release_under_pressure',
      misconceptionId: 'continues_after_pressure_without_strength',
      sourceTruthStatus: 'migrated',
      feedbackReason:
          'Fold preserves the stack when a weak starting hand has no release '
          'permission.',
      sourceJob: 'w1_canonical_hand_discipline_sample',
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world2/v1/sessions/w2.s01/drills/'
          'd.choose_fold_early.json',
      outputPath:
          '$_outputDir/w2_bridge_or_legacy_import_export_sample_v1.json',
      fixtureId: 'w2_bridge_or_legacy_import_export_sample_v1',
      fixtureLevel: 'content_factory_import_export_mvp_bridge',
      worldId: 'world_2',
      routeWorldId: 'world_2',
      displayWorldTitle: 'Hand Discipline',
      contentOwnerWorldId: 'world_2',
      routeGateStatus: 'learner_playable',
      lessonId: 'w2.l01',
      sessionId: 'w2.s01',
      packId: 'world2_spine_campaign_v1',
      taskId: 'w2.s01.choose_fold_early.import_export_sample_v1',
      conceptFamilyId: 'position_btn_vs_early',
      repairFocusId: 'early_position_weak_hand_release',
      sameSignalGroupId: 'w2.position_btn_vs_early.weak_start_release',
      misconceptionId: 'enters_pot_from_early_weak_start',
      sourceTruthStatus: 'bridge_or_legacy',
      feedbackReason: null,
      sourceJob: 'table_reading_bridge',
    ),
  ];

  final results = [
    ...samples.map(_exportSample),
    exportW1WorldCoveragePilotV1(writeFiles: false),
    exportW2BridgeSchemaMigrationPilotV1(writeFiles: false),
  ];
  if (writeFiles) {
    Directory(_outputDir).createSync(recursive: true);
    for (final result in results) {
      File(
        result.outputPath,
      ).writeAsStringSync('${_prettyJson.convert(result.fixture)}\n');
    }
  }
  return results;
}

ContentFactoryImportExportResultV1 exportW1WorldCoveragePilotV1({
  bool writeFiles = false,
}) {
  final specs = [
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s02/drills/'
          'd.choose_button_open_clean_v1.json',
      outputPath: '',
      fixtureId: 'w1_world_coverage_pilot_v1',
      fixtureLevel: 'w1_world_coverage_expansion_pilot',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l02',
      sessionId: 'w1.s02',
      packId: 'world1_spine_campaign_v1',
      taskId: 'w1.s02.choose_button_open_clean_v1.coverage_pilot_v1',
      conceptFamilyId: 'position_action_order',
      repairFocusId: 'position_before_action',
      sameSignalGroupId: 'w1.position_action_order.first_in_or_facing_pressure',
      transferSurfaceId: 'first_in_action_order_v1',
      misconceptionId: 'acts_without_reading_position',
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_action_order_pressure_pilot',
      claimsTransfer: true,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s02/drills/'
          'd.choose_big_blind_continue_defend_v1.json',
      outputPath: '',
      fixtureId: 'w1_world_coverage_pilot_v1',
      fixtureLevel: 'w1_world_coverage_expansion_pilot',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l02',
      sessionId: 'w1.s02',
      packId: 'world1_spine_campaign_v1',
      taskId: 'w1.s02.choose_big_blind_continue_defend_v1.coverage_pilot_v1',
      conceptFamilyId: 'position_action_order',
      repairFocusId: 'position_before_action',
      sameSignalGroupId: 'w1.position_action_order.first_in_or_facing_pressure',
      transferSurfaceId: 'facing_open_pressure_v1',
      misconceptionId: 'acts_without_reading_position',
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_action_order_pressure_pilot',
      claimsTransfer: true,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s02/drills/'
          'd.choose_small_blind_release_caution_v1.json',
      outputPath: '',
      fixtureId: 'w1_world_coverage_pilot_v1',
      fixtureLevel: 'w1_world_coverage_expansion_pilot',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l02',
      sessionId: 'w1.s02',
      packId: 'world1_spine_campaign_v1',
      taskId: 'w1.s02.choose_small_blind_release_caution_v1.coverage_pilot_v1',
      conceptFamilyId: 'position_action_order',
      repairFocusId: 'position_before_action',
      sameSignalGroupId: 'w1.position_action_order.first_in_or_facing_pressure',
      transferSurfaceId: 'facing_open_pressure_v1',
      misconceptionId: 'acts_without_reading_position',
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_action_order_pressure_pilot',
      claimsTransfer: true,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s03/drills/'
          'd.choose_first_in_raise_after_folds_v1.json',
      outputPath: '',
      fixtureId: 'w1_world_coverage_pilot_v1',
      fixtureLevel: 'w1_world_coverage_expansion_pilot',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l03',
      sessionId: 'w1.s03',
      packId: 'world1_spine_campaign_v1',
      taskId: 'w1.s03.choose_first_in_raise_after_folds_v1.coverage_pilot_v1',
      conceptFamilyId: 'position_action_order',
      repairFocusId: 'position_before_action',
      sameSignalGroupId: 'w1.position_action_order.first_in_or_facing_pressure',
      transferSurfaceId: 'first_in_action_order_v1',
      misconceptionId: 'acts_without_reading_position',
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_action_order_pressure_pilot',
      claimsTransfer: true,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s03/drills/'
          'd.choose_call_when_pressure_reaches_you_v1.json',
      outputPath: '',
      fixtureId: 'w1_world_coverage_pilot_v1',
      fixtureLevel: 'w1_world_coverage_expansion_pilot',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l03',
      sessionId: 'w1.s03',
      packId: 'world1_spine_campaign_v1',
      taskId:
          'w1.s03.choose_call_when_pressure_reaches_you_v1.coverage_pilot_v1',
      conceptFamilyId: 'position_action_order',
      repairFocusId: 'position_before_action',
      sameSignalGroupId: 'w1.position_action_order.first_in_or_facing_pressure',
      transferSurfaceId: 'facing_open_pressure_v1',
      misconceptionId: 'acts_without_reading_position',
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_action_order_pressure_pilot',
      claimsTransfer: true,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world1/v1/sessions/w1.s03/drills/'
          'd.choose_fold_when_multiway_pressure_stacks_v1.json',
      outputPath: '',
      fixtureId: 'w1_world_coverage_pilot_v1',
      fixtureLevel: 'w1_world_coverage_expansion_pilot',
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l03',
      sessionId: 'w1.s03',
      packId: 'world1_spine_campaign_v1',
      taskId:
          'w1.s03.choose_fold_when_multiway_pressure_stacks_v1.coverage_pilot_v1',
      conceptFamilyId: 'position_action_order',
      repairFocusId: 'position_before_action',
      sameSignalGroupId: 'w1.position_action_order.first_in_or_facing_pressure',
      transferSurfaceId: 'multiway_pressure_v1',
      misconceptionId: 'acts_without_reading_position',
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_action_order_pressure_pilot',
      claimsTransfer: true,
    ),
  ];

  final tasks = specs
      .map((spec) => _exportSample(spec).task!)
      .toList(growable: false);
  final fixture = <String, Object?>{
    'schema_version': _schemaVersion,
    'fixture_id': 'w1_world_coverage_pilot_v1',
    'fixture_level': 'w1_world_coverage_expansion_pilot',
    'generated_by': 'content_factory_import_export_mvp_v1',
    'tasks': tasks,
  };
  final result = ContentFactoryImportExportResultV1(
    outputPath: '$_outputDir/w1_world_coverage_pilot_v1.json',
    fixture: fixture,
  );

  if (writeFiles) {
    Directory(_outputDir).createSync(recursive: true);
    File(
      result.outputPath,
    ).writeAsStringSync('${_prettyJson.convert(result.fixture)}\n');
  }
  return result;
}

ContentFactoryImportExportResultV1 exportW2BridgeSchemaMigrationPilotV1({
  bool writeFiles = false,
}) {
  final specs = [
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world2/v1/sessions/w2.s01/drills/'
          'd.choose_fold_early.json',
      outputPath: '',
      fixtureId: 'w2_bridge_or_legacy_schema_migration_pilot_v1',
      fixtureLevel: 'w1_w6_schema_migration_bridge_pilot',
      worldId: 'world_2',
      routeWorldId: 'world_2',
      displayWorldTitle: 'Hand Discipline',
      contentOwnerWorldId: 'world_2',
      routeGateStatus: 'learner_playable',
      lessonId: 'w2.l01',
      sessionId: 'w2.s01',
      packId: 'world2_spine_campaign_v1',
      taskId: 'w2.s01.choose_fold_early.schema_migration_pilot_v1',
      conceptFamilyId: 'position_btn_vs_early',
      repairFocusId: 'position_price_action_default',
      sameSignalGroupId: 'w2.position_btn_vs_early.bridge_action_default',
      transferSurfaceId: 'early_position_release_v1',
      misconceptionId: 'acts_before_reading_position_or_price',
      sourceTruthStatus: 'bridge_or_legacy',
      feedbackReason: null,
      sourceJob: 'table_reading_bridge',
      claimsTransfer: true,
      safeClaimStatus: 'limited_bridge',
      launchCoverageClaimed: false,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world2/v1/sessions/w2.s01/drills/'
          'd.choose_call_vs_open.json',
      outputPath: '',
      fixtureId: 'w2_bridge_or_legacy_schema_migration_pilot_v1',
      fixtureLevel: 'w1_w6_schema_migration_bridge_pilot',
      worldId: 'world_2',
      routeWorldId: 'world_2',
      displayWorldTitle: 'Hand Discipline',
      contentOwnerWorldId: 'world_2',
      routeGateStatus: 'learner_playable',
      lessonId: 'w2.l01',
      sessionId: 'w2.s01',
      packId: 'world2_spine_campaign_v1',
      taskId: 'w2.s01.choose_call_vs_open.schema_migration_pilot_v1',
      conceptFamilyId: 'position_btn_vs_early',
      repairFocusId: 'position_price_action_default',
      sameSignalGroupId: 'w2.position_btn_vs_early.bridge_action_default',
      transferSurfaceId: 'facing_open_price_v1',
      misconceptionId: 'acts_before_reading_position_or_price',
      sourceTruthStatus: 'bridge_or_legacy',
      feedbackReason: null,
      sourceJob: 'table_reading_bridge',
      claimsTransfer: true,
      safeClaimStatus: 'limited_bridge',
      launchCoverageClaimed: false,
    ),
    _FactorySampleSpecV1(
      sourcePath:
          'content/worlds/world2/v1/sessions/w2.s01/drills/'
          'd.choose_raise_btn.json',
      outputPath: '',
      fixtureId: 'w2_bridge_or_legacy_schema_migration_pilot_v1',
      fixtureLevel: 'w1_w6_schema_migration_bridge_pilot',
      worldId: 'world_2',
      routeWorldId: 'world_2',
      displayWorldTitle: 'Hand Discipline',
      contentOwnerWorldId: 'world_2',
      routeGateStatus: 'learner_playable',
      lessonId: 'w2.l01',
      sessionId: 'w2.s01',
      packId: 'world2_spine_campaign_v1',
      taskId: 'w2.s01.choose_raise_btn.schema_migration_pilot_v1',
      conceptFamilyId: 'position_btn_vs_early',
      repairFocusId: 'position_price_action_default',
      sameSignalGroupId: 'w2.position_btn_vs_early.bridge_action_default',
      transferSurfaceId: 'late_position_open_v1',
      misconceptionId: 'acts_before_reading_position_or_price',
      sourceTruthStatus: 'bridge_or_legacy',
      feedbackReason: null,
      sourceJob: 'table_reading_bridge',
      claimsTransfer: true,
      safeClaimStatus: 'limited_bridge',
      launchCoverageClaimed: false,
    ),
  ];

  final tasks = specs
      .map((spec) => _exportSample(spec).task!)
      .toList(growable: false);
  final fixture = <String, Object?>{
    'schema_version': _schemaVersion,
    'fixture_id': 'w2_bridge_or_legacy_schema_migration_pilot_v1',
    'fixture_level': 'w1_w6_schema_migration_bridge_pilot',
    'generated_by': 'content_factory_import_export_mvp_v1',
    'tasks': tasks,
  };
  final result = ContentFactoryImportExportResultV1(
    outputPath:
        '$_outputDir/w2_bridge_or_legacy_schema_migration_pilot_v1.json',
    fixture: fixture,
  );

  if (writeFiles) {
    Directory(_outputDir).createSync(recursive: true);
    File(
      result.outputPath,
    ).writeAsStringSync('${_prettyJson.convert(result.fixture)}\n');
  }
  return result;
}

ContentFactoryImportExportResultV1 _exportSample(_FactorySampleSpecV1 spec) {
  final sourceFile = File(spec.sourcePath);
  if (!sourceFile.existsSync()) {
    throw StateError('source task not found: ${spec.sourcePath}');
  }

  final decoded = jsonDecode(sourceFile.readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    throw FormatException(
      'source task root must be an object',
      spec.sourcePath,
    );
  }

  final sourceId = _requiredString(decoded, 'id', spec.sourcePath);
  final sourceKind = _requiredString(decoded, 'kind', spec.sourcePath);
  final sourceIntent = _requiredString(decoded, 'intent_v1', spec.sourcePath);
  final sourceErrorClass = _requiredString(
    decoded,
    'error_class',
    spec.sourcePath,
  );
  final correctAction = _expectedAction(decoded, spec.sourcePath);
  final feedbackReason =
      spec.feedbackReason ??
      _requiredString(decoded, 'why_v1', spec.sourcePath);

  final task = <String, Object?>{
    'schema_version': _schemaVersion,
    'world_id': spec.worldId,
    'route_world_id': spec.routeWorldId,
    'display_world_title': spec.displayWorldTitle,
    'content_owner_world_id': spec.contentOwnerWorldId,
    'route_gate_status': spec.routeGateStatus,
    'lesson_id': spec.lessonId,
    'session_id': spec.sessionId,
    'pack_id': spec.packId,
    'task_id': spec.taskId,
    'concept_family_id': spec.conceptFamilyId,
    'repairable': true,
    'repair_focus_id': spec.repairFocusId,
    'claims_same_signal': true,
    'same_signal_group_id': spec.sameSignalGroupId,
    'claims_transfer': spec.claimsTransfer,
    'transfer_surface_id': spec.transferSurfaceId,
    'misconception_id': spec.misconceptionId,
    'drill_kind': sourceKind,
    'correct_action': correctAction,
    'acceptable_actions': <String>[],
    'feedback_reason': feedbackReason,
    'validation_status': 'source_validated',
    'preview_only': false,
    'source_truth_status': spec.sourceTruthStatus,
    'locale_key': spec.taskId.replaceAll('.', '_'),
    if (spec.safeClaimStatus != null) 'safe_claim_status': spec.safeClaimStatus,
    if (spec.launchCoverageClaimed != null)
      'launch_coverage_claimed': spec.launchCoverageClaimed,
    'migration_source': <String, Object?>{
      'source_path': spec.sourcePath,
      'source_id': sourceId,
      'source_kind': sourceKind,
      'source_intent_v1': sourceIntent,
      'source_expected_action': correctAction,
      'source_error_class': sourceErrorClass,
      'source_job': spec.sourceJob,
      'source_transform': 'tiny_content_factory_import_export_mvp_v1',
    },
  };

  final fixture = <String, Object?>{
    'schema_version': _schemaVersion,
    'fixture_id': spec.fixtureId,
    'fixture_level': spec.fixtureLevel,
    'generated_by': 'content_factory_import_export_mvp_v1',
    'tasks': [task],
  };

  return ContentFactoryImportExportResultV1(
    outputPath: spec.outputPath,
    fixture: fixture,
    task: task,
  );
}

String _requiredString(Map<String, Object?> source, String field, String path) {
  final value = source[field];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('source task missing required string $field', path);
}

String _expectedAction(Map<String, Object?> source, String path) {
  final expected = source['expected'];
  if (expected is Map) {
    final actionId = expected['actionId'];
    if (actionId is String && actionId.isNotEmpty) return actionId;
  }
  throw FormatException('source task missing expected.actionId', path);
}

class ContentFactoryImportExportResultV1 {
  const ContentFactoryImportExportResultV1({
    required this.outputPath,
    required this.fixture,
    this.task,
  });

  final String outputPath;
  final Map<String, Object?> fixture;
  final Map<String, Object?>? task;
}

class _FactorySampleSpecV1 {
  const _FactorySampleSpecV1({
    required this.sourcePath,
    required this.outputPath,
    required this.fixtureId,
    required this.fixtureLevel,
    required this.worldId,
    required this.routeWorldId,
    required this.displayWorldTitle,
    required this.contentOwnerWorldId,
    required this.routeGateStatus,
    required this.lessonId,
    required this.sessionId,
    required this.packId,
    required this.taskId,
    required this.conceptFamilyId,
    required this.repairFocusId,
    required this.sameSignalGroupId,
    this.transferSurfaceId,
    required this.misconceptionId,
    required this.sourceTruthStatus,
    required this.feedbackReason,
    required this.sourceJob,
    this.claimsTransfer = false,
    this.safeClaimStatus,
    this.launchCoverageClaimed,
  });

  final String sourcePath;
  final String outputPath;
  final String fixtureId;
  final String fixtureLevel;
  final String worldId;
  final String routeWorldId;
  final String displayWorldTitle;
  final String contentOwnerWorldId;
  final String routeGateStatus;
  final String lessonId;
  final String sessionId;
  final String packId;
  final String taskId;
  final String conceptFamilyId;
  final String repairFocusId;
  final String sameSignalGroupId;
  final String? transferSurfaceId;
  final String misconceptionId;
  final String sourceTruthStatus;
  final String? feedbackReason;
  final String sourceJob;
  final bool claimsTransfer;
  final String? safeClaimStatus;
  final bool? launchCoverageClaimed;
}

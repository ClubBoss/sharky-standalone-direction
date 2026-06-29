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
    exportW1StartingHandDisciplineBatch1V1(writeFiles: false),
    exportW1SeatRoleOrientationPr2V1(writeFiles: false),
    exportW1CardBoardOrientationPr2V1(writeFiles: false),
    exportW1BetSizeVocabularyPreviewPr3V1(writeFiles: false),
    exportW1CheckpointSynthesisPr3V1(writeFiles: false),
    exportW1ShowdownBasicsSourceAuthorshipRepairV1(writeFiles: false),
    exportW2BridgeSchemaMigrationPilotV1(writeFiles: false),
    exportW2CanonicalCertificationPilotV1(writeFiles: false),
    exportW2FacingPriceDisciplineCanonicalPr2V1(writeFiles: false),
    exportW2ApprovedRaiseDisciplineCanonicalPr3V1(writeFiles: false),
    exportW3BridgeSchemaMigrationPilotV1(writeFiles: false),
    exportW3CanonicalCertificationPilotV1(writeFiles: false),
    exportW3HandBucketActionFrameCanonicalPr2V1(writeFiles: false),
    exportW4BridgeSchemaMigrationPilotV1(writeFiles: false),
    exportW4PriceGivenBeforeActionCanonicalPilotV1(writeFiles: false),
    exportW4IntentActionDisciplineCanonicalPr2V1(writeFiles: false),
    exportW5BridgeSchemaMigrationPilotV1(writeFiles: false),
    exportW5BoardTextureClassificationCanonicalPilotV1(writeFiles: false),
    exportW5BoardShiftAwarenessCanonicalPr2V1(writeFiles: false),
    exportW6BridgeSchemaMigrationPilotV1(writeFiles: false),
    exportW6RangeBucketByBoardFitCanonicalPilotV1(writeFiles: false),
    exportW6RangeWidthAwarenessCanonicalPr2V1(writeFiles: false),
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

ContentFactoryImportExportResultV1 exportW1StartingHandDisciplineBatch1V1({
  bool writeFiles = false,
}) {
  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w1_starting_hand_discipline_migration_batch1_v1.json',
    fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
    fixtureLevel: 'w1_concept_family_migration_batch1',
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.choose_cutoff_raise_clean_start_v1.json',
        outputPath: '',
        fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
        fixtureLevel: 'w1_concept_family_migration_batch1',
        worldId: 'world_1',
        routeWorldId: 'world_1',
        displayWorldTitle: 'Poker from Zero',
        contentOwnerWorldId: 'world_1',
        routeGateStatus: 'learner_playable',
        lessonId: 'w1.l05',
        sessionId: 'w1.s05',
        packId: 'world1_spine_campaign_v1',
        taskId:
            'w1.s05.choose_cutoff_raise_clean_start_v1.'
            'starting_hand_batch1_v1',
        conceptFamilyId: 'starting_hand_discipline',
        repairFocusId: 'release_weak_or_dominated_start',
        sameSignalGroupId: 'w1.starting_hand_discipline.clean_start_or_release',
        transferSurfaceId: 'clean_first_in_start_v1',
        misconceptionId: 'passes_clean_first_in_playable_start',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: 'w1_starting_hand_discipline_batch1',
        claimsTransfer: true,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.choose_small_blind_fold_weak_start_v1.json',
        outputPath: '',
        fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
        fixtureLevel: 'w1_concept_family_migration_batch1',
        worldId: 'world_1',
        routeWorldId: 'world_1',
        displayWorldTitle: 'Poker from Zero',
        contentOwnerWorldId: 'world_1',
        routeGateStatus: 'learner_playable',
        lessonId: 'w1.l05',
        sessionId: 'w1.s05',
        packId: 'world1_spine_campaign_v1',
        taskId:
            'w1.s05.choose_small_blind_fold_weak_start_v1.'
            'starting_hand_batch1_v1',
        conceptFamilyId: 'starting_hand_discipline',
        repairFocusId: 'release_weak_or_dominated_start',
        sameSignalGroupId: 'w1.starting_hand_discipline.clean_start_or_release',
        transferSurfaceId: 'oop_weak_start_release_v1',
        misconceptionId: 'continues_weak_oop_start',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: 'w1_starting_hand_discipline_batch1',
        claimsTransfer: true,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s06/drills/'
            'd.choose_raise_clean_first_in_checkpoint_v1.json',
        outputPath: '',
        fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
        fixtureLevel: 'w1_concept_family_migration_batch1',
        worldId: 'world_1',
        routeWorldId: 'world_1',
        displayWorldTitle: 'Poker from Zero',
        contentOwnerWorldId: 'world_1',
        routeGateStatus: 'learner_playable',
        lessonId: 'w1.l06',
        sessionId: 'w1.s06',
        packId: 'world1_spine_campaign_v1',
        taskId:
            'w1.s06.choose_raise_clean_first_in_checkpoint_v1.'
            'starting_hand_batch1_v1',
        conceptFamilyId: 'starting_hand_discipline',
        repairFocusId: 'release_weak_or_dominated_start',
        sameSignalGroupId: 'w1.starting_hand_discipline.clean_start_or_release',
        transferSurfaceId: 'clean_first_in_start_v1',
        misconceptionId: 'underplays_clean_strong_start',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: 'w1_starting_hand_discipline_batch1',
        claimsTransfer: true,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s08/drills/'
            'd.choose_big_blind_call_oop_defend_focus_v1.json',
        outputPath: '',
        fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
        fixtureLevel: 'w1_concept_family_migration_batch1',
        worldId: 'world_1',
        routeWorldId: 'world_1',
        displayWorldTitle: 'Poker from Zero',
        contentOwnerWorldId: 'world_1',
        routeGateStatus: 'learner_playable',
        lessonId: 'w1.l08',
        sessionId: 'w1.s08',
        packId: 'world1_spine_campaign_v1',
        taskId:
            'w1.s08.choose_big_blind_call_oop_defend_focus_v1.'
            'starting_hand_batch1_v1',
        conceptFamilyId: 'starting_hand_discipline',
        repairFocusId: 'release_weak_or_dominated_start',
        sameSignalGroupId: 'w1.starting_hand_discipline.clean_start_or_release',
        transferSurfaceId: 'facing_open_continue_or_release_v1',
        misconceptionId: 'turns_playable_defend_into_loose_raise',
        sourceTruthStatus: 'migrated',
        feedbackReason:
            'Calling from the big blind with a playable broadway is a defend: '
            'you already posted the big blind, but without position the clean '
            'continue is call.',
        sourceJob: 'w1_starting_hand_discipline_batch1',
        claimsTransfer: true,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s09/drills/'
            'd.choose_raise_when_action_folds_to_you_focus_v1.json',
        outputPath: '',
        fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
        fixtureLevel: 'w1_concept_family_migration_batch1',
        worldId: 'world_1',
        routeWorldId: 'world_1',
        displayWorldTitle: 'Poker from Zero',
        contentOwnerWorldId: 'world_1',
        routeGateStatus: 'learner_playable',
        lessonId: 'w1.l09',
        sessionId: 'w1.s09',
        packId: 'world1_spine_campaign_v1',
        taskId:
            'w1.s09.choose_raise_when_action_folds_to_you_focus_v1.'
            'starting_hand_batch1_v1',
        conceptFamilyId: 'starting_hand_discipline',
        repairFocusId: 'release_weak_or_dominated_start',
        sameSignalGroupId: 'w1.starting_hand_discipline.clean_start_or_release',
        transferSurfaceId: 'clean_first_in_start_v1',
        misconceptionId: 'passes_clean_first_in_playable_start',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: 'w1_starting_hand_discipline_batch1',
        claimsTransfer: true,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s09/drills/'
            'd.choose_fold_when_pressure_and_position_fail_focus_v1.json',
        outputPath: '',
        fixtureId: 'w1_starting_hand_discipline_migration_batch1_v1',
        fixtureLevel: 'w1_concept_family_migration_batch1',
        worldId: 'world_1',
        routeWorldId: 'world_1',
        displayWorldTitle: 'Poker from Zero',
        contentOwnerWorldId: 'world_1',
        routeGateStatus: 'learner_playable',
        lessonId: 'w1.l09',
        sessionId: 'w1.s09',
        packId: 'world1_spine_campaign_v1',
        taskId:
            'w1.s09.choose_fold_when_pressure_and_position_fail_focus_v1.'
            'starting_hand_batch1_v1',
        conceptFamilyId: 'starting_hand_discipline',
        repairFocusId: 'release_weak_or_dominated_start',
        sameSignalGroupId: 'w1.starting_hand_discipline.clean_start_or_release',
        transferSurfaceId: 'oop_weak_start_release_v1',
        misconceptionId: 'continues_weak_oop_start',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: 'w1_starting_hand_discipline_batch1',
        claimsTransfer: true,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW1SeatRoleOrientationPr2V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w1_seat_role_orientation_migration_pr2_v1';
  return _exportAggregateFixture(
    outputPath: '$_outputDir/$fixtureId.json',
    fixtureId: fixtureId,
    fixtureLevel: 'w1_coverage_expansion_pr2',
    writeFiles: writeFiles,
    specs: [
      _w1SeatRolePr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.find_btn.json',
        lessonId: 'w1.l01',
        sessionId: 'w1.s01',
        taskId: 'w1.s01.find_btn.seat_role_pr2_v1',
        transferSurfaceId: 'button_role_find_v1',
        misconceptionId: 'cannot_identify_button_role',
        correctActionOverride: 'btn',
      ),
      _w1SeatRolePr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s02/drills/'
            'd.find_sb.json',
        lessonId: 'w1.l02',
        sessionId: 'w1.s02',
        taskId: 'w1.s02.find_sb.seat_role_pr2_v1',
        transferSurfaceId: 'blind_role_find_v1',
        misconceptionId: 'cannot_identify_blind_role',
        correctActionOverride: 'sb',
      ),
      _w1SeatRolePr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s03/drills/'
            'd.find_bb.json',
        lessonId: 'w1.l03',
        sessionId: 'w1.s03',
        taskId: 'w1.s03.find_bb.seat_role_pr2_v1',
        transferSurfaceId: 'blind_role_find_v1',
        misconceptionId: 'cannot_identify_blind_role',
        correctActionOverride: 'bb',
      ),
      _w1SeatRolePr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s07/drills/'
            'd.find_btn_focus.json',
        lessonId: 'w1.l07',
        sessionId: 'w1.s07',
        taskId: 'w1.s07.find_btn_focus.seat_role_pr2_v1',
        transferSurfaceId: 'button_role_find_v1',
        misconceptionId: 'cannot_identify_button_role',
        correctActionOverride: 'btn',
      ),
      _w1SeatRolePr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s08/drills/'
            'd.find_sb_focus.json',
        lessonId: 'w1.l08',
        sessionId: 'w1.s08',
        taskId: 'w1.s08.find_sb_focus.seat_role_pr2_v1',
        transferSurfaceId: 'blind_role_find_v1',
        misconceptionId: 'cannot_identify_blind_role',
        correctActionOverride: 'sb',
      ),
      _w1SeatRolePr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s10/drills/'
            'd.find_btn_focus.json',
        lessonId: 'w1.l10',
        sessionId: 'w1.s10',
        taskId: 'w1.s10.find_btn_focus.seat_role_pr2_v1',
        transferSurfaceId: 'button_role_find_v1',
        misconceptionId: 'cannot_identify_button_role',
        correctActionOverride: 'btn',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW1CardBoardOrientationPr2V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w1_card_board_orientation_migration_pr2_v1';
  return _exportAggregateFixture(
    outputPath: '$_outputDir/$fixtureId.json',
    fixtureId: fixtureId,
    fixtureLevel: 'w1_coverage_expansion_pr2',
    writeFiles: writeFiles,
    specs: [
      _w1CardBoardPr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.tap_flop_right.json',
        lessonId: 'w1.l01',
        sessionId: 'w1.s01',
        taskId: 'w1.s01.tap_flop_right.card_board_pr2_v1',
        transferSurfaceId: 'flop_slot_find_v1',
        misconceptionId: 'cannot_identify_flop_slot',
        correctActionOverride: 'flop_right',
      ),
      _w1CardBoardPr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s02/drills/'
            'd.tap_turn.json',
        lessonId: 'w1.l02',
        sessionId: 'w1.s02',
        taskId: 'w1.s02.tap_turn.card_board_pr2_v1',
        transferSurfaceId: 'turn_slot_find_v1',
        misconceptionId: 'cannot_identify_turn_slot',
        correctActionOverride: 'turn',
      ),
      _w1CardBoardPr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s03/drills/'
            'd.tap_river.json',
        lessonId: 'w1.l03',
        sessionId: 'w1.s03',
        taskId: 'w1.s03.tap_river.card_board_pr2_v1',
        transferSurfaceId: 'river_slot_find_v1',
        misconceptionId: 'cannot_identify_river_slot',
        correctActionOverride: 'river',
      ),
      _w1CardBoardPr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s04/drills/'
            'd.tap_flop_right_repeat.json',
        lessonId: 'w1.l04',
        sessionId: 'w1.s04',
        taskId: 'w1.s04.tap_flop_right_repeat.card_board_pr2_v1',
        transferSurfaceId: 'flop_slot_find_v1',
        misconceptionId: 'cannot_identify_flop_slot',
        correctActionOverride: 'flop_right',
      ),
      _w1CardBoardPr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.tap_turn_repeat.json',
        lessonId: 'w1.l05',
        sessionId: 'w1.s05',
        taskId: 'w1.s05.tap_turn_repeat.card_board_pr2_v1',
        transferSurfaceId: 'turn_slot_find_v1',
        misconceptionId: 'cannot_identify_turn_slot',
        correctActionOverride: 'turn',
      ),
      _w1CardBoardPr2Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s06/drills/'
            'd.tap_river_repeat.json',
        lessonId: 'w1.l06',
        sessionId: 'w1.s06',
        taskId: 'w1.s06.tap_river_repeat.card_board_pr2_v1',
        transferSurfaceId: 'river_slot_find_v1',
        misconceptionId: 'cannot_identify_river_slot',
        correctActionOverride: 'river',
      ),
    ],
  );
}

_FactorySampleSpecV1 _w1SeatRolePr2Spec({
  required String sourcePath,
  required String lessonId,
  required String sessionId,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  required String correctActionOverride,
}) {
  return _FactorySampleSpecV1(
    sourcePath: sourcePath,
    outputPath: '',
    fixtureId: 'w1_seat_role_orientation_migration_pr2_v1',
    fixtureLevel: 'w1_coverage_expansion_pr2',
    worldId: 'world_1',
    routeWorldId: 'world_1',
    displayWorldTitle: 'Poker from Zero',
    contentOwnerWorldId: 'world_1',
    routeGateStatus: 'learner_playable',
    lessonId: lessonId,
    sessionId: sessionId,
    packId: 'world1_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'seat_role_orientation',
    repairFocusId: 'role_before_action',
    sameSignalGroupId: 'w1.seat_role_orientation.blind_button_seat_identity',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason: 'Find the blind or button role before action selection.',
    sourceJob: 'w1_coverage_expansion_pr2_seat_role_orientation',
    claimsTransfer: true,
    correctActionOverride: correctActionOverride,
  );
}

_FactorySampleSpecV1 _w1CardBoardPr2Spec({
  required String sourcePath,
  required String lessonId,
  required String sessionId,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  required String correctActionOverride,
}) {
  return _FactorySampleSpecV1(
    sourcePath: sourcePath,
    outputPath: '',
    fixtureId: 'w1_card_board_orientation_migration_pr2_v1',
    fixtureLevel: 'w1_coverage_expansion_pr2',
    worldId: 'world_1',
    routeWorldId: 'world_1',
    displayWorldTitle: 'Poker from Zero',
    contentOwnerWorldId: 'world_1',
    routeGateStatus: 'learner_playable',
    lessonId: lessonId,
    sessionId: sessionId,
    packId: 'world1_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'card_board_orientation',
    repairFocusId: 'board_slot_before_action',
    sameSignalGroupId: 'w1.card_board_orientation.board_slot_identity',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason:
        'Find the board card slot before using the card in an action decision.',
    sourceJob: 'w1_coverage_expansion_pr2_card_board_orientation',
    claimsTransfer: true,
    correctActionOverride: correctActionOverride,
  );
}

ContentFactoryImportExportResultV1 exportW1BetSizeVocabularyPreviewPr3V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w1_bet_size_vocabulary_preview_migration_pr3_v1';
  return _exportAggregateFixture(
    outputPath: '$_outputDir/$fixtureId.json',
    fixtureId: fixtureId,
    fixtureLevel: 'w1_coverage_expansion_pr3',
    writeFiles: writeFiles,
    specs: [
      _w1BetSizePr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_one_third_pot_keep_price.json',
        taskId: 'w1.s01.choose_one_third_pot_keep_price.bet_size_pr3_v1',
        transferSurfaceId: 'cheap_price_label_v1',
        misconceptionId: 'overstates_preview_size_strategy',
        feedbackReason:
            'One third pot is a smaller size label. The pot is the chips '
            'already in the middle.',
      ),
      _w1BetSizePr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_half_pot_value.json',
        taskId: 'w1.s01.choose_half_pot_value.bet_size_pr3_v1',
        transferSurfaceId: 'value_size_label_v1',
        misconceptionId: 'overstates_preview_size_strategy',
        feedbackReason:
            'Half pot means betting half the chips currently in the middle.',
      ),
      _w1BetSizePr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_min_raise_reopen.json',
        taskId: 'w1.s01.choose_min_raise_reopen.bet_size_pr3_v1',
        transferSurfaceId: 'reopen_label_v1',
        misconceptionId: 'confuses_min_raise_with_value_size',
      ),
      _w1BetSizePr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_pot_pressure.json',
        taskId: 'w1.s01.choose_pot_pressure.bet_size_pr3_v1',
        transferSurfaceId: 'pressure_size_label_v1',
        misconceptionId: 'confuses_pressure_size_with_value_size',
        feedbackReason:
            'A pot-sized bet matches the chips already in the middle; it is '
            'the largest basic size label in this preview.',
      ),
      _w1BetSizePr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.chain_world1_first_bridge_v1.json',
        taskId: 'w1.s01.chain_first_bridge.step3.bet_size_pr3_v1',
        transferSurfaceId: 'cheap_price_label_v1',
        misconceptionId: 'overstates_preview_size_strategy',
        sourceStepIndex: 2,
        feedbackReason:
            'World 1 only previews sizing vocabulary here. One third pot is '
            'the compact smaller-pot size label.',
      ),
      _w1BetSizePr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.chain_world1_first_bridge_v1.json',
        taskId: 'w1.s01.chain_first_bridge.step4.bet_size_pr3_v1',
        transferSurfaceId: 'value_size_label_v1',
        misconceptionId: 'overstates_preview_size_strategy',
        sourceStepIndex: 3,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW1CheckpointSynthesisPr3V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w1_checkpoint_synthesis_migration_pr3_v1';
  return _exportAggregateFixture(
    outputPath: '$_outputDir/$fixtureId.json',
    fixtureId: fixtureId,
    fixtureLevel: 'w1_coverage_expansion_pr3',
    writeFiles: writeFiles,
    specs: [
      _w1CheckpointPr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s02/drills/'
            'd.chain_world1_blind_button_intro_v1.json',
        lessonId: 'w1.l02',
        sessionId: 'w1.s02',
        taskId: 'w1.s02.chain_blind_button_intro.checkpoint_pr3_v1',
        transferSurfaceId: 'blind_button_chain_v1',
        misconceptionId: 'cannot_connect_blind_button_sequence',
        feedbackReason:
            'The blind-and-button chain connects opening, defending, and '
            'releasing as one World 1 checkpoint.',
      ),
      _w1CheckpointPr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s03/drills/'
            'd.chain_world1_action_order_checkpoint_v1.json',
        lessonId: 'w1.l03',
        sessionId: 'w1.s03',
        taskId: 'w1.s03.chain_action_order.checkpoint_pr3_v1',
        transferSurfaceId: 'action_order_chain_v1',
        misconceptionId: 'cannot_connect_action_order_sequence',
        feedbackReason:
            'The action-order chain connects unopened action, prior pressure, '
            'and stacked pressure into one checkpoint.',
      ),
      _w1CheckpointPr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s04/drills/'
            'd.chain_world1_position_stability_v1.json',
        lessonId: 'w1.l04',
        sessionId: 'w1.s04',
        taskId: 'w1.s04.chain_position_stability.checkpoint_pr3_v1',
        transferSurfaceId: 'position_stability_chain_v1',
        misconceptionId: 'cannot_keep_position_habit_stable',
        feedbackReason:
            'The position-stability chain checks whether the same World 1 '
            'seat habits stay reliable across repeated surfaces.',
      ),
      _w1CheckpointPr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.chain_world1_start_quality_reinforcement_v1.json',
        lessonId: 'w1.l05',
        sessionId: 'w1.s05',
        taskId: 'w1.s05.chain_start_quality.checkpoint_pr3_v1',
        transferSurfaceId: 'start_quality_chain_v1',
        misconceptionId: 'cannot_connect_start_quality_sequence',
        feedbackReason:
            'The start-quality chain reinforces clean starts, pressure '
            'continues, and weak-hand releases as one review unit.',
      ),
      _w1CheckpointPr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s06/drills/'
            'd.chain_world1_mixed_checkpoint_v1.json',
        lessonId: 'w1.l06',
        sessionId: 'w1.s06',
        taskId: 'w1.s06.chain_mixed_checkpoint.checkpoint_pr3_v1',
        transferSurfaceId: 'mixed_checkpoint_chain_v1',
        misconceptionId: 'cannot_combine_seat_pressure_hand_quality',
        feedbackReason:
            'The mixed checkpoint chain combines seat, pressure, and hand '
            'quality without adding new strategy.',
      ),
      _w1CheckpointPr3Spec(
        sourcePath:
            'content/worlds/world1/v1/sessions/w1.s10/drills/'
            'd.chain_world1_final_checkpoint_v1.json',
        lessonId: 'w1.l10',
        sessionId: 'w1.s10',
        taskId: 'w1.s10.chain_final_checkpoint.checkpoint_pr3_v1',
        transferSurfaceId: 'final_checkpoint_chain_v1',
        misconceptionId: 'cannot_summarize_world1_decision_frame',
        feedbackReason:
            'The final checkpoint chain summarizes the World 1 frame: read '
            'seat, notice pressure, and let hand quality shape the action.',
      ),
    ],
  );
}

_FactorySampleSpecV1 _w1BetSizePr3Spec({
  required String sourcePath,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  int? sourceStepIndex,
  String? feedbackReason,
}) {
  return _FactorySampleSpecV1(
    sourcePath: sourcePath,
    outputPath: '',
    fixtureId: 'w1_bet_size_vocabulary_preview_migration_pr3_v1',
    fixtureLevel: 'w1_coverage_expansion_pr3',
    worldId: 'world_1',
    routeWorldId: 'world_1',
    displayWorldTitle: 'Poker from Zero',
    contentOwnerWorldId: 'world_1',
    routeGateStatus: 'learner_playable',
    lessonId: 'w1.l01',
    sessionId: 'w1.s01',
    packId: 'world1_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'bet_size_vocabulary_preview',
    repairFocusId: 'size_label_before_strategy',
    sameSignalGroupId: 'w1.bet_size_vocabulary_preview.size_label_recognition',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason: feedbackReason,
    sourceJob: 'w1_coverage_expansion_pr3_bet_size_vocabulary_preview',
    claimsTransfer: true,
    sourceStepIndex: sourceStepIndex,
    sourceIntentOverride: 'bet_size_vocabulary_preview',
  );
}

_FactorySampleSpecV1 _w1CheckpointPr3Spec({
  required String sourcePath,
  required String lessonId,
  required String sessionId,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  required String feedbackReason,
}) {
  return _FactorySampleSpecV1(
    sourcePath: sourcePath,
    outputPath: '',
    fixtureId: 'w1_checkpoint_synthesis_migration_pr3_v1',
    fixtureLevel: 'w1_coverage_expansion_pr3',
    worldId: 'world_1',
    routeWorldId: 'world_1',
    displayWorldTitle: 'Poker from Zero',
    contentOwnerWorldId: 'world_1',
    routeGateStatus: 'learner_playable',
    lessonId: lessonId,
    sessionId: sessionId,
    packId: 'world1_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'world1_checkpoint_synthesis',
    repairFocusId: 'connect_seat_pressure_hand_quality',
    sameSignalGroupId:
        'w1.world1_checkpoint_synthesis.seat_pressure_hand_quality_chain',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason: feedbackReason,
    sourceJob: 'w1_coverage_expansion_pr3_checkpoint_synthesis',
    claimsTransfer: true,
    correctActionOverride: 'complete_chain',
    sourceIntentOverride: 'world1_checkpoint_synthesis',
    sourceErrorClassOverride: 'checkpoint_synthesis_review',
  );
}

ContentFactoryImportExportResultV1
exportW1ShowdownBasicsSourceAuthorshipRepairV1({bool writeFiles = false}) {
  const fixtureId = 'w1_showdown_basics_source_authorship_repair_v1';
  const fixtureLevel = 'w1_showdown_basics_source_authorship_repair_v1';
  const sourceRoot =
      'content/worlds/world1/v1/source_repairs/showdown_basics_v1/drills/';

  _FactorySampleSpecV1 spec({
    required String sourceFile,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: '$sourceRoot$sourceFile',
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_1',
      routeWorldId: 'world_1',
      displayWorldTitle: 'Poker from Zero',
      contentOwnerWorldId: 'world_1',
      routeGateStatus: 'learner_playable',
      lessonId: 'w1.l11',
      sessionId: 'w1.s11',
      packId: 'world1_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: 'showdown_basics',
      repairFocusId: 'best_five_before_showdown_winner',
      sameSignalGroupId: 'w1.showdown_basics.best_five_comparison',
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: 'w1_showdown_basics_source_authorship_repair_v1',
      claimsTransfer: true,
      sourceIntentOverride: 'showdown_basics',
      safeClaimStatus: 'canonical_pilot',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath: '$_outputDir/$fixtureId.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourceFile: 'd.identify_straight_over_two_pair_v1.json',
        taskId: 'w1.s11.identify_straight_over_two_pair.showdown_repair_v1',
        transferSurfaceId: 'hand_rank_order_v1',
        misconceptionId: 'ranks_two_pair_above_straight',
      ),
      spec(
        sourceFile: 'd.identify_flush_over_straight_v1.json',
        taskId: 'w1.s11.identify_flush_over_straight.showdown_repair_v1',
        transferSurfaceId: 'hand_rank_order_v1',
        misconceptionId: 'ranks_straight_above_flush',
      ),
      spec(
        sourceFile: 'd.select_nine_high_straight_best_five_v1.json',
        taskId: 'w1.s11.select_nine_high_straight_best_five.showdown_repair_v1',
        transferSurfaceId: 'best_five_selection_v1',
        misconceptionId: 'fails_to_select_best_five_from_seven',
      ),
      spec(
        sourceFile: 'd.choose_hero_pair_over_pair_showdown_v1.json',
        taskId: 'w1.s11.choose_hero_pair_over_pair_showdown.showdown_repair_v1',
        transferSurfaceId: 'showdown_winner_v1',
        misconceptionId: 'chooses_lower_pair_at_showdown',
      ),
      spec(
        sourceFile: 'd.choose_hero_king_kicker_showdown_v1.json',
        taskId: 'w1.s11.choose_hero_king_kicker_showdown.showdown_repair_v1',
        transferSurfaceId: 'kicker_tiebreak_v1',
        misconceptionId: 'ignores_kicker_after_pair_ties',
      ),
      spec(
        sourceFile: 'd.choose_board_plays_tie_v1.json',
        taskId: 'w1.s11.choose_board_plays_tie.showdown_repair_v1',
        transferSurfaceId: 'board_plays_tie_v1',
        misconceptionId: 'forces_winner_when_best_five_ties',
      ),
    ],
  );
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

ContentFactoryImportExportResultV1 exportW2CanonicalCertificationPilotV1({
  bool writeFiles = false,
}) {
  final specs = [
    _w2CanonicalHandDisciplineSpecV1(
      sourceFileName: 'd.choose_fold_early.json',
      sourceId: 'choose_fold_early',
      sourceSessionId: 'w2.s01',
      lessonId: 'w2.l01',
      taskId: 'w2.s01.choose_fold_early.canonical_certification_pilot_v1',
      transferSurfaceId: 'early_position_release_v1',
      misconceptionId: 'enters_pot_from_early_weak_start',
      feedbackReason:
          'Fold keeps weak early-position hands out of pressure spots.',
    ),
    _w2CanonicalHandDisciplineSpecV1(
      sourceFileName: 'd.choose_call_vs_open.json',
      sourceId: 'choose_call_vs_open',
      sourceSessionId: 'w2.s01',
      lessonId: 'w2.l01',
      taskId: 'w2.s01.choose_call_vs_open.canonical_certification_pilot_v1',
      transferSurfaceId: 'facing_open_price_v1',
      misconceptionId: 'folds_playable_price_or_forces_extra_aggression',
      feedbackReason:
          'Call is the disciplined continue when the price is playable.',
    ),
    _w2CanonicalHandDisciplineSpecV1(
      sourceFileName: 'd.choose_raise_btn.json',
      sourceId: 'choose_raise_btn',
      sourceSessionId: 'w2.s01',
      lessonId: 'w2.l01',
      taskId: 'w2.s01.choose_raise_btn.canonical_certification_pilot_v1',
      transferSurfaceId: 'late_position_open_v1',
      misconceptionId: 'misses_late_position_open_default',
      feedbackReason:
          'Raise is the disciplined first-in default from Button position.',
    ),
    _w2CanonicalHandDisciplineSpecV1(
      sourceFileName: 'd.choose_fold_utg_open.json',
      sourceId: 'choose_fold_utg_open',
      sourceSessionId: 'w2.s02',
      lessonId: 'w2.l02',
      taskId: 'w2.s02.choose_fold_utg_open.canonical_certification_pilot_v1',
      transferSurfaceId: 'early_position_release_v1',
      misconceptionId: 'opens_weak_early_position_hand',
      feedbackReason:
          'Fold discipline removes weak early-seat open candidates.',
    ),
    _w2CanonicalHandDisciplineSpecV1(
      sourceFileName: 'd.choose_call_btn_defend.json',
      sourceId: 'choose_call_btn_defend',
      sourceSessionId: 'w2.s02',
      lessonId: 'w2.l02',
      taskId: 'w2.s02.choose_call_btn_defend.canonical_certification_pilot_v1',
      transferSurfaceId: 'facing_open_price_v1',
      misconceptionId: 'overfolds_playable_button_defend',
      feedbackReason:
          'Call keeps the Button defend disciplined when the price is defined.',
    ),
    _w2CanonicalHandDisciplineSpecV1(
      sourceFileName: 'd.choose_raise_btn_open.json',
      sourceId: 'choose_raise_btn_open',
      sourceSessionId: 'w2.s02',
      lessonId: 'w2.l02',
      taskId: 'w2.s02.choose_raise_btn_open.canonical_certification_pilot_v1',
      transferSurfaceId: 'late_position_open_v1',
      misconceptionId: 'passes_on_clean_button_open',
      feedbackReason: 'Raise preserves the clean Button first-in discipline.',
    ),
  ];

  final tasks = specs
      .map((spec) => _exportSample(spec).task!)
      .toList(growable: false);
  final fixture = <String, Object?>{
    'schema_version': _schemaVersion,
    'fixture_id': 'w2_canonical_certification_pilot_v1',
    'fixture_level': 'w2_canonical_certification_pilot',
    'generated_by': 'content_factory_import_export_mvp_v1',
    'tasks': tasks,
  };
  final result = ContentFactoryImportExportResultV1(
    outputPath: '$_outputDir/w2_canonical_certification_pilot_v1.json',
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

_FactorySampleSpecV1 _w2CanonicalHandDisciplineSpecV1({
  required String sourceFileName,
  required String sourceId,
  required String sourceSessionId,
  required String lessonId,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  required String feedbackReason,
}) {
  return _FactorySampleSpecV1(
    sourcePath:
        'content/worlds/world2/v1/sessions/$sourceSessionId/drills/'
        '$sourceFileName',
    outputPath: '',
    fixtureId: 'w2_canonical_certification_pilot_v1',
    fixtureLevel: 'w2_canonical_certification_pilot',
    worldId: 'world_2',
    routeWorldId: 'world_2',
    displayWorldTitle: 'Hand Discipline',
    contentOwnerWorldId: 'world_2',
    routeGateStatus: 'learner_playable',
    lessonId: lessonId,
    sessionId: sourceSessionId,
    packId: 'world2_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'hand_discipline_position_price_defaults',
    repairFocusId: 'position_price_hand_discipline',
    sameSignalGroupId: 'w2.hand_discipline.position_price_action_defaults',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason: feedbackReason,
    sourceJob: 'w2_hand_discipline_canonical_pilot',
    claimsTransfer: true,
    sourceIntentOverride: 'hand_discipline_position_price_defaults',
    sourceErrorClassOverride: 'hand_discipline_position_price_default',
    safeClaimStatus: 'canonical_pilot',
    launchCoverageClaimed: false,
  );
}

ContentFactoryImportExportResultV1 exportW2FacingPriceDisciplineCanonicalPr2V1({
  bool writeFiles = false,
}) {
  return _exportAggregateFixture(
    outputPath: '$_outputDir/w2_facing_price_discipline_canonical_pr2_v1.json',
    fixtureId: 'w2_facing_price_discipline_canonical_pr2_v1',
    fixtureLevel: 'w2_canonical_coverage_expansion_pr2',
    writeFiles: writeFiles,
    specs: [
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s03/drills/'
            'd.choose_call_facing_bet.json',
        lessonId: 'w2.l03',
        sessionId: 'w2.s03',
        taskId: 'w2.s03.choose_call_facing_bet.canonical_pr2_v1',
        transferSurfaceId: 'facing_bet_price_continue_v1',
        misconceptionId: 'folds_acceptable_facing_bet_price',
        feedbackReason:
            'Call keeps discipline when the facing-bet price is acceptable.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s03/drills/'
            'd.choose_fold_facing_bet.json',
        lessonId: 'w2.l03',
        sessionId: 'w2.s03',
        taskId: 'w2.s03.choose_fold_facing_bet.canonical_pr2_v1',
        transferSurfaceId: 'facing_bet_price_release_v1',
        misconceptionId: 'continues_poor_facing_bet_price',
        feedbackReason:
            'Fold keeps discipline when the facing-bet price is poor.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s07/drills/'
            'd.choose_call_facing_open_price_ok.json',
        lessonId: 'w2.l07',
        sessionId: 'w2.s07',
        taskId: 'w2.s07.choose_call_facing_open_price_ok.canonical_pr2_v1',
        transferSurfaceId: 'facing_bet_price_continue_v1',
        misconceptionId: 'overfolds_acceptable_facing_open_price',
        feedbackReason:
            'Call preserves the continue when the facing-open price is okay.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s07/drills/'
            'd.choose_fold_facing_open_price_bad.json',
        lessonId: 'w2.l07',
        sessionId: 'w2.s07',
        taskId: 'w2.s07.choose_fold_facing_open_price_bad.canonical_pr2_v1',
        transferSurfaceId: 'facing_bet_price_release_v1',
        misconceptionId: 'continues_bad_facing_open_price',
        feedbackReason:
            'Fold preserves discipline when the facing-open price is bad.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s09/drills/'
            'd.choose_call_bridge_tocall_price_ok.json',
        lessonId: 'w2.l09',
        sessionId: 'w2.s09',
        taskId: 'w2.s09.choose_call_bridge_tocall_price_ok.canonical_pr2_v1',
        transferSurfaceId: 'bridge_price_continue_v1',
        misconceptionId: 'overfolds_acceptable_tocall_price',
        feedbackReason:
            'Call keeps the price read steady when toCall is acceptable.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s09/drills/'
            'd.choose_fold_bridge_tocall_price_bad.json',
        lessonId: 'w2.l09',
        sessionId: 'w2.s09',
        taskId: 'w2.s09.choose_fold_bridge_tocall_price_bad.canonical_pr2_v1',
        transferSurfaceId: 'bridge_price_release_v1',
        misconceptionId: 'continues_bad_tocall_price',
        feedbackReason:
            'Fold keeps the price read steady when toCall is too expensive.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s10/drills/'
            'd.choose_call_checkpoint_tocall_price_ok.json',
        lessonId: 'w2.l10',
        sessionId: 'w2.s10',
        taskId:
            'w2.s10.choose_call_checkpoint_tocall_price_ok.canonical_pr2_v1',
        transferSurfaceId: 'bridge_price_continue_v1',
        misconceptionId: 'drops_acceptable_checkpoint_price',
        feedbackReason:
            'Call carries the acceptable price read into the checkpoint.',
      ),
      _w2FacingPriceDisciplinePr2Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s10/drills/'
            'd.choose_fold_checkpoint_tocall_price_bad.json',
        lessonId: 'w2.l10',
        sessionId: 'w2.s10',
        taskId:
            'w2.s10.choose_fold_checkpoint_tocall_price_bad.canonical_pr2_v1',
        transferSurfaceId: 'bridge_price_release_v1',
        misconceptionId: 'continues_bad_checkpoint_price',
        feedbackReason: 'Fold carries the poor price read into the checkpoint.',
      ),
    ],
  );
}

_FactorySampleSpecV1 _w2FacingPriceDisciplinePr2Spec({
  required String sourcePath,
  required String lessonId,
  required String sessionId,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  required String feedbackReason,
}) {
  return _FactorySampleSpecV1(
    sourcePath: sourcePath,
    outputPath: '',
    fixtureId: 'w2_facing_price_discipline_canonical_pr2_v1',
    fixtureLevel: 'w2_canonical_coverage_expansion_pr2',
    worldId: 'world_2',
    routeWorldId: 'world_2',
    displayWorldTitle: 'Hand Discipline',
    contentOwnerWorldId: 'world_2',
    routeGateStatus: 'learner_playable',
    lessonId: lessonId,
    sessionId: sessionId,
    packId: 'world2_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'facing_price_continue_release_discipline',
    repairFocusId: 'facing_price_continue_release_discipline',
    sameSignalGroupId: 'w2.hand_discipline.facing_price_continue_release',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason: feedbackReason,
    sourceJob: 'w2_canonical_coverage_expansion_pr2_facing_price',
    claimsTransfer: true,
    sourceIntentOverride: 'facing_price_continue_release_discipline',
    sourceErrorClassOverride: 'facing_price_continue_release_error',
    safeClaimStatus: 'canonical_pilot',
    launchCoverageClaimed: false,
  );
}

ContentFactoryImportExportResultV1
exportW2ApprovedRaiseDisciplineCanonicalPr3V1({bool writeFiles = false}) {
  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w2_approved_raise_discipline_canonical_pr3_v1.json',
    fixtureId: 'w2_approved_raise_discipline_canonical_pr3_v1',
    fixtureLevel: 'w2_canonical_coverage_expansion_pr3',
    writeFiles: writeFiles,
    specs: [
      _w2ApprovedRaiseDisciplinePr3Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s03/drills/'
            'd.choose_raise_to_facing_bet.json',
        lessonId: 'w2.l03',
        sessionId: 'w2.s03',
        taskId: 'w2.s03.choose_raise_to_facing_bet.canonical_pr3_v1',
        transferSurfaceId: 'clear_aggression_trigger_raise_v1',
        misconceptionId: 'misses_clear_aggression_trigger',
        feedbackReason:
            'Raise is disciplined only because the source grants a clear aggression trigger.',
      ),
      _w2ApprovedRaiseDisciplinePr3Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s07/drills/'
            'd.choose_raise_facing_open_isolation.json',
        lessonId: 'w2.l07',
        sessionId: 'w2.s07',
        taskId: 'w2.s07.choose_raise_facing_open_isolation.canonical_pr3_v1',
        transferSurfaceId: 'approved_isolation_raise_v1',
        misconceptionId: 'flats_approved_isolation_spot',
        feedbackReason:
            'Raise is disciplined when the source marks the isolation node as approved.',
      ),
      _w2ApprovedRaiseDisciplinePr3Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s04/drills/'
            'd.choose_raise_flop_value.json',
        lessonId: 'w2.l04',
        sessionId: 'w2.s04',
        taskId: 'w2.s04.choose_raise_flop_value.canonical_pr3_v1',
        transferSurfaceId: 'value_intent_raise_v1',
        misconceptionId: 'checks_clear_value_spot',
        feedbackReason:
            'Raise is disciplined when the source identifies a clear value spot.',
      ),
      _w2ApprovedRaiseDisciplinePr3Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s04/drills/'
            'd.choose_raise_flop_denial.json',
        lessonId: 'w2.l04',
        sessionId: 'w2.s04',
        taskId: 'w2.s04.choose_raise_flop_denial.canonical_pr3_v1',
        transferSurfaceId: 'denial_raise_v1',
        misconceptionId: 'gives_free_equity_in_denial_spot',
        feedbackReason:
            'Raise is disciplined when the source frames the node as denial.',
      ),
      _w2ApprovedRaiseDisciplinePr3Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s09/drills/'
            'd.choose_raise_bridge_pressure_counter.json',
        lessonId: 'w2.l09',
        sessionId: 'w2.s09',
        taskId: 'w2.s09.choose_raise_bridge_pressure_counter.canonical_pr3_v1',
        transferSurfaceId: 'approved_pressure_counter_raise_v1',
        misconceptionId: 'drifts_passive_when_pressure_counter_is_approved',
        feedbackReason:
            'Raise is disciplined when the source approves the pressure counter.',
      ),
      _w2ApprovedRaiseDisciplinePr3Spec(
        sourcePath:
            'content/worlds/world2/v1/sessions/w2.s10/drills/'
            'd.choose_raise_checkpoint_value_branch.json',
        lessonId: 'w2.l10',
        sessionId: 'w2.s10',
        taskId: 'w2.s10.choose_raise_checkpoint_value_branch.canonical_pr3_v1',
        transferSurfaceId: 'value_intent_raise_v1',
        misconceptionId: 'passes_value_checkpoint_branch',
        feedbackReason:
            'Raise is disciplined when the checkpoint source names the branch as value-intent.',
      ),
    ],
  );
}

_FactorySampleSpecV1 _w2ApprovedRaiseDisciplinePr3Spec({
  required String sourcePath,
  required String lessonId,
  required String sessionId,
  required String taskId,
  required String transferSurfaceId,
  required String misconceptionId,
  required String feedbackReason,
}) {
  return _FactorySampleSpecV1(
    sourcePath: sourcePath,
    outputPath: '',
    fixtureId: 'w2_approved_raise_discipline_canonical_pr3_v1',
    fixtureLevel: 'w2_canonical_coverage_expansion_pr3',
    worldId: 'world_2',
    routeWorldId: 'world_2',
    displayWorldTitle: 'Hand Discipline',
    contentOwnerWorldId: 'world_2',
    routeGateStatus: 'learner_playable',
    lessonId: lessonId,
    sessionId: sessionId,
    packId: 'world2_spine_campaign_v1',
    taskId: taskId,
    conceptFamilyId: 'approved_raise_discipline',
    repairFocusId: 'approved_raise_only_when_source_grants_trigger',
    sameSignalGroupId: 'w2.hand_discipline.approved_raise_only',
    transferSurfaceId: transferSurfaceId,
    misconceptionId: misconceptionId,
    sourceTruthStatus: 'migrated',
    feedbackReason: feedbackReason,
    sourceJob: 'w2_canonical_coverage_expansion_pr3_approved_raise',
    claimsTransfer: true,
    sourceIntentOverride: 'approved_raise_discipline',
    sourceErrorClassOverride: 'approved_raise_without_source_trigger_error',
    safeClaimStatus: 'canonical_pilot',
    launchCoverageClaimed: false,
  );
}

ContentFactoryImportExportResultV1 exportW3CanonicalCertificationPilotV1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w3_canonical_certification_pilot_v1';
  const fixtureLevel = 'w3_canonical_certification_pilot';
  const conceptFamilyId = 'position_sensitive_preflop_decision';
  const repairFocusId = 'position_before_preflop_action';
  const sameSignalGroupId =
      'w3.position_thinking.position_before_preflop_action';
  const sourceJob = 'position_thinking_canonical_pilot';
  const sourceIntentOverride = 'position_thinking_canonical_pilot';
  const sourceErrorClassOverride = 'position_before_preflop_action_error';

  return _exportAggregateFixture(
    outputPath: '$_outputDir/w3_canonical_certification_pilot_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s11/drills/'
            'd.chain_position_open_call_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l11',
        sessionId: 'w3.s11',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s11.position_open_call.step1.canonical_pilot_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'position_identity_v1',
        misconceptionId: 'acts_without_reading_position',
        sourceTruthStatus: 'migrated',
        feedbackReason:
            'In position means acting after your opponent. Out of position '
            'means acting before your opponent. Acting later gives you more '
            'information before the next decision.',
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 0,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s11/drills/'
            'd.chain_position_open_call_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l11',
        sessionId: 'w3.s11',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s11.position_open_call.step2.canonical_pilot_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'unopened_late_position_open_v1',
        misconceptionId: 'opens_without_position_action_frame',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 1,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s11/drills/'
            'd.chain_position_open_call_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l11',
        sessionId: 'w3.s11',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s11.position_open_call.step3.canonical_pilot_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'facing_open_in_position_continue_v1',
        misconceptionId: 'treats_opened_pot_like_unopened_frame',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s12/drills/'
            'd.chain_position_continue_fold_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l12',
        sessionId: 'w3.s12',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s12.position_continue_fold.step3.canonical_pilot_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'facing_open_in_position_release_v1',
        misconceptionId: 'continues_too_wide_because_position_exists',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s13/drills/'
            'd.chain_position_open_fold_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l13',
        sessionId: 'w3.s13',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s13.position_open_fold.step3.canonical_pilot_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'unopened_late_position_release_v1',
        misconceptionId: 'overvalues_position_with_weak_offsuit_hand',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s14/drills/'
            'd.chain_position_sensitive_open_fold_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l14',
        sessionId: 'w3.s14',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s14.position_sensitive_open_fold.step3.canonical_pilot_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'same_hand_position_shift_release_v1',
        misconceptionId: 'ignores_same_hand_position_shift',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW3HandBucketActionFrameCanonicalPr2V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w3_hand_bucket_action_frame_canonical_pr2_v1';
  const fixtureLevel = 'w3_canonical_coverage_expansion_pr2';
  const conceptFamilyId = 'hand_bucket_action_frame_discipline';
  const repairFocusId = 'hand_bucket_before_preflop_action';
  const sameSignalGroupId = 'w3.position_thinking.hand_bucket_action_frame';
  const sourceJob = 'w3_canonical_coverage_pr2_hand_bucket_action_frame';
  const sourceIntentOverride = 'hand_bucket_action_frame_discipline';
  const sourceErrorClassOverride = 'hand_bucket_action_frame_error';

  return _exportAggregateFixture(
    outputPath: '$_outputDir/w3_hand_bucket_action_frame_canonical_pr2_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s01/drills/'
            'd.chain_preflop_framework_intro_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l01',
        sessionId: 'w3.s01',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s01.preflop_framework_intro.step1.canonical_pr2_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'unopened_premium_open_v1',
        misconceptionId: 'misses_premium_unopened_open',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 0,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s01/drills/'
            'd.chain_preflop_framework_intro_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l01',
        sessionId: 'w3.s01',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s01.preflop_framework_intro.step2.canonical_pr2_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'facing_open_playable_call_v1',
        misconceptionId: 'treats_facing_open_like_unopened_raise',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 1,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s01/drills/'
            'd.chain_preflop_framework_intro_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l01',
        sessionId: 'w3.s01',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s01.preflop_framework_intro.step3.canonical_pr2_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'out_of_position_weak_release_v1',
        misconceptionId: 'defends_weak_out_of_position_bucket',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s02/drills/'
            'd.chain_preflop_category_reuse_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l02',
        sessionId: 'w3.s02',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s02.preflop_category_reuse.step3.canonical_pr2_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'facing_open_weak_release_v1',
        misconceptionId: 'continues_weak_bucket_after_open',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s08/drills/'
            'd.chain_preflop_continue_fold_discipline_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l08',
        sessionId: 'w3.s08',
        packId: 'world3_spine_campaign_v1',
        taskId:
            'w3.s08.preflop_continue_fold_discipline.step1.canonical_pr2_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'facing_open_suited_continue_v1',
        misconceptionId: 'overfolds_playable_suited_bucket_after_open',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 0,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s10/drills/'
            'd.chain_preflop_final_checkpoint_v1.json',
        outputPath: '',
        fixtureId: fixtureId,
        fixtureLevel: fixtureLevel,
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l10',
        sessionId: 'w3.s10',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s10.preflop_final_checkpoint.step3.canonical_pr2_v1',
        conceptFamilyId: conceptFamilyId,
        repairFocusId: repairFocusId,
        sameSignalGroupId: sameSignalGroupId,
        transferSurfaceId: 'earlier_position_weak_release_v1',
        misconceptionId: 'opens_weak_bucket_with_players_behind',
        sourceTruthStatus: 'migrated',
        feedbackReason: null,
        sourceJob: sourceJob,
        claimsTransfer: true,
        sourceStepIndex: 2,
        sourceIntentOverride: sourceIntentOverride,
        sourceErrorClassOverride: sourceErrorClassOverride,
        safeClaimStatus: 'canonical_pilot',
        launchCoverageClaimed: false,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW3BridgeSchemaMigrationPilotV1({
  bool writeFiles = false,
}) {
  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w3_bridge_or_legacy_schema_migration_pilot_v1.json',
    fixtureId: 'w3_bridge_or_legacy_schema_migration_pilot_v1',
    fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s06/drills/'
            'd.choose_raise_mixed_context_checkpoint_v1.json',
        outputPath: '',
        fixtureId: 'w3_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l06',
        sessionId: 'w3.s06',
        packId: 'world3_spine_campaign_v1',
        taskId:
            'w3.s06.choose_raise_mixed_context_checkpoint_v1.bridge_pilot_v1',
        conceptFamilyId: 'preflop_framework_bridge',
        repairFocusId: 'preflop_frame_action_default',
        sameSignalGroupId: 'w3.preflop_framework.bridge_action_default',
        transferSurfaceId: 'late_position_open_v1',
        misconceptionId: 'acts_without_preflop_frame',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'preflop_framework_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s03/drills/'
            'd.choose_call_preflop_checkpoint_v1.json',
        outputPath: '',
        fixtureId: 'w3_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l03',
        sessionId: 'w3.s03',
        packId: 'world3_spine_campaign_v1',
        taskId: 'w3.s03.choose_call_preflop_checkpoint_v1.bridge_pilot_v1',
        conceptFamilyId: 'preflop_framework_bridge',
        repairFocusId: 'preflop_frame_action_default',
        sameSignalGroupId: 'w3.preflop_framework.bridge_action_default',
        transferSurfaceId: 'facing_open_continue_v1',
        misconceptionId: 'acts_without_preflop_frame',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'preflop_framework_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world3/v1/sessions/w3.s10/drills/'
            'd.choose_fold_final_preflop_checkpoint_v1.json',
        outputPath: '',
        fixtureId: 'w3_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_3',
        routeWorldId: 'world_3',
        displayWorldTitle: 'Position Thinking',
        contentOwnerWorldId: 'world_3',
        routeGateStatus: 'learner_playable',
        lessonId: 'w3.l10',
        sessionId: 'w3.s10',
        packId: 'world3_spine_campaign_v1',
        taskId:
            'w3.s10.choose_fold_final_preflop_checkpoint_v1.bridge_pilot_v1',
        conceptFamilyId: 'preflop_framework_bridge',
        repairFocusId: 'preflop_frame_action_default',
        sameSignalGroupId: 'w3.preflop_framework.bridge_action_default',
        transferSurfaceId: 'earlier_position_release_v1',
        misconceptionId: 'acts_without_preflop_frame',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'preflop_framework_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW4BridgeSchemaMigrationPilotV1({
  bool writeFiles = false,
}) {
  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w4_bridge_or_legacy_schema_migration_pilot_v1.json',
    fixtureId: 'w4_bridge_or_legacy_schema_migration_pilot_v1',
    fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
            'd.choose_raise_focus.json',
        outputPath: '',
        fixtureId: 'w4_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_4',
        routeWorldId: 'world_4',
        displayWorldTitle: 'Bet Purpose / Price',
        contentOwnerWorldId: 'world_4',
        routeGateStatus: 'learner_playable',
        lessonId: 'w4.l10',
        sessionId: 'w4.s10',
        packId: 'world4_spine_campaign_v1',
        taskId: 'w4.s10.choose_raise_focus.bridge_pilot_v1',
        conceptFamilyId: 'bet_purpose_price_bridge',
        repairFocusId: 'purpose_price_action_default',
        sameSignalGroupId: 'w4.bet_purpose_price.bridge_action_default',
        transferSurfaceId: 'denial_raise_v1',
        misconceptionId: 'chooses_size_without_purpose_or_price',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'bet_purpose_price_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
            'd.choose_call_focus.json',
        outputPath: '',
        fixtureId: 'w4_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_4',
        routeWorldId: 'world_4',
        displayWorldTitle: 'Bet Purpose / Price',
        contentOwnerWorldId: 'world_4',
        routeGateStatus: 'learner_playable',
        lessonId: 'w4.l10',
        sessionId: 'w4.s10',
        packId: 'world4_spine_campaign_v1',
        taskId: 'w4.s10.choose_call_focus.bridge_pilot_v1',
        conceptFamilyId: 'bet_purpose_price_bridge',
        repairFocusId: 'purpose_price_action_default',
        sameSignalGroupId: 'w4.bet_purpose_price.bridge_action_default',
        transferSurfaceId: 'control_call_v1',
        misconceptionId: 'chooses_size_without_purpose_or_price',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'bet_purpose_price_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
            'd.choose_fold_focus.json',
        outputPath: '',
        fixtureId: 'w4_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_4',
        routeWorldId: 'world_4',
        displayWorldTitle: 'Bet Purpose / Price',
        contentOwnerWorldId: 'world_4',
        routeGateStatus: 'learner_playable',
        lessonId: 'w4.l10',
        sessionId: 'w4.s10',
        packId: 'world4_spine_campaign_v1',
        taskId: 'w4.s10.choose_fold_focus.bridge_pilot_v1',
        conceptFamilyId: 'bet_purpose_price_bridge',
        repairFocusId: 'purpose_price_action_default',
        sameSignalGroupId: 'w4.bet_purpose_price.bridge_action_default',
        transferSurfaceId: 'release_when_denial_gone_v1',
        misconceptionId: 'chooses_size_without_purpose_or_price',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'bet_purpose_price_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW5BridgeSchemaMigrationPilotV1({
  bool writeFiles = false,
}) {
  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w5_bridge_or_legacy_schema_migration_pilot_v1.json',
    fixtureId: 'w5_bridge_or_legacy_schema_migration_pilot_v1',
    fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
            'd.classify_texture_synthesis_dry_raise_v1.json',
        outputPath: '',
        fixtureId: 'w5_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_5',
        routeWorldId: 'world_5',
        displayWorldTitle: 'Board Awareness',
        contentOwnerWorldId: 'world_5',
        routeGateStatus: 'learner_playable',
        lessonId: 'w5.l10',
        sessionId: 'w5.s10',
        packId: 'world5_spine_campaign_v1',
        taskId:
            'w5.s10.classify_texture_synthesis_dry_raise_v1.bridge_pilot_v1',
        conceptFamilyId: 'board_awareness_bridge',
        repairFocusId: 'texture_before_action',
        sameSignalGroupId: 'w5.board_awareness.bridge_texture_action_default',
        transferSurfaceId: 'dry_texture_pressure_v1',
        misconceptionId: 'acts_without_texture_read',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'board_awareness_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
            'd.classify_texture_synthesis_connected_call_v1.json',
        outputPath: '',
        fixtureId: 'w5_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_5',
        routeWorldId: 'world_5',
        displayWorldTitle: 'Board Awareness',
        contentOwnerWorldId: 'world_5',
        routeGateStatus: 'learner_playable',
        lessonId: 'w5.l10',
        sessionId: 'w5.s10',
        packId: 'world5_spine_campaign_v1',
        taskId:
            'w5.s10.classify_texture_synthesis_connected_call_v1.bridge_pilot_v1',
        conceptFamilyId: 'board_awareness_bridge',
        repairFocusId: 'texture_before_action',
        sameSignalGroupId: 'w5.board_awareness.bridge_texture_action_default',
        transferSurfaceId: 'connected_texture_control_v1',
        misconceptionId: 'acts_without_texture_read',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'board_awareness_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
            'd.classify_texture_synthesis_wet_fold_v1.json',
        outputPath: '',
        fixtureId: 'w5_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_5',
        routeWorldId: 'world_5',
        displayWorldTitle: 'Board Awareness',
        contentOwnerWorldId: 'world_5',
        routeGateStatus: 'learner_playable',
        lessonId: 'w5.l10',
        sessionId: 'w5.s10',
        packId: 'world5_spine_campaign_v1',
        taskId: 'w5.s10.classify_texture_synthesis_wet_fold_v1.bridge_pilot_v1',
        conceptFamilyId: 'board_awareness_bridge',
        repairFocusId: 'texture_before_action',
        sameSignalGroupId: 'w5.board_awareness.bridge_texture_action_default',
        transferSurfaceId: 'wet_texture_release_v1',
        misconceptionId: 'acts_without_texture_read',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'board_awareness_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1
exportW4PriceGivenBeforeActionCanonicalPilotV1({bool writeFiles = false}) {
  const fixtureId = 'w4_price_given_before_action_canonical_pilot_v1';
  const fixtureLevel = 'w4_w5_canonical_pilot_batch_v1';
  const conceptFamilyId = 'price_given_before_action';
  const repairFocusId = 'price_before_action';
  const sameSignalGroupId = 'w4.bet_purpose_price.price_given_before_action';
  const sourceJob = 'w4_canonical_pilot_price_given_before_action';
  const sourceIntentOverride = 'price_given_before_action';
  const sourceErrorClassOverride = 'price_before_action_error';
  _FactorySampleSpecV1 spec({
    required String sourcePath,
    required String lessonId,
    required String sessionId,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
    String? feedbackReason,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: sourcePath,
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_4',
      routeWorldId: 'world_4',
      displayWorldTitle: 'Bet Purpose / Price',
      contentOwnerWorldId: 'world_4',
      routeGateStatus: 'learner_playable',
      lessonId: lessonId,
      sessionId: sessionId,
      packId: 'world4_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      sameSignalGroupId: sameSignalGroupId,
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: feedbackReason,
      sourceJob: sourceJob,
      claimsTransfer: true,
      sourceIntentOverride: sourceIntentOverride,
      sourceErrorClassOverride: sourceErrorClassOverride,
      safeClaimStatus: 'canonical_pilot',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w4_price_given_before_action_canonical_pilot_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s01/drills/'
            'd.choose_half_pot_value.json',
        lessonId: 'w4.l01',
        sessionId: 'w4.s01',
        taskId: 'w4.s01.choose_half_pot_value.canonical_pilot_v1',
        transferSurfaceId: 'half_pot_value_price_v1',
        misconceptionId: 'sizes_before_naming_value_price',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s01/drills/'
            'd.choose_raise_value.json',
        lessonId: 'w4.l01',
        sessionId: 'w4.s01',
        taskId: 'w4.s01.choose_raise_value.canonical_pilot_v1',
        transferSurfaceId: 'raise_value_action_v1',
        misconceptionId: 'acts_before_naming_value_purpose',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s03/drills/'
            'd.choose_half_pot_value_checkpoint.json',
        lessonId: 'w4.l03',
        sessionId: 'w4.s03',
        taskId: 'w4.s03.choose_half_pot_value_checkpoint.canonical_pilot_v1',
        transferSurfaceId: 'half_pot_value_price_v1',
        misconceptionId: 'overprices_value_checkpoint',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s04/drills/'
            'd.choose_half_pot_value_stability.json',
        lessonId: 'w4.l04',
        sessionId: 'w4.s04',
        taskId: 'w4.s04.choose_half_pot_value_stability.canonical_pilot_v1',
        transferSurfaceId: 'half_pot_value_price_v1',
        misconceptionId: 'drops_stable_value_price',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s07/drills/'
            'd.choose_half_pot_value_followthrough.json',
        lessonId: 'w4.l07',
        sessionId: 'w4.s07',
        taskId: 'w4.s07.choose_half_pot_value_followthrough.canonical_pilot_v1',
        transferSurfaceId: 'half_pot_value_price_v1',
        misconceptionId: 'maxes_pressure_before_preserving_value',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s07/drills/'
            'd.choose_pot_value_pressure_finish.json',
        lessonId: 'w4.l07',
        sessionId: 'w4.s07',
        taskId: 'w4.s07.choose_pot_value_pressure_finish.canonical_pilot_v1',
        transferSurfaceId: 'pot_value_pressure_price_v1',
        misconceptionId: 'misses_when_value_supports_max_price',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1
exportW5BoardTextureClassificationCanonicalPilotV1({bool writeFiles = false}) {
  const fixtureId = 'w5_board_texture_classification_canonical_pilot_v1';
  const fixtureLevel = 'w4_w5_canonical_pilot_batch_v1';
  const conceptFamilyId = 'board_texture_classification';
  const repairFocusId = 'texture_before_action';
  const sameSignalGroupId = 'w5.board_awareness.board_texture_classification';
  const sourceJob = 'w5_canonical_pilot_board_texture_classification';
  _FactorySampleSpecV1 spec({
    required String sourcePath,
    required String lessonId,
    required String sessionId,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
    String? feedbackReason,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: sourcePath,
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_5',
      routeWorldId: 'world_5',
      displayWorldTitle: 'Board Awareness',
      contentOwnerWorldId: 'world_5',
      routeGateStatus: 'learner_playable',
      lessonId: lessonId,
      sessionId: sessionId,
      packId: 'world5_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      sameSignalGroupId: sameSignalGroupId,
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: feedbackReason,
      sourceJob: sourceJob,
      claimsTransfer: true,
      safeClaimStatus: 'canonical_pilot',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w5_board_texture_classification_canonical_pilot_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s01/drills/'
            'd.classify_texture_intro_dry_raise_v1.json',
        lessonId: 'w5.l01',
        sessionId: 'w5.s01',
        taskId: 'w5.s01.classify_texture_intro_dry_raise.canonical_pilot_v1',
        transferSurfaceId: 'dry_texture_pressure_v1',
        misconceptionId: 'misses_dry_texture_value_pressure',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s01/drills/'
            'd.classify_texture_intro_wet_call_v1.json',
        lessonId: 'w5.l01',
        sessionId: 'w5.s01',
        taskId: 'w5.s01.classify_texture_intro_wet_call.canonical_pilot_v1',
        transferSurfaceId: 'wet_texture_control_v1',
        misconceptionId: 'overplays_wet_texture',
        feedbackReason:
            'A draw is an incomplete hand that can become strong if the right '
            'card comes. Wet boards carry more draw pressure, so calling '
            'controls risk while still continuing.',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s01/drills/'
            'd.classify_texture_intro_paired_fold_v1.json',
        lessonId: 'w5.l01',
        sessionId: 'w5.s01',
        taskId: 'w5.s01.classify_texture_intro_paired_fold.canonical_pilot_v1',
        transferSurfaceId: 'paired_texture_release_v1',
        misconceptionId: 'ignores_paired_texture_release',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s03/drills/'
            'd.classify_wet_protection_connected_call_v1.json',
        lessonId: 'w5.l03',
        sessionId: 'w5.s03',
        taskId:
            'w5.s03.classify_wet_protection_connected_call.canonical_pilot_v1',
        transferSurfaceId: 'connected_texture_control_v1',
        misconceptionId: 'misses_connected_board_volatility',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s04/drills/'
            'd.classify_turn_shift_paired_fold_v1.json',
        lessonId: 'w5.l04',
        sessionId: 'w5.s04',
        taskId: 'w5.s04.classify_turn_shift_paired_fold.canonical_pilot_v1',
        transferSurfaceId: 'turn_shift_paired_release_v1',
        misconceptionId: 'continues_after_paired_turn_shift',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
            'd.classify_texture_synthesis_dry_raise_v1.json',
        lessonId: 'w5.l10',
        sessionId: 'w5.s10',
        taskId:
            'w5.s10.classify_texture_synthesis_dry_raise.canonical_pilot_v1',
        transferSurfaceId: 'dry_texture_pressure_v1',
        misconceptionId: 'fails_to_convert_clean_dry_synthesis',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1
exportW4IntentActionDisciplineCanonicalPr2V1({bool writeFiles = false}) {
  const fixtureId = 'w4_intent_action_discipline_canonical_pr2_v1';
  const fixtureLevel = 'w4_w5_canonical_coverage_expansion_pr2_v1';
  const conceptFamilyId = 'intent_action_discipline';
  const repairFocusId = 'purpose_before_action';
  const sameSignalGroupId = 'w4.bet_purpose_price.intent_action_discipline';
  const sourceJob = 'w4_canonical_pr2_intent_action_discipline';
  const sourceIntentOverride = 'intent_action_discipline';
  const sourceErrorClassOverride = 'purpose_before_action_error';
  _FactorySampleSpecV1 spec({
    required String sourcePath,
    required String lessonId,
    required String sessionId,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
    String? feedbackReason,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: sourcePath,
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_4',
      routeWorldId: 'world_4',
      displayWorldTitle: 'Bet Purpose / Price',
      contentOwnerWorldId: 'world_4',
      routeGateStatus: 'learner_playable',
      lessonId: lessonId,
      sessionId: sessionId,
      packId: 'world4_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      sameSignalGroupId: sameSignalGroupId,
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: feedbackReason,
      sourceJob: sourceJob,
      claimsTransfer: true,
      sourceIntentOverride: sourceIntentOverride,
      sourceErrorClassOverride: sourceErrorClassOverride,
      safeClaimStatus: 'canonical_pr2',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath: '$_outputDir/w4_intent_action_discipline_canonical_pr2_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s01/drills/'
            'd.choose_raise_protection.json',
        lessonId: 'w4.l01',
        sessionId: 'w4.s01',
        taskId: 'w4.s01.choose_raise_protection.canonical_pr2_v1',
        transferSurfaceId: 'protection_raise_action_v1',
        misconceptionId: 'chooses_price_before_protection_purpose',
        feedbackReason:
            'Protection means betting so drawing hands pay more to continue; '
            'raising here charges overcards and draws instead of giving them '
            'a free card.',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s02/drills/'
            'd.choose_raise_bluff.json',
        lessonId: 'w4.l02',
        sessionId: 'w4.s02',
        taskId: 'w4.s02.choose_raise_bluff.canonical_pr2_v1',
        transferSurfaceId: 'bluff_raise_action_v1',
        misconceptionId: 'misses_bluff_pressure_action',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s02/drills/'
            'd.choose_raise_denial.json',
        lessonId: 'w4.l02',
        sessionId: 'w4.s02',
        taskId: 'w4.s02.choose_raise_denial.canonical_pr2_v1',
        transferSurfaceId: 'denial_raise_action_v1',
        misconceptionId: 'undercharges_denial_spot',
        feedbackReason:
            'Equity means chance to win the hand. Raise here to make drawing '
            'hands pay more instead of letting them use that chance cheaply.',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s02/drills/'
            'd.choose_call_control.json',
        lessonId: 'w4.l02',
        sessionId: 'w4.s02',
        taskId: 'w4.s02.choose_call_control.canonical_pr2_v1',
        transferSurfaceId: 'denial_control_call_v1',
        misconceptionId: 'overraises_control_spot',
        feedbackReason:
            'Call controls risk when raising would build the pot without '
            'enough clear pressure.',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s03/drills/'
            'd.choose_raise_bluff.json',
        lessonId: 'w4.l03',
        sessionId: 'w4.s03',
        taskId: 'w4.s03.choose_raise_bluff.canonical_pr2_v1',
        transferSurfaceId: 'bluff_raise_action_v1',
        misconceptionId: 'ignores_blocker_bluff_pressure',
        feedbackReason:
            'Raise as a bluff when the spot creates enough simple pressure '
            'and opponents can still fold.',
      ),
      spec(
        sourcePath:
            'content/worlds/world4/v1/sessions/w4.s05/drills/'
            'd.choose_raise_repeat.json',
        lessonId: 'w4.l05',
        sessionId: 'w4.s05',
        taskId: 'w4.s05.choose_raise_repeat.canonical_pr2_v1',
        transferSurfaceId: 'protection_raise_action_v1',
        misconceptionId: 'misses_repeat_protection_raise',
        feedbackReason:
            'Protection means betting so drawing hands pay more to continue; '
            'raise here to charge draws instead of giving a free card.',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW5BoardShiftAwarenessCanonicalPr2V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w5_board_shift_awareness_canonical_pr2_v1';
  const fixtureLevel = 'w4_w5_canonical_coverage_expansion_pr2_v1';
  const conceptFamilyId = 'board_shift_awareness';
  const repairFocusId = 'board_shift_before_action';
  const sameSignalGroupId = 'w5.board_awareness.board_shift_awareness';
  const sourceJob = 'w5_canonical_pr2_board_shift_awareness';
  const sourceIntentOverride = 'board_shift_awareness';
  const sourceErrorClassOverride = 'board_shift_action_error';
  _FactorySampleSpecV1 spec({
    required String sourcePath,
    required String lessonId,
    required String sessionId,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: sourcePath,
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_5',
      routeWorldId: 'world_5',
      displayWorldTitle: 'Board Awareness',
      contentOwnerWorldId: 'world_5',
      routeGateStatus: 'learner_playable',
      lessonId: lessonId,
      sessionId: sessionId,
      packId: 'world5_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      sameSignalGroupId: sameSignalGroupId,
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: null,
      sourceJob: sourceJob,
      claimsTransfer: true,
      sourceIntentOverride: sourceIntentOverride,
      sourceErrorClassOverride: sourceErrorClassOverride,
      safeClaimStatus: 'canonical_pr2',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath: '$_outputDir/w5_board_shift_awareness_canonical_pr2_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s04/drills/'
            'd.classify_turn_shift_connected_raise_v1.json',
        lessonId: 'w5.l04',
        sessionId: 'w5.s04',
        taskId: 'w5.s04.classify_turn_shift_connected_raise.canonical_pr2_v1',
        transferSurfaceId: 'turn_connected_pressure_v1',
        misconceptionId: 'misses_connected_turn_pressure_shift',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s04/drills/'
            'd.classify_turn_shift_wet_call_v1.json',
        lessonId: 'w5.l04',
        sessionId: 'w5.s04',
        taskId: 'w5.s04.classify_turn_shift_wet_call.canonical_pr2_v1',
        transferSurfaceId: 'turn_wet_control_v1',
        misconceptionId: 'overplays_wet_turn_shift',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s04/drills/'
            'd.classify_turn_shift_paired_fold_v1.json',
        lessonId: 'w5.l04',
        sessionId: 'w5.s04',
        taskId: 'w5.s04.classify_turn_shift_paired_fold.canonical_pr2_v1',
        transferSurfaceId: 'turn_paired_release_v1',
        misconceptionId: 'forces_paired_turn_continue',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s05/drills/'
            'd.classify_river_closure_connected_call_v1.json',
        lessonId: 'w5.l05',
        sessionId: 'w5.s05',
        taskId: 'w5.s05.classify_river_closure_connected_call.canonical_pr2_v1',
        transferSurfaceId: 'river_connected_control_v1',
        misconceptionId: 'overpresses_connected_river_closure',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s05/drills/'
            'd.classify_river_closure_dry_fold_v1.json',
        lessonId: 'w5.l05',
        sessionId: 'w5.s05',
        taskId: 'w5.s05.classify_river_closure_dry_fold.canonical_pr2_v1',
        transferSurfaceId: 'river_dry_missed_release_v1',
        misconceptionId: 'continues_missed_dry_closure',
      ),
      spec(
        sourcePath:
            'content/worlds/world5/v1/sessions/w5.s05/drills/'
            'd.classify_river_closure_wet_raise_v1.json',
        lessonId: 'w5.l05',
        sessionId: 'w5.s05',
        taskId: 'w5.s05.classify_river_closure_wet_raise.canonical_pr2_v1',
        transferSurfaceId: 'river_wet_pressure_v1',
        misconceptionId: 'misses_completed_wet_river_pressure',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1
exportW6RangeBucketByBoardFitCanonicalPilotV1({bool writeFiles = false}) {
  const fixtureId = 'w6_range_bucket_by_board_fit_canonical_pilot_v1';
  const fixtureLevel = 'w6_range_bucket_source_repair_plan_v1';
  const conceptFamilyId = 'range_bucket_by_board_fit';
  const repairFocusId = 'bucket_before_action';
  const sameSignalGroupId = 'w6.range_thinking.range_bucket_by_board_fit';
  const sourceJob = 'w6_canonical_pilot_range_bucket_by_board_fit';
  _FactorySampleSpecV1 spec({
    required String sourcePath,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
    String? feedbackReason,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: sourcePath,
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_6',
      routeWorldId: 'world_6',
      displayWorldTitle: 'Range Thinking',
      contentOwnerWorldId: 'world_6',
      routeGateStatus: 'learner_playable',
      lessonId: 'w6.l01',
      sessionId: 'w6.s01',
      packId: 'world6_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      sameSignalGroupId: sameSignalGroupId,
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: feedbackReason,
      sourceJob: sourceJob,
      claimsTransfer: true,
      safeClaimStatus: 'canonical_pilot',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w6_range_bucket_by_board_fit_canonical_pilot_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s01/drills/'
            'd.classify_strong_raise.json',
        taskId: 'w6.s01.classify_strong_clean_fit.canonical_pilot_v1',
        transferSurfaceId: 'made_hand_clean_fit_v1',
        misconceptionId: 'misses_clean_made_hand_strength',
        feedbackReason:
            'A range is the set of hands an opponent could have here, not one '
            'exact hand. Strong means the made hand fits the board well and '
            'sits ahead of many weaker made hands.',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s01/drills/'
            'd.classify_strong_call_control.json',
        taskId: 'w6.s01.classify_strong_overpair_fit.canonical_pilot_v1',
        transferSurfaceId: 'made_hand_clean_fit_v1',
        misconceptionId: 'undervalues_overpair_board_fit',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s01/drills/'
            'd.classify_medium_call_control.json',
        taskId: 'w6.s01.classify_medium_second_pair_fit.canonical_pilot_v1',
        transferSurfaceId: 'made_hand_showdown_fit_v1',
        misconceptionId: 'overclasses_second_pair_as_strong',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s01/drills/'
            'd.classify_weak_fold_pressure.json',
        taskId: 'w6.s01.classify_weak_bottom_pair_fit.canonical_pilot_v1',
        transferSurfaceId: 'light_pair_fit_v1',
        misconceptionId: 'overclasses_bottom_pair_as_medium',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s01/drills/'
            'd.classify_missed_fold.json',
        taskId: 'w6.s01.classify_missed_overcards_no_draw.canonical_pilot_v1',
        transferSurfaceId: 'missed_no_clear_draw_v1',
        misconceptionId: 'treats_unpaired_overcards_as_made_fit',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s01/drills/'
            'd.classify_missed_fold_recheck.json',
        taskId: 'w6.s01.classify_missed_low_cards_no_draw.canonical_pilot_v1',
        transferSurfaceId: 'missed_no_clear_draw_v1',
        misconceptionId: 'treats_unpaired_low_cards_as_board_fit',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW6RangeWidthAwarenessCanonicalPr2V1({
  bool writeFiles = false,
}) {
  const fixtureId = 'w6_range_width_awareness_canonical_pr2_v1';
  const fixtureLevel = 'w6_canonical_coverage_expansion_pr2_v1';
  const conceptFamilyId = 'range_width_awareness';
  const repairFocusId = 'width_before_action';
  const sameSignalGroupId = 'w6.range_thinking.range_width_awareness';
  const sourceJob = 'w6_canonical_pr2_range_width_awareness';
  _FactorySampleSpecV1 spec({
    required String sourcePath,
    required String taskId,
    required String transferSurfaceId,
    required String misconceptionId,
    String? feedbackReason,
  }) {
    return _FactorySampleSpecV1(
      sourcePath: sourcePath,
      outputPath: '',
      fixtureId: fixtureId,
      fixtureLevel: fixtureLevel,
      worldId: 'world_6',
      routeWorldId: 'world_6',
      displayWorldTitle: 'Range Thinking',
      contentOwnerWorldId: 'world_6',
      routeGateStatus: 'learner_playable',
      lessonId: 'w6.l02',
      sessionId: 'w6.s02',
      packId: 'world6_spine_campaign_v1',
      taskId: taskId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      sameSignalGroupId: sameSignalGroupId,
      transferSurfaceId: transferSurfaceId,
      misconceptionId: misconceptionId,
      sourceTruthStatus: 'migrated',
      feedbackReason: feedbackReason,
      sourceJob: sourceJob,
      claimsTransfer: true,
      safeClaimStatus: 'canonical_pilot',
      launchCoverageClaimed: false,
    );
  }

  return _exportAggregateFixture(
    outputPath: '$_outputDir/w6_range_width_awareness_canonical_pr2_v1.json',
    fixtureId: fixtureId,
    fixtureLevel: fixtureLevel,
    writeFiles: writeFiles,
    specs: [
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s02/drills/'
            'd.find_btn_realize.json',
        taskId: 'w6.s02.classify_button_range_wider.canonical_pr2_v1',
        transferSurfaceId: 'late_position_more_hands_v1',
        misconceptionId: 'treats_button_like_utg_width',
        feedbackReason:
            'A range is the set of hands an opponent could have here, not one '
            'exact hand. Wider means the button can include more hands '
            'because fewer players remain behind.',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s02/drills/d.find_bb.json',
        taskId: 'w6.s02.classify_big_blind_continue_narrower.canonical_pr2_v1',
        transferSurfaceId: 'facing_open_filters_hands_v1',
        misconceptionId: 'treats_continue_range_as_all_hands',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s02/drills/'
            'd.choose_call_realize.json',
        taskId: 'w6.s02.classify_continue_range_narrower.canonical_pr2_v1',
        transferSurfaceId: 'facing_open_filters_hands_v1',
        misconceptionId: 'treats_continue_range_as_wide_as_opener',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s02/drills/'
            'd.choose_raise_blocker.json',
        taskId: 'w6.s02.classify_button_open_less_constrained.canonical_pr2_v1',
        transferSurfaceId: 'late_position_more_varied_v1',
        misconceptionId: 'overconstrains_late_position_range',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s02/drills/'
            'd.tap_flop_realize.json',
        taskId: 'w6.s02.classify_utg_range_stronger_average.canonical_pr2_v1',
        transferSurfaceId: 'early_position_fewer_stronger_v1',
        misconceptionId: 'misses_early_position_strength_filter',
      ),
      spec(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s02/drills/d.tap_turn.json',
        taskId: 'w6.s02.classify_late_position_more_hands.canonical_pr2_v1',
        transferSurfaceId: 'late_position_more_hands_v1',
        misconceptionId: 'misses_late_position_width',
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 exportW6BridgeSchemaMigrationPilotV1({
  bool writeFiles = false,
}) {
  return _exportAggregateFixture(
    outputPath:
        '$_outputDir/w6_bridge_or_legacy_schema_migration_pilot_v1.json',
    fixtureId: 'w6_bridge_or_legacy_schema_migration_pilot_v1',
    fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
    writeFiles: writeFiles,
    specs: [
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s10/drills/'
            'd.choose_raise_synthesis.json',
        outputPath: '',
        fixtureId: 'w6_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_6',
        routeWorldId: 'world_6',
        displayWorldTitle: 'Range Thinking',
        contentOwnerWorldId: 'world_6',
        routeGateStatus: 'learner_playable',
        lessonId: 'w6.l10',
        sessionId: 'w6.s10',
        packId: 'world6_spine_campaign_v1',
        taskId: 'w6.s10.choose_raise_synthesis.bridge_pilot_v1',
        conceptFamilyId: 'range_thinking_bridge',
        repairFocusId: 'range_before_action',
        sameSignalGroupId: 'w6.range_thinking.bridge_range_action_default',
        transferSurfaceId: 'range_strength_raise_v1',
        misconceptionId: 'acts_from_hand_only',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'range_thinking_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s10/drills/'
            'd.choose_call_synthesis.json',
        outputPath: '',
        fixtureId: 'w6_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_6',
        routeWorldId: 'world_6',
        displayWorldTitle: 'Range Thinking',
        contentOwnerWorldId: 'world_6',
        routeGateStatus: 'learner_playable',
        lessonId: 'w6.l10',
        sessionId: 'w6.s10',
        packId: 'world6_spine_campaign_v1',
        taskId: 'w6.s10.choose_call_synthesis.bridge_pilot_v1',
        conceptFamilyId: 'range_thinking_bridge',
        repairFocusId: 'range_before_action',
        sameSignalGroupId: 'w6.range_thinking.bridge_range_action_default',
        transferSurfaceId: 'equity_realization_call_v1',
        misconceptionId: 'acts_from_hand_only',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'range_thinking_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
      _FactorySampleSpecV1(
        sourcePath:
            'content/worlds/world6/v1/sessions/w6.s03/drills/'
            'd.choose_fold_trap.json',
        outputPath: '',
        fixtureId: 'w6_bridge_or_legacy_schema_migration_pilot_v1',
        fixtureLevel: 'w2_w6_bridge_coverage_expansion_pilot',
        worldId: 'world_6',
        routeWorldId: 'world_6',
        displayWorldTitle: 'Range Thinking',
        contentOwnerWorldId: 'world_6',
        routeGateStatus: 'learner_playable',
        lessonId: 'w6.l03',
        sessionId: 'w6.s03',
        packId: 'world6_spine_campaign_v1',
        taskId: 'w6.s03.choose_fold_trap.bridge_pilot_v1',
        conceptFamilyId: 'range_thinking_bridge',
        repairFocusId: 'range_before_action',
        sameSignalGroupId: 'w6.range_thinking.bridge_range_action_default',
        transferSurfaceId: 'range_weak_release_v1',
        misconceptionId: 'acts_from_hand_only',
        sourceTruthStatus: 'bridge_or_legacy',
        feedbackReason: null,
        sourceJob: 'range_thinking_bridge',
        claimsTransfer: true,
        safeClaimStatus: 'limited_bridge',
        launchCoverageClaimed: false,
      ),
    ],
  );
}

ContentFactoryImportExportResultV1 _exportAggregateFixture({
  required String outputPath,
  required String fixtureId,
  required String fixtureLevel,
  required List<_FactorySampleSpecV1> specs,
  required bool writeFiles,
}) {
  final tasks = specs
      .map((spec) => _exportSample(spec).task!)
      .toList(growable: false);
  final fixture = <String, Object?>{
    'schema_version': _schemaVersion,
    'fixture_id': fixtureId,
    'fixture_level': fixtureLevel,
    'generated_by': 'content_factory_import_export_mvp_v1',
    'tasks': tasks,
  };
  final result = ContentFactoryImportExportResultV1(
    outputPath: outputPath,
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

  final sourcePayload = _sourcePayload(decoded, spec);
  final sourceId = _requiredString(decoded, 'id', spec.sourcePath);
  final sourceKind = _requiredString(decoded, 'kind', spec.sourcePath);
  final sourceIntent =
      _optionalString(sourcePayload, 'intent_v1') ??
      _optionalString(decoded, 'intent_v1') ??
      spec.sourceIntentOverride ??
      (throw FormatException(
        'source task missing required string intent_v1',
        spec.sourcePath,
      ));
  final sourceErrorClass =
      spec.sourceErrorClassOverride ??
      _optionalString(sourcePayload, 'error_class') ??
      _optionalString(decoded, 'error_class') ??
      (throw FormatException(
        'source task missing required string error_class',
        spec.sourcePath,
      ));
  final correctAction =
      spec.correctActionOverride ??
      _expectedAction(sourcePayload, spec.sourcePath);
  final feedbackReason =
      spec.feedbackReason ??
      _requiredString(sourcePayload, 'why_v1', spec.sourcePath);
  final sourceChainId = _optionalString(decoded, 'chain_id');

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
      if (sourceChainId != null) 'source_chain_id': sourceChainId,
      if (spec.sourceStepIndex != null)
        'source_step_index': spec.sourceStepIndex,
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

Map<String, Object?> _sourcePayload(
  Map<String, Object?> decoded,
  _FactorySampleSpecV1 spec,
) {
  final sourceStepIndex = spec.sourceStepIndex;
  if (sourceStepIndex == null) return decoded;

  final steps = decoded['steps'];
  if (steps is! List ||
      sourceStepIndex < 0 ||
      sourceStepIndex >= steps.length ||
      steps[sourceStepIndex] is! Map) {
    throw FormatException(
      'source task missing usable steps[$sourceStepIndex]',
      spec.sourcePath,
    );
  }
  return (steps[sourceStepIndex]! as Map).cast<String, Object?>();
}

String? _optionalString(Map<String, Object?> source, String field) {
  final value = source[field];
  if (value is String && value.isNotEmpty) return value;
  return null;
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
    final presetId = expected['presetId'];
    if (presetId is String && presetId.isNotEmpty) return presetId;
  }
  final expectedAction = source['expected_action'];
  if (expectedAction is String && expectedAction.isNotEmpty) {
    return expectedAction;
  }
  final expectedPresetId = source['expected_preset_id'];
  if (expectedPresetId is String && expectedPresetId.isNotEmpty) {
    return expectedPresetId;
  }
  throw FormatException('source task missing expected action', path);
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
    this.correctActionOverride,
    this.sourceStepIndex,
    this.sourceIntentOverride,
    this.sourceErrorClassOverride,
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
  final String? correctActionOverride;
  final int? sourceStepIndex;
  final String? sourceIntentOverride;
  final String? sourceErrorClassOverride;
  final String? safeClaimStatus;
  final bool? launchCoverageClaimed;
}

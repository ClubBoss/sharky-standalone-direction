import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/content/release_content_plan.dart';

Map<String, Object> buildReleaseReadinessSnapshot({String rootPath = '.'}) {
  final root = Directory(rootPath);
  final rulesFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}EXECUTION_RULES.md',
  );
  final rulesContent = rulesFile.existsSync()
      ? rulesFile.readAsStringSync()
      : '';
  final baselineFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}release_confidence_baseline_v1.md',
  );
  final baselineContent = baselineFile.existsSync()
      ? baselineFile.readAsStringSync()
      : '';
  final checklistFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}final_product_release_checklist_v1.md',
  );
  final checklistContent = checklistFile.existsSync()
      ? checklistFile.readAsStringSync()
      : '';
  final smokeBaselineFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}final_product_smoke_baseline_v1.md',
  );
  final smokeBaselineContent = smokeBaselineFile.existsSync()
      ? smokeBaselineFile.readAsStringSync()
      : '';
  final decisionFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}go_hold_rollback_truth_v1.md',
  );
  final decisionContent = decisionFile.existsSync()
      ? decisionFile.readAsStringSync()
      : '';
  final operationalBaselineFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}operational_confidence_baseline_v1.md',
  );
  final operationalBaselineContent = operationalBaselineFile.existsSync()
      ? operationalBaselineFile.readAsStringSync()
      : '';
  final releaseReadmeFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}RELEASE_README.md',
  );
  final releaseReadmeContent = releaseReadmeFile.existsSync()
      ? releaseReadmeFile.readAsStringSync()
      : '';
  final operationalPacketOwnerFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}operational_review_packet_truth_v1.md',
  );
  final operationalPacketRunnerFile = File(
    '${root.path}${Platform.pathSeparator}tools${Platform.pathSeparator}operational_review_packet_v1.dart',
  );
  final operationalPacketJsonFile = File(
    '${root.path}${Platform.pathSeparator}release${Platform.pathSeparator}_reports${Platform.pathSeparator}operational_review_packet_v1.json',
  );
  final operationalPacketMarkdownFile = File(
    '${root.path}${Platform.pathSeparator}release${Platform.pathSeparator}_reports${Platform.pathSeparator}operational_review_packet_v1.md',
  );
  final humanReviewFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}release_owner_review_v1.md',
  );
  final humanReviewContent = humanReviewFile.existsSync()
      ? humanReviewFile.readAsStringSync()
      : '';
  final rollbackOwnershipFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}rollback_ownership_truth_v1.md',
  );
  final rollbackOwnershipContent = rollbackOwnershipFile.existsSync()
      ? rollbackOwnershipFile.readAsStringSync()
      : '';
  final storeGuardDocumented = rulesContent.contains('STORE_PACKAGE_GUARD=1');
  final releaseContentDocumented = rulesContent.contains(
    'RELEASE_CONTENT_GUARD=1',
  );

  final storeAssetsTest = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}store_package_assets_contract_test.dart',
  );
  final storeDocsTest = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}store_package_docs_sync_contract_test.dart',
  );
  final executionRulesTest = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}store_package_execution_rules_sync_contract_test.dart',
  );
  final telemetryTest = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}store_package_telemetry_guard_test.dart',
  );
  final telemetryIntegrityTest = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}telemetry_release_critical_integrity_test.dart',
  );
  final contentTest = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}release_content_meaningful_contract_test.dart',
  );
  final scriptFile = File(
    '${root.path}${Platform.pathSeparator}tool${Platform.pathSeparator}release_dry_run_gate.sh',
  );
  final smokeRunnerFile = File(
    '${root.path}${Platform.pathSeparator}tool${Platform.pathSeparator}release_smoke_baseline_v1.sh',
  );
  final telemetryLogFile = File(
    '${root.path}${Platform.pathSeparator}release${Platform.pathSeparator}_reports${Platform.pathSeparator}telemetry.jsonl',
  );
  final lowOpsProofFile = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}ops${Platform.pathSeparator}low_ops_burden_proof_v1.md',
  );
  final world1GateScript = File(
    '${root.path}${Platform.pathSeparator}tools${Platform.pathSeparator}release_gate_world1.sh',
  );
  final branchSurfaceFile = File(
    '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}ui_v2${Platform.pathSeparator}screens${Platform.pathSeparator}module_launcher_screen.dart',
  );
  final focusSeamFile = File(
    '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}services${Platform.pathSeparator}progress_service.dart',
  );
  final firstWinContractFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}ui_v2${Platform.pathSeparator}onboarding_first_win_test.dart',
  );
  final intakePlanFile = File(
    '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}ui_v2${Platform.pathSeparator}screens${Platform.pathSeparator}universal_intake_plan_screen.dart',
  );
  final intakeContractFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}guards${Platform.pathSeparator}world1_app_root_startup_contract_test.dart',
  );
  final iosAssetsDir = Directory(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}store${Platform.pathSeparator}ios',
  );
  final androidAssetsDir = Directory(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}store${Platform.pathSeparator}android',
  );
  final generatedStoreAssetsDoc = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}release${Platform.pathSeparator}store_assets_v1.md',
  );
  final storeAssetsContract = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}contracts${Platform.pathSeparator}store_package_assets_contract_test.dart',
  );
  final generatedStoreAssetsZip = File(
    '${root.path}${Platform.pathSeparator}out${Platform.pathSeparator}modern_table_screenshots_v1.zip',
  );
  final inRepoStoreAssetsPresent =
      iosAssetsDir.existsSync() && androidAssetsDir.existsSync();
  final generatedStoreAssetsPresent =
      generatedStoreAssetsDoc.existsSync() &&
      storeAssetsContract.existsSync() &&
      generatedStoreAssetsZip.existsSync();
  final storeAssetsPresent =
      inRepoStoreAssetsPresent || generatedStoreAssetsPresent;
  final releaseContentDirsPresent = ReleaseContentPlanV1.manifestEnforcedModules
      .every(
        (module) => Directory(
          '${root.path}${Platform.pathSeparator}content${Platform.pathSeparator}${module.id}${Platform.pathSeparator}v1',
        ).existsSync(),
      );
  final branchProgressionSurfacePresent =
      branchSurfaceFile.existsSync() &&
      branchSurfaceFile.readAsStringSync().contains('ModuleLauncherBranch');
  final personalizationFocusSeamPresent =
      focusSeamFile.existsSync() &&
      focusSeamFile.readAsStringSync().contains('lesson_focus_label_v1');
  final firstWinContractPresent = firstWinContractFile.existsSync();
  final intakePlanPresent = intakePlanFile.existsSync();
  final intakeContractPresent = intakeContractFile.existsSync();
  final sessionResultContractFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}ui_v2${Platform.pathSeparator}session_result_world1_onboarding_payoff_test.dart',
  );
  final moduleLauncherBoundaryContractFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}guards${Platform.pathSeparator}module_launcher_legacy_bridge_boundary_contract_test.dart',
  );
  final todayEntitlementTruthFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}ui_v2${Platform.pathSeparator}today_plan_entitlement_truth_v1_test.dart',
  );
  final premiumHubAccessStateFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}ui_v2${Platform.pathSeparator}premium_hub_access_state_v1_test.dart',
  );
  final worldCampaignMapHomeFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}guards${Platform.pathSeparator}world_campaign_map_home_contract_test.dart',
  );
  final worldCampaignMapHomeContent = worldCampaignMapHomeFile.existsSync()
      ? worldCampaignMapHomeFile.readAsStringSync()
      : '';
  final legalScreenTestFile = File(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}ui_v2${Platform.pathSeparator}legal_screen_v1_test.dart',
  );

  final guards = <String, Object>{
    'store_assets': _guardStatus(
      exists: storeAssetsTest.existsSync(),
      toggleDocumented: storeGuardDocumented,
    ),
    'store_docs': _guardStatus(
      exists: storeDocsTest.existsSync(),
      toggleDocumented: false,
    ),
    'execution_rules': _guardStatus(
      exists: executionRulesTest.existsSync() && scriptFile.existsSync(),
      toggleDocumented: false,
    ),
    'telemetry': _guardStatus(
      exists: telemetryTest.existsSync(),
      toggleDocumented: false,
    ),
    'content_meaningful': _guardStatus(
      exists: contentTest.existsSync(),
      toggleDocumented: releaseContentDocumented,
    ),
  };

  final enforcement = <String, Object>{
    'STORE_PACKAGE_GUARD': storeGuardDocumented ? 'documented' : 'missing',
    'RELEASE_CONTENT_GUARD': releaseContentDocumented
        ? 'documented'
        : 'missing',
  };

  return <String, Object>{
    'version': 'v1',
    'confidenceScope': 'bounded_multi_surface_release_confidence',
    'goVerdict': 'not_a_go_verdict',
    'guards': guards,
    'enforcement': enforcement,
    'baselineDocPresent': baselineFile.existsSync(),
    'baselineDocSaysNotGo': baselineContent.contains('not a GO verdict'),
    'baselineDocSaysBoundedScope': baselineContent.contains(
      'bounded release-confidence baseline',
    ),
    'fullProductChecklistPresent': checklistFile.existsSync(),
    'fullProductChecklistSaysCurrentMain':
        checklistContent.contains(
          'current-main full-product release checklist',
        ) &&
        checklistContent.contains(
          '## Machine-Proven Checklist Items On Current Main',
        ),
    'fullProductChecklistSaysNotGo': checklistContent.contains(
      'It is not a GO verdict',
    ),
    'boundedSmokeBaselinePresent': smokeBaselineFile.existsSync(),
    'boundedSmokeBaselineSaysNotFullCoverage': smokeBaselineContent.contains(
      'does not claim complete full-product smoke coverage',
    ),
    'goNoGoArtifactPresent': decisionFile.existsSync(),
    'goNoGoStateIsHold': decisionContent.contains('Current state: HOLD'),
    'rollbackArtifactPresent': decisionFile.existsSync(),
    'rollbackTruthSaysUnresolved': decisionContent.contains(
      'No active artifact currently proves a finalized production rollback runbook',
    ),
    'humanReviewOwnerPresent': humanReviewFile.existsSync(),
    'humanReviewStatePending': humanReviewContent.contains(
      'Current state: PENDING_HUMAN_REVIEW',
    ),
    'rollbackOwnershipOwnerPresent': rollbackOwnershipFile.existsSync(),
    'rollbackOwnershipSaysUnresolvedButOwned': rollbackOwnershipContent
        .contains('Current state: UNRESOLVED_BUT_OWNED'),
    'operationalConfidenceBaselinePresent': operationalBaselineFile
        .existsSync(),
    'operationalConfidenceSaysBounded': operationalBaselineContent.contains(
      'bounded operational-confidence baseline',
    ),
    'operationalReviewCadencePresent': operationalBaselineContent.contains(
      '## Review Cadence On Current Main',
    ),
    'operationalDecisionLoopPresent': operationalBaselineContent.contains(
      '## Decisions Current Main Can Support',
    ),
    'operationalDashboardTruthPresent': operationalBaselineContent.contains(
      '## Dashboard / Report Truth On Current Main',
    ),
    'operationalDashboardTruthSaysNoCanonicalDashboard':
        operationalBaselineContent.contains(
          'No canonical active dashboard is currently the governed decision owner',
        ),
    'releaseReadmeHistoricalOnly': releaseReadmeContent.contains(
      'Status: HISTORICAL SNAPSHOT / NOT ACTIVE OPS OWNER',
    ),
    'operationalReviewPacketOwnerPresent': operationalPacketOwnerFile
        .existsSync(),
    'operationalReviewPacketRunnerPresent': operationalPacketRunnerFile
        .existsSync(),
    'operationalReviewPacketJsonPresent': operationalPacketJsonFile
        .existsSync(),
    'operationalReviewPacketMarkdownPresent': operationalPacketMarkdownFile
        .existsSync(),
    'telemetryReleaseCriticalIntegrityPresent': telemetryIntegrityTest
        .existsSync(),
    'releaseTelemetryGuardPresent': telemetryTest.existsSync(),
    'telemetryLogPresent': telemetryLogFile.existsSync(),
    'lowOpsProofPresent': lowOpsProofFile.existsSync(),
    'storeAssetsPresent': storeAssetsPresent,
    'releaseContentDirsPresent': releaseContentDirsPresent,
    'releaseDryRunGateScriptPresent': scriptFile.existsSync(),
    'releaseSmokeBaselineScriptPresent': smokeRunnerFile.existsSync(),
    'world1ReleaseGateScriptPresent': world1GateScript.existsSync(),
    'branchProgressionSurfacePresent': branchProgressionSurfacePresent,
    'personalizationFocusSeamPresent': personalizationFocusSeamPresent,
    'firstWinContractPresent': firstWinContractPresent,
    'intakePlanPresent': intakePlanPresent,
    'intakeContractPresent': intakeContractPresent,
    'sessionResultContinuationPresent': sessionResultContractFile.existsSync(),
    'moduleLauncherBoundaryContractPresent': moduleLauncherBoundaryContractFile
        .existsSync(),
    'todayEntitlementTruthPresent': todayEntitlementTruthFile.existsSync(),
    'premiumHubAccessStatePresent': premiumHubAccessStateFile.existsSync(),
    'premiumTargetGatingPresent':
        worldCampaignMapHomeContent.contains(
          'today plan gates world5 placement behind premium preview and restore unblocks next attempt',
        ) &&
        worldCampaignMapHomeContent.contains(
          'today plan allows trial-active entitlement to open premium-target placement deterministically',
        ),
    'legalSurfacePresencePresent': legalScreenTestFile.existsSync(),
    'executionRulesPresent': rulesFile.existsSync(),
    'fullProductSmokePathPresent': smokeRunnerFile.existsSync(),
  };
}

String encodeSnapshot(Map<String, Object> snapshot) {
  return const JsonEncoder.withIndent('  ').convert(snapshot);
}

String _guardStatus({required bool exists, required bool toggleDocumented}) {
  if (!exists) return 'missing';
  if (toggleDocumented) return 'skipped_by_default';
  return 'present';
}

void main() {
  final snapshot = buildReleaseReadinessSnapshot();
  stdout.writeln(encodeSnapshot(snapshot));
}

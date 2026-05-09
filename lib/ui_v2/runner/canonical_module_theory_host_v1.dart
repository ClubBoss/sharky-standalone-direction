import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/action_order_btn_last_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/bet_sizing_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/blockers_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/board_texture_buckets_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/check_vs_bet_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/core_starting_hands_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/exploit_adjustments_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/forced_bets_etalon_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/plan_builder_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/position_ip_oop_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/pot_growth_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/preflop_mixed_checkpoint_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/range_advantage_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/range_advantage_continuation_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_bluff_selection_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_bluffcatch_thresholds_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_checkback_vs_value_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_discipline_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_jam_vs_blocker_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_mixed_checkpoint_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_overbet_vs_standard_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/river_value_vs_bluff_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/sizing_by_texture_basics_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/theory_session_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/turn_barrel_vs_check_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/turn_mixed_checkpoint_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/value_targeting_basics_screen.dart';

typedef _TableFirstBuilderV1 =
    Widget Function(String moduleId, String moduleTitle);

Future<String> loadCanonicalModuleTheoryHostTitleV1(String moduleId) async {
  try {
    final manifestJson = await rootBundle.loadString(
      'content/$moduleId/v1/manifest.json',
    );
    final data = jsonDecode(manifestJson) as Map<String, dynamic>;
    final title = (data['title'] ?? data['name']) as String?;
    if (title != null && title.isNotEmpty) {
      return title;
    }
  } catch (_) {
    // Fallback to moduleId if manifest is missing or malformed.
  }
  return moduleId;
}

final Map<String, _TableFirstBuilderV1> _canonicalTableFirstRoutesV1 = {
  preflopMixedCheckpointModuleId: (id, title) =>
      PreflopMixedCheckpointScenarioScreen(moduleId: id, moduleTitle: title),
  forcedBetsEtalonModuleId: (id, title) =>
      ForcedBetsEtalonScenarioScreen(moduleId: id, moduleTitle: title),
  actionOrderBtnLastModuleId: (id, title) =>
      ActionOrderBtnLastScenarioScreen(moduleId: id, moduleTitle: title),
  positionIpOopBasicsModuleId: (id, title) =>
      PositionIpOopBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  rangeAdvantageBasicsModuleId: (id, title) =>
      RangeAdvantageBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  rangeAdvantageContinuationModuleId: (id, title) =>
      RangeAdvantageContinuationScreen(moduleId: id, moduleTitle: title),
  boardTextureBucketsModuleId: (id, title) =>
      BoardTextureBucketsScenarioScreen(moduleId: id, moduleTitle: title),
  turnBarrelVsCheckModuleId: (id, title) =>
      TurnBarrelVsCheckScenarioScreen(moduleId: id, moduleTitle: title),
  turnMixedCheckpointModuleId: (id, title) =>
      TurnMixedCheckpointScenarioScreen(moduleId: id, moduleTitle: title),
  riverValueVsBluffModuleId: (id, title) =>
      RiverValueVsBluffScenarioScreen(moduleId: id, moduleTitle: title),
  riverDisciplineBasicsModuleId: (id, title) =>
      RiverDisciplineBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  riverCheckbackBasicsModuleId: (id, title) =>
      RiverCheckbackVsValueScenarioScreen(moduleId: id, moduleTitle: title),
  riverBluffSelectionModuleId: (id, title) =>
      RiverBluffSelectionScenarioScreen(moduleId: id, moduleTitle: title),
  riverBluffcatchThresholdsModuleId: (id, title) =>
      RiverBluffcatchThresholdsScenarioScreen(moduleId: id, moduleTitle: title),
  riverOverbetVsStandardModuleId: (id, title) =>
      RiverOverbetVsStandardScenarioScreen(moduleId: id, moduleTitle: title),
  riverJamVsBlockerModuleId: (id, title) =>
      RiverJamVsBlockerScenarioScreen(moduleId: id, moduleTitle: title),
  riverMixedCheckpointModuleId: (id, title) =>
      RiverMixedCheckpointScenarioScreen(moduleId: id, moduleTitle: title),
  exploitAdjustmentsBasicsModuleId: (id, title) =>
      ExploitAdjustmentsBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  planBuilderBasicsModuleId: (id, title) =>
      PlanBuilderBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  sizingByTextureBasicsModuleId: (id, title) =>
      SizingByTextureBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  blockersBasicsModuleId: (id, title) =>
      BlockersBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  valueTargetingBasicsModuleId: (id, title) =>
      ValueTargetingBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  potGrowthBasicsModuleId: (id, title) =>
      PotGrowthBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  checkVsBetBasicsModuleId: (id, title) =>
      CheckVsBetBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  betSizingBasicsModuleId: (id, title) =>
      BetSizingBasicsScenarioScreen(moduleId: id, moduleTitle: title),
  coreStartingHandsModuleId: (id, title) =>
      CoreStartingHandsScreen(moduleId: id, moduleTitle: title),
};

Widget buildCanonicalModuleTheoryHostScreenV1(
  String moduleId,
  String moduleTitle, {
  ProgressionHandoffContextV1? handoffContextV1,
}) {
  if (moduleId == actionOrderBtnLastModuleId) {
    return ActionOrderBtnLastScenarioScreen(
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      handoffContextV1: handoffContextV1,
    );
  }
  final builder = _canonicalTableFirstRoutesV1[moduleId];
  if (builder != null) {
    return builder(moduleId, moduleTitle);
  }
  return FutureBuilder<bool>(
    future: const DrillRuntimeAdapterV1().hasSessionDrills(moduleId),
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return CanonicalLauncherV1.sessionDrill(sessionId: moduleId);
      }
      return TheorySessionScreen(moduleId: moduleId, moduleTitle: moduleTitle);
    },
  );
}

Route<void> canonicalModuleTheoryHostRouteV1({
  required String moduleId,
  required String moduleTitle,
  ProgressionHandoffContextV1? handoffContextV1,
}) {
  return MaterialPageRoute<void>(
    builder: (_) => buildCanonicalModuleTheoryHostScreenV1(
      moduleId,
      moduleTitle,
      handoffContextV1: handoffContextV1,
    ),
  );
}

Future<void> pushReplacementCanonicalModuleTheoryHostV1(
  BuildContext context,
  String moduleId, {
  String? moduleTitle,
  ProgressionHandoffContextV1? handoffContextV1,
}) async {
  final resolvedTitle =
      moduleTitle ?? await loadCanonicalModuleTheoryHostTitleV1(moduleId);
  if (!context.mounted) return;
  Navigator.of(context).pushReplacement(
    canonicalModuleTheoryHostRouteV1(
      moduleId: moduleId,
      moduleTitle: resolvedTitle,
      handoffContextV1: handoffContextV1,
    ),
  );
}

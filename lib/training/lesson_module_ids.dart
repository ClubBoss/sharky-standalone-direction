/// Compatibility-only constants for the older table-first lesson chain.
///
/// These IDs remain live because runner/theory/review compatibility seams still
/// import them, but they are not the active authored content truth for the
/// standalone Sharky_1.0 product. Active authored content now lives in Act0
/// and `content/worlds/` under the W1-W12 master-plan route.
///
/// Freeze marker: kTableFirstFrameworkFreezeId = 'freeze_2025_12_25_v1'
const String preflopMixedCheckpointModuleId = 'preflop_mixed_checkpoint';
const String forcedBetsEtalonModuleId = 'forced_bets_etalon';
const String actionOrderBtnLastModuleId = 'action_order_btn_last';
const String potGrowthBasicsModuleId = 'pot_growth_basics';
const String checkVsBetBasicsModuleId = 'check_vs_bet_basics';
const String betSizingBasicsModuleId = 'bet_sizing_basics';

const String positionIpOopBasicsModuleId = 'position_ip_oop_basics';
const String rangeAdvantageBasicsModuleId = 'range_advantage_basics';
const String rangeAdvantageContinuationModuleId =
    'range_advantage_continuation';
const String boardTextureBucketsModuleId = 'board_texture_buckets';
const String turnBarrelVsCheckModuleId = 'turn_barrel_vs_check';
const String turnMixedCheckpointModuleId = 'turn_mixed_checkpoint';
const String riverValueVsBluffModuleId = 'river_value_vs_bluff';
const String riverDisciplineBasicsModuleId = 'river_discipline_basics';
const String riverCheckbackBasicsModuleId = 'river_checkback_basics';
const String riverBluffSelectionModuleId = 'river_bluff_selection';
const String riverBluffcatchThresholdsModuleId = 'river_bluffcatch_thresholds';
const String riverOverbetVsStandardModuleId = 'river_overbet_vs_standard';
const String riverJamVsBlockerModuleId = 'river_jam_vs_blocker';
const String riverMixedCheckpointModuleId = 'river_mixed_checkpoint';
const String exploitAdjustmentsBasicsModuleId = 'exploit_adjustments_basics';
const String planBuilderBasicsModuleId = 'plan_builder_basics';
const String sizingByTextureBasicsModuleId = 'sizing_by_texture_basics';
const String blockersBasicsModuleId = 'blockers_basics';
const String valueTargetingBasicsModuleId = 'value_targeting_basics';
const String coreStartingHandsModuleId = 'core_starting_hands';

const List<String> tableFirstLessonModuleIds = [
  preflopMixedCheckpointModuleId,
  forcedBetsEtalonModuleId,
  actionOrderBtnLastModuleId,
  positionIpOopBasicsModuleId,
  rangeAdvantageBasicsModuleId,
  rangeAdvantageContinuationModuleId,
  boardTextureBucketsModuleId,
  turnBarrelVsCheckModuleId,
  turnMixedCheckpointModuleId,
  riverValueVsBluffModuleId,
  riverDisciplineBasicsModuleId,
  riverCheckbackBasicsModuleId,
  riverBluffSelectionModuleId,
  riverBluffcatchThresholdsModuleId,
  riverOverbetVsStandardModuleId,
  riverJamVsBlockerModuleId,
  riverMixedCheckpointModuleId,
  exploitAdjustmentsBasicsModuleId,
  planBuilderBasicsModuleId,
  sizingByTextureBasicsModuleId,
  blockersBasicsModuleId,
  valueTargetingBasicsModuleId,
  potGrowthBasicsModuleId,
  checkVsBetBasicsModuleId,
  betSizingBasicsModuleId,
  coreStartingHandsModuleId,
];

const bool kTableFirstChainLocked = true;
const bool kAllowTableFirstOrderEdits = false;

const List<String> tableFirstLessonOrder = tableFirstLessonModuleIds;
const List<String> _tableFirstOrderSnapshot = [
  preflopMixedCheckpointModuleId,
  forcedBetsEtalonModuleId,
  actionOrderBtnLastModuleId,
  positionIpOopBasicsModuleId,
  rangeAdvantageBasicsModuleId,
  rangeAdvantageContinuationModuleId,
  boardTextureBucketsModuleId,
  turnBarrelVsCheckModuleId,
  turnMixedCheckpointModuleId,
  riverValueVsBluffModuleId,
  riverDisciplineBasicsModuleId,
  riverCheckbackBasicsModuleId,
  riverBluffSelectionModuleId,
  riverBluffcatchThresholdsModuleId,
  riverOverbetVsStandardModuleId,
  riverJamVsBlockerModuleId,
  riverMixedCheckpointModuleId,
  exploitAdjustmentsBasicsModuleId,
  planBuilderBasicsModuleId,
  sizingByTextureBasicsModuleId,
  blockersBasicsModuleId,
  valueTargetingBasicsModuleId,
  potGrowthBasicsModuleId,
  checkVsBetBasicsModuleId,
  betSizingBasicsModuleId,
  coreStartingHandsModuleId,
];
const List<String> kTableFirstDemoSpine = [
  forcedBetsEtalonModuleId,
  actionOrderBtnLastModuleId,
  positionIpOopBasicsModuleId,
  rangeAdvantageBasicsModuleId,
];
bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final bool _tableFirstOrderGuard = (() {
  if (kTableFirstChainLocked && !kAllowTableFirstOrderEdits) {
    assert(
      _listEquals(tableFirstLessonOrder, _tableFirstOrderSnapshot),
      'Table-first lesson order changed while chain lock is active.',
    );
  }
  return true;
})();

String? nextTableFirstLessonId(String currentModuleId) {
  final index = tableFirstLessonOrder.indexOf(currentModuleId);
  if (index < 0 || index + 1 >= tableFirstLessonOrder.length) {
    return null;
  }
  return tableFirstLessonOrder[index + 1];
}

import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/canonical/canonical_landing_decision_v1.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart'
    as canonical_truth;
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/canonical/world1_topology_entry_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/constants/launch_package_truth_v1.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:poker_analyzer/personalization/skill_tags_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/return_loop_service_v1.dart';
import 'package:poker_analyzer/services/learning_stats_v1_service.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/player_profile_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/module_launcher_screen.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/map/path_nodes_v1.dart';
import 'package:poker_analyzer/ui_v2/map/season1_checkpoint_selector_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';

// DoD:
// - [ ] `flutter format --set-exit-if-changed lib/sharky/design_tokens_v1.dart lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
// - [ ] `dart analyze`
// - [ ] Connectors follow width/color/dash/cap requirements
// - [ ] Only Learn Path visuals touched

const int _mapRhythmRuleEveryNPacksV1 = 3;
const bool _showLegacyPathRhythmStripOnCampaignMapV1 = false;
const bool _showLegacyAct0CardsOnCampaignMapV1 = false;

String mapLearningTopFocusLabelV1(String value) => 'Top focus: $value';

enum MapDebugAutoOpenSurfaceV1 { levelsSheet, levelCompleteSheet }

class _MapNodePreviewStateV1 {
  const _MapNodePreviewStateV1({
    required this.anchorRect,
    required this.packId,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.inlineWorld,
    required this.canStart,
  });

  final Rect anchorRect;
  final String packId;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final int inlineWorld;
  final bool canStart;
}

enum MapNextActionKindV1 { start_next_pack, start_review_queue }

class MapRhythmDecisionV1 {
  const MapRhythmDecisionV1({required this.kind, required this.reason});

  final MapNextActionKindV1 kind;
  final String reason;
}

MapRhythmDecisionV1 decideNextActionV1({
  required int completedPacksCount,
  required bool hasReviewQueueForNextPack,
  int rhythmEveryN = 3,
}) {
  final safeRhythmEveryN = rhythmEveryN <= 0 ? 3 : rhythmEveryN;
  final checkpointDue =
      completedPacksCount > 0 &&
      completedPacksCount % safeRhythmEveryN == 0 &&
      hasReviewQueueForNextPack;
  if (checkpointDue) {
    return const MapRhythmDecisionV1(
      kind: MapNextActionKindV1.start_review_queue,
      reason: 'Review required',
    );
  }
  if (hasReviewQueueForNextPack) {
    return const MapRhythmDecisionV1(
      kind: MapNextActionKindV1.start_review_queue,
      reason: 'Missed spots ready',
    );
  }
  return const MapRhythmDecisionV1(
    kind: MapNextActionKindV1.start_next_pack,
    reason: 'Continue',
  );
}

String todayPlanRoutingReasonLineV1({
  required String normalizedNextPackId,
  required bool reviewDueForNextPack,
  required String mapRhythmReason,
}) {
  return resolveProgressionRouteStoryForPackV1(
    nextPackId: normalizedNextPackId,
    reviewRequired: reviewDueForNextPack,
    activePackId: '',
    nextHandIndex: 0,
    rhythmReason: mapRhythmReason,
  ).reasonLine;
}

String mapCheckpointPendingReasonTextV1({
  required String normalizedNextPackId,
  required String activePackId,
  required int nextHandIndex,
  required String mapRhythmReason,
}) {
  final reasonLine = resolveProgressionRouteStoryForPackV1(
    nextPackId: normalizedNextPackId,
    reviewRequired: true,
    activePackId: activePackId,
    nextHandIndex: nextHandIndex,
    rhythmReason: mapRhythmReason,
  ).reasonLine;
  return progressionRouteReasonValueTextV1(reasonLine);
}

class _MapRhythmDecisionV1 {
  const _MapRhythmDecisionV1({
    required this.isReviewDueForNextPack,
    required this.isCheckpointDueByRhythm,
    required this.effectiveNextAction,
    required this.reason,
  });

  final bool isReviewDueForNextPack;
  final bool isCheckpointDueByRhythm;
  final MapNextActionKindV1 effectiveNextAction;
  final String reason;

  bool get shouldGateStartNowToReview => isReviewDueForNextPack;
}

class MapReviewQueueStripLabelsV1 {
  const MapReviewQueueStripLabelsV1({
    required this.title,
    required this.value,
    required this.cta,
  });

  final String title;
  final String value;
  final String cta;
}

MapReviewQueueStripLabelsV1 mapReviewQueueStripLabelsV1({
  required bool reviewRequired,
  String? normalizedNextPackId,
  String? valueOverride,
}) {
  final value = valueOverride?.trim();
  final target = normalizedNextPackId == null
      ? null
      : resolveProgressionRouteTargetForPackIdV1(normalizedNextPackId);
  final cadenceValue = target == null
      ? null
      : progressionReviewCadenceValueForTargetV1(
          target: target,
          reviewRequired: reviewRequired,
          rhythmReason: reviewRequired
              ? 'Review required'
              : 'Missed spots ready',
        );
  return MapReviewQueueStripLabelsV1(
    title: reviewRequired ? 'UP NEXT' : 'REVIEW',
    value: value != null && value.isNotEmpty
        ? value
        : cadenceValue != null && cadenceValue.isNotEmpty
        ? cadenceValue
        : learnerJourneyReviewQueueValueTextV1(reviewRequired: reviewRequired),
    cta: reviewRequired ? 'REVIEW MISSED' : 'REVIEW',
  );
}

String mapNextPackCtaLabelV1({
  required bool reviewRequired,
  required String nextPackId,
  required String activePackId,
  required int nextHandIndex,
}) {
  return resolveProgressionRouteStoryForPackV1(
    nextPackId: nextPackId,
    reviewRequired: reviewRequired,
    activePackId: activePackId,
    nextHandIndex: nextHandIndex,
    rhythmReason: '',
  ).ctaLabel;
}

String mapNextPackCtaSemanticsLabelV1({
  required bool reviewRequired,
  required String nextPackId,
  required String activePackId,
  required int nextHandIndex,
}) {
  return resolveProgressionRouteStoryForPackV1(
    nextPackId: nextPackId,
    reviewRequired: reviewRequired,
    activePackId: activePackId,
    nextHandIndex: nextHandIndex,
    rhythmReason: '',
  ).semanticsLabel;
}

_MapRhythmDecisionV1 _computeMapRhythmDecisionV1({
  required String nextPackId,
  required bool hasReviewQueueForNextPack,
  required int completedSpinePackCount,
}) {
  final hasNextPack = nextPackId.trim().isNotEmpty;
  final isAct0ToSpineBoundary =
      nextPackId.trim() == ProgressService.spineInitialPackIdV1;
  final isCheckpointDueByRhythm =
      hasNextPack &&
      !isAct0ToSpineBoundary &&
      completedSpinePackCount > 0 &&
      completedSpinePackCount % _mapRhythmRuleEveryNPacksV1 == 0;
  final isReviewDueForNextPack =
      hasNextPack && hasReviewQueueForNextPack && isCheckpointDueByRhythm;
  final uiDecision = decideNextActionV1(
    completedPacksCount: completedSpinePackCount,
    hasReviewQueueForNextPack: hasReviewQueueForNextPack,
    rhythmEveryN: _mapRhythmRuleEveryNPacksV1,
  );
  return _MapRhythmDecisionV1(
    isReviewDueForNextPack: isReviewDueForNextPack,
    isCheckpointDueByRhythm: isCheckpointDueByRhythm,
    effectiveNextAction: uiDecision.kind,
    reason: uiDecision.reason,
  );
}

class UiV2ProgressMapScreenV2 extends StatefulWidget {
  const UiV2ProgressMapScreenV2({
    super.key,
    this.autoOpenReviewQueueForNextPackV1 = false,
    this.debugAutoOpenSurfaceV1,
  });

  final bool autoOpenReviewQueueForNextPackV1;
  final MapDebugAutoOpenSurfaceV1? debugAutoOpenSurfaceV1;

  @override
  State createState() => _UiV2ProgressMapScreenV2State();
}

Route<void> progressMapRouteV1({
  bool autoOpenReviewQueueForNextPackV1 = false,
  MapDebugAutoOpenSurfaceV1? debugAutoOpenSurfaceV1,
}) {
  // Archived runtime surface: keep file as reference, but route callers
  // to canonical Act0 root unless explicitly opened from dev tooling.
  return MaterialPageRoute<void>(
    builder: (_) => Act0ShellPreviewScreenV1(showPlacementOnStart: false),
  );
}

class _UiV2ProgressMapScreenV2State extends State<UiV2ProgressMapScreenV2>
    with SingleTickerProviderStateMixin {
  static const List<String> _campaignWorldTitlesEnV1 = <String>[
    'Foundations',
    'Position Basics',
    'Pot Odds Intro',
    'Bet Sizing Basics',
    'Board Texture',
    'Turn Pressure',
    'River Decisions',
    'Exploit Adjustments',
    'High Leverage Spots',
    'Mastery Integration',
  ];

  static const List<String> _campaignWorldThemesEnV1 = <String>[
    'Table literacy and turn order',
    'In-position vs out-of-position',
    'Simple pot-odds discipline',
    'Baseline bet and raise sizing',
    'Dry vs wet board adaptation',
    'Turn pressure and defense',
    'Value and bluff boundaries',
    'Population exploit adjustments',
    'High-pressure pot branches',
    'Full-loop mastery integration',
  ];
  static const List<String> _levelFocusLinesV1 = <String>[
    'Focus: Table basics and action order',
    'Focus: Hand selection and simple decisions',
    'Focus: Position changes power',
    'Focus: Decision structure by street',
    'Focus: Bets have purpose',
    'Focus: Board texture changes strength',
    'Focus: Ranges, not single hands',
    'Focus: Stack depth changes strategy',
    'Focus: Tournament basics and ICM',
    'Focus: Exploit and adjustments',
  ];
  static const List<String> _levelTitlesV1 = <String>[
    'Table Basics',
    'Foundations',
    'Position Basics',
    'Pot Odds Intro',
    'Bet Sizing Basics',
    'Board Texture',
    'Turn Pressure',
    'River Decisions',
    'Exploit Adjustments',
    'Mastery Integration',
  ];
  static const List<String> _level0PackIdsV1 = <String>[
    'world1_act0_table_literacy',
    'world1_act0_action_literacy',
    'world1_act0_street_flow',
  ];

  late Future<List<Map<String, dynamic>>> _nodesFuture;
  late final AnimationController _mapMotionController;
  late final Animation<double> _currentNodePulseScale;
  final ScrollController _mapScrollController = ScrollController();
  final GlobalKey _mapOverlayHostKeyV1 = GlobalKey();
  final Map<String, GlobalKey> _worldNodeKeysV1 = <String, GlobalKey>{};
  int _xp = 0;
  int _streak = 0;
  int _dailyHandIndex = 0;
  int _starsCount = 0;
  int _chipsBalanceV1 = 0;
  bool _focusCurrentNodeOnNextBuild = false;
  bool _todayChipCompletedInSession = false;
  String _campaignNextPackId = ProgressService.spineInitialPackIdV1;
  String _campaignActivePackId = '';
  int _campaignNextHandIndexV1 = 0;
  int _campaignCompletedHands = 0;
  int _campaignTotalHands = 0;
  String _campaignRankLabel = 'Tadpole';
  String _campaignRankHint = '';
  bool _campaignDetailsExpanded = false;
  int? _inlineSelectedWorld;
  String? _inlineSelectedPackId;
  _MapNodePreviewStateV1? _mapNodePreviewV1;
  bool _hasReviewQueueForNextPack = false;
  bool _checkpointPendingV1 = false;
  bool _autoOpenedReviewQueueForNextPackV1 = false;
  bool _debugAutoOpenedSurfaceV1 = false;
  int _completedSpinePackCountV1 = 0;
  Set<int> _effectiveCompletedWorldsV1 = const <int>{};
  bool _levelCompletionSnapshotBootstrappedV1 = false;
  Set<int> _completedLevelsSnapshotV1 = <int>{};
  bool _levelTransitionSheetOpenV1 = false;
  WorldMasteryLevelV1? _currentWorldMasteryV1;
  List<String> _currentWorldSkillTagsV1 = const <String>[];
  _MapRhythmDecisionV1 _mapRhythmDecisionV1 = const _MapRhythmDecisionV1(
    isReviewDueForNextPack: false,
    isCheckpointDueByRhythm: false,
    effectiveNextAction: MapNextActionKindV1.start_next_pack,
    reason: 'Continue',
  );
  LearningStatsSnapshotV1 _learningStats = const LearningStatsSnapshotV1(
    totalDecisions: 0,
    correctDecisions: 0,
    rangeErrors: 0,
    sizingErrors: 0,
    timingErrors: 0,
    logicErrors: 0,
    updatedAtMs: null,
  );

  ButtonStyle _campaignNodeStyle(bool enabled) {
    return OutlinedButton.styleFrom(
      side: BorderSide(
        color: enabled
            ? SharkyTokensV1.slate500.withOpacity(0.7)
            : SharkyTokensV1.slate600.withOpacity(0.55),
      ),
      backgroundColor: enabled
          ? SharkyTokensV1.surfaceCard.withOpacity(0.42)
          : SharkyTokensV1.surfaceCard.withOpacity(0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  @override
  void initState() {
    super.initState();
    _mapMotionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _currentNodePulseScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _mapMotionController, curve: Curves.easeInOut),
    );
    _startMapMicroMotion();
    _nodesFuture = _loadData();
    unawaited(_refreshCampaignNextPackId());
    if (widget.autoOpenReviewQueueForNextPackV1) {
      unawaited(_autoOpenReviewQueueForNextPackAfterBootstrapV1());
    }
    if (kDebugMode && widget.debugAutoOpenSurfaceV1 != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_debugAutoOpenSurfaceAfterBootstrapV1());
      });
    }
    ProgressService.world1ProgressRevision.addListener(
      _onWorld1ProgressRevision,
    );
  }

  @override
  void dispose() {
    _mapScrollController.dispose();
    _mapMotionController.dispose();
    ProgressService.world1ProgressRevision.removeListener(
      _onWorld1ProgressRevision,
    );
    super.dispose();
  }

  void _onWorld1ProgressRevision() {
    _refresh(focusCurrentNode: true);
  }

  Future<void> _debugAutoOpenSurfaceAfterBootstrapV1() async {
    if (!kDebugMode ||
        !mounted ||
        _debugAutoOpenedSurfaceV1 ||
        widget.debugAutoOpenSurfaceV1 == null) {
      return;
    }
    _debugAutoOpenedSurfaceV1 = true;
    switch (widget.debugAutoOpenSurfaceV1!) {
      case MapDebugAutoOpenSurfaceV1.levelsSheet:
        await _showLevelsSheetV1();
        return;
      case MapDebugAutoOpenSurfaceV1.levelCompleteSheet:
        await _showLevelCompleteSheetV1(
          levelIndex: 1,
          nextPackId:
              computeNextLevelFirstPackIdV1(1) ??
              ProgressService.spineInitialPackIdV1,
        );
        return;
    }
  }

  void _startMapMicroMotion() {
    _mapMotionController
      ..reset()
      ..forward();
  }

  Future<List<Map<String, dynamic>>> _loadData() async {
    final rawModules = await DirectLoader.loadAvailableModules();
    final orderedModules = orderWorld1Modules(rawModules);
    final enriched = <Map<String, dynamic>>[];
    for (var i = 0; i < orderedModules.length; i++) {
      final module = orderedModules[i];
      final moduleId = resolveProgressMapModuleId(module, fallbackIndex: i);
      final completed = await ProgressService.isModuleCompleted(moduleId);
      final node = Map<String, dynamic>.from(module);
      node['id'] = moduleId;
      node['isCompleted'] = completed;
      enriched.add(node);
    }

    final deterministicNodes = applyLinearUnlockByPreviousCompletion(enriched);

    await ProgressService.checkInStreak();
    final xp = await ProgressService.getXp();
    await ReturnLoopServiceV1.instance.updateOnAppOpenOrProgressMapShown();
    final streak = ReturnLoopServiceV1.instance.currentStreak;
    final dailyHand = ReturnLoopServiceV1.instance.todayDailyHandIndex;
    final persistedDailyCompleted =
        await ProgressService.isWorld1DailyCompletedToday();
    final completedCount = deterministicNodes
        .where((node) => node['isCompleted'] as bool? ?? false)
        .length;
    final campaignNextPackId = await _resolveEarliestIncompleteWorld1PackIdV1();
    final campaignActivePackId = await ProgressService.getSpineActivePackIdV1();
    final campaignNextHandIndexV1 =
        await ProgressService.getSpineNextHandIndexV1();
    final campaignCompletedHands =
        await ProgressService.completedHandsInCampaignV1();
    final campaignTotalHands = await ProgressService.totalHandsInCampaignV1();
    final campaignRankLabel = await ProgressService.campaignRankLabelV1();
    final campaignRankHint =
        await ProgressService.campaignNextRankUnlockHintV1();
    final chipsLedger = await ProgressService.getChipsLedgerSnapshotV1();
    final learningStats = await LearningStatsV1Service.instance.load();
    final completedSpinePackIds =
        await ProgressService.getSpineCompletedPackIdsV1();
    final completedSpinePackCountV1 = ProgressService.campaignPackIdsV1
        .where(completedSpinePackIds.contains)
        .length;
    final effectiveCompletedWorldsV1 = await _loadEffectiveCompletedWorldsV1(
      completedPackIds: completedSpinePackIds,
    );
    final currentWorldMasteryV1 = campaignNextPackId.trim().isEmpty
        ? null
        : await ProgressService.getWorldMasteryForPackV1(campaignNextPackId);
    final currentWorldSkillTagsV1 = campaignNextPackId.trim().isEmpty
        ? const <String>[]
        : await ProgressService.getSkillTagsForPackV1(campaignNextPackId);
    final hasReviewQueueForNextPack = campaignNextPackId.trim().isEmpty
        ? false
        : await ProgressService.hasReviewQueueForPackV1(campaignNextPackId);
    final checkpointStateV1 =
        await ProgressService.getCheckpointProgressStateV1();
    final mapRhythmDecisionV1 = _computeMapRhythmDecisionV1(
      nextPackId: campaignNextPackId,
      hasReviewQueueForNextPack: hasReviewQueueForNextPack,
      completedSpinePackCount: completedSpinePackCountV1,
    );
    if (mounted) {
      final sessionDailyCompleted =
          ProgressService.world1DailyCompletionInSession.value;
      setState(() {
        if (_dailyHandIndex != dailyHand) {
          _todayChipCompletedInSession = false;
          if (ProgressService.world1DailyCompletionInSession.value) {
            ProgressService.world1DailyCompletionInSession.value = false;
          }
        }
        _xp = xp;
        _streak = streak;
        _dailyHandIndex = dailyHand;
        _starsCount = completedCount;
        _campaignNextPackId = campaignNextPackId;
        _campaignActivePackId = campaignActivePackId ?? '';
        _campaignNextHandIndexV1 = campaignNextHandIndexV1;
        _campaignCompletedHands = campaignCompletedHands;
        _campaignTotalHands = campaignTotalHands;
        _campaignRankLabel = campaignRankLabel;
        _campaignRankHint = campaignRankHint;
        _chipsBalanceV1 = chipsLedger.balance;
        _learningStats = learningStats;
        _hasReviewQueueForNextPack = hasReviewQueueForNextPack;
        _checkpointPendingV1 = checkpointStateV1.checkpointPending;
        _completedSpinePackCountV1 = completedSpinePackCountV1;
        _effectiveCompletedWorldsV1 = effectiveCompletedWorldsV1;
        _currentWorldMasteryV1 = currentWorldMasteryV1;
        _currentWorldSkillTagsV1 = currentWorldSkillTagsV1;
        _mapRhythmDecisionV1 = mapRhythmDecisionV1;
        _todayChipCompletedInSession =
            _todayChipCompletedInSession ||
            sessionDailyCompleted ||
            persistedDailyCompleted;
      });
    }

    return deterministicNodes;
  }

  void _refresh({bool focusCurrentNode = false}) {
    if (!mounted) return;
    if (focusCurrentNode) {
      _focusCurrentNodeOnNextBuild = true;
    }
    _startMapMicroMotion();
    setState(() {
      _nodesFuture = _loadData();
    });
    unawaited(_refreshCampaignNextPackId());
  }

  Future<String> _resolveEarliestIncompleteWorld1PackIdV1() async {
    final completedPackIds = await ProgressService.getSpineCompletedPackIdsV1();
    final fallback = await ProgressService.getNextSpinePackToRunV1();
    return resolveWorld1CanonicalEntryPackIdV1(
      completedPackIds: completedPackIds,
      fallbackPackId: fallback,
    );
  }

  Future<void> _refreshCampaignNextPackId() async {
    final nextPackId = await _resolveEarliestIncompleteWorld1PackIdV1();
    final completedSpinePackIds =
        await ProgressService.getSpineCompletedPackIdsV1();
    final completedSpinePackCountV1 = ProgressService.campaignPackIdsV1
        .where(completedSpinePackIds.contains)
        .length;
    final effectiveCompletedWorldsV1 = await _loadEffectiveCompletedWorldsV1(
      completedPackIds: completedSpinePackIds,
    );
    final currentWorldMasteryV1 = nextPackId.trim().isEmpty
        ? null
        : await ProgressService.getWorldMasteryForPackV1(nextPackId);
    final currentWorldSkillTagsV1 = nextPackId.trim().isEmpty
        ? const <String>[]
        : await ProgressService.getSkillTagsForPackV1(nextPackId);
    final chipsLedger = await ProgressService.getChipsLedgerSnapshotV1();
    final hasReviewQueue = nextPackId.trim().isEmpty
        ? false
        : await ProgressService.hasReviewQueueForPackV1(nextPackId);
    final checkpointStateV1 =
        await ProgressService.getCheckpointProgressStateV1();
    final mapRhythmDecisionV1 = _computeMapRhythmDecisionV1(
      nextPackId: nextPackId,
      hasReviewQueueForNextPack: hasReviewQueue,
      completedSpinePackCount: completedSpinePackCountV1,
    );
    if (!mounted) return;
    setState(() {
      _campaignNextPackId = nextPackId;
      _chipsBalanceV1 = chipsLedger.balance;
      _hasReviewQueueForNextPack = hasReviewQueue;
      _checkpointPendingV1 = checkpointStateV1.checkpointPending;
      _completedSpinePackCountV1 = completedSpinePackCountV1;
      _effectiveCompletedWorldsV1 = effectiveCompletedWorldsV1;
      _currentWorldMasteryV1 = currentWorldMasteryV1;
      _currentWorldSkillTagsV1 = currentWorldSkillTagsV1;
      _mapRhythmDecisionV1 = mapRhythmDecisionV1;
    });
    if (widget.autoOpenReviewQueueForNextPackV1 &&
        !_autoOpenedReviewQueueForNextPackV1 &&
        hasReviewQueue) {
      _autoOpenedReviewQueueForNextPackV1 = true;
      unawaited(_openReviewQueueForNextPackV1());
    }
    unawaited(
      _handleLevelCompletionTransitionV1(
        nextPackId: nextPackId,
        completedPackIds: completedSpinePackIds,
      ),
    );
  }

  Future<void> _autoOpenReviewQueueForNextPackAfterBootstrapV1() async {
    await _refreshCampaignNextPackId();
    for (var i = 0; i < 120; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted || _autoOpenedReviewQueueForNextPackV1) return;
      if (_campaignNextPackId.trim().isEmpty || !_hasReviewQueueForNextPack) {
        continue;
      }
      _autoOpenedReviewQueueForNextPackV1 = true;
      await _openReviewQueueForNextPackV1();
      return;
    }
  }

  Future<Set<int>> _loadEffectiveCompletedWorldsV1({
    Set<String>? completedPackIds,
  }) async {
    final resolvedCompletedPackIds =
        completedPackIds ?? await ProgressService.getSpineCompletedPackIdsV1();
    final completedWorlds = <int>{};
    for (var world = 1; world <= 10; world++) {
      final canonicalPlayableSessionIds = canonical_truth
          .canonicalTruthPlayableSessionEntriesForWorldV1(world)
          .map((entry) => entry.sessionId);
      final done = await ProgressService.isEffectiveCampaignWorldDoneV1(
        world: world,
        completedPackIds: resolvedCompletedPackIds,
        canonicalPlayableSessionIds: canonicalPlayableSessionIds,
      );
      if (done) {
        completedWorlds.add(world);
      }
    }
    return completedWorlds;
  }

  Future<void> _openFoundationsCheck(
    Map<String, dynamic> moduleData, {
    String mode = kWorld1RunnerModeFoundationsCheck,
    int? checkpointId,
  }) async {
    final moduleId = (moduleData['id'] ?? '').toString();
    if (moduleId.isEmpty || !hasWorld1MicroTaskPack(moduleId) || !mounted) {
      return;
    }
    unawaited(() async {
      try {
        final chipsSpend = await ProgressService.spendChipsForSessionStartV1();
        await Telemetry.logEvent(TelemetryEvents.chipsSpentV1, <
          String,
          dynamic
        >{
          'amount': chipsSpend.appliedAmount,
          'reason': checkpointId == null ? 'session_start' : 'checkpoint_start',
          'balance_after': chipsSpend.after.balance,
          'bankrupt': chipsSpend.insufficientFunds,
        });
      } catch (_) {
        // Best-effort accounting/telemetry must not block deterministic launch.
      }
    }());
    final title = (moduleData['title'] ?? moduleData['name'] ?? moduleId)
        .toString();
    final result = await pushWorld1FoundationsRunnerV1<bool>(
      context,
      moduleId: moduleId,
      moduleTitle: title,
      mode: mode,
      checkpointId: checkpointId,
    );
    if (mounted && result == true) {
      setState(() {
        _todayChipCompletedInSession = true;
      });
    }
    _refresh(focusCurrentNode: true);
  }

  String _dailyRunPrimaryLabel() => 'Daily Run (30s)';

  String _dailyRunSubtitleLabel() => '+15 XP · Streak $_streak';

  String _todayChipPrimaryLabel() {
    return 'Today +15 XP · Streak $_streak';
  }

  String _todayChipStateLabel() {
    return _todayChipCompletedInSession ? 'Completed Today' : 'Daily Ready';
  }

  Future<void> _openCheckpointSession({
    required int checkpointId,
    required String anchorModuleId,
  }) async {
    if (!mounted) return;
    final anchorData = <String, dynamic>{
      'id': anchorModuleId,
      'title': 'Checkpoint $checkpointId',
      'name': 'Checkpoint $checkpointId',
    };
    await _openFoundationsCheck(
      anchorData,
      mode: kWorld1RunnerModeCheckpoint,
      checkpointId: checkpointId,
    );
  }

  Future<void> _startFirstModuleFromEmptyState(BuildContext context) async {
    final modules = orderWorld1Modules(
      await DirectLoader.loadAvailableModules(),
    );
    if (modules.isEmpty || !context.mounted) return;
    final first = modules.firstWhere(
      (module) => module['isAvailable'] as bool? ?? true,
      orElse: () => modules.first,
    );
    final moduleId =
        (first['id'] ?? first['name'] ?? first['title'] ?? 'module_0')
            .toString();
    final moduleTitle = (first['title'] ?? first['name'] ?? moduleId)
        .toString();
    await navigateToLearningModuleV1(
      context,
      moduleId,
      moduleTitle: moduleTitle,
    );
  }

  Widget _buildMapRenderFallback({
    required String title,
    required String subtitle,
  }) {
    return Center(
      key: const Key('map_render_fallback_v1'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 42,
              color: SharkyTokensV1.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color: SharkyTokensV1.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: SharkyTokensV1.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 170,
              child: OutlinedButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLoadingSurface() {
    return Center(
      key: const Key('map_loading_v1'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Loading map...',
              style: AppTypography.body.copyWith(
                color: SharkyTokensV1.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapEmptyStateSurfaceV1(BuildContext context) {
    return Container(
      key: const Key('map_empty_state_surface_v1'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.82),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusLg),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.58)),
        boxShadow: SharkyTokensV1.elevation2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCampaignWorldMapRow(),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: SharkyTokensV1.brandPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
            ),
            child: Icon(
              Icons.alt_route_rounded,
              color: SharkyTokensV1.brandPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Learning Path',
            style: AppTypography.h1.copyWith(color: SharkyTokensV1.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No training packs found',
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start with the first module to unlock the release path from theory into practice.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              key: const Key('map_empty_state_start_cta_v1'),
              onPressed: () {
                UiSoundV1.fire(UiSoundEventV1.tap);
                _startFirstModuleFromEmptyState(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: SharkyTokensV1.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                ),
              ),
              child: Text(
                'START THEORY',
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardMetric(
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Key? key,
  }) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.label.copyWith(
            color: SharkyTokensV1.amber500,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Icon(icon, color: SharkyTokensV1.amber500, size: 18),
      ],
    );
    if (onTap == null) return child;
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: child,
      ),
    );
  }

  Widget _streakIndicator() {
    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: SharkyTokensV1.amber500),
        const SizedBox(width: 4),
        Text(
          '$_streak',
          style: AppTypography.label.copyWith(
            color: SharkyTokensV1.amber500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWideTopBar(AppLocalizations l10n) {
    return _buildTopBarSurfaceV1(
      child: Row(
        children: [
          _streakIndicator(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Learning Path',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h3.copyWith(
                color: SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _rewardMetric(
            '$_xp',
            Icons.monetization_on,
            onTap: _showLevelsSheetV1,
            key: const Key('map_header_metric_xp_v1'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _rewardMetric(
            '$_starsCount',
            Icons.star,
            onTap: _showLevelsSheetV1,
            key: const Key('map_header_metric_stars_v1'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _infoChip(
            l10n.streakChipLabel(_streak),
            onTap: _showLevelsSheetV1,
            key: const Key('map_header_streak_chip_v1'),
          ),
          const SizedBox(width: AppSpacing.xs),
          _infoChip(
            l10n.dailyHandLabel(_dailyHandIndex + 1),
            onTap: _showLevelsSheetV1,
            key: const Key('map_header_daily_chip_v1'),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowTopBar(AppLocalizations l10n, {required bool compact}) {
    final worldProgressLine =
        'World ${_worldForPackId(_campaignNextPackId.trim()) ?? 10}/10 • $_campaignCompletedHands/$_campaignTotalHands';
    final compactMeta = compact
        ? 'XP $_xp · Stars $_starsCount'
        : 'XP $_xp · Stars $_starsCount · ${l10n.dailyHandLabel(_dailyHandIndex + 1)}';
    return _buildTopBarSurfaceV1(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 120) {
                return Text(
                  'Path',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: SharkyTokensV1.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _streakIndicator(),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Learning Path',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          worldProgressLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(
                            color: SharkyTokensV1.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: _infoChip(
                      compactMeta,
                      onTap: _showLevelsSheetV1,
                      key: const Key('map_header_meta_v1'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarSurfaceV1({required Widget child}) {
    return Container(
      key: const Key('map_top_bar_surface_v1'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceElevated.withOpacity(0.72),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.42)),
      ),
      child: child,
    );
  }

  Widget _buildLevelsHeaderActionV1() {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return TextButton.icon(
      key: const Key('map_levels_button_v1'),
      onPressed: _showLevelsSheetV1,
      icon: const Icon(Icons.layers_outlined, size: 16),
      label: const Text('Levels'),
      style: TextButton.styleFrom(
        foregroundColor: SharkyTokensV1.textSecondary,
        textStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
        minimumSize: const Size(44, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  Widget _buildDevHubHeaderActionV1() {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return TextButton.icon(
      key: const Key('map_dev_hub_button_v1'),
      onPressed: () {
        Navigator.of(context).push(canonicalDevAccessHubRouteV1());
      },
      icon: const Icon(Icons.hub_outlined, size: 16),
      label: const Text('Dev Hub'),
      style: TextButton.styleFrom(
        foregroundColor: SharkyTokensV1.textSecondary,
        textStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
        minimumSize: const Size(44, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  Widget _buildProfileHeaderActionV1() {
    return IconButton(
      key: const Key('map_profile_button_v1'),
      tooltip: 'Profile',
      onPressed: _openPlayerProfileV1,
      icon: const Icon(Icons.person_outline),
    );
  }

  Future<void> _openPlayerProfileV1() async {
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const PlayerProfileScreenV1()),
    );
  }

  Widget _buildLearningStatsDetailsV1() {
    final hasDecisions = _learningStats.totalDecisions > 0;
    final topBuckets = _learningStats.topErrorBuckets(limit: 1);
    final topBucketLabel = topBuckets.isEmpty ? 'None' : topBuckets.first.key;
    final accuracyPercent = _learningStats.totalDecisions <= 0
        ? 0
        : ((_learningStats.correctDecisions * 100) /
                  _learningStats.totalDecisions)
              .round();
    final accuracyValue = hasDecisions ? '$accuracyPercent%' : 'N/A';
    final leakValue = hasDecisions ? topBucketLabel : 'None';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Accuracy: $accuracyValue',
            key: const Key('map_learning_details_accuracy_v1'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            mapLearningTopFocusLabelV1(leakValue),
            key: const Key('map_learning_details_top_leak_v1'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReviewQueueForNextPackV1() async {
    final packId = _campaignNextPackId.trim();
    await _openReviewQueueForPackV1(packId);
  }

  Future<CanonicalLandingDecisionV1> _resolveCanonicalMapLandingDecisionV1({
    required String canonicalEntryPackId,
    required CanonicalLandingSourceV1 source,
    bool allowReviewQueue = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedPackId = canonicalEntryPackId.trim();
    final checkpointStateV1 =
        await ProgressService.getCheckpointProgressStateV1();
    final activePackId = await ProgressService.getSpineActivePackIdV1();
    final nextHandIndex = await ProgressService.getSpineNextHandIndexV1();
    final hasReviewQueueForCanonicalEntryPack =
        allowReviewQueue && normalizedPackId.isNotEmpty
        ? await ProgressService.hasReviewQueueForPackV1(normalizedPackId)
        : false;
    return resolveCanonicalLandingDecisionV1(
      CanonicalLandingDecisionInputsV1(
        onboardingCompleted: prefs.getBool('onboardingCompleted') ?? false,
        intakeCompleted: await ProgressService.isIntakeCompleted(),
        campaignComplete: await ProgressService.isCampaignCompleteV1(),
        checkpointPending: checkpointStateV1.checkpointPending,
        nextPackId: normalizedPackId,
        canonicalEntryPackId: normalizedPackId,
        hasReviewQueueForCanonicalEntryPack:
            hasReviewQueueForCanonicalEntryPack,
        activePackId: activePackId ?? '',
        currentPackId: _campaignActivePackId,
        nextHandIndex: nextHandIndex,
        source: source,
      ),
    );
  }

  Future<void> _openReviewQueueForPackV1(String packId) async {
    final landingDecision = await _resolveCanonicalMapLandingDecisionV1(
      canonicalEntryPackId: packId,
      source: CanonicalLandingSourceV1.mapReview,
      allowReviewQueue: true,
    );
    if (landingDecision.surfaceKind !=
            CanonicalLandingSurfaceKindV1.campaignReviewQueue ||
        landingDecision.entryId.trim().isEmpty ||
        !mounted) {
      return;
    }
    final chipsSpend = await ProgressService.spendChipsForSessionStartV1();
    await Telemetry.logEvent(TelemetryEvents.chipsSpentV1, <String, dynamic>{
      'amount': chipsSpend.appliedAmount,
      'reason': 'review_start',
      'balance_after': chipsSpend.after.balance,
      'bankrupt': chipsSpend.insufficientFunds,
    });
    await pushWorld1FoundationsRunnerV1<bool>(
      context,
      moduleId: landingDecision.entryId,
      moduleTitle: 'Review Missed',
      mode: landingDecision.runnerMode ?? kWorld1RunnerModeReviewQueue,
    );
    _refresh(focusCurrentNode: true);
  }

  Future<void> _handleCampaignStartNowActionV1() async {
    if (_mapRhythmDecisionV1.shouldGateStartNowToReview) {
      await _openReviewQueueForNextPackV1();
      return;
    }
    if (_mapRhythmDecisionV1.isCheckpointDueByRhythm) {
      await _openRhythmCheckpointPackV1();
      return;
    }
    await _openNextCampaignPackFromSsoT();
  }

  String _rhythmCheckpointPackIdV1() =>
      selectSeason1CheckpointPackIdV1(_completedSpinePackCountV1);

  Future<void> _openRhythmCheckpointPackV1() async {
    final checkpointPackId = _rhythmCheckpointPackIdV1();
    final moduleData = <String, dynamic>{
      'id': checkpointPackId,
      'title': 'Checkpoint',
      'name': 'Checkpoint',
    };
    await _openFoundationsCheck(moduleData);
  }

  Future<void> _openGlobalCheckpointPackV1() async {
    final moduleData = <String, dynamic>{
      'id': ProgressService.checkpointPackIdV1,
      'title': 'Checkpoint',
      'name': 'Checkpoint',
    };
    await _openFoundationsCheck(moduleData, mode: kWorld1RunnerModeCheckpoint);
  }

  Future<void> _openOptionalAppliedPackV1({
    required String packId,
    required String title,
  }) async {
    final moduleData = <String, dynamic>{
      'id': packId,
      'title': title,
      'name': title,
    };
    await _openFoundationsCheck(
      moduleData,
      mode: kWorld1RunnerModeDemoHandLoopV1,
    );
  }

  Widget _buildReviewQueueHintStripV1() {
    final reviewRequired = _mapRhythmDecisionV1.shouldGateStartNowToReview;
    final labels = mapReviewQueueStripLabelsV1(
      reviewRequired: reviewRequired,
      normalizedNextPackId: _campaignNextPackId,
      valueOverride: reviewRequired
          ? mapCheckpointPendingReasonTextV1(
              normalizedNextPackId: _campaignNextPackId,
              activePackId: _campaignActivePackId,
              nextHandIndex: _campaignNextHandIndexV1,
              mapRhythmReason: _mapRhythmDecisionV1.reason,
            )
          : null,
    );
    return Container(
      key: const Key('map_review_queue_strip'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(2, 0, 2, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SharkyTokensV1.slate500.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Text(
            labels.title,
            key: const Key('map_review_queue_title'),
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              labels.value,
              key: const Key('map_review_queue_value'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 30,
            child: OutlinedButton(
              key: const Key('map_review_queue_cta'),
              onPressed: _openReviewQueueForNextPackV1,
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                side: BorderSide(
                  color: SharkyTokensV1.slate500.withOpacity(0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                labels.cta,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointPendingStripV1() {
    final checkpointReason = mapCheckpointPendingReasonTextV1(
      normalizedNextPackId: _campaignNextPackId,
      activePackId: _campaignActivePackId,
      nextHandIndex: _campaignNextHandIndexV1,
      mapRhythmReason: _mapRhythmDecisionV1.reason,
    );
    return Container(
      key: const Key('map_checkpoint_pending_strip'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(2, 0, 2, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SharkyTokensV1.slate500.withOpacity(0.28),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              checkpointReason,
              key: const Key('map_checkpoint_pending_text_v1'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            key: const Key('checkpoint_entry_cta_v1'),
            onPressed: _openReviewQueueForNextPackV1,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(44, 36),
            ),
            child: const Text('REVIEW'),
          ),
        ],
      ),
    );
  }

  Widget _buildPathRhythmNodesStripV1({
    required List<String> inlinePackIds,
    required String nextPackId,
  }) {
    final nodes = buildPathNodesV1(
      packIds: inlinePackIds,
      nextPackId: nextPackId,
      completedPacksCount: _completedSpinePackCountV1,
      hasReviewQueueForNextPack: _hasReviewQueueForNextPack,
      rhythmEveryN: _mapRhythmRuleEveryNPacksV1,
    );
    final specialNodes = nodes
        .where((node) => node.kind != PathNodeKindV1.pack)
        .toList(growable: false);
    if (specialNodes.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget buildNodeTile(PathNodeV1 node) {
      final isReview = node.kind == PathNodeKindV1.review;
      final isCheckpoint = node.kind == PathNodeKindV1.checkpoint;
      final isOptionalPack = node.kind == PathNodeKindV1.optionalPack;
      final key = isReview
          ? const Key('map_node_review_v1')
          : isCheckpoint
          ? const Key('map_node_checkpoint_v1')
          : Key('map_node_${node.packId ?? 'optional'}');
      final optionalTitle =
          (node.packId == 'world2_streets_demo_v1' ||
              node.packId == 'world3_streets_demo_v1')
          ? 'STREETS CHALLENGE'
          : 'STREETS DRILL';
      final label = isReview
          ? 'REVIEW'
          : isCheckpoint
          ? 'CHECKPOINT'
          : optionalTitle;
      final value = (node.reason ?? '').trim().isEmpty
          ? (isReview
                ? 'Missed spots ready'
                : isCheckpoint
                ? 'Checkpoint ready'
                : 'Optional practice')
          : node.reason!;
      final onPressed = isReview
          ? _openReviewQueueForNextPackV1
          : isCheckpoint
          ? _openRhythmCheckpointPackV1
          : () => _openOptionalAppliedPackV1(
              packId: node.packId ?? 'world1_streets_demo_v1',
              title:
                  (node.packId == 'world2_streets_demo_v1' ||
                      node.packId == 'world3_streets_demo_v1')
                  ? 'Streets Challenge'
                  : 'Streets Drill',
            );
      final tilePadding = isOptionalPack
          ? const EdgeInsets.symmetric(horizontal: 9, vertical: 7)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
      return Container(
        key: key,
        padding: tilePadding,
        decoration: BoxDecoration(
          color: SharkyTokensV1.surfaceCard.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                (isReview ? SharkyTokensV1.brandGlow : SharkyTokensV1.slate500)
                    .withOpacity(0.28),
            width: 0.9,
          ),
        ),
        child: isOptionalPack
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.3,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 5,
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          minimumSize: const Size(44, 28),
                          side: BorderSide(
                            color: SharkyTokensV1.slate500.withOpacity(0.24),
                          ),
                          backgroundColor: SharkyTokensV1.surfaceCard
                              .withOpacity(0.34),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Text(
                          'OPEN',
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                      letterSpacing: 0.35,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        minimumSize: const Size(44, 28),
                        side: BorderSide(
                          color: SharkyTokensV1.slate500.withOpacity(0.24),
                        ),
                        backgroundColor: SharkyTokensV1.surfaceCard.withOpacity(
                          0.34,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        'OPEN',
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [for (final node in specialNodes) buildNodeTile(node)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNarrowTopBar = MediaQuery.sizeOf(context).width < 980;
    final isCompactTopBar = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: SharkyTokensV1.surfaceApp,
      appBar: AppBar(
        backgroundColor: SharkyTokensV1.surfaceCard,
        elevation: 2,
        toolbarHeight: isNarrowTopBar ? 60 : kToolbarHeight,
        title: l10n == null
            ? Text(
                'Learning Path',
                style: AppTypography.h3.copyWith(
                  color: SharkyTokensV1.textPrimary,
                ),
              )
            : (isNarrowTopBar
                  ? _buildNarrowTopBar(l10n, compact: isCompactTopBar)
                  : _buildWideTopBar(l10n)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _buildDevHubHeaderActionV1(),
          ),
          _buildProfileHeaderActionV1(),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _buildLevelsHeaderActionV1(),
          ),
        ],
      ),
      body: Container(
        key: const Key('map_shell_v1'),
        color: SharkyTokensV1.surfaceApp,
        child: Column(
          children: [
            if (_checkpointPendingV1 && _hasReviewQueueForNextPack)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: _buildCheckpointPendingStripV1(),
              ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _nodesFuture,
                builder: (context, snap) {
                  if (l10n == null ||
                      snap.connectionState == ConnectionState.waiting ||
                      (!snap.hasData && !snap.hasError)) {
                    return _buildMapLoadingSurface();
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCampaignWorldMapRow(),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Map is unavailable right now',
                              style: AppTypography.h3.copyWith(
                                color: SharkyTokensV1.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Please try again',
                              style: AppTypography.body.copyWith(
                                color: SharkyTokensV1.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final nodes = snap.data ?? [];
                  if (nodes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: _buildMapEmptyStateSurfaceV1(context),
                      ),
                    );
                  }

                  try {
                    return LayoutBuilder(
                      builder: (context, viewport) {
                        return Stack(
                          key: _mapOverlayHostKeyV1,
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      if (notification.depth != 0) {
                                        return false;
                                      }
                                      if (_mapNodePreviewV1 == null)
                                        return false;
                                      if (notification
                                          is ScrollStartNotification) {
                                        _dismissMapNodePreviewOverlayV1();
                                      } else if (notification
                                              is ScrollUpdateNotification &&
                                          notification.dragDetails != null) {
                                        _dismissMapNodePreviewOverlayV1();
                                      } else if (notification
                                              is UserScrollNotification &&
                                          notification.direction !=
                                              ScrollDirection.idle) {
                                        _dismissMapNodePreviewOverlayV1();
                                      }
                                      return false;
                                    },
                                    child: SingleChildScrollView(
                                      controller: _mapScrollController,
                                      physics: const BouncingScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: viewport.maxHeight,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            6,
                                            0,
                                            6,
                                            0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: isCompactTopBar
                                                    ? 8
                                                    : 10,
                                              ),
                                              if (_hasReviewQueueForNextPack &&
                                                  !_checkpointPendingV1)
                                                _buildReviewQueueHintStripV1(),
                                              if (_showLegacyAct0CardsOnCampaignMapV1 &&
                                                  _shouldShowAct0SectionV1())
                                                _buildWorld1PathMap(nodes)
                                              else
                                                _buildHiddenLegacyWorld1NodeAnchorsV1(
                                                  nodes,
                                                ),
                                              _buildFutureBranchesSectionV1(),
                                              _buildCampaignWorldMapRow(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _buildPinnedStartNowCtaV1(),
                              ],
                            ),
                            Positioned.fill(
                              child: _buildMapNodePreviewOverlayV1(),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (error, stack) {
                    if (kDebugMode) {
                      debugPrint('Map fallback active: $error');
                      debugPrint(stack.toString());
                    }
                    return _buildMapRenderFallback(
                      title: 'Map is unavailable right now',
                      subtitle: 'Please retry. Your progress is safe.',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowAct0SectionV1() {
    final normalizedNextPackId = _campaignNextPackId.trim().toLowerCase();
    // Cohesion guard: Act0 square-card curriculum must not render on the
    // World 1+ circular campaign path surface.
    return normalizedNextPackId.startsWith('world1_act0_');
  }

  Widget _buildHiddenLegacyWorld1NodeAnchorsV1(
    List<Map<String, dynamic>> nodes,
  ) {
    final firstNode = nodes.isNotEmpty ? nodes.first : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          key: ValueKey<String>('world1_state_current'),
          height: 0,
        ),
        if (ProgressService.world1DailyCompletionInSession.value)
          const SizedBox(
            height: 1,
            width: 1,
            child: Text(
              'Completed Today',
              style: TextStyle(fontSize: 0.1, color: Colors.transparent),
            ),
          ),
        if (firstNode != null)
          Column(
            children: [
              SizedBox(
                height: 1,
                width: 1,
                child: GestureDetector(
                  key: ValueKey<String>('world1_node_${firstNode['id']}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    UiSoundV1.fire(UiSoundEventV1.tap);
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ModuleSummaryScreen(moduleData: firstNode),
                      ),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: const SizedBox.expand(),
                ),
              ),
              SizedBox(
                height: 1,
                width: 1,
                child: GestureDetector(
                  key: ValueKey<String>(
                    'world1_daily_run_cta_${firstNode['id']}',
                  ),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openFoundationsCheck(
                    firstNode,
                    mode: kWorld1RunnerModeDailyRun,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildWorld1PathMap(List<Map<String, dynamic>> nodes) {
    final visibleNodes = nodes
        .where((node) => node['isAvailable'] as bool? ?? true)
        .toList(growable: false);
    final effectiveNodes = visibleNodes.isEmpty ? nodes : visibleNodes;
    final currentIndex = effectiveNodes.indexWhere((node) {
      final available = node['isAvailable'] as bool? ?? true;
      final unlocked = node['isUnlocked'] as bool? ?? false;
      final completed = node['isCompleted'] as bool? ?? false;
      return available && unlocked && !completed;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isNarrow = width < 760;
        final isUltraWide = width >= 1400;
        final nodeWidth = isNarrow
            ? math.max(220.0, width - 32)
            : (isUltraWide ? 300.0 : 260.0);
        final nodeHeight = isNarrow ? 188.0 : 202.0;
        final step = isNarrow ? 178.0 : (isUltraWide ? 198.0 : 190.0);
        final sidePadding = isNarrow ? 10.0 : (isUltraWide ? 48.0 : 22.0);
        final anchors = <double>[0.5, 0.76, 0.28, 0.72, 0.3, 0.74, 0.5];
        final nodesCount = effectiveNodes.length.clamp(1, 7);
        final points = <Offset>[];
        final cards = <Widget>[];

        for (var i = 0; i < nodesCount; i++) {
          final centerX = sidePadding + (width - sidePadding * 2) * anchors[i];
          final left = (centerX - nodeWidth / 2).clamp(0.0, width - nodeWidth);
          final top = 22.0 + i * step;
          final node = effectiveNodes[i];
          final visualState = _resolveWorld1VisualState(
            node: node,
            isCurrent: i == currentIndex,
          );
          final isCurrent = i == currentIndex;
          final moduleId = (node['id'] ?? '').toString();
          final showFoundationsEntry = isCurrent;
          final foundationsEntryEnabled =
              showFoundationsEntry && hasWorld1MicroTaskPack(moduleId);
          final compactTodayCopy = width < 420;
          final showDailyRunCta = isCurrent && !compactTodayCopy;
          final dailyRunEnabled = showDailyRunCta && foundationsEntryEnabled;
          final todayChipPrimaryLabel = _todayChipPrimaryLabel();
          final todayChipStateLabel = _todayChipStateLabel();
          final dailyRunPrimaryLabel = _dailyRunPrimaryLabel();
          final dailyRunSubtitleLabel = _dailyRunSubtitleLabel();
          points.add(Offset(left + nodeWidth / 2, top + nodeHeight / 2));
          cards.add(
            Positioned(
              left: left,
              top: top,
              width: nodeWidth,
              height: nodeHeight,
              child: KeyedSubtree(
                key: _worldNodeKeyForIdV1(
                  moduleId.isEmpty ? '__node_$i' : moduleId,
                ),
                child: _MapNode(
                  nodeTapKey: ValueKey<String>('world1_node_${node['id']}'),
                  semanticsKey: ValueKey<String>(
                    'world1_node_semantics_${node['id']}',
                  ),
                  moduleData: node,
                  levelIndex: i + 1,
                  visualState: visualState,
                  onRefresh: _refresh,
                  pulseScale: i == currentIndex
                      ? _currentNodePulseScale.value
                      : 1.0,
                  showFoundationsEntry: showFoundationsEntry,
                  foundationsEntryEnabled: foundationsEntryEnabled,
                  showDailyRunCta: showDailyRunCta,
                  dailyRunEnabled: dailyRunEnabled,
                  onOpenFoundationsCheck: () => _openFoundationsCheck(node),
                  onOpenDailyRun: () => _openFoundationsCheck(
                    node,
                    mode: kWorld1RunnerModeDailyRun,
                  ),
                  dailyRunPrimaryLabel: dailyRunPrimaryLabel,
                  dailyRunSubtitleLabel: dailyRunSubtitleLabel,
                  todayChipPrimaryLabel: todayChipPrimaryLabel,
                  todayChipStateLabel: todayChipStateLabel,
                  compactTodayCopy: compactTodayCopy,
                ),
              ),
            ),
          );
        }

        final mapHeight = 44.0 + (nodesCount - 1) * step + nodeHeight + 18.0;
        if (_focusCurrentNodeOnNextBuild &&
            currentIndex >= 0 &&
            currentIndex < points.length) {
          _focusCurrentNodeOnNextBuild = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_mapScrollController.hasClients) return;
            final currentNodeId = (effectiveNodes[currentIndex]['id'] ?? '')
                .toString();
            final currentNodeContext =
                _worldNodeKeysV1[currentNodeId]?.currentContext;
            if (currentNodeContext != null) {
              unawaited(
                Scrollable.ensureVisible(
                  currentNodeContext,
                  alignment: 0.14,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                ),
              );
              return;
            }
            final viewport = _mapScrollController.position.viewportDimension;
            final target = (points[currentIndex].dy - (viewport * 0.42)).clamp(
              0.0,
              _mapScrollController.position.maxScrollExtent,
            );
            _mapScrollController.animateTo(
              target,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            );
          });
        }
        return SizedBox(
          width: width,
          height: mapHeight,
          child: AnimatedBuilder(
            animation: _mapMotionController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _World1PathPainter(
                          points: points,
                          states: [
                            for (var i = 0; i < nodesCount; i++)
                              _resolveWorld1VisualState(
                                node: nodes[i],
                                isCurrent: i == currentIndex,
                              ),
                          ],
                          motionPhase: _mapMotionController.value,
                        ),
                      ),
                    ),
                  ),
                  ...cards,
                  ..._buildCheckpointMarkers(
                    points: points,
                    nodes: nodes,
                    width: width,
                    nodeWidth: nodeWidth,
                    onOpenCheckpoint: _openCheckpointSession,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFutureBranchesSectionV1() {
    return FutureBuilder<Set<int>>(
      future: _loadEffectiveCompletedWorldsV1(),
      builder: (context, completedSnap) {
        final completedWorlds = completedSnap.data ?? const <int>{};
        final coreComplete = List<int>.generate(
          10,
          (index) => index + 1,
        ).every(completedWorlds.contains);
        if (!coreComplete) {
          return const SizedBox.shrink();
        }
        return Column(
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _FutureBranchPlaceholder(
                    key: const Key('world1_branch_cash_unlocked'),
                    label: 'Cash',
                    requirementLabel: 'Unlocked',
                    requirementKey: const Key(
                      'world1_branch_cash_requirements',
                    ),
                    isLocked: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ModuleLauncherScreen(
                            branch: ModuleLauncherBranch.cash,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _FutureBranchPlaceholder(
                    key: const Key('world1_branch_mtt_unlocked'),
                    label: 'MTT',
                    requirementLabel: 'Unlocked',
                    requirementKey: const Key('world1_branch_mtt_requirements'),
                    isLocked: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ModuleLauncherScreen(
                            branch: ModuleLauncherBranch.mtt,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }

  int? _worldForPackId(String packId) {
    final normalized = packId.trim();
    if (normalized.isEmpty) return null;
    return ProgressService.worldIndexForPackIdV1(normalized);
  }

  List<String> _sortedPackIdsForWorld(int world) {
    return canonical_truth.canonicalTruthCampaignPackOrderForWorldV1(world);
  }

  String _lessonBuyInObjectiveV1({
    required bool isNext,
    required bool completed,
  }) {
    if (isNext) {
      return 'This is your next lesson in the current world.';
    }
    if (completed) {
      return 'Review this lesson to lock in the pattern.';
    }
    return 'Complete previous lessons to unlock this node.';
  }

  String _inlineNodeTitleV1({
    required String packId,
    required String rawLabel,
    required int inlineWorld,
    required int lessonNumber,
  }) {
    final trimmedLabel = rawLabel.trim();
    if (trimmedLabel.isNotEmpty &&
        trimmedLabel != 'Act 0' &&
        trimmedLabel != 'Spine' &&
        !trimmedLabel.contains('Followup')) {
      return trimmedLabel;
    }
    final normalized = packId.trim().toLowerCase();
    if (normalized.contains('table_literacy')) {
      return 'Table Basics';
    }
    if (normalized.contains('action_literacy')) {
      return 'Action Order';
    }
    if (normalized.contains('street_flow')) {
      return 'Street Flow';
    }
    if (normalized.contains('followup_v1_b0')) {
      return 'Practice 1';
    }
    if (normalized.contains('followup_v1_b1')) {
      return 'Practice 2';
    }
    if (normalized.contains('followup_v1_b2')) {
      return 'Practice 3';
    }
    if (normalized.contains('spine_campaign_v1')) {
      return '${_levelTitlesV1[inlineWorld - 1]} Core';
    }
    return 'Level ${inlineWorld - 1} Lesson $lessonNumber';
  }

  String _inlineNodePreviewSubtitleV1({
    required int inlineWorld,
    required bool isNext,
    required bool completed,
  }) {
    final levelIndex = inlineWorld - 1;
    if (levelIndex >= 0 && levelIndex < _levelFocusLinesV1.length) {
      return _levelFocusLinesV1[levelIndex];
    }
    return _lessonBuyInObjectiveV1(isNext: isNext, completed: completed);
  }

  void _dismissMapNodePreviewOverlayV1() {
    if (!mounted || _mapNodePreviewV1 == null) return;
    setState(() {
      _mapNodePreviewV1 = null;
    });
  }

  GlobalKey _worldNodeKeyForIdV1(String moduleId) {
    final normalized = moduleId.trim();
    return _worldNodeKeysV1.putIfAbsent(
      normalized,
      () => GlobalKey(debugLabel: 'world1_node_$normalized'),
    );
  }

  Rect? _mapNodeAnchorRectForContextV1(BuildContext nodeContext) {
    final nodeRenderBox = nodeContext.findRenderObject();
    final overlayRenderBox = _mapOverlayHostKeyV1.currentContext
        ?.findRenderObject();
    if (nodeRenderBox is! RenderBox ||
        overlayRenderBox is! RenderBox ||
        !nodeRenderBox.hasSize ||
        !overlayRenderBox.hasSize) {
      return null;
    }
    final topLeft = nodeRenderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayRenderBox,
    );
    return topLeft & nodeRenderBox.size;
  }

  Future<void> _openMapNodePreviewV1({
    required BuildContext nodeContext,
    required String packId,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required int inlineWorld,
    required bool canStart,
  }) async {
    try {
      final anchorRect = _mapNodeAnchorRectForContextV1(nodeContext);
      if (anchorRect != null && mounted) {
        setState(() {
          _mapNodePreviewV1 = _MapNodePreviewStateV1(
            anchorRect: anchorRect,
            packId: packId,
            title: title,
            subtitle: subtitle,
            ctaLabel: ctaLabel,
            inlineWorld: inlineWorld,
            canStart: canStart,
          );
        });
        return;
      }
    } catch (_) {
      // Fall back to the modal preview if anchored geometry is unavailable.
    }
    await _showMapNodePreviewSheetV1(
      packId: packId,
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      inlineWorld: inlineWorld,
      canStart: canStart,
    );
  }

  Future<void> _showMapNodePreviewSheetV1({
    required String packId,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required int inlineWorld,
    required bool canStart,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SizedBox(
              width: double.infinity,
              child: KeyedSubtree(
                key: const Key('map_node_preview_sheet_v1'),
                child: _buildMapNodePreviewSurfaceV1(
                  title: title,
                  subtitle: subtitle,
                  ctaLabel: ctaLabel,
                  canStart: canStart,
                  onPrimaryPressed: canStart
                      ? () async {
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          await _openCampaignPack(
                            packId: packId,
                            title: 'World $inlineWorld',
                          );
                        }
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapNodePreviewSurfaceV1({
    required String title,
    required String subtitle,
    required String ctaLabel,
    required bool canStart,
    required Future<void> Function()? onPrimaryPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: SharkyTokensV1.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SharkyTokensV1.slate600.withOpacity(0.72),
            width: 1.15,
          ),
          boxShadow: <BoxShadow>[
            ...SharkyTokensV1.elevation3.map(
              (shadow) => shadow.copyWith(
                color: SharkyTokensV1.slate600.withOpacity(0.32),
              ),
            ),
            BoxShadow(
              color: SharkyTokensV1.brandGlow.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h3.copyWith(
                color: SharkyTokensV1.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('map_node_preview_primary_cta_v1'),
                onPressed: canStart
                    ? () async {
                        await onPrimaryPressed?.call();
                      }
                    : null,
                child: Text(ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapNodePreviewCardContentV1(_MapNodePreviewStateV1 preview) {
    return _buildMapNodePreviewSurfaceV1(
      title: preview.title,
      subtitle: preview.subtitle,
      ctaLabel: preview.ctaLabel,
      canStart: preview.canStart,
      onPrimaryPressed: () async {
        _dismissMapNodePreviewOverlayV1();
        await _openCampaignPack(
          packId: preview.packId,
          title: 'World ${preview.inlineWorld}',
        );
      },
    );
  }

  Widget _buildMapNodePreviewOverlayV1() {
    final preview = _mapNodePreviewV1;
    if (preview == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        const horizontalMargin = 12.0;
        const verticalMargin = 12.0;
        const gap = 10.0;
        final safeTop = mediaQuery.padding.top + verticalMargin;
        final safeBottom =
            constraints.maxHeight - mediaQuery.padding.bottom - verticalMargin;
        final maxCardWidth = constraints.maxWidth - (horizontalMargin * 2);
        final cardWidth = maxCardWidth.clamp(220.0, 280.0);
        final anchorCenterX = preview.anchorRect.center.dx;
        final left = (anchorCenterX - (cardWidth / 2)).clamp(
          horizontalMargin,
          constraints.maxWidth - cardWidth - horizontalMargin,
        );
        const estimatedCardHeight = 154.0;
        final spaceAbove = preview.anchorRect.top - safeTop;
        final spaceBelow = safeBottom - preview.anchorRect.bottom;
        final showAbove =
            spaceAbove >= estimatedCardHeight || spaceAbove >= spaceBelow;
        final top = showAbove
            ? (preview.anchorRect.top - estimatedCardHeight - gap).clamp(
                safeTop,
                (safeBottom - estimatedCardHeight).clamp(safeTop, safeBottom),
              )
            : (preview.anchorRect.bottom + gap).clamp(
                safeTop,
                (safeBottom - estimatedCardHeight).clamp(safeTop, safeBottom),
              );
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _dismissMapNodePreviewOverlayV1,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              key: const Key('map_node_preview_overlay_v1'),
              left: left,
              top: top,
              width: cardWidth,
              child: _buildMapNodePreviewCardContentV1(preview),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWorldDetailSheet({
    required int world,
    required String title,
    required Set<String> completedPackIds,
  }) async {
    if (!mounted) return;
    final worldPackIds = _sortedPackIdsForWorld(world);
    final firstIncompleteIndex = worldPackIds.indexWhere(
      (packId) => !completedPackIds.contains(packId),
    );
    final nextIndex = firstIncompleteIndex >= 0 ? firstIncompleteIndex : -1;
    final String? nextPackId = nextIndex >= 0 ? worldPackIds[nextIndex] : null;
    final String? firstPackId = worldPackIds.isNotEmpty
        ? worldPackIds.first
        : null;
    final primaryCtaLabel = nextPackId != null ? 'START NEXT LESSON' : 'REVIEW';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SharkyTokensV1.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetContext) {
        final total = worldPackIds.length;
        final done = worldPackIds
            .where((packId) => completedPackIds.contains(packId))
            .length;
        final worldCompleted = total > 0 && done >= total;
        final sheetSize = MediaQuery.sizeOf(sheetContext);
        final compactSheet = sheetSize.width < 410 || sheetSize.height < 780;
        final progressValue = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
        final nextLessonLabel = nextPackId == null
            ? null
            : ProgressService.segmentLabelForPackIdV1(nextPackId);
        final detailNodeSize = compactSheet ? 44.0 : 46.0;
        final connectorTopHeight = compactSheet ? 8.0 : 10.0;
        final connectorBottomHeight = compactSheet ? 14.0 : 16.0;
        return SafeArea(
          child: Container(
            key: const Key('world_detail_sheet_v1'),
            constraints: BoxConstraints(maxHeight: sheetSize.height * 0.84),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'World $world - $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (compactSheet
                                    ? AppTypography.label
                                    : AppTypography.h3)
                                .copyWith(
                                  color: SharkyTokensV1.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compactSheet ? 7 : 8,
                        vertical: compactSheet ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: SharkyTokensV1.surfaceApp.withOpacity(0.54),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: SharkyTokensV1.slate500.withOpacity(0.42),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '$done/$total',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.2,
                        ),
                      ),
                    ),
                    if (worldCompleted) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compactSheet ? 7 : 8,
                          vertical: compactSheet ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: SharkyTokensV1.semanticWin.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: SharkyTokensV1.semanticWin.withOpacity(0.75),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Completed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.semanticWin,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                      width: 44,
                      height: 44,
                      key: const Key('world_detail_close_cta_v1'),
                      child: IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: SharkyTokensV1.textSecondary,
                        ),
                        tooltip: 'Close',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: compactSheet ? 3.5 : 4,
                    backgroundColor: SharkyTokensV1.slate600.withOpacity(0.35),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SharkyTokensV1.brandPrimary.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                if (compactSheet && total > 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'Scroll for more lessons',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.6,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: worldPackIds.length,
                    itemBuilder: (context, index) {
                      final packId = worldPackIds[index];
                      final completed = completedPackIds.contains(packId);
                      final isNext = !completed && index == nextIndex;
                      final unlocked = completed || isNext;
                      final snakeOffset = compactSheet
                          ? 0.0
                          : (index.isEven ? 0.0 : 8.0);
                      final nodeColor = completed
                          ? SharkyTokensV1.semanticWin.withOpacity(0.22)
                          : isNext
                          ? SharkyTokensV1.brandPrimary.withOpacity(0.2)
                          : SharkyTokensV1.surfaceApp.withOpacity(0.5);
                      final borderColor = completed
                          ? SharkyTokensV1.semanticWin
                          : isNext
                          ? SharkyTokensV1.brandGlow
                          : SharkyTokensV1.slate500.withOpacity(0.7);
                      final stateLabel = completed
                          ? 'DONE'
                          : isNext
                          ? 'NEXT'
                          : 'LOCKED';
                      final shortName = ProgressService.segmentLabelForPackIdV1(
                        packId,
                      );
                      return Padding(
                        padding: EdgeInsets.only(
                          left: snakeOffset,
                          right: compactSheet ? 0 : (12.0 - snakeOffset),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                if (index > 0)
                                  Container(
                                    width: 2.5,
                                    height: connectorTopHeight,
                                    color: SharkyTokensV1.slate500.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                SizedBox(
                                  width: detailNodeSize,
                                  height: detailNodeSize,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      if (isNext)
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: detailNodeSize + 2,
                                              height: detailNodeSize + 2,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: SharkyTokensV1
                                                      .brandGlow
                                                      .withOpacity(0.95),
                                                  width: 2.4,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: SharkyTokensV1
                                                        .brandGlow
                                                        .withOpacity(0.28),
                                                    blurRadius: 11,
                                                    spreadRadius: 1.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      OutlinedButton(
                                        key: Key(
                                          'world_detail_pack_node_${world}_${index + 1}',
                                        ),
                                        onPressed: unlocked
                                            ? () async {
                                                Navigator.of(
                                                  sheetContext,
                                                ).pop();
                                                await _openCampaignPack(
                                                  packId: packId,
                                                  title: 'World $world',
                                                );
                                              }
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(44, 44),
                                          maximumSize: Size(
                                            detailNodeSize,
                                            detailNodeSize,
                                          ),
                                          fixedSize: Size(
                                            detailNodeSize,
                                            detailNodeSize,
                                          ),
                                          shape: const CircleBorder(),
                                          padding: EdgeInsets.zero,
                                          side: BorderSide(
                                            color: borderColor,
                                            width: isNext ? 1.6 : 1.0,
                                          ),
                                          backgroundColor: nodeColor,
                                        ),
                                        child: Icon(
                                          completed
                                              ? Icons.check_rounded
                                              : isNext
                                              ? Icons.play_arrow_rounded
                                              : Icons.lock_outline,
                                          size: 18,
                                          color: completed
                                              ? SharkyTokensV1.semanticWin
                                              : isNext
                                              ? SharkyTokensV1.brandGlow
                                              : SharkyTokensV1.textMuted,
                                        ),
                                      ),
                                      if (completed)
                                        Positioned(
                                          top: -1,
                                          right: -1,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.semanticWin,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    SharkyTokensV1.surfaceCard,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: SharkyTokensV1.textPrimary,
                                              size: 10,
                                            ),
                                          ),
                                        )
                                      else if (!unlocked)
                                        Positioned(
                                          top: -1,
                                          right: -1,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: SharkyTokensV1.surfaceCard,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: SharkyTokensV1.slate500
                                                    .withOpacity(0.8),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.lock_outline_rounded,
                                              color: SharkyTokensV1.textMuted,
                                              size: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (index < worldPackIds.length - 1)
                                  Container(
                                    width: 2.5,
                                    height: connectorBottomHeight,
                                    color: SharkyTokensV1.slate500.withOpacity(
                                      0.6,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: compactSheet ? 6 : 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shortName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: unlocked
                                            ? SharkyTokensV1.textPrimary
                                            : SharkyTokensV1.textMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      stateLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: completed
                                            ? SharkyTokensV1.semanticWin
                                            : isNext
                                            ? SharkyTokensV1.brandGlow
                                            : SharkyTokensV1.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                    if (isNext) ...[
                                      const SizedBox(height: 0.5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons
                                                .subdirectory_arrow_right_rounded,
                                            size: 12,
                                            color: SharkyTokensV1.brandGlow
                                                .withOpacity(0.9),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'START HERE',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color: SharkyTokensV1
                                                      .brandGlow
                                                      .withOpacity(0.9),
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10.2,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('world_detail_primary_cta_v1'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        elevation: 2,
                        shadowColor: SharkyTokensV1.brandGlow.withOpacity(0.22),
                        textStyle: AppTypography.label.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.35,
                        ),
                      ),
                      onPressed: firstPackId == null
                          ? null
                          : () async {
                              final selectedPackId = nextPackId ?? firstPackId;
                              Navigator.of(sheetContext).pop();
                              await _openCampaignPack(
                                packId: selectedPackId,
                                title: 'World $world',
                              );
                            },
                      child: Text(primaryCtaLabel),
                    ),
                  ),
                ),
                if (!compactSheet && nextLessonLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Next: $nextLessonLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCampaignPack({
    required String packId,
    required String title,
    int startHandIndex = 0,
    bool debugAutoPopForTestV1 = false,
  }) async {
    if (!mounted) return;
    final landingDecision = await _resolveCanonicalMapLandingDecisionV1(
      canonicalEntryPackId: packId,
      source: CanonicalLandingSourceV1.mapStart,
      allowReviewQueue: false,
    );
    final resolvedPackId = landingDecision.entryId;
    if (resolvedPackId.trim().isEmpty) return;
    await ProgressService.spendChipsForSessionStartV1();
    if (debugAutoPopForTestV1) {
      unawaited(() async {
        for (var i = 0; i < 40; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 16));
          if (!mounted) return;
          final nav = Navigator.of(context);
          if (nav.canPop()) {
            nav.pop(false);
            return;
          }
        }
      }());
    }
    if (landingDecision.surfaceKind ==
        CanonicalLandingSurfaceKindV1.directSessionLaunch) {
      final handoffContextV1 = buildProgressionHandoffContextForPackV1(packId);
      await Navigator.of(context).push<void>(
        canonicalSessionDrillRouteV1(
          sessionId: resolvedPackId,
          handoffContextV1: handoffContextV1,
        ),
      );
      _refresh(focusCurrentNode: true);
      return;
    }
    await pushWorld1FoundationsRunnerV1<bool>(
      context,
      moduleId: resolvedPackId,
      moduleTitle: title,
      mode: landingDecision.runnerMode ?? kWorld1RunnerModeCampaignSpine,
      startHandIndex: startHandIndex > 0
          ? startHandIndex
          : landingDecision.startHandIndex,
    );
    _refresh(focusCurrentNode: true);
  }

  Future<String> _resolveCampaignLaunchTargetV1(String packId) async {
    final landingDecision = await _resolveCanonicalMapLandingDecisionV1(
      canonicalEntryPackId: packId,
      source: CanonicalLandingSourceV1.mapStart,
      allowReviewQueue: false,
    );
    return landingDecision.entryId;
  }

  @visibleForTesting
  Future<void> debugStartCampaignPackForTestV1(String packId) async {
    await _openCampaignPack(
      packId: packId,
      title: 'TEST PACK',
      debugAutoPopForTestV1: true,
    );
  }

  @visibleForTesting
  void debugLaunchCampaignPackForTestV1(String packId) {
    unawaited(_openCampaignPack(packId: packId, title: 'TEST PACK'));
  }

  @visibleForTesting
  Future<String> debugResolveCampaignLaunchTargetForTestV1(String packId) {
    return _resolveCampaignLaunchTargetV1(packId);
  }

  @visibleForTesting
  Future<void> debugHandleCampaignStartNowForTestV1() async {
    await _handleCampaignStartNowActionV1();
  }

  @visibleForTesting
  Future<void> debugOpenReviewQueueForNextPackForTestV1() async {
    await _openReviewQueueForNextPackV1();
  }

  @visibleForTesting
  Future<void> debugOpenReviewQueueForPackForTestV1(String packId) async {
    await _openReviewQueueForPackV1(packId);
  }

  @visibleForTesting
  Future<void> debugRefreshCampaignForTestV1() async {
    await _refreshCampaignNextPackId();
  }

  @visibleForTesting
  List<String> debugVisiblePackOrderForWorldForTestV1(int world) {
    return _sortedPackIdsForWorld(world);
  }

  @visibleForTesting
  String debugInlineNodeTitleForTestV1({
    required String packId,
    required int inlineWorld,
    required int lessonNumber,
  }) {
    return _inlineNodeTitleV1(
      packId: packId,
      rawLabel: '',
      inlineWorld: inlineWorld,
      lessonNumber: lessonNumber,
    );
  }

  @visibleForTesting
  String? debugNextPackIdForWorldForTestV1({
    required int world,
    required Set<String> completedPackIds,
  }) {
    final visiblePackOrder = _sortedPackIdsForWorld(world);
    for (final packId in visiblePackOrder) {
      if (!completedPackIds.contains(packId)) {
        return packId;
      }
    }
    return null;
  }

  @visibleForTesting
  void debugSelectInlineWorldForTestV1({
    required int world,
    String? nextPackId,
  }) {
    if (!mounted) return;
    setState(() {
      _inlineSelectedWorld = world;
      if (nextPackId != null && nextPackId.trim().isNotEmpty) {
        _campaignNextPackId = nextPackId.trim();
      }
    });
  }

  @visibleForTesting
  Future<void> debugShowLockedNodePreviewForTestV1({
    int inlineWorld = 1,
    String title = 'Practice 2',
    String subtitle = 'Complete previous lessons to unlock this.',
  }) async {
    if (!mounted) return;
    final overlayRenderBox = _mapOverlayHostKeyV1.currentContext
        ?.findRenderObject();
    if (overlayRenderBox is RenderBox && overlayRenderBox.hasSize) {
      final width = overlayRenderBox.size.width;
      setState(() {
        _mapNodePreviewV1 = _MapNodePreviewStateV1(
          anchorRect: Rect.fromLTWH(width * 0.5 - 24, 120, 48, 48),
          packId: 'debug_locked_pack_v1',
          title: title,
          subtitle: subtitle,
          ctaLabel: 'LOCKED',
          inlineWorld: inlineWorld,
          canStart: false,
        );
      });
      return;
    }
    await _showMapNodePreviewSheetV1(
      packId: 'debug_locked_pack_v1',
      title: title,
      subtitle: subtitle,
      ctaLabel: 'LOCKED',
      inlineWorld: inlineWorld,
      canStart: false,
    );
  }

  Future<void> _openNextCampaignPackFromSsoT() async {
    unawaited(AudioService.instance.playUiSfx('click_start'));
    final nextPackId = await _resolveEarliestIncompleteWorld1PackIdV1();
    if (nextPackId.trim().isEmpty) return;
    final completed = await ProgressService.isSpinePackCompletedV1(nextPackId);
    if (completed) return;
    final activePackId = await ProgressService.getSpineActivePackIdV1();
    final startIndex = activePackId == nextPackId
        ? await ProgressService.getSpineNextHandIndexV1()
        : 0;
    await _openCampaignPack(
      packId: nextPackId,
      title: 'NEXT PACK',
      startHandIndex: startIndex,
    );
  }

  Future<void> _showCampaignHelpSheet() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: SharkyTokensV1.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help',
                  style: AppTypography.h3.copyWith(
                    color: SharkyTokensV1.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Complete worlds in order and use NEXT PACK.',
                  style: AppTypography.caption.copyWith(
                    color: SharkyTokensV1.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2. Accuracy shows correct decisions. Focus shows top error categories.',
                  style: AppTypography.caption.copyWith(
                    color: SharkyTokensV1.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3. $kLaunchSupportLineV1',
                  style: AppTypography.caption.copyWith(
                    color: SharkyTokensV1.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int? _levelForPackIdV1(String packId) {
    final normalized = packId.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized.startsWith('world1_act0_')) return 0;
    if (normalized.startsWith('world1_')) return 1;
    final world = _worldForPackId(normalized);
    if (world == null) return null;
    if (world >= 2 && world <= 9) return world;
    return null;
  }

  bool computeLevelCompletionV1({
    required int levelIndex,
    required Set<String> completedPackIds,
  }) {
    final packIds = _packIdsForLevelV1(levelIndex);
    if (packIds.isEmpty) return false;
    return packIds.every(completedPackIds.contains);
  }

  Future<bool> _computeEffectiveLevelCompletionV1({
    required int levelIndex,
    required Set<String> completedPackIds,
  }) async {
    if (levelIndex <= 1) {
      return computeLevelCompletionV1(
        levelIndex: levelIndex,
        completedPackIds: completedPackIds,
      );
    }
    final canonicalPlayableSessionIds = canonical_truth
        .canonicalTruthPlayableSessionEntriesForWorldV1(levelIndex)
        .map((entry) => entry.sessionId);
    return ProgressService.isEffectiveCampaignWorldDoneV1(
      world: levelIndex,
      completedPackIds: completedPackIds,
      canonicalPlayableSessionIds: canonicalPlayableSessionIds,
    );
  }

  String? computeNextLevelFirstPackIdV1(int levelIndex) {
    final nextLevel = levelIndex + 1;
    if (nextLevel > 9) return null;
    final nextPackIds = _packIdsForLevelV1(nextLevel);
    if (nextPackIds.isEmpty) return null;
    return nextPackIds.first;
  }

  List<String> _packIdsForLevelV1(int level) {
    if (level == 0) return _level0PackIdsV1;
    if (level == 1) {
      return ProgressService.campaignPackIdsV1
          .where(
            (id) => id.startsWith('world1_') && !id.startsWith('world1_act0_'),
          )
          .toList(growable: false);
    }
    return _sortedPackIdsForWorld(level);
  }

  int _mapWorldForLevelV1(int levelIndex) {
    if (levelIndex <= 1) return 1;
    return levelIndex;
  }

  String _levelCompletionShownKeyV1(int levelIndex) {
    return 'level_complete_shown_v1_level_$levelIndex';
  }

  Future<bool> _wasLevelCompletionShownV1(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_levelCompletionShownKeyV1(levelIndex)) ?? false;
  }

  Future<void> _markLevelCompletionShownV1(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_levelCompletionShownKeyV1(levelIndex), true);
  }

  Future<void> _handleLevelCompletionTransitionV1({
    required String nextPackId,
    required Set<String> completedPackIds,
  }) async {
    final completedNow = <int>{};
    for (var level = 0; level <= 9; level++) {
      if (await _computeEffectiveLevelCompletionV1(
        levelIndex: level,
        completedPackIds: completedPackIds,
      )) {
        completedNow.add(level);
      }
    }
    if (!_levelCompletionSnapshotBootstrappedV1) {
      _levelCompletionSnapshotBootstrappedV1 = true;
      _completedLevelsSnapshotV1 = completedNow;
      return;
    }
    int? newlyCompletedLevel;
    for (var level = 0; level <= 9; level++) {
      if (completedNow.contains(level) &&
          !_completedLevelsSnapshotV1.contains(level)) {
        newlyCompletedLevel = level;
        break;
      }
    }
    _completedLevelsSnapshotV1 = completedNow;
    if (newlyCompletedLevel == null || _levelTransitionSheetOpenV1) return;
    if (await _wasLevelCompletionShownV1(newlyCompletedLevel)) return;
    await _markLevelCompletionShownV1(newlyCompletedLevel);
    await Telemetry.logEvent('level_complete_shown_v1', <String, dynamic>{
      'schemaVersion': 1,
      'levelIndex': newlyCompletedLevel,
    });
    if (!mounted) return;
    await _showLevelCompleteSheetV1(
      levelIndex: newlyCompletedLevel,
      nextPackId: nextPackId,
    );
  }

  Future<void> _showLevelCompleteSheetV1({
    required int levelIndex,
    required String nextPackId,
  }) async {
    if (!mounted || _levelTransitionSheetOpenV1) return;
    _levelTransitionSheetOpenV1 = true;
    try {
      final nextPackIdForLevel = computeNextLevelFirstPackIdV1(levelIndex);
      final nextLevel = levelIndex + 1;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: false,
        backgroundColor: SharkyTokensV1.surfaceCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Container(
              key: const Key('map_level_complete_sheet_v1'),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $levelIndex complete',
                    style: AppTypography.h3.copyWith(
                      color: SharkyTokensV1.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You learned: ${_levelFocusLinesV1[levelIndex]}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (nextPackIdForLevel != null && nextLevel <= 9) ...[
                    const SizedBox(height: 10),
                    Text(
                      'UP NEXT',
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level $nextLevel - ${_levelTitlesV1[nextLevel]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        color: SharkyTokensV1.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _levelFocusLinesV1[nextLevel],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (nextPackIdForLevel != null && nextLevel <= 9)
                        Expanded(
                          child: FilledButton(
                            key: const Key('map_level_complete_next_cta_v1'),
                            style: FilledButton.styleFrom(
                              backgroundColor: SharkyTokensV1.brandPrimary,
                              foregroundColor: SharkyTokensV1.textInverted,
                              textStyle: AppTypography.label.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () async {
                              await Telemetry.logEvent(
                                'level_complete_next_clicked_v1',
                                <String, dynamic>{
                                  'schemaVersion': 1,
                                  'fromLevel': levelIndex,
                                  'toLevel': nextLevel,
                                },
                              );
                              if (!sheetContext.mounted) return;
                              Navigator.of(sheetContext).pop();
                              final launchPackId =
                                  nextPackId.trim() == nextPackIdForLevel.trim()
                                  ? nextPackId.trim()
                                  : nextPackIdForLevel;
                              await _openCampaignPack(
                                packId: launchPackId,
                                title: 'LEVEL $nextLevel START',
                              );
                            },
                            child: Text('Go to Level $nextLevel'),
                          ),
                        ),
                      if (nextPackIdForLevel != null && nextLevel <= 9)
                        const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('map_level_complete_replay_cta_v1'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SharkyTokensV1.textPrimary,
                            side: BorderSide(
                              color: SharkyTokensV1.slate500.withOpacity(0.42),
                            ),
                            textStyle: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () async {
                            await Telemetry.logEvent(
                              'level_complete_replay_clicked_v1',
                              <String, dynamic>{
                                'schemaVersion': 1,
                                'levelIndex': levelIndex,
                              },
                            );
                            if (mounted) {
                              setState(() {
                                _inlineSelectedWorld = _mapWorldForLevelV1(
                                  levelIndex,
                                );
                                _inlineSelectedPackId = null;
                              });
                            }
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          child: Text('Replay Level $levelIndex'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      _levelTransitionSheetOpenV1 = false;
    }
  }

  Future<void> _showLevelsSheetV1() async {
    if (!mounted) return;
    final completedPackIds = await ProgressService.getSpineCompletedPackIdsV1();
    final levelRows = <Map<String, dynamic>>[];
    for (var level = 0; level <= 9; level++) {
      final packIds = _packIdsForLevelV1(level);
      final completedCount = packIds.where(completedPackIds.contains).length;
      final done = packIds.isNotEmpty && completedCount >= packIds.length;
      levelRows.add(<String, dynamic>{
        'level': level,
        'packIds': packIds,
        'completedCount': completedCount,
        'done': done,
      });
    }
    final firstIncomplete = levelRows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['done'] != true,
      orElse: () => null,
    );
    var currentLevel = _levelForPackIdV1(_campaignNextPackId.trim());
    if (currentLevel == null ||
        ((levelRows[currentLevel]['done'] as bool?) ?? false)) {
      currentLevel = firstIncomplete?['level'] as int?;
    }
    final nextLevel = currentLevel == null
        ? null
        : (currentLevel + 1 <= 9 ? currentLevel + 1 : null);
    var selectedLevelForHeader = currentLevel ?? 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final headerLevel = selectedLevelForHeader.clamp(0, 9);
              final headerTitle = _levelTitlesV1[headerLevel];
              final headerFocus = _levelFocusLinesV1[headerLevel];
              return Container(
                key: const Key('map_levels_sheet_v1'),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: SharkyTokensV1.surfaceCard,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: SharkyTokensV1.slate500.withOpacity(0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: SharkyTokensV1.slate500.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Levels',
                              style: AppTypography.h3.copyWith(
                                color: SharkyTokensV1.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Container(
                        key: const Key('map_levels_sticky_node_header_v1'),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: SharkyTokensV1.surfaceApp.withOpacity(0.44),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: SharkyTokensV1.brandGlow.withOpacity(0.34),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Selected node',
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textMuted,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Level $headerLevel - $headerTitle',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label.copyWith(
                                color: SharkyTokensV1.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              headerFocus,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        itemCount: levelRows.length,
                        itemBuilder: (context, index) {
                          final row = levelRows[index];
                          final level = row['level'] as int;
                          final packIds =
                              row['packIds'] as List<String>? ??
                              const <String>[];
                          final completedCount =
                              row['completedCount'] as int? ?? 0;
                          final done = row['done'] as bool? ?? false;
                          final isCurrent =
                              currentLevel != null && level == currentLevel;
                          final isNext =
                              nextLevel != null && level == nextLevel;
                          final showDetails = done || isCurrent || isNext;
                          final status = done
                              ? 'DONE'
                              : isCurrent
                              ? 'CURRENT'
                              : isNext
                              ? 'NEXT'
                              : 'LOCKED';
                          final stateIcon = done
                              ? Icons.check_rounded
                              : isCurrent
                              ? Icons.play_arrow_rounded
                              : isNext
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded;
                          final statusColor = done
                              ? SharkyTokensV1.semanticWin
                              : isCurrent
                              ? SharkyTokensV1.brandGlow
                              : isNext
                              ? SharkyTokensV1.textSecondary
                              : SharkyTokensV1.textMuted;
                          final actionLabel = done
                              ? 'Replay'
                              : isCurrent
                              ? 'Continue'
                              : 'Locked';
                          final leftInset = index.isOdd ? 22.0 : 0.0;
                          final rightInset = index.isEven ? 22.0 : 0.0;

                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              leftInset,
                              0,
                              rightInset,
                              10,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  selectedLevelForHeader = level;
                                });
                              },
                              child: Container(
                                key: Key('map_levels_tile_${level}_v1'),
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  10,
                                ),
                                decoration: BoxDecoration(
                                  color: SharkyTokensV1.surfaceApp.withOpacity(
                                    0.50,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent
                                        ? SharkyTokensV1.brandGlow.withOpacity(
                                            0.58,
                                          )
                                        : SharkyTokensV1.slate500.withOpacity(
                                            0.30,
                                          ),
                                    width: isCurrent ? 1.2 : 0.9,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Level $level',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.label.copyWith(
                                              color: SharkyTokensV1.textPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(
                                              0.16,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: statusColor.withOpacity(
                                                0.42,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                stateIcon,
                                                size: 12,
                                                color: statusColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                status,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 10.5,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: SharkyTokensV1.surfaceElevated
                                            .withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: SharkyTokensV1.slate500
                                              .withOpacity(0.26),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            showDetails
                                                ? _levelTitlesV1[level]
                                                : 'Locked',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color: showDetails
                                                      ? SharkyTokensV1
                                                            .textSecondary
                                                      : SharkyTokensV1
                                                            .textMuted,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            showDetails
                                                ? _levelFocusLinesV1[level]
                                                : 'Locked',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color:
                                                      SharkyTokensV1.textMuted,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: SharkyTokensV1.surfaceApp
                                            .withOpacity(0.36),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: SharkyTokensV1.slate500
                                              .withOpacity(0.20),
                                        ),
                                      ),
                                      child: Text(
                                        'Subblocks: $completedCount/${packIds.length} completed',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: SharkyTokensV1.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: done && packIds.isNotEmpty
                                          ? OutlinedButton(
                                              key: Key(
                                                'map_levels_replay_$level',
                                              ),
                                              onPressed: () async {
                                                Navigator.of(
                                                  sheetContext,
                                                ).pop();
                                                await _openCampaignPack(
                                                  packId: packIds.first,
                                                  title: 'LEVEL $level REPLAY',
                                                );
                                              },
                                              child: Text(actionLabel),
                                            )
                                          : FilledButton(
                                              key: isCurrent
                                                  ? Key(
                                                      'map_levels_continue_$level',
                                                    )
                                                  : null,
                                              onPressed: isCurrent
                                                  ? () async {
                                                      Navigator.of(
                                                        sheetContext,
                                                      ).pop();
                                                      await _handleCampaignStartNowActionV1();
                                                    }
                                                  : null,
                                              style: FilledButton.styleFrom(
                                                backgroundColor: isCurrent
                                                    ? SharkyTokensV1
                                                          .brandPrimary
                                                    : SharkyTokensV1.slate600,
                                                disabledBackgroundColor:
                                                    SharkyTokensV1.slate600
                                                        .withOpacity(0.42),
                                                foregroundColor:
                                                    SharkyTokensV1.textInverted,
                                              ),
                                              child: Text(actionLabel),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCampaignWorldMapRow() {
    final normalizedNextPackId = _campaignNextPackId.trim();
    final nextWorld = _worldForPackId(normalizedNextPackId);
    final progressLabel =
        'Progress $_campaignCompletedHands/$_campaignTotalHands';
    return FutureBuilder<Set<String>>(
      future: ProgressService.getSpineCompletedPackIdsV1(),
      builder: (context, completedSnap) {
        final motionEnabled = CampaignUiMotionV1.microAnimationsEnabled;
        final microMotion = CampaignUiMotionV1.maybeAnimate(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          enabled: motionEnabled,
        );
        final compactCampaignLayout = MediaQuery.sizeOf(context).height < 900;
        final completedPackIds = completedSnap.data ?? const <String>{};
        final campaignPackIds = ProgressService.campaignPackIdsV1;
        final completedWorldCount = _effectiveCompletedWorldsV1.length;
        final campaignProgress = _campaignTotalHands <= 0
            ? 0.0
            : (_campaignCompletedHands / _campaignTotalHands).clamp(0.0, 1.0);
        var doneCount = 0;
        var nextCount = 0;
        var lockedCount = 0;
        final worldNodeData = <Map<String, dynamic>>[];
        for (var world = 1; world <= 10; world++) {
          final replayPackId = 'world${world}_spine_campaign_v1';
          final done = _effectiveCompletedWorldsV1.contains(world);
          final next = !done && nextWorld == world;
          final state = done
              ? 'DONE'
              : next
              ? 'NEXT'
              : 'LOCKED';
          final enabled = done || next;
          if (done) {
            doneCount += 1;
          } else if (next) {
            nextCount += 1;
          } else {
            lockedCount += 1;
          }
          final stateSemanticLabel = done
              ? 'completed'
              : next
              ? 'unlocked'
              : 'locked';
          worldNodeData.add(<String, dynamic>{
            'world': world,
            'state': state,
            'done': done,
            'next': next,
            'enabled': enabled,
            'semantic': stateSemanticLabel,
            'replayPackId': replayPackId,
          });
        }
        final firstIncompleteWorld =
            worldNodeData.cast<Map<String, dynamic>?>().firstWhere(
                  (node) => !((node?['done'] as bool?) ?? false),
                  orElse: () => null,
                )?['world']
                as int?;
        final currentWorld = firstIncompleteWorld ?? 10;
        final currentWorldPrefix = 'world${currentWorld}_';
        final currentWorldTotalPacks = campaignPackIds
            .where((id) => id.startsWith(currentWorldPrefix))
            .length;
        final currentWorldCompletedPacks = completedPackIds
            .where((id) => id.startsWith(currentWorldPrefix))
            .length;
        final detailsCollapsedLine = firstIncompleteWorld == null
            ? 'All worlds complete'
            : 'World $currentWorld: $currentWorldCompletedPacks/$currentWorldTotalPacks lessons';
        final screenHeight = MediaQuery.sizeOf(context).height;
        final panelMinHeight = compactCampaignLayout
            ? (screenHeight * 0.62).clamp(420.0, 700.0)
            : (screenHeight * 0.6).clamp(410.0, 660.0);
        var maxVisibleWorld = 1;
        for (var world = 2; world <= 10; world++) {
          final previousWorldDone =
              (worldNodeData[world - 2]['done'] as bool?) ?? false;
          if (!previousWorldDone) {
            break;
          }
          maxVisibleWorld = world;
        }
        final inlineWorld =
            (_inlineSelectedWorld != null &&
                _inlineSelectedWorld! >= 1 &&
                _inlineSelectedWorld! <= maxVisibleWorld)
            ? _inlineSelectedWorld!
            : currentWorld;
        final inlineWorldTitle = _campaignWorldTitlesEnV1[inlineWorld - 1];
        final inlinePackIds = _sortedPackIdsForWorld(inlineWorld);
        final inlinePackLabels = inlinePackIds
            .map(ProgressService.segmentLabelForPackIdV1)
            .toList(growable: false);
        final inlineLabelCounts = <String, int>{};
        for (final label in inlinePackLabels) {
          final normalized = label.trim().toLowerCase();
          inlineLabelCounts[normalized] =
              (inlineLabelCounts[normalized] ?? 0) + 1;
        }
        final inlineNextIndex = inlinePackIds.indexWhere(
          (packId) => !completedPackIds.contains(packId),
        );
        final inlineNodeSize = compactCampaignLayout ? 72.0 : 78.0;
        final inlineNodeStep = compactCampaignLayout ? 130.0 : 140.0;
        final inlinePathCanvasHeight =
            ((inlinePackIds.length - 1) * inlineNodeStep + inlineNodeSize + 48)
                .clamp(280.0, 980.0);
        final inlineSelectedPackId =
            (_inlineSelectedPackId != null &&
                inlinePackIds.contains(_inlineSelectedPackId))
            ? _inlineSelectedPackId
            : null;
        final compactUnlockHint = firstIncompleteWorld == null
            ? 'All worlds complete'
            : (firstIncompleteWorld == 1
                  ? 'Complete World 1 to unlock World 2'
                  : (currentWorldCompletedPacks == 0
                        ? 'World ${firstIncompleteWorld - 1} complete • World $firstIncompleteWorld unlocked'
                        : (firstIncompleteWorld >= 10
                              ? 'Complete World 10 to finish all worlds'
                              : 'Complete World $firstIncompleteWorld to unlock World ${firstIncompleteWorld + 1}')));

        return CampaignInfoCardV1(
          containerKey: const Key('world_campaign_section'),
          compact: true,
          microAnimationsEnabled: false,
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          decoration: BoxDecoration(
            color: SharkyTokensV1.surfaceCard.withOpacity(0.24),
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusLg),
            border: Border.all(
              color: SharkyTokensV1.slate500.withOpacity(0.1),
              width: 0.7,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: panelMinHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 0.5),
                Row(
                  key: const Key('world_campaign_hud'),
                  children: [
                    Expanded(
                      child: Text(
                        detailsCollapsedLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 9.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      key: const Key('world_campaign_details_toggle_v1'),
                      onPressed: () {
                        setState(() {
                          _campaignDetailsExpanded = !_campaignDetailsExpanded;
                        });
                      },
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(44, 30),
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      child: Text(
                        _campaignDetailsExpanded ? 'Hide' : 'Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      key: const Key('map_chips_badge_v1'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SharkyTokensV1.surfaceCard.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: SharkyTokensV1.slate500.withOpacity(0.28),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Chips: $_chipsBalanceV1',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0.5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  decoration: BoxDecoration(
                    color: SharkyTokensV1.surfaceApp.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SharkyTokensV1.slate500.withOpacity(0.22),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'World $inlineWorld - $inlineWorldTitle',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: SharkyTokensV1.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (_currentWorldMasteryV1 != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    key: const Key('map_world_mastery_badge'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SharkyTokensV1.surfaceCard
                                          .withOpacity(0.72),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: SharkyTokensV1.slate500
                                            .withOpacity(0.28),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      '${_currentWorldMasteryV1!.name[0].toUpperCase()}${_currentWorldMasteryV1!.name.substring(1)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (_currentWorldSkillTagsV1.isNotEmpty &&
                                _campaignDetailsExpanded) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Skills: ${skillTagsSummaryForPackIdV1(_campaignNextPackId, maxTags: 2).isEmpty ? _currentWorldSkillTagsV1.take(2).join(', ') : skillTagsSummaryForPackIdV1(_campaignNextPackId, maxTags: 2)}',
                                key: const Key('map_world_skill_tags_summary'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: SharkyTokensV1.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9.8,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: SharkyTokensV1.surfaceCard.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: SharkyTokensV1.slate500.withOpacity(0.28),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$currentWorldCompletedPacks/$currentWorldTotalPacks',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (_showLegacyPathRhythmStripOnCampaignMapV1)
                  KeyedSubtree(
                    key: const Key('legacy_path_rhythm_strip_v1'),
                    child: _buildPathRhythmNodesStripV1(
                      inlinePackIds: inlinePackIds,
                      nextPackId: normalizedNextPackId,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: inlinePathCanvasHeight,
                  child: LayoutBuilder(
                    builder: (context, pathConstraints) {
                      final pathWidth = pathConstraints.maxWidth;
                      final centerX = pathWidth / 2;
                      final nodeOffsetAmplitude = compactCampaignLayout
                          ? (pathWidth * 0.16).clamp(24.0, 56.0)
                          : (pathWidth * 0.20).clamp(28.0, 74.0);
                      final nodeLabelColumnWidth = compactCampaignLayout
                          ? 176.0
                          : 196.0;
                      final nodeCenters = <Offset>[];
                      for (
                        var index = 0;
                        index < inlinePackIds.length;
                        index++
                      ) {
                        final offsetX = index == 0
                            ? 0.0
                            : (index.isOdd
                                  ? -nodeOffsetAmplitude
                                  : nodeOffsetAmplitude);
                        final centerY =
                            20 +
                            (inlineNodeSize / 2) +
                            (index * inlineNodeStep);
                        nodeCenters.add(Offset(centerX + offsetX, centerY));
                      }
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _InlineLessonPathPainterV1(
                                  centers: nodeCenters,
                                  baseColor: SharkyTokensV1.slate500
                                      .withOpacity(0.72),
                                  glowColor: SharkyTokensV1.brandGlow
                                      .withOpacity(0.28),
                                ),
                              ),
                            ),
                          ),
                          for (
                            var index = 0;
                            index < inlinePackIds.length;
                            index++
                          )
                            (() {
                              final packId = inlinePackIds[index];
                              final completed = completedPackIds.contains(
                                packId,
                              );
                              final isNext =
                                  !completed && index == inlineNextIndex;
                              final unlocked = completed || isNext;
                              final isSelected = inlineSelectedPackId == packId;
                              final rawLabel = inlinePackLabels[index];
                              final normalizedLabel = rawLabel
                                  .trim()
                                  .toLowerCase();
                              final isRepeatedLabel =
                                  (inlineLabelCounts[normalizedLabel] ?? 0) > 1;
                              final shortName = _inlineNodeTitleV1(
                                packId: packId,
                                rawLabel: isRepeatedLabel ? '' : rawLabel,
                                inlineWorld: inlineWorld,
                                lessonNumber: index + 1,
                              );
                              final stateLabel = completed
                                  ? 'DONE'
                                  : isNext
                                  ? 'NEXT'
                                  : 'LOCKED';
                              final nextPackRawLabel = inlineNextIndex >= 0
                                  ? inlinePackLabels[inlineNextIndex]
                                  : null;
                              final nextPackRepeated = nextPackRawLabel == null
                                  ? false
                                  : (inlineLabelCounts[nextPackRawLabel
                                                .trim()
                                                .toLowerCase()] ??
                                            0) >
                                        1;
                              final nextPackTitle = inlineNextIndex >= 0
                                  ? _inlineNodeTitleV1(
                                      packId: inlinePackIds[inlineNextIndex],
                                      rawLabel: nextPackRepeated
                                          ? ''
                                          : (nextPackRawLabel ?? ''),
                                      inlineWorld: inlineWorld,
                                      lessonNumber: inlineNextIndex + 1,
                                    )
                                  : null;
                              final nodeColor = completed
                                  ? SharkyTokensV1.semanticWin.withOpacity(0.22)
                                  : isNext
                                  ? SharkyTokensV1.brandPrimary.withOpacity(0.2)
                                  : SharkyTokensV1.surfaceApp.withOpacity(0.56);
                              final borderColor = completed
                                  ? SharkyTokensV1.semanticWin
                                  : isNext
                                  ? SharkyTokensV1.brandGlow
                                  : SharkyTokensV1.slate500.withOpacity(0.72);
                              final nodeCenter = nodeCenters[index];
                              final labelColor = isNext
                                  ? SharkyTokensV1.brandGlow
                                  : completed
                                  ? SharkyTokensV1.semanticWin
                                  : SharkyTokensV1.textMuted;
                              return Positioned(
                                left:
                                    (nodeCenter.dx - (nodeLabelColumnWidth / 2))
                                        .clamp(
                                          0.0,
                                          (pathWidth - nodeLabelColumnWidth)
                                              .clamp(0.0, double.infinity),
                                        ),
                                top: nodeCenter.dy - (inlineNodeSize / 2),
                                width: nodeLabelColumnWidth,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: inlineNodeSize,
                                      height: inlineNodeSize,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          if (isNext)
                                            Positioned.fill(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: SharkyTokensV1
                                                        .brandGlow
                                                        .withOpacity(0.96),
                                                    width: 2.8,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: SharkyTokensV1
                                                          .brandGlow
                                                          .withOpacity(0.2),
                                                      blurRadius: 10,
                                                      spreadRadius: 0.6,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    SharkyTokensV1.surfaceCard,
                                              ),
                                            ),
                                          ),
                                          Builder(
                                            builder: (nodeContext) {
                                              return OutlinedButton(
                                                key: Key(
                                                  'inline_pack_node_${inlineWorld}_${index + 1}',
                                                ),
                                                onPressed: () async {
                                                  final previewSubtitle =
                                                      unlocked
                                                      ? _inlineNodePreviewSubtitleV1(
                                                          inlineWorld:
                                                              inlineWorld,
                                                          isNext: isNext,
                                                          completed: completed,
                                                        )
                                                      : nextPackTitle == null
                                                      ? 'Complete previous lessons to unlock this.'
                                                      : 'Complete previous lessons to unlock this. Up next: $nextPackTitle';
                                                  final ctaLabel = completed
                                                      ? 'REVIEW'
                                                      : isNext
                                                      ? 'START'
                                                      : 'LOCKED';
                                                  await _openMapNodePreviewV1(
                                                    nodeContext: nodeContext,
                                                    packId: packId,
                                                    title: shortName,
                                                    subtitle: previewSubtitle,
                                                    ctaLabel: ctaLabel,
                                                    inlineWorld: inlineWorld,
                                                    canStart: unlocked,
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  minimumSize: const Size(
                                                    44,
                                                    44,
                                                  ),
                                                  fixedSize: Size(
                                                    inlineNodeSize,
                                                    inlineNodeSize,
                                                  ),
                                                  shape: const CircleBorder(),
                                                  side: BorderSide(
                                                    color: borderColor,
                                                    width: isSelected
                                                        ? 2.2
                                                        : 1.4,
                                                  ),
                                                  backgroundColor: nodeColor,
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: Icon(
                                                  completed
                                                      ? Icons.check_rounded
                                                      : isNext
                                                      ? Icons.play_arrow_rounded
                                                      : Icons.lock_outline,
                                                  size: isNext ? 22 : 20,
                                                  color: completed
                                                      ? SharkyTokensV1
                                                            .semanticWin
                                                      : isNext
                                                      ? SharkyTokensV1.brandGlow
                                                      : SharkyTokensV1
                                                            .textMuted,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      shortName,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.2,
                                        height: 1.06,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 6,
                                      children: [
                                        Text(
                                          stateLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption.copyWith(
                                            color: labelColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10.8,
                                          ),
                                        ),
                                        if (isNext)
                                          Text(
                                            'START HERE',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color:
                                                      SharkyTokensV1.brandGlow,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 9.8,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            })(),
                        ],
                      );
                    },
                  ),
                ),
                if (inlineSelectedPackId != null) ...[
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final selectedPackId = inlineSelectedPackId;
                      final selectedLabel =
                          ProgressService.segmentLabelForPackIdV1(
                            selectedPackId,
                          );
                      final selectedIndex = inlinePackIds.indexOf(
                        selectedPackId,
                      );
                      final selectedCompleted = completedPackIds.contains(
                        selectedPackId,
                      );
                      final selectedIsNext =
                          !selectedCompleted &&
                          selectedIndex == inlineNextIndex;
                      final startLabel = selectedCompleted ? 'REVIEW' : 'START';
                      final objective = _lessonBuyInObjectiveV1(
                        isNext: selectedIsNext,
                        completed: selectedCompleted,
                      );
                      return SafeArea(
                        top: false,
                        minimum: const EdgeInsets.only(bottom: 2),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Container(
                            key: const Key('lesson_buy_in_card_v1'),
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            decoration: BoxDecoration(
                              color: SharkyTokensV1.surfaceApp.withOpacity(
                                0.58,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: SharkyTokensV1.slate500.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: SharkyTokensV1.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: IconButton(
                                        key: const Key(
                                          'lesson_buy_in_close_cta_v1',
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _inlineSelectedPackId = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: SharkyTokensV1.textSecondary,
                                        ),
                                        splashRadius: 20,
                                        tooltip: 'Close',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  objective,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: SharkyTokensV1.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '~30-60s',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: SharkyTokensV1.textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.6,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: FilledButton(
                                    key: const Key(
                                      'lesson_buy_in_start_cta_v1',
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _inlineSelectedPackId = null;
                                      });
                                      await _openCampaignPack(
                                        packId: selectedPackId,
                                        title: 'World $inlineWorld',
                                      );
                                    },
                                    child: Text(
                                      startLabel == 'START'
                                          ? 'START NEXT LESSON'
                                          : 'REVIEW',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (compactCampaignLayout && !_campaignDetailsExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Text(
                      compactUnlockHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textMuted.withOpacity(0.85),
                        fontSize: 9.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_campaignDetailsExpanded) ...[
                  const SizedBox(height: 4),
                  _buildLearningStatsDetailsV1(),
                  if (!compactCampaignLayout)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: const Key('world_campaign_help_cta'),
                        onPressed: _showCampaignHelpSheet,
                        icon: const Icon(Icons.help_outline, size: 16),
                        label: Text(
                          'Help',
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(44, 44),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  Text(
                    progressLabel,
                    key: const Key('world_campaign_progress_value'),
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        children: [
                          Container(
                            color: SharkyTokensV1.slate600.withOpacity(0.45),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: campaignProgress),
                            duration: microMotion.duration,
                            curve: microMotion.curve,
                            builder: (context, value, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: value,
                                child: child,
                              );
                            },
                            child: Container(
                              color: SharkyTokensV1.brandPrimary.withOpacity(
                                0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  !motionEnabled
                      ? Text(
                          'Worlds completed: $completedWorldCount/10',
                          key: const Key('world_campaign_worlds_completed'),
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: microMotion.duration,
                          reverseDuration: microMotion.duration,
                          switchInCurve: microMotion.curve,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.985,
                                  end: 1.0,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            'Worlds completed: $completedWorldCount/10',
                            key: ValueKey<String>(
                              'world_campaign_worlds_completed_$completedWorldCount',
                            ),
                            style: AppTypography.caption.copyWith(
                              color: SharkyTokensV1.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: CampaignRankBadgeV1(
                          label: _campaignRankLabel,
                          valueKey: const Key('world_campaign_rank_value'),
                          compact: true,
                          semanticsLabel: 'Campaign rank $_campaignRankLabel',
                        ),
                      ),
                    ],
                  ),
                  if (_campaignRankHint.isNotEmpty && !compactCampaignLayout)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _campaignRankHint,
                        key: const Key('world_campaign_rank_hint'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 108),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinnedStartNowCtaV1() {
    final normalizedNextPackId = _campaignNextPackId.trim();
    final exposeTodayPlanCompatKey =
        _campaignTotalHands <= 0 ||
        _campaignCompletedHands < _campaignTotalHands;
    return FutureBuilder<Set<String>>(
      future: ProgressService.getSpineCompletedPackIdsV1(),
      builder: (context, completedSnap) {
        final completedPackIds = completedSnap.data ?? const <String>{};
        final showNextPackCta =
            normalizedNextPackId.isNotEmpty &&
            !completedPackIds.contains(normalizedNextPackId);
        if (!showNextPackCta) {
          return SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 1,
                    width: 1,
                    child: GestureDetector(
                      key: const Key('today_plan_start_cta'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleCampaignStartNowActionV1,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _todayPlanRoutingReasonLineV1(normalizedNextPackId),
                    key: const Key('today_plan_focus_line_v1'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  key: exposeTodayPlanCompatKey
                      ? const Key('today_plan_start_cta')
                      : null,
                  height: 48,
                  width: 208,
                  child: CampaignPrimaryCtaV1(
                    controlKey: const Key('world_campaign_next_pack_cta'),
                    onPressed: _handleCampaignStartNowActionV1,
                    label: _mapNextPackCtaLabelV1(normalizedNextPackId),
                    compact: false,
                    microAnimationsEnabled: false,
                    semanticsLabel: _mapNextPackCtaSemanticsLabelV1(
                      normalizedNextPackId,
                    ),
                    textStyle: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: SharkyTokensV1.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todayPlanRoutingReasonLineV1(normalizedNextPackId),
                  key: const Key('today_plan_focus_line_v1'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: SharkyTokensV1.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _todayPlanRoutingReasonLineV1(String normalizedNextPackId) {
    return todayPlanRoutingReasonLineV1(
      normalizedNextPackId: normalizedNextPackId,
      reviewDueForNextPack: _mapRhythmDecisionV1.shouldGateStartNowToReview,
      mapRhythmReason: _mapRhythmDecisionV1.reason,
    );
  }

  String _mapNextPackCtaLabelV1(String normalizedNextPackId) {
    return mapNextPackCtaLabelV1(
      reviewRequired: _mapRhythmDecisionV1.shouldGateStartNowToReview,
      nextPackId: normalizedNextPackId,
      activePackId: _campaignActivePackId,
      nextHandIndex: _campaignNextHandIndexV1,
    );
  }

  String _mapNextPackCtaSemanticsLabelV1(String normalizedNextPackId) {
    return mapNextPackCtaSemanticsLabelV1(
      reviewRequired: _mapRhythmDecisionV1.shouldGateStartNowToReview,
      nextPackId: normalizedNextPackId,
      activePackId: _campaignActivePackId,
      nextHandIndex: _campaignNextHandIndexV1,
    );
  }
}

class World1LadderProgressBar extends StatelessWidget {
  const World1LadderProgressBar({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.hintLabel,
  });

  final int completedCount;
  final int totalCount;
  final String? hintLabel;

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalCount <= 0 ? 1 : totalCount;
    final progress = (completedCount / safeTotal).clamp(0.0, 1.0);
    final label = 'Foundations $completedCount / $safeTotal';
    return Semantics(
      key: const Key('world1_ladder_semantics'),
      label: 'World1 ladder progress, $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hintLabel != null && hintLabel!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              hintLabel!,
              key: const Key('world1_ladder_hint_label'),
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 6),
          SizedBox(
            width: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                key: const Key('world1_ladder_progress_bar'),
                height: 8,
                child: Stack(
                  children: [
                    Container(color: SharkyTokensV1.slate600.withOpacity(0.5)),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(color: SharkyTokensV1.brandPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineLessonPathPainterV1 extends CustomPainter {
  _InlineLessonPathPainterV1({
    required this.centers,
    required this.baseColor,
    required this.glowColor,
  });

  final List<Offset> centers;
  final Color baseColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < centers.length; i++) {
      final start = centers[i - 1];
      final end = centers[i];
      final cp1 = Offset(start.dx, start.dy + (end.dy - start.dy) * 0.36);
      final cp2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.64);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, basePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InlineLessonPathPainterV1 oldDelegate) {
    return oldDelegate.centers != centers ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.glowColor != glowColor;
  }
}

Widget _infoChip(String label, {VoidCallback? onTap, Key? key}) {
  final child = Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
    decoration: BoxDecoration(
      color: SharkyTokensV1.surfaceCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: SharkyTokensV1.slate500.withOpacity(0.35)),
    ),
    child: Text(
      label,
      style: AppTypography.caption.copyWith(
        color: SharkyTokensV1.textPrimary,
        fontSize: 12,
      ),
    ),
  );
  if (onTap == null) return child;
  return InkWell(
    key: key,
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: child,
  );
}

class _MapNode extends StatelessWidget {
  final Key? nodeTapKey;
  final Key semanticsKey;
  final Map<String, dynamic> moduleData;
  final _World1NodeVisualState visualState;
  final VoidCallback onRefresh;
  final int levelIndex;
  final double pulseScale;
  final bool showFoundationsEntry;
  final bool foundationsEntryEnabled;
  final bool showDailyRunCta;
  final bool dailyRunEnabled;
  final VoidCallback onOpenFoundationsCheck;
  final VoidCallback onOpenDailyRun;
  final String dailyRunPrimaryLabel;
  final String dailyRunSubtitleLabel;
  final String todayChipPrimaryLabel;
  final String todayChipStateLabel;
  final bool compactTodayCopy;

  const _MapNode({
    this.nodeTapKey,
    required this.semanticsKey,
    required this.moduleData,
    required this.visualState,
    required this.onRefresh,
    required this.levelIndex,
    required this.pulseScale,
    required this.showFoundationsEntry,
    required this.foundationsEntryEnabled,
    required this.showDailyRunCta,
    required this.dailyRunEnabled,
    required this.onOpenFoundationsCheck,
    required this.onOpenDailyRun,
    required this.dailyRunPrimaryLabel,
    required this.dailyRunSubtitleLabel,
    required this.todayChipPrimaryLabel,
    required this.todayChipStateLabel,
    required this.compactTodayCopy,
  });

  @override
  Widget build(BuildContext context) {
    final title = (moduleData['title'] ?? moduleData['name'] ?? 'Untitled')
        .toString();
    final isAvailable = moduleData['isAvailable'] as bool? ?? true;
    final isUnlocked = moduleData['isUnlocked'] as bool? ?? false;
    final nodeStyle = _resolveNodeStyle(visualState);
    final stateLabel = _stateLabel(visualState);
    final tapEnabled = isUnlocked && isAvailable;
    final moduleId = (moduleData['id'] ?? '').toString();
    final semanticsLabel =
        'Level L$levelIndex, $title, ${_semanticStateLabel(visualState)}';
    final semanticsHint = tapEnabled ? 'double tap to open' : '';

    return Semantics(
      key: semanticsKey,
      label: semanticsLabel,
      hint: semanticsHint.isEmpty ? null : semanticsHint,
      button: tapEnabled,
      enabled: tapEnabled,
      child: GestureDetector(
        onTap: tapEnabled
            ? () async {
                UiSoundV1.fire(UiSoundEventV1.tap);
                if (visualState == _World1NodeVisualState.current &&
                    foundationsEntryEnabled) {
                  unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
                  onOpenFoundationsCheck();
                  return;
                }
                try {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ModuleSummaryScreen(moduleData: moduleData),
                    ),
                  );
                } catch (error, stack) {
                  debugPrint('Map node navigation failed: $error');
                  debugPrint(stack.toString());
                }
                onRefresh();
              }
            : null,
        child: RepaintBoundary(
          child: Transform.scale(
            scale: pulseScale,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hideSecondaryActions = constraints.maxWidth < 190;
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Container(
                    key: visualState == _World1NodeVisualState.current
                        ? const Key('world1_focus_current_node')
                        : null,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: nodeStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: nodeStyle.borderColor,
                        width: nodeStyle.borderWidth,
                      ),
                      boxShadow: nodeStyle.shadow,
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LevelTag(
                              label: 'L$levelIndex',
                              textColor: nodeStyle.tagTextColor,
                              borderColor: nodeStyle.tagBorderColor,
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              nodeStyle.icon,
                              size: 26,
                              color: nodeStyle.iconColor,
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                key: nodeTapKey,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: nodeStyle.titleStyle.copyWith(
                                  height: 1.08,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                stateLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                key:
                                    visualState ==
                                        _World1NodeVisualState.current
                                    ? const ValueKey<String>(
                                        'world1_state_current',
                                      )
                                    : null,
                                style: nodeStyle.subtitleStyle.copyWith(
                                  height: 1.04,
                                ),
                              ),
                              if (!hideSecondaryActions &&
                                  visualState == _World1NodeVisualState.current)
                                const SizedBox(height: 2),
                              if (!hideSecondaryActions &&
                                  visualState == _World1NodeVisualState.current)
                                Text(
                                  'IN PROGRESS',
                                  key: Key('world1_node_in_progress_$moduleId'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: SharkyTokensV1.brandGlow,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.5,
                                    letterSpacing: 0.35,
                                  ),
                                ),
                              if (!hideSecondaryActions &&
                                  showFoundationsEntry) ...[
                                const SizedBox(height: 3),
                                Container(
                                  key: Key(
                                    foundationsEntryEnabled
                                        ? 'world1_today_chip_$moduleId'
                                        : 'world1_today_chip_disabled_$moduleId',
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Semantics(
                                    key: Key(
                                      'world1_foundations_entry_semantics_$moduleId',
                                    ),
                                    label:
                                        'World1 foundations entry for $moduleId',
                                    value: foundationsEntryEnabled
                                        ? todayChipStateLabel
                                        : 'Locked',
                                    hint: foundationsEntryEnabled
                                        ? 'double tap to open foundations check'
                                        : 'unavailable',
                                    button: true,
                                    enabled: foundationsEntryEnabled,
                                    child: SizedBox(
                                      height: 44,
                                      child: OutlinedButton(
                                        key: Key(
                                          foundationsEntryEnabled
                                              ? 'world1_foundations_entry_$moduleId'
                                              : 'world1_foundations_entry_disabled_$moduleId',
                                        ),
                                        onPressed: foundationsEntryEnabled
                                            ? () {
                                                unawaited(
                                                  UiHapticsV1.fire(
                                                    UiHapticEventV1.success,
                                                  ),
                                                );
                                                onOpenFoundationsCheck();
                                              }
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                          minimumSize: const Size(44, 44),
                                          side: BorderSide(
                                            color: foundationsEntryEnabled
                                                ? SharkyTokensV1.brandPrimary
                                                : SharkyTokensV1.slate600,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                foundationsEntryEnabled
                                                    ? (compactTodayCopy
                                                          ? 'Today'
                                                          : todayChipPrimaryLabel)
                                                    : 'Today unavailable',
                                                key: const Key(
                                                  'world1_today_chip_label',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      color:
                                                          foundationsEntryEnabled
                                                          ? SharkyTokensV1
                                                                .textPrimary
                                                          : SharkyTokensV1
                                                                .textMuted,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 9.8,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              foundationsEntryEnabled
                                                  ? (compactTodayCopy
                                                        ? (todayChipStateLabel ==
                                                                  'Completed Today'
                                                              ? 'Done'
                                                              : 'Ready')
                                                        : todayChipStateLabel)
                                                  : 'Locked',
                                              key: const Key(
                                                'world1_today_chip_state',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color:
                                                        foundationsEntryEnabled
                                                        ? SharkyTokensV1
                                                              .brandGlow
                                                        : SharkyTokensV1
                                                              .textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 9,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (showDailyRunCta) ...[
                                  const SizedBox(height: 3),
                                  Semantics(
                                    key: Key(
                                      'world1_daily_run_cta_semantics_$moduleId',
                                    ),
                                    label: 'World1 daily run for $moduleId',
                                    value: dailyRunEnabled
                                        ? 'available'
                                        : 'locked',
                                    hint: dailyRunEnabled
                                        ? 'double tap to start daily run'
                                        : 'unavailable',
                                    button: true,
                                    enabled: dailyRunEnabled,
                                    child: SizedBox(
                                      height: 44,
                                      child: OutlinedButton(
                                        key: Key(
                                          dailyRunEnabled
                                              ? 'world1_daily_run_cta_$moduleId'
                                              : 'world1_daily_run_cta_disabled_$moduleId',
                                        ),
                                        onPressed: dailyRunEnabled
                                            ? () {
                                                unawaited(
                                                  UiHapticsV1.fire(
                                                    UiHapticEventV1.success,
                                                  ),
                                                );
                                                onOpenDailyRun();
                                              }
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                          minimumSize: const Size(44, 44),
                                          side: BorderSide(
                                            color: dailyRunEnabled
                                                ? SharkyTokensV1.semanticWin
                                                : SharkyTokensV1.slate600,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          compactTodayCopy
                                              ? 'Run · +15 XP'
                                              : '$dailyRunPrimaryLabel · $dailyRunSubtitleLabel',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption.copyWith(
                                            color: dailyRunEnabled
                                                ? SharkyTokensV1.textPrimary
                                                : SharkyTokensV1.textMuted,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 9.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> _buildCheckpointMarkers({
  required List<Offset> points,
  required List<Map<String, dynamic>> nodes,
  required double width,
  required double nodeWidth,
  required Future<void> Function({
    required int checkpointId,
    required String anchorModuleId,
  })
  onOpenCheckpoint,
}) {
  final markers = <Widget>[];
  final l3Id = kWorld1CanonicalModuleOrder[2];
  final l6Id = kWorld1CanonicalModuleOrder[5];
  final l3Completed =
      (nodes.cast<Map<String, dynamic>?>().firstWhere(
            (node) => (node?['id'] ?? '').toString() == l3Id,
            orElse: () => null,
          )?['isCompleted']
          as bool?) ??
      false;
  final l6Completed =
      (nodes.cast<Map<String, dynamic>?>().firstWhere(
            (node) => (node?['id'] ?? '').toString() == l6Id,
            orElse: () => null,
          )?['isCompleted']
          as bool?) ??
      false;
  if (points.length >= 4 && nodes.length >= 3) {
    final anchor = Offset(width / 2, (points[2].dy + points[3].dy) / 2);
    markers.add(
      _checkpointMarker(
        key: const Key('world1_checkpoint_3'),
        label: 'Checkpoint after L3',
        center: anchor,
        width: nodeWidth * 0.42,
        completed: l3Completed,
        openKey: const Key('world1_checkpoint_open_3'),
        disabledOpenKey: const Key('world1_checkpoint_open_disabled_3'),
        onOpen: () => onOpenCheckpoint(checkpointId: 3, anchorModuleId: l3Id),
      ),
    );
  }
  if (points.length >= 7 && nodes.length >= 6) {
    final anchor = Offset(width / 2, (points[5].dy + points[6].dy) / 2);
    markers.add(
      _checkpointMarker(
        key: const Key('world1_checkpoint_6'),
        label: 'Checkpoint after L6',
        center: anchor,
        width: nodeWidth * 0.42,
        completed: l6Completed,
        openKey: const Key('world1_checkpoint_open_6'),
        disabledOpenKey: const Key('world1_checkpoint_open_disabled_6'),
        onOpen: () => onOpenCheckpoint(checkpointId: 6, anchorModuleId: l6Id),
      ),
    );
  }
  return markers;
}

Widget _checkpointMarker({
  required Key key,
  required String label,
  required Offset center,
  required double width,
  required bool completed,
  required Key openKey,
  required Key disabledOpenKey,
  required VoidCallback onOpen,
}) {
  final markerWidth = width.clamp(112.0, 180.0);
  final isEnabled = completed;
  return Positioned(
    left: center.dx - markerWidth / 2,
    top: center.dy - 33,
    width: markerWidth,
    height: 66,
    child: Semantics(
      label: label,
      button: false,
      enabled: false,
      child: Column(
        children: [
          Container(
            key: key,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: completed
                  ? SharkyTokensV1.semanticWin.withOpacity(0.15)
                  : SharkyTokensV1.slate600.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: completed
                    ? SharkyTokensV1.semanticWin.withOpacity(0.8)
                    : SharkyTokensV1.slate600.withOpacity(0.85),
              ),
            ),
            child: Text(
              completed ? 'CHECKPOINT CLEARED' : 'CHECKPOINT LOCKED',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: completed
                    ? SharkyTokensV1.semanticWin
                    : SharkyTokensV1.textMuted,
                fontSize: 8.8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 44,
            width: markerWidth,
            child: OutlinedButton(
              key: isEnabled ? openKey : disabledOpenKey,
              onPressed: isEnabled ? onOpen : null,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                side: BorderSide(
                  color: isEnabled
                      ? SharkyTokensV1.brandPrimary.withOpacity(0.8)
                      : SharkyTokensV1.slate600.withOpacity(0.7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                isEnabled ? 'OPEN SESSION' : 'LOCKED',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: isEnabled
                      ? SharkyTokensV1.textPrimary
                      : SharkyTokensV1.textMuted,
                  fontSize: 8.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String world1LadderHintLabel(int completedCount, {bool compact = false}) {
  if (completedCount < 3) {
    return compact ? 'Next CP L3' : 'Next checkpoint L3';
  }
  if (completedCount < 6) {
    return compact ? 'Next CP L6' : 'Next checkpoint L6';
  }
  if (completedCount < 7) {
    return compact ? 'Final stretch' : 'Final stretch to L7';
  }
  return compact ? 'All clear' : 'All checkpoints cleared';
}

class _LevelTag extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color borderColor;

  const _LevelTag({
    required this.label,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: textColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FutureBranchPlaceholder extends StatelessWidget {
  const _FutureBranchPlaceholder({
    super.key,
    required this.label,
    required this.requirementLabel,
    this.isLocked = true,
    this.requirementKey,
    this.onTap,
  });

  final String label;
  final String requirementLabel;
  final bool isLocked;
  final Key? requirementKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isLocked
        ? SharkyTokensV1.textMuted
        : SharkyTokensV1.brandGlow;
    final titleColor = isLocked
        ? SharkyTokensV1.textMuted
        : SharkyTokensV1.textPrimary;
    final titleLabel = isLocked ? '$label (Locked)' : '$label (Unlocked)';
    return Semantics(
      label: '$label branch ${isLocked ? 'locked' : 'unlocked'}',
      button: onTap != null,
      enabled: !isLocked,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isLocked
                ? SharkyTokensV1.slate600.withOpacity(0.14)
                : SharkyTokensV1.surfaceCard.withOpacity(0.24),
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
            border: Border.all(
              color: isLocked
                  ? SharkyTokensV1.slate600.withOpacity(0.8)
                  : SharkyTokensV1.brandPrimary.withOpacity(0.65),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_outline : Icons.check_circle_outline,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      requirementLabel,
                      key: requirementKey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _World1PathPainter extends CustomPainter {
  const _World1PathPainter({
    required this.points,
    required this.states,
    required this.motionPhase,
  });

  final List<Offset> points;
  final List<_World1NodeVisualState> states;
  final double motionPhase;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final style = _resolveConnectorStyle(
        states[i],
        states[i + 1],
        motionPhase,
      );
      final paint = Paint()
        ..color = style.color.withOpacity(style.opacity)
        ..strokeWidth = style.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final midY = (start.dy + end.dy) / 2;
      final bend = (end.dx - start.dx).abs() * 0.28;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx + bend, midY, end.dx - bend, midY, end.dx, end.dy);
      if (style.dashed) {
        const dashLength = 6.0;
        const gapLength = 6.0;
        for (final metric in path.computeMetrics()) {
          double distance = 0;
          while (distance < metric.length) {
            final next = math.min(distance + dashLength, metric.length);
            final dash = metric.extractPath(distance, next);
            canvas.drawPath(dash, paint);
            distance = next + gapLength;
          }
        }
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _World1PathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.states != states ||
        oldDelegate.motionPhase != motionPhase;
  }
}

enum _World1NodeVisualState { locked, unlocked, completed, current, missing }

class _NodeVisualStyle {
  const _NodeVisualStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.icon,
    required this.iconColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.tagTextColor,
    required this.tagBorderColor,
    required this.shadow,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final IconData icon;
  final Color iconColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final Color tagTextColor;
  final Color tagBorderColor;
  final List<BoxShadow> shadow;
}

class _ConnectorStyle {
  const _ConnectorStyle({
    required this.color,
    required this.strokeWidth,
    required this.opacity,
    required this.dashed,
  });

  final Color color;
  final double strokeWidth;
  final double opacity;
  final bool dashed;
}

_World1NodeVisualState _resolveWorld1VisualState({
  required Map<String, dynamic> node,
  required bool isCurrent,
}) {
  final available = node['isAvailable'] as bool? ?? true;
  final unlocked = node['isUnlocked'] as bool? ?? false;
  final completed = node['isCompleted'] as bool? ?? false;
  if (!available) return _World1NodeVisualState.missing;
  if (completed) return _World1NodeVisualState.completed;
  if (isCurrent) return _World1NodeVisualState.current;
  if (unlocked) return _World1NodeVisualState.unlocked;
  return _World1NodeVisualState.locked;
}

_NodeVisualStyle _resolveNodeStyle(_World1NodeVisualState state) {
  switch (state) {
    case _World1NodeVisualState.completed:
      return _NodeVisualStyle(
        backgroundColor: SharkyTokensV1.semanticWin.withOpacity(0.16),
        borderColor: SharkyTokensV1.semanticWin.withOpacity(0.9),
        borderWidth: 2.0,
        icon: Icons.check_circle,
        iconColor: SharkyTokensV1.semanticWin,
        titleStyle: AppTypography.h3.copyWith(
          color: SharkyTokensV1.textPrimary,
        ),
        subtitleStyle: AppTypography.caption.copyWith(
          color: SharkyTokensV1.semanticWin,
        ),
        tagTextColor: SharkyTokensV1.textPrimary,
        tagBorderColor: SharkyTokensV1.semanticWin.withOpacity(0.8),
        shadow: SharkyTokensV1.elevation1,
      );
    case _World1NodeVisualState.current:
      return _NodeVisualStyle(
        backgroundColor: SharkyTokensV1.brandPrimary.withOpacity(0.16),
        borderColor: SharkyTokensV1.brandPrimary,
        borderWidth: 2.2,
        icon: Icons.play_circle_fill,
        iconColor: SharkyTokensV1.brandPrimary,
        titleStyle: AppTypography.h3.copyWith(
          color: SharkyTokensV1.textPrimary,
        ),
        subtitleStyle: AppTypography.caption.copyWith(
          color: SharkyTokensV1.brandGlow,
        ),
        tagTextColor: SharkyTokensV1.textPrimary,
        tagBorderColor: SharkyTokensV1.brandPrimary.withOpacity(0.95),
        shadow: SharkyTokensV1.elevation2,
      );
    case _World1NodeVisualState.unlocked:
      return _NodeVisualStyle(
        backgroundColor: SharkyTokensV1.surfaceCard.withOpacity(0.9),
        borderColor: SharkyTokensV1.brandPrimary.withOpacity(0.7),
        borderWidth: 1.8,
        icon: Icons.radio_button_checked,
        iconColor: SharkyTokensV1.brandPrimary,
        titleStyle: AppTypography.h3.copyWith(
          color: SharkyTokensV1.textPrimary,
        ),
        subtitleStyle: AppTypography.caption.copyWith(
          color: SharkyTokensV1.textSecondary,
        ),
        tagTextColor: SharkyTokensV1.textPrimary,
        tagBorderColor: SharkyTokensV1.slate500.withOpacity(0.75),
        shadow: SharkyTokensV1.elevation1,
      );
    case _World1NodeVisualState.missing:
      return _NodeVisualStyle(
        backgroundColor: SharkyTokensV1.slate600.withOpacity(0.15),
        borderColor: SharkyTokensV1.slate600.withOpacity(0.9),
        borderWidth: 1.4,
        icon: Icons.block,
        iconColor: SharkyTokensV1.slate500,
        titleStyle: AppTypography.h3.copyWith(color: SharkyTokensV1.textMuted),
        subtitleStyle: AppTypography.caption.copyWith(
          color: SharkyTokensV1.textMuted,
        ),
        tagTextColor: SharkyTokensV1.textMuted,
        tagBorderColor: SharkyTokensV1.slate600.withOpacity(0.7),
        shadow: const <BoxShadow>[],
      );
    case _World1NodeVisualState.locked:
      return _NodeVisualStyle(
        backgroundColor: SharkyTokensV1.slate600.withOpacity(0.12),
        borderColor: SharkyTokensV1.slate600.withOpacity(0.85),
        borderWidth: 1.4,
        icon: Icons.lock,
        iconColor: SharkyTokensV1.slate500,
        titleStyle: AppTypography.h3.copyWith(
          color: SharkyTokensV1.textSecondary,
        ),
        subtitleStyle: AppTypography.caption.copyWith(
          color: SharkyTokensV1.textMuted,
        ),
        tagTextColor: SharkyTokensV1.textSecondary,
        tagBorderColor: SharkyTokensV1.slate600.withOpacity(0.75),
        shadow: const <BoxShadow>[],
      );
  }
}

_ConnectorStyle _resolveConnectorStyle(
  _World1NodeVisualState start,
  _World1NodeVisualState end,
  double motionPhase,
) {
  if (start == _World1NodeVisualState.completed &&
      (end == _World1NodeVisualState.completed ||
          end == _World1NodeVisualState.current ||
          end == _World1NodeVisualState.unlocked)) {
    return const _ConnectorStyle(
      color: SharkyTokensV1.emerald500,
      strokeWidth: 3,
      opacity: 0.95,
      dashed: false,
    );
  }
  if (end == _World1NodeVisualState.current ||
      end == _World1NodeVisualState.unlocked) {
    return _ConnectorStyle(
      color: SharkyTokensV1.brandPrimary,
      strokeWidth: 2.6,
      opacity: 0.8 + (0.18 * motionPhase),
      dashed: false,
    );
  }
  return const _ConnectorStyle(
    color: SharkyTokensV1.slate600,
    strokeWidth: 2,
    opacity: 0.42,
    dashed: true,
  );
}

String _stateLabel(_World1NodeVisualState state) {
  switch (state) {
    case _World1NodeVisualState.completed:
      return 'Completed';
    case _World1NodeVisualState.current:
      return 'Current';
    case _World1NodeVisualState.unlocked:
      return 'Unlocked';
    case _World1NodeVisualState.missing:
      return 'Locked';
    case _World1NodeVisualState.locked:
      return 'Locked';
  }
}

String _semanticStateLabel(_World1NodeVisualState state) {
  switch (state) {
    case _World1NodeVisualState.completed:
      return 'completed';
    case _World1NodeVisualState.current:
      return 'current';
    case _World1NodeVisualState.unlocked:
      return 'unlocked';
    case _World1NodeVisualState.missing:
      return 'missing';
    case _World1NodeVisualState.locked:
      return 'locked';
  }
}

Map<_NodeState, int> _nodeStateCounts(List<Map<String, dynamic>> nodes) {
  final counts = <_NodeState, int>{
    for (final state in _NodeState.values) state: 0,
  };
  for (final node in nodes) {
    final state = _nodeState(
      node['isUnlocked'] as bool? ?? false,
      node['isCompleted'] as bool? ?? false,
    );
    counts[state] = counts[state]! + 1;
  }
  return counts;
}

enum _NodeState { completed, active, locked }

_NodeState _nodeState(bool isUnlocked, bool isCompleted) {
  if (isCompleted) return _NodeState.completed;
  if (isUnlocked) return _NodeState.active;
  return _NodeState.locked;
}

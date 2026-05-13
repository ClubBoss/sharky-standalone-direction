import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/canonical/canonical_landing_decision_v1.dart';
import 'package:poker_analyzer/canonical/first_session_trust_contract_v1.dart';
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/infra/telemetry_builder.dart';
import 'package:poker_analyzer/personalization/focus_recommendation_router_v1.dart';
import 'package:poker_analyzer/personalization/learner_journey_cta_v1.dart';
import 'package:poker_analyzer/personalization/learning_continuation_v1.dart';
import 'package:poker_analyzer/personalization/mastery_progress_contract_v1.dart';
import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_signal_store_v1.dart';
import 'package:poker_analyzer/personalization/recent_top_mistake_utility_v1.dart';
import 'package:poker_analyzer/personalization/recovery_readiness_contract_v1.dart';
import 'package:poker_analyzer/personalization/season1_summary_v1.dart';
import 'package:poker_analyzer/personalization/skill_tags_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:poker_analyzer/services/chips_ledger_v1.dart';
import 'package:poker_analyzer/services/learning_track_recommendation_engine.dart';
import 'package:poker_analyzer/services/learning_stats_v1_service.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:poker_analyzer/services/session_log_service.dart';
import 'package:poker_analyzer/services/tag_mastery_service.dart';
import 'package:poker_analyzer/services/track_mastery_service.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_bottom_action_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_completion_surface_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';
import 'package:poker_analyzer/ui_v2/widgets/next_action_strip_v1.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stub: progress map screen was archived. Navigate to canonical Act0 root.
Route<void> progressMapRouteV1({
  bool autoOpenReviewQueueForNextPackV1 = false,
}) {
  return MaterialPageRoute<void>(
    builder: (_) => const Act0ShellPreviewScreenV1(showPlacementOnStart: false),
  );
}

Route<T> sessionResultRouteV1<T>({
  required int correctCount,
  required int totalCount,
  required String moduleId,
  int? campaignSessionDelta,
  OutcomeSummaryV1? campaignOutcomeSummary,
  String? campaignPersonalizationHint,
  PersonalizedRecommendationV1? personalizationResultV1,
}) {
  return MaterialPageRoute<T>(
    builder: (_) => SessionResultScreen(
      correctCount: correctCount,
      totalCount: totalCount,
      moduleId: moduleId,
      campaignSessionDelta: campaignSessionDelta,
      campaignOutcomeSummary: campaignOutcomeSummary,
      campaignPersonalizationHint: campaignPersonalizationHint,
      personalizationResultV1: personalizationResultV1,
    ),
  );
}

Future<T?> pushReplacementSessionResultV1<T, TO>(
  BuildContext context, {
  required int correctCount,
  required int totalCount,
  required String moduleId,
  int? campaignSessionDelta,
  OutcomeSummaryV1? campaignOutcomeSummary,
  String? campaignPersonalizationHint,
  PersonalizedRecommendationV1? personalizationResultV1,
}) async {
  if (!context.mounted) return null;
  return Navigator.of(context).pushReplacement<T, TO>(
    sessionResultRouteV1<T>(
      correctCount: correctCount,
      totalCount: totalCount,
      moduleId: moduleId,
      campaignSessionDelta: campaignSessionDelta,
      campaignOutcomeSummary: campaignOutcomeSummary,
      campaignPersonalizationHint: campaignPersonalizationHint,
      personalizationResultV1: personalizationResultV1,
    ),
  );
}

class SessionResultScreen extends StatefulWidget {
  final int correctCount;
  final int totalCount;
  final String moduleId;
  final int? campaignSessionDelta;
  final OutcomeSummaryV1? campaignOutcomeSummary;
  final String? campaignPersonalizationHint;
  final PersonalizedRecommendationV1? personalizationResultV1;

  const SessionResultScreen({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.moduleId,
    this.campaignSessionDelta,
    this.campaignOutcomeSummary,
    this.campaignPersonalizationHint,
    this.personalizationResultV1,
  });

  @override
  State<SessionResultScreen> createState() => _SessionResultScreenState();
}

class _SessionResultScreenState extends State<SessionResultScreen> {
  static const Set<String> _campaignSpineModuleIds = <String>{
    'world1_spine_campaign_v1',
    'world10_spine_campaign_v1',
  };
  static const World10TrackRecommendationV1
  _fallbackWorld10TrackRecommendationV1 = World10TrackRecommendationV1(
    choiceId: ProgressService.world10TrackChoiceTournamentV1,
    label: 'Tournament',
    reason:
        'Tournament pressure and survival tradeoffs look like the weakest '
        'current fit signal. Mastery 0%.',
  );
  Map<String, dynamic>? _nextModuleData;
  String? _focusLabel;
  String _spineRankLabel = 'Fish';
  String _campaignRankLabel = 'Tadpole';
  String _campaignRankHint = '';
  int _campaignCompletedHands = 0;
  int _campaignTotalHands = 0;
  String _campaignSegmentLabel = 'Campaign';
  int _campaignBankroll = ProgressService.bankrollCap;
  bool _campaignComplete = false;
  bool _showShareActions = false;
  FocusRecommendationV1? _focusRecommendation;
  bool _focusRecommendationImpressionLogged = false;
  bool _hasReviewQueueForPack = false;
  WorldMasteryV1? _worldMastery;
  LatestSessionOutcomeSnapshotV1? _latestSessionSnapshotV1;
  List<String> _skillTagsV1 = const <String>[];
  int _chipsEarnedThisResultV1 = 0;
  int _chipsSpentDisplayV1 = 0;
  int _chipsBalanceV1 = 0;
  bool _chipsLowBalanceNoteV1 = false;
  Season1SummaryV1? _season1SummaryV1;
  String _identityPhraseTextV1 = '';
  bool _showTableContextV1 = false;
  bool _checkpointPendingHintV1 = false;
  World10TrackRecommendationV1? _world10TrackRecommendationV1;
  String? _spineContinuationPackIdV1;
  ProgressionRouteStoryV1? _spineContinuationRouteStoryV1;
  ProgressionRouteStoryV1? _spineHandoffRouteStoryV1;
  PersonalizedRecommendationV1? _effectivePersonalizationResultV1;
  WeaknessConfidenceAssessmentV1? _weaknessConfidenceAssessmentV1;
  List<RecentTelemetrySignalV1> _recentSignalsV1 =
      const <RecentTelemetrySignalV1>[];
  bool _firstSessionAhaImpressionLoggedV1 = false;

  PersonalizedRecommendationV1? get _activePersonalizationResultV1 =>
      _effectivePersonalizationResultV1 ?? widget.personalizationResultV1;

  String _worldIdForCheckpointV1() {
    final match = RegExp(
      r'^w(\d+)\.s\d+$',
    ).firstMatch(widget.moduleId.trim().toLowerCase());
    final sessionWorld = int.tryParse(match?.group(1) ?? '');
    if (sessionWorld != null && sessionWorld > 0) {
      return 'world$sessionWorld';
    }
    final packWorld = ProgressService.worldIndexForPackIdV1(widget.moduleId);
    return 'world$packWorld';
  }

  List<String> _sessionErrorClassesForCheckpointV1() {
    if (widget.correctCount >= widget.totalCount) {
      return const <String>[];
    }
    final errorType = widget.campaignOutcomeSummary?.errorType
        ?.trim()
        .toLowerCase();
    if (errorType != null && errorType.isNotEmpty && errorType != 'none') {
      return <String>[errorType];
    }
    return const <String>['session_mistake'];
  }

  bool get _isCampaignSpineSession =>
      _campaignSpineModuleIds.contains(widget.moduleId);
  bool get _isSpinePackSession =>
      ProgressService.campaignPackIdsV1.contains(widget.moduleId) ||
      widget.moduleId.trim().toLowerCase() ==
          ProgressService.checkpointPackIdV1;
  bool get _isFinalSeason1CheckpointSession =>
      widget.moduleId == 'season1_checkpoint_w7_10_v1';

  String? _personalizedFocusLabelV1() {
    final focus = _activePersonalizationResultV1?.recommendedFocusId
        .trim()
        .toLowerCase();
    if (focus == null || focus.isEmpty) return null;
    return focus;
  }

  String? _personalizedHintTextV1() {
    final hint = _activePersonalizationResultV1?.shortHintText.trim();
    if (hint != null && hint.isNotEmpty) {
      return hint;
    }
    final legacyHint = widget.campaignPersonalizationHint?.trim();
    if (legacyHint != null && legacyHint.isNotEmpty) {
      return legacyHint;
    }
    return null;
  }

  LearningContinuationV1? _sharedContinuationV1() {
    return LearningContinuationFactoryV1.fromPersonalizedRecommendation(
      recommendation: _activePersonalizationResultV1,
      resolveModuleTitle: recommendedLearningModuleTitleForId,
      recentSignals: _recentSignalsV1,
    );
  }

  String? _framedRecommendationReasonV1(FocusRecommendationV1 recommendation) {
    final reason = recommendation.reason.trim();
    if (reason.isEmpty) return null;
    switch (recommendation.kind) {
      case FocusRecommendationKindV1.reviewFocus:
      case FocusRecommendationKindV1.backToMap:
        return 'Back to map: $reason';
      case FocusRecommendationKindV1.repeatPack:
      case FocusRecommendationKindV1.continueCampaign:
      case FocusRecommendationKindV1.nextModule:
      case FocusRecommendationKindV1.none:
        return reason;
    }
  }

  void _logFirstSessionAhaImpressionIfNeededV1(
    FirstSessionAhaContractV1 contract,
  ) {
    if (_firstSessionAhaImpressionLoggedV1) {
      return;
    }
    _firstSessionAhaImpressionLoggedV1 = true;
    unawaited(
      Telemetry.logEvent(
        TelemetryEvents.firstSessionAhaImpressionV1,
        <String, dynamic>{
          'module_id': widget.moduleId,
          'surface': 'session_result',
          'primary_cta': 'session_result_next_module_cta',
          'why_line': contract.realTableWhyLine,
          'sharky_line': contract.sharkyLine,
        },
      ),
    );
  }

  Future<void> _openNextSpinePackV1() async {
    final chipsSpend = await ProgressService.spendChipsForSessionStartV1();
    await Telemetry.logEvent(TelemetryEvents.chipsSpentV1, <String, dynamic>{
      'amount': chipsSpend.appliedAmount,
      'reason': 'session_start',
      'balance_after': chipsSpend.after.balance,
      'bankrupt': chipsSpend.insufficientFunds,
    });
    final nextPackId = await ProgressService.getNextPackConsideringCheckpointV1(
      widget.moduleId,
    );
    if (nextPackId.trim().isEmpty || !context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted =
        prefs.getBool('onboardingCompleted') ?? _isSpinePackSession;
    final intakeCompleted =
        await ProgressService.isIntakeCompleted() || _isSpinePackSession;
    final checkpointState =
        await ProgressService.getCheckpointProgressStateV1();
    final activePackId = await ProgressService.getSpineActivePackIdV1();
    final nextHandIndex = await ProgressService.getSpineNextHandIndexV1();
    final landingDecision = await resolveCanonicalLandingDecisionV1(
      CanonicalLandingDecisionInputsV1(
        onboardingCompleted: onboardingCompleted,
        intakeCompleted: intakeCompleted,
        campaignComplete: await ProgressService.isCampaignCompleteV1(),
        checkpointPending: checkpointState.checkpointPending,
        nextPackId: nextPackId,
        canonicalEntryPackId: nextPackId,
        hasReviewQueueForCanonicalEntryPack:
            await ProgressService.hasReviewQueueForPackV1(nextPackId),
        activePackId: activePackId ?? '',
        currentPackId: widget.moduleId,
        nextHandIndex: nextHandIndex,
        source: CanonicalLandingSourceV1.resultContinue,
      ),
    );
    if (!context.mounted) return;
    if (landingDecision.entryId.trim().isEmpty) return;
    if (landingDecision.surfaceKind ==
        CanonicalLandingSurfaceKindV1.directSessionLaunch) {
      final handoffContext = buildProgressionHandoffContextForPackV1(
        nextPackId,
      );
      await Navigator.of(context).pushReplacement<void, void>(
        canonicalSessionDrillRouteV1(
          sessionId: landingDecision.entryId,
          handoffContextV1: handoffContext,
        ),
      );
      return;
    }
    await pushReplacementWorld1FoundationsRunnerV1<void, void>(
      context,
      moduleId: landingDecision.entryId,
      moduleTitle: 'Next Module',
      mode: landingDecision.runnerMode ?? kWorld1RunnerModeCampaignSpine,
      startHandIndex: landingDecision.startHandIndex,
    );
  }

  Future<void> _launchSharedContinuationV1(
    LearningContinuationV1 continuation,
  ) async {
    final canonicalEntryId = continuation.targetEntryId.trim();
    if (canonicalEntryId.isEmpty || !context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted =
        prefs.getBool('onboardingCompleted') ?? _isSpinePackSession;
    final intakeCompleted =
        await ProgressService.isIntakeCompleted() || _isSpinePackSession;
    final checkpointState =
        await ProgressService.getCheckpointProgressStateV1();
    final activePackId = await ProgressService.getSpineActivePackIdV1();
    final nextHandIndex = await ProgressService.getSpineNextHandIndexV1();
    final landingDecision = await resolveCanonicalLandingDecisionV1(
      CanonicalLandingDecisionInputsV1(
        onboardingCompleted: onboardingCompleted,
        intakeCompleted: intakeCompleted,
        campaignComplete: await ProgressService.isCampaignCompleteV1(),
        checkpointPending: checkpointState.checkpointPending,
        nextPackId: canonicalEntryId,
        canonicalEntryPackId: canonicalEntryId,
        hasReviewQueueForCanonicalEntryPack: false,
        activePackId: activePackId ?? '',
        currentPackId: widget.moduleId,
        nextHandIndex: nextHandIndex,
        source: CanonicalLandingSourceV1.resultContinue,
      ),
    );
    if (!context.mounted) return;
    final resolvedEntryId = landingDecision.entryId.trim();
    if (resolvedEntryId.isEmpty) return;
    final handoffContextV1 = LearningContinuationFactoryV1.buildHandoffContext(
      entryId: canonicalEntryId,
      continuation: continuation,
    );
    if (resolvedEntryId == actionOrderBtnLastModuleId) {
      await navigateToLearningModuleV1(
        context,
        resolvedEntryId,
        moduleTitle: recommendedLearningModuleTitleForId(resolvedEntryId),
        handoffContextV1: handoffContextV1,
      );
      return;
    }
    if (landingDecision.surfaceKind ==
        CanonicalLandingSurfaceKindV1.directSessionLaunch) {
      await Navigator.of(context).pushReplacement<void, void>(
        canonicalSessionDrillRouteV1(
          sessionId: resolvedEntryId,
          handoffContextV1: handoffContextV1,
        ),
      );
      return;
    }
    await pushReplacementWorld1FoundationsRunnerV1<void, void>(
      context,
      moduleId: resolvedEntryId,
      moduleTitle: recommendedLearningModuleTitleForId(resolvedEntryId),
      mode: landingDecision.runnerMode ?? kWorld1RunnerModeCampaignSpine,
      startHandIndex: landingDecision.startHandIndex,
      handoffContextV1: handoffContextV1,
    );
  }

  Future<void> _copySkillCard() async {
    final focus = (await ProgressService.getLessonFocusLabel()) ?? 'none';
    final reviewDue = focus == 'none'
        ? false
        : await ProgressService.isFocusReviewDue(focus);
    final nextModuleId = recommendedModuleIdForFocus(
      focusLabel: focus == 'none' ? null : focus,
      reviewDue: reviewDue,
    );
    final nextMode = reviewDue ? 'Review' : 'Next Session';
    final lines = <String>[
      'Poker Analyzer Skill Card',
      'date: ${ProgressService.todayYmd()}',
      'focus_label: $focus',
      'last_session: ${widget.correctCount}/${widget.totalCount}',
      'review_due: ${reviewDue ? 'yes' : 'no'}',
      'next: $nextMode -> $nextModuleId',
    ];
    final text = lines.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    await Telemetry.logEvent(TelemetryEvents.skillCardCopied, <String, dynamic>{
      'module_id': widget.moduleId,
      'focus_label': focus,
      'review_due': reviewDue,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Skill Card copied')));
  }

  Future<void> _copyDuelCode() async {
    final focus = (await ProgressService.getLessonFocusLabel()) ?? 'none';
    final reviewDue = focus == 'none'
        ? false
        : await ProgressService.isFocusReviewDue(focus);
    final nextModuleId = recommendedModuleIdForFocus(
      focusLabel: focus == 'none' ? null : focus,
      reviewDue: reviewDue,
    );
    final code = encodeDuelCodeV1(
      moduleId: nextModuleId,
      focusLabel: focus,
      stampYmdHour: formatYmdHour(ProgressService.nowUtc()),
    );
    await Clipboard.setData(ClipboardData(text: code));
    await Telemetry.logEvent(TelemetryEvents.duelCodeCopied, <String, dynamic>{
      'module_id': widget.moduleId,
      'focus_label': focus,
      'duel_target': nextModuleId,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Duel Code copied')));
  }

  String _nextModuleLabel() {
    if (_isCampaignSpineSession) {
      return 'Campaign hand set complete. Run the spine again to sharpen decisions.';
    }
    final module = _nextModuleData;
    final focusPrefix = _focusLabel == null
        ? ''
        : 'Recommended focus: $_focusLabel. ';
    if (module == null) {
      return '${focusPrefix}World1 complete. Coming next: Cash + MTT (locked)';
    }
    final title = (module['title'] ?? module['name'] ?? '').toString();
    final id = (module['id'] ?? '').toString();
    if (title.isNotEmpty && id.isNotEmpty) {
      return '${focusPrefix}Next module: $title ($id)';
    }
    if (title.isNotEmpty) {
      return '${focusPrefix}Next module: $title';
    }
    if (id.isNotEmpty) {
      return '${focusPrefix}Next module: $id';
    }
    return '${focusPrefix}Next step available';
  }

  @override
  void initState() {
    super.initState();
    _bootstrapResultState();
  }

  Future<void> _bootstrapResultState() async {
    final xpEarned = widget.correctCount * 10;
    if (!_isCampaignSpineSession) {
      try {
        await _updateFocusLabelFromOutcome();
      } catch (error) {
        debugPrint('SessionResultScreen focus label skipped: $error');
      }
      try {
        await ProgressService.addXp(xpEarned);
        await ProgressService.markModuleCompleted(widget.moduleId);
        await _applyBankrollRakebackOnce();
      } catch (error) {
        debugPrint('SessionResultScreen bootstrap skipped: $error');
      }
    }
    Map<String, dynamic>? next;
    try {
      next = await _resolveNextUnlockedModuleData();
    } catch (error) {
      debugPrint('SessionResultScreen next module resolution skipped: $error');
    }
    final focusLabel = _isCampaignSpineSession
        ? null
        : await ProgressService.getLessonFocusLabel();
    final focusReviewDue = (focusLabel == null || focusLabel.trim().isEmpty)
        ? false
        : await ProgressService.isFocusReviewDue(focusLabel);
    final learningStats = await LearningStatsV1Service.instance.load();
    final normalizedModuleId = widget.moduleId.trim().toLowerCase();
    final isCheckpointPackSession =
        normalizedModuleId == ProgressService.checkpointPackIdV1;
    if (_isSpinePackSession && !isCheckpointPackSession) {
      await ProgressService.recordSessionForCheckpointV1(
        sessionId: widget.moduleId,
        worldId: _worldIdForCheckpointV1(),
        errorClasses: _sessionErrorClassesForCheckpointV1(),
      );
    }
    final chipsEarnMutation =
        await ProgressService.earnChipsForSessionCompletionV1(
          isCheckpoint: widget.moduleId.toLowerCase().contains('checkpoint'),
        );
    if (chipsEarnMutation.appliedAmount > 0) {
      await Telemetry.logEvent(TelemetryEvents.chipsEarnedV1, <String, dynamic>{
        'amount': chipsEarnMutation.appliedAmount,
        'reason': widget.moduleId.toLowerCase().contains('checkpoint')
            ? 'checkpoint_complete'
            : 'session_complete',
        'balance_after': chipsEarnMutation.after.balance,
      });
    }
    final hasReviewQueueForPack = _isSpinePackSession
        ? await ProgressService.hasReviewQueueForPackV1(widget.moduleId)
        : false;
    final checkpointState = _isSpinePackSession
        ? await ProgressService.getCheckpointProgressStateV1()
        : const CheckpointProgressUpdateV1(
            completedSessionsSinceLastCheckpoint: 0,
            checkpointPending: false,
            topErrorClasses: <String>[],
          );
    final checkpointPendingHint =
        _isSpinePackSession &&
        checkpointState.checkpointPending &&
        !isCheckpointPackSession;
    String? spineContinuationPackId;
    ProgressionRouteStoryV1? spineContinuationRouteStory;
    ProgressionRouteStoryV1? spineHandoffRouteStory;
    if (_isSpinePackSession) {
      spineContinuationPackId =
          await ProgressService.getNextPackConsideringCheckpointV1(
            widget.moduleId,
          );
    }
    if (_isSpinePackSession &&
        (spineContinuationPackId?.trim().isNotEmpty ?? false)) {
      final activePackId = await ProgressService.getSpineActivePackIdV1();
      final nextHandIndex = activePackId == spineContinuationPackId
          ? await ProgressService.getSpineNextHandIndexV1()
          : 0;
      spineHandoffRouteStory = resolveProgressionRouteStoryForPackV1(
        nextPackId: spineContinuationPackId!,
        reviewRequired: hasReviewQueueForPack || checkpointPendingHint,
        activePackId: activePackId ?? '',
        nextHandIndex: nextHandIndex,
        rhythmReason: hasReviewQueueForPack
            ? 'Missed spots ready'
            : checkpointPendingHint
            ? 'Review required'
            : '',
      );
      if (!hasReviewQueueForPack &&
          spineHandoffRouteStory.target.isCrossFamilyRoute) {
        spineContinuationRouteStory = spineHandoffRouteStory;
      }
    }
    if (_isSpinePackSession) {
      await ProgressService.seedSkillTagsForPackFromRulesV1(widget.moduleId);
    }
    if (isCheckpointPackSession &&
        widget.totalCount > 0 &&
        widget.correctCount >= widget.totalCount) {
      await ProgressService.clearCheckpointPendingV1();
    }
    final skillTagsV1 = _isSpinePackSession
        ? await ProgressService.getSkillTagsForPackV1(widget.moduleId)
        : const <String>[];
    WorldMasteryV1? worldMastery;
    if (_isSpinePackSession) {
      final totalCount = widget.totalCount <= 0 ? 1 : widget.totalCount;
      final accuracyPercent = ((widget.correctCount * 100) / totalCount)
          .round()
          .clamp(0, 100);
      final mistakesCount = (widget.totalCount - widget.correctCount).clamp(
        0,
        1 << 30,
      );
      worldMastery = computeWorldMasteryV1(
        accuracyPercent: accuracyPercent,
        mistakesCount: mistakesCount,
        reviewCleared: !hasReviewQueueForPack,
      );
      await ProgressService.setWorldMasteryForPackV1(
        widget.moduleId,
        worldMastery.level,
      );
    }
    final personalizedFocusLabel = _personalizedFocusLabelV1();
    final recentSignals = await RecentActivitySignalStoreV1.instance
        .loadSignals();
    final mergedTopErrorBuckets = RecentTopMistakeUtilityV1.mergeTopBuckets(
      recentBuckets: RecentTopMistakeUtilityV1.deriveTopBuckets(recentSignals),
      fallbackBuckets: learningStats.topErrorBuckets(),
    );
    final latestSessionSnapshotV1 = LatestSessionOutcomeSnapshotV1(
      moduleId: widget.moduleId,
      correctCount: widget.correctCount,
      totalCount: widget.totalCount,
      isCampaignSession:
          widget.campaignOutcomeSummary != null ||
          widget.campaignSessionDelta != null ||
          _isCampaignSpineSession,
      outcomeKind: widget.campaignOutcomeSummary?.outcomeKind,
      errorType: widget.campaignOutcomeSummary?.errorType,
    );
    await ProgressionQualityGateV1.saveLatestSessionSnapshot(
      latestSessionSnapshotV1,
    );
    final progressionFitRecommendation = ProgressionQualityGateV1.apply(
      recommendation: widget.personalizationResultV1,
      latestSession: latestSessionSnapshotV1,
      recentSignals: recentSignals,
    );
    final persistedWeaknessHistory =
        await WeaknessConfidenceLayerV1.loadHistory();
    final effectiveWeaknessHistory = WeaknessConfidenceLayerV1.appendInMemory(
      history: persistedWeaknessHistory,
      recommendation: progressionFitRecommendation,
      latestSession: latestSessionSnapshotV1,
    );
    final weaknessConfidenceAssessmentV1 = WeaknessConfidenceLayerV1.assess(
      recommendation: progressionFitRecommendation,
      latestSession: latestSessionSnapshotV1,
      recentSignals: recentSignals,
      history: effectiveWeaknessHistory,
    );
    await WeaknessConfidenceLayerV1.saveHistory(effectiveWeaknessHistory);
    final effectivePersonalizationResultV1 = WeaknessConfidenceLayerV1.apply(
      recommendation: progressionFitRecommendation,
      latestSession: latestSessionSnapshotV1,
      recentSignals: recentSignals,
      history: effectiveWeaknessHistory,
    );
    final recommendation = FocusRecommendationRouterV1.route(
      FocusRecommendationInputsV1(
        isCampaignSession:
            widget.campaignOutcomeSummary != null ||
            widget.campaignSessionDelta != null ||
            _isCampaignSpineSession,
        focusReviewDue: focusReviewDue,
        focusLabel: personalizedFocusLabel ?? focusLabel,
        campaignOutcomeSummary: widget.campaignOutcomeSummary,
        campaignPersonalizationHint: widget.campaignPersonalizationHint,
        personalizationResultV1: effectivePersonalizationResultV1,
        topErrorBuckets: mergedTopErrorBuckets,
      ),
    );
    final spineRank = await ProgressService.getSpineRankV1();
    final campaignCompletedHands =
        await ProgressService.completedHandsInCampaignV1();
    final campaignTotalHands = await ProgressService.totalHandsInCampaignV1();
    final campaignSegmentLabel = await ProgressService.currentSegmentLabelV1();
    final campaignBankroll =
        await ProgressService.getCampaignBankrollBalanceV1();
    final campaignComplete = await ProgressService.isCampaignCompleteV1();
    final campaignRankLabel = await ProgressService.campaignRankLabelV1();
    final campaignRankHint =
        await ProgressService.campaignNextRankUnlockHintV1();
    Season1SummaryV1? season1Summary;
    if (_isFinalSeason1CheckpointSession) {
      final prefs = await SharedPreferences.getInstance();
      season1Summary = computeSeason1SummaryFromPrefsV1(prefs: prefs);
    }
    final identityPhrasePayload =
        await ProgressService.getEmotionPhraseTelemetryPayloadForContextV1(
          context: EmotionPhraseContextV1.identity,
        );
    final identityPhrase = (identityPhrasePayload['text'] ?? '')
        .toString()
        .trim();
    World10TrackRecommendationV1? world10TrackRecommendation;
    if (_isSpinePackSession && !isCheckpointPackSession) {
      final world10Completed =
          await ProgressService.isWorld10CalibrationCompletedV1();
      final alreadySeen = await ProgressService.isWorld10TrackChoiceSeenV1();
      if (world10Completed && !alreadySeen) {
        world10TrackRecommendation =
            await _resolveWorld10TrackRecommendationV1();
      }
    }
    if (!mounted) return;
    setState(() {
      _nextModuleData = _isCampaignSpineSession ? null : next;
      _focusLabel = _focusLabel ?? personalizedFocusLabel ?? focusLabel;
      _spineRankLabel = ProgressService.spineRankLabel(spineRank);
      _campaignCompletedHands = campaignCompletedHands;
      _campaignTotalHands = campaignTotalHands;
      _campaignSegmentLabel = campaignSegmentLabel;
      _campaignBankroll = campaignBankroll;
      _campaignComplete = campaignComplete;
      _campaignRankLabel = campaignRankLabel;
      _campaignRankHint = campaignRankHint;
      _focusRecommendation = recommendation;
      _effectivePersonalizationResultV1 = effectivePersonalizationResultV1;
      _weaknessConfidenceAssessmentV1 = weaknessConfidenceAssessmentV1;
      _latestSessionSnapshotV1 = latestSessionSnapshotV1;
      _recentSignalsV1 = recentSignals;
      _hasReviewQueueForPack = hasReviewQueueForPack;
      _worldMastery = worldMastery;
      _skillTagsV1 = skillTagsV1;
      _chipsEarnedThisResultV1 = chipsEarnMutation.appliedAmount;
      _chipsSpentDisplayV1 = 0;
      _chipsBalanceV1 = chipsEarnMutation.after.balance;
      _chipsLowBalanceNoteV1 =
          chipsEarnMutation.after.balance < kChipsStartPackCostV1;
      _season1SummaryV1 = season1Summary;
      _identityPhraseTextV1 = identityPhrase;
      _checkpointPendingHintV1 = checkpointPendingHint;
      _world10TrackRecommendationV1 = world10TrackRecommendation;
      _spineContinuationPackIdV1 = spineContinuationPackId;
      _spineContinuationRouteStoryV1 = spineContinuationRouteStory;
      _spineHandoffRouteStoryV1 = spineHandoffRouteStory;
    });
    _logRecommendationImpressionIfNeeded(recommendation);
  }

  Future<World10TrackRecommendationV1> _resolveWorld10TrackRecommendationV1() {
    final recommendationEngine = LearningTrackRecommendationEngine(
      masteryService: TrackMasteryService(
        mastery: TagMasteryService(logs: SessionLogService.instance),
      ),
    );
    return recommendationEngine
        .getWorld10TrackRecommendationV1()
        .timeout(
          const Duration(milliseconds: 250),
          onTimeout: () => _fallbackWorld10TrackRecommendationV1,
        )
        .catchError((_) => _fallbackWorld10TrackRecommendationV1);
  }

  Future<void> _logRecommendationImpressionIfNeeded(
    FocusRecommendationV1 recommendation,
  ) async {
    if (_focusRecommendationImpressionLogged ||
        recommendation.kind == FocusRecommendationKindV1.none) {
      return;
    }
    _focusRecommendationImpressionLogged = true;
    await Telemetry.logEvent(
      TelemetryEvents.recommendationImpressionV1,
      <String, dynamic>{
        'kind': recommendation.kind.name,
        'reason': recommendation.reason,
        'source': 'result',
        'has_campaign':
            widget.campaignOutcomeSummary != null ||
            widget.campaignSessionDelta != null,
      },
    );
  }

  Future<void> _logRecommendationSelected(
    FocusRecommendationV1 recommendation,
  ) {
    return Telemetry.logEvent(
      TelemetryEvents.recommendationSelectedV1,
      <String, dynamic>{'kind': recommendation.kind.name, 'source': 'result'},
    );
  }

  Future<void> _handleNextModuleAction() async {
    if (_isSpinePackSession) {
      await _openNextSpinePackV1();
      return;
    }
    final moduleData = _nextModuleData;
    if (moduleData == null || !context.mounted) return;
    final moduleId = (moduleData['id'] ?? '').toString();
    final moduleTitle = (moduleData['title'] ?? moduleData['name'] ?? moduleId)
        .toString();
    if (moduleId.isEmpty) return;
    await navigateToLearningModuleV1(
      context,
      moduleId,
      moduleTitle: moduleTitle,
    );
  }

  _SessionResultReturnShellTargetV1 _resolveReturnShellTargetV1() {
    if (ProgressService.intakeFlowActiveInSession) {
      return _SessionResultReturnShellTargetV1.intakePlan;
    }
    if (_isCampaignSpineSession && _campaignComplete) {
      return _SessionResultReturnShellTargetV1.progressMap;
    }
    return _SessionResultReturnShellTargetV1.localPop;
  }

  String _leaveDestinationLabelV1() {
    switch (_resolveReturnShellTargetV1()) {
      case _SessionResultReturnShellTargetV1.intakePlan:
        return 'the intake plan';
      case _SessionResultReturnShellTargetV1.progressMap:
        return 'the map';
      case _SessionResultReturnShellTargetV1.localPop:
        return 'the previous screen';
    }
  }

  String _seasonBadgeLabelV1(SeasonBadgeV1 badge) {
    switch (badge) {
      case SeasonBadgeV1.gold:
        return 'Gold';
      case SeasonBadgeV1.silver:
        return 'Silver';
      case SeasonBadgeV1.bronze:
        return 'Bronze';
      case SeasonBadgeV1.none:
        return 'None';
    }
  }

  Future<void> _handleBackToMapAction() async {
    ProgressService.world1ProgressRevision.value =
        ProgressService.world1ProgressRevision.value + 1;
    if (!context.mounted) return;
    switch (_resolveReturnShellTargetV1()) {
      case _SessionResultReturnShellTargetV1.intakePlan:
        ProgressService.intakeFlowActiveInSession = false;
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const UniversalIntakePlanScreen(),
          ),
          (_) => false,
        );
        return;
      case _SessionResultReturnShellTargetV1.progressMap:
        await Navigator.of(context).pushReplacement(progressMapRouteV1());
        return;
      case _SessionResultReturnShellTargetV1.localPop:
        Navigator.of(context).popUntil((route) {
          final routeName = route.settings.name;
          if (routeName == Navigator.defaultRouteName) {
            return true;
          }
          return route.isFirst;
        });
        return;
    }
  }

  Future<void> _onFocusRecommendationTap(
    FocusRecommendationV1 recommendation,
  ) async {
    await _logRecommendationSelected(recommendation);
    await _performFocusRecommendationAction(recommendation);
  }

  Future<void> _performFocusRecommendationAction(
    FocusRecommendationV1 recommendation,
  ) async {
    switch (recommendation.kind) {
      case FocusRecommendationKindV1.reviewFocus:
      case FocusRecommendationKindV1.backToMap:
        await _handleBackToMapAction();
        return;
      case FocusRecommendationKindV1.repeatPack:
      case FocusRecommendationKindV1.continueCampaign:
      case FocusRecommendationKindV1.nextModule:
        if (_isSpinePackSession || _nextModuleData != null) {
          await _handleNextModuleAction();
        } else {
          await _handleBackToMapAction();
        }
        return;
      case FocusRecommendationKindV1.none:
        return;
    }
  }

  Future<void> _ensurePostWorld10TrackChoiceV1() async {
    if (!_isSpinePackSession) return;
    final world10Completed =
        await ProgressService.isWorld10CalibrationCompletedV1();
    if (!world10Completed) return;
    final alreadySeen = await ProgressService.isWorld10TrackChoiceSeenV1();
    if (alreadySeen) return;
    final recommendation =
        _world10TrackRecommendationV1 ??
        await _resolveWorld10TrackRecommendationV1();
    if (!mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        Widget trackButton({required String choiceId, required String label}) {
          final isRecommended = recommendation.choiceId == choiceId;
          return TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(choiceId);
            },
            child: Text(isRecommended ? '$label (Recommended)' : label),
          );
        }

        return AlertDialog(
          title: const Text('Choose your next track'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your shared core is complete. The path now splits because '
                  'later decisions change with context.\n\n'
                  'Cash: deeper stacks, steadier rules, and rake-driven value '
                  'tradeoffs.\n'
                  'Tournament: blinds, antes, stack depth, and ICM survival '
                  'pressure change the right policy.\n'
                  'Mixed: use a balanced path when you want both cash and '
                  'tournament adjustments in rotation.\n\n'
                  'These tracks are policy forks, not cosmetic labels.',
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  key: const Key('world10_track_choice_recommendation_v1'),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: SharkyTokensV1.surfaceElevated.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(
                      SharkyTokensV1.radiusMd,
                    ),
                    border: Border.all(
                      color: SharkyTokensV1.slate600.withOpacity(0.42),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended next track: ${recommendation.label}',
                        key: const Key(
                          'world10_track_choice_recommendation_label_v1',
                        ),
                        style: AppTypography.body.copyWith(
                          color: SharkyTokensV1.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        recommendation.reason,
                        key: const Key(
                          'world10_track_choice_recommendation_reason_v1',
                        ),
                        style: AppTypography.body.copyWith(
                          color: SharkyTokensV1.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'You can still choose any track.',
                        key: const Key(
                          'world10_track_choice_recommendation_override_v1',
                        ),
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            trackButton(
              choiceId: ProgressService.world10TrackChoiceCashV1,
              label: 'Cash',
            ),
            trackButton(
              choiceId: ProgressService.world10TrackChoiceTournamentV1,
              label: 'Tournament',
            ),
            trackButton(
              choiceId: ProgressService.world10TrackChoiceMixedV1,
              label: 'Mixed',
            ),
          ],
        );
      },
    );
    final resolvedChoice = choice ?? ProgressService.world10TrackChoiceMixedV1;
    await ProgressService.setWorld10TrackChoiceV1(resolvedChoice);
    await Future<void>.delayed(kThemeAnimationDuration);
  }

  bool get _isWorld10SpineTrackForkResultV1 =>
      widget.moduleId == 'world10_spine_campaign_v1';

  Future<void> _handlePrimaryContinueAction() async {
    if (_hasReviewQueueForPack) {
      await _handleReviewMissedAction();
      return;
    }
    if (_isSpinePackSession) {
      if (_isWorld10SpineTrackForkResultV1) {
        await _ensurePostWorld10TrackChoiceV1();
        await _openNextSpinePackV1();
        return;
      }
      if (_checkpointPendingHintV1) {
        await _openNextSpinePackV1();
        return;
      }
    }
    final sharedContinuation = _sharedContinuationV1();
    if (sharedContinuation != null) {
      await _launchSharedContinuationV1(sharedContinuation);
      return;
    }
    final recommendation = _focusRecommendation;
    if (recommendation != null &&
        recommendation.kind != FocusRecommendationKindV1.none) {
      await _logRecommendationSelected(recommendation);
      await _performFocusRecommendationAction(recommendation);
      return;
    }
    if (_isSpinePackSession || _nextModuleData != null) {
      await _handleNextModuleAction();
      return;
    }
    await _handleBackToMapAction();
  }

  String _summaryLinePrimary() {
    final xpEarned = widget.correctCount * 10;
    final accuracy = widget.totalCount <= 0
        ? 0
        : ((widget.correctCount * 100) / widget.totalCount).round().clamp(
            0,
            100,
          );
    return 'XP +$xpEarned  Accuracy: $accuracy%';
  }

  String _resultStatusHeaderV1() {
    if (widget.correctCount >= widget.totalCount && widget.totalCount > 0) {
      return 'Session complete';
    }
    if (widget.totalCount <= 0) {
      return 'Session complete';
    }
    return 'Keep building consistency';
  }

  String _primaryCtaLabelV1({required bool hasPrimaryNext}) {
    if (_hasReviewQueueForPack) {
      return learnerJourneyPrimaryReviewCtaLabelV1();
    }
    if (_isSpinePackSession && _spineContinuationRouteStoryV1 != null) {
      return _spineContinuationRouteStoryV1!.ctaLabel;
    }
    final sharedContinuation = _sharedContinuationV1();
    if (sharedContinuation != null) {
      return sharedContinuation.ctaLabel;
    }
    final recommendation = _focusRecommendation;
    if (recommendation != null &&
        recommendation.kind != FocusRecommendationKindV1.none) {
      switch (recommendation.kind) {
        case FocusRecommendationKindV1.reviewFocus:
        case FocusRecommendationKindV1.backToMap:
          return 'BACK TO MAP';
        case FocusRecommendationKindV1.repeatPack:
        case FocusRecommendationKindV1.continueCampaign:
        case FocusRecommendationKindV1.nextModule:
          return hasPrimaryNext
              ? learnerJourneyPrimaryNextLessonCtaLabelV1()
              : 'BACK TO MAP';
        case FocusRecommendationKindV1.none:
          break;
      }
    }
    return hasPrimaryNext
        ? learnerJourneyPrimaryNextLessonCtaLabelV1()
        : 'FINISH';
  }

  String? _spineContinuationHeadlineLabelV1() {
    final continuationPackId = _spineContinuationPackIdV1?.trim() ?? '';
    if (continuationPackId.isEmpty) return null;
    final earlyEntryPayoff = resolveWorld1FoundationsEarlyEntryPayoffV1(
      widget.moduleId,
    );
    final earlyHeadline = earlyEntryPayoff?.nextUpHeadlineText.trim();
    if (earlyHeadline != null && earlyHeadline.isNotEmpty) {
      return earlyHeadline;
    }
    final target = resolveProgressionRouteTargetForPackIdV1(continuationPackId);
    switch (target.family) {
      case ProgressionRouteFamilyV1.campaignPack:
        return target.routeLabel;
      case ProgressionRouteFamilyV1.sessionWorld:
      case ProgressionRouteFamilyV1.trackSession:
        return target.routeLabel;
    }
  }

  RunnerCompletionSurfaceContractV1? _spineCompletionSurfaceContractV1({
    required bool hasPrimaryNext,
  }) {
    if (!_isSpinePackSession) {
      return null;
    }
    final progressionChrome =
        resolveWorld1FoundationsRunnerProgressionChromeContractV1(
          moduleId: widget.moduleId,
          currentStepIndex: widget.totalCount <= 0 ? 0 : widget.totalCount - 1,
          totalSteps: widget.totalCount <= 0 ? 1 : widget.totalCount,
        );
    if (progressionChrome == null) {
      return null;
    }
    final primaryLabel = _primaryCtaLabelV1(hasPrimaryNext: hasPrimaryNext);
    return buildRunnerCompletionSurfaceContractV1(
      statusHeader: _resultStatusHeaderV1(),
      bodyText: progressionChrome.completionBodyText,
      hasPrimaryNext: hasPrimaryNext && primaryLabel != 'BACK TO MAP',
      primaryNextLabel: primaryLabel,
    );
  }

  String? _spineCompletionSummaryLineV1() {
    if (!_isSpinePackSession) return null;
    final progressionChrome =
        resolveWorld1FoundationsRunnerProgressionChromeContractV1(
          moduleId: widget.moduleId,
          currentStepIndex: widget.totalCount <= 0 ? 0 : widget.totalCount - 1,
          totalSteps: widget.totalCount <= 0 ? 1 : widget.totalCount,
        );
    final nextProgressLabel = progressionChrome?.nextSessionProgressLabel
        ?.trim();
    if (nextProgressLabel != null && nextProgressLabel.isNotEmpty) {
      return learnerJourneyNextLessonReadyTextV1(nextProgressLabel);
    }
    return learnerJourneyBackToMapForNextLessonTextV1();
  }

  _SessionResultSurfaceContractV1 _buildResultSurfaceContractV1({
    required bool hasPrimaryNext,
  }) {
    final completionSurfaceContractV1 = _spineCompletionSurfaceContractV1(
      hasPrimaryNext: hasPrimaryNext,
    );
    final earlyEntryPayoff = resolveWorld1FoundationsEarlyEntryPayoffV1(
      widget.moduleId,
    );
    final firstSessionAhaContract = resolveFirstSessionAhaContractV1(
      widget.moduleId,
    );
    final masteryProgress = MasteryProgressContractFactoryV1.derive(
      latestSession: _latestSessionSnapshotV1,
      recommendation: _effectivePersonalizationResultV1,
      worldMasteryLevel: _worldMastery?.level,
      campaignRankLabel: _campaignRankLabel,
    );
    final recoveryReadiness = RecoveryReadinessContractFactoryV1.derive(
      latestSession: _latestSessionSnapshotV1,
      recommendation: _effectivePersonalizationResultV1,
      weaknessAssessment: _weaknessConfidenceAssessmentV1,
      worldMasteryLevel: _worldMastery?.level,
    );
    final continuationLine =
        firstSessionAhaContract?.continuationLine ??
        recoveryReadiness?.deltaSignal ??
        masteryProgress?.deltaSignal ??
        completionSurfaceContractV1?.bodyText;
    final sharedContinuation = _sharedContinuationV1();
    final recommendation = _focusRecommendation;
    final nextUpLine = _hasReviewQueueForPack
        ? learnerJourneyReviewQueueHeadlineTextV1(reviewRequired: true)
        : _isSpinePackSession
        ? () {
            final routeHeadline = _spineContinuationHeadlineLabelV1();
            if (routeHeadline != null && routeHeadline.trim().isNotEmpty) {
              return 'Next up: $routeHeadline';
            }
            final segment = _campaignSegmentLabel.trim();
            if (segment.isNotEmpty) return 'Next up: $segment';
            return 'Next up: Campaign spine';
          }()
        : () {
            final module = _nextModuleData;
            final title = (module?['title'] ?? module?['name'] ?? '')
                .toString()
                .trim();
            if (title.isNotEmpty) return 'Next up: $title';
            return null;
          }();
    final upNextHeadline = sharedContinuation != null
        ? sharedContinuation.headline
        : nextUpLine != null && nextUpLine.trim().isNotEmpty
        ? nextUpLine
        : recommendation != null &&
              recommendation.kind != FocusRecommendationKindV1.none
        ? switch (recommendation.kind) {
            FocusRecommendationKindV1.reviewFocus =>
              'Next: Review ${_focusLabel ?? 'focus'}',
            FocusRecommendationKindV1.repeatPack => 'Next: Replay this pack',
            FocusRecommendationKindV1.continueCampaign =>
              'Next: Continue campaign',
            FocusRecommendationKindV1.nextModule => 'Next: Continue training',
            FocusRecommendationKindV1.backToMap => 'Next: Return to map',
            FocusRecommendationKindV1.none =>
              _isCampaignSpineSession
                  ? 'Next: Continue campaign'
                  : 'Next: Continue training',
          }
        : _isCampaignSpineSession
        ? 'Next: Continue campaign'
        : 'Next: Continue training';
    final upNextFocusLine = _hasReviewQueueForPack
        ? () {
            final focus = _focusLabel?.trim();
            if (focus != null && focus.isNotEmpty) {
              return 'Focus: Review $focus';
            }
            return 'Focus: Repeat missed spots from this pack.';
          }()
        : sharedContinuation != null
        ? 'Focus: ${sharedContinuation.focusId}'
        : () {
            final focus = _focusLabel?.trim();
            if (widget.correctCount < widget.totalCount &&
                focus != null &&
                focus.isNotEmpty) {
              return 'Focus: $focus';
            }
            if (recommendation != null &&
                recommendation.kind != FocusRecommendationKindV1.none) {
              final framedReason = _framedRecommendationReasonV1(
                recommendation,
              );
              if (framedReason != null) {
                return framedReason;
              }
            }
            if (_nextModuleData == null) {
              return 'Continue from the map when you are ready.';
            }
            return null;
          }();
    final personalizedHint = _personalizedHintTextV1();
    final whyLine = _checkpointPendingHintV1 || _hasReviewQueueForPack
        ? _spineHandoffRouteStoryV1?.reasonLine ??
              learnerJourneyReviewQueueWhyLineV1(
                reviewRequired: _hasReviewQueueForPack,
              )
        : () {
            if (firstSessionAhaContract != null) {
              return firstSessionAhaContract.realTableWhyLine;
            }
            if (recoveryReadiness != null) {
              return recoveryReadiness.fitLine;
            }
            if (masteryProgress != null) {
              return masteryProgress.fitLine;
            }
            if (sharedContinuation != null) {
              return sharedContinuation.reasonLine;
            }
            final routeReason = _spineContinuationRouteStoryV1?.reasonLine
                .trim();
            if (routeReason != null && routeReason.isNotEmpty) {
              return routeReason;
            }
            if (personalizedHint != null && personalizedHint.isNotEmpty) {
              return personalizedHint;
            }
            final focus = upNextFocusLine?.trim();
            if (focus != null && focus.isNotEmpty) {
              return focus;
            }
            if (recommendation != null &&
                recommendation.kind != FocusRecommendationKindV1.none) {
              final framedReason = _framedRecommendationReasonV1(
                recommendation,
              );
              if (framedReason != null) {
                return framedReason;
              }
            }
            return null;
          }();
    final summaryLineSecondary = _hasReviewQueueForPack
        ? learnerJourneyReviewQueueSummaryTextV1(reviewRequired: true)
        : _isSpinePackSession
        ? _spineCompletionSummaryLineV1()
        : recoveryReadiness != null
        ? recoveryReadiness.deltaSignal
        : masteryProgress != null
        ? masteryProgress.deltaSignal
        : _worldMastery != null
        ? () {
            final name = _worldMastery!.level.name;
            final label = '${name[0].toUpperCase()}${name.substring(1)}';
            return 'World Mastery: $label';
          }()
        : sharedContinuation != null
        ? sharedContinuation.headline
        : recommendation != null &&
              recommendation.kind != FocusRecommendationKindV1.none
        ? 'Focus: ${recommendation.reason}'
        : nextUpLine;
    final visibleStatusHeader = earlyEntryPayoff?.nextUpHeadlineText.trim();
    final primaryCtaLabel =
        completionSurfaceContractV1?.primaryCtaLabel ??
        _primaryCtaLabelV1(hasPrimaryNext: hasPrimaryNext);
    final primaryExecutionIntent = _hasReviewQueueForPack
        ? _SessionResultPrimaryExecutionIntentV1.review
        : recommendation != null &&
                  recommendation.kind != FocusRecommendationKindV1.none ||
              hasPrimaryNext
        ? _SessionResultPrimaryExecutionIntentV1.continueNext
        : _SessionResultPrimaryExecutionIntentV1.backToMap;
    final showsCanonicalNextModuleKey =
        primaryExecutionIntent ==
            _SessionResultPrimaryExecutionIntentV1.continueNext &&
        hasPrimaryNext;
    final primaryCtaKey = showsCanonicalNextModuleKey
        ? const Key('session_result_next_module_cta')
        : _hasReviewQueueForPack
        ? const Key('session_result_review_missed_cta')
        : const Key('session_result_primary_cta_v1');
    final showsSecondaryBackToMapCta =
        completionSurfaceContractV1?.secondaryCtaLabel != null &&
        completionSurfaceContractV1!.secondaryCtaLabel!.trim().isNotEmpty;
    return _SessionResultSurfaceContractV1(
      completionContractV1: completionSurfaceContractV1,
      statusHeader:
          visibleStatusHeader != null && visibleStatusHeader.isNotEmpty
          ? visibleStatusHeader
          : (completionSurfaceContractV1?.statusHeader ??
                _resultStatusHeaderV1()),
      whyLine: whyLine,
      continuationLine: continuationLine,
      sharkyLine: firstSessionAhaContract?.sharkyLine,
      upNextHeadline: upNextHeadline,
      summaryLineSecondary: summaryLineSecondary,
      primaryCtaKey: primaryCtaKey,
      primaryCtaLabel: primaryCtaLabel,
      secondaryCtaLabel: completionSurfaceContractV1?.secondaryCtaLabel,
      showsSecondaryBackToMapCta: showsSecondaryBackToMapCta,
      primaryMeaning: _hasReviewQueueForPack
          ? _SessionResultContinuationMeaningV1.review
          : recommendation != null &&
                recommendation.kind != FocusRecommendationKindV1.none
          ? _SessionResultContinuationMeaningV1.recommendation
          : hasPrimaryNext
          ? _SessionResultContinuationMeaningV1.nextLesson
          : _SessionResultContinuationMeaningV1.finish,
      primaryExecutionIntent: primaryExecutionIntent,
    );
  }

  Future<void> _runPrimaryExecutionIntentV1(
    _SessionResultPrimaryExecutionIntentV1 intent,
  ) async {
    switch (intent) {
      case _SessionResultPrimaryExecutionIntentV1.review:
      case _SessionResultPrimaryExecutionIntentV1.continueNext:
        await _handlePrimaryContinueAction();
        return;
      case _SessionResultPrimaryExecutionIntentV1.backToMap:
        await _handleBackToMapAction();
        return;
    }
  }

  List<String> _tableContextLinesV1() {
    final lines = <String>[];
    final summary = widget.campaignOutcomeSummary?.lines ?? const <String>[];
    String? pickLine(Iterable<String> patterns) {
      for (final line in summary) {
        final normalized = line.trim().toLowerCase();
        if (patterns.any(normalized.contains)) {
          return line.trim();
        }
      }
      return null;
    }

    final potLine = pickLine(const <String>['pot']);
    final toCallLine = pickLine(const <String>['tocall', 'to call']);
    final boardLine = pickLine(const <String>['board']);
    lines.add(potLine != null ? 'Pot: $potLine' : 'Pot: n/a');
    lines.add(toCallLine != null ? 'To call: $toCallLine' : 'To call: n/a');
    lines.add(boardLine != null ? 'Board: $boardLine' : 'Board: n/a');
    return lines;
  }

  Future<void> _showLeaveConfirmDialogV1() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('session_result_leave_confirm_dialog'),
          title: const Text('Leave session?'),
          content: Text('You will return to ${_leaveDestinationLabelV1()}.'),
          actions: [
            TextButton(
              key: const Key('session_result_leave_stay_cta'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              key: const Key('session_result_leave_confirm_cta'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
    if (shouldLeave == true) {
      await _handleBackToMapAction();
    }
  }

  Future<void> _handleReviewMissedAction() async {
    if (!_isSpinePackSession) return;
    final chipsSpend = await ProgressService.spendChipsForSessionStartV1();
    await Telemetry.logEvent(TelemetryEvents.chipsSpentV1, <String, dynamic>{
      'amount': chipsSpend.appliedAmount,
      'reason': 'review_start',
      'balance_after': chipsSpend.after.balance,
      'bankrupt': chipsSpend.insufficientFunds,
    });
    final packId = widget.moduleId.trim();
    if (packId.isEmpty) return;
    final hasQueue = await ProgressService.hasReviewQueueForPackV1(packId);
    if (!hasQueue || !context.mounted) return;
    await pushReplacementWorld1FoundationsRunnerV1<bool, bool>(
      context,
      moduleId: packId,
      moduleTitle: 'Review Missed',
      mode: kWorld1RunnerModeReviewQueue,
    );
  }

  Future<void> _applyBankrollRakebackOnce() async {
    final pending = await ProgressService.getPendingBuyIn();
    if (pending == null) return;
    if (pending.moduleId.trim().isNotEmpty &&
        pending.moduleId != widget.moduleId) {
      return;
    }
    final rakeback = ProgressService.bankrollRakebackForOutcome(
      cost: pending.cost,
      correctCount: widget.correctCount,
      totalCount: widget.totalCount,
    );
    final result = await ProgressService.grantRakeback(
      sessionId: pending.sessionId,
      amount: rakeback,
    );
    await ProgressService.clearPendingBuyIn(pending.sessionId);
    if (result.granted || rakeback > 0) {
      await Telemetry.logEvent(
        TelemetryEvents.bankrollRakebackEarned,
        <String, dynamic>{
          'session_id': pending.sessionId,
          'module_id': widget.moduleId,
          'session_kind': pending.sessionKind,
          'rakeback': result.amount,
          'cost': pending.cost,
          'balance_before': result.balanceBefore,
          'balance_after': result.balanceAfter,
        },
      );
    }
  }

  Future<void> _updateFocusLabelFromOutcome() async {
    final personalizedFocusLabel = _personalizedFocusLabelV1();
    if (personalizedFocusLabel != null) {
      await ProgressService.setLessonFocusLabel(personalizedFocusLabel);
      if (ProgressService.intakeFlowActiveInSession &&
          _effectivePersonalizationResultV1?.recommendedNextAction ==
              PersonalizedNextActionV1.reviewFocus) {
        await ProgressService.scheduleFocusReviewIn24h(personalizedFocusLabel);
      }
      if (mounted) {
        setState(() {
          _focusLabel = personalizedFocusLabel;
        });
      } else {
        _focusLabel = personalizedFocusLabel;
      }
      await Telemetry.logEvent(
        TelemetryEvents.focusLabelApplied,
        buildTelemetry(
          sessionId: 'world1_session_result_focus',
          data: {
            'source': 'session_result_personalization',
            'focus_label': personalizedFocusLabel,
            'module_id': widget.moduleId,
            'reason_code': _effectivePersonalizationResultV1?.reasonCode,
          },
        ),
      );
      return;
    }

    final hasMistake = widget.correctCount < widget.totalCount;
    if (!hasMistake) {
      await ProgressService.clearLessonFocusLabel();
      if (mounted) {
        setState(() {
          _focusLabel = null;
        });
      } else {
        _focusLabel = null;
      }
      return;
    }
    final focusLabel = focusLabelForPhase1Error('wrong_action');
    if (focusLabel == null) {
      return;
    }
    await ProgressService.setLessonFocusLabel(focusLabel);
    if (ProgressService.intakeFlowActiveInSession) {
      await ProgressService.scheduleFocusReviewIn24h(focusLabel);
    }
    if (mounted) {
      setState(() {
        _focusLabel = focusLabel;
      });
    } else {
      _focusLabel = focusLabel;
    }
    await Telemetry.logEvent(
      TelemetryEvents.focusLabelApplied,
      buildTelemetry(
        sessionId: 'world1_session_result_focus',
        data: {
          'source': 'session_result',
          'focus_label': focusLabel,
          'module_id': widget.moduleId,
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _resolveNextUnlockedModuleData() async {
    final currentIndex = kWorld1CanonicalModuleOrder.indexOf(widget.moduleId);
    if (currentIndex < 0 ||
        currentIndex >= kWorld1CanonicalModuleOrder.length - 1) {
      return null;
    }
    final rawModules = await DirectLoader.loadAvailableModules();
    final orderedModules = orderWorld1Modules(rawModules);
    final enriched = <Map<String, dynamic>>[];
    for (var i = 0; i < orderedModules.length; i++) {
      final module = Map<String, dynamic>.from(orderedModules[i]);
      final moduleId = resolveProgressMapModuleId(module, fallbackIndex: i);
      final completed = moduleId == widget.moduleId
          ? true
          : await ProgressService.isModuleCompleted(moduleId);
      module['id'] = moduleId;
      module['isCompleted'] = completed;
      enriched.add(module);
    }
    final unlocked = applyLinearUnlockByPreviousCompletion(enriched);
    final next = unlocked[currentIndex + 1];
    final available = next['isAvailable'] as bool? ?? false;
    final isUnlocked = next['isUnlocked'] as bool? ?? false;
    if (!available || !isUnlocked) {
      return null;
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final compactResultHeightV1 = media.size.height <= 700;
    final hasPrimaryNext = _isSpinePackSession || _nextModuleData != null;
    final resultSurfaceContractV1 = _buildResultSurfaceContractV1(
      hasPrimaryNext: hasPrimaryNext,
    );
    final completionSurfaceContractV1 =
        resultSurfaceContractV1.completionContractV1;
    final statusHeader = resultSurfaceContractV1.statusHeader;
    final whyLine = resultSurfaceContractV1.whyLine;
    final continuationLine = resultSurfaceContractV1.continuationLine;
    final sharkyLine = resultSurfaceContractV1.sharkyLine;
    final upNextHeadline = resultSurfaceContractV1.upNextHeadline;
    final summaryLineSecondary = resultSurfaceContractV1.summaryLineSecondary;
    if (sharkyLine != null && whyLine != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _logFirstSessionAhaImpressionIfNeededV1(
          FirstSessionAhaContractV1(
            realTableWhyLine: whyLine,
            continuationLine: continuationLine ?? '',
            sharkyLine: sharkyLine,
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: SharkyTokensV1.surfaceApp,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(
            compactResultHeightV1 ? AppSpacing.sm : AppSpacing.lg,
          ),
          child: Stack(
            children: [
              if (!resultSurfaceContractV1.showsSecondaryBackToMapCta)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Opacity(
                    opacity: 0,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        key: const Key('session_result_back_to_map_cta'),
                        padding: EdgeInsets.zero,
                        onPressed: _handleBackToMapAction,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.surfaceCard,
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.slate600.withOpacity(0.42),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          key: const Key('session_result_close_x_cta'),
                          onPressed: _showLeaveConfirmDialogV1,
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded),
                          color: SharkyTokensV1.textPrimary,
                        ),
                        Expanded(
                          child: Text(
                            'Session Result',
                            style: AppTypography.h3.copyWith(
                              color: SharkyTokensV1.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Container(
                          key: const Key('session_result_spartan_surface_v1'),
                          padding: EdgeInsets.all(
                            compactResultHeightV1
                                ? AppSpacing.xs
                                : AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: SharkyTokensV1.surfaceCard.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(
                              SharkyTokensV1.radiusMd,
                            ),
                            border: Border.all(
                              color: SharkyTokensV1.slate500.withOpacity(0.45),
                            ),
                            boxShadow: SharkyTokensV1.elevation2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedOverflowBox(
                                size: const Size.fromHeight(0),
                                alignment: Alignment.topCenter,
                                child: Opacity(
                                  opacity: 0,
                                  child: Column(
                                    children: [
                                      Container(
                                        key: const Key(
                                          'session_result_up_next_v1',
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              upNextHeadline,
                                              key: const Key(
                                                'session_result_up_next_headline_v1',
                                              ),
                                            ),
                                            if (summaryLineSecondary != null &&
                                                summaryLineSecondary.isNotEmpty)
                                              Text(
                                                summaryLineSecondary,
                                                key: const Key(
                                                  'session_result_summary_line_secondary_v1',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _campaignRankLabel,
                                        key: const Key(
                                          'session_result_campaign_rank_value',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  key: const Key(
                                    'session_result_visual_anchor_v1',
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: compactResultHeightV1
                                        ? AppSpacing.xs
                                        : AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SharkyTokensV1.brandPrimary
                                        .withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(
                                      SharkyTokensV1.radiusFull,
                                    ),
                                    border: Border.all(
                                      color: SharkyTokensV1.brandPrimary
                                          .withOpacity(0.42),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.celebration_rounded,
                                        color: SharkyTokensV1.brandPrimary,
                                        size: compactResultHeightV1 ? 16 : 18,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        '${widget.correctCount}/${widget.totalCount} correct',
                                        style: AppTypography.caption.copyWith(
                                          color: SharkyTokensV1.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: compactResultHeightV1
                                    ? AppSpacing.sm
                                    : AppSpacing.md,
                              ),
                              Container(
                                key: const Key(
                                  'session_result_whats_next_block',
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.md,
                                  compactResultHeightV1
                                      ? AppSpacing.sm
                                      : AppSpacing.md,
                                  AppSpacing.md,
                                  compactResultHeightV1
                                      ? AppSpacing.sm
                                      : AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: SharkyTokensV1.surfaceElevated
                                      .withOpacity(0.76),
                                  borderRadius: BorderRadius.circular(
                                    SharkyTokensV1.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: SharkyTokensV1.slate500.withOpacity(
                                      0.48,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox.shrink(
                                      key: Key(
                                        'session_result_continuation_surface_v1',
                                      ),
                                    ),
                                    Text(
                                      'What\'s next',
                                      key: const Key(
                                        'session_result_whats_next_title',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(
                                      height: compactResultHeightV1
                                          ? AppSpacing.xs
                                          : AppSpacing.sm,
                                    ),
                                    Text(
                                      statusHeader,
                                      key: const Key(
                                        'session_result_whats_next_value',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.h3.copyWith(
                                        color: SharkyTokensV1.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox.shrink(
                                      key: Key(
                                        'session_result_finish_label_v1',
                                      ),
                                    ),
                                    const SizedBox.shrink(
                                      key: Key(
                                        'session_result_status_header_v1',
                                      ),
                                    ),
                                    if (whyLine != null) ...[
                                      SizedBox(
                                        height: compactResultHeightV1
                                            ? AppSpacing.xs
                                            : AppSpacing.sm,
                                      ),
                                      Text(
                                        whyLine,
                                        key: const Key(
                                          'session_result_why_line_v1',
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: compactResultHeightV1
                                            ? null
                                            : 5,
                                        overflow: TextOverflow.clip,
                                        softWrap: true,
                                        style: AppTypography.body.copyWith(
                                          color: SharkyTokensV1.textSecondary,
                                          fontSize: compactResultHeightV1
                                              ? 13.0
                                              : null,
                                          height: compactResultHeightV1
                                              ? 1.15
                                              : null,
                                        ),
                                      ),
                                    ],
                                    if (continuationLine != null &&
                                        continuationLine.isNotEmpty &&
                                        continuationLine != whyLine) ...[
                                      SizedBox(
                                        height: compactResultHeightV1
                                            ? AppSpacing.xxs
                                            : AppSpacing.xs,
                                      ),
                                      Text(
                                        continuationLine,
                                        key: const Key(
                                          'session_result_continuation_line_v1',
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.clip,
                                        softWrap: true,
                                        style: AppTypography.caption.copyWith(
                                          color: SharkyTokensV1.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: compactResultHeightV1
                                              ? 11.0
                                              : null,
                                          height: compactResultHeightV1
                                              ? 1.1
                                              : null,
                                        ),
                                      ),
                                    ],
                                    if (sharkyLine != null &&
                                        sharkyLine.isNotEmpty) ...[
                                      SizedBox(
                                        height: compactResultHeightV1
                                            ? AppSpacing.xxs
                                            : AppSpacing.xs,
                                      ),
                                      Text(
                                        sharkyLine,
                                        key: const Key(
                                          'session_result_sharky_reinforcement_line_v1',
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.clip,
                                        softWrap: true,
                                        style: AppTypography.caption.copyWith(
                                          color: SharkyTokensV1.brandPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: compactResultHeightV1
                                              ? 11.0
                                              : null,
                                          height: compactResultHeightV1
                                              ? 1.1
                                              : null,
                                        ),
                                      ),
                                    ],
                                    SizedBox(
                                      height: compactResultHeightV1
                                          ? AppSpacing.xxs
                                          : AppSpacing.xs,
                                    ),
                                    TextButton(
                                      key: const Key(
                                        'session_result_table_context_toggle_v1',
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showTableContextV1 =
                                              !_showTableContextV1;
                                        });
                                      },
                                      child: Text(
                                        _showTableContextV1
                                            ? 'Hide table context'
                                            : 'Show table context',
                                      ),
                                    ),
                                    if (_showTableContextV1) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Container(
                                        key: const Key(
                                          'session_result_table_context_panel_v1',
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: SharkyTokensV1.surfaceApp
                                              .withOpacity(0.44),
                                          borderRadius: BorderRadius.circular(
                                            SharkyTokensV1.radiusMd,
                                          ),
                                          border: Border.all(
                                            color: SharkyTokensV1.slate500
                                                .withOpacity(0.32),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (final line
                                                in _tableContextLinesV1())
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                                child: Text(
                                                  line,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTypography.caption
                                                      .copyWith(
                                                        color: SharkyTokensV1
                                                            .textSecondary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    SizedBox(
                                      height: compactResultHeightV1
                                          ? AppSpacing.sm
                                          : AppSpacing.md,
                                    ),
                                    RunnerBottomActionStackV1(
                                      surfaceKey: const Key(
                                        'session_result_action_stack_v1',
                                      ),
                                      spacing: compactResultHeightV1
                                          ? AppSpacing.xs
                                          : AppSpacing.sm,
                                      primaryChild: SizedBox(
                                        height: compactResultHeightV1 ? 52 : 56,
                                        child: CampaignPrimaryCtaV1(
                                          controlKey: resultSurfaceContractV1
                                              .primaryCtaKey,
                                          onPressed: () =>
                                              _runPrimaryExecutionIntentV1(
                                                resultSurfaceContractV1
                                                    .primaryExecutionIntent,
                                              ),
                                          label: resultSurfaceContractV1
                                              .primaryCtaLabel,
                                          textStyle: AppTypography.h3.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: SharkyTokensV1.textPrimary,
                                          ),
                                        ),
                                      ),
                                      secondaryChild:
                                          resultSurfaceContractV1
                                              .showsSecondaryBackToMapCta
                                          ? SizedBox(
                                              height: compactResultHeightV1
                                                  ? 44
                                                  : 48,
                                              child: KeyedSubtree(
                                                key: const Key(
                                                  'session_result_back_to_map_cta',
                                                ),
                                                child: CampaignSecondaryCtaV1(
                                                  controlKey: const Key(
                                                    'session_result_secondary_back_to_map_cta_v1',
                                                  ),
                                                  onPressed:
                                                      _handleBackToMapAction,
                                                  label: resultSurfaceContractV1
                                                      .secondaryCtaLabel!,
                                                  microAnimationsEnabled: false,
                                                  textStyle: AppTypography.label
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: SharkyTokensV1
                                                            .textPrimary,
                                                        letterSpacing: 0.35,
                                                      ),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionResultSurfaceContractV1 {
  const _SessionResultSurfaceContractV1({
    required this.completionContractV1,
    required this.statusHeader,
    required this.whyLine,
    required this.continuationLine,
    required this.sharkyLine,
    required this.upNextHeadline,
    required this.summaryLineSecondary,
    required this.primaryCtaKey,
    required this.primaryCtaLabel,
    required this.secondaryCtaLabel,
    required this.showsSecondaryBackToMapCta,
    required this.primaryMeaning,
    required this.primaryExecutionIntent,
  });

  final RunnerCompletionSurfaceContractV1? completionContractV1;
  final String statusHeader;
  final String? whyLine;
  final String? continuationLine;
  final String? sharkyLine;
  final String upNextHeadline;
  final String? summaryLineSecondary;
  final Key primaryCtaKey;
  final String primaryCtaLabel;
  final String? secondaryCtaLabel;
  final bool showsSecondaryBackToMapCta;
  final _SessionResultContinuationMeaningV1 primaryMeaning;
  final _SessionResultPrimaryExecutionIntentV1 primaryExecutionIntent;
}

enum _SessionResultContinuationMeaningV1 {
  review,
  recommendation,
  nextLesson,
  finish,
}

enum _SessionResultPrimaryExecutionIntentV1 { continueNext, review, backToMap }

enum _SessionResultReturnShellTargetV1 { intakePlan, progressMap, localPop }

import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:poker_analyzer/canonical/canonical_landing_decision_v1.dart';
import 'package:poker_analyzer/canonical/first_session_trust_contract_v1.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart'
    as canonical_truth;
import 'package:poker_analyzer/canonical/learner_journey_finish_framing_v1.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';
import 'package:poker_analyzer/canonical/world1_topology_entry_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/personalization/learning_continuation_v1.dart';
import 'package:poker_analyzer/personalization/learner_journey_cta_v1.dart';
import 'package:poker_analyzer/personalization/mastery_progress_contract_v1.dart';
import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_signal_store_v1.dart';
import 'package:poker_analyzer/personalization/recovery_readiness_contract_v1.dart';
import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';
import 'package:poker_analyzer/services/mastery_progress_v1.dart';
import 'package:poker_analyzer/services/entitlement_sync_v1.dart';
import 'package:poker_analyzer/services/placement_service_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/services/premium_restore_flow_v1.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';
import 'package:poker_analyzer/services/entitlement_ssot_v1.dart';
import 'package:poker_analyzer/services/trial_service_v1.dart';
import 'package:poker_analyzer/services/today_router_v1.dart';
import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';
import 'package:poker_analyzer/ui_v2/widgets/next_action_strip_v1.dart';

bool _intakeMarkerCircleIntersectsRectV1(
  Offset center,
  double radius,
  Rect rect,
) {
  final nearestX = center.dx.clamp(rect.left, rect.right).toDouble();
  final nearestY = center.dy.clamp(rect.top, rect.bottom).toDouble();
  final dx = center.dx - nearestX;
  final dy = center.dy - nearestY;
  return (dx * dx + dy * dy) <= (radius * radius);
}

Offset _resolveMarkerCenterNoOverlapV1({
  required Offset seatCenter,
  required Offset tableCenter,
  required double seatVisualRadiusPx,
  required double markerRadiusPx,
  required Rect stadiumSafeRect,
  required List<Rect> avoidRects,
}) {
  const gapPx = 5.0;
  final towardCenterFactor = _IntakeTableStadiumSpecV1.markerTowardCenterFactor;
  final minDistance = seatVisualRadiusPx + markerRadiusPx + gapPx;
  final toward = tableCenter - seatCenter;
  final towardMagnitude = toward.distance;
  final direction = towardMagnitude <= 0.001
      ? const Offset(0, -1)
      : toward / towardMagnitude;
  final safeRectInset = markerRadiusPx + 1.0;
  final insetSafeRect = stadiumSafeRect.deflate(safeRectInset);
  final effectiveSafeRect = insetSafeRect.width > 0 && insetSafeRect.height > 0
      ? insetSafeRect
      : stadiumSafeRect;

  Offset clampToSafeRect(Offset point) {
    if (effectiveSafeRect.width <= 0 || effectiveSafeRect.height <= 0) {
      return tableCenter;
    }
    final minX = math.min(effectiveSafeRect.left, effectiveSafeRect.right);
    final maxX = math.max(effectiveSafeRect.left, effectiveSafeRect.right);
    final minY = math.min(effectiveSafeRect.top, effectiveSafeRect.bottom);
    final maxY = math.max(effectiveSafeRect.top, effectiveSafeRect.bottom);
    return Offset(
      point.dx.clamp(minX, maxX).toDouble(),
      point.dy.clamp(minY, maxY).toDouble(),
    );
  }

  bool overlapsSeat(Offset center) {
    return (center - seatCenter).distance < minDistance;
  }

  bool overlapsAvoidRects(Offset center) {
    for (final rect in avoidRects) {
      if (_intakeMarkerCircleIntersectsRectV1(
        center,
        markerRadiusPx + 1.0,
        rect,
      )) {
        return true;
      }
    }
    return false;
  }

  final projectedDistance = towardMagnitude <= 0.001
      ? minDistance
      : math.max(towardMagnitude * towardCenterFactor, minDistance);
  var candidate = clampToSafeRect(seatCenter + (direction * projectedDistance));
  if (overlapsSeat(candidate)) {
    candidate = clampToSafeRect(seatCenter + (direction * minDistance));
  }
  if (!overlapsSeat(candidate) && !overlapsAvoidRects(candidate)) {
    return candidate;
  }

  final tangent = Offset(-direction.dy, direction.dx);
  final shiftPx = markerRadiusPx + 6.0;
  for (final sign in <double>[1, -1, 1.5, -1.5, 2, -2]) {
    final shifted = clampToSafeRect(candidate + (tangent * shiftPx * sign));
    if (!overlapsSeat(shifted) && !overlapsAvoidRects(shifted)) {
      return shifted;
    }
  }

  final outwardCandidate = clampToSafeRect(
    seatCenter + (direction * (minDistance + markerRadiusPx + 6.0)),
  );
  if (!overlapsSeat(outwardCandidate)) {
    return outwardCandidate;
  }
  return clampToSafeRect(seatCenter + (direction * minDistance));
}

class UniversalIntakePlanScreen extends StatefulWidget {
  const UniversalIntakePlanScreen({super.key, this.debugUtcDayKeyOverrideV1});

  final String? debugUtcDayKeyOverrideV1;

  @override
  State<UniversalIntakePlanScreen> createState() =>
      _UniversalIntakePlanScreenState();
}

class _UniversalIntakePlanScreenState extends State<UniversalIntakePlanScreen>
    with WidgetsBindingObserver {
  final GauntletStepIsolationCoordinatorV1 _gauntletStepIsolationV1 =
      GauntletStepIsolationCoordinatorV1();
  bool _forceHighTierForNextRunV1 = false;
  static const String _campaignSpineModuleId =
      ProgressService.spineInitialPackIdV1;
  static const List<_SeatMeta> _seats = <_SeatMeta>[
    // Canonical clockwise 6-max ring from Button:
    // BTN -> SB -> BB -> UTG -> HJ -> CO
    _SeatMeta('btn', 'Button', Alignment(0, 0.88)),
    _SeatMeta('sb', 'Small Blind', Alignment(-0.46, 0.78)),
    _SeatMeta('bb', 'Big Blind', Alignment(-0.78, 0.48)),
    _SeatMeta('utg', 'UTG', Alignment(-0.78, -0.14)),
    _SeatMeta('hj', 'Hijack', Alignment(0, -0.88)),
    _SeatMeta('co', 'Cutoff', Alignment(0.78, -0.14)),
  ];

  static const List<_IntakeStep> _steps = <_IntakeStep>[
    _IntakeStep(
      prompt: 'Find the Button seat.',
      hint: 'Dealer button is at the bottom center.',
      expectedSeatId: 'btn',
    ),
    _IntakeStep(
      prompt: 'Find the Small Blind seat.',
      hint: 'Small Blind is left of the Button.',
      expectedSeatId: 'sb',
    ),
    _IntakeStep(
      prompt: 'Find the Big Blind seat.',
      hint: 'Big Blind is right of the Small Blind.',
      expectedSeatId: 'bb',
    ),
    _IntakeStep(
      prompt: 'Skip the empty spot and tap the next active player.',
      hint: 'Ignore empty seats while counting.',
      expectedSeatId: 'hj',
    ),
    _IntakeStep(
      prompt: 'Tap the late-position seat just before the Button.',
      hint: 'Use the upper-left seat at this table.',
      expectedSeatId: 'co',
    ),
    _IntakeStep(
      prompt: 'Return to Button to restart the order.',
      hint: 'Button remains your position reference.',
      expectedSeatId: 'btn',
    ),
    _IntakeStep(
      prompt: 'Finish by tapping Big Blind.',
      hint: 'Big Blind closes this quick intake.',
      expectedSeatId: 'bb',
    ),
  ];

  static const List<_IntakeStep> _placementSteps = <_IntakeStep>[
    _IntakeStep(
      prompt: 'Placement 1/3: where is the dealer anchor?',
      hint: 'Use the bottom center seat.',
      expectedSeatId: 'btn',
    ),
    _IntakeStep(
      prompt: 'Placement 2/3: identify Small Blind.',
      hint: 'Small Blind is left of Button.',
      expectedSeatId: 'sb',
    ),
    _IntakeStep(
      prompt: 'Placement 3/3: identify Big Blind.',
      hint: 'Big Blind is right of Small Blind.',
      expectedSeatId: 'bb',
    ),
  ];

  int _stepIndex = 0;
  int _wrongAttempts = 0;
  String? _selectedSeatId;
  String? _feedback;
  bool _showHint = false;
  bool _intakeCompleted = false;
  bool _startInProgress = false;
  bool _todayPrimaryRouteInProgressV1 = false;
  bool _intakeSubmitInProgress = false;
  String _skillBand = 'beginner';
  int _placementScore = 0;
  int _placementStepIndex = 0;
  bool _placementStageActive = false;
  int _freeRollRemaining = ProgressService.freeRollInitialSessions;
  String? _focusLabel;
  PersonalizedRecommendationV1? _sharedRecentActivityRecommendationV1;
  List<RecentTelemetrySignalV1> _sharedRecentActivitySignalsV1 =
      const <RecentTelemetrySignalV1>[];
  LatestSessionOutcomeSnapshotV1? _sharedRecentActivityLatestSessionV1;
  WorldMasteryLevelV1? _sharedRecentActivityWorldMasteryLevelV1;
  WeaknessConfidenceAssessmentV1? _sharedRecentActivityWeaknessAssessmentV1;
  bool _reviewDue = false;
  bool _spineCalibrationCompleted = false;
  int? _spineCalibrationBand;
  String? _spineActivePackId;
  int _spineNextHandIndex = 0;
  int _bankrollBalance = ProgressService.bankrollCap;
  int _bankrollCap = ProgressService.bankrollCap;
  int _bankrollMinutesToRegen = 0;
  int _campaignCompletedHands = 0;
  int _campaignTotalHands = 0;
  String _campaignSegmentLabel = 'Campaign';
  String _campaignRankLabel = 'Tadpole';
  String _campaignRankHint = '';
  int _campaignBankroll = ProgressService.bankrollCap;
  String _nextSpinePackIdV1 = '';
  bool _campaignBusted = false;
  bool _campaignBackerAvailable = true;
  String _campaignBlockedReason = '';
  bool _campaignComplete = false;
  bool _campaignBackerInProgress = false;
  String _ssotNextPackIdForReviewV1 = '';
  bool _hasReviewQueueForSsotNextPackV1 = false;
  bool _todayCompletedV1 = false;
  bool _gauntletPlayedTodayV1 = false;
  bool _leaksDueTodayV1 = false;
  String? _cohortPromotionBannerTextV1;
  DateTime _decisionStartedAt = DateTime.now().toUtc();
  PlacementResultV1? _placementResultV1;
  PlacementRouteV1? _placementRouteV1;
  TrialStatusV1? _trialStatusV1;
  SubscriptionStatusV1? _subscriptionStatusV1;
  bool _trialStartInProgressV1 = false;
  bool _firstSessionTrustImpressionLoggedV1 = false;
  bool _firstSessionTrustStartedLoggedV1 = false;

  _IntakeStep get _activeStep => _placementStageActive
      ? _placementSteps[_placementStepIndex]
      : _steps[_stepIndex];
  int get _activeStepNumber =>
      _placementStageActive ? _placementStepIndex + 1 : _stepIndex + 1;
  int get _activeStepTotal =>
      _placementStageActive ? _placementSteps.length : _steps.length;
  double get _progress =>
      (_activeStepNumber / _activeStepTotal).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    ProgressService.intakeFlowActiveInSession = false;
    WidgetsBinding.instance.addObserver(this);
    EntitlementSyncV1.revision.addListener(_handleEntitlementSyncV1);
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    EntitlementSyncV1.revision.removeListener(_handleEntitlementSyncV1);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshEntitlementStateV1());
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _bootstrap() async {
    final intakeCompleted = await ProgressService.isIntakeCompleted();
    final profile = await ProgressService.getIntakeProfile();
    final skillBand = await ProgressService.getSkillBandV1();
    final placementScore = await ProgressService.getPlacementScoreV1();
    final placementResult = await PlacementServiceV1.getLastResultV1();
    final placementRoute = await PlacementServiceV1.getLastRouteV1();
    final nowEpochMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final trialStatus = await TrialServiceV1.getTrialStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final subscriptionStatus = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final freeRollRemaining = await ProgressService.getFreeRollRemainingV1();
    final spineCalibrationCompleted =
        await ProgressService.isSpineCalibrationCompletedV1();
    final spineCalibrationBand =
        await ProgressService.getSpineCalibrationBandV1();
    final spineActivePackId = await ProgressService.getSpineActivePackIdV1();
    final spineNextHandIndex = await ProgressService.getSpineNextHandIndexV1();
    final campaignCompletedHands =
        await ProgressService.completedHandsInCampaignV1();
    final campaignTotalHands = await ProgressService.totalHandsInCampaignV1();
    final campaignSegmentLabel = await ProgressService.currentSegmentLabelV1();
    final campaignRankLabel = await ProgressService.campaignRankLabelV1();
    final campaignRankHint =
        await ProgressService.campaignNextRankUnlockHintV1();
    final nextSpinePackIdV1 = await ProgressService.getNextSpinePackToRunV1();
    final campaignBankroll =
        await ProgressService.getCampaignBankrollBalanceV1();
    final campaignBusted = await ProgressService.isCampaignBustedV1();
    final campaignBackerAvailable = await ProgressService.canUseBackerNowV1();
    final campaignBlockedReason = campaignBusted && !campaignBackerAvailable
        ? await ProgressService.backerCooldownRemainingLabelV1()
        : '';
    final campaignComplete = await ProgressService.isCampaignCompleteV1();
    final ssotNextPackIdForReviewV1 =
        await _resolveEarliestIncompletePackIdV1();
    final hasReviewQueueForSsotNextPackV1 =
        ssotNextPackIdForReviewV1.trim().isEmpty
        ? false
        : await ProgressService.hasReviewQueueForPackV1(
            ssotNextPackIdForReviewV1,
          );
    String? cohortPromotionBannerTextV1;
    if (intakeCompleted) {
      final event = await ProgressService.consumeLatestPromotionEventV1(
        utcDayKey: _utcDayKeyNowV1(),
      );
      if (event != null) {
        cohortPromotionBannerTextV1 =
            'Promoted to ${event.toCohort.toUpperCase()}';
      }
    }
    final focusLabel =
        (profile?['focusLabel'] as String?) ??
        await ProgressService.getLessonFocusLabel();
    final sharedRecentActivityRecommendation =
        await _resolveSharedRecentActivityRecommendationV1();
    if (!mounted) return;
    final reviewDue = await _isReviewDueForFocus(focusLabel);
    if (!mounted) return;
    setState(() {
      _intakeCompleted = intakeCompleted;
      _skillBand = (skillBand ?? 'beginner');
      _placementScore = placementScore ?? 0;
      _freeRollRemaining = freeRollRemaining;
      _focusLabel = focusLabel;
      _sharedRecentActivityRecommendationV1 =
          sharedRecentActivityRecommendation;
      _reviewDue = reviewDue;
      _spineCalibrationCompleted = spineCalibrationCompleted;
      _spineCalibrationBand = spineCalibrationBand;
      _spineActivePackId = spineActivePackId;
      _spineNextHandIndex = spineNextHandIndex;
      _campaignCompletedHands = campaignCompletedHands;
      _campaignTotalHands = campaignTotalHands;
      _campaignSegmentLabel = campaignSegmentLabel;
      _campaignRankLabel = campaignRankLabel;
      _campaignRankHint = campaignRankHint;
      _nextSpinePackIdV1 = nextSpinePackIdV1;
      _campaignBankroll = campaignBankroll;
      _campaignBusted = campaignBusted;
      _campaignBackerAvailable = campaignBackerAvailable;
      _campaignBlockedReason = campaignBlockedReason;
      _campaignComplete = campaignComplete;
      _ssotNextPackIdForReviewV1 = ssotNextPackIdForReviewV1;
      _hasReviewQueueForSsotNextPackV1 = hasReviewQueueForSsotNextPackV1;
      _cohortPromotionBannerTextV1 = cohortPromotionBannerTextV1;
      _decisionStartedAt = DateTime.now().toUtc();
      _placementResultV1 = placementResult;
      _placementRouteV1 = placementRoute;
      _trialStatusV1 = trialStatus;
      _subscriptionStatusV1 = subscriptionStatus;
    });
    await _refreshTodayCompletedStateV1();
    if (intakeCompleted) {
      await ProgressService.applyDailyDripTxnV1(utcDayKey: _utcDayKeyNowV1());
      await _refreshTodayCompletedStateV1();
    }
    await _refreshBankrollStatus(emitRegenTelemetry: true);
    if (!intakeCompleted) {
      final startingBand = (skillBand ?? 'beginner').trim().toLowerCase();
      final totalItems = _placementTotalItemsForBandV1(startingBand);
      await PlacementServiceV1.startPlacementV1(totalItems: totalItems);
      _emitTelemetry(TelemetryEvents.intakeStart, <String, dynamic>{
        'surface': 'universal_intake_plan',
        'steps_total': _steps.length,
      });
      _emitTelemetry('placement_start_v1', <String, dynamic>{
        'schemaVersion': 1,
        'skillBand': startingBand,
        'totalItems': totalItems,
      });
    }
    if (intakeCompleted) {
      await _maybeEmitTrialStatusTelemetryV1();
    }
  }

  void _handleEntitlementSyncV1() {
    unawaited(_refreshEntitlementStateV1());
  }

  Future<void> _refreshEntitlementStateV1() async {
    final nowEpochMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final trialStatus = await TrialServiceV1.getTrialStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final subscriptionStatus = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs,
    );
    if (!mounted) return;
    setState(() {
      _trialStatusV1 = trialStatus;
      _subscriptionStatusV1 = subscriptionStatus;
    });
  }

  Future<void> _refreshBankrollStatus({bool emitRegenTelemetry = false}) async {
    final status = await ProgressService.getBankrollStatus();
    final freeRollRemaining = await ProgressService.getFreeRollRemainingV1();
    if (emitRegenTelemetry && status.regenApplied > 0) {
      _emitTelemetry(TelemetryEvents.bankrollRegenApplied, <String, dynamic>{
        'amount': status.regenApplied,
        'balance_after': status.balance,
      });
    }
    if (!mounted) return;
    setState(() {
      _bankrollBalance = status.balance;
      _bankrollCap = status.cap;
      _bankrollMinutesToRegen = status.minutesUntilNextRegen;
      _freeRollRemaining = freeRollRemaining;
    });
  }

  Future<void> _refreshCampaignProgress() async {
    final completedHands = await ProgressService.completedHandsInCampaignV1();
    final totalHands = await ProgressService.totalHandsInCampaignV1();
    final segmentLabel = await ProgressService.currentSegmentLabelV1();
    final rankLabel = await ProgressService.campaignRankLabelV1();
    final rankHint = await ProgressService.campaignNextRankUnlockHintV1();
    final campaignBankroll =
        await ProgressService.getCampaignBankrollBalanceV1();
    final campaignBusted = await ProgressService.isCampaignBustedV1();
    final campaignBackerAvailable = await ProgressService.canUseBackerNowV1();
    final campaignBlockedReason = campaignBusted && !campaignBackerAvailable
        ? await ProgressService.backerCooldownRemainingLabelV1()
        : '';
    final campaignComplete = await ProgressService.isCampaignCompleteV1();
    final nextSpinePackIdV1 = await ProgressService.getNextSpinePackToRunV1();
    final ssotNextPackIdForReviewV1 =
        await _resolveEarliestIncompletePackIdV1();
    final hasReviewQueueForSsotNextPackV1 =
        ssotNextPackIdForReviewV1.trim().isEmpty
        ? false
        : await ProgressService.hasReviewQueueForPackV1(
            ssotNextPackIdForReviewV1,
          );
    if (!mounted) return;
    setState(() {
      _campaignCompletedHands = completedHands;
      _campaignTotalHands = totalHands;
      _campaignSegmentLabel = segmentLabel;
      _campaignRankLabel = rankLabel;
      _campaignRankHint = rankHint;
      _campaignBankroll = campaignBankroll;
      _campaignBusted = campaignBusted;
      _campaignBackerAvailable = campaignBackerAvailable;
      _campaignBlockedReason = campaignBlockedReason;
      _campaignComplete = campaignComplete;
      _nextSpinePackIdV1 = nextSpinePackIdV1;
      _ssotNextPackIdForReviewV1 = ssotNextPackIdForReviewV1;
      _hasReviewQueueForSsotNextPackV1 = hasReviewQueueForSsotNextPackV1;
    });
  }

  Future<String> _resolveEarliestIncompletePackIdV1() async {
    final completedPackIds = await ProgressService.getSpineCompletedPackIdsV1();
    final fallback = await ProgressService.getNextSpinePackToRunV1();
    return resolveWorld1CanonicalEntryPackIdV1(
      completedPackIds: completedPackIds,
      fallbackPackId: fallback,
    );
  }

  Future<void> _refreshTodayCompletedStateV1() async {
    if (!_intakeCompleted) {
      if (!mounted) return;
      setState(() {
        _todayCompletedV1 = false;
        _gauntletPlayedTodayV1 = false;
        _leaksDueTodayV1 = false;
      });
      return;
    }
    final utcDayKey = _utcDayKeyNowV1();
    final cohort = await ProgressService.getCurrentCohortV1();
    final gauntletCompleted = await ProgressService.isGauntletCompletedV1(
      utcDayKey: utcDayKey,
      cohort: cohort,
    );
    final leaksDue = await ProgressService.isLeaksDueForDayV1(
      utcDayKey: utcDayKey,
    );
    if (!mounted) return;
    setState(() {
      _gauntletPlayedTodayV1 = gauntletCompleted;
      _leaksDueTodayV1 = leaksDue;
      _todayCompletedV1 = gauntletCompleted && !leaksDue;
    });
  }

  Future<void> _consumeCohortPromotionFeedbackV1() async {
    final event = await ProgressService.consumeLatestPromotionEventV1(
      utcDayKey: _utcDayKeyNowV1(),
    );
    if (!mounted) return;
    if (event == null) {
      return;
    }
    setState(() {
      _cohortPromotionBannerTextV1 =
          'Promoted to ${event.toCohort.toUpperCase()}';
    });
  }

  void _emitTelemetry(String name, Map<String, dynamic> payload) {
    unawaited(
      RecentActivitySignalStoreV1.instance.appendSignal(
        name: name,
        payload: Map<String, Object?>.from(payload),
      ),
    );
    unawaited(Telemetry.logEvent(name, payload));
  }

  String _subscriptionSurfaceStatusV1(SubscriptionStatusV1 status) {
    return status.accessState.name;
  }

  String _todayPremiumStatusLineV1(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      SubscriptionAccessStateV1.trial =>
        'Trial active: ${status.trialRemainingDays} days left on premium-target Today routes and World 5+.',
      SubscriptionAccessStateV1.free => kPremiumValuePackageV1.freeRuleLine,
    };
  }

  String _todayPremiumPreviewStatusLineV1(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium is active now on this account.',
      SubscriptionAccessStateV1.trial =>
        'Trial is active now. Premium keeps premium-target Today routes and World 5+ open after the trial ends.',
      SubscriptionAccessStateV1.free =>
        'Free stays on the opening path plus one Today route per UTC day on current main.',
    };
  }

  Future<void> _maybeEmitTrialStatusTelemetryV1() async {
    final nowEpochMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final shouldEmit = await TrialServiceV1.consumeStatusTelemetryForDayV1(
      nowEpochMs: nowEpochMs,
    );
    if (!shouldEmit) return;
    final subscriptionStatus = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final status = await TrialServiceV1.getTrialStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final surfaceStatus = _subscriptionSurfaceStatusV1(subscriptionStatus);
    _emitTelemetry('trial_status_v1', <String, dynamic>{
      'schemaVersion': status.schemaVersion,
      'active': status.isTrialActive,
      'remainingDays': status.remainingDays,
      'eligible': status.isEligible,
      'reason': status.reason,
    });
    _emitTelemetry('premium_surface_impression_v1', <String, dynamic>{
      'schemaVersion': 1,
      'status': surfaceStatus,
      'remainingDays': status.remainingDays,
    });
    if (!mounted) return;
    setState(() {
      _trialStatusV1 = status;
      _subscriptionStatusV1 = subscriptionStatus;
    });
  }

  Future<void> _startTrialFromIntakeV1() async {
    if (_trialStartInProgressV1) return;
    final previous = _trialStatusV1;
    final before = _trialStatusV1;
    _emitTelemetry('trial_cta_clicked_v1', <String, dynamic>{
      'schemaVersion': 1,
      'eligible': before?.isEligible ?? false,
      'reason': before?.reason ?? 'unknown',
    });
    setState(() {
      _trialStartInProgressV1 = true;
    });
    final nowEpochMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final status = await TrialServiceV1.startTrialIfEligibleV1(
      nowEpochMs: nowEpochMs,
    );
    final subscriptionStatus = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs,
    );
    if (status.isTrialActive && !(previous?.isTrialActive ?? false)) {
      _emitTelemetry('trial_started_v1', <String, dynamic>{
        'schemaVersion': 1,
        'startEpochMs': nowEpochMs,
      });
    }
    if (!mounted) return;
    setState(() {
      _trialStatusV1 = status;
      _subscriptionStatusV1 = subscriptionStatus;
      _trialStartInProgressV1 = false;
    });
    await _maybeEmitTrialStatusTelemetryV1();
  }

  Future<void> _openPremiumPreviewV1() async {
    final nowEpochMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final status =
        _subscriptionStatusV1 ??
        await SubscriptionServiceV1.getStatusV1(nowEpochMs: nowEpochMs);
    final surfaceStatus = _subscriptionSurfaceStatusV1(status);
    _emitTelemetry('premium_preview_opened_v1', <String, dynamic>{
      'schemaVersion': 1,
      'status': surfaceStatus,
    });
    if (!mounted) return;
    final paymentService = PaymentService();
    var restoreInProgress = false;
    String? restoreMessage;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kPremiumValuePackageV1.title,
                        key: const Key('today_plan_premium_preview_title_v1'),
                        style: AppTypography.h3.copyWith(
                          color: SharkyTokensV1.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _todayPremiumPreviewStatusLineV1(status),
                        key: const Key(
                          'today_plan_premium_preview_status_line_v1',
                        ),
                        style: AppTypography.body.copyWith(
                          color: SharkyTokensV1.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '- ${kPremiumValuePackageV1.freeRuleLine}',
                        key: const Key(
                          'today_plan_premium_preview_free_line_v1',
                        ),
                        style: AppTypography.body.copyWith(
                          color: SharkyTokensV1.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '- ${kPremiumValuePackageV1.unlockLine}',
                        key: const Key(
                          'today_plan_premium_preview_unlock_line_v1',
                        ),
                        style: AppTypography.body.copyWith(
                          color: SharkyTokensV1.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '- ${kPremiumValuePackageV1.restoreLine}',
                        key: const Key(
                          'today_plan_premium_preview_restore_line_v1',
                        ),
                        style: AppTypography.body.copyWith(
                          color: SharkyTokensV1.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          key: const Key(
                            'today_plan_premium_preview_restore_cta_v1',
                          ),
                          onPressed: restoreInProgress
                              ? null
                              : () async {
                                  setModalState(() {
                                    restoreInProgress = true;
                                    restoreMessage = null;
                                  });
                                  final outcome =
                                      await PremiumRestoreFlowV1.run(
                                        entitlementBefore: status.isEntitled,
                                        performRestore:
                                            paymentService.restorePurchases,
                                        readEntitlementAfter: () {
                                          return EntitlementSSOTV1.instance
                                              .isEntitledToPremiumV1(
                                                nowEpochMs: nowEpochMs,
                                              );
                                        },
                                        readLastError: () =>
                                            paymentService.lastError,
                                      );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  setModalState(() {
                                    restoreInProgress = false;
                                    restoreMessage = outcome.message;
                                  });
                                },
                          child: Text(
                            restoreInProgress
                                ? 'RESTORING...'
                                : 'Restore purchases',
                            style: AppTypography.caption.copyWith(
                              color: SharkyTokensV1.brandPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (restoreMessage != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          restoreMessage!,
                          key: const Key(
                            'today_plan_premium_preview_restore_status_v1',
                          ),
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    await _refreshEntitlementStateV1();
  }

  Future<void> _setSkillBand(String band) async {
    if (band == _skillBand) return;
    await ProgressService.setSkillBandV1(band);
    if (!_intakeCompleted) {
      final totalItems = _placementTotalItemsForBandV1(band);
      await PlacementServiceV1.startPlacementV1(totalItems: totalItems);
      _emitTelemetry('placement_start_v1', <String, dynamic>{
        'schemaVersion': 1,
        'skillBand': band.trim().toLowerCase(),
        'totalItems': totalItems,
      });
    }
    if (!mounted) return;
    setState(() {
      _skillBand = band;
      _placementScore = 0;
      _placementStageActive = false;
      _placementStepIndex = 0;
      _showHint = false;
      _feedback = null;
      _selectedSeatId = null;
    });
    _emitTelemetry(TelemetryEvents.placementSkillBandSet, <String, dynamic>{
      'band': band,
    });
  }

  int _elapsedMs(DateTime from) {
    return DateTime.now().toUtc().difference(from).inMilliseconds;
  }

  int _placementTotalItemsForBandV1(String band) {
    final normalized = band.trim().toLowerCase();
    final placementItems = normalized == 'beginner'
        ? 0
        : _placementSteps.length;
    return _steps.length + placementItems;
  }

  void _onSeatTap(String seatId) {
    UiSoundV1.fire(UiSoundEventV1.tap);
    setState(() {
      _selectedSeatId = seatId;
      _feedback = null;
    });
  }

  Future<void> _onCheck() async {
    if (_intakeSubmitInProgress) return;
    final selected = _selectedSeatId;
    if (selected == null) {
      setState(() {
        _feedback = 'Select a seat first.';
      });
      return;
    }
    final decisionMs = _elapsedMs(_decisionStartedAt);
    final currentStep = _activeStep;
    final isCorrect = selected == currentStep.expectedSeatId;

    _emitTelemetry('user_choice', <String, dynamic>{
      'surface': 'universal_intake_plan',
      'step_index': _stepIndex,
      'choice': selected,
    });

    if (!isCorrect) {
      await PlacementServiceV1.recordAnswerV1(
        correct: false,
        decisionMs: decisionMs,
      );
      UiSoundV1.fire(UiSoundEventV1.error);
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      _wrongAttempts += 1;
      _emitTelemetry('correct', <String, dynamic>{
        'surface': 'universal_intake_plan',
        'step_index': _stepIndex,
        'correct': false,
        'error_type': 'incorrect_seat',
      });
      setState(() {
        _showHint = true;
        _feedback = 'Not yet. Try again.';
      });
      return;
    }

    await PlacementServiceV1.recordAnswerV1(
      correct: true,
      decisionMs: decisionMs,
    );

    if (_placementStageActive) {
      final nextPlacementScore = _placementScore + 1;
      if (_placementStepIndex >= _placementSteps.length - 1) {
        await ProgressService.setPlacementScoreV1(nextPlacementScore);
        _emitTelemetry(
          TelemetryEvents.placementTestCompleted,
          <String, dynamic>{
            'band': _skillBand,
            'score': nextPlacementScore,
            'steps_total': _placementSteps.length,
          },
        );
        setState(() {
          _placementScore = nextPlacementScore;
          _placementStageActive = false;
          _selectedSeatId = null;
          _showHint = false;
          _feedback = null;
          _decisionStartedAt = DateTime.now().toUtc();
        });
        _intakeSubmitInProgress = true;
        await _completeIntake();
        _intakeSubmitInProgress = false;
        return;
      }
      setState(() {
        _placementScore = nextPlacementScore;
        _placementStepIndex += 1;
        _selectedSeatId = null;
        _showHint = false;
        _feedback = null;
        _decisionStartedAt = DateTime.now().toUtc();
      });
      return;
    }

    UiSoundV1.fire(UiSoundEventV1.success);
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
    _emitTelemetry('correct', <String, dynamic>{
      'surface': 'universal_intake_plan',
      'step_index': _stepIndex,
      'correct': true,
      'error_type': 'none',
    });
    _emitTelemetry('time_to_decision', <String, dynamic>{
      'surface': 'universal_intake_plan',
      'step_index': _stepIndex,
      'time_to_decision_ms': decisionMs,
    });

    if (_stepIndex >= _steps.length - 1) {
      if (_skillBand != 'beginner') {
        setState(() {
          _placementScore = 0;
          _placementStepIndex = 0;
          _placementStageActive = true;
          _selectedSeatId = null;
          _showHint = false;
          _feedback = null;
          _decisionStartedAt = DateTime.now().toUtc();
        });
        return;
      }
      _intakeSubmitInProgress = true;
      await _completeIntake();
      _intakeSubmitInProgress = false;
      return;
    }

    setState(() {
      _stepIndex += 1;
      _selectedSeatId = null;
      _showHint = false;
      _feedback = null;
      _decisionStartedAt = DateTime.now().toUtc();
    });
  }

  Future<void> _completeIntake() async {
    final errorClass = _wrongAttempts > 0 ? 'wrong_action' : 'none';
    final focusLabel = errorClass == 'none'
        ? 'baseline'
        : (focusLabelForPhase1Error(errorClass) ?? 'range');
    final profile = <String, Object?>{
      'version': 'v1',
      'completedAt': DateTime.now().toUtc().toIso8601String(),
      'steps': _steps.length,
      'wrongAttempts': _wrongAttempts,
      'errorClass': errorClass,
      'focusLabel': focusLabel,
      'skillBand': _skillBand,
      'placementScore': _placementScore,
    };

    await ProgressService.saveIntakeProfile(profile);
    await ProgressService.setLessonFocusLabel(focusLabel);
    await ProgressService.setSkillBandV1(_skillBand);
    await ProgressService.setPlacementScoreV1(_placementScore);
    final placementResult = await PlacementServiceV1.finishPlacementV1(
      skillBand: _skillBand,
    );
    final placementRoute = await PlacementServiceV1.computePlacementRouteV1(
      placementResult,
    );
    final placementMetrics = await PlacementServiceV1.getLastResultMetricsV1();
    _emitTelemetry('placement_end_v1', <String, dynamic>{
      'schemaVersion': placementResult.schemaVersion,
      'bucket': placementResult.bucket.name,
      'confidence': placementResult.confidence,
      'weakAreasCount': placementResult.weakAreas.length,
      'durationMs': placementMetrics['durationMs'] ?? 0,
      'correctCount': placementMetrics['correctCount'] ?? 0,
      'totalCount': placementMetrics['totalCount'] ?? 0,
    });
    _emitTelemetry('placement_route_selected_v1', <String, dynamic>{
      'schemaVersion': placementRoute.schemaVersion,
      'bucket': placementResult.bucket.name,
      'confidence': placementResult.confidence,
      'startTargetSessionId': placementRoute.startTargetSessionId,
      'repairSessionId': placementRoute.repairSessionId,
      'reasonCodesCount': placementRoute.reasonCodes.length,
    });
    await TrialServiceV1.markPlacementCompletedV1();
    final nowEpochMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final trialStatus = await TrialServiceV1.getTrialStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final subscriptionStatus = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final sharedRecentActivityRecommendation =
        await _resolveSharedRecentActivityRecommendationV1();
    if (trialStatus.isEligible) {
      final shouldEmitOffer =
          await TrialServiceV1.consumeOfferShownTelemetryTokenV1();
      if (shouldEmitOffer) {
        _emitTelemetry('trial_offer_shown_v1', <String, dynamic>{
          'schemaVersion': 1,
          'eligible': true,
          'reason': trialStatus.reason,
        });
      }
    }

    _emitTelemetry(TelemetryEvents.intakeComplete, <String, dynamic>{
      'surface': 'universal_intake_plan',
      'steps_total': _steps.length,
      'wrong_attempts': _wrongAttempts,
      'focus_label': focusLabel,
      'error_type': errorClass,
    });

    if (!mounted) return;
    final reviewDue = await _isReviewDueForFocus(focusLabel);
    if (!mounted) return;
    setState(() {
      _focusLabel = focusLabel;
      _intakeCompleted = true;
      _reviewDue = reviewDue;
      _selectedSeatId = null;
      _showHint = false;
      _feedback = null;
      _placementResultV1 = placementResult;
      _placementRouteV1 = placementRoute;
      _sharedRecentActivityRecommendationV1 =
          sharedRecentActivityRecommendation;
      _trialStatusV1 = trialStatus;
      _subscriptionStatusV1 = subscriptionStatus;
    });
    await _refreshBankrollStatus(emitRegenTelemetry: true);
    await _maybeEmitTrialStatusTelemetryV1();
  }

  Future<PersonalizedRecommendationV1?>
  _resolveSharedRecentActivityRecommendationV1() async {
    final signals = await RecentActivitySignalStoreV1.instance.loadSignals();
    _sharedRecentActivitySignalsV1 = signals;
    if (signals.isEmpty) {
      _sharedRecentActivityLatestSessionV1 = null;
      _sharedRecentActivityWorldMasteryLevelV1 = null;
      _sharedRecentActivityWeaknessAssessmentV1 = null;
      return null;
    }
    final baseRecommendation = RecentActivityPersonalizationV1.infer(
      RecentActivityPersonalizationInputV1(
        signals: signals,
        isCampaignSession: false,
      ),
    );
    final latestSessionSnapshotV1 =
        await ProgressionQualityGateV1.loadLatestSessionSnapshot();
    _sharedRecentActivityLatestSessionV1 = latestSessionSnapshotV1;
    _sharedRecentActivityWorldMasteryLevelV1 = latestSessionSnapshotV1 == null
        ? null
        : await ProgressService.getWorldMasteryForPackV1(
            latestSessionSnapshotV1.moduleId,
          );
    final progressionFitRecommendation = ProgressionQualityGateV1.apply(
      recommendation: baseRecommendation,
      latestSession: latestSessionSnapshotV1,
      recentSignals: signals,
    );
    final weaknessHistory = await WeaknessConfidenceLayerV1.loadHistory();
    _sharedRecentActivityWeaknessAssessmentV1 =
        WeaknessConfidenceLayerV1.assess(
          recommendation: progressionFitRecommendation,
          latestSession: latestSessionSnapshotV1,
          recentSignals: signals,
          history: weaknessHistory,
        );
    return WeaknessConfidenceLayerV1.apply(
      recommendation: progressionFitRecommendation,
      latestSession: latestSessionSnapshotV1,
      recentSignals: signals,
      history: weaknessHistory,
    );
  }

  String _recommendedModuleId() {
    final activePack = _spineActivePackId;
    final hasActiveCampaignPack =
        activePack != null && activePack.trim().isNotEmpty;
    if (!hasActiveCampaignPack &&
        !_hasReviewQueueForSsotNextPackV1 &&
        _reviewDue &&
        (_focusLabel ?? '').trim().isNotEmpty) {
      return recommendedModuleIdForFocus(
        focusLabel: _focusLabel,
        reviewDue: _reviewDue,
        skillBand: _skillBand,
        placementScore: _placementScore,
      );
    }
    final ssotNextPack = _ssotNextPackIdForReviewV1.trim();
    if (ssotNextPack.isNotEmpty) {
      return ssotNextPack;
    }
    if (activePack != null && activePack.trim().isNotEmpty) {
      return activePack;
    }
    if (_spineCalibrationCompleted) {
      return campaignNextPackIdForBandV1(
        _spineCalibrationBand ?? ProgressService.spineCalibrationBandBeginner,
      );
    }
    return 'world1_act0_table_literacy';
  }

  Future<bool> _isReviewDueForFocus(String? focusLabel) async {
    if (focusLabel == null || focusLabel.trim().isEmpty) {
      return false;
    }
    return ProgressService.isFocusReviewDue(focusLabel);
  }

  String _recommendedModuleTitle(String moduleId) {
    return recommendedModuleTitleForId(moduleId);
  }

  String _todayPlanRoutingReasonV1(String normalizedNextPackId) {
    return resolveProgressionRouteStoryForPackV1(
      nextPackId: normalizedNextPackId,
      reviewRequired:
          _hasReviewQueueForSsotNextPackV1 &&
          _ssotNextPackIdForReviewV1.trim().isNotEmpty,
      activePackId: _spineActivePackId ?? '',
      nextHandIndex: _spineNextHandIndex,
      rhythmReason: 'Review required',
    ).reasonLine;
  }

  void _logFirstSessionTrustImpressionIfNeededV1(
    FirstSessionTrustPlanContractV1 contract,
    String moduleId,
  ) {
    if (_firstSessionTrustImpressionLoggedV1) {
      return;
    }
    _firstSessionTrustImpressionLoggedV1 = true;
    unawaited(
      Telemetry.logEvent(
        TelemetryEvents.firstSessionTrustImpressionV1,
        <String, dynamic>{
          'module_id': moduleId,
          'surface': 'today_plan',
          'primary_cta': _startCtaLabel,
          'promise_line': contract.promiseLine,
          'success_line': contract.successLine,
          'sharky_line': contract.sharkyLine,
        },
      ),
    );
  }

  Future<void> _logFirstSessionTrustStartedIfNeededV1({
    required String moduleId,
    required String source,
  }) async {
    if (_firstSessionTrustStartedLoggedV1) {
      return;
    }
    final contract = resolveFirstSessionTrustPlanContractV1(moduleId);
    if (contract == null) {
      return;
    }
    _firstSessionTrustStartedLoggedV1 = true;
    await Telemetry.logEvent(
      TelemetryEvents.firstSessionTrustStartedV1,
      <String, dynamic>{
        'module_id': moduleId,
        'surface': 'today_plan',
        'source': source,
        'primary_cta': _startCtaLabel,
        'sharky_line': contract.sharkyLine,
      },
    );
  }

  String _primaryRoutePackIdForPlanV1() {
    final normalized = _nextSpinePackIdV1.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return _recommendedModuleId();
  }

  String _sharedRecentActivityHeadlineV1(
    PersonalizedRecommendationV1 recommendation,
  ) {
    final continuation = _sharedRecentActivityContinuationV1();
    if (continuation != null) {
      return continuation.targetLabel;
    }
    final moduleId = recommendation.recommendedNextSessionTarget.trim();
    return _recommendedModuleTitle(moduleId);
  }

  String _sharedRecentActivityCtaLabelV1(
    PersonalizedRecommendationV1 recommendation,
  ) {
    final continuation = _sharedRecentActivityContinuationV1();
    if (continuation != null) {
      return continuation.ctaLabel;
    }
    return learnerJourneyPersonalizedActionCtaLabelV1(
      recommendation.recommendedNextAction,
    );
  }

  LearningContinuationV1? _sharedRecentActivityContinuationV1() {
    return LearningContinuationFactoryV1.fromPersonalizedRecommendation(
      recommendation: _sharedRecentActivityRecommendationV1,
      resolveModuleTitle: _recommendedModuleTitle,
      recentSignals: _sharedRecentActivitySignalsV1,
    );
  }

  String _sharedRecentActivityTitleV1() {
    final continuation = _sharedRecentActivityContinuationV1();
    if (continuation?.weakPatternReview != null) {
      return learnerJourneyReviewSurfaceTitleV1();
    }
    return 'Recent focus';
  }

  Future<void> _startSharedRecentActivityRecommendationV1() async {
    final continuation = _sharedRecentActivityContinuationV1();
    if (continuation == null) return;
    final moduleId = continuation.targetEntryId.trim();
    if (moduleId.isEmpty) return;
    final isEntitled = await EntitlementSSOTV1.instance.isEntitledToPremiumV1();
    if (_isPremiumProgressionWorldV1(_worldIndexFromModuleIdV1(moduleId)) &&
        !isEntitled) {
      await _openPremiumPreviewV1();
      return;
    }
    final tierConfig = await _consumeTodayTierConfigV1(moduleId);
    await _startTodayEntryTargetV1(
      moduleId,
      source: 'recent_activity_recommendation',
      hintsEnabledV1: !tierConfig.hintsOff,
      continuationV1: continuation,
    );
    await _refreshBankrollStatus();
    await _refreshCampaignProgress();
    await _refreshTodayCompletedStateV1();
  }

  bool get _startBlocked => false;
  String get _startCtaLabel {
    if (_hasReviewQueueForSsotNextPackV1 &&
        _ssotNextPackIdForReviewV1.trim().isNotEmpty) {
      return 'REVIEW MISSED';
    }
    if (_intakeCompleted && _todayCompletedV1) {
      return 'PRACTICE';
    }
    if (_campaignComplete) {
      return 'REPLAY CAMPAIGN';
    }
    return resolveProgressionRouteStoryForPackV1(
      nextPackId: _primaryRoutePackIdForPlanV1(),
      reviewRequired: false,
      activePackId: _spineActivePackId ?? '',
      nextHandIndex: _spineNextHandIndex,
      rhythmReason: '',
    ).ctaLabel;
  }

  Future<void> _startSessionForModule(
    String moduleId, {
    required String source,
    String? forcedFocusLabel,
    int? startHandIndex,
    bool hintsEnabledV1 = true,
    ProgressionHandoffContextV1? handoffContextV1,
  }) async {
    if (_startInProgress) return;
    _startInProgress = true;
    ProgressService.intakeFlowActiveInSession = true;
    final moduleTitle = _recommendedModuleTitle(moduleId);
    if (forcedFocusLabel != null && forcedFocusLabel.trim().isNotEmpty) {
      await ProgressService.setLessonFocusLabel(forcedFocusLabel);
    }

    await pushReplacementWorld1FoundationsRunnerV1<void, void>(
      context,
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      mode: kWorld1RunnerModeCampaignSpine,
      startHandIndex: startHandIndex ?? 0,
      hintsEnabledV1: hintsEnabledV1,
      handoffContextV1: handoffContextV1,
    );
    ProgressService.intakeFlowActiveInSession = false;
    final latestFocus = await ProgressService.getLessonFocusLabel();
    final spineCalibrationCompleted =
        await ProgressService.isSpineCalibrationCompletedV1();
    final spineCalibrationBand =
        await ProgressService.getSpineCalibrationBandV1();
    final spineActivePackId = await ProgressService.getSpineActivePackIdV1();
    final spineNextHandIndex = await ProgressService.getSpineNextHandIndexV1();
    if (!mounted) return;
    final reviewDue = await _isReviewDueForFocus(latestFocus ?? _focusLabel);
    if (!mounted) return;
    final campaignCompletedHands =
        await ProgressService.completedHandsInCampaignV1();
    final campaignTotalHands = await ProgressService.totalHandsInCampaignV1();
    final campaignSegmentLabel = await ProgressService.currentSegmentLabelV1();
    if (!mounted) return;
    setState(() {
      _focusLabel = latestFocus ?? _focusLabel;
      _reviewDue = reviewDue;
      _spineCalibrationCompleted = spineCalibrationCompleted;
      _spineCalibrationBand = spineCalibrationBand;
      _spineActivePackId = spineActivePackId;
      _spineNextHandIndex = spineNextHandIndex;
      _campaignCompletedHands = campaignCompletedHands;
      _campaignTotalHands = campaignTotalHands;
      _campaignSegmentLabel = campaignSegmentLabel;
    });
    _startInProgress = false;
  }

  bool _isCanonicalDirectSessionEntryTargetV1(String entryId) {
    return canonical_truth.canonicalTruthIsPlayableSessionEntryIdV1(entryId);
  }

  Future<CanonicalLandingDecisionV1> _resolveCanonicalTodayLandingDecisionV1({
    required String canonicalEntryPackId,
    bool allowReviewQueue = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEntryPackId = canonicalEntryPackId.trim();
    final checkpointStateV1 =
        await ProgressService.getCheckpointProgressStateV1();
    final activePackId =
        _spineActivePackId ?? await ProgressService.getSpineActivePackIdV1();
    final nextHandIndex = _spineNextHandIndex > 0
        ? _spineNextHandIndex
        : await ProgressService.getSpineNextHandIndexV1();
    final hasReviewQueueForCanonicalEntryPack =
        allowReviewQueue && normalizedEntryPackId.isNotEmpty
        ? await ProgressService.hasReviewQueueForPackV1(normalizedEntryPackId)
        : false;
    return resolveCanonicalLandingDecisionV1(
      CanonicalLandingDecisionInputsV1(
        onboardingCompleted: prefs.getBool('onboardingCompleted') ?? false,
        intakeCompleted: await ProgressService.isIntakeCompleted(),
        campaignComplete: await ProgressService.isCampaignCompleteV1(),
        checkpointPending: checkpointStateV1.checkpointPending,
        nextPackId: normalizedEntryPackId,
        canonicalEntryPackId: normalizedEntryPackId,
        hasReviewQueueForCanonicalEntryPack:
            hasReviewQueueForCanonicalEntryPack,
        activePackId: activePackId ?? '',
        currentPackId: activePackId ?? '',
        nextHandIndex: nextHandIndex,
        source: CanonicalLandingSourceV1.todayStart,
      ),
    );
  }

  Future<void> _startTodayEntryTargetV1(
    String entryId, {
    required String source,
    bool hintsEnabledV1 = true,
    LearningContinuationV1? continuationV1,
  }) async {
    final landingDecision = await _resolveCanonicalTodayLandingDecisionV1(
      canonicalEntryPackId: entryId,
      allowReviewQueue: false,
    );
    final resolvedEntryId = landingDecision.entryId.trim();
    if (resolvedEntryId.isEmpty) return;
    await _logFirstSessionTrustStartedIfNeededV1(
      moduleId: resolvedEntryId,
      source: source,
    );
    final handoffContextV1 = continuationV1 == null
        ? buildProgressionHandoffContextForPackV1(entryId)
        : LearningContinuationFactoryV1.buildHandoffContext(
            entryId: entryId,
            continuation: continuationV1,
          );
    if (resolvedEntryId == actionOrderBtnLastModuleId) {
      if (_startInProgress || !mounted) return;
      _startInProgress = true;
      ProgressService.intakeFlowActiveInSession = true;
      await navigateToTheorySession(
        context,
        resolvedEntryId,
        handoffContextV1: handoffContextV1,
      );
      ProgressService.intakeFlowActiveInSession = false;
      _startInProgress = false;
      return;
    }
    if (landingDecision.surfaceKind ==
        CanonicalLandingSurfaceKindV1.directSessionLaunch) {
      if (_startInProgress || !mounted) return;
      _startInProgress = true;
      ProgressService.intakeFlowActiveInSession = true;
      await Navigator.of(context).pushReplacement<void, void>(
        canonicalSessionDrillRouteV1(
          sessionId: resolvedEntryId,
          handoffContextV1: handoffContextV1,
        ),
      );
      ProgressService.intakeFlowActiveInSession = false;
      _startInProgress = false;
      return;
    }
    await _startSessionForModule(
      resolvedEntryId,
      source: source,
      startHandIndex: landingDecision.startHandIndex,
      hintsEnabledV1: hintsEnabledV1,
      handoffContextV1: handoffContextV1,
    );
  }

  Future<void> _startTodayPrimaryRouteV1() async {
    if (_todayPrimaryRouteInProgressV1) {
      return;
    }
    setState(() {
      _todayPrimaryRouteInProgressV1 = true;
    });
    unawaited(AudioService.instance.playUiSfx('click_start'));
    await _logFirstSessionTrustStartedIfNeededV1(
      moduleId: _primaryRoutePackIdForPlanV1(),
      source: 'today_plan_start',
    );
    try {
      if (_campaignBusted) {
        await _refreshCampaignProgress();
        return;
      }
      final reviewPackId = _ssotNextPackIdForReviewV1.trim();
      if (_hasReviewQueueForSsotNextPackV1 && reviewPackId.isNotEmpty) {
        final landingDecision = await _resolveCanonicalTodayLandingDecisionV1(
          canonicalEntryPackId: reviewPackId,
          allowReviewQueue: true,
        );
        if (landingDecision.surfaceKind ==
            CanonicalLandingSurfaceKindV1.campaignReviewQueue) {
          await Navigator.of(
            context,
          ).push(progressMapRouteV1(autoOpenReviewQueueForNextPackV1: true));
          await _refreshBankrollStatus();
          await _refreshCampaignProgress();
          await _refreshTodayCompletedStateV1();
          return;
        }
      }
      final isEntitled = await EntitlementSSOTV1.instance
          .isEntitledToPremiumV1();
      final pendingPlacementSessionId = await _peekNextPlacementSessionIdV1();
      if (pendingPlacementSessionId != null &&
          pendingPlacementSessionId.trim().isNotEmpty &&
          _isPremiumProgressionWorldV1(
            _worldIndexFromSessionIdV1(pendingPlacementSessionId),
          ) &&
          !isEntitled) {
        await _openPremiumPreviewV1();
        return;
      }
      final placementSessionId =
          await PlacementServiceV1.consumeNextPlacementSessionIdV1();
      if (placementSessionId != null && placementSessionId.trim().isNotEmpty) {
        final placementModuleId = _moduleIdForPlacementSessionIdV1(
          placementSessionId,
        );
        if (placementModuleId != null && placementModuleId.isNotEmpty) {
          final tierConfig = await _consumeTodayTierConfigV1(placementModuleId);
          await _startTodayEntryTargetV1(
            placementModuleId,
            source: 'placement_route_start',
            hintsEnabledV1: !tierConfig.hintsOff,
          );
          await _refreshBankrollStatus();
          await _refreshCampaignProgress();
          await _refreshTodayCompletedStateV1();
          return;
        }
      }
      final utcDayKey = _utcDayKeyNowV1();
      final cohort = await ProgressService.getCurrentCohortV1();
      final gauntletPlayedToday = await ProgressService.isGauntletCompletedV1(
        utcDayKey: utcDayKey,
        cohort: cohort,
      );
      final leaksDueToday = await ProgressService.isLeaksDueForDayV1(
        utcDayKey: utcDayKey,
      );
      final todayCompleted = gauntletPlayedToday && !leaksDueToday;
      if (todayCompleted) {
        await Navigator.of(context).push(progressMapRouteV1());
        await _refreshTodayCompletedStateV1();
        return;
      }
      final nextSpinePackId = (await ProgressService.getNextSpinePackToRunV1())
          .trim();
      final recommendedWorldMatch = RegExp(
        r'^world(\d+)_spine_campaign_v1$',
      ).firstMatch(nextSpinePackId);
      final recommendedWorld = int.tryParse(
        recommendedWorldMatch?.group(1) ?? '',
      );
      if (!todayCompleted &&
          recommendedWorld != null &&
          recommendedWorld >= 1) {
        if (_isPremiumProgressionWorldV1(recommendedWorld) && !isEntitled) {
          await _openPremiumPreviewV1();
          return;
        }
        final tierConfig = await _consumeTodayTierConfigV1(nextSpinePackId);
        await _startTodayEntryTargetV1(
          nextSpinePackId,
          source: 'today_plan_start',
          hintsEnabledV1: !tierConfig.hintsOff,
        );
        await _refreshBankrollStatus();
        await _refreshCampaignProgress();
        await _refreshTodayCompletedStateV1();
        return;
      }
      if (!todayCompleted && !leaksDueToday) {
        final moduleId = _recommendedModuleId().trim();
        if (moduleId.isNotEmpty) {
          if (_isPremiumProgressionWorldV1(
                _worldIndexFromModuleIdV1(moduleId),
              ) &&
              !isEntitled) {
            await _openPremiumPreviewV1();
            return;
          }
          final tierConfig = await _consumeTodayTierConfigV1(moduleId);
          await _startTodayEntryTargetV1(
            moduleId,
            source: 'today_plan_start',
            hintsEnabledV1: !tierConfig.hintsOff,
          );
          await _refreshBankrollStatus();
          await _refreshCampaignProgress();
          await _refreshTodayCompletedStateV1();
          return;
        }
      }

      final decision = await TodayRouterV1.resolveFromAssets(
        utcDayKey: utcDayKey,
        cohort: _todayRouterCohortFromStringV1(cohort),
        progress: TodayProgressStateV1(
          gauntletPlayedToday: gauntletPlayedToday,
          leaksEnabled: true,
          leaksDue: leaksDueToday,
        ),
      );
      if (!mounted) return;

      var launchedGauntletStep = false;
      if (decision.kind == TodayRouteKindV1.gauntlet) {
        final gauntletId = decision.gauntletId ?? '';
        if (gauntletId.isNotEmpty) {
          final gauntletMarkdown = await _loadTodayGauntletMarkdownV1(
            gauntletId,
          );
          final allSteps = TodayRouterV1.parseAllStepsFromGauntletMarkdown(
            gauntletMarkdown,
          );
          if (allSteps.isNotEmpty) {
            final persistedStepIndex =
                await ProgressService.getGauntletStepIndexV1(
                  utcDayKey: utcDayKey,
                  cohort: cohort,
                  gauntletId: gauntletId,
                );
            final resumeStepIndex = persistedStepIndex < 0
                ? 0
                : (persistedStepIndex >= allSteps.length
                      ? allSteps.length - 1
                      : persistedStepIndex);
            final step = allSteps[resumeStepIndex];
            final stepType = step.type;
            final stepRef = step.ref;
            if ((stepType == 'module' ||
                    stepType == 'pack' ||
                    stepType == 'checkpoint') &&
                stepRef.isNotEmpty) {
              final tierConfig = await _consumeTodayTierConfigV1(stepRef);
              await ProgressService.applyTodayEntryTxnV1(
                utcDayKey: utcDayKey,
                cohort: cohort,
              );
              await _launchGauntletStepSessionV1(
                utcDayKey: utcDayKey,
                cohort: cohort,
                gauntletId: gauntletId,
                stepIndex: resumeStepIndex,
                stepCount: allSteps.length,
                stepType: stepType,
                stepRef: stepRef,
                source: 'today_plan_start',
                tierConfig: tierConfig,
              );
              launchedGauntletStep = true;
              await _refreshBankrollStatus();
              await _refreshCampaignProgress();
              await _refreshTodayCompletedStateV1();
              return;
            }
          }
        }
        if (!launchedGauntletStep && !todayCompleted) {
          final moduleId = _recommendedModuleId().trim();
          if (moduleId.isNotEmpty) {
            final tierConfig = await _consumeTodayTierConfigV1(moduleId);
            await _startTodayEntryTargetV1(
              moduleId,
              source: 'today_plan_start',
              hintsEnabledV1: !tierConfig.hintsOff,
            );
            await _refreshBankrollStatus();
            await _refreshCampaignProgress();
            await _refreshTodayCompletedStateV1();
            return;
          }
        }
      }

      if (decision.kind == TodayRouteKindV1.leaks) {
        await Navigator.of(
          context,
        ).push(progressMapRouteV1(autoOpenReviewQueueForNextPackV1: true));
        await _refreshTodayCompletedStateV1();
        return;
      }

      if (decision.kind == TodayRouteKindV1.practice && !todayCompleted) {
        final moduleId = _recommendedModuleId().trim();
        if (moduleId.isNotEmpty) {
          final tierConfig = await _consumeTodayTierConfigV1(moduleId);
          await _startTodayEntryTargetV1(
            moduleId,
            source: 'today_plan_start',
            hintsEnabledV1: !tierConfig.hintsOff,
          );
          await _refreshBankrollStatus();
          await _refreshCampaignProgress();
          await _refreshTodayCompletedStateV1();
          return;
        }
      }

      await Navigator.of(context).push(progressMapRouteV1());
      await _refreshTodayCompletedStateV1();
    } finally {
      _todayPrimaryRouteInProgressV1 = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _launchGauntletStepSessionV1({
    required String utcDayKey,
    required String cohort,
    required String gauntletId,
    required int stepIndex,
    required int stepCount,
    required String stepType,
    required String stepRef,
    required String source,
    required MasteryTierConfigV1 tierConfig,
  }) async {
    final launchToken = _gauntletStepIsolationV1.beginFreshStepLaunch(
      gauntletId: gauntletId,
      stepIndex: stepIndex,
      stepType: stepType,
      stepRef: stepRef,
    );
    if (launchToken.stepType == 'review_queue') {
      return;
    }
    await _startSessionForModule(
      launchToken.stepRef,
      source: source,
      startHandIndex: 0,
      hintsEnabledV1: !tierConfig.hintsOff,
    );
    if (!mounted) {
      return;
    }
    final isLastStep = stepIndex >= (stepCount - 1);
    if (isLastStep) {
      await ProgressService.markGauntletCompletedV1(
        utcDayKey: utcDayKey,
        cohort: cohort,
        gauntletId: gauntletId,
      );
      await ProgressService.resetGauntletStepV1(
        utcDayKey: utcDayKey,
        cohort: cohort,
        gauntletId: gauntletId,
      );
    } else {
      await ProgressService.advanceGauntletStepV1(
        utcDayKey: utcDayKey,
        cohort: cohort,
        gauntletId: gauntletId,
        currentStepIndex: stepIndex,
      );
    }
  }

  Future<String> _loadTodayGauntletMarkdownV1(String gauntletId) async {
    final path = 'content/gauntlets/$gauntletId/v1/gauntlet.md';
    try {
      return await rootBundle.loadString(path);
    } on FlutterError {
      return File(path).readAsStringSync();
    }
  }

  TodayRouterCohortV1 _todayRouterCohortFromStringV1(String cohort) {
    switch (cohort) {
      case 'intermediate':
        return TodayRouterCohortV1.intermediate;
      case 'advanced':
        return TodayRouterCohortV1.advanced;
      case 'beginner':
      default:
        return TodayRouterCohortV1.beginner;
    }
  }

  Future<MasteryTierConfigV1> _consumeTodayTierConfigV1(
    String sessionId,
  ) async {
    final config = await ProgressService.masteryTierConfigForSessionIdV1(
      sessionId,
    );
    final forceHigh = _forceHighTierForNextRunV1;
    _forceHighTierForNextRunV1 = false;
    if (forceHigh) {
      return masteryTierConfigForSessionV1(
        sessionId: 'w0.s01',
        progressForWorld: const MasteryProgressV1(
          worldId: 'world0',
          totalSessions: 1,
          completedSessions: 1,
          rollingAccuracy: 1.0,
        ),
      );
    }
    return config;
  }

  Future<void> _confirmEnableHighTierForNextRunV1() async {
    if (_campaignBusted || !_intakeCompleted) return;
    final enabled = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enable High Tier?'),
          content: const Text(
            'High tier turns hints off and applies one-life constraints for the next Today run.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
    if (enabled != true || !mounted) return;
    setState(() {
      _forceHighTierForNextRunV1 = true;
    });
  }

  String _utcDayKeyNowV1() {
    final override = widget.debugUtcDayKeyOverrideV1?.trim();
    if (override != null && override.isNotEmpty) {
      return override;
    }
    final now = DateTime.now().toUtc();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _useCampaignBacker() async {
    if (_campaignBackerInProgress ||
        !_campaignBusted ||
        !_campaignBackerAvailable) {
      return;
    }
    _campaignBackerInProgress = true;
    final before = _campaignBankroll;
    final after = await ProgressService.backerRefillCampaignV1();
    unawaited(AudioService.instance.playUiSfx('backer_refill'));
    _emitTelemetry(TelemetryEvents.campaignBackerUsed, <String, dynamic>{
      'bankroll_before': before,
      'bankroll_after': after,
      'refill_amount': ProgressService.campaignBackerRefillAmountV1,
      'cooldown_minutes': ProgressService.campaignBackerCooldownMinutesV1,
    });
    await _refreshCampaignProgress();
    _campaignBackerInProgress = false;
  }

  String? _moduleIdForPlacementSessionIdV1(String sessionId) {
    final normalized = sessionId.trim().toLowerCase();
    if (_isCanonicalDirectSessionEntryTargetV1(normalized)) {
      return normalized;
    }
    final match = RegExp(r'^w([0-9]+)\.s[0-9]{2}$').firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final worldIndex = int.tryParse(match.group(1) ?? '');
    if (worldIndex == null) {
      return null;
    }
    if (worldIndex <= 1) {
      return 'world1_act0_table_literacy';
    }
    return 'world${worldIndex}_spine_campaign_v1';
  }

  int? _worldIndexFromSessionIdV1(String sessionId) {
    final match = RegExp(
      r'^w([0-9]+)\.s[0-9]{2}$',
    ).firstMatch(sessionId.trim().toLowerCase());
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1) ?? '');
  }

  int? _worldIndexFromModuleIdV1(String moduleId) {
    final match = RegExp(
      r'^world([0-9]+)_spine_campaign_v1$',
    ).firstMatch(moduleId.trim().toLowerCase());
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1) ?? '');
  }

  bool _isPremiumProgressionWorldV1(int? worldIndex) {
    if (worldIndex == null) {
      return false;
    }
    return worldIndex >= 5;
  }

  Future<String?> _peekNextPlacementSessionIdV1() async {
    final route = await PlacementServiceV1.getLastRouteV1();
    if (route == null) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    var repairPending = route.repairSessionId != null;
    var targetPending = true;
    final rawProgress = prefs.getString('placement_route_progress_v1');
    if (rawProgress != null && rawProgress.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawProgress);
        if (decoded is Map) {
          repairPending = decoded['repairPending'] == true;
          targetPending = decoded['targetPending'] == true;
        }
      } catch (_) {
        // Keep deterministic defaults when progress payload is malformed.
      }
    }
    if (repairPending && route.repairSessionId != null) {
      return route.repairSessionId;
    }
    if (targetPending) {
      return route.startTargetSessionId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SharkyTokensV1.surfaceApp,
      appBar: AppBar(
        backgroundColor: SharkyTokensV1.surfaceCard,
        title: Text(
          _intakeCompleted ? 'Today Plan' : 'Universal Intake',
          style: AppTypography.h3.copyWith(color: SharkyTokensV1.textPrimary),
        ),
      ),
      body: _intakeCompleted ? _buildPlan() : _buildIntake(),
    );
  }

  Widget _buildPlan() {
    final recommendedId = _recommendedModuleId();
    final routeStoryPackId = _primaryRoutePackIdForPlanV1();
    final recommendedTitle = _recommendedModuleTitle(recommendedId);
    final routeStory = resolveProgressionRouteStoryForPackV1(
      nextPackId: routeStoryPackId,
      reviewRequired: false,
      activePackId: _spineActivePackId ?? '',
      nextHandIndex: _spineNextHandIndex,
      rhythmReason: '',
    );
    final routingReason = _todayPlanRoutingReasonV1(routeStoryPackId);
    final media = MediaQuery.of(context);
    final compactLayout = media.size.height < 760 || media.size.width < 900;
    final earlyArcStageShiftValue = progressionRouteStageShiftValueForTargetV1(
      routeStory.target,
    );
    final summaryTitle = earlyArcStageShiftValue != null
        ? 'What changes now'
        : routeStory.target.isCrossFamilyRoute
        ? 'Next route'
        : (_spineCalibrationCompleted ? 'Continue campaign' : 'Campaign spine');
    final learnerSummaryValue = recommendedTitle.trim().isEmpty
        ? routeStory.target.routeLabel
        : recommendedTitle;
    final summaryValue = earlyArcStageShiftValue != null
        ? earlyArcStageShiftValue
        : routeStory.target.isCrossFamilyRoute
        ? routeStory.target.routeLabel
        : learnerSummaryValue;
    final bankrollValue = '$_bankrollBalance/$_bankrollCap chips';
    final campaignProgressValue =
        '$_campaignCompletedHands/$_campaignTotalHands  $_campaignSegmentLabel';
    final campaignStakesValue =
        '$_campaignBankroll/${ProgressService.bankrollCap}';
    final campaignRankValue = _campaignRankLabel;
    final placementRouteSummary = _placementRouteV1 == null
        ? null
        : (_placementRouteV1!.repairSessionId == null
              ? 'Next session: ${_placementRouteV1!.startTargetSessionId}'
              : 'Next sessions: ${_placementRouteV1!.repairSessionId} -> ${_placementRouteV1!.startTargetSessionId}');
    final placementResultSummary = _placementResultV1 == null
        ? null
        : 'Placement: ${_placementResultV1!.bucket.name} (${(_placementResultV1!.confidence * 100).round()}%)';
    final placementPrimarySummary =
        placementRouteSummary ?? placementResultSummary;
    final placementShowSecondary =
        !compactLayout &&
        placementRouteSummary != null &&
        placementResultSummary != null;
    final firstSessionTrustContract = resolveFirstSessionTrustPlanContractV1(
      routeStoryPackId,
    );
    if (firstSessionTrustContract != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _logFirstSessionTrustImpressionIfNeededV1(
          firstSessionTrustContract,
          routeStoryPackId,
        );
      });
    }
    final trialStatus = _trialStatusV1;
    final subscriptionStatus = _subscriptionStatusV1;
    final isPremium =
        subscriptionStatus?.accessState == SubscriptionAccessStateV1.premium;
    final isTrialActive = trialStatus?.isTrialActive ?? false;
    final isTrialEligible = trialStatus?.isEligible ?? false;
    final effectiveSubscriptionStatus =
        subscriptionStatus ??
        SubscriptionStatusV1(
          isPremium: false,
          isEntitled: isTrialActive,
          isTrialActive: isTrialActive,
          trialRemainingDays: trialStatus?.remainingDays ?? 0,
          source: isTrialActive
              ? SubscriptionSourceV1.trial
              : SubscriptionSourceV1.none,
          accessState: isTrialActive
              ? SubscriptionAccessStateV1.trial
              : SubscriptionAccessStateV1.free,
        );
    final showMonetizationRow =
        (subscriptionStatus?.isEntitled ?? false) ||
        isTrialActive ||
        isTrialEligible;
    final sharedRecentActivityRecommendation =
        _sharedRecentActivityRecommendationV1;
    final sharedRecentActivityContinuation =
        _sharedRecentActivityContinuationV1();
    final masteryProgress = MasteryProgressContractFactoryV1.derive(
      latestSession: _sharedRecentActivityLatestSessionV1,
      recommendation: sharedRecentActivityRecommendation,
      worldMasteryLevel: _sharedRecentActivityWorldMasteryLevelV1,
      campaignRankLabel: _campaignRankLabel,
    );
    final recoveryReadiness = RecoveryReadinessContractFactoryV1.derive(
      latestSession: _sharedRecentActivityLatestSessionV1,
      recommendation: sharedRecentActivityRecommendation,
      weaknessAssessment: _sharedRecentActivityWeaknessAssessmentV1,
      worldMasteryLevel: _sharedRecentActivityWorldMasteryLevelV1,
    );
    final sharedRecentActivityHeadline =
        sharedRecentActivityRecommendation == null
        ? null
        : _sharedRecentActivityHeadlineV1(sharedRecentActivityRecommendation);
    final sharedRecentActivityReasonCode =
        sharedRecentActivityRecommendation?.reasonCode.trim() ?? '';
    final sharedRecentActivityHint =
        recoveryReadiness?.fitLine ??
        masteryProgress?.fitLine ??
        (sharedRecentActivityReasonCode.startsWith('weakness_confidence_')
            ? sharedRecentActivityRecommendation?.shortHintText.trim()
            : null) ??
        sharedRecentActivityContinuation?.reasonLine.trim() ??
        sharedRecentActivityRecommendation?.shortHintText.trim();
    final sharedRecentActivityDelta =
        recoveryReadiness?.deltaSignal ?? masteryProgress?.deltaSignal;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(compactLayout ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          key: const Key('today_plan_screen'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NextActionStripV1(
                      key: const Key('today_plan_next_action_strip'),
                      compact: compactLayout,
                      title: summaryTitle,
                      value: summaryValue,
                      titleKey: const Key('today_plan_top_leak_title'),
                      valueKey: const Key('today_plan_top_leak_value'),
                      semanticsLabel: 'Today plan top leak',
                      semanticsValue: summaryValue,
                      semanticsHint: 'start recommended session for this focus',
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routingReason,
                            key: const Key('today_plan_routing_reason_v1'),
                            maxLines: compactLayout ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: SharkyTokensV1.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (placementPrimarySummary != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              placementPrimarySummary,
                              key: placementRouteSummary != null
                                  ? const Key('today_plan_placement_route_v1')
                                  : const Key('today_plan_placement_result_v1'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (placementShowSecondary) ...[
                            const SizedBox(height: 2),
                            Text(
                              placementResultSummary,
                              key: const Key('today_plan_placement_result_v1'),
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
                    if (firstSessionTrustContract != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      CampaignInfoCardV1(
                        containerKey: const Key(
                          'today_plan_first_session_brief_v1',
                        ),
                        compact: compactLayout,
                        microAnimationsEnabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstSessionTrustContract.titleLine,
                              key: const Key(
                                'today_plan_first_session_title_v1',
                              ),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              firstSessionTrustContract.productPromiseLine,
                              key: const Key(
                                'today_plan_first_session_product_promise_v1',
                              ),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              firstSessionTrustContract.promiseLine,
                              key: const Key(
                                'today_plan_first_session_promise_v1',
                              ),
                              style: AppTypography.body.copyWith(
                                color: SharkyTokensV1.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              firstSessionTrustContract.successLine,
                              key: const Key(
                                'today_plan_first_session_success_v1',
                              ),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              firstSessionTrustContract.sharkyLine,
                              key: const Key(
                                'today_plan_first_session_sharky_v1',
                              ),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.brandPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Offstage(
                      offstage: true,
                      child: Text(
                        summaryValue,
                        key: const Key('today_plan_recommended_value'),
                      ),
                    ),
                    if (sharedRecentActivityRecommendation != null &&
                        sharedRecentActivityHeadline != null &&
                        sharedRecentActivityHeadline.isNotEmpty &&
                        sharedRecentActivityHint != null &&
                        sharedRecentActivityHint.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      CampaignInfoCardV1(
                        containerKey: const Key(
                          'today_plan_recent_activity_card_v1',
                        ),
                        compact: compactLayout,
                        microAnimationsEnabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sharedRecentActivityTitleV1(),
                              key: const Key(
                                'today_plan_recent_activity_title_v1',
                              ),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              sharedRecentActivityHeadline,
                              key: const Key(
                                'today_plan_recent_activity_target_v1',
                              ),
                              style: AppTypography.body.copyWith(
                                color: SharkyTokensV1.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              sharedRecentActivityHint,
                              key: const Key(
                                'today_plan_recent_activity_hint_v1',
                              ),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (sharedRecentActivityDelta != null &&
                                sharedRecentActivityDelta.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                sharedRecentActivityDelta,
                                key: const Key(
                                  'today_plan_recent_activity_delta_v1',
                                ),
                                style: AppTypography.caption.copyWith(
                                  color: SharkyTokensV1.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                key: const Key(
                                  'today_plan_recent_activity_cta_v1',
                                ),
                                onPressed:
                                    _startSharedRecentActivityRecommendationV1,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 0,
                                  ),
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _sharedRecentActivityCtaLabelV1(
                                    sharedRecentActivityRecommendation,
                                  ),
                                  style: AppTypography.caption.copyWith(
                                    color: SharkyTokensV1.brandPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    CampaignInfoCardV1(
                      containerKey: const Key('today_plan_status_card_v1'),
                      compact: compactLayout,
                      microAnimationsEnabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campaign status',
                            style: AppTypography.caption.copyWith(
                              color: SharkyTokensV1.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                            height: compactLayout
                                ? AppSpacing.xs
                                : AppSpacing.sm,
                          ),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _TodayPlanMetricChipV1(
                                label: 'Progress',
                                value: campaignProgressValue,
                                valueKey: const Key(
                                  'today_plan_campaign_progress_value',
                                ),
                              ),
                              _TodayPlanMetricChipV1(
                                label: 'Stakes',
                                value: bankrollValue,
                                valueKey: const Key(
                                  'today_plan_bankroll_value',
                                ),
                              ),
                              _TodayPlanMetricChipV1(
                                label: 'Campaign stakes',
                                value: campaignStakesValue,
                                valueKey: const Key(
                                  'today_plan_campaign_stakes_value',
                                ),
                              ),
                              Container(
                                key: const Key(
                                  'today_plan_campaign_rank_strip',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: SharkyTokensV1.surfaceApp.withOpacity(
                                    0.48,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    SharkyTokensV1.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: SharkyTokensV1.slate500.withOpacity(
                                      0.35,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Rank',
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    CampaignRankBadgeV1(
                                      label: campaignRankValue,
                                      valueKey: const Key(
                                        'world_campaign_rank_value',
                                      ),
                                      compact: true,
                                      semanticsLabel:
                                          'Campaign rank $campaignRankValue',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_campaignRankHint.isNotEmpty && !_campaignBusted)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
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
                    if ((_cohortPromotionBannerTextV1 ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _cohortPromotionBannerTextV1!,
                          key: const Key(
                            'today_plan_cohort_promotion_banner_v1',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (showMonetizationRow)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isPremium)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _todayPremiumStatusLineV1(
                                        effectiveSubscriptionStatus,
                                      ),
                                      key: const Key(
                                        'today_plan_trial_status_v1',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Manage',
                                    key: const Key(
                                      'today_plan_premium_manage_v1',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: SharkyTokensV1.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else if (isTrialActive)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _todayPremiumStatusLineV1(
                                        effectiveSubscriptionStatus,
                                      ),
                                      key: const Key(
                                        'today_plan_trial_status_v1',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  TextButton(
                                    key: const Key(
                                      'today_plan_premium_preview_cta_v1',
                                    ),
                                    onPressed: _openPremiumPreviewV1,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(0, 28),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'See premium access',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: SharkyTokensV1.brandPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (isTrialEligible)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: compactLayout ? 34 : 38,
                                    child: OutlinedButton(
                                      key: const Key(
                                        'today_plan_trial_start_cta_v1',
                                      ),
                                      onPressed: _trialStartInProgressV1
                                          ? null
                                          : _startTrialFromIntakeV1,
                                      child: Text(
                                        _trialStartInProgressV1
                                            ? 'STARTING...'
                                            : 'START 7-DAY TRIAL',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      key: const Key(
                                        'today_plan_premium_preview_cta_v1',
                                      ),
                                      onPressed: _openPremiumPreviewV1,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs,
                                          vertical: 0,
                                        ),
                                        minimumSize: const Size(0, 28),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'See premium access',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: SharkyTokensV1.brandPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: compactLayout ? AppSpacing.sm : AppSpacing.md,
                    ),
                    if (_campaignBusted) ...[
                      CampaignInfoCardV1(
                        containerKey: const Key('world_campaign_bust_panel'),
                        compact: compactLayout,
                        microAnimationsEnabled: false,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BANKROLL: $_campaignBankroll. You need chips to play this hand.',
                              key: const Key('world_campaign_bust_reason'),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _campaignBackerAvailable
                                  ? 'Use BACKER to refill and continue.'
                                  : 'Wait until $_campaignBlockedReason',
                              key: const Key('today_plan_start_blocked_reason'),
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                              ),
                            ),
                            if (_campaignBackerAvailable) ...[
                              const SizedBox(height: AppSpacing.sm),
                              SizedBox(
                                height: compactLayout ? 40 : 44,
                                child: CampaignSecondaryCtaV1(
                                  controlKey: const Key(
                                    'world_campaign_backer_cta',
                                  ),
                                  onPressed: _campaignBackerInProgress
                                      ? null
                                      : _useCampaignBacker,
                                  label: 'BACKER',
                                  compact: compactLayout,
                                  microAnimationsEnabled: false,
                                  semanticsLabel: 'Use backer refill',
                                  highlight: true,
                                  textStyle: AppTypography.label.copyWith(
                                    color: SharkyTokensV1.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(
                        height: compactLayout ? AppSpacing.sm : AppSpacing.md,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: compactLayout ? AppSpacing.xs : AppSpacing.sm),
            SizedBox(
              height: compactLayout ? 52 : 56,
              child: GestureDetector(
                onLongPress: _campaignBusted
                    ? null
                    : _confirmEnableHighTierForNextRunV1,
                child: CampaignPrimaryCtaV1(
                  controlKey: const Key('today_plan_start_cta'),
                  onPressed: _campaignBusted || _todayPrimaryRouteInProgressV1
                      ? null
                      : _startTodayPrimaryRouteV1,
                  label: _startCtaLabel,
                  compact: compactLayout,
                  microAnimationsEnabled: false,
                  semanticsLabel: _startCtaLabel,
                  textStyle: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: SharkyTokensV1.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: compactLayout ? AppSpacing.xs : AppSpacing.sm),
            SizedBox(
              height: compactLayout ? 44 : 48,
              child: CampaignSecondaryCtaV1(
                controlKey: const Key('today_plan_open_map_cta'),
                onPressed: () {
                  Navigator.of(context).push(progressMapRouteV1());
                },
                label: 'OPEN MAP',
                compact: compactLayout,
                microAnimationsEnabled: false,
                textStyle: AppTypography.label.copyWith(
                  color: SharkyTokensV1.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntake() {
    final media = MediaQuery.of(context);
    final portrait = media.size.height > media.size.width;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: portrait ? AppSpacing.sm : AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            Container(
              key: const Key('intake_runner'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: SharkyTokensV1.surfaceCard.withOpacity(0.84),
                borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                border: Border.all(
                  color: SharkyTokensV1.slate600.withOpacity(0.65),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill band',
                    style: AppTypography.caption.copyWith(
                      color: SharkyTokensV1.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _buildSkillBandChip('beginner', 'Beginner'),
                      _buildSkillBandChip('intermediate', 'Intermediate'),
                      _buildSkillBandChip('advanced', 'Advanced'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_placementStageActive)
                    Text(
                      'Placement microtest',
                      key: const Key('placement_stage_header'),
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.brandPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Step $_activeStepNumber of $_activeStepTotal',
                    key: const Key('intake_step_header'),
                    style: AppTypography.h3.copyWith(
                      color: SharkyTokensV1.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _activeStep.prompt,
                    maxLines: portrait ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: SharkyTokensV1.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    key: const Key('intake_progress'),
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: SharkyTokensV1.slate600.withOpacity(0.35),
                    color: SharkyTokensV1.brandPrimary,
                  ),
                  if (_showHint) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _activeStep.hint,
                      key: const Key('intake_hint_bubble'),
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.semanticInfo,
                      ),
                    ),
                  ],
                  if (_feedback != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _feedback!,
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.semanticLoss,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  final portrait =
                      viewportConstraints.maxHeight >
                      viewportConstraints.maxWidth;
                  final tableSurface = Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: portrait ? 0 : AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: portrait ? 0 : AppSpacing.xs,
                      vertical: portrait ? 2 : AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.surfaceCard.withOpacity(
                        portrait ? 0.28 : 0.42,
                      ),
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.slate600.withOpacity(0.28),
                        width: 0.9,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final center = Offset(
                          constraints.maxWidth / 2,
                          constraints.maxHeight / 2,
                        );
                        final canvasSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        final compact =
                            constraints.maxWidth < 360 ||
                            constraints.maxHeight < 300;
                        final seatSize = compact ? 48.0 : 54.0;
                        final provisionalEdgeInset = (seatSize / 2) + 2;
                        final seatCenters = _seats
                            .map(
                              (seat) =>
                                  _IntakeTableStadiumSpecV1.resolveSeatCenter(
                                    canvasSize: canvasSize,
                                    seatId: seat.id,
                                    safeInset: provisionalEdgeInset,
                                  ),
                            )
                            .toList(growable: false);
                        var minCenterDistance = double.infinity;
                        for (var i = 0; i < seatCenters.length; i++) {
                          for (var j = i + 1; j < seatCenters.length; j++) {
                            final distance =
                                (seatCenters[i] - seatCenters[j]).distance;
                            if (distance < minCenterDistance) {
                              minCenterDistance = distance;
                            }
                          }
                        }
                        final nonOverlappingSeatSize =
                            (minCenterDistance.isFinite
                                    ? (minCenterDistance - 1.0)
                                    : seatSize)
                                .clamp(44.0, seatSize);
                        final seatEdgeInset = (nonOverlappingSeatSize / 2) + 2;
                        final seatRenderOrder = List<_SeatMeta>.from(_seats)
                          ..sort((a, b) {
                            if (_selectedSeatId == a.id) return 1;
                            if (_selectedSeatId == b.id) return -1;
                            return 0;
                          });
                        Offset resolveSeatCenter(_SeatMeta seat) =>
                            _IntakeTableStadiumSpecV1.resolveSeatCenter(
                              canvasSize: canvasSize,
                              seatId: seat.id,
                              safeInset: seatEdgeInset,
                            );

                        _SeatMeta seatById(String id) =>
                            _seats.firstWhere((seat) => seat.id == id);

                        final btnCenter = resolveSeatCenter(seatById('btn'));
                        final sbCenter = resolveSeatCenter(seatById('sb'));
                        final bbCenter = resolveSeatCenter(seatById('bb'));
                        const cueRadius = 9.0;
                        final seatVisualRadius = nonOverlappingSeatSize / 2;
                        final dealerMarkerRadius = cueRadius;
                        final blindMarkerRadius = cueRadius * 1.6;
                        final stadiumSafeRect = Rect.fromCenter(
                          center: center,
                          width:
                              constraints.maxWidth *
                              _IntakeTableStadiumSpecV1.stadiumWidth,
                          height:
                              constraints.maxHeight *
                              _IntakeTableStadiumSpecV1.stadiumHeight,
                        ).deflate(2.0);
                        final dealerCueCenter = _resolveMarkerCenterNoOverlapV1(
                          seatCenter: btnCenter,
                          tableCenter: center,
                          seatVisualRadiusPx: seatVisualRadius,
                          markerRadiusPx: dealerMarkerRadius,
                          stadiumSafeRect: stadiumSafeRect,
                          avoidRects: const <Rect>[],
                        );
                        final resolvedSbCueCenter =
                            _resolveMarkerCenterNoOverlapV1(
                              seatCenter: sbCenter,
                              tableCenter: center,
                              seatVisualRadiusPx: seatVisualRadius,
                              markerRadiusPx: blindMarkerRadius,
                              stadiumSafeRect: stadiumSafeRect,
                              avoidRects: const <Rect>[],
                            );
                        final resolvedBbCueCenter =
                            _resolveMarkerCenterNoOverlapV1(
                              seatCenter: bbCenter,
                              tableCenter: center,
                              seatVisualRadiusPx: seatVisualRadius,
                              markerRadiusPx: blindMarkerRadius,
                              stadiumSafeRect: stadiumSafeRect,
                              avoidRects: const <Rect>[],
                            );
                        return Stack(
                          key: const Key('intake_table'),
                          children: [
                            Positioned.fill(
                              child: Center(
                                child: SizedBox(
                                  width:
                                      constraints.maxWidth *
                                      _IntakeTableStadiumSpecV1.stadiumWidth,
                                  height:
                                      constraints.maxHeight *
                                      _IntakeTableStadiumSpecV1.stadiumHeight,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: Transform.translate(
                                          offset: const Offset(0, 8),
                                          child: const DecoratedBox(
                                            decoration: ShapeDecoration(
                                              color: Color(0x66000000),
                                              shape: StadiumBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: ShapeDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Color(0xFF1A2540),
                                                Color(0xFF0E162A),
                                              ],
                                            ),
                                            shape: StadiumBorder(
                                              side: BorderSide(
                                                color: const Color(
                                                  0xFF2C3D63,
                                                ).withOpacity(0.94),
                                                width: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF121D33),
                                            shape: StadiumBorder(
                                              side: BorderSide(
                                                color: const Color(
                                                  0xFFC9A96A,
                                                ).withOpacity(0.36),
                                                width: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          margin: const EdgeInsets.all(14),
                                          decoration: ShapeDecoration(
                                            gradient: const RadialGradient(
                                              center: Alignment(0, -0.06),
                                              radius: 1.05,
                                              colors: <Color>[
                                                Color(0xFF0E6A57),
                                                Color(0xFF083B34),
                                              ],
                                            ),
                                            shape: StadiumBorder(
                                              side: BorderSide(
                                                color: const Color(
                                                  0xFF1C7C67,
                                                ).withOpacity(0.74),
                                                width: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: dealerCueCenter.dx - cueRadius,
                              top: dealerCueCenter.dy - cueRadius,
                              child: IgnorePointer(
                                child: _buildIntakeChipStackBadgeV1(
                                  label: 'D',
                                  amount: 0,
                                  chipSize: cueRadius * 0.76,
                                  compact: true,
                                ),
                              ),
                            ),
                            for (final cue in <({Offset center, String label})>[
                              (center: resolvedSbCueCenter, label: 'SB'),
                              (center: resolvedBbCueCenter, label: 'BB'),
                            ])
                              Positioned(
                                left: cue.center.dx - (cueRadius * 1.6),
                                top: cue.center.dy - (cueRadius * 1.6),
                                child: IgnorePointer(
                                  child: _buildIntakeChipStackBadgeV1(
                                    label: cue.label,
                                    amount: cue.label == 'SB' ? 1 : 2,
                                    chipSize: cueRadius * 0.72,
                                    compact: true,
                                  ),
                                ),
                              ),
                            for (final seat in seatRenderOrder)
                              Positioned(
                                left: () {
                                  final seatCenter = resolveSeatCenter(seat);
                                  return seatCenter.dx -
                                      (nonOverlappingSeatSize / 2);
                                }(),
                                top: () {
                                  final seatCenter = resolveSeatCenter(seat);
                                  return seatCenter.dy -
                                      (nonOverlappingSeatSize / 2);
                                }(),
                                child: SizedBox(
                                  width: nonOverlappingSeatSize,
                                  height: nonOverlappingSeatSize,
                                  child: Semantics(
                                    label: 'Seat ${seat.label}',
                                    button: true,
                                    hint: 'double tap to select seat',
                                    child: GestureDetector(
                                      key: Key('intake_seat_${seat.id}'),
                                      onTap: () => _onSeatTap(seat.id),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: _selectedSeatId == seat.id
                                              ? SharkyTokensV1.brandPrimary
                                              : SharkyTokensV1.surfaceCard
                                                    .withOpacity(0.8),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: SharkyTokensV1.slate500,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            seat.shortLabel,
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color: SharkyTokensV1
                                                      .textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                  return tableSurface;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('intake_check_cta'),
                onPressed: _onCheck,
                child: Text(
                  'CHECK',
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SharkyTokensV1.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBandChip(String id, String label) {
    final selected = _skillBand == id;
    return ChoiceChip(
      key: Key('intake_skill_band_$id'),
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: selected
              ? SharkyTokensV1.textInverted
              : SharkyTokensV1.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      selected: selected,
      onSelected: (_) {
        unawaited(_setSkillBand(id));
      },
      selectedColor: SharkyTokensV1.brandPrimary,
      backgroundColor: SharkyTokensV1.surfaceCard.withOpacity(0.7),
      side: BorderSide(color: SharkyTokensV1.slate600.withOpacity(0.7)),
    );
  }

  Widget _buildIntakeChipStackBadgeV1({
    required String label,
    required int amount,
    required double chipSize,
    bool compact = false,
  }) {
    final labelStyle = AppTypography.caption.copyWith(
      color: SharkyTokensV1.textPrimary,
      fontWeight: FontWeight.w800,
      fontSize: compact ? 7.2 : 8.6,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final amountStyle = AppTypography.caption.copyWith(
      color: SharkyTokensV1.brandGlow,
      fontWeight: FontWeight.w800,
      fontSize: compact ? 7.0 : 8.3,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SharkyTokensV1.surfaceCard.withOpacity(0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.42)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5.5 : 7.0,
            vertical: compact ? 2.6 : 3.2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildIntakeChipStackGlyphV1(chipSize: chipSize),
              SizedBox(width: compact ? 3.3 : 4.6),
              Text(label, style: labelStyle),
              if (amount > 0) ...<Widget>[
                SizedBox(width: compact ? 2.8 : 4.0),
                Text(amount.toString(), style: amountStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntakeChipStackGlyphV1({required double chipSize}) {
    final effectiveSize = chipSize.clamp(4.0, 18.0);
    return SizedBox(
      width: effectiveSize * 1.35,
      height: effectiveSize * 1.3,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          _buildIntakeSingleChipDotV1(
            size: effectiveSize,
            top: effectiveSize * 0.24,
            opacity: 0.84,
          ),
          _buildIntakeSingleChipDotV1(
            size: effectiveSize,
            top: effectiveSize * 0.12,
            opacity: 0.92,
          ),
          _buildIntakeSingleChipDotV1(
            size: effectiveSize,
            top: 0,
            opacity: 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeSingleChipDotV1({
    required double size,
    required double top,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              SharkyTokensV1.brandPrimary.withOpacity(0.95 * opacity),
              SharkyTokensV1.brandGlow.withOpacity(0.82 * opacity),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: SharkyTokensV1.surfaceApp.withOpacity(0.86),
            width: 0.72,
          ),
        ),
      ),
    );
  }
}

class _IntakeStep {
  const _IntakeStep({
    required this.prompt,
    required this.hint,
    required this.expectedSeatId,
  });

  final String prompt;
  final String hint;
  final String expectedSeatId;
}

class _SeatMeta {
  const _SeatMeta(this.id, this.label, this.alignment);

  final String id;
  final String label;
  final Alignment alignment;

  String get shortLabel {
    switch (id) {
      case 'btn':
        return 'BTN';
      case 'sb':
        return 'SB';
      case 'bb':
        return 'BB';
      case 'utg':
        return 'UTG';
      case 'hj':
        return 'HJ';
      case 'co':
        return 'CO';
      default:
        return label;
    }
  }
}

class _TodayPlanMetricChipV1 extends StatelessWidget {
  const _TodayPlanMetricChipV1({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceApp.withOpacity(0.48),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: SharkyTokensV1.slate500.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            key: valueKey,
            style: AppTypography.caption.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntakeTableStadiumSpecV1 {
  static const Offset stadiumCenter = Offset(0.50, 0.50);
  static const double stadiumWidth = 0.68;
  static const double stadiumHeight = 0.86;
  static const Map<String, Offset> seatAnchorById = <String, Offset>{
    // Canonical clockwise ring from BTN:
    // BTN -> SB -> BB -> UTG -> HJ -> CO.
    'btn': Offset(0.50, 0.93),
    'sb': Offset(0.16, 0.70),
    'bb': Offset(0.16, 0.30),
    'utg': Offset(0.50, 0.07),
    'hj': Offset(0.84, 0.30),
    'co': Offset(0.84, 0.70),
  };
  static const double markerTowardCenterFactor = 0.14;

  static Offset resolveSeatCenter({
    required Size canvasSize,
    required String seatId,
    required double safeInset,
  }) {
    final anchor = seatAnchorById[seatId] ?? stadiumCenter;
    final rawX = canvasSize.width * anchor.dx;
    final rawY = canvasSize.height * anchor.dy;
    final minX = safeInset;
    final maxX = canvasSize.width - safeInset;
    final minY = safeInset;
    final maxY = canvasSize.height - safeInset;
    final resolvedX = maxX < minX
        ? canvasSize.width * stadiumCenter.dx
        : rawX.clamp(minX, maxX).toDouble();
    final resolvedY = maxY < minY
        ? canvasSize.height * stadiumCenter.dy
        : rawY.clamp(minY, maxY).toDouble();
    return Offset(resolvedX, resolvedY);
  }
}

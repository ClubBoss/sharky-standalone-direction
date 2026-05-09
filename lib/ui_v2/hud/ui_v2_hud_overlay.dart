import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/services/emotion_adaptive_engine.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/services/energy_service.dart';
import 'package:poker_analyzer/services/league_service.dart';
import 'package:poker_analyzer/services/economy_tuning_service.dart';
import 'package:poker_analyzer/services/ui_perf_telemetry_service.dart';
import 'package:poker_analyzer/services/xp_progress_service.dart';
import 'package:poker_analyzer/services/multiplayer_sim_bridge.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/overlay_manager.dart';
import 'package:poker_analyzer/services/ux_feedback_manager.dart';
import 'package:poker_analyzer/services/replay_recorder.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui_v2/components/mini_toast.dart';
import 'package:poker_analyzer/ui_v2/hand_analyzer_mode.dart';
import 'package:poker_analyzer/ui_v2/session_playback_engine.dart';
import 'package:poker_analyzer/ui_v2/table_visualization_prototype.dart';
import 'package:poker_analyzer/ui_v2/table_betting_layer.dart';
import 'package:poker_analyzer/ui_v2/reviewer_metrics_panel.dart';
import 'package:poker_analyzer/ui_v2/settings/settings_screen.dart';
import 'package:poker_analyzer/ui_v2/settings/settings_controller.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_table_widget.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_telemetry.dart';
import 'package:poker_analyzer/ui_v2/hud/simulation_mode_panel.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_engine.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_table_widget.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_controls_panel.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_telemetry.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_review_screen.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_engine.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_overlay.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_telemetry.dart';
import 'package:poker_analyzer/ui_v2/hud/components/reward_popup.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';

/// UI V2 HUD Overlay
///
/// Minimal in-game heads-up display showing:
/// - Energy (⚡)
/// - Chips (🪙)
/// - XP Level (⭐)
/// - League tier (💎)
///
/// Uses live service data with periodic refresh.
class UiV2HudOverlay extends StatefulWidget {
  const UiV2HudOverlay({super.key});

  @override
  State<UiV2HudOverlay> createState() => _UiV2HudOverlayState();
}

class _UiV2HudOverlayState extends State<UiV2HudOverlay> {
  late final ValueNotifier<_HudSnapshot> _snapshot;
  Timer? _refreshTimer;
  bool _pulseXp = false;
  bool _pulseEnergy = false;
  Timer? _xpPulseTimer;
  Timer? _energyPulseTimer;
  final List<_ToastEntry> _toasts = <_ToastEntry>[];
  int _toastSeq = 0;
  bool _showMultiSim = false;
  MultiplayerSimBridge? _multiBridge;
  List<SimTableSnapshot> _multiSnapshots = const [];
  StreamSubscription<List<SimTableSnapshot>>? _multiSubscription;
  double _difficultyMultiplier = 1.0;
  double _repetitionRate = 0.25;
  String _contextualMessage = '';
  BettingAction _demoAction = BettingAction.none;
  int _demoBetAmount = 0;
  int _demoPotSize = 100;

  // UX loop transition helpers for demo card
  int _demoRoundId = 0;
  bool _showFeedbackCard = false;
  Stopwatch? _uxStopwatch;
  bool _pendingLatencyLog = false;

  // Simulation mode state
  bool _simulationModeEnabled = false;
  SimulationEngine? _simulationEngine;
  bool _simulationPaused = false;
  StreamSubscription<SimulationEvent>? _simulationSubscription;
  ReplayRecorder? _replayRecorder;
  String? _latestReplayPath;

  // Replay mode state
  bool _replayModeEnabled = false;
  ReplayEngine? _replayEngine;
  ReplayTelemetry? _replayTelemetry;
  bool _showReviewButton = false;

  // AI Coach state
  bool _aiCoachEnabled = true;
  AiCoachEngine? _aiCoachEngine;
  AiCoachTelemetry? _aiCoachTelemetry;
  VoidCallback? _settingsListener;

  // Reward popup state
  final List<_RewardPopupEntry> _activeRewards = <_RewardPopupEntry>[];
  int _rewardSeq = 0;

  @override
  void initState() {
    super.initState();
    _snapshot = ValueNotifier<_HudSnapshot>(_HudSnapshot.loading());
    _refreshHud();
    UiPerfTelemetryService.instance.start();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshHud(),
    );
    // Initialize AI coach
    // Ensure settings are loaded and listen for changes
    AppSettingsService.instance.load().then((_) {
      if (!mounted) return;
      final s = AppSettingsService.instance.snapshot;
      setState(() {
        _aiCoachEnabled = s.aiCoachEnabled;
        if (_aiCoachEngine != null) {
          _aiCoachEngine!.enabled = _aiCoachEnabled;
        }
      });
    });
    _settingsListener = () {
      if (!mounted) return;
      final s = AppSettingsService.instance.snapshot;
      setState(() {
        _aiCoachEnabled = s.aiCoachEnabled;
        if (_aiCoachEngine != null) {
          _aiCoachEngine!.enabled = _aiCoachEnabled;
        }
      });
    };
    AppSettingsService.instance.changes.addListener(_settingsListener!);

    _aiCoachEngine = AiCoachEngine(enabled: _aiCoachEnabled);
    _aiCoachTelemetry = AiCoachTelemetry();
    OverlayManager.instance.registerDelegate(
      OverlayType.reward,
      _handleRewardOverlay,
    );
    // Demo betting animation trigger every 10 seconds
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && _demoAction == BettingAction.none) {
        setState(() {
          _demoAction = BettingAction.bet;
          _demoBetAmount = 50 + (DateTime.now().second % 5) * 20;
          _demoPotSize += _demoBetAmount;
        });
      }
    });
    // Demo reward popup trigger every 15 seconds
    Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        final xp = 25 + (DateTime.now().second % 4) * 10;
        final chips = 50 + (DateTime.now().second % 3) * 25;
        UxFeedbackManager.instance.grantReward(xp: xp, chips: chips);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _xpPulseTimer?.cancel();
    _energyPulseTimer?.cancel();
    OverlayManager.instance.unregisterDelegate(
      OverlayType.reward,
      _handleRewardOverlay,
    );
    _stopMultiSim();
    unawaited(_stopSimulation(fromDispose: true));
    _stopReplay();
    _stopAiCoach();
    _snapshot.dispose();
    if (_settingsListener != null) {
      AppSettingsService.instance.changes.removeListener(_settingsListener!);
      _settingsListener = null;
    }
    super.dispose();
  }

  Future<void> _refreshHud() async {
    try {
      final xpService = XpProgressService.instance;
      await xpService.load();
      final energyService = EnergyService();
      final energy = await energyService.getCurrentEnergy();
      final maxEnergy = energyService.getMaxEnergy();
      final level = xpService.level;
      final xpInLevel = xpService.xpInCurrentLevel;
      final tier = LeagueService.instance.getLeagueForXp(xpService.xpTotal);
      final economy = EconomyTuningService.instance;
      final xpFactor = await economy.getDynamicXpFactor();
      final refill = await economy.getDynamicRefillInterval(
        const Duration(minutes: 30),
      );

      // Load adaptive tuning
      final tuning = await loadPokerTableTuning();
      _difficultyMultiplier = tuning.difficultyMultiplier;
      _repetitionRate = tuning.repetitionRate;
      _updateContextualMessage();

      final nextSnapshot = _HudSnapshot(
        energy: energy,
        maxEnergy: maxEnergy,
        level: level,
        xpInLevel: xpInLevel,
        tier: tier,
        xpFactor: xpFactor,
        energyIntervalMinutes: refill.inMinutes,
      );
      final previous = _snapshot.value;
      if (!previous.isLoading) {
        _evaluateFeedback(previous, nextSnapshot);
      }
      _snapshot.value = nextSnapshot;
    } catch (_) {
      // Keep previous snapshot on failure.
    }
  }

  void _updateContextualMessage() {
    final momentum = EmotionAdaptiveEngine.instance.momentum;
    String message = '';

    if (_difficultyMultiplier >= 1.25) {
      message = '💪 Solid run - high difficulty engaged!';
    } else if (_repetitionRate >= 0.6) {
      message = '⏱ Time to review - reinforcing mastery!';
    } else if (momentum >= 0.5) {
      message = '🔥 On fire! Adaptive training in sync!';
    } else if (momentum >= 0.2) {
      message = '📈 Building consistency steadily!';
    }

    if (mounted && message.isNotEmpty && message != _contextualMessage) {
      setState(() => _contextualMessage = message);
      _enqueueToast('💡', message);
    }
  }

  String _leagueLabel(LeagueTier tier) {
    switch (tier) {
      case LeagueTier.Bronze:
        return '💎 Bronze';
      case LeagueTier.Silver:
        return '💎 Silver';
      case LeagueTier.Gold:
        return '💎 Gold';
      case LeagueTier.Platinum:
        return '💎 Platinum';
      case LeagueTier.Diamond:
        return '💎 Diamond';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingSmall ?? 8.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ValueListenableBuilder<_HudSnapshot>(
              valueListenable: _snapshot,
              builder: (context, data, _) {
                return ValueListenableBuilder<UiPerfSnapshot>(
                  valueListenable: UiPerfTelemetryService.instance.metrics,
                  builder: (context, perf, __) {
                    final highDifficulty = _difficultyMultiplier >= 1.2;
                    final highRepetition = _repetitionRate >= 0.5;
                    final badges = <Widget>[
                      _HudBadge(
                        iconData: Icons.bolt,
                        pulse: _pulseEnergy,
                        glow: highRepetition,
                        value: data.isLoading
                            ? '--'
                            : '${data.energy}/${data.maxEnergy}',
                        subtitle: 'Energy',
                      ),
                      _HudBadge(
                        iconData: Icons.star,
                        pulse: _pulseXp,
                        shimmer: highDifficulty,
                        value: data.isLoading ? '--' : 'L${data.level}',
                        subtitle: data.isLoading
                            ? null
                            : '${data.xpInLevel}/${XpProgressService.xpPerLevel} XP',
                      ),
                      _HudBadge(
                        iconData: Icons.emoji_events,
                        shimmer: highDifficulty,
                        value: data.isLoading ? '--' : _leagueLabel(data.tier),
                        subtitle: 'League',
                      ),
                      _HudBadge(
                        iconData: Icons.speed,
                        value: '${perf.fpsAvg.toStringAsFixed(0)} fps',
                        subtitle:
                            'miss ${perf.missesPerMinute.toStringAsFixed(1)}/m',
                      ),
                    ];
                    if (!data.isLoading) {
                      badges.add(
                        _HudBadge(
                          iconData: Icons.tune,
                          pulse: _pulseXp,
                          glow: highRepetition,
                          value: 'xp ×${data.xpFactor.toStringAsFixed(2)}',
                          subtitle: 'refill ${data.energyIntervalMinutes}m',
                        ),
                      );
                    }
                    final preview = FutureBuilder<PokerTableTuning>(
                      future: loadPokerTableTuning(),
                      builder: (context, snapshot) {
                        final tuning =
                            snapshot.data ?? PokerTableTuning.defaults;
                        final tables = <_PreviewTableConfig>[
                          _PreviewTableConfig(
                            count: 2,
                            spotKind: SpotKind.l3_river_jam_vs_raise,
                            heroAction: 'shoves river',
                            villainAction: 'snap calls',
                            pot: '68 BB',
                            board: const ['Ks', 'Qd', '7c', '7s', '2d'],
                            positions: const [
                              'Hero SB (70bb)',
                              'Villain BB (62bb)',
                            ],
                          ),
                          _PreviewTableConfig(
                            count: 6,
                            spotKind: SpotKind.l3_flop_jam_vs_raise,
                            heroAction: 'bets 33% pot',
                            villainAction: 'folds',
                            pot: '32 BB',
                            board: const ['Ac', '7d', '2h'],
                            positions: const [
                              'Hero BTN (45bb)',
                              'SB (30bb)',
                              'BB Villain (48bb)',
                              'UTG (38bb)',
                              'MP (52bb)',
                              'CO (40bb)',
                            ],
                          ),
                          _PreviewTableConfig(
                            count: 9,
                            spotKind: SpotKind.l4_icm_bubble_jam_vs_fold,
                            heroAction: 'pressures bubble',
                            villainAction: 'folds BB',
                            pot: '22 BB',
                            board: const ['9h', '9c', '4s'],
                            positions: const [
                              'Hero BTN (18bb)',
                              'SB (12bb)',
                              'BB (40bb)',
                              'UTG (33bb)',
                              'UTG+1 (29bb)',
                              'MP (27bb)',
                              'LJ (24bb)',
                              'HJ (31bb)',
                              'CO (21bb)',
                            ],
                          ),
                          _PreviewTableConfig(
                            count: 10,
                            spotKind: SpotKind.l4_icm_ladder_jam_vs_fold,
                            heroAction: 'shoves CO',
                            villainAction: 'folds BTN',
                            pot: '40 BB',
                            board: const ['Qh', 'Jc', '8s'],
                            positions: const [
                              'Hero CO (25bb)',
                              'BTN (30bb)',
                              'SB (28bb)',
                              'BB (55bb)',
                              'UTG (20bb)',
                              'UTG+1 (35bb)',
                              'MP1 (33bb)',
                              'MP2 (28bb)',
                              'LJ (26bb)',
                              'HJ (24bb)',
                            ],
                          ),
                        ];
                        if (_showMultiSim) {
                          _startMultiSim();
                          return _buildMultiplayerPreview(context, spacing);
                        }
                        return _buildSinglePreview(
                          context,
                          spacing,
                          tuning,
                          tables,
                        );
                      },
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: spacing,
                          runSpacing: spacing / 2,
                          children: badges,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _openSettings,
                                  icon: Icon(
                                    Icons.settings,
                                    color: brand?.primaryBrand ?? Colors.teal,
                                  ),
                                  tooltip: 'Settings',
                                ),
                                IconButton(
                                  onPressed: () {
                                    unawaited(_toggleSimulationMode());
                                  },
                                  icon: Icon(
                                    _simulationModeEnabled
                                        ? Icons.casino
                                        : Icons.casino_outlined,
                                    color: _simulationModeEnabled
                                        ? Colors.amber
                                        : (brand?.primaryBrand ?? Colors.teal),
                                  ),
                                  tooltip: _simulationModeEnabled
                                      ? 'Exit Simulation'
                                      : 'Enter Simulation',
                                ),
                                // Review Session button (visible after simulation ends)
                                if (_showReviewButton && !_replayModeEnabled)
                                  IconButton(
                                    onPressed: _startReplay,
                                    icon: const Icon(
                                      Icons.replay,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Review Session',
                                  ),
                                // Exit Replay button (visible during replay)
                                if (_replayModeEnabled)
                                  IconButton(
                                    onPressed: _stopReplay,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Exit Replay',
                                  ),
                                // AI Coach toggle (visible during simulation or replay)
                                if (_simulationModeEnabled ||
                                    _replayModeEnabled)
                                  IconButton(
                                    onPressed: _toggleAiCoach,
                                    icon: Icon(
                                      _aiCoachEnabled
                                          ? Icons.school
                                          : Icons.school_outlined,
                                      color: _aiCoachEnabled
                                          ? Colors.lightBlueAccent
                                          : (brand?.primaryBrand ??
                                                Colors.teal),
                                    ),
                                    tooltip: _aiCoachEnabled
                                        ? 'AI Coach (On)'
                                        : 'AI Coach (Off)',
                                  ),
                                // Save Replay button (visible during simulation)
                                if (_simulationModeEnabled &&
                                    _replayRecorder != null)
                                  IconButton(
                                    onPressed: _saveReplay,
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.deepPurple,
                                    ),
                                    tooltip: 'Save Replay',
                                  ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _toggleMultiSim,
                              icon: Icon(
                                _showMultiSim
                                    ? Icons.grid_off
                                    : Icons.grid_view,
                              ),
                              label: Text(
                                _showMultiSim
                                    ? 'Single-table demo'
                                    : 'Multi-table demo',
                              ),
                            ),
                          ],
                        ),
                        preview,
                      ],
                    );
                  },
                );
              },
            ),
            Positioned(
              top: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _toasts
                    .map(
                      (toast) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MiniToast(
                          key: ValueKey(toast.id),
                          icon: toast.icon,
                          message: toast.message,
                          onDismissed: () => _removeToast(toast.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // Simulation control panel
            if (_simulationModeEnabled && _simulationEngine != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: SimulationModePanel(
                  engine: _simulationEngine!,
                  isPaused: _simulationPaused,
                  onPause: _pauseSimulation,
                  onResume: _resumeSimulation,
                  onRestart: _restartSimulation,
                ),
              ),
            // Replay controls panel
            if (_replayModeEnabled &&
                _replayEngine != null &&
                _replayTelemetry != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: ReplayControlsPanel(
                  engine: _replayEngine!,
                  replayDurationMs: _replayTelemetry!.replayDurationMs,
                  userScrubActions: _replayTelemetry!.userScrubActions,
                  onPlay: () => setState(() {}),
                  onPause: () => setState(() {}),
                  onStepForward: () => setState(() {}),
                  onStepBackward: () => setState(() {}),
                  onReset: () => setState(() {}),
                  onSpeedChange: (_) => setState(() {}),
                ),
              ),
            // AI Coach overlay
            if (_aiCoachEnabled && _aiCoachEngine != null)
              Positioned(
                left: 16,
                bottom: 80,
                child: AiCoachOverlay(
                  feedbackStream: _aiCoachEngine!.feedbackStream,
                  visible: _aiCoachEnabled,
                ),
              ),
            // Reward popups overlay
            ..._activeRewards.map((entry) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.5 - 100,
                child: RewardPopup(
                  key: ValueKey(entry.id),
                  xp: entry.xp,
                  chips: entry.chips,
                  onDismissed: () {
                    if (mounted) {
                      setState(() {
                        _activeRewards.removeWhere((e) => e.id == entry.id);
                      });
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _evaluateFeedback(_HudSnapshot previous, _HudSnapshot next) {
    if (!mounted) return;
    final xpPrev = previous.xpFactor;
    final xpNext = next.xpFactor;
    if (xpPrev > 0) {
      final delta = (xpNext - xpPrev) / xpPrev;
      if (delta >= 0.03) {
        final percent = (delta * 100).toStringAsFixed(1);
        _triggerPulse(
          target: _PulseTarget.xp,
          toastIcon: '🚀',
          toastMessage: '+$percent% XP boost!',
          delta: delta * 100,
          eventName: 'xp_boost',
        );
      }
    }

    if (next.energy > previous.energy) {
      final deltaEnergy = next.energy - previous.energy;
      final maxEnergy = next.maxEnergy > 0
          ? next.maxEnergy
          : previous.maxEnergy;
      final energyPercent = maxEnergy > 0
          ? (deltaEnergy / maxEnergy) * 100
          : deltaEnergy.toDouble();
      final icon = next.energy == next.maxEnergy ? '⚡' : '✨';
      final message = next.energy == next.maxEnergy
          ? 'Energy refilled!'
          : '+$deltaEnergy ⚡ energy';
      _triggerPulse(
        target: _PulseTarget.energy,
        toastIcon: icon,
        toastMessage: message,
        delta: energyPercent,
        eventName: 'energy_refill',
      );
    }
  }

  Widget _buildSinglePreview(
    BuildContext context,
    double spacing,
    PokerTableTuning tuning,
    List<_PreviewTableConfig> tables,
  ) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Padding(
      padding: EdgeInsets.only(top: spacing, bottom: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PokerSessionPlaybackWidget(
            actions: _previewPlaybackActions,
            board: const ['Ah', '7c', '2d'],
            potHistory: _previewPlaybackPotHistory,
            positions: const ['Hero BTN (60bb)', 'SB (40bb)', 'BB (55bb)'],
            playerCount: 3,
            analysisEntries: _previewAnalysisEntries,
            difficultyMultiplier: tuning.difficultyMultiplier,
            repetitionRate: tuning.repetitionRate,
          ),
          SizedBox(height: spacing),
          ...tables.map(
            (table) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: PokerTableVisualizer(
                  spotKind: table.spotKind,
                  heroAction: table.heroAction,
                  villainAction: table.villainAction,
                  board: table.board,
                  pot: table.pot,
                  positions: table.positions,
                  playerCount: table.count,
                  difficultyMultiplier: tuning.difficultyMultiplier,
                  repetitionRate: tuning.repetitionRate,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _replayModeEnabled && _replayEngine != null
                ? ReplayTableWidget(
                    engine: _replayEngine!,
                    onScrubAction: _handleReplayScrubAction,
                  )
                : _simulationModeEnabled && _simulationEngine != null
                ? SimulationTableWidget(engine: _simulationEngine!)
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: SizedBox(
                      key: ValueKey<String>(
                        _showFeedbackCard
                            ? 'feedback_$_demoRoundId'
                            : 'round_$_demoRoundId',
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Next-hand card (default)
                            if (!_showFeedbackCard)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(
                                    brand?.radius ?? 12,
                                  ),
                                ),
                                child: PokerTableBettingLayer(
                                  playerCount: 6,
                                  heroSeat: 0,
                                  potSize: _demoPotSize,
                                  action: _demoAction,
                                  amount: _demoBetAmount,
                                  onActionComplete: () {
                                    if (!mounted) return;
                                    // Haptic and system click based on settings
                                    final settings =
                                        AppSettingsService.instance.snapshot;
                                    if (settings.hapticsEnabled) {
                                      HapticFeedback.lightImpact();
                                    }
                                    if (settings.soundEnabled) {
                                      SystemSound.play(SystemSoundType.click);
                                    }
                                    // Start latency timer, preload next "spot" assets/work
                                    _uxStopwatch ??= Stopwatch()..start();
                                    unawaited(
                                      loadPokerTableTuning(),
                                    ); // lightweight warmup
                                    setState(() {
                                      _demoAction = BettingAction.none;
                                      _showFeedbackCard = true;
                                    });
                                    // UX Loop 2.0 hook — reward + feedback telemetry.
                                    UxFeedbackManager.instance.grantReward(
                                      xp: 10,
                                      chips: 5,
                                    );
                                    UxFeedbackManager.instance.playFeedback(
                                      haptic: true,
                                      sound: true,
                                    );
                                    // Quick feedback phase, then transition to next card
                                    Future<void>.delayed(
                                      const Duration(milliseconds: 180),
                                      () {
                                        if (!mounted) return;
                                        setState(() {
                                          _showFeedbackCard = false;
                                          _demoRoundId++; // triggers switch to "next hand"
                                          _pendingLatencyLog = true;
                                        });
                                        // Log latency as soon as the next frame is presented
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (_pendingLatencyLog &&
                                                  _uxStopwatch != null) {
                                                _pendingLatencyLog = false;
                                                _uxStopwatch!.stop();
                                                final ms = _uxStopwatch!
                                                    .elapsedMilliseconds;
                                                _uxStopwatch = null;
                                                unawaited(
                                                  FirebaseLiteTelemetryService
                                                      .instance
                                                      .logEvent(
                                                        'ux_loop_latency_ms',
                                                        params: {
                                                          'value_ms': ms,
                                                        },
                                                      ),
                                                );
                                              }
                                            });
                                      },
                                    );
                                  },
                                ),
                              ),
                            // Feedback overlay (brief)
                            if (_showFeedbackCard)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(
                                    brand?.radius ?? 12,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.lightGreenAccent,
                                        size: 56,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Great!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ReviewerMetricsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplayerPreview(BuildContext context, double spacing) {
    final snapshots = _multiSnapshots;
    if (snapshots.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    final maxWidth = MediaQuery.of(context).size.width;
    final itemWidth = min(360.0, maxWidth / 2 - spacing * 1.5);

    return Padding(
      padding: EdgeInsets.only(top: spacing, bottom: spacing),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: snapshots
            .map(
              (snapshot) => SizedBox(
                width: itemWidth,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PokerTableVisualizer(
                        spotKind:
                            snapshot.currentAction?.type ==
                                PlaybackActionType.win
                            ? SpotKind.l3_river_jam_vs_raise
                            : SpotKind.l3_flop_jam_vs_raise,
                        heroAction:
                            snapshot.currentAction?.description ?? '---',
                        villainAction: _describeAction(snapshot.currentAction),
                        board: snapshot.board,
                        pot: '${snapshot.pot} BB',
                        positions: snapshot.positions,
                        playerCount: snapshot.playerCount,
                        difficultyMultiplier: _difficultyMultiplier,
                        repetitionRate: _repetitionRate,
                      ),
                      IgnorePointer(
                        child: PokerTableBettingLayer(
                          playerCount: snapshot.playerCount,
                          heroSeat: snapshot.currentAction?.seat ?? 0,
                          potSize: snapshot.pot,
                          action: _bettingFromAction(snapshot.currentAction),
                          amount: snapshot.currentAction?.amount ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _openSettings() async {
    final controller = SettingsController();
    await controller.initialize();

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SettingsScreen(controller: controller),
        ),
      );
    }
  }

  void _toggleMultiSim() {
    final enable = !_showMultiSim;
    if (enable) {
      _startMultiSim();
    } else {
      _stopMultiSim();
    }
    setState(() => _showMultiSim = enable);
  }

  void _startMultiSim() {
    if (_multiBridge == null) {
      _multiBridge = MultiplayerSimBridge(tableCount: 3, playersPerTable: 4);
      _multiSnapshots = _multiBridge!.currentSnapshots;
      _multiSubscription = _multiBridge!.snapshots.listen((snapshots) {
        if (mounted) {
          setState(() => _multiSnapshots = snapshots);
        }
      });
    }
    _multiBridge?.start();
  }

  void _stopMultiSim() {
    _multiSubscription?.cancel();
    _multiSubscription = null;
    _multiBridge?.dispose();
    _multiBridge = null;
    _multiSnapshots = const [];
  }

  Future<void> _toggleSimulationMode() async {
    final enable = !_simulationModeEnabled;
    if (enable) {
      _startSimulation();
    } else {
      await _stopSimulation();
    }
    if (mounted) {
      setState(() => _simulationModeEnabled = enable);
    }
  }

  void _startSimulation() {
    if (_simulationEngine != null) return;

    // Initialize engine with adaptive parameters
    _simulationEngine = SimulationEngine(
      playerCount: 6,
      heroSeat: 0,
      smallBlind: 10,
      bigBlind: 20,
      initialStack: 1000,
      autoPlayHero: false,
    );

    // Initialize replay recorder
    _replayRecorder = ReplayRecorder(engine: _simulationEngine!);

    // Subscribe to simulation events
    _simulationSubscription = _simulationEngine!.eventStream.listen((event) {
      if (!mounted) return;

      // Log simulation UX latency to telemetry
      if (event.type == 'action' &&
          _simulationEngine!.players[event.seatIndex].type == PlayerType.hero) {
        unawaited(
          FirebaseLiteTelemetryService.instance.logEvent(
            'simulation_ux_latency_ms',
            params: {
              'latency_ms':
                  _simulationEngine!.metrics.userInteractionLatencies.isNotEmpty
                  ? _simulationEngine!.metrics.userInteractionLatencies.last
                  : 0,
            },
          ),
        );
      }

      // Trigger UI update on any event
      setState(() {});
    });

    _simulationEngine!.startRound();
    _latestReplayPath = null;
  }

  Future<void> _stopSimulation({bool fromDispose = false}) async {
    if (_simulationEngine != null) {
      unawaited(
        SimulationTelemetry.writeMetricsReport(
          _simulationEngine!.metrics,
          difficultyMultiplier: _difficultyMultiplier,
          repetitionRate: _repetitionRate,
          metaFeedbackScore: EmotionAdaptiveEngine.instance.momentum,
        ),
      );
    }

    String? replayPath;
    final recorder = _replayRecorder;
    if (recorder != null) {
      replayPath = await recorder.exportReplay();
    }

    _simulationSubscription?.cancel();
    _simulationSubscription = null;
    _replayRecorder?.dispose();
    _replayRecorder = null;
    _simulationEngine?.dispose();
    _simulationEngine = null;
    _simulationPaused = false;

    _latestReplayPath = replayPath;

    if (!fromDispose && mounted) {
      setState(() {
        _showReviewButton = replayPath != null;
      });
    } else if (fromDispose) {
      _showReviewButton = false;
    }
  }

  void _pauseSimulation() {
    setState(() => _simulationPaused = true);
  }

  void _resumeSimulation() {
    setState(() => _simulationPaused = false);
  }

  void _restartSimulation() {
    if (_simulationEngine != null && _simulationEngine!.isRoundActive) {
      // Can't restart mid-round in current implementation
      return;
    }
    _simulationEngine?.startRound();
    setState(() => _simulationPaused = false);
  }

  Future<void> _saveReplay() async {
    if (_replayRecorder == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No replay data available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final filePath = await _replayRecorder!.exportReplay();
    if (filePath != null) {
      _latestReplayPath = filePath;
    }

    if (mounted) {
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Replay saved to $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save replay (no events captured)'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleSimulationUserAction(PlayerAction action, int? amount) {
    if (_simulationPaused) return;
    final SimulationEngine? engine = _simulationEngine;
    if (engine == null) return;

    // Evaluate action with AI coach if enabled
    if (_aiCoachEnabled &&
        _aiCoachEngine != null &&
        _aiCoachTelemetry != null) {
      final hero = engine.players[engine.heroSeat];

      // Extract game state for coach evaluation
      final street = engine.currentStreet
          .toString()
          .split('.')
          .last; // 'preflop', 'flop', etc.
      final pot = engine.pot;
      final stack = hero.stack;
      final currentBet = 20; // Use big blind as default bet
      final playerCount = engine.players.where((p) => p.isActive).length;
      final position = engine.heroSeat; // simplified position

      // Convert PlayerAction to coach action string
      String coachAction = 'unknown';
      switch (action) {
        case PlayerAction.fold:
          coachAction = 'fold';
          break;
        case PlayerAction.check:
          coachAction = 'check';
          break;
        case PlayerAction.call:
          coachAction = 'call';
          break;
        case PlayerAction.bet:
          coachAction = 'bet';
          break;
        case PlayerAction.raise:
          coachAction = 'raise';
          break;
        case PlayerAction.allIn:
        case PlayerAction.push:
          coachAction = 'all_in';
          break;
        case PlayerAction.post:
          coachAction = 'post';
          break;
        case PlayerAction.none:
          coachAction = 'none';
          break;
      }

      // Evaluate and record feedback
      final feedback = _aiCoachEngine!.evaluateAction(
        userAction: coachAction,
        street: street,
        pot: pot,
        heroStack: stack,
        currentBet: amount ?? currentBet,
        numActivePlayers: playerCount,
        heroPosition: position,
      );

      _aiCoachTelemetry!.recordFeedback(feedback);
    }

    engine.playerAction(action, amount: amount);
  }

  // Replay mode methods
  Future<void> _startReplay() async {
    final heroSeat = _simulationEngine?.heroSeat ?? 0;
    if (_simulationModeEnabled) {
      await _stopSimulation();
      if (mounted) {
        setState(() {
          _simulationModeEnabled = false;
        });
      }
    }

    String? replayPath = _latestReplayPath;
    if (replayPath == null || replayPath.isEmpty) {
      replayPath = await _replayRecorder?.exportReplay();
      _latestReplayPath = replayPath;
    }

    if (!mounted) return;

    if (replayPath == null || replayPath.isEmpty) {
      _enqueueToast('⚠️', 'No replay data available');
      return;
    }

    final String resolvedPath = replayPath;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReplayReviewScreen(replayPath: resolvedPath, heroSeat: heroSeat),
      ),
    );

    if (mounted) {
      setState(() {
        _showReviewButton = true;
      });
    }
  }

  void _stopReplay() {
    if (_replayEngine != null && _replayTelemetry != null) {
      // Write telemetry before disposing
      unawaited(
        _replayTelemetry!.writeMetricsReport(
          totalSnapshots: _replayEngine!.totalSnapshots,
          snapshotsViewed: _replayEngine!.currentIndex + 1,
          playbackSpeed: _replayEngine!.playbackSpeed,
        ),
      );
    }

    _replayEngine?.dispose();
    _replayEngine = null;
    _replayTelemetry = null;
    setState(() {
      _replayModeEnabled = false;
    });

    stdout.writeln('[HUD] Stopped replay mode');
  }

  void _handleReplayScrubAction() {
    _replayTelemetry?.recordScrubAction();
  }

  BettingAction _bettingFromAction(PlaybackAction? action) {
    if (action == null) return BettingAction.none;
    switch (action.type) {
      case PlaybackActionType.bet:
        return BettingAction.bet;
      case PlaybackActionType.raise:
        return BettingAction.raise;
      case PlaybackActionType.call:
        return BettingAction.call;
      case PlaybackActionType.fold:
        return BettingAction.fold;
      case PlaybackActionType.check:
        return BettingAction.check;
      case PlaybackActionType.win:
      case PlaybackActionType.none:
        return BettingAction.none;
    }
  }

  String _describeAction(PlaybackAction? action) {
    if (action == null) return 'Awaiting action';
    final seatLabel = 'Seat ${action.seat + 1}';
    switch (action.type) {
      case PlaybackActionType.bet:
        return '$seatLabel bets ${action.amount} BB';
      case PlaybackActionType.raise:
        return '$seatLabel raises to ${action.amount} BB';
      case PlaybackActionType.call:
        return '$seatLabel calls ${action.amount} BB';
      case PlaybackActionType.fold:
        return '$seatLabel folds';
      case PlaybackActionType.check:
        return '$seatLabel checks';
      case PlaybackActionType.win:
        return '$seatLabel drags the pot';
      case PlaybackActionType.none:
        return '$seatLabel waits';
    }
  }

  // AI Coach methods
  void _toggleAiCoach() {
    final enable = !AppSettingsService.instance.aiCoachEnabled;
    unawaited(AppSettingsService.instance.setAiCoachEnabled(enable));
    stdout.writeln(
      '[HUD] AI Coach ${_aiCoachEnabled ? "enabled" : "disabled"}',
    );
  }

  void _stopAiCoach() {
    if (_aiCoachTelemetry != null) {
      // Write telemetry before disposing
      unawaited(_aiCoachTelemetry!.writeMetricsReport());
    }
    _aiCoachEngine?.dispose();
    _aiCoachEngine = null;
    _aiCoachTelemetry = null;
    stdout.writeln('[HUD] Stopped AI Coach');
  }

  void _triggerPulse({
    required _PulseTarget target,
    required String toastIcon,
    required String toastMessage,
    required double delta,
    required String eventName,
  }) {
    if (!mounted) return;
    setState(() {
      if (target == _PulseTarget.xp) {
        _pulseXp = true;
        _xpPulseTimer?.cancel();
        _xpPulseTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _pulseXp = false);
          }
        });
      } else {
        _pulseEnergy = true;
        _energyPulseTimer?.cancel();
        _energyPulseTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _pulseEnergy = false);
          }
        });
      }
    });
    _enqueueToast(toastIcon, toastMessage);
    EmotionAdaptiveEngine.instance.recordEvent(eventName, delta);
  }

  void _enqueueToast(String icon, String message) {
    final entry = _ToastEntry(
      id: 'toast_${_toastSeq++}',
      icon: icon,
      message: message,
    );
    setState(() {
      if (_toasts.length >= 3) {
        _toasts.removeAt(0);
      }
      _toasts.add(entry);
    });
  }

  void _removeToast(String id) {
    setState(() => _toasts.removeWhere((element) => element.id == id));
  }

  Future<void> _handleRewardOverlay(Map<String, Object?> payload) async {
    if (!mounted) return;
    final xp = (payload['xp'] as num?)?.toInt() ?? 0;
    final chips = (payload['chips'] as num?)?.toInt() ?? 0;
    final entry = _RewardPopupEntry(
      id: 'reward_${_rewardSeq++}',
      xp: xp,
      chips: chips,
    );
    setState(() {
      _activeRewards.add(entry);
    });
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() {
      _activeRewards.removeWhere((e) => e.id == entry.id);
    });
  }
}

class _HudBadge extends StatefulWidget {
  final String? icon;
  final IconData? iconData;
  final String value;
  final String? subtitle;
  final bool pulse;
  final bool shimmer;
  final bool glow;
  final VoidCallback? onTap;

  const _HudBadge({
    this.icon,
    this.iconData,
    required this.value,
    this.subtitle,
    this.pulse = false,
    this.shimmer = false,
    this.glow = false,
    this.onTap, // ignore: unused_element_parameter
  }) : assert(
         icon != null || iconData != null,
         'Either icon or iconData must be provided',
       );

  @override
  State<_HudBadge> createState() => _HudBadgeState();
}

class _HudBadgeState extends State<_HudBadge> with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _updateShimmer();
  }

  @override
  void didUpdateWidget(_HudBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shimmer != widget.shimmer) {
      _updateShimmer();
    }
  }

  void _updateShimmer() {
    if (widget.shimmer) {
      _shimmerController.repeat(reverse: true);
    } else {
      _shimmerController.stop();
      _shimmerController.value = 0;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _tapController.forward().then((_) => _tapController.reverse());
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;
    final primaryColor = brand?.primaryBrand ?? Colors.teal;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerOpacity = _shimmerController.value * 0.4;
        final glowIntensity = widget.glow ? 0.6 : 0.3;

        return AnimatedScale(
          scale: widget.pulse ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: primaryColor.withValues(
                  alpha: widget.shimmer ? 0.5 + shimmerOpacity : 1.0,
                ),
                width: widget.shimmer ? 1.5 : 1,
              ),
              boxShadow: [
                // Base shadow for depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
                if (widget.glow)
                  BoxShadow(
                    color: primaryColor.withValues(alpha: glowIntensity),
                    blurRadius: 12 + (widget.glow ? 8 : 0),
                    spreadRadius: 2,
                  ),
                if (widget.shimmer)
                  BoxShadow(
                    color: primaryColor.withValues(alpha: shimmerOpacity),
                    blurRadius: 8 + (shimmerOpacity * 12),
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap != null ? _handleTap : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _tapController,
              builder: (context, child) {
                final scale = 1.0 - (_tapController.value * 0.15);
                final opacity = 1.0 - (_tapController.value * 0.3);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
              child: widget.iconData != null
                  ? Icon(
                      widget.iconData,
                      size: 16,
                      color: brand?.primaryBrand ?? Colors.teal,
                    )
                  : Text(widget.icon!, style: AppTypography.label),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    widget.value,
                    key: ValueKey(widget.value),
                    style: AppTypography.label.copyWith(
                      color: brand?.primaryBrand ?? Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.subtitle != null)
                  Text(widget.subtitle!, style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HudSnapshot {
  final int energy;
  final int maxEnergy;
  final int level;
  final int xpInLevel;
  final LeagueTier tier;
  final bool isLoading;
  final double xpFactor;
  final int energyIntervalMinutes;

  const _HudSnapshot({
    required this.energy,
    required this.maxEnergy,
    required this.level,
    required this.xpInLevel,
    required this.tier,
    required this.xpFactor,
    required this.energyIntervalMinutes,
    this.isLoading = false,
  });

  factory _HudSnapshot.loading() => const _HudSnapshot(
    energy: 0,
    maxEnergy: 0,
    level: 0,
    xpInLevel: 0,
    tier: LeagueTier.Bronze,
    xpFactor: 1.0,
    energyIntervalMinutes: 30,
    isLoading: true,
  );
}

class _ToastEntry {
  final String id;
  final String icon;
  final String message;

  const _ToastEntry({
    required this.id,
    required this.icon,
    required this.message,
  });
}

class _RewardPopupEntry {
  final String id;
  final int xp;
  final int chips;

  const _RewardPopupEntry({
    required this.id,
    required this.xp,
    required this.chips,
  });
}

class _PreviewTableConfig {
  const _PreviewTableConfig({
    required this.count,
    required this.spotKind,
    required this.heroAction,
    required this.villainAction,
    required this.pot,
    required this.board,
    required this.positions,
  });

  final int count;
  final SpotKind spotKind;
  final String heroAction;
  final String villainAction;
  final String pot;
  final List<String> board;
  final List<String> positions;
}

enum _PulseTarget { xp, energy }

const List<PlaybackAction> _previewPlaybackActions = <PlaybackAction>[
  PlaybackAction(
    seat: 0,
    type: PlaybackActionType.bet,
    amount: 12,
    description: 'Hero opens BTN to 12 BB',
  ),
  PlaybackAction(
    seat: 1,
    type: PlaybackActionType.call,
    amount: 12,
    description: 'SB calls 12 BB',
  ),
  PlaybackAction(
    seat: 2,
    type: PlaybackActionType.fold,
    amount: 0,
    description: 'BB folds',
  ),
  PlaybackAction(
    seat: 0,
    type: PlaybackActionType.bet,
    amount: 18,
    description: 'Hero c-bets 18 BB',
  ),
  PlaybackAction(
    seat: 1,
    type: PlaybackActionType.fold,
    amount: 0,
    description: 'SB folds to pressure',
  ),
  PlaybackAction(
    seat: 0,
    type: PlaybackActionType.win,
    amount: 42,
    description: 'Hero wins the pot',
  ),
];

const List<int> _previewPlaybackPotHistory = <int>[0, 12, 24, 24, 42, 42, 0];

const List<HandAnalyzerEntry> _previewAnalysisEntries = <HandAnalyzerEntry>[
  HandAnalyzerEntry(
    actionIndex: 0,
    correctAction: PlaybackActionType.bet,
    evDiff: 0.25,
    rationale: 'BTN open builds pot with range advantage.',
  ),
  HandAnalyzerEntry(
    actionIndex: 1,
    correctAction: PlaybackActionType.call,
    evDiff: 0.08,
    rationale: 'SB defend suited connector getting 3.5:1.',
  ),
  HandAnalyzerEntry(
    actionIndex: 2,
    correctAction: PlaybackActionType.fold,
    evDiff: -0.02,
    rationale: 'BB fold acceptable; low EV loss.',
  ),
  HandAnalyzerEntry(
    actionIndex: 3,
    correctAction: PlaybackActionType.bet,
    evDiff: 0.35,
    rationale: 'Small c-bet presses capped SB range.',
  ),
  HandAnalyzerEntry(
    actionIndex: 4,
    correctAction: PlaybackActionType.fold,
    evDiff: 0.12,
    rationale: 'SB fold avoids dominated top pair spots.',
  ),
  HandAnalyzerEntry(
    actionIndex: 5,
    correctAction: PlaybackActionType.win,
    evDiff: 0.40,
    rationale: 'Hero drags 42 BB uncontested.',
  ),
];

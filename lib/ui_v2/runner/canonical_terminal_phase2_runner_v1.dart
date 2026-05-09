import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase2_canonical_host_flow_bridge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase2_canonical_host_launch_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_canonical_consumer_path_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_top_level_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';

const String _sessionStartEvent = 'PHASE2_SESSION_START';
const String _ahaEvent = 'PHASE2_AHA';
const String _flowEndEvent = 'PHASE2_FLOW_END';

class CanonicalTerminalPhase2RunnerV1 extends StatefulWidget {
  const CanonicalTerminalPhase2RunnerV1({
    super.key,
    required this.runtimeConfigV1,
  });

  final CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1;

  @override
  State createState() => _CanonicalTerminalPhase2RunnerV1State();
}

class _CanonicalTerminalPhase2RunnerV1State
    extends State<CanonicalTerminalPhase2RunnerV1>
    with WidgetsBindingObserver {
  late final String _runId;
  Phase2CanonicalHostFlowStateV1 _flowStateV1 =
      const Phase2CanonicalHostFlowStateV1.initial();
  DateTime? _feedbackShownAt;
  Timer? _bubbleTimer;
  bool _sessionStartLogged = false;
  bool _flowEndLogged = false;

  bool get _ahaFired => _flowStateV1.ahaFired;
  bool get _navigationHappened => _flowStateV1.navigationHappened;
  bool get _bubbleVisible => _flowStateV1.bubbleVisible;

  @override
  void initState() {
    super.initState();
    _runId = widget.runtimeConfigV1.runIdV1;
    _sessionStartLogged = widget.runtimeConfigV1.sessionStartLoggedV1;
    if (!_sessionStartLogged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logSessionStart();
      });
    }
    WidgetsBinding.instance.addObserver(this);
  }

  String get _sessionStartPayload {
    return '$_sessionStartEvent: ${jsonEncode({'run_id': _runId, 'timestamp': DateTime.now().toUtc().toIso8601String()})}';
  }

  String get _ahaPayload {
    final payload = {
      'run_id': _runId,
      'aha_type': 'value_realization',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    return '$_ahaEvent: ${jsonEncode(payload)}';
  }

  void _triggerAha() {
    final triggerPlanV1 = Phase2CanonicalHostFlowBridgeV1.triggerAha(
      _flowStateV1,
    );
    if (!triggerPlanV1.firesAha) return;
    _onAttemptStart();
    setState(() {
      _flowStateV1 = triggerPlanV1.nextState;
      _feedbackShownAt = DateTime.now().toUtc();
    });
    debugPrint(_ahaPayload);
    if (triggerPlanV1.showsBubble) {
      _showErrorBubble();
    }
  }

  void _onAttemptStart() {
    if (_bubbleVisible) {
      _hideErrorBubble();
    }
  }

  void _showErrorBubble() {
    if (_bubbleVisible) return;
    setState(() {
      _flowStateV1 = _flowStateV1.copyWith(bubbleVisible: true);
    });
    final payload = {
      'run_id': _runId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'state': 'shown',
    };
    debugPrint('PHASE2_AHA_HINT_SHOWN ${jsonEncode(payload)}');
    _bubbleTimer?.cancel();
    _bubbleTimer = Timer(const Duration(seconds: 3), _hideErrorBubble);
  }

  void _hideErrorBubble() {
    if (!_bubbleVisible) return;
    setState(() {
      _flowStateV1 = Phase2CanonicalHostFlowBridgeV1.dismissBubble(
        _flowStateV1,
      );
    });
    final payload = {
      'run_id': _runId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'state': 'dismissed',
    };
    debugPrint('PHASE2_AHA_HINT_DISMISSED ${jsonEncode(payload)}');
    _bubbleTimer?.cancel();
    _bubbleTimer = null;
  }

  void _finish() {
    final finishPlanV1 = Phase2CanonicalHostFlowBridgeV1.finish(_flowStateV1);
    if (!finishPlanV1.shouldNavigate) return;
    _flowStateV1 = finishPlanV1.nextState;
    _logFlowEndOnce(result: finishPlanV1.flowResult);
    if (finishPlanV1.hidesBubble) {
      _hideErrorBubble();
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _logSessionStart() {
    if (_sessionStartLogged) return;
    final line = buildPhase2CanonicalSessionStartPayloadV1(
      _runId,
      DateTime.now(),
    );
    print(line);
    _sessionStartLogged = true;
  }

  void _logFlowEndOnce({required String result}) {
    if (_flowEndLogged) return;
    final now = DateTime.now().toUtc();
    final payload = <String, Object>{
      'run_id': _runId,
      'result': result,
      'timestamp': now.toIso8601String(),
    };
    if (_feedbackShownAt != null) {
      payload['feedback_view_duration_ms'] = now
          .difference(_feedbackShownAt!)
          .inMilliseconds;
    }
    _flowEndLogged = true;
    final line = '$_flowEndEvent ${jsonEncode(payload)}';
    print(line);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _logFlowEndOnce(result: _ahaFired ? 'signaled' : 'canceled');
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final runner = Builder(
      builder: (context) {
        final bottomInset =
            AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom;
        final content = SharedLearnerCanonicalConsumerPathV1(
          topLevelShellContract: SharedLearnerTopLevelShellContractV1(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Phase 2 Runner'),
              leading: BackButton(onPressed: _finish),
            ),
            wrapBodyInSafeArea: true,
            safeAreaBottom: false,
          ),
          shellContract: SurfacedLearnerHostShellContractV1(
            outerPadding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              bottomInset,
            ),
            borderRadius: BorderRadius.circular(20),
            shellGradientColors: const <Color>[
              AppColors.surface,
              AppColors.surfaceVariant,
            ],
            shadowColor: Colors.black26,
            shadowBlurRadius: 16,
            headerPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Value/Aha Runner',
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Trigger the aha moment whenever the player grasps the insight.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            body: const SizedBox.shrink(),
            bottomBandMaxHeight: 0,
            bottomBandPadding: EdgeInsets.zero,
            bottomBandSurfaceKey: const Key('phase2_runner_bottom_band_v1'),
            bottomBandCompact: true,
            wrapBottomBandInSupportLane: false,
            bottomBandSurfaceColor: Colors.transparent,
            bottomBandBorderColor: Colors.transparent,
            bottomBandChild: null,
          ),
          frameViewportRegion: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_bubbleVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Fact: The aha happens after an unexpected action anchors value.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                if (_ahaFired)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Value insight registered.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _ahaFired ? null : _triggerAha,
                    child: const Text('Trigger Aha'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _finish,
                    child: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ),
        );
        if (!_bubbleVisible) {
          return content;
        }
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _onAttemptStart(),
          child: content,
        );
      },
    );
    return WillPopScope(
      onWillPop: () async {
        _finish();
        return false;
      },
      child: runner,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logFlowEndOnce(result: _ahaFired ? 'signaled' : 'canceled');
    _bubbleTimer?.cancel();
    super.dispose();
  }
}

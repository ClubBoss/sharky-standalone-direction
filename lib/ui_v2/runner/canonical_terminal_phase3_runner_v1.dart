import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/main.dart';
import 'package:poker_analyzer/services/learning_path_launcher_service.dart';
import 'package:poker_analyzer/services/learning_path_orchestrator.dart';
import 'package:poker_analyzer/services/learning_path_summary_cache_v2.dart';
import 'package:poker_analyzer/services/session_log_service.dart';
import 'package:poker_analyzer/services/training_path_progress_service_v2.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase3_canonical_host_flow_bridge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase3_canonical_host_launch_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_canonical_consumer_path_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_top_level_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';

const String _returnSignalEvent = 'PHASE3_RETURN_SIGNAL';
const String _flowEndEvent = 'PHASE3_FLOW_END';
const String _returnCtaShownEvent = 'PHASE3_RETURN_CTA_SHOWN';
const String _returnCtaTappedEvent = 'PHASE3_RETURN_CTA_TAPPED';
const String _returnCtaLatencyEvent = 'PHASE3_RETURN_CTA_TAP_LATENCY_MS';

class CanonicalTerminalPhase3RunnerV1 extends StatefulWidget {
  const CanonicalTerminalPhase3RunnerV1({
    super.key,
    required this.runtimeConfigV1,
  });

  final CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1;

  @override
  State createState() => _CanonicalTerminalPhase3RunnerV1State();
}

class _CanonicalTerminalPhase3RunnerV1State
    extends State<CanonicalTerminalPhase3RunnerV1> {
  late final String _runId;
  Phase3CanonicalHostFlowStateV1 _flowState =
      const Phase3CanonicalHostFlowStateV1.initial();

  @override
  void initState() {
    super.initState();
    _runId = widget.runtimeConfigV1.runIdV1;
  }

  String _returnSignalPayload() {
    return buildPhase3CanonicalReturnSignalPayloadV1(_runId, DateTime.now());
  }

  String _flowEndPayload(String result) {
    return buildPhase3CanonicalFlowEndPayloadV1(_runId, result, DateTime.now());
  }

  void _sendSignal() {
    final plan = Phase3CanonicalHostFlowBridgeV1.sendSignal(
      _flowState,
      DateTime.now().toUtc(),
    );
    if (plan.nextState != _flowState) {
      setState(() {
        _flowState = plan.nextState;
      });
    }
    if (plan.shouldEmitReturnSignal) {
      debugPrint(_returnSignalPayload());
    }
    if (plan.shouldLogReturnCtaShown) {
      debugPrint(_returnCtaShownEvent);
    }
  }

  void _finish() {
    final plan = Phase3CanonicalHostFlowBridgeV1.finish(_flowState);
    if (plan.nextState != _flowState) {
      _flowState = plan.nextState;
    }
    if (plan.shouldLogFlowEnd) {
      debugPrint(_flowEndPayload(plan.flowResult));
    }
    if (plan.shouldNavigateHome) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleReturnCtaTap() async {
    final plan = Phase3CanonicalHostFlowBridgeV1.tapContinueTraining(
      _flowState,
      DateTime.now().toUtc(),
    );
    if (plan.nextState != _flowState) {
      _flowState = plan.nextState;
    }
    if (!plan.shouldLaunchNextStage) {
      return;
    }
    if (plan.shouldLogReturnCtaTapped) {
      debugPrint(_returnCtaTappedEvent);
    }
    if (plan.shouldLogLatency && plan.latencyMs != null) {
      final payload = {
        'run_id': _runId,
        'duration_ms': plan.latencyMs,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };
      debugPrint('$_returnCtaLatencyEvent: ${jsonEncode(payload)}');
    }
    final rootContext = navigatorKey.currentContext;
    if (rootContext == null) return;
    final template = await LearningPathOrchestrator.instance.resolve();
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    final launcher = LearningPathLauncherService(
      cache: LearningPathSummaryCache(
        progress: TrainingPathProgressServiceV2(
          logs: SessionLogService.instance,
        ),
      ),
    );
    await launcher.launchNextStage(template.id, rootContext);
  }

  @override
  Widget build(BuildContext context) {
    return SharedLearnerCanonicalConsumerPathV1(
      topLevelShellContract: SharedLearnerTopLevelShellContractV1(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Phase 3 Runner'),
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
          AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom,
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
              'Engagement Signal',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Send the return-loop signal when the user feels compelled to go back.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
        body: const SizedBox.shrink(),
        bottomBandMaxHeight: 0,
        bottomBandPadding: EdgeInsets.zero,
        bottomBandSurfaceKey: const Key('phase3_runner_bottom_band_v1'),
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
            if (_flowState.signalSent)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Return signal recorded.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            if (!_flowState.signalSent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendSignal,
                  child: const Text('Send return signal'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleReturnCtaTap,
                  child: const Text('Continue training'),
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
  }
}

// PHASE 1 FROZEN: do not modify without a P0 issue plus explicit approval.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/phase1_canonical_host_launch_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_canonical_consumer_path_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_top_level_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';

const String _sessionStartEvent = 'PHASE1_SESSION_START';
const String _passEvent = 'PHASE1_PASS';
const String _attemptStartEvent = 'PHASE1_ATTEMPT_START';
const String _attemptResultEvent = 'PHASE1_ATTEMPT_RESULT';
const String _flowEndEvent = 'PHASE1_FLOW_END';
const int _maxAttempts = 6;
const Set<int> _wrongAttempts = {3};
const List<String> _passLabels = ['A', 'B'];

class CanonicalTerminalPhase1RunnerV1 extends StatefulWidget {
  const CanonicalTerminalPhase1RunnerV1({
    super.key,
    required this.runtimeConfigV1,
  });

  final CanonicalTerminalPhaseRuntimeConfigV1 runtimeConfigV1;

  @override
  State createState() => _CanonicalTerminalPhase1RunnerV1State();
}

class _CanonicalTerminalPhase1RunnerV1State
    extends State<CanonicalTerminalPhase1RunnerV1> {
  late final String _runId;
  bool _sessionStarted = false;
  bool _flowLogged = false;
  bool _navigationHappened = false;
  int _attemptIndex = 0;
  int _passIndex = 0;
  String _status = 'Ready to run Phase 1';
  DateTime? _attemptStartedAt;

  @override
  void initState() {
    super.initState();
    _runId = widget.runtimeConfigV1.runIdV1;
  }

  void _logSessionStart() {
    if (_sessionStarted) return;
    final payload = {
      'run_id': _runId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    debugPrint('$_sessionStartEvent ${jsonEncode(payload)}');
    _sessionStarted = true;
  }

  String get _currentPassLabel => _passLabels[_passIndex];

  int get _displayAttemptIndex {
    if (_attemptIndex < 1) return 1;
    if (_attemptIndex > _maxAttempts) return _maxAttempts;
    return _attemptIndex;
  }

  String get _scenarioDescriptor {
    final attemptNum = _displayAttemptIndex;
    final base = 'Spot $_currentPassLabel-$attemptNum';
    if (_passIndex == 1) {
      return '$base (iso repeat)';
    }
    return base;
  }

  String get _layoutDescriptor =>
      _passIndex == 1 ? 'Layout: mirrored labels' : 'Layout: baseline order';

  void _logPass() {
    final payload = {
      'run_id': _runId,
      'pass': _currentPassLabel,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    debugPrint('$_passEvent ${jsonEncode(payload)}');
  }

  void _logAttemptStart() {
    if (_attemptIndex < 1 || _attemptIndex > _maxAttempts) return;
    final payload = {
      'run_id': _runId,
      'attempt': _attemptIndex,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    debugPrint('$_attemptStartEvent ${jsonEncode(payload)}');
  }

  void _logAttemptResult(bool correct) {
    final payload = {
      'run_id': _runId,
      'attempt': _attemptIndex,
      'result': correct ? 'correct' : 'wrong_action',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      if (correct && _attemptStartedAt != null)
        'decision_time_ms': DateTime.now()
            .toUtc()
            .difference(_attemptStartedAt!)
            .inMilliseconds,
    };
    debugPrint('$_attemptResultEvent ${jsonEncode(payload)}');
  }

  void _logFlowEnd(String result) {
    if (_flowLogged) return;
    final payload = {
      'run_id': _runId,
      'result': result,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    debugPrint('$_flowEndEvent ${jsonEncode(payload)}');
    _flowLogged = true;
  }

  void _beginAttempt() {
    _attemptStartedAt = DateTime.now().toUtc();
    _logAttemptStart();
    setState(() {
      _status =
          'Pass $_currentPassLabel attempt $_attemptIndex of $_maxAttempts';
    });
  }

  void _startSession() {
    if (_sessionStarted) return;
    _logSessionStart();
    _passIndex = 0;
    _attemptIndex = 1;
    _logPass();
    _beginAttempt();
  }

  void _submitDecision() {
    if (!_sessionStarted || _attemptIndex > _maxAttempts) return;
    final correct = !_wrongAttempts.contains(_attemptIndex);
    _logAttemptResult(correct);
    if (!correct) {
      setState(() {
        _status = 'Incorrect (wrong_action)';
      });
    }
    if (_attemptIndex >= _maxAttempts) {
      if (_passIndex + 1 < _passLabels.length) {
        _passIndex++;
        _attemptIndex = 1;
        _logPass();
        _beginAttempt();
        return;
      }
      setState(() {
        _status = 'Phase 1 complete';
      });
      _logFlowEnd('completed');
      _attemptIndex = _maxAttempts + 1;
    } else {
      _attemptIndex++;
      _beginAttempt();
    }
  }

  void _finishPhase() {
    if (_navigationHappened) return;
    _navigationHappened = true;
    final result = _flowLogged ? 'completed' : 'canceled';
    _logFlowEnd(result);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom;
    return WillPopScope(
      onWillPop: () async {
        _finishPhase();
        return false;
      },
      child: SharedLearnerCanonicalConsumerPathV1(
        topLevelShellContract: SharedLearnerTopLevelShellContractV1(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Phase 1 Runner'),
            leading: BackButton(onPressed: _finishPhase),
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
                'Phase 1 Learning Effect',
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Confirm the foundation response for the single Phase-1 scenario.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          body: const SizedBox.shrink(),
          bottomBandMaxHeight: 0,
          bottomBandPadding: EdgeInsets.zero,
          bottomBandSurfaceKey: const Key('phase1_runner_bottom_band_v1'),
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
              const Spacer(),
              Text(
                _status,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                _scenarioDescriptor,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              Text(
                _layoutDescriptor,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _sessionStarted ? null : _startSession,
                child: const Text('Start Phase 1'),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_sessionStarted && _attemptIndex <= _maxAttempts)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Decision',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitDecision,
                            child: const Text('Push'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitDecision,
                            child: const Text('Fold'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _finishPhase,
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

const String _phase3TScenarioId = 'pf_btn_02_transfer';

class Phase3TransferRunnerScreen extends StatefulWidget {
  const Phase3TransferRunnerScreen({super.key});

  @override
  State createState() => _Phase3TransferRunnerScreenState();
}

class _Phase3TransferRunnerScreenState
    extends State<Phase3TransferRunnerScreen> {
  static const int _totalAttempts = 6;
  static const int _passSize = 3;
  static const int _seed = 424242;
  static const List<int> _delayOptionsMs = [0, 30000, 300000];

  bool _runStarted = false;
  bool _contractLogged = false;
  final TextEditingController _baselineController = TextEditingController();
  String _runId = '';
  String _status = 'Ready to run Phase 3 Transfer';
  String? _baselineRunId;
  String? _baselineLoadError;
  String? _baselinePickerError;
  int _configuredDelayMs = 0;
  bool _delayActive = false;
  int _delayRemainingSeconds = 0;
  int _delayActualMs = 0;
  Timer? _delayTimer;
  DateTime? _delayStartTime;
  int _currentAttempt = 0;
  bool _runCompleted = false;
  late DateTime _attemptStart;
  final List<Map<String, Object?>> _attemptLog = [];

  void _startRun() {
    if (_runStarted) return;
    setState(() {
      _runStarted = true;
      _baselineRunId = _baselineController.text.isEmpty
          ? null
          : _baselineController.text.trim();
      _runId = _generateRunId();
      _status = 'Phase 3 Transfer attempt 1/$_totalAttempts';
      _currentAttempt = 1;
      _runCompleted = false;
      _attemptLog.clear();
      _delayActualMs = 0;
      _delayActive = _configuredDelayMs > 0;
      if (_delayActive) {
        _delayRemainingSeconds = (_configuredDelayMs / 1000).ceil();
        _delayStartTime = DateTime.now();
        _status = 'Delay ${_delayRemainingSeconds}s before transfer';
        _delayTimer?.cancel();
        _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final now = DateTime.now();
          final elapsed = now.difference(_delayStartTime!).inMilliseconds;
          if (elapsed >= _configuredDelayMs) {
            timer.cancel();
            final actual = now.difference(_delayStartTime!).inMilliseconds;
            setState(() {
              _delayActive = false;
              _delayRemainingSeconds = 0;
              _delayActualMs = actual;
              _attemptStart = DateTime.now();
              _status = 'Phase 3 Transfer attempt 1/$_totalAttempts';
            });
          } else {
            final remaining = (_configuredDelayMs - elapsed) ~/ 1000;
            setState(() {
              _delayRemainingSeconds = remaining + 1;
              _status = 'Delay ${_delayRemainingSeconds}s before transfer';
            });
          }
        });
      } else {
        _attemptStart = DateTime.now();
      }
    });
  }

  void _emitContract() {
    if (_contractLogged) return;
    final correctCount = _attemptLog
        .where((entry) => entry['correct'] == true)
        .length;
    final totalElapsed = _attemptLog
        .map((entry) => entry['elapsed_ms'] as int? ?? 0)
        .fold<int>(0, (acc, value) => acc + value);
    final correctEntries = _attemptLog
        .where((entry) => entry['correct'] == true)
        .toList();
    final correctElapsed = correctEntries
        .map((entry) => entry['elapsed_ms'] as int? ?? 0)
        .fold<int>(0, (acc, value) => acc + value);
    final transferAvg = _attemptLog.isEmpty
        ? 0
        : (totalElapsed / _attemptLog.length).round();
    final transferAvgCorrect = correctEntries.isEmpty
        ? 0
        : (correctElapsed / correctEntries.length).round();
    final transferAccuracy = _attemptLog.isEmpty
        ? 0.0
        : (correctCount / _attemptLog.length * 100);
    _baselineLoadError = null;
    final summary = {
      'run_id': _runId,
      'scenario_id': _phase3TScenarioId,
      'note': 'transfer_probe',
      'baseline_run_id': _baselineRunId,
      'attempts': _totalAttempts,
      'correct': correctCount,
      'seed': _seed,
      'pass_size': _passSize,
      'transfer_attempts': _totalAttempts,
      'transfer_correct': correctCount,
      'transfer_avg_time_ms': transferAvgCorrect,
      'transfer_avg_time_all_ms': transferAvg,
      'transfer_delay_ms_configured': _configuredDelayMs,
      'transfer_delay_ms_actual': _delayActualMs,
      'transfer_accuracy_pct': double.parse(
        transferAccuracy.toStringAsFixed(1),
      ),
    };
    final baselineMetrics = (_baselineRunId?.isNotEmpty == true)
        ? _loadBaselineMetrics(_baselineRunId!)
        : null;
    if (baselineMetrics != null) {
      summary['baseline'] = baselineMetrics.summary;
      summary['delta_vs_baseline_passB_accuracy'] = double.parse(
        ((summary['transfer_accuracy_pct'] as double) -
                baselineMetrics.passBAcc * 100.0)
            .toStringAsFixed(1),
      );
      summary['delta_vs_baseline_passB_avg_time_ms'] =
          transferAvg - baselineMetrics.passBAvgTime;
    } else if (_baselineRunId?.isNotEmpty == true) {
      summary['baseline_load_error'] =
          _baselineLoadError ?? 'baseline_summary_missing';
    }
    debugPrint('PHASE3T_SUMMARY: ${jsonEncode(summary)}');
    debugPrint(
      'PHASE3T_DECK: run_id=$_runId | pf_btn_02_transfer | seed=424242',
    );
    debugPrint('PHASE3T_LOG: ${jsonEncode(_attemptLog)}');
    _contractLogged = true;
  }

  void _recordAttempt(bool correct) {
    if (!_runStarted || _runCompleted) return;
    final elapsed = DateTime.now().difference(_attemptStart).inMilliseconds;
    final entry = {
      'run_id': _runId,
      'attempt_number': _currentAttempt,
      'scenario_id': _phase3TScenarioId,
      'correct': correct,
      'elapsed_ms': elapsed,
      'delay_ms_configured': _configuredDelayMs,
      'delay_ms_actual': _delayActualMs,
      'baseline_run_id': _baselineRunId,
    };
    _attemptLog.add(entry);
    setState(() {
      if (_currentAttempt >= _totalAttempts) {
        _runCompleted = true;
        _status = 'Phase 3 Transfer complete';
        _emitContract();
      } else {
        _currentAttempt++;
        _attemptStart = DateTime.now();
        _status = 'Phase 3 Transfer attempt $_currentAttempt/$_totalAttempts';
      }
    });
  }

  String _generateRunId() =>
      DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');

  _BaselineMetrics? _loadBaselineMetrics(String runId) {
    final runsDir = Directory('tools/_reports/runs');
    final file = File(
      '${runsDir.path}/${runId}_preflop_learning_effect_summary.json',
    );
    if (!file.existsSync()) {
      _baselineLoadError = 'baseline_summary_missing';
      return null;
    }
    try {
      final decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final requiredKeys = [
        'pass_a_accuracy',
        'pass_b_accuracy',
        'pass_a_avg_decision_time_ms',
        'pass_b_avg_decision_time_ms',
        'accuracy_delta',
        'decision_time_delta_ms',
      ];
      for (final key in requiredKeys) {
        if (!decoded.containsKey(key) || decoded[key] == null) {
          _baselineLoadError = 'baseline_summary_missing_keys';
          return null;
        }
      }
      final passAAcc = (decoded['pass_a_accuracy'] as num).toDouble();
      final passBAcc = (decoded['pass_b_accuracy'] as num).toDouble();
      final passAAvg = (decoded['pass_a_avg_decision_time_ms'] as num).toInt();
      final passBAvg = (decoded['pass_b_avg_decision_time_ms'] as num).toInt();
      final accuracyDelta = decoded['accuracy_delta'];
      final timeDelta = decoded['decision_time_delta_ms'];
      return _BaselineMetrics(
        summary: {
          'passA_accuracy': passAAcc,
          'passB_accuracy': passBAcc,
          'passA_avg_time_ms': passAAvg,
          'passB_avg_time_ms': passBAvg,
          'accuracy_delta': accuracyDelta,
          'decision_time_delta_ms': timeDelta,
        },
        passBAcc: passBAcc,
        passBAvgTime: passBAvg,
      );
    } catch (_) {
      _baselineLoadError = 'baseline_summary_parse_error';
      return null;
    }
  }

  void _finish() {
    if (!_contractLogged) return;
    Navigator.of(context).pop();
  }

  void _useLatestBaseline() {
    final runsDir = Directory('tools/_reports/runs');
    if (!runsDir.existsSync()) {
      setState(() {
        _baselinePickerError = 'No runs directory';
      });
      return;
    }

    final matching = runsDir
        .listSync()
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('_preflop_learning_effect_summary.json'),
        )
        .toList();
    if (matching.isEmpty) {
      setState(() {
        _baselinePickerError = 'No baseline summaries found';
      });
      return;
    }

    matching.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );
    final latest = matching.first;
    final name = latest.uri.pathSegments.last;
    final match = RegExp(
      r'^(.+?)_preflop_learning_effect_summary\.json$',
    ).firstMatch(name);
    if (match == null) {
      setState(() {
        _baselinePickerError = 'Unable to parse baseline filename';
      });
      return;
    }

    setState(() {
      _baselineController.text = match.group(1) ?? '';
      _baselinePickerError = null;
    });
  }

  void _selectDelayOption(int delayMs) {
    if (_runStarted) return;
    setState(() {
      _configuredDelayMs = delayMs;
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _baselineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 3 Transfer Runner')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: $_status'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _baselineController,
                decoration: const InputDecoration(
                  labelText: 'Baseline run_id (optional)',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Delay before transfer'),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _delayOptionsMs.map((delayMs) {
                final label = delayMs == 0 ? '0s' : '${delayMs ~/ 1000}s';
                final isSelected = _configuredDelayMs == delayMs;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.blueAccent
                          : Colors.transparent,
                    ),
                    onPressed: () => _selectDelayOption(delayMs),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_baselinePickerError != null) ...[
              const SizedBox(height: 8),
              Text(
                _baselinePickerError!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _useLatestBaseline,
              child: const Text('Use latest baseline'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _runStarted ? null : _startRun,
              child: const Text('Start Phase 3 Transfer (pf_btn_02)'),
            ),
            const SizedBox(height: 16),
            if (_runStarted && !_runCompleted && !_delayActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _recordAttempt(true),
                    child: const Text('Mark correct'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _recordAttempt(false),
                    child: const Text('Mark wrong'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _contractLogged ? _finish : null,
              child: const Text('Finish (Go to Progress Map V2)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaselineMetrics {
  _BaselineMetrics({
    required this.summary,
    required this.passBAcc,
    required this.passBAvgTime,
  });

  final Map<String, Object?> summary;
  final double passBAcc;
  final int passBAvgTime;
}

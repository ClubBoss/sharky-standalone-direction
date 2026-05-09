import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/content/scenario_content_contract_v1.dart';
import 'package:poker_analyzer/learning/learning_engine_v1.dart';

class LearningEngineRunnerScreenV1 extends StatefulWidget {
  const LearningEngineRunnerScreenV1({super.key});

  @override
  State<LearningEngineRunnerScreenV1> createState() =>
      _LearningEngineRunnerScreenV1State();
}

class _LearningEngineRunnerScreenV1State
    extends State<LearningEngineRunnerScreenV1> {
  static const String _scenarioAssetPath = 'assets/scenarios/demo_hu.json';
  static const String _errorClassFallback = 'engine_v1_error';
  final LearningEngineV1 _engine = LearningEngineV1();

  ScenarioContentSpecV1? _spec;
  String? _loadError;
  EngineTelemetryV1? _lastTelemetry;
  String? _lastLine;
  bool _attemptActive = false;

  @override
  void initState() {
    super.initState();
    assert(kDebugMode);
    _loadScenario();
  }

  Future<void> _loadScenario() async {
    try {
      final content = await rootBundle.loadString(_scenarioAssetPath);
      final decoded = jsonDecode(content) as Map<String, Object?>;
      final spec = ScenarioContentSpecV1.fromMap(decoded);
      setState(() {
        _spec = spec;
        _loadError = null;
      });
      _startAttempt();
    } catch (error) {
      setState(() {
        _loadError = 'Scenario load error: $error';
      });
    }
  }

  void _startAttempt() {
    _engine.startAttempt(DateTime.now().toUtc());
    setState(() {
      _attemptActive = true;
      _lastTelemetry = null;
      _lastLine = null;
    });
  }

  Future<void> _submitChoice(String choice) async {
    final spec = _spec;
    if (spec == null || !_attemptActive) return;
    final telemetry = _engine.submitChoice(
      userChoice: choice,
      now: DateTime.now().toUtc(),
      expectedBestAction: spec.decisionNode.solutionBestAction,
      errorClass: spec.decisionNode.errorClass ?? _errorClassFallback,
    );
    final payload = {
      'user_choice': telemetry.userChoice,
      'is_correct': telemetry.isCorrect,
      'error_class': telemetry.errorClass,
      'time_to_decision_ms': telemetry.timeToDecisionMs,
      'scenario_asset': _scenarioAssetPath,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    final line = jsonEncode(payload);
    final path = _outputPath();
    await File(path).writeAsString('$line\n', mode: FileMode.append);
    setState(() {
      _attemptActive = false;
      _lastTelemetry = telemetry;
      _lastLine = line;
    });
  }

  String _outputPath() {
    final dir = Directory.systemTemp.path;
    return '$dir/learning_engine_telemetry_v1.jsonl';
  }

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final actions = spec?.decisionNode.legalActions ?? const <String>[];
    final outputPath = _outputPath();
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Engine Runner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scenario: $_scenarioAssetPath'),
            Text('Output: $outputPath'),
            const SizedBox(height: 12),
            if (_loadError != null) Text(_loadError!),
            if (spec != null) ...[
              Text('Expected: ${spec.decisionNode.solutionBestAction}'),
              Text(
                'Error class: ${spec.decisionNode.errorClass ?? _errorClassFallback}',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final action in actions)
                    ElevatedButton(
                      onPressed: _attemptActive
                          ? () => _submitChoice(action)
                          : null,
                      child: Text(action),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (!_attemptActive)
                OutlinedButton(
                  onPressed: _startAttempt,
                  child: const Text('Start next attempt'),
                ),
              if (_lastLine != null) ...[
                const SizedBox(height: 12),
                const Text('Last emitted JSON:'),
                SelectableText(_lastLine!),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

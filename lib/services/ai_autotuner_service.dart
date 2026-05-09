import 'dart:convert';
import 'dart:io';

class AiAutotunerService {
  AiAutotunerService({
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.statePath = 'release/_reports/ai_autotune_state.json',
    this.learningRate = 0.02,
    this.winRateTarget = 0.50,
    this.winRateTolerance = 0.06,
    this.bluffTarget = 0.22,
    this.bluffTolerance = 0.06,
  });

  final String telemetryPath;
  final String statePath;
  final double learningRate;
  final double winRateTarget;
  final double winRateTolerance;
  final double bluffTarget;
  final double bluffTolerance;

  Future<AutotuneResult> runCycle() async {
    final telemetryFile = File(telemetryPath);
    if (!telemetryFile.existsSync()) {
      return AutotuneResult.empty('Telemetry log not found at $telemetryPath');
    }

    final winSamples = <double>[];
    final bluffSamples = <double>[];
    final sessionSamples = <double>[];
    final evSamples = <double>[];
    final lines = await telemetryFile.readAsLines();
    for (final raw in lines) {
      if (raw.trim().isEmpty) continue;
      Map<String, dynamic> event;
      try {
        event = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final name = event['event']?.toString() ?? '';
      switch (name) {
        case 'ai_reliability_calibrated':
          final win = _readDouble(event['win_rate']);
          final bluff = _readDouble(event['bluff_rate']);
          if (win != null) winSamples.add(win);
          if (bluff != null) bluffSamples.add(bluff);
          break;
        case 'session_accuracy':
          final accuracy = _readDouble(event['accuracy']);
          if (accuracy != null) sessionSamples.add(accuracy);
          break;
        case 'session_ev_delta':
        case 'ev_delta':
          final delta = _readDouble(event['delta']);
          if (delta != null) evSamples.add(delta);
          break;
      }
    }

    final state = await _readState();
    final sessionAvg = sessionSamples.isEmpty ? null : _average(sessionSamples);
    final evAvg = evSamples.isEmpty ? null : _average(evSamples);
    final winAvg = winSamples.isEmpty ? null : _average(winSamples);
    final bluffAvg = bluffSamples.isEmpty ? null : _average(bluffSamples);
    final adjustments = <String, double>{};
    final notes = <String>[];

    if (winAvg != null) {
      final diff = winAvg - winRateTarget;
      final delta = _boundedDelta(diff, winRateTolerance);
      final updated = _applyScale(state.aggressionScale, -delta);
      if (updated != state.aggressionScale) {
        state.aggressionScale = updated;
        adjustments['aggression_scale'] = updated;
      }
    }

    if (bluffAvg != null) {
      final diff = bluffAvg - bluffTarget;
      final delta = _boundedDelta(diff, bluffTolerance);
      final updated = _applyScale(state.bluffScale, -delta);
      if (updated != state.bluffScale) {
        state.bluffScale = updated;
        adjustments['bluff_scale'] = updated;
      }
    }

    state.lastUpdated = DateTime.now().toUtc().toIso8601String();
    await _writeState(state);

    if (sessionAvg != null) {
      notes.add('Session accuracy mean: ${sessionAvg.toStringAsFixed(4)}');
    }
    if (evAvg != null) {
      notes.add('EV delta mean: ${evAvg.toStringAsFixed(4)}');
    }
    if (adjustments.isEmpty) {
      notes.add('No telemetry deltas detected; state unchanged.');
    }

    return AutotuneResult(
      success: adjustments.isNotEmpty,
      sessions: sessionSamples.length,
      adjustments: adjustments,
      warnings: adjustments.isEmpty ? 1 : 0,
      notes: notes,
    );
  }

  double _boundedDelta(double diff, double tolerance) {
    if (tolerance == 0) return 0;
    final normalized = (diff / tolerance).clamp(-1.0, 1.0);
    return normalized * learningRate;
  }

  double _applyScale(double current, double delta) {
    final updated = current * (1 + delta);
    return updated.clamp(0.8, 1.2);
  }

  Future<_AutotuneState> _readState() async {
    final file = File(statePath);
    if (!file.existsSync()) {
      return _AutotuneState.initial();
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return _AutotuneState.fromJson(decoded);
      }
    } catch (_) {}
    return _AutotuneState.initial();
  }

  Future<void> _writeState(_AutotuneState state) async {
    final file = File(statePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
    );
  }

  double? _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  double _average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;
}

class AutotuneResult {
  AutotuneResult({
    required this.success,
    required this.sessions,
    required this.adjustments,
    required this.warnings,
    required this.notes,
  });

  factory AutotuneResult.empty(String note) => AutotuneResult(
    success: false,
    sessions: 0,
    adjustments: const {},
    warnings: 1,
    notes: <String>[note],
  );

  final bool success;
  final int sessions;
  final Map<String, double> adjustments;
  final int warnings;
  final List<String> notes;

  void printSummary() {
    const border = '+----------------------+--------------------+';
    stdout.writeln(border);
    stdout.writeln('| Metric               | Value              |');
    stdout.writeln(border);
    stdout.writeln(
      '| Sessions analyzed    | '
      '${sessions.toString().padLeft(18)} |',
    );
    stdout.writeln(
      '| Adjustments applied  | '
      '${adjustments.length.toString().padLeft(18)} |',
    );
    stdout.writeln(
      '| Success              | '
      '${(success ? 'PASS' : 'WARN').padLeft(18)} |',
    );
    stdout.writeln(border);
    if (adjustments.isNotEmpty) {
      stdout.writeln('Adjustments:');
      adjustments.forEach((key, value) {
        stdout.writeln('  - $key -> ${value.toStringAsFixed(4)}');
      });
    }
    if (notes.isNotEmpty) {
      stdout.writeln('Notes:');
      for (final note in notes) {
        stdout.writeln('  - $note');
      }
    }
  }
}

class _AutotuneState {
  _AutotuneState({
    required this.aggressionScale,
    required this.bluffScale,
    required this.lastUpdated,
  });

  double aggressionScale;
  double bluffScale;
  String lastUpdated;

  factory _AutotuneState.initial() => _AutotuneState(
    aggressionScale: 1.0,
    bluffScale: 1.0,
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(
      0,
    ).toUtc().toIso8601String(),
  );

  factory _AutotuneState.fromJson(Map<String, dynamic> json) => _AutotuneState(
    aggressionScale: (json['aggression_scale'] as num?)?.toDouble() ?? 1.0,
    bluffScale: (json['bluff_scale'] as num?)?.toDouble() ?? 1.0,
    lastUpdated: json['last_updated']?.toString() ?? '',
  );

  Map<String, Object> toJson() => {
    'aggression_scale': double.parse(aggressionScale.toStringAsFixed(6)),
    'bluff_scale': double.parse(bluffScale.toStringAsFixed(6)),
    'last_updated': lastUpdated,
  };
}

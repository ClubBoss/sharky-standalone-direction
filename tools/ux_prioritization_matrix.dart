import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final matrix = _UxPrioritizationMatrix();
  try {
    final result = await matrix.build();
    await matrix.writeReport(result);
    await matrix.emitTelemetry(result);
  } finally {
    await matrix.restorePermissions();
  }
}

class _UxPrioritizationMatrix {
  bool _madeWritable = false;

  Future<_MatrixResult> build() async {
    final source = File('release/_reports/design_refinement_report.md');
    if (!source.existsSync()) {
      throw StateError('design_refinement_report.md not found.');
    }

    final lines = await source.readAsLines();
    final scores = _parseScores(lines);
    final improvements = _parseImprovements(lines);

    final weightedScore = _weightedScore(scores);
    final weightedUrgency = (100 - weightedScore).clamp(0, 100);

    final enriched = _prioritize(improvements, scores);

    return _MatrixResult(
      timestamp: DateTime.now().toUtc(),
      scores: scores,
      weightedScore: weightedScore,
      weightedUrgency: weightedUrgency.toDouble(),
      priorities: enriched,
    );
  }

  Future<void> writeReport(_MatrixResult result) async {
    final buffer = StringBuffer()
      ..writeln('# UX Prioritization Matrix')
      ..writeln('Generated: ${result.timestamp.toIso8601String()}')
      ..writeln('Source: design_refinement_report.md')
      ..writeln()
      ..writeln('Weighted score: ${result.weightedScore.toStringAsFixed(2)}')
      ..writeln(
        'Weighted urgency: ${result.weightedUrgency.toStringAsFixed(2)}',
      )
      ..writeln()
      ..writeln('## Dimension Inputs')
      ..writeln('| Dimension | Score | Weight |')
      ..writeln('|-----------|-------|--------|');
    for (final entry in _weights.entries) {
      final score = result.scores[entry.key] ?? 0;
      buffer.writeln(
        '| ${entry.key} | ${score.toString().padLeft(3)} | '
        '${entry.value.toStringAsFixed(2)} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Priority Actions')
      ..writeln('| Rank | Area | Impact | Driver | Action |')
      ..writeln('|------|------|--------|--------|--------|');

    for (var i = 0; i < result.priorities.length; i += 1) {
      final item = result.priorities[i];
      buffer.writeln(
        '| ${i + 1} | ${item.area} | ${item.impact} '
        '| ${item.driver} | ${item.action} |',
      );
    }

    await _safeWrite(
      File('release/_reports/ux_prioritization_matrix.md'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_MatrixResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.uxPrioritizationCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'weighted_score': result.weightedScore,
      'weighted_urgency': result.weightedUrgency,
      'priority_count': result.priorities.length,
      'top_area': result.priorities.isEmpty ? '' : result.priorities.first.area,
    };

    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  Future<void> restorePermissions() async {
    if (_madeWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _madeWritable = false;
    }
  }

  Map<String, int> _parseScores(List<String> lines) {
    final scores = <String, int>{};
    final pattern = RegExp(r'^\|\s*(\w+)\s*\|\s*(\d+)');
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        scores[match.group(1)!] = int.parse(match.group(2)!);
      }
    }
    return scores;
  }

  List<_ImprovementEntry> _parseImprovements(List<String> lines) {
    final improvements = <_ImprovementEntry>[];
    final pattern = RegExp(
      r'^\|\s*(\d+)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(High|Medium|Low)\s*\|',
    );
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        improvements.add(
          _ImprovementEntry(
            rank: int.parse(match.group(1)!),
            area: match.group(2)!.trim(),
            action: match.group(3)!.trim(),
            impact: match.group(4)!.trim(),
          ),
        );
      }
    }
    return improvements;
  }

  double _weightedScore(Map<String, int> scores) {
    var total = 0.0;
    for (final entry in _weights.entries) {
      total += (scores[entry.key] ?? 0) * entry.value;
    }
    return total;
  }

  List<_PriorityItem> _prioritize(
    List<_ImprovementEntry> improvements,
    Map<String, int> scores,
  ) {
    final items = <_PriorityItem>[];
    for (final improvement in improvements) {
      final dimension = _dimensionForArea(improvement.area);
      final dimensionScore = scores[dimension] ?? _weightedScore(scores);
      final urgency = (100 - dimensionScore).clamp(0, 100);
      final impactWeight = _impactWeight(improvement.impact);
      final driver =
          '$dimension score=${dimensionScore.toStringAsFixed(0)} ⇒ urgency ${urgency.toStringAsFixed(0)}';
      items.add(
        _PriorityItem(
          area: improvement.area,
          action: improvement.action,
          impact: improvement.impact,
          urgency: urgency.toDouble(),
          impactWeight: impactWeight,
          driver: driver,
        ),
      );
    }

    items.sort((a, b) {
      final impactCompare = b.impactWeight.compareTo(a.impactWeight);
      if (impactCompare != 0) {
        return impactCompare;
      }
      final urgencyCompare = b.urgency.compareTo(a.urgency);
      if (urgencyCompare != 0) {
        return urgencyCompare;
      }
      return a.area.compareTo(b.area);
    });

    if (items.length > 10) {
      return items.sublist(0, 10);
    }
    return items;
  }

  String _dimensionForArea(String area) {
    final normalized = area.toLowerCase();
    if (normalized.contains('balance')) return 'Balance';
    if (normalized.contains('ergonomic')) return 'Ergonomics';
    if (normalized.contains('contrast') || normalized.contains('consistency')) {
      return 'Contrast';
    }
    if (normalized.contains('motion') ||
        normalized.contains('performance') ||
        normalized.contains('telemetry')) {
      return 'Motion';
    }
    if (normalized.contains('clarity') ||
        normalized.contains('documentation') ||
        normalized.contains('testing') ||
        normalized.contains('focus') ||
        normalized.contains('quality')) {
      return 'Clarity';
    }
    return 'Ergonomics';
  }

  int _impactWeight(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }

  Future<void> _safeWrite(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _safeAppend(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents, mode: FileMode.append);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents, mode: FileMode.append);
    }
  }

  Future<void> _makeWritable() async {
    if (_madeWritable) {
      return;
    }
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }
}

const Map<String, double> _weights = <String, double>{
  'Balance': 0.2,
  'Ergonomics': 0.3,
  'Contrast': 0.25,
  'Motion': 0.15,
  'Clarity': 0.1,
};

class _ImprovementEntry {
  const _ImprovementEntry({
    required this.rank,
    required this.area,
    required this.action,
    required this.impact,
  });

  final int rank;
  final String area;
  final String action;
  final String impact;
}

class _PriorityItem {
  _PriorityItem({
    required this.area,
    required this.action,
    required this.impact,
    required this.urgency,
    required this.impactWeight,
    required this.driver,
  });

  final String area;
  final String action;
  final String impact;
  final double urgency;
  final int impactWeight;
  final String driver;
}

class _MatrixResult {
  _MatrixResult({
    required this.timestamp,
    required this.scores,
    required this.weightedScore,
    required this.weightedUrgency,
    required this.priorities,
  });

  final DateTime timestamp;
  final Map<String, int> scores;
  final double weightedScore;
  final double weightedUrgency;
  final List<_PriorityItem> priorities;
}

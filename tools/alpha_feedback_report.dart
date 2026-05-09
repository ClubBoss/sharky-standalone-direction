import 'dart:convert';
import 'dart:io';

Future<int> main(List<String> args) async {
  final options = _Options.parse(args);
  if (options == null) {
    return 64; // usage error
  }

  final file = File(options.path);
  if (!file.existsSync()) {
    stderr.writeln('[AlphaFeedback] Missing file: ${options.path}');
    return 66; // EX_NOINPUT
  }

  final entries = await _readEntries(file);
  final report = _Report.fromEntries(entries);

  _printReport(report);
  return 0;
}

class _Options {
  _Options(this.path);

  final String path;

  static _Options? parse(List<String> args) {
    if (args.length != 2 || args[0] != '--file') {
      _printUsage();
      return null;
    }
    return _Options(args[1]);
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tools/alpha_feedback_report.dart --file <path>',
  );
}

Future<List<_FeedbackEntry>> _readEntries(File file) async {
  final lines = await file.readAsLines();
  final entries = <_FeedbackEntry>[];
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final entry = _FeedbackEntry.fromJson(decoded);
        if (entry != null) {
          entries.add(entry);
        }
      }
    } catch (_) {
      // Ignore malformed lines; keep report resilient to partial exports.
    }
  }
  return entries;
}

class _FeedbackEntry {
  _FeedbackEntry({
    required this.classification,
    this.flowId,
    this.scenarioId,
    this.scenarioTitle,
    this.stepIndex,
    this.stepTotal,
  });

  final String classification;
  final String? flowId;
  final String? scenarioId;
  final String? scenarioTitle;
  final int? stepIndex;
  final int? stepTotal;

  bool get isUnclear => classification == 'unclear';

  static _FeedbackEntry? fromJson(Map<String, dynamic> json) {
    final classification = _parseClassification(json);
    if (classification == null) return null;

    return _FeedbackEntry(
      classification: classification,
      flowId: _asString(json['flow_id']),
      scenarioId: _asString(json['scenario_id']),
      scenarioTitle: _asString(json['scenario_title']),
      stepIndex: _asInt(json['step_index'] ?? json['step']),
      stepTotal: _asInt(json['step_total']),
    );
  }

  static String? _parseClassification(Map<String, dynamic> json) {
    final candidates = [
      json['classification'],
      json['type'],
      json['kind'],
      json['label'],
      json['category'],
    ];
    for (final candidate in candidates) {
      final value = _asString(candidate);
      if (value != null && value.isNotEmpty) {
        return value.toLowerCase();
      }
    }
    return null;
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }
}

class _Report {
  _Report({required this.entries, required this.unclearGroups});

  final List<_FeedbackEntry> entries;
  final List<_UnclearGroup> unclearGroups;

  static _Report fromEntries(List<_FeedbackEntry> entries) {
    final unclearGroups = <String, _UnclearGroup>{};

    for (final entry in entries) {
      if (!entry.isUnclear) continue;
      final flow = entry.flowId ?? 'unknown';
      final scenario = entry.scenarioTitle ?? entry.scenarioId ?? 'unknown';
      final key = '$flow::$scenario';
      final stepLabel = _formatStep(entry.stepIndex, entry.stepTotal);
      final group = unclearGroups.putIfAbsent(
        key,
        () => _UnclearGroup(flow: flow, scenario: scenario),
      );
      group.count += 1;
      if (stepLabel != null) {
        group.steps.add(stepLabel);
      }
    }

    final sortedGroups = unclearGroups.values.toList()
      ..sort((a, b) {
        final flowCompare = a.flow.compareTo(b.flow);
        if (flowCompare != 0) return flowCompare;
        return a.scenario.compareTo(b.scenario);
      });

    return _Report(entries: entries, unclearGroups: sortedGroups);
  }
}

class _UnclearGroup {
  _UnclearGroup({required this.flow, required this.scenario});

  final String flow;
  final String scenario;
  int count = 0;
  final Set<String> steps = <String>{};
}

String? _formatStep(int? index, int? total) {
  if (index == null && total == null) return null;
  final idxText = index != null ? index.toString() : '?';
  final totalText = total != null ? '/$total' : '';
  return '$idxText$totalText';
}

void _printReport(_Report report) {
  stdout.writeln('Alpha Feedback Report');
  stdout.writeln('Entries: ${report.entries.length}');

  stdout.writeln('Unclear feedback grouped by flow/scenario:');
  if (report.unclearGroups.isEmpty) {
    stdout.writeln('- none');
    return;
  }

  for (final group in report.unclearGroups) {
    final steps = group.steps.toList()..sort();
    final stepsText = steps.isEmpty
        ? 'steps=[]'
        : 'steps=[${steps.join(', ')}]';
    stdout.writeln(
      '- flow=${group.flow} scenario=${group.scenario} count=${group.count} $stepsText',
    );
  }
}

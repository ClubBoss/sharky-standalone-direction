import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Content Flow Audit (Stage 81B)
///
/// Scans all JSONL content packs under `content/**/v*/`, builds a chronological
/// view of module progression, and surfaces flow anomalies along with coverage
/// distribution metrics for dashboard consumption.
Future<void> main(List<String> args) async {
  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    final emptyReport = _FlowReport.empty();
    emptyReport.emit();
    return;
  }

  final jsonlFiles =
      contentDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.jsonl'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (jsonlFiles.isEmpty) {
    final emptyReport = _FlowReport.empty();
    emptyReport.emit();
    return;
  }

  final modules = <String, _Module>{};
  final entryIds = <String>{};
  final nextChecks = <_Entry>[];

  for (final file in jsonlFiles) {
    final moduleKey = _resolveModuleKey(file.path);
    final module = modules.putIfAbsent(
      moduleKey,
      () => _Module(moduleKey: moduleKey),
    );
    module.fileCount++;

    final detectedType = _detectTypeFromPath(file.path);
    final lines = file.readAsLinesSync();
    module.lineCount += lines.length;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          module.parseErrors++;
          continue;
        }
      } catch (_) {
        module.parseErrors++;
        continue;
      }
      final entry = _Entry.fromData(
        data: data,
        moduleKey: moduleKey,
        fallbackType: detectedType,
      );
      module.addEntry(entry);
      if (entry.id != null) {
        entryIds.add(entry.id!);
      }
      if (entry.nextIds.isNotEmpty ||
          (entry.contentType != null &&
              _typesNeedingTransition.contains(entry.contentType))) {
        nextChecks.add(entry);
      }
    }
  }

  final modulesList = modules.values.toList()
    ..sort((a, b) => a.moduleKey.compareTo(b.moduleKey));

  int difficultyJumps = 0;
  int xpSpikes = 0;
  int missingLinks = 0;
  double? prevDifficulty;
  double? prevXp;

  final incompleteModules = <String>[];
  final coverageTotals = <String, int>{
    for (final type in _coverageTypes) type: 0,
  };

  for (final entry in nextChecks) {
    if (entry.nextIds.isEmpty) {
      // Count empty transitions for tracked content types.
      if (entry.contentType != null &&
          _typesNeedingTransition.contains(entry.contentType)) {
        missingLinks++;
      }
      continue;
    }
    for (final nextId in entry.nextIds) {
      if (nextId.isEmpty || !entryIds.contains(nextId)) {
        missingLinks++;
      }
    }
  }

  for (final module in modulesList) {
    if (!module.hasFlowCoverage) {
      incompleteModules.add(module.moduleKey);
    }

    final avgDifficulty = module.averageDifficulty;
    final avgXp = module.averageXp;
    if (avgDifficulty != null && prevDifficulty != null) {
      final delta = avgDifficulty - prevDifficulty;
      final base = prevDifficulty.abs() < 1e-6 ? 0.0 : prevDifficulty;
      if (base > 0 && (delta / base).abs() > 0.30) {
        difficultyJumps++;
      }
    }
    if (avgXp != null && prevXp != null) {
      final delta = avgXp - prevXp;
      final base = prevXp.abs() < 1e-6 ? 0.0 : prevXp;
      if (base > 0 && (delta / base) > 0.40) {
        xpSpikes++;
      }
    }
    if (avgDifficulty != null) {
      prevDifficulty = avgDifficulty;
    }
    if (avgXp != null) {
      prevXp = avgXp;
    }

    for (final type in _coverageTypes) {
      coverageTotals[type] = coverageTotals[type]! + module.coverage[type]!;
    }
  }

  final totalEntries = coverageTotals.values.fold<int>(
    0,
    (sum, value) => sum + value,
  );

  final coverageRatios = <String, double>{
    for (final type in _coverageTypes)
      type: totalEntries == 0
          ? 0.0
          : (coverageTotals[type]! / max(1, totalEntries)) * 100.0,
  };

  final ideal = 100.0 / _coverageTypes.length;
  var pass = totalEntries > 0;
  for (final type in _coverageTypes) {
    final ratio = coverageRatios[type] ?? 0.0;
    if (ratio < 10.0) {
      pass = false;
    }
    if ((ratio - ideal).abs() > 20.0) {
      pass = false;
    }
  }

  final report = _FlowReport(
    modules: modulesList.length,
    files: jsonlFiles.length,
    difficultyJumps: difficultyJumps,
    xpSpikes: xpSpikes,
    missingLinks: missingLinks,
    coverageRatios: coverageRatios,
    pass: pass,
    incompleteModules: incompleteModules,
  );

  report.emit();
}

const _coverageTypes = <String>[
  'theory',
  'demo',
  'drill',
  'quiz',
  'recap',
  'lab',
];

Map<String, double> _emptyCoverageRatios() {
  return {for (final type in _coverageTypes) type: 0.0};
}

const _typesNeedingTransition = <String>{'recap', 'quiz', 'lab'};

String _resolveModuleKey(String path) {
  final parts = path.split(Platform.pathSeparator);
  final buffer = <String>[];
  for (final part in parts) {
    buffer.add(part);
    if (RegExp(r'^v\d+', caseSensitive: false).hasMatch(part)) {
      break;
    }
  }
  return buffer.join(Platform.pathSeparator);
}

String? _detectTypeFromPath(String path) {
  final fileName = path
      .split(Platform.pathSeparator)
      .last
      .toLowerCase()
      .replaceAll('.jsonl', '');
  if (fileName.startsWith('demo')) return 'demo';
  if (fileName.startsWith('drill')) return 'drill';
  if (fileName.startsWith('quiz')) return 'quiz';
  if (fileName.startsWith('recap')) return 'recap';
  if (fileName.startsWith('lab')) return 'lab';
  if (fileName.startsWith('theory')) return 'theory';
  return null;
}

class _Module {
  _Module({required this.moduleKey});

  final String moduleKey;
  final List<_Entry> entries = [];
  final Map<String, int> coverage = <String, int>{
    for (final type in _coverageTypes) type: 0,
  };
  int fileCount = 0;
  int lineCount = 0;
  int parseErrors = 0;
  double _difficultySum = 0;
  double _xpSum = 0;
  int _difficultyCount = 0;
  int _xpCount = 0;

  void addEntry(_Entry entry) {
    entries.add(entry);
    final type = entry.contentType;
    if (type != null && coverage.containsKey(type)) {
      coverage[type] = coverage[type]! + 1;
    }
    final diff = entry.difficulty;
    if (diff != null) {
      _difficultySum += diff;
      _difficultyCount++;
    }
    final xp = entry.xpValue;
    if (xp != null) {
      _xpSum += xp;
      _xpCount++;
    }
  }

  bool get hasFlowCoverage {
    var nonZeroBuckets = 0;
    for (final type in _coverageTypes) {
      if ((coverage[type] ?? 0) > 0) {
        nonZeroBuckets++;
      }
    }
    return nonZeroBuckets >= 3;
  }

  double? get averageDifficulty =>
      _difficultyCount == 0 ? null : _difficultySum / _difficultyCount;

  double? get averageXp => _xpCount == 0 ? null : _xpSum / _xpCount;
}

class _Entry {
  _Entry({
    required this.moduleKey,
    this.id,
    this.contentType,
    this.difficulty,
    this.xpValue,
    List<String>? nextIds,
  }) : nextIds = nextIds ?? const [];

  factory _Entry.fromData({
    required Map<String, dynamic> data,
    required String moduleKey,
    String? fallbackType,
  }) {
    final id = _asString(data['id']);
    final type = _inferType(data, fallbackType);
    final difficulty = _parseDifficulty(data);
    final xpValue = _parseXp(data['xp_value'] ?? data['xp_reward']);
    final nextIds = _parseNext(data['next']);

    return _Entry(
      moduleKey: moduleKey,
      id: id,
      contentType: type,
      difficulty: difficulty,
      xpValue: xpValue,
      nextIds: nextIds,
    );
  }

  final String moduleKey;
  final String? id;
  final String? contentType;
  final double? difficulty;
  final double? xpValue;
  final List<String> nextIds;
}

class _FlowReport {
  const _FlowReport({
    required this.modules,
    required this.files,
    required this.difficultyJumps,
    required this.xpSpikes,
    required this.missingLinks,
    required this.coverageRatios,
    required this.pass,
    required this.incompleteModules,
  });

  factory _FlowReport.empty() => _FlowReport(
    modules: 0,
    files: 0,
    difficultyJumps: 0,
    xpSpikes: 0,
    missingLinks: 0,
    coverageRatios: _emptyCoverageRatios(),
    pass: false,
    incompleteModules: const <String>[],
  );

  final int modules;
  final int files;
  final int difficultyJumps;
  final int xpSpikes;
  final int missingLinks;
  final Map<String, double> coverageRatios;
  final bool pass;
  final List<String> incompleteModules;

  void emit() {
    final status = pass ? 'PASS (✓)' : 'FAIL (✗)';
    stdout.writeln('Content Flow Audit: $status');
    stdout.writeln('$modules modules / $files files analyzed');
    stdout.writeln(
      '$difficultyJumps difficulty jumps, '
      '$xpSpikes XP spikes, $missingLinks missing links',
    );
    final coverageLine = StringBuffer('Coverage → ');
    var first = true;
    for (final type in _coverageTypes) {
      if (!first) coverageLine.write(', ');
      first = false;
      final value = coverageRatios[type] ?? 0.0;
      coverageLine.write('$type ${value.round()} %');
    }
    stdout.writeln(coverageLine.toString());
    if (incompleteModules.isNotEmpty) {
      final preview = incompleteModules.length <= 5
          ? incompleteModules
          : incompleteModules.sublist(0, 5);
      final suffix = incompleteModules.length > preview.length
          ? ' ... (+${incompleteModules.length - preview.length} more)'
          : '';
      stdout.writeln('Incomplete packs: ${preview.join(', ')}$suffix');
    }
    final reportFile = File('tools/_reports/content_flow_audit.json');
    final reportDir = reportFile.parent;
    if (!reportDir.existsSync()) {
      reportDir.createSync(recursive: true);
    }
    final jsonReport = jsonEncode({
      'modules': modules,
      'files': files,
      'difficulty_jumps': difficultyJumps,
      'xp_spikes': xpSpikes,
      'missing_links': missingLinks,
      'coverage': {
        for (final type in _coverageTypes)
          type: (coverageRatios[type] ?? 0.0).round(),
      },
      'pass': pass,
      if (incompleteModules.isNotEmpty) 'incomplete_modules': incompleteModules,
    });
    reportFile.writeAsStringSync(jsonReport);
  }
}

List<String> _parseNext(dynamic value) {
  if (value == null) return const [];
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    return [trimmed];
  }
  if (value is List) {
    final result = <String>[];
    for (final item in value) {
      if (item is String && item.trim().isNotEmpty) {
        result.add(item.trim());
      }
    }
    return result;
  }
  return const [];
}

double? _parseDifficulty(Map<String, dynamic> data) {
  final difficultyScore = data['difficulty_score'];
  if (difficultyScore is num) return difficultyScore.toDouble();
  final difficulty = data['difficulty'];
  if (difficulty is num) return difficulty.toDouble();
  if (difficulty is String) {
    final normalized = difficulty.toLowerCase();
    if (normalized == 'easy') return 0.8;
    if (normalized == 'medium') return 1.0;
    if (normalized == 'hard') return 1.2;
  }
  return null;
}

double? _parseXp(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}

String? _inferType(Map<String, dynamic> data, String? fallbackType) {
  final type =
      _asString(data['content_type']) ??
      _asString(data['type']) ??
      _inferTypeFromId(_asString(data['id'])) ??
      fallbackType;
  if (type == null) return null;
  final normalized = type.toLowerCase();
  if (normalized.startsWith('demo')) return 'demo';
  if (normalized.startsWith('drill')) return 'drill';
  if (normalized.startsWith('quiz')) return 'quiz';
  if (normalized.startsWith('recap')) return 'recap';
  if (normalized.startsWith('lab')) return 'lab';
  if (normalized.startsWith('theory')) return 'theory';
  return null;
}

String? _inferTypeFromId(String? id) {
  if (id == null) return null;
  final normalized = id.toLowerCase();
  if (normalized.contains('demo')) return 'demo';
  if (normalized.contains('drill')) return 'drill';
  if (normalized.contains('quiz')) return 'quiz';
  if (normalized.contains('recap')) return 'recap';
  if (normalized.contains('lab')) return 'lab';
  if (normalized.contains('theory')) return 'theory';
  return null;
}

String? _asString(dynamic value) {
  if (value is String) return value.trim();
  return null;
}

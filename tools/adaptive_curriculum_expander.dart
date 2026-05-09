import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _contentRoot = 'content';
const String _fusionRoot = '_fusion_/drills';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/adaptive_curriculum_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

const List<String> _monitoredBands = ['easy', 'medium', 'hard'];
const double _minDifficultyShare = 0.2;
const int _absoluteMinModules = 6;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final snapshot = await _collectSnapshot();
  if (snapshot.packs.isEmpty) {
    stdout.writeln('adaptive_curriculum_expander: no curriculum files found.');
    return;
  }

  final analysis = _analyzeCoverage(snapshot.packs);

  await _withReportsWritable(() async {
    await _writeSummary(snapshot, analysis);
    await _appendTelemetry(
      newVariants: analysis.totalActions,
      coveragePct: analysis.coveragePct,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_curriculum_expander: '
    '${analysis.recommendations.length} packs flagged, '
    '${analysis.totalActions} recommended actions.',
  );
}

Future<_CurriculumSnapshot> _collectSnapshot() async {
  final packsById = <String, _PackAggregate>{};
  final fusionSources = <String>[];

  final contentDir = Directory(_contentRoot);
  if (await contentDir.exists()) {
    await for (final entity in contentDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (!FileSystemEntity.isDirectorySync(entity.path)) continue;
      if (!entity.path.endsWith('${Platform.pathSeparator}v1')) continue;
      final packId = _packIdFromV1(entity.path);
      if (packId.isEmpty) continue;
      final pack = packsById.putIfAbsent(
        packId,
        () => _PackAggregate(packId, Directory(entity.path)),
      );
      _ingestJsonlFiles(pack, Directory(entity.path));
    }
  }

  final fusionDir = Directory(_fusionRoot);
  if (fusionDir.existsSync()) {
    final v1Dir = Directory('${fusionDir.path}/v1');
    if (v1Dir.existsSync()) {
      final fusionPackId = 'fusion:${fusionDir.path.replaceAll('/', '_')}';
      final pack = packsById.putIfAbsent(
        fusionPackId,
        () => _PackAggregate(fusionPackId, v1Dir),
      );
      _ingestJsonlFiles(pack, v1Dir);
      fusionSources.add(_fusionRoot);
    }
  }

  return _CurriculumSnapshot(
    packs: packsById.values.toList(),
    fusionSources: fusionSources,
  );
}

void _ingestJsonlFiles(_PackAggregate pack, Directory dir) {
  final files = dir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.jsonl'));
  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty || raw.startsWith('#')) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          pack.addModule(
            _ModuleRecord(
              id: decoded['id']?.toString() ?? '${file.path}:${i + 1}',
              spotKind: decoded['spot_kind']?.toString(),
              difficulty: decoded['difficulty']?.toString(),
              difficultyScore: (decoded['difficulty_score'] as num?)
                  ?.toDouble(),
              goal: decoded['goal']?.toString(),
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }
  }
}

_AnalysisResult _analyzeCoverage(List<_PackAggregate> packs) {
  packs.sort((a, b) => a.id.compareTo(b.id));
  final totalModules = packs.fold<int>(
    0,
    (sum, pack) => sum + pack.moduleCount,
  );
  final avgModules = packs.isEmpty
      ? 0.0
      : totalModules / packs.length.toDouble();
  final lowVolumeThreshold = max(
    _absoluteMinModules,
    (avgModules * 0.6).round(),
  );

  final recommendations = <_Recommendation>[];
  for (final pack in packs) {
    final notes = <String>[];
    final actions = <String>[];

    if (pack.moduleCount < lowVolumeThreshold) {
      notes.add('low volume (${pack.moduleCount} modules)');
      final needed = lowVolumeThreshold - pack.moduleCount;
      actions.add(
        'Author ${max(1, needed)}+ reinforcement drills to close foundational gap.',
      );
    }

    for (final band in _monitoredBands) {
      final count = pack.difficultyCounts[band] ?? 0;
      final share = pack.moduleCount == 0
          ? 0.0
          : count / pack.moduleCount.toDouble();
      if (count == 0) {
        notes.add('missing $band content');
        actions.add(_actionForBand(band, true));
      } else if (share < _minDifficultyShare) {
        notes.add(
          '$band share ${(share * 100).toStringAsFixed(0)}% '
          '(target ${(100 * _minDifficultyShare).toStringAsFixed(0)}%)',
        );
        actions.add(_actionForBand(band, false));
      }
    }

    if (pack.spotKinds.length <= 1 && pack.moduleCount >= 3) {
      final spotText = pack.spotKinds.isEmpty
          ? 'unspecified'
          : pack.spotKinds.first;
      notes.add('single spot kind focus ($spotText)');
      actions.add('Blend in contrasting spot kinds to diversify transfer.');
    }

    if (notes.isNotEmpty) {
      recommendations.add(
        _Recommendation(
          packId: pack.id,
          modules: pack.moduleCount,
          gapNotes: notes,
          actions: actions,
        ),
      );
    }
  }

  recommendations.sort((a, b) => a.modules.compareTo(b.modules));
  final balancedCount = packs.length - recommendations.length;
  final coveragePct = packs.isEmpty
      ? 0.0
      : (balancedCount / packs.length) * 100.0;
  final totalActions = recommendations.fold<int>(
    0,
    (sum, rec) => sum + rec.actions.length,
  );

  return _AnalysisResult(
    recommendations: recommendations,
    coveragePct: double.parse(coveragePct.toStringAsFixed(2)),
    lowVolumeThreshold: lowVolumeThreshold,
    avgModules: avgModules,
    totalActions: totalActions,
  );
}

Future<void> _writeSummary(
  _CurriculumSnapshot snapshot,
  _AnalysisResult analysis,
) async {
  final packs = snapshot.packs;
  final modulesScanned = packs.fold<int>(
    0,
    (sum, pack) => sum + pack.moduleCount,
  );
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE CURRICULUM SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Packs scanned: ${packs.length}')
    ..writeln('Modules scanned: $modulesScanned')
    ..writeln(
      'Average modules per pack: ${analysis.avgModules.toStringAsFixed(1)}',
    )
    ..writeln('Low-volume threshold: ${analysis.lowVolumeThreshold}')
    ..writeln(
      'Coverage health: ${analysis.coveragePct.toStringAsFixed(1)}% packs balanced',
    )
    ..writeln(
      'Fusion feeds: ${snapshot.fusionSources.isEmpty ? 'none detected' : snapshot.fusionSources.join(', ')}',
    )
    ..writeln();

  if (analysis.recommendations.isEmpty) {
    buffer
      ..writeln('All packs meet the coverage thresholds — no follow-up needed.')
      ..writeln();
  } else {
    buffer
      ..writeln('| Pack | Modules | Gap Notes | Recommended Actions |')
      ..writeln('|------|---------|-----------|---------------------|');
    for (final rec in analysis.recommendations) {
      buffer.writeln(
        '| ${rec.packId} | ${rec.modules} | ${rec.gapNotes.join('; ')} | '
        '${rec.actions.join('; ')} |',
      );
    }
    buffer.writeln();
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int newVariants,
  required double coveragePct,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_curriculum_expanded',
    'timestamp': DateTime.now().toIso8601String(),
    'new_variants': newVariants,
    'coverage_pct': coveragePct,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _packIdFromV1(String v1Path) {
  final normalized = v1Path.replaceAll('\\', '/');
  final marker = 'content/';
  final markerIndex = normalized.indexOf(marker);
  if (markerIndex == -1) {
    return normalized.endsWith('/v1')
        ? normalized.substring(0, normalized.length - 3)
        : normalized;
  }
  final start = markerIndex + marker.length;
  final trimmed = normalized.substring(start);
  if (!trimmed.contains('/')) return trimmed.replaceAll('/v1', '');
  return trimmed.endsWith('/v1')
      ? trimmed.substring(0, trimmed.length - 3)
      : trimmed;
}

String _actionForBand(String band, bool missing) {
  switch (band) {
    case 'easy':
      return missing
          ? 'Add onboarding walkthroughs for quick wins.'
          : 'Expand soft-entry reps to lift early confidence.';
    case 'medium':
      return missing
          ? 'Author bridge drills to connect fundamentals to mid-stakes play.'
          : 'Balance with scenario-based reps in the medium band.';
    case 'hard':
      return missing
          ? 'Inject advanced challenge sets to push ceiling.'
          : 'Add follow-up branches that escalate decision depth.';
    default:
      return 'Round out difficulty mix for $band learners.';
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'adaptive_curriculum_expander: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _CurriculumSnapshot {
  const _CurriculumSnapshot({required this.packs, required this.fusionSources});

  final List<_PackAggregate> packs;
  final List<String> fusionSources;
}

class _PackAggregate {
  _PackAggregate(this.id, Directory source) : sourcePath = source.path;

  final String id;
  final String sourcePath;
  int moduleCount = 0;
  final Map<String, int> difficultyCounts = {};
  final Set<String> spotKinds = <String>{};

  void addModule(_ModuleRecord module) {
    moduleCount += 1;
    final normalizedDifficulty = _normalizeDifficulty(
      module.difficulty,
      module.difficultyScore,
    );
    difficultyCounts[normalizedDifficulty] =
        (difficultyCounts[normalizedDifficulty] ?? 0) + 1;
    final spot = module.spotKind?.trim();
    if (spot != null && spot.isNotEmpty) {
      spotKinds.add(spot);
    }
  }
}

class _ModuleRecord {
  const _ModuleRecord({
    required this.id,
    required this.spotKind,
    required this.difficulty,
    required this.difficultyScore,
    required this.goal,
  });

  final String id;
  final String? spotKind;
  final String? difficulty;
  final double? difficultyScore;
  final String? goal;
}

class _AnalysisResult {
  const _AnalysisResult({
    required this.recommendations,
    required this.coveragePct,
    required this.lowVolumeThreshold,
    required this.avgModules,
    required this.totalActions,
  });

  final List<_Recommendation> recommendations;
  final double coveragePct;
  final int lowVolumeThreshold;
  final double avgModules;
  final int totalActions;
}

class _Recommendation {
  const _Recommendation({
    required this.packId,
    required this.modules,
    required this.gapNotes,
    required this.actions,
  });

  final String packId;
  final int modules;
  final List<String> gapNotes;
  final List<String> actions;
}

String _normalizeDifficulty(String? difficulty, double? score) {
  final lower = difficulty?.toLowerCase();
  if (_monitoredBands.contains(lower)) {
    return lower!;
  }
  if (lower == 'expert' || lower == 'advanced') {
    return 'hard';
  }
  if (score != null) {
    if (score < 0.9) return 'easy';
    if (score < 1.1) return 'medium';
    return 'hard';
  }
  return 'medium';
}

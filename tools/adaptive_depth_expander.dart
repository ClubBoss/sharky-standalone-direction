import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _contentRoot = 'content';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/adaptive_depth_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

const int _minContentLength = 60;
const int _maxContentLength = 180;
const double _targetDifficultyLow = 0.8;
const double _targetDifficultyHigh = 1.2;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final packs = await _scanPacks();
  if (packs.isEmpty) {
    stdout.writeln('adaptive_depth_expander: no content found.');
    return;
  }

  final variants = <_Variant>[];
  for (final pack in packs) {
    variants.addAll(_generateVariants(pack));
  }

  final coveragePct = packs.isEmpty
      ? 0.0
      : variants.isEmpty
      ? 1.0
      : min(1.0, packs.length / packs.length.toDouble());

  await _withReportsWritable(() async {
    await _writeSummary(packs, variants);
    await _appendTelemetry(
      newVariants: variants.length,
      coveragePct: double.parse(coveragePct.toStringAsFixed(4)),
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_depth_expander: ${variants.length} follow-up variants generated.',
  );
}

Future<List<_PackStats>> _scanPacks() async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];
  final packs = <_PackStats>[];

  await for (final dir in root.list(recursive: false, followLinks: false)) {
    if (dir is! Directory) continue;
    final v1 = Directory('${dir.path}/v1');
    if (!v1.existsSync()) continue;
    final modules = <_Module>[];
    for (final file
        in v1
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((f) => f.path.endsWith('.jsonl'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final raw = lines[i].trim();
        if (raw.isEmpty || raw.startsWith('#')) continue;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            modules.add(
              _Module(
                id: decoded['id']?.toString() ?? '${file.path}:${i + 1}',
                path: file.path,
                goal: decoded['goal']?.toString() ?? '',
                reaction: decoded['reaction_text']?.toString() ?? '',
                difficultyScore: (decoded['difficulty_score'] as num?)
                    ?.toDouble(),
                difficultyText: decoded['difficulty']?.toString(),
              ),
            );
          }
        } catch (_) {
          // skip invalid jsonl rows
        }
      }
    }
    if (modules.isEmpty) continue;
    packs.add(
      _PackStats(
        id: dir.path.split(Platform.pathSeparator).last,
        modules: modules,
        pathCategory: _pathCategory(dir.path),
      ),
    );
  }

  return packs;
}

List<_Variant> _generateVariants(_PackStats pack) {
  final variants = <_Variant>[];
  final goalLengths = pack.modules
      .map((m) => m.goal.length + m.reaction.length)
      .toList(growable: false);
  final avgLength = goalLengths.isEmpty
      ? 0.0
      : goalLengths.reduce((a, b) => a + b) / goalLengths.length;
  final avgDifficulty =
      pack.modules
          .map(
            (m) => m.difficultyScore ?? _difficultyFromText(m.difficultyText),
          )
          .where((v) => v != null)
          .map((v) => v!)
          .fold<double>(0.0, (sum, v) => sum + v) /
      (goalLengths.isEmpty ? 1 : goalLengths.length);

  for (final module in pack.modules) {
    final contentLength = module.goal.length + module.reaction.length;
    final difficulty =
        module.difficultyScore ??
        _difficultyFromText(module.difficultyText) ??
        1.0;

    if (contentLength < _minContentLength ||
        difficulty < _targetDifficultyLow) {
      final rationale = contentLength < _minContentLength
          ? 'Content length below minimum '
                '(${contentLength.toStringAsFixed(0)} < $_minContentLength)'
          : 'Difficulty below band '
                '(${difficulty.toStringAsFixed(2)} < $_targetDifficultyLow)';
      variants.add(
        _Variant(
          baseId: module.id,
          type: 'advanced',
          rationale: rationale,
          suggestedDelta: '+depth, +complexity',
        ),
      );
    } else if (contentLength > _maxContentLength ||
        difficulty > _targetDifficultyHigh) {
      final rationale = contentLength > _maxContentLength
          ? 'Content length above maximum '
                '(${contentLength.toStringAsFixed(0)} > $_maxContentLength)'
          : 'Difficulty above band '
                '(${difficulty.toStringAsFixed(2)} > $_targetDifficultyHigh)';
      variants.add(
        _Variant(
          baseId: module.id,
          type: 'remedial',
          rationale: rationale,
          suggestedDelta: '-depth, reinforce fundamentals',
        ),
      );
    }
  }

  // If pack-wide averages drift, add a meta variant suggestion.
  if (avgLength < _minContentLength || avgDifficulty < _targetDifficultyLow) {
    variants.add(
      _Variant(
        baseId: pack.id,
        type: 'advanced_pack',
        rationale:
            'Pack average below target (length ${avgLength.toStringAsFixed(1)}, difficulty ${avgDifficulty.toStringAsFixed(2)})',
        suggestedDelta: 'Add advanced follow-up modules',
      ),
    );
  } else if (avgLength > _maxContentLength ||
      avgDifficulty > _targetDifficultyHigh) {
    variants.add(
      _Variant(
        baseId: pack.id,
        type: 'remedial_pack',
        rationale:
            'Pack average above target (length ${avgLength.toStringAsFixed(1)}, difficulty ${avgDifficulty.toStringAsFixed(2)})',
        suggestedDelta: 'Provide remedial or condensed variants',
      ),
    );
  }

  return variants;
}

Future<void> _writeSummary(
  List<_PackStats> packs,
  List<_Variant> variants,
) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE DEPTH EXPANSION SUMMARY')
    ..writeln('=================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Packs scanned: ${packs.length}')
    ..writeln(
      'Modules scanned: ${packs.fold<int>(0, (sum, p) => sum + p.modules.length)}',
    )
    ..writeln('New variant suggestions: ${variants.length}')
    ..writeln();

  if (variants.isEmpty) {
    buffer.writeln('All packs fall within the target depth band.');
  } else {
    buffer.writeln('Variant Suggestions:');
    for (final variant in variants) {
      buffer.writeln(
        '- ${variant.baseId} -> ${variant.type} '
        '(${variant.rationale}; ${variant.suggestedDelta})',
      );
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int newVariants,
  required double coveragePct,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'adaptive_depth_expanded',
    'timestamp': DateTime.now().toIso8601String(),
    'new_variants': newVariants,
    'coverage_pct': coveragePct,
    'duration_ms': durationMs,
  };
  await telemetryFile.writeAsString(
    jsonEncode(event) + '\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(addWrite: true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(addWrite: false);
  }
}

Future<void> _setReportsPermissions({required bool addWrite}) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'adaptive_depth_expander: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

String _pathCategory(String path) {
  final lower = path.toLowerCase();
  if (lower.contains('cash')) return 'Cash';
  if (lower.contains('mtt')) return 'MTT';
  if (lower.contains('live')) return 'Live';
  return 'Other';
}

double? _difficultyFromText(String? label) {
  if (label == null) return null;
  switch (label.toLowerCase()) {
    case 'easy':
      return 0.8;
    case 'medium':
      return 1.0;
    case 'hard':
      return 1.2;
    default:
      return null;
  }
}

class _PackStats {
  _PackStats({
    required this.id,
    required this.modules,
    required this.pathCategory,
  });

  final String id;
  final List<_Module> modules;
  final String pathCategory;
}

class _Module {
  _Module({
    required this.id,
    required this.path,
    required this.goal,
    required this.reaction,
    required this.difficultyScore,
    required this.difficultyText,
  });

  final String id;
  final String path;
  final String goal;
  final String reaction;
  final double? difficultyScore;
  final String? difficultyText;
}

class _Variant {
  _Variant({
    required this.baseId,
    required this.type,
    required this.rationale,
    required this.suggestedDelta,
  });

  final String baseId;
  final String type;
  final String rationale;
  final String suggestedDelta;
}

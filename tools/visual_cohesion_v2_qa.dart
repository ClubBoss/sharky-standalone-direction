import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _designSummaryPath =
    'release/_reports/dynamic_visual_integration_summary.txt';
const String _uiRoot = 'lib/ui';
const String _outputPath = 'release/_reports/visual_cohesion_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const double _violationWeight = 0.05;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final summary = await _DesignIntegrationSummary.load(_designSummaryPath);
  final analyzer = _UiStyleAnalyzer(root: _uiRoot);
  final analysis = await analyzer.scan();

  final weightedViolations = analysis.totalRefs == 0
      ? 0
      : min(
          analysis.totalRefs,
          (analysis.violations * _violationWeight).round(),
        );
  final index = analysis.totalRefs == 0
      ? 100.0
      : (1 - (weightedViolations / analysis.totalRefs)) * 100;

  await _withReportsWritable(() async {
    await _writeSummary(
      summary: summary,
      analysis: analysis,
      index: index,
      durationMs: stopwatch.elapsedMilliseconds,
      weightedViolations: weightedViolations,
    );
    await _emitTelemetry(
      analysis: analysis,
      index: index,
      durationMs: stopwatch.elapsedMilliseconds,
      weightedViolations: weightedViolations,
    );
  });

  stdout.writeln(
    'visual_cohesion_v2_qa: refs=${analysis.totalRefs} '
    'violations=${analysis.violations} index=${index.toStringAsFixed(2)}',
  );
}

Future<void> _writeSummary({
  required _DesignIntegrationSummary summary,
  required _AnalysisResult analysis,
  required double index,
  required int durationMs,
  required int weightedViolations,
}) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION QA v2')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln()
    ..writeln('Dynamic Theme Spec Snapshot:')
    ..writeln('- Accent: ${summary.accentHex} (${summary.accentToken})')
    ..writeln('- Brightness: ${summary.brightness}')
    ..writeln('- Spacing scale: ${summary.spacingScale}')
    ..writeln('- Typography weight: ${summary.typographyWeight}')
    ..writeln('- Overlay strength: ${summary.overlayStrength}')
    ..writeln()
    ..writeln('Cohesion Metrics:')
    ..writeln('- Theme references scanned : ${analysis.totalRefs}')
    ..writeln('- Violations detected      : ${analysis.violations}')
    ..writeln(
      '- Weighted violations      : $weightedViolations '
      '(${(_violationWeight * 100).toStringAsFixed(0)}% severity)',
    )
    ..writeln('- Visual Cohesion Index    : ${index.toStringAsFixed(2)}%')
    ..writeln()
    ..writeln('Top Offenders:');

  if (analysis.violations == 0) {
    buffer.writeln('- None 🎉');
  } else {
    for (final entry in analysis.topViolations.take(5)) {
      buffer.writeln('- ${entry.file}:${entry.line} → ${entry.snippet}');
    }
  }

  buffer
    ..writeln()
    ..writeln('File Breakdown (violations):');

  if (analysis.fileViolations.isEmpty) {
    buffer.writeln('- No issues detected across UI files.');
  } else {
    final sortedFiles = analysis.fileViolations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedFiles.take(10)) {
      buffer.writeln('- ${entry.key}: ${entry.value}');
    }
  }

  buffer
    ..writeln()
    ..writeln('Recommendation:')
    ..writeln(
      analysis.violations == 0
          ? 'All UI files honor DynamicThemeSpec.'
          : 'Replace inline styles with DynamicThemeSpec or AppColors/AppSpacing tokens.',
    )
    ..writeln();

  await File(_outputPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry({
  required _AnalysisResult analysis,
  required double index,
  required int durationMs,
  required int weightedViolations,
}) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'refs': analysis.totalRefs,
    'violations': analysis.violations,
    'weighted_violations': weightedViolations,
    'violation_weight': _violationWeight,
    'index': double.parse(index.toStringAsFixed(2)),
    'top_files': analysis.fileViolations.entries
        .sorted((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((entry) => {'file': entry.key, 'violations': entry.value})
        .toList(),
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _DesignIntegrationSummary {
  const _DesignIntegrationSummary({
    required this.accentToken,
    required this.accentHex,
    required this.spacingScale,
    required this.typographyWeight,
    required this.overlayStrength,
    required this.brightness,
  });

  static Future<_DesignIntegrationSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing dynamic visual integration summary at $path');
    }
    final lines = await file.readAsLines();

    String accentToken = 'unknown';
    String accentHex = '#000000';
    double spacingScale = 1.0;
    double typographyWeight = 600;
    double overlayStrength = 0.2;
    String brightness = 'unknown';

    final accentRegex = RegExp(r'Accent color\s*:\s*(#[0-9A-Fa-f]{6})');
    final spacingRegex = RegExp(r'Spacing scale\s*:\s*([0-9.]+)');
    final typoRegex = RegExp(r'Typography weight\s*:\s*([0-9.]+)');
    final overlayRegex = RegExp(r'Overlay strength\s*:\s*([0-9.]+)');
    final brightnessRegex = RegExp(r'Brightness\s*:\s*(\w+)');
    final accentTokenRegex = RegExp(r'Design accent\s*:\s*([^(]+)\(');

    for (final line in lines) {
      final accentMatch = accentRegex.firstMatch(line);
      if (accentMatch != null) {
        accentHex = accentMatch.group(1)!;
      }
      final tokenMatch = accentTokenRegex.firstMatch(line);
      if (tokenMatch != null) {
        accentToken = tokenMatch.group(1)!.trim();
      }
      final spacingMatch = spacingRegex.firstMatch(line);
      if (spacingMatch != null) {
        spacingScale = double.tryParse(spacingMatch.group(1)!) ?? spacingScale;
      }
      final typoMatch = typoRegex.firstMatch(line);
      if (typoMatch != null) {
        typographyWeight =
            double.tryParse(typoMatch.group(1)!) ?? typographyWeight;
      }
      final overlayMatch = overlayRegex.firstMatch(line);
      if (overlayMatch != null) {
        overlayStrength =
            double.tryParse(overlayMatch.group(1)!) ?? overlayStrength;
      }
      final brightnessMatch = brightnessRegex.firstMatch(line);
      if (brightnessMatch != null) {
        brightness = brightnessMatch.group(1)!;
      }
    }

    return _DesignIntegrationSummary(
      accentToken: accentToken,
      accentHex: accentHex,
      spacingScale: spacingScale,
      typographyWeight: typographyWeight,
      overlayStrength: overlayStrength,
      brightness: brightness,
    );
  }

  final String accentToken;
  final String accentHex;
  final double spacingScale;
  final double typographyWeight;
  final double overlayStrength;
  final String brightness;
}

class _UiStyleAnalyzer {
  const _UiStyleAnalyzer({required this.root});

  final String root;

  Future<_AnalysisResult> scan() async {
    final files = await _collectUiFiles();
    var total = 0;
    var violations = 0;
    final violationDetails = <_Violation>[];
    final perFile = <String, int>{};

    for (final file in files) {
      final lines = await file.readAsLines();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!_stylePattern.hasMatch(line)) continue;
        total++;
        if (_isCompliant(line)) continue;

        violations++;
        perFile[file.path] = (perFile[file.path] ?? 0) + 1;
        violationDetails.add(
          _Violation(file: file.path, line: i + 1, snippet: line.trim()),
        );
      }
    }

    violationDetails.sort((a, b) => b.file.compareTo(a.file));

    return _AnalysisResult(
      totalRefs: total,
      violations: violations,
      violationDetails: violationDetails,
      fileViolations: perFile,
    );
  }

  Future<List<File>> _collectUiFiles() async {
    final rootDir = Directory(root);
    if (!await rootDir.exists()) {
      throw StateError('UI directory missing at $root');
    }
    return await rootDir
        .list(recursive: true)
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith('.dart') &&
              !entity.path.contains('generated'),
        )
        .cast<File>()
        .toList();
  }

  bool _isCompliant(String line) {
    final normalized = line.toLowerCase();
    for (final token in _allowedTokens) {
      if (normalized.contains(token)) {
        return true;
      }
    }
    return false;
  }
}

class _AnalysisResult {
  const _AnalysisResult({
    required this.totalRefs,
    required this.violations,
    required this.violationDetails,
    required this.fileViolations,
  });

  final int totalRefs;
  final int violations;
  final List<_Violation> violationDetails;
  final Map<String, int> fileViolations;

  Iterable<_Violation> get topViolations => violationDetails.take(10);
}

class _Violation {
  const _Violation({
    required this.file,
    required this.line,
    required this.snippet,
  });

  final String file;
  final int line;
  final String snippet;
}

final RegExp _stylePattern = RegExp(
  r'(Color\(|Colors\.|TextStyle\(|EdgeInsets|SizedBox\(|padding:|margin:)',
);

final List<String> _allowedTokens = <String>[
  'appcolors',
  'apptypography',
  'appspacing',
  'theme.of',
  'dynamicthemespec',
  'spacingmultiplier',
  'spacingscale',
  'context.dynamic',
  'theme.of',
  'spec.',
];

extension<T> on Iterable<T> {
  List<T> sorted([int Function(T a, T b)? compare]) {
    final list = toList();
    list.sort(compare);
    return list;
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _uiRoot = 'lib/ui';
const String _assetsRoot = 'assets';
const String _outputPath =
    'release/_reports/contrast_accessibility_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const double _minContrast = 4.5;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final samples = <_ColorSample>[];
  samples.addAll(await _scanDirectory(_uiRoot));
  samples.addAll(await _scanDirectory(_assetsRoot));

  if (samples.isEmpty) {
    throw StateError('No color samples found under $_uiRoot or $_assetsRoot.');
  }

  final stats = _contrastStats(samples);

  await _withReportsWritable(() async {
    await _writeSummary(
      stats: stats,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(stats, stopwatch.elapsedMilliseconds);
  });

  if (stats.minContrast < _minContrast) {
    exitCode = 1;
  }
}

Future<List<_ColorSample>> _scanDirectory(String root) async {
  final dir = Directory(root);
  if (!await dir.exists()) return const [];
  final samples = <_ColorSample>[];
  final regexHex = RegExp(r'0xFF([0-9A-Fa-f]{6})|#([0-9A-Fa-f]{6})');
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart') &&
        !entity.path.endsWith('.json') &&
        !entity.path.endsWith('.txt')) {
      continue;
    }
    final lines = await entity.readAsLines();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      for (final match in regexHex.allMatches(line)) {
        final hex = match.group(1) ?? match.group(2);
        if (hex == null) continue;
        samples.add(_ColorSample(file: entity.path, line: index + 1, hex: hex));
      }
      for (final entry in _namedColors.entries) {
        if (line.contains(entry.key)) {
          samples.add(
            _ColorSample(
              file: entity.path,
              line: index + 1,
              hex: entry.value,
              reference: entry.key,
            ),
          );
        }
      }
    }
  }
  return samples;
}

_ContrastStats _contrastStats(List<_ColorSample> samples) {
  final backgroundHexes = ['1A1A1C', 'FFFFFF'];
  final results = <double>[];
  final failures = <_ContrastFailure>[];

  for (final sample in samples) {
    final color = _hexToColor(sample.hex);
    double bestRatio = 0;
    for (final bgHex in backgroundHexes) {
      final ratio = _contrastRatio(color, _hexToColor(bgHex));
      bestRatio = max(bestRatio, ratio);
    }
    results.add(bestRatio);
    if (bestRatio < _minContrast) {
      failures.add(_ContrastFailure(sample: sample, ratio: bestRatio));
    }
  }

  final avg = results.reduce((a, b) => a + b) / results.length;
  final minRatio = results.reduce(min);

  failures.sort((a, b) => a.ratio.compareTo(b.ratio));

  return _ContrastStats(
    average: avg,
    minContrast: minRatio,
    samples: samples.length,
    failures: failures,
  );
}

double _contrastRatio(_RgbColor a, _RgbColor b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final bright = max(l1, l2);
  final dark = min(l1, l2);
  return (bright + 0.05) / (dark + 0.05);
}

double _relativeLuminance(_RgbColor color) {
  double transform(int value) {
    final channel = value / 255;
    return channel <= 0.03928
        ? channel / 12.92
        : pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = transform(color.r);
  final g = transform(color.g);
  final b = transform(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

Future<void> _writeSummary({
  required _ContrastStats stats,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('CONTRAST ACCESSIBILITY SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Files scanned: ${stats.samples}')
    ..writeln(
      'Average contrast: ${stats.average.toStringAsFixed(2)} | '
      'Min: ${stats.minContrast.toStringAsFixed(2)}',
    )
    ..writeln('WCAG AA threshold: $_minContrast')
    ..writeln()
    ..writeln('Failures:')
    ..writeln(stats.failures.isEmpty ? '- None 🎉' : '');
  for (final failure in stats.failures.take(10)) {
    buffer.writeln(
      '- ${failure.sample.file}:${failure.sample.line} → '
      '#${failure.sample.hex.toUpperCase()} '
      '(${failure.sample.reference ?? 'inline'}) '
      'ratio=${failure.ratio.toStringAsFixed(2)}',
    );
  }

  await File(_outputPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry(_ContrastStats stats, int durationMs) async {
  final payload = <String, Object?>{
    'event': 'contrast_accessibility_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'average_ratio': stats.average,
    'min_ratio': stats.minContrast,
    'sample_count': stats.samples,
    'failures': stats.failures.length,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

_RgbColor _hexToColor(String hex) {
  final normalized = hex.replaceAll('#', '');
  final value = int.parse(normalized, radix: 16);
  return _RgbColor(
    r: (value >> 16) & 0xFF,
    g: (value >> 8) & 0xFF,
    b: value & 0xFF,
  );
}

class _ColorSample {
  const _ColorSample({
    required this.file,
    required this.line,
    required this.hex,
    this.reference,
  });

  final String file;
  final int line;
  final String hex;
  final String? reference;
}

class _ContrastFailure {
  const _ContrastFailure({required this.sample, required this.ratio});

  final _ColorSample sample;
  final double ratio;
}

class _ContrastStats {
  const _ContrastStats({
    required this.average,
    required this.minContrast,
    required this.samples,
    required this.failures,
  });

  final double average;
  final double minContrast;
  final int samples;
  final List<_ContrastFailure> failures;
}

class _RgbColor {
  const _RgbColor({required this.r, required this.g, required this.b});

  final int r;
  final int g;
  final int b;
}

const Map<String, String> _namedColors = <String, String>{
  'Colors.white': 'FFFFFF',
  'Colors.black': '000000',
  'Colors.red': 'F44336',
  'Colors.green': '4CAF50',
  'Colors.blue': '2196F3',
  'Colors.yellow': 'FFEB3B',
  'Colors.orange': 'FF9800',
  'Colors.purple': '9C27B0',
  'Colors.grey': '9E9E9E',
  'Colors.teal': '009688',
};

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

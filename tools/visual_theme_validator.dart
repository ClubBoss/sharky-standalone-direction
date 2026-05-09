import 'dart:convert';
import 'dart:io';

const String _finalSummaryPath =
    'release/_reports/final_visual_theme_summary.txt';
const String _visualSummaryPath =
    'release/_reports/visual_cohesion_dashboard_v2_summary.txt';
const String _summaryOutPath =
    'release/_reports/visual_theme_validator_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final validator = VisualThemeValidator();
  final pass = await validator.run();
  if (!pass) {
    exitCode = 2;
  }
}

class VisualThemeValidator {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final finalSummary = await _FinalThemeSummary.load(_finalSummaryPath);
    final visualSummary = await _VisualDashboardSummary.load(
      _visualSummaryPath,
    );
    final result = _ValidationResult.fromSummaries(
      finalSummary: finalSummary,
      visualSummary: visualSummary,
    );

    final verdict = result.isPass ? 'PASS' : 'FAIL';
    await _withReportsWritable(() async {
      await _writeSummary(
        result: result,
        finalSummary: finalSummary,
        visualSummary: visualSummary,
        durationMs: stopwatch.elapsedMilliseconds,
        verdict: verdict,
      );
      await _emitTelemetry(
        result: result,
        durationMs: stopwatch.elapsedMilliseconds,
        verdict: verdict,
      );
    });

    return result.isPass;
  }
}

class _ValidationResult {
  _ValidationResult({
    required this.visualHealth,
    required this.animationP95,
    required this.contrastMin,
    required this.cohesionIndex,
    required this.motionFast,
    required this.motionMedium,
    required this.motionSlow,
  });

  final double visualHealth;
  final double animationP95;
  final double contrastMin;
  final double cohesionIndex;
  final int motionFast;
  final int motionMedium;
  final int motionSlow;

  bool get isPass =>
      visualHealth >= 90 &&
      animationP95 <= 16 &&
      contrastMin >= 4.5 &&
      cohesionIndex >= 90 &&
      motionFast <= 160 &&
      motionMedium <= 225 &&
      motionSlow <= 280;

  static _ValidationResult fromSummaries({
    required _FinalThemeSummary finalSummary,
    required _VisualDashboardSummary visualSummary,
  }) {
    return _ValidationResult(
      visualHealth: finalSummary.visualHealthAfter,
      animationP95: finalSummary.animationP95After,
      contrastMin: finalSummary.contrastAfter,
      cohesionIndex: finalSummary.cohesionAfter,
      motionFast: finalSummary.motionFastAfter,
      motionMedium: finalSummary.motionMediumAfter,
      motionSlow: finalSummary.motionSlowAfter,
    );
  }
}

class _FinalThemeSummary {
  _FinalThemeSummary({
    required this.visualHealthAfter,
    required this.animationP95After,
    required this.contrastAfter,
    required this.cohesionAfter,
    required this.motionFastAfter,
    required this.motionMediumAfter,
    required this.motionSlowAfter,
  });

  final double visualHealthAfter;
  final double animationP95After;
  final double contrastAfter;
  final double cohesionAfter;
  final int motionFastAfter;
  final int motionMediumAfter;
  final int motionSlowAfter;

  static Future<_FinalThemeSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing final visual theme summary at $path');
    }
    double? health;
    double? p95;
    double? contrast;
    double? cohesion;
    int? fast;
    int? medium;
    int? slow;
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Visual Health Index :')) {
        final value = _valueAfterColon(trimmed)?.replaceAll('%', '');
        health = double.tryParse(value ?? '');
      } else if (trimmed.startsWith('- P95 Frame (ms)      :')) {
        p95 = double.tryParse(_valueAfterColon(trimmed) ?? '');
      } else if (trimmed.startsWith('- Contrast Min        :')) {
        contrast = double.tryParse(_valueAfterColon(trimmed) ?? '');
      } else if (trimmed.startsWith('- Cohesion Index      :')) {
        final value = _valueAfterColon(trimmed)?.replaceAll('%', '');
        cohesion = double.tryParse(value ?? '');
      } else if (trimmed.startsWith('- Motion timings (ms) :')) {
        final match = RegExp(
          r'fast=([0-9]+)\s+medium=([0-9]+)\s+slow=([0-9]+)',
        ).firstMatch(trimmed);
        if (match != null) {
          fast = int.tryParse(match.group(1)!);
          medium = int.tryParse(match.group(2)!);
          slow = int.tryParse(match.group(3)!);
        }
      }
    }
    if ([health, p95, contrast, cohesion, fast, medium, slow].contains(null)) {
      throw StateError('Final visual theme summary missing metrics.');
    }
    return _FinalThemeSummary(
      visualHealthAfter: health!,
      animationP95After: p95!,
      contrastAfter: contrast!,
      cohesionAfter: cohesion!,
      motionFastAfter: fast!,
      motionMediumAfter: medium!,
      motionSlowAfter: slow!,
    );
  }
}

class _VisualDashboardSummary {
  _VisualDashboardSummary({
    required this.visualHealthIndex,
    required this.minContrast,
    required this.cohesionIndex,
  });

  final double visualHealthIndex;
  final double minContrast;
  final double cohesionIndex;

  static Future<_VisualDashboardSummary> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing visual dashboard summary at $path');
    }
    double? health;
    double? contrast;
    double? cohesion;
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Overall Visual Health Index')) {
        final value = _valueAfterColon(trimmed)?.replaceAll('%', '');
        health = double.tryParse(value ?? '');
      } else if (trimmed.startsWith('- contrast_accessibility_summary')) {
        final match = RegExp(r'minContrast=([0-9.]+)').firstMatch(trimmed);
        if (match != null) {
          contrast = double.tryParse(match.group(1)!);
        }
      } else if (trimmed.startsWith('- visual_cohesion_v2_summary')) {
        final match = RegExp(r'index=([0-9.]+)%').firstMatch(trimmed);
        if (match != null) {
          cohesion = double.tryParse(match.group(1)!);
        }
      }
    }
    if ([health, contrast, cohesion].contains(null)) {
      throw StateError('Visual dashboard details missing metrics.');
    }
    return _VisualDashboardSummary(
      visualHealthIndex: health!,
      minContrast: contrast!,
      cohesionIndex: cohesion!,
    );
  }
}

Future<void> _writeSummary({
  required _ValidationResult result,
  required _FinalThemeSummary finalSummary,
  required _VisualDashboardSummary visualSummary,
  required int durationMs,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL THEME VALIDATOR SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Final theme metrics (after adjustments):')
    ..writeln(
      '- Visual Health Index : ${finalSummary.visualHealthAfter.toStringAsFixed(2)}%',
    )
    ..writeln(
      '- P95 Frame (ms)      : ${finalSummary.animationP95After.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Contrast Min        : ${finalSummary.contrastAfter.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Cohesion Index      : ${finalSummary.cohesionAfter.toStringAsFixed(2)}%',
    )
    ..writeln('- Motion Fast         : ${finalSummary.motionFastAfter}ms')
    ..writeln('- Motion Medium       : ${finalSummary.motionMediumAfter}ms')
    ..writeln('- Motion Slow         : ${finalSummary.motionSlowAfter}ms')
    ..writeln()
    ..writeln('Latest dashboard references:')
    ..writeln(
      '- Visual Health Index : ${visualSummary.visualHealthIndex.toStringAsFixed(2)}%',
    )
    ..writeln(
      '- Contrast Min        : ${visualSummary.minContrast.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Cohesion Index      : ${visualSummary.cohesionIndex.toStringAsFixed(2)}%',
    )
    ..writeln();

  final requirements = {
    'Visual Health Index': result.visualHealth >= 90,
    'P95 Frame <= 16ms': result.animationP95 <= 16,
    'Contrast >= 4.5:1': result.contrastMin >= 4.5,
    'Cohesion >= 90%': result.cohesionIndex >= 90,
    'Motion fast <= 160ms': result.motionFast <= 160,
    'Motion medium <= 225ms': result.motionMedium <= 225,
    'Motion slow <= 280ms': result.motionSlow <= 280,
  };
  buffer.writeln('Threshold check:');
  requirements.forEach((label, met) {
    buffer.writeln('- $label : ${met ? 'PASS' : 'FAIL'}');
  });

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required _ValidationResult result,
  required int durationMs,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'visual_theme_validator_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'verdict': verdict,
    'metrics': {
      'visual_health_index': result.visualHealth,
      'animation_p95_ms': result.animationP95,
      'contrast_min': result.contrastMin,
      'cohesion_index': result.cohesionIndex,
      'motion_fast': result.motionFast,
      'motion_medium': result.motionMedium,
      'motion_slow': result.motionSlow,
    },
    'duration_ms': durationMs,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
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

String? _valueAfterColon(String line) {
  final index = line.indexOf(':');
  if (index == -1) {
    return null;
  }
  return line.substring(index + 1).trim();
}

// extracted from health_dashboard.dart — stage D13-refactor step 1
// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

const _baseline = {
  'tests': 100,
  'analyzerErrors': 0,
  'minCoverage': 25.0,
  'minFps': 55.0,
};

Future<ProcessResult> _safeRunTool(
  List<String> args, {
  Duration timeout = const Duration(seconds: 60),
  String executable = 'dart',
}) async {
  try {
    return await Process.run(executable, args).timeout(
      timeout,
      onTimeout: () {
        stderr.writeln('[TIMEOUT] $executable ${args.join(' ')}');
        return ProcessResult(pid, 124, '', 'Timeout');
      },
    );
  } catch (e) {
    stderr.writeln('[ERROR] $executable ${args.join(' ')}: $e');
    return ProcessResult(0, 1, '', e.toString());
  }
}

Future<Map<String, dynamic>> _checkUiPerformanceStatus() async {
  try {
    final file = File('ui_perf_metrics.json');
    if (!await file.exists()) {
      return {
        'fps_avg': 0.0,
        'frame_misses': 0.0,
        'pass': false,
        'missing': true,
      };
    }
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    final fps = (data['fps_avg'] as num?)?.toDouble() ?? 0.0;
    final misses = (data['frame_misses'] as num?)?.toDouble() ?? 0.0;
    final stamp = data['timestamp'] as String? ?? '';
    final pass = fps >= (_baseline['minFps'] as num).toDouble();
    return {
      'fps_avg': fps,
      'frame_misses': misses,
      'timestamp': stamp,
      'pass': pass,
    };
  } catch (e) {
    return {
      'fps_avg': 0.0,
      'frame_misses': 0.0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkUiFrameCostStatus() async {
  try {
    final metricsFile = File('tools/_reports/ui_perf_metrics.json');
    if (!await metricsFile.exists()) {
      return {
        'avg_ms': 0.0,
        'pass': false,
        'missing': true,
        'screens': <String, dynamic>{},
      };
    }

    final raw = await metricsFile.readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final avgMs = (data['overall_avg_ms'] as num?)?.toDouble() ?? 0.0;
    final screens = data['screens'] as Map<String, dynamic>? ?? {};

    final pass = avgMs > 0 && avgMs < 5.0;

    return {
      'avg_ms': avgMs,
      'pass': pass,
      'screens': screens,
      'timestamp': data['timestamp'],
    };
  } catch (e) {
    return {
      'avg_ms': 0.0,
      'pass': false,
      'error': e.toString(),
      'screens': <String, dynamic>{},
    };
  }
}

Future<Map<String, dynamic>> _runFastUiSmokeTest() async {
  try {
    final proc = await _safeRunTool(
      ['-lc', 'FAST_MODE=1 flutter test test/ui_v2_smoke_test.dart'],
      executable: 'bash',
      timeout: const Duration(seconds: 90),
    );
    final pass = proc.exitCode == 0;
    final map = <String, Object>{'pass': pass, 'exit_code': proc.exitCode};
    if (!pass) {
      if (proc.stdout is String && (proc.stdout as String).isNotEmpty) {
        map['stdout'] = proc.stdout;
      }
      if (proc.stderr is String && (proc.stderr as String).isNotEmpty) {
        map['stderr'] = proc.stderr;
      }
    }
    return map;
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _runFastContentSmokeTest() async {
  try {
    final proc = await _safeRunTool(
      [
        '-lc',
        'FAST_MODE=1 dart test test/services/content_beta_smoke_test.dart',
      ],
      executable: 'bash',
      timeout: const Duration(seconds: 90),
    );
    final pass = proc.exitCode == 0;
    final map = <String, Object>{'pass': pass, 'exit_code': proc.exitCode};
    if (!pass) {
      if (proc.stdout is String && (proc.stdout as String).isNotEmpty) {
        map['stdout'] = proc.stdout;
      }
      if (proc.stderr is String && (proc.stderr as String).isNotEmpty) {
        map['stderr'] = proc.stderr;
      }
    }
    return map;
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> runAllChecks() async {
  final summary = <String, dynamic>{};
  summary['ui_performance'] = await _checkUiPerformanceStatus();
  summary['ui_frame_cost'] = await _checkUiFrameCostStatus();
  summary['fast_ui_smoke_status'] = await _runFastUiSmokeTest();
  summary['fast_content_smoke_status'] = await _runFastContentSmokeTest();
  return summary;
}

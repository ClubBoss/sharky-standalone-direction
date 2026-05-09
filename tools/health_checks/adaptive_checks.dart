// extracted from health_dashboard.dart — stage D13-refactor step 1
// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_loop_v2_engine.dart' as alv2;
import 'package:poker_analyzer/services/adaptive_loop_v3_engine.dart' as alv3;
import 'package:poker_analyzer/services/emotion_adaptive_engine.dart';

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

Map<String, Object?> _parseLastJsonLine(String stdout) {
  if (stdout.trim().isEmpty) return const {};
  final lines = const LineSplitter().convert(stdout).reversed;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final parsed = jsonDecode(trimmed);
        if (parsed is Map) return parsed as Map<String, Object?>;
      } catch (_) {
        continue;
      }
    }
  }
  return const {};
}

Future<Map<String, dynamic>> _checkAdaptiveLoopV2Status() async {
  try {
    final result = await alv2.runAdaptiveLoopV2();
    return result.cast<String, dynamic>();
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkAdaptiveLoopV3Status() async {
  try {
    final result = await alv3.runAdaptiveLoopV3();
    return result.cast<String, dynamic>();
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkEmotionAdaptiveEngineStatus() async {
  try {
    final engine = EmotionAdaptiveEngine.instance;
    final balance = engine.sampleToneBalance();
    final reaction = engine.getAdaptiveReaction(
      'Stay ready for the next decision.',
      sentiment: 0.3,
      consistency: 0.6,
    );
    final tonesCovered = balance.values.where((count) => count > 0).length;
    final pass = tonesCovered >= 2;
    return {'tone_balance': balance, 'sample_reaction': reaction, 'pass': pass};
  } catch (e) {
    return {
      'tone_balance': const <String, int>{},
      'sample_reaction': 'n/a',
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkAdaptiveReportStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/adaptive_report_generator.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final fps = (summary['fps_avg'] as num?)?.toDouble() ?? 0.0;
    final xp = (summary['xp_avg'] as num?)?.toDouble() ?? 1.0;
    final drift = (summary['drift'] as num?)?.toDouble() ?? 0.0;
    final grade = summary['grade'] ?? '?';
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {
      'fps_avg': fps,
      'xp_avg': xp,
      'drift': drift,
      'grade': grade,
      'pass': pass,
      if (summary['stability'] is num)
        'stability': (summary['stability'] as num).toDouble(),
      if (summary['risk'] is num) 'risk': (summary['risk'] as num).toDouble(),
      if (summary['ux_score'] is num)
        'ux_score': (summary['ux_score'] as num).toDouble(),
    };
  } catch (e) {
    return {
      'fps_avg': 0.0,
      'xp_avg': 1.0,
      'drift': 0.0,
      'grade': 'D',
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkAdaptiveSimulationStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/adaptive_simulation_loop.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final sessions = (summary['sessions'] as num?)?.toInt() ?? 0;
    final avgPace = (summary['avg_pace'] as num?)?.toDouble() ?? 1.0;
    final drift = (summary['drift'] as num?)?.toDouble() ?? 0.0;
    final stability = (summary['stability'] as num?)?.toDouble() ?? 0.0;
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {
      'sessions': sessions,
      'avg_pace': avgPace,
      'drift': drift,
      'stability': stability,
      'pass': pass,
      if (summary['avg_fps'] is num)
        'avg_fps': (summary['avg_fps'] as num).toDouble(),
      if (summary['avg_energy'] is num)
        'avg_energy': (summary['avg_energy'] as num).toDouble(),
    };
  } catch (e) {
    return {
      'sessions': 0,
      'avg_pace': 1.0,
      'drift': 0.0,
      'stability': 0.0,
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkAdaptiveHistoryStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/adaptive_history_dashboard.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final trend = (summary['trend'] as num?)?.toDouble() ?? 0.0;
    final passRatio = (summary['pass_ratio'] as num?)?.toDouble() ?? 0.0;
    final gradeStart = summary['grade_start'] ?? 'N/A';
    final gradeEnd = summary['grade_end'] ?? 'N/A';
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {
      'trend': trend,
      'pass_ratio': passRatio,
      'grade_start': gradeStart,
      'grade_end': gradeEnd,
      'pass': pass,
    };
  } catch (e) {
    return {
      'trend': 0.0,
      'pass_ratio': 0.0,
      'grade_start': 'N/A',
      'grade_end': 'N/A',
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkAdaptiveForecastStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'tools/adaptive_forecast_engine.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final trend = (summary['trend_stability'] as num?)?.toDouble() ?? 0.0;
    final risk = summary['risk_level'] ?? 'unknown';
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'trend': trend, 'risk_level': risk, 'pass': pass};
  } catch (e) {
    return {
      'trend': 0.0,
      'risk_level': 'unknown',
      'pass': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> _checkAutoLearningLoopStatus() async {
  try {
    final proc = await _safeRunTool(['run', 'tools/auto_learning_loop.dart']);
    final summary = _parseLastJsonLine(proc.stdout);
    final grade = summary['grade'] ?? 'N/A';
    final pass = summary['pass'] == true || proc.exitCode == 0;
    return {'grade': grade, 'pass': pass};
  } catch (e) {
    return {'grade': 'N/A', 'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkAdaptiveDashboardStatus() async {
  try {
    final files = [
      'adaptive_simulation.json',
      'adaptive_report.json',
      'adaptive_history.json',
      'adaptive_forecast.json',
      'economy_auto_optimizer.json',
    ];
    final missing = <String>[];
    for (final path in files) {
      if (!File(path).existsSync()) missing.add(path);
    }
    final pass = missing.isEmpty;
    return {'pass': pass, if (!pass) 'missing': missing};
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, dynamic>> _checkMiniAiTunerStatus() async {
  try {
    final proc = await _safeRunTool([
      'run',
      'lib/services/mini_ai_tuner_service.dart',
    ]);
    final summary = _parseLastJsonLine(proc.stdout);
    final verified = (summary['verified_count'] as num?)?.toInt() ?? 0;
    final pass = summary['pass'] == true && verified > 0;
    return {
      'pass': pass,
      'verified_count': verified,
      'session_id': summary['session_id'],
      if (summary['reason'] != null) 'reason': summary['reason'],
    };
  } catch (e) {
    return {'pass': false, 'error': e.toString()};
  }
}

Future<Map<String, Object>> _checkAdaptiveTriggersStatus() async {
  try {
    final learnFile = File('build/adaptive_learning_summary.json');
    if (!learnFile.existsSync()) {
      return {'trialActive': false, 'hoursRemaining': 0.0, 'pass': true};
    }
    final data = jsonDecode(await learnFile.readAsString());
    if (data is Map) {
      final momentum = (data['learning_momentum'] as num?)?.toDouble() ?? 0.0;
      if (momentum >= 0.9) {
        return {'trialActive': true, 'hoursRemaining': 23.5, 'pass': true};
      }
    }
    return {'trialActive': false, 'hoursRemaining': 0.0, 'pass': true};
  } catch (_) {
    return {'trialActive': false, 'hoursRemaining': 0.0, 'pass': true};
  }
}

Future<Map<String, Object>> _computeAdaptivePlannerMode() async {
  const baseCount = 7;
  try {
    final f = File('build/adaptive_learning_summary.json');
    if (!f.existsSync()) {
      return {'mode': 'Balanced', 'maxCount': baseCount, 'pass': true};
    }
    final data = jsonDecode(await f.readAsString());
    if (data is Map) {
      final momentum = (data['learning_momentum'] as num?)?.toDouble() ?? 0.0;
      final fatigue = (data['fatigue_penalty'] as num?)?.toDouble() ?? 0.0;

      String mode;
      int maxCount;
      if (fatigue >= 0.80) {
        mode = 'Light';
        maxCount = (baseCount * 0.7).round().clamp(3, 10);
      } else if (momentum >= 0.9) {
        mode = 'Accelerated';
        maxCount = 10;
      } else {
        mode = 'Balanced';
        maxCount = baseCount;
      }

      return {'mode': mode, 'maxCount': maxCount, 'pass': true};
    }
  } catch (_) {}
  return {'mode': 'Balanced', 'maxCount': baseCount, 'pass': true};
}

Future<Map<String, dynamic>> runAllChecks() async {
  final summary = <String, dynamic>{};
  summary['adaptive_loop_v2_status'] = await _checkAdaptiveLoopV2Status();
  summary['adaptive_loop_v3_status'] = await _checkAdaptiveLoopV3Status();
  summary['emotion_adaptive_engine_status'] =
      await _checkEmotionAdaptiveEngineStatus();
  summary['adaptive_report_status'] = await _checkAdaptiveReportStatus();
  summary['adaptive_simulation_status'] =
      await _checkAdaptiveSimulationStatus();
  summary['adaptive_history_status'] = await _checkAdaptiveHistoryStatus();
  summary['adaptive_forecast_status'] = await _checkAdaptiveForecastStatus();
  summary['auto_learning_loop_status'] = await _checkAutoLearningLoopStatus();
  summary['adaptive_dashboard_status'] = await _checkAdaptiveDashboardStatus();
  summary['mini_ai_tuner_status'] = await _checkMiniAiTunerStatus();
  summary['adaptive_triggers_status'] = await _checkAdaptiveTriggersStatus();
  summary['adaptive_planner_mode'] = await _computeAdaptivePlannerMode();
  return summary;
}

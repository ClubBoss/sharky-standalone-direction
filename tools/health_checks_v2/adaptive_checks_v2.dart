import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_loop_v2_engine.dart' as alv2;
import 'package:poker_analyzer/services/adaptive_loop_v3_engine.dart' as alv3;

Future<Map<String, dynamic>> runAdaptiveChecksV2({
  required Future<Map<String, dynamic>> Function(
    String label,
    Future<Map<String, dynamic>> Function(),
  )
  safeWrap,
  required Map<String, dynamic>? Function(String path) readJsonCached,
}) async {
  Future<Map<String, dynamic>> runLoopV2() async {
    try {
      final result = await alv2.runAdaptiveLoopV2();
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'pass': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> runLoopV3() async {
    try {
      final result = await alv3.runAdaptiveLoopV3();
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'pass': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> runMiniAiTuner() async {
    try {
      final proc = await _runTool([
        'run',
        'lib/services/mini_ai_tuner_service.dart',
      ]);
      var details = _parseLastJsonLine(_stdoutToString(proc.stdout));
      if (details.isEmpty) {
        final cached =
            readJsonCached('tools/_reports/mini_ai_tuner_summary.json') ??
            const {};
        details = Map<String, Object?>.from(cached);
      }
      final verified = (details['verified_count'] as num?)?.toInt() ?? 0;
      final pass = details['pass'] == true && verified > 0;
      return {
        'pass': pass,
        'verified_count': verified,
        'session_id': details['session_id'],
        if (details['reason'] != null) 'reason': details['reason'],
      };
    } catch (e) {
      return {'pass': false, 'error': e.toString()};
    }
  }

  final loopV2 = await safeWrap('adaptive_loop_v2', runLoopV2);
  final loopV3 = await safeWrap('adaptive_loop_v3', runLoopV3);
  final mini = await safeWrap('mini_ai_tuner', runMiniAiTuner);

  return {
    'adaptive_loop_v2_status': loopV2,
    'adaptive_loop_v3_status': loopV3,
    'mini_ai_tuner_status': mini,
  };
}

Future<ProcessResult> _runTool(
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
  if (stdout.trim().isEmpty) return <String, Object?>{};
  final lines = const LineSplitter().convert(stdout).reversed;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final parsed = jsonDecode(trimmed);
        if (parsed is Map) {
          return Map<String, Object?>.from(parsed);
        }
      } catch (_) {
        continue;
      }
    }
  }
  return <String, Object?>{};
}

String _stdoutToString(Object? value) {
  if (value is String) return value;
  if (value is List<int>) return utf8.decode(value);
  return value?.toString() ?? '';
}

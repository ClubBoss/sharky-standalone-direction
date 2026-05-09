import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> runContentConsistencyV2({
  required Future<Map<String, dynamic>> Function(
    String label,
    Future<Map<String, dynamic>> Function(),
  )
  safeWrap,
  required Map<String, dynamic>? Function(String path) readJsonCached,
}) async {
  Future<Map<String, dynamic>> runIdAutofix() async {
    final cached =
        readJsonCached('tools/_reports/content_id_autofix.json') ?? const {};
    try {
      final proc = await _runTool(['run', 'tools/content_id_autofix.dart']);
      final summary = _parseLastJsonLine(_stdoutToString(proc.stdout));
      if (summary.isNotEmpty) {
        return _normalizeIdAutofix(summary, proc.exitCode);
      }
      if (cached.isNotEmpty) {
        return _normalizeIdAutofix(cached, proc.exitCode);
      }
      return {'fixed': 0, 'total': 0, 'pass': proc.exitCode == 0};
    } catch (e) {
      return {'fixed': 0, 'total': 0, 'pass': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> runConsistencyAudit() async {
    final cached =
        readJsonCached('tools/_reports/content_consistency_audit.json') ??
        const {};
    try {
      final proc = await _runTool([
        'run',
        'tools/content_consistency_audit.dart',
      ]);
      final summary = _parseLastJsonLine(_stdoutToString(proc.stdout));
      if (summary.isNotEmpty) {
        return _normalizeConsistency(summary, proc.exitCode);
      }
      if (cached.isNotEmpty) {
        return _normalizeConsistency(cached, proc.exitCode);
      }
      return {
        'duplicates': 0,
        'deprecated': 0,
        'broken': 0,
        'pass': proc.exitCode == 0,
      };
    } catch (e) {
      return {
        'duplicates': 0,
        'deprecated': 0,
        'broken': 0,
        'pass': false,
        'error': e.toString(),
      };
    }
  }

  final idAutofix = await safeWrap('content_id_autofix', runIdAutofix);
  final consistency = await safeWrap(
    'content_consistency',
    runConsistencyAudit,
  );

  return {
    'content_id_autofix_status': idAutofix,
    'content_consistency_status': consistency,
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

Map<String, dynamic> _normalizeIdAutofix(
  Map<String, dynamic> raw,
  int exitCode,
) {
  final fixed = (raw['fixed'] as num?)?.toInt() ?? 0;
  final total = (raw['total'] as num?)?.toInt() ?? 0;
  final pass = raw['pass'] == true || exitCode == 0;
  final map = <String, dynamic>{'fixed': fixed, 'total': total, 'pass': pass};
  if (raw['error'] is String) {
    map['error'] = raw['error'];
  }
  return map;
}

Map<String, dynamic> _normalizeConsistency(
  Map<String, dynamic> raw,
  int exitCode,
) {
  final duplicates = (raw['duplicates'] as num?)?.toInt() ?? 0;
  final deprecated = (raw['deprecated'] as num?)?.toInt() ?? 0;
  final broken = (raw['broken'] as num?)?.toInt() ?? 0;
  final pass = raw['pass'] == true || exitCode == 0;
  final map = <String, dynamic>{
    'duplicates': duplicates,
    'deprecated': deprecated,
    'broken': broken,
    'pass': pass,
  };
  if (raw['error'] is String) {
    map['error'] = raw['error'];
  }
  return map;
}

Map<String, Object?> _parseLastJsonLine(String stdout) {
  if (stdout.trim().isEmpty) return {};
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
  return {};
}

String _stdoutToString(Object? value) {
  if (value is String) return value;
  if (value is List<int>) return utf8.decode(value);
  return value?.toString() ?? '';
}

import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> runContentSemanticV2({
  required Future<Map<String, dynamic>> Function(
    String label,
    Future<Map<String, dynamic>> Function(),
  )
  safeWrap,
  required Map<String, dynamic>? Function(String path) readJsonCached,
}) async {
  Future<Map<String, dynamic>> runAudit() async {
    final result = await _runTool(['run', 'tools/content_semantic_audit.dart']);
    final report = _readReport(
      'tools/_reports/content_semantic_audit.json',
      readJsonCached,
    );
    final pass = (report['pass'] == true) && result.exitCode == 0;
    final map = Map<String, dynamic>.from(report);
    map['pass'] = pass;
    return map;
  }

  Future<Map<String, dynamic>> runAutofix() async {
    final result = await _runTool([
      'run',
      'tools/content_semantic_autofix.dart',
    ]);
    final report = _readReport(
      'tools/_reports/content_semantic_autofix.json',
      readJsonCached,
    );
    final pass = (report['pass'] == true) && result.exitCode == 0;
    final map = Map<String, dynamic>.from(report);
    map['pass'] = pass;
    return map;
  }

  final audit = await safeWrap('content_semantic_audit', runAudit);
  final autofix = await safeWrap('content_semantic_autofix', runAutofix);

  return {
    'content_semantic_audit_status': audit,
    'content_semantic_autofix_status': autofix,
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

Map<String, dynamic> _readReport(
  String path,
  Map<String, dynamic>? Function(String path) readJsonCached,
) {
  final cached = readJsonCached(path);
  if (cached != null && cached.isNotEmpty) {
    return Map<String, dynamic>.from(cached);
  }

  final file = File(path);
  if (!file.existsSync()) {
    return <String, dynamic>{};
  }

  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {}
  return <String, dynamic>{};
}

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  final schema = await _runTool(
    'tools/content_schema_upgrade.dart',
    dryRun: dryRun,
  );
  final enricher = await _runTool(
    'tools/content_auto_enricher.dart',
    dryRun: dryRun,
  );
  final audit = await _runTool('tools/content_beta_audit.dart', dryRun: true);

  final schemaFixed = (schema['fixed'] as num?)?.toInt() ?? 0;
  final enricherFixed = (enricher['fixed'] as num?)?.toInt() ?? 0;
  final issuesRemaining =
      _metric(audit, 'invalid_schema') +
      _metric(audit, 'empty_goals') +
      _metric(audit, 'empty_reactions') +
      _metric(audit, 'parse_errors');
  final totalFixed = schemaFixed + enricherFixed;
  final pass =
      audit['pass'] == true &&
      (schema['pass'] ?? true) == true &&
      (enricher['pass'] ?? true) == true;

  _printSummary(
    dryRun: dryRun,
    totalFixed: totalFixed,
    schemaSummary: schema,
    enricherSummary: enricher,
    auditSummary: audit,
    pass: pass,
  );

  final summary = {
    'dry_run': dryRun,
    'schema_fixed': schemaFixed,
    'enricher_fixed': enricherFixed,
    'fixed_total': totalFixed,
    'issues_remaining': issuesRemaining,
    'audit': audit,
    'pass': pass,
  };
  await File(
    'content_auto_fixer.json',
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(summary));
}

Future<Map<String, dynamic>> _runTool(
  String script, {
  required bool dryRun,
}) async {
  final args = ['run', script, if (!dryRun) '--apply' else '--dry-run'];
  final proc = await Process.run('dart', args, runInShell: true);

  final summary = _parseLastJson(proc.stdout);
  summary['pass'] ??= proc.exitCode == 0;
  summary['exit_code'] = proc.exitCode;
  return summary;
}

Map<String, dynamic> _parseLastJson(Object? output) {
  final raw = output is String ? output : output?.toString() ?? '';
  if (raw.isEmpty) return <String, dynamic>{};

  final lines = const LineSplitter().convert(raw).reversed;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) continue;
    try {
      final data = jsonDecode(trimmed) as Map<String, dynamic>;
      return data;
    } catch (_) {
      continue;
    }
  }
  return <String, dynamic>{};
}

void _printSummary({
  required bool dryRun,
  required int totalFixed,
  required Map<String, dynamic> schemaSummary,
  required Map<String, dynamic> enricherSummary,
  required Map<String, dynamic> auditSummary,
  required bool pass,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  final schemaFixed = (schemaSummary['fixed'] as num?)?.toInt() ?? 0;
  final enricherFixed = (enricherSummary['fixed'] as num?)?.toInt() ?? 0;
  final issues =
      _metric(auditSummary, 'invalid_schema') +
      _metric(auditSummary, 'empty_goals') +
      _metric(auditSummary, 'empty_reactions') +
      _metric(auditSummary, 'parse_errors');

  stdout.writeln(
    'Content Auto-Fixer\n'
    'Mode: $mode\n'
    'Schema fixes: $schemaFixed\n'
    'Enricher fixes: $enricherFixed\n'
    'Total fixes: $totalFixed\n'
    'Issues remaining: $issues\n'
    'Status: ${pass ? 'PASS' : 'FAIL'}',
  );
}

int _metric(Map<String, dynamic> summary, String key) {
  return (summary[key] as num?)?.toInt() ?? 0;
}

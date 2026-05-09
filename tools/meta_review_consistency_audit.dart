import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _contentRoot = 'content';
const String _drillSummaryPath =
    'release/_reports/drill_refinement_summary.txt';
const String _reportsDir = 'release/_reports';
const String _summaryPath =
    'release/_reports/meta_review_consistency_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

const List<String> _positiveHooks = [
  'keep',
  'love',
  'great',
  'smooth',
  'steady',
  'strong',
  'bold',
  'sharp',
  'stay',
  'press',
  'crisp',
  'tighten',
];

const int _duplicateThreshold = 8;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final entries = await _collectEntries();
  if (entries.isEmpty) {
    stdout.writeln('meta_review_consistency_audit: no entries found.');
    return;
  }

  final audit = _runAudit(entries);
  final clarityHighlights = await _readDrillHighlights();

  await _withReportsWritable(() async {
    await _writeSummary(audit, clarityHighlights);
    await _appendTelemetry(
      issues: audit.issues.length,
      coveragePct: audit.coveragePct,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'meta_review_consistency_audit: ${entries.length} entries scanned, '
    '${audit.issues.length} issues logged.',
  );
}

Future<List<_ContentEntry>> _collectEntries() async {
  final results = <_ContentEntry>[];
  final root = Directory(_contentRoot);
  if (!await root.exists()) return results;

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.jsonl')) continue;
    final packId = _packIdFromPath(entity.path);
    int lineNo = 0;
    for (final raw in entity.readAsLinesSync()) {
      lineNo += 1;
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          results.add(
            _ContentEntry(
              packId: packId,
              filePath: entity.path,
              line: lineNo,
              id: decoded['id']?.toString() ?? '${entity.path}:$lineNo',
              reaction: decoded['reaction_text']?.toString() ?? '',
            ),
          );
        }
      } catch (_) {
        // ignore invalid rows; other tooling surfaces these.
      }
    }
  }

  return results;
}

_AuditResult _runAudit(List<_ContentEntry> entries) {
  final issues = <_Issue>[];
  final packStats = <String, _PackStat>{};
  final reactionMap = <String, List<_ContentEntry>>{};

  for (final entry in entries) {
    final normalizedReaction = entry.reaction.trim();
    reactionMap
        .putIfAbsent(normalizedReaction.toLowerCase(), () => <_ContentEntry>[])
        .add(entry);

    final stat = packStats.putIfAbsent(entry.packId, _PackStat.new);
    stat.total += 1;

    final check = _evaluateReaction(entry.reaction);
    if (check.isNormalized) {
      stat.normalized += 1;
    } else {
      for (final reason in check.reasons) {
        issues.add(
          _Issue(entry: entry, type: reason.type, detail: reason.message),
        );
      }
    }
  }

  // Duplicate issue detection.
  reactionMap.remove('');
  reactionMap.forEach((key, value) {
    if (value.length <= _duplicateThreshold) return;
    final preview = value.first.reaction.trim();
    issues.add(
      _Issue(
        entry: value.first,
        type: _IssueType.duplication,
        detail:
            'Reaction repeated ${value.length} times: ${_truncate(preview)}',
      ),
    );
  });

  final totalEntries = entries.length;
  final normalizedTotal = packStats.values.fold<int>(
    0,
    (sum, stat) => sum + stat.normalized,
  );
  final coverage = totalEntries == 0
      ? 0.0
      : (normalizedTotal / totalEntries) * 100.0;

  final packBreakdown =
      packStats.entries
          .map(
            (e) => _PackCoverage(
              packId: e.key,
              total: e.value.total,
              normalized: e.value.normalized,
            ),
          )
          .toList()
        ..sort((a, b) {
          final delta = (a.normalized / max(1, a.total)).compareTo(
            b.normalized / max(1, b.total),
          );
          if (delta != 0) return delta;
          return a.packId.compareTo(b.packId);
        });

  final issueCounts = <_IssueType, int>{};
  for (final issue in issues) {
    issueCounts[issue.type] = (issueCounts[issue.type] ?? 0) + 1;
  }

  return _AuditResult(
    issues: issues,
    coveragePct: double.parse(coverage.toStringAsFixed(2)),
    packCoverage: packBreakdown,
    issueCounts: issueCounts,
    totalEntries: totalEntries,
    normalizedEntries: normalizedTotal,
  );
}

_ReactionCheck _evaluateReaction(String reaction) {
  final trimmed = reaction.trim();
  final reasons = <_IssueReason>[];
  if (trimmed.isEmpty) {
    reasons.add(
      const _IssueReason(
        type: _IssueType.missing,
        message: 'reaction_text empty',
      ),
    );
    return _ReactionCheck(isNormalized: false, reasons: reasons);
  }

  if (!_startsWithCapital(trimmed)) {
    reasons.add(
      const _IssueReason(
        type: _IssueType.grammar,
        message: 'does not start with a capital letter',
      ),
    );
  }

  if (!_hasTerminalPunctuation(trimmed)) {
    reasons.add(
      const _IssueReason(
        type: _IssueType.grammar,
        message: 'missing terminal punctuation',
      ),
    );
  }

  final lower = trimmed.toLowerCase();
  final hasPositiveHook = _positiveHooks.any(lower.contains);
  if (!hasPositiveHook) {
    reasons.add(
      const _IssueReason(
        type: _IssueType.tone,
        message: 'missing motivational phrasing (keep/love/etc.)',
      ),
    );
  }

  if (trimmed.contains('  ')) {
    reasons.add(
      const _IssueReason(
        type: _IssueType.grammar,
        message: 'contains double spaces',
      ),
    );
  }

  if (trimmed.length < 16) {
    reasons.add(
      const _IssueReason(
        type: _IssueType.tone,
        message: 'too short (<16 chars) to convey guidance',
      ),
    );
  }

  return _ReactionCheck(isNormalized: reasons.isEmpty, reasons: reasons);
}

Future<List<String>> _readDrillHighlights() async {
  final file = File(_drillSummaryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final highlights = <String>[];
  bool capture = false;
  for (final line in lines) {
    if (line.startsWith('Lowest clarity drills')) {
      capture = true;
      continue;
    }
    if (capture) {
      if (line.trim().isEmpty) break;
      if (line.startsWith('|') && !line.startsWith('|-------')) {
        highlights.add(line);
      }
    }
  }
  return highlights;
}

Future<void> _writeSummary(
  _AuditResult audit,
  List<String> clarityHighlights,
) async {
  final buffer = StringBuffer()
    ..writeln('META REVIEW CONSISTENCY SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Entries scanned: ${audit.totalEntries}')
    ..writeln('Normalized reactions: ${audit.normalizedEntries}')
    ..writeln('Coverage: ${audit.coveragePct.toStringAsFixed(2)}%')
    ..writeln('Issues detected: ${audit.issues.length}')
    ..writeln();

  if (audit.issueCounts.isNotEmpty) {
    buffer.writeln('Issue breakdown:');
    for (final type in _IssueType.values) {
      final count = audit.issueCounts[type] ?? 0;
      buffer.writeln('- ${_issueLabel(type)}: $count');
    }
    buffer.writeln();
  }

  if (audit.packCoverage.isNotEmpty) {
    buffer
      ..writeln('Lowest coverage packs (needs rewrites)')
      ..writeln('| Pack | Normalized | Total | Coverage |')
      ..writeln('|------|------------|-------|----------|');
    for (final pack in audit.packCoverage.take(10)) {
      final pct = pack.total == 0 ? 0 : (pack.normalized / pack.total) * 100.0;
      buffer.writeln(
        '| ${pack.packId} | ${pack.normalized} | ${pack.total} | '
        '${pct.toStringAsFixed(1)}% |',
      );
    }
    buffer.writeln();
  }

  _writeIssueTable(
    buffer: buffer,
    title: 'Tone / positivity violations',
    issues: audit.issues
        .where((issue) => issue.type == _IssueType.tone)
        .take(8)
        .toList(),
  );

  _writeIssueTable(
    buffer: buffer,
    title: 'Grammar / punctuation issues',
    issues: audit.issues
        .where((issue) => issue.type == _IssueType.grammar)
        .take(8)
        .toList(),
  );

  _writeIssueTable(
    buffer: buffer,
    title: 'Duplicate reactions',
    issues: audit.issues
        .where((issue) => issue.type == _IssueType.duplication)
        .take(5)
        .toList(),
  );

  if (clarityHighlights.isNotEmpty) {
    buffer
      ..writeln(
        'Cross-reference: lowest clarity drills (from refinement summary)',
      )
      ..writeln('| Drill | Clarity | Coverage | Concept |');
    for (final line in clarityHighlights.take(5)) {
      buffer.writeln(line);
    }
    buffer.writeln();
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

void _writeIssueTable({
  required StringBuffer buffer,
  required String title,
  required List<_Issue> issues,
}) {
  if (issues.isEmpty) return;
  buffer
    ..writeln(title)
    ..writeln('| Pack | Entry | Detail | Reaction |')
    ..writeln('|------|-------|--------|----------|');
  for (final issue in issues) {
    buffer.writeln(
      '| ${issue.entry.packId} | ${issue.entry.id} | '
      '${issue.detail} | ${_truncate(issue.entry.reaction)} |',
    );
  }
  buffer.writeln();
}

Future<void> _appendTelemetry({
  required int issues,
  required double coveragePct,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'meta_review_consistency_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'issues': issues,
    'coverage_pct': coveragePct,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'meta_review_consistency_audit: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

String _packIdFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final contentIndex = normalized.indexOf('content/');
  if (contentIndex == -1) return normalized;
  final start = contentIndex + 'content/'.length;
  final afterContent = normalized.substring(start);
  final slashIndex = afterContent.indexOf('/');
  if (slashIndex == -1) return afterContent;
  return afterContent.substring(0, slashIndex);
}

bool _startsWithCapital(String value) {
  if (value.isEmpty) return false;
  final first = value.codeUnitAt(0);
  return first >= 65 && first <= 90;
}

bool _hasTerminalPunctuation(String value) {
  if (value.isEmpty) return false;
  final last = value[value.length - 1];
  return last == '.' || last == '!' || last == '?';
}

String _truncate(String value, {int max = 80}) {
  final trimmed = value.trim().replaceAll('\n', ' ');
  if (trimmed.length <= max) return trimmed;
  return '${trimmed.substring(0, max - 3)}...';
}

String _issueLabel(_IssueType type) {
  switch (type) {
    case _IssueType.missing:
      return 'Missing reaction_text';
    case _IssueType.tone:
      return 'Tone / positivity';
    case _IssueType.grammar:
      return 'Grammar / punctuation';
    case _IssueType.duplication:
      return 'Duplicate phrasing';
  }
}

class _ContentEntry {
  const _ContentEntry({
    required this.packId,
    required this.filePath,
    required this.line,
    required this.id,
    required this.reaction,
  });

  final String packId;
  final String filePath;
  final int line;
  final String id;
  final String reaction;
}

class _PackStat {
  int total = 0;
  int normalized = 0;
}

class _PackCoverage {
  const _PackCoverage({
    required this.packId,
    required this.total,
    required this.normalized,
  });

  final String packId;
  final int total;
  final int normalized;
}

class _ReactionCheck {
  const _ReactionCheck({required this.isNormalized, required this.reasons});

  final bool isNormalized;
  final List<_IssueReason> reasons;
}

class _IssueReason {
  const _IssueReason({required this.type, required this.message});

  final _IssueType type;
  final String message;
}

class _Issue {
  const _Issue({required this.entry, required this.type, required this.detail});

  final _ContentEntry entry;
  final _IssueType type;
  final String detail;
}

class _AuditResult {
  const _AuditResult({
    required this.issues,
    required this.coveragePct,
    required this.packCoverage,
    required this.issueCounts,
    required this.totalEntries,
    required this.normalizedEntries,
  });

  final List<_Issue> issues;
  final double coveragePct;
  final List<_PackCoverage> packCoverage;
  final Map<_IssueType, int> issueCounts;
  final int totalEntries;
  final int normalizedEntries;
}

enum _IssueType { missing, tone, grammar, duplication }

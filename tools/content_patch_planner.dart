import 'dart:io';

void main() {
  final consistency = _parseConsistency();
  final bootstrap = _parseBootstrap();
  final explainDrafts = _parseDraftsIndex();
  final densityIndex = _parseDensityIndex();
  final scorecards = _parseScorecards();
  final modules = <String>{
    ...consistency.keys,
    ...bootstrap.keys,
    ...explainDrafts,
    ...densityIndex.keys,
    ...scorecards.keys,
  };
  final index = StringBuffer();
  index.writeln('module | severity | topActions');
  final planDir = Directory('release/_reports/patch_plans');
  planDir.createSync(recursive: true);
  for (final module in modules) {
    final struct = consistency[module];
    final boot = bootstrap[module];
    final explainCount = explainDrafts.contains(module) ? 1 : 0;
    final density = densityIndex[module];
    final card = scorecards[module];
    final severity = _severityLookup(
      struct?.heat ?? 'Warm',
      explainCount,
      density,
    );
    final actions = <String>[];
    if (struct != null && struct.missing > 0) {
      actions.add('Fix ${struct.missing} missing structure assets');
    }
    if (struct != null && struct.heat == 'order-bad') {
      actions.add('Realign section ordering');
    }
    if (explainCount > 0) {
      actions.add('Write $explainCount explain drafts');
    }
    if (density != null) {
      final densSeverity = density.severity;
      actions.add('Address $densSeverity density/coherence issues');
    }
    if (card != null) {
      final weakness = card.weakness;
      actions.add('Follow scorecard fixes: $weakness');
    }
    if (boot != null) {
      final fixHint = boot.fix;
      actions.add('Autofix hint: $fixHint');
    }
    if (actions.isEmpty) {
      actions.add('Monitor for regressions');
    }
    final plan = StringBuffer();
    plan.writeln('==== MODULE PATCH PLAN ====');
    plan.writeln('module: $module');
    plan.writeln('severity: $severity');
    plan.writeln('structural fixes: ${struct?.missing ?? 0} issues');
    plan.writeln('explain drafts needed: $explainCount');
    plan.writeln('density/coherence: ${density?.status ?? 'n/a'}');
    plan.writeln('scorecard notes: ${card?.weakness ?? 'n/a'}');
    plan.writeln('recommended order: ${actions.join(' -> ')}');
    plan.writeln('actions:');
    for (final action in actions) plan.writeln('  - $action');
    File('${planDir.path}/$module.txt').writeAsStringSync(plan.toString());
    final firstAction = actions.first;
    index.writeln('$module | $severity | $firstAction');
  }
  File('${planDir.path}/_index.txt').writeAsStringSync(index.toString());
  stdout.write(index.toString());
}

Map<String, _Consistency> _parseConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  if (!file.existsSync()) return {};
  final map = <String, _Consistency>{};
  for (final line in file.readAsLinesSync().skip(1)) {
    final cols = line.split('|').map((p) => p.trim()).toList();
    if (cols.length < 7) continue;
    map[cols[1]] = _Consistency(
      heat: cols[6],
      missing: cols[2] == 'ok' ? 0 : 1,
    );
  }
  return map;
}

Map<String, _Bootstrap> _parseBootstrap() {
  final file = File('release/_reports/autofix_priority_bootstrap.txt');
  if (!file.existsSync()) return {};
  final map = <String, _Bootstrap>{};
  final lines = file.readAsLinesSync();
  for (final line in lines) {
    if (!line.contains('. ')) continue;
    final parts = line.split('. ')[1].split('|').map((p) => p.trim()).toList();
    if (parts.length < 2) continue;
    final module = parts[0];
    map[module] = _Bootstrap(
      fix: 'Follow priority bootstrap action',
      heat: parts.length > 2 ? parts[2] : 'Warm',
    );
  }
  return map;
}

Set<String> _parseDraftsIndex() {
  final file = File('release/_reports/tap_to_explain_drafts/_index.txt');
  if (!file.existsSync()) return {};
  final entries = <String>{};
  for (final line in file.readAsLinesSync().skip(1)) {
    final module = line.split('|').first.trim();
    entries.add(module);
  }
  return entries;
}

Map<String, _DensityEntry> _parseDensityIndex() {
  final file = File(
    'release/_reports/density_coherence_suggestions/_index.txt',
  );
  if (!file.existsSync()) return {};
  final map = <String, _DensityEntry>{};
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 4) continue;
    final status = parts[3];
    map[parts[0]] = _DensityEntry(
      status: status,
      severity: status == 'HIGH' ? 'HIGH' : 'MEDIUM',
    );
  }
  return map;
}

Map<String, _ScorecardEntry> _parseScorecards() {
  final file = File('release/_reports/scorecards/_index.txt');
  if (!file.existsSync()) return {};
  final map = <String, _ScorecardEntry>{};
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    map[parts[0]] = _ScorecardEntry(weakness: parts[2]);
  }
  return map;
}

String _severityLookup(String heat, int explains, _DensityEntry? density) {
  var score = heat == 'Hot'
      ? 3
      : heat == 'Warm'
      ? 2
      : 1;
  if (explains > 0) score += 1;
  if (density?.severity == 'HIGH') score += 1;
  if (score >= 5) return 'CRITICAL';
  if (score >= 4) return 'HIGH';
  if (score >= 3) return 'MEDIUM';
  return 'LOW';
}

class _Consistency {
  _Consistency({required this.heat, required this.missing});

  final String heat;
  final int missing;
}

class _Bootstrap {
  _Bootstrap({required this.fix, required this.heat});

  final String fix;
  final String heat;
}

class _DensityEntry {
  _DensityEntry({required this.status, required this.severity});

  final String status;
  final String severity;
}

class _ScorecardEntry {
  _ScorecardEntry({required this.weakness});

  final String weakness;
}

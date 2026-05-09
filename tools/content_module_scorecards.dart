import 'dart:io';

void main() {
  final structure = _parseStructure();
  final density = _parseDensity();
  final tte = _parseTTE();
  final consistency = _parseConsistency();
  final modules = <String>{}
    ..addAll(structure.keys)
    ..addAll(density.keys)
    ..addAll(tte.keys)
    ..addAll(consistency.keys);
  final index = StringBuffer();
  index.writeln('module | heat | score');
  for (final module in modules) {
    final struct = structure[module];
    final dens = density[module];
    final tt = tte[module];
    final cons = consistency[module];
    final heat = cons?.heat ?? 'Warm';
    final score = cons?.score.toStringAsFixed(2) ?? 'n/a';
    index.writeln('$module | $heat | $score');
    final card = StringBuffer();
    card.writeln('MODULE SCORECARD: $module');
    card.writeln('Structure | ${struct?.description ?? 'n/a'}');
    final densityStr = dens != null
        ? '${dens.density.toStringAsFixed(2)} (${dens.status})'
        : 'n/a';
    final coherenceStr = dens != null
        ? '${dens.coherence.toStringAsFixed(2)} (${dens.coStatus})'
        : 'n/a';
    card.writeln('Density   | $densityStr');
    card.writeln('Coherence | $coherenceStr');
    final tteCoverage = tt != null ? tt.coverage.toStringAsFixed(2) : 'n/a';
    final tteMissing = tt?.missing ?? 0;
    card.writeln('TTE       | $tteCoverage coverage, $tteMissing missing');
    card.writeln('Score     | $score heat=$heat');
    card.writeln('Suggestions:');
    final suggestions = <String>{};
    final missingFiles = struct?.missing ?? [];
    if (missingFiles.isNotEmpty) {
      suggestions.add('Add missing files: ${missingFiles.join(",")}');
    }
    if (struct != null && !struct.orderOk) {
      suggestions.add('Fix section ordering');
    }
    if (dens != null) {
      if (dens.status == 'low') suggestions.add('Expand textual explanations');
      if (dens.status == 'high') suggestions.add('Split dense sections');
      if (dens.coStatus == 'low') suggestions.add('Clarify reasoning flow');
    }
    final ttMissing = tt?.missing ?? 0;
    if (ttMissing > 0 && tt != null) {
      suggestions.add(
        'Define missing explain keys: ${tt.missingList.join(",")}',
      );
    }
    if (suggestions.isEmpty) suggestions.add('Maintain current quality');
    for (final suggestion in suggestions) {
      card.writeln('  - $suggestion');
    }
    final dir = Directory('release/_reports/scorecards');
    dir.createSync(recursive: true);
    File('${dir.path}/$module.txt').writeAsStringSync(card.toString());
  }
  File(
    'release/_reports/scorecards/_index.txt',
  ).writeAsStringSync(index.toString());
  stdout.write(index);
}

Map<String, _StructureRow> _parseStructure() {
  final file = File('release/_reports/content_structure_audit.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _StructureRow>{};
  for (var line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    rows[parts[0]] = _StructureRow(
      module: parts[0],
      missing: parts[1] == 'none' ? [] : parts[1].split(','),
      jsonValid: parts[2] == 'ok',
      extras: parts[3] == 'none' ? [] : parts[3].split(','),
      orderOk: parts[4] == 'order-ok',
      description:
          parts[1] == 'none' && parts[3] == 'none' && parts[4] == 'order-ok'
          ? 'OK'
          : 'issues',
    );
  }
  return rows;
}

Map<String, _DensityRow> _parseDensity() {
  final file = File('release/_reports/theory_density_normalized.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _DensityRow>{};
  final lines = file.readAsLinesSync();
  for (final line in lines) {
    if (!line.startsWith('module:')) continue;
    final module = line.split(':').last.trim();
    final densityLine = lines.firstWhere(
      (l) => l.startsWith('density:'),
      orElse: () => '',
    );
    final coherenceLine = lines.firstWhere(
      (l) => l.startsWith('coherence:'),
      orElse: () => '',
    );
    final densityVal =
        double.tryParse(densityLine.split('(').first.split(':').last.trim()) ??
        0;
    final coherenceVal =
        double.tryParse(
          coherenceLine.split('(').first.split(':').last.trim(),
        ) ??
        0;
    rows[module] = _DensityRow(
      density: densityVal,
      status: densityVal < 85 ? 'low' : (densityVal > 135 ? 'high' : 'ideal'),
      coherence: coherenceVal,
      coStatus: coherenceVal >= 0.85 ? 'ok' : 'low',
    );
  }
  return rows;
}

Map<String, _TTERow> _parseTTE() {
  final file = File('release/_reports/tap_to_explain_coverage.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _TTERow>{};
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    rows[parts[0]] = _TTERow(
      module: parts[0],
      required: int.tryParse(parts[1]) ?? 0,
      defined: int.tryParse(parts[2]) ?? 0,
      missing: int.tryParse(parts[3]) ?? 0,
      coverage: double.tryParse(parts[4]) ?? 0.0,
      missingList: parts[3] == '0' ? [] : parts[3].split(','),
    );
  }
  return rows;
}

Map<String, _ConsistencyRow> _parseConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  if (!file.existsSync()) return {};
  final rows = <String, _ConsistencyRow>{};
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    rows[parts[1]] = _ConsistencyRow(
      module: parts[1],
      score: double.tryParse(parts[5]) ?? 0.0,
      heat: parts[6],
    );
  }
  return rows;
}

class _StructureRow {
  _StructureRow({
    required this.module,
    required this.missing,
    required this.jsonValid,
    required this.extras,
    required this.orderOk,
    required this.description,
  });

  final String module;
  final List<String> missing;
  final bool jsonValid;
  final List<String> extras;
  final bool orderOk;
  final String description;
}

class _DensityRow {
  _DensityRow({
    required this.density,
    required this.status,
    required this.coherence,
    required this.coStatus,
  });

  final double density;
  final String status;
  final double coherence;
  final String coStatus;
}

class _TTERow {
  _TTERow({
    required this.module,
    required this.required,
    required this.defined,
    required this.missing,
    required this.coverage,
    required this.missingList,
  });

  final String module;
  final int required;
  final int defined;
  final int missing;
  final double coverage;
  final List<String> missingList;
}

class _ConsistencyRow {
  _ConsistencyRow({
    required this.module,
    required this.score,
    required this.heat,
  });

  final String module;
  final double score;
  final String heat;
}

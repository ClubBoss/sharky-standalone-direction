import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/content/release_content_plan.dart';

const _bannedJargon = <String>[
  'gto',
  'spr',
  'blocker',
  'polar',
  'merge',
  'donk',
  'range adv',
  'range advantage',
  'rangeadv',
  'rfi',
  'three-bet',
  '3-bet',
  'c-bet',
  'cbet',
  'cbets',
];

const _maxReasoningLength = 260;

void main() {
  final modules = ReleaseContentPlanV1.modules.toList()
    ..sort((a, b) => a.id.compareTo(b.id));

  final moduleReports = <_ModuleReport>[];

  for (final module in modules) {
    final report = _auditModule(module);
    moduleReports.add(report);
  }

  _writeReport(moduleReports);
}

_ModuleReport _auditModule(ReleaseContentModule module) {
  final errors = <String>[];
  final manifestPath = 'content/${module.id}/v1/manifest.json';
  final manifestFile = File(manifestPath);

  if (!manifestFile.existsSync()) {
    errors.add('${module.id} manifest missing');
  } else {
    try {
      final manifest = jsonDecode(manifestFile.readAsStringSync());
      if (manifest is Map<String, dynamic>) {
        final difficultyTier = manifest['difficulty_tier'];
        if (difficultyTier != module.difficultyTier) {
          errors.add(
            '${module.id} difficulty_tier mismatch (plan=${module.difficultyTier}, manifest=$difficultyTier)',
          );
        }

        final reasoning = (manifest['reasoning'] as String?)?.trim() ?? '';
        _applyReasoningChecks(module, reasoning, errors);

        final availability = (manifest['availability'] as String?)?.trim();
        if (availability == null || availability.isEmpty) {
          errors.add('${module.id} manifest missing availability');
        } else if (availability != 'available') {
          errors.add('${module.id} availability is $availability');
        }

        _checkDeterminism(module, manifest, errors);
      } else {
        errors.add('${module.id} manifest.json must be an object');
      }
    } catch (e) {
      errors.add('${module.id} manifest parse error ($e)');
    }
  }

  return _ModuleReport(
    module: module,
    manifestPath: manifestPath,
    flags: errors,
  );
}

void _applyReasoningChecks(
  ReleaseContentModule module,
  String reasoning,
  List<String> errors,
) {
  if (reasoning.isEmpty) {
    errors.add('${module.id} reasoning is empty');
  }

  if (reasoning.length > _maxReasoningLength) {
    errors.add('${module.id} reasoning exceeds $_maxReasoningLength chars');
  }

  final lines = reasoning
      .split(RegExp(r'\r?\n'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty);

  final seenForms = <String, Set<String>>{};

  for (final line in lines) {
    final lower = line.toLowerCase();
    for (final term in _bannedJargon) {
      final token = term.replaceAll(' ', r'\s+');
      final match = RegExp(r'\b' + token + r'\b').hasMatch(lower);
      if (match && !_isExplained(term, lower)) {
        errors.add('${module.id} reasoning uses jargon "$term"');
      }
    }

    for (final word in RegExp(r'[A-Za-z0-9][A-Za-z0-9\-]*').allMatches(line)) {
      final raw = word.group(0)!;
      final normalized = raw
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .toLowerCase();
      if (normalized.length <= 1) continue;
      seenForms.putIfAbsent(normalized, () => <String>{}).add(raw);
    }
  }

  for (final entry in seenForms.entries) {
    if (entry.value.length > 1) {
      final forms = entry.value.join(', ');
      errors.add(
        '${module.id} uses inconsistent spelling "${entry.key}" ($forms)',
      );
    }
  }
}

bool _isExplained(String term, String line) {
  final lowerTerm = term.toLowerCase();
  return line.contains('$lowerTerm -') ||
      line.contains('$lowerTerm—') ||
      line.contains('$lowerTerm:');
}

void _checkDeterminism(
  ReleaseContentModule module,
  Map<String, dynamic> manifest,
  List<String> errors,
) {
  for (final banned in ['seed', 'timestamp', 'random']) {
    if (manifest.containsKey(banned)) {
      errors.add('${module.id} manifest defines prohibited field $banned');
    }
  }
}

void _writeReport(List<_ModuleReport> reports) {
  final file = File('docs/pedagogical_audit_report_v1.md');
  final buffer = StringBuffer()
    ..writeln('# Pedagogical Audit v1')
    ..writeln()
    ..writeln(
      'This audit covers the release content modules defined in '
      '`ReleaseContentPlanV1` and reports deterministic reasoning quality.',
    )
    ..writeln()
    ..writeln('## Summary Table')
    ..writeln()
    ..writeln('| Module ID | Difficulty Tier | Flags |')
    ..writeln('| --- | --- | --- |');

  for (final report in reports) {
    final flagSummary = report.flags.isEmpty
        ? 'none'
        : '${report.flags.length} flag(s): ${report.flags.take(2).join('; ')}';
    buffer.writeln(
      '| ${report.module.id} | ${report.module.difficultyTier} | $flagSummary |',
    );
  }

  buffer.writeln();
  buffer.writeln('## Module Details');

  for (final report in reports) {
    buffer
      ..writeln()
      ..writeln('### ${report.module.id}')
      ..writeln('- Difficulty Tier: ${report.module.difficultyTier}')
      ..writeln('- Error Class: ${report.module.errorClass}')
      ..writeln('- Reasoning: ${report.module.reasoning}')
      ..writeln('- Manifest Path: `${report.manifestPath}`');
    if (report.flags.isEmpty) {
      buffer.writeln('- Flags: none');
    } else {
      buffer.writeln('- Flags:');
      for (final flag in report.flags) {
        buffer.writeln('  - $flag');
      }
    }
  }

  file.writeAsStringSync(buffer.toString());
}

class _ModuleReport {
  _ModuleReport({
    required this.module,
    required this.manifestPath,
    required this.flags,
  });

  final ReleaseContentModule module;
  final String manifestPath;
  final List<String> flags;
}

import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final preview = _VisualIterationPreview();
  try {
    final result = await preview.build();
    await preview.writeReport(result);
    await preview.emitTelemetry(result);
  } finally {
    await preview.restorePermissions();
  }
}

class _VisualIterationPreview {
  bool _madeWritable = false;

  Future<_PreviewResult> build() async {
    final designFile = File('release/_reports/design_refinement_report.md');
    final matrixFile = File('release/_reports/ux_prioritization_matrix.md');

    if (!designFile.existsSync()) {
      throw StateError('design_refinement_report.md missing');
    }
    if (!matrixFile.existsSync()) {
      throw StateError('ux_prioritization_matrix.md missing');
    }

    final designLines = await designFile.readAsLines();
    final matrixLines = await matrixFile.readAsLines();

    final sections = _parseDesignSections(designLines);
    final priorities = _parsePriorities(matrixLines);

    return _PreviewResult(
      timestamp: DateTime.now().toUtc(),
      sections: sections,
      priorities: priorities.take(5).toList(),
    );
  }

  Future<void> writeReport(_PreviewResult result) async {
    final buffer = StringBuffer()
      ..writeln('# Visual Iteration Preview')
      ..writeln('Generated: ${result.timestamp.toIso8601String()}')
      ..writeln(
        'Sources: design_refinement_report.md + '
        'ux_prioritization_matrix.md',
      )
      ..writeln()
      ..writeln('## Canvas Summary')
      ..writeln('| Dimension | Score | Notes |')
      ..writeln('|-----------|-------|-------|');
    for (final section in result.sections) {
      buffer.writeln(
        '| ${section.name} | ${section.score.toString().padLeft(3)} '
        '| ${section.notes} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Iteration Concepts');
    for (var i = 0; i < result.priorities.length; i += 1) {
      final priority = result.priorities[i];
      final motionTags = _motionTags(priority);
      final layoutTokens = _layoutTokens(priority.area);
      buffer
        ..writeln('### ${i + 1}. ${priority.area} (${priority.impact})')
        ..writeln('- Motion tags: ${motionTags.join(', ')}')
        ..writeln('- Layout tokens: ${layoutTokens.join(', ')}')
        ..writeln('- Before: ${priority.driver}')
        ..writeln('- After: ${priority.action}')
        ..writeln();
    }

    await _safeWrite(
      File('release/_reports/visual_iteration_preview.md'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_PreviewResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.visualIterationCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'section_count': result.sections.length,
      'concepts': result.priorities.length,
      'top_area': result.priorities.isEmpty ? '' : result.priorities.first.area,
    };

    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  Future<void> restorePermissions() async {
    if (_madeWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _madeWritable = false;
    }
  }

  List<_DesignSection> _parseDesignSections(List<String> lines) {
    final sections = <_DesignSection>[];
    final pattern = RegExp(r'^\|\s*(\w+)\s*\|\s*(\d+)\s*\|\s*(.+?)\s*\|');
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        sections.add(
          _DesignSection(
            name: match.group(1)!,
            score: int.parse(match.group(2)!),
            notes: match.group(3)!.trim(),
          ),
        );
      }
    }
    return sections;
  }

  List<_PriorityRow> _parsePriorities(List<String> lines) {
    final priorities = <_PriorityRow>[];
    for (final line in lines) {
      if (!line.startsWith('|')) {
        continue;
      }
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 6) {
        continue;
      }
      final rank = int.tryParse(parts[1]);
      if (rank == null) {
        continue;
      }
      priorities.add(
        _PriorityRow(
          rank: rank,
          area: parts[2],
          impact: parts[3],
          driver: parts[4],
          action: parts[5],
        ),
      );
    }
    priorities.sort((a, b) => a.rank.compareTo(b.rank));
    return priorities;
  }

  List<String> _motionTags(_PriorityRow priority) {
    final normalized = (priority.area + priority.action).toLowerCase();
    final tags = <String>[];
    if (normalized.contains('motion') ||
        normalized.contains('animation') ||
        normalized.contains('streak')) {
      tags.add('motion: choreographed');
    }
    if (normalized.contains('telemetry')) {
      tags.add('signal: telemetry hook');
    }
    if (normalized.contains('spacing') ||
        normalized.contains('cta') ||
        normalized.contains('padding')) {
      tags.add('layout: spacing');
    }
    if (tags.isEmpty) {
      tags.add('static-pass');
    }
    return tags;
  }

  List<String> _layoutTokens(String area) {
    final normalized = area.toLowerCase();
    if (normalized.contains('ergonomics')) {
      return <String>['pad-16', 'gap-12', 'grid-flow-column'];
    }
    if (normalized.contains('focus')) {
      return <String>['surface-cta', 'stroke-amber', 'elev-04'];
    }
    if (normalized.contains('consistency')) {
      return <String>['type-title-md', 'type-body-sm', 'color-slate-40'];
    }
    if (normalized.contains('quality') || normalized.contains('testing')) {
      return <String>['golden-lock', 'token-guard', 'doc-note'];
    }
    if (normalized.contains('performance')) {
      return <String>['repaint-boundary', 'cache-layer', 'stack-trim'];
    }
    return <String>['layout-token-review'];
  }

  Future<void> _safeWrite(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _safeAppend(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents, mode: FileMode.append);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents, mode: FileMode.append);
    }
  }

  Future<void> _makeWritable() async {
    if (_madeWritable) {
      return;
    }
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }
}

class _DesignSection {
  _DesignSection({
    required this.name,
    required this.score,
    required this.notes,
  });

  final String name;
  final int score;
  final String notes;
}

class _PriorityRow {
  _PriorityRow({
    required this.rank,
    required this.area,
    required this.impact,
    required this.driver,
    required this.action,
  });

  final int rank;
  final String area;
  final String impact;
  final String driver;
  final String action;
}

class _PreviewResult {
  _PreviewResult({
    required this.timestamp,
    required this.sections,
    required this.priorities,
  });

  final DateTime timestamp;
  final List<_DesignSection> sections;
  final List<_PriorityRow> priorities;
}

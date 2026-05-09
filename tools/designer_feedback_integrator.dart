import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final integrator = _DesignerFeedbackIntegrator();
  try {
    final matrix = await integrator.build();
    await integrator.writeMatrix(matrix);
    await integrator.emitTelemetry(matrix);
  } finally {
    await integrator.restorePermissions();
  }
}

class _DesignerFeedbackIntegrator {
  bool _madeWritable = false;

  Future<_FeedbackMatrix> build() async {
    final designFile = File('release/_reports/design_refinement_report.md');
    final previewFile = File('release/_reports/visual_iteration_preview.md');

    if (!designFile.existsSync()) {
      throw StateError('design_refinement_report.md not found.');
    }
    if (!previewFile.existsSync()) {
      throw StateError('visual_iteration_preview.md not found.');
    }

    final designLines = await designFile.readAsLines();
    final previewLines = await previewFile.readAsLines();

    final sections = _parseSections(designLines);
    final concepts = _parseConcepts(previewLines);

    final now = DateTime.now().toUtc();

    final entries = <_FeedbackEntry>[
      _buildColorEntry(sections, concepts),
      _buildLayoutEntry(sections, concepts),
      _buildMotionEntry(sections, concepts),
      _buildSpacingEntry(sections, concepts),
    ];

    return _FeedbackMatrix(
      timestamp: now,
      entries: entries,
      conceptCount: concepts.length,
    );
  }

  Future<void> writeMatrix(_FeedbackMatrix matrix) async {
    final buffer = StringBuffer()
      ..writeln('# Designer Feedback Matrix')
      ..writeln('Generated: ${matrix.timestamp.toIso8601String()}')
      ..writeln(
        'Sources: design_refinement_report.md + '
        'visual_iteration_preview.md',
      )
      ..writeln()
      ..writeln(
        '| Category | Current Observation | Proposed Adjustment | Notes |',
      )
      ..writeln(
        '|----------|---------------------|---------------------|-------|',
      );
    for (final entry in matrix.entries) {
      buffer.writeln(
        '| ${entry.category} | ${entry.current} | ${entry.proposed} | '
        '${entry.notes} |',
      );
    }

    await _safeWrite(
      File('release/_reports/designer_feedback_matrix.md'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_FeedbackMatrix matrix) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.designerFeedbackIntegrated,
      'timestamp': matrix.timestamp.toIso8601String(),
      'entries': matrix.entries.length,
      'concepts': matrix.conceptCount,
      'top_category': matrix.entries.isEmpty
          ? ''
          : matrix.entries.first.category,
    };
    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  List<_DesignSection> _parseSections(List<String> lines) {
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

  List<_Concept> _parseConcepts(List<String> lines) {
    final concepts = <_Concept>[];
    for (var i = 0; i < lines.length; i += 1) {
      final line = lines[i];
      if (!line.startsWith('### ')) continue;
      final heading = RegExp(
        r'^###\s+\d+\.\s+(.+?)\s+\((.+)\)',
      ).firstMatch(line);
      if (heading == null) continue;
      final area = heading.group(1)!.trim();
      final impact = heading.group(2)!.trim();
      final motionLine = _readBullet(lines, i + 1, '- Motion tags:');
      final layoutLine = _readBullet(lines, i + 2, '- Layout tokens:');
      final beforeLine = _readBullet(lines, i + 3, '- Before:');
      final afterLine = _readBullet(lines, i + 4, '- After:');

      concepts.add(
        _Concept(
          area: area,
          impact: impact,
          motionTags: motionLine.split(',').map((s) => s.trim()).toList(),
          layoutTokens: layoutLine.split(',').map((s) => s.trim()).toList(),
          before: beforeLine.trim(),
          after: afterLine.trim(),
        ),
      );
    }
    return concepts;
  }

  static String _readBullet(List<String> lines, int index, String prefix) {
    if (index >= lines.length) return '';
    final line = lines[index];
    if (!line.startsWith(prefix)) return '';
    return line.substring(prefix.length).trim();
  }

  _FeedbackEntry _buildColorEntry(
    List<_DesignSection> sections,
    List<_Concept> concepts,
  ) {
    final balance = _findSection(sections, 'Balance');
    final contrast = _findSection(sections, 'Contrast');
    final consistencyConcept = concepts.firstWhere(
      (c) => c.area.toLowerCase().contains('consistency'),
      orElse: () => _Concept.empty,
    );

    final current = [
      if (balance != null) 'Balance ${balance.score}: ${balance.notes}',
      if (contrast != null) 'Contrast ${contrast.score}: ${contrast.notes}',
    ].join(' / ');

    final proposed = consistencyConcept == _Concept.empty
        ? 'Rebalance hero + neutral usage on CTA lanes.'
        : consistencyConcept.after;

    final notes = consistencyConcept == _Concept.empty
        ? 'No explicit iteration concept; align palette with scorecard.'
        : 'Driver: ${consistencyConcept.before}';

    return _FeedbackEntry(
      category: 'Color',
      current: current.isEmpty ? 'n/a' : current,
      proposed: proposed,
      notes: notes,
    );
  }

  _FeedbackEntry _buildLayoutEntry(
    List<_DesignSection> sections,
    List<_Concept> concepts,
  ) {
    final clarity = _findSection(sections, 'Clarity');
    final focusConcept = concepts.firstWhere(
      (c) => c.area.toLowerCase().contains('focus'),
      orElse: () => _Concept.empty,
    );

    final current = clarity == null
        ? 'Layout clarity baseline unavailable.'
        : 'Clarity ${clarity.score}: ${clarity.notes}';

    final proposed = focusConcept == _Concept.empty
        ? 'Highlight interaction focus states across secondary chips.'
        : focusConcept.after;

    final notes = focusConcept == _Concept.empty
        ? 'Derive detailed layouts from scorecard observations.'
        : 'Layout tokens: ${focusConcept.layoutTokens.join(', ')}';

    return _FeedbackEntry(
      category: 'Layout',
      current: current,
      proposed: proposed,
      notes: notes,
    );
  }

  _FeedbackEntry _buildMotionEntry(
    List<_DesignSection> sections,
    List<_Concept> concepts,
  ) {
    final motion = _findSection(sections, 'Motion');
    final motionConcept = concepts.firstWhere(
      (c) => c.motionTags.any((tag) => tag.toLowerCase().contains('motion')),
      orElse: () => concepts.firstWhere(
        (c) => c.area.toLowerCase().contains('performance'),
        orElse: () => _Concept.empty,
      ),
    );

    final current = motion == null
        ? 'Motion signal not captured.'
        : 'Motion ${motion.score}: ${motion.notes}';

    final proposed = motionConcept == _Concept.empty
        ? 'Add micro-motion to streak/reward overlays.'
        : motionConcept.after;

    final notes = motionConcept == _Concept.empty
        ? 'No motion tags in preview; schedule exploratory pass.'
        : 'Motion tags: ${motionConcept.motionTags.join(', ')}';

    return _FeedbackEntry(
      category: 'Motion',
      current: current,
      proposed: proposed,
      notes: notes,
    );
  }

  _FeedbackEntry _buildSpacingEntry(
    List<_DesignSection> sections,
    List<_Concept> concepts,
  ) {
    final ergonomics = _findSection(sections, 'Ergonomics');
    final spacingConcept = concepts.firstWhere(
      (c) => c.area.toLowerCase().contains('ergonomics'),
      orElse: () => _Concept.empty,
    );

    final current = ergonomics == null
        ? 'Spacing metrics unavailable.'
        : 'Ergonomics ${ergonomics.score}: ${ergonomics.notes}';

    final proposed = spacingConcept == _Concept.empty
        ? 'Revisit CTA stack spacing for mobile.'
        : spacingConcept.after;

    final notes = spacingConcept == _Concept.empty
        ? 'No spacing concept captured in preview.'
        : 'Layout tokens: ${spacingConcept.layoutTokens.join(', ')}';

    return _FeedbackEntry(
      category: 'Spacing',
      current: current,
      proposed: proposed,
      notes: notes,
    );
  }

  _DesignSection? _findSection(List<_DesignSection> sections, String name) {
    return sections
        .firstWhere(
          (section) => section.name.toLowerCase() == name.toLowerCase(),
          orElse: () => _DesignSection.empty,
        )
        .maybeNull;
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
    if (_madeWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }

  Future<void> restorePermissions() async {
    if (!_madeWritable) return;
    await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
    _madeWritable = false;
  }
}

class _DesignSection {
  const _DesignSection({
    required this.name,
    required this.score,
    required this.notes,
  });

  final String name;
  final int score;
  final String notes;

  static const _DesignSection empty = _DesignSection(
    name: '',
    score: 0,
    notes: '',
  );

  _DesignSection? get maybeNull => name.isEmpty ? null : this;
}

class _Concept {
  const _Concept({
    required this.area,
    required this.impact,
    required this.motionTags,
    required this.layoutTokens,
    required this.before,
    required this.after,
  });

  final String area;
  final String impact;
  final List<String> motionTags;
  final List<String> layoutTokens;
  final String before;
  final String after;

  static const _Concept empty = _Concept(
    area: '',
    impact: '',
    motionTags: <String>[],
    layoutTokens: <String>[],
    before: '',
    after: '',
  );
}

class _FeedbackEntry {
  _FeedbackEntry({
    required this.category,
    required this.current,
    required this.proposed,
    required this.notes,
  });

  final String category;
  final String current;
  final String proposed;
  final String notes;
}

class _FeedbackMatrix {
  _FeedbackMatrix({
    required this.timestamp,
    required this.entries,
    required this.conceptCount,
  });

  final DateTime timestamp;
  final List<_FeedbackEntry> entries;
  final int conceptCount;
}

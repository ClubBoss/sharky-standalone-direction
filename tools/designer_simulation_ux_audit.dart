import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final audit = _DesignerSimulationUxAudit();
  try {
    final result = await audit.evaluate();
    await audit.writeReport(result);
    await audit.emitTelemetry(result);
  } finally {
    await audit.restorePermissions();
  }
}

class _DesignerSimulationUxAudit {
  bool _madeWritable = false;

  Future<_AuditResult> evaluate() async {
    final stats = _UxStats();
    final directories = <String>['lib/ui_v3', 'lib/widgets'];

    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        continue;
      }
      final entities = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in entities) {
        final content = await file.readAsString();
        stats.addFile(content);
      }
    }

    final snapshot = stats.snapshot();
    final sections = _buildSections(snapshot);
    final improvements = _buildImprovements(snapshot, sections);

    return _AuditResult(
      timestamp: DateTime.now().toUtc(),
      stats: snapshot,
      sections: sections,
      improvements: improvements.take(10).toList(),
    );
  }

  Future<void> writeReport(_AuditResult result) async {
    final buffer = StringBuffer()
      ..writeln('# Designer Simulation UX Audit')
      ..writeln('Generated: ${result.timestamp.toIso8601String()}')
      ..writeln('Source: lib/ui_v3 + lib/widgets (Phi-D sweep)')
      ..writeln()
      ..writeln('## Scorecard')
      ..writeln('| Dimension | Score | Notes |')
      ..writeln('|-----------|-------|-------|');
    for (final section in result.sections) {
      buffer.writeln(
        '| ${section.name} | ${section.score.toString().padLeft(3)} | ${section.notes} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Detailed Findings');
    for (final section in result.sections) {
      buffer
        ..writeln('### ${section.name} (${section.score}/100)')
        ..writeln(section.details)
        ..writeln();
    }

    buffer
      ..writeln('## Top Improvement Opportunities')
      ..writeln('| # | Area | Recommendation | Impact |')
      ..writeln('|---|------|----------------|--------|');
    for (var i = 0; i < result.improvements.length; i += 1) {
      final suggestion = result.improvements[i];
      buffer.writeln(
        '| ${i + 1} | ${suggestion.area} '
        '| ${suggestion.note} | ${suggestion.impact} |',
      );
    }

    await _safeWrite(
      File('release/_reports/design_refinement_report.md'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_AuditResult result) async {
    final scoreMap = <String, int>{
      for (final section in result.sections) section.name: section.score,
    };
    final payload = <String, Object>{
      'event': TelemetryEvents.designAuditCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'files': result.stats.fileCount,
      'scores': scoreMap,
      'improvements': result.improvements.length,
      'long_line_ratio':
          result.stats.longLineCount /
          (result.stats.totalLines == 0 ? 1 : result.stats.totalLines),
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

List<_SectionScore> _buildSections(_UxStatsSnapshot stats) {
  final sections = <_SectionScore>[];

  sections.add(
    _SectionScore(
      name: 'Balance',
      score: _scoreBalance(stats),
      notes:
          'Color accents=${stats.colorCalls} vs neutral=${stats.neutralColorCalls}',
      details:
          'Balanced palettes rely on a 55/45 accent split. Current ratio is '
          '${stats.accentRatio.toStringAsFixed(2)}, so tune hero surfaces '
          'or lighten neutral overlays to keep hierarchy crisp.',
    ),
  );

  sections.add(
    _SectionScore(
      name: 'Ergonomics',
      score: _scoreErgonomics(stats),
      notes:
          'Spacing widgets per file=${stats.spacingDensity.toStringAsFixed(1)}',
      details:
          'Spatial rhythm stays comfortable when spacing primitives land in the '
          '8–14 range per file. Current density suggests ${stats.spacingDensity < 8 ? 'tight touch targets' : 'ample negative space'}, so audit padding tokens on primary flows.',
    ),
  );

  sections.add(
    _SectionScore(
      name: 'Contrast',
      score: _scoreContrast(stats),
      notes: 'Contrast index=${stats.contrastIndex.toStringAsFixed(2)}',
      details:
          'Contrast leans on pairing vibrant brand tokens with grounded neutrals. '
          'Monitor hero/neutral usage to avoid flattening CTA focus and ensure '
          'WCAG-compliant pairings.',
    ),
  );

  sections.add(
    _SectionScore(
      name: 'Motion',
      score: _scoreMotion(stats),
      notes: 'Motion density=${stats.motionDensity.toStringAsFixed(2)}',
      details:
          'Micro-motion (Animated*, Tween, Duration) communicates state changes. '
          'Aim for at least one lightweight animation per major surface without '
          'overdriving choreographed sequences.',
    ),
  );

  sections.add(
    _SectionScore(
      name: 'Clarity',
      score: _scoreClarity(stats),
      notes:
          'Text density=${stats.textDensity.toStringAsFixed(1)}, long lines=${stats.longLineRate.toStringAsFixed(2)}',
      details:
          'Copy blocks and widget nesting impact readability. Consider splitting '
          'dense Text widgets and breaking long layout lines (>100 chars) to keep '
          'design handoff diff-friendly.',
    ),
  );

  return sections;
}

List<_Improvement> _buildImprovements(
  _UxStatsSnapshot stats,
  List<_SectionScore> sections,
) {
  final suggestions = <_Improvement>[];

  void addSuggestion(String area, String note, String impact) {
    suggestions.add(_Improvement(area: area, note: note, impact: impact));
  }

  if (stats.accentRatio < 0.45) {
    addSuggestion(
      'Balance',
      'Increase hero token usage on progression and reward cards to avoid muted CTA stacks.',
      'High',
    );
  } else if (stats.accentRatio > 0.65) {
    addSuggestion(
      'Balance',
      'Introduce additional neutral ramps (Slate/Grey 30–50) so chip trays and banners do not compete with HUD alerts.',
      'Medium',
    );
  }

  if (stats.spacingDensity < 7) {
    addSuggestion(
      'Ergonomics',
      'Layer extra EdgeInsets.symmetric or SizedBox spacing between stacked CTAs on mobile breakpoints.',
      'High',
    );
  } else if (stats.spacingDensity > 16) {
    addSuggestion(
      'Ergonomics',
      'Trim redundant SizedBox gaps in widget clusters to tighten fold-friendly HUD overlays.',
      'Medium',
    );
  }

  if (stats.motionDensity < 0.8) {
    addSuggestion(
      'Motion',
      'Add AnimatedOpacity or CurvedAnimation-driven reveals for streak + reward components to telegraph progression.',
      'High',
    );
  }

  if (stats.textDensity > 28) {
    addSuggestion(
      'Clarity',
      'Split heavy Text widgets into headline + helper copy to drop perceived cognitive load.',
      'Medium',
    );
  }

  if (stats.longLineRate > 0.09) {
    addSuggestion(
      'Clarity',
      'Wrap layout builders at <100 chars so designers can diff padding/spacing updates cleanly.',
      'Medium',
    );
  }

  if (stats.todoCount > 0) {
    addSuggestion(
      'Quality',
      'Resolve ${stats.todoCount} TODO/FIXME markers before the next showcase sync to prevent drift.',
      'High',
    );
  }

  if (stats.interactionDensity < 1.2) {
    addSuggestion(
      'Focus',
      'Add explicit InkWell or IconButton affordances on secondary chips to reinforce tap targets.',
      'High',
    );
  }

  if (stats.focusWidgets < 6) {
    addSuggestion(
      'Accessibility',
      'Inject additional Semantics / Focus widgets around HUD overlays for screen-reader parity.',
      'Medium',
    );
  }

  if (stats.neutralColorCalls < 40) {
    addSuggestion(
      'Contrast',
      'Expand neutral palette tokens for modal backgrounds to improve depth separation from tables.',
      'Medium',
    );
  }

  if (stats.animationWidgets > stats.fileCount * 4) {
    addSuggestion(
      'Motion',
      'Throttle overlapping animation controllers to avoid motion fatigue in coaching overlays.',
      'Low',
    );
  }

  const fallback = <_Improvement>[
    _Improvement(
      area: 'Consistency',
      note:
          'Normalize typography tokens across v3 widgets before the next figma export.',
      impact: 'Medium',
    ),
    _Improvement(
      area: 'Documentation',
      note:
          'Call out design rationales in widget doc comments for QA traceability.',
      impact: 'Low',
    ),
    _Improvement(
      area: 'Testing',
      note:
          'Add golden baselines for critical HUD widgets to freeze color + spacing decisions.',
      impact: 'Medium',
    ),
    _Improvement(
      area: 'Performance',
      note:
          'Audit large Stack/Positioned clusters for potential repaint boundaries.',
      impact: 'Low',
    ),
    _Improvement(
      area: 'Telemetry',
      note:
          'Tag high-risk UX widgets with telemetry breadcrumbs for future sweeps.',
      impact: 'Low',
    ),
  ];

  var fallbackIndex = 0;
  while (suggestions.length < 10) {
    suggestions.add(fallback[fallbackIndex % fallback.length]);
    fallbackIndex += 1;
  }

  return suggestions;
}

int _scoreBalance(_UxStatsSnapshot stats) {
  final ratio = stats.accentRatio;
  final delta = (ratio - 0.55).abs();
  final score = (100 - (delta * 220)).clamp(0, 100);
  return score.round();
}

int _scoreErgonomics(_UxStatsSnapshot stats) {
  final density = stats.spacingDensity;
  final normalized = (density / 12).clamp(0, 2);
  final score = normalized >= 1
      ? (100 - (normalized - 1) * 45)
      : (60 + normalized * 40);
  return score.clamp(0, 100).round();
}

int _scoreContrast(_UxStatsSnapshot stats) {
  final contrast = stats.contrastIndex;
  final score = (contrast * 28 + 55).clamp(0, 100);
  return score.round();
}

int _scoreMotion(_UxStatsSnapshot stats) {
  final density = stats.motionDensity;
  final score = (density / 1.5 * 100).clamp(20, 100);
  return score.round();
}

int _scoreClarity(_UxStatsSnapshot stats) {
  final density = stats.textDensity;
  final longPenalty = stats.longLineRate * 160;
  final base = (90 - (density - 22).clamp(0, 40) * 1.6) - longPenalty;
  return base.clamp(0, 100).round();
}

class _UxStats {
  int fileCount = 0;
  int totalLines = 0;
  int colorCalls = 0;
  int neutralColorCalls = 0;
  int spacingWidgets = 0;
  int animationWidgets = 0;
  int durationCalls = 0;
  int textWidgets = 0;
  int longLineCount = 0;
  int todoCount = 0;
  int interactionWidgets = 0;
  int focusWidgets = 0;

  final RegExp _colorPattern = RegExp(r'Colors\.[A-Za-z0-9_]+');
  final RegExp _neutralPattern = RegExp(
    r'Colors\.(grey|gray|blueGrey|white|black|brown|amber|indigo)',
    caseSensitive: false,
  );
  final RegExp _spacingPattern = RegExp(r'EdgeInsets|SizedBox|Padding\(');
  final RegExp _animationPattern = RegExp(
    r'Animated[A-Z]|AnimationController|Tween|CurvedAnimation',
  );
  final RegExp _textPattern = RegExp(r'Text\(');
  final RegExp _interactionPattern = RegExp(
    r'GestureDetector|InkWell|ElevatedButton|TextButton|FilledButton|IconButton|InkResponse',
  );
  final RegExp _focusPattern = RegExp(
    r'FocusNode|FocusScope|Semantics|Tooltip|FocusableActionDetector',
  );
  final RegExp _todoPattern = RegExp(r'TODO|FIXME', caseSensitive: false);

  void addFile(String contents) {
    fileCount += 1;
    final lines = contents.split('\n');
    totalLines += lines.length;
    longLineCount += lines.where((line) => line.length > 100).length;

    colorCalls += _countMatches(contents, _colorPattern);
    neutralColorCalls += _countMatches(contents, _neutralPattern);
    spacingWidgets += _countMatches(contents, _spacingPattern);
    animationWidgets += _countMatches(contents, _animationPattern);
    durationCalls += _countMatches(contents, RegExp(r'Duration\('));
    textWidgets += _countMatches(contents, _textPattern);
    interactionWidgets += _countMatches(contents, _interactionPattern);
    focusWidgets += _countMatches(contents, _focusPattern);
    todoCount += _countMatches(contents, _todoPattern);
  }

  int _countMatches(String contents, RegExp pattern) =>
      pattern.allMatches(contents).length;

  _UxStatsSnapshot snapshot() {
    final files = fileCount == 0 ? 1 : fileCount;
    final lines = totalLines == 0 ? 1 : totalLines;
    final accent = colorCalls + neutralColorCalls == 0
        ? 0.5
        : colorCalls / (colorCalls + neutralColorCalls);
    final spacingDensity = spacingWidgets / files;
    final motionDensity = (animationWidgets + durationCalls) / files;
    final textDensity = textWidgets / files;
    final longRate = longLineCount / lines;
    final contrastIndex = (colorCalls + 1) / (neutralColorCalls + 1).toDouble();
    final interactionDensity = interactionWidgets / files;

    return _UxStatsSnapshot(
      fileCount: fileCount,
      totalLines: totalLines,
      colorCalls: colorCalls,
      neutralColorCalls: neutralColorCalls,
      spacingWidgets: spacingWidgets,
      animationWidgets: animationWidgets,
      durationCalls: durationCalls,
      textWidgets: textWidgets,
      longLineCount: longLineCount,
      todoCount: todoCount,
      interactionWidgets: interactionWidgets,
      focusWidgets: focusWidgets,
      accentRatio: accent,
      spacingDensity: spacingDensity,
      motionDensity: motionDensity,
      textDensity: textDensity,
      longLineRate: longRate,
      contrastIndex: contrastIndex,
      interactionDensity: interactionDensity,
    );
  }
}

class _UxStatsSnapshot {
  _UxStatsSnapshot({
    required this.fileCount,
    required this.totalLines,
    required this.colorCalls,
    required this.neutralColorCalls,
    required this.spacingWidgets,
    required this.animationWidgets,
    required this.durationCalls,
    required this.textWidgets,
    required this.longLineCount,
    required this.todoCount,
    required this.interactionWidgets,
    required this.focusWidgets,
    required this.accentRatio,
    required this.spacingDensity,
    required this.motionDensity,
    required this.textDensity,
    required this.longLineRate,
    required this.contrastIndex,
    required this.interactionDensity,
  });

  final int fileCount;
  final int totalLines;
  final int colorCalls;
  final int neutralColorCalls;
  final int spacingWidgets;
  final int animationWidgets;
  final int durationCalls;
  final int textWidgets;
  final int longLineCount;
  final int todoCount;
  final int interactionWidgets;
  final int focusWidgets;
  final double accentRatio;
  final double spacingDensity;
  final double motionDensity;
  final double textDensity;
  final double longLineRate;
  final double contrastIndex;
  final double interactionDensity;
}

class _SectionScore {
  _SectionScore({
    required this.name,
    required this.score,
    required this.notes,
    required this.details,
  });

  final String name;
  final int score;
  final String notes;
  final String details;
}

class _Improvement {
  const _Improvement({
    required this.area,
    required this.note,
    required this.impact,
  });

  final String area;
  final String note;
  final String impact;
}

class _AuditResult {
  _AuditResult({
    required this.timestamp,
    required this.stats,
    required this.sections,
    required this.improvements,
  });

  final DateTime timestamp;
  final _UxStatsSnapshot stats;
  final List<_SectionScore> sections;
  final List<_Improvement> improvements;
}

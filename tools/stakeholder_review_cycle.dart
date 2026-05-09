import 'dart:io';

const _summaryPath = 'release/_reports/stakeholder_review_cycle_summary.md';

void main(List<String> args) {
  final root = Directory.current;
  final reportsDir = Directory.fromUri(root.uri.resolve('release/_reports/'));

  if (!reportsDir.existsSync()) {
    stderr.writeln('[ERROR] Missing release/_reports directory.');
    exitCode = 1;
    return;
  }

  final files =
      reportsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                (file.path.endsWith('.txt') || file.path.endsWith('.md')) &&
                !file.path.endsWith('stakeholder_review_cycle_summary.md'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('[WARN] No .txt or .md files found in release/_reports.');
  }

  final analyzer = _ReportAnalyzer(files);
  final sections = analyzer.buildSections();

  final writer = _SummaryWriter(root.uri.resolve(_summaryPath));
  writer.write(sections);

  _AsciiTablePrinter.printSummary(sections);

  final warningCount = sections.where((s) => s.entries.isEmpty).length;

  _emitTelemetry(sectionCount: sections.length, warningCount: warningCount);

  stdout.writeln('Stakeholder review summary written to $_summaryPath');
}

void _emitTelemetry({required int sectionCount, required int warningCount}) {
  final telemetryLine = StringBuffer()
    ..write('[telemetry] stakeholder_review_cycle_completed ')
    ..write('sectionCount=$sectionCount ')
    ..write('warningCount=$warningCount');
  stdout.writeln(telemetryLine.toString());
}

class _SectionDefinition {
  _SectionDefinition(this.title, this.fileKeywords, this.contentKeywords);

  final String title;
  final List<String> fileKeywords;
  final List<String> contentKeywords;

  bool matches(String fileName, String content) {
    final fileNameLower = fileName.toLowerCase();
    if (fileKeywords.any(fileNameLower.contains)) {
      return true;
    }
    final contentLower = content.toLowerCase();
    return contentKeywords.any(contentLower.contains);
  }
}

class _SectionSnapshot {
  _SectionSnapshot(this.title, this.entries);

  final String title;
  final List<_SectionEntry> entries;

  bool get isWarning => entries.isEmpty;
}

class _SectionEntry {
  _SectionEntry(this.source, this.insight);

  final String source;
  final String insight;
}

class _ReportAnalyzer {
  _ReportAnalyzer(this.files);

  final List<File> files;

  static final List<_SectionDefinition> _sections = [
    _SectionDefinition(
      'QA Health',
      ['qa', 'quality', 'stability', 'test', 'launch_readiness'],
      ['qa', 'quality', 'test', 'stability', 'defect', 'bug'],
    ),
    _SectionDefinition(
      'Governance',
      ['governance', 'archival', 'audit', 'compliance'],
      ['governance', 'policy', 'compliance', 'audit', 'owner'],
    ),
    _SectionDefinition(
      'UX Tuning',
      ['ux', 'ui', 'visual', 'polish', 'design'],
      ['ux', 'ui', 'visual', 'layout', 'design', 'experience'],
    ),
    _SectionDefinition(
      'Telemetry Trends',
      ['telemetry', 'metrics', 'drift', 'signal'],
      ['telemetry', 'metric', 'trend', 'signal', 'anomaly'],
    ),
    _SectionDefinition(
      'Next Actions',
      ['next', 'action', 'todo', 'roadmap', 'follow'],
      ['next', 'action', 'todo', 'follow-up', 'plan', 'recommendation'],
    ),
  ];

  List<_SectionSnapshot> buildSections() {
    final Map<String, List<_SectionEntry>> buckets = {
      for (final section in _sections) section.title: <_SectionEntry>[],
    };

    for (final file in files) {
      final relativePath = _relativeFrom(file.path);
      final content = _readFileSafe(file);
      for (final section in _sections) {
        if (section.matches(relativePath, content)) {
          buckets[section.title]!.add(
            _SectionEntry(relativePath, _deriveInsight(content)),
          );
        }
      }
    }

    return _sections
        .map(
          (section) => _SectionSnapshot(section.title, buckets[section.title]!),
        )
        .toList(growable: false);
  }

  String _relativeFrom(String fullPath) {
    final index = fullPath.indexOf('release/_reports');
    if (index == -1) return fullPath;
    return fullPath.substring(index);
  }

  String _readFileSafe(File file) {
    try {
      return file.readAsStringSync();
    } catch (e) {
      stderr.writeln('[WARN] Failed to read ${file.path}: $e');
      return '';
    }
  }

  String _deriveInsight(String content) {
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return 'No insights captured.';
    }

    String? candidate;
    for (final line in lines) {
      final stripped = _stripBullet(line);
      if (_looksInformative(stripped)) {
        candidate = stripped;
        break;
      }
    }

    candidate ??= _stripBullet(lines.first);

    return candidate.length > 160
        ? '${candidate.substring(0, 157)}...'
        : candidate;
  }

  String _stripBullet(String line) {
    if (line.startsWith('- ') ||
        line.startsWith('* ') ||
        line.startsWith('+ ')) {
      return line.substring(2).trimLeft();
    }
    return line;
  }

  bool _looksInformative(String line) {
    if (line.isEmpty) return false;
    if (line.startsWith('===') && line.endsWith('===')) {
      return false;
    }
    if (line.startsWith('#')) {
      return false;
    }
    final lower = line.toLowerCase();
    if (lower == 'none' || lower == 'n/a') {
      return false;
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(line)) {
      return false;
    }
    final cleaned = line.replaceAll(RegExp(r'[^0-9a-f]'), '');
    final isHash = RegExp(r'^[0-9a-f]{24,}$').hasMatch(cleaned);
    return !isHash;
  }
}

class _SummaryWriter {
  _SummaryWriter(this.summaryUri);

  final Uri summaryUri;

  void write(List<_SectionSnapshot> sections) {
    final file = File.fromUri(summaryUri);
    file.parent.createSync(recursive: true);
    final buffer = StringBuffer()
      ..writeln('# Stakeholder Review Cycle Summary')
      ..writeln()
      ..writeln('Generated on ${DateTime.now().toUtc().toIso8601String()} UTC.')
      ..writeln();

    for (final section in sections) {
      buffer
        ..writeln('## ${section.title}')
        ..writeln();
      if (section.entries.isEmpty) {
        buffer.writeln('- No signals captured from source reports.');
      } else {
        final notes = section.entries.take(5);
        for (final entry in notes) {
          buffer.writeln('- ${entry.insight} _(source: ${entry.source})_');
        }
        if (section.entries.length > 5) {
          buffer.writeln(
            '- ${section.entries.length - 5} additional signals available in source files.',
          );
        }
      }
      buffer.writeln();
    }

    file.writeAsStringSync(buffer.toString());
  }
}

class _AsciiTablePrinter {
  static void printSummary(List<_SectionSnapshot> sections) {
    const borders =
        '+-----------------------+-------+------------------------------+';
    stdout.writeln(borders);
    stdout.writeln(
      '| Section               | Flag  | Signals                      |',
    );
    stdout.writeln(borders);
    for (final section in sections) {
      final flag = section.isWarning ? 'WARN' : 'PASS';
      final signalText = section.entries.isEmpty
          ? 'No signals'
          : '${section.entries.length} sources';
      stdout.writeln(
        '| ${_pad(section.title, 21)} | ${_pad(flag, 5)} | ${_pad(signalText, 28)} |',
      );
    }
    stdout.writeln(borders);
  }

  static String _pad(String input, int width) {
    if (input.length >= width) {
      return input.substring(0, width);
    }
    return input.padRight(width);
  }
}

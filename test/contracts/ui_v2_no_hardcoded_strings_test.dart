import 'dart:io';

import 'package:test/test.dart';

const _dirsToScan = ['lib/ui_v2/settings'];

const _excludeSegments = ['.g.dart', '.freezed.dart', '.mocks.dart', '/l10n/'];

final _pattern = RegExp(
  r"""\bText(?:Span)?\s*\([^)]*?["']([^"']+)["']""",
  multiLine: true,
  dotAll: true,
);

void main() {
  test('ui_v2 screens avoid hardcoded literals', () {
    final findings = <_Finding>[];
    for (final dir in _dirsToScan) {
      final directory = Directory(dir);
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File) continue;
        final path = entity.path;
        if (!path.endsWith('.dart')) continue;
        if (_excludeSegments.any(path.contains)) continue;
        final content = entity.readAsStringSync();
        final lineStarts = _computeLineStarts(content);
        for (final match in _pattern.allMatches(content)) {
          final literal = match.group(1);
          if (literal == null ||
              _isAllowedLiteral(literal) ||
              !_shouldInspectLiteral(literal)) {
            continue;
          }
          final contextSnippet = _contextAround(
            content,
            match.start,
            match.end,
          );
          if (_shouldIgnoreContext(contextSnippet)) continue;
          final line = _lineNumberAt(lineStarts, match.start);
          findings.add(_Finding(path, line, literal.trim()));
        }
      }
    }

    if (findings.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Hardcoded text detected in UI v2:')
        ..writeln('Use AppLocalizations instead of literal strings.');
      for (final finding in findings) {
        buffer.writeln(
          '- ${finding.path}:${finding.line} → "${finding.literal}"',
        );
      }
      buffer
        ..writeln()
        ..writeln('Total hardcoded literals: ${findings.length}');
      fail(buffer.toString());
    }
  });
}

class _Finding {
  const _Finding(this.path, this.line, this.literal);

  final String path;
  final int line;
  final String literal;
}

bool _isAllowedLiteral(String literal) {
  final trimmed = literal.trim();
  if (trimmed.isEmpty) return true;
  final punctuation = RegExp(r'^[0-9\s.,:;!?—…()"-]+$');
  return punctuation.hasMatch(trimmed);
}

bool _shouldInspectLiteral(String literal) {
  final trimmed = literal.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.length < 8) return false;
  final words = trimmed.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  return words.length >= 2 && RegExp(r'[A-Za-z]').hasMatch(trimmed);
}

List<int> _computeLineStarts(String content) {
  final starts = <int>[0];
  for (var i = 0; i < content.length; i++) {
    if (content[i] == '\n') {
      starts.add(i + 1);
    }
  }
  return starts;
}

int _lineNumberAt(List<int> starts, int index) {
  for (var i = starts.length - 1; i >= 0; i--) {
    if (starts[i] <= index) return i + 1;
  }
  return 1;
}

String _contextAround(String content, int start, int end) {
  final begin = (start - 40).clamp(0, content.length);
  final finish = (end + 40).clamp(0, content.length);
  return content.substring(begin, finish).toLowerCase();
}

bool _shouldIgnoreContext(String snippet) {
  return snippet.contains('assert(') || snippet.contains('kdebugmode');
}

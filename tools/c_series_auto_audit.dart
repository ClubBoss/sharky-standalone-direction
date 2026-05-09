import 'dart:convert';

import 'utils/c_series_rules.dart';

class CSeriesAuditResult {
  CSeriesAuditResult({
    required this.pass,
    required this.fixes,
    required this.files,
  });

  final bool pass;
  final List<String> fixes;
  final Map<String, String> files;
}

class CSeriesAutoAudit {
  const CSeriesAutoAudit();

  CSeriesAuditResult auditAndFix(Map<String, String> files) {
    var current = Map<String, String>.from(files);
    final prefix = _detectPrefix(current);
    final fixes = <String>[];
    var pass = false;
    for (var i = 0; i < 3; i++) {
      final issues = _validate(current, prefix);
      if (issues.isEmpty) {
        pass = true;
        break;
      }
      fixes.addAll(issues.map((e) => 'cycle ${i + 1}: $e'));
      current = _selfCorrect(current, prefix);
    }
    if (!pass && _validate(current, prefix).isEmpty) {
      pass = true;
    }
    return CSeriesAuditResult(pass: pass, fixes: fixes, files: current);
  }

  List<String> _validate(Map<String, String> files, String prefix) {
    final issues = <String>[];
    files.forEach((name, content) {
      if (!_isAscii(content)) issues.add('$name: non-ascii detected');
    });
    _validateTheory(files['theory.md'], issues);
    _validateRecap(files['recap.md'], issues);
    _validateJsonl(
      files['demos.jsonl'],
      '$prefix:demo:',
      issues,
      minCount: CSeriesRules.demosMin,
      maxCount: CSeriesRules.demosMax,
    );
    _validateJsonl(
      files['drills.jsonl'],
      '$prefix:drill:',
      issues,
      allowedActions: CSeriesRules.actions,
      minCount: CSeriesRules.drillsMin,
      maxCount: CSeriesRules.drillsMax,
      actionField: 'target_action',
    );
    _validateQuiz(files['quiz.jsonl'], prefix, issues);
    _validateMicro(files['micro_quiz.jsonl'], prefix, issues);
    _validateAllowlist(files['allowlist.txt'], issues);
    return issues;
  }

  Map<String, String> _selfCorrect(Map<String, String> files, String prefix) {
    final next = Map<String, String>.from(files);
    next['theory.md'] = _fixWordBounds(
      files['theory.md'] ?? '',
      CSeriesRules.theoryMinWords,
      CSeriesRules.theoryMaxWords,
    );
    next['theory.md'] = _ensurePlaceholder(next['theory.md']!, prefix);
    next['theory.md'] = _stripBanned(next['theory.md']!);
    next['recap.md'] = _fixWordBounds(
      files['recap.md'] ?? '',
      CSeriesRules.recapMinWords,
      CSeriesRules.recapMaxWords,
    );
    if (files.containsKey('demos.jsonl')) {
      final adjusted = _fixIds(files['demos.jsonl']!, '$prefix:demo:');
      next['demos.jsonl'] = _fixRationaleLengths(adjusted);
    }
    if (files.containsKey('drills.jsonl')) {
      final adjusted = _fixIds(files['drills.jsonl']!, '$prefix:drill:');
      next['drills.jsonl'] = _fixRationaleLengths(adjusted);
    }
    if (files.containsKey('quiz.jsonl')) {
      final adjusted = _fixIds(files['quiz.jsonl']!, '$prefix:quiz:');
      next['quiz.jsonl'] = _fixQuiz(adjusted);
    }
    if (files.containsKey('micro_quiz.jsonl')) {
      next['micro_quiz.jsonl'] = _fixMicro(
        files['micro_quiz.jsonl']!,
        '$prefix:micro:',
      );
    }
    if (files.containsKey('allowlist.txt')) {
      next['allowlist.txt'] = _mergeAllowlist(files['allowlist.txt']!);
    }
    return next;
  }

  void _validateTheory(String? content, List<String> issues) {
    if (content == null) {
      issues.add('theory.md missing');
      return;
    }
    final wc = _wordCount(content);
    if (wc < CSeriesRules.theoryMinWords || wc > CSeriesRules.theoryMaxWords) {
      issues.add('theory.md word count $wc outside bounds');
    }
    final matches = CSeriesRules.imagePlaceholder.allMatches(content);
    if (matches.isEmpty) issues.add('theory.md missing image placeholder');
    if (!CSeriesRules.positions.any((p) => content.contains(p))) {
      issues.add('theory.md missing positions');
    }
    if (!content.toLowerCase().contains('gto')) {
      issues.add('theory.md missing GTO contrast');
    }
    for (final banned in CSeriesRules.bannedJargon) {
      if (content.toLowerCase().contains(banned.toLowerCase())) {
        issues.add('theory.md contains banned term $banned');
      }
    }
  }

  void _validateRecap(String? content, List<String> issues) {
    if (content == null) {
      issues.add('recap.md missing');
      return;
    }
    final wc = _wordCount(content);
    if (wc < CSeriesRules.recapMinWords || wc > CSeriesRules.recapMaxWords) {
      issues.add('recap.md word count $wc outside bounds');
    }
  }

  void _validateJsonl(
    String? content,
    String idPrefix,
    List<String> issues, {
    List<String>? allowedActions,
    int? minCount,
    int? maxCount,
    String actionField = 'answer',
  }) {
    if (content == null) {
      issues.add('$idPrefix missing file');
      return;
    }
    final lines = content
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (minCount != null && lines.length < minCount) {
      issues.add('$idPrefix count below $minCount');
    }
    if (maxCount != null && lines.length > maxCount) {
      issues.add('$idPrefix count above $maxCount');
    }
    for (var i = 0; i < lines.length; i++) {
      try {
        final obj = json.decode(lines[i]);
        final id = obj['id']?.toString() ?? '';
        final target = '$idPrefix${(i + 1).toString().padLeft(2, '0')}';
        if (id != target) {
          issues.add('id mismatch at line ${i + 1} expected $target');
        }
        if (obj.containsKey('rationale')) {
          final rat = obj['rationale']?.toString() ?? '';
          if (rat.length > CSeriesRules.rationaleMax) {
            issues.add('rationale too long at $id');
          }
        }
        if (allowedActions != null && obj.containsKey(actionField)) {
          final ans = obj[actionField]?.toString();
          if (!allowedActions.contains(ans)) {
            issues.add('action $ans not allowed at $id');
          }
        }
      } catch (_) {
        issues.add('invalid json at line ${i + 1}');
      }
    }
  }

  void _validateQuiz(String? content, String prefix, List<String> issues) {
    if (content == null) {
      issues.add('quiz.jsonl missing');
      return;
    }
    final lines = content
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.length < CSeriesRules.quizMin) {
      issues.add('quiz count below ${CSeriesRules.quizMin}');
    }
    if (lines.length > CSeriesRules.quizMax) {
      issues.add('quiz count above ${CSeriesRules.quizMax}');
    }
    for (var i = 0; i < lines.length; i++) {
      final target = '$prefix:quiz:${(i + 1).toString().padLeft(2, '0')}';
      try {
        final obj = json.decode(lines[i]);
        if (obj['id'] != target) issues.add('quiz id mismatch $target');
        final type = obj['type'];
        if (type != 'mc' && type != 'tf') issues.add('$target type invalid');
        final exp = obj['explanation']?.toString() ?? '';
        if (exp.length > CSeriesRules.explanationMax) {
          issues.add('$target explanation too long');
        }
        if (type == 'mc') {
          final opts = obj['options'];
          if (opts is! List || opts.isEmpty) {
            issues.add('$target missing options');
          }
          if (obj['answer'] is! int) {
            issues.add('$target mc answer index invalid');
          }
        } else {
          if (obj['answer'] is! bool) issues.add('$target tf answer invalid');
        }
      } catch (_) {
        issues.add('quiz invalid json at line ${i + 1}');
      }
    }
  }

  void _validateMicro(String? content, String prefix, List<String> issues) {
    if (content == null) {
      issues.add('micro_quiz.jsonl missing');
      return;
    }
    final lines = content
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.length < CSeriesRules.microMin ||
        lines.length > CSeriesRules.microMax) {
      issues.add('micro quiz count invalid');
    }
    for (var i = 0; i < lines.length; i++) {
      final target = '$prefix:micro:${(i + 1).toString().padLeft(2, '0')}';
      try {
        final obj = json.decode(lines[i]);
        if (obj['id'] != target) issues.add('micro id mismatch $target');
        final prompt = obj['prompt']?.toString() ?? '';
        if (prompt.length > CSeriesRules.promptMax) {
          issues.add('$target prompt too long');
        }
        final opts = obj['options'];
        if (opts is! List || opts.length < 2) {
          issues.add('$target options invalid');
        }
        if (opts is List) {
          for (final o in opts) {
            if (o.toString().length > CSeriesRules.optionMax) {
              issues.add('$target option too long');
            }
          }
        }
        final exp = obj['explanation']?.toString() ?? '';
        if (exp.length > CSeriesRules.explanationMax) {
          issues.add('$target explanation too long');
        }
        if (obj['answer'] is! int) issues.add('$target answer index invalid');
      } catch (_) {
        issues.add('micro invalid json at line ${i + 1}');
      }
    }
  }

  void _validateAllowlist(String? content, List<String> issues) {
    if (content == null) {
      issues.add('allowlist missing');
      return;
    }
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toSet();
    for (final pos in CSeriesRules.positions) {
      if (!lines.contains(pos)) issues.add('allowlist missing $pos');
    }
    for (final act in CSeriesRules.actions) {
      if (!lines.contains(act)) issues.add('allowlist missing $act');
    }
  }

  String _fixWordBounds(String content, int min, int max) {
    final words = content.split(RegExp(r'\s+'));
    if (words.length > max) {
      return words.take(max).join(' ');
    }
    if (words.length < min) {
      final filler = List<String>.filled(min - words.length, 'filler');
      return (words + filler).join(' ');
    }
    return content;
  }

  String _fixRationaleLengths(String jsonl) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        if (obj.containsKey('rationale')) {
          var rat = obj['rationale']?.toString() ?? '';
          if (rat.length > CSeriesRules.rationaleMax) {
            rat = rat.substring(0, CSeriesRules.rationaleMax);
            obj['rationale'] = rat;
          }
        }
        buffer.writeln(json.encode(obj));
      } catch (_) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trim();
  }

  String _fixQuiz(String jsonl) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        final exp = obj['explanation']?.toString() ?? '';
        if (exp.length > CSeriesRules.explanationMax) {
          obj['explanation'] = exp.substring(0, CSeriesRules.explanationMax);
        }
        buffer.writeln(json.encode(obj));
      } catch (_) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trim();
  }

  String _fixMicro(String jsonl, String prefix) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    var index = 1;
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        obj['id'] = '$prefix${index.toString().padLeft(2, '0')}';
        final prompt = obj['prompt']?.toString() ?? '';
        if (prompt.length > CSeriesRules.promptMax) {
          obj['prompt'] = prompt.substring(0, CSeriesRules.promptMax);
        }
        final opts = obj['options'];
        if (opts is List) {
          final trimmed = opts
              .map(
                (o) => o.toString().length > CSeriesRules.optionMax
                    ? o.toString().substring(0, CSeriesRules.optionMax)
                    : o.toString(),
              )
              .toList();
          obj['options'] = trimmed;
        }
        final exp = obj['explanation']?.toString() ?? '';
        if (exp.length > CSeriesRules.explanationMax) {
          obj['explanation'] = exp.substring(0, CSeriesRules.explanationMax);
        }
        buffer.writeln(json.encode(obj));
        index++;
      } catch (_) {
        buffer.writeln(line);
        index++;
      }
    }
    return buffer.toString().trim();
  }

  String _mergeAllowlist(String content) {
    final set = content.split('\n').where((e) => e.trim().isNotEmpty).toSet();
    set.addAll(CSeriesRules.positions);
    set.addAll(CSeriesRules.actions);
    return (set.toList()..sort()).join('\n');
  }

  String _fixIds(String jsonl, String prefix) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    var index = 1;
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        obj['id'] = '$prefix${index.toString().padLeft(2, '0')}';
        buffer.writeln(json.encode(obj));
      } catch (_) {
        buffer.writeln(line);
      }
      index++;
    }
    return buffer.toString().trim();
  }

  String _ensurePlaceholder(String content, String prefix) {
    if (CSeriesRules.imagePlaceholder.hasMatch(content)) return content;
    final placeholder = '[[IMAGE: ${prefix}_img | placeholder]]';
    return '$content\n\n$placeholder';
  }

  String _stripBanned(String content) {
    var output = content;
    for (final banned in CSeriesRules.bannedJargon) {
      output = output.replaceAll(RegExp(banned, caseSensitive: false), '');
    }
    return output;
  }

  String _detectPrefix(Map<String, String> files) {
    final sources = [
      files['demos.jsonl'],
      files['drills.jsonl'],
      files['quiz.jsonl'],
      files['micro_quiz.jsonl'],
    ];
    for (final src in sources) {
      if (src == null) continue;
      for (final line in src.split('\n')) {
        if (line.trim().isEmpty) continue;
        try {
          final obj = json.decode(line);
          final id = obj['id']?.toString() ?? '';
          final parts = id.split(':');
          if (parts.isNotEmpty && parts.first.isNotEmpty) {
            return parts.first;
          }
        } catch (_) {
          continue;
        }
      }
    }
    return 'cxx';
  }

  bool _isAscii(String input) {
    for (final codeUnit in input.codeUnits) {
      if (codeUnit > 127) return false;
    }
    return true;
  }

  int _wordCount(String text) {
    return RegExp(r'\b\w+\b').allMatches(text).length;
  }
}

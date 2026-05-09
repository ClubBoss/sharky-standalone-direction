import 'dart:convert';

class CSeriesTapExplainTransformer {
  const CSeriesTapExplainTransformer();

  Map<String, String> transform(Map<String, String> files) {
    final allowlist = files['allowlist.txt'] ?? '';
    final tokens = _tokensFromAllowlist(allowlist);
    final explain = _buildExplanation(tokens);
    final next = Map<String, String>.from(files);
    next['theory.md'] = _injectTheory(files['theory.md'] ?? '', explain);
    next['drills.jsonl'] = _injectDrills(files['drills.jsonl'] ?? '', explain);
    next['quiz.jsonl'] = _injectQuiz(files['quiz.jsonl'] ?? '', explain);
    next['micro_quiz.jsonl'] = _injectMicro(
      files['micro_quiz.jsonl'] ?? '',
      explain,
    );
    return next;
  }

  List<String> _tokensFromAllowlist(String content) {
    final lines =
        content
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return lines.take(6).toList();
  }

  String _buildExplanation(List<String> tokens) {
    final joined = tokens.join(', ');
    var exp = 'Note: focus on $joined.';
    if (exp.length > 90) exp = exp.substring(0, 90);
    return exp;
  }

  String _injectTheory(String content, String exp) {
    final lines = content.split('\n');
    final out = <String>[];
    for (final line in lines) {
      out.add(line);
      if (line.startsWith('[[IMAGE:')) {
        out.add(exp);
      }
    }
    return out.join('\n');
  }

  String _injectDrills(String jsonl, String exp) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        final rat = obj['rationale']?.toString() ?? '';
        obj['rationale'] = rat.isEmpty ? exp : '$rat — $exp';
        buffer.writeln(json.encode(obj));
      } catch (_) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trim();
  }

  String _injectQuiz(String jsonl, String exp) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        final base = obj['explanation']?.toString() ?? '';
        obj['explanation'] = base.isEmpty ? exp : '$base — $exp';
        buffer.writeln(json.encode(obj));
      } catch (_) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trim();
  }

  String _injectMicro(String jsonl, String exp) {
    final buffer = StringBuffer();
    final lines = jsonl.split('\n').where((l) => l.trim().isNotEmpty);
    for (final line in lines) {
      try {
        final obj = json.decode(line) as Map<String, dynamic>;
        final base = obj['explanation']?.toString() ?? '';
        obj['explanation'] = base.isEmpty ? exp : '$base — $exp';
        buffer.writeln(json.encode(obj));
      } catch (_) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trim();
  }
}

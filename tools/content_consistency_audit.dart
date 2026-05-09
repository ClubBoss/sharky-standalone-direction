import 'dart:convert';
import 'dart:io';

const _stopwords = {
  'the',
  'and',
  'a',
  'an',
  'of',
  'to',
  'in',
  'for',
  'on',
  'with',
  'that',
  'is',
  'by',
  'from',
  'as',
  'at',
  'it',
};

void main() {
  final root = Directory('content');
  if (!root.existsSync()) return;
  final modules = <String, Directory>{};
  for (final dir in root.listSync(recursive: true).whereType<Directory>()) {
    if (dir.path.endsWith('${Platform.pathSeparator}v1')) {
      final moduleId = dir.parent.path.split(Platform.pathSeparator).last;
      modules[moduleId] = dir;
    }
  }
  final buffer = StringBuffer();
  buffer.writeln('module | coverage | mismatch | alignmentIndex');
  for (final entry in modules.entries) {
    final module = entry.key;
    final dir = entry.value;
    final theory = File('${dir.path}${Platform.pathSeparator}theory.md');
    if (!theory.existsSync()) continue;
    final theoryTokens = _extractTokens(theory.readAsStringSync());
    final topTokens = theoryTokens.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSet = topTokens.take(20).map((e) => e.key).toSet();
    final jsonFiles = ['drills.jsonl', 'demos.jsonl', 'quiz.jsonl'];
    var total = 0;
    var coverageCount = 0;
    var mismatchCount = 0;
    for (final name in jsonFiles) {
      final file = File('${dir.path}${Platform.pathSeparator}$name');
      if (!file.existsSync()) continue;
      for (final line in file.readAsLinesSync()) {
        if (line.trim().isEmpty) continue;
        Map<String, dynamic> data;
        try {
          data = json.decode(line);
        } catch (_) {
          continue;
        }
        total++;
        final text = <String>[];
        if (data['label'] != null) text.add(data['label'].toString());
        if (data['decision'] != null) text.add(data['decision'].toString());
        if (data['tags'] is Iterable) {
          text.addAll(
            (data['tags'] as Iterable).map((e) => e.toString()).toList(),
          );
        }
        final words = _textTokens(text.join(' '));
        final hits = words.where(topSet.contains).toSet();
        if (hits.isNotEmpty) coverageCount++;
        final mismatched = words.where((w) => !topSet.contains(w)).isNotEmpty;
        if (mismatched) mismatchCount++;
      }
    }
    if (total == 0) {
      buffer.writeln('$module | n/a | n/a | n/a');
      continue;
    }
    final coverage = coverageCount / total;
    final mismatch = mismatchCount / total;
    final alignment = (coverage * 0.7 + (1 - mismatch) * 0.3);
    buffer.writeln(
      '$module | ${coverage.toStringAsFixed(2)} | ${mismatch.toStringAsFixed(2)} | ${alignment.toStringAsFixed(2)}',
    );
  }
  final out = File('release/_reports/content_consistency_audit.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

Map<String, int> _extractTokens(String src) {
  final tokens = <String, int>{};
  for (final word in _textTokens(src)) {
    tokens[word] = (tokens[word] ?? 0) + 1;
  }
  return tokens;
}

Iterable<String> _textTokens(String text) sync* {
  final lower = text.toLowerCase();
  final words = lower.split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty);
  for (final word in words) {
    if (_stopwords.contains(word)) continue;
    yield word;
  }
}

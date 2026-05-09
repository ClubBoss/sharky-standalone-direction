import 'dart:convert';

import 'c_series_rules.dart';

class CSeriesGeneratorUtils {
  static Map<String, String> seedModule(String id, String spec) {
    final words = spec
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final theme = words.take(6).join(' ');
    return {
      'theory.md': _buildTheory(theme),
      'demos.jsonl': _buildDemos(),
      'drills.jsonl': _buildDrills(),
      'quiz.jsonl': _buildQuiz(),
      'recap.md': _buildRecap(theme),
      'allowlist.txt': _buildAllowlist(),
      'micro_quiz.jsonl': _buildMicro(),
    };
  }

  static String _buildTheory(String theme) {
    final body = List.filled(CSeriesRules.theoryMinWords, 'content').join(' ');
    const placeholder = '[[IMAGE: concept | description]]';
    return 'Theory $theme\n$placeholder\n$body';
  }

  static String _buildRecap(String theme) {
    final body = List.filled(CSeriesRules.recapMinWords, 'recap').join(' ');
    return 'Recap $theme\n$body';
  }

  static String _buildDemos() {
    final demo1 = {
      'id': 'c13:demo:01',
      'question': 'Demo one',
      'steps': ['step1', 'step2'],
      'rationale': 'short rationale',
    };
    final demo2 = {
      'id': 'c13:demo:02',
      'question': 'Demo two',
      'steps': ['step1', 'step2'],
      'rationale': 'short rationale',
    };
    return '${json.encode(demo1)}\n${json.encode(demo2)}';
  }

  static String _buildDrills() {
    final lines = <String>[];
    for (var i = 1; i <= 12; i++) {
      final obj = {
        'id': 'c13:drill:${i.toString().padLeft(2, '0')}',
        'prompt': 'drill $i',
        'options': CSeriesRules.actions.take(4).toList(),
        'answer': CSeriesRules.actions.first,
        'rationale': 'short rat',
      };
      lines.add(json.encode(obj));
    }
    return lines.join('\n');
  }

  static String _buildQuiz() {
    final items = <String>[];
    for (var i = 1; i <= 6; i++) {
      items.add(
        json.encode({
          'id': 'c13:quiz:${i.toString().padLeft(2, '0')}',
          'type': i.isEven ? 'tf' : 'mc',
          'prompt': 'quiz $i',
          'options': i.isEven ? null : ['a', 'b', 'c'],
          'answer': i.isEven ? true : 0,
          'explanation': 'short exp',
        }),
      );
    }
    return items.join('\n');
  }

  static String _buildMicro() {
    final items = <String>[];
    for (var i = 1; i <= 10; i++) {
      items.add(
        json.encode({
          'id': 'c13:micro:${i.toString().padLeft(2, '0')}',
          'type': 'mc',
          'prompt': 'micro $i',
          'options': ['a', 'b'],
          'answer': 0,
          'explanation': 'short exp',
        }),
      );
    }
    return items.join('\n');
  }

  static String _buildAllowlist() {
    final set = {...CSeriesRules.positions, ...CSeriesRules.actions};
    return set.join('\n');
  }
}

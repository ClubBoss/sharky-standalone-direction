import 'dart:convert';
import 'dart:io';

const _allowList = [
  'lib/ui_v2/screens/theory_session_screen.dart',
  'lib/ui_v2/screens/drill_runner_screen.dart',
  'lib/ui_v2/screens/session_result_screen.dart',
  'lib/ui_v2/screens/phase2_runner_screen.dart',
  'lib/ui_v2/screens/phase3_runner_screen.dart',
  'lib/ui_v2/screens/action_order_btn_last_screen.dart',
];

void main() {
  final offending = <String>{};
  for (final path in _allowList) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final content = file.readAsStringSync();
    final safeAreaMatches = RegExp(r'SafeArea\s*\(').allMatches(content);
    for (final match in safeAreaMatches) {
      final start = content.indexOf('(', match.end - 1);
      if (start == -1) continue;
      final section = _extractSection(content, start);
      if (!section.contains(RegExp(r'\bbottom\s*:\s*false\b'))) {
        offending.add(path);
        break;
      }
    }
  }

  final result = {
    'event': 'REGRESSION_INSET_GUARD',
    'result': offending.isEmpty ? 'pass' : 'fail',
    'offending': offending.toList(),
  };
  stdout.writeln(jsonEncode(result));
  if (offending.isNotEmpty) {
    stderr.writeln(
      'Inset guard failure: SafeArea must opt-out of bottom insets for ${offending.join(', ')}',
    );
    exit(1);
  }
}

String _extractSection(String content, int start) {
  var depth = 0;
  final buffer = StringBuffer();
  for (var i = start; i < content.length; i++) {
    final char = content[i];
    if (char == '(') depth++;
    if (char == ')') depth--;
    buffer.write(char);
    if (depth == 0) break;
  }
  return buffer.toString();
}

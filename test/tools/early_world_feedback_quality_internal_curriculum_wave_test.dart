import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'internal-curriculum corrective feedback in the admitted early-world subset stays poker-reasoned',
    () {
      final repoRoot = Directory.current.path;
      final file = File(
        '$repoRoot/content/worlds/world3/v1/sessions/w3.s03/drills/d.choose_call_preflop_checkpoint_v1.json',
      );
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final feedback = json['feedback_incorrect_v1'] as String;

      expect(feedback, contains('in-position call'));
      expect(feedback, contains('playable broadway hand'));
      expect(feedback, contains('without bloating it'));
      expect(feedback, contains('stronger opening ranges'));

      expect(feedback, isNot(contains('checkpoint wants')));
      expect(feedback, isNot(contains('World 3 checkpoint')));
      expect(feedback, isNot(contains('lesson')));
    },
  );
}

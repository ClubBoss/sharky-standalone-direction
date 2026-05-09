import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'world10 w10.s01 corrective feedback stays learner-facing and not curriculum-labeled',
    () {
      final repoRoot = Directory.current.path;
      final files = <String>[
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_call_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_raise_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.find_role_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.find_seat_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.tap_flop_left_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.tap_hole_left_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.tap_turn_track_baseline.json',
        'content/worlds/world10/v1/sessions/w10.s01/drills/d.tap_river_track_baseline.json',
      ];

      for (final relativePath in files) {
        final file = File('$repoRoot/$relativePath');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_incorrect_v1'] as String;

        expect(feedback, startsWith('Incorrect.'));
        final lower = feedback.toLowerCase();
        expect(lower, isNot(contains('baseline track')));
        expect(lower, isNot(contains('track read')));
        expect(lower, isNot(contains('track decision')));
        expect(lower, isNot(contains('track sequence')));
        expect(lower, isNot(contains('track-based')));
        expect(lower, isNot(contains('lesson')));
        expect(lower, isNot(contains('curriculum')));
      }

      expect(_feedbackFor(repoRoot, files[0]), contains('controlled continue'));
      expect(
        _feedbackFor(repoRoot, files[1]),
        contains('second cue confirms more pressure'),
      );
      expect(_feedbackFor(repoRoot, files[2]), contains('button'));
      expect(_feedbackFor(repoRoot, files[3]), contains('seat S1'));
      expect(_feedbackFor(repoRoot, files[4]), contains('left flop card'));
      expect(_feedbackFor(repoRoot, files[5]), contains('ace of spades'));
      expect(
        _feedbackFor(repoRoot, files[6]),
        contains('pressure cue changes'),
      );
      expect(_feedbackFor(repoRoot, files[7]), contains('river'));
    },
  );
}

String _feedbackFor(String repoRoot, String relativePath) {
  final file = File('$repoRoot/$relativePath');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json['feedback_incorrect_v1'] as String;
}

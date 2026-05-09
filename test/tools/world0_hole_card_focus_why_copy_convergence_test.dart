import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s07/drills/d.tap_hole_right_focus.json',
    'content/worlds/world0/v1/sessions/w0.s08/drills/d.tap_hole_left_focus.json',
    'content/worlds/world0/v1/sessions/w0.s09/drills/d.tap_hole_right_focus.json',
  ];

  test('World 0 mixed-focus hole-card why_v1 copy no longer uses the generic template', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync();
      expect(
        content.contains('This drill checks whether the learner can keep the hole-card anchor stable inside the mixed focus reps.'),
        isFalse,
        reason: path,
      );
    }

    expect(
      File('content/worlds/world0/v1/sessions/w0.s08/drills/d.tap_hole_left_focus.json')
          .readAsStringSync()
          .contains('big blind side'),
      isTrue,
    );
    expect(
      File('content/worlds/world0/v1/sessions/w0.s09/drills/d.tap_hole_right_focus.json')
          .readAsStringSync()
          .contains('small blind side'),
      isTrue,
    );
  });

  test('validator no longer reports generic World 0 mixed-focus hole-card why_v1 failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('world0_drill_why_generic_hole_card_focus_copy_leak_v1'),
      isFalse,
      reason: combined,
    );
  });
}

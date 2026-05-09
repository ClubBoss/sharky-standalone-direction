import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s07/drills/d.find_btn_focus.json',
    'content/worlds/world0/v1/sessions/w0.s08/drills/d.find_bb_focus.json',
    'content/worlds/world0/v1/sessions/w0.s09/drills/d.find_sb_focus.json',
    'content/worlds/world0/v1/sessions/w0.s10/drills/d.find_btn_focus.json',
  ];

  test('World 0 focus seat-tap why_v1 copy no longer uses the generic seat-context template', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync();
      expect(
        content.contains('This drill checks seat context before action selection.'),
        isFalse,
        reason: path,
      );
    }

    expect(
      File('content/worlds/world0/v1/sessions/w0.s08/drills/d.find_bb_focus.json')
          .readAsStringSync()
          .contains('big blind seat'),
      isTrue,
    );
    expect(
      File('content/worlds/world0/v1/sessions/w0.s10/drills/d.find_btn_focus.json')
          .readAsStringSync()
          .contains('final World 0 checkpoint set'),
      isTrue,
    );
  });

  test('validator no longer reports generic World 0 seat-context why_v1 failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('world0_drill_why_generic_seat_context_copy_leak_v1'),
      isFalse,
      reason: combined,
    );
  });
}

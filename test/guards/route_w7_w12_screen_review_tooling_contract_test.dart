import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route W7-W12 screen-review lane is registered end-to-end', () {
    final shell = File('tools/screen_review_fast_v1.sh').readAsStringSync();
    final capture = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();
    final packager = File(
      'tools/package_screen_review_v1.py',
    ).readAsStringSync();

    expect(shell, contains('route_w7_w12'));
    expect(capture, contains("'route_w7_w12'"));
    expect(packager, contains('"route_w7_w12_fast"'));

    for (final surface in <String>[
      'w7_first_route_task',
      'w8_first_route_task',
      'w9_first_route_task',
      'w10_first_route_task',
      'w11_danger_texture_task',
      'w12_first_review_task',
      'w12_payoff_completion',
      'volume_i_terminal_review',
      'no_w13_terminal_state',
    ]) {
      expect(capture, contains(surface), reason: surface);
      expect(packager, contains(surface), reason: surface);
    }

    for (final packId in <String>[
      'world7_spine_campaign_v1',
      'world8_spine_campaign_v1',
      'world9_spine_campaign_v1',
      'world10_spine_campaign_v1',
      'world11_spine_campaign_v1',
      'world12_spine_campaign_v1',
      'volume_i_terminal_review_v1',
    ]) {
      expect(capture, contains(packId), reason: packId);
    }
  });
}

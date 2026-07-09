import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compact first decision reserves visible actionability', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave1b_actionability_anchor'));
    expect(source, contains('act0_shell_wave1b_answer_peek'));
    expect(source, contains('_runnerEnvelopeWave1bMinLowerSlotHeightV1'));
  });

  test('table signal is refined without reverting to tiny metadata', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave1b_table_signal_chip'));
    expect(source, contains('act0_shell_wave1b_status_lane'));
    expect(source, contains('act0_shell_wave1b_table_signal_text'));
    expect(source, isNot(contains('big educational banner')));
  });

  test(
    'feedback bridge is evidence-weighted rather than another label row',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      ).readAsStringSync();

      expect(source, contains('act0_shell_wave1b_feedback_evidence_bridge'));
      expect(source, contains('Table evidence'));
      expect(source, isNot(contains('Clue from table')));
    },
  );

  test(
    'hero and button markers keep poker meaning with polished treatment',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      ).readAsStringSync();

      expect(source, contains('act0_shell_wave1b_hero_badge'));
      expect(source, contains('act0_shell_wave1b_button_marker'));
      expect(source, contains('BTN'));
    },
  );

  test('wave1b visual pack builder names the required evidence output', () {
    final script = File(
      'tools/build_real_text_visual_pack_wave1b_table_signal_refinement_v1.py',
    );
    expect(script.existsSync(), isTrue);

    final source = script.readAsStringSync();
    expect(
      source,
      contains('real_text_visual_pack_wave1b_table_signal_refinement_v1'),
    );
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_visible_contact_sheet.png'));
    expect(source, contains('wave1b_table_signal_refinement_v1.md'));
  });
}

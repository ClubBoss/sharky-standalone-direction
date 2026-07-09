import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('table owns primary signal hierarchy for the first decision read', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave1_status_cluster'));
    expect(source, contains('act0_shell_wave1_table_signal_anchor'));
    expect(source, contains('act0_shell_wave1_pot_priority_stat'));
    expect(source, contains('act0_shell_wave1_price_priority_stat'));
    expect(source, contains('Table clue'));
  });

  test('seat artifacts identify Hero, BTN, and blinds as poker signals', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave1_hero_you_badge'));
    expect(source, contains('act0_shell_wave1_dealer_marker'));
    expect(source, contains('act0_shell_wave1_blind_marker'));
    expect(source, contains('BTN'));
  });

  test('feedback visually bridges back to the table clue', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave1_feedback_signal_bridge'));
    expect(source, contains('Table evidence'));
  });

  test('wave1 visual pack builder names the required evidence output', () {
    final script = File(
      'tools/build_real_text_visual_pack_wave1_table_signal_v1.py',
    );
    expect(script.existsSync(), isTrue);

    final source = script.readAsStringSync();
    expect(source, contains('real_text_visual_pack_wave1_table_signal_v1'));
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_visible_contact_sheet.png'));
    expect(source, contains('wave1_table_signal_first_decision_v1.md'));
  });
}

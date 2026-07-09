import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feedback states expose distinct wave2 semantic anchors', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave2_feedback_correct_state'));
    expect(source, contains('act0_shell_wave2_feedback_miss_state'));
    expect(source, contains('act0_shell_wave2_feedback_repair_state'));
    expect(source, contains('act0_shell_wave2_feedback_proof_earned_state'));
    expect(source, contains('act0_shell_wave2_feedback_state_rail'));
  });

  test('feedback bridge and labels reduce proof vocabulary overload', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_wave2_feedback_evidence_bridge'));
    expect(source, contains('Clue from table'));
    expect(source, contains('Result'));
    expect(source, contains('Repair landed'));
    expect(source, contains('Session result'));
    expect(source, contains('Collected read'));
    expect(source, contains('Local read saved'));
    expect(source, isNot(contains('Proof confirmed')));
    expect(source, isNot(contains('Repair proof')));
    expect(source, isNot(contains('Session repair')));
    expect(source, isNot(contains('Proof banked')));
    expect(source, isNot(contains('Session proof')));
    expect(source, isNot(contains('Collected proof')));
    expect(source, isNot(contains('Local proof saved')));
  });

  test('review and practice foreground current clue without fake data', () {
    final reviewSource = File(
      'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
    ).readAsStringSync();
    final previewSource = File(
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
    ).readAsStringSync();
    final playSource = File(
      'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
    ).readAsStringSync();

    expect(
      reviewSource,
      contains('act0_shell_wave2_review_active_clue_preview'),
    );
    expect(reviewSource, contains('Current clue'));
    expect(reviewSource, contains('nobody has bet yet'));
    expect(
      reviewSource,
      isNot(contains("'legal actions': 'the actions you can choose'")),
    );
    expect(reviewSource, isNot(contains('proof note')));
    expect(playSource, contains('act0_shell_wave2_practice_current_rep_value'));
    expect(previewSource, contains('Current useful rep'));
  });

  test('wave2 visual pack builder names the required evidence output', () {
    final script = File(
      'tools/build_real_text_visual_pack_wave2_feedback_repair_proof_v1.py',
    );
    expect(script.existsSync(), isTrue);

    final source = script.readAsStringSync();
    expect(
      source,
      contains('real_text_visual_pack_wave2_feedback_repair_proof_v1'),
    );
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_deferred_phone_first'));
    expect(source, contains('wave2_feedback_repair_proof_system_v1.md'));
  });
}

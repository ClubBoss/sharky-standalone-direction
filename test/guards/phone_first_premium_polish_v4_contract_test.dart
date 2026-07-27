import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home and Learn keep one hero while secondary modules stay quiet', () {
    final home = File(
      'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
    ).readAsStringSync();
    final learn = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();

    expect(home, contains('act0_shell_home_quiet_sequence_surface'));
    expect(home, contains('act0_shell_home_v6_primary_cta'));
    expect(learn, contains('act0_shell_current_mission_card'));
    expect(learn, contains('act0_shell_current_mission_step_band'));
    expect(learn, contains('act0_shell_current_mission_cta'));
  });

  test('Summary, feedback, and actions own purposeful premium moments', () {
    final runner = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(runner, contains('act0_shell_session_summary_victory_lap'));
    expect(runner, contains('act0_shell_feedback_companion_role'));
    expect(runner, contains('act0_shell_poker_action_tactile_surface_'));
    expect(runner, contains('Missed cue'));
    expect(runner, contains('Repair focus'));
    expect(runner, contains('Original read proven'));
  });

  test('six active screens retain distinct primary role elements', () {
    final home = File(
      'lib/ui_v2/act0_shell/act0_home_shell_v1.dart',
    ).readAsStringSync();
    final learn = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();
    final review = File(
      'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
    ).readAsStringSync();
    final practice = File(
      'lib/ui_v2/act0_shell/act0_play_shell_v1.dart',
    ).readAsStringSync();
    final profile = File(
      'lib/ui_v2/act0_shell/act0_profile_shell_v1.dart',
    ).readAsStringSync();
    final runner = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(home, contains('act0_shell_home_v6_primary_cta'));
    expect(learn, contains('act0_shell_current_mission_cta'));
    expect(review, contains('act0_shell_review_practice_cta'));
    expect(practice, contains('act0_shell_play_v1_featured_action_cta'));
    expect(profile, contains('act0_shell_profile_recommended_focus'));
    expect(runner, contains('act0_shell_session_summary_victory_lap'));
  });

  test('W12 terminal closes Volume I without opening a later world', () {
    final source = File(
      'lib/campaign/campaign_pack_registry_v1.dart',
    ).readAsStringSync();
    final capture = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();

    expect(source, contains('Volume I complete'));
    expect(
      source,
      contains('You can now slow down and read the table before choosing.'),
    );
    expect(
      source,
      contains('Review stays open. Later worlds stay locked for now.'),
    );
    expect(capture, contains("taskIndex == 3"));
    expect(capture, contains("'Volume I complete'"));
  });

  test('visual pack v4 is phone-first with tablet visible smoke', () {
    final script = File('tools/build_real_text_visual_pack_v4.py');
    expect(script.existsSync(), isTrue);
    final source = script.readAsStringSync();

    expect(source, contains('real_text_visual_pack_v4'));
    expect(source, contains('"phone_first": True'));
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_visible_contact_sheet.png'));
    expect(source, contains('claude_design_final_rereview_prompt.md'));
  });
}

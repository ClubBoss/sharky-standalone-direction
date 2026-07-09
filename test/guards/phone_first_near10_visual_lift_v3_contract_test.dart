import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('W12 terminal uses complete short copy and keeps later worlds locked', () {
    final source = File(
      'lib/campaign/campaign_pack_registry_v1.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'Review stays open. Later worlds stay locked for now.',
      ),
    );
    expect(
      source,
      contains('You can now slow down and read the table before choosing.'),
    );
    expect(
      source,
      isNot(
        contains(
          'Volume I review is complete. Later worlds stay locked for now. Stay in review and keep the Volume I clues sharp.',
        ),
      ),
    );
  });

  test(
    'Review empty state provides truthful value without fake queue data',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
      ).readAsStringSync();

      expect(source, contains('act0_shell_review_empty_value_preview'));
      expect(source, contains('Finish a lesson'));
      expect(source, contains('Miss'));
      expect(source, contains('Repair'));
      expect(source, contains('PROOF'));
      expect(source, contains('Act0SharkyPresenceBubbleV1'));
      expect(source, isNot(contains('fake queue')));
    },
  );

  test('runner distinguishes miss repair and proof visual moments', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_feedback_missed_cue_state'));
    expect(source, contains('act0_shell_feedback_repair_focus_state'));
    expect(source, contains('act0_shell_feedback_proof_state'));
    expect(source, contains('act0_shell_first_table_orientation'));
    expect(source, contains('act0_shell_hint_coaching_chip'));
    expect(source, contains('act0_shell_poker_action_button'));
  });

  test('Learn detail and Session Summary own distinct hero treatments', () {
    final learn = File(
      'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart',
    ).readAsStringSync();
    final runner = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(learn, contains('act0_shell_lesson_detail_hero'));
    expect(learn, contains('Lesson focus'));
    expect(runner, contains('act0_shell_session_summary_hero_metric'));
  });

  test('visual pack v3 owns phone-first and tablet-smoke metadata', () {
    final script = File('tools/build_real_text_visual_pack_v3.py');
    expect(script.existsSync(), isTrue);
    final source = script.readAsStringSync();

    expect(source, contains('real_text_visual_pack_v3'));
    expect(source, contains('"phone_first": True'));
    expect(source, contains('"tablet_smoke":'));
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_visible_contact_sheet.png'));
    expect(source, contains('claude_design_final_rereview_prompt.md'));
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Review empty previews the truthful learning loop without fake data',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_review_shell_v1.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('act0_shell_review_empty_learning_engine_preview'),
      );
      expect(source, contains('act0_shell_review_empty_sharky_coach_panel'));
      expect(
        source,
        contains(
          'After a lesson, Sharky brings back the exact cue you missed.',
        ),
      );
    },
  );

  test('feedback owns distinct miss treatment and stable Sharky slots', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_feedback_missed_cue_treatment'));
    expect(source, contains('act0_shell_feedback_sharky_slot_wrong'));
    expect(source, contains('act0_shell_feedback_sharky_slot_repair'));
    expect(source, contains('act0_shell_feedback_sharky_slot_proof'));
    expect(source, contains('Icons.search_off_rounded'));
  });

  test('first seat tap is framed as a deliberate table-read milestone', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_shell_first_table_read_milestone'));
    expect(source, contains('Step 1 · Locate your seat'));
    expect(
      source,
      contains('Read the table from your seat before any action.'),
    );
  });

  test('visual pack v5 is phone-first with tablet visible smoke', () {
    final script = File('tools/build_real_text_visual_pack_v5.py');
    expect(script.existsSync(), isTrue);
    final source = script.readAsStringSync();

    expect(source, contains('real_text_visual_pack_v5'));
    expect(source, contains('"phone_first": True'));
    expect(source, contains('compact_visible_contact_sheet.png'));
    expect(source, contains('compact_full_scroll_contact_sheet.png'));
    expect(source, contains('tablet_visible_contact_sheet.png'));
    expect(source, contains('claude_design_final_max10_rereview_prompt.md'));
  });
}

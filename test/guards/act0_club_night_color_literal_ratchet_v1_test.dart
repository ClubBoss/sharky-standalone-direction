import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Club Night keeps colour in one file: act0_club_night_tokens_v1.dart.
///
/// This is a ratchet. Each file below may keep at most the colour literals
/// it had when Club Night started (2026-11-20); new files may have none.
/// When a screen moves to Club Night, lower its number here (or remove the
/// line). Never raise a number. The table scene files stay listed until the
/// table itself is restyled.
// Token sources: Club Night tokens and the B32 skin token set (designer slot).
const Set<String> _tokenFiles = <String>{
  'lib/ui_v2/act0_shell/act0_club_night_tokens_v1.dart',
  'lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart',
};

const Map<String, int> _allowance = <String, int>{
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart': 19,
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart': 12,
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_onboarding_leaf_v1.dart': 2,
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart': 3,
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart': 5,
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_settings_leaf_v1.dart': 9,
  'lib/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart': 14,
  'lib/ui_v2/act0_shell/act0_academy_folio_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_academy_reading_style_v1.dart': 2,
  'lib/ui_v2/act0_shell/act0_learn_path_cards_v1.dart': 3,
  'lib/ui_v2/act0_shell/act0_learn_path_mission_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart': 12,
  'lib/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart': 6,
  'lib/ui_v2/act0_shell/act0_learning_scene_v3.dart': 1,
  'lib/ui_v2/act0_shell/act0_lesson_runner_feedback_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_lesson_runner_seats_v1.dart': 7,
  'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_review_shell_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_scene_character_asset_v1.dart': 1,
  'lib/ui_v2/act0_shell/act0_scene_depth_v1.dart': 9,
  'lib/ui_v2/act0_shell/act0_scene_hud_v1.dart': 11,
  'lib/ui_v2/act0_shell/act0_scene_material_v1.dart': 19,
  'lib/ui_v2/act0_shell/act0_scene_player_v1.dart': 22,
  'lib/ui_v2/act0_shell/act0_shell_tokens_v1.dart': 50,
};

void main() {
  test('no new colour literals outside the Club Night tokens', () {
    final literal = RegExp(r'Color\(0x');
    final over = <String>[];
    final dir = Directory('lib/ui_v2/act0_shell');
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (_tokenFiles.contains(path)) continue;
      final count = literal.allMatches(entity.readAsStringSync()).length;
      final allowed = _allowance[path] ?? 0;
      if (count > allowed) {
        over.add('$path: $count colour literals, allowed $allowed');
      }
    }
    expect(
      over,
      isEmpty,
      reason:
          'Use Act0ClubNightTokensV1 instead of Color(0x...). '
          'Lower an allowance when a file migrates; never raise one.',
    );
  });
}

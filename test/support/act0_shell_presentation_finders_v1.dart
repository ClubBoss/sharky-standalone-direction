import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';

/// Selects the actual active presentation, never falls back to a hidden legacy
/// control. Callers keep their original route/state/telemetry assertions.
Finder act0ShellPresentationFinderV1(String legacyKey) {
  var key = legacyKey;
  if (act0AcademyHomePreviewV1) {
    key = switch (key) {
      'act0_shell_main_cta' => 'act0_academy_home_leaf_cta',
      'act0_shell_home_dev_menu_button' => 'act0_academy_home_leaf_dev_menu',
      _ => key,
    };
  }
  if (act0AcademyPracticePreviewV1) {
    if (key == 'act0_shell_play_repair_queue_item_cta') {
      return find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(
              'act0_academy_practice_leaf_repair_cta_',
            ),
      );
    }
    if (key == 'act0_shell_play_daily_hero') {
      final input =
          (find.byType(Act0AcademyPracticeLeafV1).evaluate().single.widget
                  as Act0AcademyPracticeLeafV1)
              .input;
      if (input.recommendedGroupId == 'weak_spots' &&
          input.repairQueue.items.any(
            act0AcademyPracticeRepairItemLaunchableV1,
          )) {
        return find.byKey(const Key('act0_academy_practice_leaf_quick_reps'));
      }
    }
    key = switch (key) {
      'act0_shell_practice_group_daily' =>
        'act0_academy_practice_leaf_topic_daily',
      'act0_shell_play_screen' => 'act0_academy_practice_leaf',
      'act0_shell_play_featured_cta' => 'act0_academy_practice_leaf_start',
      'act0_shell_play_daily_hero' =>
        'act0_academy_practice_leaf_recommendation',
      'act0_shell_play_repair_queue' ||
      'act0_shell_practice_group_weak_spots' =>
        'act0_academy_practice_leaf_repair_queue',
      _ => key,
    };
  }
  if (act0AcademyReviewPreviewV1) {
    const prefix = 'act0_shell_fixed_mistake_replay_';
    if (key.startsWith(prefix)) {
      final taskId = key.substring(prefix.length);
      key = 'act0_academy_review_leaf_past_$taskId';
    }
    key = switch (key) {
      'act0_shell_review_screen' => 'act0_academy_review_leaf',
      'act0_shell_review_practice_cta' => 'act0_academy_review_leaf_repair_cta',
      _ => key,
    };
  }
  return find.byKey(ValueKey<String>(key));
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'act0_learn_cinematic_path_a_v1_test.dart' as harness;

Future<void> open(WidgetTester t) async {
  await harness.tap(t, find.text('All worlds').first);
}

Finder key(String s) => find.byKey(Key(s));
Map<String, Object> nextWorldFixture() {
  final raw = harness.prefs(fresh: true);
  final p =
      jsonDecode(raw['act0_shell_progress_v1'] as String)
          as Map<String, dynamic>;
  final w1 = Act0ShellStateV1.sample.worldById('world_1');
  final w2 = Act0ShellStateV1.sample.worldById('world_2');
  p['completedTaskIds'] = [
    for (final l in w1.lessons)
      for (final t in l.taskList) t.taskId,
  ];
  p['completedLessonIds'] = [for (final l in w1.lessons) l.lessonId];
  p['skippedTaskIds'] = <String>[];
  p['selectedWorldId'] = w2.worldId;
  p['selectedLessonId'] = w2.lessons.first.lessonId;
  p['selectedTaskId'] = w2.lessons.first.taskList.first.taskId;
  raw['act0_shell_progress_v1'] = jsonEncode(p);
  return raw;
}

void main() {
  testWidgets(
    'Worlds flag is reversible; overview is source-backed and closes to unchanged Learn',
    (t) async {
      await harness.mount(t, harness.prefs(fresh: true));
      await open(t);
      expect(
        key('act0_worlds_b_overlay'),
        kAct0WorldsBPreviewV1 ? findsOneWidget : findsNothing,
      );
      if (!kAct0WorldsBPreviewV1) return;
      expect(key('act0_shell_bottom_nav'), findsNothing);
      expect(find.text('12 worlds · 1 open · 11 locked'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is AnnotatedRegion<SystemUiOverlayStyle> &&
              w.value == SystemUiOverlayStyle.light,
        ),
        findsWidgets,
      );
      expect(
        t.getSize(key('act0_worlds_b_continue')).height,
        greaterThanOrEqualTo(44),
      );
      // Widget harness uses synthetic test glyph widths; native default fit is captured separately.
      await t.ensureVisible(key('act0_worlds_b_row_world_3'));
      await t.pumpAndSettle();
      expect(
        t.getBottomRight(key('act0_worlds_b_row_world_3')).dy,
        lessThan(t.getTopLeft(key('act0_worlds_b_catalog_toggle')).dy),
      );
      await harness.tap(t, key('act0_worlds_b_row_world_2'));
      expect(key('act0_worlds_b_overlay'), findsOneWidget);
      expect(key('act0_shell_lesson_runner_shell'), findsNothing);
      await harness.tap(t, key('act0_worlds_b_continue'));
      expect(key('act0_worlds_b_overlay'), findsNothing);
      expect(key('act0_learn_cinematic_body'), findsOneWidget);
      expect(find.text('0 of 9 lessons complete'), findsOneWidget);
    },
  );
  testWidgets(
    'existing full world catalog, last row, overview and Learn back',
    (t) async {
      await harness.mount(t, harness.prefs());
      await open(t);
      if (!kAct0WorldsBPreviewV1) return;
      await harness.tap(t, key('act0_worlds_b_catalog_toggle'));
      expect(find.text('All 12 worlds'), findsOneWidget);
      await t.ensureVisible(key('act0_worlds_b_row_world_12'));
      await t.pumpAndSettle();
      final row = t.widget<InkWell>(key('act0_worlds_b_row_world_12'));
      expect(row.onTap, isNull);
      expect(
        t.getBottomRight(key('act0_worlds_b_row_world_12')).dy,
        lessThanOrEqualTo(t.getTopLeft(key('act0_worlds_b_catalog_toggle')).dy),
      );
      await harness.tap(t, key('act0_worlds_b_catalog_toggle'));
      expect(key('act0_worlds_b_current_card'), findsOneWidget);
      await harness.tap(t, key('act0_worlds_b_back'));
      expect(key('act0_worlds_b_overlay'), findsNothing);
      expect(key('act0_learn_cinematic_body'), findsOneWidget);
    },
    skip: !kAct0WorldsBPreviewV1,
  );
  testWidgets(
    'restored source-valid W1 complete changes current card and counts',
    (t) async {
      final fixture = nextWorldFixture();
      // Explicit QA restore exported for the matching native alternate-state check.
      final out = Directory('output/worlds_b_v1_20261026');
      out.createSync(recursive: true);
      File(
        '${out.path}/next_world_fixture.json',
      ).writeAsStringSync(jsonEncode(fixture));
      await harness.mount(t, fixture);
      await open(t);
      expect(find.text('12 worlds · 2 open · 10 locked'), findsOneWidget);
      expect(
        find.descendant(
          of: key('act0_worlds_b_current_card'),
          matching: find.text('Hand Discipline'),
        ),
        findsOneWidget,
      );
      await harness.tap(t, key('act0_worlds_b_continue'));
      expect(key('act0_worlds_b_overlay'), findsNothing);
      expect(key('act0_learn_cinematic_body'), findsOneWidget);
    },
    skip: !kAct0WorldsBPreviewV1,
  );
}

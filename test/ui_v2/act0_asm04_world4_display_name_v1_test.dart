import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ASM-04: the real preview screen feeds Learn with the World 4 display name
// (owner decision 'Betting Decisions'); the authored name equals the World 4
// recap answer and must not appear while World 4 is the current world.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets(
    'preview Learn shows Betting Decisions, never the authored name',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sample = Act0ShellStateV1.sample;
      final world4 = sample.worldById('world_4');
      expect(world4.title, act0World4AuthoredTitleV1);
      final lessons = <Act0LessonCardV1>[
        world4.lessons.first.copyWith(
          state: Act0LessonStateV1.current,
          isSelectable: true,
          isLocked: false,
        ),
        ...world4.lessons.skip(1),
      ];
      final state = Act0ShellStateV1(
        courseTitle: sample.courseTitle,
        courseSubtitle: sample.courseSubtitle,
        levelLabel: sample.levelLabel,
        xp: sample.xp,
        xpTarget: sample.xpTarget,
        streakDays: sample.streakDays,
        dailyGoalLabel: sample.dailyGoalLabel,
        dailyGoalValue: sample.dailyGoalValue,
        pathProgressLabel: sample.pathProgressLabel,
        selectedWorldId: 'world_4',
        worlds: <Act0WorldCardV1>[
          world4.copyWith(
            lessons: lessons,
            status: Act0WorldStateV1.current,
            isSelectable: true,
            isLocked: false,
          ),
          sample.worldById('world_5'),
        ],
        lessons: lessons,
        review: sample.review,
        profile: sample.profile,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Act0ShellPreviewScreenV1(
            state: state,
            showPlacementOnStart: false,
            initialTab: Act0ShellTabV1.learn,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final learn = tester.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      // Preview hook: module title.
      expect(learn.moduleTitle, 'Betting Decisions');
      // Preview hook: unlock labels handed to Learn.
      for (final w in learn.worlds) {
        expect(w.unlockLabel, isNot(contains(act0World4AuthoredTitleV1)));
      }
      final visible = [
        for (final w in tester.widgetList<Text>(find.byType(Text)))
          if (w.data != null) w.data!,
        for (final w in tester.widgetList<RichText>(find.byType(RichText)))
          w.text.toPlainText(),
      ];
      expect(visible.where((t) => t.contains('Bet Purpose')), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}

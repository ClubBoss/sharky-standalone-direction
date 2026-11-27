import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w14_skill_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('partial world input keeps the release skill map heading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0AcademyYouLeafV1(
            input: Act0AcademyYouLeafInputV1(
              worlds: [Act0ShellStateV1.sample.worlds.first],
              skills: const [
                Act0W14SkillStateV1(
                  label: 'Table sense',
                  lessonCount: 1,
                  taskCount: 1,
                  answeredTasks: 1,
                  independentTasks: 1,
                  helpedOrUnverifiedTasks: 0,
                  tasksToRevisit: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.text(
        act0CurriculumPilotEnabledV1 ? 'Skills · W1–W1' : 'Skills · W1–W12',
      ),
      findsOneWidget,
    );
  });

  testWidgets('You explains the unstarted W1–W12 skill map', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          state: act0CurriculumPilotEnabledV1
              ? Act0ShellStateV1.volumeOneLearnerCatalog
              : null,
          debugPersistFixtureProgress: act0CurriculumPilotEnabledV1,
          showPlacementOnStart: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    final skills = find.byKey(const Key('act0_w14_skills'));
    expect(skills, findsOneWidget);
    expect(find.text('Skills · W1–W12'), findsOneWidget);
    await tester.ensureVisible(skills);
    await tester.tap(skills);
    await tester.pumpAndSettle();
    expect(find.text('Not started'), findsNWidgets(12));
    expect(find.text('Table sense'), findsOneWidget);
    expect(find.text('Position play'), findsOneWidget);
    expect(find.text('Range reading'), findsOneWidget);
    expect(find.text('Stack decisions'), findsOneWidget);
    expect(find.text('Tournament decisions'), findsOneWidget);
    expect(find.text('Player adjustment'), findsOneWidget);
    expect(find.text('Session routine'), findsOneWidget);
    expect(find.text('Mental game'), findsOneWidget);
    expect(find.text('No lesson answers recorded yet.'), findsNWidgets(12));
    expect(
      tester.getTopLeft(find.text('Table sense')).dx,
      tester.getTopLeft(find.text('Hand reading')).dx,
    );
    expect(find.text('2 lessons · 9 tasks'), findsOneWidget);
  });
}

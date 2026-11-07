import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Full REP-06 includes each completion branch, not only an ordinary lesson.
// Pending shared-owner repair: exact-main source currently emits unconditional
// "You learned" / "What improved" world copy from aggregate skill counters.
// These are widget fixtures, never native or actual learning-effect proof.
void main() {
  for (final world in <int>[1, 2, 4, 12]) {
    for (final condition in <String>['assisted', 'missed', 'unverified']) {
      testWidgets(
        'World $world $condition completion reports practice without growth',
        (tester) async {
          tester.view.physicalSize = const Size(393, 852);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Act0BlockCompletionShellV1(
                  summary: Act0BlockCompletionSummaryV1(
                    curriculumCompleted: true,
                    lessonTitle: 'World recap',
                    milestoneTier: Act0ProgressMilestoneTierV1.world,
                    worldNumber: world,
                    worldTitle: 'World $world',
                    nextWorldNumber: world == 12 ? null : world + 1,
                    nextWorldTitle: world == 12
                        ? 'Volume I review'
                        : 'World ${world + 1}',
                    xpEarned: 0,
                    errorCount: condition == 'missed' ? 1 : 0,
                    assistedCount: condition == 'assisted' ? 1 : 0,
                    independentProvenanceKnown: condition != 'unverified',
                    taskCount: 2,
                    correctCount: condition == 'missed' ? 1 : 2,
                    startLevel: 1,
                    endLevel: 1,
                    startXp: 20,
                    endXp: 20,
                    xpTarget: 100,
                    skillGains: const <Act0SkillGainV1>[
                      Act0SkillGainV1(
                        label: 'Table sense',
                        gain: 1,
                        source: 'World recap',
                      ),
                    ],
                  ),
                  firstCorrectEarnedThisRun: false,
                  onContinue: () {},
                  onBackToMap: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('act0_shell_block_summary_title')),
            findsOneWidget,
          );
          expect(find.text('What improved'), findsNothing);
          expect(find.textContaining('You learned'), findsNothing);
          expect(find.textContaining('You can now'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

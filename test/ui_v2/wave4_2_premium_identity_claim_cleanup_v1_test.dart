import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets(
    'Profile uses Sharky mascot identity instead of XP header economy',
    (tester) async {
      final sample = Act0ShellStateV1.sample.profile;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ProfileShellV1(
              profile: Act0ProfileStateV1(
                playerName: sample.playerName,
                level: 'Level 2',
                xpLine: '125 / 200 XP',
                lessonsLine: sample.lessonsLine,
                accuracyLine: sample.accuracyLine,
                qualityLine: sample.qualityLine,
                streakLine: sample.streakLine,
                streakDays: sample.streakDays,
                consistencyActiveDays: sample.consistencyActiveDays,
                achievements: sample.achievements,
                strongCategories: sample.strongCategories,
                weakCategories: sample.weakCategories,
                recentProgress: sample.recentProgress,
                recentSkillGains: sample.recentSkillGains,
                skillStats: sample.skillStats,
                streakLast7: sample.streakLast7,
                recommendedFocusTitle: sample.recommendedFocusTitle,
                recommendedFocusBody: sample.recommendedFocusBody,
                recommendedFocusCtaLabel: sample.recommendedFocusCtaLabel,
              ),
              onRetakePlacement: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_profile_sharky_identity')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_sharky_presence_mascot_neutral')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_profile_xp_progress_bar')),
        findsNothing,
      );
      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Level'), findsNothing);
      expect(find.text('Proof profile'), findsWidgets);
      expect(find.text('Sharky keeps proof, not points.'), findsOneWidget);
    },
  );

  testWidgets(
    'feedback completion toast is proof-based without XP or level copy',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0FeedbackShellV1(
              title: 'Correct.',
              reason: 'Nobody had bet yet - that was the clue.',
              quality: Act0FeedbackQualityV1.correct,
              sharkyLine: 'Good read.',
              sharkyMood: Act0SharkyMoodV1.happy,
              selectedLabel: 'Check',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              signalProof: const Act0FeedbackSignalProofV1(
                signalId: 'no_bet_yet',
                label: 'No bet yet',
                proofLine: 'Signal: No bet yet',
              ),
              completionSummary: const Act0RunnerCompletionSummaryV1(
                xpGain: 12,
                startLevel: 1,
                endLevel: 2,
                startXp: 195,
                endXp: 7,
                xpTarget: 200,
              ),
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_completion_toast')),
        findsOneWidget,
      );
      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Level'), findsNothing);
      expect(find.text('Proof banked'), findsOneWidget);
      expect(find.text('Table read improved'), findsOneWidget);
    },
  );

  testWidgets(
    'session summary progress card uses local proof copy without XP',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0BlockCompletionShellV1(
              summary: const Act0BlockCompletionSummaryV1(
                lessonTitle: 'Action words',
                xpEarned: 24,
                errorCount: 0,
                taskCount: 2,
                correctCount: 2,
                startLevel: 1,
                endLevel: 2,
                startXp: 180,
                endXp: 4,
                xpTarget: 200,
                nextLessonTitle: 'Blinds and action order',
              ),
              onReplay: () {},
              onContinue: () {},
              onBackToMap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_block_summary_xp_gain')),
        findsOneWidget,
      );
      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('Level'), findsNothing);
      expect(find.text('One clean read'), findsOneWidget);
      expect(find.text('Local proof saved'), findsOneWidget);
    },
  );
}

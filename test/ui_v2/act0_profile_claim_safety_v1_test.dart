import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  for (final hasRecentGain in <bool>[false, true]) {
    testWidgets(
      'A single ${hasRecentGain ? 'practice gain' : 'correct category'} does not claim skill growth or habit',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0ProfileShellV1(
                // Activity and the legacy practice fields carry no independent
                // mastery, unseen-transfer or elapsed-retention evidence.
                profile: Act0ProfileStateV1(
                  playerName: 'New player',
                  level: 'Level 99',
                  xpLine: '99999 XP',
                  lessonsLine: '0 of 24 tasks complete',
                  accuracyLine: '',
                  consistencyActiveDays: 30,
                  achievements: const <Act0AchievementV1>[],
                  streakDays: 30,
                  streakLine: '30 day streak',
                  strongCategories: hasRecentGain
                      ? const <String>[]
                      : const <String>['Table sense'],
                  recentSkillGains: hasRecentGain
                      ? const <Act0SkillGainV1>[
                          Act0SkillGainV1(
                            label: 'Table sense',
                            gain: 1,
                            source: 'One practice response',
                          ),
                        ]
                      : const <Act0SkillGainV1>[],
                ),
                onRetakePlacement: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final visibleText = tester
            .widgetList<Text>(find.byType(Text))
            .map(
              (widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '',
            )
            .join(' ')
            .toLowerCase();
        for (final claim in <String>[
          'becoming more familiar',
          'becoming a habit',
          'growing',
          'mastered',
          'retained',
          'transfer confirmed',
        ]) {
          expect(visibleText, isNot(contains(claim)));
        }
        expect(
          find.text(
            hasRecentGain
                ? 'Recent practice: Table sense.'
                : 'Correct read: Table sense.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_shell_profile_evidence_signal')),
          findsNothing,
        );
        if (hasRecentGain) {
          expect(find.text('1 practiced'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Profile skill proof uses evidence-safe nonnumeric copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ProfileShellV1(
            profile: const Act0ProfileStateV1(
              playerName: 'New player',
              level: 'Level 1',
              xpLine: '120 / 200 XP',
              lessonsLine: '8 of 24 tasks complete',
              accuracyLine: '82% practice accuracy',
              qualityLine: '1 perfect clear',
              consistencyActiveDays: 3,
              achievements: <Act0AchievementV1>[
                Act0AchievementV1(label: 'First clear read'),
                Act0AchievementV1(label: 'Rhythm saved today'),
              ],
              streakLine: '3 day streak',
              streakDays: 3,
              skillStats: <Act0PlacementSkillStatV1>[
                Act0PlacementSkillStatV1(
                  label: 'Table sense',
                  value: 78,
                  meaning: 'Tracks table reads.',
                  affects: 'Supports table reads.',
                  whyImportant: 'Table reads matter.',
                ),
                Act0PlacementSkillStatV1(
                  label: 'Board reading',
                  value: 72,
                  meaning: 'Reads board texture.',
                  affects: 'Supports board reads.',
                  whyImportant: 'Board reads matter.',
                ),
              ],
              recentSkillGains: <Act0SkillGainV1>[
                Act0SkillGainV1(
                  label: 'Table sense',
                  gain: 6,
                  source: 'Action words',
                ),
                Act0SkillGainV1(
                  label: 'Board reading',
                  gain: 3,
                  source: 'Read the flop',
                ),
              ],
            ),
            onRetakePlacement: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final visibleText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ');

    for (final unsafe in <String>[
      'Level',
      'Lv',
      'XP',
      'Rating',
      'Radar',
      'Skill score',
      'Mastered',
      'Strongest skill',
      'Weakest skill',
    ]) {
      expect(visibleText, isNot(contains(unsafe)));
    }
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_profile_progress_proof')),
        matching: find.byIcon(Icons.radar_rounded),
      ),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('act0_shell_profile_skill_stats')),
      180,
      scrollable: find.descendant(
        of: find.byKey(const Key('act0_shell_profile_screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Practice topics'), findsOneWidget);
    expect(find.textContaining('Recent practice: Table sense'), findsWidgets);
    expect(find.text('Table sense'), findsWidgets);
    expect(find.text('Recent practice'), findsWidgets);
    expect(find.text('From Action words'), findsOneWidget);
    final skillText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_profile_skill_stats')),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ');

    for (final unsafe in <String>[
      'Skill snapshot',
      'Table sense +',
      'Board reading +',
      '+6',
      '+3',
      'Lv 1',
      'Lv 2',
      'Level',
      'XP',
      'Rating',
      'Radar',
      'Skill score',
      'Strongest skill',
      'Weakest skill',
      'mastered',
      'leak',
      'AI',
      'GTO',
      'solver',
      'proof',
    ]) {
      expect(skillText, isNot(contains(unsafe)));
    }
    expect(find.textContaining('badges'), findsNothing);
  });
}

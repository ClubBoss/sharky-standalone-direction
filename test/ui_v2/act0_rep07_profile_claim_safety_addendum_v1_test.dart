import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_cross_session_profile_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  Future<void> showProfile(
    WidgetTester tester, {
    required Act0ProfileStateV1 profile,
    Act0ProfileEvidenceSignalViewModelV1? signal,
    Act0CrossSessionProfileProofV1? proof,
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0ProfileShellV1(
            profile: profile,
            evidenceSignal: signal,
            crossSessionProof: proof,
            onRetakePlacement: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const empty = Act0ProfileStateV1(
    playerName: 'Test learner',
    level: 'Level 99',
    xpLine: '99999 XP',
    lessonsLine: '0 of 24 tasks complete',
    accuracyLine: '',
    consistencyActiveDays: 30,
    streakDays: 30,
    streakLine: '30 day streak',
    achievements: <Act0AchievementV1>[],
  );

  testWidgets('REP-07 recorded practice does not become route proof', (
    tester,
  ) async {
    await showProfile(
      tester,
      profile: const Act0ProfileStateV1(
        playerName: 'Test learner',
        level: 'Level 99',
        xpLine: '99999 XP',
        lessonsLine: '1 of 24 tasks complete',
        accuracyLine: '',
        consistencyActiveDays: 30,
        streakDays: 30,
        streakLine: '30 day streak',
        achievements: <Act0AchievementV1>[],
        recentSkillGains: <Act0SkillGainV1>[
          Act0SkillGainV1(
            label: 'Table sense',
            gain: 1,
            source: 'Single practice response',
          ),
        ],
      ),
    );
    expect(find.text('What Sharky can prove'), findsNothing);
    expect(find.text('Recent route proof'), findsNothing);
    expect(find.text('Recent practice: Table sense.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REP-07 no evidence does not imply skill growth', (tester) async {
    await showProfile(
      tester,
      profile: empty,
      signal: const Act0ProfileEvidenceSignalViewModelV1(
        signalId: 'profile_recent_v1|table_read',
        skillAtomId: 'table_read',
        skillLabel: 'Table reading',
        correctCount: 0,
        attemptCount: 0,
        proofLine: 'Confirmation needed - make an independent response.',
        confirmationState: act0RecentEvidenceConfirmationNeededV1,
      ),
    );
    final card = find.byKey(
      const Key('act0_shell_profile_evidence_signal'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      card,
      260,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.text('You are building this skill.'), findsNothing);
    expect(
      find.text('Independent confirmation is still needed.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('REP-07 one clean response is practice, not mastery', (
    tester,
  ) async {
    await showProfile(
      tester,
      profile: empty,
      signal: const Act0ProfileEvidenceSignalViewModelV1(
        signalId: 'profile_recent_v1|table_read',
        skillAtomId: 'table_read',
        skillLabel: 'Table reading',
        correctCount: 1,
        attemptCount: 1,
        proofLine: '1/1 correct; more independent responses needed.',
        confirmationState: act0RecentEvidenceConfirmationNeededV1,
      ),
    );
    expect(find.text('What Sharky can prove'), findsNothing);
    expect(find.text('Recent route proof'), findsNothing);
    final card = find.byKey(
      const Key('act0_shell_profile_evidence_signal'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      card,
      260,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Independent confirmation is still needed.'),
      findsOneWidget,
    );
  });

  testWidgets('REP-07 practice counter does not show a skill-level bar', (
    tester,
  ) async {
    await showProfile(
      tester,
      profile: const Act0ProfileStateV1(
        playerName: 'Test learner',
        level: 'Level 99',
        xpLine: '99999 XP',
        lessonsLine: '1 of 24 tasks complete',
        accuracyLine: '',
        consistencyActiveDays: 30,
        achievements: <Act0AchievementV1>[],
        skillStats: <Act0PlacementSkillStatV1>[
          Act0PlacementSkillStatV1(
            label: 'Table sense',
            value: 84,
            meaning: 'Practice focus',
            affects: 'Table decisions',
            whyImportant: 'Observe the situation',
          ),
          Act0PlacementSkillStatV1(
            label: 'Board reading',
            value: 78,
            meaning: 'Practice focus',
            affects: 'Board decisions',
            whyImportant: 'Observe the cards',
          ),
          Act0PlacementSkillStatV1(
            label: 'Position play',
            value: 79,
            meaning: 'Practice focus',
            affects: 'Position decisions',
            whyImportant: 'Observe the seat',
          ),
        ],
      ),
    );
    final openAll = find.byKey(
      const Key('act0_shell_profile_skills_button'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      openAll,
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    await tester.tap(openAll);
    await tester.pumpAndSettle();
    final sheet = find.byKey(const Key('act0_shell_profile_skills_sheet'));
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(
        of: sheet,
        matching: find.byType(LinearProgressIndicator),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('REP-07 completion alone cannot earn a clean read claim', (
    tester,
  ) async {
    await showProfile(
      tester,
      profile: const Act0ProfileStateV1(
        playerName: 'Test learner',
        level: 'Level 99',
        xpLine: '99999 XP',
        lessonsLine: '1 of 24 tasks complete',
        accuracyLine: '',
        consistencyActiveDays: 30,
        achievements: <Act0AchievementV1>[
          Act0AchievementV1(
            id: 'first_table_read',
            label: 'First clear read',
            locked: false,
          ),
        ],
      ),
    );
    final milestones = find.byKey(
      const Key('act0_shell_profile_milestones'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      milestones,
      240,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.text('First clear read'), findsNothing);
    expect(find.text('First task completed'), findsOneWidget);
  });

  testWidgets('REP-07 historical repair does not imply current confirmation', (
    tester,
  ) async {
    await showProfile(
      tester,
      profile: empty,
      proof: const Act0CrossSessionProfileProofV1(
        totalBankedFixCount: 1,
        distinctConceptFamilyCount: 1,
        recentProofItems: <Act0CrossSessionProfileProofItemV1>[
          Act0CrossSessionProfileProofItemV1(
            proofId: 'saved-repair',
            conceptFamilyId: 'table_read',
            proofState: 'repair_completed_v1',
            sourceRepairReference: 'repair-outcome',
            bankedOrder: 1,
            conceptLabelKey: 'table_read',
            messageKey: 'profile_proof_repair_completed_v1',
            currentVerificationState: act0RecentEvidenceConfirmationNeededV1,
            currentVerificationLine:
                'Independent confirmation is still needed.',
          ),
        ],
      ),
      signal: const Act0ProfileEvidenceSignalViewModelV1(
        signalId: 'profile_recent_v1|table_read',
        skillAtomId: 'table_read',
        skillLabel: 'Table reading',
        correctCount: 0,
        attemptCount: 0,
        proofLine: 'Confirmation needed - make an independent response.',
        confirmationState: act0RecentEvidenceConfirmationNeededV1,
      ),
    );
    expect(find.text('What Sharky can prove'), findsNothing);
    expect(find.text('Recent route proof'), findsNothing);
    expect(find.text('Saved repair evidence'), findsOneWidget);
    final card = find.byKey(
      const Key('act0_shell_profile_progress_proof'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      card,
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.text('Repair evidence'), findsOneWidget);
    expect(find.text('1 banked'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REP-07 verified recent responses never claim mastery', (
    tester,
  ) async {
    await showProfile(
      tester,
      profile: empty,
      signal: const Act0ProfileEvidenceSignalViewModelV1(
        signalId: 'profile_recent_v1|table_read',
        skillAtomId: 'table_read',
        skillLabel: 'Table reading',
        correctCount: 5,
        attemptCount: 5,
        proofLine: '5/5 correct in recent independent responses.',
        confirmationState: act0RecentEvidenceVerifiedV1,
      ),
    );
    expect(find.text('What Sharky can prove'), findsOneWidget);
    expect(find.text('Recent route proof'), findsOneWidget);
    final card = find.byKey(
      const Key('act0_shell_profile_evidence_signal'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      card,
      260,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recent independent responses verified.'), findsOneWidget);
    expect(find.textContaining('mastered'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

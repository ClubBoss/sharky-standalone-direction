import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_screen_v1.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import '../ui_v2/hst06_review_route_proposal_test.dart' as fixture;

Map<String, Object?> evidenceSnapshot(WidgetTester tester) {
  final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
  // Read-only existing test APIs; do not call the next-target getter that records an audit transition.
  return jsonDecode(
        jsonEncode({
          'repairOutcomes': state.debugRepairOutcomeProjectionPayloadV1(),
          'conceptEvidence': state.debugConceptFamilyStatePayloadV1(),
          'retention': state.debugDurableRetentionPayloadV1(),
          'repairAudit': state.debugRepairIntentAuditTrailPayloadV1(),
          'openRepairCount': state.debugOpenRepairIntentCountV1(),
          'activeRepair': state.debugActiveRepairContextPayloadV1(),
          'selectedTask': state.debugSelectedTaskIdV1(),
          'selectedWorld': state.debugSelectedWorldIdV1(),
          'selectedLesson': state.debugSelectedLessonIdV1(),
          'phase': state.debugPhaseV1(),
          'selectedOption': state.debugSelectedOptionIdV1(),
        }),
      )
      as Map<String, Object?>;
}

Future<Map<String, Object?>> youSnapshot(WidgetTester tester) async {
  await tester.tap(find.text('You').last);
  await tester.pumpAndSettle();
  final input = tester
      .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
      .input;
  final result = <String, Object?>{
    'xpLine': input.xpLine,
    'completedTaskCount': input.completedTaskCount,
    'earnedMomentIds': input.earnedMoments.map((m) => m.seedId).toList(),
    'bankedRepairs': input.bankedRepairCount,
    'reinforcedRepairs': input.reinforcedRepairCount,
    'openRepairs': input.openRepairCount,
    'dueReviews': input.dueReviewCount,
  };
  await openReview(tester);
  return result;
}

Future<void> openReview(WidgetTester tester) async {
  await tester.tap(find.text('Review').last);
  await tester.pumpAndSettle();
  expect(find.byType(Act0AcademyReviewLeafV1), findsOneWidget);
}

Future<void> boot(WidgetTester tester) async {
  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();
  expect(find.byType(Act0ShellPreviewScreenV1), findsOneWidget);
  final shell = tester.widget<Act0ShellPreviewScreenV1>(
    find.byType(Act0ShellPreviewScreenV1),
  );
  expect(shell.debugHarnessEntry, isNull);
  expect(shell.showPlacementOnStart, isFalse);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'returning AppRoot Review personal import cancel save and remount preserve learning storage',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Supported returning-user state; not first-use placement evidence.
      SharedPreferences.setMockInitialValues({'onboardingCompleted': true});
      await boot(tester);
      await openReview(tester);
      final learningBefore = await youSnapshot(tester);
      final evidenceBefore = evidenceSnapshot(tester);
      final before = await fixture.snapshot();
      await fixture.open(tester);
      await fixture.preview(tester);
      expect(tester.takeException(), isNull);
      await fixture.tapKey(tester, 'hst06-cancel-0');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(Act0AcademyReviewLeafV1), findsOneWidget);
      expect(await fixture.snapshot(), before);
      await fixture.open(tester);
      await fixture.preview(tester);
      await fixture.tapKey(tester, 'hst06-confirm-0');
      expect(await Hst06PersonalStore().load(), hasLength(1));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(evidenceSnapshot(tester), evidenceBefore);
      expect(await youSnapshot(tester), learningBefore);
      final saved = await fixture.snapshot();
      expect(saved.containsKey(Hst06PersonalStore.storageKey), isTrue);
      final withoutPersonal = Map<String, Object?>.from(saved)
        ..remove(Hst06PersonalStore.storageKey);
      expect(
        withoutPersonal,
        before,
        reason:
            'Every real shell preference outside the personal key must stay unchanged.',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await boot(tester);
      await openReview(tester);
      await fixture.open(tester);
      expect(find.byType(Hst06PersonalHandScreen), findsOneWidget);
      expect(find.text('Saved personal hands: 1'), findsOneWidget);
      expect(await Hst06PersonalStore().load(), hasLength(1));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        await fixture.snapshot(),
        saved,
        reason: 'Full preference map survives actual AppRoot remount.',
      );
      expect(await youSnapshot(tester), learningBefore);
      expect(evidenceSnapshot(tester), evidenceBefore);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'fresh AppRoot visible beginner onboarding reaches Review personal hands',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();
      final shell = tester.widget<Act0ShellPreviewScreenV1>(
        find.byType(Act0ShellPreviewScreenV1),
      );
      expect(shell.debugHarnessEntry, isNull);
      expect(shell.showPlacementOnStart, isTrue);
      for (final key in [
        'act0_shell_placement_intro_cta',
        'act0_shell_placement_option_new',
        'act0_shell_placement_next_cta',
      ]) {
        await fixture.tapKey(tester, key);
      }
      await fixture.tapKey(tester, 'act0_shell_welcome_primary_cta');
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      // Select the displayed first option; do not manufacture a correct result.
      await fixture.tapKey(
        tester,
        'act0_shell_option_${runner.runner.options.first.id}',
      );
      final feedback = find.byKey(
        const Key('act0_shell_feedback_continue_cta'),
      );
      if (feedback.evaluate().isNotEmpty) {
        await fixture.tapKey(tester, 'act0_shell_feedback_continue_cta');
      }
      await fixture.tapKey(tester, 'act0_shell_welcome_primary_cta');
      await openReview(tester);
      final before = await fixture.snapshot();
      final evidence = evidenceSnapshot(tester);
      await fixture.open(tester);
      await fixture.preview(tester);
      await fixture.tapKey(tester, 'hst06-cancel-0');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(await fixture.snapshot(), before);
      expect(evidenceSnapshot(tester), evidence);
      expect(tester.takeException(), isNull);
    },
  );
}

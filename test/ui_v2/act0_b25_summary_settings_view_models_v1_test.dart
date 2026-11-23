import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_summary_view_model_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_settings_view_model_v1.dart';
import 'package:test/test.dart';

void main() {
  group('Session summary', () {
    Act0SessionSummaryViewModelV1 view({
      bool worldDone = false,
      bool cleanPass = false,
      int repairs = 0,
      int assisted = 0,
      int misses = 0,
      bool hasNext = false,
      bool courseDone = false,
    }) => Act0SessionSummaryViewModelV1(
      worldDone: worldDone,
      cleanPass: cleanPass,
      quickFixCount: repairs,
      assistedCount: assisted,
      independentProvenanceKnown: true,
      firstCorrectEarnedThisRun: false,
      openMissedSpots: misses,
      canReturnHome: true,
      hasSourceNext: hasNext,
      hasUnlockLabel: true,
      hasGrowthLabel: true,
      canShareResult: true,
      curriculumCompleted: courseDone,
    );

    test(
      'lesson done clean keeps the milestone action and hides repair proof',
      () {
        final clean = view(cleanPass: true);
        expect(clean.lessonDoneClean, isTrue);
        expect(clean.showRepairReceipt, isFalse);
        expect(
          clean.primaryAction,
          Act0SessionSummaryPrimaryActionV1.milestone,
        );
      },
    );

    test('done with repairs displays independent repair proof', () {
      final repaired = view(repairs: 1, hasNext: true);
      expect(repaired.doneWithRepairs, isTrue);
      expect(repaired.showRepairReceipt, isTrue);
      expect(
        repaired.primaryAction,
        Act0SessionSummaryPrimaryActionV1.practiceClue,
      );
      final assisted = view(repairs: 1, assisted: 1);
      expect(assisted.doneWithRepairs, isTrue);
      expect(assisted.showRepairReceipt, isFalse);
      expect(
        view(repairs: 1, hasNext: true, misses: 2).primaryAction,
        Act0SessionSummaryPrimaryActionV1.fixMissedSpots,
      );
    });

    test(
      'world done folds unlock into the milestone; sharing uses course completion',
      () {
        final world = view(worldDone: true, cleanPass: true);
        expect(world.worldDone, isTrue);
        expect(world.lessonDoneClean, isFalse);
        expect(world.foldUnlockIntoMilestonePanel, isTrue);
        expect(world.showHabitReward, isFalse);
        expect(world.showShare, isFalse);
        expect(view(worldDone: true, courseDone: true).showShare, isTrue);
      },
    );
  });

  group('Settings', () {
    test('default preferences preserve support and busy boundaries', () async {
      final view = Act0SettingsViewModelV1(
        loadState: Act0AcademySettingsLoadStateV1.ready,
        version: Future.value('Version 1.0 (build 42)'),
        hapticsEnabled: true,
        reminderSupported: false,
        reminderEnabled: false,
        savingReminder: false,
      );
      expect(view.loadState, Act0AcademySettingsLoadStateV1.ready);
      expect(await view.version, 'Version 1.0 (build 42)');
      expect(view.hapticsEnabled, isTrue);
      expect(view.practiceReminderEnabled, isNull);
      expect(view.canChangeReminder, isTrue);
    });

    test('an unfulfilled opt-in shows the permission notice', () {
      for (final (enabled, scheduled, expected) in [
        (true, false, true),
        (true, true, false),
        (false, false, false),
      ]) {
        expect(
          Act0SettingsViewModelV1.showReminderPermissionNotice(
            enabled: enabled,
            scheduled: scheduled,
          ),
          expected,
        );
      }
    });

    test(
      'delete confirmation and deleted handoff do not own the busy screen',
      () {
        expect(
          Act0SettingsDeletionStateV1.deleteConfirm.showDeletionScreen,
          isFalse,
        );
        expect(Act0SettingsDeletionStateV1.deleting.showDeletionScreen, isTrue);
        expect(Act0SettingsDeletionStateV1.error.showDeletionScreen, isTrue);
        expect(Act0SettingsDeletionStateV1.deleted.showDeletionScreen, isFalse);
      },
    );

    test('release Settings cannot bind legacy debug preview actions', () {
      var launches = 0;
      void openPreview() => launches++;
      final releaseAction = act0SettingsPreviewActionV1(
        openPreview,
        isDebugMode: false,
        legacyPreviewRequested: true,
      );
      expect(releaseAction, isNull);
      releaseAction?.call();
      expect(launches, 0);

      act0SettingsPreviewActionV1(
        openPreview,
        isDebugMode: true,
        legacyPreviewRequested: true,
      )?.call();
      expect(launches, 1);
    });
  });
}

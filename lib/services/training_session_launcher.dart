import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/v2/training_pack_template_v2.dart';
import '../models/v2/training_pack_v2.dart';
import '../screens/training_session_screen.dart';
import '../screens/theory_pack_preview_screen.dart';
import 'achievements_engine.dart';
import 'dart:async';
import '../models/theory_mini_lesson_node.dart';
import 'smart_recap_booster_launcher.dart';
import 'smart_recap_booster_linker.dart';
import 'training_pack_template_storage_service.dart';
import 'pack_recall_stats_service.dart';
import '../core/training/library/training_pack_library_v2.dart';
import 'mini_lesson_library_service.dart';
import '../screens/mini_lesson_screen.dart';
import 'theory_lesson_completion_logger.dart';
import 'training_pack_stats_service.dart';
import '../widgets/unlock_progress_dialog.dart';
import 'training_session_outcome.dart';
import 'session_start_timing_service_v1.dart';
import 'drill_runtime_adapter_v1.dart';
import 'canonical_training_session_launch_plan_v1.dart';
import 'canonical_legacy_training_launch_v1.dart';
import '../ui_v2/runner/canonical_launcher_api_v1.dart';
import '../ui_v2/screens/viral_proof_v1.dart';
import '../archive/legacy_runners/world1_foundations_microtask_runner_screen.dart';

typedef TrainingSessionLaunchHandler =
    Future<void> Function(
      TrainingPackTemplateV2 template, {
      int startIndex,
      List<String>? sessionTags,
      String? source,
      TrainingSessionEndCallback? onSessionEnd,
    });

/// Helper to start a training session from a pack template.
class TrainingSessionLauncher {
  TrainingSessionLauncher();

  static TrainingSessionLaunchHandler? _launchOverride;

  @visibleForTesting
  static void overrideLaunchHandler(TrainingSessionLaunchHandler? handler) {
    assert(() {
      _launchOverride = handler;
      return true;
    }());
  }

  /// Launches a training session for [template]. If the pack only contains
  /// theory spots, shows [TheoryPackPreviewScreen] first.
  Future<void> launch(
    TrainingPackTemplateV2 template, {
    int startIndex = 0,
    List<String>? sessionTags,
    String? source,
    TrainingSessionEndCallback? onSessionEnd,
  }) async {
    final override = _launchOverride;
    if (override != null) {
      return override(
        template,
        startIndex: startIndex,
        sessionTags: sessionTags,
        source: source,
        onSessionEnd: onSessionEnd,
      );
    }
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    String? lessonId = template.meta['lessonId'] as String?;
    if (lessonId == null) {
      if (template.id == TrainingPackLibraryV2.mvpPackId) {
        lessonId = 'lesson_push_fold_intro';
      } else if (template.id == 'push_fold_btn_cash') {
        lessonId = 'lesson_push_fold_btn_cash';
      }
    }

    if (lessonId != null) {
      await MiniLessonLibraryService.instance.loadAll();
      final completed = await TheoryLessonCompletionLogger.instance.isCompleted(
        lessonId,
      );
      if (!completed) {
        final lesson = MiniLessonLibraryService.instance.getById(lessonId);
        if (lesson != null) {
          await Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => MiniLessonScreen(lesson: lesson)),
          );
        }
      }
    }

    unawaited(
      PackRecallStatsService.instance.recordReview(template.id, DateTime.now()),
    );

    final launchPlan = await resolveCanonicalTrainingSessionLaunchPlanV1(
      template,
      source: source,
    );

    if (launchPlan.launchesCanonicalWorld1Runner) {
      SessionStartTimingServiceV1.instance.start(
        source: source ?? 'training_session_launcher',
      );
      await Navigator.push(
        ctx,
        canonicalSessionDrillRouteV1(
          sessionId: launchPlan.templateId,
          world1ModuleTitleV1: launchPlan.world1ModuleTitleV1,
          world1ModeV1: launchPlan.world1ModeV1,
          world1StartHandIndexV1: startIndex,
        ),
      );
      unawaited(AchievementsEngine.instance.checkAll());
      return;
    }

    if (launchPlan.launchesTheoryPreview) {
      await Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => TheoryPackPreviewScreen(template: template),
        ),
      );
      unawaited(AchievementsEngine.instance.checkAll());
      return;
    }

    if (launchPlan.launchesSessionDrill) {
      SessionStartTimingServiceV1.instance.start(
        source: source ?? 'training_session_launcher',
      );
      await Navigator.push(
        ctx,
        canonicalSessionDrillRouteV1(sessionId: launchPlan.templateId),
      );
      unawaited(AchievementsEngine.instance.checkAll());
      return;
    }

    final statBefore = await TrainingPackStatsService.getStats(template.id);
    final handsBefore = await TrainingPackStatsService.getHandsCompleted(
      template.id,
    );

    if (!kDebugMode) {
      final unmet = <String>[];

      final reqAcc = template.requiredAccuracy;
      if (reqAcc != null && (statBefore?.accuracy ?? 0) * 100 < reqAcc) {
        unmet.add('достигнуть точности ${reqAcc.toStringAsFixed(0)}%');
      }

      final minHands = template.minHands;
      if (minHands != null && handsBefore < minHands) {
        unmet.add('сыграть $minHands рук');
      }

      if (template.requiresTheoryCompleted && lessonId != null) {
        final done = await TheoryLessonCompletionLogger.instance.isCompleted(
          lessonId,
        );
        if (!done) {
          unmet.add('пройти теорию');
        }
      }

      if (unmet.isNotEmpty) {
        await showDialog<void>(
          context: ctx,
          builder: (context) => AlertDialog(
            title: const Text('Пак ещё недоступен'),
            content: Text('Необходимо: ${unmet.join(', ')}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    final pack = TrainingPackV2.fromTemplate(template, template.id);

    SessionStartTimingServiceV1.instance.start(
      source: source ?? 'training_session_launcher',
    );
    await pushCanonicalLegacyTrainingV1<void>(
      ctx,
      input: CanonicalLegacyTrainingLaunchInputV1.pack(
        pack: pack,
        startIndex: startIndex,
        source: source,
        onSessionEnd: onSessionEnd == null
            ? null
            : () => onSessionEnd(TrainingSessionEndReasonV1.completed),
      ),
    );
    unawaited(AchievementsEngine.instance.checkAll());

    final statAfter = await TrainingPackStatsService.getStats(template.id);
    final handsAfter = await TrainingPackStatsService.getHandsCompleted(
      template.id,
    );
    if (template.requiredAccuracy != null || template.minHands != null) {
      await showUnlockProgressDialog(
        ctx,
        accuracyBefore: (statBefore?.accuracy ?? 0) * 100,
        accuracyAfter: (statAfter?.accuracy ?? 0) * 100,
        handsBefore: handsBefore,
        handsAfter: handsAfter,
        requiredAccuracy: template.requiredAccuracy,
        minHands: template.minHands,
      );
    }
  }

  /// Parses a YAML string and launches a session for the resulting pack.
  Future<void> launchFromYaml(
    String yaml, {
    int startIndex = 0,
    List<String>? sessionTags,
    String? source,
  }) async {
    final tpl = TrainingPackTemplateV2.fromYamlString(yaml);
    await launch(
      tpl,
      startIndex: startIndex,
      sessionTags: sessionTags,
      source: source,
    );
  }

  /// Finds and launches a booster drill relevant to [lesson].
  Future<void> launchForMiniLesson(
    TheoryMiniLessonNode lesson, {
    List<String>? sessionTags,
  }) async {
    final service = SmartRecapBoosterLauncher(
      linker: SmartRecapBoosterLinker(
        storage: TrainingPackTemplateStorageService(),
      ),
    );
    await service.launchBoosterForLesson(lesson, sessionTags: sessionTags);
  }
}

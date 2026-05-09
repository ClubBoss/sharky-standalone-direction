import 'dart:async';

import 'package:poker_analyzer/services/content_module_loader_service.dart';

import 'skill_summary_service.dart';
import 'skill_unlock_service.dart';
import 'topic_progress_service.dart';

class PlannedTopic {
  final String topicId;
  final String labelEn;
  final String labelRu;
  final String reasonTag;
  final int? streakDaysRequired;
  final double? minAccuracyRequired;

  PlannedTopic({
    required this.topicId,
    required this.labelEn,
    required this.labelRu,
    required this.reasonTag,
    this.streakDaysRequired,
    this.minAccuracyRequired,
  });
}

class NextTopicPlannerService {
  NextTopicPlannerService._privateConstructor();

  static final NextTopicPlannerService instance =
      NextTopicPlannerService._privateConstructor();

  Future<PlannedTopic?> getNextTopic() async {
    final weakTopics = SkillSummaryService.instance.getWeakTopics();
    final unlockedTopics = SkillUnlockService.instance.getUnlockedTopics();
    final now = DateTime.now();

    for (final topicId in weakTopics) {
      final progress = await TopicProgressService.instance.getTopicProgress(
        topicId,
      );
      final lastSeen = progress.seenCount > 0 ? progress.lastUpdated : null;
      if (progress.seenCount >= 2 &&
          (lastSeen == null || now.difference(lastSeen).inDays >= 4)) {
        return _buildPlannedTopic(topicId, 'mistakes', streakDaysRequired: 5);
      }
    }

    for (final topicId in weakTopics) {
      final progress = await TopicProgressService.instance.getTopicProgress(
        topicId,
      );
      if (progress.accuracy < 0.6 && progress.streak == 0) {
        return _buildPlannedTopic(
          topicId,
          'low_accuracy',
          minAccuracyRequired: 0.8,
        );
      }
    }

    for (final topicId in unlockedTopics) {
      final progress = await TopicProgressService.instance.getTopicProgress(
        topicId,
      );
      if (progress.seenCount == 0) {
        return _buildPlannedTopic(topicId, 'new_unlock');
      }
    }

    for (final topicId in unlockedTopics) {
      final progress = await TopicProgressService.instance.getTopicProgress(
        topicId,
      );
      if (progress.seenCount == 1 &&
          DateTime.now().difference(progress.lastUpdated).inDays <= 2) {
        return _buildPlannedTopic(topicId, 'fresh');
      }
    }

    for (final topicId in unlockedTopics) {
      final progress = await TopicProgressService.instance.getTopicProgress(
        topicId,
      );
      final lastSeen = progress.seenCount > 0 ? progress.lastUpdated : null;
      if (lastSeen == null || now.difference(lastSeen).inDays >= 5) {
        return _buildPlannedTopic(topicId, 'fallback');
      }
    }

    return null;
  }

  Future<PlannedTopic> _buildPlannedTopic(
    String topicId,
    String reasonTag, {
    int? streakDaysRequired,
    double? minAccuracyRequired,
  }) async {
    final labelEn = await ContentModuleLoaderService.instance.getModuleTitle(
      topicId,
      locale: 'en',
    );
    final labelRu = await ContentModuleLoaderService.instance.getModuleTitle(
      topicId,
      locale: 'ru',
    );

    return PlannedTopic(
      topicId: topicId,
      labelEn: labelEn,
      labelRu: labelRu,
      reasonTag: reasonTag,
      streakDaysRequired: streakDaysRequired,
      minAccuracyRequired: minAccuracyRequired,
    );
  }
}

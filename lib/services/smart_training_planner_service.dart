import 'post_session_review_service.dart';
import 'review_checkpoint_service.dart';
import 'weekly_skill_builder_service.dart';
import 'next_topic_planner_service.dart';

class SmartTrainingPlannerService {
  static final SmartTrainingPlannerService _instance =
      SmartTrainingPlannerService._internal();

  factory SmartTrainingPlannerService() => _instance;

  SmartTrainingPlannerService._internal();

  final PostSessionReviewService postSessionReviewService =
      PostSessionReviewService.instance;
  final ReviewCheckpointService reviewCheckpointService =
      ReviewCheckpointService.instance;
  final WeeklySkillBuilderService weeklySkillBuilderService =
      WeeklySkillBuilderService.instance;
  final NextTopicPlannerService nextTopicPlanner =
      NextTopicPlannerService.instance;

  Future<TrainingPlan?> getNextTrainingPlan() async {
    if (postSessionReviewService.shouldShowCTA()) {
      final spots = postSessionReviewService.getMistakeSpots();
      if (spots.isNotEmpty) {
        return TrainingPlan(type: 'retry', data: spots);
      }
    }

    if (await reviewCheckpointService.shouldShowCheckpoint()) {
      final topics = await reviewCheckpointService.getReviewCheckpointTopics();
      if (topics.isNotEmpty) {
        return TrainingPlan(type: 'checkpoint', data: topics.first);
      }
    }

    if (await weeklySkillBuilderService.shouldShow()) {
      final focus = await weeklySkillBuilderService.getCurrent();
      if (focus != null) {
        return TrainingPlan(type: 'weekly', data: focus.topicId);
      }
    }

    final plannedTopic = await nextTopicPlanner.getNextTopic();
    if (plannedTopic != null) {
      return TrainingPlan(type: 'next_topic', data: plannedTopic.topicId);
    }

    return null;
  }
}

class TrainingPlan {
  final String type; // "retry", "checkpoint", "weekly", "next_topic"
  final dynamic data; // id or list of spots

  TrainingPlan({required this.type, required this.data});
}

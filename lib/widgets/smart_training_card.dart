import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/analytics_service.dart';
import '../services/content_module_loader_service.dart';
import '../services/review_launcher_service.dart';
import '../services/smart_training_planner_service.dart';

class SmartTrainingCard extends StatelessWidget {
  const SmartTrainingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planFuture = SmartTrainingPlannerService().getNextTrainingPlan();

    return FutureBuilder<TrainingPlan?>(
      future: planFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final trainingPlan = snapshot.data;
        if (trainingPlan == null) return const SizedBox.shrink();

        switch (trainingPlan.type) {
          case 'retry':
            return _buildCard(
              context: context,
              title: Intl.message(
                "Let’s fix your recent mistakes",
                name: "retryTitle",
              ),
              description: '',
              onStart: () async {
                await AnalyticsService.instance.logEvent(
                  "smart_training_started",
                  {"plan_type": "retry", "module_id": null},
                );
                final ids = List<String>.from(trainingPlan.data as List);
                await ReviewLauncherService.instance.launchByIds(context, ids);
              },
            );
          case 'checkpoint':
            return _buildCard(
              context: context,
              title: Intl.message(
                "Review key concepts",
                name: "checkpointTitle",
              ),
              description: '',
              onStart: () async {
                final checkpointId = trainingPlan.data as String;
                await AnalyticsService.instance.logEvent(
                  "smart_training_started",
                  {"plan_type": "checkpoint", "module_id": checkpointId},
                );
                await ReviewLauncherService.instance.launchById(
                  context,
                  checkpointId,
                );
              },
            );
          case 'weekly':
            return _buildModuleCard(
              context: context,
              moduleId: trainingPlan.data as String,
              titleBuilder: (moduleTitle) => Intl.message(
                "Your weekly focus: $moduleTitle",
                name: "weeklyTitle",
                args: [moduleTitle],
              ),
              planType: 'weekly',
            );
          case 'next_topic':
            return _buildModuleCard(
              context: context,
              moduleId: trainingPlan.data as String,
              titleBuilder: (moduleTitle) => Intl.message(
                "Next topic: $moduleTitle",
                name: "nextTopicTitle",
                args: [moduleTitle],
              ),
              planType: 'next_topic',
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String description,
    required Future<void> Function() onStart,
  }) => Card(
    margin: const EdgeInsets.all(16.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => onStart(),
            child: Text(Intl.message("Start now", name: "startNowButton")),
          ),
        ],
      ),
    ),
  );

  Widget _buildModuleCard({
    required BuildContext context,
    required String moduleId,
    required String Function(String moduleTitle) titleBuilder,
    required String planType,
  }) => FutureBuilder<String>(
    future: ContentModuleLoaderService.instance.getModuleTitle(moduleId),
    builder: (context, snapshot) {
      final moduleTitle = snapshot.data ?? moduleId;
      return _buildCard(
        context: context,
        title: titleBuilder(moduleTitle),
        description: moduleTitle,
        onStart: () async {
          await AnalyticsService.instance.logEvent("smart_training_started", {
            "plan_type": planType,
            "module_id": moduleId,
          });
          if (planType == 'weekly') {
            await ReviewLauncherService.instance.launchById(
              context,
              moduleId,
              title: moduleTitle,
            );
          } else {
            await ReviewLauncherService.instance.launchById(
              context,
              moduleId,
              title: moduleTitle,
            );
          }
        },
      );
    },
  );
}

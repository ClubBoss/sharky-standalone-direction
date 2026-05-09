import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/topic_progress_service.dart';
import '../services/session_log_service.dart';
import '../services/topic_session_drill_planner.dart';
import '../services/content_module_loader_service.dart';
import '../services/review_launcher_service.dart';

class TopicRecapOverlay extends StatelessWidget {
  final String topicTitle;
  final int correctAnswers;
  final int totalAnswers;
  final int mistakeRate;
  final int streak;
  final DateTime? lastSuccess;
  final VoidCallback onTrainAgain;

  const TopicRecapOverlay({
    Key? key,
    required this.topicTitle,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.mistakeRate,
    required this.streak,
    this.lastSuccess,
    required this.onTrainAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accuracy = (correctAnswers / totalAnswers * 100).toStringAsFixed(1);
    final streakStatus = streak >= 3 ? '🔥' : '';
    final lastSuccessDate = lastSuccess != null
        ? DateFormat.yMMMd(Intl.getCurrentLocale()).format(lastSuccess!)
        : '-';

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.7)),
        ),
        Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    topicTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text('Accuracy: $accuracy% ($correctAnswers/$totalAnswers)'),
                  Text('Mistake Rate: $mistakeRate%'),
                  Text('Streak: $streak $streakStatus'),
                  Text('Last Success: $lastSuccessDate'),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: onTrainAgain,
                    child: Text(
                      Intl.message('Train Again', name: 'trainAgainButton'),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      final drillPlanner = TopicSessionDrillPlanner(
                        sessionLogService: SessionLogService(),
                        topicProgressService: TopicProgressService.instance,
                        contentModuleLoaderService:
                            ContentModuleLoaderService.instance,
                      );
                      final spots = drillPlanner.generateDrill(topicTitle);
                      if (spots.isNotEmpty) {
                        final ids = [for (final spot in spots) spot.id];
                        await ReviewLauncherService.instance.launchByIds(
                          context,
                          ids,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              Intl.message(
                                'No drills available',
                                name: 'noDrillsAvailable',
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      Intl.message(
                        'Try smart drill',
                        name: 'trySmartDrillButton',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

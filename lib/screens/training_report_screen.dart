import 'package:flutter/material.dart';
import '../services/session_log_service.dart';
import '../services/skill_summary_service.dart';
import '../services/weekly_loop_service.dart';
import '../services/training_report_export_service.dart';

class TrainingReportScreen extends StatelessWidget {
  TrainingReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        Localizations.localeOf(context).languageCode == 'ru'
            ? 'Ваш отчёт об обучении'
            : 'Your Training Report',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: () async {
            try {
              final file = await TrainingReportExportService.instance
                  .exportToFile();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'PDF успешно сохранён: ${file.path}'
                        : 'PDF successfully saved: ${file.path}',
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Ошибка при экспорте PDF'
                        : 'Error exporting PDF',
                  ),
                ),
              );
            }
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildSessionsCompletedSection(context),
          const SizedBox(height: 16.0),
          _buildTopicsPracticedSection(context),
          const SizedBox(height: 16.0),
          _buildSkillSummarySection(context),
          const SizedBox(height: 16.0),
          _buildLoopCompletionsSection(context),
        ],
      ),
    ),
  );

  Widget _buildSessionsCompletedSection(BuildContext context) =>
      FutureBuilder<Map<String, int>>(
        future: SessionLogService.instance.getSessionCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final counts = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Завершено сессий'
                    : 'Sessions Completed',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'За последние 7 дней: ${counts['last7Days']}'
                    : 'Last 7 days: ${counts['last7Days']}',
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'За последние 30 дней: ${counts['last30Days']}'
                    : 'Last 30 days: ${counts['last30Days']}',
              ),
            ],
          );
        },
      );

  Widget _buildTopicsPracticedSection(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: SkillSummaryService.instance.getTopPracticedTopics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final topics = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Практикуемые темы'
                    : 'Topics Practiced',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              ...topics.map(
                (topic) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(topic['name']), Text('${topic['count']}')],
                ),
              ),
            ],
          );
        },
      );

  Widget _buildSkillSummarySection(BuildContext context) =>
      FutureBuilder<Map<String, int>>(
        future: SkillSummaryService.instance.getSkillSummary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final summary = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Ваши навыки'
                    : 'Your Skill Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Сильные темы: ${summary['strong']}'
                    : 'Strong topics: ${summary['strong']}',
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Слабые темы: ${summary['weak']}'
                    : 'Weak topics: ${summary['weak']}',
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Новые темы: ${summary['new']}'
                    : 'New topics: ${summary['new']}',
              ),
            ],
          );
        },
      );

  Widget _buildLoopCompletionsSection(BuildContext context) =>
      FutureBuilder<Map<String, dynamic>>(
        future: WeeklyLoopService.instance.getLoopStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final stats = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Завершение циклов'
                    : 'Loop Completions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Текущая серия: ${stats['currentStreak']}'
                    : 'Current streak: ${stats['currentStreak']}',
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Всего за неделю: ${stats['totalThisWeek']}'
                    : 'Total this week: ${stats['totalThisWeek']}',
              ),
            ],
          );
        },
      );
}

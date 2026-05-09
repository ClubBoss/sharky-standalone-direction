import 'package:flutter/material.dart';
import '../services/skill_summary_service.dart';
import 'topic_progress_card.dart';

class TopicProgressGrid extends StatelessWidget {
  const TopicProgressGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Map<String, List<String>>>(
        future: SkillSummaryService.instance.getAllTopicsWithCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;
          final locale = Localizations.localeOf(context);

          return CustomScrollView(
            slivers: categories.entries.map((entry) {
              final category = entry.key;
              final topics = entry.value;

              String headerText;
              switch (category) {
                case 'Weak':
                  headerText = locale.languageCode == 'ru'
                      ? 'Требует практики'
                      : 'Needs Practice';
                  break;
                case 'New':
                  headerText = locale.languageCode == 'ru'
                      ? 'Новые темы'
                      : 'New Topics';
                  break;
                case 'Strong':
                  headerText = locale.languageCode == 'ru'
                      ? 'Сильные стороны'
                      : 'Strong Topics';
                  break;
                case 'NeverSeen':
                  headerText = locale.languageCode == 'ru'
                      ? 'Не изучено'
                      : 'Untouched';
                  break;
                default:
                  headerText = locale.languageCode == 'ru'
                      ? 'В процессе'
                      : 'In Progress';
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        headerText,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    );
                  }
                  final topicId = topics[index - 1];
                  return TopicProgressCard(topicId: topicId);
                }, childCount: topics.length + 1),
              );
            }).toList(),
          );
        },
      );
}

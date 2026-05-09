import 'package:flutter/material.dart';
import '../services/skill_summary_service.dart';
import '../services/content_module_loader_service.dart';
import '../widgets/topic_progress_card.dart';

class ExploreTopicsScreen extends StatefulWidget {
  ExploreTopicsScreen({Key? key}) : super(key: key);

  @override
  _ExploreTopicsScreenState createState() => _ExploreTopicsScreenState();
}

class _ExploreTopicsScreenState extends State<ExploreTopicsScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        Localizations.localeOf(context).languageCode == 'ru'
            ? 'Изучение тем'
            : 'Explore Topics',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
          },
        ),
      ],
    ),
    body: Column(
      children: [
        _buildFilterDropdown(context),
        Expanded(
          child: FutureBuilder<Map<String, List<String>>>(
            future: SkillSummaryService.instance.getAllTopicsWithCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data!;
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories.keys.elementAt(index);
                  final topics = categories[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _getCategoryLabel(context, category),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ...topics
                          .map((topicId) => _buildTopicRow(context, topicId))
                          .toList(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildFilterDropdown(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: DropdownButton<String>(
      value: filter,
      onChanged: (value) {
        setState(() {
          filter = value!;
        });
      },
      items: ['All', 'Weak', 'New', 'With Progress', 'Unseen']
          .map(
            (filter) => DropdownMenuItem(
              value: filter,
              child: Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? _getFilterLabelRu(filter)
                    : _getFilterLabelEn(filter),
              ),
            ),
          )
          .toList(),
    ),
  );

  String _getFilterLabelEn(String filter) {
    switch (filter) {
      case 'Weak':
        return 'Needs Practice';
      case 'New':
        return 'New Topics';
      case 'With Progress':
        return 'With Progress';
      case 'Unseen':
        return 'Untouched';
      default:
        return 'All';
    }
  }

  String _getFilterLabelRu(String filter) {
    switch (filter) {
      case 'Weak':
        return 'Требует практики';
      case 'New':
        return 'Новые темы';
      case 'With Progress':
        return 'С прогрессом';
      case 'Unseen':
        return 'Не изучено';
      default:
        return 'Все';
    }
  }

  String _getCategoryLabel(BuildContext context, String category) {
    final locale = Localizations.localeOf(context);
    switch (category) {
      case 'Weak':
        return locale.languageCode == 'ru'
            ? 'Требует практики'
            : 'Needs Practice';
      case 'New':
        return locale.languageCode == 'ru' ? 'Новые темы' : 'New Topics';
      case 'Strong':
        return locale.languageCode == 'ru'
            ? 'Сильные стороны'
            : 'Strong Topics';
      case 'NeverSeen':
        return locale.languageCode == 'ru' ? 'Не изучено' : 'Untouched';
      default:
        return locale.languageCode == 'ru' ? 'В процессе' : 'In Progress';
    }
  }

  Widget _buildTopicRow(BuildContext context, String topicId) =>
      FutureBuilder<String>(
        future: ContentModuleLoaderService.instance.getModuleTitle(topicId),
        builder: (context, snapshot) {
          final title = snapshot.data ?? 'Unknown Topic';

          return ListTile(
            title: Text(title),
            subtitle: TopicProgressCard(topicId: topicId),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    // Open theory page
                  },
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Теория'
                        : 'Theory',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Start drill session
                  },
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Упражнения'
                        : 'Drills',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Open quiz
                  },
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Викторина'
                        : 'Quiz',
                  ),
                ),
              ],
            ),
          );
        },
      );
}

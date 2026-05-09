import 'package:flutter/material.dart';
import '../services/onboarding_mission_service.dart';

/// Card showing onboarding mission progress with checklist.
///
/// Displays "Intro Quest X/5" with checkbox list of 5 missions.
/// Auto-hides when all missions are completed.
/// Localized for EN/RU.
class OnboardingMissionCard extends StatefulWidget {
  const OnboardingMissionCard({super.key});

  @override
  State<OnboardingMissionCard> createState() => _OnboardingMissionCardState();
}

class _OnboardingMissionCardState extends State<OnboardingMissionCard> {
  final _service = OnboardingMissionService.instance;
  bool _isLoading = true;
  int _progress = 0;
  int _total = 5;
  Map<String, bool> _missions = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await _service.init();
    if (!mounted) return;

    setState(() {
      _progress = _service.getProgress();
      _total = _service.getTotalMissions();
      _missions = _service.getAllMissions();
      _isLoading = false;
    });
  }

  String _getMissionTitle(String key, bool isRu) {
    final titles = {
      'moduleOpened': isRu
          ? 'Открыть первый модуль'
          : 'Open your first training module',
      'drillCompleted': isRu ? 'Завершить дрилл' : 'Complete a drill',
      'sessionFinished': isRu ? 'Завершить сессию' : 'Finish a session',
      'profileViewed': isRu ? 'Посмотреть профиль' : 'View your profile',
      'trophyEarned': isRu
          ? 'Получить первый трофей'
          : 'Earn your first trophy',
    };
    return titles[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Hide when all missions completed
    if (_service.isCompleted()) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode == 'ru';
    final title = isRu ? 'Вводные задания' : 'Intro Quest';
    final progressText = '$_progress/$_total';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progressText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._missions.entries.map((entry) {
              final isCompleted = entry.value;
              final missionTitle = _getMissionTitle(entry.key, isRu);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: isCompleted ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        missionTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted ? Colors.grey : null,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

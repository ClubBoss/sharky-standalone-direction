import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';
import '../services/skill_unlock_service.dart';
import '../services/skill_summary_service.dart';
import '../services/content_module_loader_service.dart';
import '../services/review_launcher_service.dart';

/// A Duolingo-style learning path widget showing user's progress through topics.
///
/// Displays:
/// - ✓ Unlocked topics (green) - tappable to launch review
/// - ⏳ Almost unlocked topics (grey) - only 1 prerequisite missing
///
/// Max 10 topics displayed (prioritizes unlocked + almost-unlocked).
/// Auto-hides if no topics to show.
///
/// **Integration:**
/// ```dart
/// const ProgressPathCard() // Add to profile_screen.dart
/// ```
class ProgressPathCard extends StatefulWidget {
  const ProgressPathCard({super.key});

  @override
  State<ProgressPathCard> createState() => _ProgressPathCardState();
}

class _ProgressPathCardState extends State<ProgressPathCard> {
  bool _loading = true;
  final List<_PathItem> _pathItems = [];
  final Map<String, String> _moduleTitles = {};
  final _unlockService = SkillUnlockService.instance;
  final _contentLoader = ContentModuleLoaderService();

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    setState(() => _loading = true);

    try {
      // Initialize services
      final skillService = SkillSummaryService.instance;
      await skillService.load();
      await _unlockService.initialize();

      // Load module titles
      await _contentLoader.initialize();
      final index = await _contentLoader.getModuleIndex();
      _moduleTitles
        ..clear()
        ..addEntries(index.map((m) => MapEntry(m.id.toLowerCase(), m.title)));

      // Build path items
      final items = <_PathItem>[];

      // Add unlocked topics (up to 5)
      final unlockedTopics = _unlockService.getUnlockedTopics().toList();
      for (final topicId in unlockedTopics.take(5)) {
        items.add(
          _PathItem(
            topicId: topicId,
            status: _PathItemStatus.unlocked,
            title: _moduleTitles[topicId.toLowerCase()] ?? topicId,
          ),
        );
      }

      // Add almost-unlocked topics (up to 5 more)
      final almostUnlocked = _unlockService.getAlmostUnlockedTopics().toList();
      for (final topicId in almostUnlocked.take(10 - items.length)) {
        final missing = _unlockService.getMissingPrerequisites(topicId);
        items.add(
          _PathItem(
            topicId: topicId,
            status: _PathItemStatus.almostUnlocked,
            title: _moduleTitles[topicId.toLowerCase()] ?? topicId,
            missingPrerequisite: missing.isNotEmpty ? missing.first : null,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _pathItems
            ..clear()
            ..addAll(items);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('ProgressPathCard load error: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Launch review for an unlocked topic.
  Future<void> _launchReview(String topicId) async {
    final titleEntry = _moduleTitles[topicId.toLowerCase()];
    if (titleEntry != null) {
      await ReviewLauncherService.instance.launchById(
        context,
        topicId,
        title: titleEntry,
      );
      return;
    }

    // Fallback: format topic as module ID
    final formatted = topicId.toLowerCase().replaceAll(' ', '_');
    await ReviewLauncherService.instance.launchById(
      context,
      formatted,
      title: topicId,
    );
  }

  /// Build a single path item.
  Widget _buildPathItem(_PathItem item, bool isEnglish) {
    final isUnlocked = item.status == _PathItemStatus.unlocked;
    final color = isUnlocked
        ? VisualThemeV3.success
        : VisualThemeV3.neutralGrey;
    final icon = isUnlocked ? Icons.check_circle : Icons.hourglass_empty;

    // Status tooltip
    String statusText;
    if (isUnlocked) {
      statusText = isEnglish ? 'Unlocked' : 'Разблокировано';
    } else {
      final missing = item.missingPrerequisite;
      final missingTitle = missing != null
          ? (_moduleTitles[missing.toLowerCase()] ?? missing)
          : '';

      if (isEnglish) {
        statusText = missing != null
            ? 'Almost there! Master: $missingTitle'
            : 'Locked';
      } else {
        statusText = missing != null
            ? 'Почти готово! Освойте: $missingTitle'
            : 'Заблокировано';
      }
    }

    final itemWidget = ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isUnlocked
              ? VisualThemeV3.textPrimaryLight
              : VisualThemeV3.neutralGrey,
        ),
      ),
      subtitle: Text(
        statusText,
        style: const TextStyle(fontSize: 12, color: VisualThemeV3.neutralGrey),
      ),
      trailing: isUnlocked
          ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: VisualThemeV3.neutralGrey,
            )
          : null,
      onTap: isUnlocked ? () => _launchReview(item.topicId) : null,
      enabled: isUnlocked,
      dense: true,
    );

    return itemWidget;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Auto-hide if no items
    if (!_loading && _pathItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  size: 24,
                  color: Colors.deepPurple.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  isEnglish ? 'Your Progress Path' : 'Ваш путь прогресса',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isEnglish
                  ? 'Next steps in your learning journey'
                  : 'Следующие шаги в вашем обучении',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Loading state
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Path items
            if (!_loading && _pathItems.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pathItems.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) =>
                    _buildPathItem(_pathItems[index], isEnglish),
              ),

            // Empty state
            if (!_loading && _pathItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    isEnglish
                        ? 'No topics available yet'
                        : 'Темы пока недоступны',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Internal model for a path item.
class _PathItem {
  final String topicId;
  final _PathItemStatus status;
  final String title;
  final String? missingPrerequisite;

  _PathItem({
    required this.topicId,
    required this.status,
    required this.title,
    this.missingPrerequisite,
  });
}

/// Status of a path item.
enum _PathItemStatus { unlocked, almostUnlocked }

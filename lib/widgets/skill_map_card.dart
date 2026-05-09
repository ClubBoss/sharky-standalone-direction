import 'package:flutter/material.dart';
import '../services/skill_summary_service.dart';
import '../services/review_launcher_service.dart';
import '../services/content_module_loader_service.dart';
import '../services/skill_unlock_service.dart';

/// A card widget that visualizes the user's complete skill map as a grid.
///
/// Displays topics color-coded by category:
/// - Green: Strong topics (≥3 correct, 0 mistakes)
/// - Red: Weak topics (≥2 mistakes)
/// - Blue: New topics (first seen in last 7 days)
/// - Grey: Never seen topics (0 correct, 0 mistakes)
/// - Locked: Grey with lock icon (prerequisites not mastered)
///
/// Tapping a chip launches a review session for that topic.
/// Locked topics show a tooltip explaining unlock requirements.
/// Auto-hides if all categories are empty.
class SkillMapCard extends StatefulWidget {
  const SkillMapCard({super.key});

  @override
  State<SkillMapCard> createState() => _SkillMapCardState();
}

class _SkillMapCardState extends State<SkillMapCard> {
  bool _loading = true;
  Map<String, String> _topicsWithCategories = {};
  final Map<String, String> _moduleTitles = {};
  final Map<String, bool> _unlockStatus = {};
  final _contentLoader = ContentModuleLoaderService();
  final _unlockService = SkillUnlockService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final skillService = SkillSummaryService.instance;
      await skillService.load();
      final categories = skillService.getAllTopicsWithCategories();

      // Initialize unlock service
      await _unlockService.initialize();

      // Load module index for title resolution
      await _contentLoader.initialize();
      final index = await _contentLoader.getModuleIndex();
      _moduleTitles
        ..clear()
        ..addEntries(index.map((m) => MapEntry(m.id.toLowerCase(), m.title)));

      // Determine unlock status for all topics
      _unlockStatus.clear();
      for (final topicId in categories.keys) {
        _unlockStatus[topicId] = _unlockService.isUnlocked(topicId);
      }

      if (mounted) {
        setState(() {
          _topicsWithCategories = categories;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('SkillMapCard load error: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Get color for a category.
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'strong':
        return Colors.green.shade600;
      case 'weak':
        return Colors.red.shade600;
      case 'new':
        return Colors.blue.shade600;
      case 'neverSeen':
        return Colors.grey.shade400;
      case 'neutral':
      default:
        return Colors.orange.shade400;
    }
  }

  /// Get localized label for a category.
  String _getCategoryLabel(String category, bool isEnglish) {
    switch (category) {
      case 'strong':
        return isEnglish ? 'Strong' : 'Сильные';
      case 'weak':
        return isEnglish ? 'Needs Practice' : 'Требуют практики';
      case 'new':
        return isEnglish ? 'New' : 'Новые';
      case 'neverSeen':
        return isEnglish ? 'Not Started' : 'Не начаты';
      case 'neutral':
      default:
        return isEnglish ? 'Learning' : 'В процессе';
    }
  }

  /// Launch review session for a topic.
  Future<void> _launchReview(String topicId) async {
    // Check if topic is locked
    final isLocked = !(_unlockStatus[topicId] ?? true);
    if (isLocked) {
      // Show tooltip with unlock requirements
      if (!mounted) return;
      final missing = _unlockService.getMissingPrerequisites(topicId);
      final missingText = missing.join(', ');
      final isEnglish = Localizations.localeOf(context).languageCode == 'en';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish
                ? 'Locked: Master $missingText first'
                : 'Заблокировано: сначала освойте $missingText',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Try exact match with module titles
    final titleEntry = _moduleTitles[topicId.toLowerCase()];
    if (titleEntry != null) {
      await ReviewLauncherService.instance.launchById(
        context,
        topicId,
        title: titleEntry,
      );
      return;
    }

    // Search for module by name
    final results = await _contentLoader.searchModules(topicId);
    if (results.isNotEmpty) {
      final first = results.first;
      await ReviewLauncherService.instance.launchById(
        context,
        first.id,
        title: first.title,
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

  /// Build a chip for a topic.
  Widget _buildChip(String topicId, String category, bool isEnglish) {
    final isLocked = !(_unlockStatus[topicId] ?? true);
    final color = isLocked ? Colors.grey.shade400 : _getCategoryColor(category);

    // Get module title from cached map
    final title = _moduleTitles[topicId.toLowerCase()] ?? topicId;

    // Get unlock description for tooltip
    final unlockDesc = isLocked
        ? _unlockService.getUnlockDescription(topicId, isEnglish: isEnglish)
        : null;

    final chipWidget = InkWell(
      onTap: () => _launchReview(topicId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isLocked ? 0.1 : 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: isLocked ? 1.0 : 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLocked) ...[
                Icon(Icons.lock, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with tooltip if locked
    if (isLocked && unlockDesc != null) {
      return Tooltip(message: unlockDesc, child: chipWidget);
    }

    return chipWidget;
  }

  /// Build legend row.
  Widget _buildLegend(bool isEnglish) {
    final categories = ['strong', 'weak', 'new', 'neverSeen', 'neutral'];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: categories.map((cat) {
        final color = _getCategoryColor(cat);
        final label = _getCategoryLabel(cat, isEnglish);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Auto-hide if no data
    if (!_loading && _topicsWithCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 3;

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
                  Icons.grid_view_rounded,
                  size: 24,
                  color: Colors.deepPurple.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  isEnglish ? 'Your Skill Map' : 'Карта навыков',
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
                  ? 'Tap any topic to practice'
                  : 'Нажмите на любую тему для практики',
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

            // Grid
            if (!_loading && _topicsWithCategories.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.0,
                ),
                itemCount: _topicsWithCategories.length,
                itemBuilder: (context, index) {
                  final topic = _topicsWithCategories.keys.elementAt(index);
                  final category = _topicsWithCategories[topic]!;
                  return _buildChip(topic, category, isEnglish);
                },
              ),

            // Legend
            if (!_loading && _topicsWithCategories.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildLegend(isEnglish),
            ],
          ],
        ),
      ),
    );
  }
}

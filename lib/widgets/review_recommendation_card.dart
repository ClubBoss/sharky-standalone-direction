import 'package:flutter/material.dart';
import '../services/auto_review_service.dart';
import '../services/content_module_loader_service.dart';
import '../services/review_launcher_service.dart';
import '../screens/module_catalog_screen.dart';

/// Card showing top 3 review module recommendations from AutoReviewService.
///
/// Displays modules that need review based on:
/// - Staleness (completed ≥7 days ago)
/// - Failures (2+ mistakes in practice)
/// - Never-seen (cold start fallback)
///
/// Auto-hides when no candidates exist. Supports EN/RU localization.
class ReviewRecommendationCard extends StatefulWidget {
  const ReviewRecommendationCard({super.key});

  @override
  State<ReviewRecommendationCard> createState() =>
      _ReviewRecommendationCardState();
}

class _ReviewRecommendationCardState extends State<ReviewRecommendationCard> {
  final _service = AutoReviewService.instance;
  final _contentLoader = ContentModuleLoaderService();
  final _launcher = ReviewLauncherService.instance;
  bool _isLoading = true;
  List<AutoReviewCandidate> _candidates = [];
  Map<String, String> _moduleTitles = {};

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      // Load candidates and module metadata
      final candidates = await _service.getReviewCandidates();
      await _contentLoader.initialize();
      final allModules = await _contentLoader.getModuleIndex();

      // Create title lookup map
      final titleMap = <String, String>{};
      for (final module in allModules) {
        titleMap[module.id] = module.title;
      }

      if (!mounted) return;

      setState(() {
        _candidates = candidates.take(3).toList(); // Top 3 only
        _moduleTitles = titleMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _candidates = [];
        _moduleTitles = {};
        _isLoading = false;
      });
    }
  }

  String _getSourceLabel(AutoReviewSource source, bool isRu) {
    switch (source) {
      case AutoReviewSource.stale:
        return isRu ? 'Не повторяли давно' : 'Not reviewed recently';
      case AutoReviewSource.failed:
        return isRu ? 'Нужна практика' : 'Needs practice';
      case AutoReviewSource.neverSeen:
        return isRu ? 'Новый материал' : 'New material';
    }
  }

  String _getStalenessInfo(AutoReviewCandidate candidate, bool isRu) {
    if (candidate.source == AutoReviewSource.failed &&
        candidate.failureCount > 0) {
      final mistakes = candidate.failureCount;
      return isRu ? '$mistakes ошибок' : '$mistakes mistakes';
    }

    if (candidate.lastCompletedAt != null) {
      final daysSince = DateTime.now()
          .difference(candidate.lastCompletedAt!)
          .inDays;
      if (daysSince > 0) {
        return isRu ? '$daysSince дней назад' : '$daysSince days ago';
      }
    }

    return isRu ? 'Еще не изучали' : 'Not studied yet';
  }

  Color _getSourceColor(AutoReviewSource source) {
    switch (source) {
      case AutoReviewSource.failed:
        return Colors.orange;
      case AutoReviewSource.stale:
        return Colors.blue;
      case AutoReviewSource.neverSeen:
        return Colors.grey;
    }
  }

  IconData _getSourceIcon(AutoReviewSource source) {
    switch (source) {
      case AutoReviewSource.failed:
        return Icons.refresh;
      case AutoReviewSource.stale:
        return Icons.schedule;
      case AutoReviewSource.neverSeen:
        return Icons.fiber_new;
    }
  }

  void _openModule(String moduleId) {
    // Option 1: Open module detail screen for preview
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ModuleDetailScreen(moduleId: moduleId)),
    );
  }

  void _launchReview(String moduleId) {
    // Option 2: Launch review session directly
    final title = _moduleTitles[moduleId] ?? _formatModuleId(moduleId);
    _launcher.launchSingle(
      context,
      ReviewModuleEntry(moduleId: moduleId, title: title),
    );
  }

  void _reviewAll() {
    // Launch multi-module review session
    final entries = _candidates.map((c) {
      final title = _moduleTitles[c.moduleId] ?? _formatModuleId(c.moduleId);
      return ReviewModuleEntry(moduleId: c.moduleId, title: title);
    }).toList();

    _launcher.launchMultiple(context, entries);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Hide when no candidates
    if (_candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode == 'ru';
    final title = isRu
        ? 'Рекомендации для повторения'
        : 'Recommended for Review';

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
                Icon(
                  Icons.auto_awesome,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
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
              ],
            ),
            const SizedBox(height: 16),
            ..._candidates.map((candidate) {
              final sourceLabel = _getSourceLabel(candidate.source, isRu);
              final stalenessInfo = _getStalenessInfo(candidate, isRu);
              final sourceColor = _getSourceColor(candidate.source);
              final sourceIcon = _getSourceIcon(candidate.source);
              final title =
                  _moduleTitles[candidate.moduleId] ??
                  _formatModuleId(candidate.moduleId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _launchReview(candidate.moduleId),
                  onLongPress: () => _openModule(candidate.moduleId),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(sourceIcon, color: sourceColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    sourceLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: sourceColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    stalenessInfo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reviewAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isRu ? 'Повторить все' : 'Review All',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format module ID for display (convert snake_case to Title Case)
  String _formatModuleId(String moduleId) => moduleId
      .split('_')
      .map(
        (word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}

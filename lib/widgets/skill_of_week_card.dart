import 'package:flutter/material.dart';
import '../services/weekly_skill_builder_service.dart';
import '../services/content_module_loader_service.dart';
import '../services/review_launcher_service.dart';

/// Displays the "Skill of the Week" - a weekly focus topic recommendation
/// that nudges users toward key improvement areas.
///
/// **Features:**
/// - Shows one weak/new topic per 7-day cycle
/// - Displays topic name with module title when available
/// - "Start Drill" CTA launches review via ReviewLauncherService
/// - Dismissible (user can skip this week's recommendation)
/// - Auto-hides when dismissed or no focus available
///
/// **Integration:**
/// ```dart
/// SkillOfWeekCard(), // Add to training_home_screen.dart
/// ```
class SkillOfWeekCard extends StatefulWidget {
  const SkillOfWeekCard({super.key});

  @override
  State<SkillOfWeekCard> createState() => _SkillOfWeekCardState();
}

class _SkillOfWeekCardState extends State<SkillOfWeekCard> {
  bool _loading = true;
  WeeklySkillFocus? _focus;
  String? _topicTitle;
  int _daysRemaining = 0;

  final _contentLoader = ContentModuleLoaderService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final service = WeeklySkillBuilderService.instance;
      await service.initialize();

      final shouldShow = await service.shouldShow();
      if (!shouldShow) {
        setState(() => _loading = false);
        return;
      }

      final focus = await service.getCurrent();
      if (focus == null) {
        setState(() => _loading = false);
        return;
      }

      // Load module title
      await _contentLoader.initialize();
      final index = await _contentLoader.getModuleIndex();
      final metadata = index.firstWhere(
        (m) => m.id.toLowerCase() == focus.topicId.toLowerCase(),
        orElse: () => ModuleMetadata(
          id: focus.topicId,
          title: _formatTopicId(focus.topicId),
          category: '',
          uri: '',
        ),
      );

      final daysRemaining = await service.getDaysRemaining();

      setState(() {
        _focus = focus;
        _topicTitle = metadata.title;
        _daysRemaining = daysRemaining;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _startDrill() async {
    if (_focus == null) return;

    final title = _topicTitle ?? _formatTopicId(_focus!.topicId);
    await ReviewLauncherService.instance.launchById(
      context,
      _focus!.topicId,
      title: title,
    );
  }

  Future<void> _dismiss() async {
    await WeeklySkillBuilderService.instance.markDismissed();
    setState(() {
      _focus = null;
    });
  }

  String _formatTopicId(String topicId) => topicId
      .split('_')
      .map(
        (word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    // Hide card if loading or no focus
    if (_loading || _focus == null) {
      return const SizedBox.shrink();
    }

    final title = isRu ? 'Навык недели' : 'Skill of the Week';
    final startLabel = isRu ? 'Начать тренировку' : 'Start Drill';
    final daysLabel = isRu
        ? '$_daysRemaining ${_pluralizeDays(_daysRemaining, isRu)}'
        : '$_daysRemaining ${_pluralizeDays(_daysRemaining, isRu)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.deepPurple.shade900.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dismiss button
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_daysRemaining > 0)
                        Text(
                          daysLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white54,
                  ),
                  onPressed: _dismiss,
                  tooltip: isRu ? 'Пропустить' : 'Dismiss',
                  constraints: const BoxConstraints(
                    maxHeight: 32,
                    maxWidth: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Topic name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school,
                    size: 18,
                    color: Colors.purpleAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _topicTitle ?? _formatTopicId(_focus!.topicId),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // CTA button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startDrill,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(startLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pluralizeDays(int days, bool isRu) {
    if (!isRu) {
      return days == 1 ? 'day left' : 'days left';
    }
    // Russian pluralization
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день осталось';
    } else if (days % 10 >= 2 &&
        days % 10 <= 4 &&
        (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня осталось';
    } else {
      return 'дней осталось';
    }
  }
}

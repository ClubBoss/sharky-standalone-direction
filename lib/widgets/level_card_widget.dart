import 'package:flutter/material.dart';
import '../services/leveling_service.dart';
import '../services/xp_service.dart';
import '../models/xp_trophy.dart';

/// Card widget showing player level and progress to next level.
class LevelCardWidget extends StatefulWidget {
  const LevelCardWidget({super.key});

  @override
  State<LevelCardWidget> createState() => _LevelCardWidgetState();
}

class _LevelCardWidgetState extends State<LevelCardWidget> {
  final _levelingService = LevelingService.instance;
  late final _xpService = XpService();
  late int _currentXp;
  late int _currentLevel;
  late double _progress;
  late int _xpInLevel;
  late int _xpRequired;

  @override
  void initState() {
    super.initState();
    _updateValues();
    _xpService.watchTotalXp().listen((_) {
      if (mounted) {
        setState(_updateValues);
      }
    });
  }

  void _updateValues() {
    _currentXp = _xpService.getTotalXp();
    _currentLevel = _levelingService.getLevel(_currentXp);
    _progress = _levelingService.getProgressToNextLevel(_currentXp);
    _xpInLevel = _levelingService.getXpInCurrentLevel(_currentXp);
    _xpRequired = _levelingService.getXpRequiredForNextLevel(_currentXp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    final isMilestone = _levelingService.isMilestoneLevel(_currentLevel);
    final nextMilestone = _levelingService.getNextMilestone(_currentLevel);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Level badge and title
            Row(
              children: [
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _levelingService.formatLevel(_currentLevel, isRu: isRu),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    isRu ? 'Уровень игрока' : 'Player Level',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Milestone trophy indicator
                if (isMilestone)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRu ? 'Прогресс' : 'Progress',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '$_xpInLevel / $_xpRequired XP',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Next milestone indicator (if applicable)
            if (nextMilestone != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isRu
                            ? 'Следующая награда: Уровень $nextMilestone'
                            : 'Next trophy: Level $nextMilestone',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${_levelingService.getXpForLevel(nextMilestone) - _currentXp} XP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Current milestone trophy (if on milestone)
            if (isMilestone) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.2),
                      Colors.orange.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRu
                                ? '🎉 Награда получена!'
                                : '🎉 Trophy Unlocked!',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getTrophyTitle(_currentLevel, isRu: isRu),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTrophyTitle(int level, {required bool isRu}) {
    final trophy = _getTrophyForLevel(level);
    if (trophy == null) return '';
    return trophy.title(isRu: isRu);
  }

  XpTrophy? _getTrophyForLevel(int level) {
    switch (level) {
      case 1:
        return XpTrophy.level1;
      case 5:
        return XpTrophy.level5;
      case 10:
        return XpTrophy.level10;
      case 25:
        return XpTrophy.level25;
      case 50:
        return XpTrophy.level50;
      case 100:
        return XpTrophy.level100;
      default:
        return null;
    }
  }
}

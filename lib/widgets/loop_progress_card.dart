import 'package:flutter/material.dart';
import 'package:poker_analyzer/qa/learning_loop_validator.dart';

import '../infra/telemetry.dart';
import '../models/xp_trophy.dart';
import '../services/xp_trophy_service.dart';

class LoopProgressCard extends StatefulWidget {
  final String initialTopic;
  final String targetUnlock;
  final int sessionCount;
  final int loopsCompletedThisWeek;
  final Locale locale;

  const LoopProgressCard({
    Key? key,
    required this.initialTopic,
    required this.targetUnlock,
    this.sessionCount = 3,
    this.loopsCompletedThisWeek = 0,
    required this.locale,
  }) : super(key: key);

  @override
  State<LoopProgressCard> createState() => _LoopProgressCardState();
}

class _LoopProgressCardState extends State<LoopProgressCard> {
  late Future<ValidationResult> _validationFuture;

  @override
  void initState() {
    super.initState();
    _validationFuture = LearningLoopValidator().validateLoop(
      initialTopic: widget.initialTopic,
      targetUnlock: widget.targetUnlock,
      sessionCount: widget.sessionCount,
    );
  }

  void _refresh() {
    setState(() {
      _validationFuture = LearningLoopValidator().validateLoop(
        initialTopic: widget.initialTopic,
        targetUnlock: widget.targetUnlock,
        sessionCount: widget.sessionCount,
      );
    });
  }

  String _getMedalAsset(int count) {
    if (count >= 3) return '🥇';
    if (count == 2) return '🥈';
    if (count == 1) return '🥉';
    return '';
  }

  String _localized(String en, String ru) =>
      widget.locale.languageCode == 'ru' ? ru : en;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<ValidationResult>(
        future: _validationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(
                  _localized(
                    'Checking learning loop...',
                    'Проверка цикла обучения...',
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Text(
              _localized(
                'Unable to load loop status.',
                'Не удалось загрузить статус цикла.',
              ),
            );
          }
          final result = snapshot.data!;
          final medal = _getMedalAsset(widget.loopsCompletedThisWeek);
          final stages = result.stages;
          final failedStage = stages.entries
              .firstWhere(
                (e) => !e.value,
                orElse: () => const MapEntry('', true),
              )
              .key;
          final isBlocked = !result.isValid && failedStage == 'review_system';
          final isComplete = result.isValid && result.allStagesPassed;

          if (isComplete) {
            // Log completion to TrophyService
            final trophyService = XpTrophyService.instance;
            if (widget.loopsCompletedThisWeek >= 3) {
              trophyService.unlock(XpTrophy.weeklyWarriorGold);
            } else if (widget.loopsCompletedThisWeek == 2) {
              trophyService.unlock(XpTrophy.weeklyWarriorSilver);
            } else if (widget.loopsCompletedThisWeek == 1) {
              trophyService.unlock(XpTrophy.weeklyWarriorBronze);
            }

            // Log telemetry
            Telemetry.logEvent('learning_loop_completed', {
              'loops_completed': widget.loopsCompletedThisWeek,
              'locale': widget.locale.languageCode,
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (medal.isNotEmpty)
                    Text(medal, style: const TextStyle(fontSize: 28)),
                  if (medal.isNotEmpty) const SizedBox(width: 8),
                  Text(
                    _localized(
                      'Learning Loop Progress',
                      'Прогресс цикла обучения',
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: _localized('Refresh', 'Обновить'),
                    onPressed: _refresh,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isComplete)
                Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _localized(
                          'New skill unlocked! Great job!',
                          'Навык разблокирован!',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                )
              else if (isBlocked)
                Row(
                  children: [
                    const Text('❌', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _localized(
                          'You still need to review mistakes',
                          'Нужно повторить ошибки',
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          _localized('Loop in progress', 'Цикл в процессе'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          stages.values.where((v) => v).length / stages.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: stages.keys.map((stage) {
                        final passed = stages[stage] ?? false;
                        final icon = passed ? '✓' : '…';
                        final label = _localized(
                          _stageLabelEn(stage),
                          _stageLabelRu(stage),
                        );
                        return Chip(
                          label: Text('$icon $label'),
                          backgroundColor: passed
                              ? Colors.green[100]
                              : Colors.grey[300],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                _localized(
                  'Loops completed this week:',
                  'Циклов завершено на этой неделе:',
                ),
                style: const TextStyle(fontSize: 14),
              ),
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        i < widget.loopsCompletedThisWeek
                            ? _getMedalAsset(i + 1)
                            : '⬜',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );

  String _stageLabelEn(String stage) {
    switch (stage) {
      case 'session_tracking':
        return 'Session';
      case 'review_system':
        return 'Review';
      case 'mastery':
        return 'Mastery';
      case 'unlock':
        return 'Unlock';
      case 'path_update':
        return 'Path';
      default:
        return stage;
    }
  }

  String _stageLabelRu(String stage) {
    switch (stage) {
      case 'session_tracking':
        return 'Сессия';
      case 'review_system':
        return 'Повторение';
      case 'mastery':
        return 'Мастерство';
      case 'unlock':
        return 'Разблокировка';
      case 'path_update':
        return 'Путь';
      default:
        return stage;
    }
  }
}

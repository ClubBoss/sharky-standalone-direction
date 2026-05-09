import 'package:flutter/material.dart';

/// Future-friendly set of XP trophies and their unlocked entries.
@immutable
class XpTrophyEntry {
  final XpTrophy type;
  final DateTime achievedAt;

  const XpTrophyEntry({required this.type, required this.achievedAt});

  /// Backwards-friendly alias used elsewhere in the codebase.
  XpTrophy get trophy => type;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory XpTrophyEntry.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final achieved = json['achievedAt'] as String?;
    if (typeName == null || achieved == null) {
      throw ArgumentError('Invalid XpTrophyEntry json: $json');
    }
    return XpTrophyEntry(
      type: XpTrophy.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => throw ArgumentError('Unknown XpTrophy: $typeName'),
      ),
      achievedAt: DateTime.parse(achieved),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XpTrophyEntry &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          achievedAt == other.achievedAt;

  @override
  int get hashCode => Object.hash(type, achievedAt);
}

/// NOTE: enums are append-only — new entries are added at the end.
enum XpTrophy {
  // Existing/legacy trophies
  streak10,
  weekly50,
  milestone1000,

  // Newly added trophies (append-only)
  firstXp,
  milestone25,
  weekly5,
  comeback,
  streak3,
  firstModule,
  tenDrills,
  theoryReader,
  streak7,
  perfectWeek,
  weeklyChampion, // Weekly Challenge completion trophy
  xp1000, // 1,000 total XP milestone
  xp5000, // 5,000 total XP milestone
  xp10000, // 10,000 total XP milestone
  streakMaster, // 7-day session streak
  // Challenge trophies (append-only)
  dailyGrinderBronze,
  dailyGrinderSilver,
  dailyGrinderGold,
  weeklyWarriorBronze,
  weeklyWarriorSilver,
  weeklyWarriorGold,
  challengeMasterBronze,
  challengeMasterSilver,
  challengeMasterGold,
  // Level milestone trophies (append-only)
  level1,
  level5,
  level10,
  level25,
  level50,
  level100,
  // Onboarding trophy (append-only)
  introComplete;

  /// Convenience getter returning every trophy.
  static List<XpTrophy> get all => List.unmodifiable(values);
}

class _XpTrophyMeta {
  const _XpTrophyMeta({
    required this.trophy,
    required this.iconName,
    required this.titleEn,
    required this.titleRu,
    required this.descriptionEn,
    required this.descriptionRu,
  });

  final XpTrophy trophy;
  final String iconName;
  final String titleEn;
  final String titleRu;
  final String descriptionEn;
  final String descriptionRu;
}

const List<_XpTrophyMeta> _trophyMetadata = [
  _XpTrophyMeta(
    trophy: XpTrophy.streak10,
    iconName: 'emoji_events',
    titleEn: '10-day streak',
    titleRu: 'Серия 10',
    descriptionEn: '',
    descriptionRu: '',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.weekly50,
    iconName: 'emoji_events',
    titleEn: '50 XP this week',
    titleRu: '50 XP за неделю',
    descriptionEn: '',
    descriptionRu: '',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.milestone1000,
    iconName: 'emoji_events',
    titleEn: '1,000 XP milestone',
    titleRu: '1000 XP достигнуто',
    descriptionEn: '',
    descriptionRu: '',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.firstXp,
    iconName: 'emoji_events',
    titleEn: 'First XP',
    titleRu: 'Первый XP',
    descriptionEn: 'You earned your first XP',
    descriptionRu: 'Вы получили первый XP',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.milestone25,
    iconName: 'emoji_events',
    titleEn: '25 XP milestone',
    titleRu: 'Веха 25 XP',
    descriptionEn: 'Reach 25 total XP',
    descriptionRu: 'Достигните 25 XP',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.weekly5,
    iconName: 'emoji_events',
    titleEn: '5 XP this week',
    titleRu: '5 XP за неделю',
    descriptionEn: 'Earn 5 XP within a week',
    descriptionRu: 'Заработайте 5 XP за неделю',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.comeback,
    iconName: 'emoji_events',
    titleEn: 'Comeback',
    titleRu: 'Возвращение',
    descriptionEn: 'Gained XP after a 5+ day break',
    descriptionRu: 'Вернулись после паузы',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.streak3,
    iconName: 'emoji_events',
    titleEn: '3-day streak',
    titleRu: 'Серия 3',
    descriptionEn: 'Keep a 3-day streak',
    descriptionRu: 'Серия 3 дня',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.firstModule,
    iconName: 'emoji_events',
    titleEn: 'First Module Completed',
    titleRu: 'Первый модуль завершен',
    descriptionEn: 'Finish your first training module',
    descriptionRu: 'Завершите первый модуль тренировок',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.tenDrills,
    iconName: 'emoji_events',
    titleEn: 'Ten Drills Completed',
    titleRu: 'Десять дриллов завершено',
    descriptionEn: 'Complete ten drills across any packs',
    descriptionRu: 'Завершите десять дриллов в любых паках',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.theoryReader,
    iconName: 'emoji_events',
    titleEn: 'Read 3 Theory Lessons',
    titleRu: 'Прочтите 3 теоретических урока',
    descriptionEn: 'Finish three theory lessons',
    descriptionRu: 'Прочтите три теоретических урока',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.streak7,
    iconName: 'emoji_events',
    titleEn: 'One Week Streak',
    titleRu: 'Семь дней подряд',
    descriptionEn: 'Maintain activity for seven days in a row',
    descriptionRu: 'Держите активность семь дней подряд',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.perfectWeek,
    iconName: 'emoji_events',
    titleEn: 'Perfect Week',
    titleRu: 'Идеальная неделя',
    descriptionEn: 'Earn XP every day for 7 days',
    descriptionRu: 'Заработай XP каждый день в течение 7 дней',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.weeklyChampion,
    iconName: 'emoji_events',
    titleEn: 'Weekly Champion',
    titleRu: 'Чемпион недели',
    descriptionEn: 'Complete the weekly challenge',
    descriptionRu: 'Завершите еженедельный вызов',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.xp1000,
    iconName: 'emoji_events',
    titleEn: '1,000 XP Milestone',
    titleRu: 'Веха 1000 XP',
    descriptionEn: 'Reach 1,000 total XP',
    descriptionRu: 'Достигните 1000 XP',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.xp5000,
    iconName: 'emoji_events',
    titleEn: '5,000 XP Milestone',
    titleRu: 'Веха 5000 XP',
    descriptionEn: 'Reach 5,000 total XP',
    descriptionRu: 'Достигните 5000 XP',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.xp10000,
    iconName: 'emoji_events',
    titleEn: '10,000 XP Milestone',
    titleRu: 'Веха 10000 XP',
    descriptionEn: 'Reach 10,000 total XP',
    descriptionRu: 'Достигните 10000 XP',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.streakMaster,
    iconName: 'whatshot',
    titleEn: 'Streak Master',
    titleRu: 'Мастер серии',
    descriptionEn: 'Maintain a 7-day consecutive session streak',
    descriptionRu: 'Поддерживайте 7-дневную серию сессий подряд',
  ),
  // Challenge trophies
  _XpTrophyMeta(
    trophy: XpTrophy.dailyGrinderBronze,
    iconName: 'emoji_events',
    titleEn: 'Daily Grinder 🥉',
    titleRu: 'Дневной трудяга 🥉',
    descriptionEn: 'Complete 7 daily challenges',
    descriptionRu: 'Завершите 7 дневных вызовов',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.dailyGrinderSilver,
    iconName: 'emoji_events',
    titleEn: 'Daily Grinder 🥈',
    titleRu: 'Дневной трудяга 🥈',
    descriptionEn: 'Complete 30 daily challenges',
    descriptionRu: 'Завершите 30 дневных вызовов',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.dailyGrinderGold,
    iconName: 'emoji_events',
    titleEn: 'Daily Grinder 🥇',
    titleRu: 'Дневной трудяга 🥇',
    descriptionEn: 'Complete 100 daily challenges',
    descriptionRu: 'Завершите 100 дневных вызовов',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.weeklyWarriorBronze,
    iconName: 'emoji_events',
    titleEn: 'Weekly Warrior 🥉',
    titleRu: 'Недельный воин 🥉',
    descriptionEn: 'Complete 4 weekly challenges',
    descriptionRu: 'Завершите 4 недельных вызова',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.weeklyWarriorSilver,
    iconName: 'emoji_events',
    titleEn: 'Weekly Warrior 🥈',
    titleRu: 'Недельный воин 🥈',
    descriptionEn: 'Complete 12 weekly challenges',
    descriptionRu: 'Завершите 12 недельных вызовов',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.weeklyWarriorGold,
    iconName: 'emoji_events',
    titleEn: 'Weekly Warrior 🥇',
    titleRu: 'Недельный воин 🥇',
    descriptionEn: 'Complete 52 weekly challenges',
    descriptionRu: 'Завершите 52 недельных вызова',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.challengeMasterBronze,
    iconName: 'emoji_events',
    titleEn: 'Challenge Master 🥉',
    titleRu: 'Мастер вызовов 🥉',
    descriptionEn: 'Complete 10 challenges of any type',
    descriptionRu: 'Завершите 10 вызовов любого типа',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.challengeMasterSilver,
    iconName: 'emoji_events',
    titleEn: 'Challenge Master 🥈',
    titleRu: 'Мастер вызовов 🥈',
    descriptionEn: 'Complete 50 challenges of any type',
    descriptionRu: 'Завершите 50 вызовов любого типа',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.challengeMasterGold,
    iconName: 'emoji_events',
    titleEn: 'Challenge Master 🥇',
    titleRu: 'Мастер вызовов 🥇',
    descriptionEn: 'Complete 200 challenges of any type',
    descriptionRu: 'Завершите 200 вызовов любого типа',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.level1,
    iconName: 'emoji_events',
    titleEn: 'Level 1 🏆',
    titleRu: 'Уровень 1 🏆',
    descriptionEn: 'Reached level 1',
    descriptionRu: 'Достигнут уровень 1',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.level5,
    iconName: 'emoji_events',
    titleEn: 'Level 5 🏆',
    titleRu: 'Уровень 5 🏆',
    descriptionEn: 'Reached level 5',
    descriptionRu: 'Достигнут уровень 5',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.level10,
    iconName: 'emoji_events',
    titleEn: 'Level 10 🏆',
    titleRu: 'Уровень 10 🏆',
    descriptionEn: 'Reached level 10',
    descriptionRu: 'Достигнут уровень 10',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.level25,
    iconName: 'emoji_events',
    titleEn: 'Level 25 🏆',
    titleRu: 'Уровень 25 🏆',
    descriptionEn: 'Reached level 25',
    descriptionRu: 'Достигнут уровень 25',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.level50,
    iconName: 'emoji_events',
    titleEn: 'Level 50 🏆',
    titleRu: 'Уровень 50 🏆',
    descriptionEn: 'Reached level 50',
    descriptionRu: 'Достигнут уровень 50',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.level100,
    iconName: 'emoji_events',
    titleEn: 'Level 100 🏆',
    titleRu: 'Уровень 100 🏆',
    descriptionEn: 'Reached level 100',
    descriptionRu: 'Достигнут уровень 100',
  ),
  _XpTrophyMeta(
    trophy: XpTrophy.introComplete,
    iconName: 'emoji_events',
    titleEn: 'Intro Complete 🎓',
    titleRu: 'Введение завершено 🎓',
    descriptionEn: 'Complete all 5 onboarding quests',
    descriptionRu: 'Завершите все 5 начальных заданий',
  ),
];

extension XpTrophyMetaExt on XpTrophy {
  _XpTrophyMeta get _meta =>
      _trophyMetadata.firstWhere((m) => m.trophy == this);

  String get iconName => _meta.iconName;
  String get titleEn => _meta.titleEn;
  String get titleRu => _meta.titleRu;
  String get descEn => _meta.descriptionEn;
  String get descRu => _meta.descriptionRu;

  IconData icon() => Icons.emoji_events;

  String title({required bool isRu}) => isRu ? titleRu : titleEn;

  String description({required bool isRu}) => isRu ? descRu : descEn;
}

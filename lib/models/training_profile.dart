import 'package:flutter/material.dart';

/// Training profile type based on user behavior patterns.
enum TrainingProfileType { explorer, grinder, theorist, gtoFan, gambler }

/// Training profile with metadata for display.
class TrainingProfile {
  final TrainingProfileType type;
  final String titleEn;
  final String titleRu;
  final String descriptionEn;
  final String descriptionRu;
  final IconData icon;
  final Color color;

  const TrainingProfile({
    required this.type,
    required this.titleEn,
    required this.titleRu,
    required this.descriptionEn,
    required this.descriptionRu,
    required this.icon,
    required this.color,
  });

  String title({required bool isRu}) => isRu ? titleRu : titleEn;
  String description({required bool isRu}) =>
      isRu ? descriptionRu : descriptionEn;

  /// All available profiles with their metadata.
  static const List<TrainingProfile> all = [
    TrainingProfile(
      type: TrainingProfileType.explorer,
      titleEn: 'Explorer',
      titleRu: 'Исследователь',
      descriptionEn:
          'You enjoy trying new content and diverse training approaches.',
      descriptionRu:
          'Вы любите пробовать новый контент и разнообразные подходы к тренировкам.',
      icon: Icons.explore,
      color: Colors.teal,
    ),
    TrainingProfile(
      type: TrainingProfileType.grinder,
      titleEn: 'Grinder',
      titleRu: 'Гриндер',
      descriptionEn:
          'You focus on volume, consistency, and building strong fundamentals.',
      descriptionRu:
          'Вы фокусируетесь на объёме, постоянстве и построении прочных основ.',
      icon: Icons.fitness_center,
      color: Colors.orange,
    ),
    TrainingProfile(
      type: TrainingProfileType.theorist,
      titleEn: 'Theorist',
      titleRu: 'Теоретик',
      descriptionEn:
          'You prefer studying theory and understanding concepts deeply.',
      descriptionRu:
          'Вы предпочитаете изучать теорию и глубоко понимать концепции.',
      icon: Icons.school,
      color: Colors.blue,
    ),
    TrainingProfile(
      type: TrainingProfileType.gtoFan,
      titleEn: 'GTO Fan',
      titleRu: 'Фанат GTO',
      descriptionEn: 'You love solver work and optimal strategy analysis.',
      descriptionRu:
          'Вы любите работу с солверами и анализ оптимальных стратегий.',
      icon: Icons.trending_up,
      color: Colors.purple,
    ),
    TrainingProfile(
      type: TrainingProfileType.gambler,
      titleEn: 'Gambler',
      titleRu: 'Игрок',
      descriptionEn: 'You focus on live play and real-world application.',
      descriptionRu:
          'Вы фокусируетесь на реальной игре и практическом применении.',
      icon: Icons.casino,
      color: Colors.red,
    ),
  ];

  /// Find profile by type.
  static TrainingProfile fromType(TrainingProfileType type) =>
      all.firstWhere((p) => p.type == type);
}

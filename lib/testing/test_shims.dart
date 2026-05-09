// ignore_for_file: unused_field, unused_element, unused_local_variable, deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:io';

class ShareOptions {}

enum GameType { tournament, cash }

enum TrainingType { generic, icm, gto }

enum TrainingPackLevel { l1, l2, l3 }

enum HeroPosition { utg, mp, co, btn, sb, bb }

extension HeroPositionLabel on HeroPosition {
  String get label {
    switch (this) {
      case HeroPosition.utg:
        return 'UTG';
      case HeroPosition.mp:
        return 'MP';
      case HeroPosition.co:
        return 'CO';
      case HeroPosition.btn:
        return 'BTN';
      case HeroPosition.sb:
        return 'SB';
      case HeroPosition.bb:
        return 'BB';
    }
  }
}

@Deprecated(
  'Use TrainingPackTemplateV2 directly from package:poker_analyzer/models/v2/training_pack_template_v2.dart',
)
class TrainingPackTemplateV2 {
  final String id;
  final String name;
  final GameType? type;
  final List<String>? tags;
  final TrainingType trainingType;
  final DateTime? createdAt;
  final TrainingPackLevel? level;

  const TrainingPackTemplateV2({
    this.id = '',
    this.name = '',
    this.type,
    this.tags,
    this.trainingType = TrainingType.generic,
    this.createdAt,
    this.level,
  });

  bool hasPlayableContent() => true;
}

class MixedDrillStat {
  final List<String> tags;
  final double accuracy;
  final String street;

  const MixedDrillStat({
    this.tags = const [],
    this.accuracy = 0.0,
    this.street = '',
  });
}

class TagGoalProgress {
  final String tag;
  final double progress;

  const TagGoalProgress(this.tag, this.progress);
}

class HandData {
  final String id;
  final String street;

  const HandData({this.id = '', this.street = ''});
}

Map<String, Object?> parseYamlToMap(String src) => const <String, Object?>{};

bool isAutoReplayKind(Object? _) => false;

extension ShimLastModifiedDir on Directory {
  Future<void> setLastModified(DateTime _) async {}
}

extension ShimLastModifiedFile on File {
  Future<void> setLastModified(DateTime _) async {}
}

class MixedDrillHistoryService {
  List<MixedDrillStat> get stats => const [];
}

class TrainingSessionService {
  Future<void> startSession(TrainingPackTemplateV2 tpl) async {
    _ignore(tpl);
  }
}

class TrainingPackService {
  static Future<TrainingPackTemplateV2?> createRepeatForIncorrect(Object? _) =>
      Future.value(const TrainingPackTemplateV2(name: 'Repeat Incorrect'));

  static Future<TrainingPackTemplateV2?> createRepeatForCorrected(Object? _) =>
      Future.value(const TrainingPackTemplateV2(name: 'Repeat Corrected'));

  static Future<TrainingPackTemplateV2?> createSingleRandomMistakeDrill(
    Object? _,
  ) => Future.value(const TrainingPackTemplateV2(name: 'Random Mistake'));

  static Future<TrainingPackTemplateV2?> createDrillFromCorrectedHands(
    Object? _,
  ) => Future.value(const TrainingPackTemplateV2(name: 'Corrected Drill'));

  static Future<TrainingPackTemplateV2?> createDrillFromWeakestCategory(
    Object? _,
  ) => Future.value(const TrainingPackTemplateV2(name: 'Weakest Category'));

  static Future<TrainingPackTemplateV2?> createTopMistakeDrill(Object? _) =>
      Future.value(const TrainingPackTemplateV2(name: 'Top Mistakes'));
}

class RecentTrainingPackSection {
  RecentTrainingPackSection({
    required List<TrainingPackTemplateV2> templates,
    Object? progress,
    void Function()? onClear,
    void Function(TrainingPackTemplateV2 tpl)? onPlay,
  }) {
    _ignore(templates, progress, onClear, onPlay);
  }
}

class FilterSummaryBar {
  FilterSummaryBar({
    required String summary,
    required void Function() onReset,
    required void Function() onChange,
  }) {
    _ignore(summary, onReset, onChange);
  }
}

class AppColors {
  static const int accent = 0;
}

abstract class MiniLessonLibraryService {
  Object? findLessonByTag(String tag);
  Object? getNextLesson(String tag);
  bool isLessonCompleted(String tag);
  List<String> linkedPacksFor(String tag);
}

abstract class PackLibraryService<T> {
  Future<void> addOrUpdate(T item);
  Future<int> count();
  Future<List<String>> getAvailablePackIds();
  Future<T?> getPack(String id);
  Future<List<T>> getAll();
}

class RecallSuccessLoggerService {
  RecallSuccessLoggerService();
}

class SmartTheoryRecapDismissalMemory {
  SmartTheoryRecapDismissalMemory();
}

class AppLocalizations {
  static AppLocalizations of(Object? _) => AppLocalizations();

  String get ok => 'OK';
  String get cancel => 'Cancel';
}

void _ignore([Object? a, Object? b, Object? c, Object? d]) {}

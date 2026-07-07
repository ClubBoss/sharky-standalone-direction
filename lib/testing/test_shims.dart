// ignore_for_file: unused_field, unused_element, unused_local_variable, deprecated_member_use_from_same_package

import 'dart:async';

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

bool isAutoReplayKind(Object? _) => false;

class TrainingSessionService {
  Future<void> startSession(TrainingPackTemplateV2 tpl) async {
    _ignore(tpl);
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

void _ignore([Object? a]) {}

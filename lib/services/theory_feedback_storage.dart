import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/theory_lesson_feedback.dart';

class TheoryFeedbackStorage {
  TheoryFeedbackStorage._();

  static final TheoryFeedbackStorage instance = TheoryFeedbackStorage._();

  static const String _key = 'theory_lesson_feedback';

  Future<List<TheoryLessonFeedback>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return [
      for (final s in raw)
        if (_parseFeedback(s) case final feedback?) feedback,
    ].whereType<TheoryLessonFeedback>().toList();
  }

  TheoryLessonFeedback? _parseFeedback(String source) {
    if (source.isEmpty) return null;
    try {
      final data = jsonDecode(source);
      if (data is Map) {
        return TheoryLessonFeedback.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  Future<void> _save(List<TheoryLessonFeedback> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, [
      for (final f in list) jsonEncode(f.toJson()),
    ]);
  }

  Future<void> record(
    String lessonId,
    TheoryLessonFeedbackChoice choice,
  ) async {
    final list = await _load();
    final idx = list.indexWhere((e) => e.lessonId == lessonId);
    final entry = TheoryLessonFeedback(lessonId: lessonId, choice: choice);
    if (idx >= 0) {
      list[idx] = entry;
    } else {
      list.add(entry);
    }
    while (list.length > 200) {
      list.removeAt(0);
    }
    await _save(list);
  }

  Future<TheoryLessonFeedback?> getFeedback(String lessonId) async {
    final list = await _load();
    for (final entry in list) {
      if (entry.lessonId == lessonId) return entry;
    }
    return null;
  }

  Future<List<TheoryLessonFeedback>> getAll() => _load();
}

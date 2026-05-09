import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TopicProgress {
  final String topicId;
  int seenCount;
  int correctCount;
  int streak;
  DateTime lastUpdated;
  List<Map<String, dynamic>> history;

  TopicProgress({
    required this.topicId,
    this.seenCount = 0,
    this.correctCount = 0,
    this.streak = 0,
    DateTime? lastUpdated,
    List<Map<String, dynamic>>? history,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       history = history ?? [];

  double get accuracy => seenCount > 0 ? correctCount / seenCount : 0.0;

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'seenCount': seenCount,
    'correctCount': correctCount,
    'streak': streak,
    'lastUpdated': lastUpdated.toIso8601String(),
    'history': history,
  };

  factory TopicProgress.fromJson(Map<String, dynamic> json) => TopicProgress(
    topicId: json['topicId'] as String,
    seenCount: json['seenCount'] as int,
    correctCount: json['correctCount'] as int,
    streak: json['streak'] as int,
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    history: List<Map<String, dynamic>>.from(json['history'] as Iterable),
  );
}

class TopicProgressService {
  static const _progressKey = 'topic_progress';
  static final TopicProgressService instance =
      TopicProgressService._privateConstructor();

  TopicProgressService._privateConstructor();

  Future<void> updateProgress(String topicId, bool correct) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = prefs.getString(_progressKey);
    final progressData = progressMap != null
        ? jsonDecode(progressMap) as Map<String, dynamic>
        : <String, dynamic>{};

    final topicProgress = progressData[topicId] != null
        ? TopicProgress.fromJson(progressData[topicId] as Map<String, dynamic>)
        : TopicProgress(topicId: topicId);

    topicProgress.seenCount++;
    if (correct) {
      topicProgress.correctCount++;
      topicProgress.streak++;
    } else {
      topicProgress.streak = 0;
    }
    topicProgress.lastUpdated = DateTime.now();
    topicProgress.history.add({
      'timestamp': DateTime.now().toIso8601String(),
      'correct': correct,
    });

    progressData[topicId] = topicProgress.toJson();
    await prefs.setString(_progressKey, jsonEncode(progressData));
  }

  Future<TopicProgress> getTopicProgress(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = prefs.getString(_progressKey);
    final progressData = progressMap != null
        ? jsonDecode(progressMap) as Map<String, dynamic>
        : <String, dynamic>{};

    if (progressData[topicId] != null) {
      return TopicProgress.fromJson(
        progressData[topicId] as Map<String, dynamic>,
      );
    } else {
      return TopicProgress(topicId: topicId);
    }
  }

  Future<List<String>> getMostImprovedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = prefs.getString(_progressKey);
    final progressData = progressMap != null
        ? jsonDecode(progressMap) as Map<String, dynamic>
        : <String, dynamic>{};

    final topics = progressData.entries
        .map((e) => TopicProgress.fromJson(e.value as Map<String, dynamic>))
        .toList();
    topics.sort((a, b) => b.accuracy.compareTo(a.accuracy));

    return topics.map((t) => t.topicId).toList();
  }

  Future<List<String>> getTrendingTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = prefs.getString(_progressKey);
    final progressData = progressMap != null
        ? jsonDecode(progressMap) as Map<String, dynamic>
        : <String, dynamic>{};

    final topics = progressData.entries
        .map((e) => TopicProgress.fromJson(e.value as Map<String, dynamic>))
        .toList();
    topics.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return topics.map((t) => t.topicId).toList();
  }

  // Add a method to fetch topic-specific progress data
  Map<String, dynamic> getTopicRecapData(String topicId) => {
    'correctAnswers': 15,
    'totalAnswers': 20,
    'mistakeRate': 25,
    'streak': 4,
    'lastSuccess': DateTime.now().subtract(const Duration(days: 2)),
  };

  // Add a method to fetch accuracy by topic
  Map<String, int> getAccuracy(String topicId) => {
    'spot1': 50,
    'spot2': 70,
    'spot3': 40,
  };
}

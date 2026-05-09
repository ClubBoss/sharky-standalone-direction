import 'package:shared_preferences/shared_preferences.dart';

class CheckpointEntry {
  final String id;
  final List<String> topics;
  final String category;
  final String subtitle;

  CheckpointEntry({
    required this.id,
    required this.topics,
    required this.category,
    required this.subtitle,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'topics': topics,
    'category': category,
    'subtitle': subtitle,
  };

  factory CheckpointEntry.fromJson(Map<String, dynamic> json) =>
      CheckpointEntry(
        id: json['id'] as String,
        topics: List<String>.from(json['topics'] as Iterable<dynamic>),
        category: json['category'] as String,
        subtitle: json['subtitle'] as String,
      );
}

class CheckpointService {
  static const _lastCheckpointKey = 'last_checkpoint';
  static final CheckpointService instance =
      CheckpointService._privateConstructor();

  CheckpointService._privateConstructor();

  Future<CheckpointEntry?> getEligibleCheckpoint() async {
    // Simulate logic to evaluate checkpoint readiness
    final completedTopics = await _getCompletedTopics();
    if (completedTopics.length >= 3) {
      return CheckpointEntry(
        id: 'checkpoint_1',
        topics: completedTopics,
        category: 'Mastery',
        subtitle: 'You have mastered ${completedTopics.length} topics',
      );
    }
    return null;
  }

  Future<void> clearCheckpointProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCheckpointKey);
  }

  Future<void> markCheckpointCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCheckpointKey, id);
  }

  Future<List<String>> _getCompletedTopics() async {
    // Simulate fetching completed topics
    return ['topic_1', 'topic_2', 'topic_3'];
  }
}

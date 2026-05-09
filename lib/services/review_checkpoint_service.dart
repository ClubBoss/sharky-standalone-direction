import 'package:shared_preferences/shared_preferences.dart';

class ReviewCheckpointService {
  static const _lastReviewKey = 'last_review_checkpoint';
  static final ReviewCheckpointService instance =
      ReviewCheckpointService._privateConstructor();

  ReviewCheckpointService._privateConstructor();

  Future<List<String>> getReviewCheckpointTopics() async {
    final topics = await _fetchTopics();
    final now = DateTime.now();

    final eligibleTopics = topics.where((topic) {
      final lastReviewed = topic['lastReviewed'] != null
          ? DateTime.parse(topic['lastReviewed'] as String)
          : null;
      final mistakeRate = topic['mistakeRate'] ?? 0.0;

      return ((mistakeRate as num) > 0.3 ||
              lastReviewed == null ||
              now.difference(lastReviewed).inDays >= 10) ==
          true;
    }).toList();

    eligibleTopics.sort(
      (a, b) => (b['mistakeRate'] as int).compareTo(a['mistakeRate'] as int),
    );

    return eligibleTopics
        .take(5)
        .map((topic) => topic['id'] as String)
        .toList();
  }

  Future<bool> shouldShowCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReview = prefs.getString(_lastReviewKey);

    if (lastReview != null) {
      final lastReviewDate = DateTime.parse(lastReview);
      if (DateTime.now().difference(lastReviewDate).inDays < 7) {
        return false;
      }
    }

    final topics = await getReviewCheckpointTopics();
    return topics.isNotEmpty;
  }

  Future<void> markCheckpointReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReviewKey, DateTime.now().toIso8601String());
  }

  Future<List<Map<String, dynamic>>> _fetchTopics() async {
    // Simulate fetching topics with metadata
    return [
      {'id': 'topic_1', 'mistakeRate': 0.4, 'lastReviewed': '2025-10-10'},
      {'id': 'topic_2', 'mistakeRate': 0.2, 'lastReviewed': '2025-10-01'},
      {'id': 'topic_3', 'mistakeRate': 0.5, 'lastReviewed': null},
      {'id': 'topic_4', 'mistakeRate': 0.1, 'lastReviewed': '2025-10-15'},
    ];
  }
}

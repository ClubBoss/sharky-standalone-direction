import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _reviewPromptLastYmdKey = 'review_prompt_last_ymd';
const _reviewPromptCooldownDays = 60;

enum ReviewPositiveMomentV1 { onboardingCompleted }

class ReviewPromptServiceV1 {
  ReviewPromptServiceV1._();

  static final instance = ReviewPromptServiceV1._();

  DateTime Function() _clock = DateTime.now;
  Future<void> Function() _requestReview = _defaultRequestReview;

  @visibleForTesting
  set clockOverride(DateTime Function() provider) {
    _clock = provider;
  }

  @visibleForTesting
  set requestReviewOverride(Future<void> Function() requester) {
    _requestReview = requester;
  }

  Future<void> maybePromptAfterPositiveMoment(
    ReviewPositiveMomentV1 moment,
  ) async {
    final now = _clock();
    final prefs = await SharedPreferences.getInstance();
    final lastYmd = prefs.getString(_reviewPromptLastYmdKey);
    if (lastYmd != null) {
      final lastDate = _parseYmd(lastYmd);
      if (now.difference(lastDate).inDays < _reviewPromptCooldownDays) {
        return;
      }
    }
    try {
      await _requestReview();
    } catch (_) {
      // swallow errors silently
    }
    await prefs.setString(_reviewPromptLastYmdKey, _formatYmd(now));
  }

  String _formatYmd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  DateTime _parseYmd(String ymd) {
    final year = int.parse(ymd.substring(0, 4));
    final month = int.parse(ymd.substring(4, 6));
    final day = int.parse(ymd.substring(6, 8));
    return DateTime(year, month, day);
  }

  @visibleForTesting
  void resetForTesting() {
    _clock = DateTime.now;
    _requestReview = _defaultRequestReview;
  }
}

Future<void> _defaultRequestReview() async {
  // No-op fallback when native in-app review plugin is unavailable.
  return;
}

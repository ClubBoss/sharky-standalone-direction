import 'act0_attempt_archive_v1.dart';
import 'act0_imported_hand_v1.dart';

/// Local browsing state. The shell continues to own archive persistence.
class Act0AttemptArchiveViewModelV1 {
  bool showOwnHands = false;
  String query = '';
  Act0ArchivedAttemptV1? replayingAttempt;
  Act0ImportedHandV1? replayingHand;

  bool get atArchiveRoot =>
      !showOwnHands && replayingAttempt == null && replayingHand == null;

  void backToParent() {
    if (replayingAttempt != null || replayingHand != null) {
      replayingAttempt = null;
      replayingHand = null;
    } else {
      showOwnHands = false;
    }
  }

  List<Act0ArchivedAttemptV1> visibleAttempts(Act0AttemptArchiveV1 archive) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) return archive.attempts;
    return archive.attempts
        .where((attempt) {
          return [
            attempt.taskLabel,
            attempt.choiceLabel,
            attempt.evidence.taskId,
            attempt.evidence.choiceId,
          ].whereType<String>().any(
            (label) => label.toLowerCase().contains(search),
          );
        })
        .toList(growable: false);
  }
}

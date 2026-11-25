import 'act0_w14_skill_state_v1.dart';
import 'act0_attempt_archive_v1.dart';
import 'act0_imported_hand_v1.dart';

/// Local browsing state. The shell continues to own archive persistence.
class Act0AttemptArchiveViewModelV1 {
  String query = '';
  String? world;
  String? skill;
  String? outcome;

  void clearFilters() {
    query = '';
    world = null;
    skill = null;
    outcome = null;
  }

  static List<String> skillsFor(Act0ArchivedAttemptV1 attempt) =>
      act0SkillsForTaskV1(attempt.evidence.lessonId, attempt.evidence.taskId);

  static String outcomeFor(Act0ArchivedAttemptV1 attempt) {
    final evidence = attempt.evidence;
    if (evidence.isRepaired) return 'Repaired';
    if (evidence.isAssistedCorrect) return 'Assisted';
    return evidence.isCorrect ? 'Correct' : 'Wrong';
  }

  Act0ArchivedAttemptV1? replayingAttempt;
  Act0ImportedHandV1? replayingHand;

  bool get atArchiveRoot => replayingAttempt == null && replayingHand == null;

  void backToParent() {
    replayingAttempt = null;
    replayingHand = null;
  }

  List<Act0ArchivedAttemptV1> visibleAttempts(Act0AttemptArchiveV1 archive) {
    final search = query.trim().toLowerCase();

    return archive.attempts
        .where((attempt) {
          if (world != null && attempt.evidence.worldId != world ||
              skill != null && !skillsFor(attempt).contains(skill) ||
              outcome != null && outcomeFor(attempt) != outcome) {
            return false;
          }
          return search.isEmpty ||
              [
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

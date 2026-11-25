import 'act0_attempt_archive_v1.dart';
import 'act0_authored_source_proof_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_w14_skill_state_v1.dart';

/// Counts saved graded answers, not mastery or unique tasks. A repair and an
/// independent correct answer are separate evidence categories.
class Act0SkillProgressV1 {
  const Act0SkillProgressV1({
    required this.skill,
    required this.attempts,
    required this.independentCorrect,
    required this.repaired,
    required this.missedAnswers,
    required this.minimumAnswers,
  });

  final String skill;
  final int attempts;
  final int independentCorrect;
  final int repaired;
  final int missedAnswers;
  final int minimumAnswers;

  int get answersNeeded =>
      attempts < minimumAnswers ? minimumAnswers - attempts : 0;
  bool get needsWork => answersNeeded == 0 && missedAnswers > 0;

  String get status => answersNeeded > 0
      ? 'Not enough answers yet ($answersNeeded more)'
      : needsWork
      ? 'Needs work'
      : 'No misses in saved answers';

  String get counts =>
      '$attempts answers · $independentCorrect correct without help · '
      '$repaired repaired · $missedAnswers missed';

  /// Use the same minimum sample size as B31. Only the retained archive
  /// contributes counts; changed or unmapped task revisions are not evidence
  /// about the current skill map.
  static List<Act0SkillProgressV1> fromArchive({
    required Act0AttemptArchiveV1 archive,
    required List<Act0WorldCardV1> worlds,
    int minimumAnswers = 8,
  }) {
    if (minimumAnswers < 1) {
      throw ArgumentError.value(minimumAnswers, 'minimumAnswers');
    }
    final tasks = {
      for (final world in worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList)
            (world.worldId, lesson.lessonId, task.taskId): task,
    };
    final skills = <String, _Counts>{};
    for (final key in tasks.keys) {
      for (final skill in act0SkillsForTaskV1(key.$2, key.$3)) {
        skills.putIfAbsent(skill, _Counts.new);
      }
    }
    final fingerprints = <(String, String, String), String?>{};
    for (final attempt in archive.attempts) {
      final record = attempt.evidence;
      if (record.isPlacementAssessment || record.isDiagnosticLearningEntry) {
        continue;
      }
      final key = (record.worldId, record.lessonId, record.taskId);
      final task = tasks[key];
      if (task == null ||
          fingerprints.putIfAbsent(
                key,
                () => act0AuthoredSourceFingerprintV1(
                  worldId: key.$1,
                  lessonId: key.$2,
                  task: task,
                ),
              ) !=
              record.authoredSourceFingerprint) {
        continue;
      }
      for (final skill in act0SkillsForTaskV1(key.$2, key.$3).toSet()) {
        final count = skills[skill]!;
        count.attempts++;
        if (!record.isCorrect) count.missed++;
        if (record.isRepaired) count.repaired++;
        if (record.isIndependentCorrect && !task.guidedDecision) {
          count.independent++;
        }
      }
    }
    return List.unmodifiable([
      for (final entry in skills.entries)
        Act0SkillProgressV1(
          skill: entry.key,
          attempts: entry.value.attempts,
          independentCorrect: entry.value.independent,
          repaired: entry.value.repaired,
          missedAnswers: entry.value.missed,
          minimumAnswers: minimumAnswers,
        ),
    ]);
  }

  /// Rank only sufficiently sampled skills, by missed-answer rate and then
  /// number of misses. Repaired answers remain visible separately.
  static List<Act0SkillProgressV1> topNeedsWork(
    Iterable<Act0SkillProgressV1> skills,
  ) {
    final ranked = skills.where((skill) => skill.needsWork).toList()
      ..sort((a, b) {
        final rate = (b.missedAnswers * a.attempts).compareTo(
          a.missedAnswers * b.attempts,
        );
        if (rate != 0) return rate;
        final misses = b.missedAnswers.compareTo(a.missedAnswers);
        return misses != 0 ? misses : a.skill.compareTo(b.skill);
      });
    return List.unmodifiable(ranked.take(3));
  }
}

class _Counts {
  int attempts = 0;
  int independent = 0;
  int repaired = 0;
  int missed = 0;
}

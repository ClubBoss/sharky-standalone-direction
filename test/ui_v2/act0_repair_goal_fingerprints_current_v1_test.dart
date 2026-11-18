import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';

// A repair goal is bound to the exact task content by fingerprint. Editing a
// task's caption, hint, question or feedback changes that fingerprint, and the
// goal then silently stops offering the retry after a wrong answer. This test
// makes such an edit fail loudly and prints the value to put in the contract.
void main() {
  test('every repair goal matches the current task content', () {
    final stale = <String>[];
    for (final c in act0RepairGoalContractsV1) {
      final source = act0CurrentAuthoredSourceFingerprintForIdentityV1(
        worldId: c.sourceWorldId,
        lessonId: c.sourceLessonId,
        taskId: c.sourceTaskId,
      );
      // Placement entries pin the whole task in sourceContainerFingerprint and
      // leave sourceFingerprint empty (their variant is captured at runtime).
      final pinned = c.sourceFingerprint.isNotEmpty
          ? c.sourceFingerprint
          : c.sourceContainerFingerprint;
      if (pinned.isNotEmpty && source != pinned) {
        stale.add('${c.relationId} source ${c.sourceTaskId}: now $source');
      }
      if (c.targetFingerprint.isEmpty) continue;
      final target = act0CurrentAuthoredSourceFingerprintForIdentityV1(
        worldId: c.targetWorldId,
        lessonId: c.targetLessonId,
        taskId: c.targetTaskId,
      );
      if (target != c.targetFingerprint) {
        stale.add('${c.relationId} target ${c.targetTaskId}: now $target');
      }
    }
    expect(stale, isEmpty, reason: stale.join('\n'));
  });
}

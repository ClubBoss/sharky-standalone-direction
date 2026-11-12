// Private source attribution; never a reward/grade/Store or migration authority.
import 'act0_shell_state_v1.dart';
import 'act0_authored_source_proof_v1.dart';

class Act0W4AuthoredBindingV1 {
  const Act0W4AuthoredBindingV1(
    this.world,
    this.lesson,
    this.task,
    this.fingerprint,
    this.record,
    this.version,
    this.recordHash,
    this.hand,
    this.decision,
  );
  final String world,
      lesson,
      task,
      fingerprint,
      record,
      version,
      recordHash,
      hand,
      decision;
  String get sourceManifest =>
      '6f8a9eb4a83e02ea0e0c1d7d614f5b50971bfff8d33760d08d4af73df10c9b04';
  String get bindingManifest =>
      'b07eaeb89d78640cfe8c3d92cf8e7e5a83fed50cac1feb0ab66539ac42864d32';
}

const act0PrivateW4BindingsV1 = <Act0W4AuthoredBindingV1>[
  Act0W4AuthoredBindingV1(
    "world_4",
    "call_price",
    "w4_good_price_call",
    "d532a7e56d5a2a62c1207f86ce2a1303c5de4ba28462490db3b4f3468e440d86",
    "w4_new_good_v1",
    "1.0.0-proposal.5",
    "98fa9816ac67440d55902a1b5bd27beef2ddab5dac9f959f9d414b99ea6c5bcc",
    "new_hand_w4_good_001",
    "new_hand_w4_good_001:turn_facing_sb_bet",
  ),
  Act0W4AuthoredBindingV1(
    "world_4",
    "call_price",
    "w4_bad_price_fold",
    "0a0ca6617e56049eac64b42e6e6436d6410faed5d5cc44922baa308a055e756c",
    "w4_new_bad_v1",
    "1.0.0-proposal.5",
    "492cc13c768b9ccec8857c3d4308953cef185c248beef5596a0d984e89007ad4",
    "new_hand_w4_bad_001",
    "new_hand_w4_bad_001:turn_facing_sb_bet",
  ),
  Act0W4AuthoredBindingV1(
    "world_4",
    "call_price",
    "w4_cheap_price_marginal_call",
    "58de64773c9ad5890f3baad81aa6f46bf4ed79126befe33f492bace8f85696bd",
    "w4_new_cheap_v1",
    "1.0.0-proposal.4",
    "34cb4f3792314be8d068dc5ee0d718ff581be1cdabc83943846cd92cd5bec6ac",
    "new_hand_w4_cheap_001",
    "new_hand_w4_cheap_001:turn_facing_sb_bet",
  ),
  Act0W4AuthoredBindingV1(
    "world_4",
    "call_price",
    "w4_big_price_marginal_fold",
    "be3d0c204e8bc96b0b2526bc06c929628f44c148ab0360f27ce2e227082625db",
    "w4_new_big_v1",
    "1.0.0-proposal.4",
    "47a76beb3497900bc8b4ce2bfa82dcb64c136a55d6e7412806e764be2a0df782",
    "new_hand_w4_big_001",
    "new_hand_w4_big_001:turn_facing_sb_bet",
  ),
  Act0W4AuthoredBindingV1(
    "world_4",
    "price_checkpoint",
    "w4_checkpoint_price",
    "ddcb0854866666d6fc4c4d4191c35c241f6b2b00b190d276591398daf71755f6",
    "w4_new_checkpoint_v1",
    "1.0.0-proposal.3",
    "778969eb51404e75250a0b98cf9fc33a8c1a772512fe177ca9c58100f72823d7",
    "new_hand_w4_checkpoint_001",
    "new_hand_w4_checkpoint_001:turn_facing_sb_bet",
  ),
  Act0W4AuthoredBindingV1(
    "world_4",
    "price_checkpoint",
    "w4_checkpoint_table_price",
    "2fa1d9991fb8cd9ce17d11256efb55198db85042b03216045521932d65eb393f",
    "w4_new_table_v1",
    "1.0.0-proposal.3",
    "f7ad9eb560918e3247586338317acbd58836e2299d85479bb2520388d48d4687",
    "new_hand_w4_table_001",
    "new_hand_w4_table_001:turn_facing_sb_bet",
  ),
];
Act0W4AuthoredBindingV1? act0W4BindingForTaskV1({
  required String world,
  required String lesson,
  required Act0LessonTaskV1 task,
  Act0RunnerStateV1? runner,
  String? expectedRouteLessonTitle,
}) {
  final fingerprint = act0AuthoredSourceFingerprintV1(
    worldId: world,
    lessonId: lesson,
    task: task,
  );
  final matches = act0PrivateW4BindingsV1
      .where(
        (r) =>
            r.world == world &&
            r.lesson == lesson &&
            r.task == task.taskId &&
            r.fingerprint == fingerprint,
      )
      .toList();
  if (matches.length != 1) return null;
  if (runner != null) {
    final authoredPair =
        runner.lessonId == task.runner.lessonId &&
        runner.lessonTitle == task.runner.lessonTitle;
    final routePair =
        expectedRouteLessonTitle != null &&
        expectedRouteLessonTitle.isNotEmpty &&
        runner.lessonId == lesson &&
        runner.lessonTitle == expectedRouteLessonTitle;
    if (!authoredPair && !routePair) return null;
    // Only the validated route-owned identity/title envelope is presentation.
    // Every remaining authored semantic field still participates in proof.
    final semanticRunner = runner.copyWith(
      lessonId: task.runner.lessonId,
      lessonTitle: task.runner.lessonTitle,
    );
    final active = Act0LessonTaskV1(
      taskId: task.taskId,
      title: task.title,
      phase: task.phase,
      runner: semanticRunner,
      rewardXp: task.rewardXp,
      stepKind: task.stepKind,
      taskFamily: task.taskFamily,
      tablePresentation: task.tablePresentation,
      summary: task.summary,
      lockedSummary: task.lockedSummary,
    );
    if (act0AuthoredSourceFingerprintV1(
          worldId: world,
          lessonId: lesson,
          task: active,
        ) !=
        fingerprint)
      return null;
  }
  return matches.single;
}

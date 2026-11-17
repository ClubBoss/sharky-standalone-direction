// Read-only source inventory for CUR-01.a. No Flutter initialization or runtime
// simulation; the existing copy parser supplies authored goals and task IDs.
import 'dart:convert';
import 'dart:io';

import '_lib/act0_content_copy_source_parser.dart';

const _base = 'ccd263c4ed9c03f0a09751b19048dc6030ffbbcf';
const _state = 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';
const _preview = 'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
const _parser = 'tools/_lib/act0_content_copy_source_parser.dart';
const _jsonPath = 'docs/content/FOUNDATION_W1_W4_SOURCE_MAP_v1.json';
const _mdPath = 'docs/content/FOUNDATION_W1_W4_SOURCE_MAP_v1.md';

// Fixed proposal payload, frozen for independent review; never read through the
// companion JSON. Current 455f authorship remains separate from historical
// extraction and does not weaken the State/Preview pins below.
const Map<String, Object?> _callPriceCuration = {
  "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
  "curator_role": "cur01-content-02",
  "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
  "source_commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
  "source_state_git_blob": "ee9e54ac8ea6f53246fa453b4abf3781e386b65f",
  "scope_task_ids": [
    "w4_price_intro",
    "w4_good_price_call",
    "w4_bad_price_fold",
    "w4_cheap_price_marginal_call",
    "w4_big_price_marginal_fold",
    "w4_price_recap",
  ],
  "lesson_objective":
      "Read the displayed pot and call amount with the stated hand, identify each authored example choice, and explain the price checklist while keeping unsupported strategic conclusions explicit.",
  "skills": [
    {
      "skill_id": "read_price_labels",
      "objective":
          "Identify Pot as chips available to win and To call as the additional amount required to continue.",
      "introduction_task_id": "w4_price_intro",
      "introduction_status": "SOURCE_TEACHING_PRESENT",
      "introduction_source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 15958,
        "end_line": 15988,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "application_task_ids": [
        "w4_good_price_call",
        "w4_bad_price_fold",
        "w4_cheap_price_marginal_call",
        "w4_big_price_marginal_fold",
        "w4_price_recap",
      ],
      "limits":
          "Label interpretation only; no pot accounting convention or profitable-call proof.",
    },
    {
      "skill_id": "compare_price_with_hand",
      "objective":
          "Read pot, call amount and stated hand together, and explain the authored choice in these examples without generalizing it into a strategy rule.",
      "introduction_task_id": "w4_price_intro",
      "introduction_status": "PARTIAL_SOURCE_TEACHING",
      "introduction_source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 15963,
        "end_line": 15966,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "application_task_ids": [
        "w4_good_price_call",
        "w4_bad_price_fold",
        "w4_cheap_price_marginal_call",
        "w4_big_price_marginal_fold",
        "w4_price_recap",
      ],
      "limits":
          "The intro names all three inputs but supplies no equity/range model or criterion for enough hand strength; strategic justification remains GAP.",
    },
    {
      "skill_id": "read_pair_subtypes",
      "objective":
          "Distinguish the task statements one pair, weak pair, middle pair and top pair with weak kicker.",
      "introduction_task_id": null,
      "introduction_status": "UNKNOWN_BEFORE_REQUIRED_USE",
      "first_required_task_id": "w4_bad_price_fold",
      "application_task_ids": [
        "w4_good_price_call",
        "w4_bad_price_fold",
        "w4_cheap_price_marginal_call",
        "w4_big_price_marginal_fold",
      ],
      "limits":
          "Earlier pair and kicker teaching is verified below. A prior introduction to middle/top/weak pair and weak-kicker strategic meaning was not established in this bounded inspection.",
    },
  ],
  "pedagogical_prerequisites": [
    {
      "task_id": "what_poker_is_pot_stack",
      "required_knowledge": "Identify the pot as shared chips in the middle.",
      "source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 8724,
        "end_line": 8770,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "status": "SOURCE_TEACHING_PRESENT",
      "claim_limit":
          "Source teaching only; route closure and learner comprehension are unverified.",
    },
    {
      "task_id": "actions_call_drill",
      "required_knowledge":
          "Call matches the current bet; raise adds chips beyond the call.",
      "source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 9557,
        "end_line": 9658,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "status": "SOURCE_TEACHING_PRESENT",
      "claim_limit":
          "Source teaching only; route closure and learner comprehension are unverified.",
    },
    {
      "task_id": "actions_fold_drill",
      "required_knowledge":
          "Fold gives up the hand and avoids paying the call.",
      "source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 9456,
        "end_line": 9480,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "status": "SOURCE_TEACHING_PRESENT",
      "claim_limit":
          "Source teaching only; route closure and learner comprehension are unverified.",
    },
    {
      "task_id": "hand_rankings_pair_drill",
      "required_knowledge":
          "Identify a pair by matching ranks using hole cards and board.",
      "source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 10250,
        "end_line": 10300,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "status": "SOURCE_TEACHING_PRESENT",
      "claim_limit":
          "Source teaching only; route closure and learner comprehension are unverified.",
    },
    {
      "task_id": "showdown_kicker_drill",
      "required_knowledge":
          "Recognize a kicker as a side card that can break a matching-pair tie.",
      "source": {
        "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
        "start_line": 11048,
        "end_line": 11072,
        "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
      },
      "status": "SOURCE_TEACHING_PRESENT",
      "claim_limit":
          "Source teaching only; route closure and learner comprehension are unverified.",
    },
  ],
  "prerequisite_limit":
      "These are newly curated knowledge dependencies, not newly imposed route gates. Historical prior_lesson_ids_in_world remains source order, not mastery. Pair/kicker terms alone do not prove strategic hand-strength sufficiency.",
  "unknown_prerequisites": [
    "Earlier explicit teaching of middle pair, top pair, weak pair and weak kicker in price decisions: UNKNOWN in this bounded inspection.",
    "A justified call/fold decision rule using opponent holdings/ranges or equity, future action and an unambiguous pot convention: GAP.",
    "How future cards affect a price decision: UNKNOWN; recap names future cards but these six tasks do not teach that analysis.",
  ],
  "evidence_limit":
      "Source inspection only; no runner execution, grading correctness validation, learning, native, Human, CUR-01.a or CUR-02.a acceptance.",
  "maintenance":
      "DEPENDENCY: generator exact serialization and original State/Preview pin guards prevent direct integration; see MAINTENANCE.md. Historical provenance is untouched.",
};
const Map<String, Map<String, Object?>> _callPriceTaskCuration = {
  "w4_price_intro": {
    "decision_kind": "NEW_CURRENT_CURATION",
    "curator_role": "cur01-content-02",
    "objective": "Identify the price to continue by reading Pot and To call.",
    "source": {
      "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
      "start_line": 15958,
      "end_line": 15988,
      "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
    },
    "immediate_runner_parent": "_callActionRunner -> _readBoardRunner",
    "displayed_operands": ["Pot 8 BB", "To call 2 BB", "Turn"],
    "authored_option_ids_in_runner_declaration": [],
    "authored_correct_option_id": null,
    "correctness_claim": "NO_OPTION_GRADING_IN_DECLARATION",
    "option_order_limit":
        "Task copyWith reorders options for bad_price_fold, cheap_price_marginal_call and big_price_marginal_fold; IDs and authored flags are the references, not option positions.",
    "required_earlier_task_ids": [
      "what_poker_is_pot_stack",
      "actions_call_drill",
    ],
    "skill_ids": ["read_price_labels", "compare_price_with_hand"],
    "introduction_or_application": "INTRODUCTION",
    "teaching_semantics":
        "No options; teaching explicitly defines the two labels. Hand-strength hint is only a named consideration.",
    "source_feedback_limit":
        "Historical runner_feedback_source is preserved. For first five tasks its flop sentence is inherited runner-level feedback, not these tasks' option-specific teaching. Visible feedback path is unverified.",
  },
  "w4_good_price_call": {
    "decision_kind": "NEW_CURRENT_CURATION",
    "curator_role": "cur01-content-02",
    "objective":
        "Read 8 BB pot, 1 BB call and one pair; explain that Call is the source-authored answer, while its profitability remains unproved.",
    "source": {
      "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
      "start_line": 16015,
      "end_line": 16068,
      "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
    },
    "immediate_runner_parent": "_world4PriceIntroRunner",
    "displayed_operands": ["Pot 8 BB", "To call 1 BB", "Ts 7d / Th 8c 3d 2s"],
    "authored_option_ids_in_runner_declaration": ["call", "fold"],
    "authored_correct_option_id": "call",
    "correctness_claim": "SOURCE_FLAG_ONLY_NOT_STRATEGIC_VALIDATION",
    "option_order_limit":
        "Task copyWith reorders options for bad_price_fold, cheap_price_marginal_call and big_price_marginal_fold; IDs and authored flags are the references, not option positions.",
    "required_earlier_task_ids": [
      "actions_call_drill",
      "hand_rankings_pair_drill",
      "w4_price_intro",
    ],
    "skill_ids": [
      "read_price_labels",
      "compare_price_with_hand",
      "read_pair_subtypes",
    ],
    "introduction_or_application": "APPLICATION",
    "teaching_semantics":
        "Own option feedback gives the small-price/one-pair rationale; source does not give a range or equity justification.",
    "source_feedback_limit":
        "Historical runner_feedback_source is preserved. For first five tasks its flop sentence is inherited runner-level feedback, not these tasks' option-specific teaching. Visible feedback path is unverified.",
  },
  "w4_bad_price_fold": {
    "decision_kind": "NEW_CURRENT_CURATION",
    "curator_role": "cur01-content-02",
    "objective":
        "Read 8 BB pot, 7 BB call and weak pair; explain that Fold is the source-authored answer and why the example labels the price high.",
    "source": {
      "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
      "start_line": 16070,
      "end_line": 16116,
      "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
    },
    "immediate_runner_parent": "_world4GoodPriceCallRunner",
    "displayed_operands": ["Pot 8 BB", "To call 7 BB", "8s 7d / Kh 8c 4d 2s"],
    "authored_option_ids_in_runner_declaration": ["fold", "call"],
    "authored_correct_option_id": "fold",
    "correctness_claim": "SOURCE_FLAG_ONLY_NOT_STRATEGIC_VALIDATION",
    "option_order_limit":
        "Task copyWith reorders options for bad_price_fold, cheap_price_marginal_call and big_price_marginal_fold; IDs and authored flags are the references, not option positions.",
    "required_earlier_task_ids": [
      "actions_fold_drill",
      "hand_rankings_pair_drill",
      "w4_price_intro",
    ],
    "skill_ids": [
      "read_price_labels",
      "compare_price_with_hand",
      "read_pair_subtypes",
    ],
    "introduction_or_application": "APPLICATION",
    "teaching_semantics":
        "Own option feedback describes weak pair/high price; amount and pair alone do not establish a general fold.",
    "source_feedback_limit":
        "Historical runner_feedback_source is preserved. For first five tasks its flop sentence is inherited runner-level feedback, not these tasks' option-specific teaching. Visible feedback path is unverified.",
  },
  "w4_cheap_price_marginal_call": {
    "decision_kind": "NEW_CURRENT_CURATION",
    "curator_role": "cur01-content-02",
    "objective":
        "Read 10 BB pot, 1 BB call and stated middle pair; distinguish the authored Call from Fold and Raise without inferring cheap means profitable.",
    "source": {
      "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
      "start_line": 16118,
      "end_line": 16186,
      "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
    },
    "immediate_runner_parent": "_world4GoodPriceCallRunner",
    "displayed_operands": ["Pot 10 BB", "To call 1 BB", "9s 7d / Kc 9h 4d 2s"],
    "authored_option_ids_in_runner_declaration": ["call", "fold", "raise"],
    "authored_correct_option_id": "call",
    "correctness_claim": "SOURCE_FLAG_ONLY_NOT_STRATEGIC_VALIDATION",
    "option_order_limit":
        "Task copyWith reorders options for bad_price_fold, cheap_price_marginal_call and big_price_marginal_fold; IDs and authored flags are the references, not option positions.",
    "required_earlier_task_ids": [
      "actions_call_drill",
      "actions_fold_drill",
      "hand_rankings_pair_drill",
      "w4_price_intro",
    ],
    "skill_ids": [
      "read_price_labels",
      "compare_price_with_hand",
      "read_pair_subtypes",
    ],
    "introduction_or_application": "APPLICATION",
    "teaching_semantics":
        "Own teaching/option feedback favors a cheap continue and rejects extra raising risk. Middle-pair terminology and strategic sufficiency are not established by the intro.",
    "source_feedback_limit":
        "Historical runner_feedback_source is preserved. For first five tasks its flop sentence is inherited runner-level feedback, not these tasks' option-specific teaching. Visible feedback path is unverified.",
  },
  "w4_big_price_marginal_fold": {
    "decision_kind": "NEW_CURRENT_CURATION",
    "curator_role": "cur01-content-02",
    "objective":
        "Read 9 BB pot, 6 BB call and stated top pair with weak kicker; explain the authored Fold and avoid treating top pair as an automatic continue.",
    "source": {
      "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
      "start_line": 16188,
      "end_line": 16260,
      "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
    },
    "immediate_runner_parent": "_world4BadPriceFoldRunner",
    "displayed_operands": ["Pot 9 BB", "To call 6 BB", "Qs 7d / Qh Jc 3d 2s"],
    "authored_option_ids_in_runner_declaration": ["fold", "call", "raise"],
    "authored_correct_option_id": "fold",
    "correctness_claim": "SOURCE_FLAG_ONLY_NOT_STRATEGIC_VALIDATION",
    "option_order_limit":
        "Task copyWith reorders options for bad_price_fold, cheap_price_marginal_call and big_price_marginal_fold; IDs and authored flags are the references, not option positions.",
    "required_earlier_task_ids": [
      "actions_fold_drill",
      "hand_rankings_pair_drill",
      "showdown_kicker_drill",
      "w4_price_intro",
    ],
    "skill_ids": [
      "read_price_labels",
      "compare_price_with_hand",
      "read_pair_subtypes",
    ],
    "introduction_or_application": "APPLICATION",
    "teaching_semantics":
        "Own teaching and feedback call this a thin hand for the price; kicker teaching supplies vocabulary, not evidence that this fold is strategically forced.",
    "source_feedback_limit":
        "Historical runner_feedback_source is preserved. For first five tasks its flop sentence is inherited runner-level feedback, not these tasks' option-specific teaching. Visible feedback path is unverified.",
  },
  "w4_price_recap": {
    "decision_kind": "NEW_CURRENT_CURATION",
    "curator_role": "cur01-content-02",
    "objective":
        "Restate the pot, to-call and hand-strength checklist; identify future-card analysis as not taught here.",
    "source": {
      "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
      "start_line": 16262,
      "end_line": 16278,
      "commit": "455f240d2a4e8646725187536a77fb23a56eb1a6",
    },
    "immediate_runner_parent": "_world4PriceIntroRunner",
    "displayed_operands": [
      "inherits Pot 8 BB",
      "inherits To call 2 BB",
      "inherits Turn board",
    ],
    "authored_option_ids_in_runner_declaration": [],
    "authored_correct_option_id": null,
    "correctness_claim": "NO_OPTION_GRADING_IN_DECLARATION",
    "option_order_limit":
        "Task copyWith reorders options for bad_price_fold, cheap_price_marginal_call and big_price_marginal_fold; IDs and authored flags are the references, not option positions.",
    "required_earlier_task_ids": ["w4_price_intro"],
    "skill_ids": ["read_price_labels", "compare_price_with_hand"],
    "introduction_or_application": "RECAP",
    "teaching_semantics":
        "Review has no options; explicit feedback and teaching restate the checklist. Hint adds future cards without an analysis method.",
    "source_feedback_limit":
        "Historical runner_feedback_source is preserved. For first five tasks its flop sentence is inherited runner-level feedback, not these tasks' option-specific teaching. Visible feedback path is unverified.",
  },
};
const _callPriceSummary = r'''

## New current curation proposal: call_price (six existing tasks)

PREPARED FOR INDEPENDENT REVIEW by `cur01-content-02`. These goals and prerequisites are new curation decisions, not recovered historical intent or learner proof. This section reads current main `455f240d2a4e8646725187536a77fb23a56eb1a6`, State blob `ee9e54ac8ea6f53246fa453b4abf3781e386b65f`. All historical fields above and in JSON remain unchanged. JSON `call_price.current_curation` and the six task-local sections carry the full mapping.

Goal: read the displayed pot and call amount with the stated hand, identify the authored example choice, and explain the price checklist while keeping unsupported strategic conclusions explicit.

| Existing task | New narrow objective / source | Introduction or dependency |
| --- | --- | --- |
| `w4_price_intro` | Identify the price to continue by reading Pot and To call. [runner source](https://github.com/ClubBoss/sharky-standalone-direction/blob/455f240d2a4e8646725187536a77fb23a56eb1a6/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15958) | Introduces price labels; names hand strength, without a decision criterion. |
| `w4_good_price_call` | Read 8 BB pot, 1 BB call and one pair; explain that Call is the source-authored answer, while its profitability remains unproved. [runner source](https://github.com/ClubBoss/sharky-standalone-direction/blob/455f240d2a4e8646725187536a77fb23a56eb1a6/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16015) | Applies `w4_price_intro`; see JSON for direct vocabulary dependencies. |
| `w4_bad_price_fold` | Read 8 BB pot, 7 BB call and weak pair; explain that Fold is the source-authored answer and why the example labels the price high. [runner source](https://github.com/ClubBoss/sharky-standalone-direction/blob/455f240d2a4e8646725187536a77fb23a56eb1a6/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16070) | Applies `w4_price_intro`; see JSON for direct vocabulary dependencies. |
| `w4_cheap_price_marginal_call` | Read 10 BB pot, 1 BB call and stated middle pair; distinguish the authored Call from Fold and Raise without inferring cheap means profitable. [runner source](https://github.com/ClubBoss/sharky-standalone-direction/blob/455f240d2a4e8646725187536a77fb23a56eb1a6/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16118) | Applies `w4_price_intro`; see JSON for direct vocabulary dependencies. |
| `w4_big_price_marginal_fold` | Read 9 BB pot, 6 BB call and stated top pair with weak kicker; explain the authored Fold and avoid treating top pair as an automatic continue. [runner source](https://github.com/ClubBoss/sharky-standalone-direction/blob/455f240d2a4e8646725187536a77fb23a56eb1a6/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16188) | Applies `w4_price_intro`; see JSON for direct vocabulary dependencies. |
| `w4_price_recap` | Restate the pot, to-call and hand-strength checklist; identify future-card analysis as not taught here. [runner source](https://github.com/ClubBoss/sharky-standalone-direction/blob/455f240d2a4e8646725187536a77fb23a56eb1a6/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16262) | Applies `w4_price_intro`; see JSON for direct vocabulary dependencies. |

Newly curated direct prerequisites: `what_poker_is_pot_stack` (pot labels; State L8724), `actions_call_drill` (matching the bet / raising adds chips; L9557), `actions_fold_drill` (give up rather than pay; L9456), `hand_rankings_pair_drill` (matching ranks; L10250), `showdown_kicker_drill` (side card tie break; L11048). Their source teaching precedes this lesson in the existing map; this does not prove completion or understanding. No route requirements change.

Gaps: earlier explicit teaching of top/middle/weak pair in this decision context is UNKNOWN; enough hand strength is not defined; opponent holdings/ranges, equity, future action and pot accounting convention are absent. Cheap price does not by itself prove Call. The recap adds future cards without teaching their evaluation. The first five historical generic feedback strings are inherited runner-level flop copy; specific action-option feedback was inspected separately. Final visible feedback remains unverified.

This proposal does not change strategy, grading, runtime, task IDs, XP, routing, source-map revision or historical provenance. Exact generator serialization and historical State/Preview guards require the separate maintenance decision in `MAINTENANCE.md` before integration. No CUR-01.a, CUR-02.a, 0.3, native or Human acceptance is claimed.
''';

String _blob(String path) {
  final result = Process.runSync('git', ['hash-object', path]);
  if (result.exitCode != 0) throw StateError('Cannot identify source: $path');
  return (result.stdout as String).trim();
}

int? _line(String source, String needle) {
  final index = source.indexOf(needle);
  return index == -1
      ? null
      : '\n'.allMatches(source.substring(0, index)).length + 1;
}

Map<String, Object?> buildFoundationSourceMapV1() {
  final stateBlob = _blob(_state);
  final previewBlob = _blob(_preview);
  if (stateBlob != '3fcc919efb9cb0aa48940514c60d800c3362d038' ||
      previewBlob != '8b5f358e2d24b897384fe244a6c5255fd1e8cc90') {
    throw StateError(
      'Source revision changed; review and version the source map.',
    );
  }
  final source = File(_state).readAsStringSync();
  final preview = File(_preview).readAsStringSync();
  final helperLessonIds = RegExp(
    r"_lessonFromTasksV1\(\s*lessonId:\s*'([^']+)'",
  ).allMatches(source).map((m) => m.group(1)).toSet();
  final worlds = Act0SourceParser(source)
      .parse()
      .worlds
      .where((w) => w.worldNumber >= 1 && w.worldNumber <= 4)
      .toList();
  if (worlds.length != 4)
    throw StateError('Foundation world coverage changed.');
  final taskIds = <String>{};
  final lessonIds = <String>{};
  final gaps = <Map<String, String>>[];
  final rows = <Map<String, Object?>>[];
  for (var wi = 0; wi < worlds.length; wi += 1) {
    final world = worlds[wi];
    if (world.worldNumber != wi + 1 || world.lessons.isEmpty) {
      throw StateError('Foundation world order/lessons changed.');
    }
    final earlierLessons = <String>[];
    final lessons = <Map<String, Object?>>[];
    for (final lesson in world.lessons) {
      if (!lessonIds.add(lesson.lessonId) ||
          lesson.subtitle.trim().isEmpty ||
          lesson.tasks.isEmpty) {
        throw StateError('Duplicate lesson or missing authored goal/tasks.');
      }
      final tasks = <Map<String, Object?>>[];
      for (var ti = 0; ti < lesson.tasks.length; ti += 1) {
        final task = lesson.tasks[ti];
        if (!taskIds.add(task.taskId))
          throw StateError('Task ID collision: ${task.taskId}');
        final helper = helperLessonIds.contains(lesson.lessonId);
        final prefix = '${lesson.lessonId}_';
        if (helper && !task.taskId.startsWith(prefix))
          throw StateError('Missing helper prefix.');
        final sourceTaskId = helper
            ? task.taskId.substring(prefix.length)
            : task.taskId;
        final line = _line(source, "taskId: '$sourceTaskId'");
        if (line == null)
          throw StateError('Missing source task declaration: $sourceTaskId');
        final unknown = <String>[
          if (task.runnerName == null)
            'runner expression not resolved by source parser',
          if (task.question == null)
            'runner question not resolved by source parser',
          if (task.feedbackReason == null)
            'runner feedback not resolved by source parser',
          if (task.phase == 'unknown') 'phase not resolved by source parser',
        ];
        if (unknown.isNotEmpty)
          gaps.add({'task_id': task.taskId, 'gap': unknown.join('; ')});
        tasks.add({
          'task_id': task.taskId,
          'title': task.title,
          'authored_phase': task.phase,
          'authored_step_kind': task.stepKind,
          'runner_reference': task.runnerName,
          'runner_question_source': task.question,
          'runner_feedback_source': task.feedbackReason,
          'source_task_id': sourceTaskId,
          'source_line': line,
          'source_helper_retitled': helper,
          'earlier_task_ids_in_lesson': lesson.tasks
              .take(ti)
              .map((t) => t.taskId)
              .toList(),
          'runtime_independence_unseen_and_human': 'NOT_VERIFIED_BY_SOURCE_MAP',
          'source_copy_gaps': unknown,
          if (lesson.lessonId == 'call_price')
            'current_curation': _callPriceTaskCuration[task.taskId]!,
        });
      }
      lessons.add({
        'lesson_id': lesson.lessonId,
        'title': lesson.title,
        'authored_goal': lesson.subtitle,
        'source_line': _line(source, "lessonId: '${lesson.lessonId}'"),
        'prior_lesson_ids_in_world': List<String>.of(earlierLessons),
        'prerequisite_kind':
            'source-order path closure, not demonstrated mastery',
        'profile_dependent_availability': 'NOT_VERIFIED_BY_SOURCE_MAP',
        'tasks': tasks,
        if (lesson.lessonId == 'call_price')
          'current_curation': _callPriceCuration,
      });
      earlierLessons.add(lesson.lessonId);
    }
    rows.add({
      'world_id': world.worldId,
      'world_number': world.worldNumber,
      'title': world.title,
      'authored_goal': world.subtitle,
      'prior_world_id': wi == 0 ? null : worlds[wi - 1].worldId,
      'lessons': lessons,
    });
  }
  return {
    'schema': 'act0_foundation_source_map_v1',
    'map_revision': 3,
    'source_status': 'PREPARED_ONB_ACK_CANDIDATE_NOT_PUBLISHED_OR_ACCEPTED',
    'source_delta': {
      'composition_base_commit': '86f9ffb294d3ed529edab01e9c1c6b381a284fa2',
      'scope':
          'first-start ACK/cache/retry lifecycle only; route gates unchanged',
      'preview_prior_git_blob': 'e2f837841997402cbd4c08a6a308587c080ae480',
      'preview_candidate_git_blob': previewBlob,
      'prior_utc_patch_sha256':
          'ef9686afe5b9ef5d1e6e0501192098050ef2bf9f73de11173a62f1a81de82e07',
      'runtime_composition_and_human': 'NOT_VERIFIED',
      'prior_source_delta': {
        'composition_base_commit': '6e848de8c11caa312af37347550ebde714d4b47c',
        'scope':
            'strict whole-cache retention admission only; route gates unchanged',
        'preview_prior_git_blob': 'e4e977674457061c8345da2ffe94ad72a75209e9',
        'preview_candidate_git_blob':
            'e2f837841997402cbd4c08a6a308587c080ae480',
        'utc_patch_sha256':
            'ef9686afe5b9ef5d1e6e0501192098050ef2bf9f73de11173a62f1a81de82e07',
        'runtime_composition_and_human': 'NOT_VERIFIED',
      },
    },
    'scope':
        'W1-W4 source traceability preparation; not course/runtime/Human acceptance',
    'source_base_commit': _base,
    'source_git_blobs': {
      _state: stateBlob,
      _preview: previewBlob,
      _parser: _blob(_parser),
    },
    'gate_semantics': {
      'path_closed': 'completed task IDs union Placement-skipped task IDs',
      'world_gate':
          'previous world path closed; each lesson task path closed for propagation',
      'lesson_gate':
          'world available and lesson completed or first incomplete lesson',
      'task_gate':
          'completed or skipped replay, otherwise first path-incomplete task',
      'earned_display':
          'completed task IDs only; skipped does not prove earned work',
      'assessment':
          'route closure is not independent correctness, unseen transfer, elapsed retention or mastery',
      'preview_source_lines': {
        '_pathClosedTaskIds': _line(
          preview,
          '  Set<String> get _pathClosedTaskIds',
        ),
        '_progressWorldsWithTaskIds': _line(
          preview,
          '  List<Act0WorldCardV1> _progressWorldsWithTaskIds(',
        ),
        '_progressWorld': _line(preview, '  Act0WorldCardV1 _progressWorld('),
        '_progressLesson': _line(
          preview,
          '  Act0LessonCardV1 _progressLesson(',
        ),
        '_taskAvailable': _line(preview, '  bool _taskAvailable('),
      },
    },
    'counts': {
      'worlds': worlds.length,
      'lessons': lessonIds.length,
      'tasks': taskIds.length,
      'source_copy_gaps': gaps.length,
    },
    'worlds': rows,
    'source_copy_gaps': gaps,
    'remaining': [
      'Resolve any listed source-copy gaps before claiming complete copy coverage.',
      'Verify genuine graded independent tasks, explanation and repair at the admitted runtime boundary.',
      'Prove all claimed transitions/unlock negative cases with applicable checks; this is no source-only PASS for CUR-08.',
      'Human understanding and efficacy remain separately gated; no points or full CUR/0.3 acceptance.',
    ],
  };
}

String renderFoundationSourceMapV1(Map<String, Object?> map) {
  final out = StringBuffer('# Foundation W1-W4 source map v1 - revision 3\n\n');
  out.writeln(
    'Status: PREPARED ONB ACK CANDIDATE SOURCE TRACE ONLY; NOT PUBLISHED OR ACCEPTED. Parent CUR-01, 0.3, runtime and Human acceptance are not granted.',
  );
  out.writeln(
    '\nBase: `$_base`. The JSON companion lists exact source Git blobs, canonical task IDs, source declarations and unresolved fields. Content-source links retain the unchanged historical base. Composition base: 86f9ffb294d3ed529edab01e9c1c6b381a284fa2. Preview is an unpublished ONB ACK/retry delta, not a blob in that base commit. Revision 2 UTC provenance is retained in the JSON source_delta.prior_source_delta; its patch SHA256 remains ef9686afe5b9ef5d1e6e0501192098050ef2bf9f73de11173a62f1a81de82e07. Prior revisions remain historical; their acceptance does not transfer. Route gates and content are unchanged by this delta.',
  );
  out.writeln(
    '\nThis inventory follows current Act0 world names and actual helper-retitled task IDs. Lesson goals quote authored subtitles. Earlier lessons/tasks describe source order; they are not new pedagogical prerequisites or evidence of learning.',
  );
  out.writeln(
    '\nRouting uses completed plus Placement-skipped task IDs. A skipped task can close the route without earning XP or proving a correct independent choice. Availability depends on persisted learner state; authored sample lock flags are not runtime proof.',
  );
  for (final world in (map['worlds'] as List).cast<Map<String, Object?>>()) {
    out.writeln('\n## ${world['world_id']}: ${world['title']}\n');
    out.writeln('Authored goal: ${world['authored_goal']}\n');
    out.writeln(
      'Previous world path gate: ${world['prior_world_id'] ?? 'none'}.\n',
    );
    out.writeln(
      '| Lesson | Authored goal | Earlier lessons in this world | Canonical task IDs in actual order |',
    );
    out.writeln('| --- | --- | --- | --- |');
    for (final lesson
        in (world['lessons'] as List).cast<Map<String, Object?>>()) {
      final tasks = (lesson['tasks'] as List).cast<Map<String, Object?>>();
      final ids = tasks.map((t) => '`${t['task_id']}`').join(', ');
      final before = (lesson['prior_lesson_ids_in_world'] as List)
          .map((id) => '`$id`')
          .join(', ');
      out.writeln(
        '| [${lesson['lesson_id']}](https://github.com/ClubBoss/sharky-standalone-direction/blob/$_base/$_state#L${lesson['source_line']}) | ${lesson['authored_goal']} | ${before.isEmpty ? 'none' : before} | $ids |',
      );
    }
  }
  out.writeln('\n## Limits and reproduction\n');
  out.writeln(
    'The repaired existing source parser supplies this inventory; it does not execute Flutter, resolve arbitrary Dart expressions, grade choices, measure usability or prove native persistence. Unknown runner expressions/copy remain explicit JSON gaps. Source question/feedback is not a claim about final rendered UI.',
  );
  out.writeln(
    '\nRun `dart tools/check_act0_content_copy_source_parser_v1.dart`, then `dart tools/act0_foundation_source_map_v1.dart --check` from the repository root with the compatible standalone Dart VM. No Flutter initialization or dependency download is needed. `--write` regenerates both companion files only after the exact State/Preview source pins match. Changed pins require an intentional map revision and review.',
  );
  out.writeln(
    '\nThe map has ${map['counts']}. Full Foundation source, graded runtime, negative route controls and admitted Human proof remain distinct. Original DoDs, weights, protected gates and existing holds remain unchanged.',
  );
  out.write(_callPriceSummary);
  return out.toString();
}

void main(List<String> args) {
  if (args.length != 1 || !{'--write', '--check'}.contains(args.single)) {
    stderr.writeln(
      'Usage: dart tools/act0_foundation_source_map_v1.dart --write|--check',
    );
    exitCode = 64;
    return;
  }
  final map = buildFoundationSourceMapV1();
  final json = '${const JsonEncoder.withIndent('  ').convert(map)}\n';
  final markdown = renderFoundationSourceMapV1(map);
  if (args.single == '--write') {
    File(_jsonPath).writeAsStringSync(json);
    File(_mdPath).writeAsStringSync(markdown);
  } else if (!File(_jsonPath).existsSync() ||
      !File(_mdPath).existsSync() ||
      File(_jsonPath).readAsStringSync() != json ||
      File(_mdPath).readAsStringSync() != markdown) {
    stderr.writeln(
      'FAIL Foundation source map is missing/stale/tampered; no source acceptance.',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln(
    jsonEncode({
      'operation': args.single,
      'source_trace_only': true,
      'counts': map['counts'],
    }),
  );
}

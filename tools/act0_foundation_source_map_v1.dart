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

// Independently reviewed finite documentary proposal; dated1bdd provenance
// retained, with only three explicit later-source qualifications.
const Map<String, Object?> _purposeTaskCuration = {
  "w4_purpose_intro": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Every bet should have a simple purpose.",
      "existing_map_pointer": "/worlds/3/lessons/0/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Name value, bluff and protection as purposes before asking for a bet size.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_purpose_intro",
        "field": "question",
        "owner": "_world4PurposeIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15812, 15838],
          "sha256":
              "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
        },
        "declaration":
            "  question: 'What should you name before sizing a bet?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_purpose_intro",
        "field": "teachingSteps",
        "owner": "_world4PurposeIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15812, 15838],
          "sha256":
              "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
      },
      {
        "quote":
            "Value gets calls, bluff gets folds, protection makes the next card cost money.",
        "owner": "_world4PurposeIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15834, 15834],
          "sha256":
              "ec582677ef61f475a409a49dcb199877ab270b96ee1cbcfdac6b0dfdd08fa7e8",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15834",
        },
      },
      {
        "quote":
            "Value gets calls, bluff gets folds, protection makes the next card cost money.",
        "owner": "_world4PurposeIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15834, 15834],
          "sha256":
              "ec582677ef61f475a409a49dcb199877ab270b96ee1cbcfdac6b0dfdd08fa7e8",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15834",
        },
      },
      {
        "quote":
            "Value gets calls, bluff gets folds, protection makes the next card cost money.",
        "owner": "_world4PurposeIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15834, 15834],
          "sha256":
              "ec582677ef61f475a409a49dcb199877ab270b96ee1cbcfdac6b0dfdd08fa7e8",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15834",
        },
      },
      {
        "quote": "protection makes the next card cost money.",
        "owner": "_world4PurposeIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15834, 15834],
          "sha256":
              "ec582677ef61f475a409a49dcb199877ab270b96ee1cbcfdac6b0dfdd08fa7e8",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15834",
        },
      },
    ],
    "instructional_role":
        "INTRODUCE_PURPOSE_AND_PROTECTION_WITH_PARTIAL_VALUE_BLUFF_OVERVIEW",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bet_purpose",
        "role": "SOURCE_INTRODUCTION",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
      {
        "concept_id": "value_worse_calls",
        "role": "PARTIAL_SHORTHAND",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
      {
        "concept_id": "bluff_better_folds",
        "role": "PARTIAL_SHORTHAND",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
      {
        "concept_id": "protection_denies_free_cards",
        "role": "SOURCE_INTRODUCTION",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "caption",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  caption: 'A bet should have a reason before it has a size.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [],
        "prior_lesson_ids_in_world": [],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
    "post_authoring_source_qualification": {
      "qualification_kind":
          "LATER_SOURCE_ONLY_DELTA_NOT_RETROACTIVE_OLD_FACTS_OR_EXPOSURE",
      "original_annotation_basis": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
      "later_source_origin": "19b1f23145a8cddf0a95ce87c6588fe1047cd0bd",
      "later_package": "WP03-W4-PURPOSE-INTRO-REPAIR-01",
      "earlier_teaching_task_id": "w4_purpose_intro",
      "current_teaching_body":
          "Name the bet purpose first. Value means worse hands can still call. A bluff tries to make better hands fold. Protection makes the next card cost money.",
      "teaching_body_utf8_sha256":
          "934299c41ff4ea3b0ce255dcc9862e8035d8747aabf1b956478470afceeeda1a",
      "qualification":
          "The source overview now explicitly states worse-call value and better-fold bluff meanings. Original PARTIAL_SHORTHAND/omission evidence below is a dated1bdd snapshot, not a claim about the later source. The source now offers an earlier precise teaching input; neither actual-before-choice exposure gap is closed.",
      "render_evidence":
          "Direct EN393x852 widget full text reachable through existing theory-support scroll; ordinary learner entry/prechoice order UNKNOWN.",
      "assessment_and_study":
          "Assessment FP unchanged; separate teaching-study revision changes. Old raw study remains readable but does not establish the revised text.",
      "both_actual_prior_intro_gaps": "UNKNOWN_OPEN",
      "parent_acceptance_or_points": "NONE",
    },
  },
  "w4_value_purpose": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Every bet should have a simple purpose.",
      "existing_map_pointer": "/worlds/3/lessons/0/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Identify the authored value purpose from the stated stronger-hand/weaker-caller premise; distinguish it from bluff.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_purpose",
        "field": "question",
        "owner": "_world4ValuePurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15840, 15885],
          "sha256":
              "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
        },
        "declaration": "  question: 'What is the main purpose?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_purpose",
        "field": "teachingSteps",
        "owner": "_world4ValuePurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15840, 15885],
          "sha256":
              "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
      },
      {
        "quote": "A value bet wants weaker hands to call.",
        "owner": "_world4ValuePurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15855, 15855],
          "sha256":
              "d85e1cebb030528c0faf536fa7080e0612485b49028a367af3f7d7d5c6508e6f",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15855",
        },
      },
      {
        "quote":
            "Hero is not trying to fold out everything; weaker hands can pay.",
        "owner": "_world4ValuePurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15866, 15866],
          "sha256":
              "5ad88fd2890343efdfb610af228a71ff81306dcadf3446797d7fc7a48b05fe30",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15866",
        },
      },
    ],
    "instructional_role": "APPLICATION_WITH_SAME_TASK_PRECISE_EXPLANATION",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bet_purpose",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": ["w4_purpose_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_purpose_intro",
            "field": "teachingSteps",
            "owner": "_world4PurposeIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15812, 15838],
              "sha256":
                  "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_purpose",
          "field": "teachingSteps",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
      {
        "concept_id": "value_worse_calls",
        "role": "FIRST_APPLICATION_GAP_PRECISE_PRIOR_INTRO_NOT_PROVED",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_purpose",
          "field": "teachingSteps",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_purpose_intro",
        "concept_id": "bet_purpose",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Name the intended job of a bet before choosing its size.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_purpose",
          "field": "question",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration": "  question: 'What is the main purpose?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_purpose",
          "field": "caption",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration":
              "  caption: 'Hero has top pair on A-7-2 after BB checks.',",
        },
      },
      {
        "knowledge":
            "Precise weaker-call or better-fold definition before its first required application.",
        "status": "GAP",
        "reason":
            "Only calls/folds shorthand precedes this task. Precise same-task explanation does not prove it was introduced before use.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_purpose",
          "field": "options",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'value',\n      label: 'Value',\n      isCorrect: true,\n      preferredLabel: 'Value',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Solid understanding.',\n      feedbackReason: 'A value bet wants weaker hands to call.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'bluff',\n      label: 'Bluff',\n      isCorrect: false,\n      preferredLabel: 'Value',\n      betterAnswerLabel: 'Value',\n      quality: Act0FeedbackQualityV1.wrong,\n      feedbackTitle: 'One more step.',\n      feedbackReason:\n          'Hero is not trying to fold out everything; weaker hands can pay.',\n    ),\n  ],",
        },
        "earlier_overview_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_purpose_intro"],
        "prior_lesson_ids_in_world": [],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
    "post_authoring_source_qualification": {
      "qualification_kind":
          "LATER_SOURCE_ONLY_DELTA_NOT_RETROACTIVE_OLD_FACTS_OR_EXPOSURE",
      "original_annotation_basis": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
      "later_source_origin": "19b1f23145a8cddf0a95ce87c6588fe1047cd0bd",
      "later_package": "WP03-W4-PURPOSE-INTRO-REPAIR-01",
      "earlier_teaching_task_id": "w4_purpose_intro",
      "current_teaching_body":
          "Name the bet purpose first. Value means worse hands can still call. A bluff tries to make better hands fold. Protection makes the next card cost money.",
      "teaching_body_utf8_sha256":
          "934299c41ff4ea3b0ce255dcc9862e8035d8747aabf1b956478470afceeeda1a",
      "qualification":
          "The source overview now explicitly states worse-call value and better-fold bluff meanings. Original PARTIAL_SHORTHAND/omission evidence below is a dated1bdd snapshot, not a claim about the later source. The source now offers an earlier precise teaching input; neither actual-before-choice exposure gap is closed.",
      "render_evidence":
          "Direct EN393x852 widget full text reachable through existing theory-support scroll; ordinary learner entry/prechoice order UNKNOWN.",
      "assessment_and_study":
          "Assessment FP unchanged; separate teaching-study revision changes. Old raw study remains readable but does not establish the revised text.",
      "both_actual_prior_intro_gaps": "UNKNOWN_OPEN",
      "parent_acceptance_or_points": "NONE",
    },
  },
  "w4_bluff_purpose": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Every bet should have a simple purpose.",
      "existing_map_pointer": "/worlds/3/lessons/0/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Identify the authored bluff purpose as trying to make better hands fold; distinguish it from value.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_purpose",
        "field": "question",
        "owner": "_world4BluffPurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15887, 15930],
          "sha256":
              "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
        },
        "declaration": "  question: 'What is the main purpose?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_purpose",
        "field": "teachingSteps",
        "owner": "_world4BluffPurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15887, 15930],
          "sha256":
              "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
      },
      {
        "quote": "A bluff tries to make better hands fold.",
        "owner": "_world4BluffPurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15901, 15901],
          "sha256":
              "beddefcee49c7782000f4f0dfb1edfcae74c17734ac37437c770332164948ece",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15901",
        },
      },
      {
        "quote": "Hero missed, so the bet is not asking weaker hands to pay.",
        "owner": "_world4BluffPurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15912, 15912],
          "sha256":
              "2f529095e20908268b25e36b9b4c0b90f0a15e6a48574a673ba320805c61e7fc",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15912",
        },
      },
    ],
    "instructional_role": "APPLICATION_WITH_SAME_TASK_PRECISE_EXPLANATION",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bet_purpose",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": ["w4_purpose_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_purpose_intro",
            "field": "teachingSteps",
            "owner": "_world4PurposeIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15812, 15838],
              "sha256":
                  "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_purpose",
          "field": "teachingSteps",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
      {
        "concept_id": "bluff_better_folds",
        "role": "FIRST_APPLICATION_GAP_PRECISE_PRIOR_INTRO_NOT_PROVED",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_purpose",
          "field": "teachingSteps",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_purpose_intro",
        "concept_id": "bet_purpose",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Name the intended job of a bet before choosing its size.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_purpose",
          "field": "question",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration": "  question: 'What is the main purpose?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_purpose",
          "field": "caption",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration": "  caption: 'Hero missed on A-7-2 after BB checks.',",
        },
      },
      {
        "knowledge":
            "Precise weaker-call or better-fold definition before its first required application.",
        "status": "GAP",
        "reason":
            "Only calls/folds shorthand precedes this task. Precise same-task explanation does not prove it was introduced before use.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_purpose",
          "field": "options",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'bluff',\n      label: 'Bluff',\n      isCorrect: true,\n      preferredLabel: 'Bluff',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Well done.',\n      feedbackReason: 'A bluff tries to make better hands fold.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'value',\n      label: 'Value',\n      isCorrect: false,\n      preferredLabel: 'Bluff',\n      betterAnswerLabel: 'Bluff',\n      quality: Act0FeedbackQualityV1.wrong,\n      feedbackTitle: 'Getting warmer.',\n      feedbackReason:\n          'Hero missed, so the bet is not asking weaker hands to pay.',\n    ),\n  ],",
        },
        "earlier_overview_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_purpose_intro", "w4_value_purpose"],
        "prior_lesson_ids_in_world": [],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
    "post_authoring_source_qualification": {
      "qualification_kind":
          "LATER_SOURCE_ONLY_DELTA_NOT_RETROACTIVE_OLD_FACTS_OR_EXPOSURE",
      "original_annotation_basis": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
      "later_source_origin": "19b1f23145a8cddf0a95ce87c6588fe1047cd0bd",
      "later_package": "WP03-W4-PURPOSE-INTRO-REPAIR-01",
      "earlier_teaching_task_id": "w4_purpose_intro",
      "current_teaching_body":
          "Name the bet purpose first. Value means worse hands can still call. A bluff tries to make better hands fold. Protection makes the next card cost money.",
      "teaching_body_utf8_sha256":
          "934299c41ff4ea3b0ce255dcc9862e8035d8747aabf1b956478470afceeeda1a",
      "qualification":
          "The source overview now explicitly states worse-call value and better-fold bluff meanings. Original PARTIAL_SHORTHAND/omission evidence below is a dated1bdd snapshot, not a claim about the later source. The source now offers an earlier precise teaching input; neither actual-before-choice exposure gap is closed.",
      "render_evidence":
          "Direct EN393x852 widget full text reachable through existing theory-support scroll; ordinary learner entry/prechoice order UNKNOWN.",
      "assessment_and_study":
          "Assessment FP unchanged; separate teaching-study revision changes. Old raw study remains readable but does not establish the revised text.",
      "both_actual_prior_intro_gaps": "UNKNOWN_OPEN",
      "parent_acceptance_or_points": "NONE",
    },
  },
  "w4_purpose_recap": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Every bet should have a simple purpose.",
      "existing_map_pointer": "/worlds/3/lessons/0/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Restate that purpose comes before size and recall the three named purposes.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_purpose_recap",
        "field": "question",
        "owner": "_world4PurposeRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15932, 15948],
          "sha256":
              "56d4c4912c135559d7c7af5299bc505e4598823f570c1cdcb6a9c9f8ac5017d4",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15932",
        },
        "declaration": "  question: 'What comes before the bet size?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_purpose_recap",
        "field": "teachingSteps",
        "owner": "_world4PurposeRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15932, 15948],
          "sha256":
              "56d4c4912c135559d7c7af5299bc505e4598823f570c1cdcb6a9c9f8ac5017d4",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15932",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose checklist.',\n      body: 'Ask what the bet wants before asking how big it should be.',\n      focusLabels: <String>['Purpose', 'Then size'],\n    ),\n  ],",
      },
      {
        "quote":
            "Value gets calls. Bluff gets folds. Protection denies free cards.",
        "owner": "_world4PurposeRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15936, 15936],
          "sha256":
              "9194ecf60c327a09e10f6044cf8490c54e4284cdd0b0822d525b321a73cb89dd",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15936",
        },
      },
      {
        "quote":
            "Value gets calls. Bluff gets folds. Protection denies free cards.",
        "owner": "_world4PurposeRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15936, 15936],
          "sha256":
              "9194ecf60c327a09e10f6044cf8490c54e4284cdd0b0822d525b321a73cb89dd",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15936",
        },
      },
      {
        "quote":
            "Value gets calls. Bluff gets folds. Protection denies free cards.",
        "owner": "_world4PurposeRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15936, 15936],
          "sha256":
              "9194ecf60c327a09e10f6044cf8490c54e4284cdd0b0822d525b321a73cb89dd",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15936",
        },
      },
      {
        "quote": "Protection denies free cards.",
        "owner": "_world4PurposeRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15936, 15936],
          "sha256":
              "9194ecf60c327a09e10f6044cf8490c54e4284cdd0b0822d525b321a73cb89dd",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15936",
        },
      },
    ],
    "instructional_role": "RECAP_WITHOUT_INDEPENDENT_OPTION_CHECK",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bet_purpose",
        "role": "RECAP",
        "earlier_source_supported_introduction_task_ids": ["w4_purpose_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_purpose_intro",
            "field": "teachingSteps",
            "owner": "_world4PurposeIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15812, 15838],
              "sha256":
                  "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_recap",
          "field": "teachingSteps",
          "owner": "_world4PurposeRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15932, 15948],
            "sha256":
                "56d4c4912c135559d7c7af5299bc505e4598823f570c1cdcb6a9c9f8ac5017d4",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15932",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose checklist.',\n      body: 'Ask what the bet wants before asking how big it should be.',\n      focusLabels: <String>['Purpose', 'Then size'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_purpose_intro",
        "concept_id": "bet_purpose",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Name the intended job of a bet before choosing its size.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_recap",
          "field": "question",
          "owner": "_world4PurposeRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15932, 15948],
            "sha256":
                "56d4c4912c135559d7c7af5299bc505e4598823f570c1cdcb6a9c9f8ac5017d4",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15932",
          },
          "declaration": "  question: 'What comes before the bet size?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_recap",
          "field": "caption",
          "owner": "_world4PurposeRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15932, 15948],
            "sha256":
                "56d4c4912c135559d7c7af5299bc505e4598823f570c1cdcb6a9c9f8ac5017d4",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15932",
          },
          "declaration":
              "  caption: 'Lesson learned: name the purpose before the size.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [
          "w4_purpose_intro",
          "w4_value_purpose",
          "w4_bluff_purpose",
        ],
        "prior_lesson_ids_in_world": [],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_value_intro": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet when worse hands can still call.",
      "existing_map_pointer": "/worlds/3/lessons/1/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "State that a value bet needs worse hands that can call, rather than just a strong hand.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_intro",
        "field": "question",
        "owner": "_world4ValueIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15950, 15965],
          "sha256":
              "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
        },
        "declaration": "  question: 'Who should a value bet get called by?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_intro",
        "field": "teachingSteps",
        "owner": "_world4ValueIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15950, 15965],
          "sha256":
              "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
      },
      {
        "quote": "A value bet targets weaker hands that can call.",
        "owner": "_world4ValueIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15954, 15954],
          "sha256":
              "1014221289679afb90593b21286fb63894c8fec95a8e3de331592a57f7a41845",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15954",
        },
      },
    ],
    "instructional_role": "EXPLICIT_DEFINITION_REINFORCEMENT",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "value_worse_calls",
        "role": "EXPLICIT_SOURCE_DEFINITION",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_intro",
          "field": "teachingSteps",
          "owner": "_world4ValueIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15950, 15965],
            "sha256":
                "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_purpose_intro",
        "concept_id": "bet_purpose",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Name the intended job of a bet before choosing its size.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_intro",
          "field": "question",
          "owner": "_world4ValueIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15950, 15965],
            "sha256":
                "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
          },
          "declaration": "  question: 'Who should a value bet get called by?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_intro",
          "field": "caption",
          "owner": "_world4ValueIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15950, 15965],
            "sha256":
                "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
          },
          "declaration":
              "  caption: 'A value bet targets weaker hands that can call.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [],
        "prior_lesson_ids_in_world": ["why_bets_happen"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_value_bet": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet when worse hands can still call.",
      "existing_map_pointer": "/worlds/3/lessons/1/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Relate the stated worse-caller premise to the source-authored value-bet choice; do not infer optimal sizing.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_bet",
        "field": "question",
        "owner": "_world4ValueBetRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15967, 15999],
          "sha256":
              "0ae5a4ca5f864165e1c11434980de36f74e6ffad847ab97db88cd57bea7dfc24",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15967",
        },
        "declaration": "  question: 'What action fits the purpose?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_bet",
        "field": "teachingSteps",
        "owner": "_world4ValuePurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15840, 15885],
          "sha256":
              "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
      },
      {
        "quote": "Half-pot asks weaker hands to pay without using a huge size.",
        "owner": "_world4ValueBetRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15983, 15983],
          "sha256":
              "ba3f8103cf9b717f4d819df8edb42a81df16a94c5de5230f58188b0fca367a0a",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15983",
        },
      },
    ],
    "instructional_role": "APPLICATION",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "value_worse_calls",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": ["w4_value_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_value_intro",
            "field": "teachingSteps",
            "owner": "_world4ValueIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15950, 15965],
              "sha256":
                  "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_bet",
          "field": "teachingSteps",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_value_intro",
        "concept_id": "value_worse_calls",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize value as seeking calls from worse hands.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_intro",
          "field": "teachingSteps",
          "owner": "_world4ValueIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15950, 15965],
            "sha256":
                "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_bet",
          "field": "question",
          "owner": "_world4ValueBetRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15967, 15999],
            "sha256":
                "0ae5a4ca5f864165e1c11434980de36f74e6ffad847ab97db88cd57bea7dfc24",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15967",
          },
          "declaration": "  question: 'What action fits the purpose?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_bet",
          "field": "caption",
          "owner": "_world4ValueBetRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15967, 15999],
            "sha256":
                "0ae5a4ca5f864165e1c11434980de36f74e6ffad847ab97db88cd57bea7dfc24",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15967",
          },
          "declaration":
              "  caption: 'Top pair on a safe flop. BB can call worse.',",
        },
      },
      {
        "knowledge":
            "Interpreting the named one-third/half/pot-size and whether that action/size is strategically justified.",
        "status": "UNKNOWN_OR_OUT_OF_SCOPE",
        "reason":
            "Size/action labels occur in source options; this four-concept package does not prove prior arithmetic instruction or optimality. A label/focus label is not a full introduction.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_bet",
          "field": "options",
          "owner": "_world4ValueBetRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15967, 15999],
            "sha256":
                "0ae5a4ca5f864165e1c11434980de36f74e6ffad847ab97db88cd57bea7dfc24",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15967",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'bet_half',\n      label: 'Bet half-pot',\n      amountLabel: '3 BB',\n      isCorrect: true,\n      preferredLabel: 'Bet half-pot',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Excellent spot.',\n      feedbackReason:\n          'Half-pot asks weaker hands to pay without using a huge size.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'check',\n      label: 'Check',\n      isCorrect: false,\n      preferredLabel: 'Bet half-pot',\n      betterAnswerLabel: 'Bet half-pot',\n      quality: Act0FeedbackQualityV1.wrong,\n      feedbackTitle: 'On the right track.',\n      feedbackReason: 'Checking can miss value when worse hands can call.',\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_value_intro"],
        "prior_lesson_ids_in_world": ["why_bets_happen"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_value_missed": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet when worse hands can still call.",
      "existing_map_pointer": "/worlds/3/lessons/1/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Explain why checking can miss value under the stated premise that worse hands can call.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_missed",
        "field": "question",
        "owner": "_world4ValueCheckMissRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16001, 16030],
          "sha256":
              "137704769143b4260455beec35ce61b4803053562ff7d0b7603de1b755ac8165",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16001",
        },
        "declaration":
            "  question: 'What action best collects value from worse hands here?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_missed",
        "field": "teachingSteps",
        "owner": "_world4ValuePurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15840, 15885],
          "sha256":
              "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
      },
      {
        "quote":
            "A half-pot bet lets worse hands call while you hold the stronger hand.",
        "owner": "_world4ValueCheckMissRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16027, 16027],
          "sha256":
              "6174bff8ac337401ba5391c05304613c52ad725c896522db05d14d94049653a7",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16027",
        },
      },
    ],
    "instructional_role": "APPLICATION",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "value_worse_calls",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": ["w4_value_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_value_intro",
            "field": "teachingSteps",
            "owner": "_world4ValueIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15950, 15965],
              "sha256":
                  "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_missed",
          "field": "teachingSteps",
          "owner": "_world4ValuePurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15840, 15885],
            "sha256":
                "bdfe434442571b23af56390c088809363e06469be3fcbcf1918bd9a0bb0c65bc",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15840",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value wants calls.',\n      body: 'With top pair, weaker pairs and worse aces may continue.',\n      focusCardIds: <String>['hero_0', 'hero_1', 'board_0'],\n      focusLabels: <String>['Top pair', 'Weaker calls'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_value_intro",
        "concept_id": "value_worse_calls",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize value as seeking calls from worse hands.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_intro",
          "field": "teachingSteps",
          "owner": "_world4ValueIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15950, 15965],
            "sha256":
                "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_missed",
          "field": "question",
          "owner": "_world4ValueCheckMissRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16001, 16030],
            "sha256":
                "137704769143b4260455beec35ce61b4803053562ff7d0b7603de1b755ac8165",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16001",
          },
          "declaration":
              "  question: 'What action best collects value from worse hands here?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_missed",
          "field": "caption",
          "owner": "_world4ValueCheckMissRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16001, 16030],
            "sha256":
                "137704769143b4260455beec35ce61b4803053562ff7d0b7603de1b755ac8165",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16001",
          },
          "declaration":
              "  caption: 'Hero has top pair and worse hands can still call a bet.',",
        },
      },
      {
        "knowledge":
            "Interpreting the named one-third/half/pot-size and whether that action/size is strategically justified.",
        "status": "UNKNOWN_OR_OUT_OF_SCOPE",
        "reason":
            "Size/action labels occur in source options; this four-concept package does not prove prior arithmetic instruction or optimality. A label/focus label is not a full introduction.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_missed",
          "field": "options",
          "owner": "_world4ValueCheckMissRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16001, 16030],
            "sha256":
                "137704769143b4260455beec35ce61b4803053562ff7d0b7603de1b755ac8165",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16001",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'check',\n      label: 'Check',\n      isCorrect: false,\n      preferredLabel: 'Bet half-pot',\n      betterAnswerLabel: 'Bet half-pot',\n      quality: Act0FeedbackQualityV1.wrong,\n      feedbackTitle: 'Keep the value chance.',\n      feedbackReason:\n          'Checking leaves value on the table when worse hands can call.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'bet_half',\n      label: 'Bet half-pot',\n      amountLabel: '3 BB',\n      isCorrect: true,\n      preferredLabel: 'Bet half-pot',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Value collected.',\n      feedbackReason:\n          'A half-pot bet lets worse hands call while you hold the stronger hand.',\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_value_intro", "w4_value_bet"],
        "prior_lesson_ids_in_world": ["why_bets_happen"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_value_recap": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet when worse hands can still call.",
      "existing_map_pointer": "/worlds/3/lessons/1/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Restate the worse-calls criterion for value before choosing size.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_recap",
        "field": "question",
        "owner": "_world4ValueRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16032, 16048],
          "sha256":
              "7e6a5ebeebcba4c02e5cae3497b9fda92b0c21d0ad061c053deeb6c4dbee71ee",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16032",
        },
        "declaration": "  question: 'What makes a bet value?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_value_recap",
        "field": "teachingSteps",
        "owner": "_world4ValueRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16032, 16048],
          "sha256":
              "7e6a5ebeebcba4c02e5cae3497b9fda92b0c21d0ad061c053deeb6c4dbee71ee",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16032",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value checklist.',\n      body: 'Ask what worse hands can call before choosing a size.',\n      focusLabels: <String>['Worse calls', 'Size next'],\n    ),\n  ],",
      },
      {
        "quote":
            "A value bet is not just betting a strong hand. It needs weaker hands that can call.",
        "owner": "_world4ValueRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16040, 16040],
          "sha256":
              "246cb4053115ef5aff62d8bd2f1a1ffb16ac14b0deb8bfffc826452263f960b0",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16040",
        },
      },
    ],
    "instructional_role": "RECAP_WITHOUT_INDEPENDENT_OPTION_CHECK",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "value_worse_calls",
        "role": "RECAP",
        "earlier_source_supported_introduction_task_ids": ["w4_value_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_value_intro",
            "field": "teachingSteps",
            "owner": "_world4ValueIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15950, 15965],
              "sha256":
                  "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_recap",
          "field": "teachingSteps",
          "owner": "_world4ValueRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16032, 16048],
            "sha256":
                "7e6a5ebeebcba4c02e5cae3497b9fda92b0c21d0ad061c053deeb6c4dbee71ee",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16032",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Value checklist.',\n      body: 'Ask what worse hands can call before choosing a size.',\n      focusLabels: <String>['Worse calls', 'Size next'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_value_intro",
        "concept_id": "value_worse_calls",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize value as seeking calls from worse hands.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_intro",
          "field": "teachingSteps",
          "owner": "_world4ValueIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15950, 15965],
            "sha256":
                "622d502fdc2411134546397920f8b4ba99ba6cd831c9a3cb47183de494ccdebf",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15950",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Worse calls.',\n      body: 'Value means worse hands can still call.',\n      focusLabels: <String>['Worse hands', 'Call', '3 BB into 6 BB'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_recap",
          "field": "question",
          "owner": "_world4ValueRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16032, 16048],
            "sha256":
                "7e6a5ebeebcba4c02e5cae3497b9fda92b0c21d0ad061c053deeb6c4dbee71ee",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16032",
          },
          "declaration": "  question: 'What makes a bet value?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_value_recap",
          "field": "caption",
          "owner": "_world4ValueRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16032, 16048],
            "sha256":
                "7e6a5ebeebcba4c02e5cae3497b9fda92b0c21d0ad061c053deeb6c4dbee71ee",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16032",
          },
          "declaration":
              "  caption: 'Lesson learned: value means worse can call.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [
          "w4_value_intro",
          "w4_value_bet",
          "w4_value_missed",
        ],
        "prior_lesson_ids_in_world": ["why_bets_happen"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_bluff_intro": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "A bluff tries to make better hands fold.",
      "existing_map_pointer": "/worlds/3/lessons/2/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "State that a bluff tries to win through better hands folding and needs fold chance.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_intro",
        "field": "question",
        "owner": "_world4BluffIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16050, 16065],
          "sha256":
              "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
        },
        "declaration": "  question: 'What does a bluff need?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_intro",
        "field": "teachingSteps",
        "owner": "_world4BluffIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16050, 16065],
          "sha256":
              "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
      },
      {
        "quote": "A bluff tries to win when better hands fold.",
        "owner": "_world4BluffIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16054, 16054],
          "sha256":
              "0822eb419dbedf9447a427853ae53d13e87b6b4c94eeaf018d76e4e12c728313",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16054",
        },
      },
    ],
    "instructional_role": "EXPLICIT_DEFINITION_REINFORCEMENT",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bluff_better_folds",
        "role": "EXPLICIT_SOURCE_DEFINITION",
        "earlier_source_supported_introduction_task_ids": [],
        "introduction_evidence": [],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_intro",
          "field": "teachingSteps",
          "owner": "_world4BluffIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16050, 16065],
            "sha256":
                "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_purpose_intro",
        "concept_id": "bet_purpose",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Name the intended job of a bet before choosing its size.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_intro",
          "field": "question",
          "owner": "_world4BluffIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16050, 16065],
            "sha256":
                "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
          },
          "declaration": "  question: 'What does a bluff need?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_intro",
          "field": "caption",
          "owner": "_world4BluffIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16050, 16065],
            "sha256":
                "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
          },
          "declaration":
              "  caption: 'A bluff tries to win when better hands fold.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [],
        "prior_lesson_ids_in_world": ["why_bets_happen", "value_bets"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_bluff_pressure": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "A bluff tries to make better hands fold.",
      "existing_map_pointer": "/worlds/3/lessons/2/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Relate the given missed-hand/fold-chance premise to the source-authored pressure bet; do not validate profitability.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_pressure",
        "field": "question",
        "owner": "_world4BluffPressureRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16067, 16100],
          "sha256":
              "66b16998d5082efe28237fdaa83901e7b9cbecca7bdc1b4f6d312d1b3ab86d9c",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16067",
        },
        "declaration": "  question: 'What action matches the bluff purpose?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_pressure",
        "field": "teachingSteps",
        "owner": "_world4BluffPurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15887, 15930],
          "sha256":
              "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
      },
      {
        "quote": "A one-third bet creates fold pressure at a controlled price.",
        "owner": "_world4BluffPressureRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16083, 16083],
          "sha256":
              "91eecefcff73a145163f2afd8ee4dfce03a90a1ba62f2a50ab4a7686f97a2a50",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16083",
        },
      },
    ],
    "instructional_role": "APPLICATION",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bluff_better_folds",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": ["w4_bluff_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_bluff_intro",
            "field": "teachingSteps",
            "owner": "_world4BluffIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [16050, 16065],
              "sha256":
                  "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_pressure",
          "field": "teachingSteps",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_bluff_intro",
        "concept_id": "bluff_better_folds",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize bluffing as trying to make better hands fold.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_intro",
          "field": "teachingSteps",
          "owner": "_world4BluffIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16050, 16065],
            "sha256":
                "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_pressure",
          "field": "question",
          "owner": "_world4BluffPressureRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16067, 16100],
            "sha256":
                "66b16998d5082efe28237fdaa83901e7b9cbecca7bdc1b4f6d312d1b3ab86d9c",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16067",
          },
          "declaration":
              "  question: 'What action matches the bluff purpose?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_pressure",
          "field": "caption",
          "owner": "_world4BluffPressureRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16067, 16100],
            "sha256":
                "66b16998d5082efe28237fdaa83901e7b9cbecca7bdc1b4f6d312d1b3ab86d9c",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16067",
          },
          "declaration":
              "  caption: 'Hero missed, but BB checked and can fold.',",
        },
      },
      {
        "knowledge":
            "Interpreting the named one-third/half/pot-size and whether that action/size is strategically justified.",
        "status": "UNKNOWN_OR_OUT_OF_SCOPE",
        "reason":
            "Size/action labels occur in source options; this four-concept package does not prove prior arithmetic instruction or optimality. A label/focus label is not a full introduction.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_pressure",
          "field": "options",
          "owner": "_world4BluffPressureRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16067, 16100],
            "sha256":
                "66b16998d5082efe28237fdaa83901e7b9cbecca7bdc1b4f6d312d1b3ab86d9c",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16067",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'bet_small',\n      label: 'Bet one-third',\n      amountLabel: '2 BB',\n      isCorrect: true,\n      preferredLabel: 'Bet one-third',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Clean execution.',\n      feedbackReason:\n          'A one-third bet creates fold pressure at a controlled price.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'check',\n      label: 'Check',\n      isCorrect: false,\n      preferredLabel: 'Bet one-third',\n      betterAnswerLabel: 'Bet one-third',\n      quality: Act0FeedbackQualityV1.suboptimal,\n      feedbackTitle: 'Legal, but betting is sharper.',\n      feedbackReason:\n          'Checking is legal and not a disaster, but a small bet creates fold pressure at low cost.',\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_bluff_intro"],
        "prior_lesson_ids_in_world": ["why_bets_happen", "value_bets"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_bad_bluff": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "A bluff tries to make better hands fold.",
      "existing_map_pointer": "/worlds/3/lessons/2/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Use the stated low-fold-pressure premise to explain avoiding a forced bluff in this authored example.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bad_bluff",
        "field": "question",
        "owner": "_world4BadBluffRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16102, 16134],
          "sha256":
              "55a3c96b61717a7d1f3cc181228afb7a8be83ba127f330e7bb5d0d92845c86e8",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16102",
        },
        "declaration": "  question: 'What is the safer beginner action?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bad_bluff",
        "field": "teachingSteps",
        "owner": "_world4BluffPurposeRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [15887, 15930],
          "sha256":
              "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
      },
      {
        "quote": "When fold pressure is low, checking avoids a forced bluff.",
        "owner": "_world4BadBluffRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16116, 16116],
          "sha256":
              "b2da3607111b0c5244c9dfe9c666ad6f7bb0d5c515db1e5617d17f2619d2e761",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16116",
        },
      },
    ],
    "instructional_role": "APPLICATION_NEGATIVE_CASE",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bluff_better_folds",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": ["w4_bluff_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_bluff_intro",
            "field": "teachingSteps",
            "owner": "_world4BluffIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [16050, 16065],
              "sha256":
                  "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bad_bluff",
          "field": "teachingSteps",
          "owner": "_world4BluffPurposeRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15887, 15930],
            "sha256":
                "053e2abc51a8b63912abac80e5951e14d884fecb1204d579962e982cef662fd9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15887",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff wants folds.',\n      body: 'When hero has no pair, the bet works only if folds happen.',\n      focusLabels: <String>['Missed', 'Fold pressure'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_bluff_intro",
        "concept_id": "bluff_better_folds",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize bluffing as trying to make better hands fold.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_intro",
          "field": "teachingSteps",
          "owner": "_world4BluffIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16050, 16065],
            "sha256":
                "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bad_bluff",
          "field": "question",
          "owner": "_world4BadBluffRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16102, 16134],
            "sha256":
                "55a3c96b61717a7d1f3cc181228afb7a8be83ba127f330e7bb5d0d92845c86e8",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16102",
          },
          "declaration": "  question: 'What is the safer beginner action?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bad_bluff",
          "field": "caption",
          "owner": "_world4BadBluffRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16102, 16134],
            "sha256":
                "55a3c96b61717a7d1f3cc181228afb7a8be83ba127f330e7bb5d0d92845c86e8",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16102",
          },
          "declaration":
              "  caption: 'Villain called big already. Fold pressure is low.',",
        },
      },
      {
        "knowledge":
            "Interpreting the named one-third/half/pot-size and whether that action/size is strategically justified.",
        "status": "UNKNOWN_OR_OUT_OF_SCOPE",
        "reason":
            "Size/action labels occur in source options; this four-concept package does not prove prior arithmetic instruction or optimality. A label/focus label is not a full introduction.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bad_bluff",
          "field": "options",
          "owner": "_world4BadBluffRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16102, 16134],
            "sha256":
                "55a3c96b61717a7d1f3cc181228afb7a8be83ba127f330e7bb5d0d92845c86e8",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16102",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'check',\n      label: 'Check',\n      isCorrect: true,\n      preferredLabel: 'Check',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Check is the cleaner line.',\n      feedbackReason:\n          'When fold pressure is low, checking avoids a forced bluff.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'pot_bet',\n      label: 'Bet pot-size',\n      amountLabel: '6 BB',\n      isCorrect: false,\n      preferredLabel: 'Check',\n      betterAnswerLabel: 'Check',\n      quality: Act0FeedbackQualityV1.wrong,\n      feedbackTitle: 'Almost got it.',\n      feedbackReason:\n          'A pot-size bluff is too ambitious when fold pressure is unclear.',\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_bluff_intro", "w4_bluff_pressure"],
        "prior_lesson_ids_in_world": ["why_bets_happen", "value_bets"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_bluff_recap": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "A bluff tries to make better hands fold.",
      "existing_map_pointer": "/worlds/3/lessons/2/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Restate that bluffing aims at better folds and a missed hand need not always bet.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_recap",
        "field": "question",
        "owner": "_world4BluffRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16136, 16152],
          "sha256":
              "1c2e2130b28f47a41fdd1124f4b0cda82d9f15c7baeebfbc147345ec14a01a31",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16136",
        },
        "declaration": "  question: 'What does a bluff try to create?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_bluff_recap",
        "field": "teachingSteps",
        "owner": "_world4BluffRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16136, 16152],
          "sha256":
              "1c2e2130b28f47a41fdd1124f4b0cda82d9f15c7baeebfbc147345ec14a01a31",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16136",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff checklist.',\n      body: 'Ask whether better hands can fold before betting a miss.',\n      focusLabels: <String>['Better folds', 'Controlled risk'],\n    ),\n  ],",
      },
      {
        "quote":
            "Bluffing is pressure with a purpose: make better hands fold without risking chips blindly.",
        "owner": "_world4BluffRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16144, 16144],
          "sha256":
              "880a5b40cdafb7eb7e069b30af1cfb5e7ce2abb52a17abcef30675e7b3e87c05",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16144",
        },
      },
    ],
    "instructional_role": "RECAP_WITHOUT_INDEPENDENT_OPTION_CHECK",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "bluff_better_folds",
        "role": "RECAP",
        "earlier_source_supported_introduction_task_ids": ["w4_bluff_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_bluff_intro",
            "field": "teachingSteps",
            "owner": "_world4BluffIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [16050, 16065],
              "sha256":
                  "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_recap",
          "field": "teachingSteps",
          "owner": "_world4BluffRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16136, 16152],
            "sha256":
                "1c2e2130b28f47a41fdd1124f4b0cda82d9f15c7baeebfbc147345ec14a01a31",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16136",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Bluff checklist.',\n      body: 'Ask whether better hands can fold before betting a miss.',\n      focusLabels: <String>['Better folds', 'Controlled risk'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_bluff_intro",
        "concept_id": "bluff_better_folds",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize bluffing as trying to make better hands fold.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_intro",
          "field": "teachingSteps",
          "owner": "_world4BluffIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16050, 16065],
            "sha256":
                "125067e33c7e5844a7e8570dc7f797dbf9f80cfc0a0fd2453d2e42998c362724",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16050",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Fold pressure.',\n      body: 'A bluff is a story backed by chips, not random betting.',\n      focusLabels: <String>['Better folds', 'Pressure'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_recap",
          "field": "question",
          "owner": "_world4BluffRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16136, 16152],
            "sha256":
                "1c2e2130b28f47a41fdd1124f4b0cda82d9f15c7baeebfbc147345ec14a01a31",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16136",
          },
          "declaration": "  question: 'What does a bluff try to create?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_bluff_recap",
          "field": "caption",
          "owner": "_world4BluffRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16136, 16152],
            "sha256":
                "1c2e2130b28f47a41fdd1124f4b0cda82d9f15c7baeebfbc147345ec14a01a31",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16136",
          },
          "declaration":
              "  caption: 'Lesson learned: bluff only when folds can happen.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [
          "w4_bluff_intro",
          "w4_bluff_pressure",
          "w4_bad_bluff",
        ],
        "prior_lesson_ids_in_world": ["why_bets_happen", "value_bets"],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_protection_intro": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet so the next card is not free.",
      "existing_map_pointer": "/worlds/3/lessons/3/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Explain that protection denies a free next card by making continuation cost chips.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_intro",
        "field": "question",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16154, 16178],
          "sha256":
              "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
        },
        "declaration": "  question: 'What does protection deny?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_intro",
        "field": "teachingSteps",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16154, 16178],
          "sha256":
              "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
      },
      {
        "quote": "Protection makes the next card cost something.",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16174, 16174],
          "sha256":
              "33a65cc5ceaa13b4759a14c0ebf9c902407f60a684d233ca612b781be276de16",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16174",
        },
      },
      {
        "quote": "Deny free cards.",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16173, 16173],
          "sha256":
              "a8f020a733cb55f55ab817a9eb8a9d9a638fd0f6eafed823132fffb8302c06ea",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16173",
        },
      },
      {
        "quote": "This is value-adjacent, but the key word is deny.",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16159, 16159],
          "sha256":
              "30efe9b02a3287bbc9c84b709e0541c4aae78c0b11eea010105b69b222791aa6",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16159",
        },
      },
    ],
    "instructional_role": "EXPLICIT_DEFINITION_REINFORCEMENT",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "protection_denies_free_cards",
        "role": "EXPLICIT_SOURCE_DEFINITION",
        "earlier_source_supported_introduction_task_ids": ["w4_purpose_intro"],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_purpose_intro",
            "field": "teachingSteps",
            "owner": "_world4PurposeIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [15812, 15838],
              "sha256":
                  "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_intro",
          "field": "teachingSteps",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_purpose_intro",
        "concept_id": "bet_purpose",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Name the intended job of a bet before choosing its size.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_purpose_intro",
          "field": "teachingSteps",
          "owner": "_world4PurposeIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [15812, 15838],
            "sha256":
                "abc0d3843081e33388504c0161eeafcadb8a3323531f26ad3b444306926eb163",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L15812",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Purpose first.',\n      body:\n          'Name the bet purpose first. Value gets calls, bluff gets folds, protection makes the next card cost money.',\n      focusLabels: <String>['Value', 'Bluff', 'Protection'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_intro",
          "field": "question",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration": "  question: 'What does protection deny?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_intro",
          "field": "caption",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  caption: 'Protection bets make the next card cost something.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [],
        "prior_lesson_ids_in_world": [
          "why_bets_happen",
          "value_bets",
          "bluff_pressure",
        ],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_protection_bet": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet so the next card is not free.",
      "existing_map_pointer": "/worlds/3/lessons/3/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Relate the protection bet to charging for the next card rather than allowing a free continuation.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_bet",
        "field": "question",
        "owner": "_world4ProtectionBetRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16180, 16215],
          "sha256":
              "1565dd50bca1f7de6aced40aa82044614c8d34e563204b2822131f1512284dd3",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16180",
        },
        "declaration": "  question: 'What action fits protection?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_bet",
        "field": "teachingSteps",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16154, 16178],
          "sha256":
              "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
      },
      {
        "quote": "The bet makes the next card cost something.",
        "owner": "_world4ProtectionBetRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16195, 16195],
          "sha256":
              "cd3b0067bb7b8a83fde2b4ff6dda107cf2b3077b59cdcef987d699e43c933731",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16195",
        },
      },
      {
        "quote": "Checking lets villain see the next card for free.",
        "owner": "_world4ProtectionBetRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16205, 16205],
          "sha256":
              "172ef8e9d674ca056040417e2e4967e1512707b9f7060192348a5f90252e8876",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16205",
        },
      },
      {
        "quote": "Betting protects value by denying that free card.",
        "owner": "_world4ProtectionBetRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16184, 16184],
          "sha256":
              "0806c52f3ce226129c6de89a456ff399fd7f9ed488b068784d0b5bdf0bb04803",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16184",
        },
      },
    ],
    "instructional_role": "APPLICATION",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "protection_denies_free_cards",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": [
          "w4_protection_intro",
        ],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_protection_intro",
            "field": "teachingSteps",
            "owner": "_world4ProtectionIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [16154, 16178],
              "sha256":
                  "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_bet",
          "field": "teachingSteps",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_protection_intro",
        "concept_id": "protection_denies_free_cards",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize protection/denial as making continuation to the next card cost chips.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_intro",
          "field": "teachingSteps",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_bet",
          "field": "question",
          "owner": "_world4ProtectionBetRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16180, 16215],
            "sha256":
                "1565dd50bca1f7de6aced40aa82044614c8d34e563204b2822131f1512284dd3",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16180",
          },
          "declaration": "  question: 'What action fits protection?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_bet",
          "field": "caption",
          "owner": "_world4ProtectionBetRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16180, 16215],
            "sha256":
                "1565dd50bca1f7de6aced40aa82044614c8d34e563204b2822131f1512284dd3",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16180",
          },
          "declaration":
              "  caption: 'Hero has top pair. Checking gives villain a free next card.',",
        },
      },
      {
        "knowledge":
            "Interpreting the named one-third/half/pot-size and whether that action/size is strategically justified.",
        "status": "UNKNOWN_OR_OUT_OF_SCOPE",
        "reason":
            "Size/action labels occur in source options; this four-concept package does not prove prior arithmetic instruction or optimality. A label/focus label is not a full introduction.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_bet",
          "field": "options",
          "owner": "_world4ProtectionBetRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16180, 16215],
            "sha256":
                "1565dd50bca1f7de6aced40aa82044614c8d34e563204b2822131f1512284dd3",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16180",
          },
          "declaration":
              "  options: const <Act0RunnerOptionV1>[\n    Act0RunnerOptionV1(\n      id: 'bet_half',\n      label: 'Bet half-pot',\n      amountLabel: '3 BB',\n      isCorrect: true,\n      preferredLabel: 'Bet half-pot',\n      quality: Act0FeedbackQualityV1.correct,\n      feedbackTitle: 'Sharp read.',\n      feedbackReason: 'The bet makes the next card cost something.',\n    ),\n    Act0RunnerOptionV1(\n      id: 'check',\n      label: 'Check',\n      isCorrect: false,\n      preferredLabel: 'Bet half-pot',\n      betterAnswerLabel: 'Bet half-pot',\n      quality: Act0FeedbackQualityV1.wrong,\n      feedbackTitle: 'Very close.',\n      feedbackReason: 'Checking lets villain see the next card for free.',\n    ),\n  ],",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": ["w4_protection_intro"],
        "prior_lesson_ids_in_world": [
          "why_bets_happen",
          "value_bets",
          "bluff_pressure",
        ],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_protection_check": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet so the next card is not free.",
      "existing_map_pointer": "/worlds/3/lessons/3/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Identify a free next card as the consequence described after Hero checks behind.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_check",
        "field": "question",
        "owner": "_world4ProtectionCheckRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16217, 16247],
          "sha256":
              "db5554e37e62914241034db569ef146e66d793250c17039d4f20bd0fa023a4b5",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16217",
        },
        "declaration": "  question: 'What did checking allow?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_check",
        "field": "teachingSteps",
        "owner": "_world4ProtectionIntroRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16154, 16178],
          "sha256":
              "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
      },
      {
        "quote": "Checking allowed villain to continue without paying.",
        "owner": "_world4ProtectionCheckRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16230, 16230],
          "sha256":
              "cfe4e2f785a8a8d96597e421f0cd8e46ba2f24cadc89d6142e1a7f57489e6857",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16230",
        },
      },
      {
        "quote": "Checking allowed villain to continue without paying.",
        "owner": "_world4ProtectionCheckRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16230, 16230],
          "sha256":
              "cfe4e2f785a8a8d96597e421f0cd8e46ba2f24cadc89d6142e1a7f57489e6857",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16230",
        },
      },
    ],
    "instructional_role":
        "APPLICATION_OF_CHECK_CONSEQUENCE_NOT_INDEPENDENT_PROOF",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "protection_denies_free_cards",
        "role": "APPLICATION",
        "earlier_source_supported_introduction_task_ids": [
          "w4_protection_intro",
        ],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_protection_intro",
            "field": "teachingSteps",
            "owner": "_world4ProtectionIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [16154, 16178],
              "sha256":
                  "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_check",
          "field": "teachingSteps",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_protection_intro",
        "concept_id": "protection_denies_free_cards",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize protection/denial as making continuation to the next card cost chips.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_intro",
          "field": "teachingSteps",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_check",
          "field": "question",
          "owner": "_world4ProtectionCheckRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16217, 16247],
            "sha256":
                "db5554e37e62914241034db569ef146e66d793250c17039d4f20bd0fa023a4b5",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16217",
          },
          "declaration": "  question: 'What did checking allow?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_check",
          "field": "caption",
          "owner": "_world4ProtectionCheckRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16217, 16247],
            "sha256":
                "db5554e37e62914241034db569ef146e66d793250c17039d4f20bd0fa023a4b5",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16217",
          },
          "declaration":
              "  caption: 'Hero checks behind on a draw-heavy board.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [
          "w4_protection_intro",
          "w4_protection_bet",
        ],
        "prior_lesson_ids_in_world": [
          "why_bets_happen",
          "value_bets",
          "bluff_pressure",
        ],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
  "w4_protection_recap": {
    "status": "PREPARED_FOR_INDEPENDENT_REVIEW",
    "curator_role": "content-purpose-01",
    "decision_kind": "NEW_CURRENT_CURATION_NOT_RECOVERED_HISTORIC_INTENT",
    "package": "WP03-SKILL-LINKS-W4-PURPOSE-01",
    "result_revision": "AUTHOR/v1",
    "source_commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
    "authored_lesson_goal_reused": {
      "text": "Bet so the next card is not free.",
      "existing_map_pointer": "/worlds/3/lessons/3/authored_goal",
      "map_preimage_sha256":
          "482719d3fc5042c0e16b72071f30d7bc625bb72e9863b862465918d2b166df94",
      "meaning":
          "Existing historical map goal retained; not rebound to new historical source lines.",
    },
    "learning_goal":
        "Restate that protection prevents continuation to the next card from being free.",
    "goal_evidence": [
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_recap",
        "field": "question",
        "owner": "_world4ProtectionRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16249, 16265],
          "sha256":
              "2a2076485527705e86ef5e5fa419e049e523abb63fde64867fa111fb90ca50f9",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16249",
        },
        "declaration": "  question: 'What does a protection bet deny?',",
      },
      {
        "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
        "task_id": "w4_protection_recap",
        "field": "teachingSteps",
        "owner": "_world4ProtectionRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16249, 16265],
          "sha256":
              "2a2076485527705e86ef5e5fa419e049e523abb63fde64867fa111fb90ca50f9",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16249",
        },
        "declaration":
            "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Protection checklist.',\n      body: 'Ask if checking gives away the next card too cheaply.',\n      focusLabels: <String>['Next card', 'Free card', 'Bet'],\n    ),\n  ],",
      },
      {
        "quote":
            "Protection means the next card is not free for the player trying to continue.",
        "owner": "_world4ProtectionRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16257, 16257],
          "sha256":
              "7c15aff37b9c4bc0ac1b3e8493c40fba51fedfa4e3180b9882b3f654023f5e26",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16257",
        },
      },
      {
        "quote": "Denying a free card is a real purpose.",
        "owner": "_world4ProtectionRecapRunner",
        "source": {
          "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
          "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
          "lines": [16253, 16253],
          "sha256":
              "5ef68e10f4acc1c73e2a816c2fad88dd73a2917c90cf985c8975f70c18117063",
          "link":
              "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16253",
        },
      },
    ],
    "instructional_role": "RECAP_WITHOUT_INDEPENDENT_OPTION_CHECK",
    "role_basis":
        "Actual teaching/options/feedback content; intro/recap labels alone are not evidence. Empty-option recaps are not independent checks.",
    "concept_links": [
      {
        "concept_id": "protection_denies_free_cards",
        "role": "RECAP",
        "earlier_source_supported_introduction_task_ids": [
          "w4_protection_intro",
        ],
        "introduction_evidence": [
          {
            "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
            "task_id": "w4_protection_intro",
            "field": "teachingSteps",
            "owner": "_world4ProtectionIntroRunner",
            "source": {
              "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
              "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
              "lines": [16154, 16178],
              "sha256":
                  "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
              "link":
                  "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
            },
            "declaration":
                "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
          },
        ],
        "target_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_recap",
          "field": "teachingSteps",
          "owner": "_world4ProtectionRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16249, 16265],
            "sha256":
                "2a2076485527705e86ef5e5fa419e049e523abb63fde64867fa111fb90ca50f9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16249",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Protection checklist.',\n      body: 'Ask if checking gives away the next card too cheaply.',\n      focusLabels: <String>['Next card', 'Free card', 'Bet'],\n    ),\n  ],",
        },
        "actual_exposure_before_choice":
            "UNKNOWN; route may close through Placement skip and final Help visibility is unproved.",
      },
    ],
    "pedagogical_prerequisites": [
      {
        "task_id": "w4_protection_intro",
        "concept_id": "protection_denies_free_cards",
        "kind": "PROPOSED_SEMANTIC_DEPENDENCY_SOURCE_SUPPORTED",
        "knowledge_needed":
            "Recognize protection/denial as making continuation to the next card cost chips.",
        "prior_teaching_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_intro",
          "field": "teachingSteps",
          "owner": "_world4ProtectionIntroRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16154, 16178],
            "sha256":
                "b2d03a59e8994c7f81967f14088565eaf7982345b9e1108305b8760fb15fbaf0",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16154",
          },
          "declaration":
              "  teachingSteps: const <Act0TeachingStepV1>[\n    Act0TeachingStepV1(\n      title: 'Deny free cards.',\n      body: 'Protection makes the next card cost something.',\n      focusLabels: <String>['Next card', 'Cost', 'Deny'],\n    ),\n  ],",
        },
        "target_use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_recap",
          "field": "question",
          "owner": "_world4ProtectionRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16249, 16265],
            "sha256":
                "2a2076485527705e86ef5e5fa419e049e523abb63fde64867fa111fb90ca50f9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16249",
          },
          "declaration": "  question: 'What does a protection bet deny?',",
        },
        "limit":
            "A knowledge requirement proposal, not an added runtime gate, completion requirement or learner competence claim.",
      },
    ],
    "unknown_inputs_and_gaps": [
      {
        "knowledge":
            "Bet/call/check/fold vocabulary, card/hand comparison and BB/pot notation as required by this task.",
        "status": "UNKNOWN_CROSS_SCOPE",
        "reason":
            "These source words and premises are used here, but their earlier instruction was not established in the admitted sixteen-ID packet; no W01/W3 or excluded lesson audit is performed.",
        "use_evidence": {
          "evidence_kind": "REUSED_QA_VERIFIED_FIELD",
          "task_id": "w4_protection_recap",
          "field": "caption",
          "owner": "_world4ProtectionRecapRunner",
          "source": {
            "commit": "1bddf5ea55faba2bfc9cb9831284b2039f7af631",
            "path": "lib/ui_v2/act0_shell/act0_shell_state_v1.dart",
            "lines": [16249, 16265],
            "sha256":
                "2a2076485527705e86ef5e5fa419e049e523abb63fde64867fa111fb90ca50f9",
            "link":
                "https://github.com/ClubBoss/sharky-standalone-direction/blob/1bddf5ea55faba2bfc9cb9831284b2039f7af631/lib/ui_v2/act0_shell/act0_shell_state_v1.dart#L16249",
          },
          "declaration":
              "  caption: 'Lesson learned: protection denies a free next card.',",
        },
      },
    ],
    "navigation_distinction": {
      "existing_source_order_fields_preserved": [
        "earlier_task_ids_in_lesson",
        "prior_lesson_ids_in_world",
      ],
      "navigation_fact": {
        "earlier_task_ids_in_lesson": [
          "w4_protection_intro",
          "w4_protection_bet",
          "w4_protection_check",
        ],
        "prior_lesson_ids_in_world": [
          "why_bets_happen",
          "value_bets",
          "bluff_pressure",
        ],
        "prerequisite_kind":
            "source-order path closure, not demonstrated mastery",
      },
      "actual_profile_runtime_availability": "NOT_VERIFIED_BY_SOURCE_MAP",
      "source_map_route_rule_reused":
          "completed or skipped replay, otherwise first path-incomplete task",
      "route_rule_limit":
          "Historical source-map description only; actual learner/profile prerequisite traversal is UNKNOWN. Source order is not the proposed semantic dependency. Placement skip is not mastery.",
      "runtime_gate_changes": false,
    },
    "evidence_limit":
        "Static semantic annotation only. No full important-Foundation skill list, independent/unseen strategy/grade/mastery, final Help/native/comprehension proof or CUR-01.a/CUR-02.a acceptance.",
  },
};

const _purposeSummary = r'''
## Qualified documentary skill links: W4 purpose/value/bluff/protection

Sixteen existing IDs receive new documentary learning-goal/prerequisite/concept annotations from the independently reviewed WP03-SKILL-LINKS-W4-PURPOSE-01 proposal, authored at immutable1bddf5ea. This is a finite source-qualified subset, not a complete important-Foundation skill inventory or a runtime gate. Original source-map records, earlier accepted Call-price annotations and all historical pins remain unchanged.

Later source qualification for w4_purpose_intro, w4_value_purpose and w4_bluff_purpose: source19b1f231 adds the exact worse-call/better-fold definitions only to the earlier task-local teaching body. The original annotations' PARTIAL_SHORTHAND and omission evidence is explicitly the dated1bdd snapshot. A direct EN14Pro widget shows the full longer text through existing scroll. Ordinary-route exposure before BOTH first applications remains UNKNOWN/open; source order, a synthetic current-study classification or a distinct ID is not learner comprehension or independent proof. No route, grade, XP or criterion is changed by this document.

| Existing task ID | Documentary goal |
| --- | --- |
| `w4_purpose_intro` | Name value, bluff and protection as purposes before asking for a bet size. |
| `w4_value_purpose` | Identify the authored value purpose from the stated stronger-hand/weaker-caller premise; distinguish it from bluff. |
| `w4_bluff_purpose` | Identify the authored bluff purpose as trying to make better hands fold; distinguish it from value. |
| `w4_purpose_recap` | Restate that purpose comes before size and recall the three named purposes. |
| `w4_value_intro` | State that a value bet needs worse hands that can call, rather than just a strong hand. |
| `w4_value_bet` | Relate the stated worse-caller premise to the source-authored value-bet choice; do not infer optimal sizing. |
| `w4_value_missed` | Explain why checking can miss value under the stated premise that worse hands can call. |
| `w4_value_recap` | Restate the worse-calls criterion for value before choosing size. |
| `w4_bluff_intro` | State that a bluff tries to win through better hands folding and needs fold chance. |
| `w4_bluff_pressure` | Relate the given missed-hand/fold-chance premise to the source-authored pressure bet; do not validate profitability. |
| `w4_bad_bluff` | Use the stated low-fold-pressure premise to explain avoiding a forced bluff in this authored example. |
| `w4_bluff_recap` | Restate that bluffing aims at better folds and a missed hand need not always bet. |
| `w4_protection_intro` | Explain that protection denies a free next card by making continuation cost chips. |
| `w4_protection_bet` | Relate the protection bet to charging for the next card rather than allowing a free continuation. |
| `w4_protection_check` | Identify a free next card as the consequence described after Hero checks behind. |
| `w4_protection_recap` | Restate that protection prevents continuation to the next card from being free. |

Final Help visibility, cross-scope prerequisite coverage, important-Foundation completeness, strategic grade validity and learner exposure remain separately unverified. The already-qualified same-case protection practice pair is NOT independent/unseen proof. Full CUR-01.a/CUR-02.a, PKR, native/Human/release and roadmap points remain unaccepted.
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
          if (_purposeTaskCuration.containsKey(task.taskId))
            'current_curation': _purposeTaskCuration[task.taskId]!,
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
  out.write(_purposeSummary);
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

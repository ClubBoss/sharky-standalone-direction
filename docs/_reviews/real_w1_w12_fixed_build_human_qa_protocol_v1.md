---
status: "undeclared"
status_source: "absent"
doc_date: "2026-07-09"
baseline: "ef84482b6434"
generated_by: "docs_frontmatter_v1"
---

# Real W1-W12 Fixed-Build Human QA Protocol v1

Date: 2026-07-09

Terminal verdict: `human_qa_protocol_ready_for_real_execution`

## 1. Executive verdict

This artifact prepares the first real Human QA execution protocol for the W1-W12 fixed-build baseline on `main`.

Allowed claim after this artifact only: Human QA protocol is ready for execution from fixed-build `main`.

Human QA has not been run. This artifact does not create participants, simulate users, synthesize evidence, claim Human QA approval, claim public readiness, claim launch readiness, claim 9.0 readiness, claim 10/10 quality, claim durable learning effect, claim beginner mastery, claim premium commercial readiness, or open W13+.

## 2. Fixed-build baseline

Required fixed-build baseline:

- Branch: `main`
- Expected `main` / `origin/main`: `ef84482b6434eb91aadbb093a50a9521726bca3d`
- Baseline artifact: `docs/_reviews/fixed_build_human_qa_baseline_packet_v1.md`
- Baseline verdict: `fixed_build_human_qa_baseline_ready`

Baseline facts carried into this protocol:

- W1-W12 are the current Human QA candidate scope.
- W1-W12 have technical source, fixture, route, screenshot, and guard support.
- Human QA remains the external learner-outcome evidence gate.
- Screenshot outputs are local proof artifacts only and are not participant evidence by themselves.
- W12 terminal/no-W13 remains part of the tested boundary.

## 3. Claim-safety boundaries

This protocol preserves these boundaries:

- Human QA has not yet been run.
- This artifact prepares execution only.
- No fake participants.
- No synthetic participant evidence.
- No internal developer click-through counted as Human QA.
- No agent or AI simulation counted as Human QA.
- No public readiness claim.
- No launch readiness claim.
- No 9.0 or 10/10 claim.
- No durable learning-effect claim.
- No beginner mastery claim.
- No W13+ opening.
- No monetization, release, App Store, or premium commercial readiness claim.

After a future real session, evidence may support only the bounded Human QA verdict rules in section 13.

## 4. Human QA objective

The objective is to test whether real novice or near-novice users can move through the W1-W12 fixed-build learner chain and understand:

- what the screen asks;
- what table signal matters;
- why their choice was right or wrong;
- what the repair asks them to notice;
- whether they can apply the repair on recheck;
- whether summary, Review, and Profile give a clear next step;
- whether the W12 terminal feels like honest Volume I review and closure, not mastery or W13 opening.

This protocol does not test:

- public launch readiness;
- monetization;
- store assets;
- W13+;
- Modern Table redesign;
- long-term retention;
- durable learning;
- premium commercial readiness.

## 5. Participant plan

Minimum first pass:

- Use 1 real novice or near-novice participant.
- Goal: find obvious comprehension blockers.
- Do not treat this as broad success proof.

Preferred first batch:

- Use 3 real participants.
- Participant 1: complete novice.
- Participant 2: casual poker-aware beginner.
- Participant 3: stronger beginner or low-intermediate.
- Goal: compare confusion clusters across familiarity levels.

Exclusions:

- Do not use the project owner as a participant.
- Do not use someone coached during the session as clean evidence.
- Do not use an AI, agent, synthetic persona, or scripted simulation as Human QA.
- Do not count internal developer click-through as Human QA.
- Do not collect sensitive personal data.

Participant labeling:

- Use pseudonyms such as `P01_novice`, `P02_poker_aware_beginner`, or `P03_low_intermediate`.
- Store only the minimum profile needed to interpret evidence.

## 6. Device/environment plan

Minimum device plan:

- Include at least one phone-class device.
- Record device class and OS.
- Record whether the run is on simulator, emulator, or physical hardware.

Optional device plan:

- Add one tablet session if feasible because tablet density was a prior concern.
- If tablet is not tested in the first pass, record `tablet_not_tested_first_pass`.

Environment fields to capture:

- tested commit hash;
- app build source;
- device class;
- OS/device notes;
- language;
- session location type, such as remote, in-person, or screen-share;
- evidence capture method, such as note-only, screenshot, or screen recording.

## 7. Session script

### 7.1 Pre-session setup

Before the participant starts, record:

- session id;
- participant pseudonym;
- participant type;
- tested commit hash;
- device class;
- OS/device notes;
- date and time;
- operator name or initials;
- prior poker familiarity;
- language;
- whether the participant has seen Sharky before;
- evidence capture permission status.

### 7.2 Warm intro

Say:

> This is a test of the app, not a test of you. Please use it naturally. If something is confusing, that is useful evidence. I will mostly stay quiet so we can see what the app explains by itself.

Also say:

> If you are comfortable, think aloud as you go. I will not teach poker outside the app during the first attempt.

Do not say:

- which answer is correct;
- which table signal to look for;
- that a screen is supposed to be easy;
- that the app is finished, ready, launch-ready, 9.0, 10/10, or proven to teach beginners.

### 7.3 Core W1-W12 journey

Run the minimum critical path first:

1. Placement or first-use entry.
2. Welcome.
3. Home / Learn entry.
4. Lesson detail.
5. First decision.
6. One correct feedback surface if naturally reached.
7. One wrong feedback surface.
8. Repair focus.
9. Targeted recheck.
10. Session summary.
11. Review/Profile return.
12. Selected W7-W12 active-route surfaces.
13. W11 transfer moment.
14. W12 payoff / mindset bridge.
15. W12 terminal/no-W13 boundary.

Do not force exhaustive completion of every W1-W12 task in the first protocol. Use the extended path only if the participant is comfortable and not fatigued.

### 7.4 Stopping rules

Stop the session if:

- participant asks to stop;
- participant shows fatigue that invalidates observations;
- a P0 or P1 blocker prevents continuation;
- device or build failure invalidates the route;
- the participant needs repeated coaching to proceed.

If stopped, classify the session outcome under section 13 instead of filling gaps with assumptions.

### 7.5 Post-session questions

Ask:

- What did you think the app was teaching?
- Which screen confused you most?
- What table signal did you learn to notice?
- What did the repair screen ask you to do?
- What would you do next if you reopened the app tomorrow?
- Did the W12 ending feel like review/closure or like the app promised mastery?

### 7.6 Delayed recall option

Optional:

- Run a 10-20 minute delayed recall before the participant leaves.
- Run a next-day delayed recall if feasible.
- Ask one or two table-signal questions without coaching.
- Record whether the answer was recalled, guessed, or blocked.

## 8. Critical path task sample

Critical path sample:

| Sample | Required observation | Evidence goal |
| --- | --- | --- |
| W1 first decision / action read | Observe whether the participant understands the ask and selects an action. | Prompt clarity and first table-signal recognition. |
| Wrong outcome and repair | Ensure at least one wrong outcome is observed if it occurs naturally or through an admitted test route. | Whether feedback and repair explain the missed cue. |
| Targeted recheck | Observe whether the same signal is applied after repair. | Repair transfer within the session. |
| Session summary | Ask participant what the summary says to do next. | Next-step clarity. |
| Review/Profile return | Ask participant why they would return. | Whether repair/proof surfaces explain continuation. |

Critical path pass signal:

- participant can state the current ask;
- participant can name at least one table signal;
- participant can explain one repair in their own words;
- participant can attempt a recheck without operator coaching;
- participant understands W12 terminal as review/closure without W13 opening.

## 9. Extended task sample

Use this only if time and fatigue allow.

| Segment | Sample | Evidence goal |
| --- | --- | --- |
| Mid-chain W4-W6 | One concept involving table purpose, price, or range checkpoint if accessible in the fixed route. | Verify prerequisite terms are understood before later-world reasoning. |
| Late-chain W10 | One player-adjustment / target-logic item. | Check whether target logic is understood without solver claims. |
| Late-chain W11 | One real-play transfer item. | Check whether one trigger-action lever transfers to a game-like moment. |
| Late-chain W12 | One payoff, mindset, or terminal item. | Check whether Volume I closure is understood as review, not mastery. |
| Terminal boundary | Ask what is available after W12. | Verify later worlds are not perceived as open. |

Optional extended path should be stopped if the participant becomes fatigued, starts clicking without reading, or needs repeated explanation outside the app.

## 10. Evidence record schema

Each observation row must use this schema:

| Field | Required | Notes |
| --- | --- | --- |
| `session_id` | yes | No sensitive personal data. |
| `participant_id` | yes | Pseudonym only. |
| `participant_type` | yes | `novice`, `poker-aware beginner`, or `low-intermediate`. |
| `device_class` | yes | Phone, tablet, desktop simulator, or other. |
| `os_device_notes` | yes | OS, simulator/physical note, visible constraints. |
| `tested_commit_hash` | yes | Must match the build under test. |
| `date_time` | yes | Local timestamp is acceptable. |
| `route_surface` | yes | Example: Home, Learn, decision, repair, Review, Profile, W12 terminal. |
| `world_task_concept_family` | yes | Use the clearest available world/task/family label. |
| `prompt_shown` | yes | Short excerpt or paraphrase; do not store private data. |
| `user_choice` | yes | Exact choice or action taken. |
| `expected_answer` | yes | Expected answer/action when known. |
| `correct_incorrect` | yes | `correct`, `incorrect`, `not_applicable`, or `blocked`. |
| `error_type` | yes | Use section 11 taxonomy. |
| `time_to_decision_seconds` | yes | Estimate if exact timing is unavailable. |
| `hesitation_blocking_note` | yes | Note hesitation, stall, or route block. |
| `confusion_quote_or_paraphrase` | yes | Paraphrase when direct quote is not available. |
| `repair_shown_yes_no` | yes | Whether repair was shown. |
| `repair_understood_yes_no` | yes | Based on participant explanation or behavior. |
| `recheck_result` | yes | `passed`, `failed_same_reason`, `failed_new_reason`, `not_run`. |
| `post_session_recall_result` | optional | Use if delayed recall is performed. |
| `severity` | yes | Use section 12 taxonomy. |
| `operator_note` | yes | Keep factual, not interpretive. |
| `evidence_reference` | optional | Screenshot, video timestamp, or note id if available. |

Do not include participant names, contact information, health data, payment data, or unrelated personal history.

## 11. Error taxonomy

Use one primary error type per observation row:

- `unclear_prompt`
- `missed_table_signal`
- `misunderstood_action`
- `misunderstood_position`
- `misunderstood_price_or_pot`
- `misunderstood_board_texture`
- `confused_by_term`
- `chose_by_guessing`
- `clicked_without_reading`
- `feedback_not_understood`
- `repair_not_understood`
- `recheck_failed_same_reason`
- `fatigue_or_attention`
- `UI_navigation_confusion`
- `device_or_layout_issue`
- `language_or_copy_issue`
- `other`

If multiple errors appear, record the dominant root cause in `error_type` and add secondary causes in `operator_note`.

## 12. Severity taxonomy

- P0: cannot proceed / harmful or false teaching / route broken.
- P1: repeated blocker preventing learning on core path.
- P2: meaningful confusion requiring pre-release repair.
- P3: friction or wording issue; fix if bounded and high-EV.
- P4: preference / future improvement.

Severity must be assigned from observed behavior, not from operator preference.

## 13. Pass/fail decision rules

Use exactly one session or batch verdict.

### `human_qa_passes_for_next_gate`

Use only if:

- participant or participants complete the critical path;
- no P0 or P1 appears;
- no repeated same-root P2 appears;
- repair loop is understood at least once;
- W12/no-W13 boundary is understood;
- no claim-safety issue appears.

This verdict supports only movement to the next internal gate. It does not support public, launch, premium, durable-learning, beginner-mastery, 9.0, or 10/10 claims.

### `human_qa_requires_bounded_repair`

Use if:

- one or more concrete P2 or P3 issues are found;
- issues are local enough for a bounded repair;
- route correctness and claim-safety are not broken.

### `human_qa_blocks_until_repair`

Use if:

- any P0 or P1 appears;
- participants cannot understand the core route;
- repair loop fails repeatedly;
- W12 ending implies mastery or future unlock incorrectly;
- route, correctness, answer, or feedback mismatch appears.

### `human_qa_inconclusive_needs_more_participants`

Use if:

- evidence is too thin;
- participant is not representative;
- session is interrupted;
- device problem invalidates result;
- operator coaching makes the session unusable as clean evidence.

Claim rules:

- One participant is evidence, not broad market proof.
- Passing first Human QA only supports moving to the next internal gate.
- Do not claim public, launch, or premium readiness.
- Do not claim durable learning without delayed or longitudinal evidence.

## 14. Operator script

Before the session, say:

> This is a test of the app, not of you. Please use the app naturally. I may ask what you are thinking, but I will not explain the poker content before your first attempt.

What not to say:

- Do not tell the participant what signal to inspect.
- Do not say which answer is correct.
- Do not explain poker concepts before the app has a chance to teach them.
- Do not describe the app as finished, launch-ready, 9.0, 10/10, proven, or mastery-producing.

When to stay silent:

- during first reading of a screen;
- during first decision attempt;
- during repair reading;
- during recheck unless the participant is blocked by navigation rather than content.

When to help:

- if the participant cannot operate the device;
- if accessibility, language, or hardware prevents continuation;
- if the participant asks to stop;
- if a route is broken and no meaningful observation can continue.

How to record confusion:

- write down the screen, task, exact or paraphrased quote, time to decision, and observed action;
- label one primary error type;
- assign severity after the observation, not during the participant's attempt.

How to avoid coaching:

- answer process questions only, such as "Use the app as you normally would";
- do not define terms until after the observation is complete;
- if help is given, mark the row as coached in `operator_note`.

How to handle fatigue:

- pause after a visible slowdown;
- offer to stop;
- mark late-session errors as `fatigue_or_attention` when fatigue appears to be the dominant cause;
- do not push through W1-W12 exhaustion to manufacture completion.

How to stop safely:

- thank the participant;
- stop recording if recording exists;
- mark the session as stopped;
- record the reason;
- do not fill missing rows with assumptions.

How to label evidence:

- use `session_id`, participant pseudonym, date, tested commit, route/surface, and row number;
- store screenshots or video references separately from the observation table;
- do not store sensitive personal data.

## 15. Participant intake template

```text
session_id:
participant_id:
participant_type: novice | poker-aware beginner | low-intermediate
prior_poker_familiarity:
has_seen_sharky_before: yes | no
language:
device_class:
os_device_notes:
tested_commit_hash:
date_time:
operator:
evidence_capture_permission: note-only | screenshot | screen-recording | none
session_context: remote | in-person | screen-share | other
```

## 16. Observation row template

```csv
session_id,participant_id,participant_type,device_class,os_device_notes,tested_commit_hash,date_time,route_surface,world_task_concept_family,prompt_shown,user_choice,expected_answer,correct_incorrect,error_type,time_to_decision_seconds,hesitation_blocking_note,confusion_quote_or_paraphrase,repair_shown_yes_no,repair_understood_yes_no,recheck_result,post_session_recall_result,severity,operator_note,evidence_reference
```

Example placeholder row shape only, not evidence:

```csv
SESSION_ID,PARTICIPANT_ID,novice,phone,OS_NOTES,COMMIT_HASH,DATE_TIME,W1 decision,action read,PROMPT_PARAPHRASE,USER_CHOICE,EXPECTED,correct_or_incorrect,error_type,SECONDS,NOTE,QUOTE_OR_PARAPHRASE,yes_or_no,yes_or_no,recheck_result,recall_result,severity,OPERATOR_NOTE,EVIDENCE_REF
```

## 17. Session summary template

```text
session_id:
tested_commit_hash:
participant_type:
device_class:
critical_path_completed: yes | no
stopping_reason:
highest_severity:
observed_error_types:
repair_understood_at_least_once: yes | no
recheck_success_observed: yes | no
W12_no_W13_boundary_understood: yes | no | not_reached
participant_summary_of_app:
most_confusing_screen:
table_signal_recalled:
tomorrow_next_step_answer:
delayed_recall_result:
operator_synthesis:
recommended_verdict:
```

## 18. Issue report template

```text
issue_id:
session_id:
severity: P0 | P1 | P2 | P3 | P4
error_type:
route_surface:
world_task_concept_family:
tested_commit_hash:
observed_behavior:
participant_quote_or_paraphrase:
expected_behavior:
why_this_matters_for_learning:
reproduction_steps:
evidence_reference:
bounded_repair_candidate:
claim_safety_impact:
recommended_disposition: repair_now | monitor | future_stage | reject_with_evidence
```

## 19. Final synthesis template

```text
Human QA synthesis id:
tested_commit_hash:
date_range:
participant_count:
participant_mix:
device_mix:
sessions_completed:
sessions_inconclusive:
highest_severity_found:
P0_count:
P1_count:
P2_count:
repeated_same_root_P2: yes | no
repair_loop_understood_at_least_once: yes | no
W12_no_W13_boundary_understood: yes | no | mixed | not_reached
critical_path_result:
confusion_clusters:
notable quotes or paraphrases:
claim_safety findings:
recommended verdict: human_qa_passes_for_next_gate | human_qa_requires_bounded_repair | human_qa_blocks_until_repair | human_qa_inconclusive_needs_more_participants
exact next action:
explicit non-claims:
```

## 20. What this protocol may support

Protocol creation may support only:

- Human QA protocol ready for real execution from fixed-build `main`.

After future real Human QA evidence is collected, the evidence may support:

- identifying concrete comprehension blockers;
- routing bounded repairs;
- deciding whether to move to the next internal gate;
- comparing confusion clusters across novice, poker-aware beginner, and low-intermediate participants;
- evaluating whether W12 terminal/no-W13 language is understood by real users.

## 21. What this protocol may not support

This protocol may not support:

- Human QA approval before real sessions;
- fake or synthetic Human QA;
- public readiness;
- launch readiness;
- 9.0 readiness;
- 10/10 quality;
- durable learning effect;
- beginner mastery;
- premium commercial readiness;
- App Store/release readiness;
- monetization activation;
- W13+ readiness or route opening;
- broad market proof from one participant.

## 22. Exact next action

Recruit and schedule the minimum first-pass real participant, build or open the app from `main@ef84482b6434eb91aadbb093a50a9521726bca3d` or a later explicitly admitted fixed-build commit, and run this protocol without coaching, simulation, or synthetic evidence.

If a later commit is used, record the exact tested commit hash and do not reuse this baseline hash as if it were the tested build.

## 23. Explicit non-claims

This artifact explicitly does not claim:

- Human QA was run;
- Human QA approval;
- participant evidence exists;
- public readiness;
- launch readiness;
- 9.0 readiness;
- 10/10 product quality;
- durable learning effect;
- beginner mastery;
- premium commercial readiness;
- App Store/release readiness;
- monetization readiness;
- W13+ activation;
- W13+ readiness.

## 24. Token Efficiency Report

- Used the fixed-build baseline packet and Human QA capsule as the controlling authorities.
- Preserved W1-W12 scope instead of reopening old W1-W6-only protocol language.
- Converted accepted Human-QA-only questions into an execution script and record schema.
- Avoided product code, test, route, telemetry, screenshot, content, Modern Table, and W13+ changes.
- Created exactly one docs artifact.

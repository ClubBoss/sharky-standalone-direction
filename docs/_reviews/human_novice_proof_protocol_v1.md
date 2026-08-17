---
status: "READY_FOR_REAL_HUMAN_HNP_SESSION; HUMAN_PROOF = FALSE"
status_source: "post-harness authority reconciliation"
baseline: "f62f2d40ee0022de42e11b6a0326ecc3e1d46ded"
generated_by: "docs_frontmatter_v1"
---

# Human Novice Proof Protocol v1

Status: `READY_FOR_REAL_HUMAN_HNP_SESSION`.

This document prepares and governs a real moderated Human Novice Proof session.
It is not itself Human Novice Proof evidence or a pass claim.

`HUMAN_PROOF = FALSE` until a real eligible participant produces evidence that
satisfies the terminal criteria below.

## Authority and current baseline

- Exact product candidate: `f62f2d40ee0022de42e11b6a0326ecc3e1d46ded`.
- Canonical route authority: `AppRoot -> _EntryGate ->
  Act0ShellPreviewScreenV1 -> Act0LessonRunnerShellV1`.
- Post-harness campaign dispatch:
  `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`.
- Product direction authority:
  `docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`.

The Human protocol uses two separately labeled observations:

1. **Profile A orientation:** fresh install/fresh equivalent state. Action is not
   assumed to be fresh-install reachable.
2. **Profile B learning loop:** a production-equivalent progressed state that
   exposes the normal Action learning loop without a debug menu, direct-state
   route, answer coaching, or synthetic production bypass.

The older novice-walkthrough orientation and the bounded Profile B
repair/recheck observation are complementary. Do not merge their evidence.

## Post-harness terminal reconciliation - 2026-08-17

Technical closure used branch:

`hnp/claude-local-harness-closure-v1`

Terminal harness head:

`63dc5532a0bf174d47e1534e2610af42bb2f1948`

Reconciled evidence:

- Profile A passed locally.
- In real GitHub macOS run `31973115398`, Profile A XCTest completed with zero
  failures and `TEST SUCCEEDED`; the workflow later failed during screenshot
  capture after the Profile A traversal had already passed.
- Run `32004559132`, on the same harness head, failed before XCTest execution
  with nondeterministic Simulator launch denial:
  `FBSOpenApplicationServiceErrorDomain / SBMainWorkspace RequestDenied`.
- The same launch-affecting harness code had already launched and executed
  Profile A successfully in the previous run.
- The full Profile B / physical JSONL / privacy / reset chain remains
  `UNPROVEN`; it is not a failed product claim and must not be promoted to PASS.
- Residual Simulator/GitHub macOS launch unreliability is a
  `TECHNICAL_CAPABILITY_LIMITATION`, not a proven Sharky product defect.
- `HARNESS_DIMINISHING_RETURNS = REACHED`.
- `PRODUCT_IMPLEMENTATION_DISPOSITION = DO_NOTHING`.
- `PRODUCT_REPAIR_BUDGET_CONSUMED = 0`.
- `REAL_HUMAN_HNP = NOT_EXECUTED`.
- `HUMAN_PROOF = FALSE`.

A perfectly green automated CI/HNP lane is not a prerequisite for beginning a
real moderated Human session. No new technical harness loop is required before
Human evidence. This does not relax participant, observation, privacy,
no-coaching, or evidence-quality rules.

## Participant, consent, and privacy

The participant must be a real person, new to this Sharky build, not an
internal Sharky QA participant, unfamiliar with its implementation, and not an
advanced poker-training expert. Assign only a non-identifying code such as
`HNP-P01`. Explain that this is a voluntary usability and learning session,
that poker knowledge is not being assessed, and that they may stop at any time.
Obtain separate consent before any screen/audio/video capture.

Never record a legal name, email, account/device credential, face, unrelated
conversation, or personal screen content. Raw capture, notes, screenshots, and
telemetry remain untracked under the timestamped `output/` evidence directory
and are never committed.

Human observations and machine telemetry are separate evidence classes:

- Human observation is the primary record for orientation, comprehension,
  confusion, self-repair, felt learning effect, and Human product blockers.
- Machine telemetry is supporting technical evidence for event order and the
  local learning-loop mechanism only.
- Telemetry cannot establish Human comprehension, felt learning effect, or a
  Human PASS.
- If telemetry cannot be collected safely or reliably, record
  `HNP_PHYSICAL_TELEMETRY_FULL_CHAIN = UNPROVEN` or `NOT_COLLECTED`; do not
  infer either a Human failure or a product defect.

## Device, build, and starting state

Record the actual device/Simulator model, iOS version, locale, text size, build
command/exit code, Runner SHA-256, bundle identifier, and build HEAD in the
session evidence manifest. The Human session must use the normal production
route from the exact recorded product candidate.

For Profile A, uninstall the previous app/container or establish an equivalent
fresh state, install the recorded candidate, launch normally, and verify the
fresh learner baseline before participant interaction. Do not seed completion,
auto-complete prerequisites, or imply that Action is fresh-install reachable.

If the local HNP sink can be enabled without changing product behavior, it may
be used as separate supporting evidence via:

`--dart-define=HNP_TELEMETRY=true`

Physical JSONL path when available:

`Library/Application Support/act0_hnp_trace_v1.jsonl`

Telemetry availability is not the admission gate for the Human session.

Run the session in two labeled parts, without merging their evidence:

1. **Profile A orientation:** a fresh installed container. The participant may
   orient, identify the primary learning action, and begin the actual first
   lesson. Do not seed completion or imply that Action is fresh-install
   reachable.
2. **Profile B learning loop:** after the Profile A observation ends, explain
   only that the next independent task starts from an already-progressed course
   state. Use the existing production-equivalent Profile B materialization path
   if it is available without product mutation or a synthetic production
   bypass. The participant starts at `actions_theory`, continues to
   `actions_check_drill`, and naturally makes choices. A wrong source answer is
   evidence only if it occurs without coaching; do not ask for or manufacture
   an incorrect answer. If no natural error occurs, record repair/recheck
   exposure as insufficient rather than treating a correct first answer as
   failure.

If Profile B cannot be materialized because the execution environment fails
before the participant task begins, record
`PROFILE_B = NOT_EXECUTED_TECHNICAL_CAPABILITY_LIMITATION`. Do not count that as
a Human or product failure, do not mutate Sharky to force the session, and do
not start another harness loop. The Profile A Human observation remains valid
as separately labeled evidence; any claim requiring Profile B remains unproven.

One observer-only launch/fresh-state check is permitted before the participant
is involved. It must use a separate clean container/state and must not become a
new technical harness campaign.

## Neutral script and observer restrictions

Read only: “Please use the app as you normally would and say aloud what you
are looking for and what you expect to happen. There are no right answers about
the app. If something is confusing, say it immediately.”

Permitted neutral prompts are: “What are you looking at now?”, “What did you
think the task was asking?”, “What clue did the feedback tell you to notice?”,
“What changed in your answer the second time?”, “What would you look for in a
similar spot?”, and “What do you think the suggested next step is for?”

The observer must not point at an option, explain poker, reveal expected
answers, tell the participant to scroll, name a CTA, or rescue confusion except
for a safety or technical stop. Log every assistance event: `none`, `neutral`,
`directional_UI`, or `explicit_route_or_answer`. Any directional or explicit
assistance makes that checkpoint non-clean.

## Route observations and criteria

Record timestamps, actual route/screen, actions, participant words,
hesitation/confusion, scrolling discovery, and assistance.

| Dimension | Required observation | Pass condition for that observation |
| --- | --- | --- |
| Entry and orientation | Primary learning action and start | Participant identifies and begins it without answer coaching. |
| Decision comprehension | What is being requested; options | Participant can state the decision in their own words; labels and interaction are reachable. |
| Feedback causality | Wrong-answer feedback, if naturally exposed | Participant explains a missed clue, rather than merely “wrong/right.” |
| Repair and recheck | Same-misconception repair and original-source recheck, if naturally exposed | Participant understands the repair, returns to the source recheck, and answers without supplied answer. |
| Learning payoff | Payoff/recommendation and next step | Participant describes a learned/corrected point and can explain the next step. |
| Exit and continuation | Required CTA and deliberate exit/continue | CTA is reachable and understandable; required route records one terminal exit. |

An initial poker mistake is not a failure. Task completion, usability, concept
comprehension, felt learning effect, deterministic telemetry, product blocker,
and observer assistance are distinct records. A claimed felt learning effect
requires the participant’s own words; telemetry cannot establish it.

## Feedback scroll-reachability observation

On feedback/recommendation, record whether below-fold content is noticed,
vertical scrolling works, `Next step` is readable, the required CTA is
reachable, safe-area/home indicator overlap exists, and return preserves a
sensible scroll position. Classify exactly one of:

- `REACHABLE_AND_DISCOVERABLE`
- `REACHABLE_BUT_NOT_DISCOVERABLE`
- `PARTIALLY_OBSCURED`
- `CTA_UNREACHABLE`
- `INCONCLUSIVE`

Only materially task-impacting `PARTIALLY_OBSCURED` or `CTA_UNREACHABLE` is a
confirmed functional regression. Do not repair it during the Human session.

## Separate evidence capture

Create:

`output/human_novice_proof_v1/<UTC_TIMESTAMP>/human/`

for the Human record, containing only consent-safe material such as:

- participant code;
- build/device manifest reference;
- neutral-script record;
- sanitized observer notes and timestamps;
- task outcomes;
- assistance ledger;
- consented captures;
- route/screen reproduction notes;
- severity candidates and Human verdict.

If machine telemetry is available, create separately:

`output/human_novice_proof_v1/<UTC_TIMESTAMP>/machine/`

and place the physical JSONL plus its validation report there. Validate that
every line parses, the final line is complete, route/task and choice IDs,
canonical error type, bounded decision-time bucket, repair/recheck chronology,
payoff/recommendation, and required terminal exit agree with observer notes.
Confirm that no participant identity, raw board-card ID, table signal,
learner-facing copy/context, account, or network field is present. Record each
disagreement explicitly; do not alter telemetry.

If machine telemetry cannot be exported or validated, keep the `machine/`
record as a status note only and preserve its claim as `UNPROVEN`. Never copy
Human notes into telemetry or infer missing telemetry from Human observation.

## Minimum operator handoff

1. Re-resolve and record the exact product candidate. For this reconciliation it
   is `f62f2d40ee0022de42e11b6a0326ecc3e1d46ded`. If product main changes before
   the session, stop and reconcile the candidate instead of silently mixing
   builds.
2. Confirm participant eligibility and consent; assign only a non-identifying
   participant code.
3. Prepare a clean Profile A state on the normal product route. Record device,
   build SHA/hash, locale, text size, and fresh-state baseline before handing
   control to the participant.
4. Run Profile A with the neutral script and no directional/answer coaching.
   Capture Human observations in `human/` only.
5. End Profile A, preserve its evidence, then prepare the independent
   production-equivalent Profile B state if the existing materialization path
   is available. If infrastructure prevents Profile B before participant
   execution, mark the technical limitation and preserve Profile B as unproven;
   do not repair product or harness.
6. Run Profile B without manufacturing a wrong answer. Record confusion,
   decision comprehension, feedback causality, self-repair/recheck if naturally
   exposed, learning payoff, CTA reachability, and exit/continuation.
7. Export/validate machine JSONL separately only when available. A telemetry
   gap cannot overwrite the Human observation record and cannot be called PASS.
8. Teardown the participant state and local evidence safely. Verify that no
   identifying participant data was added to app state, telemetry, commits, or
   tracked repository files.
9. Apply the terminal verdict rules below. Open a product repair only from an
   actionable real-Human finding; otherwise keep
   `PRODUCT_IMPLEMENTATION_DISPOSITION = DO_NOTHING`.

## Stop conditions, findings, and non-claims

Stop immediately for missing consent/eligibility, a technical/safety stop,
P0/P1 route failure, or evidence that cannot safely be captured. A finding must
include stable ID, observed behavior, route/screen, assistance, evidence,
learning impact, P0–P4 severity, confidence, deterministic reproducibility,
smallest repair boundary, and disposition. Classify separately as novice
misunderstanding, intentional learning error, unclear instruction, interaction
blocker, telemetry mismatch, technical capability limitation, or cosmetic
preference. One participant’s taste is not a defect.

Infrastructure failure before the participant can execute a required task is
not a Human FAIL and is not a product defect unless separate evidence proves a
Sharky causal defect. Record it as a technical capability limitation and keep
the affected claim unproven.

Use `HUMAN_NOVICE_PROOF_V1_PASSED` only after a real eligible participant has
completed the required applicable Human observations without prohibited
coaching or a functional blocker. Use
`HUMAN_NOVICE_PROOF_V1_FAILED_WITH_ACTIONABLE_FINDINGS` for real reproducible
Human/product blockers; `HUMAN_NOVICE_PROOF_V1_INCONCLUSIVE` for an executed but
unreliable Human session; and `HUMAN_NOVICE_PROOF_V1_READY_FOR_SESSION` only
before a participant session.

A clean Human verdict does not automatically promote
`HNP_PHYSICAL_TELEMETRY_FULL_CHAIN`; that machine claim remains independently
PASS/UNPROVEN according to actual telemetry evidence.

This protocol makes no claim of Human Novice Proof passed, full accessibility,
fresh-install Action access, release readiness, remote analytics, Profile B
telemetry/privacy/reset PASS, or a product repair before those claims are
actually evidenced.

`READY_FOR_REAL_HUMAN_HNP_SESSION = TRUE`
`REAL_HUMAN_HNP = NOT_EXECUTED`
`HUMAN_PROOF = FALSE`

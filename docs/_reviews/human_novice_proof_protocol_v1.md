# Human Novice Proof Protocol v1

Status: LOCAL-ONLY SESSION PROTOCOL. This document prepares a real moderated
session; it is not Human Novice Proof evidence or a pass claim.

## Authority and baseline

- Product candidate: `5e2727b0101d433708198c598ae38381cef8da12`.
- Documentation head: `76b175eb064d7d9def8644055fc67e5ac77ffedb`.
- Local reconciliation: `6c786a0060fff24b3c6def10484612fad2be54be`.
- Frozen preparation baseline: `e2d612d570894d47ceb5a450b64b04c8c2681eec`.
- Route authority: `AppRoot -> _EntryGate -> Act0ShellPreviewScreenV1 ->
  Act0LessonRunnerShellV1`.

The Final Deep Independent Audit names Human Novice Proof as the next gate and
does not authorize a repair wave before its adjudication. It also establishes
the route split used here: Profile A is a fresh install and truthfully stops at
First Table Guide with Action locked; Profile B is the documented,
production-equivalent persisted state (four completed prerequisite lessons and
28 prerequisite tasks) that exposes the Action learning loop. The older
novice-walkthrough protocol remains the first-session orientation observation;
it is complementary rather than a substitute for the bounded Profile B
repair/recheck observation below.

## Participant, consent, and privacy

The participant must be a real person, new to this Sharky build, not an
internal Sharky QA participant, unfamiliar with its implementation, and not
an advanced poker-training expert. Assign only a non-identifying code such as
`HNP-P01`. Explain that this is a voluntary usability and learning session,
that poker knowledge is not being assessed, and that they may stop at any time.
Obtain separate consent before any screen/audio/video capture.

Never record a legal name, email, account/device credential, face, unrelated
conversation, or personal screen content. Raw capture, notes, screenshots,
and telemetry remain untracked under the timestamped `output/` evidence
directory and are never committed.

## Device, build, and starting state

Record the actual simulator model, iOS version, locale, text size, build
command/exit code, Runner SHA-256, bundle identifier, and build HEAD in the
session evidence manifest. Build a fresh debug iOS Simulator app with
`--dart-define=HNP_TELEMETRY=true`, uninstall the previous app/container, then
install the fresh Runner.

The prepared local environment is iPhone 16 Pro
`F66875F4-A2B2-4EB5-84BB-5C3E919B2B91`, iOS 18.1, Simulator Debug, bundle
identifier `com.example.pokerAnalyzer`. The fresh HNP-enabled build completed
from docs-only HNP preparation HEAD `fe07a316d457a54615e44b29fb5405f36c0f1328`;
its Runner SHA-256 is
`81e1ca24a2523d00571c065f6bc5b5fbe268bc93845c51f63503c4c8f3447bb8`.
The participant operator must re-record these values if building a replacement
binary before the live session.

Run the session in two labeled parts, without merging their evidence:

1. **Profile A orientation:** a fresh installed container. The participant may
   orient, identify the primary learning action, and begin the actual first
   lesson. Do not seed completion or imply that Action is fresh-install
   reachable.
2. **Profile B learning loop:** after the Profile A observation ends, explain
   only that the next independent task starts from an already-progressed course
   state. Reset to the validated production-equivalent Profile B fixture; do
   not use a debug menu, direct-state route, or answer coaching. The participant
   starts at `actions_theory`, continues to `actions_check_drill`, and
   naturally makes choices. A wrong source answer is evidence only if it occurs
   without coaching; do not ask for or manufacture an incorrect answer. If no
   natural error occurs, record repair/recheck exposure as insufficient rather
   than treating a correct first answer as failure.

One observer-only technical traversal is permitted before the participant is
involved; reset to a separate clean container before Profile A.

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
confirmed functional regression. Do not repair it in this mission.

## Telemetry and evidence

The debug-only local HNP sink writes
`Library/Application Support/act0_hnp_trace_v1.jsonl` inside the installed
Simulator container. After the session, extract the physical file and validate
that every line parses, the final line is complete, route/task and choice IDs,
canonical error type, bounded decision-time bucket, repair/recheck chronology,
payoff/recommendation, and required single terminal exit agree with observer
notes. Confirm that no participant identity, raw board-card ID, table signal,
learner-facing copy/context, account, or network field is present. Record each
disagreement explicitly; do not alter telemetry.

Create `output/human_novice_proof_v1/<UTC_TIMESTAMP>/` containing the build
log/exit code, Runner hash, this protocol snapshot, neutral script, sanitized
notes, task outcomes, assistance ledger, ordered consented captures, physical
JSONL, JSONL validation report, and an evidence manifest with SHA-256 hashes.

## Stop conditions, findings, and non-claims

Stop immediately for missing consent/eligibility, a technical/safety stop,
P0/P1 route failure, or evidence that cannot safely be captured. A finding must
include stable ID, observed behavior, route/screen, assistance, evidence,
learning impact, P0–P4 severity, confidence, deterministic reproducibility,
smallest repair boundary, and disposition. Classify separately as novice
misunderstanding, intentional learning error, unclear instruction, interaction
blocker, telemetry mismatch, or cosmetic preference. One participant’s taste
is not a defect.

Use `HUMAN_NOVICE_PROOF_V1_PASSED` only after a real eligible participant has
completed the required applicable observations without prohibited coaching or a
functional blocker. Use `HUMAN_NOVICE_PROOF_V1_FAILED_WITH_ACTIONABLE_FINDINGS`
for real reproducible blockers; `HUMAN_NOVICE_PROOF_V1_INCONCLUSIVE` for an
executed but unreliable session; and `HUMAN_NOVICE_PROOF_V1_READY_FOR_SESSION`
only after preparation is complete with no real participant session. This
protocol makes no claim of Human Novice Proof passed, full accessibility,
fresh-install Action access, release readiness, remote analytics, or a product
repair.

# October 2026 Early Human Mechanics Pilot — Preflight

Status: READY_FOR_MANAGED_SETUP / REAL_PARTICIPANTS_NOT_YET_RUN
Date: 2026-10-08
Purpose: mechanics-first evaluation on legible temporary art; **not** full P02,
not premium visual acceptance, not commercial efficacy evidence.

## Exact candidate and admission

Candidate proposed: PR #226 `e87862309817f2f27f9db8bb51afbfd118f8310f`
(on main base `bdf560f`). No merge is authorized by this packet.
Frozen candidate is only valid after exact-SHA install/launch smoke and
visible CTA/feedback inspection on the intended supported phone class.
The machine route cone is explicitly **39 pass / 5 fail** (see
`2026_10_wave3_mechanics_route_truth_v1.md`); unresolved geometry
assertions are novice-actionability **hypotheses** and cannot be
automatically marked PASS. Use a build actually derived from the admitted
candidate, not the dirty protected Mac checkout or unfinished V4 art branch.
Do not conflate a developmental pilot with the Master Plan P02 admission gate.

Existing, reusable procedure is in
`docs/_reviews/human_novice_proof_preflight_v1/`:
`MODERATOR_SCRIPT.md`, `OBSERVER_CHECKLIST.md`,
`SESSION_SCORECARD.md`, `CONSENT_AND_RECORDING_NOTE.md`,
`TELEMETRY_MAPPING.md`, `ISSUE_CLASSIFICATION.md` and
`CANDIDATE_MANIFEST.md`. This packet does not fork, duplicate or relax
their requirements.

## Core falsification goal

Does a novice, with no poker help, understand and complete:
**Entry → table clue → decision → causal feedback → continue → Review
→ practice/repair → source recheck → earned proof → next useful rep**?

At proof screen, user must see a concrete corrected signal (not only XP,
progress number, generic praise, or a telemetry event). Original-source
recheck must be distinguished from an unseen transfer check. Exact-source
success cannot be claimed to demonstrate generalized retention.

## Five-novice bounded pilot

Target five truly inexperienced poker learners, one independently observed
session each (not simultaneous group coaching). Keep device/build, task,
moderator script, intervention criteria and locale fixed per comparison;
record locale and any deviations. EN and RU are supported; do not silently
mix them in one individual test.

Moderator reads the exact previously accepted script: no tutorial, no
spoilers, no leading questions, no forced wrong answer.
Record first meaningful action, observed table scan, decision time, first
visible feedback, learner's causal paraphrase, self-directed next step,
Review and repair route when naturally exposed, and comprehension of the
earned proof. Include verbatim response to four payoff questions.
Capture *actual* view/scroll/tap frustration relating to the measured
94.12px feedback gap or 143.12px recheck action gap.

Intervention ladder: 0 self-directed, 1 neutral “What would you do next?”,
2 directional UI guidance, 3 explicit route/answer. 2/3 is not an
independent learner PASS.

Evidence target from prior protocol:
- Zero P0/P1 crash/dead-end/unreachable-action or data-loss incidents.
- >=4/5 discover primary entry with level 0/1 intervention.
- >=4/5 identify private cards / board / pot independently.
- >=4/5 explain a causal feedback clue and recall a specific rule.
- >=3 naturally exposed repair journeys complete without level 2/3;
  when <3 naturally occur, classify Repair/Review Human evidence
  `INSUFFICIENT_EXPOSURE`, not product failure or PASS.
- Collect decision time descriptively; avoid invented pass cutoff.
- The cohort is formative, not statistically strong evidence of
  Day-2/Day-7 retention or willingness-to-pay.

Telemetry minimum, without PII:
`user_choice`, `correct`/outcome and `error_type`,
`time_to_decision`, ordered `repair_started`,
`repair_completed`, `recheck_started`,
`learning_effect_delta_viewed` (only if proof actually visible),
plus a stable attempt/run identity. Compare event ordering with a
human-observed screenshot/state, not event count alone.
Preserve exact timestamp/build mapping; do not harvest contacts or
record a participant without the separate consent note.

## Abort / promotion rules

Stop and classify P0/P1 on crash, dead action, inability to proceed,
required answer hidden, wrong state identity or feedback/CTA clipping.
P2 needs repeated concrete comprehension/interaction friction.
An isolated aesthetic preference is observation only. Visual character
polish does not become an active wave unless it blocks task recognition
or basic affordance.

The pilot does not auto-promote:
- `HUMAN_PROOF` to TRUE for the whole product;
- `P02` to admitted or passed;
- same-clue proof to unseen transfer;
- a short-term correction to Day-2/Day-7 durable retention;
- incomplete premium/engaged-inactive art to accepted.

## Completion and next gate

When eligible user sessions exist:
1. Freeze one exact candidate SHA, simulator/device model and date.
2. Complete five scorecards, times, intervention levels and incident ledger.
3. Classify any repeated learner blockage by first owner family.
4. If a single consequential blocker is proven, implement one bounded
   reversible fix in a new PR; rerun affected evidence only.
5. Otherwise, record `EARLY_MECHANICS_PILOT_COMPLETE` and propose
   explicit separate full P02 admission and later transfer/retention runs.

Until real participants are recruited and observed:
`EARLY_PILOT_HUMAN_PROOF = NOT_COLLECTED`.

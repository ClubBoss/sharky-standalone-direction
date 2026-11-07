# First 10 Minutes × Voluntary Engagement — Field Card v1

**Status:** blank execution form; NO participant observed as a result of authoring this card.
**Authority:** current `docs/_reviews/human_novice_proof_preflight_v1/MODERATOR_SCRIPT.md`,
`OBSERVER_CHECKLIST.md`, `SESSION_SCORECARD.md`, consent/telemetry contracts and
Master Plan v4. This is a concise **engagement extension**, not a replacement
or a relaxation of the original Human protocol. Pilot is distinct from P02.
Use the full canonical moderator script for actual sessions.

## Session identity (NO real names/emails)

- Session code: ______ (pseudonym; store local only)
- Exact app/build/SHA and install provenance: ______
- Device/OS/locale: ______
- Participant self-reported baseline: new / casual / experienced
- Sharky first-run path observed: `new → Start from zero` / `2-question → 3-spot diagnostic` / other (specify)
- Started at [local time]: ______
- Consent note read? yes/no. Recording opted-in? yes/no (no recording by default)
- Tester/observer role: ______

## Clock (actual observer stopwatch, not event precision)

| Event | mm:ss elapsed | Independent? assistance level 0–3 | Notes / exact CTA or copy |
| --- | --- | --- | --- |
| First actual visible frame | 00:00 | n/a | |
| First meaningful tap | | | |
| First poker decision (diagnostic vs taught **label explicitly**) | | | |
| First committed table action | | | |
| First result/feedback visible | | | |
| Learner independently explains ONE causal clue | | | |
| First earned proof in main lesson (if reached) | | | |
| Second meaningful challenge voluntarily started | | | |
| First self-initiated exit or pause | | | |
| 10:00 stop if still in app | | | |

**Assistance:** 0 no hints; 1 neutral “What would you do next?”;
2 directional UI help; 3 exact route/answer. Levels 2–3 are NOT independent success.
Never tell the participant to select an incorrect response. No forced reading
or deliberately interrupted learning state.

## Independent observed behavior (check only if actually observed)

- [ ] First required action identified without directional help
- [ ] Table private cards, board and pot recognized where relevant
- [ ] Causal *why* paraphrase correct, verbatim participant words: ______
- [ ] Feedback not skipped mechanically; if skipped, observed seconds: ______
- [ ] If an error happened naturally, repair attempted independently; result: ______
- [ ] Same-signal recheck distinguished from a new/unseen transfer challenge
- [ ] Earned proof read AND understood, not only rendered
- [ ] A different meaningful task voluntarily chosen after initial payoff
- [ ] Participant knew how to stop and return later
- [ ] No artificial urgency, energy scarcity or hidden fee disclosed

Exact user language about *fun*: ______
Exact user language about *frustration/confusion*: ______
Observer notes on action-dock/table spacing or dead area: ______

## Only after behavioral portion: four neutral payoff questions

Use the canonical Human moderator's four payoff questions from its observer
checklist **verbatim**. Then append:
- “How interesting was the exercise, 1–5?” ___
- “Would you choose another challenge now if nothing rewarded you for it?” yes/no; reason in participant's words: ____
- “What specifically would bring you back tomorrow?” ____
- “Which felt more rewarding: understanding the clue, winning the hand, points, or something else?” ____

Do NOT use these answers as retention proof; behavior and actual return matter
more than stated intention. Avoid teaching poker during questions.

## Event reconciliation (local only)

Match technical session/run/attempt IDs and task IDs to observed task sequence.
Required: `user_choice`, correct/result/error type,
`decisionTimeBucket` (`under_3s`, `3_to_10s`, `over_10s` or `unknown`),
repair/recheck/payoff events if encountered, and explicit exit.
The old pilot worksheet's `time_to_decision_ms` request is NOT an active
telemetry field; measure exact seconds here with stopwatch instead.
Do not record raw cards/copy, account identity or recording links in telemetry.
If a local trace is unavailable, write `NOT_CAPTURED`, not fabricated data.

## First-ten-minute independent truth

- Entry: PASS / OBSERVED_BLOCKER / NOT_EXPOSED
- First table choice: PASS / OBSERVED_BLOCKER / NOT_EXPOSED
- Causal comprehension: PASS / FAIL / NOT_EXPOSED
- Voluntary next challenge: YES / NO / NOT_REACHED
- Observed attention/boredom: ______
- Main learning proof visible: YES / NO / NOT_EXPOSED
- Brand/trust/paywall friction: ______
- Incident severity P0/P1/P2/observation and stable repro if any: ______
- Session human-evidence disposition: INSUFFICIENT / FORMATIVE_FINDING / NO_CONFIRMED_BLOCKER
- Next wave verdict: no automatic implementation; aggregate across cohort and
  choose one bottleneck based on repeated causally relevant evidence.

## Across five fresh novices (blank aggregation)

| Measure | n observed / n eligible | Finding / exposure caveat |
| --- | --- | --- |
| Unaided first meaningful action | __ / __ | |
| Correct causal paraphrase | __ / __ | |
| Unassisted continuation after first feedback | __ / __ | |
| Voluntary next meaningful challenge | __ / __ | |
| Genuine repair exposure | __ / __ | |
| Full repair route success | __ / __ | only if naturally exposed |
| Learner asks for more poker after session | __ / __ | intention only |
| Any P0/P1 | __ / __ | stop if confirmed |

Five users can expose repeated usability bottlenecks; they cannot establish
population-level fun, D7/D30 retention, conversion or competitor superiority.

## Competitor parity extension (independent session, no privileged access)

When testing Poker Skill / WSOP Academy / PokerArena / Runout:
- record exact app/version/region and whether the participant is on free
  access, account creation, trial or paid tier;
- use the same clock and first-action/first-poker-decision metrics;
- record any competitor-specific job mismatch (PvP vs guided microlearning);
- record a genuine first feedback and whether voluntary second rep is possible;
- if gated by a paywall, stop at the legally accessible gate; do not buy or
  circumvent without explicit separate authorization;
- do not imply that marketing screenshots constitute observed app sessions.

**End:** `HUMAN_RESULTS = EMPTY_UNTIL_FILLED`.

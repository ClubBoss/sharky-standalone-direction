# W10-to-W11 Transition & W11 Active Source Contract v1

## 1. Verdict

`w11_source_contract_ready_with_transition_policy`

W11 remains non-routable today, but the minimum source and transition contract
is now explicit. The future admission policy is conditional W10-to-W11
continuation: only a completed selected W10 track may hand off to W11, and only
after the W11 active-source and route-proof definition of done is complete.

## 2. Current blocker statement

W11 route proof is blocked because `content/worlds/world11/` does not exist,
and neither the campaign registry nor canonical truth map has a W11 entry.
`ProgressService.getNextSpinePackToRunV1()` currently returns the selected W10
track after W10 calibration; it has no W11 branch.

The dormant W11 lesson cards and runners in
`lib/ui_v2/act0_shell/act0_shell_state_v1.dart` express Real Play Transfer
intent: session planning, trigger recognition, review loops, and a capstone.
They are locked, non-selectable Act0 preview definitions. They are not active
authored content, a campaign pack, a canonical session, learner access, or
route proof.

Synthetic W11 content is forbidden because it would invent curriculum rather
than promote owned source. A W10 handoff cannot be invented either: W10's
existing calibration only selects Cash, Tournament, or Mixed track entry, and
does not define a completed-track transition to another world.

## 3. W11 active source contract

Before W11 is route-owned, all of the following must exist.

1. **Active-root shelf.** Create `content/worlds/world11/v1/` with an explicit
   world manifest/index and a bounded session family. It must be owned by the
   active content tree, not by `act0_shell_state_v1.dart` or an archive.
2. **Minimum learning shape.** The first admitted W11 slice must identify one
   Real Play Transfer cognitive shift and use curated micro-sessions. Every
   session has one measurable skill atom, 6-12 table-first decisions where a
   drill is used, factual error feedback, a short variation or correction, and
   a transfer/review close. It must preserve
   `choice -> visible table signal -> why -> repair or recheck -> proof`.
3. **Source-proven copy.** Titles, prompts, hints, outcomes, and transfer text
   must be reviewed against the active curriculum authority and the dormant
   W11 intent. Copy may say `Real Play Transfer` and describe the admitted
   session objective; it must not claim broad mastery, AI/adaptivity, leak
   diagnosis, specialization, paid access, W12 completion, or Volume I
   completion.
4. **Route-owned decision path.** If a W11 campaign is admitted, every
   session/pack has deterministic decision targets and uses the existing
   campaign telemetry event owners. No telemetry schema or new analytics owner
   is required; standard campaign start/end and session completion must remain
   observable through existing behavior.
5. **Canonical registration.** The active campaign pack registry,
   `kCampaignPackIdsV1`, canonical session-backed pack set, canonical world
   entry ordering, and the current route owner must all name the same W11 pack
   and session identity. The registration must be derived from the active shelf
   rather than using a dormant runner as a substitute.
6. **Required tests.** Add deterministic content/registry invariants, a W11
   next-pack route contract from an explicit completed-W10 fixture, and a
   learner-entry/actionability test on the canonical Act0 path. Existing W7-W10
   route tests must remain green.

## 4. Dormant W11 promotion rules

- Dormant definitions may be used only as source hints for scope, naming, and
  intended learning outcomes.
- Before any promotion, content review must map every admitted W11 session to
  one active curriculum cognitive shift, one skill atom, its table signal,
  correct action, factual why, common error, variation, and transfer/review
  close. Poker correctness and pedagogy review are required by the Content
  System production rule.
- Locked cards, `Act0LessonTaskV1` objects, preview copy, and runner `copyWith`
  variants cannot be promoted directly as an active shelf, canonical session,
  campaign pack, registration row, entitlement/gate, or learner route.
- Route proof is not established until the active shelf, canonical
  registrations, route entry, and deterministic tests agree. The locked W11
  definitions must remain non-selectable until that separate implementation
  ships.

## 5. W10-to-W11 transition policy

| Option | Trust and route truth | Risk / cost | Decision |
| --- | --- | --- | --- |
| 1. Keep W10 terminal while W11 is planned. | Honest current behavior. | Does not define future continuation. | Current-state fallback. |
| 2. Show a neutral planned-next message after W10. | Can be honest if carefully worded. | Requires UI/copy ownership without adding W11 value. | Reject for now. |
| 3. Route to W11 only after an active W11 shelf and canonical session exist. | Connects a real completed W10 path to an owned W11 continuation. | Requires explicit completed-track contract and focused tests. | **Select.** |
| 4. Require W11 plus W12 readiness before routing W11. | Conservative. | Couples W11 to a premature W12/Volume I boundary. | Reject. |
| 5. Add W11 as manual Learn-only entry. | Avoids an automatic handoff. | Creates a second progression owner and weakens Today-route truth. | Reject. |

**Selected policy — conditional automatic continuation.** Until W11 route DoD
is green, preserve option 1 exactly: W10 remains the terminal current route.
After DoD is green, a future implementation may return the W11 entry pack only
when all of these are true:

1. W10 calibration is complete.
2. A valid selected track exists (Cash, Tournament, or Mixed; Mixed remains
   the existing fallback).
3. The selected W10 track entry pack is recorded complete by existing pack
   completion truth.
4. The active W11 shelf, canonical registration, W11 route contract, and safe
   learner entry are all present.

This is a single selected-track completion, not a requirement to complete all
W10 tracks and not a specialization-completion claim. It must not change W10
track choice, replace Act0 Home, or use W12 as an intermediate gate.

## 6. No-W12 / No-W13 gateway rules

- W12 remains `planned foundation` until a separate source, route, and proof
  decision admits it.
- W13+ remains later frontier only; no W11 or W12 state can unlock, link to,
  or imply access to it.
- W11 admission must say only `current continuation` where route proof exists;
  it must not say `Volume I complete`, `next volume`, or equivalent completion
  language.
- W10 completion and W11 availability are not premium gates. They create no
  price, trial, purchase, restore, entitlement, or paid-unlock implication.
- No W11 failure, completion, or W12 planned state may be used to imply AI,
  mastery, leak, or specialization behavior.

## 7. Future W11 route-proof DoD

Do not reopen W11 implementation until each gate is demonstrably true:

1. An active `content/worlds/world11/v1/` source shelf exists and passes
   content validation.
2. Its session/drill/theory source passes the promotion review in section 4.
3. The selected transition policy has an explicit completed-W10 fixture and
   a named selected-track completion predicate.
4. The W11 campaign/session IDs and their registry, canonical truth, and
   current-route owner paths are identified and agree.
5. The canonical Act0 learner entry owner is identified; Act0 Home remains the
   canonical root rather than being replaced.
6. Focused deterministic W11 registry, route, and learner-entry tests are
   written, including regression coverage that W7-W10 routing remains intact.
7. Current-route copy says only W11 continuation, W12 planned, and W13+ later
   frontier; copy guards prove the forbidden claims are absent.
8. Explicit tests prove no W12 route, no W13 unlock/access branch, no Volume I
   completion claim, and no commerce or entitlement behavior change.

## 8. Next recommended wave

`W11 Active Source Draft v1`

The dormant W11 definitions supply bounded source hints, and the active content
architecture supplies a reviewable shelf shape. The next wave should draft and
review that source only; it must not register a route or modify W10 progression.

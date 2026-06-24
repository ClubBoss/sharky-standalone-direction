# Mastery Tier Contract v1

Date: 2026-06-24
Status: local contract; no product implementation
Scope: define the minimum safe `Learn -> Prove -> Speed` contract from current
evidence. This is not a new roadmap authority and does not make a mastery UI
claim.

## 1. Verdict

`contract_ready_with_owner_boundary`

Act0 has sufficient task-level atom identity, repair outcome, deterministic
sequence age, recheck, and candidate-prove seams to define a local contract.
It is not yet safe to treat W5/W6 session-drill receipts as the same state:
that family retains session/drill identity and has no durable recheck-result
owner. A cross-family bridge contract must precede any unified tier state.

## 2. Current evidence seams

| Need | Current evidence and owner | Limit |
| --- | --- | --- |
| Atom identity | `Act0SkillReceiptV1` carries `skillAtomId`, `skillLabel`, `sourceSignalId`, and a learner-facing signal label. The first-value mapper currently recognizes table position, starting hand, board, action, price, and fallback table reading. | The persisted Act0 retention record is keyed by source `taskId`, not `skillAtomId`. |
| Repair outcome | A wrong/suboptimal Act0 result creates an `Act0RepairIntentV1`; a correct exact/mapped repair clears it and stores task-level `fixedRecent` retention. A failed repair retains/open-repairs the source. | This is task-intent proof, not a durable atom tier record. |
| Recheck outcome | After six deterministic retention-sequence steps, `fixedRecent` becomes `agedRecheck`. A correct aged recheck increments `successfulRecheckCount` and becomes `ownedCandidate`; a miss opens repair again. | The count is task-level; it is not a mixed-context proof threshold. |
| Prove outcome | An owned candidate is surfaced as a `prove:` job. A correct attempt emits the existing Act0 prove-completed event; current local stability is two successful rechecks. | There is no per-atom persisted `Prove` result or Speed target selector. |
| Home / Review priority | Act0 orders open repair before aged recheck, then owned-candidate proof, then ordinary route continuation. Home owns next action; Review owns repair/recheck/replay continuation. | This ordering must remain intact. |
| Profile | Profile reflects current focus/recent proof/progress after the action. | It is a mirror, never a tier-state owner. |
| W5/W6 session drills | The session-drill receipt family persists source world/session/drill, missed signal, and exact/same-signal target; Review derives a launch queue from it. | Its store cannot record resolved/attempted/successful rechecks, and launch/back-out must not mutate it. |

`Act0MasteryStatusV1` (`learning`, `needsReview`, `solid`, `cleanPass`) is a
per-run display/status seam. It must not be relabeled as this durable tier
state without an explicit owner.

## 3. Canonical atom identity

A tierable atom requires this minimum record. Missing any required field makes
the atom ineligible; it may still use existing task-level repair.

| Field | Requirement |
| --- | --- |
| `skillAtomId` | Stable product identifier for the behavior being learned. |
| Visible signal family | Stable table/card/action cue, including its machine signal id and learner-safe label. |
| Learner-facing clue name | The short clue used by Home, Practice, Review, and feedback; it must not introduce new terminology. |
| Source family / world | Act0 task identity plus its source family/world; session drills additionally retain session/drill identity. |
| Curated target availability | An exact replay or explicitly mapped same-signal repair target exists and is route-valid. |
| Repair target availability | A correct repair can be attributed to the same source identity without guessing from route launch. |
| Mixed-context target availability, if eligible | A curated target exists that tests the same atom in a safe different context and has no unintroduced terms. |

Task IDs remain the local persistence keys until an owner bridge defines a
many-task-to-one-atom mapping. A signal label alone is not identity.

## 4. Tier states

Only these three learner-safe states are permitted. They describe evidence,
not permanent ability or a score.

| State | Learner-facing meaning | System meaning | Required evidence to enter | Hold condition | Downgrade condition | Must not happen |
| --- | --- | --- | --- | --- | --- | --- |
| Learn | “Practice this clue with help.” | Default state and any open repair. | Initial attempt has started, or a miss/repair outcome exists. | Keep while repair is open or stability is not yet evidenced. | Same-signal miss/open repair remains or returns here. | Do not call a first clean answer mastery. |
| Prove | “You repaired it; check it again with less help.” | Eligible candidate after evidence of repair and stability; it is not Speed. | Clean repair result plus a clean aged recheck for the same local identity, with no open repair. | Hold while awaiting an eligible curated prove target/result. | Same-signal miss or reopened repair returns to Learn. | Do not promote merely because the learner launched, viewed, or backed out of a target. |
| Speed | “Keep this clue sharp in quick mixed spots.” | An atom has passed its curated proof target and can be selected for eligible mixed recall. | Clean Prove result on the exact curated target, no open repair, and mixed-context eligibility. | Hold only while later same-signal evidence remains clean. | Any same-signal miss reopens repair and returns to Learn. | Do not claim transfer or schedule random drills without a curated target. |

## 5. Promotion, hold, and downgrade rules

The contract uses only initial outcome, repair result, recheck result, prove
result, and deterministic sequence age.

1. An initial miss opens or preserves `Learn` and the existing open repair.
2. A clean repair moves the local identity to `fixedRecent`; it is eligible for
   later `Prove` assessment, never immediately `Speed`.
3. Deterministic sequence age may create an `agedRecheck`. A clean aged
   recheck, with no open repair, makes the identity eligible for `Prove`.
4. A clean result on the exact curated Prove target makes the identity eligible
   for `Speed`; the later owner must persist that result before any Speed claim.
5. A same-signal miss at repair, recheck, Prove, or mixed recall downgrades to
   `Learn` and opens/preserves repair. It does not erase historic evidence.
6. Launch, CTA tap, route entry, route continuation, target view, invalid
   fallback, and back-out alone are stable no-ops for tier state.
7. Normal route continuation is a stable no-op unless one of the evidence
   events above is recorded.
8. Aged recheck is the stability test before promotion where the local identity
   has not already produced an exact persisted proof result.

The current Act0 local implementation has a stronger task-level stability
floor of two successful rechecks for `ownedCandidate`; a future owner may use
that existing floor, but must not silently widen it into a new scheduler rule.

## 6. Mixed-recall eligibility

An atom is eligible for a later deterministic mixed-recall selector only when:

1. it has a curated mixed-context target;
2. it has passed the required exact proof threshold for its owner;
3. it has no open repair;
4. its target uses no unintroduced terms; and
5. it is beginner-safe for the learner's current world route.

No random scheduler is authorized. Existing authored later-Volume-I transfer
tasks are inventory, not evidence that an atom is mixed-recall eligible.

## 7. Cross-family boundary

| Family | What it owns now | What it cannot safely own yet |
| --- | --- | --- |
| Act0 repair/task evidence | Task-keyed open repair, correct repair, retention sequence, aged recheck, owned candidate, Home priority, Review continuation, and Profile mirror. | A durable atom-keyed tier record across multiple tasks/families. |
| W5/W6 session-drill receipt/recheck evidence | Source world/session/drill, drill family, missed signal, target drill, and a derived Review launch item. | A durable correct/wrong recheck result, resolved receipt, tier mutation, or atom merge with Act0. |
| Later Volume I content evidence | Curated practice/transfer inventory and content-quality requirements for a skill atom, repair, mastery signal, and beginner-safe vocabulary. | Runtime ownership, scheduling, or promotion evidence. |

Do not fabricate `Act0RepairIntentV1` for session-drill receipts or aggregate
these families by label. The required future bridge must define a canonical
atom key, source-identity mapping, exact-answer result event, and retained
resolution evidence before it permits shared tier transitions.

## 8. Candidate atom inventory for a future tiny slice

| Atom / signal family | Current source | Why safe | Tier eligibility confidence | Missing evidence |
| --- | --- | --- | --- | --- |
| `action_read` / `no_bet_yet` | Act0 first-value receipt; `actions_legal_context -> actions_check_drill` mapped repair. | Full identity, same-signal repair, visible clue, and Home/Review regression coverage exist. | High for Learn and repair; low for Speed. | Curated mixed target and persisted atom-level Prove result. |
| `table_position_read` / `hero_button` | Act0 first-value receipt and position repair targets. | Concrete table cue and learner-safe repair vocabulary exist. | Medium. | Exact cross-context proof target and atom-level owner. |
| `starting_hand_read` / `hero_cards` | Act0 first-value receipt and private-card recheck content. | One visible card cue with explicit recheck content. | Medium. | Canonical same-atom repair mapping and mixed target. |
| `board_read` / `board_cards` | Act0 first-value receipt and W5 board-reading tasks. | Curated table cue and later reinforcement exist. | Medium for Act0-only scope. | Cross-family mapping and exact mixed proof target. |
| `price_read` / `pot_to_call` | Act0 first-value receipt. | Clear table signal and beginner-facing label. | Low-medium. | Supported repair target and mixed-context proof. |
| W5 `board_texture_*` | Session-drill receipt/queue family (`w5.s01`). | Real source/target identity and same-signal launch queue exist. | Low until bridged. | Correct/wrong recheck-resolution owner and `skillAtomId` mapping. |
| W6 `range_bucket_*` | Session-drill receipt/queue family (`w6.s01`). | Real source/target identity and Review queue exist. | Low until bridged. | Correct/wrong recheck-resolution owner and `skillAtomId` mapping. |

The `no_bet_yet` atom is the safest later Act0-only test fixture, but no tier
implementation is selected while the cross-family owner boundary remains open.

## 9. Non-goals / guardrails

- No UI or dashboard.
- No XP economy or streak pressure.
- No new scheduler.
- No new telemetry owner or schema.
- No commerce, paywall, or trial work.
- No Modern Table changes.
- No first-week polish continuation.
- No Runout taxonomy cloning.
- No broad content expansion.
- No fake AI, adaptive, or mastery claims.
- No generated outputs committed.
- No route or Profile-owner change; Profile remains a mirror.

## 10. Smallest later implementation candidate

`Cross-Family Mastery Owner Boundary v1`

This is selected because Act0 and W5/W6 currently have split ownership. Its
scope must be an owner/spec boundary first: retained session-drill resolution,
exact target-answer result, canonical atom mapping, and a proof that no route
launch/back-out causes mutation. It must not add a tier UI, scheduler, or
cross-family aggregator before those contracts exist.

## 11. Acceptance criteria for the later tiny slice

The selected bridge contract/implementation must prove all of the following:

1. **Promotion after exact proof threshold:** a clean repair plus the approved
   exact recheck/prove evidence creates only the documented next eligibility;
   it does not skip directly to `Speed`.
2. **Downgrade after same-signal miss:** a correct source identity is retained,
   repair reopens, and a tier/eligibility result returns to `Learn`.
3. **Stable no-op on route continuation:** normal continuation does not change
   receipt resolution or tier eligibility without a recorded answer outcome.
4. **No mutation from launch/back-out alone:** CTA tap, launch, target view,
   invalid fallback, and back-out preserve the open receipt/tier state.
5. **Home priority preserved:** open repair still outranks aged recheck, which
   outranks owned/prove candidate, which outranks route continuation.
6. **Review ownership preserved:** Review continues to own repair/recheck
   continuation and queue presentation; it is not a state store.
7. **Profile remains mirror, not state owner:** Profile can render derived
   focus/proof only and cannot promote, downgrade, or resolve evidence.

## Evidence consulted

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `docs/_reviews/w6_recheck_resolution_policy_audit_v1.md`
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`
- `docs/content/CONTENT_SYSTEM_v2.1.md`

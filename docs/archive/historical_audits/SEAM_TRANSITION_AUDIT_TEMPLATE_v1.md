# SEAM TRANSITION AUDIT TEMPLATE v1

Status: TEMPLATE
Owner: Content + Product QA

## Purpose

Use this template to decide whether transition World N -> World N+1 is
`bridge-playable` or `release-playable`.

This template is mandatory under:

- `docs/plan/MASTER_PLAN_v3.0.md` -> `Transition Readiness Governance (Permanent)`

## Audit Metadata

- Audit date:
- Auditor:
- Seam:
- Previous world id:
- Next world id:
- Version or commit ref:
- Scope note:

## Evidence Index (Required)

List concrete pointers before scoring.

- Lesson cards reviewed:
- Runner ids reviewed:
- Test cases reviewed:
- User confusion/QA tickets (if any):

## Gate 1: Concept Bridge

Question:

Does World N explicitly frame the mental model of World N+1 in recap/exit copy?

- Verdict: `PASS` / `FAIL`
- Evidence:
- Gap note (if fail):

## Gate 2: Decision Exposure

Question:

Does World N include at least 2 true decision drills (not only recognition taps)?

- Verdict: `PASS` / `FAIL`
- Count of decision drills:
- Evidence:
- Gap note (if fail):

## Gate 3: Contrast Exposure

Question:

Is there at least one mirrored contrast where learner sees playable line vs
sharper disciplined line?

- Verdict: `PASS` / `FAIL`
- Evidence:
- Gap note (if fail):

## Gate 4: Suboptimal Literacy

Question:

Is there at least one non-punitive suboptimal option with clear explanation:
"playable, but sharper line exists"?

- Verdict: `PASS` / `FAIL`
- Evidence:
- Gap note (if fail):

## Gate 5: Vocabulary Handoff

Question:

Are key terms used in first two lessons of World N+1 pre-introduced or bridged
in World N?

- Verdict: `PASS` / `FAIL`
- Evidence:
- Gap note (if fail):

## Gate 6: Emotional Safety

Question:

Do early tasks in World N+1 avoid unstated abstractions and avoid punishing
reasonable novice logic?

- Verdict: `PASS` / `FAIL`
- Evidence:
- Gap note (if fail):

## Gate 7: Regression Lock

Question:

Do targeted tests exist that would fail if this seam regresses?

- Verdict: `PASS` / `FAIL`
- Evidence:
- Gap note (if fail):

## Gate 8: Gap Closure Protocol Compliance

Question:

If a seam gap was found, are all closure artifacts present:

1. bounded content patch,
2. regression test update,
3. master-plan trace?

- Verdict: `PASS` / `FAIL` / `N/A`
- Evidence:
- Gap note (if fail):

## Final Decision

Rules:

- `release-playable` only if Gates 1..7 are all `PASS` and Gate 8 is `PASS` or `N/A`.
- Otherwise: `bridge-playable`.

- Final seam verdict:
- Blocking reasons (if not release-playable):
- Required fix wave:
- Target re-audit date:

## Sign-off

- Content owner:
- Product owner:
- QA owner:

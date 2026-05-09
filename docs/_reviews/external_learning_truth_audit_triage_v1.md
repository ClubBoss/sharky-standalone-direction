# External Learning Truth Audit Triage v1

## 1) Purpose
Preserve and rank the externally reported Learning Truth & Feedback findings into bounded issue classes for future weakest-link selection, without forcing immediate broad implementation.

## 2) Source summary of the external audit
External findings provided in chat context identified recurring instructional-truth risks:
- prompt leakage families,
- contradictory primary-correct feedback strings,
- irrelevant generic `why_v1` strings,
- TODO/placeholder leakage in user-visible instructional/session content,
- duplicated onboarding / binding candidates,
- misleading Top leak for non-strategic sessions.

This document is a triage anchor, not an implementation mandate.

## 3) P0 do-now issue classes
P0 classes are immediate trust/blocker risks if confirmed in active user-visible paths:
1. Contradictory primary-correct feedback strings that invert correctness meaning.
2. Prompt leakage patterns that directly reveal the required action in graded flows.
3. TODO/placeholder leakage present in user-visible instructional/session content.

## 4) P1 verify-then-fix issue classes
P1 classes require bounded verification and severity confirmation before code/content changes:
1. Irrelevant generic `why_v1` strings that are non-empty but instructionally low-signal.
2. Misleading Top leak labels in non-strategic sessions where leak framing is not pedagogically valid.
3. Duplicated onboarding/binding candidates that may create redundant or confusing first-run paths.

## 5) P2 backlog issue classes
P2 classes are quality debt to defer unless promoted by future weakest-link analysis:
1. Broader explanation tone consistency harmonization.
2. Non-critical copy normalization across older sessions.
3. Optional taxonomy cleanups for leak naming consistency where user impact is low.

## 6) Separation by execution surface
### A) Tooling guard candidates
- Deterministic validator fences for prompt/action leakage classes.
- Deterministic validator fences for contradictory feedback label patterns.
- Deterministic placeholder/TODO leakage checks in user-visible fields.

### B) Content cleanup batch candidates
- Batched prompt rewrites only for rows that violate guard contracts.
- Batched `why_v1` replacement for irrelevant/generic lines once bounded criteria are approved.
- Targeted onboarding/binding dedup cleanup once canonical path is selected.

### C) Runtime presentation candidates
- Runtime guardrails for when/where “Top leak” is shown to avoid non-strategic misuse.
- Session-result phrasing adjustments tied to validated truth rules.
- No broad runtime UX expansion without separate weakest-link selection.

## 7) Anti-drift note
This triage is a deferred evidence source, not an automatic implementation mandate.
Future implementation must still pass evidence-first weakest-link selection and remain bounded to one slice at a time.

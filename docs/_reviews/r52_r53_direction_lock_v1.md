# R52 R53 Direction Lock v1

## 1) Narrowed A-candidate (learning-truth/content-integrity)
- Candidate family: **narrow prompt-leak template** `in this <...> spot, choose <action>`.
- Why this A is bounded:
  - explicitly identified in R41 as a separate narrow family,
  - deterministic to detect with validator regex extension,
  - low expected cleanup size and one-family execution path.
- Implementation-ready shape (if selected):
  - extend prompt-leak guard for this exact template,
  - run targeted content cleanup only for violating rows,
  - add fail-on-violation/pass-on-valid guard contracts.

## 2) Narrowed B-candidate (personalization/profile EV)
- Candidate family: **intake-profile typed-signal normalization** in adaptive routing fallback.
- Why this B is bounded:
  - stays inside existing intake-profile fallback layer introduced/extended in R46-R50,
  - deterministic coercion/fallback rules over existing signals only (`focusLabel`, `placementScore`, `skillBand`),
  - no scoring/UI/schema expansion.
- Implementation-ready shape (if selected):
  - add bounded coercion for string/numeric representations of existing fields,
  - preserve null-fallthrough on unusable values,
  - add targeted deterministic contracts for precedence safety and stable repeatability.

## 3) Evidence basis
- `docs/_reviews/r51_post_r50_decision_lock_v1.md`
- `docs/_reviews/external_learning_truth_audit_triage_v1.md`
- `docs/_reviews/r39_external_audit_execution_verdict_v1.md`
- `docs/_reviews/r40_learning_truth_closeout_audit_v1.md`
- `docs/_reviews/r41_learning_truth_closeout_audit_v1.md`
- `docs/_reviews/r42_learning_truth_closeout_audit_v1.md`
- `docs/_reviews/r43_runtime_trust_closeout_audit_v1.md`
- `docs/_reviews/r44_runtime_trust_closeout_audit_v1.md`
- `docs/_reviews/r45_onboarding_binding_closeout_audit_v1.md`
- `docs/_reviews/r46_personalization_closeout_audit_v1.md`
- `docs/_reviews/r47_personalization_closeout_audit_v1.md`
- `docs/_reviews/r48_personalization_closeout_audit_v1.md`
- `docs/_reviews/r49_personalization_closeout_audit_v1.md`
- `docs/_reviews/r50_personalization_closeout_audit_v1.md`
- `docs/ROADMAP_FINAL_100_SSOT.md`

## 4) Explicit comparison (A vs B)

| Dimension | A: narrow prompt-leak template | B: intake-profile typed-signal normalization |
|---|---|---|
| Current completeness / good-enough state | R41 already removed larger prompt family; this residual family appears small and partially de-risked. | R46-R50 routing stack is strong; typed-value normalization remains an explicit residual gap class after malformed-payload hardening. |
| Local EV | Medium | High |
| System EV | Medium | High |
| Strategic EV | Medium | High |
| Scope-explosion risk | Low-Medium | Low |
| Evidence confidence | Medium | Medium-High |
| Implementation readiness | High | High |

## 5) Exact verdict
- Verdict: **B wins**.
- Why B wins:
  - higher system-level impact on deterministic adaptive routing continuity,
  - directly extends the fresh R46-R50 chain with one bounded family,
  - lower sprawl than reopening another content guard/cleanup cycle,
  - implementation surface and contracts are already concentrated in one routing/test area.

## 6) Exact R53 direction lock
- R53 locked direction: **one-family deterministic personalization refinement**.
- Exact target class:
  - implement intake-profile typed-signal normalization in adaptive routing fallback using existing signals/contracts only.
- Required contract boundaries:
  - preserve higher-priority routing layers unchanged,
  - coerce only bounded existing intake fields,
  - keep deterministic null-fallthrough for unusable values,
  - prove stable identical output under identical input/time state.

## 7) Anti-drift note
- R53 is locked to one family only (personalization routing fallback normalization).
- Do not combine with learning-truth content cleanup, runtime trust wording, onboarding, weighted scoring, profile UI, schema redesign, or ML.
- If bounded coercion rules cannot be stated clearly, STOP as bounded NO-GO rather than widening scope.

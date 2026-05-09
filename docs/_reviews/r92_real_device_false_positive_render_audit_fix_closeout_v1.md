# R92 Real-Device False-Positive Render Audit/Fix Closeout v1

## Purpose and bounded scope
- Audit the real-device portrait mismatch on `world1_act0_table_literacy`.
- Keep scope bounded to covered concept-first steps `0-1` on the authoritative runner seam.

## PIEC summary
- Reconciled:
  - `docs/_reviews/r91_covered_host_visible_smart_learning_render_audit_fix_closeout_v1.md`
  - `docs/_reviews/r87_world1_concept_first_gold_cluster_closeout_v1.md`
  - `docs/_reviews/r86_world1_concept_first_gold_micro_slice_closeout_v1.md`
  - `docs/_reviews/r83_gold_learning_authoring_contract_v1.md`
- Confirmed live-evidence target:
  - host: `world1_act0_table_literacy`
  - covered step index: `0`
  - secondary covered confirmation: step `1`
  - anti-leak control: step `2`
  - resolved mode: `seat_quiz`

## Exact root cause
- Host matching was already correct.
- Covered-step matching was already correct.
- Covered concept-first branch activation was already correct.
- The false positive was caused by compact portrait composition:
  - `_buildRunnerCompactHeaderV1(...)` did build the concept-first prelude
  - but the compact portrait top panel still reserved only a near one-row height
  - the prelude therefore existed in the widget tree while sitting below the clipped visible compact-header viewport
- Why R91 looked closed:
  - R91 asserted widget-tree presence and legacy prompt suppression
  - it did not assert that the prelude itself fit inside the visible compact-header viewport on the real portrait path

## Fix
- Reserved explicit compact-header height for covered concept-first steps so setup, `Why it matters:`, and `Notice:` remain visibly inside the portrait header.
- Strengthened the targeted portrait contract to assert visible in-viewport rendering, not only tree existence.
- Preserved uncovered step `2` legacy behavior.

## Final authoritative render truth
- On `world1_act0_table_literacy` covered steps `0-1`:
  - the concept-first smart-learning prelude is visibly present on the real compact portrait path
  - setup/context, `Why it matters:`, and `Notice:` are inside the visible compact header
  - the legacy seat-drill prompt is not the sole dominant teaching block
- On uncovered adjacent step `2`:
  - the concept-first prelude is absent
  - the legacy seat-drill prompt remains active

## Runtime fix vs proof-only
- Runtime fix was needed.
- The change stayed bounded to the authoritative runner seam plus the minimum targeted contract and closeout note.

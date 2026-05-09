# R91 Covered-Host Visible Smart-Learning Render Audit/Fix Closeout v1

## Purpose and bounded scope
- Audit the real first-user host render path on `world1_act0_table_literacy`.
- Keep scope bounded to covered concept-first steps `0-1` on the authoritative runner seam.

## PIEC summary
- Reconciled:
  - `docs/_reviews/r90_post_topology_fix_visible_path_verification_closeout_v1.md`
  - `docs/_reviews/r87_world1_concept_first_gold_cluster_closeout_v1.md`
  - `docs/_reviews/r86_world1_concept_first_gold_micro_slice_closeout_v1.md`
  - `docs/_reviews/r83_gold_learning_authoring_contract_v1.md`
- Confirmed intended covered host and steps:
  - host: `world1_act0_table_literacy`
  - covered step indexes: `0-1`
  - adjacent uncovered step: `2`

## Root cause
- Host matching was already correct.
- Covered-step matching was already correct.
- The remaining issue was a portrait compact-header false positive:
  - concept-first framing existed behind `_showConceptFirstSeatPreludeCardV1`
  - portrait campaign-spine uses `_buildRunnerCompactHeaderV1(...)`
  - that path now built the concept-first prelude card
  - but the compact portrait top-panel height still stayed near one-row size
  - so the prelude could exist in the widget tree while sitting below the clipped visible header viewport
- Result:
  - R91 tree-presence contracts could pass
  - real device portrait step `0` still showed only the legacy visible teaching surface

## Fix
- Reserved explicit compact-header height for covered concept-first steps so the full prelude is visible without scrolling or clipping.
- Strengthened the targeted portrait contract to assert visible in-viewport dominance, not only widget-tree existence.
- Preserved legacy prompt behavior for adjacent uncovered step `2` and all other paths.

## Final authoritative render truth
- On `world1_act0_table_literacy` covered steps `0-1`:
  - visible dominant teaching surface is the concept-first smart-learning block
  - it includes:
    - setup/context
    - `Why it matters:`
    - `Notice:`
  - legacy on-table seat-drill prompt is suppressed
- On adjacent uncovered step `2`:
  - concept-first smart-learning block is absent
  - legacy seat-drill prompt remains active

## Runtime fix vs proof-only
- Runtime fix was needed.
- Fix remained bounded to the authoritative runner seam and this exact covered host/step set only.

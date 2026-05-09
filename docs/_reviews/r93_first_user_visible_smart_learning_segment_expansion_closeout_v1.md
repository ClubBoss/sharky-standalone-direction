# R93 First-User Visible Smart-Learning Segment Expansion Closeout v1

## Purpose and bounded scope
- Expand the first-user visible smart-learning segment on `world1_act0_table_literacy`.
- Keep scope bounded to the authoritative runner seam and this host only.

## PIEC summary
- Reconciled:
  - `docs/_reviews/r92_real_device_false_positive_render_audit_fix_closeout_v1.md`
  - `docs/_reviews/r91_covered_host_visible_smart_learning_render_audit_fix_closeout_v1.md`
  - `docs/_reviews/r87_world1_concept_first_gold_cluster_closeout_v1.md`
  - `docs/_reviews/r83_gold_learning_authoring_contract_v1.md`
- Selected improvement:
  - extend the visible concept-first segment from covered steps `0-1` to covered steps `0-2` on `world1_act0_table_literacy`
  - derive low-density step-2 copy from existing step truth instead of widening authoring or other hosts

## Why this was chosen
- Step `2` is the immediate adjacent Big Blind completion step in the same first-user seat-map segment.
- Extending one more step creates a clearly more noticeable early learning run without spreading to another host.
- This keeps the table first and avoids adding heavier top or bottom teaching chrome.

## What changed
- Extended the concept-first seat cluster to include step `2`.
- Added derived fallback setup/why/reinforce lines for blind-pair completion when step `2` lacks authored concept fields.
- Preserved the same compact portrait visibility safeguards from R92.

## Final user-visible lift
- On `world1_act0_table_literacy` steps `0-2`, the first-user segment now reads as one coherent seat-orientation mini-run:
  - understand the seat concept
  - why it matters
  - notice the target
  - act
  - receive compact reinforcement
- Step `2` now visibly completes the blind-pair idea instead of dropping back to the older seat-drill feel immediately after step `1`.

## Runtime fix vs proof-only
- Runtime fix was needed.
- The change stayed bounded to the runner seam, the targeted contract, and this closeout note.

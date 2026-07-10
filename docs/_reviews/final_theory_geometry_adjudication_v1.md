# Final Theory Geometry Adjudication and Identity Seam v1

## 1. Terminal verdict

Select **A**: corrected T1 is the default spatial-table geometry for theory
and the complete task loop. There is one spatial geometry, not two. The
evidence shows the original defect is the tall under-occupied theory panel;
after removing that reserve, T2-92 has no material capacity or readability
advantage that justifies a separate geometry.

Production-pilot admission remains **no** because target learner identity is
only represented by a prototype-only overlay; the current production scene has
no implemented identity-policy seam.

## 2. Owner screenshot finding

The owner-supplied finding in the active addendum is accepted as the visual
control: large table, tall fixed theory block, short top-aligned copy, and
controls pinned far below it. The raw screenshot was not available as a
readable local image to copy into this evidence folder. The comparison therefore
uses it by explicit owner-described defect class, alongside the local fixed-slot
reference rather than claiming a pixel-for-pixel owner-image measurement.

## 3. Fixed-slot defect equivalence

The local fixed-slot reference is the same defect class: 248px panel height,
108px body-to-footer gap, and 66.1% occupancy. The owner description likewise
identifies a large empty internal band caused by a tall reserve with short,
top-aligned content and a distant footer. The equivalence is architectural and
visual, but not a raw-raster equivalence because the owner image is unavailable.

## 4. Corrected T1 assessment

Corrected T1 holds the largest exact production table: 344px wide by 597.22px
high. Its content-sized theory panel is 162px high, has an 18px body-to-footer
gap, 83.3% visible-content occupancy, no scroll, no overflow, and a reachable
Continue CTA. It removes the fixed-slot defect without a table reduction.

## 5. T2-92 assessment

T2-92 uses the same corrected 162px panel, the same 18px gap, and the same
83.3% occupancy. Its table is 316.48px wide by 549.44px high. It neither gains
additional authored theory capacity nor improves panel separation; it merely
creates a deliberate smaller table and a small inter-region gap. It remains
legible but gives up the strongest production-table readability.

## 6. Identity seam comparison

The local prototype wrapper compares the exact scene's current `You` + `BTN
Hero` + dealer-disc treatment with target display forms:

- position-relevant: `You · BTN`, no learner-facing Hero, dealer disc removed;
- dealer order: `You · BTN` plus one visible dealer disc;
- non-position: `You`, with the redundant disc visually suppressed.

The wrapper changes no table bounds or panel metrics, so identity cleanup does
not alter the T1/T2 outcome. It is not a production implementation: the
public scene currently does not consume `Act0TableIdentityPolicyV1` to replace
the underlying identity/disc widgets. The overlay therefore proves comparison
scope only and records the exact production seam still needed.

## 7. Final T1/T2 decision

T1 wins. Final adjudication scores: **T1 9.0 / 10**, **T2-92 8.0 / 10**.
T1 wins on readable table scale, reuse of the full task-loop scene, no extra
geometry/boundary, and equal corrected panel quality. T2-92 has no material
advantage after the occupancy correction or the identity comparison.

## 8. Number of final spatial geometries

**One.** `tableLesson` uses the exact full locked spatial geometry for spatial
theory, decision, feedback, repair, View table, repair result, and recheck.
`information` remains table-free by default. A new hand can change semantic
table state but does not select a smaller geometry preset.

## 9. Updated complete state system

```text
information: no full table
tableLesson: one full locked table
  theory: content-sized static panel, no handle/scroll
  practice: compact | standard | expanded | peek teaching sheet
  expanded repair only: conditional evidence header if actual critical bounds cross
```

There is no theory→decision table resize. The only legitimate table change is a
new hand/context, which changes source truth rather than creating a presentation
preset.

## 10. Any superseded conclusions

The earlier two-geometry recommendation in
`complete_table_presentation_state_machine_v1.md` is superseded for spatial
theory. Its task-loop continuity, information family, panel/sheet ownership,
critical-evidence, and content-guard conclusions remain valid. T2-88/90 are
closed; T2-92 is rejected as an unnecessary second geometry.

## 11. Production-pilot admission decision

**No.** A production pilot must not use a visual overlay to conceal a live
identity widget. The next admitted implementation must first own the identity
contract in the production scene/config and prove it does not regress seat,
dealer-order, W9, feedback-clue, or progress-scope behavior.

## 12. Exact bounded pilot scope if admitted

Not admitted in this wave. After a separate explicit prompt admits it, scope is
one production-owned identity/config seam and one `tableLesson` theory/decision
family only: wire `You · BTN`, suppress the dealer disc except dealer-order
truth, replace the fixed theory reserve with the content-sized panel contract,
and retain the exact full table across theory→decision→feedback→repair→recheck.

## 13. Exact non-scope

No canonical UI migration, route change, feedbackEvidence renderer, motion,
telemetry, new dependency, generic bottom-sheet system, persistence, tablet or
landscape work, Human QA, public readiness, or push.

## 14. Evidence paths

- [Adjudication evidence](/Users/elmarsalimzade/Sharky_1.0/output/prototypes/final_theory_geometry_adjudication_v1)
- [T1 vs T2 identity comparison](/Users/elmarsalimzade/Sharky_1.0/output/prototypes/final_theory_geometry_adjudication_v1/final_t1_vs_t2_contact_sheet.png)
- [Identity comparison](/Users/elmarsalimzade/Sharky_1.0/output/prototypes/final_theory_geometry_adjudication_v1/identity_contact_sheet.png)
- [Shared metrics](/Users/elmarsalimzade/Sharky_1.0/output/prototypes/final_theory_geometry_adjudication_v1/geometry_metrics.json)
- [Corrected prototype evidence](/Users/elmarsalimzade/Sharky_1.0/output/prototypes/complete_table_system_v1)

## 15. Validation

The complete table-system prototype test passes after the identity comparison
addition, with deterministic repeated renders. Analyzer passes for the touched
harness. Focused feedback clue, W9/table-context, and progress-scope guards
remain required final regression checks before commit.

## 16. Non-claims

This adjudicates a local prototype architecture only. It does not claim a
production identity change, a finished theory panel in the canonical route,
learner preference, accessibility certification, learning effect, premium
quality score, Human QA result, or launch readiness.

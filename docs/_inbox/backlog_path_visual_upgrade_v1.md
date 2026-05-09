# Path Visual Upgrade Backlog v1

Status: DEFERRED (not in current sprint)

## Why Deferred
- Scope control: current sprint focus is runner stability, tooling proofs, and deterministic progression improvements.
- Avoid visual churn on the Path/Map while multiple adjacent systems are still settling.
- Keep guards stable and reduce risk of regressions in map contract tests and store-assets proofs.

## Visual References
- Ref A: Academy map (progress bar + big title + start-here emphasis)
- Ref B: PLAY/TRAIN map (dual modality nodes + CTA bubbles)

## Borrow List (Actionable)
- Dual modality nodes: PLAY vs TRAIN -> future Path 2.0 L vs D.
- Strong NEXT emphasis via on-node bubble to reduce reliance on pinned START NOW later.
- Simplified header: 1 progress bar + 1-2 metrics; move the rest to Details.
- Clear node states DONE/LOCKED/NEXT by shape and color with subtle glow.
- Cleaner connector rhythm (spacing + curve) to avoid clutter.

## Avoid List
- Heavy blur or glow effects that risk perf or determinism.
- Header metric overload.
- Stars or ratings everywhere before the scoring model is stable.

## Future DoD (Measurable)
- Map is canvas-first (70-85% height dedicated to path/canvas content).
- NEXT node dominates and is unambiguous.
- One primary CTA flow (on-node bubble OR pinned CTA, not both competing).
- No overflows on narrow widths (store-assets safe).

## Constraints When Activated
- No progression logic changes in v1.
- Keep guards green; store-assets proofs are mandatory.

## Activation Trigger
- After Path 2.0 scheduling.
- After current stability milestones are complete.

## Planned Execution (Future Clusters)
- Cluster 1: header simplification and layout compaction.
- Cluster 2: node visuals and connector rhythm refresh.
- Cluster 3: PLAY/TRAIN modality layer (L/D).

# Audit Buckets

This folder holds active audit evidence and closeout records that are still useful, but are not part of the primary SSOT chain by default.

## Structure

- `investigations/`
  - bounded seam audits
  - policy investigations
  - reconciliation passes
- `closeouts/`
  - bounded closure checkpoints
  - completed audit follow-ups

## Scope Rule

Keep documents here when they answer:
- what was investigated
- what was proven
- what was intentionally deferred
- what layer should be worked next

Move documents back into an SSOT folder only if they become governing product or execution truth.

Placement and authority rules are defined in [docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md).

## Historical Audit Stream

The older review stream remains in `docs/_reviews/`.
Keep using it for historical traceability, not as the active execution entrypoint.

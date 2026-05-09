# content/_generated

Bucket type: `GENERATED / LOCAL`

Purpose:
- Stores generated content artifacts produced by tooling.
- Not hand-authored source content; regenerate from tools when needed.

Known generated path(s)
- `content/_generated/drills/v1/drills.jsonl`

Tooling evidence (writes/uses generated drills)
- `tools/reinforcement_drill_generator.dart`
- `tools/drill_refinement_normalizer.dart`

Policy:
- Do not treat this folder as canonical authored content.
- See `docs/governance/ARCHIVE_POLICY_v1.md`.

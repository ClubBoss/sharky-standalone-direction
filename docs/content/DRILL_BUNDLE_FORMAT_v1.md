# Drill Bundle Format v1

Use strict ASCII text with LF newlines.

## Session delimiter
- `=== SESSION <id> ===`

## Blocks inside each SESSION
- `--- drills/index.md ---` (required, exactly one)
- `--- drills/d.<drillId>.json ---` (repeatable, one per listed drill)

## Rules
- Exact delimiters and headers only.
- ASCII-only content.
- LF-only newlines.
- No trailing spaces.
- No extra blocks.
- Session ids must exist in `content/_meta/world_sessions_manifest_v1.json`.
- Drill ids listed in `drills/index.md` must match provided JSON drill blocks.

## Templates
- Template index (authoring references): `../../content/_templates/README.md`
- Quiz/checkpoint style references often paired with drill production:
  - `../../content/_templates/quiz_template_v1.jsonl`
  - `../../content/_templates/checkpoint_template_v1.md`

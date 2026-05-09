# Session Bundle Format v1

Use a UTF-8 text file with one or more session sections.

## Session delimiter
- `=== SESSION <id> ===`

## Required file blocks (exact headers)
- `--- session.md ---`
- `--- notes.md ---`
- `--- drills/index.md ---`

## Rules
- Session ids must already exist in `content/_meta/world_sessions_manifest_v1.json`.
- Unknown session ids are rejected.
- Each session section must include all three file blocks exactly once.
- Unknown file blocks are rejected.
- Duplicate session sections are rejected.

## Templates
- Template index (authoring references): `../../content/_templates/README.md`
- Common supporting templates:
  - `../../content/_templates/checkpoint_template_v1.md`
  - `../../content/_templates/recap_template_v1.md`

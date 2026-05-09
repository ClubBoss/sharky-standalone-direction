# Archive Policy v1

Repository-wide policy for classifying historical material without deleting files.

## 1) Definitions

### DEPRECATED
Superseded SSOT/process/spec documents retained for traceability.

Rules:
- Not authoritative for current execution.
- Must keep a replacement pointer (or explicit note if none exists yet).
- Prefer deprecation banners in-file.

### SNAPSHOT
Frozen stop points, evidence captures, phase completion artifacts, and dated/versioned exports kept as point-in-time records.

Rules:
- Treat as immutable historical records.
- Prefer explicit version/date in name.
- Reference from an index so readers know what is current.

### REFERENCE / GOVERNANCE
Useful governance, phase planning, audits, and historical materials that may guide decisions but are not the active SSOT chain unless explicitly promoted.

Rules:
- Can be consulted for context.
- Must not override `docs/README_SSOT.md`.
- Should link to current SSOT when relevant.

### GENERATED / LOCAL
Generated outputs and local work artifacts (reports, screenshots, bundles, exports).

Rules:
- Default assumption: local/ephemeral.
- Commit only if explicitly whitelisted and reviewed.
- Track exceptions in local bucket README/index (for example `out/README.md`).

## 2) Canonical Locations

- `docs/_archive/` = DEPRECATED docs (superseded docs retained with history value).
- `docs/archive/` = SNAPSHOTS (phase stop points / frozen records).
- `docs/canonical/` + `docs/reference/master_plan_6/` = REFERENCE / GOVERNANCE (non-active unless promoted in `docs/README_SSOT.md`).
- `out/` = GENERATED / LOCAL (with tracked exceptions documented in `out/README.md`).

Related archive-like buckets outside docs:
- `.github/_workflows_archive/` = deprecated/disabled workflow snapshots (REFERENCE/DEPRECATED operational history).
- `release/_archives/` = release-related historical outputs/snapshots.
- `content/_legacy_archive/` = legacy content snapshots/reference material.
- `archive/` = non-doc historical bucket (project-specific; classify per local index/README if used).
- `out/store_assets/archive/` = generated snapshot/archive sub-bucket under `out/` (still `GENERATED/LOCAL` unless explicitly promoted).

## 3) Rules of Operation

### Move / rename safety
- Never delete historical material as part of cleanup.
- Move only with an index entry + backlink/replacement note.
- Rename only with backlinks (old path referenced from index/changelog/readme).

### Index requirement
- Every archive bucket must have an index file (`README.md` or `INDEX.md`) describing:
  - bucket type (`DEPRECATED`, `SNAPSHOT`, `REFERENCE`, `GENERATED/LOCAL`)
  - scope
  - whether contents are authoritative
  - where current guidance lives

### SSOT precedence
- `docs/README_SSOT.md` defines the active SSOT chain.
- Archive/reference buckets must not claim active authority unless explicitly promoted there.

## 4) Gem Extraction Rule (Zero-loss)

When a historical/governance document contains useful content:

1. Extract the reusable idea into an active SSOT appendix (or `docs/deferred_backlog.md` if not ready).
2. Preserve source trace:
   - original path
   - section heading
   - short summary of what was extracted
3. Keep the original archived/reference file in place (no deletion).

Recommended destinations:
- Active SSOT appendix in the relevant document (`MASTER_PLAN`, `ULA`, `CONTENT_SYSTEM`, `CONTENT_PLAN_PER_WORLD`)
- `docs/deferred_backlog.md` for deferred “gem mining” items

## 5) Minimal Enforcement Checklist (for future PRs)

- Classify each historical artifact before touching it.
- Add/update bucket index entries.
- Keep backlinks/replacement paths.
- Do not move tracked outputs in `out/` without an explicit exception decision.

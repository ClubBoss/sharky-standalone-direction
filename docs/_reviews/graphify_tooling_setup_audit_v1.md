# Graphify Tooling Setup Audit v1

## Scope

Audit and minimally stabilize the repository Graphify setup.

No product code, UI, gameplay, Review, repair logic, Modern Table, content,
glossary, telemetry, monetization, AI/persona, dashboard, XP, or economy code
changed.

## Files inspected

- `AGENTS.md`
- `CLAUDE.md`
- `.github/copilot-instructions.md`
- `.codex/hooks.json`
- `.claude/settings.json`
- `.gitignore`
- local generated `graphify-out/`
- local generated `output/graphify-out/` ignore behavior

## Graphify availability

Graphify is installed and available on this machine:

- command: `/Library/Frameworks/Python.framework/Versions/3.12/bin/graphify`
- version: `graphify 0.8.44`

`graphify --version` is supported.

## Hook/check result

`graphify hook-check` is the canonical lightweight validation check for this
repo setup. It returned exit code `0`.

The Codex hook uses a portable command:

`graphify hook-check`

## Generated-output handling

`graphify-out/` was already ignored. This audit added a targeted ignore entry
for:

- `output/graphify-out/`

No generated graph output was staged or committed.

## Instruction safety result

Instruction files now describe Graphify as advisory navigation and dependency
safety tooling. They explicitly say Graphify must not override:

- active SSOT docs;
- roadmap decisions;
- product scope;
- user instructions.

They also direct agents to use `graphify hook-check` as lightweight validation
and reserve full graph refreshes for explicit freshness needs or tasks that
require them.

The audit found no secrets or credentials in the inspected instruction files.
The previous tracked absolute local repository path in `AGENTS.md` was replaced
with a checkout-relative root statement.

## Fixes made

- Added `.gitignore` coverage for `output/graphify-out/`.
- Clarified Graphify is advisory/tooling only in `AGENTS.md`, `CLAUDE.md`, and
  `.github/copilot-instructions.md`.
- Replaced unconditional full `graphify update .` guidance with lightweight
  `graphify hook-check` guidance and explicit full-refresh gating.
- Clarified generated graph output must not be committed.
- Removed the absolute local root path from `AGENTS.md`.

## What was intentionally not changed

- No `.codex/hooks.json` change was needed.
- No `.claude/settings.json` change was needed.
- No full graph generation was run.
- No generated graph output was committed.
- No product, content, telemetry, route, Modern Table, or UI files changed.

## Remaining limitations

`graphify-out/` can still be stale if the full graph refresh has not run after
large code movement. That is acceptable for this setup because Graphify is
advisory and the lightweight hook check is the release-safe validation path.

## Recommended future use

- Use `graphify query`, `graphify explain`, or `graphify path` for scoped repo
  orientation when `graphify-out/graph.json` exists.
- Use `graphify hook-check` for quick validation.
- Run full graph refresh only when graph freshness is materially needed.
- Never commit generated graph output.

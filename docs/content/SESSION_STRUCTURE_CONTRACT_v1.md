# Session Structure Contract v1

This contract defines the minimal semantic structure required in every `session.md`.

## Required headings (exact, case-sensitive)
- `# Session <id>`
- `## Objective`
- `## Scenario`
- `## Decision`
- `## Explanation`

## Rules
- Required headings must appear exactly once.
- Required headings must appear in the exact order listed above.
- No additional required sections exist in v1.

## Rationale
- Keeps session content structurally consistent for batch generation, committee QA, and deterministic validation before runtime integration.

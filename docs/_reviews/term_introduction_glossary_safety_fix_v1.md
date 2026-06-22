# Term Introduction / Glossary Safety Fix v1

## Scope

Bounded learner-content safety work only. No product UI, routes, telemetry, drill
coverage, monetization, or screenshot tooling changed.

## Contract

`content/_meta/term_introduction_contract_v1.json` owns the six priority
learner-facing terms and their first safe session source:

- `EQUITY`: W1 s05
- `PROBE`: W4 s02
- `BLOCKERS`: W4 s03
- `SPR`: W7 s02
- `EV`: W8 s02
- `EXPLOIT`: W9 s01

Each source carries one short, plain-English definition before its first use.
The wording is intentionally small and local to the existing curriculum entry;
this wave adds no glossary UI or broader content pack.

## Scanner behavior

`dart run tools/term_coverage_scanner.dart` now scans active learner session
content under `content/worlds`, including the World 10 track-session paths. It
fails when a priority term is used in an earlier session or before its
definition inside the declared introduction source. It reports a passing
active-content check otherwise.

`PFA` and `DB` are quarantined as reference-only tokens. Their confirmed uses
are under `content/_reference`, which is outside the active learner-content
root. No learner-facing owner or safe definition was proven, so this wave does
not guess one or make them active scanner requirements.

## Tests and checks

- Focused scanner tests prove rejection of pre-introduction and before-definition
  uses, and acceptance of a declared introduction while ignoring reference-only
  content.
- The scanner passes against current active learner session content.
- Run the existing content integrity validation, formatter, analyzer, diff, and
  status checks before local commit.

## Remaining limits

The contract is deliberately limited to the six audited priority terms. It is a
first-use safety rail, not a full content glossary, localization layer, or
replacement for future term-ownership audits.

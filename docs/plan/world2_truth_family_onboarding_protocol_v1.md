# World 2 Truth Family Onboarding Protocol v1

Purpose:

- onboard World 2 truth families without building a generic platform
- keep truth-first discipline explicit
- make exclusions a first-class output

## Family Selection Criteria

- boundary is structurally deterministic from existing content
- truth can be derived from authored data, not UI/runtime behavior
- family is small enough for exact checked/skipped reporting
- validator can stay family-specific

## Supported Truth Shapes

| Truth shape | Definition | Current example |
| --- | --- | --- |
| exact-answer truth | answer derives from authored structured state and resolves to a single discrete choice | `position_thinking_choice_v1` |
| exact card-truth | answer derives directly from cards and resolves to a single outcome/count | `showdown_winner_choice_v1`, `outs_count_choice_v1` |
| bounded contract truth with exclusions | only a crisp subset of authored labels is enforceable; heuristic remainder is explicitly excluded | `board_texture_classifier_v1` |

## Minimum Onboarding Outputs

- canonical truth basis or contract doc
- family-specific validator/service
- one tool entrypoint
- one targeted test file
- registry entry update
- explicit exclusions policy with checked/skipped reasoning

## STOP Conditions

- heuristic-only semantics
- runtime or UI dependency
- fuzzy strategic truth
- broad platform or engine requirement
- inability to state deterministic exclusions

## Current Protocol-Proven Families

| Family | Truth shape | Status |
| --- | --- | --- |
| `showdown_winner_choice_v1` | exact card-truth | onboarded |
| `outs_count_choice_v1` | exact card-truth | onboarded |
| `board_texture_classifier_v1` | bounded contract truth with exclusions | partially onboarded |
| `position_thinking_choice_v1` | exact-answer truth | onboarded |
| `initiative_aggressor_choice_v1` | bounded contract truth with exclusions | partially onboarded |

# World 2 Board Texture Truth Contract v1

Scope:

- World 2 `board_texture_classifier_v1` only
- board-card truth only
- no action advice, pressure ranking, or strategy semantics

## Canonical Board Facts

| Fact | Definition |
| --- | --- |
| `paired` | at least two flop cards share the same rank |
| `rainbow` | all three flop cards have different suits |
| `two_tone` | exactly two flop cards share a suit |
| `monotone` | all three flop cards share a suit |
| `connected_run_3` | the three flop ranks are distinct and can be ordered into a three-card straight run; ace may count high or low |

## Supported `board_texture_v1` Mappings

| Authored label | Contract mapping | Status |
| --- | --- | --- |
| `paired` | `paired = true` | enforceable |
| `connected` | `connected_run_3 = true` | enforceable |
| `dry` | strategy/pressure shorthand, not a crisp board-shape fact by itself | excluded in v1 |

## Current World 2 Family Audit

| Drill | Authored label | Contract v1 status | Reason |
| --- | --- | --- | --- |
| `classify_paired_king_king_three_rainbow` | `paired` | enforceable now | paired flop is exact rank-shape truth |
| `classify_coordinated_jack_ten_nine_two_tone` | `connected` | enforceable now | J-T-9 is a distinct three-card straight run |
| `classify_dry_ace_seven_deuce_rainbow` | `dry` | explicitly excluded | `dry` is a heuristic texture/action concept, not a single crisp board-card fact |
| `review_texture_dry_board_stays_calmer` | `dry` | explicitly excluded | same reason as above; also review-style drill stays out of the enforced subset |

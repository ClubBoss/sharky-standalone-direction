# World 2 Showdown Validation Coverage Matrix v1

Bounded family only:

- Checked visible-card showdown drills:
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_hero_top_pair_showdown.json`
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_villain_straight_showdown.json`
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_board_plays_showdown.json`
  - `content/worlds/world2/v1/sessions/w2.s05/drills/d.review_showdown_hero_top_pair.json`

## Boundary Status

| Boundary | Members | Status | Covered / partial / excluded | Notes |
| --- | --- | --- | --- | --- |
| Saturated visible-card micro-family | `choose_hero_top_pair_showdown`, `choose_villain_straight_showdown`, `choose_board_plays_showdown` | semantically saturated checked subset | covered: winner truth, pair mislabels, board-pair naming, stronger-pair, generic underpair copy, straight copy, explicit generic two-pair copy, board-plays copy, explicit board-plays/tie semantics | Exact membership is enforced in validator report + targeted test; no further bounded contradiction family remains inside the current authored pilot corpus |
| Next audited showdown family boundary | Full World 2 `showdown_winner_choice_v1` family | explicit family boundary | covered: 4 visible-card drills | Review drill now carries the same visible-card payload seam as the core showdown bridge, so the full authored family is validator-covered |

## Adjacent Family Onboarding

| Family | Boundary | Coverage state | Checked / excluded | Current blind spot |
| --- | --- | --- | --- | --- |
| `outs_count_choice_v1` | Full World 2 `outs_count_choice_v1` family | onboarded with bounded validator | checked: `count_flush_draw_nine_outs`, `count_open_ended_straight_draw_eight_outs`, `count_gutshot_four_outs`; excluded: none | broader outs semantics such as combo draws, overcards, and non-canonical counts remain out of scope |

Enforced now for the outs family:

- exact family membership via validator report + targeted test
- expected outs truth (`4` / `8` / `9`)
- explicit copy contradictions for `flush draw`, `open-ended`, `gutshot`, and stated `X outs` wording

| Error class | Short example | Covered now | Where enforced now | Current blind spot / limitation | EV / priority | Recommended next bounded slice |
| --- | --- | --- | --- | --- | --- | --- |
| Showdown winner contradiction | `expected.actionId=hero` when visible cards make villain win | yes | `lib/services/world2_showdown_truth_validator_v1.dart`, `tools/validate_world2_showdown_truth_v1.dart`, corpus sweep test | Non-board tie outcomes still stop at `unsupportedTie` | high | Keep bounded to current family; do not generalize tie engine yet |
| Explicit pair-category mislabel | `Hero has top pair`, `Villain has second pair` | yes | validator pair-copy checks, targeted unit tests | Only phrases explicitly naming current pair labels are enforced | high | Add new labels only if current family authors them |
| Generic underpair contradiction | `Top pair beats an underpair here` when no visible hand is an underpair | yes | validator generic underpair copy check, targeted unit test | Still bounded to non-actor-qualified `underpair` wording only; no broader overpair/underpair taxonomy sweep | high | Extend only if current family authors more generic pair-family comparison copy |
| Board-pair naming contradiction | `top pair` on a paired board that is really two pair | yes | validator pair semantics + board-aware guard, targeted unit test | No broader made-hand copy taxonomy beyond pair-family terms | high | Only extend when bounded authored copy appears |
| Stronger-pair contradiction | `Hero wins with the stronger pair` when kicker decides | yes | validator stronger-pair check, targeted unit test | Still phrase-driven; no full kicker explanation engine | high | Keep phrase-driven unless corpus demands more |
| Explicit straight-copy contradiction | `Villain makes a straight` when visible cards do not | yes | validator straight-copy check, targeted unit test | Limited to explicit straight wording | high | Keep straight-only unless flush wording appears |
| Explicit generic two-pair contradiction | `Straight beats two pair`, `Hero only has two pair` when no visible hand is two pair | yes | validator two-pair copy check, targeted unit test | Still bounded to explicit `two pair` wording only; no trips/set taxonomy sweep | high | Extend only if current family authors more made-hand category copy |
| Board-best-straight contradiction | `The board already makes the best straight for both players` | yes | validator straight-copy check, targeted unit test | Board/tie wording outside straight-specific phrases is only partially explicit | high | Tighten split-pot / board-plays wording guard |
| Split-pot / board-plays-the-hand ambiguity | `both players tie`, `board plays`, `best hand for everyone` | yes | explicit board-plays contradiction checks plus positive board-plays semantics guard, targeted unit test | Still bounded to authored board-plays/tie wording; no broader tie engine | highest | Keep bounded to board-plays semantics only; do not generalize non-board tie handling |
| Flush-related contradiction | `Hero makes a flush` | no | none in current bounded family | No explicit flush wording in the visible-card showdown corpus | low | Stop until authored showdown copy exists |
| Full house / quads / higher made-hand contradiction | `Villain has a full house` | no | none in current bounded family | No authored pressure in this family; would broaden into generic hand taxonomy | low | Stop until authored showdown copy exists |
| Kicker-sensitive naming edge cases | `pair of queens` when actual pair rank differs | partial | pair-rank naming check, stronger-pair check, targeted tests | Only explicit `pair of <rank>` and `stronger pair` phrases are enforced | medium | Extend only if current family authors more kicker-specific copy |

## Saturation Note

- Current result:
  - the visible-card World 2 showdown pilot is semantically saturated for this hardening line
- Why:
  - the remaining SSOT-implied categories (`trips`, `set`, `flush`, and higher made-hand families) do not appear in the current authored pilot corpus
  - the remaining uncovered possibilities would require either new authored showdown copy pressure or a broader generic made-hand taxonomy sweep
- Operational rule:
  - stop this hardening line here until the pilot corpus adds new explicit semantic claims

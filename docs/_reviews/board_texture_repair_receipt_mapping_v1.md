# Board Texture Repair Receipt Mapping v1

- Branch: `main`
- Base after Part A push: `8301abd244a742943d4613f256aa786e172c9ec8`
- Scope: local-only service contract for W5 board-texture repair receipt mapping.

## Problem

The W6 range-bucket repair path had a receipt -> consumer -> launch queue seam, but W5 board-texture misses had no equivalent service-level mapping. The scaling audit selected board texture as the next candidate family because its authored W5 s01 drills already expose deterministic board texture, expected action, and error-class data.

## Mapping added

Only authored W5 s01 board texture classifier drills are supported:

| Source drill | Missed signal | Target drill | Target kind |
|---|---|---|---|
| `classify_texture_intro_dry_raise_v1` | `board_texture_dry` | `classify_texture_intro_dry_raise_v1` | `exact_replay` |
| `classify_texture_intro_wet_call_v1` | `board_texture_wet` | `classify_texture_intro_wet_call_v1` | `exact_replay` |
| `classify_texture_intro_paired_fold_v1` | `board_texture_paired` | `classify_texture_intro_paired_fold_v1` | `exact_replay` |

The mapper only creates a receipt candidate after a failed evaluated drill result. Correct and soft-pass actions do not create receipts.

## Service behavior

- `buildBoardTextureRepairReceiptCandidateV1` creates adapter-compatible receipt candidates for supported W5 board-texture misses.
- Session-drill receipt persistence now tries the existing W6 range-bucket mapper first, then the W5 board-texture mapper.
- `SessionDrillRepairReceiptConsumerV1.loadBoardTextureRecheckCandidates()` converts persisted W5 board-texture receipts into internal recheck candidates.
- `SessionDrillRecheckLaunchQueueV1.loadBoardTextureLaunchQueueItems()` converts those candidates into deterministic session-drill launch queue items.
- Malformed, wrong-session, and wrong-family receipts are ignored safely.

## Explicit non-scope

- No visible Review card was added.
- No Act0 queue consumer was changed.
- No route schema was changed.
- No telemetry schema was changed.
- No Modern Table code was changed.
- No content/glossary files were changed.
- No queue resolution or clear policy was added.
- No one-drill-only result flow was added.
- No generic multi-family action-choice mapper was added.

## Current limitation

This wave proves W5 board-texture receipts can become internal launch descriptors. Visible Review still does not consume the board-texture launch queue; the current visible Act0 queue path remains separately owned and should only be extended in a future scoped consumer wave.

## Checks

- Focused board-texture receipt mapping test
- W6 receipt adapter/consumer/queue/user-launch focused tests
- Range-bucket evaluator focused test
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

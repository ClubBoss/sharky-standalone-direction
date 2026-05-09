# R7 Worlds 1-10 Canonical Audit v1

Date: 2026-03-05

## Scope
- World coverage audit for Worlds 1-10.
- Canonical session existence check (`MS1..MS10` per world).
- Total drill counts and `acceptable_actions` counts by world.
- Transition checkpoint presence check for:
  - w4-w6
  - w6-w7
  - w7-w8
  - w8-w9
  - w9-w10

## Method (deterministic)
- Session existence: counted `content/worlds/worldN/v1/sessions/wN.s*` directories.
- Drill totals: counted `content/worlds/worldN/v1/sessions/**/drills/d.*.json`.
- `acceptable_actions`: counted JSON lines matching `"acceptable_actions"` under each world sessions tree.
- Transition checkpoint presence: verified non-TODO handoff/transition lines in target `notes.md` files.

## World Coverage (MS1-MS10)

| world | ms1-ms10 present | session_count |
| --- | --- | ---: |
| world1 | YES | 10 |
| world2 | YES | 10 |
| world3 | YES | 10 |
| world4 | YES | 10 |
| world5 | YES | 10 |
| world6 | YES | 10 |
| world7 | YES | 10 |
| world8 | YES | 10 |
| world9 | YES | 10 |
| world10 | YES | 10 |

## Drill Totals + acceptable_actions

| world | total_drills | acceptable_actions_count |
| --- | ---: | ---: |
| world1 | 60 | 0 |
| world2 | 80 | 35 |
| world3 | 80 | 0 |
| world4 | 80 | 0 |
| world5 | 80 | 0 |
| world6 | 80 | 0 |
| world7 | 80 | 0 |
| world8 | 80 | 0 |
| world9 | 80 | 0 |
| world10 | 80 | 0 |

## Transition Checkpoint Presence

| checkpoint | status | evidence |
| --- | --- | --- |
| w4-w6 | PRESENT | `world4/w4.s10/notes.md`, `world5/w5.s01/notes.md`, `world6/w6.s01/notes.md` |
| w6-w7 | PRESENT | `world6/w6.s10/notes.md`, `world7/w7.s01/notes.md` |
| w7-w8 | PRESENT | `world7/w7.s10/notes.md`, `world8/w8.s01/notes.md` |
| w8-w9 | PRESENT | `world8/w8.s10/notes.md`, `world9/w9.s01/notes.md` |
| w9-w10 | PRESENT | `world9/w9.s10/notes.md`, `world10/w10.s01/notes.md` |

## Cover-Grade Note (Worlds 1-2)
- Worlds 1-2 remain cover-grade in current roadmap status:
  - World1 intro prelude + in-hand truth guardrails.
  - World2 intro/handoff + seat-quiz gold contracts + action-decision board visibility contract.

## Summary
- Worlds 1-10 have `MS1..MS10` present.
- Worlds 3-10 are canonicalized to full 10-session coverage.
- Transition checkpoints listed above are present.
- `acceptable_actions` usage is concentrated in World2 practice layer, zero in Worlds 3-10.

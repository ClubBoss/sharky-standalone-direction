# Volume I Cluster Execution Policy v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Define how `W1-W12` should be improved from here without reopening the same
execution-shape debate every cycle.

This policy answers one practical question:

- should we keep using one prompt = one world by default
- or should we plan and execute `Volume I` as multi-world clusters

## Core Decision

Do not use `one prompt = one world` as the default execution model for the rest
of `Volume I`.

Use:

1. one active multi-world cluster at a time
2. one bounded sub-wave inside that cluster per cycle
3. one recalibration pass after the cluster improves materially

This gives better continuity without widening each individual implementation
wave into an unsafe blob.

## Why This Is Better

### What is bad about strict one-world-only execution

If taken too literally, it causes:

1. local optimization without route coherence
2. repeated prompt/setup overhead
3. too much token burn on re-deciding the next world every time
4. a higher chance that adjacent worlds drift in density or tone

### What is bad about broad many-world execution at once

If taken too broadly, it causes:

1. unclear ownership
2. weak verification
3. route drift
4. broad rewrites instead of clean packets

### Preferred middle path

The right model is:

1. plan several adjacent worlds as one structural cluster
2. improve one bounded sub-wave at a time inside that cluster
3. keep scorecard and recalibration at the cluster level

## Execution Model

### Level 1. Cluster

A cluster is:

- a small adjacent stretch of worlds
- one shared route role
- one shared quality frontier

Examples:

1. `W1-W4` beginner grammar cluster
2. `W5-W6` purpose-and-board applied cluster
3. `W7-W9` context-and-pressure cluster
4. `W10-W12` back-half Volume I completion cluster

### Level 2. Sub-wave

A sub-wave is:

- one bounded world or seam pass inside the active cluster
- one admitted owner family
- one verification cycle

This preserves the existing bounded-wave discipline.

### Level 3. Recalibration

After one or more meaningful sub-waves inside the active cluster:

1. update the calibration truth
2. decide whether the same cluster still contains the highest-EV next move
3. only then advance to the next cluster

## Default Rules

1. Plan by cluster.
2. Execute by bounded sub-wave.
3. Recalibrate by cluster.

Do not:

1. re-decide the whole route from scratch after every tiny world pass
2. widen one implementation wave across multiple unrelated worlds at once
3. jump to a new cluster while the active cluster still contains the strongest
   obvious thin point

## Current Volume I Cluster Map

### Cluster A. W1-W4

Role:

- beginner grammar and early table choices

Current state:

- strong enough; not the active frontier

### Cluster B. W5-W6

Role:

- first applied betting and board-reading logic

Current state:

- strong enough; not the active frontier

### Cluster C. W7-W9

Role:

- context, stack, and pressure extension

Current state:

- now materially stronger after W7, W8, and W9 density waves

### Cluster D. W10-W12

Role:

- complete the back half of `Volume I` with:
  - real-player adaptation
  - capstone transfer
  - mindset / process bridge

Current state:

- now materially stronger after W10, W11, and W12 density waves plus seam
  regression locks

## Active Cluster Policy (Current)

There is no default broad `Volume I` density cluster right now.

`W10-W12` has already completed its highest-EV bounded sub-waves:

1. `W10 Real-Player Thinking`
2. `W11 Real Play Transfer / Capstone`
3. `W12 Mindset Bridge`
4. cluster recalibration

Any re-entry into `Volume I` should start from fresh calibration, not from an
assumption that `W10` is still the next move.

If the public-launch bar from `VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` is the
goal, reopen only the clusters that still contain visible worlds below `19`.

Current lift order under that stricter bar:

1. none by default; `W1-W12` now clears the visible `19+` bar

## Why W10-W12 Is One Cluster

These worlds share one route job:

1. convert earlier technical competence into real-life usefulness
2. make the learner feel the product is now becoming personally practical
3. complete `Volume I` as a believable route, not just a technical ladder

Treating them as one cluster reduces the chance of:

1. W10 being tactical but thin
2. W11 being meaningful but underpowered
3. W12 drifting into abstract mindset talk

## Verification Rule

Every sub-wave inside a cluster still requires:

1. code/content change in bounded scope
2. regression lock
3. plan trace
4. focused verification

Cluster planning does not weaken wave-level proof.

## Scorecard Rule

Cluster work must stay anchored to:

1. `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md`
2. `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`

Use those for:

1. choosing the next sub-wave inside the cluster
2. deciding whether the cluster is materially stronger
3. deciding when to advance to the next cluster or stop

## Stop Rule

Do not keep polishing a cluster indefinitely.

Advance or pause when:

1. the active cluster no longer contains the clearest thin point
2. the remaining work is mostly cosmetic
3. the next cluster now offers higher route EV

## Bottom Line

The default execution shape for the rest of `Volume I` is:

1. cluster-first planning
2. bounded sub-wave implementation
3. cluster-level recalibration

Current default:

- no active `Volume I` density cluster by default
- no public-launch lift cluster by default; visible `W1-W12` now clears `19+`
- next honest route frontier = `W12 -> W13`, which remains outside current
  `Volume I` execution scope unless later-volume work is explicitly admitted

# R17 Mastery Checkpoint Audit v1

## What shipped
- Checkpoint trigger cadence is deterministic: pending every 4 completed sessions.
- Checkpoint seed consumes top-3 error classes from ProgressService.
- Global checkpoint pack is now a canonical 6-step runtime Gold slice:
  - 3 bounded error classes only: `range`, `timing`, `sizing`.
  - deterministic seat and action checks in one table-first flow.

## Where it lives
- Trigger + seed persistence:
  - `lib/services/progress_service.dart`
- Checkpoint pack content (runtime canonical source):
  - `lib/campaign/campaign_pack_registry_v1.dart`
  - pack id: `season1_checkpoint_global_v1`
- Seed consumption + deterministic 6-step selection + cue:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`

## Quick verify
1. `flutter analyze`
2. `./tools/fast_loop_world1_v1.sh`

## Done criteria for R17
- Checkpoint path is deterministic and dead-end free.
- Trigger cadence and seed usage are contract-covered.
- Gold checkpoint pack has exactly 6 steps and bounded top error classes.
- Tier0 gates are green.

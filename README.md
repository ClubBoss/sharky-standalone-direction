# Sharky 1.0

This repository is the standalone active product root:

- `/Users/elmarsalimzade/Sharky_1.0`
- GitHub canonical remote: `https://github.com/ClubBoss/sharky-standalone-direction.git`

All future pushes for active product development must go to `origin/main` in
this standalone repository.

Older neighboring roots under `poker_ai_analyzer/` are donor/archive
workspaces only and must not be treated as the active product.

## Start Here

1. `AGENTS.md` — how to work in this repository.
2. `docs/PLAN.md` — the single plan: current stage, next result, blockers.

## Product Truth

Live content in the active product root is intentionally narrow:

1. `content/world1_act0_*/v1/`
2. `content/worlds/world*/v1/`
3. `content/gauntlets/`
4. `content/schedules/`
5. support shelves under `content/_*`

Archived or donor material does not define the live product.

## Run

```bash
flutter pub get
flutter run -t lib/main.dart
```

## Verification

Default fast loop:

```bash
./tools/fast_loop_world1_v1.sh
```

Release-gated loop:

```bash
./tools/release_gate_world1.sh
```

Checkpoint loop:

```bash
./tools/checkpoint_world1_v1.sh
```

## Repository Hygiene

- `build/`, `.dart_tool/`, and local runtime outputs are generated only.
- adaptive sidecars such as `content_adaptive_generated/` and
  `content_adaptive_preview/` are archive/tooling outputs, not product truth.
- old neighboring roots remain available for reference but are not the active
  workspace.

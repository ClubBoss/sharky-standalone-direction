# Sharky 1.0

This repository is the standalone active product root:

- `/Users/elmarsalimzade/Sharky_1.0`
- GitHub canonical remote: `https://github.com/ClubBoss/sharky-standalone-direction.git`

All future pushes for active product development must go to `origin/main` in
this standalone repository.

Older neighboring roots under `poker_ai_analyzer/` are donor/archive
workspaces only and must not be treated as the active product.

## Start Here

Active SSOT entrypoint:

1. [docs/README.md](/Users/elmarsalimzade/Sharky_1.0/docs/README.md)

Active working chain:

1. [docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md)
2. [docs/plan/MASTER_PLAN_v3.0.md](/Users/elmarsalimzade/Sharky_1.0/docs/plan/MASTER_PLAN_v3.0.md)
3. [docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md)
4. [docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md)
5. [STANDALONE_PRODUCT_SCOPE_v1.md](/Users/elmarsalimzade/Sharky_1.0/STANDALONE_PRODUCT_SCOPE_v1.md)

Launch/readiness reference only when specifically needed:

- [docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md)

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
flutter run -t main.dart
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

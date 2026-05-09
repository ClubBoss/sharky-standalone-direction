# R90 Post-Topology-Fix Visible Path Verification Closeout v1

## Purpose and bounded scope
- Verify the user-visible World1 entry path after the R89 topology alignment fix.
- Scope stayed bounded to:
  - fresh/reset World1 first visible node identity,
  - `START HERE` consistency,
  - first node launch destination,
  - fresh/reset `Start Now` destination,
  - alignment with already covered `world1_act0_table_literacy` learning hosts.

## PIEC summary
- Reconciled:
  - `docs/_reviews/r88_fresh_reset_start_now_runtime_path_audit_lock_closeout_v1.md`
  - `lib/ui_v2/map/progress_map_world1_determinism.dart`
  - R89 topology fix on `ui_v2_progress_map_screen_v2.dart`
- Branch-state finding at start of R90:
  - R89 runtime/test changes were present locally but not yet committed.
  - `HEAD` was still `47cfe21a4` (`R88`) on `main` / `origin/main`.
- Authoritative ownership chain remains:
  - canonical order source: `kWorld1CanonicalModuleOrder`
  - visible World1 path order: `_sortedPackIdsForWorld(1)`
  - visible label source: `_inlineNodeTitleV1(...)`
  - first visible marker source: first incomplete index on the visible path
  - Start Now owner: `_handleCampaignStartNowActionV1()` -> `_resolveEarliestIncompleteWorld1PackIdV1()`
  - launch seam for map node and Start Now: `_openCampaignPack(...)`

## What was verified
- Fresh/reset World1 first visible node label is now:
  - `Table Basics`
- Fresh/reset visible first node marker is now:
  - `START HERE`
- Fresh/reset visible first node launch resolves to:
  - `world1_act0_table_literacy`
- Fresh/reset `Start Now` resolves to:
  - `world1_act0_table_literacy`
- Therefore visible first node and `Start Now` now agree on the same canonical host.

## Covered host alignment
- The opened host is now the already covered Act0 table-literacy pack:
  - `world1_act0_table_literacy`
- Existing covered-learning runtime on that host remains proven by deterministic contracts:
  - concept-first covered cluster on `world1_act0_table_literacy`
  - gold literacy covered slice/cluster on `world1_act0_table_literacy`
- Result:
  - the previously landed-visible path now reaches the host where those covered improvements already exist, so they are now visible in the actual first-user path.

## Runtime fix vs proof-only
- Additional runtime fix in R90: not needed.
- R90 closed as:
  - commit/push cleanup for the R89 topology fix,
  - visible-path proof strengthening only.

## User-visible truth after R90
- On fresh/reset World1:
  1. first visible lesson is `Table Basics`
  2. that lesson carries `START HERE`
  3. first lesson open lands on `world1_act0_table_literacy`
  4. `Start Now` also lands on `world1_act0_table_literacy`


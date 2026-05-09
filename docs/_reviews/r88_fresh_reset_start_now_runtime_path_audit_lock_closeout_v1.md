# R88 Fresh Reset / Start Now Runtime Path Audit and Lock Closeout v1

## Purpose and bounded scope
- Audit and lock the authoritative runtime path for:
  - `dev reset -> Start Now -> resolved packId`.
- Scope remained bounded to authoritative seams:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/services/progress_service.dart`
  - targeted map contract proof only.
- Out of scope respected:
  - no concept/literacy rollout,
  - no map/result redesign,
  - no theory/multi-street/sizing work,
  - no schema expansion.

## PIEC summary
- Reconciled:
  - `docs/_reviews/r79_world1_fresh_install_route_truth_lock_closeout_v1.md`
  - `docs/_reviews/r86_world1_concept_first_gold_micro_slice_closeout_v1.md`
  - `docs/_reviews/r87_world1_concept_first_gold_cluster_closeout_v1.md`
- Authoritative ownership chain confirmed:
  - dev reset owner: `ProgressService.resetSpineProgressV1()`
  - Start Now owner: `_handleCampaignStartNowActionV1()`
  - pack resolver: `_resolveEarliestIncompleteWorld1PackIdV1()`
  - resolver state source: `ProgressService.getSpineCompletedPackIdsV1()`
  - launch path: `_openNextCampaignPackFromSsoT()` -> `_openCampaignPack(...)`
- Audit finding:
  - reset and Start Now route both rely on the same authoritative spine state family (`spine_campaign_*` + campaign completion bits).

## What was proven
- After authoritative reset on progressed state:
  - `spine_campaign_completed_packs_v1` is cleared,
  - `spine_campaign_active_pack_id_v1` is cleared,
  - `spine_campaign_next_hand_index_v1` is cleared,
  - legacy campaign completion bit for first pack is cleared.
- Then Start Now deterministically resolves to:
  - `world1_act0_table_literacy` (Act0-first).

## Runtime fix vs proof-only
- Runtime code fix: not needed.
- This milestone closed as proof-only lock with strengthened contract coverage.

## Contract strengthening added
- Updated:
  - `test/guards/world_campaign_map_home_contract_test.dart`
- New proof ensures no reset/read divergence:
  - reset-cleared keys are the same keys Start Now path reads for routing,
  - first pack after reset is `world1_act0_table_literacy`.

## Interpretation vs prior R79 expectation
- R79 expectation remains confirmed on authoritative reset path:
  - fresh-reset Start Now routes to Act0 table first.
- Therefore the previously observed `world1_act0_action_literacy` after "dev reset" is not authoritative-path truth for this seam and likely came from a non-equivalent reset state in that run.

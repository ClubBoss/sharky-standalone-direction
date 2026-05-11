# Legacy Compatibility Owners v1

Status: ACTIVE
Last updated: 2026-05-09

## Purpose

Record the code owners that still preserve older intro/core/table-first runtime
behavior after the standalone `Sharky_1.0` content cutover.

This is a compatibility map, not a product-plan override.

## Product Truth

For active product content truth, use:

1. `docs/plan/MASTER_PLAN_v3.0.md`
2. `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`
3. `content/world1_act0_*/v1/`
4. `content/worlds/world*/v1/`

Do not treat the compatibility files below as the canonical source for what is
currently in the live 12-world route.

## Compatibility Owners Still Kept Live

These files are still referenced by runtime code, validators, theory hosts,
progress services, or guard tests, so they must not be removed blindly:

1. `lib/content/release_content_plan.dart`
   Compatibility release metadata for the older intro/core module family.
2. `lib/campaign/campaign_pack_registry_v1.dart`
   Compatibility microtask pack registry still used by runner/bootstrap paths.
3. `lib/training/lesson_module_ids.dart`
   Compatibility IDs for the older table-first/theory/review chain.
4. `lib/ui_v2/runner/canonical_module_theory_host_v1.dart`
   Compatibility theory host still routes some older module IDs.

## Working Rule

When a task touches `intro_*`, `core_*`, `tier_1_checkpoint`, or older
table-first module IDs:

1. assume the code path may still be live,
2. verify imports and guards first,
3. prefer compatibility labeling or routing isolation,
4. do not archive or delete the owner seam without a replacement wave.

## Cleanup Rule

The right next cleanup is not blind deletion.

The safe order is:

1. move active runtime paths fully onto Act0 / W1-W12 owners,
2. replace the compatibility caller seams,
3. then archive the old code owners together.

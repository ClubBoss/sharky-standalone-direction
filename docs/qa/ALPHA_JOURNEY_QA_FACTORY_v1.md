# Alpha Journey QA Factory v1

Run the reusable Alpha admission lane after an admitted change to the canonical
W1 Action learning loop:

```bash
./tools/run_alpha_journey_qa_v1.sh
```

The factory validates `tools/contracts/alpha_action_repair_recovery_v1.json`,
runs the canonical visible-control Learn replay, records its ordered telemetry
trace, exercises correct-first and failed-recheck policy paths, captures the
Action raster lane at compact/tall/large phone sizes, checks the frozen Modern
Table ownership boundary, and packages local-only evidence. The legacy Modern
Table screenshot generator is intentionally excluded: it targets retired owners
and is the known unrelated missing-import failure.

It deliberately uses deterministic widget replay as the valid fallback when
computer-use is unavailable. Its black-box trace begins at Learn and taps
visible controls; direct-state harnesses remain limited to the separately
labeled raster evidence lane and cannot satisfy black-box trace validation.

Successful output is local only:

```text
output/review_bundles/alpha_journey_qa_factory_v1_<SHORT_SHA>/
output/review_bundles/alpha_journey_qa_factory_v1_<SHORT_SHA>.zip
output/review_bundles/alpha_journey_qa_factory_v1_<SHORT_SHA>.zip.sha256
```

The command fails closed for tracked edits, staged output, stale contract
versions, a direct-state black-box trace, missing/misordered/duplicate required
telemetry, broken session-scoped or sequence continuity, unbound repair/recheck
mapping, incomplete compact/tall/large evidence, overflow, or missing recovered
payoff. Its manifest hashes all bundle files except itself; the archive hash is
stored beside the ZIP so creating it cannot invalidate the bundle. Update the
versioned contract first whenever a frozen route ID, sequence, telemetry order,
viewport, or geometry policy legitimately changes; then update the replay and
evidence owners in the same admitted wave.

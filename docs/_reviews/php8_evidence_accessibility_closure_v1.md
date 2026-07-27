---
status: "closed_proven"
status_source: "PHP-8 deterministic evidence and accessibility lane"
baseline: "194b2f14709b012db8af73921cd41315e0cf7053"
---

# PHP-8 Evidence & Accessibility Closure v1

**`PHP8_CLOSED_PROVEN`**. Two causal tooling gaps were repaired without a new
screenshot framework or new accessibility assertions.

| Gap | Owner and class | Disposition |
| --- | --- | --- |
| No dedicated W2 fast capture | existing real-text capture and screen-review packaging | Added the `w2` compact lane, using the active Act0 runtime test wrapper for W2 apply/recap surfaces. |
| No named accessibility sweep | existing deterministic accessibility contracts | Added `tools/php8_accessibility_sweep_v1.sh`, which runs semantics, text-scale, compact/enlarged-text and supported-phone visibility contracts as one named lane. |

The historic `world1_plan_result_compact_height_no_overflow_contract_test.dart`
remains an `ACTIVE_NONBLOCKING` stale-fixture carrier from PHP-0: its dormant
Today-plan fixture does not enter the current Act0 surface. It is deliberately
not promoted into the PHP-8 acceptance lane. The active compact-height and
enlarged-text contracts above are green.

F-14 wording was corrected in
`act0_same_session_learning_delta_v1_test.dart`: the source-recheck test now
names the W2 continuation it actually asserts, rather than implying Review
owns the terminal continuation.

The W2 lane exercised `RenderRepaintBoundary.toImage()` successfully on the
exact baseline, disproving the recorded milestone capture anomaly for this
active capture path. Local generated evidence stays under `output/` and is not
committed.

Human Novice Proof was not performed. Modern Table was not touched.

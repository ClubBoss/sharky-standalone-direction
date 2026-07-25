---
status: "undeclared"
status_source: "absent"
baseline: "b3e995e57320"
generated_by: "docs_frontmatter_v1"
---

# Profile Proof Identity / MB-024 Gate v1

Terminal verdict: `profile_proof_identity_mb024_v1_implemented_with_capture_debt`

## Scope and decision

- Branch / HEAD before: `claude/hub-surface-coherence-audit-plan-v1` /
  `b3e995e573202e8d23f5b692b140174a909d9e3b`.
- Active source entry point inspected:
  `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart` (`Act0ProfileShellV1`,
  `_ProfileProgressProofCardV1`, `_ProfileSkillStatsStripV1`, and
  `_ProfileSkillSummaryTileV1`).
- Existing data inspected: `profile.skillStats`, `profile.recentSkillGains`,
  profile evidence signal, cross-session fix proof, earned-moment seeds, and
  existing route/focus fields.

The gate passed for a bounded implementation. Profile already had sufficient
truth and did not need a new data contract, achievement system, route state,
or personalized statistic. The weak point was presentation: the skill area
repeated the generic `Practiced` label even when it had an existing source for
a recent skill gain.

## Change

The existing skill-stat section now uses **Proof in practice** framing:

- section title: `Proof in practice`;
- support: `What this route has put into practice.`;
- existing recent-gain rollup: `Recent proof: ...`;
- each stat with an existing recent gain shows `Recent route proof`, the
  already-provided `From <source>` line, and a `Route proof` visual chip;
- untouched stats retain the existing `Practiced` or `Later` state.

This changes hierarchy and framing only. It does not calculate, persist, or
invent proof. The source line is the pre-existing `Act0SkillGainV1.source`,
not generated personalization. No mastery, streak, achievement, level, score,
progression, route, or telemetry behavior was added or changed.

## Before / after role

Before, the Profile skill area named tracked skills and repeated `Practiced`,
which read as generic dashboard status. After, the same area answers the
Profile question more directly: what has been put into practice, and where
that evidence came from. It remains a compact supporting proof block rather
than competing with Learn, Worlds, Practice, Review, or Home.

## Validation

Passed:

- `flutter test test/ui_v2/act0_profile_claim_safety_v1_test.dart test/ui_v2/act0_cross_session_profile_proof_v1_test.dart test/ui_v2/act0_profile_evidence_consumer_v1_test.dart` — 26 tests.
- `flutter analyze` — no issues.
- `git diff --check` — passed.
- `graphify hook-check` — passed.

The claim-safety test now specifically verifies `Proof in practice`,
`Recent proof`, `Recent route proof`, and the existing source line while
retaining the established forbidden-claim checks.

## Compact evidence

Smallest available Profile lane:

```bash
dart run tools/act0_real_text_surface_capture_v1.dart profile_evidence compact
```

Local-only evidence:

- folder: `output/screen_review/current/profile_evidence_fast/`
- image: `compact.profile_evidence.png`

The capture shows the new section title, proof rollup, and first source-backed
tile. Its second tile drops the stat-label raster while preserving the other
tile text. Focused widget tests find the label and the source has no layout
exception; this is treated as the existing RichText/capture rendering debt,
not as product evidence that the label is absent. No capture post-processing
was changed.

## Return queue

| ID | Item | Disposition |
| --- | --- | --- |
| MB-024 | Generic Profile stat-tile framing. | Bounded proof-identity pass implemented. |
| CAP-024 | Compact capture drops one lower skill label despite widget-tree proof. | Evidence-pipeline debt; investigate separately. |
| MB-015 | Shared hub card grammar. | Deferred; outside Profile-only scope. |
| P3 | Practice/Review sparseness and dead-space. | Deferred; untouched. |
| P2 | Long three-option compact-row horizontal overflow. | Separate runner debt; untouched. |

Home, Learn, Worlds, Practice, Review, Table, Sharky, motion, tablet,
telemetry, route/progression, W12 terminal, and W13 locking were not part of
this wave. No 10/10, public-readiness, or Human-QA-readiness claim is made.

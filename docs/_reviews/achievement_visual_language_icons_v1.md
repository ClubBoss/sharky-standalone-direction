# Achievement Visual Language / Icons v1

## 1. Verdict

`achievement_visual_language_icons_landed_with_bounded_consumers`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `4a9bdf29ed8826e25dbd7712e2394c973aa05fd6`
- No tracked or staged changes existed at start; only untracked `output/**` was
  present.
- `graphify hook-check` passed. This linked worktree has no local
  `graphify-out/graph.json`, so scoped graph queries were unavailable; the
  main repo checkout owns the graph. Direct scoped reads (`rg`, targeted
  `Read`) were used instead, following the narrow required-read order.

## 3. Capsule/authority check

`ACTIVE_ROUTE_CAPSULE_v1.md` and `VISUAL_PROOF_CAPSULE_v1.md` both named
`Achievement Visual Language / Icons v1` as the active Phase 4 task, with
freshness date 2026-07-03 matching today. Their verified product HEAD
(`99783a3d`) was one commit behind the actual starting HEAD (`4a9bdf29`,
itself a docs-only capsule-refresh commit that recorded this exact route with
no source drift). No route-critical fact conflicted with live source/tests,
so no `stale_capsule_scope` was raised.

## 4. Existing visual audit

- Profile `Progress proof` (`_ProfileProgressProofCardV1` /
  `_crossSessionProofTilesV1` in `act0_profile_shell_v1.dart`) rendered
  "Fixes" and "Reinforced" tiles with plain Material icons
  (`Icons.check_circle_outline_rounded`, `Icons.replay_circle_filled_rounded`)
  colored directly by an arbitrary per-tile tone (gold, green).
- Session Summary's banked-fix receipt
  (`_SessionSummaryRepairOutcomeReceiptCardV1` in
  `act0_lesson_runner_shell_v1.dart`, consuming
  `Act0RepairOutcomeConsumerV1.sessionReceipt`) had **no icon at all** — title
  and lines only.
- A separate in-lesson ceremony block (`_FeedbackSessionSummaryCeremonyBlockV1`,
  key `act0_shell_session_summary_proof_block`) also renders "Session repair"
  copy, but it is sourced from an immediate per-answer copy-guard function
  (`act0RepairSessionSummaryCopyGuardLinesV1`), not the banked-fix projection.
  It was left untouched; it is not the receipt the capsule describes and
  touching it would exceed the two-consumer cap.
- Duplicate/conflicting metaphor found: the Profile fallback (no
  cross-session proof) "Earned" tile uses `Icons.emoji_events_rounded` (a
  generic trophy), which is exactly the cheap-badge metaphor this task must
  avoid. It sits in a different, already-frozen fallback branch outside this
  task's admitted consumers, so it was left as a documented inconsistency
  rather than widened into scope.
- All existing icons are plain `Icon(IconData)` calls tinted by ad hoc tone
  colors; there was no shared icon-frame/tile primitive, painter, or SVG
  asset to reuse. Tokens (`Act0ShellTokensV1`, `Act0VisualCanonV1`) already
  define the gold/navy/teal palette needed.
- Conclusion: existing icon primitives were insufficient (no frame/rim/echo
  grammar existed), so a small shared semantic widget was justified.

## 5. Semantic proof roles

`Act0ProofIconRoleV1` (`lib/ui_v2/act0_shell/act0_proof_icon_v1.dart`) defines
exactly three roles: `repairCompleted`, `reinforced`, and `milestone`
(reserved, not emitted by any active consumer). No rarity, mastery, tier,
level, lock state, score, or progress percentage was added.

## 6. Visual grammar

`Act0ProofIconV1` renders a compact rounded-square tile on the existing
navy-glass surface tone with a thin gold rim:

- `repairCompleted`: single tile, `Icons.check_rounded`, restrained rim
  opacity — calm, not celebratory.
- `reinforced`: same tile family plus a second, lower-opacity outer ring
  ("echo") and `Icons.done_all_rounded` (double-confirm glyph) — communicates
  additional evidence, not higher rank.
- `milestone`: reserved larger seal size, thicker rim, `Icons.verified_rounded`
  — not wired into any consumer.

No crowns, coins, stars-as-currency, cartoon trophies, or loot-style
decoration were introduced; a focused test asserts none of those icons ever
render from `Act0ProofIconV1`.

## 7. Shared seam

`Act0ProofIconV1` is a small `StatelessWidget` accepting only `role` and
`size` (`Act0ProofIconSizeV1.inline|tile|seal`, 20/32/44dp boxes). It accepts
no rarity, level, progress, lock, animation, or monetization state, and reads
only shared visual tokens — no new dependency, no new asset.

## 8. Consumer integration

Two consumers, matching the two-consumer cap:

1. **Profile `Progress proof`**: the "Fixes" tile now renders
   `Act0ProofIconRoleV1.repairCompleted`; the "Reinforced" tile renders
   `Act0ProofIconRoleV1.reinforced` only when `reinforcedFixCount > 0`
   (otherwise no icon renders for that tile — the fallback branch and its
   "Concepts"/"Lessons" tiles are unchanged). Card/row structure, callbacks,
   and copy are unchanged.
2. **Session Summary banked-fix receipt**: `Act0RepairOutcomeSessionReceiptV1`
   gained two fields — `isBankedFixProof` and `hasReinforcedEvidence` — set
   only by `_sessionReceiptForFixProofV1` (the structured banked-fix path),
   never by the raw activity fallback
   (`_sessionReceiptForOutcomesV1`). The receipt card shows
   `repairCompleted` or `reinforced` next to its title only when
   `isBankedFixProof` is true; the fallback path shows no icon. Card
   structure, gold containment, and callback behavior are unchanged.

## 9. Gold containment

Both integrations reuse `Act0ShellTokensV1.gold` for the icon rim/glyph only,
inside existing gold-contained regions (Profile tile border already used
`tile.tone`; Session Summary receipt already sits inside the gold-toned
`_RepairSystemProofBlockV1` frame for the ceremony block, and inside its own
existing bordered card for the receipt). No new gold button, gold background
region, or gold text was introduced.

## 10. Semantic/claim safety

- `repairCompleted` and `reinforced` are driven exclusively by
  `Act0FixProofProjectionV1`/`Act0CrossSessionProfileProofV1` /
  `Act0RepairOutcomeSessionReceiptV1.isBankedFixProof` —
  all downstream of Review resolution receipts and transfer evidence, per the
  accepted proof source chain. Icon selection is a pure read in a
  `StatelessWidget`; it cannot mutate proof state.
- `milestone` is defined but not referenced by either consumer (verified by a
  source-scan test), so it cannot appear on ordinary repair proof.
- Missing/insufficient proof (empty aggregate, or the raw activity-count
  fallback receipt) renders no earned-proof icon at all.
- Same-task immediate correctness and same-session evidence still cannot
  produce `reinforced` — that rule lives in `Act0FixProofProjectionV1` and was
  unchanged; the icon layer only reads its output.

## 11. Screenshot evidence

`./tools/screen_review_fast_v1.sh core compact`,
`first_week compact`, and `full_scroll compact` all ran and passed, confirming
no regression to Profile/Session Summary layout, gold containment, or overflow
in their default fixtures.

A dedicated local-only capture attempt for the six specifically requested
proof-icon states (no-proof fallback, one completed fix, reinforced fix for
both Profile and Session Summary, plus a compact comparison) was written as a
throwaway widget-test harness. It produced one image
(`profile_no_proof_fallback.png`) successfully, then stalled indefinitely
(near-zero CPU, no exception) inside `RenderRepaintBoundary.toImage()` once a
non-empty `crossSessionProof`/`fixProofProjection` fixture was pumped — most
likely a software-rasterizer capture-tool limitation in this sandbox, not a
product defect: the same non-empty-proof fixtures already render correctly
and deterministically under the existing, passing `pumpAndSettle`-based
widget-test suite (see Tests/validation). The stalled harness was killed and
deleted; nothing under `output/achievement_visual_language_icons_v1/` was
committed. Per the Visual Proof Capsule, this capture-tool artifact is
recorded as an evidence limitation, not a claimed defect.

## 12. Tests/validation

- New: `test/ui_v2/act0_proof_icon_v1_test.dart` (7 tests) — role-to-glyph
  mapping, echo layer, no rarity/lock/trophy icons ever render, and a
  source-scan confirming `milestone` is unwired from both consumers.
- Extended: `test/ui_v2/act0_cross_session_profile_proof_v1_test.dart` (+5
  tests) — banked fix maps to `repairCompleted`/`reinforced`, missing proof
  yields no icon, non-reinforced banked fix shows no reinforced icon,
  ordinary fix never maps to `milestone`, rendering does not mutate proof
  state.
- Extended: `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart` (+3
  tests) — banked fix maps to `repairCompleted`, later-supported fix maps to
  `reinforced`, activity-only fallback shows no earned icon.
- Extended: `test/ui_v2/act0_repair_outcome_consumer_v1_test.dart` (+2 tests)
  — `isBankedFixProof`/`hasReinforcedEvidence` flag correctly on the
  structured path and correctly absent on the fallback path.
- Full targeted run: 87 tests passed across the above four files plus
  `act0_fix_proof_projection_v1_test.dart` (unchanged, re-run for
  regression).
- Regression spot-check: `session_summary_gold_containment_v1_test.dart`,
  `act0_profile_claim_safety_v1_test.dart`,
  `wave4_3_premium_reward_session_summary_payoff_v1_test.dart`,
  `wave4_2_premium_identity_claim_cleanup_v1_test.dart`,
  `act0_profile_evidence_consumer_v1_test.dart` — all passed unchanged.
- `flutter analyze` on all touched files: no issues.
- `git diff --check` / `git diff --cached --check`: clean (see Stage 12
  validation below).

## 13. Rolling Capsule Advance

`docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`: Phase 4 sequence item 3
(`Achievement Visual Language / Icons`) marked CLOSED; item 4
(`W1 Completion Payoff`) marked ACTIVE and set as the current active task;
verified route artifact repointed to this review file.

`docs/context/VISUAL_PROOF_CAPSULE_v1.md`: Current Proof State and Remaining
Visual Route updated to record the landed `Act0ProofIconV1` seam, its two
admitted consumers, the reserved `milestone` role, and `W1 Completion Payoff`
as next; reference artifact list extended with this review file.

Per the repository's Rolling Capsule Advance convention, both capsules record
"pending commit (this task's own commit advances it)" for the verified HEAD
field, since the exact hash is unknown until the same atomic commit lands.

## 14. Scope safety

No new route, screen, achievement gallery, collection/grid, XP/coins/levels/
ranks/rarity, motion, Sharky visual evolution, completion-payoff
implementation, multi-repair visible expansion, W13+ work, new dependency, or
new raster/SVG asset was introduced. No Modern Table, broad Profile/Session
Summary redesign, or broad copy rewrite occurred. `output/**` remains local
and uncommitted; the throwaway evidence-capture test file was deleted before
commit.

## 15. Known limitations

- The Profile fallback (no cross-session proof) "Earned" tile still uses a
  generic trophy icon (`Icons.emoji_events_rounded`); it sits outside this
  task's two admitted consumers and was left untouched to preserve scope.
- The in-lesson `_FeedbackSessionSummaryCeremonyBlockV1` ceremony block (a
  different "session repair" surface, not sourced from banked-fix proof) was
  not touched; it remains a plain-text ceremony, consistent with the
  two-consumer cap.
- The six specifically requested proof-icon screenshot states could not be
  captured due to a capture-harness (`RenderRepaintBoundary.toImage()`)
  stall in this sandbox; correctness for those exact states is instead
  proven by the passing focused widget tests in section 12.
- `milestone` remains defined but entirely unused, as required; it will need
  its first real consumer wiring in a later completion-payoff/band-transition
  stage.

## 16. Next recommendation

`W1 Completion Payoff v1`

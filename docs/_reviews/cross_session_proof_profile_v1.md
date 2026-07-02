# Cross-Session Proof Profile v1

## 1. Verdict

`cross_session_proof_profile_landed_with_bounded_consumer`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `c79505dd98257113dcfabb40529d40e1cf24cb1f`
- No tracked or staged changes existed; only untracked `output/**` was present.
- `graphify hook-check` passed. The linked worktree has no local
  `graphify-out/graph.json`, so scoped graph queries were unavailable.

## 3. Capsule/authority check

The active capsule names Phase 4 - Proof Progression and
`Cross-Session Proof Profile v1` as the active task. Its verified product-state
HEAD is `2472b68c`; `c79505dd` is the accepted capsule-refresh commit that
records this route. The broader strategy plans retain older route text, so the
newer current execution context and accepted capsule-refresh evidence govern
this bounded implementation without reopening roadmap scope.

## 4. Current Profile ownership audit

- Screen owner: `Act0ProfileShellV1`, mounted by the existing Act0 Profile tab.
- Existing hierarchy: header, hero, next milestone, `Progress proof`, optional
  evidence signal, earned moments, skill detail, milestones, and account rows.
- Existing `Progress proof` values were primarily activity-based: lessons,
  rhythm, tracked/practiced skills, and achievement labels.
- Completed progress is carried by `lessonsLine`, completed task/lesson ids,
  and world counts. Existing optional Profile evidence is sourced from local
  learning records but is separate from exact repair proof.
- Existing Profile fallback is the unchanged generic `Progress proof` grid.
- Safe consumer slot: the existing `act0_shell_profile_progress_proof` card.
- The slot can show three lifetime proof aggregates and up to three recent
  lines without a new route, card, callback, or scroll architecture.

## 5. Profile proof contract

`Act0CrossSessionProfileProofV1` contains schema version, lifetime banked count,
reinforced count, distinct concept-family count, recent-window descriptor,
capped recent items, latest proof session/order, and raw repair proof refs.
`completedSessionCount` was not added because it is not needed for this proof
job.

## 6. Lifetime versus recent proof

Lifetime values use all unique source-backed Fix Proof items. Recent items use
the accepted `recent_session_window_v1` projection. Moving the recent window
does not lower lifetime counts. One exact proof id counts once, and a reinforced
version upgrades the same proof rather than adding another fix.

## 7. Recent proof item model

Each `Act0CrossSessionProfileProofItemV1` carries proof id, concept-family id,
proof state, repair outcome ref, optional later-evidence ref, banked order,
concept label key, and message key. Visible items are capped at three and retain
Fix Proof ordering: reinforced first, then newest banked order, then stable id.

## 8. Aggregation and deduplication

Blank or incomplete proof identities fail closed. Duplicate proof ids collapse
deterministically, preferring reinforced evidence and then the latest banked
order. Different exact fixes in one family count separately while the family
aggregate deduplicates.

## 9. Claim-safe copy

The bounded consumer uses concrete language such as `4 banked`,
`1 on a later hand`, `2 worked on`, `You repaired this table-reading clue`,
`Later evidence supported this repair`, and `Across your recent sessions`.
It adds no mastery, score, percentage, level, rating, weakest-skill, AI, or
calendar-week claim.

## 10. Consumer admission

The existing `Progress proof` card switches from generic activity tiles to
proof-backed Fixes, Reinforced, Concepts, and Lessons tiles only when source
proof exists. The no-proof fallback, Profile route, next-milestone callback,
account callbacks, and surrounding hierarchy remain unchanged.

## 11. Visual hierarchy

The existing navy-glass card and compact two-column grid remain intact. Gold is
limited to earned proof emphasis. Recent lines are plain text with no trophy,
medal, achievement icon system, chart, hero, analytics table, or motion.
Compact widget evidence reports no overflow.

## 12. Persistence boundary

The audit found that Review resolution receipts and learning evidence persisted
but `Act0RepairOutcomeProjectionV1` did not. Exact completed repair proof could
therefore not survive reload. The existing progress owner now persists that
source projection in schema v16. The projection gained strict parse support;
no Profile-specific store or copied display text was added.

## 13. Relationship to existing learning layers

- Fix Proof remains the only proof source.
- Queue resolution remains active-repair truth.
- Review resolution remains unresolved-only and supplies durable receipts.
- Resolved Review items are not recreated.
- Pattern coaching remains observational.
- Transfer measurement supplies only later supporting evidence.
- Personalized return reason and spaced repetition remain independent.
- Profile reads these projections and mutates none of them.

## 14. Telemetry boundary

No event, payload, sink, backend, SDK, or analytics owner changed.

## 15. Screenshot evidence if applicable

`./tools/screen_review_fast_v1.sh core compact` passed. Local-only evidence is
under `output/cross_session_proof_profile_v1/`:

- `core_compact_profile.png`
- `empty_no_proof_profile.png`
- `one_banked_fix_profile.png`
- `reinforced_fix_profile.png`
- `multiple_recent_proof_profile.png`
- `compact_profile_comparison.png`

The known test-font capture artifact renders labels as blocks, but card bounds,
hierarchy, emphasis, item count, and compact expansion remain judgeable.

## 16. Backward compatibility

Progress snapshots v1-v16 remain accepted. Missing or malformed repair outcome
payloads default to an empty projection. Restored sequence numbering resumes
after the highest valid persisted outcome.

## 17. Tests/validation

- 146 focused projection, Profile widget, Fix Proof, repair outcome,
  queue/Review, transfer/session, and Session Summary tests passed.
- The focused schema-v16 Profile proof reload test passed.
- The focused legacy snapshot restore test passed.
- `flutter analyze` passed with no issues.
- `./tools/screen_review_fast_v1.sh core compact` passed.
- Two stale focused test expectations were corrected: one referenced optional
  earned-moment copy without mounting that consumer, and one expected schema 14
  while the starting code already wrote schema 15.
- Final graphify and diff hygiene checks are required before commit.

## 18. Scope safety

No new route, Profile redesign, dashboard, graph, radar, percentage, XP/level
surface, rating, mastery label, ranking, AI claim, public profile, icon system,
motion, telemetry, server analytics, W13+ work, dependency, Modern Table visual,
Home consumer, or Session Summary consumer was added. `output/**` remains local.

## 19. Known limitations

- Recent display remains capped at three items.
- Concept copy is intentionally generic until a dedicated display-label
  contract is admitted.
- Historical proof begins with source outcomes available to schema-v16 state;
  older snapshots without repair outcomes safely show the existing fallback.
- Capture labels retain the known test-font evidence limitation.

## 20. Next recommendation

`Achievement Visual Language / Icons v1`

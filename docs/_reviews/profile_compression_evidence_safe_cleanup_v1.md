# Profile Compression / Evidence-Safe Cleanup v1

## 1. Verdict

profile_compression_ready

## 2. Claude audit finding addressed

The accepted UX/UI v2 audit flagged Profile / You as the largest current premium-perception drag: longest core scroll, decorative mood-copy, and repeated "table sense" / progress blocks. This pass compresses Profile without adding new data claims.

## 3. Before/after Profile structure

Before:

1. Header with "Your progress rhythm"
2. Current focus
3. Recent progress payoff card
4. Identity / level card
5. Progress proof
6. Rhythm / consistency card
7. Skill snapshot
8. Achievements
9. Account & settings

After:

1. Header with neutral "Learning profile"
2. Identity / level card
3. Current focus / View path
4. Compact Progress proof, including rhythm and week affordance
5. Skill snapshot
6. Achievements
7. Account & settings

## 4. Evidence-safe claim boundary

The screen still uses only existing Profile state: level, XP, streak/rhythm, lesson/task progress, skill stats, recent skill gains, achievements, current focus, and settings tools.

No new claims were added about last-N decisions, strongest/weakest areas beyond owned skill stat display, Review history, Practice recommendations, AI, leaks, mastery, solver/GTO, or long-term evidence.

## 5. Removed/collapsed decorative copy

- Removed the standalone Recent progress payoff card from the main Profile stack.
- Removed the standalone Rhythm / consistency card from the main Profile stack.
- Replaced "Your progress rhythm" with "Learning profile."
- Replaced the skill chip label "Recent progress" with "Recent gain."
- Replaced "Your strongest signals right now" with "Current skill signals from this route."
- Kept streak/week access inside the compact Progress proof block.

## 6. Scroll-depth impact

The full-scroll compact packet records Profile max scroll extent at 602px after this pass. The accepted audit finding called out a 1,090px Profile scroll, so the deterministic evidence shows materially reduced scroll depth.

## 7. Boundary proof

- Product UI changed only inside `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`.
- No Home, Learn, Practice, Review, Session Summary, Modern Table, route, progression, telemetry, content, glossary, premium/paywall, AI/persona, dashboard, XP/economy, or generated screenshot files were changed.
- Tests were updated only for the Profile contract affected by the compression.

## 8. Screenshot/full-scroll proof

Command:

```bash
./tools/screen_review_fast_v1.sh full_scroll compact
```

Artifacts:

- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/full_scroll_meta.json`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated artifacts remain local-only and are not committed.

## 9. Tests / validation

- Profile-focused widget subset: passed.
- Full-scroll packet capture: passed.
- Remaining final gate commands are recorded in the implementation summary.

## 10. Next recommended wave

Run the next Claude UX/UI v2 review packet against core, first-week, day2-return, and full-scroll evidence. Keep any follow-up Profile work separate unless the next review shows a concrete evidence-backed blocker.

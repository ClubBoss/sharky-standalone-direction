# Compact English Premium Pack Recapture v1

## Purpose

Validate the current Product Surface Premium Pack in compact English proof lanes without changing product code, copy, routes, telemetry, commerce, localization, or screenshot tooling.

This pass uses English as the commercial proof source of truth and treats RU/mixed-locale proof as deferred localization QA only.

## Capture Method

- App server: existing local Flutter web server at `http://127.0.0.1:7357/`
- Viewport: compact portrait `393 x 852`
- Locale lane: explicit `locale=en` with `act0_capture`
- Capture path: in-app browser screenshot API after the Flutter accessibility gate was enabled
- Output directory: `/Users/elmarsalimzade/Sharky_1.0/output/playwright/compact_english_premium_pack_recapture_v1/`

The direct Practice URL opens the pre-completion Practice state. To capture completed daily truth, the same browser session tapped `Start daily set`, completed the three visible daily reps correctly, and captured the resulting completion state.

## Screenshot Inventory

| Surface | URL / flow | Screenshot | Status |
| --- | --- | --- | --- |
| Home / Today | `?act0_capture=first_week_home&locale=en` | `/Users/elmarsalimzade/Sharky_1.0/output/playwright/compact_english_premium_pack_recapture_v1/first_week_home_compact_en.png` | captured |
| Practice completed | `?act0_capture=practice&locale=en`, then complete three daily reps | `/Users/elmarsalimzade/Sharky_1.0/output/playwright/compact_english_premium_pack_recapture_v1/practice_completion_compact_en.png` | captured |
| Review repair | `?act0_capture=first_week_review&locale=en` | `/Users/elmarsalimzade/Sharky_1.0/output/playwright/compact_english_premium_pack_recapture_v1/first_week_review_compact_en.png` | captured as open repair |
| Profile rhythm | `?act0_capture=first_week_profile&locale=en` | `/Users/elmarsalimzade/Sharky_1.0/output/playwright/compact_english_premium_pack_recapture_v1/first_week_profile_compact_en.png` | captured |

## Surface Score Table

| Surface | Commercial clarity | CTA truth | Density | Coach voice | Premium feel | Blocker? | Issue class |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| Home / Today | 8.4 | 8.8 | 7.8 | 8.5 | 8.4 | No | acceptable checklist density |
| Practice completed | 8.9 | 9.1 | 8.6 | 8.7 | 8.5 | No | acceptable polish |
| Review open repair | 8.2 | 8.6 | 8.1 | 8.3 | 8.0 | No | exact repaired/clean proof not captured |
| Profile rhythm | 8.5 | 8.2 | 8.0 | 8.4 | 8.4 | No | acceptable below-fold density |

## Home Findings

Home is valid English commercial proof. The top card now establishes `Today's table read` and keeps the first action family concrete with `Fold, check, call, raise`. The short practice block carries the loop well: `Today: keep one table clue warm` and `Sharky has your next useful hand ready`.

The checklist still makes compact portrait feel busy, but it is readable and coherent. This is not a blocker.

## Practice Completed Findings

The completed Practice state is the strongest surface in this pack. It clearly says `Daily table trainer complete`, replaces the stale start CTA with `Practice extra reps`, and adds a calm session result: `One table clue is warm. Sharky has your next useful hand ready.`

This resolves the previous commercial-truth concern where the completed state could still feel like an unfinished daily set.

## Review Repair Findings

The captured Review state is English and readable. It shows one repair waiting, a clear repair headline, the selected vs better answer, a short why line, signal chips, and a direct `Repair this clue` CTA.

This lane did not prove a repaired or clean Review state. The current `first_week_review` capture remains an open-repair proof state, so exact repaired-proof commercial evidence is still a capture coverage gap, not a product blocker from this screenshot.

## Profile Findings

Profile is valid English commercial proof. `Your progress rhythm`, `Progress proof`, `3 day streak`, and `28 tasks complete` make the return rhythm legible without over-claiming.

The lower proof grid continues below the fold, but the first viewport communicates level, streak, lesson progress, next milestone, and rhythm without obvious overlap.

## Runout Comparison

From the visible evidence in this pack only:

- Runout-like strength Sharky now covers: calm premium shells, clear first-week rhythm, compact status cards, and product-native training CTAs.
- Sharky differentiator: deterministic table-clue language and repair loop proof. Practice completion and Review repair are more learning-specific than generic progress packaging.
- Remaining Runout-style gap: ceremony and visual polish around completion still feel quieter than a market-leading result moment. Sharky is truthful and clear; it is not yet especially memorable.

## Blockers vs Acceptable Polish

Blockers:

- None found in the captured compact English product surfaces.

Acceptable polish:

- Home checklist density can be reduced later if it competes with the hero.
- Review needs a separate exact repaired/clean proof lane if commercial proof requires that state.
- Practice completion could gain a slightly stronger result ceremony later, but current CTA truth is correct.
- Profile lower proof tiles extend below the fold; acceptable for compact portrait.

## Recommended Next Implementation Wave

Run `Result Ceremony Visual Uplift v1`.

Scope should stay bounded to the completed Practice/session result state and possibly the matching Home completed return line. Do not change the daily logic, repair resolver, table geometry, commerce, or localization. The goal is not new copy truth; it is making the already truthful completion moment feel more premium and memorable.

## Direction Score

Current direction: **8.7 / 10**.

The product surfaces now pass compact English commercial proof for Home, Practice completion, Review open repair, and Profile. The main gap is not truth or route clarity; it is ceremony and final-state visual memorability.


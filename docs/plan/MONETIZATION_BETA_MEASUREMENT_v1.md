# What beta must measure · B149

Free beta (PLAN M1/B0/Q2). Use only voluntarily shared **You → Settings → Beta
activity → Copy summary** and consented manual observations. No new telemetry,
remote collection, purchases or identifiers. Denominator: consenting first-open
installations, not people; report sample size, missing shares and censoring.

| Simulator input / check | Existing evidence and calculation | Availability |
|---|---|---|
| `daily_lessons` | `Beta day 0..7: N lessons` (`recordLesson`, unique IDs) / observed active days, including zero-lesson active days. Summary cannot establish every active day; manually observe missing activity or bound the estimate. | First week |
| `d1_retention` | `Day 2: returned/missed/pending` (`recordVisit`), [24,48) h; returned / closed windows. | Direct |
| `d7_retention` | `Day 7` = [144,168) h (elapsed D6), not D7 [168,192). Label proxy or manually observe exact D7. | Proxy |
| `d30_retention` | Summary caps at day 7; manually observe launch/foreground in [720,744) h. | Otherwise assumed |
| `practice_participation` | Share of active installs with any `Beta day N: practice steps` (`recordPracticeStep`) or observed Daily Practice use. | First-week proxy |
| `practice_repeat_day` | `practice_started` / `practice_completed` (`practiceGroupId: daily`) show use, not novelty. Observe existing repeat/exhaustion message or repeated canonical task/recipe identity; first age-day of unwanted repetition, not spaced repair. Censor never-seen. | Manual; no repeat-day export |
| `persistent_activity_fraction`, `post_d30_half_life_days` | Day 2/7 flags and daily counts give partial joint activity; longitudinal consented return observations estimate correlation/decay. | Otherwise assumed |
| `bankroll_pace_fraction` | Lesson pace, `Completed route practice steps`, `After a mistake`, `Corrected mistakes` show burden, not response to nonexistent credits. | Counterfactual |
| `trial_to_paid`, `offer_to_trial`, `wall_offer_to_paid`, `bankroll_offer_to_paid`, `practice_offer_to_paid`, `monthly_price_usd`, `monthly_churn`, `trial_days` | No paid/trial/renewal event; existing five survey questions are not WTP. Consented owner discussions can establish stated preferences only. Price/duration are scenario choices; real conversion/churn require approved later evidence. | Assumed |
| Learning guard / W12 | `Farthest lesson reached`, `Completed lessons`, independent vs assisted answers, W1 check, `Day 7 new review`, repair outcomes and five B0 questions. W12 share of eligible installs; separately compare proxy unlock, mastery and hypothetical repair access. | W12 may be immature; no causal paid impact |

**Handoff:** report numerator, denominator, missing/censored count, build and
window; copy JSON and mark only supported ranges `measured` with provenance.
Keep other inputs `assumed`, run comparison and vary one input at a time. Compare
with free control and B0 learning thresholds; stated intent is not actual WTP.

Sources: [RELEASE beta protocol](../RELEASE.md), `act0_beta_metrics_v1.dart`,
`act0_shell_preview_telemetry_v1.dart`, `act0_shell_preview_home_v1.dart` and
`act0_shell_preview_persistence_v1.dart` (existing Act0 owners; local only).
